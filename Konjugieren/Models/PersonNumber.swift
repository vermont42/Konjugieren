// Copyright © 2025 Josh Adams. All rights reserved.

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
}
