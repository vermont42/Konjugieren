// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// Every one-word conjugation of every verb, mapped to the verbs it belongs to, so that search
/// can start from a conjugation: ging finds gehen.
///
/// ConjugationMapTool builds the map at build time and writes it into the app bundle, and the
/// app reads that copy. The tool compiles this file and the conjugation core from the app's own
/// sources, so the two cannot disagree; see docs/feature-architecture.md § Conjugation Map.
///
/// Compound conjugations have no entries, because their parts already do: hat gefunden resolves
/// through gefunden. Entries for haben and werden would otherwise attach to every verb.
nonisolated struct ConjugationMap: Equatable, Sendable {
  nonisolated struct Entry: Hashable, Sendable {
    let infinitiv: String

    /// The separable prefix that a main clause sends to its end, when the conjugation is only
    /// the finite part left behind: halte, from "ich halte mich auf", is aufhalten's with the
    /// particle auf. Nil when the conjugation is the whole verb.
    let particle: String?
  }

  static let resourceName = "ConjugationMap"
  static let resourceExtension = "lzfse"

  /// Keys are lowercase, because the Conjugator marks ablaut in uppercase (sAng), and that
  /// casing is highlighting rather than spelling. Within a key, whole-verb entries come
  /// before finite parts, and each kind is alphabetical.
  let entriesByConjugation: [String: [Entry]]

  init(entriesByConjugation: [String: [Entry]]) {
    self.entriesByConjugation = entriesByConjugation
  }

  func entries(for conjugation: String) -> [Entry] {
    entriesByConjugation[conjugation.lowercased()] ?? []
  }

  /// The copy in the app bundle, loaded on first use. Loading takes a moment, so a caller on
  /// the main actor may want to touch it first from a background task. Empty if the file is
  /// missing, which `ConjugationMapTests` would catch.
  static let bundled: ConjugationMap = {
    guard
      let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension),
      let data = try? Data(contentsOf: url),
      let map = try? ConjugationMap(compressed: data)
    else {
      return ConjugationMap(entriesByConjugation: [:])
    }
    return map
  }()
}

// The bundled file is this text, compressed with LZFSE: 1.4 MB becomes about 160 KB.
nonisolated extension ConjugationMap {
  /// One line per conjugation, in sorted order: the conjugation, then a tab before each entry.
  /// An entry is an infinitive, followed by a space and the particle when it has one.
  ///
  ///     fängt	fangen	anfangen an
  var text: String {
    entriesByConjugation.keys.sorted().map { conjugation in
      let entries = entriesByConjugation[conjugation] ?? []
      let fields = entries.map { entry in
        entry.particle.map { "\(entry.infinitiv) \($0)" } ?? entry.infinitiv
      }
      return ([conjugation] + fields).joined(separator: "\t")
    }
    .joined(separator: "\n")
  }

  init(text: String) {
    var entriesByConjugation: [String: [Entry]] = [:]
    for line in text.split(separator: "\n") {
      let fields = line.split(separator: "\t")
      guard let conjugation = fields.first else {
        continue
      }
      entriesByConjugation[String(conjugation)] = fields.dropFirst().map { field in
        let parts = field.split(separator: " ", maxSplits: 1)
        return Entry(infinitiv: String(parts[0]), particle: parts.count > 1 ? String(parts[1]) : nil)
      }
    }
    self.init(entriesByConjugation: entriesByConjugation)
  }

  func compressed() throws -> Data {
    try (Data(text.utf8) as NSData).compressed(using: .lzfse) as Data
  }

  init(compressed data: Data) throws {
    let decompressed = try (data as NSData).decompressed(using: .lzfse) as Data
    self.init(text: String(decoding: decompressed, as: UTF8.self))
  }
}

extension ConjugationMap {
  /// The four conjugationgroups whose conjugations are one finite word, and which therefore
  /// strand a separable prefix in a main clause.
  private static let finiteFactories: [(PersonNumber) -> Conjugationgroup] = [
    Conjugationgroup.präsensIndikativ,
    Conjugationgroup.präsensKonjunktivI,
    Conjugationgroup.präteritumIndikativ,
    Conjugationgroup.präteritumKonjunktivII,
  ]

  /// Builds the map from `Verb.verbs` and `AblautGroup.ablautGroups`, which must be loaded.
  ///
  /// Every reading counts, because readings differ in family and so in conjugations: hängen is
  /// both hing and hängte.
  @MainActor static func build() -> ConjugationMap {
    var builder = Builder()
    for infinitiv in Verb.verbs.keys.sorted() {
      guard let verb = Verb.verbs[infinitiv] else {
        continue
      }
      for readingIndex in verb.readings.indices {
        builder.addConjugations(of: verb, readingIndex: readingIndex)
      }
    }
    return builder.finished()
  }

  private struct Builder {
    private var entriesByConjugation: [String: [Entry]] = [:]
    private var seen: Set<String> = []

    @MainActor mutating func addConjugations(of verb: Verb, readingIndex: Int) {
      guard let reading = verb.reading(at: readingIndex) else {
        return
      }
      let infinitiv = verb.infinitiv
      let run = reading.prefixes.separableRun
      let particle = run.isEmpty ? nil : run

      add(reading.infinitiv, infinitiv: infinitiv, particle: nil)

      // The zu-infinitive is one word only when a separable prefix wraps the zu: anzufangen,
      // but "zu vermeiden", whose second word the infinitive already covers.
      if !run.isEmpty {
        add(run + "zu" + reading.infinitiv.dropFirst(run.count), infinitiv: infinitiv, particle: nil)
      }

      for group in [Conjugationgroup.perfektpartizip, .präsenspartizip] {
        if let conjugation = conjugate(infinitiv, group, readingIndex, .subordinate) {
          add(conjugation, infinitiv: infinitiv, particle: nil)
        }
      }

      for factory in ConjugationMap.finiteFactories {
        for personNumber in PersonNumber.allCases {
          let group = factory(personNumber)
          if let joined = conjugate(infinitiv, group, readingIndex, .subordinate) {
            add(joined, infinitiv: infinitiv, particle: nil)
          }
          if
            particle != nil,
            let main = conjugate(infinitiv, group, readingIndex, .main),
            let finitePart = main.split(separator: " ").first
          {
            add(finitePart, infinitiv: infinitiv, particle: particle)
          }
        }
      }

      // The Imperativ is split already (fang an) and may carry a pronoun (fangen wir an), so
      // only its first word is the verb.
      for personNumber in PersonNumber.imperativPersonNumbers {
        if
          let imperativ = conjugate(infinitiv, .imperativ(personNumber), readingIndex, .main),
          let head = imperativ.split(separator: " ").first
        {
          add(head, infinitiv: infinitiv, particle: particle)
        }
      }
    }

    @MainActor private func conjugate(_ infinitiv: String, _ group: Conjugationgroup, _ readingIndex: Int, _ clause: Clause) -> String? {
      try? Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: group, readingIndex: readingIndex, clause: clause).get()
    }

    private mutating func add(_ conjugation: some StringProtocol, infinitiv: String, particle: String?) {
      let key = conjugation.lowercased()
      let particle = particle?.lowercased()
      guard !key.isEmpty, seen.insert("\(key)|\(infinitiv)|\(particle ?? "")").inserted else {
        return
      }
      entriesByConjugation[key, default: []].append(Entry(infinitiv: infinitiv, particle: particle))
    }

    func finished() -> ConjugationMap {
      ConjugationMap(entriesByConjugation: entriesByConjugation.mapValues { entries in
        entries.sorted { lhs, rhs in
          (lhs.particle == nil) == (rhs.particle == nil) ? lhs.infinitiv < rhs.infinitiv : lhs.particle == nil
        }
      })
    }
  }
}
