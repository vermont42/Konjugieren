// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

/// The variants Josh accepted on 2026-11-13, by their row in
/// plans/pedagogy-phase1-variant-audit.md, and the ones he rejected.
@Suite(.serialized)
@MainActor
struct StandardVariantsTests {
  init() {
    Current.settings.region = .north
  }

  private func accepts(_ infinitiv: String, _ conjugationgroup: Conjugationgroup, _ answer: String, readingIndex: Int = 0) throws -> Bool {
    let verb = try #require(Verb.verbs[infinitiv])
    return Quiz().makeQuizItem(verb: verb, conjugationgroup: conjugationgroup, readingIndex: readingIndex).accepts(answer)
  }

  @Test func a1ImperativTakesAnOptionalE() throws {
    #expect(try accepts("gehen", .imperativ(.secondSingular), "geh"))
    #expect(try accepts("gehen", .imperativ(.secondSingular), "gehe"))
    #expect(try accepts("kommen", .imperativ(.secondSingular), "komme"))
    #expect(try accepts("entschuldigen", .imperativ(.secondSingular), "entschuldige"))
    #expect(try accepts("weggehen", .imperativ(.secondSingular), "gehe weg"))
    #expect(try accepts("tun", .imperativ(.secondSingular), "tue"))
  }

  @Test func a1NeverForAChangedStem() throws {
    #expect(!(try accepts("sehen", .imperativ(.secondSingular), "siehe")))
    #expect(!(try accepts("nehmen", .imperativ(.secondSingular), "nimme")))
    #expect(!(try accepts("geben", .imperativ(.secondSingular), "gibe")))
  }

  @Test func a2StrongDOrTStemMayDropTheE() throws {
    #expect(try accepts("bitten", .imperativ(.secondSingular), "bitt"))
    #expect(try accepts("halten", .imperativ(.secondSingular), "halt"))
    #expect(try accepts("finden", .imperativ(.secondSingular), "find"))
    #expect(try accepts("bitten", .imperativ(.secondSingular), "bitte"))
  }

  @Test func a2WeakDOrTStemKeepsTheE() throws {
    #expect(!(try accepts("arbeiten", .imperativ(.secondSingular), "arbeit")))
    #expect(!(try accepts("reden", .imperativ(.secondSingular), "red")))
  }

  @Test func b1ElnVerbsMayDropTheEOfEl() throws {
    #expect(try accepts("sammeln", .präsensIndikativ(.firstSingular), "sammle"))
    #expect(try accepts("sammeln", .präsensIndikativ(.firstSingular), "sammele"))
    #expect(try accepts("sammeln", .präsensKonjunktivI(.firstSingular), "sammle"))
    #expect(try accepts("sammeln", .präsensKonjunktivI(.thirdSingular), "sammle"))
    #expect(try accepts("sammeln", .imperativ(.secondSingular), "sammle"))
    #expect(try accepts("sammeln", .imperativ(.secondSingular), "sammele"))
    #expect(try accepts("sammeln", .imperativ(.secondSingular), "sammel"))
    #expect(try accepts("einsammeln", .präsensIndikativ(.firstSingular), "sammle ein"))
    #expect(try accepts("einsammeln", .präsensIndikativ(.firstSingular), "einsammle"))
  }

  @Test func b2ErnVerbsKeepTheEOfEr() throws {
    #expect(!(try accepts("wandern", .präsensIndikativ(.firstSingular), "wandre")))
    #expect(!(try accepts("ändern", .präsensKonjunktivI(.firstSingular), "ändre")))
    #expect(try accepts("wandern", .imperativ(.secondSingular), "wandere"))
  }

  @Test func b3KonjunktivIOfElnAndErnVerbs() throws {
    #expect(try accepts("sammeln", .präsensKonjunktivI(.secondSingular), "sammelst"))
    #expect(try accepts("sammeln", .präsensKonjunktivI(.secondPlural), "sammelt"))
    #expect(try accepts("wandern", .präsensKonjunktivI(.secondSingular), "wanderst"))
    #expect(try accepts("wandern", .präsensKonjunktivI(.secondPlural), "wandert"))
  }

  @Test func c1KonjunktivIIMayDropTheE() throws {
    #expect(try accepts("kommen", .präteritumKonjunktivII(.secondSingular), "kämst"))
    #expect(try accepts("kommen", .präteritumKonjunktivII(.secondPlural), "kämt"))
    #expect(try accepts("kommen", .präteritumKonjunktivII(.secondSingular), "kämest"))
    #expect(try accepts("sein", .präteritumKonjunktivII(.secondSingular), "wärst"))
    #expect(try accepts("sein", .präteritumKonjunktivII(.secondPlural), "wärt"))
    #expect(try accepts("gehen", .plusquamperfektKonjunktivII(.secondSingular), "wärst gegangen"))
  }

  @Test func c1NotAfterASibilantDTOrVowel() throws {
    #expect(!(try accepts("essen", .präteritumKonjunktivII(.secondSingular), "äßst")))
    #expect(!(try accepts("machen", .präteritumKonjunktivII(.secondSingular), "machtst")))
    #expect(!(try accepts("schreien", .präteritumKonjunktivII(.secondSingular), "schrist")))
  }

  @Test func c2PräteritumDuEitherWay() throws {
    #expect(try accepts("bitten", .präteritumIndikativ(.secondSingular), "batst"))
    #expect(try accepts("bitten", .präteritumIndikativ(.secondSingular), "batest"))
    #expect(try accepts("halten", .präteritumIndikativ(.secondSingular), "hieltst"))
    #expect(try accepts("essen", .präteritumIndikativ(.secondSingular), "aßest"))
    #expect(try accepts("essen", .präteritumIndikativ(.secondSingular), "aßt"))
    #expect(try accepts("aufstehen", .präteritumIndikativ(.secondSingular), "standst auf"))
  }

  @Test func c2NotForWeakVerbs() throws {
    #expect(!(try accepts("arbeiten", .präteritumIndikativ(.secondSingular), "arbeitetst")))
  }

  @Test func c3Seiest() throws {
    #expect(try accepts("sein", .präsensKonjunktivI(.secondSingular), "seiest"))
    #expect(try accepts("sein", .präsensKonjunktivI(.secondSingular), "seist"))
    #expect(try accepts("gehen", .perfektKonjunktivI(.secondSingular), "seiest gegangen"))
  }

  @Test(arguments: [
    ("stehen", "stünde"),
    ("verstehen", "verstünde"),
    ("aufstehen", "stünde auf"),
    ("helfen", "hülfe"),
    ("beginnen", "begönne"),
    ("schwimmen", "schwömme"),
    ("empfehlen", "empföhle"),
    ("stehlen", "stöhle"),
    ("gelten", "gälte"),
    ("entgelten", "entgälte")
  ])
  func d1KonjunktivIIVowelDoublets(infinitiv: String, answer: String) throws {
    #expect(try accepts(infinitiv, .präteritumKonjunktivII(.firstSingular), answer))
  }

  @Test func d1OnlyForTheListedVerbs() throws {
    #expect(!(try accepts("sprechen", .präteritumKonjunktivII(.firstSingular), "spröche")))
    #expect(!(try accepts("stehen", .präteritumIndikativ(.firstSingular), "stund")))
  }

  @Test func d1DigraphSpellingShowsTheVariant() throws {
    let verb = try #require(Verb.verbs["stehen"])
    let item = Quiz().makeQuizItem(verb: verb, conjugationgroup: .präteritumKonjunktivII(.firstSingular))
    #expect(item.preferredSpelling(of: "stuende") == "stünde")
    #expect(item.preferredSpelling(of: "staende") == item.correctAnswer)
  }

  @Test func d2HubIsRejected() throws {
    #expect(!(try accepts("heben", .präteritumIndikativ(.firstSingular), "hub")))
    #expect(!(try accepts("heben", .präteritumKonjunktivII(.firstSingular), "hübe")))
  }

  @Test func e1Sandte() throws {
    #expect(try accepts("senden", .präteritumIndikativ(.firstSingular), "sandte"))
    #expect(try accepts("senden", .präteritumIndikativ(.secondPlural), "sandtet"))
    #expect(try accepts("senden", .perfektpartizip, "gesandt"))
    #expect(try accepts("senden", .perfektIndikativ(.firstSingular), "habe gesandt"))
    #expect(try accepts("absenden", .präteritumIndikativ(.firstSingular), "sandte ab"))
    #expect(try accepts("absenden", .präteritumIndikativ(.firstSingular), "absandte"))
    #expect(try accepts("absenden", .perfektpartizip, "abgesandt"))
    #expect(try accepts("versenden", .perfektpartizip, "versandt"))
    #expect(try accepts("senden", .präteritumIndikativ(.firstSingular), "sendete"))
  }

  // Duden gives senden's Konjunktiv II as sendete only.
  @Test func e1NotInKonjunktivII() throws {
    #expect(!(try accepts("senden", .präteritumKonjunktivII(.firstSingular), "sandte")))
  }

  @Test func e2Wandte() throws {
    #expect(try accepts("wenden", .präteritumIndikativ(.thirdSingular), "wandte"))
    #expect(try accepts("verwenden", .perfektpartizip, "verwandt"))
    #expect(try accepts("anwenden", .perfektIndikativ(.thirdSingular), "hat angewandt"))
    #expect(try accepts("verwenden", .präteritumIndikativ(.firstPlural), "verwandten"))
  }

  @Test func e3OtherDoublets() throws {
    #expect(try accepts("melken", .präteritumIndikativ(.firstSingular), "melkte"))
    #expect(try accepts("melken", .perfektpartizip, "gemelkt"))
    #expect(try accepts("winken", .perfektpartizip, "gewunken"))
    #expect(try accepts("winken", .perfektIndikativ(.firstSingular), "habe gewunken"))
    #expect(try accepts("gären", .präteritumIndikativ(.firstSingular), "gärte"))
    #expect(try accepts("salzen", .perfektpartizip, "gesalzt"))
    #expect(try accepts("sieden", .präteritumIndikativ(.firstSingular), "siedete"))
    #expect(try accepts("sieden", .perfektpartizip, "gesiedet"))
    #expect(try accepts("hauen", .präteritumIndikativ(.firstSingular), "hieb"))
    #expect(try accepts("hauen", .präteritumIndikativ(.secondSingular), "hiebst"))
  }

  @Test func e3PresentStaysAsItIs() throws {
    #expect(!(try accepts("winken", .präsensIndikativ(.thirdSingular), "wunkt")))
    #expect(!(try accepts("abhauen", .präteritumIndikativ(.firstSingular), "hieb ab")))
    #expect(!(try accepts("hauen", .perfektpartizip, "gehaut")))
  }

  @Test func e4ArchaicAndColloquialAreRejected() throws {
    #expect(!(try accepts("fragen", .präteritumIndikativ(.firstSingular), "frug")))
    #expect(!(try accepts("stecken", .präteritumIndikativ(.firstSingular), "stak")))
    #expect(!(try accepts("backen", .präteritumIndikativ(.firstSingular), "buk")))
  }

  @Test func f1AnerkennenSplits() throws {
    #expect(try accepts("anerkennen", .präsensIndikativ(.thirdSingular), "erkennt an"))
    #expect(try accepts("anerkennen", .präsensIndikativ(.thirdSingular), "anerkennt"))
    #expect(try accepts("anerkennen", .präteritumIndikativ(.firstSingular), "erkannte an"))
    #expect(try accepts("anerkennen", .imperativ(.thirdPlural), "erkennen Sie an"))
    #expect(!(try accepts("anerkennen", .perfektpartizip, "erkannt an")))
  }

  @Test func scheidenAndVergleichenAreGradedRight() throws {
    #expect(try accepts("vergleichen", .präteritumIndikativ(.firstSingular), "verglich"))
    #expect(try accepts("scheiden", .perfektIndikativ(.thirdSingular), "hat geschieden"))
  }
}
