// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite(.serialized)
@MainActor
struct AnswerSpellingTests {
  init() {
    Current.settings.region = .north
  }

  private func item(_ infinitiv: String, _ conjugationgroup: Conjugationgroup, readingIndex: Int = 0) throws -> QuizItem {
    let verb = try #require(Verb.verbs[infinitiv])
    return Quiz().makeQuizItem(verb: verb, conjugationgroup: conjugationgroup, readingIndex: readingIndex)
  }

  // The three simulator cases from plans/pedagogy.md.
  @Test func reportCasesPass() throws {
    #expect(try item("ferngucken", .perfektIndikativ(.secondPlural)).accepts("ihr habt ferngeguckt"))
    #expect(try item("übernehmen", .präsensIndikativ(.firstSingular)).accepts("uebernehme"))
    #expect(try item("umstoßen", .imperativ(.thirdPlural)).accepts("stossen Sie um"))
  }

  @Test(arguments: [
    (PersonNumber.firstSingular, "ich gehe"),
    (.secondSingular, "du gehst"),
    (.thirdSingular, "er geht"),
    (.thirdSingular, "sie geht"),
    (.thirdSingular, "es geht"),
    (.firstPlural, "wir gehen"),
    (.secondPlural, "ihr geht"),
    (.thirdPlural, "sie gehen"),
    (.thirdPlural, "Sie gehen")
  ])
  func leadingPronounOfTheAskedPersonIsIgnored(personNumber: PersonNumber, answer: String) throws {
    #expect(try item("gehen", .präsensIndikativ(personNumber)).accepts(answer))
  }

  @Test func leadingPronounOfAnotherPersonIsWrong() throws {
    let item = try item("gehen", .präsensIndikativ(.thirdSingular))
    #expect(!item.accepts("ich geht"))
    #expect(!item.accepts("du geht"))
    #expect(!item.accepts("ihr geht"))
  }

  @Test func pronounIsStrippedFromCompoundAndSeparableAnswers() throws {
    let item = try item("ankommen", .präsensIndikativ(.thirdSingular))
    #expect(item.accepts("er kommt an"))
    #expect(item.accepts("Er  ankommt"))
    #expect(try self.item("ankommen", .perfektIndikativ(.firstSingular)).accepts("ich bin angekommen"))
  }

  // The wir and Sie imperatives carry their pronoun after the verb, and nothing goes in front of
  // any imperative.
  @Test func imperativKeepsItsPronounAndTakesNoneInFront() throws {
    let sie = try item("umstoßen", .imperativ(.thirdPlural))
    #expect(sie.accepts("stoßen Sie um"))
    #expect(!sie.accepts("Sie stoßen Sie um"))
    #expect(!sie.accepts("Sie stoßen um"))
    #expect(!sie.accepts("stoßen um"))
    let du = try item("gehen", .imperativ(.secondSingular))
    #expect(du.accepts("geh"))
    #expect(!du.accepts("du geh"))
  }

  @Test func participleTakesNoPronoun() throws {
    #expect(!(try item("gehen", .perfektpartizip).accepts("ich gegangen")))
  }

  @Test func digraphsStandForUmlauts() throws {
    let item = try item("übernehmen", .präteritumKonjunktivII(.firstSingular))
    #expect(item.accepts("übernähme"))
    #expect(item.accepts("uebernaehme"))
    #expect(item.accepts("uebernähme"))
    #expect(item.accepts("übernaehme"))
    #expect(item.accepts("ich UEBERNAEHME"))
  }

  @Test func missingUmlautStaysWrong() throws {
    #expect(!(try item("übernehmen", .präsensIndikativ(.firstSingular)).accepts("ubernehme")))
    #expect(!(try item("fahren", .präsensIndikativ(.thirdSingular)).accepts("fahrt")))
  }

  // The expansion runs only from umlaut to digraph, so a word with a real ue does not gain a
  // spelling with ü.
  @Test func genuineDigraphIsNotAnUmlaut() throws {
    let item = try item("bauen", .präsensIndikativ(.firstSingular))
    #expect(item.accepts("baue"))
    #expect(!item.accepts("baü"))
  }

  @Test func digraphSpellingsCoverEveryCombination() {
    #expect(AnswerSpelling.digraphSpellings(of: "übernähme") == ["übernähme", "uebernähme", "übernaehme", "uebernaehme"])
    #expect(AnswerSpelling.digraphSpellings(of: "geht") == ["geht"])
  }

  @Test func preferredSpellingShowsTheUmlautsOfADigraphAnswer() throws {
    let item = try item("übernehmen", .präsensIndikativ(.firstSingular))
    #expect(item.preferredSpelling(of: "uebernehme") == "übernehme")
    #expect(item.preferredSpelling(of: "ich uebernehme") == "übernehme")
    #expect(item.preferredSpelling(of: "übernehme") == nil)
    #expect(item.preferredSpelling(of: "ubernehme") == nil)
  }

  @Test func preferredSpellingFollowsTheRegion() throws {
    let german = try item("umstoßen", .imperativ(.thirdPlural))
    #expect(german.correctAnswer.lowercased() == "stoßen sie um")
    #expect(german.preferredSpelling(of: "stossen Sie um") == german.correctAnswer)
    Current.settings.region = .switzerland
    defer { Current.settings.region = .north }
    #expect(try item("umstoßen", .imperativ(.thirdPlural)).preferredSpelling(of: "stossen Sie um") == nil)
  }

  // Austria's Perfekt with sein is a right answer, not a misspelling of Germany's.
  @Test func anotherRegionsAuxiliaryGetsNoCorrection() throws {
    let item = try item("stehen", .perfektIndikativ(.firstSingular))
    #expect(item.accepts("bin gestanden"))
    #expect(item.preferredSpelling(of: "bin gestanden") == nil)
  }

  @Test func preferredSpellingMatchesTheClauseTyped() throws {
    // Reading 1 is the separable "boil over"; reading 0, "cook again", is inseparable.
    let item = try item("überkochen", .präsensIndikativ(.thirdSingular), readingIndex: 1)
    #expect(item.preferredSpelling(of: "kocht ueber") == "kocht über")
    #expect(item.preferredSpelling(of: "ueberkocht") == "überkocht")
  }

  @Test func quizRecordsThePreferredSpellingOfARightAnswer() throws {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .verbPage(try #require(Verb.verbs["übernehmen"]), readingIndex: 0))
    let question = try #require(quiz.currentQuestion)
    let digraphAnswer = question.correctAnswer.lowercased()
      .replacingOccurrences(of: "ü", with: "ue")
      .replacingOccurrences(of: "ä", with: "ae")
    quiz.submitAnswer(digraphAnswer)
    #expect(quiz.questions[0].isCorrect == true)
    #expect(quiz.lastPreferredSpelling == question.correctAnswer)
    quiz.submitAnswer("falsch")
    #expect(quiz.lastPreferredSpelling == nil)
    quiz.quit()
  }
}
