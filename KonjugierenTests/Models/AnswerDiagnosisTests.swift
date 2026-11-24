// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

@Suite(.serialized)
@MainActor
struct AnswerDiagnosisTests {
  init() {
    Current.settings.region = .north
    Current.settings.quizLevel = .elementary
    Current.settings.conjugationgroupLang = .german
    Current.settings.thirdPersonPronounGender = .er
  }

  private func item(_ infinitiv: String, _ conjugationgroup: Conjugationgroup, readingIndex: Int = 0) throws -> QuizItem {
    let verb = try #require(Verb.verbs[infinitiv])
    return Quiz().makeQuizItem(verb: verb, conjugationgroup: conjugationgroup, readingIndex: readingIndex)
  }

  @Test(arguments: [
    ("hängen", Conjugationgroup.präteritumIndikativ(.firstSingular), 0, "hängte", AnswerDiagnosis.otherReading(infinitiv: "hängen", translation: "hang, suspend something")),
    ("hängen", .präteritumIndikativ(.firstSingular), 1, "hing", .otherReading(infinitiv: "hängen", translation: "hang, be suspended")),
    ("aufstehen", .imperativ(.secondSingular), 0, "aufsteh", .prefixAtEnd(prefix: "auf")),
    ("aufstehen", .imperativ(.secondPlural), 0, "aufsteht", .prefixAtEnd(prefix: "auf")),
    ("aufstehen", .perfektpartizip, 0, "gestanden auf", .participleIsOneWord(prefix: "auf")),
    ("aufstehen", .perfektIndikativ(.firstSingular), 0, "bin auf gestanden", .participleIsOneWord(prefix: "auf")),
    ("gehen", .perfektIndikativ(.firstSingular), 0, "gegangen", .missingAuxiliary(.perfektIndikativ(.firstSingular))),
    ("gehen", .futurIndikativ(.thirdSingular), 0, "gehen", .missingAuxiliary(.futurIndikativ(.thirdSingular))),
    ("gehen", .perfektIndikativ(.thirdSingular), 0, "hat gegangen", .wrongAuxiliary(infinitiv: "gehen", expected: .sein, given: .haben)),
    ("gehen", .perfektIndikativ(.thirdSingular), 0, "er hat gegangen", .wrongAuxiliary(infinitiv: "gehen", expected: .sein, given: .haben)),
    ("machen", .plusquamperfektIndikativ(.firstSingular), 0, "war gemacht", .wrongAuxiliary(infinitiv: "machen", expected: .haben, given: .sein)),
    ("machen", .perfektpartizip, 0, "macht", .missingGe),
    ("aufstehen", .perfektpartizip, 0, "aufstanden", .missingGe),
    ("gehen", .perfektIndikativ(.firstSingular), 0, "bin gangen", .missingGe),
    ("verstehen", .perfektpartizip, 0, "geverstanden", .geOnInseparable(prefix: "ver")),
    ("studieren", .perfektpartizip, 0, "gestudiert", .geOnIeren),
    ("studieren", .perfektIndikativ(.firstSingular), 0, "habe gestudiert", .geOnIeren),
    ("aufstehen", .perfektpartizip, 0, "geaufstanden", .geBeforeSeparablePrefix(prefix: "auf")),
    ("gehen", .präteritumIndikativ(.firstSingular), 0, "gehte", .weakConjugation(infinitiv: "gehen", isMixed: false)),
    ("singen", .perfektpartizip, 0, "gesingt", .weakConjugation(infinitiv: "singen", isMixed: false)),
    ("aufstehen", .präteritumIndikativ(.firstSingular), 0, "stehte auf", .weakConjugation(infinitiv: "aufstehen", isMixed: false)),
    ("fahren", .präsensIndikativ(.secondSingular), 0, "fahrst", .weakConjugation(infinitiv: "fahren", isMixed: false)),
    // Also ihr fahrt, but the weak conjugation explains the missing umlaut.
    ("fahren", .präsensIndikativ(.thirdSingular), 0, "fahrt", .weakConjugation(infinitiv: "fahren", isMixed: false)),
    ("denken", .präteritumIndikativ(.firstSingular), 0, "denkte", .weakConjugation(infinitiv: "denken", isMixed: true)),
    ("kommen", .präsensIndikativ(.secondSingular), 0, "kommt", .otherPerson([.thirdSingular, .secondPlural], isImperativ: false)),
    ("gehen", .imperativ(.secondSingular), 0, "geht", .otherPerson([.secondPlural], isImperativ: true)),
    ("gehen", .perfektIndikativ(.firstSingular), 0, "ging", .otherConjugationgroup(.präteritumIndikativ(.firstSingular), persons: [])),
    ("gehen", .präsensIndikativ(.secondSingular), 0, "ging", .otherConjugationgroup(.präteritumIndikativ(.firstSingular), persons: [.firstSingular, .thirdSingular])),
    ("machen", .präteritumIndikativ(.firstSingular), 0, "gemacht", .otherConjugationgroup(.perfektpartizip, persons: []))
  ])
  func aDiagnosableErrorIsNamed(infinitiv: String, conjugationgroup: Conjugationgroup, readingIndex: Int, answer: String, expected: AnswerDiagnosis) throws {
    #expect(try item(infinitiv, conjugationgroup, readingIndex: readingIndex).diagnosis(of: answer) == expected)
  }

  // Right answers, a regional auxiliary that is right in Austria and Switzerland, a slip with
  // nothing certain to say about it, and nonsense.
  @Test(arguments: [
    ("gehen", Conjugationgroup.perfektIndikativ(.firstSingular), "bin gegangen"),
    ("gehen", .perfektIndikativ(.firstSingular), "ich bin gegangen"),
    ("stehen", .perfektIndikativ(.firstSingular), "bin gestanden"),
    ("kommen", .präsensIndikativ(.secondSingular), "komst"),
    ("aufstehen", .präsensIndikativ(.firstSingular), "aufstehe"),
    ("kommen", .präsensIndikativ(.secondSingular), "definitelywrong"),
    ("kommen", .präsensIndikativ(.secondSingular), "")
  ])
  func anUndiagnosableAnswerGetsNoLine(infinitiv: String, conjugationgroup: Conjugationgroup, answer: String) throws {
    #expect(try item(infinitiv, conjugationgroup).diagnosis(of: answer) == nil)
  }

  @Test func theLinesNameTheError() {
    #expect(AnswerDiagnosis.wrongAuxiliary(infinitiv: "gehen", expected: .sein, given: .haben).line == "With gehen, the auxiliary is sein, not haben.")
    #expect(AnswerDiagnosis.prefixAtEnd(prefix: "auf").line == "In the Imperativ, auf goes at the end.")
    #expect(AnswerDiagnosis.missingAuxiliary(.perfektIndikativ(.firstSingular)).line == "The Perfekt Indikativ needs an auxiliary as well.")
    #expect(AnswerDiagnosis.otherPerson([.thirdSingular, .secondPlural], isImperativ: false).line == "That is the conjugation for er and ihr.")
    #expect(AnswerDiagnosis.otherPerson([.thirdPlural], isImperativ: true).line == "That is the conjugation for Sie.")
    #expect(AnswerDiagnosis.otherConjugationgroup(.präteritumIndikativ(.firstSingular), persons: []).line == "That conjugation belongs to the Präteritum Indikativ.")
    #expect(AnswerDiagnosis.weakConjugation(infinitiv: "singen", isMixed: false).line == "That is a weak verb’s conjugation, and singen is strong.")
  }

  @Test func theLinesFollowTheConjugationgroupLanguage() {
    Current.settings.conjugationgroupLang = .english
    defer {
      Current.settings.conjugationgroupLang = .german
    }
    #expect(AnswerDiagnosis.otherConjugationgroup(.präteritumIndikativ(.firstSingular), persons: []).line == "That conjugation belongs to the Past Indicative.")
  }

  /// A quiz on verstehen, whose questions are drawn at random from its cells.
  private func startedQuiz() throws -> Quiz {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .verbPage(try #require(Verb.verbs["verstehen"]), readingIndex: 0))
    return quiz
  }

  /// Another cell's conjugation that the question does not accept and can diagnose.
  private func diagnosableAnswer(for question: QuizItem) throws -> String {
    let answer = Conjugationgroup.allCells.lazy
      .compactMap { conjugationgroup in
        try? Conjugator.conjugate(infinitiv: question.verb.infinitiv, conjugationgroup: conjugationgroup, clause: .main).get().lowercased()
      }
      .first { !question.accepts($0) && question.diagnosis(of: $0) != nil }
    return try #require(answer)
  }

  @Test func aDiagnosedErrorWaitsOnItsQuestion() throws {
    let quiz = try startedQuiz()
    let question = quiz.questions[0]
    let answer = try diagnosableAnswer(for: question)
    quiz.submitAnswer(answer)

    let diagnosis = try #require(question.diagnosis(of: answer))
    #expect(quiz.isAwaitingSecondAttempt)
    #expect(quiz.correction == nil)
    #expect(quiz.currentIndex == 0)
    #expect(quiz.questions[0].firstAttempt == answer)
    #expect(quiz.questions[0].firstAttemptDiagnosis == diagnosis)
    #expect(quiz.questions[0].secondAttemptPrompt == diagnosis.line + " Try once more.")
    quiz.quit()
  }

  @Test func aRightRepairEarnsHalfPoints() throws {
    let quiz = try startedQuiz()
    quiz.submitAnswer(try diagnosableAnswer(for: quiz.questions[0]))
    quiz.submitAnswer(quiz.questions[0].correctAnswer)

    #expect(quiz.score == Quiz.pointsPerSecondAttempt)
    #expect(quiz.secondAttemptCount == 1)
    #expect(quiz.questions[0].state == .correctOnSecondAttempt)
    #expect(quiz.currentIndex == 1)
    quiz.quit()
  }

  @Test func aWrongRepairShowsTheCorrectionWithItsOwnDiagnosis() throws {
    let quiz = try startedQuiz()
    let question = quiz.questions[0]
    let first = try diagnosableAnswer(for: question)
    let second = question.correctAnswer.lowercased() + "x"
    quiz.submitAnswer(first)
    quiz.submitAnswer(second)

    #expect(quiz.correction?.difference.given == second)
    #expect(quiz.correction?.diagnosis == question.diagnosis(of: second))
    #expect(quiz.questions[0].state == .incorrect)
    #expect(!quiz.isAwaitingSecondAttempt)
    quiz.quit()
  }

  /// One more attempt at most, whatever earned it: a slip after a diagnosis is not given a third.
  @Test func aSlipAfterADiagnosisGoesToTheCorrection() throws {
    let quiz = try startedQuiz()
    let question = quiz.questions[0]
    quiz.submitAnswer(try diagnosableAnswer(for: question))
    let slip = question.correctAnswer.lowercased() + "x"
    #expect(question.isSlip(slip))
    quiz.submitAnswer(slip)

    #expect(quiz.correction != nil)
    #expect(quiz.questions[0].state == .incorrect)
    quiz.quit()
  }

  @Test func aDiagnosedErrorOnTheLastAttemptIsShownInTheCorrection() throws {
    let quiz = try startedQuiz()
    let question = quiz.questions[0]
    let answer = try diagnosableAnswer(for: question)
    quiz.submitAnswer(answer)
    quiz.submitAnswer(answer)

    #expect(quiz.correction?.diagnosis == question.diagnosis(of: answer))
    #expect(quiz.correction?.diagnosis != nil)
    quiz.quit()
  }

  @Test func aSlipSaysAlmostRatherThanADiagnosis() throws {
    let quiz = try startedQuiz()
    quiz.submitAnswer(quiz.questions[0].correctAnswer.lowercased() + "x")

    #expect(quiz.isAwaitingSecondAttempt)
    #expect(quiz.questions[0].firstAttemptDiagnosis == nil)
    #expect(quiz.questions[0].secondAttemptPrompt == L.Quiz.almost)
    quiz.quit()
  }
}
