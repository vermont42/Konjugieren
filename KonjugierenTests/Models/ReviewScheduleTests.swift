// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

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

  @Test func aStartIsDueTheNextMorning() {
    let schedule = ReviewSchedule.start(at: date(10, hour: 23), calendar: calendar)

    #expect(schedule.box == 0)
    #expect(schedule.due == startOf(11))
    #expect(!schedule.isDue(at: date(10, hour: 23)))
    #expect(schedule.isDue(at: startOf(11)))
  }

  @Test func reviewsClimbTheLadderAndStayOnItsLastRung() {
    var schedule = ReviewSchedule.start(at: date(1), calendar: calendar)
    var dueDays: [Int] = []
    for _ in 0..<6 {
      schedule = schedule.reviewed(at: schedule.due, calendar: calendar)
      dueDays.append(calendar.dateComponents([.day], from: startOf(1), to: schedule.due).day ?? -1)
    }

    // Started on the 1st and due on the 2nd; then 3, 7, 14, 30, and 30 days after each review.
    #expect(dueDays == [4, 11, 25, 55, 85, 115])
    #expect(schedule.box == ReviewSchedule.intervals.count - 1)
  }

  @Test func aSnoozeKeepsTheBoxAndWaitsADay() {
    let schedule = ReviewSchedule.start(at: date(1), calendar: calendar).reviewed(at: date(2), calendar: calendar)

    let snoozed = schedule.snoozed(at: date(5, hour: 8), calendar: calendar)

    #expect(snoozed.box == schedule.box)
    #expect(snoozed.due == startOf(6))
  }

  @Test func aRightAnswerWhenDueMovesUpABox() {
    let schedule = ReviewSchedule(box: 2, due: startOf(5))

    #expect(schedule.answered(correctly: true, at: date(6), calendar: calendar) == ReviewSchedule(box: 3, due: startOf(20)))
  }

  @Test func aRightAnswerBeforeTheDueDateChangesNothing() {
    let schedule = ReviewSchedule(box: 2, due: startOf(9))

    #expect(schedule.answered(correctly: true, at: date(6), calendar: calendar) == schedule)
  }

  @Test(arguments: [true, false])
  func aWrongAnswerStartsOverWhetherOrNotDue(isDue: Bool) {
    let schedule = ReviewSchedule(box: 4, due: isDue ? startOf(5) : startOf(30))

    #expect(schedule.answered(correctly: false, at: date(6), calendar: calendar) == ReviewSchedule(box: 0, due: startOf(7)))
  }

  @Test func aNewItemAnsweredRightWaitsThreeDaysAndWrongWaitsOne() {
    let new = ReviewSchedule.new(at: date(6))

    #expect(new.answered(correctly: true, at: date(6), calendar: calendar) == ReviewSchedule(box: 1, due: startOf(9)))
    #expect(new.answered(correctly: false, at: date(6), calendar: calendar) == ReviewSchedule(box: 0, due: startOf(7)))
  }

  // Germany's clocks went forward on 2026-03-29, a day of 23 hours, and back on 2026-10-25, a day
  // of 25. A due date counted in seconds would land at 01:00 or 23:00 after either, and an item
  // due at 23:00 would come due the evening before its day.
  private static let berlinCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Europe/Berlin") ?? .gmt
    return calendar
  }()

  private func berlin(month: Int, day: Int, hour: Int) -> Date {
    Self.berlinCalendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour)) ?? .distantPast
  }

  @Test(arguments: zip([3, 10], [29, 25]))
  func aDueDateCrossingAClockChangeFallsAtMidnight(month: Int, day: Int) {
    let start = ReviewSchedule.start(at: berlin(month: month, day: day, hour: 12), calendar: Self.berlinCalendar)
    let snoozed = start.snoozed(at: berlin(month: month, day: day, hour: 23), calendar: Self.berlinCalendar)
    let reviewed = ReviewSchedule(box: 0, due: .distantPast).reviewed(at: berlin(month: month, day: day - 1, hour: 20), calendar: Self.berlinCalendar)

    #expect(start.due == berlin(month: month, day: day + 1, hour: 0))
    #expect(snoozed.due == berlin(month: month, day: day + 1, hour: 0))
    #expect(reviewed == ReviewSchedule(box: 1, due: berlin(month: month, day: day + 2, hour: 0)))
  }
}
