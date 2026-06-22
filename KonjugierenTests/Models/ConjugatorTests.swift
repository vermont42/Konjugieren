// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@Suite("Conjugator")
@MainActor
struct ConjugatorTests {
  @Test func perfektpartizip() {
    // Weak verb
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektpartizip, expected: "gemacht")

    // Weak verb with stamm ending in t (e-insertion: -t → -et)
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .perfektpartizip, expected: "gearbeitet")

    // -ieren verb (no ge- prefix)
    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektpartizip, expected: "studiert")

    // Strong verbs (uppercase indicates ablaut changes)
    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektpartizip, expected: "gesUngen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektpartizip, expected: "gegANGen")
    expectConjugation(infinitiv: "finden", conjugationgroup: .perfektpartizip, expected: "gefUnden")
    expectConjugation(infinitiv: "nehmen", conjugationgroup: .perfektpartizip, expected: "genOMMen")
    expectConjugation(infinitiv: "sitzen", conjugationgroup: .perfektpartizip, expected: "gesESSen")

    // Mixed verbs
    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektpartizip, expected: "gebrACHt")
    expectConjugation(infinitiv: "haben", conjugationgroup: .perfektpartizip, expected: "gehabt")

    // Separable prefix verb (prefix + ge + stamm + ending)
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektpartizip, expected: "angekommen")

    // Inseparable prefix verb (no ge- prefix)
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektpartizip, expected: "verstANDen")
  }

  @Test func präsenspartizip() {
    // Weak verb
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsenspartizip, expected: "machend")

    // Strong verb
    expectConjugation(infinitiv: "singen", conjugationgroup: .präsenspartizip, expected: "singend")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .präsenspartizip, expected: "gehend")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präsenspartizip, expected: "studierend")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präsenspartizip, expected: "bringend")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präsenspartizip, expected: "ankommend")

    // Inseparable prefix verb
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .präsenspartizip, expected: "verstehend")
  }

  @Test func präsensIndikativ() {
    // Weak verb - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "mache")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "machst")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "macht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "macht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "machen")

    // Strong verb with e→i ablaut (sehen: e→ie in 2s, 3s)
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "sehe")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "sIEhst")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "sIEht")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "sehen")

    // Strong verb lassen: 2s has full override showing irregular ending, 3s has standard ablaut
    expectConjugation(infinitiv: "lassen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "lÄssEst")
    expectConjugation(infinitiv: "lassen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "lÄsst")

    // Irregular sein (uppercase shows ablaut, lowercase shows unchanged portions)
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "BIN")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "BIst")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "IST")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "sIND")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "seiD")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "sIND")

    // Irregular haben (uppercase A shows stem vowel change from "ab" to "A")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "habe")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "hAst")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "hAt")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "studiere")
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "studiert")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "ankomme")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "ankommt")
  }

  @Test func präsensKonjunktivI() {
    // Weak verb - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.firstSingular), expected: "mache")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.secondSingular), expected: "machest")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.thirdSingular), expected: "mache")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.firstPlural), expected: "machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.secondPlural), expected: "machet")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.thirdPlural), expected: "machen")

    // Strong verb (no ablaut in Konjunktiv I)
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensKonjunktivI(.firstSingular), expected: "sehe")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensKonjunktivI(.secondSingular), expected: "sehest")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensKonjunktivI(.thirdSingular), expected: "sehe")

    // Irregular sein (1s, 2s, 3s have explicit overrides; plural forms use default stamm + endings)
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.firstSingular), expected: "seI")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.secondSingular), expected: "seIst")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.thirdSingular), expected: "seI")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.firstPlural), expected: "seien")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.secondPlural), expected: "seiet")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.thirdPlural), expected: "seien")

    // Irregular haben
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensKonjunktivI(.firstSingular), expected: "habe")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensKonjunktivI(.thirdSingular), expected: "habe")
  }

  @Test func präteritumIndikativ() {
    // Weak verb - all persons (uses -te endings)
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "machtest")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "machten")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "machtet")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "machten")

    // Strong verb (ablaut, no -te suffix)
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sAng")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "sAngst")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "sAng")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "sAngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "sAngt")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "sAngen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sAh")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "sAh")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gING")

    // Mixed verb (ablaut + -te suffix)
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "brACHte")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "brACHtest")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "brACHte")

    // Irregular sein (WAR replaces ablaut region, endings added in lowercase)
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "WAR")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "WARst")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "WAR")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "WARen")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "WARt")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "WARen")

    // -ieren verb (weak-style endings)
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "studierte")
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "studierte")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "ankAm")
  }

  @Test func präteritumKonjunktivII() {
    // Weak verb - all persons (uses -te endings, same as Präteritum for weak verbs)
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "machtest")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "machten")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "machtet")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "machten")

    // Strong verb (ablaut often includes umlaut, KonjunktivII endings)
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sÄnge")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "sÄngest")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "sÄnge")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "sÄngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "sÄnget")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "sÄngen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sÄhe")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gINGe")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "brÄCHte")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "brÄCHte")

    // Irregular sein (WÄR replaces ablaut region, endings added in lowercase)
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "WÄRe")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "WÄRest")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "WÄRe")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "WÄRen")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "WÄRet")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "WÄRen")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "studierte")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "ankÄme")
  }

  @Test func perfektIndikativ() {
    // Weak verb with haben auxiliary - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.secondSingular), expected: "hAst gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.firstPlural), expected: "haben gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.secondPlural), expected: "habt gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.thirdPlural), expected: "haben gemacht")

    // Strong verb with sein auxiliary (sein conjugation reflects corrected ablaut)
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.secondSingular), expected: "BIst gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.firstPlural), expected: "sIND gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.secondPlural), expected: "seiD gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.thirdPlural), expected: "sIND gegANGen")

    // Strong verb with haben auxiliary
    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gesUngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gesUngen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gesehen")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gesehen")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gebrACHt")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gebrACHt")

    // -ieren verb (no ge- prefix)
    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe studiert")
    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt studiert")

    // Separable prefix verb (sein auxiliary reflects corrected ablaut)
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN angekommen")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST angekommen")

    // Inseparable prefix verb
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe verstANDen")
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt verstANDen")
  }

  @Test func perfektKonjunktivI() {
    // Weak verb with haben auxiliary - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.secondSingular), expected: "habest gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.thirdSingular), expected: "habe gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.firstPlural), expected: "haben gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.secondPlural), expected: "habet gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.thirdPlural), expected: "haben gemacht")

    // Strong verb with sein auxiliary (sein Konjunktiv I reflects corrected ablaut)
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "seI gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.secondSingular), expected: "seIst gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.thirdSingular), expected: "seI gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.firstPlural), expected: "seien gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.secondPlural), expected: "seiet gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.thirdPlural), expected: "seien gegANGen")

    // Strong verb with haben auxiliary
    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe gesUngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektKonjunktivI(.thirdSingular), expected: "habe gesUngen")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe gebrACHt")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe studiert")

    // Separable prefix verb (sein Konjunktiv I reflects corrected ablaut)
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "seI angekommen")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektKonjunktivI(.thirdSingular), expected: "seI angekommen")

    // Inseparable prefix verb
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe verstANDen")
  }

  @Test func werden() {
    // werden has extensive irregular forms with explicit full overrides
    // Präsens Indikativ
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "werde")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wIrst")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wIrD")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "werden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "werdEt")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "werden")

    // Präteritum Indikativ
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wUrdE")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "wUrdEst")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "wUrdE")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "wUrden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "wUrdEt")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "wUrden")

    // Präteritum KonjunktivII
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜrde")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "wÜrdest")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "wÜrde")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "wÜrden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "wÜrdet")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "wÜrden")

    // Perfektpartizip
    expectConjugation(infinitiv: "werden", conjugationgroup: .perfektpartizip, expected: "gewOrden")
  }

  @Test func imperativ() {
    // MARK: - du form (secondSingular)

    // Weak verb - basic stem
    expectConjugation(infinitiv: "machen", conjugationgroup: .imperativ(.secondSingular), expected: "mach")

    // Strong verb with e→i change - should apply (uppercase indicates ablaut)
    expectConjugation(infinitiv: "geben", conjugationgroup: .imperativ(.secondSingular), expected: "gIb")
    expectConjugation(infinitiv: "nehmen", conjugationgroup: .imperativ(.secondSingular), expected: "nIMM")

    // Strong verb with e→ie change - should apply
    expectConjugation(infinitiv: "sehen", conjugationgroup: .imperativ(.secondSingular), expected: "sIEh")

    // Strong verb with a→ä change - should NOT apply (use base stem)
    expectConjugation(infinitiv: "lassen", conjugationgroup: .imperativ(.secondSingular), expected: "lass")

    // Verb ending in -d needs -e for pronunciation
    expectConjugation(infinitiv: "werden", conjugationgroup: .imperativ(.secondSingular), expected: "werde")

    // Irregular sein (i2s has explicit override)
    expectConjugation(infinitiv: "sein", conjugationgroup: .imperativ(.secondSingular), expected: "seI")

    // Separable prefix verb - prefix goes to end
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .imperativ(.secondSingular), expected: "komm an")

    // MARK: - ihr form (secondPlural)

    expectConjugation(infinitiv: "machen", conjugationgroup: .imperativ(.secondPlural), expected: "macht")
    expectConjugation(infinitiv: "geben", conjugationgroup: .imperativ(.secondPlural), expected: "gebt")
    expectConjugation(infinitiv: "sein", conjugationgroup: .imperativ(.secondPlural), expected: "seiD")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .imperativ(.secondPlural), expected: "kommt an")

    // MARK: - wir form (firstPlural)

    expectConjugation(infinitiv: "machen", conjugationgroup: .imperativ(.firstPlural), expected: "machen wir")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .imperativ(.firstPlural), expected: "gehen wir")
    expectConjugation(infinitiv: "sein", conjugationgroup: .imperativ(.firstPlural), expected: "seien wir")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .imperativ(.firstPlural), expected: "kommen wir an")

    // MARK: - Sie form (thirdPlural)

    expectConjugation(infinitiv: "machen", conjugationgroup: .imperativ(.thirdPlural), expected: "machen Sie")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .imperativ(.thirdPlural), expected: "gehen Sie")
    expectConjugation(infinitiv: "sein", conjugationgroup: .imperativ(.thirdPlural), expected: "seien Sie")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .imperativ(.thirdPlural), expected: "kommen Sie an")
  }

  @Test func tun() {
    // Präsens Indikativ - no ablaut
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "tue")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "tust")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "tut")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "tun")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "tut")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "tun")

    // Präteritum Indikativ - u→at, with e-insertion for 2s/2p
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "tAT")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "tATest")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "tAT")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "tATen")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "tATet")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "tATen")

    // Präteritum KonjunktivII - u→ät
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "tÄTe")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "tÄTest")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "tÄTe")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "tÄTen")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "tÄTet")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "tÄTen")

    // Perfektpartizip
    expectConjugation(infinitiv: "tun", conjugationgroup: .perfektpartizip, expected: "getAn")
  }

  @Test func newAblautGroups() {
    // fahren - a→ä (Präsens 2s,3s), a→u (Präteritum), a→ü (Konjunktiv II)
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "fÄhrst")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "fÄhrt")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "fUhr")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fÜhre")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .perfektpartizip, expected: "gefahren")

    // laufen - au→äu (Präsens 2s,3s), au→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "lÄUfst")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "lÄUft")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "lIEf")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "lIEfe")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .perfektpartizip, expected: "gelaufen")

    // fallen - all→äll (Präsens 2s,3s), all→iel (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "fÄLLst")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "fÄLLt")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "fIEL")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fIELe")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .perfektpartizip, expected: "gefallen")

    // treffen - eff→iff (Präsens 2s,3s), eff→af (Präteritum), eff→äf (Konjunktiv II), eff→off (Perfektpartizip)
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "trIFFst")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "trIFFt")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trAF")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÄFe")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .perfektpartizip, expected: "getrOFFen")

    // schließen - ie→o (Präteritum, Perfektpartizip), ie→ö (Konjunktiv II)
    // Note: German spelling would convert ß→ss after short vowel, but conjugator preserves consonant
    expectConjugation(infinitiv: "schließen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schlOß")
    expectConjugation(infinitiv: "schließen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schlÖße")
    expectConjugation(infinitiv: "schließen", conjugationgroup: .perfektpartizip, expected: "geschlOßen")

    // heißen - ei→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "heißen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "hIEß")
    expectConjugation(infinitiv: "heißen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "hIEße")
    expectConjugation(infinitiv: "heißen", conjugationgroup: .perfektpartizip, expected: "geheißen")

    // ziehen - ieh→og (Präteritum, Perfektpartizip), ieh→ög (Konjunktiv II)
    expectConjugation(infinitiv: "ziehen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "zOG")
    expectConjugation(infinitiv: "ziehen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "zÖGe")
    expectConjugation(infinitiv: "ziehen", conjugationgroup: .perfektpartizip, expected: "gezOGen")

    // tragen - a→ä (Präsens 2s,3s), a→u (Präteritum), a→ü (Konjunktiv II)
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "trÄgst")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "trÄgt")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trUg")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÜge")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .perfektpartizip, expected: "getragen")

    // gewinnen - i→a (Präteritum), i→ä (Konjunktiv II), i→o (Perfektpartizip)
    expectConjugation(infinitiv: "gewinnen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gewAnn")
    expectConjugation(infinitiv: "gewinnen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gewÄnne")
    expectConjugation(infinitiv: "gewinnen", conjugationgroup: .perfektpartizip, expected: "gewOnnen")

    // empfehlen - e→ie (Präsens 2s,3s), e→a (Präteritum), e→ä (Konjunktiv II), e→o (Perfektpartizip)
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "empfIEhlst")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "empfIEhlt")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "empfAhl")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "empfÄhle")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .perfektpartizip, expected: "empfOhlen")

    // treten - et→itt (Präsens 2s,3s), et→at (Präteritum), et→ät (Konjunktiv II), et→et (Perfektpartizip)
    // Note: 3s ending -t merges with stamm ending -tt (German phonology)
    expectConjugation(infinitiv: "treten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "trITTst")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "trITT")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trAT")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÄTe")
    expectConjugation(infinitiv: "treten", conjugationgroup: .perfektpartizip, expected: "getrETen")

    // verlieren - ie→o (Präteritum, Perfektpartizip), ie→ö (Konjunktiv II)
    expectConjugation(infinitiv: "verlieren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "verlOr")
    expectConjugation(infinitiv: "verlieren", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "verlÖre")
    expectConjugation(infinitiv: "verlieren", conjugationgroup: .perfektpartizip, expected: "verlOren")

    // steigen - ei→ie (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "steigen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stIEg")
    expectConjugation(infinitiv: "steigen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stIEge")
    expectConjugation(infinitiv: "steigen", conjugationgroup: .perfektpartizip, expected: "gestIEgen")

    // erscheinen - ei→ie (Präteritum, Konjunktiv II, Perfektpartizip) with inseparable prefix
    expectConjugation(infinitiv: "erscheinen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "erschIEn")
    expectConjugation(infinitiv: "erscheinen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "erschIEne")
    expectConjugation(infinitiv: "erscheinen", conjugationgroup: .perfektpartizip, expected: "erschIEnen")

    // gelingen - i→a (Präteritum), i→ä (Konjunktiv II), i→u (Perfektpartizip)
    expectConjugation(infinitiv: "gelingen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gelAng")
    expectConjugation(infinitiv: "gelingen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gelÄnge")
    expectConjugation(infinitiv: "gelingen", conjugationgroup: .perfektpartizip, expected: "gelUngen")

    // schlagen - a→ä (Präsens 2s,3s), a→u (Präteritum), a→ü (Konjunktiv II)
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "schlÄgst")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "schlÄgt")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schlUg")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schlÜge")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .perfektpartizip, expected: "geschlagen")

    // laden - a→ä (Präsens 2s,3s), a→u (Präteritum), a→ü (Konjunktiv II)
    expectConjugation(infinitiv: "laden", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "lÄdst")
    expectConjugation(infinitiv: "laden", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "lÄdt")
    expectConjugation(infinitiv: "laden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "lUd")
    expectConjugation(infinitiv: "laden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "lÜde")
    expectConjugation(infinitiv: "laden", conjugationgroup: .perfektpartizip, expected: "geladen")

    // wachsen - a→ä (Präsens 2s,3s), a→u (Präteritum), a→ü (Konjunktiv II)
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wÄchst")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wÄchst")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wUchs")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜchse")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .perfektpartizip, expected: "gewachsen")

    // rufen - u→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "rufen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "rIEf")
    expectConjugation(infinitiv: "rufen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rIEfe")
    expectConjugation(infinitiv: "rufen", conjugationgroup: .perfektpartizip, expected: "gerufen")

    // weisen - ei→ie (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "weisen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wIEs")
    expectConjugation(infinitiv: "weisen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wIEse")
    expectConjugation(infinitiv: "weisen", conjugationgroup: .perfektpartizip, expected: "gewIEsen")

    // genießen - ie→o (Präteritum, Perfektpartizip), ie→ö (Konjunktiv II)
    // Note: genießen uses schließen pattern, ge- is inseparable prefix (no double ge-)
    // German spelling would convert ß→ss after short vowel, but conjugator preserves consonant
    expectConjugation(infinitiv: "genießen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "genOß")
    expectConjugation(infinitiv: "genießen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "genÖße")
    expectConjugation(infinitiv: "genießen", conjugationgroup: .perfektpartizip, expected: "genOßen")

    // bitten - itt→at (Präteritum), itt→ät (Konjunktiv II), itt→et (Perfektpartizip)
    expectConjugation(infinitiv: "bitten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bAT")
    expectConjugation(infinitiv: "bitten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "bÄTe")
    expectConjugation(infinitiv: "bitten", conjugationgroup: .perfektpartizip, expected: "gebETen")

    // essen - e→i (Präsens 2s,3s), e→a (Präteritum), e→ä (Konjunktiv II)
    // Note: German spelling ß/ss rules not automatically applied by conjugator
    // Perfektpartizip "gegessen" uses full override due to irregular form
    expectConjugation(infinitiv: "essen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "Isst")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "Isst")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "Ass")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "Ässe")
    expectConjugation(infinitiv: "essen", conjugationgroup: .perfektpartizip, expected: "gegEssen")

    // sterben - uses sprechen pattern (e→i Präsens 2s,3s, e→a Präteritum, e→o Perfektpartizip)
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "stIrbst")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "stIrbt")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stArb")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stÜrbe")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .perfektpartizip, expected: "gestOrben")

    // vergessen - uses geben pattern (e→i Präsens 2s,3s, e→a Präteritum)
    // Note: German spelling ß/ss rules not automatically applied by conjugator
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "vergIsst")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "vergIsst")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "vergAss")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .perfektpartizip, expected: "vergessen")

    // Compound verbs test - ensure prefixed verbs work correctly
    // erfahren - compound of fahren
    expectConjugation(infinitiv: "erfahren", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "erfÄhrt")
    expectConjugation(infinitiv: "erfahren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "erfUhr")
    expectConjugation(infinitiv: "erfahren", conjugationgroup: .perfektpartizip, expected: "erfahren")

    // anbieten - separable prefix compound of bieten
    expectConjugation(infinitiv: "anbieten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "anbOt")
    expectConjugation(infinitiv: "anbieten", conjugationgroup: .perfektpartizip, expected: "angebOten")

    // betragen - compound of tragen
    expectConjugation(infinitiv: "betragen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "betrÄgt")
    expectConjugation(infinitiv: "betragen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "betrUg")
    expectConjugation(infinitiv: "betragen", conjugationgroup: .perfektpartizip, expected: "betragen")

    // stattfinden - separable prefix compound of finden
    expectConjugation(infinitiv: "stattfinden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stattfAnd")
    expectConjugation(infinitiv: "stattfinden", conjugationgroup: .perfektpartizip, expected: "stattgefUnden")
  }

  @Test func newVerbs() {
    // gelten - strong verb with e→i (Präsens 2s/3s), e→a (Präteritum), e→o (Perfektpartizip)
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "gIltst")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "gIlt")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gAlt")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "gAltest")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "gAltet")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gÖlte")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .perfektpartizip, expected: "gegOlten")

    // sprechen - strong verb with e→i (Präsens 2s/3s), e→a (Präteritum), e→o (Perfektpartizip)
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "sprIchst")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "sprIcht")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sprAch")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sprÄche")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .perfektpartizip, expected: "gesprOchen")

    // helfen - uses sprechen ablaut pattern
    expectConjugation(infinitiv: "helfen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "hIlfst")
    expectConjugation(infinitiv: "helfen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "hAlf")
    expectConjugation(infinitiv: "helfen", conjugationgroup: .perfektpartizip, expected: "gehOlfen")

    // lesen - uses sehen ablaut pattern (e→ie Präsens 2s/3s, e→a Präteritum)
    expectConjugation(infinitiv: "lesen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "lIEst")
    expectConjugation(infinitiv: "lesen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "lIEst")
    expectConjugation(infinitiv: "lesen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "lAs")
    expectConjugation(infinitiv: "lesen", conjugationgroup: .perfektpartizip, expected: "gelesen")

    // beginnen - strong verb with i→a (Präteritum), i→o (Perfektpartizip)
    expectConjugation(infinitiv: "beginnen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "begAnn")
    expectConjugation(infinitiv: "beginnen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "begÄnne")
    expectConjugation(infinitiv: "beginnen", conjugationgroup: .perfektpartizip, expected: "begOnnen")

    // denken - mixed verb using bringen pattern (enk→ach)
    expectConjugation(infinitiv: "denken", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "dACHte")
    expectConjugation(infinitiv: "denken", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "dÄCHte")
    expectConjugation(infinitiv: "denken", conjugationgroup: .perfektpartizip, expected: "gedACHt")

    // kennen - mixed verb (e→a Präteritum/Perfektpartizip)
    expectConjugation(infinitiv: "kennen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "kAnnte")
    expectConjugation(infinitiv: "kennen", conjugationgroup: .perfektpartizip, expected: "gekAnnt")

    // bestehen - compound of stehen
    expectConjugation(infinitiv: "bestehen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bestAND")
    expectConjugation(infinitiv: "bestehen", conjugationgroup: .perfektpartizip, expected: "bestANDen")

    // schreiben - uses bleiben ablaut pattern (ei→ie)
    expectConjugation(infinitiv: "schreiben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schrIEb")
    expectConjugation(infinitiv: "schreiben", conjugationgroup: .perfektpartizip, expected: "geschrIEben")

    // Weak verbs - spot check
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "arbeitete")
    expectConjugation(infinitiv: "spielen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "spielte")
    expectConjugation(infinitiv: "suchen", conjugationgroup: .perfektpartizip, expected: "gesucht")
  }

  @Test func plusquamperfektIndikativ() {
    // Weak verb with haben auxiliary - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.secondSingular), expected: "hATtest gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.thirdSingular), expected: "hATte gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.firstPlural), expected: "hATten gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.secondPlural), expected: "hATtet gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.thirdPlural), expected: "hATten gemacht")

    // Strong verb with sein auxiliary - all persons
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "WAR gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.secondSingular), expected: "WARst gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.thirdSingular), expected: "WAR gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.firstPlural), expected: "WARen gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.secondPlural), expected: "WARt gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.thirdPlural), expected: "WARen gegANGen")

    // Strong verb with haben auxiliary
    expectConjugation(infinitiv: "singen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte gesUngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .plusquamperfektIndikativ(.thirdSingular), expected: "hATte gesUngen")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte gebrACHt")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte studiert")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "WAR angekommen")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .plusquamperfektIndikativ(.thirdSingular), expected: "WAR angekommen")

    // Inseparable prefix verb
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte verstANDen")
  }

  @Test func plusquamperfektKonjunktivII() {
    // Weak verb with haben auxiliary - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.secondSingular), expected: "hÄTtest gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.thirdSingular), expected: "hÄTte gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.firstPlural), expected: "hÄTten gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.secondPlural), expected: "hÄTtet gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.thirdPlural), expected: "hÄTten gemacht")

    // Strong verb with sein auxiliary - all persons
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "WÄRe gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.secondSingular), expected: "WÄRest gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.thirdSingular), expected: "WÄRe gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.firstPlural), expected: "WÄRen gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.secondPlural), expected: "WÄRet gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.thirdPlural), expected: "WÄRen gegANGen")

    // Strong verb with haben auxiliary
    expectConjugation(infinitiv: "singen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte gesUngen")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte gebrACHt")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte studiert")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "WÄRe angekommen")

    // Inseparable prefix verb
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte verstANDen")
  }

  @Test func futurIndikativ() {
    // Weak verb - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.secondSingular), expected: "wIrst machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.thirdSingular), expected: "wIrD machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.firstPlural), expected: "werden machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.secondPlural), expected: "werdEt machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.thirdPlural), expected: "werden machen")

    // Strong verb with sein auxiliary
    expectConjugation(infinitiv: "gehen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde gehen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .futurIndikativ(.thirdSingular), expected: "wIrD gehen")

    // Strong verb with haben auxiliary
    expectConjugation(infinitiv: "singen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde singen")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde bringen")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde studieren")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde ankommen")

    // Inseparable prefix verb
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde verstehen")
  }

  @Test func futurKonjunktivI() {
    // Weak verb - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.secondSingular), expected: "werdest machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.thirdSingular), expected: "werde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.firstPlural), expected: "werden machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.secondPlural), expected: "werdet machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.thirdPlural), expected: "werden machen")

    // Strong verb with sein auxiliary
    expectConjugation(infinitiv: "gehen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde gehen")

    // Strong verb with haben auxiliary
    expectConjugation(infinitiv: "singen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde singen")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde bringen")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde studieren")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde ankommen")

    // Inseparable prefix verb
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde verstehen")
  }

  @Test func futurKonjunktivII() {
    // Weak verb - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.secondSingular), expected: "wÜrdest machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.thirdSingular), expected: "wÜrde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.firstPlural), expected: "wÜrden machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.secondPlural), expected: "wÜrdet machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.thirdPlural), expected: "wÜrden machen")

    // Strong verb with sein auxiliary
    expectConjugation(infinitiv: "gehen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde gehen")

    // Strong verb with haben auxiliary
    expectConjugation(infinitiv: "singen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde singen")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde bringen")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde studieren")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde ankommen")

    // Inseparable prefix verb
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde verstehen")
  }

  @Test func newAblautGroupsPhase2() {
    // fangen - a→ä (Präsens 2s,3s), a→i (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "fÄngst")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "fÄngt")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "fIng")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fInge")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .perfektpartizip, expected: "gefangen")

    // anfangen - separable prefix compound of fangen
    expectConjugation(infinitiv: "anfangen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "anfÄngt")
    expectConjugation(infinitiv: "anfangen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "anfIng")
    expectConjugation(infinitiv: "anfangen", conjugationgroup: .perfektpartizip, expected: "angefangen")

    // fliegen - ie→o (Präteritum, Perfektpartizip), ie→ö (Konjunktiv II)
    expectConjugation(infinitiv: "fliegen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "flOg")
    expectConjugation(infinitiv: "fliegen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "flÖge")
    expectConjugation(infinitiv: "fliegen", conjugationgroup: .perfektpartizip, expected: "geflOgen")

    // gebären - ä→ie (Präsens 2s,3s), ä→a (Präteritum), ä→ä (Konj II), ä→o (Perfektpartizip)
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "gebIERst")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "gebIERt")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gebAR")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gebÄRe")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .perfektpartizip, expected: "gebORen")

    // greifen - eif→iff (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "greifen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "grIFF")
    expectConjugation(infinitiv: "greifen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "grIFFe")
    expectConjugation(infinitiv: "greifen", conjugationgroup: .perfektpartizip, expected: "gegrIFFen")

    // heben - e→o (Präteritum, Perfektpartizip), e→ö (Konjunktiv II)
    expectConjugation(infinitiv: "heben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "hOb")
    expectConjugation(infinitiv: "heben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "hÖbe")
    expectConjugation(infinitiv: "heben", conjugationgroup: .perfektpartizip, expected: "gehOben")

    // erheben - inseparable prefix compound of heben
    expectConjugation(infinitiv: "erheben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "erhOb")
    expectConjugation(infinitiv: "erheben", conjugationgroup: .perfektpartizip, expected: "erhOben")

    // schlafen - a→ä (Präsens 2s,3s), a→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "schlÄfst")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "schlÄft")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schlIEf")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schlIEfe")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .perfektpartizip, expected: "geschlafen")

    // schneiden - ei→itt (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schnITT")
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schnITTe")
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .perfektpartizip, expected: "geschnITTen")

    // stoßen - o→ö (Präsens 2s,3s), o→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "stÖßt")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "stÖßt")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stIEß")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stIEße")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .perfektpartizip, expected: "gestoßen")

    // werfen - e→i (Präsens 2s,3s), e→a (Präteritum), e→ü (Konjunktiv II), e→o (Perfektpartizip)
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wIrfst")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wIrft")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wArf")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜrfe")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .perfektpartizip, expected: "gewOrfen")

    // Compound verb tests for new patterns
    // verschwinden - uses finden pattern with inseparable prefix
    expectConjugation(infinitiv: "verschwinden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "verschwAnd")
    expectConjugation(infinitiv: "verschwinden", conjugationgroup: .perfektpartizip, expected: "verschwUnden")

    // trinken - uses singen pattern
    expectConjugation(infinitiv: "trinken", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trAnk")
    expectConjugation(infinitiv: "trinken", conjugationgroup: .perfektpartizip, expected: "getrUnken")

    // klingen - uses singen pattern
    expectConjugation(infinitiv: "klingen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "klAng")
    expectConjugation(infinitiv: "klingen", conjugationgroup: .perfektpartizip, expected: "geklUngen")

    // leiden - uses bleiben pattern
    expectConjugation(infinitiv: "leiden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "lITT")
    expectConjugation(infinitiv: "leiden", conjugationgroup: .perfektpartizip, expected: "gelITTen")

    // brechen - uses sprechen pattern
    expectConjugation(infinitiv: "brechen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "brIcht")
    expectConjugation(infinitiv: "brechen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "brAch")
    expectConjugation(infinitiv: "brechen", conjugationgroup: .perfektpartizip, expected: "gebrOchen")

    // messen - uses geben pattern
    expectConjugation(infinitiv: "messen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "mIsst")
    expectConjugation(infinitiv: "messen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "mAss")
    expectConjugation(infinitiv: "messen", conjugationgroup: .perfektpartizip, expected: "gemessen")
  }

  @Test func newAblautGroupsPhase3() {
    // reißen - eiß→iss (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "rISS")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "rISSt")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rISSe")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .perfektpartizip, expected: "gerISSen")

    // streichen - eich→ich (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "strICH")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "strICHst")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "strICHe")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .perfektpartizip, expected: "gestrICHen")

    // schreiten (via überschreiten) - eit→itt (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "überschrITT")
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "überschrITTe")
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .perfektpartizip, expected: "überschrITTen")

    // Additional strong verbs from verbs 401-600
    // zwingen - uses singen pattern (i→a Prät, i→ä Konj II, i→u PP)
    expectConjugation(infinitiv: "zwingen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "zwAng")
    expectConjugation(infinitiv: "zwingen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "zwÄnge")
    expectConjugation(infinitiv: "zwingen", conjugationgroup: .perfektpartizip, expected: "gezwUngen")

    // springen - uses singen pattern, with sein auxiliary
    expectConjugation(infinitiv: "springen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sprAng")
    expectConjugation(infinitiv: "springen", conjugationgroup: .perfektpartizip, expected: "gesprUngen")
    expectConjugation(infinitiv: "springen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gesprUngen")

    // sinken - uses singen pattern, with sein auxiliary
    expectConjugation(infinitiv: "sinken", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sAnk")
    expectConjugation(infinitiv: "sinken", conjugationgroup: .perfektpartizip, expected: "gesUnken")

    // schieben - uses bieten pattern (ie→o Prät/PP, ie→ö Konj II)
    expectConjugation(infinitiv: "schieben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schOb")
    expectConjugation(infinitiv: "schieben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schÖbe")
    expectConjugation(infinitiv: "schieben", conjugationgroup: .perfektpartizip, expected: "geschOben")

    // verschieben - inseparable prefix compound of schieben
    expectConjugation(infinitiv: "verschieben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "verschOb")
    expectConjugation(infinitiv: "verschieben", conjugationgroup: .perfektpartizip, expected: "verschOben")

    // waschen - uses wachsen pattern (a→ä Präs 2s/3s, a→u Prät, a→ü Konj II)
    expectConjugation(infinitiv: "waschen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wÄschst")
    expectConjugation(infinitiv: "waschen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wUsch")
    expectConjugation(infinitiv: "waschen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜsche")
    expectConjugation(infinitiv: "waschen", conjugationgroup: .perfektpartizip, expected: "gewaschen")

    // bewerben - uses sterben pattern (e→i Präs 2s/3s, e→a Prät, e→ü Konj II, e→o PP)
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "bewIrbt")
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bewArb")
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "bewÜrbe")
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .perfektpartizip, expected: "bewOrben")

    // raten - uses halten pattern (a→ä Präs 2s/3s, a→ie Prät/Konj II)
    expectConjugation(infinitiv: "raten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "rÄtst")
    expectConjugation(infinitiv: "raten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "rÄt")
    expectConjugation(infinitiv: "raten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "rIEt")
    expectConjugation(infinitiv: "raten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rIEte")
    expectConjugation(infinitiv: "raten", conjugationgroup: .perfektpartizip, expected: "geraten")

    // geraten - inseparable ge- prefix, uses halten pattern
    expectConjugation(infinitiv: "geraten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gerIEt")
    expectConjugation(infinitiv: "geraten", conjugationgroup: .perfektpartizip, expected: "geraten")
    expectConjugation(infinitiv: "geraten", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geraten")
  }

  @Test func schreienAblaut() {
    // schreien - uses the schreien ablaut pattern with contracted Perfektpartizip
    // Pattern: IE,bA,dA|geschrIEn*,pp (contracted from *geschrieen)
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "schreie")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "schreit")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schrIE")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "schrIE")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schrIEe")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .perfektpartizip, expected: "geschrIEn")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe geschrIEn")
  }

  @Test func schaffenAblaut() {
    // erschaffen - uses the schaffen ablaut pattern for the strong verb meaning "create"
    // Pattern: U,bA|Ü,dA (Präteritum u, Konjunktiv II ü)
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "erschaffe")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "erschafft")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "erschUF")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "erschUF")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "erschÜFe")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .perfektpartizip, expected: "erschaffen")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe erschaffen")
  }

  @Test func modalVerbs() {
    // mögen - Präsens singular has full overrides, regular weak-style elsewhere
    // Pattern: mAG*,a1s,a3s|mAGst*,a2s|OCH,bA,pp|ÖCH,dA
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "mAG")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "mAGst")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "mAG")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "mOCHte")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "mÖCHte")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .perfektpartizip, expected: "gemOCHt")

    // wissen - Präsens singular has full overrides, iss→uss/üss elsewhere
    // Pattern: wEIsS*,a1s,a3s|wEISst*,a2s|USS,bA,pp|ÜSS,dA
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "wEIsS")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wEISst")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wEIsS")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wUSSte")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜSSte")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .perfektpartizip, expected: "gewUSSt")

    // wollen - Präsens singular has full overrides, regular weak-style elsewhere
    // Pattern: wIlL*,a1s,a3s|wIllst*,a2s
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "wIlL")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wIllst")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wIlL")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wollte")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .perfektpartizip, expected: "gewollt")
  }

  @Test func weakVerbsWithTStems() {
    // arbeiten: Präsens Indikativ 3s should get epenthetic "e" → "arbeitet" not "arbeitt"
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "arbeitet")
    // arbeiten: Präsens Indikativ 2p
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "arbeitet")
    // kosten: Präsens Indikativ 3s
    expectConjugation(infinitiv: "kosten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "kostet")
  }

  private func expectConjugation(
    infinitiv: String,
    conjugationgroup: Conjugationgroup,
    expected: String,
    sourceLocation: SourceLocation = #_sourceLocation
  ) {
    let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup)
    switch result {
    case .success(let conjugation):
      #expect(conjugation == expected, "Expected \(infinitiv) → \(expected), got \(conjugation)", sourceLocation: sourceLocation)
    case .failure(let err):
      Issue.record("Failed to conjugate \(infinitiv): \(err)", sourceLocation: sourceLocation)
    }
  }
}
