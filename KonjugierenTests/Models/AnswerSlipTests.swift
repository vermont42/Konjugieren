// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite(.serialized)
@MainActor
struct AnswerSlipTests {
  init() {
    Current.settings.region = .north
    Current.settings.quizLevel = .elementary
  }

  private func item(_ infinitiv: String, _ conjugationgroup: Conjugationgroup, readingIndex: Int = 0) throws -> QuizItem {
    let verb = try #require(Verb.verbs[infinitiv])
    return Quiz().makeQuizItem(verb: verb, conjugationgroup: conjugationgroup, readingIndex: readingIndex)
  }

  @Test(arguments: [
    ("fahrt", "fährt", true),
    ("komst", "kommst", true),
    ("gehne sie", "gehen sie", true),
    ("ubernahme", "übernähme", true),
    ("weis", "weiß", true),
    ("geb", "gib", false),
    ("fährt", "fährt", false),
    ("fahrst", "fährt", false),
    ("kommen", "kommst", false)
  ])
  func slipBetweenSpellings(answer: String, target: String, isSlip: Bool) {
    #expect(AnswerSlip.isSlip(answer, of: target) == isSlip)
  }

  @Test(arguments: [
    ("fahren", Conjugationgroup.präsensIndikativ(.secondSingular), "fahrst"),
    ("kommen", .präsensIndikativ(.secondSingular), "komst"),
    ("kommen", .präsensIndikativ(.secondSingular), "du komst"),
    ("wissen", .präsensIndikativ(.firstSingular), "weis"),
    ("singen", .präteritumIndikativ(.firstSingular), "sanf"),
    ("übernehmen", .präsensIndikativ(.firstSingular), "ubernehme"),
    ("aufstehen", .perfektIndikativ(.firstSingular), "bin aufgestandn"),
    ("umstoßen", .imperativ(.thirdPlural), "stosen Sie um")
  ])
  func aSlipEarnsAnotherAttempt(infinitiv: String, conjugationgroup: Conjugationgroup, answer: String) throws {
    #expect(try item(infinitiv, conjugationgroup).isSlip(answer))
  }

  // Each is near the right answer and wrong for a reason other than typing: another person,
  // another conjugationgroup, too short to call a slip, or not wrong at all.
  @Test(arguments: [
    ("kommen", Conjugationgroup.präsensIndikativ(.secondSingular), "kommt"),
    // A missing umlaut, yet also ihr fahrt, so it is the wrong person until Phase 14 can say
    // which error it is.
    ("fahren", .präsensIndikativ(.thirdSingular), "fahrt"),
    ("müssen", .präteritumKonjunktivII(.secondSingular), "musstest"),
    ("singen", .präteritumIndikativ(.firstSingular), "sing"),
    ("geben", .imperativ(.secondSingular), "geb"),
    ("fahren", .präsensIndikativ(.thirdSingular), "fährt"),
    ("übernehmen", .präsensIndikativ(.firstSingular), "uebernehme"),
    ("kommen", .präsensIndikativ(.secondSingular), "definitelywrong")
  ])
  func notASlip(infinitiv: String, conjugationgroup: Conjugationgroup, answer: String) throws {
    #expect(try !item(infinitiv, conjugationgroup).isSlip(answer))
  }

  /// A quiz on verstehen, every cell of which has at least four letters, so that any question's
  /// answer with one letter added is a slip.
  private func startedQuiz() throws -> Quiz {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .verbPage(try #require(Verb.verbs["verstehen"]), readingIndex: 0))
    return quiz
  }

  private func slip(of question: QuizItem) -> String {
    question.correctAnswer.lowercased() + "x"
  }

  @Test func aSlipWaitsOnItsQuestion() throws {
    let quiz = try startedQuiz()
    let answer = slip(of: quiz.questions[0])
    quiz.submitAnswer(answer)

    #expect(quiz.isAwaitingSecondAttempt)
    #expect(quiz.currentIndex == 0)
    #expect(quiz.correction == nil)
    #expect(quiz.score == 0)
    #expect(quiz.questions[0].firstAttempt == answer)
    #expect(quiz.questions[0].state == .unanswered)
    quiz.quit()
  }

  @Test func aRightSecondAttemptEarnsHalfPoints() throws {
    let quiz = try startedQuiz()
    quiz.submitAnswer(slip(of: quiz.questions[0]))
    quiz.submitAnswer(quiz.questions[0].correctAnswer)

    #expect(quiz.score == Quiz.pointsPerSecondAttempt)
    #expect(Quiz.pointsPerSecondAttempt * 2 == Quiz.pointsPerCorrect)
    #expect(quiz.correctCount == 0)
    #expect(quiz.secondAttemptCount == 1)
    #expect(quiz.questions[0].state == .correctOnSecondAttempt)
    #expect(quiz.currentIndex == 1)
    #expect(!quiz.isAwaitingSecondAttempt)
    quiz.quit()
  }

  @Test func aSecondSlipGoesToTheCorrection() throws {
    let quiz = try startedQuiz()
    let first = slip(of: quiz.questions[0])
    let second = quiz.questions[0].correctAnswer.lowercased() + "y"
    quiz.submitAnswer(first)
    quiz.submitAnswer(second)

    #expect(quiz.correction?.difference.given == second)
    #expect(quiz.questions[0].state == .incorrect)
    #expect(quiz.questions[0].userAnswer == second)
    #expect(quiz.questions[0].firstAttempt == first)
    #expect(!quiz.isAwaitingSecondAttempt)
    #expect(quiz.currentIndex == 0)

    quiz.continueAfterCorrection()
    #expect(quiz.currentIndex == 1)
    #expect(quiz.score == 0)
    quiz.quit()
  }

  @Test func aRealErrorGetsNoSecondAttempt() throws {
    let quiz = try startedQuiz()
    quiz.submitAnswer("definitelywrong")

    #expect(quiz.correction != nil)
    #expect(quiz.questions[0].firstAttempt == nil)
    quiz.quit()
  }

  @Test func aSecondAttemptIsCountedApartInTheResults() throws {
    let quiz = try startedQuiz()
    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    quiz.submitAnswer(slip(of: quiz.questions[1]))
    quiz.submitAnswer(quiz.questions[1].correctAnswer)
    quiz.submitAnswer(quiz.questions[2].correctAnswer)

    #expect(quiz.shouldShowResults)
    #expect(quiz.correctCount == 2)
    #expect(quiz.secondAttemptCount == 1)
    #expect(quiz.finalScore == 2 * Quiz.pointsPerCorrect + Quiz.pointsPerSecondAttempt)
  }

  @Test func quittingClearsTheSecondAttemptCount() throws {
    let quiz = try startedQuiz()
    quiz.submitAnswer(slip(of: quiz.questions[0]))
    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    quiz.quit()

    #expect(quiz.secondAttemptCount == 0)
    #expect(!quiz.isAwaitingSecondAttempt)
  }
}
