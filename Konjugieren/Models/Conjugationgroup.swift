// Copyright © 2026 Josh Adams. All rights reserved.

enum Conjugationgroup: Hashable {
  case perfektpartizip
  case präsenspartizip

  case präsensIndicativ(_ personNumber: PersonNumber)
  case präsensKonjunktivI(_ personNumber: PersonNumber)
  case präteritumIndicativ(_ personNumber: PersonNumber)
  case präteritumKonditional(_ personNumber: PersonNumber)
  case imperativ(_ personNumber: PersonNumber)

  case perfektIndikativ(_ personNumber: PersonNumber)
  case perfektKonjunktivI(_ personNumber: PersonNumber)

  case plusquamperfektIndikativ(_ personNumber: PersonNumber)
  case plusquamperfektKonditional(_ personNumber: PersonNumber)
  case futurIndikativ(_ personNumber: PersonNumber)
  case futurKonjunktivI(_ personNumber: PersonNumber)
  case futurKonditional(_ personNumber: PersonNumber)

  var germanDisplayName: String {
    switch self {
    case .präsenspartizip:
      return "Präsens Partizip"
    case .perfektpartizip:
      return "Perfekt Partizip"
    case .präsensIndicativ:
      return "Präsens Indikativ"
    case .präsensKonjunktivI:
      return "Präsens Konjunktiv I"
    case .präteritumIndicativ:
      return "Präteritum Indikativ"
    case .präteritumKonditional:
      return "Präteritum Konditional"
    case .imperativ:
      return "Imperativ"
    case .perfektIndikativ:
      return "Perfekt Indikativ"
    case .perfektKonjunktivI:
      return "Perfekt Konjunktiv I"
    case .plusquamperfektIndikativ:
      return "Plusquamperfekt Indikativ"
    case .plusquamperfektKonditional:
      return "Plusquamperfekt Konditional"
    case .futurIndikativ:
      return "Futur Indikativ"
    case .futurKonjunktivI:
      return "Futur Konjunktiv I"
    case .futurKonditional:
      return "Futur Konditional"
    }
  }

  var englishDisplayName: String {
    switch self {
    case .präsenspartizip:
      return "Present Participle"
    case .perfektpartizip:
      return "Past Participle"
    case .präsensIndicativ:
      return "Present Indicative"
    case .präsensKonjunktivI:
      return "Present Subjunctive"
    case .präteritumIndicativ:
      return "Past Indicative"
    case .präteritumKonditional:
      return "Past Conditional"
    case .imperativ:
      return "Imperative"
    case .perfektIndikativ:
      return "Present Perfect Indicative"
    case .perfektKonjunktivI:
      return "Present Perfect Subjunctive"
    case .plusquamperfektIndikativ:
      return "Pluperfect Indicative"
    case .plusquamperfektKonditional:
      return "Pluperfect Conditional"
    case .futurIndikativ:
      return "Future Indicative"
    case .futurKonjunktivI:
      return "Future Subjunctive"
    case .futurKonditional:
      return "Future Conditional"
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
      case .firstSingular, .secondSingular, .thirdSingular:
        return ""
      case .secondPlural:
        return "t"
      case .firstPlural, .thirdPlural:
        return "en"
      }
    case .perfektIndikativ, .perfektKonjunktivI, .plusquamperfektIndikativ, .plusquamperfektKonditional, .futurIndikativ, .futurKonjunktivI, .futurKonditional:
      fatalError("ending() was called for a compound tense. This is a logic error.")
    }
  }
}
