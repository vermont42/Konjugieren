// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

// Harness: exports every verb's page (conjugations, etymology, example sentences, metadata) as
// pretty-printed JSON, which scripts/generate_verb_pdf.py turns into a PDF. It reads
// /tmp/konjugieren-export.json by default, so run:
//
//   TEST_RUNNER_KONJUGIEREN_EXPORT_OUT=/tmp/konjugieren-export.json \
//   xcodebuild … -only-testing:KonjugierenTests/VerbExportTests
//
// TEST_RUNNER_KONJUGIEREN_EXPORT_ONLY, a comma-separated list of infinitives (abbauen,gehen),
// limits the export to those verbs. xcodebuild forwards a variable into the simulator only with
// the TEST_RUNNER_ prefix, which it strips, so the bare name leaves the suite skipped and green.
//
// Ungated, the export of all 3,572 verbs took about 200 of the suite's 215 seconds, and it wrote
// to a uniquely named temporary file that nothing read. Gated on 2026-11-12, at Josh's request.
//
// The export calls Conjugator directly, so separable verbs come out joined (anfängt), not as the
// verb page shows them since Phase 4 of the browse plan (fängt an).
@Suite("VerbExport", .enabled(if: ProcessInfo.processInfo.environment["KONJUGIEREN_EXPORT_OUT"] != nil))
@MainActor
struct VerbExportTests {
  // Conjugationgroup factories in VerbView display order (excluding partizipien)
  private static let conjugationgroupFactories: [(String, (PersonNumber) -> Conjugationgroup)] = [
    ("präsensIndikativ", Conjugationgroup.präsensIndikativ),
    ("präteritumIndikativ", Conjugationgroup.präteritumIndikativ),
    ("präsensKonjunktivI", Conjugationgroup.präsensKonjunktivI),
    ("präteritumKonjunktivII", Conjugationgroup.präteritumKonjunktivII),
    ("imperativ", Conjugationgroup.imperativ),
    ("perfektIndikativ", Conjugationgroup.perfektIndikativ),
    ("perfektKonjunktivI", Conjugationgroup.perfektKonjunktivI),
    ("plusquamperfektIndikativ", Conjugationgroup.plusquamperfektIndikativ),
    ("plusquamperfektKonjunktivII", Conjugationgroup.plusquamperfektKonjunktivII),
    ("futurIndikativ", Conjugationgroup.futurIndikativ),
    ("futurKonjunktivI", Conjugationgroup.futurKonjunktivI),
    ("futurKonjunktivII", Conjugationgroup.futurKonjunktivII)
  ]

  @Test func exportVerbs() throws {
    let environment = ProcessInfo.processInfo.environment
    let outputURL = URL(fileURLWithPath: try #require(environment["KONJUGIEREN_EXPORT_OUT"]))
    let only = environment["KONJUGIEREN_EXPORT_ONLY"].map { Set($0.split(separator: ",").map(String.init)) }
    let infinitives = Verb.verbs.keys.sorted().filter { only?.contains($0) ?? true }
    // A misspelled filter would otherwise write an empty array and pass.
    #expect(!infinitives.isEmpty, "No verb matched KONJUGIEREN_EXPORT_ONLY")
    let exported = infinitives.compactMap { Verb.verbs[$0] }.map { exportVerb($0) }
    try writeJSON(exported, to: outputURL)
  }

  private func exportVerb(_ verb: Verb) -> ExportedVerb {
    var conjugations: [String: AnyCodable] = [:]

    conjugations["perfektpartizip"] = AnyCodable(conjugate(verb: verb, group: .perfektpartizip))
    conjugations["präsenspartizip"] = AnyCodable(conjugate(verb: verb, group: .präsenspartizip))

    for (key, factory) in Self.conjugationgroupFactories {
      if key == "imperativ" {
        let rows = PersonNumber.imperativPersonNumbers.map { pn -> ExportedImperativRow in
          let form = conjugate(verb: verb, group: factory(pn))
          let pronoun: String? = switch pn {
          case .secondSingular:
            "du"
          case .secondPlural:
            "ihr"
          case .firstPlural, .thirdPlural, .firstSingular, .thirdSingular:
            nil
          }
          return ExportedImperativRow(pronoun: pronoun, form: form)
        }
        conjugations[key] = AnyCodable(rows)
      } else {
        let forms = PersonNumber.allCases.map { pn in
          conjugate(verb: verb, group: factory(pn))
        }
        conjugations[key] = AnyCodable(forms)
      }
    }

    let etymology = loadEtymology(for: verb.infinitiv, language: "en")

    let pair = ExampleSentences.pair(for: verb.infinitiv)
    let exampleSentences: ExportedExampleSentences? = pair.map {
      ExportedExampleSentences(
        de: ExportedSentence(sentence: $0.german.sentence, source: $0.german.source),
        en: ExportedSentence(sentence: $0.english.sentence, source: $0.english.source)
      )
    }

    let (prefixType, prefixValue): (String, String?) = switch verb.prefix {
    case .separable(let p):
      ("separable", p)
    case .inseparable(let p):
      ("inseparable", p)
    case .none:
      ("none", nil)
    }

    let familyName: String = switch verb.family {
    case .strong:
      "strong"
    case .mixed:
      "mixed"
    case .weak:
      "weak"
    case .ieren:
      "ieren"
    }

    return ExportedVerb(
      infinitiv: verb.infinitiv,
      translation: verb.translation,
      family: familyName,
      ablautGroup: verb.ablautGroup,
      auxiliary: verb.auxiliary.verb,
      frequency: verb.frequency,
      hits: verb.hits,
      prefix: prefixType,
      prefixValue: prefixValue,
      conjugations: conjugations,
      etymology: etymology,
      exampleSentences: exampleSentences
    )
  }

  private func conjugate(verb: Verb, group: Conjugationgroup) -> String {
    switch Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: group) {
    case .success(let form):
      return form
    case .failure:
      return "—"
    }
  }

  private func loadEtymology(for infinitiv: String, language: String) -> String? {
    guard
      let url = Bundle.main.url(forResource: "Etymologies", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let file = try? JSONDecoder().decode([String: [String: String]].self, from: data),
      let langSection = file[language]
    else {
      return nil
    }
    return langSection[infinitiv]
  }

  private func writeJSON(_ verbs: [ExportedVerb], to url: URL) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(verbs)
    try data.write(to: url)
  }
}

private struct ExportedVerb: Encodable {
  let infinitiv: String
  let translation: String
  let family: String
  let ablautGroup: String?
  let auxiliary: String
  /// Dense corpus rank, 1 = most common. `hits` is the raw DWDS count it is derived from;
  /// both ship because a consumer re-ranking a subset needs the count, not the rank.
  let frequency: Int
  let hits: Int
  let prefix: String
  let prefixValue: String?
  let conjugations: [String: AnyCodable]
  let etymology: String?
  let exampleSentences: ExportedExampleSentences?
}

private struct ExportedImperativRow: Encodable {
  let pronoun: String?
  let form: String
}

private struct ExportedExampleSentences: Encodable {
  let de: ExportedSentence
  let en: ExportedSentence
}

private struct ExportedSentence: Encodable {
  let sentence: String
  let source: String
}

private enum AnyCodable: Encodable {
  case string(String)
  case stringArray([String])
  case imperativ([ExportedImperativRow])

  init(_ value: String) {
    self = .string(value)
  }

  init(_ value: [String]) {
    self = .stringArray(value)
  }

  init(_ value: [ExportedImperativRow]) {
    self = .imperativ(value)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let value):
      try container.encode(value)
    case .stringArray(let value):
      try container.encode(value)
    case .imperativ(let value):
      try container.encode(value)
    }
  }
}
