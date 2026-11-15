// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("Speed Round")
struct SpeedRoundTests {
  private let calendar = Calendar.current
  private let now = Date(timeIntervalSince1970: 1_800_000_000)

  private func verb(_ infinitiv: String) throws -> Verb {
    try #require(Verb.verbs[infinitiv])
  }

  /// Right answers on two days, three or more apart, which reach the third box.
  private func master(_ items: [PracticeItem], in record: inout PracticeRecord) {
    for item in items {
      record.recordAnswer(item, isCorrect: true, at: now, calendar: calendar)
      record.recordAnswer(item, isCorrect: true, at: now.addingTimeInterval(4 * 86_400), calendar: calendar)
    }
  }

  private func item(of question: QuizDrawnQuestion) -> PracticeItem {
    PracticeItem.exercised(by: question.conjugationgroup, of: question.verb, readingIndex: question.readingIndex)
  }

  private var fiveItems: [PracticeItem] {
    [
      .pattern(of: .präsensIndikativ(.firstSingular)),
      .pattern(of: .präsensIndikativ(.secondSingular)),
      .pattern(of: .perfektIndikativ(.thirdSingular)),
      .keyConjugation(infinitiv: "kommen", readingIndex: 0, stem: .präsens),
      .keyConjugation(infinitiv: "gehen", readingIndex: 0, stem: .perfekt)
    ]
  }

  @Test func onlyTheThirdBoxAndAboveIsMastered() {
    let mastered = PracticeItem.pattern(of: .präsensIndikativ(.firstSingular))
    let learning = PracticeItem.pattern(of: .präsensIndikativ(.secondSingular))
    let missed = PracticeItem.pattern(of: .präsensIndikativ(.thirdSingular))
    var record = PracticeRecord()
    master([mastered], in: &record)
    record.recordAnswer(learning, isCorrect: true, at: now, calendar: calendar)
    record.recordAnswer(missed, isCorrect: false, at: now, calendar: calendar)
    record.recordLookup([.keyConjugation(infinitiv: "kommen", readingIndex: 0, stem: .präsens)], at: now, calendar: calendar)

    #expect(SpeedRound.masteredItems(in: record) == [mastered])
  }

  @Test func anItemThatCanNoLongerBeAskedIsNotMastered() {
    var record = PracticeRecord()
    master([.keyConjugation(infinitiv: "notaverb", readingIndex: 0, stem: .präsens), .pattern(tableKey: "notatable", person: nil)], in: &record)

    #expect(SpeedRound.masteredItems(in: record).isEmpty)
  }

  @Test func aRoundAsksOnlyMasteredItems() throws {
    let items = fiveItems
    var rng = SeededRNG(seed: 3)
    let questions = QuizDraw.speedRoundQuestions(for: items, pool: QuizLevel.elementary.pool, verbs: Quiz.defaultVerbs(for: .elementary), count: 30, using: &rng)

    #expect(questions.count == 30)
    #expect(questions.allSatisfy { items.contains(item(of: $0)) })
  }

  /// Each item is asked once before any is asked again, and none twice running, across a cycle's
  /// end and across batches.
  @Test func itemsComeRoundInTurnAndNeverTwiceRunning() throws {
    let items = fiveItems
    var rng = SeededRNG(seed: 8)
    let pool = QuizLevel.elementary.pool
    let verbs = Quiz.defaultVerbs(for: .elementary)
    let first = QuizDraw.speedRoundQuestions(for: items, pool: pool, verbs: verbs, count: 10, using: &rng).map(item)
    let last = try #require(first.last)
    let second = QuizDraw.speedRoundQuestions(for: items, pool: pool, verbs: verbs, count: 10, after: last, using: &rng).map(item)

    #expect(Set(first.prefix(5)).count == 5)
    #expect(Set(first.suffix(5)).count == 5)
    let sequence = first + second
    #expect(zip(sequence, sequence.dropFirst()).allSatisfy { $0 != $1 })
  }

  @Test func oneItemIsAskedOverAndOver() {
    var rng = SeededRNG(seed: 1)
    let questions = QuizDraw.speedRoundQuestions(for: [.pattern(of: .präsensIndikativ(.firstSingular))], pool: QuizLevel.beginner.pool, verbs: Quiz.defaultVerbs(for: .beginner), count: 4, using: &rng)

    #expect(questions.count == 4)
  }

  @Test func nothingMasteredAsksNothing() {
    var rng = SeededRNG(seed: 1)
    #expect(QuizDraw.speedRoundQuestions(for: [], pool: QuizLevel.beginner.pool, verbs: Quiz.defaultVerbs(for: .beginner), count: 10, using: &rng).isEmpty)
  }

  /// A pattern comes back with a fresh weak verb from the band, so that it is the pattern, not one
  /// verb's conjugation, that is practiced.
  @Test func aPatternAsksWeakVerbsOfTheBand() throws {
    var rng = SeededRNG(seed: 4)
    let band = Quiz.defaultVerbs(for: .beginner)
    let questions = QuizDraw.speedRoundQuestions(for: [.pattern(of: .präteritumIndikativ(.firstSingular))], pool: QuizLevel.beginner.pool, verbs: band, count: 10, using: &rng)
    let bandInfinitives = Set(band.map(\.infinitiv))

    #expect(questions.allSatisfy { $0.conjugationgroup == .präteritumIndikativ(.firstSingular) })
    #expect(questions.allSatisfy { bandInfinitives.contains($0.verb.infinitiv) })
    #expect(questions.allSatisfy { !QuizDraw.isStrong($0.verb.readings[$0.readingIndex]) })
    #expect(Set(questions.map(\.verb.infinitiv)).count > 1)
  }

  /// Mastered fuhr asks any Präteritum cell the level asks of fahren, or er fuhr itself where the
  /// level asks none, as Elementary asks the Präteritum only of sein, haben, and the modals.
  @Test func aKeyConjugationAsksTheCellsOfItsStemThatTheLevelAsks() throws {
    let kommen = try verb("kommen")
    let reading = kommen.primaryReading

    #expect(QuizDraw.speedRoundCells(of: .präteritum, verb: kommen, reading: reading, pool: QuizLevel.elementary.pool) == [.präteritumIndikativ(.thirdSingular)])

    let intermediate = QuizDraw.speedRoundCells(of: .präteritum, verb: kommen, reading: reading, pool: QuizLevel.intermediate.pool)
    #expect(intermediate.contains(.präteritumIndikativ(.secondSingular)))
    #expect(intermediate.contains(.präteritumIndikativ(.firstPlural)))
    #expect(intermediate.allSatisfy { PracticeItem.Stem($0.table) == .präteritum })
    #expect(intermediate.filter { $0 == .präteritumIndikativ(.thirdSingular) }.count == 1)

    let perfekt = QuizDraw.speedRoundCells(of: .perfekt, verb: kommen, reading: reading, pool: QuizLevel.elementary.pool)
    #expect(perfekt.contains(.perfektIndikativ(.firstSingular)))
    #expect(perfekt.contains(.perfektpartizip))
  }

  @Test func theScopeIsNeitherRankedNorContinuedAndSendsNoCounts() {
    let scope = QuizScope.speedRound()

    #expect(scope.isSpeedRound)
    #expect(!scope.isRanked)
    #expect(!scope.continues)
    #expect(!scope.mixesDueItems)
    #expect(!scope.mixesChoiceQuestions)
    #expect(!scope.sendsQuestionCounts)
    #expect(scope.source == .speedRound)
    #expect(LastQuizResult.Kind(scope: scope) == .speedRound)
  }

  @Test func theBestIsKeptAcrossALaunchAndForgottenByReset() {
    let getterSetter = GetterSetterFake()
    let practice = PracticeStore(getterSetter: getterSetter)
    #expect(practice.speedRoundBest == nil)

    #expect(!practice.recordSpeedRound(0))
    #expect(practice.speedRoundBest == nil)
    #expect(practice.recordSpeedRound(12))
    #expect(!practice.recordSpeedRound(12))
    #expect(!practice.recordSpeedRound(9))
    #expect(PracticeStore(getterSetter: getterSetter).speedRoundBest == 12)

    practice.reset()
    #expect(practice.speedRoundBest == nil)
    #expect(PracticeStore(getterSetter: getterSetter).speedRoundBest == nil)
  }
}

extension QuizTests {
  @MainActor
  @Suite("A Speed Round in a quiz")
  struct SpeedRoundQuizTests {
    private let calendar = Calendar.current

    /// A store whose record has these items mastered. The unit-test world's store is shared, so
    /// each test puts back an empty one with `defer`.
    @discardableResult
    private func practice(mastering items: [PracticeItem]) throws -> PracticeStore {
      var record = PracticeRecord()
      let start = Date.now.addingTimeInterval(-10 * 86_400)
      for item in items {
        record.recordAnswer(item, isCorrect: true, at: start, calendar: calendar)
        record.recordAnswer(item, isCorrect: true, at: start.addingTimeInterval(4 * 86_400), calendar: calendar)
      }
      let getterSetter = GetterSetterFake()
      getterSetter.set(key: PracticeRecord.storageKey, value: try #require(record.json))
      let practice = PracticeStore(getterSetter: getterSetter)
      Current.practice = practice
      return practice
    }

    private var items: [PracticeItem] {
      [
        .pattern(of: .präsensIndikativ(.firstSingular)),
        .pattern(of: .präsensIndikativ(.thirdSingular)),
        .pattern(of: .perfektIndikativ(.firstSingular)),
        .keyConjugation(infinitiv: "kommen", readingIndex: 0, stem: .präsens),
        .keyConjugation(infinitiv: "geben", readingIndex: 0, stem: .perfekt)
      ]
    }

    /// The clock is driven by `clockTicked()`, so the real timer is set never to fire.
    private func started() -> Quiz {
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(timerInterval: 10_000, randomSource: SeededRNG(seed: 21))
      quiz.start(scope: .speedRound())
      return quiz
    }

    private func tick(_ quiz: Quiz, seconds: Int) {
      for _ in 0..<seconds {
        quiz.clockTicked()
      }
    }

    @Test func nothingMasteredStartsNothing() throws {
      try practice(mastering: [])
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()

      #expect(!quiz.isInProgress)
    }

    @Test func aRightAnswerCountsAndAMissMovesOnAtOnce() throws {
      try practice(mastering: items)
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      let first = try #require(quiz.currentQuestion)

      quiz.submitAnswer(first.correctAnswer)
      #expect(quiz.correctCount == 1)
      #expect(quiz.currentIndex == 1)
      #expect(quiz.speedRoundMiss == nil)

      let second = try #require(quiz.currentQuestion)
      quiz.submitAnswer("definitelywrong")
      #expect(quiz.correction == nil)
      #expect(!quiz.isHeld)
      #expect(!quiz.isAwaitingSecondAttempt)
      #expect(quiz.currentIndex == 2)
      #expect(quiz.speedRoundMiss?.id == second.id)
      #expect(quiz.reaskCount == 0)

      quiz.submitAnswer(try #require(quiz.currentQuestion).correctAnswer)
      #expect(quiz.speedRoundMiss == nil)
      #expect(quiz.correctCount == 2)
      quiz.quit()
    }

    /// A slip is no second attempt in a Speed Round: it is a miss.
    @Test func aSlipIsAMiss() throws {
      try practice(mastering: items)
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      let question = try #require(quiz.currentQuestion)
      quiz.submitAnswer(String(question.correctAnswer.dropLast()))

      #expect(quiz.questions[0].isCorrect == false)
      #expect(quiz.currentIndex == 1)
      quiz.quit()
    }

    @Test func theRecordAndTheErrorHistoryAreUntouched() throws {
      let practice = try practice(mastering: items)
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let before = practice.record
      let errorsBefore = QuizErrorHistory.load(getterSetter: Current.getterSetter).count
      let quiz = started()
      for index in 0..<6 {
        let question = try #require(quiz.currentQuestion)
        quiz.submitAnswer(index.isMultiple(of: 2) ? question.correctAnswer : "definitelywrong")
      }
      quiz.quit()

      #expect(practice.record == before)
      #expect(QuizErrorHistory.load(getterSetter: Current.getterSetter).count == errorsBefore)
    }

    @Test func everyQuestionIsAMasteredItem() throws {
      try practice(mastering: items)
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      for _ in 0..<25 {
        quiz.submitAnswer(try #require(quiz.currentQuestion).correctAnswer)
      }

      #expect(quiz.isInProgress)
      #expect(quiz.questions.count > 25)
      #expect(quiz.questions.allSatisfy { question in
        items.contains(PracticeItem.exercised(by: question.conjugationgroup, of: question.verb, readingIndex: question.readingIndex))
      })
      quiz.quit()
    }

    /// The minute ends the round, drops the question left unanswered, and keeps a new best.
    @Test func sixtySecondsEndTheRoundAndKeepTheBest() throws {
      let practice = try practice(mastering: items)
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      for index in 0..<4 {
        let question = try #require(quiz.currentQuestion)
        quiz.submitAnswer(index == 1 ? "definitelywrong" : question.correctAnswer)
      }
      tick(quiz, seconds: SpeedRound.duration - 1)
      #expect(quiz.isInProgress)
      #expect(quiz.speedRoundSecondsLeft == 1)

      tick(quiz, seconds: 1)
      #expect(!quiz.isInProgress)
      #expect(quiz.shouldShowResults)
      #expect(quiz.questions.count == 4)
      #expect(quiz.correctCount == 3)
      #expect(quiz.questionCount == 4)
      #expect(quiz.isNewSpeedRoundBest)
      #expect(quiz.speedRoundPreviousBest == nil)
      #expect(practice.speedRoundBest == 3)
      #expect(!quiz.canContinue)

      let result = try #require(practice.lastResult)
      #expect(result.kind == .speedRound)
      #expect(result.correctCount == 3)
      #expect(result.title == L.SpeedRound.title)

      quiz.start(scope: .speedRound())
      quiz.submitAnswer(try #require(quiz.currentQuestion).correctAnswer)
      tick(quiz, seconds: SpeedRound.duration)
      #expect(!quiz.isNewSpeedRoundBest)
      #expect(quiz.speedRoundPreviousBest == 3)
      #expect(practice.speedRoundBest == 3)
    }

    @Test func aRoundPostsNoScoreAndSendsNoCounts() throws {
      try practice(mastering: items)
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let spy = Current.analytics as! AnalyticsSpy
      let gameCenter = Current.gameCenter as! GameCenterSpy
      let initialSignals = spy.signalNames.count
      let initialScores = gameCenter.submissions.count

      let quiz = started()
      quiz.submitAnswer(try #require(quiz.currentQuestion).correctAnswer)
      tick(quiz, seconds: SpeedRound.duration)
      let quitter = started()
      quitter.submitAnswer("definitelywrong")
      quitter.quit()

      let signals = Array(zip(spy.signalNames, spy.signalParameters).dropFirst(initialSignals))
      let start = try #require(signals.first { $0.0 == .startQuiz }?.1)
      let complete = try #require(signals.first { $0.0 == .completeQuiz }?.1)
      let quit = try #require(signals.first { $0.0 == .quitQuiz }?.1)
      #expect(start[ParameterKey.source.rawValue] == AnalyticsSource.speedRound.rawValue)
      #expect(complete[ParameterKey.questionCount.rawValue] == nil)
      #expect(quit[ParameterKey.questionNumber.rawValue] == nil)
      #expect(gameCenter.submissions.count == initialScores)
    }

    @Test func pausingStopsTheClock() throws {
      try practice(mastering: items)
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      tick(quiz, seconds: 20)
      quiz.pauseTimer()
      quiz.resumeTimer()

      #expect(quiz.speedRoundSecondsLeft == 40)
      #expect(quiz.isInProgress)
      quiz.quit()
    }
  }
}
