// Copyright © 2025 Josh Adams. All rights reserved.

enum PräsensIndicativ {
  static func endingForPersonNumber(_ personNumber: PersonNumber) -> String {
    switch personNumber {
    case .firstSingular:
      return "e"
    case .secondSingular:
      return "st"
    case .thirdSingular:
      return "t"
    case .firstPlural:
      return "en"
    case .secondPlural:
      return "t"
    case .thirdPlural:
      return "en"
    }
  }
}
