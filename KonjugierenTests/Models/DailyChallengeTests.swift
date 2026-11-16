// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

/// What a drawn question asks, in a form two draws can be compared by.
@MainActor private func signature(_ question: QuizDrawnQuestion) -> String {
  "\(question.verb.infinitiv) \(question.conjugationgroup) \(question.readingIndex)"
}

@MainActor private func signature(_ item: QuizItem) -> String {
  "\(item.verb.infinitiv) \(item.conjugationgroup) \(item.readingIndex)"
}

/// The `offset`th day after 15 November 2026.
@MainActor private func key(_ offset: Int, level: QuizLevel) -> DailyChallenge.Key {
  let start = DailyChallenge.date(fromDayString: "2026-11-15") ?? .now
  let date = WidgetConstants.gregorianCalendar.date(byAdding: .day, value: offset, to: start) ?? start
  return DailyChallenge.Key(date: date, level: level)
}

@MainActor
@Suite("Daily Challenge")
struct DailyChallengeTests {
  /// Every device must make the same seed from the same day and level, in every process and for
  /// all time, so the text and its FNV-1a fold are pinned. A failure here means every challenge
  /// changed for everyone.
  @Test func theSeedIsPinned() {
    let key = DailyChallenge.Key(day: "2026-11-15", level: .intermediate)
    #expect(key.seedText == "challenge-2026-11-15-intermediate")
    #expect(key.seed == 15_168_996_962_080_082_873)
  }

  @Test func aDayRoundTrips() throws {
    let date = try #require(DailyChallenge.date(fromDayString: "2026-11-15"))
    #expect(DailyChallenge.dayString(for: date) == "2026-11-15")
    #expect(DailyChallenge.Key(date: date, level: .beginner).day == "2026-11-15")
  }

  @Test(arguments: ["2026-02-30", "2026-1-5", "tomorrow", ""])
  func aDayThatIsNotADateNamesNoChallenge(day: String) {
    #expect(DailyChallenge.Key(dayString: day, level: .beginner) == nil)
  }

  /// Two devices on the same date: the same draw, whatever happened in between, and the cached
  /// questions are the drawn ones.
  @Test(arguments: QuizLevel.allCases)
  func theSameKeyDrawsTheSameChallenge(level: QuizLevel) {
    let key = key(0, level: level)
    let first = DailyChallenge.draw(for: key).map(signature)
    _ = DailyChallenge.draw(for: DailyChallenge.Key(day: "2026-11-16", level: level))
    #expect(DailyChallenge.draw(for: key).map(signature) == first)
    #expect(DailyChallenge.questions(for: key).map(signature) == first)
  }

  @Test func daysAndLevelsHaveChallengesOfTheirOwn() {
    let days = Set((0..<7).map { DailyChallenge.questions(for: key($0, level: .beginner)).map(signature) })
    #expect(days.count == 7)
    #expect(DailyChallenge.questions(for: key(0, level: .beginner)).map(signature) != DailyChallenge.questions(for: key(0, level: .advanced)).map(signature))
  }

  /// The default quiz's mix in five questions: the level's cells and band, two strong or mixed
  /// readings, two of sein, haben, werden, or a modal, a prefixed verb, and no verb twice.
  @Test(arguments: QuizLevel.allCases)
  func aChallengeIsFiveBalancedQuestionsAtItsLevel(level: QuizLevel) {
    let cells = Set(level.pool.flatMap(\.cells))
    let band = Set(Quiz.defaultVerbs(for: level).map(\.infinitiv))
    for offset in 0..<20 {
      let questions = DailyChallenge.questions(for: key(offset, level: level))
      let readings = questions.compactMap { $0.verb.reading(at: $0.readingIndex) }
      #expect(questions.count == DailyChallenge.questionCount)
      #expect(questions.allSatisfy { cells.contains($0.conjugationgroup) && band.contains($0.verb.infinitiv) })
      #expect(Set(questions.map(\.verb.infinitiv)).count == questions.count, "\(questions.map(signature))")
      #expect(readings.filter(QuizDraw.isStrong).count >= 2)
      #expect(questions.filter { QuizDraw.isCore($0.verb) }.count >= QuizDraw.minimumCoreQuestions)
      #expect(readings.contains(where: QuizDraw.isDerivative))
    }
  }

  @Test func aResultCountsItsFiveQuestionsAsFirstAsked() throws {
    let verb = try #require(Verb.verbs["gehen"])
    func item(isCorrect: Bool?, firstAttempt: String? = nil) -> QuizItem {
      var item = QuizItem(verb: verb, conjugationgroup: .präsensIndikativ(.firstSingular), correctAnswer: "gehe")
      item.isCorrect = isCorrect
      item.firstAttempt = firstAttempt
      return item
    }
    let questions = [item(isCorrect: true), item(isCorrect: true), item(isCorrect: true, firstAttempt: "geh"), item(isCorrect: false), item(isCorrect: true)]
    let result = DailyChallengeResult(key: key(0, level: .intermediate), questions: questions)

    #expect(result.outcomes == [.right, .right, .secondTry, .wrong, .right])
    #expect(result.score == 35)
    #expect(result.dots == "🟡🟡🟠🔴🟡")
    #expect(result.pointsLine == "35 / 50")
    #expect(result.spokenSummary == L.DailyChallenge.spokenResult(right: 3, secondTry: 1, count: 5, score: 35, maximum: 50))
  }

  /// The text Josh approved on 2026-11-15, in English, the language the suite runs in.
  @Test func theSharedTextIsTheAgreedText() {
    let result = DailyChallengeResult(key: DailyChallenge.Key(day: "2026-11-15", level: .intermediate), outcomes: [.right, .right, .secondTry, .wrong, .right])
    let expected = """
      Konjugieren · Daily Challenge
      November 15, 2026 · \(L.QuizLevel.intermediate)
      🟡🟡🟠🔴🟡  35 / 50

      Take this challenge in Konjugieren:
      konjugieren://quiz/challenge?date=2026-11-15&level=intermediate&source=challengeLink

      Get Konjugieren on the App Store:
      \(URL.appStore.absoluteString)
      """
    #expect(result.shareText(locale: Locale(identifier: "en_US")) == expected)
  }

  @Test func theSharedDateFollowsTheAppsLanguage() {
    let result = DailyChallengeResult(key: DailyChallenge.Key(day: "2026-11-15", level: .beginner), outcomes: [.right])
    #expect(result.shareText(locale: Locale(identifier: "de_DE")).contains("15. November 2026"))
  }

  /// The quiz widget's question is the first of the day's challenge at the level, with three
  /// wrong answers of the same reading, none of them right.
  @Test(arguments: QuizLevel.allCases)
  func theWidgetsQuestionAgreesWithTheChallenge(level: QuizLevel) throws {
    let fallback = try #require(Verb.verbs["gehen"])
    for offset in 0..<10 {
      let key = key(offset, level: level)
      let first = try #require(DailyChallenge.questions(for: key).first)
      let question = WidgetSnapshotWriter.quizQuestion(on: key.date, level: level, fallbackVerb: fallback)
      let expected = RegionalConjugator.conjugateUnsafely(infinitiv: first.verb.infinitiv, conjugationgroup: first.conjugationgroup, readingIndex: first.readingIndex).lowercased()

      #expect(question.infinitiv == first.verb.infinitiv)
      #expect(question.conjugationgroupDisplay == first.conjugationgroup.displayName(lang: Current.settings.conjugationgroupLang))
      #expect(question.pronoun == first.conjugationgroup.quizPronoun)
      #expect(question.correctAnswer == expected)
      #expect(question.questionID == "\(key.day)-\(level.rawValue)-\(first.verb.infinitiv)")
      #expect(question.wrongAnswers.count == 3)
      #expect(Set(question.wrongAnswers).count == 3)
      #expect(!question.wrongAnswers.contains(question.correctAnswer))
      // The wir and Sie Imperativ carry their pronoun (dürfen wir), which gives them away. A du
      // Imperativ may still appear, as the ich Präsens it often equals (erwarte).
      if first.conjugationgroup.table != .imperativ {
        #expect(question.wrongAnswers.allSatisfy { answer in
          ![Conjugationgroup.imperativ(.firstPlural), .imperativ(.thirdPlural)].contains { cell in
            (try? RegionalConjugator.conjugate(infinitiv: first.verb.infinitiv, conjugationgroup: cell, readingIndex: first.readingIndex).get().lowercased()) == answer
          }
        }, "\(question.wrongAnswers)")
      }
    }
  }

  @Test func theWidgetsBundleAsksEachDaysChallenge() throws {
    let start = try #require(DailyChallenge.date(fromDayString: "2026-11-15"))
    let bundle = try #require(WidgetSnapshotWriter.generateBundle(startDate: start, level: .elementary))
    for (offset, snapshot) in bundle.snapshots.enumerated() {
      #expect(snapshot.quizQuestion.infinitiv == DailyChallenge.questions(for: key(offset, level: .elementary)).first?.verb.infinitiv)
    }
  }
}

extension QuizTests {
  @MainActor
  @Suite("Daily Challenge in a Quiz")
  struct DailyChallengeQuizTests {
    private func restore() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.settings.quizLevel = Settings.quizLevelDefault
    }

    /// A challenge answered right throughout but for the questions at `wrong`.
    @discardableResult
    private func finishChallenge(_ key: DailyChallenge.Key, wrong: Set<Int> = [], seed: UInt64 = 8) throws -> Quiz {
      let quiz = Quiz(timerInterval: 10_000, randomSource: SeededRNG(seed: seed))
      quiz.start(scope: .challenge(key))
      while quiz.isInProgress {
        if quiz.correction != nil {
          quiz.continueAfterCorrection()
          continue
        }
        let question = try #require(quiz.currentQuestion)
        quiz.submitAnswer(wrong.contains(quiz.currentIndex) ? "zzzzzzzz" : question.correctAnswer)
      }
      return quiz
    }

    /// Two devices: different random sources, levels, and practice records ask the same five.
    @Test func aChallengeAsksItsKeysQuestionsWhateverTheDevice() throws {
      defer { restore() }
      let key = DailyChallenge.Key(day: "2026-11-15", level: .intermediate)
      let expected = DailyChallenge.draw(for: key).map(signature)

      Current.settings.quizLevel = .beginner
      let first = Quiz(timerInterval: 10_000, randomSource: SeededRNG(seed: 1))
      first.start(scope: .challenge(key))
      let firstAsked = first.questions.map(signature)
      first.quit()

      Current.settings.quizLevel = .advanced
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      practice.recordAnswer(verb: try #require(Verb.verbs["machen"]), conjugationgroup: .perfektIndikativ(.secondPlural), readingIndex: 0, isCorrect: false, at: .now.addingTimeInterval(-3 * 86_400))
      Current.practice = practice
      let second = Quiz(timerInterval: 10_000, randomSource: SeededRNG(seed: 99))
      second.start(scope: .challenge(key))

      #expect(firstAsked == expected)
      #expect(second.questions.map(signature) == expected)
      #expect(second.level == .intermediate)
      #expect(second.questions.allSatisfy { $0.choice == nil })
      second.quit()
    }

    @Test func finishingKeepsTheResultOnceAndRanksNothing() throws {
      defer { restore() }
      let spy = Current.analytics as! AnalyticsSpy
      let gameCenter = Current.gameCenter as! GameCenterSpy
      let initialScores = gameCenter.submissions.count
      let key = DailyChallenge.Key(day: "2026-11-15", level: .elementary)
      let quiz = try finishChallenge(key, wrong: [1])

      #expect(quiz.shouldShowResults)
      #expect(quiz.questions.count == DailyChallenge.questionCount)
      #expect(quiz.reaskCount == 0)
      #expect(!quiz.canContinue)
      #expect(quiz.challengeResult?.outcomes == [.right, .wrong, .right, .right, .right])
      #expect(Current.practice.challengeResult(for: key) == quiz.challengeResult)
      #expect(Current.practice.lastResult?.kind == .challenge)
      #expect(gameCenter.submissions.count == initialScores)
      let completion = try #require(Array(zip(spy.signalNames, spy.signalParameters)).last { $0.0 == .completeQuiz }?.1)
      #expect(completion[ParameterKey.source.rawValue] == "challenge")
      #expect(completion[ParameterKey.level.rawValue] == "elementary")

      let again = try finishChallenge(key)
      #expect(again.challengeResult == quiz.challengeResult)
      #expect(Current.practice.challengeResults.count == 1)
    }

    @Test func aWrongAnswerIsHeldButNotAskedAgain() throws {
      defer { restore() }
      let quiz = Quiz(timerInterval: 10_000, randomSource: SeededRNG(seed: 3))
      quiz.start(scope: .challenge(DailyChallenge.Key(day: "2026-11-15", level: .beginner)))
      quiz.submitAnswer("zzzzzzzz")

      #expect(quiz.correction?.willBeReasked == false)
      #expect(quiz.questions.count == DailyChallenge.questionCount)
      quiz.quit()
    }

    @Test func aQuitChallengeKeepsNothing() throws {
      defer { restore() }
      let key = DailyChallenge.Key(day: "2026-11-15", level: .beginner)
      let quiz = Quiz(timerInterval: 10_000, randomSource: SeededRNG(seed: 3))
      quiz.start(scope: .challenge(key))
      quiz.submitAnswer(try #require(quiz.currentQuestion).correctAnswer)
      quiz.quit()

      #expect(Current.practice.challengeResult(for: key) == nil)
      #expect(quiz.challengeResult == nil)
    }

    @Test func theStoreKeepsTheLatestResults() {
      defer { restore() }
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      for offset in 0..<(DailyChallengeResult.keptCount + 3) {
        practice.recordChallenge(DailyChallengeResult(key: key(offset, level: .beginner), outcomes: [.right]))
      }
      #expect(practice.challengeResults.count == DailyChallengeResult.keptCount)
      #expect(practice.challengeResult(for: key(0, level: .beginner)) == nil)
      #expect(practice.challengeResult(for: key(DailyChallengeResult.keptCount + 2, level: .beginner)) != nil)
    }

    @Test func theResultsSurviveALaunch() {
      defer { restore() }
      let getterSetter = GetterSetterFake()
      let result = DailyChallengeResult(key: key(0, level: .advanced), outcomes: [.right, .secondTry])
      PracticeStore(getterSetter: getterSetter).recordChallenge(result)
      #expect(PracticeStore(getterSetter: getterSetter).challengeResult(for: result.key) == result)
    }

    /// Sharing says which level's challenge was shared, and never how it went (Decision 5).
    @Test func sharingSendsTheLevelAlone() throws {
      let spy = Current.analytics as! AnalyticsSpy
      DailyChallengeResult(key: key(0, level: .advanced), outcomes: [.right, .wrong]).signalShare()
      let parameters = try #require(Array(zip(spy.signalNames, spy.signalParameters)).last { $0.0 == .tapShareChallenge }?.1)
      #expect(parameters == [ParameterKey.level.rawValue: "advanced"])
    }
  }
}
