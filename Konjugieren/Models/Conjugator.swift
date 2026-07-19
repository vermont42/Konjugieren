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

  // The `auxiliary` parameter exists so that regional variation can be expressed without
  // making this type region-aware. Conjugator is the oracle the classify-and-verify pipeline
  // compares against Wiktionary, and every ConjugatorTests expectation is written in the
  // German standard, so its output must never depend on a user setting. Callers that want a
  // regional reading pass the auxiliary explicitly; see RegionalConjugator.
  //
  // `readingIndex` selects among a verb's readings, which may differ in auxiliary, family,
  // and prefix all at once — hängen inflects strong when intransitive and weak when
  // transitive. It defaults to the primary reading, so existing call sites are unaffected.
  static func conjugate(
    infinitiv: String,
    conjugationgroup: Conjugationgroup,
    auxiliary: Auxiliary? = nil,
    readingIndex: Int = 0
  ) -> Result<String, ConjugatorError> {
    guard infinitiv.count >= Verb.minVerbLength else {
      return .failure(.verbTooShort)
    }

    guard Verb.endingIsValid(infinitiv: infinitiv) else {
      return .failure(.infinitivEndingInvalid)
    }

    guard let verb = Verb.verbs[infinitiv] else {
      return .failure(.verbNotRecognized)
    }

    guard verb.readings.indices.contains(readingIndex) else {
      return .failure(.readingNotRecognized)
    }
    let reading = verb.readings[readingIndex]

    switch conjugationgroup {
    case .präsensIndikativ, .präsensKonjunktivI, .präteritumIndikativ, .präteritumKonjunktivII:
      return conjugateSimpleTense(reading: reading, conjugationgroup: conjugationgroup)

    case .perfektpartizip:
      let (newStamm, isFullOverride) = applyAblaut(stamm: reading.stamm, reading: reading, conjugationgroup: conjugationgroup)
      if isFullOverride {
        return .success(newStamm)
      }
      let rawEnding = conjugationgroup.ending(family: reading.family)
      let adjustedEnding = adjustPerfektpartizipEnding(stamm: newStamm, ending: rawEnding, family: reading.family)
      switch reading.family {
      case .strong, .mixed, .weak:
        return .success(perfektpartizipWithGeAndPrefix(reading: reading, stamm: newStamm, ending: adjustedEnding))
      case .ieren:
        return .success(newStamm + adjustedEnding)
      }

    case .präsenspartizip:
      return .success(reading.stamm + (hasSyllabicStamm(reading: reading) ? "nd" : "end"))

    case .imperativ(let personNumber):
      return conjugateImperativ(reading: reading, personNumber: personNumber)

    case .perfektIndikativ(let personNumber):
      return conjugateCompoundTense(infinitiv: infinitiv, readingIndex: readingIndex, auxiliaryInfinitiv: (auxiliary ?? reading.auxiliary).verb, auxiliaryGroup: .präsensIndikativ(personNumber))

    case .perfektKonjunktivI(let personNumber):
      return conjugateCompoundTense(infinitiv: infinitiv, readingIndex: readingIndex, auxiliaryInfinitiv: (auxiliary ?? reading.auxiliary).verb, auxiliaryGroup: .präsensKonjunktivI(personNumber))

    case .plusquamperfektIndikativ(let personNumber):
      return conjugateCompoundTense(infinitiv: infinitiv, readingIndex: readingIndex, auxiliaryInfinitiv: (auxiliary ?? reading.auxiliary).verb, auxiliaryGroup: .präteritumIndikativ(personNumber))

    case .plusquamperfektKonjunktivII(let personNumber):
      return conjugateCompoundTense(infinitiv: infinitiv, readingIndex: readingIndex, auxiliaryInfinitiv: (auxiliary ?? reading.auxiliary).verb, auxiliaryGroup: .präteritumKonjunktivII(personNumber))

    case .futurIndikativ(let personNumber):
      return conjugateCompoundTense(infinitiv: infinitiv, readingIndex: readingIndex, auxiliaryInfinitiv: "werden", auxiliaryGroup: .präsensIndikativ(personNumber), useInfinitivAsSecondPart: true)

    case .futurKonjunktivI(let personNumber):
      return conjugateCompoundTense(infinitiv: infinitiv, readingIndex: readingIndex, auxiliaryInfinitiv: "werden", auxiliaryGroup: .präsensKonjunktivI(personNumber), useInfinitivAsSecondPart: true)

    case .futurKonjunktivII(let personNumber):
      return conjugateCompoundTense(infinitiv: infinitiv, readingIndex: readingIndex, auxiliaryInfinitiv: "werden", auxiliaryGroup: .präteritumKonjunktivII(personNumber), useInfinitivAsSecondPart: true)
    }
  }

  private static func conjugateSimpleTense(reading: Reading, conjugationgroup: Conjugationgroup) -> Result<String, ConjugatorError> {
    let (newStamm, isFullOverride) = applyAblaut(stamm: reading.stamm, reading: reading, conjugationgroup: conjugationgroup)
    if isFullOverride {
      return .success(newStamm)
    }
    let rawEnding = conjugationgroup.ending(family: reading.family)
    let adjustedEnding = adjustEndingForPhonology(
      stamm: newStamm,
      ending: rawEnding,
      reading: reading,
      conjugationgroup: conjugationgroup,
      stammIsAblauted: newStamm != reading.stamm
    )
    return .success(newStamm + adjustedEnding)
  }

  private static func conjugateCompoundTense(
    infinitiv: String,
    readingIndex: Int,
    auxiliaryInfinitiv: String,
    auxiliaryGroup: Conjugationgroup,
    useInfinitivAsSecondPart: Bool = false
  ) -> Result<String, ConjugatorError> {
    let auxiliaryResult = conjugate(infinitiv: auxiliaryInfinitiv, conjugationgroup: auxiliaryGroup)

    let secondPartResult: Result<String, ConjugatorError>
    if useInfinitivAsSecondPart {
      secondPartResult = .success(infinitiv)
    } else {
      // The participle must come from the same reading as the auxiliary, since a verb
      // whose readings differ in family also differs in participle: hängen is gehangen
      // intransitive but gehängt transitive.
      secondPartResult = conjugate(infinitiv: infinitiv, conjugationgroup: .perfektpartizip, readingIndex: readingIndex)
    }

    switch (auxiliaryResult, secondPartResult) {
    case (.success(let auxiliary), .success(let secondPart)):
      return .success(auxiliary + " " + secondPart)
    default:
      return .failure(.conjugationFailed)
    }
  }

  private static func conjugateImperativ(reading: Reading, personNumber: PersonNumber) -> Result<String, ConjugatorError> {
    let stamm = reading.stamm

    switch personNumber {
    case .secondSingular:
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, reading: reading, conjugationgroup: .imperativ(.secondSingular))
      if isFullOverride {
        return .success(withSeparablePrefix(reading: reading, form: newStamm))
      }

      let imperativStamm = newStamm != stamm ? newStamm : applyEToIStemChange(stamm: stamm, reading: reading)

      // A strong verb that changes its stem here keeps the bare imperative — gilt, sieh,
      // nimm — while an unchanged stem takes the epenthetic -e: arbeite, atme, finde.
      let needsE = imperativStamm == stamm && needsEpentheticE(stamm: imperativStamm)
      let form = needsE ? imperativStamm + "e" : imperativStamm
      return .success(withSeparablePrefix(reading: reading, form: form))

    case .secondPlural:
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, reading: reading, conjugationgroup: .imperativ(.secondPlural))
      if isFullOverride {
        return .success(withSeparablePrefix(reading: reading, form: newStamm))
      }
      let ending = needsEpentheticE(stamm: newStamm) ? "et" : "t"
      return .success(withSeparablePrefix(reading: reading, form: newStamm + ending))

    case .firstPlural, .thirdPlural:
      let pronoun = personNumber == .firstPlural ? "wir" : "Sie"
      let (newStamm, isFullOverride) = applyAblaut(stamm: stamm, reading: reading, conjugationgroup: .imperativ(personNumber))
      if isFullOverride {
        return .success(withSeparablePrefixAndPronoun(reading: reading, form: newStamm, pronoun: pronoun))
      }
      let (konjStamm, konjOverride) = applyAblaut(stamm: stamm, reading: reading, conjugationgroup: .präsensKonjunktivI(personNumber))
      let form = konjOverride ? konjStamm : konjStamm + pluralEnding(reading: reading)
      return .success(withSeparablePrefixAndPronoun(reading: reading, form: form, pronoun: pronoun))

    case .firstSingular, .thirdSingular:
      return .failure(.personNumberNotSupported)
    }
  }

  private static func applyEToIStemChange(stamm: String, reading: Reading) -> String {
    switch reading.family {
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

  private static func withSeparablePrefix(reading: Reading, form: String) -> String {
    let run = reading.prefixes.separableRun
    guard !run.isEmpty else {
      return form
    }
    return String(form.dropFirst(run.count)) + " " + run
  }

  private static func withSeparablePrefixAndPronoun(reading: Reading, form: String, pronoun: String) -> String {
    let run = reading.prefixes.separableRun
    guard !run.isEmpty else {
      return form + " " + pronoun
    }
    return String(form.dropFirst(run.count)) + " " + pronoun + " " + run
  }

  private static func applyAblaut(stamm: String, reading: Reading, conjugationgroup: Conjugationgroup) -> (stamm: String, isFullOverride: Bool) {
    switch reading.family {
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

  // The ge- of the Perfektpartizip sits immediately before the base stem, behind every
  // prefix, and appears only when the prefix closest to that stem is separable or absent.
  // That is why an+ge*hören gives angehört while ab+bauen gives abgebaut: both open with a
  // separable prefix, but only the first has an inseparable one against the stem.
  private static func perfektpartizipWithGeAndPrefix(reading: Reading, stamm: String, ending: String) -> String {
    let prefixes = reading.prefixes
    let head = String(stamm.prefix(prefixes.totalLength))
    let base = String(stamm.dropFirst(prefixes.totalLength))
    return head + (prefixes.takesGe ? "ge" : "") + base + ending
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
  private static func hasSyllabicStamm(reading: Reading) -> Bool {
    reading.infinitiv.hasSuffix("ern") || reading.infinitiv.hasSuffix("eln")
  }

  private static func pluralEnding(reading: Reading) -> String {
    hasSyllabicStamm(reading: reading) ? "n" : "en"
  }

  private static func adjustEndingForPhonology(
    stamm: String,
    ending: String,
    reading: Reading,
    conjugationgroup: Conjugationgroup,
    stammIsAblauted: Bool
  ) -> String {
    if ending == "en" {
      return pluralEnding(reading: reading)
    }

    let lastChar = stamm.last.map { String($0).lowercased() } ?? ""

    if ending == "st" && ["s", "ß", "x", "z"].contains(lastChar) {
      return "t"
    }

    // The endingless Präsens 3s survives only in strong verbs that change their stem
    // there: er hält, er tritt. An unablauted stem takes the ordinary ending, and a
    // t-final one takes the epenthetic -e below: ihr haltet, er findet.
    if case .präsensIndikativ = conjugationgroup, ending == "t", lastChar == "t", stammIsAblauted, case .strong = reading.family {
      return ""
    }

    guard needsEpentheticE(stamm: stamm) else {
      return ending
    }

    switch reading.family {
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
