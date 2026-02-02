// Copyright © 2026 Josh Adams. All rights reserved.

enum Conjugator {
  static func conjugateUnsafely(infinitiv: String, conjugationgroup: Conjugationgroup) -> String {
    let result = conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup)
    switch result {
    case .success(let conjugation):
      return conjugation
    case .failure(let error):
      Current.fatalError.fatalError("Conjugation of \(infinitiv) for conjugationgroup \(conjugationgroup) resulted in error \(error).")
      return ""
    }
  }

  static func conjugate(infinitiv: String, conjugationgroup: Conjugationgroup) -> Result<String, ConjugatorError> {
    guard infinitiv.count >= Verb.minVerbLength else {
      return .failure(.verbTooShort)
    }

    guard Verb.endingIsValid(infinitiv: infinitiv) else {
      return .failure(.infinitivEndingInvalid)
    }

    guard let verb = Verb.verbs[infinitiv] else {
      return .failure(.verbNotRecognized)
    }

    switch conjugationgroup {
    case .präsensIndicativ, .präsensKonjunktivI, .präteritumIndicativ, .präteritumKonjunktivII:
      let stamm = verb.stamm
      let ending = conjugationgroup.ending(family: verb.family)
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: conjugationgroup)
      if isFullOverride {
        return .success(newStamm)
      }
      let adjustedEnding = adjustEndingForPhonology(stamm: newStamm, ending: ending, family: verb.family, conjugationgroup: conjugationgroup)
      return .success(newStamm + adjustedEnding)

    case .perfektpartizip:
      let stamm = verb.stamm
      let ending = conjugationgroup.ending(family: verb.family)
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: conjugationgroup)
      if isFullOverride {
        return .success(newStamm)
      }
      let adjustedEnding = adjustPerfektpartizipEnding(stamm: newStamm, ending: ending, family: verb.family)
      switch verb.family {
      case .strong, .mixed, .weak:
        return .success(perfektpartizipWithGeAndPrefix(verb: verb, stamm: newStamm, ending: adjustedEnding))
      case .ieren:
        return .success(newStamm + adjustedEnding)
      }

    case .präsenspartizip:
      let stamm = verb.stamm
      let ending = conjugationgroup.ending(family: verb.family)
      return .success(stamm + ending)

    case .imperativ(let personNumber):
      return conjugateImperativ(verb: verb, personNumber: personNumber)

    case .perfektIndikativ(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: verb.auxiliary.verb, auxiliaryGroup: .präsensIndicativ(personNumber))

    case .perfektKonjunktivI(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: verb.auxiliary.verb, auxiliaryGroup: .präsensKonjunktivI(personNumber))

    case .plusquamperfektIndikativ(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: verb.auxiliary.verb, auxiliaryGroup: .präteritumIndicativ(personNumber))

    case .plusquamperfektKonjunktivII(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: verb.auxiliary.verb, auxiliaryGroup: .präteritumKonjunktivII(personNumber))

    case .futurIndikativ(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: "werden", auxiliaryGroup: .präsensIndicativ(personNumber), useInfinitivAsSecondPart: true)

    case .futurKonjunktivI(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: "werden", auxiliaryGroup: .präsensKonjunktivI(personNumber), useInfinitivAsSecondPart: true)

    case .futurKonjunktivII(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: "werden", auxiliaryGroup: .präteritumKonjunktivII(personNumber), useInfinitivAsSecondPart: true)
    }
  }

  private static func conjugateCompoundTense(
    verb: Verb,
    infinitiv: String,
    auxiliaryInfinitiv: String,
    auxiliaryGroup: Conjugationgroup,
    useInfinitivAsSecondPart: Bool = false
  ) -> Result<String, ConjugatorError> {
    let auxiliaryResult = conjugate(infinitiv: auxiliaryInfinitiv, conjugationgroup: auxiliaryGroup)

    let secondPartResult: Result<String, ConjugatorError>
    if useInfinitivAsSecondPart {
      secondPartResult = .success(infinitiv)
    } else {
      secondPartResult = conjugate(infinitiv: infinitiv, conjugationgroup: .perfektpartizip)
    }

    switch (auxiliaryResult, secondPartResult) {
    case (.success(let auxiliary), .success(let secondPart)):
      return .success(auxiliary + " " + secondPart)
    default:
      return .failure(.conjugationFailed)
    }
  }

  private static func conjugateImperativ(verb: Verb, personNumber: PersonNumber) -> Result<String, ConjugatorError> {
    let stamm = verb.stamm

    switch personNumber {
    case .secondSingular:
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(.secondSingular))
      if isFullOverride {
        return .success(withSeparablePrefix(verb: verb, form: newStamm))
      }

      let imperativStamm: String
      if newStamm != stamm {
        imperativStamm = newStamm
      } else {
        imperativStamm = applyEToIStemChange(stamm: stamm, verb: verb)
      }

      let needsE = imperativStamm.hasSuffix("d") || imperativStamm.hasSuffix("t")
      let form = needsE ? imperativStamm + "e" : imperativStamm
      return .success(withSeparablePrefix(verb: verb, form: form))

    case .secondPlural:
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(.secondPlural))
      if isFullOverride {
        return .success(withSeparablePrefix(verb: verb, form: newStamm))
      }
      return .success(withSeparablePrefix(verb: verb, form: newStamm + "t"))

    case .firstPlural, .thirdPlural:
      let pronoun = personNumber == .firstPlural ? "wir" : "Sie"
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(personNumber))
      if isFullOverride {
        return .success(withSeparablePrefixAndPronoun(verb: verb, form: newStamm, pronoun: pronoun))
      }
      let (konjStamm, konjOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .präsensKonjunktivI(personNumber))
      let form = konjOverride ? konjStamm : konjStamm + "en"
      return .success(withSeparablePrefixAndPronoun(verb: verb, form: form, pronoun: pronoun))

    case .firstSingular, .thirdSingular:
      return .failure(.personNumberNotSupported)
    }
  }

  private static func applyEToIStemChange(stamm: String, verb: Verb) -> String {
    switch verb.family {
    case .strong(ablautGroup: let ablautKey, ablautStartIndex: let ablautStartIndex, ablautEndIndex: let ablautEndIndex),
    .mixed(ablautGroup: let ablautKey, ablautStartIndex: let ablautStartIndex, ablautEndIndex: let ablautEndIndex):
      if
        let ablautGroup = AblautGroup.ablautGroups[ablautKey],
        let ablaut = ablautGroup.ablauts[.präsensIndicativ(.secondSingular)]
      {
        if ablaut.hasSuffix("*") {
          return stamm
        }

        let startIndex = stamm.index(stamm.startIndex, offsetBy: ablautStartIndex)
        let endIndex = stamm.index(stamm.startIndex, offsetBy: ablautEndIndex)
        let originalRegion = String(stamm[startIndex ..< endIndex])

        if originalRegion.hasPrefix("e") && ablaut.lowercased().hasPrefix("i") {
          var result = stamm
          result.replaceSubrange(startIndex ..< endIndex, with: ablaut)
          return result
        }
      }
      return stamm
    case .weak, .ieren:
      return stamm
    }
  }

  private static func withSeparablePrefix(verb: Verb, form: String) -> String {
    switch verb.prefix {
    case .separable(let prefix):
      let prefixlessForm = String(form.dropFirst(prefix.count))
      return prefixlessForm + " " + prefix
    case .inseparable, .none:
      return form
    }
  }

  private static func withSeparablePrefixAndPronoun(verb: Verb, form: String, pronoun: String) -> String {
    switch verb.prefix {
    case .separable(let prefix):
      let prefixlessForm = String(form.dropFirst(prefix.count))
      return prefixlessForm + " " + pronoun + " " + prefix
    case .inseparable, .none:
      return form + " " + pronoun
    }
  }

  private static func applyAblaut(stamm: String, verb: Verb, conjugationgroup: Conjugationgroup) -> (stamm: String, isFullOverride: Bool) {
    switch verb.family {
    case .strong(ablautGroup: let ablautKey, ablautStartIndex: let ablautStartIndex, ablautEndIndex: let ablautEndIndex),
    .mixed(ablautGroup: let ablautKey, ablautStartIndex: let ablautStartIndex, ablautEndIndex: let ablautEndIndex):
      if
        let ablautGroup = AblautGroup.ablautGroups[ablautKey],
        let ablaut = ablautGroup.ablauts[conjugationgroup]
      {
        if ablaut.hasSuffix("*") {
          let overrideValue = String(ablaut.dropLast())
          return (overrideValue, true)
        }

        var result = stamm
        let startIndex = result.index(result.startIndex, offsetBy: ablautStartIndex)
        let endIndex = result.index(result.startIndex, offsetBy: ablautEndIndex)
        result.replaceSubrange(startIndex ..< endIndex, with: ablaut)
        return (result, false)
      }
      return (stamm, false)
    case .weak, .ieren:
      return (stamm, false)
    }
  }

  private static func perfektpartizipWithGeAndPrefix(verb: Verb, stamm: String, ending: String) -> String {
    switch verb.prefix {
    case .separable(let prefix):
      let prefixlessStamm = String(stamm.dropFirst(prefix.count))
      return prefix + "ge" + prefixlessStamm + ending
    case .inseparable:
      return stamm + ending
    case .none:
      return "ge" + stamm + ending
    }
  }

  private static func adjustPerfektpartizipEnding(stamm: String, ending: String, family: Family) -> String {
    guard ending == "t" else { return ending }
    let lastChar = stamm.last.map { String($0).lowercased() } ?? ""
    if ["t", "d"].contains(lastChar) {
      switch family {
      case .weak, .mixed, .ieren:
        return "et"
      case .strong:
        return ending
      }
    }
    return ending
  }

  private static func adjustEndingForPhonology(stamm: String, ending: String, family: Family, conjugationgroup: Conjugationgroup) -> String {
    let lastChar = stamm.last.map { String($0).lowercased() } ?? ""

    if ending == "st" && ["s", "ß", "x", "z"].contains(lastChar) {
      return "t"
    }

    if ending == "t" && lastChar == "t" {
      return ""
    }

    if ["t", "d"].contains(lastChar) {
      switch family {
      case .weak, .mixed, .ieren:
        switch conjugationgroup {
        case .präteritumIndicativ, .präteritumKonjunktivII:
          if ["te", "test", "ten", "tet"].contains(ending) {
            return "e" + ending
          }
        case .präsensIndicativ(let pn), .präsensKonjunktivI(let pn):
          if pn == .secondSingular && ending == "st" {
            return "est"
          }
          if [.thirdSingular, .secondPlural].contains(pn) && ending == "t" {
            return "et"
          }
        default:
          break
        }
      case .strong:
        break
      }
    }

    return ending
  }
}
