// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

/// A fixed calendar, so that a day is the same day on every machine.
private let berlin: Calendar = {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: "Europe/Berlin") ?? .gmt
  return calendar
}()

/// Noon, or `hour`, of the `offset`th day after 2 November 2026.
private func day(_ offset: Int, hour: Int = 12) -> Date {
  let start = berlin.date(from: DateComponents(year: 2026, month: 11, day: 2, hour: hour)) ?? .now
  return berlin.date(byAdding: .day, value: offset, to: start) ?? start
}

@MainActor
@Suite("Daily Session")
struct DailySessionTests {
  private func streak(sessionsOn days: [Int]) -> DailyStreak {
    var streak = DailyStreak()
    for offset in days {
      streak.recordSession(at: day(offset), calendar: berlin)
    }
    return streak
  }

  @Test func noSessionIsNoStreak() {
    #expect(DailyStreak().status(at: day(0), calendar: berlin) == .none)
  }

  @Test func aStreakLivesThroughTheNextDayAndCanBeRepairedTheDayAfter() {
    let streak = streak(sessionsOn: [0])

    #expect(streak.status(at: day(0, hour: 23), calendar: berlin) == .active(length: 1, isDoneToday: true))
    #expect(streak.status(at: day(1, hour: 0), calendar: berlin) == .active(length: 1, isDoneToday: false))
    #expect(streak.status(at: day(2), calendar: berlin) == .repairable(length: 1, sessionsToday: 0))
    #expect(streak.status(at: day(3), calendar: berlin) == .none)
  }

  @Test func consecutiveDaysCountOnceEach() {
    let streak = streak(sessionsOn: [0, 1, 1, 2])

    #expect(streak.status(at: day(2), calendar: berlin) == .active(length: 3, isDoneToday: true))
  }

  /// Josh's rule: one missed day is repaired by two sessions the day after, and the missed day
  /// does not count.
  @Test func twoSessionsTheDayAfterAMissedDayRepairTheStreak() {
    var streak = streak(sessionsOn: [0, 1, 2])
    streak.recordSession(at: day(4, hour: 8), calendar: berlin)
    #expect(streak.status(at: day(4), calendar: berlin) == .repairable(length: 3, sessionsToday: 1))

    streak.recordSession(at: day(4, hour: 21), calendar: berlin)
    #expect(streak.status(at: day(4, hour: 22), calendar: berlin) == .active(length: 4, isDoneToday: true))
    #expect(streak.status(at: day(5), calendar: berlin) == .active(length: 4, isDoneToday: false))
  }

  @Test func oneSessionTheDayAfterAMissedDayStartsANewStreak() {
    var streak = streak(sessionsOn: [0, 1, 3])
    #expect(streak.status(at: day(4), calendar: berlin) == .active(length: 1, isDoneToday: false))

    streak.recordSession(at: day(4), calendar: berlin)
    #expect(streak.status(at: day(4), calendar: berlin) == .active(length: 2, isDoneToday: true))
  }

  @Test func twoMissedDaysCannotBeRepaired() {
    let streak = streak(sessionsOn: [0, 3, 3])

    #expect(streak.status(at: day(3), calendar: berlin) == .active(length: 1, isDoneToday: true))
  }

  /// The clocks went back in Berlin on 25 October 2026, a day of 25 hours.
  @Test func aDayOfTwentyFiveHoursIsOneDay() throws {
    let saturday = try #require(berlin.date(from: DateComponents(year: 2026, month: 10, day: 24, hour: 23, minute: 30)))
    let sunday = try #require(berlin.date(from: DateComponents(year: 2026, month: 10, day: 25, hour: 23, minute: 30)))
    var streak = DailyStreak()
    streak.recordSession(at: saturday, calendar: berlin)
    streak.recordSession(at: sunday, calendar: berlin)

    #expect(streak.status(at: sunday, calendar: berlin) == .active(length: 2, isDoneToday: true))
  }

  /// Only the last two runs are kept, since only the one before the last can still be joined.
  @Test func runsThatCanNoLongerChangeAreDropped() {
    var streak = streak(sessionsOn: [0, 5, 10, 12])
    #expect(streak.sessions.count == 2)
    #expect(streak.status(at: day(12), calendar: berlin) == .repairable(length: 1, sessionsToday: 1))

    streak.recordSession(at: day(12, hour: 20), calendar: berlin)
    #expect(streak.status(at: day(12, hour: 21), calendar: berlin) == .active(length: 2, isDoneToday: true))
  }

  @Test(arguments: [(1, "1"), (2, "2-6"), (6, "2-6"), (7, "7-29"), (29, "7-29"), (30, "30+"), (365, "30+")])
  func theStreakIsSentInBands(length: Int, band: String) {
    #expect(AnalyticsBand.streak(length) == band)
  }

  @Test func theStoreKeepsTheStreakAcrossALaunchAndResetForgetsIt() {
    let getterSetter = GetterSetterFake()
    let practice = PracticeStore(getterSetter: getterSetter, calendar: berlin)
    #expect(practice.recordDailySession(at: day(0)) == .active(length: 1, isDoneToday: true))
    practice.recordDailySession(at: day(1))

    let relaunched = PracticeStore(getterSetter: getterSetter, calendar: berlin)
    #expect(relaunched.streakStatus(at: day(1)) == .active(length: 2, isDoneToday: true))

    relaunched.reset()
    #expect(PracticeStore(getterSetter: getterSetter, calendar: berlin).streakStatus(at: day(1)) == .none)
  }

  private func dueRecord(_ items: [PracticeItem]) -> PracticeRecord {
    var record = PracticeRecord()
    for item in items {
      record.recordAnswer(item, isCorrect: false, at: day(-1), calendar: berlin)
    }
    return record
  }

  private func item(of question: QuizDrawnQuestion) -> PracticeItem {
    PracticeItem.exercised(by: question.conjugationgroup, of: question.verb, readingIndex: question.readingIndex)
  }

  @Test func dueItemsComeFirstAndTheDrawFillsTheRest() {
    let due: [PracticeItem] = [
      .pattern(of: .präsensIndikativ(.firstSingular)),
      .pattern(of: .perfektIndikativ(.thirdSingular)),
      .keyConjugation(infinitiv: "kommen", readingIndex: 0, stem: .präsens)
    ]
    var generator = SeededRNG(seed: 3)
    let level = QuizLevel.elementary
    let questions = QuizDraw.dailyQuestions(for: due, pool: level.pool, verbs: Quiz.defaultVerbs(for: level), using: &generator)

    #expect(questions.count == DailySession.questionCount)
    for dueItem in due {
      #expect(questions.contains { item(of: $0) == dueItem })
    }
    let cells = Set(level.pool.flatMap(\.cells))
    #expect(questions.allSatisfy { cells.contains($0.conjugationgroup) })
  }

  @Test func tenDueItemsFillTheSessionMostOverdueFirst() {
    let due = PersonNumber.allCases.map { PracticeItem.pattern(of: .präsensIndikativ($0)) }
      + PersonNumber.allCases.map { PracticeItem.pattern(of: .perfektIndikativ($0)) }
    var generator = SeededRNG(seed: 4)
    let level = QuizLevel.elementary
    let questions = QuizDraw.dailyQuestions(for: due, pool: level.pool, verbs: Quiz.defaultVerbs(for: level), using: &generator)

    #expect(questions.count == DailySession.questionCount)
    #expect(Set(questions.map(item(of:))) == Set(due.prefix(DailySession.questionCount)))
  }

  /// A key conjugation the level does not ask, here a Präteritum at Elementary, waits for Review.
  @Test func aDueItemBeyondTheLevelIsLeftOut() {
    let beyond = PracticeItem.keyConjugation(infinitiv: "kommen", readingIndex: 0, stem: .präteritum)
    var generator = SeededRNG(seed: 5)
    let level = QuizLevel.elementary
    let questions = QuizDraw.dailyQuestions(for: [beyond], pool: level.pool, verbs: Quiz.defaultVerbs(for: level), using: &generator)

    #expect(questions.count == DailySession.questionCount)
    #expect(!questions.contains { item(of: $0) == beyond })
  }

  @Test func theScopeIsNeitherRankedNorContinued() {
    let scope = QuizScope.daily()

    #expect(scope.isDaily)
    #expect(!scope.isRanked)
    #expect(!scope.continues)
    #expect(!scope.mixesDueItems)
    #expect(scope.asksByLevel)
    #expect(scope.sendsQuestionCounts)
    #expect(scope.source == .daily)
    #expect(QuizScope.daily(source: .reminder).source == .reminder)
    #expect(LastQuizResult.Kind(scope: scope) == .daily)
  }

  @Test func remindersComeEachDayAtTheChosenTime() {
    let reminders = DailyReminderPlan.reminders(record: PracticeRecord(), streak: DailyStreak(), minutes: 18 * 60 + 15, now: day(0, hour: 9), calendar: berlin)

    #expect(reminders.count == DailyReminderPlan.dayCount)
    let first = reminders[0]
    #expect(berlin.dateComponents([.day, .hour, .minute], from: first.date) == DateComponents(day: 2, hour: 18, minute: 15))
    #expect(first.identifier == "dailyReminder.2026-11-02")
    #expect(first.title == L.DailyReminder.title)
    #expect(first.body == L.DailyReminder.body)
    #expect(Set(reminders.map(\.identifier)).count == reminders.count)
  }

  @Test func todaysReminderIsLeftOutOnceItsTimeHasPassed() throws {
    let reminders = DailyReminderPlan.reminders(record: PracticeRecord(), streak: DailyStreak(), minutes: 8 * 60, now: day(0, hour: 9), calendar: berlin)

    #expect(reminders.count == DailyReminderPlan.dayCount - 1)
    #expect(berlin.component(.day, from: try #require(reminders.first).date) == 3)
  }

  /// Today's session done, today's reminder goes. The days after say what the streak needs.
  @Test func aDoneDayGetsNoReminderAndARepairableDaySaysSo() {
    let reminders = DailyReminderPlan.reminders(record: PracticeRecord(), streak: streak(sessionsOn: [0]), minutes: 18 * 60, now: day(0, hour: 9), calendar: berlin)

    #expect(reminders.count == DailyReminderPlan.dayCount - 1)
    #expect(reminders.map(\.identifier).first == "dailyReminder.2026-11-03")
    #expect(reminders[0].body == L.DailyReminder.body)
    #expect(reminders[1].body == L.DailySession.repairTwo(1))
    #expect(reminders[2].body == L.DailyReminder.body)
  }

  @Test func aReminderCountsWhatWillBeDueThatDay() {
    var record = dueRecord([.pattern(of: .präsensIndikativ(.firstSingular)), .pattern(of: .präsensIndikativ(.secondSingular))])
    // Right on day 0, due three days later.
    record.recordAnswer(.pattern(of: .perfektIndikativ(.firstSingular)), isCorrect: true, at: day(0), calendar: berlin)
    let reminders = DailyReminderPlan.reminders(record: record, streak: DailyStreak(), minutes: 18 * 60, now: day(0, hour: 9), calendar: berlin)

    #expect(reminders[0].body == L.DailyReminder.bodyDue(2))
    #expect(reminders[3].body == L.DailyReminder.bodyDue(3))
  }
}

extension QuizTests {
  @MainActor
  @Suite("Daily Session in a Quiz")
  struct DailySessionQuizTests {
    @discardableResult
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake(), calendar: berlin)
      Current.practice = practice
      return practice
    }

    private func restore() {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.settings.dailyReminder = .off
    }

    /// A daily session started on `date` and answered right throughout.
    @discardableResult
    private func finishDailySession(on date: Date, source: AnalyticsSource = .daily) throws -> Quiz {
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(timerInterval: 10_000, randomSource: SeededRNG(seed: 8), now: { date })
      quiz.start(scope: .daily(source: source))
      while quiz.isInProgress {
        quiz.submitAnswer(try #require(quiz.currentQuestion).correctAnswer)
      }
      return quiz
    }

    @Test func aDailySessionAsksTenQuestionsAtTheLevelDueItemsIncluded() throws {
      let practice = freshPractice()
      defer { restore() }
      let due = PracticeItem.pattern(of: .perfektIndikativ(.secondPlural))
      practice.recordAnswer(verb: try #require(Verb.verbs["machen"]), conjugationgroup: .perfektIndikativ(.secondPlural), readingIndex: 0, isCorrect: false, at: day(-1))
      Current.settings.quizLevel = .elementary
      let quiz = Quiz(timerInterval: 10_000, randomSource: SeededRNG(seed: 2), now: { day(0) })
      quiz.start(scope: .daily())

      #expect(quiz.questions.count == DailySession.questionCount)
      let cells = Set(QuizLevel.elementary.pool.flatMap(\.cells))
      #expect(quiz.questions.allSatisfy { cells.contains($0.conjugationgroup) && $0.choice == nil })
      #expect(quiz.questions.contains { PracticeItem.exercised(by: $0.conjugationgroup, of: $0.verb, readingIndex: $0.readingIndex) == due })
      quiz.quit()
    }

    @Test func finishingExtendsTheStreakAndSendsItsBand() throws {
      let practice = freshPractice()
      defer { restore() }
      let spy = Current.analytics as! AnalyticsSpy
      let gameCenter = Current.gameCenter as! GameCenterSpy
      let initialScores = gameCenter.submissions.count
      let quiz = try finishDailySession(on: day(0))

      #expect(quiz.shouldShowResults)
      #expect(quiz.dailyStreakStatus == .active(length: 1, isDoneToday: true))
      #expect(practice.streakStatus(at: day(0)) == .active(length: 1, isDoneToday: true))
      #expect(!quiz.canContinue)
      #expect(gameCenter.submissions.count == initialScores)
      #expect(practice.lastResult?.kind == .daily)
      let completion = try #require(Array(zip(spy.signalNames, spy.signalParameters)).last { $0.0 == .completeQuiz }?.1)
      #expect(completion[ParameterKey.streak.rawValue] == "1")
      #expect(completion[ParameterKey.source.rawValue] == "daily")
      #expect(completion[ParameterKey.questionCount.rawValue] == "10")
    }

    @Test func aQuitSessionDoesNotCount() throws {
      let practice = freshPractice()
      defer { restore() }
      let quiz = Quiz(timerInterval: 10_000, randomSource: SeededRNG(seed: 8), now: { day(0) })
      quiz.start(scope: .daily())
      quiz.submitAnswer(try #require(quiz.currentQuestion).correctAnswer)
      quiz.quit()

      #expect(practice.streakStatus(at: day(0)) == .none)
      #expect(quiz.dailyStreakStatus == nil)
    }

    /// Two days, a missed day, then two sessions: the results offer the second, which repairs.
    @Test func aStreakIsRepairedAcrossDays() throws {
      let practice = freshPractice()
      defer { restore() }
      try finishDailySession(on: day(0))
      try finishDailySession(on: day(1))
      #expect(practice.streakStatus(at: day(3)) == .repairable(length: 2, sessionsToday: 0))

      let first = try finishDailySession(on: day(3, hour: 9))
      #expect(first.dailyStreakStatus == .repairable(length: 2, sessionsToday: 1))
      #expect(first.dailyStreakStatus?.awaitsRepairSession == true)
      #expect(first.dailyStreakStatus?.resultsLine == L.DailySession.repairOne(2))

      let second = try finishDailySession(on: day(3, hour: 10))
      #expect(second.dailyStreakStatus == .active(length: 3, isDoneToday: true))
      #expect(second.dailyStreakStatus?.awaitsRepairSession == false)
      #expect(practice.streakStatus(at: day(4)) == .active(length: 3, isDoneToday: false))
    }

    /// On the real clock and calendar, which the plan reads.
    @Test func finishingReschedulesTheReminderWhileItIsOn() throws {
      Current.practice = PracticeStore(getterSetter: GetterSetterFake())
      defer { restore() }
      let reminders = Current.reminderScheduler as! ReminderSchedulerSpy
      Current.settings.dailyReminder = .on
      let before = reminders.schedules.count
      try finishDailySession(on: .now)

      #expect(reminders.schedules.count == before + 1)
      #expect(!reminders.scheduled.isEmpty)
      #expect(!reminders.scheduled.contains { $0.identifier == DailyReminderPlan.identifierPrefix + DailyStreak.dayKey(.now) })

      Current.settings.dailyReminder = .off
      Current.rescheduleReminders()
      #expect(reminders.scheduled.isEmpty)
    }

    @Test func theReminderNamesItselfAsTheSource() throws {
      freshPractice()
      defer { restore() }
      let spy = Current.analytics as! AnalyticsSpy
      try finishDailySession(on: day(0), source: .reminder)

      let start = try #require(Array(zip(spy.signalNames, spy.signalParameters)).last { $0.0 == .startQuiz }?.1)
      #expect(start[ParameterKey.source.rawValue] == "reminder")
    }
  }
}
