// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("Achievements")
struct AchievementTests {
  private let calendar = Calendar.current
  private let now = Date(timeIntervalSince1970: 1_800_000_000)

  /// Right, then right again when due: the third box, mastered.
  private func master(_ items: [PracticeItem], in record: inout PracticeRecord) {
    let later = now.addingTimeInterval(4 * 86_400)
    for item in items {
      record.recordAnswer(item, isCorrect: true, at: now, calendar: calendar)
      record.recordAnswer(item, isCorrect: true, at: later, calendar: calendar)
    }
  }

  private func patterns(at level: QuizLevel) -> [PracticeItem] {
    Mastery.patternTables(at: level).flatMap(\.cells).map(PracticeItem.pattern(of:))
  }

  /// Every key conjugation of every strong reading.
  private func keyConjugations(of verbs: [Verb]) -> [PracticeItem] {
    verbs.flatMap { verb in
      verb.readings.indices.filter { QuizDraw.isStrong(verb.readings[$0]) }.flatMap { readingIndex in
        PracticeItem.Stem.allCases.map { PracticeItem.keyConjugation(infinitiv: verb.infinitiv, readingIndex: readingIndex, stem: $0) }
      }
    }
  }

  // These IDs are permanent in App Store Connect; see docs/game_center_setup.md.
  @Test(arguments: zip(Achievement.allCases, [
    "konjugieren.achievement.patterns.beginner",
    "konjugieren.achievement.patterns.elementary",
    "konjugieren.achievement.patterns.intermediate",
    "konjugieren.achievement.patterns.advanced",
    "konjugieren.achievement.verbs.pillars",
    "konjugieren.achievement.verbs.core10",
    "konjugieren.achievement.verbs.core25",
    "konjugieren.achievement.verbs.core50"
  ]))
  func eachAchievementHasItsID(achievement: Achievement, identifier: String) {
    #expect(achievement.identifier == identifier)
  }

  @Test func theIDsAreDistinct() {
    #expect(Set(Achievement.allCases.map(\.identifier)).count == Achievement.allCases.count)
  }

  /// Apple allows 100 points an achievement and 1,000 in all.
  @Test func thePointsAreWithinGameCentersLimits() {
    #expect(Achievement.allCases.map(\.points) == [10, 25, 50, 100, 25, 25, 50, 100])
    #expect(Achievement.allCases.allSatisfy { $0.points <= 100 })
    #expect(Achievement.allCases.reduce(0) { $0 + $1.points } == 385)
  }

  @Test func thePillarsAreSeinHabenWerdenAndTheModals() {
    #expect(Set(Achievement.pillarVerbs.map(\.infinitiv)) == ["dürfen", "haben", "können", "mögen", "müssen", "sein", "sollen", "werden", "wollen"])
  }

  @Test func anEmptyRecordHasEarnedNothing() {
    let progress = Achievement.progress(in: PracticeRecord())

    #expect(Achievement.allCases.map { progress[$0]?.required } == [9, 17, 47, 66, 9, 10, 25, 50])
    #expect(Achievement.allCases.allSatisfy { progress[$0]?.mastered == 0 && progress[$0]?.percentComplete == 0 })
  }

  @Test(arguments: [Achievement.patternsBeginner, .patternsElementary, .patternsIntermediate, .patternsAdvanced])
  func aLevelsPatternsEarnItsAchievement(achievement: Achievement) throws {
    let level = try #require(achievement.patternLevel)
    var record = PracticeRecord()
    master(patterns(at: level), in: &record)
    let progress = Achievement.progress(in: record)

    #expect(progress[achievement]?.isComplete == true)
    #expect(progress[achievement]?.percentComplete == 100)
    // Each level asks every pattern of the one before, and the next asks more.
    for other in Achievement.allCases {
      guard let otherLevel = other.patternLevel else {
        #expect(progress[other]?.mastered == 0)
        continue
      }
      let isLowerOrSame = QuizLevel.allCases.firstIndex(of: otherLevel) ?? 0 <= QuizLevel.allCases.firstIndex(of: level) ?? 0
      #expect(progress[other]?.isComplete == isLowerOrSame)
    }
  }

  @Test func onePatternShortIsProgressNotTheAchievement() {
    var record = PracticeRecord()
    master(Array(patterns(at: .beginner).dropLast()), in: &record)
    let progress = Achievement.progress(in: record)[.patternsBeginner]

    #expect(progress?.isComplete == false)
    #expect(progress?.mastered == 8)
    #expect(abs((progress?.percentComplete ?? 0) - 800.0 / 9) < 0.0001)
  }

  /// An item answered right once is learning, not mastered, so it counts for nothing.
  @Test func learningCountsForNothing() {
    var record = PracticeRecord()
    for item in patterns(at: .beginner) {
      record.recordAnswer(item, isCorrect: true, at: now, calendar: calendar)
    }

    #expect(Achievement.progress(in: record)[.patternsBeginner]?.mastered == 0)
  }

  @Test func thePillarsNeedAllNineVerbs() {
    var record = PracticeRecord()
    master(keyConjugations(of: Achievement.pillarVerbs), in: &record)
    let progress = Achievement.progress(in: record)

    #expect(progress[.pillars]?.isComplete == true)
    #expect(progress[.tenStrong]?.mastered == 9)
    #expect(progress[.tenStrong]?.percentComplete == 90)
    #expect(progress[.twentyFiveStrong]?.isComplete == false)
  }

  /// The Präsens alone, all that Beginner asks, does not make a strong verb mastered, so changing
  /// the level cannot earn a strong-verb achievement.
  @Test func aStrongVerbNeedsAllThreeKeyConjugations() {
    var record = PracticeRecord()
    let präsensAndPerfekt = keyConjugations(of: Achievement.pillarVerbs).filter {
      if case let .keyConjugation(_, _, stem) = $0 {
        return stem != .präteritum
      }
      return false
    }
    master(präsensAndPerfekt, in: &record)

    #expect(Achievement.progress(in: record)[.pillars]?.mastered == 0)
    #expect(Mastery(level: .beginner, record: record).masteredVerbCount == Achievement.pillarVerbs.count)
  }

  @Test func theCoreVerbsEarnEachStep() {
    let core = Mastery.coreVerbs
    var record = PracticeRecord()
    master(keyConjugations(of: Array(core.prefix(25))), in: &record)
    var progress = Achievement.progress(in: record)
    #expect(progress[.tenStrong]?.isComplete == true)
    #expect(progress[.tenStrong]?.percentComplete == 100)
    #expect(progress[.twentyFiveStrong]?.isComplete == true)
    #expect(progress[.fiftyStrong]?.mastered == 25)
    #expect(progress[.fiftyStrong]?.percentComplete == 50)

    master(keyConjugations(of: Array(core.dropFirst(25))), in: &record)
    progress = Achievement.progress(in: record)
    #expect(progress[.fiftyStrong]?.isComplete == true)
  }

  /// fahren and ziehen have two strong readings, and each must be mastered.
  @Test func aVerbWithTwoStrongReadingsNeedsBoth() throws {
    let fahren = try #require(Verb.verbs["fahren"])
    var record = PracticeRecord()
    master(PracticeItem.Stem.allCases.map { .keyConjugation(infinitiv: "fahren", readingIndex: 0, stem: $0) }, in: &record)
    #expect(!Mastery.isFullyMastered(fahren, in: record))

    master(keyConjugations(of: [fahren]), in: &record)
    #expect(Mastery.isFullyMastered(fahren, in: record))
  }

  @Test func aWeakVerbIsNeverFullyMastered() throws {
    #expect(!Mastery.isFullyMastered(try #require(Verb.verbs["machen"]), in: PracticeRecord()))
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Achievements and personal bests")
  struct AchievementQuizTests {
    private var spy: GameCenterSpy {
      Current.gameCenter as! GameCenterSpy
    }

    /// A fresh record for the test, since the unit-test world's is shared. Each test puts back an
    /// empty one with `defer`.
    private func freshPractice(getterSetter: GetterSetter = GetterSetterFake()) -> PracticeStore {
      let practice = PracticeStore(getterSetter: getterSetter)
      Current.practice = practice
      return practice
    }

    private func daysAgo(_ days: Double) -> Date {
      Date.now.addingTimeInterval(-days * 86_400)
    }

    private func started(_ scope: QuizScope = .allVerbs, level: QuizLevel = .elementary) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 11))
      quiz.start(scope: scope)
      return quiz
    }

    /// Answers every question right, or the first wrong, which a default round never makes a
    /// choice question. A choice holds its reason whether right or wrong, so it is continued past.
    private func finish(_ quiz: Quiz, missingFirst: Bool = false) throws {
      var shouldMiss = missingFirst
      while quiz.isInProgress {
        let question = try #require(quiz.currentQuestion)
        if let choice = question.choice {
          quiz.submitChoice(choice.rightIndex)
        } else {
          quiz.submitAnswer(shouldMiss ? "definitelywrong" : question.correctAnswer)
        }
        shouldMiss = false
        if quiz.isHeld {
          quiz.continueAfterCorrection()
        }
      }
    }

    /// The milestone reached by a quiz's last right answer is reported as the quiz finishes: eight
    /// of Beginner's nine patterns mastered, and the ninth due for Review in the second box.
    @Test func theAnswerThatReachesAMilestoneReportsIt() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let machen = try #require(Verb.verbs["machen"])
      let cells = Mastery.patternTables(at: .beginner).flatMap(\.cells)
      for cell in cells.dropLast() {
        practice.recordAnswer(verb: machen, conjugationgroup: cell, readingIndex: 0, isCorrect: true, at: daysAgo(8))
        practice.recordAnswer(verb: machen, conjugationgroup: cell, readingIndex: 0, isCorrect: true, at: daysAgo(4))
      }
      let last = try #require(cells.last)
      practice.recordAnswer(verb: machen, conjugationgroup: last, readingIndex: 0, isCorrect: true, at: daysAgo(4))
      #expect(Achievement.progress(in: practice.record)[.patternsBeginner]?.mastered == 8)

      let before = spy.achievementReports.count
      let quiz = started(.recordSession(.review))
      #expect(quiz.questionCount == 1)
      try finish(quiz)

      let reports = Array(spy.achievementReports.dropFirst(before))
      #expect(reports.count == 1)
      #expect(reports.last?[.patternsBeginner] == 100)
      #expect(reports.last?[.patternsElementary] == Achievement.Progress(mastered: 9, required: 17).percentComplete)
      #expect(reports.last?.keys.count == Achievement.allCases.count)
    }

    @Test func quittingReportsTooSinceTheAnswersAreKept() {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let before = spy.achievementReports.count
      let quiz = started()
      quiz.submitAnswer(quiz.currentQuestion?.correctAnswer ?? "")
      quiz.quit()

      #expect(spy.achievementReports.count == before + 1)
    }

    @Test func theFirstRankedScoreIsANewBest() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      try finish(quiz)

      #expect(quiz.isNewLevelBest)
      #expect(quiz.levelPreviousBest == nil)
      #expect(quiz.showsLevelBest)
      #expect(practice.levelBest(at: .elementary) == 100)
      #expect(practice.levelBest(at: .beginner) == nil)
    }

    /// A miss is ninety, since the re-ask's half points do not count, as on the leaderboard.
    @Test func aLowerScoreShowsTheBestItDidNotBeat() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      try finish(started())
      let quiz = started()
      try finish(quiz, missingFirst: true)

      #expect(quiz.firstRoundScore == 90)
      #expect(!quiz.isNewLevelBest)
      #expect(quiz.levelPreviousBest == 100)
      #expect(practice.levelBest(at: .elementary) == 100)
    }

    @Test func aHigherScoreReplacesTheBest() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      try finish(started(level: .advanced), missingFirst: true)
      let quiz = started(level: .advanced)
      try finish(quiz)

      #expect(quiz.isNewLevelBest)
      #expect(quiz.levelPreviousBest == 90)
      #expect(practice.levelBest(at: .advanced) == 100)
    }

    @Test func eachLevelKeepsItsOwnBest() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      try finish(started(level: .beginner), missingFirst: true)
      try finish(started(level: .intermediate))

      #expect(practice.levelBest(at: .beginner) == 90)
      #expect(practice.levelBest(at: .intermediate) == 100)
      #expect(practice.levelBest(at: .elementary) == nil)
    }

    @Test func tenMoresResultsShowNoBest() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      try finish(quiz)
      #expect(quiz.showsLevelBest)

      quiz.continueSession()
      try finish(quiz)
      #expect(!quiz.showsLevelBest)
      #expect(!quiz.isNewLevelBest)
    }

    @Test func anUnrankedQuizSetsNoBest() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started(.daily())
      try finish(quiz)

      #expect(!quiz.showsLevelBest)
      #expect(practice.levelBests.isEmpty)
    }

    @Test func theBestsSurviveALaunchAndAResetForgetsThem() throws {
      let getterSetter = GetterSetterFake()
      _ = freshPractice(getterSetter: getterSetter)
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      try finish(started())

      let relaunched = PracticeStore(getterSetter: getterSetter)
      #expect(relaunched.levelBest(at: .elementary) == 100)

      relaunched.reset()
      #expect(relaunched.levelBest(at: .elementary) == nil)
      #expect(PracticeStore(getterSetter: getterSetter).levelBests.isEmpty)
    }

    @Test func aScoreOfNothingSetsNoBest() {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }

      #expect(!practice.recordRankedScore(0, level: .beginner))
      #expect(practice.levelBest(at: .beginner) == nil)
    }
  }
}
