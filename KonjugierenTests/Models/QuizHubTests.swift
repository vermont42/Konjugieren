// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("The practice hub's last result")
struct QuizHubTests {
  private let date = Date(timeIntervalSinceReferenceDate: 816_303_588)

  private var sample: LastQuizResult {
    LastQuizResult(kind: .verbPage, subject: "fahren", level: .elementary, score: 25, correctCount: 2, secondAttemptCount: 1, questionCount: 3, date: date)
  }

  // A stored result must keep decoding after an update, so its form is pinned.
  @Test func storedFormIsPinned() throws {
    let json = #"{"kind":"allVerbs","levelKey":"intermediate","score":75,"correctCount":7,"secondAttemptCount":1,"questionCount":10,"date":816303588}"#
    let result = try JSONDecoder().decode(LastQuizResult.self, from: Data(json.utf8))

    #expect(result == LastQuizResult(kind: .allVerbs, level: .intermediate, score: 75, correctCount: 7, secondAttemptCount: 1, questionCount: 10, date: date))
  }

  @Test func roundTrips() throws {
    let data = try JSONEncoder().encode(sample)
    #expect(try JSONDecoder().decode(LastQuizResult.self, from: data) == sample)
  }

  @Test func anUnknownLevelReadsAsNone() {
    let result = LastQuizResult(kind: .review, level: nil, score: 0, correctCount: 0, secondAttemptCount: 0, questionCount: 1, date: date)
    #expect(result.level == nil)
    #expect(sample.level == .elementary)
  }

  @Test func eachScopeHasItsKind() throws {
    let fahren = try #require(Verb.verbs["fahren"])
    let custom = CustomQuiz(tables: [.präteritumIndikativ])
    let practiceSet = PracticeSet(custom: custom, level: .beginner)

    #expect(LastQuizResult.Kind(scope: .allVerbs) == .allVerbs)
    #expect(LastQuizResult.Kind(scope: .myVerbs([fahren])) == .myVerbs)
    #expect(LastQuizResult.Kind(scope: .verbPage(fahren, readingIndex: 0)) == .verbPage)
    #expect(LastQuizResult.Kind(scope: .collection(.modals)) == .collection)
    #expect(LastQuizResult.Kind(scope: .custom(custom, myVerbs: [])) == .custom)
    #expect(LastQuizResult.Kind(scope: .custom(CustomQuiz(verbSet: .collection(.modals)), myVerbs: [])) == .custom)
    #expect(LastQuizResult.Kind(scope: practiceSet.scope(source: .sharedLink)) == .practiceSet)
    #expect(LastQuizResult.Kind(scope: practiceSet.scope(source: .qrCode)) == .practiceSet)
    #expect(LastQuizResult.Kind(scope: .recordSession(.review)) == .review)
    #expect(LastQuizResult.Kind(scope: .recordSession(.mistakes)) == .mistakes)
  }

  @Test func titlesNameTheVerbOrCollection() {
    let collection = LastQuizResult(kind: .collection, subject: VerbCollection.modals.key, level: .beginner, score: 0, correctCount: 0, secondAttemptCount: 0, questionCount: 10, date: date)

    #expect(sample.title == "fahren")
    #expect(collection.title == VerbCollection.modals.title)
  }

  @Test func theStoreKeepsTheResultAcrossALaunch() {
    let getterSetter = GetterSetterFake()
    PracticeStore(getterSetter: getterSetter).recordResult(sample)

    #expect(PracticeStore(getterSetter: getterSetter).lastResult == sample)
  }

  @Test func resetForgetsTheResult() {
    let getterSetter = GetterSetterFake()
    let practice = PracticeStore(getterSetter: getterSetter)
    practice.recordResult(sample)
    practice.reset()

    #expect(practice.lastResult == nil)
    #expect(PracticeStore(getterSetter: getterSetter).lastResult == nil)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("The last result, kept by quizzes")
  struct LastResultTests {
    /// A fresh store for the test, since the unit-test world's is shared. Each test puts back an
    /// empty one with `defer`.
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func started(_ scope: QuizScope = .allVerbs, level: QuizLevel = .intermediate) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 11))
      quiz.start(scope: scope)
      return quiz
    }

    /// Answers the first question wrongly and the rest rightly, re-ask included.
    private func finishMissingFirst(_ quiz: Quiz) throws {
      var isFirst = true
      while quiz.isInProgress {
        let question = try #require(quiz.currentQuestion)
        quiz.submitAnswer(isFirst ? "definitelywrong" : question.correctAnswer)
        isFirst = false
        if quiz.correction != nil {
          quiz.continueAfterCorrection()
        }
      }
    }

    @Test func aFinishedQuizKeepsItsResult() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      try finishMissingFirst(quiz)

      let result = try #require(practice.lastResult)
      #expect(result.kind == .allVerbs)
      #expect(result.level == .intermediate)
      #expect(result.correctCount == Quiz.questionCount - 1)
      #expect(result.questionCount == Quiz.questionCount)
      #expect(result.score == quiz.score)
      #expect(Date.now.timeIntervalSince(result.date) < 60)
    }

    @Test func tenMoreReplacesItWithTheSessionSoFar() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      try finishMissingFirst(quiz)
      quiz.continueSession()
      try finishMissingFirst(quiz)

      let result = try #require(practice.lastResult)
      #expect(result.questionCount == 2 * Quiz.questionCount)
      #expect(result.correctCount == 2 * Quiz.questionCount - 2)
      #expect(result.score == quiz.score)
    }

    @Test func aQuitQuizKeepsNothing() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      let question = try #require(quiz.currentQuestion)
      quiz.submitAnswer(question.correctAnswer)
      quiz.quit()

      #expect(practice.lastResult == nil)
    }

    @Test func aRecordSessionKeepsNoLevel() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let verb = try #require(Verb.verbs["singen"])
      practice.recordAnswer(verb: verb, conjugationgroup: .präteritumIndikativ(.firstSingular), readingIndex: 0, isCorrect: false)
      let quiz = started(.recordSession(.mistakes))
      try finishMissingFirst(quiz)

      let result = try #require(practice.lastResult)
      #expect(result.kind == .mistakes)
      #expect(result.level == nil)
    }

    @Test func aVerbPageQuizNamesItsVerb() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let verb = try #require(Verb.verbs["fahren"])
      let quiz = started(.verbPage(verb, readingIndex: 0))
      try finishMissingFirst(quiz)

      let result = try #require(practice.lastResult)
      #expect(result.kind == .verbPage)
      #expect(result.subject == "fahren")
      #expect(result.questionCount == QuizScope.verbPageQuestionCount)
    }
  }
}
