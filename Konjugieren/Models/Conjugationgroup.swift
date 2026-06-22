// Copyright © 2026 Josh Adams. All rights reserved.

enum Conjugationgroup: Hashable {
  case perfektpartizip
  case präsenspartizip

  case präsensIndikativ(_ personNumber: PersonNumber)
  case präsensKonjunktivI(_ personNumber: PersonNumber)
  case präteritumIndikativ(_ personNumber: PersonNumber)
  case präteritumKonjunktivII(_ personNumber: PersonNumber)
  case imperativ(_ personNumber: PersonNumber)

  case perfektIndikativ(_ personNumber: PersonNumber)
  case perfektKonjunktivI(_ personNumber: PersonNumber)

  case plusquamperfektIndikativ(_ personNumber: PersonNumber)
  case plusquamperfektKonjunktivII(_ personNumber: PersonNumber)
  case futurIndikativ(_ personNumber: PersonNumber)
  case futurKonjunktivI(_ personNumber: PersonNumber)
  case futurKonjunktivII(_ personNumber: PersonNumber)

  var germanDisplayName: String {
    switch self {
    case .präsenspartizip:
      return "Präsenspartizip"
    case .perfektpartizip:
      return "Perfektpartizip"
    case .präsensIndikativ:
      return "Präsens Indikativ"
    case .präsensKonjunktivI:
      return "Präsens Konjunktiv I"
    case .präteritumIndikativ:
      return "Präteritum Indikativ"
    case .präteritumKonjunktivII:
      return "Präteritum Konjunktiv II"
    case .imperativ:
      return "Imperativ"
    case .perfektIndikativ:
      return "Perfekt Indikativ"
    case .perfektKonjunktivI:
      return "Perfekt Konjunktiv I"
    case .plusquamperfektIndikativ:
      return "Plusquamperfekt Indikativ"
    case .plusquamperfektKonjunktivII:
      return "Plusquamperfekt Konjunktiv II"
    case .futurIndikativ:
      return "Futur Indikativ"
    case .futurKonjunktivI:
      return "Futur Konjunktiv I"
    case .futurKonjunktivII:
      return "Futur Konjunktiv II"
    }
  }

  var englishDisplayName: String {
    switch self {
    case .präsenspartizip:
      return "Present Participle"
    case .perfektpartizip:
      return "Past Participle"
    case .präsensIndikativ:
      return "Present Indicative"
    case .präsensKonjunktivI:
      return "Present Subjunctive"
    case .präteritumIndikativ:
      return "Past Indicative"
    case .präteritumKonjunktivII:
      return "Past Conditional"
    case .imperativ:
      return "Imperative"
    case .perfektIndikativ:
      return "Present Perfect Indicative"
    case .perfektKonjunktivI:
      return "Present Perfect Subjunctive"
    case .plusquamperfektIndikativ:
      return "Pluperfect Indicative"
    case .plusquamperfektKonjunktivII:
      return "Pluperfect Conditional"
    case .futurIndikativ:
      return "Future Indicative"
    case .futurKonjunktivI:
      return "Future Subjunctive"
    case .futurKonjunktivII:
      return "Future Conditional"
    }
  }

  func displayName(lang: ConjugationgroupLang) -> String {
    switch lang {
    case .german:
      return germanDisplayName
    case .english:
      return englishDisplayName
    }
  }

  func ending(family: Family) -> String {
    switch self {
    case .präsensIndikativ(let personNumber):
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
    case .präteritumIndikativ(let personNumber):
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
        return Conjugationgroup.weakPräteritumEnding(personNumber: personNumber)
      }
    case .präteritumKonjunktivII(let personNumber):
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
        return Conjugationgroup.weakPräteritumEnding(personNumber: personNumber)
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
    case .perfektIndikativ, .perfektKonjunktivI, .plusquamperfektIndikativ, .plusquamperfektKonjunktivII, .futurIndikativ, .futurKonjunktivI, .futurKonjunktivII:
      Current.fatalError.fatalError("ending() was called for compound tense \(self.germanDisplayName). This is a logic error.")
      return ""
    }
  }

  private static func weakPräteritumEnding(personNumber: PersonNumber) -> String {
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
}
