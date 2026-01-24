// Copyright © 2026 Josh Adams. All rights reserved.

enum PersonNumber: String, CaseIterable {
  case firstSingular = "fs"
  case secondSingular = "ss"
  case thirdSingular = "ts"
  case firstPlural = "fp"
  case secondPlural = "sp"
  case thirdPlural = "tp"

  static let imperativPersonNumbers: [PersonNumber] = [.secondSingular, .secondPlural, .firstPlural, .thirdPlural]

  var pronoun: String {
    switch self {
    case .firstSingular:
      return "ich"
    case .secondSingular:
      return "du"
    case .thirdSingular:
      return Current.settings.thirdPersonPronounGender.pronoun
    case .firstPlural:
      return "wir"
    case .secondPlural:
      return "ihr"
    case .thirdPlural:
      return "sie"
    }
  }

  var pronounWithSieDisambiguation: String {
    let base = pronoun
    guard base == "sie" else { return base }
    switch self {
    case .thirdSingular:
      return "sie (3s)"
    case .thirdPlural:
      return "sie (3p)"
    default:
      return base
    }
  }
}
