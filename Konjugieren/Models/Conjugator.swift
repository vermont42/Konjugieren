// Copyright © 2025 Josh Adams. All rights reserved.

enum Conjugator {
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
    case .präsensIndicativ:
      let stamm = verb.stamm
      let ending = conjugationgroup.ending(family: verb.family)
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: conjugationgroup)
      return .success(isFullOverride ? newStamm : newStamm + ending)
    case .präsensKonjunktivI:
      let stamm = verb.stamm
      let ending = conjugationgroup.ending(family: verb.family)
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: conjugationgroup)
      return .success(isFullOverride ? newStamm : newStamm + ending)
    case .präteritumIndicativ:
      let stamm = verb.stamm
      let ending = conjugationgroup.ending(family: verb.family)
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: conjugationgroup)
      return .success(isFullOverride ? newStamm : newStamm + ending)
    case .präteritumKonditional:
      let stamm = verb.stamm
      let ending = conjugationgroup.ending(family: verb.family)
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: conjugationgroup)
      return .success(isFullOverride ? newStamm : newStamm + ending)
    case .perfektpartizip:
      let stamm = verb.stamm
      let ending = conjugationgroup.ending(family: verb.family)
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: conjugationgroup)
      if isFullOverride {
        return .success(newStamm)
      }
      switch verb.family {
      case .strong, .mixed, .weak:
        return .success(perfektpartizipWithGeAndPrefix(verb: verb, stamm: newStamm, ending: ending))
      case .ieren:
        return .success(newStamm + ending)
      }
    case .präsenspartizip:
      let stamm = verb.stamm
      let ending = conjugationgroup.ending(family: verb.family)
      return .success(stamm + ending)
    case .imperativ(let personNumber):
      return conjugateImperativ(verb: verb, personNumber: personNumber)
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
      let form = (newStamm != stamm ? newStamm : stamm) + "t"
      return .success(withSeparablePrefix(verb: verb, form: form))

    case .firstPlural:
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(.firstPlural))
      if isFullOverride {
        return .success(withSeparablePrefixAndPronoun(verb: verb, form: newStamm, pronoun: "wir"))
      }
      let (konjStamm, konjOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .präsensKonjunktivI(.firstPlural))
      let form: String
      if konjOverride {
        form = konjStamm
      } else {
        form = (konjStamm != stamm ? konjStamm : stamm) + "en"
      }
      return .success(withSeparablePrefixAndPronoun(verb: verb, form: form, pronoun: "wir"))

    case .thirdPlural:
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(.thirdPlural))
      if isFullOverride {
        return .success(withSeparablePrefixAndPronoun(verb: verb, form: newStamm, pronoun: "Sie"))
      }
      let (konjStamm, konjOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .präsensKonjunktivI(.thirdPlural))
      let form: String
      if konjOverride {
        form = konjStamm
      } else {
        form = (konjStamm != stamm ? konjStamm : stamm) + "en"
      }
      return .success(withSeparablePrefixAndPronoun(verb: verb, form: form, pronoun: "Sie"))

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
}
