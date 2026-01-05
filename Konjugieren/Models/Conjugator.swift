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
      // Check for explicit i2s override first
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(.secondSingular))
      if isFullOverride {
        return .success(withSeparablePrefix(verb: verb, form: newStamm))
      }

      // If no explicit imperativ ablaut, check for e→i/ie stem change from präsens.
      let imperativStamm: String
      if newStamm != stamm {
        // An imperativ-specific ablaut was applied.
        imperativStamm = newStamm
      } else {
        // Check for e→i/ie change from präsens a2s.
        imperativStamm = applyEToIStemChange(stamm: stamm, verb: verb)
      }

      // Stems ending in -d or -t need an -e for pronunciation.
      let needsE = imperativStamm.hasSuffix("d") || imperativStamm.hasSuffix("t")
      let form = needsE ? imperativStamm + "e" : imperativStamm
      return .success(withSeparablePrefix(verb: verb, form: form))

    case .secondPlural:
      // Check for explicit i2p override first.
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(.secondPlural))
      if isFullOverride {
        return .success(withSeparablePrefix(verb: verb, form: newStamm))
      }
      // ihr form: stamm + "t" (no stem changes in ihr imperative)
      let form = (newStamm != stamm ? newStamm : stamm) + "t"
      return .success(withSeparablePrefix(verb: verb, form: form))

    case .firstPlural:
      // Check for explicit i1p override first.
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(.firstPlural))
      if isFullOverride {
        return .success(withSeparablePrefixAndPronoun(verb: verb, form: newStamm, pronoun: "wir"))
      }
      // wir form: use Konjunktiv I 1p (stamm + "en", or special form for sein)
      let (konjStamm, konjOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .präsensKonjunktivI(.firstPlural))
      let form: String
      if konjOverride {
        form = konjStamm
      } else {
        form = (konjStamm != stamm ? konjStamm : stamm) + "en"
      }
      return .success(withSeparablePrefixAndPronoun(verb: verb, form: form, pronoun: "wir"))

    case .thirdPlural:
      // Check for explicit i3p override first.
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(.thirdPlural))
      if isFullOverride {
        return .success(withSeparablePrefixAndPronoun(verb: verb, form: newStamm, pronoun: "Sie"))
      }
      // Sie form: use Konjunktiv I 3p (stamm + "en", or special form for sein)
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

  /// Applies e→i or e→ie stem change for du imperative (but not a→ä changes)
  private static func applyEToIStemChange(stamm: String, verb: Verb) -> String {
    switch verb.family {
    case .strong(ablautGroup: let ablautKey, ablautStartIndex: let ablautStartIndex, ablautEndIndex: let ablautEndIndex),
    .mixed(ablautGroup: let ablautKey, ablautStartIndex: let ablautStartIndex, ablautEndIndex: let ablautEndIndex):
      if
        let ablautGroup = AblautGroup.ablautGroups[ablautKey],
        let ablaut = ablautGroup.ablauts[.präsensIndicativ(.secondSingular)]
      {
        // Skip full overrides like "wirst*".
        if ablaut.hasSuffix("*") {
          return stamm
        }

        // Only apply if this is an e→i or e→ie change (not a→ä).
        let startIndex = stamm.index(stamm.startIndex, offsetBy: ablautStartIndex)
        let endIndex = stamm.index(stamm.startIndex, offsetBy: ablautEndIndex)
        let originalRegion = String(stamm[startIndex ..< endIndex])

        // Check if original starts with "e" and ablaut starts with "i" (e→i or e→ie change)
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

  /// Formats imperative with separable prefix at end for du/ihr forms.
  private static func withSeparablePrefix(verb: Verb, form: String) -> String {
    switch verb.prefix {
    case .separable(let prefix):
      let prefixlessForm = String(form.dropFirst(prefix.count))
      return prefixlessForm + " " + prefix
    case .inseparable, .none:
      return form
    }
  }

  /// Formats imperative with separable prefix and pronoun for wir/Sie forms.
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
        // Check for full override (ablaut ending with "*").
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
