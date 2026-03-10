// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite("VerbExport")
@MainActor
struct VerbExportTests {
  private static let outputPath = "/tmp/konjugieren-export.json"

  // Conjugationgroup factories in VerbView display order (excluding partizipien)
  private static let conjugationgroupFactories: [(String, (PersonNumber) -> Conjugationgroup)] = [
    ("präsensIndicativ", Conjugationgroup.präsensIndicativ),
    ("präteritumIndicativ", Conjugationgroup.präteritumIndicativ),
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

  @Test func exportAbbauen() throws {
    let verb = Verb.verbs["abbauen"]!
    let verbs = [exportVerb(verb)]
    try writeJSON(verbs)
  }

  @Test func exportAllVerbs() throws {
    let allVerbs = Verb.verbs.keys.sorted().compactMap { Verb.verbs[$0] }
    let exported = allVerbs.map { exportVerb($0) }
    try writeJSON(exported)
  }

  private func exportVerb(_ verb: Verb) -> ExportedVerb {
    var conjugations: [String: AnyCodable] = [:]

    // Partizipien
    conjugations["perfektpartizip"] = AnyCodable(conjugate(verb: verb, group: .perfektpartizip))
    conjugations["präsenspartizip"] = AnyCodable(conjugate(verb: verb, group: .präsenspartizip))

    // All other conjugationgroups
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

    // Etymology (English)
    let etymology = loadEtymology(for: verb.infinitiv, language: "en")

    // Example sentences
    let pair = ExampleSentences.pair(for: verb.infinitiv)
    let exampleSentences: ExportedExampleSentences? = pair.map {
      ExportedExampleSentences(
        de: ExportedSentence(sentence: $0.german.sentence, source: $0.german.source),
        en: ExportedSentence(sentence: $0.english.sentence, source: $0.english.source)
      )
    }

    // Prefix
    let (prefixType, prefixValue): (String, String?) = switch verb.prefix {
    case .separable(let p):
      ("separable", p)
    case .inseparable(let p):
      ("inseparable", p)
    case .none:
      ("none", nil)
    }

    // Family
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

  private func writeJSON(_ verbs: [ExportedVerb]) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(verbs)
    try data.write(to: URL(fileURLWithPath: Self.outputPath))
  }
}

// MARK: - Encodable Structs

private struct ExportedVerb: Encodable {
  let infinitiv: String
  let translation: String
  let family: String
  let ablautGroup: String?
  let auxiliary: String
  let frequency: Int
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
