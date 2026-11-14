// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Practice record")
  struct PracticeTests {
    private let tenDaysAgo = Date.now.addingTimeInterval(-10 * 86_400)

    /// A fresh record for the test, since the unit-test world's is shared. Each test puts back an
    /// empty one with `defer`, so that its overdue items reach no other suite's quiz.
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    /// A strong verb with one reading in the Elementary band, so that its key conjugations are
    /// unambiguous.
    private func strongBandVerb(excluding excluded: Set<String> = []) throws -> Verb {
      try #require(Quiz.defaultVerbs(for: .elementary).first { verb in
        verb.readings.count == 1 && QuizDraw.isStrong(verb.primaryReading) && !QuizDraw.isCore(verb) && !excluded.contains(verb.infinitiv)
      })
    }

    private func item(of question: QuizItem) -> PracticeItem {
      .exercised(by: question.conjugationgroup, of: question.verb, readingIndex: question.readingIndex)
    }

    @Test func answersAreRecordedAsGivenAndKeptOnQuit() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 11))
      quiz.start()
      let first = try #require(quiz.currentQuestion)
      quiz.submitAnswer(first.correctAnswer)
      let second = try #require(quiz.currentQuestion)
      quiz.submitAnswer("definitelywrong")
      quiz.continueAfterCorrection()

      quiz.quit()

      #expect(practice.record.entry(for: item(of: first))?.lastAnswered != nil)
      #expect(practice.record.entry(for: item(of: second))?.lastAnswerWasRight == false)
      #expect(practice.record.entries.count <= 2)
    }

    @Test func everyScopeWritesToTheRecord() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let machen = try #require(Verb.verbs["machen"])
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 3))
      quiz.start(scope: .verbPage(machen, readingIndex: 0))
      let question = try #require(quiz.currentQuestion)

      quiz.submitAnswer(question.correctAnswer)

      #expect(practice.record.entry(for: item(of: question))?.lastAnswerWasRight == true)
      quiz.quit()
    }

    @Test func dueItemsAreLimitedToTheLevelAndTheBandInTheRecordsOrder() throws {
      let verb = try strongBandVerb()
      let rare = try #require(Verb.verbs.values.sorted { $0.infinitiv < $1.infinitiv }.first { verb in
        verb.readings.count == 1 && QuizDraw.isStrong(verb.primaryReading) && !verb.isIn(.top1000)
      })
      let items: [PracticeItem] = [
        .keyConjugation(infinitiv: verb.infinitiv, readingIndex: 0, stem: .präteritum),
        .keyConjugation(infinitiv: rare.infinitiv, readingIndex: 0, stem: .präsens),
        .pattern(tableKey: "futur_indikativ", person: "fs"),
        .keyConjugation(infinitiv: verb.infinitiv, readingIndex: 0, stem: .präsens),
        .pattern(tableKey: "praesens_indikativ", person: "fs"),
        .pattern(tableKey: "perfekt_indikativ", person: "ts"),
        .pattern(tableKey: "imperativ", person: "sp")
      ]
      var generator = SeededRNG(seed: 5)

      let questions = QuizDraw.dueQuestions(for: items, pool: QuizLevel.elementary.pool, verbs: Quiz.defaultVerbs(for: .elementary), using: &generator)

      // Elementary asks the Präteritum only of sein, haben, and the modals, and no Futur; the rare
      // verb is beyond its band.
      #expect(questions.map(\.conjugationgroup) == [.präsensIndikativ(.thirdSingular), .präsensIndikativ(.firstSingular), .perfektIndikativ(.thirdSingular)])
      #expect(questions[0].verb == verb)
      #expect(questions.dropFirst().allSatisfy { question in
        question.verb.reading(at: question.readingIndex).map { !QuizDraw.isStrong($0) } == true
      })
      #expect(questions.map { PracticeItem.exercised(by: $0.conjugationgroup, of: $0.verb, readingIndex: $0.readingIndex) } == [items[3], items[4], items[5]])
    }

    @Test func aDefaultSessionMixesInDueItems() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let verb = try strongBandVerb()
      practice.recordAnswer(verb: verb, conjugationgroup: .präsensIndikativ(.secondSingular), readingIndex: 0, isCorrect: false, at: tenDaysAgo)
      Current.settings.quizLevel = .elementary

      for seed in UInt64(1)...5 {
        let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: seed))
        quiz.start()
        #expect(quiz.questions.count == Quiz.questionCount)
        #expect(quiz.questions.contains { $0.verb == verb && $0.conjugationgroup == .präsensIndikativ(.thirdSingular) })
        quiz.quit()
      }
    }

    @Test func aDefaultRoundTakesAtMostThreeDueItems() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let cells: [Conjugationgroup] = [.präsensIndikativ(.firstSingular), .präsensIndikativ(.secondSingular), .präsensIndikativ(.firstPlural), .perfektIndikativ(.firstSingular), .perfektIndikativ(.secondPlural)]
      let machen = try #require(Verb.verbs["machen"])
      for cell in cells {
        practice.recordAnswer(verb: machen, conjugationgroup: cell, readingIndex: 0, isCorrect: false, at: tenDaysAgo)
      }
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 9))

      quiz.start()

      #expect(quiz.questions.count == Quiz.questionCount)
      quiz.quit()
      var generator = SeededRNG(seed: 1)
      let due = QuizDraw.dueQuestions(for: practice.dueItems(), pool: QuizLevel.elementary.pool, verbs: Quiz.defaultVerbs(for: .elementary), using: &generator)
      #expect(due.count == QuizDraw.dueItemLimit)
    }

    @Test func aScopedQuizMixesInNothing() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let verb = try strongBandVerb()
      practice.recordAnswer(verb: verb, conjugationgroup: .präsensIndikativ(.secondSingular), readingIndex: 0, isCorrect: false, at: tenDaysAgo)
      let machen = try #require(Verb.verbs["machen"])

      for scope in [QuizScope.myVerbs([machen]), .verbPage(machen, readingIndex: 0)] {
        let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 2))
        quiz.start(scope: scope)
        #expect(quiz.questions.allSatisfy { $0.verb == machen })
        quiz.quit()
      }
      #expect(!QuizScope.myVerbs([machen]).mixesDueItems)
      #expect(QuizScope.allVerbs.mixesDueItems)
    }
  }
}
