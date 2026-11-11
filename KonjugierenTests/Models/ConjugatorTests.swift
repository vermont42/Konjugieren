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
    expectConjugation(infinitiv: "nehmen", conjugationgroup: .perfektpartizip, expected: "genOmmen")
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

    expectConjugation(infinitiv: "lassen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "lÄsst")
    expectConjugation(infinitiv: "lassen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "lÄsst")

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
    expectConjugation(infinitiv: "nehmen", conjugationgroup: .imperativ(.secondSingular), expected: "nImm")

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

    expectConjugation(infinitiv: "fallen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "fÄllst")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "fÄllt")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "fIEl")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "fIEle")
    expectConjugation(infinitiv: "fallen", conjugationgroup: .perfektpartizip, expected: "gefallen")

    expectConjugation(infinitiv: "treffen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "trIffst")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "trIfft")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trAf")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÄfe")
    expectConjugation(infinitiv: "treffen", conjugationgroup: .perfektpartizip, expected: "getrOffen")

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
    expectConjugation(infinitiv: "treten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "trIttst")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "trItt")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "trAt")
    expectConjugation(infinitiv: "treten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "trÄte")
    expectConjugation(infinitiv: "treten", conjugationgroup: .perfektpartizip, expected: "getreten")

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

    expectConjugation(infinitiv: "bitten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bAt")
    expectConjugation(infinitiv: "bitten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "bÄte")
    expectConjugation(infinitiv: "bitten", conjugationgroup: .perfektpartizip, expected: "gebEten")

    // Note: German spelling ß/ss rules not automatically applied by conjugator
    // Perfektpartizip "gegessen" uses full override due to irregular form
    expectConjugation(infinitiv: "essen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "Isst")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "Isst")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "Aẞ")
    expectConjugation(infinitiv: "essen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "Äẞe")
    expectConjugation(infinitiv: "essen", conjugationgroup: .perfektpartizip, expected: "gegEssen")

    expectConjugation(infinitiv: "sterben", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "stIrbst")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "stIrbt")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "stArb")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "stÜrbe")
    expectConjugation(infinitiv: "sterben", conjugationgroup: .perfektpartizip, expected: "gestOrben")

    // Note: German spelling ß/ss rules not automatically applied by conjugator
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "vergIsst")
    expectConjugation(infinitiv: "vergessen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "vergIsst")
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

    expectConjugation(infinitiv: "gebären", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "gebIErst")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "gebIErt")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "gebAr")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "gebäre")
    expectConjugation(infinitiv: "gebären", conjugationgroup: .perfektpartizip, expected: "gebOren")

    expectConjugation(infinitiv: "greifen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "grIff")
    expectConjugation(infinitiv: "greifen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "grIffe")
    expectConjugation(infinitiv: "greifen", conjugationgroup: .perfektpartizip, expected: "gegrIffen")

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

    expectConjugation(infinitiv: "schneiden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "schnItt")
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schnItte")
    expectConjugation(infinitiv: "schneiden", conjugationgroup: .perfektpartizip, expected: "geschnItten")

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

    expectConjugation(infinitiv: "leiden", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "lItt")
    expectConjugation(infinitiv: "leiden", conjugationgroup: .perfektpartizip, expected: "gelItten")

    expectConjugation(infinitiv: "brechen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "brIcht")
    expectConjugation(infinitiv: "brechen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "brAch")
    expectConjugation(infinitiv: "brechen", conjugationgroup: .perfektpartizip, expected: "gebrOchen")

    expectConjugation(infinitiv: "messen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "mIsst")
    expectConjugation(infinitiv: "messen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "mAẞ")
    expectConjugation(infinitiv: "messen", conjugationgroup: .perfektpartizip, expected: "gemessen")
  }

  @Test func newAblautGroupsPhase3() {
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "rISS")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "rISSt")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "rISSe")
    expectConjugation(infinitiv: "reißen", conjugationgroup: .perfektpartizip, expected: "gerISSen")

    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "strIch")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "strIchst")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "strIche")
    expectConjugation(infinitiv: "streichen", conjugationgroup: .perfektpartizip, expected: "gestrIchen")

    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "überschrItt")
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "überschrItte")
    expectConjugation(infinitiv: "überschreiten", conjugationgroup: .perfektpartizip, expected: "überschrItten")

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
    // Changed 2026-07-20 from schrIEe. The stem already ends in -e and absorbs the ending's,
    // so the Konjunktiv II singular is identical to the Präteritum. Both Wiktionary editions
    // give this paradigm, de.wiktionary's Flexion page without alternatives or a "selten"
    // marking, and schriee does not occur once in the 17 MB corpus.
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "schrIE")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumKonjunktivII(.secondSingular), expected: "schrIEst")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumKonjunktivII(.secondPlural), expected: "schrIEt")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .perfektpartizip, expected: "geschrIEn")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe geschrIEn")

    // A stem ending in -e absorbs the e of an -en ending: wir schrien, not schrieen.
    // Both spellings were correct before the 1996 reform. Until 2026-07-20 Conjugator had
    // no such rule: the participle above was hand-written into the ablaut group as a full
    // override, which hid the defect there while leaving these plurals wrong.
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumIndikativ(.firstPlural), expected: "schrIEn")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumIndikativ(.thirdPlural), expected: "schrIEn")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumIndikativ(.secondPlural), expected: "schrIEt")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präteritumKonjunktivII(.firstPlural), expected: "schrIEn")

    // The negative case, and the reason the rule tests the stem rather than the infinitive:
    // schreien's Präsens stem is schrei, which takes the full ending. Keying off the
    // infinitive, as hasSyllabicStamm does for -ern/-eln, would wrongly give wir schrein.
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "schreien")
    expectConjugation(infinitiv: "schreien", conjugationgroup: .präsenspartizip, expected: "schreiend")
  }

  @Test func schaffenAblaut() {
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "erschaffe")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "erschafft")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "erschUf")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "erschUf")
    expectConjugation(infinitiv: "erschaffen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "erschÜfe")
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
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wUsste")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "wÜsste")
    expectConjugation(infinitiv: "wissen", conjugationgroup: .perfektpartizip, expected: "gewUsst")

    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "wIlL")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "wIllst")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "wIlL")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wollte")
    expectConjugation(infinitiv: "wollen", conjugationgroup: .perfektpartizip, expected: "gewollt")

    expectConjugation(infinitiv: "können", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "kAnn")
    expectConjugation(infinitiv: "können", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "kAnnst")
    expectConjugation(infinitiv: "können", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "kAnn")
    expectConjugation(infinitiv: "können", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "können")
    expectConjugation(infinitiv: "können", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "kOnnte")
    expectConjugation(infinitiv: "können", conjugationgroup: .perfektpartizip, expected: "gekOnnt")

    expectConjugation(infinitiv: "müssen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "mUsS")
    expectConjugation(infinitiv: "müssen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "mUssT")
    expectConjugation(infinitiv: "müssen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "mUsS")
    expectConjugation(infinitiv: "müssen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "mUsste")
    expectConjugation(infinitiv: "müssen", conjugationgroup: .perfektpartizip, expected: "gemUsst")

    expectConjugation(infinitiv: "dürfen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "darF")
    expectConjugation(infinitiv: "dürfen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "dArfst")
    expectConjugation(infinitiv: "dürfen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "darF")
    expectConjugation(infinitiv: "dürfen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "dUrfte")
    expectConjugation(infinitiv: "dürfen", conjugationgroup: .perfektpartizip, expected: "gedUrft")

    // sollen is the preterite-present whose stem vowel does not alternate, so its only
    // irregularity is the endingless 1s and 3s. Nothing is uppercased because no letter
    // differs from the stem: the irregularity is the absent ending, which this notation
    // cannot mark. Until 2026-07-29 this verb was fa="w" with no ablaut group and the app
    // emitted "solle" and "sollt".
    expectConjugation(infinitiv: "sollen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "soll")
    expectConjugation(infinitiv: "sollen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "sollst")
    expectConjugation(infinitiv: "sollen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "soll")
    expectConjugation(infinitiv: "sollen", conjugationgroup: .präsensIndikativ(.firstPlural), expected: "sollen")
    expectConjugation(infinitiv: "sollen", conjugationgroup: .präsensIndikativ(.secondPlural), expected: "sollt")
    expectConjugation(infinitiv: "sollen", conjugationgroup: .präsensIndikativ(.thirdPlural), expected: "sollen")
    expectConjugation(infinitiv: "sollen", conjugationgroup: .präsensKonjunktivI(.firstSingular), expected: "solle")
    expectConjugation(infinitiv: "sollen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sollte")
    // No umlaut in Konjunktiv II, unlike könnte, müsste, dürfte and möchte.
    expectConjugation(infinitiv: "sollen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sollte")
    expectConjugation(infinitiv: "sollen", conjugationgroup: .perfektpartizip, expected: "gesollt")
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

  // stehen, sitzen, and liegen take haben in the German standard and sein in the Austrian and
  // Swiss standards. Conjugator itself must stay region-free, because it is the oracle the
  // classify-and-verify pipeline compares against Wiktionary, so the regional reading comes
  // from RegionalConjugator and an explicitly passed region.
  // Conjugator takes no region and reads no setting, so there is nothing to vary: this pins
  // the German-standard reading that the oracle and every other expectation depend on.
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

  // anhängen shipped "attach, append" on the strong reading, so a learner read "ich habe die
  // Datei angehangen". DWDS has two verbs: 2anhängen (hängte an, angehängt) is "attach" and
  // 1anhängen (hing an, angehangen) is "be devoted to". The weak sense is the common one.
  @Test func anhängenReadings() {
    expectConjugation(infinitiv: "anhängen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "anhängte")
    expectConjugation(infinitiv: "anhängen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt angehängt")

    expectConjugation(infinitiv: "anhängen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "anhIng", readingIndex: 1)
    expectConjugation(infinitiv: "anhängen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt angehAngen", readingIndex: 1)
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

    // Part 6 of the defect plan, from DWDS: über*fahren "run over" (hat überfahren) beside
    // über+fahren "cross by boat" (ist übergefahren), and um*fahren "drive around" (hat
    // umfahren) beside um+fahren "knock over" (hat umgefahren), which keeps haben.
    expectConjugation(infinitiv: "überfahren", conjugationgroup: .perfektpartizip, expected: "überfahren")
    expectConjugation(infinitiv: "überfahren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt überfahren")
    expectConjugation(infinitiv: "überfahren", conjugationgroup: .perfektpartizip, expected: "übergefahren", readingIndex: 1)
    expectConjugation(infinitiv: "überfahren", conjugationgroup: .imperativ(.secondPlural), expected: "fahrt über", readingIndex: 1)
    expectConjugation(infinitiv: "überfahren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST übergefahren", readingIndex: 1)

    expectConjugation(infinitiv: "umfahren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt umfahren")
    expectConjugation(infinitiv: "umfahren", conjugationgroup: .imperativ(.secondPlural), expected: "fahrt um", readingIndex: 1)
    expectConjugation(infinitiv: "umfahren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt umgefahren", readingIndex: 1)

    // The first verb with three readings, from DWDS and German Wiktionary: separable
    // durch+ziehen with haben (thread through) and with sein (pass through), and inseparable
    // durch*ziehen (pervade), whose participle is durchzogen.
    expectConjugation(infinitiv: "durchziehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt durchgezOGen")
    expectConjugation(infinitiv: "durchziehen", conjugationgroup: .imperativ(.secondPlural), expected: "zieht durch")
    expectConjugation(infinitiv: "durchziehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST durchgezOGen", readingIndex: 1)
    expectConjugation(infinitiv: "durchziehen", conjugationgroup: .perfektpartizip, expected: "durchzOGen", readingIndex: 2)
    expectConjugation(infinitiv: "durchziehen", conjugationgroup: .imperativ(.secondPlural), expected: "durchzieht", readingIndex: 2)
    expectConjugation(infinitiv: "durchziehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt durchzOGen", readingIndex: 2)

    // From DWDS: über+treten "convert to" (ist übergetreten) beside über*treten "violate"
    // (übertritt, übertrat, hat übertreten).
    expectConjugation(infinitiv: "übertreten", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST übergetreten")
    expectConjugation(infinitiv: "übertreten", conjugationgroup: .imperativ(.secondPlural), expected: "tretet über")
    expectConjugation(infinitiv: "übertreten", conjugationgroup: .perfektpartizip, expected: "übertreten", readingIndex: 1)
    expectConjugation(infinitiv: "übertreten", conjugationgroup: .imperativ(.secondPlural), expected: "übertretet", readingIndex: 1)
    expectConjugation(infinitiv: "übertreten", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt übertreten", readingIndex: 1)

    // durchziehen's shape again. Separable durch+brechen with sein and haben (DWDS 1durchbrechen:
    // ist/hat durchgebrochen) beside inseparable durch*brechen. DWDS's header for the inseparable
    // entry misprints its participle as durchgebrochen; its own Perfekt examples ("hat die
    // Schallmauer durchbrochen") and German Wiktionary give durchbrochen.
    expectConjugation(infinitiv: "durchbrechen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST durchgebrOchen")
    expectConjugation(infinitiv: "durchbrechen", conjugationgroup: .imperativ(.secondPlural), expected: "brecht durch")
    expectConjugation(infinitiv: "durchbrechen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt durchgebrOchen", readingIndex: 1)
    expectConjugation(infinitiv: "durchbrechen", conjugationgroup: .perfektpartizip, expected: "durchbrOchen", readingIndex: 2)
    expectConjugation(infinitiv: "durchbrechen", conjugationgroup: .imperativ(.secondPlural), expected: "durchbrecht", readingIndex: 2)
    expectConjugation(infinitiv: "durchbrechen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt durchbrOchen", readingIndex: 2)

    // The same shape with the inseparable verb first, because "eine Ausbildung durchlaufen" is the
    // commonest sense (DWDS II: hat durchlaufen). The separable readings carry their own in.
    expectConjugation(infinitiv: "durchlaufen", conjugationgroup: .perfektpartizip, expected: "durchlaufen")
    expectConjugation(infinitiv: "durchlaufen", conjugationgroup: .imperativ(.secondPlural), expected: "durchlauft")
    expectConjugation(infinitiv: "durchlaufen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt durchlaufen")
    expectConjugation(infinitiv: "durchlaufen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST durchgelaufen", readingIndex: 1)
    expectConjugation(infinitiv: "durchlaufen", conjugationgroup: .imperativ(.secondPlural), expected: "lauft durch", readingIndex: 1)
    expectConjugation(infinitiv: "durchlaufen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt durchgelaufen", readingIndex: 2)

    // umlaufen: separable with sein (DWDS I 5, kursieren) and haben (I 1, umrennen) beside
    // inseparable um*laufen (DWDS II: hat umlaufen).
    expectConjugation(infinitiv: "umlaufen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST umgelaufen")
    expectConjugation(infinitiv: "umlaufen", conjugationgroup: .perfektpartizip, expected: "umlaufen", readingIndex: 1)
    expectConjugation(infinitiv: "umlaufen", conjugationgroup: .imperativ(.secondPlural), expected: "umlauft", readingIndex: 1)
    expectConjugation(infinitiv: "umlaufen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt umlaufen", readingIndex: 1)
    expectConjugation(infinitiv: "umlaufen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt umgelaufen", readingIndex: 2)

    // durchschlagen: separable with haben (DWDS 1durchschlagen 2, sich durchschlagen) and sein (3,
    // durchdringen) beside inseparable durch*schlagen (2durchschlagen: hat durchschlagen).
    expectConjugation(infinitiv: "durchschlagen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt durchgeschlagen")
    expectConjugation(infinitiv: "durchschlagen", conjugationgroup: .imperativ(.secondPlural), expected: "schlagt durch")
    expectConjugation(infinitiv: "durchschlagen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST durchgeschlagen", readingIndex: 1)
    expectConjugation(infinitiv: "durchschlagen", conjugationgroup: .perfektpartizip, expected: "durchschlagen", readingIndex: 2)
    expectConjugation(infinitiv: "durchschlagen", conjugationgroup: .imperativ(.secondPlural), expected: "durchschlagt", readingIndex: 2)
    expectConjugation(infinitiv: "durchschlagen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt durchschlagen", readingIndex: 2)

    // überschlagen: inseparable first (DWDS 1überschlagen II: hat überschlagen), then separable
    // über+schlagen with sein (I.2, der Funke ist übergeschlagen) and haben (I.1, die Beine).
    expectConjugation(infinitiv: "überschlagen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt überschlagen")
    expectConjugation(infinitiv: "überschlagen", conjugationgroup: .perfektpartizip, expected: "übergeschlagen", readingIndex: 1)
    expectConjugation(infinitiv: "überschlagen", conjugationgroup: .imperativ(.secondPlural), expected: "schlagt über", readingIndex: 1)
    expectConjugation(infinitiv: "überschlagen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST übergeschlagen", readingIndex: 1)
    expectConjugation(infinitiv: "überschlagen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt übergeschlagen", readingIndex: 2)

    // überspringen: inseparable with haben (DWDS II, hat übersprungen) beside separable
    // über+springen with sein (I, der Funke ist übergesprungen).
    expectConjugation(infinitiv: "überspringen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt übersprUngen")
    expectConjugation(infinitiv: "überspringen", conjugationgroup: .perfektpartizip, expected: "übergesprUngen", readingIndex: 1)
    expectConjugation(infinitiv: "überspringen", conjugationgroup: .imperativ(.secondPlural), expected: "springt über", readingIndex: 1)
    expectConjugation(infinitiv: "überspringen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST übergesprUngen", readingIndex: 1)

    // übergehen (plan step 6): inseparable with haben (DWDS II, hat übergangen) beside separable
    // über+gehen with sein (I, ist übergegangen). kaikki gives sein to both, which is why the
    // audit never listed it.
    expectConjugation(infinitiv: "übergehen", conjugationgroup: .perfektpartizip, expected: "übergANGen")
    expectConjugation(infinitiv: "übergehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt übergANGen")
    expectConjugation(infinitiv: "übergehen", conjugationgroup: .perfektpartizip, expected: "übergegANGen", readingIndex: 1)
    expectConjugation(infinitiv: "übergehen", conjugationgroup: .imperativ(.secondPlural), expected: "geht über", readingIndex: 1)
    expectConjugation(infinitiv: "übergehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST übergegANGen", readingIndex: 1)

    // durchdringen, durchlaufen's arrangement: inseparable first (DWDS 2durchdringen, hat
    // durchdrungen), then separable durch+dringen with sein (1durchdringen, ist durchgedrungen).
    expectConjugation(infinitiv: "durchdringen", conjugationgroup: .perfektpartizip, expected: "durchdrUngen")
    expectConjugation(infinitiv: "durchdringen", conjugationgroup: .imperativ(.secondPlural), expected: "durchdringt")
    expectConjugation(infinitiv: "durchdringen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt durchdrUngen")
    expectConjugation(infinitiv: "durchdringen", conjugationgroup: .imperativ(.secondPlural), expected: "dringt durch", readingIndex: 1)
    expectConjugation(infinitiv: "durchdringen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST durchgedrUngen", readingIndex: 1)
  }

  // Class 4 again, and class 5 at once: weichen's "yield" reading is strong (wich, gewichen)
  // while "soak" is a separate weak verb (weichte, geweicht). The weak reading respells `in`
  // to drop the ablaut region, which a weak family may not carry.
  @Test func weichenReadings() {
    expectConjugation(infinitiv: "weichen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "wIch")
    expectConjugation(infinitiv: "weichen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST gewIchen")

    expectConjugation(infinitiv: "weichen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "weichte", readingIndex: 1)
    expectConjugation(infinitiv: "weichen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt geweicht", readingIndex: 1)
  }

  // Defect plan, Part 2. A full override (a trailing * in AblautGroups.xml) spells out the
  // base verb's conjugation, and until 2026-11-10 the derivative's prefix was never put back:
  // bedürfen showed ich darf. Expectations are German Wiktionary's; kaikki's weak table for
  // entgelten is a known English-Wiktionary defect (verbdata/wiktionary-defects.json).
  @Test func overridesKeepTheirPrefix() {
    let bedürfen = ["bedarF", "bedArfst", "bedarF", "bedürfen", "bedürft", "bedürfen"]
    let vermögen = ["vermAG", "vermAGst", "vermAG", "vermögen", "vermögt", "vermögen"]
    let entgelten = ["entgAlt", "entgAltest", "entgAlt", "entgAlten", "entgAltet", "entgAlten"]
    for (personNumber, index) in zip(PersonNumber.allCases, 0...) {
      expectConjugation(infinitiv: "bedürfen", conjugationgroup: .präsensIndikativ(personNumber), expected: bedürfen[index])
      expectConjugation(infinitiv: "vermögen", conjugationgroup: .präsensIndikativ(personNumber), expected: vermögen[index])
      expectConjugation(infinitiv: "entgelten", conjugationgroup: .präteritumIndikativ(personNumber), expected: entgelten[index])
    }
    expectConjugation(infinitiv: "bedürfen", conjugationgroup: .perfektpartizip, expected: "bedUrft")
    expectConjugation(infinitiv: "vermögen", conjugationgroup: .perfektpartizip, expected: "vermOCHt")
    expectConjugation(infinitiv: "entgelten", conjugationgroup: .perfektpartizip, expected: "entgOlten")
  }

  // No shipping verb puts an override behind a separable prefix or a participle override
  // behind an inseparable one, so these three real verbs are inserted for the length of this
  // synchronous test. A @MainActor body that does not suspend cannot interleave with another
  // test, so Verb.verbs is restored before anything else reads it.
  @Test func overridesBehindEachKindOfPrefix() {
    let synthetic = [
      Self.syntheticVerb("dasein", group: "sein", prefixes: [.separable("da")], ablautRange: 2..<5),
      Self.syntheticVerb("vertun", group: "tun", prefixes: [.inseparable("ver")], ablautRange: 4..<5),
      Self.syntheticVerb("aufessen", group: "essen", prefixes: [.separable("auf")], ablautRange: 3..<6),
    ]
    for verb in synthetic {
      Verb.verbs[verb.infinitiv] = verb
    }
    defer {
      for verb in synthetic {
        Verb.verbs[verb.infinitiv] = nil
      }
    }

    // The Imperativ path detaches the separable run by dropping its length from the front of
    // the form, which only works now that an override's form begins with that run.
    expectConjugation(infinitiv: "dasein", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "daBIN")
    expectConjugation(infinitiv: "dasein", conjugationgroup: .imperativ(.secondSingular), expected: "seI da")
    expectConjugation(infinitiv: "dasein", conjugationgroup: .imperativ(.secondPlural), expected: "seiD da")

    // The participle override carries its own ge-: kept after a separable prefix, removed
    // after an inseparable one.
    expectConjugation(infinitiv: "aufessen", conjugationgroup: .perfektpartizip, expected: "aufgegEssen")
    expectConjugation(infinitiv: "vertun", conjugationgroup: .perfektpartizip, expected: "vertAn")
    expectConjugation(infinitiv: "vertun", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "vertATest")
  }

  private static func syntheticVerb(_ infinitiv: String, group: String, prefixes: [Prefix], ablautRange: Range<Int>) -> Verb {
    let reading = Reading(
      infinitiv: infinitiv,
      translation: "",
      family: .strong(ablautGroup: group, ablautStartIndex: ablautRange.lowerBound, ablautEndIndex: ablautRange.upperBound),
      auxiliary: .haben,
      prefixes: prefixes,
      auxiliaryIsRegional: false
    )
    return Verb(infinitiv: infinitiv, hits: 0, hitsAreProvisional: false, frequency: 0, frequencyIcon: "", readings: [reading])
  }

  // Defect plan, Part 1. The tranche-2 importer took a verb's auxiliary from kaikki's
  // first-listed one and its gloss from a separate sense, so aufstehen shipped "get up" with
  // haben. Every expectation here comes from DWDS or German Wiktionary, never from the engine;
  // verbdata/auxiliary-rulings.tsv records the source for each.
  @Test func auxiliariesRuledAgainstTheDictionary() {
    expectConjugation(infinitiv: "stattfinden", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt stattgefUnden")
    expectConjugation(infinitiv: "reisen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST gereist")
    expectConjugation(infinitiv: "entgehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST entgANGen")
    expectConjugation(infinitiv: "nachgehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST nachgegANGen")
    expectConjugation(infinitiv: "aufstehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST aufgestANDen")
    expectConjugation(infinitiv: "abfahren", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST abgefahren")
    expectConjugation(infinitiv: "zurücktreten", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST zurückgetreten")

    expectConjugation(infinitiv: "umziehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST umgezOGen")
    expectConjugation(infinitiv: "umziehen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt umgezOGen", readingIndex: 1)

    expectConjugation(infinitiv: "schmelzen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST geschmOlzen")
    expectConjugation(infinitiv: "schmelzen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt geschmOlzen", readingIndex: 1)
  }

  // One row per reading in verbdata/auxiliary-rulings.tsv. This pins the rulings without a
  // hand-written mixed-case string for each, and Part 6 of the defect plan extends it.
  nonisolated private static let auxiliaryRulings: [(String, Int, Auxiliary)] = [
    ("stattfinden", 0, .haben),
    ("angehen", 0, .haben),
    ("angehen", 1, .sein),
    ("reisen", 0, .sein),
    ("entgehen", 0, .sein),
    ("nachgehen", 0, .sein),
    ("umziehen", 0, .sein),
    ("umziehen", 1, .haben),
    ("aufstehen", 0, .sein),
    ("schmelzen", 0, .sein),
    ("schmelzen", 1, .haben),
    ("ausziehen", 0, .sein),
    ("ausziehen", 1, .haben),
    ("anfahren", 0, .sein),
    ("anfahren", 1, .haben),
    ("abbiegen", 0, .sein),
    ("abfahren", 0, .sein),
    ("zerreißen", 0, .haben),
    ("zerreißen", 1, .sein),
    ("verstreichen", 0, .sein),
    ("verstreichen", 1, .haben),
    ("ausrücken", 0, .sein),
    ("umkehren", 0, .sein),
    ("umkehren", 1, .haben),
    ("einbiegen", 0, .sein),
    ("anbrechen", 0, .sein),
    ("wegfahren", 0, .sein),
    ("wegfahren", 1, .haben),
    ("anspringen", 0, .sein),
    ("herziehen", 0, .sein),
    ("herziehen", 1, .haben),
    ("durchdrehen", 0, .sein),
    ("zerschellen", 0, .sein),
    ("herumfahren", 0, .sein),
    ("abfliegen", 0, .sein),
    ("ausbrennen", 0, .sein),
    ("triefen", 0, .haben),
    ("triefen", 1, .sein),
    ("stieben", 0, .sein),
    ("ausreiten", 0, .sein),
    ("abstreichen", 0, .haben),
    ("durchklingen", 0, .haben),
    ("wegtreten", 0, .sein),
    ("ausschleichen", 0, .haben),
    ("durchkriechen", 0, .sein),
    ("zureiten", 0, .haben),
    ("zureiten", 1, .sein),
    ("aufrauchen", 0, .haben),
    ("verstinken", 0, .haben),
    ("zurücktreten", 0, .sein),
    ("abhauen", 0, .sein),
    ("anhängen", 0, .haben),
    ("anhängen", 1, .haben),
    ("einfahren", 0, .sein),
    ("einfahren", 1, .haben),
    ("rückwärtsfahren", 0, .sein),
    ("mitfahren", 0, .sein),
    ("überfahren", 0, .haben),
    ("überfahren", 1, .sein),
    ("weiterfahren", 0, .sein),
    ("hochfahren", 0, .haben),
    ("hochfahren", 1, .sein),
    ("herunterfahren", 0, .sein),
    ("herunterfahren", 1, .haben),
    ("hinfahren", 0, .sein),
    ("hinfahren", 1, .haben),
    ("ausfahren", 0, .sein),
    ("ausfahren", 1, .haben),
    ("fortfahren", 0, .haben),
    ("fortfahren", 1, .sein),
    ("vorfahren", 0, .sein),
    ("vorfahren", 1, .haben),
    ("festfahren", 0, .haben),
    ("entlangfahren", 0, .sein),
    ("herauffahren", 0, .sein),
    ("drauflosfahren", 0, .sein),
    ("umfahren", 0, .haben),
    ("umfahren", 1, .haben),
    ("durchziehen", 0, .haben),
    ("durchziehen", 1, .sein),
    ("durchziehen", 2, .haben),
    ("vorziehen", 0, .haben),
    ("aufziehen", 0, .haben),
    ("aufziehen", 1, .sein),
    ("hinziehen", 0, .sein),
    ("hinziehen", 1, .haben),
    ("verziehen", 0, .haben),
    ("mitziehen", 0, .haben),
    ("mitziehen", 1, .sein),
    ("wegziehen", 0, .haben),
    ("wegziehen", 1, .sein),
    ("zusammenziehen", 0, .haben),
    ("zusammenziehen", 1, .sein),
    ("hineinziehen", 0, .haben),
    ("weiterziehen", 0, .sein),
    ("herunterziehen", 0, .haben),
    ("fortziehen", 0, .haben),
    ("fortziehen", 1, .sein),
    ("hinunterziehen", 0, .haben),
    ("blankziehen", 0, .haben),
    ("zuziehen", 0, .haben),
    ("zuziehen", 1, .sein),
    ("abtreten", 0, .sein),
    ("abtreten", 1, .haben),
    ("übertreten", 0, .sein),
    ("übertreten", 1, .haben),
    ("heraustreten", 0, .sein),
    ("kürzertreten", 0, .haben),
    ("zutreten", 0, .haben),
    ("zutreten", 1, .sein),
    ("aufbrechen", 0, .sein),
    ("aufbrechen", 1, .haben),
    ("zerbrechen", 0, .haben),
    ("zerbrechen", 1, .sein),
    ("durchbrechen", 0, .sein),
    ("durchbrechen", 1, .haben),
    ("durchbrechen", 2, .haben),
    ("wegbrechen", 0, .sein),
    ("erbrechen", 0, .haben),
    ("auseinanderbrechen", 0, .sein),
    ("herunterbrechen", 0, .sein),
    ("herunterbrechen", 1, .haben),
    ("herausbrechen", 0, .sein),
    ("herausbrechen", 1, .haben),
    ("losbrechen", 0, .sein),
    ("umbrechen", 0, .haben),
    ("niederbrechen", 0, .haben),
    ("entzweibrechen", 0, .sein),
    ("abtreiben", 0, .haben),
    ("abtreiben", 1, .sein),
    ("antreiben", 0, .haben),
    ("auftreiben", 0, .haben),
    ("austreiben", 0, .haben),
    ("eintreiben", 0, .haben),
    ("umtreiben", 0, .haben),
    ("wegtreiben", 0, .haben),
    ("wegtreiben", 1, .sein),
    ("zertreiben", 0, .haben),
    ("zutreiben", 0, .haben),
    ("zutreiben", 1, .sein),
    ("ablaufen", 0, .sein),
    ("ablaufen", 1, .haben),
    ("auflaufen", 0, .sein),
    ("belaufen", 0, .haben),
    ("durchlaufen", 0, .haben),
    ("durchlaufen", 1, .sein),
    ("durchlaufen", 2, .haben),
    ("einlaufen", 0, .sein),
    ("einlaufen", 1, .haben),
    ("umlaufen", 0, .sein),
    ("umlaufen", 1, .haben),
    ("umlaufen", 2, .haben),
    ("unterlaufen", 0, .haben),
    ("unterlaufen", 1, .sein),
    ("zulaufen", 0, .sein),
    ("verschießen", 0, .haben),
    ("einschießen", 0, .haben),
    ("einschießen", 1, .sein),
    ("niederschießen", 0, .haben),
    ("vorschießen", 0, .haben),
    ("aufschießen", 0, .haben),
    ("überschießen", 0, .haben),
    ("losschießen", 0, .haben),
    ("streben", 0, .haben),
    ("anstreben", 0, .haben),
    ("zustreben", 0, .sein),
    ("entgegenstreben", 0, .haben),
    ("auseinanderstreben", 0, .haben),
    ("emporstreben", 0, .sein),
    ("zusammenstreben", 0, .haben),
    ("anbrennen", 0, .sein),
    ("entbrennen", 0, .sein),
    ("abbrennen", 0, .haben),
    ("abbrennen", 1, .sein),
    ("durchbrennen", 0, .sein),
    ("einbrennen", 0, .haben),
    ("durchschlagen", 0, .haben),
    ("durchschlagen", 1, .sein),
    ("durchschlagen", 2, .haben),
    ("ausschlagen", 0, .haben),
    ("ausschlagen", 1, .sein),
    ("überschlagen", 0, .haben),
    ("überschlagen", 1, .sein),
    ("überschlagen", 2, .haben),
    ("zusammenschlagen", 0, .haben),
    ("wachsen", 0, .sein),
    ("durchwachsen", 0, .sein),
    ("verwachsen", 0, .sein),
    ("auswachsen", 0, .haben),
    ("anstehen", 0, .haben),
    ("feststehen", 0, .haben),
    ("zustehen", 0, .haben),
    ("dastehen", 0, .haben),
    ("gegenüberstehen", 0, .haben),
    ("entgegenstehen", 0, .haben),
    ("unterstehen", 0, .haben),
    ("ausstehen", 0, .haben),
    ("nachstehen", 0, .haben),
    ("beistehen", 0, .haben),
    ("stillstehen", 0, .haben),
    ("offenstehen", 0, .haben),
    ("nahestehen", 0, .haben),
    ("fortbestehen", 0, .haben),
    ("herumstehen", 0, .haben),
    ("draufstehen", 0, .haben),
    ("rumstehen", 0, .haben),
    ("zurückstehen", 0, .haben),
    ("abstehen", 0, .haben),
    ("geradestehen", 0, .haben),
    ("dabeistehen", 0, .haben),
    ("strammstehen", 0, .haben),
    ("dafürstehen", 0, .haben),
    ("zurückliegen", 0, .haben),
    ("anliegen", 0, .haben),
    ("daliegen", 0, .haben),
    ("brachliegen", 0, .haben),
    ("darniederliegen", 0, .haben),
    ("richtigliegen", 0, .haben),
    ("übereinanderliegen", 0, .haben),
    ("aufeinanderliegen", 0, .haben),
    ("darüberliegen", 0, .haben),
    ("schiefliegen", 0, .haben),
    ("abliegen", 0, .haben),
    ("vorliegen", 0, .haben),
    ("beiliegen", 0, .haben),
    ("umeinanderstehen", 0, .haben),
    ("erstehen", 0, .haben),
    ("erstehen", 1, .sein),
    ("unterliegen", 0, .haben),
    ("unterliegen", 1, .sein),
    ("bekommen", 0, .haben),
    ("anfangen", 0, .haben),
    ("wandern", 0, .sein),
    ("auftauchen", 0, .sein),
    ("ergehen", 0, .sein),
    ("hintergehen", 0, .haben),
    ("überkommen", 0, .haben),
    ("unterschreiben", 0, .haben),
    ("durchfallen", 0, .sein),
    ("übersteigen", 0, .haben),
    ("zufügen", 0, .haben),
    ("entrücken", 0, .haben),
    ("hinrücken", 0, .haben),
    ("zurückschieben", 0, .haben),
    ("rückdrehen", 0, .haben),
    ("umdrehen", 0, .haben),
    ("umwenden", 0, .haben),
    ("zukehren", 0, .haben),
    ("eintauchen", 0, .haben),
    ("eintauchen", 1, .sein),
    ("ausscheiden", 0, .sein),
    ("ausscheiden", 1, .haben),
    ("anfallen", 0, .sein),
    ("anfallen", 1, .haben),
    ("überspringen", 0, .haben),
    ("überspringen", 1, .sein),
    ("wegfliegen", 0, .sein),
    ("herumfliegen", 0, .sein),
    ("zusammenstoßen", 0, .sein),
    ("vorstoßen", 0, .sein),
    ("abrücken", 0, .sein),
    ("abrücken", 1, .haben),
    ("abschieben", 0, .haben),
    ("nachschieben", 0, .haben),
    ("umstürzen", 0, .sein),
    ("umstürzen", 1, .haben),
    ("herabstürzen", 0, .sein),
    ("austrocknen", 0, .haben),
    ("austrocknen", 1, .sein),
    ("vertrocknen", 0, .sein),
    ("abtrocknen", 0, .haben),
    ("abtrocknen", 1, .sein),
    ("erlöschen", 0, .sein),
    ("auslöschen", 0, .haben),
    ("schwellen", 0, .sein),
    ("aufschwellen", 0, .sein),
    ("zerschmelzen", 0, .sein),
    ("aufschmelzen", 0, .haben),
    ("aufschmelzen", 1, .sein),
    ("verrauchen", 0, .sein),
    ("ausrauchen", 0, .haben),
    ("erweichen", 0, .haben),
    ("erweichen", 1, .sein),
    ("bleichen", 0, .haben),
    ("ausbleichen", 0, .haben),
    ("gären", 0, .haben),
    ("frieren", 0, .haben),
    ("frieren", 1, .sein),
    ("erstinken", 0, .haben),
    ("schwingen", 0, .haben),
    ("ausklingen", 0, .sein),
    ("verlauten", 0, .haben),
    ("schleifen", 0, .haben),
    ("scheren", 0, .haben),
    ("verderben", 0, .haben),
    ("verderben", 1, .sein),
    ("ausrollen", 0, .haben),
    ("ausrollen", 1, .sein),
    ("einrollen", 0, .haben),
    ("einrollen", 1, .sein),
    ("abrollen", 0, .haben),
    ("abrollen", 1, .sein),
    ("verkleben", 0, .haben),
    ("verkleben", 1, .sein),
    ("ausreißen", 0, .haben),
    ("entzweireißen", 0, .haben),
    ("entzweireißen", 1, .sein),
    ("verschleißen", 0, .haben),
    ("verschleißen", 1, .sein),
    ("schleißen", 0, .haben),
    ("durchdringen", 0, .haben),
    ("durchdringen", 1, .sein),
    ("durchfließen", 0, .sein),
    ("durchschwimmen", 0, .sein),
    ("durchstechen", 0, .haben),
    ("durchhängen", 0, .haben),
    ("behängen", 0, .haben),
    ("vorhängen", 0, .haben),
    ("zuklappen", 0, .haben),
    ("zuklappen", 1, .sein),
    ("austräumen", 0, .haben),
    ("anrennen", 0, .sein),
    ("versaufen", 0, .haben),
    ("antanzen", 0, .sein),
    ("abschreiten", 0, .haben),
    ("anschleichen", 0, .haben),
    ("aufbiegen", 0, .haben),
    ("anscheißen", 0, .haben),
    ("zerkochen", 0, .sein),
    ("zerkochen", 1, .haben),
    ("festbacken", 0, .haben),
    ("mitfolgen", 0, .haben),
    ("übergehen", 0, .haben),
    ("übergehen", 1, .sein),
  ]

  @Test("Each ruled reading carries its dictionary auxiliary", arguments: auxiliaryRulings)
  func ruledAuxiliary(verb: String, readingIndex: Int, auxiliary: Auxiliary) throws {
    let reading = try #require(Verb.verbs[verb]?.reading(at: readingIndex), "\(verb) has no reading \(readingIndex)")
    #expect(reading.auxiliary == auxiliary)
  }

  // Defect plan, Part 7a. backen, hauen, and salzen kept a strong participle after their
  // Präteritum went weak, so neither family describes them. Each is mixed with a group holding
  // only a participle override; the mixed family's weak endings supply backte and haute.
  // Expectations are DWDS's and Duden's. kaikki lists the weak participle beside the strong one
  // for all three (gebackt, gehaut, gesalzt), which is how the weak encoding passed as verified.
  // Duden marks gehaut Austrian or regional, and gesalzt is usual only for salting roads.
  @Test func strongParticiplesBehindAWeakPräteritum() {
    expectConjugation(infinitiv: "backen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "backte")
    expectConjugation(infinitiv: "backen", conjugationgroup: .präteritumIndikativ(.secondSingular), expected: "backtest")
    expectConjugation(infinitiv: "backen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "backte")
    expectConjugation(infinitiv: "backen", conjugationgroup: .perfektpartizip, expected: "gebackEN")
    expectConjugation(infinitiv: "backen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gebackEN")
    expectConjugation(infinitiv: "aufbacken", conjugationgroup: .perfektpartizip, expected: "aufgebackEN")
    expectConjugation(infinitiv: "festbacken", conjugationgroup: .perfektpartizip, expected: "festgebackEN")

    expectConjugation(infinitiv: "hauen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "haute")
    expectConjugation(infinitiv: "hauen", conjugationgroup: .perfektpartizip, expected: "gehauEN")
    expectConjugation(infinitiv: "hauen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "hAt gehauEN")
    expectConjugation(infinitiv: "abhauen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "abhaute")
    expectConjugation(infinitiv: "abhauen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST abgehauEN")
    expectConjugation(infinitiv: "zusammenhauen", conjugationgroup: .perfektpartizip, expected: "zusammengehauEN")
    expectConjugation(infinitiv: "verhauen", conjugationgroup: .perfektpartizip, expected: "verhauEN")
    expectConjugation(infinitiv: "zerhauen", conjugationgroup: .perfektpartizip, expected: "zerhauEN")

    expectConjugation(infinitiv: "salzen", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "salzt")
    expectConjugation(infinitiv: "salzen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "salzte")
    expectConjugation(infinitiv: "salzen", conjugationgroup: .perfektpartizip, expected: "gesalzEN")
    expectConjugation(infinitiv: "nachsalzen", conjugationgroup: .perfektpartizip, expected: "nachgesalzEN")
    expectConjugation(infinitiv: "versalzen", conjugationgroup: .perfektpartizip, expected: "versalzEN")
  }

  // Defect plan, Part 7b. krauchen shipped with kriechen's paradigm (kroch, gekrochen), which
  // is all English Wiktionary gives. Duden and DWDS conjugate it weak; verbdata/
  // wiktionary-defects.json records the disagreement.
  @Test func krauchenIsWeak() {
    expectConjugation(infinitiv: "krauchen", conjugationgroup: .präteritumIndikativ(.thirdSingular), expected: "krauchte")
    expectConjugation(infinitiv: "krauchen", conjugationgroup: .perfektIndikativ(.thirdSingular), expected: "IST gekraucht")
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
    expectConjugation(infinitiv: "bersten", conjugationgroup: .präsensIndikativ(.secondSingular), expected: "bIrst")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "bIrst")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "bArst")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "bÄrste")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .perfektpartizip, expected: "gebOrsten")

    expectConjugation(infinitiv: "saufen", conjugationgroup: .präsensIndikativ(.thirdSingular), expected: "sÄUft")
    expectConjugation(infinitiv: "saufen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sOff")
    expectConjugation(infinitiv: "saufen", conjugationgroup: .präteritumKonjunktivII(.firstSingular), expected: "sÖffe")
    expectConjugation(infinitiv: "saufen", conjugationgroup: .perfektpartizip, expected: "gesOffen")

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
    expectConjugation(infinitiv: "kneifen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "knIff")
    expectConjugation(infinitiv: "kneifen", conjugationgroup: .perfektpartizip, expected: "geknIffen")
    expectConjugation(infinitiv: "pfeifen", conjugationgroup: .perfektpartizip, expected: "gepfIffen")
    expectConjugation(infinitiv: "gleiten", conjugationgroup: .perfektpartizip, expected: "geglItten")
    expectConjugation(infinitiv: "schreiten", conjugationgroup: .perfektpartizip, expected: "geschrItten")
    expectConjugation(infinitiv: "schleichen", conjugationgroup: .perfektpartizip, expected: "geschlIchen")
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
    expectConjugation(infinitiv: "gleiten", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geglItten")
    expectConjugation(infinitiv: "schleichen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geschlIchen")
    expectConjugation(infinitiv: "schreiten", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geschrItten")
    expectConjugation(infinitiv: "kriechen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gekrOchen")
    expectConjugation(infinitiv: "sprießen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gesprOSSen")
    expectConjugation(infinitiv: "rinnen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gerOnnen")
    expectConjugation(infinitiv: "schwinden", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geschwUnden")
    expectConjugation(infinitiv: "klimmen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geklOmmen")
    expectConjugation(infinitiv: "genesen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN genesen")
    expectConjugation(infinitiv: "bersten", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN gebOrsten")
    expectConjugation(infinitiv: "schwellen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN geschwOllen")
    expectConjugation(infinitiv: "zerschellen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "BIN zerschellt")

    // haben, for contrast: schmelzen's transitive reading, which was its only reading until
    // the defect plan gave it a second, and graben and melken, which take haben outright.
    expectConjugation(infinitiv: "schmelzen", conjugationgroup: .perfektIndikativ(.firstSingular), expected: "habe geschmOlzen", readingIndex: 1)
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
