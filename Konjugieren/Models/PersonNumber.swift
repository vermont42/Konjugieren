// Copyright © 2026 Josh Adams. All rights reserved.

enum PersonNumber: String, CaseIterable {
  case firstSingular = "fs"
  case secondSingular = "ss"
  case thirdSingular = "ts"
  case firstPlural = "fp"
  case secondPlural = "sp"
  case thirdPlural = "tp"

  static let imperativPersonNumbers: [PersonNumber] = [.secondSingular, .secondPlural, .firstPlural, .thirdPlural]

  var imperativPronoun: String? {
    switch self {
    case .secondSingular:
      return "du"
    case .secondPlural:
      return "ihr"
    case .firstPlural:
      return "wir"
    case .thirdPlural:
      return "Sie"
    case .firstSingular, .thirdSingular:
      return nil
    }
  }
}
