// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import Testing

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Leaderboards by level")
  struct LeaderboardTests {
    private var spy: GameCenterSpy {
      Current.gameCenter as! GameCenterSpy
    }

    private func startedQuiz(scope: QuizScope = .allVerbs, level: QuizLevel = .elementary) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 7))
      quiz.start(scope: scope)
      return quiz
    }

    private func finishRight(_ quiz: Quiz) {
      while quiz.isInProgress {
        quiz.submitAnswer(quiz.currentQuestion!.correctAnswer)
      }
    }

    private func miss(_ quiz: Quiz) {
      quiz.submitAnswer("definitelywrong")
      quiz.continueAfterCorrection()
    }

    // These IDs are permanent in App Store Connect; see docs/game_center_setup.md.
    @Test(arguments: zip(QuizLevel.allCases, [
      "konjugieren.level.beginner",
      "konjugieren.level.elementary",
      "konjugieren.level.intermediate",
      "konjugieren.level.advanced"
    ]))
    func eachLevelHasItsOwnLeaderboard(level: QuizLevel, leaderboardID: String) {
      #expect(level.leaderboardID == leaderboardID)
    }

    @Test func leaderboardIDsAreDistinct() {
      #expect(Set(QuizLevel.allCases.map(\.leaderboardID)).count == QuizLevel.allCases.count)
    }

    @Test(arguments: QuizLevel.allCases)
    func aRankedSessionPostsToItsLevelsLeaderboard(level: QuizLevel) {
      let before = spy.submissions.count
      let quiz = startedQuiz(level: level)
      finishRight(quiz)

      #expect(Array(spy.submissions.dropFirst(before)) == [
        GameCenterSpy.Submission(score: Quiz.questionCount * Quiz.pointsPerCorrect, level: level)
      ])
    }

    @Test func theLevelIsTheOneTheQuizStartedAt() {
      let before = spy.submissions.count
      let quiz = startedQuiz(level: .beginner)
      Current.settings.quizLevel = .advanced
      finishRight(quiz)

      #expect(spy.submissions.dropFirst(before).map(\.level) == [.beginner])
    }

    @Test func theRankedScoreCountsSecondAttemptsButNotReasks() throws {
      let before = spy.submissions.count
      let quiz = startedQuiz()
      miss(quiz)
      let slip = String(quiz.currentQuestion!.correctAnswer.dropLast()) + "x"
      try #require(quiz.currentQuestion!.isSlip(slip))
      quiz.submitAnswer(slip)
      #expect(quiz.isAwaitingSecondAttempt)
      finishRight(quiz)

      let expected = (Quiz.questionCount - 2) * Quiz.pointsPerCorrect + Quiz.pointsPerSecondAttempt
      #expect(quiz.reaskCount == 1)
      #expect(quiz.score > expected)
      #expect(spy.submissions.dropFirst(before).map(\.score) == [expected])
    }

    @Test func tenMorePostsNothing() {
      let quiz = startedQuiz()
      finishRight(quiz)
      let afterFirstRound = spy.submissions.count
      quiz.continueSession()
      finishRight(quiz)

      #expect(spy.submissions.count == afterFirstRound)
    }

    @Test func aScopedQuizPostsNowhere() {
      let before = spy.submissions.count
      for scope in [
        QuizScope.myVerbs([Verb.verbs["gehen"]!, Verb.verbs["sein"]!]),
        .verbPage(Verb.verbs["gehen"]!, readingIndex: 0),
        .collection(.modals)
      ] {
        #expect(!scope.isRanked)
        let quiz = startedQuiz(scope: scope)
        finishRight(quiz)
      }

      #expect(spy.submissions.count == before)
    }
  }
}
