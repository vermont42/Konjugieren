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
