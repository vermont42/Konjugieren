// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@Suite("Conjugator")
@MainActor
struct ConjugatorTests {
  @Test func perfektpartizip() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektpartizip, expected: "gemacht")

    // Weak verb with stamm ending in t (e-insertion: -t → -et)
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .perfektpartizip, expected: "gearbeitet")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektpartizip, expected: "studiert")

    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektpartizip, expected: "gesUngen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektpartizip, expected: "gegANGen")
    expectConjugation(infinitiv: "finden", conjugationgroup: .perfektpartizip, expected: "gefUnden")
    expectConjugation(infinitiv: "nehmen", conjugationgroup: .perfektpartizip, expected: "genOMMen")
    expectConjugation(infinitiv: "sitzen", conjugationgroup: .perfektpartizip, expected: "gesESSen")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektpartizip, expected: "gebrACHt")
    expectConjugation(infinitiv: "haben", conjugationgroup: .perfektpartizip, expected: "gehabt")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektpartizip, expected: "angekommen")

    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektpartizip, expected: "verstANDen")
  }

  @Test func präsenspartizip() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsenspartizip, expected: "machend")

    expectConjugation(infinitiv: "singen", conjugationgroup: .präsenspartizip, expected: "singend")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .präsenspartizip, expected: "gehend")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .präsenspartizip, expected: "studierend")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .präsenspartizip, expected: "bringend")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präsenspartizip, expected: "ankommend")

    expectConjugation(infinitiv: "verstehen", conjugationgroup: .präsenspartizip, expected: "verstehend")
  }

  @Test func präsensIndikativ() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "mache")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "machst")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "macht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "macht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "machen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "sehe")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "sIEhst")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "sIEht")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "sehen")

    expectConjugation(infinitiv: "lassen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "lÄSSt")
    expectConjugation(infinitiv: "lassen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "lÄSSt")

    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "BIN")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "BIst")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "IST")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "sIND")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "seiD")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "sIND")

    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "habe")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "hAst")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "hAt")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "studiere")
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "studiert")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "ankomme")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "ankommt")
  }

  @Test func präsensKonjunktivI() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.firstSingular), expected: "mache")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.secondSingular), expected: "machest")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.thirdSingular), expected: "mache")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.firstPlural), expected: "machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.secondPlural), expected: "machet")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präsensKonjunktivI(.thirdPlural), expected: "machen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensKonjunktivI(.firstSingular), expected: "sehe")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensKonjunktivI(.secondSingular), expected: "sehest")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präsensKonjunktivI(.thirdSingular), expected: "sehe")

    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.firstSingular), expected: "seI")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.secondSingular), expected: "seIst")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.thirdSingular), expected: "seI")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.firstPlural), expected: "seien")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.secondPlural), expected: "seiet")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.thirdPlural), expected: "seien")

    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensKonjunktivI(.firstSingular), expected: "habe")
    expectConjugation(infinitiv: "haben", conjugationgroup: .präsensKonjunktivI(.thirdSingular), expected: "habe")
  }

  @Test func präteritumIndikativ() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "machtest")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "machten")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "machtet")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "machten")

    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sAng")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "sAngst")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "sAng")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "sAngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "sAngt")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "sAngen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sAh")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "sAh")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gING")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "brACHte")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "brACHtest")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "brACHte")

    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "WAR")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "WARst")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "WAR")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "WARen")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "WARt")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "WARen")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "studierte")
    expectConjugation(infinitiv: "studieren", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "studierte")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "ankAm")
  }

  @Test func präteritumKonjunktivII() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "machtest")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "machte")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "machten")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "machtet")
    expectConjugation(infinitiv: "machen", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "machten")

    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sÄnge")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "sÄngest")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "sÄnge")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "sÄngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "sÄnget")
    expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "sÄngen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sÄhe")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gINGe")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "brÄCHte")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "brÄCHte")

    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "WÄRe")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "WÄRest")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "WÄRe")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "WÄRen")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "WÄRet")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "WÄRen")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "studierte")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "ankÄme")
  }

  @Test func perfektIndikativ() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.secondSingular), expected: "hAst gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.firstPlural), expected: "haben gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.secondPlural), expected: "habt gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektIndikativ(.thirdPlural), expected: "haben gemacht")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.secondSingular), expected: "BIst gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.firstPlural), expected: "sIND gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.secondPlural), expected: "seiD gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektIndikativ(.thirdPlural), expected: "sIND gegANGen")

    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gesUngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gesUngen")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gesehen")
    expectConjugation(infinitiv: "sehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gesehen")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gebrACHt")
    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gebrACHt")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe studiert")
    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt studiert")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN angekommen")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST angekommen")

    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe verstANDen")
    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt verstANDen")
  }

  @Test func perfektKonjunktivI() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.secondSingular), expected: "habest gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.thirdSingular), expected: "habe gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.firstPlural), expected: "haben gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.secondPlural), expected: "habet gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .perfektKonjunktivI(.thirdPlural), expected: "haben gemacht")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "seI gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.secondSingular), expected: "seIst gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.thirdSingular), expected: "seI gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.firstPlural), expected: "seien gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.secondPlural), expected: "seiet gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .perfektKonjunktivI(.thirdPlural), expected: "seien gegANGen")

    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe gesUngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .perfektKonjunktivI(.thirdSingular), expected: "habe gesUngen")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe gebrACHt")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe studiert")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "seI angekommen")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .perfektKonjunktivI(.thirdSingular), expected: "seI angekommen")

    expectConjugation(infinitiv: "verstehen", conjugationgroup: .perfektKonjunktivI(.firstSingular), expected: "habe verstANDen")
  }

  @Test func werden() {
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "werde")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wIrst")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wIrD")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "werden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "werdEt")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "werden")

    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wUrdE")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "wUrdEst")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "wUrdE")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "wUrden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "wUrdEt")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "wUrden")

    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜrde")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "wÜrdest")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "wÜrde")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "wÜrden")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "wÜrdet")
    expectConjugation(infinitiv: "werden", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "wÜrden")

    expectConjugation(infinitiv: "werden", conjugationgroup: .perfektpartizip, expected: "gewOrden")
  }

  @Test func imperativ() {

    expectConjugation(infinitiv: "machen", conjugationgroup: .imperativ(.secondSingular), expected: "mach")

    expectConjugation(infinitiv: "geben", conjugationgroup: .imperativ(.secondSingular), expected: "gIb")
    expectConjugation(infinitiv: "nehmen", conjugationgroup: .imperativ(.secondSingular), expected: "nIMM")

    expectConjugation(infinitiv: "sehen", conjugationgroup: .imperativ(.secondSingular), expected: "sIEh")

    // Strong verb with a→ä change - should NOT apply (use base stem)
    expectConjugation(infinitiv: "lassen", conjugationgroup: .imperativ(.secondSingular), expected: "lass")

    // Verb ending in -d needs -e for pronunciation
    expectConjugation(infinitiv: "werden", conjugationgroup: .imperativ(.secondSingular), expected: "werde")

    expectConjugation(infinitiv: "sein", conjugationgroup: .imperativ(.secondSingular), expected: "seI")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .imperativ(.secondSingular), expected: "komm an")

    expectConjugation(infinitiv: "machen", conjugationgroup: .imperativ(.secondPlural), expected: "macht")
    expectConjugation(infinitiv: "geben", conjugationgroup: .imperativ(.secondPlural), expected: "gebt")
    expectConjugation(infinitiv: "sein", conjugationgroup: .imperativ(.secondPlural), expected: "seiD")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .imperativ(.secondPlural), expected: "kommt an")

    expectConjugation(infinitiv: "machen", conjugationgroup: .imperativ(.firstPlural), expected: "machen wir")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .imperativ(.firstPlural), expected: "gehen wir")
    expectConjugation(infinitiv: "sein", conjugationgroup: .imperativ(.firstPlural), expected: "seien wir")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .imperativ(.firstPlural), expected: "kommen wir an")

    expectConjugation(infinitiv: "machen", conjugationgroup: .imperativ(.thirdPlural), expected: "machen Sie")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .imperativ(.thirdPlural), expected: "gehen Sie")
    expectConjugation(infinitiv: "sein", conjugationgroup: .imperativ(.thirdPlural), expected: "seien Sie")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .imperativ(.thirdPlural), expected: "kommen Sie an")
  }

  @Test func tun() {
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "tue")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "tust")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "tut")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "tun")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "tut")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "tun")

    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "tAT")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "tATest")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "tAT")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "tATen")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "tATet")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "tATen")

    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "tÄTe")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "tÄTest")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.thirdSingular), expected: "tÄTe")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "tÄTen")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "tÄTet")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumKonjunktivII(.thirdPlural), expected: "tÄTen")

    expectConjugation(infinitiv: "tun", conjugationgroup: .perfektpartizip, expected: "getAn")
  }

  @Test func newAblautGroups() {
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "fÄhrst")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "fÄhrt")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "fUhr")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fÜhre")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .perfektpartizip, expected: "gefahren")

    expectConjugation(infinitiv: "laufen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "lÄUfst")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "lÄUft")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "lIEf")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "lIEfe")
    expectConjugation(infinitiv: "laufen", conjugationgroup: .perfektpartizip, expected: "gelaufen")

    expectConjugation(infinitiv: "fallen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "fÄLLst")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "fÄLLt")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "fIEL")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fIELe")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .perfektpartizip, expected: "gefallen")

    expectConjugation(infinitiv: "treffen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "trIFFst")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "trIFFt")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trAF")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÄFe")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .perfektpartizip, expected: "getrOFFen")

    // Note: German spelling would convert ß→ss after short vowel, but conjugator preserves consonant
    expectConjugation(infinitiv: "schließen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schlOSS")
    expectConjugation(infinitiv: "schließen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schlÖSSe")
    expectConjugation(infinitiv: "schließen", conjugationgroup: .perfektpartizip, expected: "geschlOSSen")

    expectConjugation(infinitiv: "heißen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "hIEß")
    expectConjugation(infinitiv: "heißen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "hIEße")
    expectConjugation(infinitiv: "heißen", conjugationgroup: .perfektpartizip, expected: "geheißen")

    expectConjugation(infinitiv: "ziehen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "zOG")
    expectConjugation(infinitiv: "ziehen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "zÖGe")
    expectConjugation(infinitiv: "ziehen", conjugationgroup: .perfektpartizip, expected: "gezOGen")

    expectConjugation(infinitiv: "tragen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "trÄgst")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "trÄgt")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trUg")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÜge")
    expectConjugation(infinitiv: "tragen", conjugationgroup: .perfektpartizip, expected: "getragen")

    expectConjugation(infinitiv: "gewinnen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gewAnn")
    expectConjugation(infinitiv: "gewinnen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gewÄnne")
    expectConjugation(infinitiv: "gewinnen", conjugationgroup: .perfektpartizip, expected: "gewOnnen")

    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "empfIEhlst")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "empfIEhlt")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "empfAhl")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "empfÄhle")
    expectConjugation(infinitiv: "empfehlen", conjugationgroup: .perfektpartizip, expected: "empfOhlen")

    // Note: 3s ending -t merges with stamm ending -tt (German phonology)
    expectConjugation(infinitiv: "treten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "trITTst")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "trITT")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trAT")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÄTe")
    expectConjugation(infinitiv: "treten", conjugationgroup: .perfektpartizip, expected: "getrETen")

    expectConjugation(infinitiv: "verlieren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "verlOr")
    expectConjugation(infinitiv: "verlieren", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "verlÖre")
    expectConjugation(infinitiv: "verlieren", conjugationgroup: .perfektpartizip, expected: "verlOren")

    expectConjugation(infinitiv: "steigen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stIEg")
    expectConjugation(infinitiv: "steigen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stIEge")
    expectConjugation(infinitiv: "steigen", conjugationgroup: .perfektpartizip, expected: "gestIEgen")

    expectConjugation(infinitiv: "erscheinen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "erschIEn")
    expectConjugation(infinitiv: "erscheinen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "erschIEne")
    expectConjugation(infinitiv: "erscheinen", conjugationgroup: .perfektpartizip, expected: "erschIEnen")

    expectConjugation(infinitiv: "gelingen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gelAng")
    expectConjugation(infinitiv: "gelingen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gelÄnge")
    expectConjugation(infinitiv: "gelingen", conjugationgroup: .perfektpartizip, expected: "gelUngen")

    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "schlÄgst")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "schlÄgt")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schlUg")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schlÜge")
    expectConjugation(infinitiv: "schlagen", conjugationgroup: .perfektpartizip, expected: "geschlagen")

    expectConjugation(infinitiv: "laden", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "lÄdst")
    expectConjugation(infinitiv: "laden", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "lÄdt")
    expectConjugation(infinitiv: "laden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "lUd")
    expectConjugation(infinitiv: "laden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "lÜde")
    expectConjugation(infinitiv: "laden", conjugationgroup: .perfektpartizip, expected: "geladen")

    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wÄchst")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wÄchst")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wUchs")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜchse")
    expectConjugation(infinitiv: "wachsen", conjugationgroup: .perfektpartizip, expected: "gewachsen")

    expectConjugation(infinitiv: "rufen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "rIEf")
    expectConjugation(infinitiv: "rufen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rIEfe")
    expectConjugation(infinitiv: "rufen", conjugationgroup: .perfektpartizip, expected: "gerufen")

    expectConjugation(infinitiv: "weisen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wIEs")
    expectConjugation(infinitiv: "weisen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wIEse")
    expectConjugation(infinitiv: "weisen", conjugationgroup: .perfektpartizip, expected: "gewIEsen")

    // Note: genießen uses schließen pattern, ge- is inseparable prefix (no double ge-)
    // German spelling would convert ß→ss after short vowel, but conjugator preserves consonant
    expectConjugation(infinitiv: "genießen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "genOSS")
    expectConjugation(infinitiv: "genießen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "genÖSSe")
    expectConjugation(infinitiv: "genießen", conjugationgroup: .perfektpartizip, expected: "genOSSen")

    expectConjugation(infinitiv: "bitten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bAT")
    expectConjugation(infinitiv: "bitten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "bÄTe")
    expectConjugation(infinitiv: "bitten", conjugationgroup: .perfektpartizip, expected: "gebETen")

    // Note: German spelling ß/ss rules not automatically applied by conjugator
    // Perfektpartizip "gegessen" uses full override due to irregular form
    expectConjugation(infinitiv: "essen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "ISSt")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "ISSt")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "Aẞ")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "Äẞe")
    expectConjugation(infinitiv: "essen", conjugationgroup: .perfektpartizip, expected: "gegEssen")

    expectConjugation(infinitiv: "sterben", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "stIrbst")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "stIrbt")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stArb")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stÜrbe")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .perfektpartizip, expected: "gestOrben")

    // Note: German spelling ß/ss rules not automatically applied by conjugator
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "vergISSt")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "vergISSt")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "vergAẞ")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .perfektpartizip, expected: "vergessen")

    expectConjugation(infinitiv: "erfahren", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "erfÄhrt")
    expectConjugation(infinitiv: "erfahren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "erfUhr")
    expectConjugation(infinitiv: "erfahren", conjugationgroup: .perfektpartizip, expected: "erfahren")

    expectConjugation(infinitiv: "anbieten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "anbOt")
    expectConjugation(infinitiv: "anbieten", conjugationgroup: .perfektpartizip, expected: "angebOten")

    expectConjugation(infinitiv: "betragen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "betrÄgt")
    expectConjugation(infinitiv: "betragen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "betrUg")
    expectConjugation(infinitiv: "betragen", conjugationgroup: .perfektpartizip, expected: "betragen")

    expectConjugation(infinitiv: "stattfinden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stattfAnd")
    expectConjugation(infinitiv: "stattfinden", conjugationgroup: .perfektpartizip, expected: "stattgefUnden")
  }

  @Test func newVerbs() {
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "gIltst")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "gIlt")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gAlt")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "gAltest")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "gAltet")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gÖlte")
    expectConjugation(infinitiv: "gelten", conjugationgroup: .perfektpartizip, expected: "gegOlten")

    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "sprIchst")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "sprIcht")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sprAch")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sprÄche")
    expectConjugation(infinitiv: "sprechen", conjugationgroup: .perfektpartizip, expected: "gesprOchen")

    expectConjugation(infinitiv: "helfen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "hIlfst")
    expectConjugation(infinitiv: "helfen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "hAlf")
    expectConjugation(infinitiv: "helfen", conjugationgroup: .perfektpartizip, expected: "gehOlfen")

    expectConjugation(infinitiv: "lesen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "lIEst")
    expectConjugation(infinitiv: "lesen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "lIEst")
    expectConjugation(infinitiv: "lesen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "lAs")
    expectConjugation(infinitiv: "lesen", conjugationgroup: .perfektpartizip, expected: "gelesen")

    expectConjugation(infinitiv: "beginnen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "begAnn")
    expectConjugation(infinitiv: "beginnen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "begÄnne")
    expectConjugation(infinitiv: "beginnen", conjugationgroup: .perfektpartizip, expected: "begOnnen")

    expectConjugation(infinitiv: "denken", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "dACHte")
    expectConjugation(infinitiv: "denken", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "dÄCHte")
    expectConjugation(infinitiv: "denken", conjugationgroup: .perfektpartizip, expected: "gedACHt")

    expectConjugation(infinitiv: "kennen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "kAnnte")
    expectConjugation(infinitiv: "kennen", conjugationgroup: .perfektpartizip, expected: "gekAnnt")

    expectConjugation(infinitiv: "bestehen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bestAND")
    expectConjugation(infinitiv: "bestehen", conjugationgroup: .perfektpartizip, expected: "bestANDen")

    expectConjugation(infinitiv: "schreiben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schrIEb")
    expectConjugation(infinitiv: "schreiben", conjugationgroup: .perfektpartizip, expected: "geschrIEben")

    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "arbeitete")
    expectConjugation(infinitiv: "spielen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "spielte")
    expectConjugation(infinitiv: "suchen", conjugationgroup: .perfektpartizip, expected: "gesucht")
  }

  @Test func plusquamperfektIndikativ() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.secondSingular), expected: "hATtest gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.thirdSingular), expected: "hATte gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.firstPlural), expected: "hATten gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.secondPlural), expected: "hATtet gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektIndikativ(.thirdPlural), expected: "hATten gemacht")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "WAR gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.secondSingular), expected: "WARst gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.thirdSingular), expected: "WAR gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.firstPlural), expected: "WARen gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.secondPlural), expected: "WARt gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektIndikativ(.thirdPlural), expected: "WARen gegANGen")

    expectConjugation(infinitiv: "singen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte gesUngen")
    expectConjugation(infinitiv: "singen", conjugationgroup: .plusquamperfektIndikativ(.thirdSingular), expected: "hATte gesUngen")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte gebrACHt")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte studiert")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "WAR angekommen")
    expectConjugation(infinitiv: "ankommen", conjugationgroup: .plusquamperfektIndikativ(.thirdSingular), expected: "WAR angekommen")

    expectConjugation(infinitiv: "verstehen", conjugationgroup: .plusquamperfektIndikativ(.firstSingular), expected: "hATte verstANDen")
  }

  @Test func plusquamperfektKonjunktivII() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.secondSingular), expected: "hÄTtest gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.thirdSingular), expected: "hÄTte gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.firstPlural), expected: "hÄTten gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.secondPlural), expected: "hÄTtet gemacht")
    expectConjugation(infinitiv: "machen", conjugationgroup: .plusquamperfektKonjunktivII(.thirdPlural), expected: "hÄTten gemacht")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "WÄRe gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.secondSingular), expected: "WÄRest gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.thirdSingular), expected: "WÄRe gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.firstPlural), expected: "WÄRen gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.secondPlural), expected: "WÄRet gegANGen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .plusquamperfektKonjunktivII(.thirdPlural), expected: "WÄRen gegANGen")

    expectConjugation(infinitiv: "singen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte gesUngen")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte gebrACHt")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte studiert")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "WÄRe angekommen")

    expectConjugation(infinitiv: "verstehen", conjugationgroup: .plusquamperfektKonjunktivII(.firstSingular), expected: "hÄTte verstANDen")
  }

  @Test func futurIndikativ() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.secondSingular), expected: "wIrst machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.thirdSingular), expected: "wIrD machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.firstPlural), expected: "werden machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.secondPlural), expected: "werdEt machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurIndikativ(.thirdPlural), expected: "werden machen")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde gehen")
    expectConjugation(infinitiv: "gehen", conjugationgroup: .futurIndikativ(.thirdSingular), expected: "wIrD gehen")

    expectConjugation(infinitiv: "singen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde singen")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde bringen")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde studieren")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde ankommen")

    expectConjugation(infinitiv: "verstehen", conjugationgroup: .futurIndikativ(.firstSingular), expected: "werde verstehen")
  }

  @Test func futurKonjunktivI() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.secondSingular), expected: "werdest machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.thirdSingular), expected: "werde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.firstPlural), expected: "werden machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.secondPlural), expected: "werdet machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivI(.thirdPlural), expected: "werden machen")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde gehen")

    expectConjugation(infinitiv: "singen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde singen")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde bringen")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde studieren")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde ankommen")

    expectConjugation(infinitiv: "verstehen", conjugationgroup: .futurKonjunktivI(.firstSingular), expected: "werde verstehen")
  }

  @Test func futurKonjunktivII() {
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.secondSingular), expected: "wÜrdest machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.thirdSingular), expected: "wÜrde machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.firstPlural), expected: "wÜrden machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.secondPlural), expected: "wÜrdet machen")
    expectConjugation(infinitiv: "machen", conjugationgroup: .futurKonjunktivII(.thirdPlural), expected: "wÜrden machen")

    expectConjugation(infinitiv: "gehen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde gehen")

    expectConjugation(infinitiv: "singen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde singen")

    expectConjugation(infinitiv: "bringen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde bringen")

    expectConjugation(infinitiv: "studieren", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde studieren")

    expectConjugation(infinitiv: "ankommen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde ankommen")

    expectConjugation(infinitiv: "verstehen", conjugationgroup: .futurKonjunktivII(.firstSingular), expected: "wÜrde verstehen")
  }

  @Test func newAblautGroupsPhase2() {
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "fÄngst")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "fÄngt")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "fIng")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fInge")
    expectConjugation(infinitiv: "fangen", conjugationgroup: .perfektpartizip, expected: "gefangen")

    expectConjugation(infinitiv: "anfangen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "anfÄngt")
    expectConjugation(infinitiv: "anfangen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "anfIng")
    expectConjugation(infinitiv: "anfangen", conjugationgroup: .perfektpartizip, expected: "angefangen")

    expectConjugation(infinitiv: "fliegen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "flOg")
    expectConjugation(infinitiv: "fliegen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "flÖge")
    expectConjugation(infinitiv: "fliegen", conjugationgroup: .perfektpartizip, expected: "geflOgen")

    expectConjugation(infinitiv: "gebären", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "gebIERst")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "gebIERt")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gebAR")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gebÄRe")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .perfektpartizip, expected: "gebORen")

    expectConjugation(infinitiv: "greifen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "grIFF")
    expectConjugation(infinitiv: "greifen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "grIFFe")
    expectConjugation(infinitiv: "greifen", conjugationgroup: .perfektpartizip, expected: "gegrIFFen")

    expectConjugation(infinitiv: "heben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "hOb")
    expectConjugation(infinitiv: "heben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "hÖbe")
    expectConjugation(infinitiv: "heben", conjugationgroup: .perfektpartizip, expected: "gehOben")

    expectConjugation(infinitiv: "erheben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "erhOb")
    expectConjugation(infinitiv: "erheben", conjugationgroup: .perfektpartizip, expected: "erhOben")

    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "schlÄfst")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "schlÄft")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schlIEf")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schlIEfe")
    expectConjugation(infinitiv: "schlafen", conjugationgroup: .perfektpartizip, expected: "geschlafen")

    expectConjugation(infinitiv: "schneiden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schnITT")
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schnITTe")
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .perfektpartizip, expected: "geschnITTen")

    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "stÖßt")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "stÖßt")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stIEß")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stIEße")
    expectConjugation(infinitiv: "stoßen", conjugationgroup: .perfektpartizip, expected: "gestoßen")

    expectConjugation(infinitiv: "werfen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wIrfst")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wIrft")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wArf")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜrfe")
    expectConjugation(infinitiv: "werfen", conjugationgroup: .perfektpartizip, expected: "gewOrfen")

    expectConjugation(infinitiv: "verschwinden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "verschwAnd")
    expectConjugation(infinitiv: "verschwinden", conjugationgroup: .perfektpartizip, expected: "verschwUnden")

    expectConjugation(infinitiv: "trinken", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trAnk")
    expectConjugation(infinitiv: "trinken", conjugationgroup: .perfektpartizip, expected: "getrUnken")

    expectConjugation(infinitiv: "klingen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "klAng")
    expectConjugation(infinitiv: "klingen", conjugationgroup: .perfektpartizip, expected: "geklUngen")

    expectConjugation(infinitiv: "leiden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "lITT")
    expectConjugation(infinitiv: "leiden", conjugationgroup: .perfektpartizip, expected: "gelITTen")

    expectConjugation(infinitiv: "brechen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "brIcht")
    expectConjugation(infinitiv: "brechen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "brAch")
    expectConjugation(infinitiv: "brechen", conjugationgroup: .perfektpartizip, expected: "gebrOchen")

    expectConjugation(infinitiv: "messen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "mISSt")
    expectConjugation(infinitiv: "messen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "mAẞ")
    expectConjugation(infinitiv: "messen", conjugationgroup: .perfektpartizip, expected: "gemessen")
  }

  @Test func newAblautGroupsPhase3() {
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "rISS")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "rISSt")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rISSe")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .perfektpartizip, expected: "gerISSen")

    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "strICH")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "strICHst")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "strICHe")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .perfektpartizip, expected: "gestrICHen")

    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "überschrITT")
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "überschrITTe")
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .perfektpartizip, expected: "überschrITTen")

    expectConjugation(infinitiv: "zwingen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "zwAng")
    expectConjugation(infinitiv: "zwingen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "zwÄnge")
    expectConjugation(infinitiv: "zwingen", conjugationgroup: .perfektpartizip, expected: "gezwUngen")

    expectConjugation(infinitiv: "springen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sprAng")
    expectConjugation(infinitiv: "springen", conjugationgroup: .perfektpartizip, expected: "gesprUngen")
    expectConjugation(infinitiv: "springen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gesprUngen")

    expectConjugation(infinitiv: "sinken", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sAnk")
    expectConjugation(infinitiv: "sinken", conjugationgroup: .perfektpartizip, expected: "gesUnken")

    expectConjugation(infinitiv: "schieben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schOb")
    expectConjugation(infinitiv: "schieben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schÖbe")
    expectConjugation(infinitiv: "schieben", conjugationgroup: .perfektpartizip, expected: "geschOben")

    expectConjugation(infinitiv: "verschieben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "verschOb")
    expectConjugation(infinitiv: "verschieben", conjugationgroup: .perfektpartizip, expected: "verschOben")

    expectConjugation(infinitiv: "waschen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wÄschst")
    expectConjugation(infinitiv: "waschen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wUsch")
    expectConjugation(infinitiv: "waschen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜsche")
    expectConjugation(infinitiv: "waschen", conjugationgroup: .perfektpartizip, expected: "gewaschen")

    expectConjugation(infinitiv: "bewerben", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "bewIrbt")
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bewArb")
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "bewÜrbe")
    expectConjugation(infinitiv: "bewerben", conjugationgroup: .perfektpartizip, expected: "bewOrben")

    expectConjugation(infinitiv: "raten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "rÄtst")
    expectConjugation(infinitiv: "raten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "rÄt")
    expectConjugation(infinitiv: "raten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "rIEt")
    expectConjugation(infinitiv: "raten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rIEte")
    expectConjugation(infinitiv: "raten", conjugationgroup: .perfektpartizip, expected: "geraten")

    expectConjugation(infinitiv: "geraten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gerIEt")
    expectConjugation(infinitiv: "geraten", conjugationgroup: .perfektpartizip, expected: "geraten")
    expectConjugation(infinitiv: "geraten", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geraten")
  }

  @Test func schreienAblaut() {
    // schreien: contracted Perfektpartizip, contracted from *geschrieen
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "schreie")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "schreit")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schrIE")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "schrIE")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schrIEe")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .perfektpartizip, expected: "geschrIEn")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe geschrIEn")
  }

  @Test func schaffenAblaut() {
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "erschaffe")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "erschafft")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "erschUF")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "erschUF")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "erschÜFe")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .perfektpartizip, expected: "erschaffen")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe erschaffen")
  }

  @Test func modalVerbs() {
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "mAG")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "mAGst")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "mAG")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "mOCHte")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "mÖCHte")
    expectConjugation(infinitiv: "mögen", conjugationgroup: .perfektpartizip, expected: "gemOCHt")

    expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "wEIẞ")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wEIẞt")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wEIẞ")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wUSSte")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜSSte")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .perfektpartizip, expected: "gewUSSt")

    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "wIlL")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wIllst")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wIlL")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wollte")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .perfektpartizip, expected: "gewollt")
  }

  @Test func weakVerbsWithTStems() {
    // arbeiten: Präsens Indikativ 3s should get epenthetic "e" → "arbeitet" not "arbeitt"
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "arbeitet")
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "arbeitet")
    expectConjugation(infinitiv: "kosten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "kostet")
  }

  // Every expectation below is Wiktionary's, via the classify-and-verify pipeline in
  // docs/verb-classification.md, not the engine's own output.

  @Test func epentheticEInImperativ() {
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .imperativ(.secondPlural), expected: "arbeitet")
    expectConjugation(infinitiv: "arbeiten", conjugationgroup: .imperativ(.secondSingular), expected: "arbeite")
    expectConjugation(infinitiv: "halten", conjugationgroup: .imperativ(.secondPlural), expected: "haltet")
    expectConjugation(infinitiv: "atmen", conjugationgroup: .imperativ(.secondSingular), expected: "atme")
    expectConjugation(infinitiv: "atmen", conjugationgroup: .imperativ(.secondPlural), expected: "atmet")
    // A strong verb that changes its stem keeps the bare imperative.
    expectConjugation(infinitiv: "gelten", conjugationgroup: .imperativ(.secondSingular), expected: "gIlt")
    expectConjugation(infinitiv: "ändern", conjugationgroup: .imperativ(.secondPlural), expected: "ändert")
  }

  @Test func epentheticEInStrongAndMixedVerbs() {
    // An unablauted d/t stem takes the -e: du findest, er findet, ihr fandet.
    expectConjugation(infinitiv: "finden", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "findest")
    expectConjugation(infinitiv: "finden", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "findet")
    expectConjugation(infinitiv: "finden", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "fAndest")
    expectConjugation(infinitiv: "finden", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "fAndet")
    // An ablauted one keeps the endingless 3s: er hält, but ihr haltet.
    expectConjugation(infinitiv: "halten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "hÄltst")
    expectConjugation(infinitiv: "halten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "hÄlt")
    expectConjugation(infinitiv: "halten", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "haltet")
    expectConjugation(infinitiv: "halten", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "hIEltet")
    // Mixed: the Präsens takes the -e, the Präteritum and Partizip do not.
    expectConjugation(infinitiv: "senden", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "sendet")
  }

  @Test func epentheticEIsNotOverapplied() {
    // A doubled consonant closes the syllable on its own: stimmte, not stimmete.
    expectConjugation(infinitiv: "stimmen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stimmte")
    expectConjugation(infinitiv: "stimmen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "stimmt")
    // A Dehnungs-h lengthens the vowel rather than closing the syllable: ahnte, wohnte.
    expectConjugation(infinitiv: "ahnen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "ahnte")
    expectConjugation(infinitiv: "wohnen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wohnst")
    expectConjugation(infinitiv: "lehnen", conjugationgroup: .perfektpartizip, expected: "gelehnt")
    // The h of rechnen and zeichnen is half of ch, a real cluster, and does take one.
    expectConjugation(infinitiv: "rechnen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "rechnete")
    expectConjugation(infinitiv: "zeichnen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "zeichnest")
    expectConjugation(infinitiv: "öffnen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "öffnet")
  }

  @Test func epentheticEInPerfektpartizip() {
    expectConjugation(infinitiv: "atmen", conjugationgroup: .perfektpartizip, expected: "geatmet")
    expectConjugation(infinitiv: "rechnen", conjugationgroup: .perfektpartizip, expected: "gerechnet")
    expectConjugation(infinitiv: "trocknen", conjugationgroup: .perfektpartizip, expected: "getrocknet")
    expectConjugation(infinitiv: "ordnen", conjugationgroup: .perfektpartizip, expected: "geordnet")
    expectConjugation(infinitiv: "ahnen", conjugationgroup: .perfektpartizip, expected: "geahnt")
    expectConjugation(infinitiv: "stimmen", conjugationgroup: .perfektpartizip, expected: "gestimmt")
  }

  @Test func syllabicStammVerbs() {
    // An -ern or -eln stem already carries the e: wir ändern, not wir änderen.
    expectConjugation(infinitiv: "ändern", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "ändern")
    expectConjugation(infinitiv: "ändern", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "ändern")
    expectConjugation(infinitiv: "ändern", conjugationgroup: .präsensKonjunktivI(.firstPlural), expected: "ändern")
    expectConjugation(infinitiv: "ändern", conjugationgroup: .präsenspartizip, expected: "ändernd")
    expectConjugation(infinitiv: "wandern", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "wandern")
    // tun and sein end in -n without the syllable, so they keep -en.
    expectConjugation(infinitiv: "tun", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "tATen")
    expectConjugation(infinitiv: "tun", conjugationgroup: .präsenspartizip, expected: "tuend")
    expectConjugation(infinitiv: "sein", conjugationgroup: .präsensKonjunktivI(.firstPlural), expected: "seien")
  }

  @Test func conjugationErrorPaths() {
    // The three guards run in order: length, then ending validity, then recognition.
    expectFailure(infinitiv: "ab", expectedError: .verbTooShort)
    expectFailure(infinitiv: "xyzzy", expectedError: .infinitivEndingInvalid)
    expectFailure(infinitiv: "blorfen", expectedError: .verbNotRecognized)
  }

  private func expectConjugation(
    infinitiv: String,
    conjugationgroup: Conjugationgroup,
    expected: String,
    readingIndex: Int = 0,
    sourceLocation: SourceLocation = #_sourceLocation
  ) {
    let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup, readingIndex: readingIndex)
    switch result {
    case .success(let conjugation):
      #expect(conjugation == expected, "Expected \(infinitiv) reading \(readingIndex) → \(expected), got \(conjugation)", sourceLocation: sourceLocation)
    case .failure(let err):
      Issue.record("Failed to conjugate \(infinitiv) reading \(readingIndex): \(err)", sourceLocation: sourceLocation)
    }
  }

  // stehen, sitzen, and liegen take haben in the northern standard and sein in Austria and
  // Switzerland. Conjugator itself must stay region-free, because it is the oracle the
  // classify-and-verify pipeline compares against Wiktionary, so the regional reading comes
  // from RegionalConjugator and an explicitly passed region.
  // Conjugator takes no region and reads no setting, so there is nothing to vary: this pins
  // the northern-standard reading that the oracle and every other expectation depend on.
  @Test func conjugatorIsRegionFree() {
    expectConjugation(infinitiv: "stehen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gestANDen")
    expectConjugation(infinitiv: "sitzen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gesESSen")
    expectConjugation(infinitiv: "liegen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gelEgen")
  }

  @Test("Regional auxiliary follows the region", arguments: zip(
    [Region.north, .austria, .switzerland],
    ["habe gestANDen", "BIN gestANDen", "BIN gestANDen"]
  ))
  func regionalAuxiliary(region: Region, expected: String) {
    let result = RegionalConjugator.conjugate(
      infinitiv: "stehen",
      conjugationgroup: .perfektIndikativ(.firstSingular),
      region: region
    )
    #expect(try! result.get() == expected)
  }

  @Test("A verb without a regional auxiliary is untouched", arguments: [Region.north, .austria, .switzerland])
  func nonRegionalAuxiliaryIsStable(region: Region) {
    let result = RegionalConjugator.conjugate(
      infinitiv: "machen",
      conjugationgroup: .perfektIndikativ(.firstSingular),
      region: region
    )
    #expect(try! result.get() == "habe gemacht")
  }

  // A separable prefix sitting on an already-prefixed base. The ge- of the Perfektpartizip
  // goes immediately before the base stem and only when the prefix against that stem is
  // separable, so all of these suppress it. Before the grammar admitted a second marker
  // these were written with one, and Conjugator produced angegehört and aufgebewahrt.
  @Test func doublePrefixes() {
    expectConjugation(infinitiv: "angehören", conjugationgroup: .perfektpartizip, expected: "angehört")
    expectConjugation(infinitiv: "aufbewahren", conjugationgroup: .perfektpartizip, expected: "aufbewahrt")
    expectConjugation(infinitiv: "vorbereiten", conjugationgroup: .perfektpartizip, expected: "vorbereitet")
    expectConjugation(infinitiv: "zubereiten", conjugationgroup: .perfektpartizip, expected: "zubereitet")
    expectConjugation(infinitiv: "weiterentwickeln", conjugationgroup: .perfektpartizip, expected: "weiterentwickelt")

    // The ablaut region belongs to the base, not to the inner prefix: einbezog, not einbOGzieh.
    expectConjugation(infinitiv: "einbeziehen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "einbezOG")
    expectConjugation(infinitiv: "einbeziehen", conjugationgroup: .perfektpartizip, expected: "einbezOGen")

    // Only the outer separable prefix detaches; the inseparable one stays put.
    expectConjugation(infinitiv: "nachvollziehen", conjugationgroup: .imperativ(.secondPlural), expected: "vollzieht nach")
    expectConjugation(infinitiv: "nachvollziehen", conjugationgroup: .perfektpartizip, expected: "nachvollzOGen")
  }

  // hängen is the type case for readings that inflect differently: strong and intransitive
  // in the first, weak and transitive in the second. Wiktionary gives the strong preterite
  // as hing and tags hang nonstandard, so hing is what these pin.
  @Test func hängenReadings() {
    expectConjugation(infinitiv: "hängen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "hänge")
    expectConjugation(infinitiv: "hängen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "hIng")
    expectConjugation(infinitiv: "hängen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "hInge")
    expectConjugation(infinitiv: "hängen", conjugationgroup: .perfektpartizip, expected: "gehAngen")
    expectConjugation(infinitiv: "hängen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gehAngen")

    expectConjugation(infinitiv: "hängen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "hänge", readingIndex: 1)
    expectConjugation(infinitiv: "hängen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "hängte", readingIndex: 1)
    expectConjugation(infinitiv: "hängen", conjugationgroup: .perfektpartizip, expected: "gehängt", readingIndex: 1)
    expectConjugation(infinitiv: "hängen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gehängt", readingIndex: 1)
  }

  // Class 1: the readings share a paradigm and differ only in auxiliary and gloss.
  // Das Eis ist geschmolzen against ich habe das Eis geschmolzen, here on brechen.
  @Test func transitivityAlternationReadings() {
    expectConjugation(infinitiv: "brechen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gebrOchen")
    expectConjugation(infinitiv: "brechen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST gebrOchen", readingIndex: 1)

    expectConjugation(infinitiv: "fahren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gefahren")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST gefahren", readingIndex: 1)

    // The Präteritum is shared, so only the compound tenses may diverge.
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "fUhr")
    expectConjugation(infinitiv: "fahren", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "fUhr", readingIndex: 1)
  }

  // Class 2: schwimmen takes sein toward a destination and haben for the activity itself.
  @Test func motionReadings() {
    expectConjugation(infinitiv: "schwimmen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geschwOmmen")
    expectConjugation(infinitiv: "schwimmen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe geschwOmmen", readingIndex: 1)
  }

  // Class 5: the readings differ in the `in` attribute itself. über*setzen "translate" is
  // inseparable, so its participle takes no ge-; über+setzen "ferry across" is separable and
  // infixes one, and takes sein. Both spellings must still resolve on the plain infinitive.
  @Test func separabilityHomographReadings() {
    expectConjugation(infinitiv: "übersetzen", conjugationgroup: .perfektpartizip, expected: "übersetzt")
    expectConjugation(infinitiv: "übersetzen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "übersetzt")
    expectConjugation(infinitiv: "übersetzen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt übersetzt")

    expectConjugation(infinitiv: "übersetzen", conjugationgroup: .perfektpartizip, expected: "übergesetzt", readingIndex: 1)
    expectConjugation(infinitiv: "übersetzen", conjugationgroup: .imperativ(.secondPlural), expected: "setzt über", readingIndex: 1)
    expectConjugation(infinitiv: "übersetzen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST übergesetzt", readingIndex: 1)
  }

  // Class 4 again, and class 5 at once: weichen's "yield" reading is strong (wich, gewichen)
  // while "soak" is a separate weak verb (weichte, geweicht). The weak reading respells `in`
  // to drop the ablaut region, which a weak family may not carry.
  @Test func weichenReadings() {
    expectConjugation(infinitiv: "weichen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wICH")
    expectConjugation(infinitiv: "weichen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST gewICHen")

    expectConjugation(infinitiv: "weichen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "weichte", readingIndex: 1)
    expectConjugation(infinitiv: "weichen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt geweicht", readingIndex: 1)
  }

  // Four verbs whose shipped encoding was wrong in a way the classify-and-verify pipeline
  // reported as verified: when the shipped hypothesis failed, the classifier went on to find
  // a different *already-shipping* ablaut group that worked, and the at-odds count only
  // flagged verbs needing a group that does not ship. Every expectation here is Wiktionary's.
  @Test func encodingsTheOracleUsedToHide() {
    // Shipped weak, so the app produced "beschreibt" and "hat beschreibt".
    expectConjugation(infinitiv: "beschreiben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "beschrIEb")
    expectConjugation(infinitiv: "beschreiben", conjugationgroup: .perfektpartizip, expected: "beschrIEben")

    // Shipped the heißen group, which carries no participle ablaut: "gescheint".
    expectConjugation(infinitiv: "scheinen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schIEn")
    expectConjugation(infinitiv: "scheinen", conjugationgroup: .perfektpartizip, expected: "geschIEnen")

    // Ablaut region spanned "imm" with the singen group: "schwA" and "geschwUen".
    expectConjugation(infinitiv: "schwimmen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schwAmm")
    expectConjugation(infinitiv: "schwimmen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schwÄmme")
    expectConjugation(infinitiv: "schwimmen", conjugationgroup: .perfektpartizip, expected: "geschwOmmen")

    // bewegen is class 4: weak "move" beside strong "induce, prompt".
    expectConjugation(infinitiv: "bewegen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bewegte")
    expectConjugation(infinitiv: "bewegen", conjugationgroup: .perfektpartizip, expected: "bewegt")
    expectConjugation(infinitiv: "bewegen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bewOg", readingIndex: 1)
    expectConjugation(infinitiv: "bewegen", conjugationgroup: .perfektpartizip, expected: "bewOgen", readingIndex: 1)
  }

  // Every reading of a verb must resolve to the same dictionary key, so that Verb.verbs and
  // Conjugator keep looking verbs up by the plain infinitive.
  @Test func everyReadingResolvesToItsVerbsKey() {
    for (key, verb) in Verb.verbs {
      for reading in verb.readings {
        #expect(reading.infinitiv == key, "Reading of \(key) resolves to \(reading.infinitiv)")
      }
      #expect(!verb.readings.isEmpty, "\(key) has no readings")
    }
  }

  @Test func readingIndexOutOfRange() {
    expectFailure(infinitiv: "machen", expectedError: .readingNotRecognized, readingIndex: 1)
  }

  // The five ablaut groups added by the strong-bases tranche (docs/roadmap.md step 7).
  @Test func strongBasesTranche1NewAblautGroups() {
    // bersten is defective in the Präsens: du birst and er birst are the same word built
    // two different ways, so the group replaces the region differently in 2s and 3s.
    expectConjugation(infinitiv: "bersten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "bIRst")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "bIRSt")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bARST")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "bÄRSTe")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .perfektpartizip, expected: "gebORSTen")

    expectConjugation(infinitiv: "saufen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "sÄUFt")
    expectConjugation(infinitiv: "saufen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sOFF")
    expectConjugation(infinitiv: "saufen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sÖFFe")
    expectConjugation(infinitiv: "saufen", conjugationgroup: .perfektpartizip, expected: "gesOFFen")

    expectConjugation(infinitiv: "schinden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schUnd")
    expectConjugation(infinitiv: "schinden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schÜnde")
    expectConjugation(infinitiv: "schinden", conjugationgroup: .perfektpartizip, expected: "geschUnden")

    // sieden carries the d → tt inside its ablaut region, the same widening the ß/ss
    // alternation needed: a region stopping at the vowel cannot spell gesotten.
    expectConjugation(infinitiv: "sieden", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "siedet")
    expectConjugation(infinitiv: "sieden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sOTT")
    expectConjugation(infinitiv: "sieden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sÖTTe")
    expectConjugation(infinitiv: "sieden", conjugationgroup: .perfektpartizip, expected: "gesOTTen")

    // The schmelzen group serves five verbs; each is pinned so a later edit to the group
    // cannot fix one and break the others silently.
    expectConjugation(infinitiv: "schmelzen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "schmIlzt")
    expectConjugation(infinitiv: "schmelzen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schmOlz")
    expectConjugation(infinitiv: "schmelzen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schmÖlze")
    expectConjugation(infinitiv: "schmelzen", conjugationgroup: .perfektpartizip, expected: "geschmOlzen")
    expectConjugation(infinitiv: "dreschen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "drIscht")
    expectConjugation(infinitiv: "dreschen", conjugationgroup: .perfektpartizip, expected: "gedrOschen")
    expectConjugation(infinitiv: "fechten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "fIcht")
    expectConjugation(infinitiv: "fechten", conjugationgroup: .perfektpartizip, expected: "gefOchten")
    expectConjugation(infinitiv: "flechten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "flIcht")
    expectConjugation(infinitiv: "flechten", conjugationgroup: .perfektpartizip, expected: "geflOchten")
    expectConjugation(infinitiv: "melken", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "mIlkt")
    expectConjugation(infinitiv: "melken", conjugationgroup: .perfektpartizip, expected: "gemOlken")
    expectConjugation(infinitiv: "schwellen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "schwIllt")
    expectConjugation(infinitiv: "schwellen", conjugationgroup: .perfektpartizip, expected: "geschwOllen")
  }

  // The classifier's proposed region was always the shortest one that worked, which put a
  // doubled consonant across the region boundary (kn^ei^fen + IF). Widening the region to
  // the house convention lets each of these reuse a group that already shipped.
  @Test func strongBasesTranche1ReuseExistingGroups() {
    expectConjugation(infinitiv: "kneifen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "knIFF")
    expectConjugation(infinitiv: "kneifen", conjugationgroup: .perfektpartizip, expected: "geknIFFen")
    expectConjugation(infinitiv: "pfeifen", conjugationgroup: .perfektpartizip, expected: "gepfIFFen")
    expectConjugation(infinitiv: "gleiten", conjugationgroup: .perfektpartizip, expected: "geglITTen")
    expectConjugation(infinitiv: "schreiten", conjugationgroup: .perfektpartizip, expected: "geschrITTen")
    expectConjugation(infinitiv: "schleichen", conjugationgroup: .perfektpartizip, expected: "geschlICHen")
    expectConjugation(infinitiv: "beißen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bISS")
    expectConjugation(infinitiv: "beißen", conjugationgroup: .perfektpartizip, expected: "gebISSen")
    expectConjugation(infinitiv: "verdrießen", conjugationgroup: .perfektpartizip, expected: "verdrOSSen")

    // The heben group (o in the Präteritum and participle, ö in Konjunktiv II) turns out
    // to fit eleven of the missing bases, across four different ablaut regions.
    expectConjugation(infinitiv: "schwören", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schwOr")
    expectConjugation(infinitiv: "schwören", conjugationgroup: .perfektpartizip, expected: "geschwOren")
    expectConjugation(infinitiv: "weben", conjugationgroup: .perfektpartizip, expected: "gewOben")
    expectConjugation(infinitiv: "gären", conjugationgroup: .perfektpartizip, expected: "gegOren")
    expectConjugation(infinitiv: "glimmen", conjugationgroup: .perfektpartizip, expected: "geglOmmen")
    expectConjugation(infinitiv: "lügen", conjugationgroup: .perfektpartizip, expected: "gelOgen")

    // A ge- base needs the inseparable marker or the participle grows a second ge-.
    expectConjugation(infinitiv: "gedeihen", conjugationgroup: .perfektpartizip, expected: "gedIEhen")
    expectConjugation(infinitiv: "genesen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "genAs")
    expectConjugation(infinitiv: "genesen", conjugationgroup: .perfektpartizip, expected: "genesen")

    expectConjugation(infinitiv: "graben", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "grÄbt")
    expectConjugation(infinitiv: "graben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "grUb")
    expectConjugation(infinitiv: "blasen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "blÄst")
    expectConjugation(infinitiv: "blasen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "blIEs")
    expectConjugation(infinitiv: "braten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "brÄt")
    expectConjugation(infinitiv: "befehlen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "befIEhlt")
    expectConjugation(infinitiv: "befehlen", conjugationgroup: .perfektpartizip, expected: "befOhlen")
  }

  // The classify-and-verify pipeline never compares a compound tense, so a wrong `ay` is
  // invisible to it and cannot move the at-odds count. These are the only guard the
  // tranche's auxiliaries have.
  @Test func strongBasesTranche1Auxiliaries() {
    expectConjugation(infinitiv: "gedeihen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gedIEhen")
    expectConjugation(infinitiv: "gleiten", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geglITTen")
    expectConjugation(infinitiv: "schleichen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geschlICHen")
    expectConjugation(infinitiv: "schreiten", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geschrITTen")
    expectConjugation(infinitiv: "kriechen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gekrOchen")
    expectConjugation(infinitiv: "sprießen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gesprOSSen")
    expectConjugation(infinitiv: "rinnen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gerOnnen")
    expectConjugation(infinitiv: "schwinden", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geschwUnden")
    expectConjugation(infinitiv: "klimmen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geklOmmen")
    expectConjugation(infinitiv: "genesen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN genesen")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gebORSTen")
    expectConjugation(infinitiv: "schwellen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geschwOllen")
    expectConjugation(infinitiv: "zerschellen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN zerschellt")

    // haben, for contrast: schmelzen is dual-auxiliary and ships the transitive reading,
    // and graben and melken take haben outright.
    expectConjugation(infinitiv: "schmelzen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe geschmOlzen")
    expectConjugation(infinitiv: "graben", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gegraben")
    expectConjugation(infinitiv: "melken", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe gemOlken")
  }

  private func expectFailure(
    infinitiv: String,
    expectedError: ConjugatorError,
    readingIndex: Int = 0,
    sourceLocation: SourceLocation = #_sourceLocation
  ) {
    // The conjugationgroup is irrelevant: every guard runs before the group switch.
    let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: .perfektpartizip, readingIndex: readingIndex)
    switch result {
    case .success(let conjugation):
      Issue.record("Expected \(infinitiv) to fail with \(expectedError), got \(conjugation)", sourceLocation: sourceLocation)
    case .failure(let err):
      #expect(err == expectedError, "Expected \(infinitiv) to fail with \(expectedError), got \(err)", sourceLocation: sourceLocation)
    }
  }
}
