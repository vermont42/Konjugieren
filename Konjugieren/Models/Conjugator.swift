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
    case .präsensIndikativ, .präsensKonjunktivI, .präteritumIndikativ, .präteritumKonjunktivII:
      return conjugateSimpleTense(verb: verb, conjugationgroup: conjugationgroup)

    case .perfektpartizip:
      let (newStamm, isFullOverride) = applyAblaut(stamm: verb.stamm, verb: verb, conjugationgroup: conjugationgroup)
      if isFullOverride {
        return .success(newStamm)
      }
      let rawEnding = conjugationgroup.ending(family: verb.family)
      let adjustedEnding = adjustPerfektpartizipEnding(stamm: newStamm, ending: rawEnding, family: verb.family)
      switch verb.family {
      case .strong, .mixed, .weak:
        return .success(perfektpartizipWithGeAndPrefix(verb: verb, stamm: newStamm, ending: adjustedEnding))
      case .ieren:
        return .success(newStamm + adjustedEnding)
      }

    case .präsenspartizip:
      return .success(verb.stamm + (hasSyllabicStamm(verb: verb) ? "nd" : "end"))

    case .imperativ(let personNumber):
      return conjugateImperativ(verb: verb, personNumber: personNumber)

    case .perfektIndikativ(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: verb.auxiliary.verb, auxiliaryGroup: .präsensIndikativ(personNumber))

    case .perfektKonjunktivI(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: verb.auxiliary.verb, auxiliaryGroup: .präsensKonjunktivI(personNumber))

    case .plusquamperfektIndikativ(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: verb.auxiliary.verb, auxiliaryGroup: .präteritumIndikativ(personNumber))

    case .plusquamperfektKonjunktivII(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: verb.auxiliary.verb, auxiliaryGroup: .präteritumKonjunktivII(personNumber))

    case .futurIndikativ(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: "werden", auxiliaryGroup: .präsensIndikativ(personNumber), useInfinitivAsSecondPart: true)

    case .futurKonjunktivI(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: "werden", auxiliaryGroup: .präsensKonjunktivI(personNumber), useInfinitivAsSecondPart: true)

    case .futurKonjunktivII(let personNumber):
      return conjugateCompoundTense(verb: verb, infinitiv: infinitiv, auxiliaryInfinitiv: "werden", auxiliaryGroup: .präteritumKonjunktivII(personNumber), useInfinitivAsSecondPart: true)
    }
  }

  private static func conjugateSimpleTense(verb: Verb, conjugationgroup: Conjugationgroup) -> Result<String, ConjugatorError> {
    let (newStamm, isFullOverride) = applyAblaut(stamm: verb.stamm, verb: verb, conjugationgroup: conjugationgroup)
    if isFullOverride {
      return .success(newStamm)
    }
    let rawEnding = conjugationgroup.ending(family: verb.family)
    let adjustedEnding = adjustEndingForPhonology(
      stamm: newStamm,
      ending: rawEnding,
      verb: verb,
      conjugationgroup: conjugationgroup,
      stammIsAblauted: newStamm != verb.stamm
    )
    return .success(newStamm + adjustedEnding)
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

      let imperativStamm = newStamm != stamm ? newStamm : applyEToIStemChange(stamm: stamm, verb: verb)

      // A strong verb that changes its stem here keeps the bare imperative — gilt, sieh,
      // nimm — while an unchanged stem takes the epenthetic -e: arbeite, atme, finde.
      let needsE = imperativStamm == stamm && needsEpentheticE(stamm: imperativStamm)
      let form = needsE ? imperativStamm + "e" : imperativStamm
      return .success(withSeparablePrefix(verb: verb, form: form))

    case .secondPlural:
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(.secondPlural))
      if isFullOverride {
        return .success(withSeparablePrefix(verb: verb, form: newStamm))
      }
      let ending = needsEpentheticE(stamm: newStamm) ? "et" : "t"
      return .success(withSeparablePrefix(verb: verb, form: newStamm + ending))

    case .firstPlural, .thirdPlural:
      let pronoun = personNumber == .firstPlural ? "wir" : "Sie"
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .imperativ(personNumber))
      if isFullOverride {
        return .success(withSeparablePrefixAndPronoun(verb: verb, form: newStamm, pronoun: pronoun))
      }
      let (konjStamm, konjOverride) = applyAblaut(stamm: stamm, verb: verb, conjugationgroup: .präsensKonjunktivI(personNumber))
      let form = konjOverride ? konjStamm : konjStamm + pluralEnding(verb: verb)
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
        let ablaut = ablautGroup.ablauts[.präsensIndikativ(.secondSingular)]
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
    guard ending == "t", needsEpentheticE(stamm: stamm) else {
      return ending
    }
    switch family {
    case .weak, .ieren:
      return "et"
    // gesandt, gewandt, gebrannt: the mixed participle attaches -t to the ablauted
    // stem directly, exactly as its Präteritum attaches -te.
    case .mixed, .strong:
      return ending
    }
  }

  private static let vowels: Set<Character> = ["a", "e", "i", "o", "u", "ä", "ö", "ü"]

  private static func needsEpentheticE(stamm: String) -> Bool {
    let characters = Array(stamm.lowercased())
    guard let last = characters.last else {
      return false
    }

    if ["t", "d"].contains(last) {
      return true
    }

    guard ["m", "n"].contains(last), characters.count >= 2 else {
      return false
    }

    let penultimate = characters[characters.count - 2]
    if ["l", "r", "m", "n"].contains(penultimate) || vowels.contains(penultimate) {
      return false
    }

    // A silent Dehnungs-h lengthens the vowel before it rather than closing the
    // syllable, so ahnen and wohnen behave like vowel stems and take no -e. The h of
    // rechnen and zeichnen is half of ch, a real cluster, and does take one.
    if penultimate == "h" {
      let beforeH = characters.count >= 3 ? characters[characters.count - 3] : " "
      return !vowels.contains(beforeH)
    }

    return true
  }

  // An -ern or -eln stem ends in a syllabic er/el that already supplies the e, so its
  // plural ending reduces to -n and its Präsenspartizip to -nd: wir ändern, ändernd.
  // The test is on the infinitive rather than the stem because verheeren's stem also
  // ends in er, and because tun and sein end in -n without the syllable: wir taten.
  private static func hasSyllabicStamm(verb: Verb) -> Bool {
    verb.infinitiv.hasSuffix("ern") || verb.infinitiv.hasSuffix("eln")
  }

  private static func pluralEnding(verb: Verb) -> String {
    hasSyllabicStamm(verb: verb) ? "n" : "en"
  }

  private static func adjustEndingForPhonology(
    stamm: String,
    ending: String,
    verb: Verb,
    conjugationgroup: Conjugationgroup,
    stammIsAblauted: Bool
  ) -> String {
    if ending == "en" {
      return pluralEnding(verb: verb)
    }

    let lastChar = stamm.last.map { String($0).lowercased() } ?? ""

    if ending == "st" && ["s", "ß", "x", "z"].contains(lastChar) {
      return "t"
    }

    // The endingless Präsens 3s survives only in strong verbs that change their stem
    // there: er hält, er tritt. An unablauted stem takes the ordinary ending, and a
    // t-final one takes the epenthetic -e below: ihr haltet, er findet.
    if case .präsensIndikativ = conjugationgroup, ending == "t", lastChar == "t", stammIsAblauted, case .strong = verb.family {
      return ""
    }

    guard needsEpentheticE(stamm: stamm) else {
      return ending
    }

    switch verb.family {
    case .weak, .ieren:
      switch conjugationgroup {
      case .präteritumIndikativ, .präteritumKonjunktivII:
        if ["te", "test", "ten", "tet"].contains(ending) {
          return "e" + ending
        }
      case .präsensIndikativ(let personNumber):
        if personNumber == .secondSingular && ending == "st" {
          return "est"
        }
        if [.thirdSingular, .secondPlural].contains(personNumber) && ending == "t" {
          return "et"
        }
      default:
        break
      }
    case .strong:
      let applies: Bool
      switch conjugationgroup {
      case .präsensIndikativ:
        applies = !stammIsAblauted
      case .präteritumIndikativ:
        applies = true
      default:
        applies = false
      }
      if applies {
        if ending == "st" {
          return "est"
        }
        if ending == "t" {
          return "et"
        }
      }
    case .mixed:
      // du sendest but sandte: the mixed Präteritum attaches -te to the ablauted stem
      // directly, so only the Präsens takes an epenthetic -e.
      if case .präsensIndikativ = conjugationgroup, !stammIsAblauted {
        if ending == "st" {
          return "est"
        }
        if ending == "t" {
          return "et"
        }
      }
    }

    return ending
  }
}
