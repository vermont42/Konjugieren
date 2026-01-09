// Copyright © 2025 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

struct ConjugatorTests {
  @Test func perfektpartizip() {
    // Weak verb
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektpartizip, expected: "gemacht")

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

    expectConjugation(infinitiv: "gehen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "gIng")

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

  @Test func präteritumKonditional() {
    // Weak verb - all persons (uses -te endings, same as Präteritum for weak verbs)
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonditional(.firstSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonditional(.secondSingular), expected: "machtest")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonditional(.thirdSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonditional(.firstPlural), expected: "machten")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonditional(.secondPlural), expected: "machtet")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonditional(.thirdPlural), expected: "machten")

    // Strong verb (ablaut often includes umlaut, Konjunktiv II endings)
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonditional(.firstSingular), expected: "sÄnge")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonditional(.secondSingular), expected: "sÄngest")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonditional(.thirdSingular), expected: "sÄnge")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonditional(.firstPlural), expected: "sÄngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonditional(.secondPlural), expected: "sÄnget")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonditional(.thirdPlural), expected: "sÄngen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .präteritumKonditional(.firstSingular), expected: "sÄhe")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .präteritumKonditional(.firstSingular), expected: "gInge")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumKonditional(.firstSingular), expected: "brÄCHte")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumKonditional(.thirdSingular), expected: "brÄCHte")

    // Irregular sein (WÄR replaces ablaut region, endings added in lowercase)
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonditional(.firstSingular), expected: "WÄRe")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonditional(.secondSingular), expected: "WÄRest")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonditional(.thirdSingular), expected: "WÄRe")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonditional(.firstPlural), expected: "WÄRen")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonditional(.secondPlural), expected: "WÄRet")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonditional(.thirdPlural), expected: "WÄRen")

    // -ieren verb
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präteritumKonditional(.firstSingular), expected: "studierte")

    // Separable prefix verb
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präteritumKonditional(.firstSingular), expected: "ankÄme")
  }

  @Test func perfektIndikativ() {
    // Weak verb with haben auxiliary - all persons
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.secondSingular), expected: "hast gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hat gemacht")
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
    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hat gesUngen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gesehen")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hat gesehen")

    // Mixed verb
    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gebrACHt")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hat gebrACHt")

    // -ieren verb (no ge- prefix)
    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe studiert")
    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hat studiert")

    // Separable prefix verb (sein auxiliary reflects corrected ablaut)
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN angekommen")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST angekommen")

    // Inseparable prefix verb
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe verstANDen")
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hat verstANDen")
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
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndicativ(.secondPlural), expected: "wErdEt")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndicativ(.thirdPlural), expected: "werden")

    // Präteritum Indikativ
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "wUrdE")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.secondSingular), expected: "wUrdEst")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.thirdSingular), expected: "wUrdE")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.firstPlural), expected: "wUrden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.secondPlural), expected: "wUrdEt")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndicativ(.thirdPlural), expected: "wUrden")

    // Präteritum Konditional (Konjunktiv II)
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonditional(.firstSingular), expected: "wÜrde")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonditional(.secondSingular), expected: "wÜrdest")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonditional(.thirdSingular), expected: "wÜrde")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonditional(.firstPlural), expected: "wÜrden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonditional(.secondPlural), expected: "wÜrdet")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonditional(.thirdPlural), expected: "wÜrden")

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
