// Copyright © 2026 Josh Adams. All rights reserved.

// The --cells-json output: every one-word conjugation of every verb, with the conjugationgroup
// it belongs to. scripts/count_conjugationgroups.py reads it to count how often each
// conjugationgroup occurs in the text corpus, which orders the verb page's sections. See
// docs/conjugationgroup_frequency.md.
//
// The shape is form → [[group, infinitive, auxiliary], …], with the form lowercased:
//
//   "ging": [["praeteritumIndikativ", "gehen", "s"], …]
//   "gegangen": [["perfektpartizip", "gehen", "s"]]
//
// `group` is a conjugationgroup's name as `key(for:)` below spells it, or "infinitiv". `auxiliary` is "h", "s",
// or "hs" for a reading whose auxiliary varies by region (stehen); the counter needs it to tell
// a Perfekt (ist gegangen) from a Zustandspassiv (ist gemacht), which look alike.
//
// Unlike the conjugation map, this records the finite part a main clause leaves (fängt, from
// "fängt … an") under the same group as the joined conjugation (anfängt), because the counter
// asks only which conjugationgroup a word is, never which verb.

import Foundation

enum CellsJSON {
  /// The name the counter reads, in ASCII because scripts/count_conjugationgroups.py matches
  /// these strings literally. Only the simple conjugationgroups are written, but the switch
  /// names them all so that a new case cannot go unnamed.
  private static func key(for group: Conjugationgroup) -> String {
    switch group {
    case .perfektpartizip:
      return "perfektpartizip"
    case .präsenspartizip:
      return "praesenspartizip"
    case .präsensIndikativ:
      return "praesensIndikativ"
    case .präsensKonjunktivI:
      return "praesensKonjunktivI"
    case .präteritumIndikativ:
      return "praeteritumIndikativ"
    case .präteritumKonjunktivII:
      return "praeteritumKonjunktivII"
    case .imperativ:
      return "imperativ"
    case .perfektIndikativ:
      return "perfektIndikativ"
    case .perfektKonjunktivI:
      return "perfektKonjunktivI"
    case .plusquamperfektIndikativ:
      return "plusquamperfektIndikativ"
    case .plusquamperfektKonjunktivII:
      return "plusquamperfektKonjunktivII"
    case .futurIndikativ:
      return "futurIndikativ"
    case .futurKonjunktivI:
      return "futurKonjunktivI"
    case .futurKonjunktivII:
      return "futurKonjunktivII"
    }
  }

  /// Only the du and ihr Imperativ: the wir and Sie Imperativ (gehen wir, gehen Sie) are the
  /// infinitive in a different word order, and the counter cannot tell them apart by spelling.
  private static let imperativPersonNumbers: [PersonNumber] = [.secondSingular, .secondPlural]

  @MainActor static func data() throws -> Data {
    var rows: [String: Set<[String]>] = [:]
    func add(_ form: some StringProtocol, _ group: String, _ infinitiv: String, _ auxiliary: String) {
      let key = form.lowercased()
      guard !key.isEmpty, !key.contains(" ") else {
        return
      }
      rows[key, default: []].insert([group, infinitiv, auxiliary])
    }

    for infinitiv in Verb.verbs.keys.sorted() {
      guard let verb = Verb.verbs[infinitiv] else {
        continue
      }
      for (readingIndex, reading) in verb.readings.enumerated() {
        let auxiliary = reading.auxiliaryIsRegional ? "hs" : reading.auxiliary.rawValue
        func conjugate(_ group: Conjugationgroup, _ clause: Clause) -> String? {
          try? Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: group, readingIndex: readingIndex, clause: clause).get()
        }

        add(reading.infinitiv, "infinitiv", infinitiv, auxiliary)
        for group in [Conjugationgroup.perfektpartizip, .präsenspartizip] {
          if let participle = conjugate(group, .subordinate) {
            add(participle, key(for: group), infinitiv, auxiliary)
          }
        }
        for personNumber in PersonNumber.allCases {
          for group in Conjugationgroup.oneWordFinites(for: personNumber) {
            if let joined = conjugate(group, .subordinate) {
              add(joined, key(for: group), infinitiv, auxiliary)
            }
            if let main = conjugate(group, .main), let head = main.split(separator: " ").first {
              add(head, key(for: group), infinitiv, auxiliary)
            }
          }
        }
        for personNumber in imperativPersonNumbers {
          let group = Conjugationgroup.imperativ(personNumber)
          if let imperativ = conjugate(group, .main), let head = imperativ.split(separator: " ").first {
            add(head, key(for: group), infinitiv, auxiliary)
          }
        }
      }
    }

    let sorted = rows.mapValues { $0.sorted { $0.lexicographicallyPrecedes($1) } }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    return try encoder.encode(sorted)
  }
}
