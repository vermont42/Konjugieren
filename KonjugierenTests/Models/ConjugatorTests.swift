// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

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

  @Test func präsensIndicativ() {
    // Weak verb - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "mache")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "machst")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "macht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndicativ(.firstPlural), expected: "machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndicativ(.secondPlural), expected: "macht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndicativ(.thirdPlural), expected: "machen")

    // Strong verb with e→i ablaut (sehen: e→ie in 2s, 3s)
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "sehe")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "sIEhst")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "sIEht")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndicativ(.firstPlural), expected: "sehen")

    // Strong verb lassen: 2s has full override showing irregular ending, 3s has standard ablaut
    expectConjugation(infinitiv: "lassen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "lÄssEst")
    expectConjugation(infinitiv: "lassen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "lÄsst")

    // Irregular sein (uppercase shows ablaut, lowercase shows unchanged portions)
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "BIN")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "BIst")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "IST")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndicativ(.firstPlural), expected: "sIND")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndicativ(.secondPlural), expected: "seiD")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndicativ(.thirdPlural), expected: "sIND")

    // Irregular haben (uppercase A shows stem vowel change from "ab" to "A")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "habe")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "hAst")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "hAt")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "studiere")
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "studiert")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "ankomme")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "ankommt")
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

  @Test func präteritumIndicativ() {
    // Weak verb - all persons (uses -te endings)
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "machtest")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndicativ(.firstPlural), expected: "machten")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndicativ(.secondPlural), expected: "machtet")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndicativ(.thirdPlural), expected: "machten")

    // Strong verb (ablaut, no -te suffix)
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "sAng")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "sAngst")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "sAng")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndicativ(.firstPlural), expected: "sAngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndicativ(.secondPlural), expected: "sAngt")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndicativ(.thirdPlural), expected: "sAngen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "sAh")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "sAh")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "gING")

    // Mixed verb (ablaut + -te suffix)
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "brACHte")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "brACHtest")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "brACHte")

    // Irregular sein (WAR replaces ablaut region, endings added in lowercase)
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "WAR")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "WARst")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "WAR")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndicativ(.firstPlural), expected: "WARen")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndicativ(.secondPlural), expected: "WARt")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndicativ(.thirdPlural), expected: "WARen")

    // -ieren verb (weak-style endings)
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "studierte")
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "studierte")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "ankAm")
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
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "werde")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "wIrst")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "wIrD")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndicativ(.firstPlural), expected: "werden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndicativ(.secondPlural), expected: "werdEt")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndicativ(.thirdPlural), expected: "werden")

    // Präteritum Indikativ
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "wUrdE")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "wUrdEst")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "wUrdE")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.firstPlural), expected: "wUrden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.secondPlural), expected: "wUrdEt")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.thirdPlural), expected: "wUrden")

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
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "tue")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "tust")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "tut")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndicativ(.firstPlural), expected: "tun")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndicativ(.secondPlural), expected: "tut")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndicativ(.thirdPlural), expected: "tun")

    // Präteritum Indikativ - u→at, with e-insertion for 2s/2p
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "tAT")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "tATest")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "tAT")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndicativ(.firstPlural), expected: "tATen")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndicativ(.secondPlural), expected: "tATet")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndicativ(.thirdPlural), expected: "tATen")

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
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "fÄhrst")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "fÄhrt")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "fUhr")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fÜhre")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .perfektpartizip, expected: "gefahren")

    // laufen - au→äu (Präsens 2s,3s), au→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "lÄUfst")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "lÄUft")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "lIEf")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "lIEfe")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .perfektpartizip, expected: "gelaufen")

    // fallen - all→äll (Präsens 2s,3s), all→iel (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "fÄLLst")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "fÄLLt")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "fIEL")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fIELe")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .perfektpartizip, expected: "gefallen")

    // treffen - eff→iff (Präsens 2s,3s), eff→af (Präteritum), eff→äf (Konjunktiv II), eff→off (Perfektpartizip)
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "trIFFst")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "trIFFt")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "trAF")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÄFe")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .perfektpartizip, expected: "getrOFFen")

    // schließen - ie→o (Präteritum, Perfektpartizip), ie→ö (Konjunktiv II)
    // Note: German spelling would convert ß→ss after short vowel, but conjugator preserves consonant
    expectConjugation(infinitiv: "schließen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "schlOß")
    expectConjugation(infinitiv: "schließen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schlÖße")
    expectConjugation(infinitiv: "schließen", conjugationgroup: .perfektpartizip, expected: "geschlOßen")

    // heißen - ei→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "heißen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "hIEß")
    expectConjugation(infinitiv: "heißen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "hIEße")
    expectConjugation(infinitiv: "heißen", conjugationgroup: .perfektpartizip, expected: "geheißen")

    // ziehen - ieh→og (Präteritum, Perfektpartizip), ieh→ög (Konjunktiv II)
    expectConjugation(infinitiv: "ziehen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "zOG")
    expectConjugation(infinitiv: "ziehen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "zÖGe")
    expectConjugation(infinitiv: "ziehen", conjugationgroup: .perfektpartizip, expected: "gezOGen")

    // tragen - a→ä (Präsens 2s,3s), a→u (Präteritum), a→ü (Konjunktiv II)
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "trÄgst")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "trÄgt")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "trUg")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÜge")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .perfektpartizip, expected: "getragen")

    // gewinnen - i→a (Präteritum), i→ä (Konjunktiv II), i→o (Perfektpartizip)
    expectConjugation(infinitiv: "gewinnen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "gewAnn")
    expectConjugation(infinitiv: "gewinnen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gewÄnne")
    expectConjugation(infinitiv: "gewinnen", conjugationgroup: .perfektpartizip, expected: "gewOnnen")

    // empfehlen - e→ie (Präsens 2s,3s), e→a (Präteritum), e→ä (Konjunktiv II), e→o (Perfektpartizip)
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "empfIEhlst")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "empfIEhlt")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "empfAhl")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "empfÄhle")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .perfektpartizip, expected: "empfOhlen")

    // treten - et→itt (Präsens 2s,3s), et→at (Präteritum), et→ät (Konjunktiv II), et→et (Perfektpartizip)
    // Note: 3s ending -t merges with stamm ending -tt (German phonology)
    expectConjugation(infinitiv: "treten", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "trITTst")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "trITT")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "trAT")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÄTe")
    expectConjugation(infinitiv: "treten", conjugationgroup: .perfektpartizip, expected: "getrETen")

    // verlieren - ie→o (Präteritum, Perfektpartizip), ie→ö (Konjunktiv II)
    expectConjugation(infinitiv: "verlieren", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "verlOr")
    expectConjugation(infinitiv: "verlieren", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "verlÖre")
    expectConjugation(infinitiv: "verlieren", conjugationgroup: .perfektpartizip, expected: "verlOren")

    // steigen - ei→ie (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "steigen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "stIEg")
    expectConjugation(infinitiv: "steigen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stIEge")
    expectConjugation(infinitiv: "steigen", conjugationgroup: .perfektpartizip, expected: "gestIEgen")

    // erscheinen - ei→ie (Präteritum, Konjunktiv II, Perfektpartizip) with inseparable prefix
    expectConjugation(infinitiv: "erscheinen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "erschIEn")
    expectConjugation(infinitiv: "erscheinen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "erschIEne")
    expectConjugation(infinitiv: "erscheinen", conjugationgroup: .perfektpartizip, expected: "erschIEnen")

    // gelingen - i→a (Präteritum), i→ä (Konjunktiv II), i→u (Perfektpartizip)
    expectConjugation(infinitiv: "gelingen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "gelAng")
    expectConjugation(infinitiv: "gelingen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gelÄnge")
    expectConjugation(infinitiv: "gelingen", conjugationgroup: .perfektpartizip, expected: "gelUngen")

    // schlagen - a→ä (Präsens 2s,3s), a→u (Präteritum), a→ü (Konjunktiv II)
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "schlÄgst")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "schlÄgt")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "schlUg")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schlÜge")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .perfektpartizip, expected: "geschlagen")

    // laden - a→ä (Präsens 2s,3s), a→u (Präteritum), a→ü (Konjunktiv II)
    expectConjugation(infinitiv: "laden", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "lÄdst")
    expectConjugation(infinitiv: "laden", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "lÄdt")
    expectConjugation(infinitiv: "laden", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "lUd")
    expectConjugation(infinitiv: "laden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "lÜde")
    expectConjugation(infinitiv: "laden", conjugationgroup: .perfektpartizip, expected: "geladen")

    // wachsen - a→ä (Präsens 2s,3s), a→u (Präteritum), a→ü (Konjunktiv II)
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "wÄchst")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "wÄchst")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "wUchs")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜchse")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .perfektpartizip, expected: "gewachsen")

    // rufen - u→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "rufen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "rIEf")
    expectConjugation(infinitiv: "rufen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rIEfe")
    expectConjugation(infinitiv: "rufen", conjugationgroup: .perfektpartizip, expected: "gerufen")

    // weisen - ei→ie (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "weisen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "wIEs")
    expectConjugation(infinitiv: "weisen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wIEse")
    expectConjugation(infinitiv: "weisen", conjugationgroup: .perfektpartizip, expected: "gewIEsen")

    // genießen - ie→o (Präteritum, Perfektpartizip), ie→ö (Konjunktiv II)
    // Note: genießen uses schließen pattern, ge- is inseparable prefix (no double ge-)
    // German spelling would convert ß→ss after short vowel, but conjugator preserves consonant
    expectConjugation(infinitiv: "genießen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "genOß")
    expectConjugation(infinitiv: "genießen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "genÖße")
    expectConjugation(infinitiv: "genießen", conjugationgroup: .perfektpartizip, expected: "genOßen")

    // bitten - itt→at (Präteritum), itt→ät (Konjunktiv II), itt→et (Perfektpartizip)
    expectConjugation(infinitiv: "bitten", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "bAT")
    expectConjugation(infinitiv: "bitten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "bÄTe")
    expectConjugation(infinitiv: "bitten", conjugationgroup: .perfektpartizip, expected: "gebETen")

    // essen - e→i (Präsens 2s,3s), e→a (Präteritum), e→ä (Konjunktiv II)
    // Note: German spelling ß/ss rules not automatically applied by conjugator
    // Perfektpartizip "gegessen" uses full override due to irregular form
    expectConjugation(infinitiv: "essen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "Isst")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "Isst")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "Ass")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "Ässe")
    expectConjugation(infinitiv: "essen", conjugationgroup: .perfektpartizip, expected: "gegEssen")

    // sterben - uses sprechen pattern (e→i Präsens 2s,3s, e→a Präteritum, e→o Perfektpartizip)
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "stIrbst")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "stIrbt")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "stArb")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stÜrbe")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .perfektpartizip, expected: "gestOrben")

    // vergessen - uses geben pattern (e→i Präsens 2s,3s, e→a Präteritum)
    // Note: German spelling ß/ss rules not automatically applied by conjugator
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "vergIsst")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "vergIsst")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "vergAss")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .perfektpartizip, expected: "vergessen")

    // Compound verbs test - ensure prefixed verbs work correctly
    // erfahren - compound of fahren
    expectConjugation(infinitiv: "erfahren", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "erfÄhrt")
    expectConjugation(infinitiv: "erfahren", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "erfUhr")
    expectConjugation(infinitiv: "erfahren", conjugationgroup: .perfektpartizip, expected: "erfahren")

    // anbieten - separable prefix compound of bieten
    expectConjugation(infinitiv: "anbieten", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "anbOt")
    expectConjugation(infinitiv: "anbieten", conjugationgroup: .perfektpartizip, expected: "angebOten")

    // betragen - compound of tragen
    expectConjugation(infinitiv: "betragen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "betrÄgt")
    expectConjugation(infinitiv: "betragen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "betrUg")
    expectConjugation(infinitiv: "betragen", conjugationgroup: .perfektpartizip, expected: "betragen")

    // stattfinden - separable prefix compound of finden
    expectConjugation(infinitiv: "stattfinden", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "stattfAnd")
    expectConjugation(infinitiv: "stattfinden", conjugationgroup: .perfektpartizip, expected: "stattgefUnden")
  }

  @Test func newVerbs() {
    // gelten - strong verb with e→i (Präsens 2s/3s), e→a (Präteritum), e→o (Perfektpartizip)
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "gIltst")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "gIlt")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "gAlt")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "gAltest")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumIndicativ(.secondPlural), expected: "gAltet")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gÖlte")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .perfektpartizip, expected: "gegOlten")

    // sprechen - strong verb with e→i (Präsens 2s/3s), e→a (Präteritum), e→o (Perfektpartizip)
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "sprIchst")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "sprIcht")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "sprAch")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sprÄche")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .perfektpartizip, expected: "gesprOchen")

    // helfen - uses sprechen ablaut pattern
    expectConjugation(infinitiv: "helfen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "hIlfst")
    expectConjugation(infinitiv: "helfen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "hAlf")
    expectConjugation(infinitiv: "helfen", conjugationgroup: .perfektpartizip, expected: "gehOlfen")

    // lesen - uses sehen ablaut pattern (e→ie Präsens 2s/3s, e→a Präteritum)
    expectConjugation(infinitiv: "lesen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "lIEst")
    expectConjugation(infinitiv: "lesen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "lIEst")
    expectConjugation(infinitiv: "lesen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "lAs")
    expectConjugation(infinitiv: "lesen", conjugationgroup: .perfektpartizip, expected: "gelesen")

    // beginnen - strong verb with i→a (Präteritum), i→o (Perfektpartizip)
    expectConjugation(infinitiv: "beginnen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "begAnn")
    expectConjugation(infinitiv: "beginnen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "begÄnne")
    expectConjugation(infinitiv: "beginnen", conjugationgroup: .perfektpartizip, expected: "begOnnen")

    // denken - mixed verb using bringen pattern (enk→ach)
    expectConjugation(infinitiv: "denken", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "dACHte")
    expectConjugation(infinitiv: "denken", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "dÄCHte")
    expectConjugation(infinitiv: "denken", conjugationgroup: .perfektpartizip, expected: "gedACHt")

    // kennen - mixed verb (e→a Präteritum/Perfektpartizip)
    expectConjugation(infinitiv: "kennen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "kAnnte")
    expectConjugation(infinitiv: "kennen", conjugationgroup: .perfektpartizip, expected: "gekAnnt")

    // bestehen - compound of stehen
    expectConjugation(infinitiv: "bestehen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "bestAND")
    expectConjugation(infinitiv: "bestehen", conjugationgroup: .perfektpartizip, expected: "bestANDen")

    // schreiben - uses bleiben ablaut pattern (ei→ie)
    expectConjugation(infinitiv: "schreiben", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "schrIEb")
    expectConjugation(infinitiv: "schreiben", conjugationgroup: .perfektpartizip, expected: "geschrIEben")

    // Weak verbs - spot check
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "arbeitete")
    expectConjugation(infinitiv: "spielen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "spielte")
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
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "fÄngst")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "fÄngt")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "fIng")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fInge")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .perfektpartizip, expected: "gefangen")

    // anfangen - separable prefix compound of fangen
    expectConjugation(infinitiv: "anfangen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "anfÄngt")
    expectConjugation(infinitiv: "anfangen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "anfIng")
    expectConjugation(infinitiv: "anfangen", conjugationgroup: .perfektpartizip, expected: "angefangen")

    // fliegen - ie→o (Präteritum, Perfektpartizip), ie→ö (Konjunktiv II)
    expectConjugation(infinitiv: "fliegen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "flOg")
    expectConjugation(infinitiv: "fliegen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "flÖge")
    expectConjugation(infinitiv: "fliegen", conjugationgroup: .perfektpartizip, expected: "geflOgen")

    // gebären - ä→ie (Präsens 2s,3s), ä→a (Präteritum), ä→ä (Konj II), ä→o (Perfektpartizip)
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "gebIERst")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "gebIERt")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "gebAR")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gebÄRe")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .perfektpartizip, expected: "gebORen")

    // greifen - eif→iff (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "greifen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "grIFF")
    expectConjugation(infinitiv: "greifen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "grIFFe")
    expectConjugation(infinitiv: "greifen", conjugationgroup: .perfektpartizip, expected: "gegrIFFen")

    // heben - e→o (Präteritum, Perfektpartizip), e→ö (Konjunktiv II)
    expectConjugation(infinitiv: "heben", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "hOb")
    expectConjugation(infinitiv: "heben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "hÖbe")
    expectConjugation(infinitiv: "heben", conjugationgroup: .perfektpartizip, expected: "gehOben")

    // erheben - inseparable prefix compound of heben
    expectConjugation(infinitiv: "erheben", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "erhOb")
    expectConjugation(infinitiv: "erheben", conjugationgroup: .perfektpartizip, expected: "erhOben")

    // schlafen - a→ä (Präsens 2s,3s), a→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "schlÄfst")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "schlÄft")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "schlIEf")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schlIEfe")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .perfektpartizip, expected: "geschlafen")

    // schneiden - ei→itt (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "schnITT")
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schnITTe")
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .perfektpartizip, expected: "geschnITTen")

    // stoßen - o→ö (Präsens 2s,3s), o→ie (Präteritum, Konjunktiv II)
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "stÖßt")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "stÖßt")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "stIEß")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stIEße")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .perfektpartizip, expected: "gestoßen")

    // werfen - e→i (Präsens 2s,3s), e→a (Präteritum), e→ü (Konjunktiv II), e→o (Perfektpartizip)
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "wIrfst")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "wIrft")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "wArf")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜrfe")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .perfektpartizip, expected: "gewOrfen")

    // Compound verb tests for new patterns
    // verschwinden - uses finden pattern with inseparable prefix
    expectConjugation(infinitiv: "verschwinden", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "verschwAnd")
    expectConjugation(infinitiv: "verschwinden", conjugationgroup: .perfektpartizip, expected: "verschwUnden")

    // trinken - uses singen pattern
    expectConjugation(infinitiv: "trinken", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "trAnk")
    expectConjugation(infinitiv: "trinken", conjugationgroup: .perfektpartizip, expected: "getrUnken")

    // klingen - uses singen pattern
    expectConjugation(infinitiv: "klingen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "klAng")
    expectConjugation(infinitiv: "klingen", conjugationgroup: .perfektpartizip, expected: "geklUngen")

    // leiden - uses bleiben pattern
    expectConjugation(infinitiv: "leiden", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "lITT")
    expectConjugation(infinitiv: "leiden", conjugationgroup: .perfektpartizip, expected: "gelITTen")

    // brechen - uses sprechen pattern
    expectConjugation(infinitiv: "brechen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "brIcht")
    expectConjugation(infinitiv: "brechen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "brAch")
    expectConjugation(infinitiv: "brechen", conjugationgroup: .perfektpartizip, expected: "gebrOchen")

    // messen - uses geben pattern
    expectConjugation(infinitiv: "messen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "mIsst")
    expectConjugation(infinitiv: "messen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "mAss")
    expectConjugation(infinitiv: "messen", conjugationgroup: .perfektpartizip, expected: "gemessen")
  }

  @Test func newAblautGroupsPhase3() {
    // reißen - eiß→iss (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "rISS")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "rISSt")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rISSe")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .perfektpartizip, expected: "gerISSen")

    // streichen - eich→ich (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "strICH")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "strICHst")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "strICHe")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .perfektpartizip, expected: "gestrICHen")

    // schreiten (via überschreiten) - eit→itt (Präteritum, Konjunktiv II, Perfektpartizip)
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "überschrITT")
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "überschrITTe")
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .perfektpartizip, expected: "überschrITTen")

    // Additional strong verbs from verbs 401-600
    // zwingen - uses singen pattern (i→a Prät, i→ä Konj II, i→u PP)
    expectConjugation(infinitiv: "zwingen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "zwAng")
    expectConjugation(infinitiv: "zwingen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "zwÄnge")
    expectConjugation(infinitiv: "zwingen", conjugationgroup: .perfektpartizip, expected: "gezwUngen")

    // springen - uses singen pattern, with sein auxiliary
    expectConjugation(infinitiv: "springen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "sprAng")
    expectConjugation(infinitiv: "springen", conjugationgroup: .perfektpartizip, expected: "gesprUngen")
    expectConjugation(infinitiv: "springen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gesprUngen")

    // sinken - uses singen pattern, with sein auxiliary
    expectConjugation(infinitiv: "sinken", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "sAnk")
    expectConjugation(infinitiv: "sinken", conjugationgroup: .perfektpartizip, expected: "gesUnken")

    // schieben - uses bieten pattern (ie→o Prät/PP, ie→ö Konj II)
    expectConjugation(infinitiv: "schieben", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "schOb")
    expectConjugation(infinitiv: "schieben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schÖbe")
    expectConjugation(infinitiv: "schieben", conjugationgroup: .perfektpartizip, expected: "geschOben")

    // verschieben - inseparable prefix compound of schieben
    expectConjugation(infinitiv: "verschieben", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "verschOb")
    expectConjugation(infinitiv: "verschieben", conjugationgroup: .perfektpartizip, expected: "verschOben")

    // waschen - uses wachsen pattern (a→ä Präs 2s/3s, a→u Prät, a→ü Konj II)
    expectConjugation(infinitiv: "waschen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "wÄschst")
    expectConjugation(infinitiv: "waschen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "wUsch")
    expectConjugation(infinitiv: "waschen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜsche")
    expectConjugation(infinitiv: "waschen", conjugationgroup: .perfektpartizip, expected: "gewaschen")

    // bewerben - uses sterben pattern (e→i Präs 2s/3s, e→a Prät, e→ü Konj II, e→o PP)
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "bewIrbt")
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "bewArb")
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "bewÜrbe")
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .perfektpartizip, expected: "bewOrben")

    // raten - uses halten pattern (a→ä Präs 2s/3s, a→ie Prät/Konj II)
    expectConjugation(infinitiv: "raten", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "rÄtst")
    expectConjugation(infinitiv: "raten", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "rÄt")
    expectConjugation(infinitiv: "raten", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "rIEt")
    expectConjugation(infinitiv: "raten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rIEte")
    expectConjugation(infinitiv: "raten", conjugationgroup: .perfektpartizip, expected: "geraten")

    // geraten - inseparable ge- prefix, uses halten pattern
    expectConjugation(infinitiv: "geraten", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "gerIEt")
    expectConjugation(infinitiv: "geraten", conjugationgroup: .perfektpartizip, expected: "geraten")
    expectConjugation(infinitiv: "geraten", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geraten")
  }

  @Test func schreienAblaut() {
    // schreien - uses the schreien ablaut pattern with contracted Perfektpartizip
    // Pattern: IE,bA,dA|geschrIEn*,pp (contracted from *geschrieen)
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "schreie")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "schreit")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "schrIE")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "schrIE")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schrIEe")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .perfektpartizip, expected: "geschrIEn")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe geschrIEn")
  }

  @Test func schaffenAblaut() {
    // erschaffen - uses the schaffen ablaut pattern for the strong verb meaning "create"
    // Pattern: U,bA|Ü,dA (Präteritum u, Konjunktiv II ü)
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "erschaffe")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "erschafft")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "erschUF")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "erschUF")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "erschÜFe")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .perfektpartizip, expected: "erschaffen")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe erschaffen")
  }

  @Test func modalVerbs() {
    // mögen - Präsens singular has full overrides, regular weak-style elsewhere
    // Pattern: mAG*,a1s,a3s|mAGst*,a2s|OCH,bA,pp|ÖCH,dA
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "mAG")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "mAGst")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "mAG")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "mOCHte")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "mÖCHte")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .perfektpartizip, expected: "gemOCHt")

    // wissen - Präsens singular has full overrides, iss→uss/üss elsewhere
    // Pattern: wEIsS*,a1s,a3s|wEISst*,a2s|USS,bA,pp|ÜSS,dA
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "wEIsS")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "wEISst")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "wEIsS")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "wUSSte")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜSSte")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .perfektpartizip, expected: "gewUSSt")

    // wollen - Präsens singular has full overrides, regular weak-style elsewhere
    // Pattern: wIlL*,a1s,a3s|wIllst*,a2s
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "wIlL")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndicativ(.secondSingular), expected: "wIllst")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndicativ(.thirdSingular), expected: "wIlL")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "wollte")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .perfektpartizip, expected: "gewollt")
  }

  private func expectConjugation(infinitiv: String, conjugationgroup: Conjugationgroup, expected: String) {
    let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup)
    switch result {
    case .success(let conjugation):
      #expect(conjugation == expected, "Expected \(infinitiv) → \(expected), got \(conjugation)")
    case .failure(let err):
      Issue.record("Failed to conjugate \(infinitiv): \(err)")
    }
  }
}
