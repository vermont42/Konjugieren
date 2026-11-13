// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
struct ReviewScheduleTests {
  private static let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
    return calendar
  }()

  private var calendar: Calendar { Self.calendar }

  /// Day `day` of 2026-11, at `hour` UTC.
  private func date(_ day: Int, hour: Int = 12) -> Date {
    calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour)) ?? .distantPast
  }

  private func startOf(_ day: Int) -> Date {
    date(day, hour: 0)
  }

  @Test func aLookupIsDueTheNextMorning() {
    let schedule = ReviewSchedule.lookedUp(at: date(10, hour: 23), calendar: calendar)

    #expect(schedule.box == 0)
    #expect(schedule.due == startOf(11))
    #expect(!schedule.isDue(at: date(10, hour: 23)))
    #expect(schedule.isDue(at: startOf(11)))
  }

  @Test func reviewsClimbTheLadderAndStayOnItsLastRung() {
    var schedule = ReviewSchedule.lookedUp(at: date(1), calendar: calendar)
    var dueDays: [Int] = []
    for _ in 0..<6 {
      schedule = schedule.reviewed(at: schedule.due, calendar: calendar)
      dueDays.append(calendar.dateComponents([.day], from: startOf(1), to: schedule.due).day ?? -1)
    }

    // Looked up on the 1st and due on the 2nd; then 3, 7, 14, 30, and 30 days after each review.
    #expect(dueDays == [4, 11, 25, 55, 85, 115])
    #expect(schedule.box == ReviewSchedule.intervals.count - 1)
  }

  @Test func aSnoozeKeepsTheBoxAndWaitsADay() {
    let schedule = ReviewSchedule.lookedUp(at: date(1), calendar: calendar).reviewed(at: date(2), calendar: calendar)

    let snoozed = schedule.snoozed(at: date(5, hour: 8), calendar: calendar)

    #expect(snoozed.box == schedule.box)
    #expect(snoozed.due == startOf(6))
  }

  @Test func dueVerbsComeLongestOverdueFirst() {
    var record = LearnerVerbs()
    record.recordOpen("sein", at: date(3), calendar: calendar)
    record.recordOpen("gehen", at: date(1), calendar: calendar)
    record.recordOpen("haben", at: date(1), calendar: calendar)
    record.recordOpen("machen", at: date(9), calendar: calendar)

    #expect(record.dueForReview(at: date(9), calendar: calendar) == ["gehen", "haben", "sein"])
    #expect(record.dueForReview(at: date(1), calendar: calendar).isEmpty)
  }

  @Test func aReviewPostponesTheVerb() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1), calendar: calendar)

    record.recordReview("gehen", at: date(2), calendar: calendar)

    #expect(record.entries["gehen"]?.review == ReviewSchedule(box: 1, due: startOf(5)))
    #expect(record.dueForReview(at: date(4), calendar: calendar).isEmpty)
    #expect(record.dueForReview(at: date(5), calendar: calendar) == ["gehen"])
  }

  @Test func aSnoozeBringsTheVerbBackTomorrow() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1), calendar: calendar)

    record.snoozeReview("gehen", at: date(2), calendar: calendar)

    #expect(record.dueForReview(at: date(2), calendar: calendar).isEmpty)
    #expect(record.dueForReview(at: date(3), calendar: calendar) == ["gehen"])
    #expect(record.entries["gehen"]?.review?.box == 0)
  }

  @Test func lookingAVerbUpAgainSendsItBackToTheFirstBox() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1), calendar: calendar)
    record.recordReview("gehen", at: date(2), calendar: calendar)
    record.recordReview("gehen", at: date(5), calendar: calendar)

    record.recordOpen("gehen", at: date(6), calendar: calendar)

    #expect(record.entries["gehen"]?.review == ReviewSchedule(box: 0, due: startOf(7)))
  }

  @Test func anOpenFromTheReviewCardKeepsTheSchedule() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1), calendar: calendar)
    record.recordReview("gehen", at: date(2), calendar: calendar)
    let reviewed = record.entries["gehen"]?.review

    record.recordOpen("gehen", at: date(2), schedulesReview: false, calendar: calendar)

    #expect(record.entries["gehen"]?.review == reviewed)
    #expect(record.entries["gehen"]?.openCount == 2)
  }

  @Test func anEntryFromBeforeTheScheduleIsDueTheDayAfterItsLastOpen() throws {
    let lastOpened = date(4)
    let json = #"{"entries":{"gehen":{"infinitiv":"gehen","openCount":1,"lastOpened":\#(lastOpened.timeIntervalSinceReferenceDate)}}}"#
    var record = try #require(LearnerVerbs(json: json))

    #expect(record.entries["gehen"]?.review == nil)
    #expect(record.dueForReview(at: date(4), calendar: calendar).isEmpty)
    #expect(record.dueForReview(at: date(5), calendar: calendar) == ["gehen"])

    record.recordReview("gehen", at: date(5), calendar: calendar)
    #expect(record.entries["gehen"]?.review == ReviewSchedule(box: 1, due: startOf(8)))
  }

  @Test func aStarredVerbNeverOpenedIsNeverDue() {
    var record = LearnerVerbs()
    record.setStarred(true, infinitiv: "gehen", at: date(1))

    #expect(record.dueForReview(at: date(30), calendar: calendar).isEmpty)
  }

  @Test func clearingRecentsEndsTheirReviews() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1), calendar: calendar)
    record.setStarred(true, infinitiv: "gehen", at: date(1))

    record.clearRecents()

    #expect(record.dueForReview(at: date(30), calendar: calendar).isEmpty)
  }

  @Test func reviewingAVerbNotInTheRecordChangesNothing() {
    var record = LearnerVerbs()
    record.recordOpen("sein", at: date(1), calendar: calendar)
    let before = record

    record.recordReview("gehen", at: date(2), calendar: calendar)
    record.snoozeReview("gehen", at: date(2), calendar: calendar)

    #expect(record == before)
  }

  @Test(arguments: [(10, 23, 0), (11, 0, 1), (13, 7, 3)])
  func daysSinceOpenedCountsCalendarDays(day: Int, hour: Int, expected: Int) {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(10, hour: 22), calendar: calendar)

    #expect(record.daysSinceOpened("gehen", at: date(day, hour: hour), calendar: calendar) == expected)
  }

  @Test func theScheduleSurvivesTheJSONRoundTrip() throws {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1), calendar: calendar)
    record.recordReview("gehen", at: date(2), calendar: calendar)

    let json = try #require(record.json)
    #expect(LearnerVerbs(json: json) == record)
  }

  @Test func theStoreOffersTheLongestOverdueVerbAndSkipsAnOpenFromTheCard() {
    let getterSetter = GetterSetterFake()
    let store = LearnerVerbStore(getterSetter: getterSetter)
    let gehen = Verb.verbs["gehen"]!
    let sein = Verb.verbs["sein"]!
    let tenDaysAgo = Date.now.addingTimeInterval(-10 * 86_400)
    store.recordOpen(gehen, source: .search, at: tenDaysAgo)
    store.recordOpen(sein, source: .browse, at: tenDaysAgo.addingTimeInterval(86_400))

    #expect(store.verbDueForReview() == gehen)

    store.recordReview(gehen)
    store.recordOpen(gehen, source: .reviewCard)
    #expect(store.verbDueForReview() == sein)

    let reloaded = LearnerVerbStore(getterSetter: getterSetter)
    #expect(reloaded.verbDueForReview() == sein)
    reloaded.snoozeReview(sein)
    #expect(reloaded.verbDueForReview() == nil)
  }
}
