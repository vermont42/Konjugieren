// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Rounds and re-asks")
  struct RoundTests {
    private func startedQuiz(scope: QuizScope = .allVerbs, seed: UInt64 = 7) -> Quiz {
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: seed))
      quiz.start(scope: scope)
      return quiz
    }

    private func answerRight(_ quiz: Quiz) {
      quiz.submitAnswer(quiz.currentQuestion!.correctAnswer)
    }

    private func miss(_ quiz: Quiz) {
      quiz.submitAnswer("definitelywrong")
      quiz.continueAfterCorrection()
    }

    private func finishRight(_ quiz: Quiz) {
      while quiz.isInProgress {
        answerRight(quiz)
      }
    }

    private func signals(since count: Int) -> [(AnalyticsName, [String: String])] {
      let spy = Current.analytics as! AnalyticsSpy
      return Array(zip(spy.signalNames, spy.signalParameters).dropFirst(count))
    }

    private var signalCount: Int {
      (Current.analytics as! AnalyticsSpy).signalNames.count
    }

    @Test func aMissedQuestionReturnsAFewQuestionsLater() {
      let quiz = startedQuiz()
      let missed = quiz.questions[0]
      quiz.submitAnswer("definitelywrong")

      #expect(quiz.questions.count == Quiz.questionCount + 1)
      #expect(quiz.correction?.willBeReasked == true)
      let reask = quiz.questions[1 + Quiz.reaskGap]
      #expect(reask.isReask)
      #expect(reask.id != missed.id)
      #expect(reask.verb.infinitiv == missed.verb.infinitiv)
      #expect(reask.conjugationgroup == missed.conjugationgroup)
      #expect(reask.readingIndex == missed.readingIndex)
      #expect(reask.state == .unanswered)
      #expect(quiz.questions.filter(\.isReask).count == 1)

      quiz.quit()
    }

    @Test func aQuestionMissedNearTheEndReturnsBeforeTheResults() {
      let quiz = startedQuiz()
      for _ in 0..<(Quiz.questionCount - 1) {
        answerRight(quiz)
      }
      miss(quiz)

      #expect(quiz.isInProgress)
      #expect(!quiz.shouldShowResults)
      #expect(quiz.currentQuestion?.isReask == true)
      #expect(quiz.questions.count == Quiz.questionCount + 1)

      answerRight(quiz)

      #expect(quiz.shouldShowResults)
    }

    @Test func aMissedReaskDoesNotReturnAgain() {
      let quiz = startedQuiz()
      miss(quiz)
      for _ in 0..<Quiz.reaskGap {
        answerRight(quiz)
      }
      #expect(quiz.currentQuestion?.isReask == true)
      quiz.submitAnswer("definitelywrong")

      #expect(quiz.correction?.willBeReasked == false)
      #expect(quiz.questions.count == Quiz.questionCount + 1)

      quiz.continueAfterCorrection()
      finishRight(quiz)

      #expect(quiz.reaskCount == 1)
      #expect(quiz.reaskCorrectCount == 0)
    }

    @Test func aRightReaskEarnsHalfPointsAndCountsApart() {
      let quiz = startedQuiz()
      miss(quiz)
      finishRight(quiz)

      #expect(quiz.correctCount == Quiz.questionCount - 1)
      #expect(quiz.secondAttemptCount == 0)
      #expect(quiz.reaskCount == 1)
      #expect(quiz.reaskCorrectCount == 1)
      #expect(quiz.score == (Quiz.questionCount - 1) * Quiz.pointsPerCorrect + Quiz.pointsPerSecondAttempt)
      #expect(quiz.maximumScore == Quiz.questionCount * Quiz.pointsPerCorrect + Quiz.pointsPerSecondAttempt)
      #expect(quiz.firstRoundScore == (Quiz.questionCount - 1) * Quiz.pointsPerCorrect)
    }

    @Test func aVerbPageQuizReasksToo() {
      let quiz = startedQuiz(scope: .verbPage(Verb.verbs["gehen"]!, readingIndex: 0))
      miss(quiz)

      #expect(quiz.questions.count == QuizScope.verbPageQuestionCount + 1)
      #expect(quiz.questions.last?.isReask == true)

      quiz.quit()
    }

    @Test func tenMoreContinuesTheSameSession() {
      let quiz = startedQuiz()
      miss(quiz)
      finishRight(quiz)
      let firstRound = quiz.questions.map(\.id)
      let scoreAfterFirstRound = quiz.score
      let firstRoundScore = quiz.firstRoundScore

      #expect(quiz.canContinue)
      quiz.continueSession()

      #expect(quiz.isInProgress)
      #expect(!quiz.shouldShowResults)
      #expect(quiz.roundCount == 2)
      #expect(quiz.questionCount == Quiz.questionCount * 2)
      #expect(quiz.questions.count == firstRound.count + Quiz.questionCount)
      #expect(Array(quiz.questions.prefix(firstRound.count).map(\.id)) == firstRound)
      #expect(quiz.currentIndex == firstRound.count)
      #expect(quiz.score == scoreAfterFirstRound)

      finishRight(quiz)

      #expect(quiz.shouldShowResults)
      #expect(quiz.score == scoreAfterFirstRound + Quiz.questionCount * Quiz.pointsPerCorrect)
      #expect(quiz.correctCount == Quiz.questionCount * 2 - 1)
      #expect(quiz.firstRoundScore == firstRoundScore)
    }

    @Test func eachRoundOfTenMoreIsMixedLikeTheFirst() {
      let quiz = startedQuiz(seed: 19)
      finishRight(quiz)
      quiz.continueSession()

      let secondRound = quiz.questions.suffix(Quiz.questionCount)
      let strong = secondRound.filter { QuizDraw.isStrong($0.verb.reading(at: $0.readingIndex) ?? $0.verb.primaryReading) }
      #expect(strong.count == Quiz.questionCount / 2)

      quiz.quit()
    }

    @Test func twoRoundsOfTenMoreReachThirty() {
      let quiz = startedQuiz()
      finishRight(quiz)
      quiz.continueSession()
      finishRight(quiz)
      quiz.continueSession()
      finishRight(quiz)

      #expect(quiz.questionCount == 30)
      #expect(quiz.correctCount == 30)
    }

    @Test func aVerbPageQuizDoesNotContinue() {
      let quiz = startedQuiz(scope: .verbPage(Verb.verbs["gehen"]!, readingIndex: 0))
      finishRight(quiz)

      #expect(!quiz.canContinue)
      quiz.continueSession()

      #expect(!quiz.isInProgress)
      #expect(quiz.shouldShowResults)
      #expect(quiz.roundCount == 1)
    }

    @Test func continuingDoesNothingBeforeTheResults() {
      let quiz = startedQuiz()
      quiz.continueSession()

      #expect(quiz.roundCount == 1)
      #expect(quiz.questions.count == Quiz.questionCount)

      quiz.quit()
    }

    @Test func myVerbsAndCollectionsContinue() {
      #expect(QuizScope.myVerbs([Verb.verbs["gehen"]!]).continues)
      #expect(QuizScope.collection(.modals).continues)
      #expect(QuizScope.allVerbs.continues)
      #expect(!QuizScope.verbPage(Verb.verbs["gehen"]!, readingIndex: 0).continues)
    }

    @Test func completeQuizCountsTheSessionsQuestions() {
      let quiz = startedQuiz()
      let before = signalCount
      miss(quiz)
      finishRight(quiz)
      quiz.continueSession()
      finishRight(quiz)

      let counts = signals(since: before).filter { $0.0 == .completeQuiz }.map { $0.1[ParameterKey.questionCount.rawValue] }
      #expect(counts == ["10", "20"])
    }

    @Test func quitQuizCarriesADurationBand() {
      let quiz = startedQuiz()
      let before = signalCount
      quiz.quit()

      let parameters = signals(since: before).first { $0.0 == .quitQuiz }?.1
      #expect(parameters?[ParameterKey.duration.rawValue] == "0-3s")
    }

    @Test(arguments: zip(
      [0.0, 2.9, 3.0, 14.9, 15.0, 39.9, 40.0, 119.9, 120.0, 3_600.0],
      ["0-3s", "0-3s", "3-15s", "3-15s", "15-40s", "15-40s", "40s-2m", "40s-2m", "2m+", "2m+"]
    ))
    func quizDurationBands(seconds: Double, band: String) {
      #expect(AnalyticsBand.quizDuration(seconds) == band)
    }

    @Test func theLiveActivityShowsNoTimeWhileTheClockIsHidden() {
      let quiz = startedQuiz()
      Current.settings.quizClock = .hide
      #expect(quiz.elapsedTimeLiveActivity == nil)
      Current.settings.quizClock = .show
      #expect(quiz.elapsedTimeLiveActivity == "0:00")
      Current.settings.quizClock = Settings.quizClockDefault

      quiz.quit()
    }
  }

  @MainActor
  @Suite("Abandonment")
  struct AbandonmentTests {
    private var getterSetter: GetterSetter {
      Current.getterSetter
    }

    private func reset() {
      getterSetter.remove(key: QuizAbandonment.key)
      Current.settings.quizLevel = .intermediate
    }

    @Test func aQuizInProgressRecordsTheQuestionReached() {
      reset()
      let quiz = Quiz(timerInterval: 0.001)
      quiz.start()
      #expect(QuizAbandonment.entries(getterSetter: getterSetter).values.map(\.questionNumber) == [1])

      quiz.submitAnswer(quiz.questions[0].correctAnswer)
      quiz.submitAnswer(quiz.questions[1].correctAnswer)
      let entry = QuizAbandonment.entries(getterSetter: getterSetter).values.first
      #expect(entry == QuizAbandonment.Entry(level: "intermediate", source: "tab", questionNumber: 3))

      quiz.quit()
      #expect(QuizAbandonment.entries(getterSetter: getterSetter).isEmpty)
    }

    @Test func reachingTheResultsClearsTheRecordAndTenMoreRestoresIt() {
      reset()
      let quiz = Quiz(timerInterval: 0.001)
      quiz.start()
      while quiz.isInProgress {
        quiz.submitAnswer(quiz.currentQuestion!.correctAnswer)
      }
      #expect(QuizAbandonment.entries(getterSetter: getterSetter).isEmpty)

      quiz.continueSession()
      #expect(QuizAbandonment.entries(getterSetter: getterSetter).values.map(\.questionNumber) == [Quiz.questionCount + 1])

      quiz.quit()
    }

    @Test func twoQuizzesKeepTheirOwnRecords() {
      reset()
      let tab = Quiz(timerInterval: 0.001)
      tab.start()
      let sheet = Quiz(timerInterval: 0.001)
      sheet.start(scope: .verbPage(Verb.verbs["gehen"]!, readingIndex: 0))
      #expect(QuizAbandonment.entries(getterSetter: getterSetter).count == 2)

      sheet.quit()
      #expect(QuizAbandonment.entries(getterSetter: getterSetter).values.map(\.source) == ["tab"])

      tab.quit()
    }

    @Test func theNextLaunchReportsAnAbandonedQuizOnce() {
      reset()
      let quiz = Quiz(timerInterval: 0.001)
      quiz.start(scope: .myVerbs([Verb.verbs["gehen"]!]))
      quiz.submitAnswer(quiz.questions[0].correctAnswer)

      let spy = Current.analytics as! AnalyticsSpy
      let before = spy.signalNames.count
      QuizAbandonment.reportAndClear(getterSetter: getterSetter, analytics: spy)
      QuizAbandonment.reportAndClear(getterSetter: getterSetter, analytics: spy)

      let signals = Array(zip(spy.signalNames, spy.signalParameters).dropFirst(before))
      #expect(signals.count == 1)
      #expect(signals.first?.0 == .abandonQuiz)
      #expect(signals.first?.1 == [
        ParameterKey.level.rawValue: "intermediate",
        ParameterKey.questionNumber.rawValue: "2",
        ParameterKey.source.rawValue: "myVerbs"
      ])
      #expect(QuizAbandonment.entries(getterSetter: getterSetter).isEmpty)
    }
  }
}
