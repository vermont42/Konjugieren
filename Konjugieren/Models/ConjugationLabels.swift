// Copyright © 2026 Josh Adams. All rights reserved.

// How the conjugation core's types read to the learner. These members depend on L or on
// Settings, so they live apart from the types themselves: the core files also compile into
// ConjugationMapTool, a macOS host tool that has neither.

extension Conjugationgroup {
  func displayName(lang: ConjugationgroupLang) -> String {
    switch lang {
    case .german:
      return germanDisplayName
    case .english:
      return englishDisplayName
    }
  }
}

extension Family {
  var displayName: String {
    switch self {
    case .strong:
      return L.Family.strong
    case .mixed:
      return L.Family.mixed
    case .weak:
      return L.Family.weak
    case .ieren:
      return L.Family.ieren
    }
  }
}

extension PersonNumber {
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
