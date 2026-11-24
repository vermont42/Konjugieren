// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

@MainActor
@Suite("Review and My Mistakes")
struct QuizRecordSessionTests {
  private let now = Date.now
  private let calendar = Calendar.current

  private func daysAgo(_ days: Double) -> Date {
    now.addingTimeInterval(-days * 86_400)
  }

  /// Strong verbs with one reading, sorted, so that each has exactly three key conjugations.
  static func strongVerbs(_ count: Int) -> [Verb] {
    Array(Verb.verbs.values
      .filter { $0.readings.count == 1 && QuizDraw.isStrong($0.primaryReading) }
      .sorted { $0.infinitiv < $1.infinitiv }
      .prefix(count))
  }

  @Test func missedItemsAreTheLastWrongAnswersMostRecentFirst() {
    var record = PracticeRecord()
    let first = PracticeItem.pattern(tableKey: "praesens_indikativ", person: "fs")
    let second = PracticeItem.pattern(tableKey: "praeteritum_indikativ", person: "ss")
    let rightOnly = PracticeItem.pattern(tableKey: "perfekt_indikativ", person: "ts")
    let repaired = PracticeItem.keyConjugation(infinitiv: "singen", readingIndex: 0, stem: .präteritum)
    record.recordAnswer(first, isCorrect: false, at: daysAgo(3), calendar: calendar)
    record.recordAnswer(second, isCorrect: false, at: daysAgo(1), calendar: calendar)
    record.recordAnswer(rightOnly, isCorrect: true, at: daysAgo(2), calendar: calendar)
    record.recordAnswer(repaired, isCorrect: false, at: daysAgo(4), calendar: calendar)
    record.recordAnswer(repaired, isCorrect: true, at: daysAgo(0.5), calendar: calendar)
    record.recordLookup([.keyConjugation(infinitiv: "fahren", readingIndex: 0, stem: .präsens)], at: now, calendar: calendar)

    #expect(record.missedItems() == [second, first])
  }

  @Test func theNextDueDateIsCountedInDays() throws {
    let practice = PracticeStore(getterSetter: GetterSetterFake())
    #expect(practice.daysUntilNextDue(at: now) == nil)
    let machen = try #require(Verb.verbs["machen"])

    practice.recordAnswer(verb: machen, conjugationgroup: .präsensIndikativ(.firstSingular), readingIndex: 0, isCorrect: true, at: now)
    #expect(practice.daysUntilNextDue(at: now) == ReviewSchedule.intervals[1])

    practice.recordAnswer(verb: machen, conjugationgroup: .präsensIndikativ(.secondSingular), readingIndex: 0, isCorrect: false, at: now)
    #expect(practice.daysUntilNextDue(at: now) == 1)
  }

  @Test func aSessionAsksBeyondTheLevelsPoolAndBand() throws {
    let rare = try #require(Verb.verbs.values.sorted { $0.infinitiv < $1.infinitiv }.first { verb in
      verb.readings.count == 1 && QuizDraw.isStrong(verb.primaryReading) && !verb.isIn(.top1000)
    })
    let band = Quiz.defaultVerbs(for: .beginner)
    let items: [PracticeItem] = [
      .keyConjugation(infinitiv: rare.infinitiv, readingIndex: 0, stem: .präteritum),
      .pattern(tableKey: "futur_konjunktiv_ii", person: "sp")
    ]
    var generator = SeededRNG(seed: 4)

    let questions = QuizDraw.sessionQuestions(for: items, verbs: band, using: &generator)

    #expect(questions.map(\.conjugationgroup) == [.präteritumIndikativ(.thirdSingular), .futurKonjunktivII(.secondPlural)])
    #expect(questions[0].verb == rare)
    let weak = questions[1]
    #expect(band.contains(weak.verb))
    #expect(weak.verb.reading(at: weak.readingIndex).map { !QuizDraw.isStrong($0) } == true)
  }

  @Test func aVerbsKeyConjugationsSitTogetherInTheirOrder() throws {
    let verbs = Self.strongVerbs(2)
    let pattern = PracticeItem.pattern(tableKey: "praesens_indikativ", person: "fs")
    let items: [PracticeItem] = [
      .keyConjugation(infinitiv: verbs[0].infinitiv, readingIndex: 0, stem: .perfekt),
      pattern,
      .keyConjugation(infinitiv: verbs[1].infinitiv, readingIndex: 0, stem: .präsens),
      .keyConjugation(infinitiv: verbs[0].infinitiv, readingIndex: 0, stem: .präsens)
    ]
    var generator = SeededRNG(seed: 2)

    let questions = QuizDraw.sessionQuestions(for: items, verbs: Quiz.defaultVerbs(for: .elementary), using: &generator)

    #expect(questions.map(\.conjugationgroup) == [
      .präsensIndikativ(.thirdSingular),
      .perfektIndikativ(.thirdSingular),
      .präsensIndikativ(.firstSingular),
      .präsensIndikativ(.thirdSingular)
    ])
    #expect(questions.map(\.verb.infinitiv)[0] == verbs[0].infinitiv)
    #expect(questions.map(\.verb.infinitiv)[1] == verbs[0].infinitiv)
    #expect(questions.map(\.verb.infinitiv)[3] == verbs[1].infinitiv)
  }

  @Test func aSessionSkipsExcludedAndUnaskableItemsAndStopsAtItsLimit() {
    let unknown = PracticeItem.keyConjugation(infinitiv: "zzzunknown", readingIndex: 0, stem: .präsens)
    let unreadable = PracticeItem.pattern(tableKey: "no_such_table", person: "fs")
    let cells = ConjugationTable.präsensIndikativ.cells + ConjugationTable.präteritumIndikativ.cells
    let patterns = cells.map(PracticeItem.pattern(of:))
    var generator = SeededRNG(seed: 8)

    let questions = QuizDraw.sessionQuestions(
      for: [unknown, unreadable] + patterns,
      verbs: Quiz.defaultVerbs(for: .elementary),
      excluded: [patterns[0].key],
      using: &generator
    )

    #expect(!unknown.isAskable)
    #expect(!unreadable.isAskable)
    #expect(patterns.allSatisfy { $0.isAskable })
    #expect(questions.map(\.conjugationgroup) == Array(cells.dropFirst().prefix(Quiz.questionCount)))
  }

  @Test func aRecordSessionIsNeverRankedAndMixesInNothing() {
    for session in QuizRecordSession.allCases {
      let scope = QuizScope.recordSession(session)
      #expect(!scope.isRanked)
      #expect(!scope.mixesDueItems)
      #expect(!scope.sendsQuestionCounts)
      #expect(scope.continues)
      #expect(scope.source == session.source)
    }
    #expect(QuizScope.allVerbs.sendsQuestionCounts)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Record sessions")
  struct RecordSessionTests {
    /// A fresh record for the test, since the unit-test world's is shared. Each test puts back an
    /// empty one with `defer`.
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func daysAgo(_ days: Double) -> Date {
      Date.now.addingTimeInterval(-days * 86_400)
    }

    private func started(_ session: QuizRecordSession, seed: UInt64 = 3) -> Quiz {
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: seed))
      quiz.start(scope: .recordSession(session))
      return quiz
    }

    private func finish(_ quiz: Quiz, correctly: Bool) throws {
      while quiz.isInProgress {
        let question = try #require(quiz.currentQuestion)
        quiz.submitAnswer(correctly ? question.correctAnswer : "definitelywrong")
        if quiz.correction != nil {
          quiz.continueAfterCorrection()
        }
      }
    }

    private var spy: AnalyticsSpy {
      Current.analytics as! AnalyticsSpy
    }

    private func signals(since count: Int) -> [(AnalyticsName, [String: String])] {
      Array(zip(spy.signalNames, spy.signalParameters).dropFirst(count))
    }

    @Test func reviewAsksTheMostOverdueTenThenTheRest() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let verbs = QuizRecordSessionTests.strongVerbs(4)
      for (index, verb) in verbs.enumerated() {
        for cell in [Conjugationgroup.präsensIndikativ(.firstSingular), .präteritumIndikativ(.firstSingular), .perfektpartizip] {
          practice.recordAnswer(verb: verb, conjugationgroup: cell, readingIndex: 0, isCorrect: false, at: daysAgo(Double(20 - index)))
        }
      }
      #expect(QuizRecordSession.review.askableCount(from: practice) == 12)

      let quiz = started(.review)

      #expect(quiz.questions.count == Quiz.questionCount)
      #expect(quiz.questions.prefix(9).map(\.verb.infinitiv) == verbs.prefix(3).flatMap { Array(repeating: $0.infinitiv, count: 3) })
      #expect(quiz.questions.prefix(3).map(\.conjugationgroup) == [.präsensIndikativ(.thirdSingular), .präteritumIndikativ(.thirdSingular), .perfektIndikativ(.thirdSingular)])
      try finish(quiz, correctly: true)
      #expect(quiz.canContinue)

      quiz.continueSession()

      #expect(quiz.questions.count == 12)
      #expect(quiz.questions.dropFirst(10).allSatisfy { $0.verb == verbs[3] })
      #expect(quiz.questionCount == 12)
      try finish(quiz, correctly: true)
      #expect(!quiz.canContinue)
      #expect(practice.dueItems().isEmpty)
    }

    @Test func aShortReviewAsksWhatIsDueAndDoesNotContinue() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let machen = try #require(Verb.verbs["machen"])
      for cell in [Conjugationgroup.präsensIndikativ(.firstSingular), .perfektIndikativ(.secondPlural)] {
        practice.recordAnswer(verb: machen, conjugationgroup: cell, readingIndex: 0, isCorrect: false, at: daysAgo(5))
      }
      practice.recordAnswer(verb: machen, conjugationgroup: .präsensIndikativ(.secondSingular), readingIndex: 0, isCorrect: false, at: .now)

      let quiz = started(.review)

      // Equal due dates fall back to the key, so perfekt_indikativ comes first.
      #expect(quiz.questions.map(\.conjugationgroup) == [.perfektIndikativ(.secondPlural), .präsensIndikativ(.firstSingular)])
      #expect(quiz.questionCount == 2)
      try finish(quiz, correctly: true)
      #expect(quiz.shouldShowResults)
      #expect(!quiz.canContinue)
    }

    @Test func anEmptyRecordStartsNoSession() {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }

      for session in QuizRecordSession.allCases {
        let quiz = started(session)
        #expect(!quiz.isInProgress)
        #expect(quiz.questions.isEmpty)
      }
    }

    @Test func aMistakeLeavesOnceAnsweredRight() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let machen = try #require(Verb.verbs["machen"])
      practice.recordAnswer(verb: machen, conjugationgroup: .präteritumIndikativ(.firstPlural), readingIndex: 0, isCorrect: false, at: daysAgo(2))
      practice.recordAnswer(verb: machen, conjugationgroup: .perfektpartizip, readingIndex: 0, isCorrect: false, at: daysAgo(1))
      practice.recordAnswer(verb: machen, conjugationgroup: .präsensIndikativ(.firstSingular), readingIndex: 0, isCorrect: true, at: daysAgo(1))

      let quiz = started(.mistakes)

      #expect(quiz.questions.map(\.conjugationgroup) == [.perfektpartizip, .präteritumIndikativ(.firstPlural)])
      try finish(quiz, correctly: true)
      #expect(practice.missedItems().isEmpty)
      #expect(!quiz.canContinue)
    }

    @Test func aMistakeMissedAgainStaysButIsNotAskedAgainInTheSession() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let machen = try #require(Verb.verbs["machen"])
      practice.recordAnswer(verb: machen, conjugationgroup: .präteritumIndikativ(.firstPlural), readingIndex: 0, isCorrect: false, at: daysAgo(1))

      let quiz = started(.mistakes)
      try finish(quiz, correctly: false)

      // The question and its one re-ask.
      #expect(quiz.questions.count == 2)
      #expect(practice.missedItems() == [.pattern(tableKey: "praeteritum_indikativ", person: "fp")])
      #expect(!quiz.canContinue)
    }

    @Test func recordSessionsSendNoCountsAndPostNoScore() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let machen = try #require(Verb.verbs["machen"])
      practice.recordAnswer(verb: machen, conjugationgroup: .präsensIndikativ(.firstSingular), readingIndex: 0, isCorrect: false, at: daysAgo(5))
      practice.recordAnswer(verb: machen, conjugationgroup: .präsensIndikativ(.secondSingular), readingIndex: 0, isCorrect: false, at: daysAgo(5))
      let gameCenter = Current.gameCenter as! GameCenterSpy
      let submissions = gameCenter.submissions.count

      for session in QuizRecordSession.allCases {
        let before = spy.signalNames.count
        let quiz = started(session)
        let inProgress = QuizAbandonment.entries(getterSetter: Current.getterSetter).values
        #expect(inProgress.contains { $0.source == session.source.rawValue && $0.questionNumber == nil })
        quiz.quit()
        let quizRecordSessionSignals = signals(since: before)
        let start = try #require(quizRecordSessionSignals.first { $0.0 == .startQuiz })
        #expect(start.1[ParameterKey.source.rawValue] == session.source.rawValue)
        let quit = try #require(quizRecordSessionSignals.first { $0.0 == .quitQuiz })
        #expect(quit.1[ParameterKey.questionNumber.rawValue] == nil)
        #expect(quit.1[ParameterKey.source.rawValue] == session.source.rawValue)
      }

      let before = spy.signalNames.count
      let quiz = started(.mistakes)
      try finish(quiz, correctly: true)
      let complete = try #require(signals(since: before).first { $0.0 == .completeQuiz })
      #expect(complete.1[ParameterKey.questionCount.rawValue] == nil)
      #expect(complete.1[ParameterKey.source.rawValue] == "mistakes")
      #expect(gameCenter.submissions.count == submissions)
    }
  }
}
