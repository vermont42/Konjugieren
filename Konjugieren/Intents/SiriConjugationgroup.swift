// Copyright © 2025 Josh Adams. All rights reserved.

import AppIntents

enum SiriConjugationgroup: String, AppEnum {
  case perfektpartizip
  case präsenspartizip
  case präsensIndicativ
  case präsensKonjunktivI
  case präteritumIndicativ
  case präteritumKonjunktivII
  case imperativ
  case perfektIndikativ
  case perfektKonjunktivI
  case plusquamperfektIndikativ
  case plusquamperfektKonjunktivII
  case futurIndikativ
  case futurKonjunktivI
  case futurKonjunktivII

  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Conjugationgroup")

  static let caseDisplayRepresentations: [SiriConjugationgroup: DisplayRepresentation] = [
    .perfektpartizip: "Past Participle",
    .präsenspartizip: "Present Participle",
    .präsensIndicativ: "Present Indicative",
    .präsensKonjunktivI: "Present Subjunctive",
    .präteritumIndicativ: "Past Indicative",
    .präteritumKonjunktivII: "Past Conditional",
    .imperativ: "Imperative",
    .perfektIndikativ: "Present Perfect Indicative",
    .perfektKonjunktivI: "Present Perfect Subjunctive",
    .plusquamperfektIndikativ: "Pluperfect Indicative",
    .plusquamperfektKonjunktivII: "Pluperfect Conditional",
    .futurIndikativ: "Future Indicative",
    .futurKonjunktivI: "Future Subjunctive",
    .futurKonjunktivII: "Future Conditional",
  ]

  func conjugationgroups() -> [Conjugationgroup] {
    switch self {
    case .perfektpartizip:
      return [.perfektpartizip]
    case .präsenspartizip:
      return [.präsenspartizip]
    case .präsensIndicativ:
      return PersonNumber.allCases.map { .präsensIndicativ($0) }
    case .präsensKonjunktivI:
      return PersonNumber.allCases.map { .präsensKonjunktivI($0) }
    case .präteritumIndicativ:
      return PersonNumber.allCases.map { .präteritumIndicativ($0) }
    case .präteritumKonjunktivII:
      return PersonNumber.allCases.map { .präteritumKonjunktivII($0) }
    case .imperativ:
      return [.secondSingular, .secondPlural, .firstPlural, .thirdPlural].map { .imperativ($0) }
    case .perfektIndikativ:
      return PersonNumber.allCases.map { .perfektIndikativ($0) }
    case .perfektKonjunktivI:
      return PersonNumber.allCases.map { .perfektKonjunktivI($0) }
    case .plusquamperfektIndikativ:
      return PersonNumber.allCases.map { .plusquamperfektIndikativ($0) }
    case .plusquamperfektKonjunktivII:
      return PersonNumber.allCases.map { .plusquamperfektKonjunktivII($0) }
    case .futurIndikativ:
      return PersonNumber.allCases.map { .futurIndikativ($0) }
    case .futurKonjunktivI:
      return PersonNumber.allCases.map { .futurKonjunktivI($0) }
    case .futurKonjunktivII:
      return PersonNumber.allCases.map { .futurKonjunktivII($0) }
    }
  }
}
