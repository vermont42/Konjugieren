// Copyright © 2026 Josh Adams. All rights reserved.

// The --cells-json output: every one-word conjugation of every verb, with the conjugationgroup
// it belongs to. scripts/count_conjugationgroups.py reads it to count how often each
// conjugationgroup occurs in the text corpus, which orders the verb page's sections. See
// docs/conjugationgroup-frequency.md.
//
// The shape is form → [[group, infinitive, auxiliary], …], with the form lowercased:
//
//   "ging": [["praeteritumIndikativ", "gehen", "s"], …]
//   "gegangen": [["perfektpartizip", "gehen", "s"]]
//
// `group` is one of the keys in `groupKeys` below, plus "infinitiv". `auxiliary` is "h", "s",
// or "hs" for a reading whose auxiliary varies by region (stehen); the counter needs it to tell
// a Perfekt (ist gegangen) from a Zustandspassiv (ist gemacht), which look alike.
//
// Unlike the conjugation map, this records the finite part a main clause leaves (fängt, from
// "fängt … an") under the same group as the joined conjugation (anfängt), because the counter
// asks only which conjugationgroup a word is, never which verb.

import Foundation

enum CellsJSON {
  private static let finiteGroups: [(key: String, factory: (PersonNumber) -> Conjugationgroup)] = [
    ("praesensIndikativ", Conjugationgroup.präsensIndikativ),
    ("praesensKonjunktivI", Conjugationgroup.präsensKonjunktivI),
    ("praeteritumIndikativ", Conjugationgroup.präteritumIndikativ),
    ("praeteritumKonjunktivII", Conjugationgroup.präteritumKonjunktivII),
  ]

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
        if let participle = conjugate(.perfektpartizip, .subordinate) {
          add(participle, "perfektpartizip", infinitiv, auxiliary)
        }
        if let participle = conjugate(.präsenspartizip, .subordinate) {
          add(participle, "praesenspartizip", infinitiv, auxiliary)
        }
        for (key, factory) in finiteGroups {
          for personNumber in PersonNumber.allCases {
            if let joined = conjugate(factory(personNumber), .subordinate) {
              add(joined, key, infinitiv, auxiliary)
            }
            if let main = conjugate(factory(personNumber), .main), let head = main.split(separator: " ").first {
              add(head, key, infinitiv, auxiliary)
            }
          }
        }
        for personNumber in imperativPersonNumbers {
          if let imperativ = conjugate(.imperativ(personNumber), .main), let head = imperativ.split(separator: " ").first {
            add(head, "imperativ", infinitiv, auxiliary)
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
