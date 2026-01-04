// Copyright © 2025 Josh Adams. All rights reserved.

enum ConjugationGroup: Hashable {
  case perfektpartizip
  case präsenspartizip

  case präsensIndicativ(_ personNumber: PersonNumber)
  case präsensKonjunktivI(_ personNumber: PersonNumber)
  case präteritumIndicativ(_ personNumber: PersonNumber)
  case präteritumKonditional(_ personNumber: PersonNumber)
  case imperativ(_ personNumber: PersonNumber)

  var titleCaseName: String {
    switch self {
    case .präsenspartizip:
      return "Präsens Partizip"
    case .perfektpartizip:
      return "Perfekt Partizip"
    case .präsensIndicativ:
      return "Präsens Aktiv Indicativ"
    case .präsensKonjunktivI:
      return "Präsens Aktiv Konjunktiv I"
    case .präteritumIndicativ:
      return "Präteritum Aktiv Indicativ"
    case .präteritumKonditional:
      return "Präteritum Aktiv Konditional"
    case .imperativ:
      return "Imperativ"
    }
  }

  var displayName: String {
    switch self {
    case .präsenspartizip:
      return L.ConjugationGroup.präsenspartizip
    case .perfektpartizip:
      return L.ConjugationGroup.perfektpartizip
    case .präsensIndicativ:
      return L.ConjugationGroup.präsensIndicativ
    case .präsensKonjunktivI:
      return L.ConjugationGroup.präsensKonjunktivI
    case .präteritumIndicativ:
      return L.ConjugationGroup.präteritumIndicativ
    case .präteritumKonditional:
      return L.ConjugationGroup.präteritumKonditional
    case .imperativ:
      return L.ConjugationGroup.imperativ
    }
  }

  func ending(family: Family) -> String {
    switch self {
    case .präsensIndicativ(let personNumber):
      switch personNumber {
      case .firstSingular:
        return "e"
      case .secondSingular:
        return "st"
      case .thirdSingular, .secondPlural:
        return "t"
      case .firstPlural, .thirdPlural:
        return "en"
      }
    case .präsensKonjunktivI(let personNumber):
      switch personNumber {
      case .firstSingular, .thirdSingular:
        return "e"
      case .secondSingular:
        return "est"
      case .firstPlural, .thirdPlural:
        return "en"
      case .secondPlural:
        return "et"
      }
    case .präteritumIndicativ(let personNumber):
      switch family {
      case .strong:
        switch personNumber {
        case .firstSingular, .thirdSingular:
          return ""
        case .secondSingular:
          return "st"
        case .firstPlural, .thirdPlural:
          return "en"
        case .secondPlural:
          return "t"
        }
      case .weak, .mixed, .ieren:
        switch personNumber {
        case .firstSingular, .thirdSingular:
          return "te"
        case .secondSingular:
          return "test"
        case .firstPlural, .thirdPlural:
          return "ten"
        case .secondPlural:
          return "tet"
        }
      }
    case .präteritumKonditional(let personNumber):
      switch family {
      case .strong:
        switch personNumber {
        case .firstSingular, .thirdSingular:
          return "e"
        case .secondSingular:
          return "est"
        case .firstPlural, .thirdPlural:
          return "en"
        case .secondPlural:
          return "et"
        }
      case .weak, .mixed, .ieren:
        switch personNumber {
        case .firstSingular, .thirdSingular:
          return "te"
        case .secondSingular:
          return "test"
        case .firstPlural, .thirdPlural:
          return "ten"
        case .secondPlural:
          return "tet"
        }
      }
    case .perfektpartizip:
      switch family {
      case .strong:
        return "en"
      case .weak, .mixed, .ieren:
        return "t"
      }
    case .präsenspartizip:
      return "end"
    case .imperativ(let personNumber):
      switch personNumber {
      case .secondSingular:
        return ""
      case .secondPlural:
        return "t"
      case .firstPlural, .thirdPlural:
        return "en"
      case .firstSingular, .thirdSingular:
        return ""
      }
    }
  }
}
