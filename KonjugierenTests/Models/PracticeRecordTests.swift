// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

@MainActor
struct PracticeRecordTests {
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

  private let präsensDu = PracticeItem.pattern(tableKey: "praesens_indikativ", person: "ss")
  private let perfektpartizip = PracticeItem.pattern(tableKey: "perfektpartizip", person: nil)

  private func keys(_ infinitiv: String, readingIndex: Int = 0) -> [PracticeItem] {
    PracticeItem.Stem.allCases.map { .keyConjugation(infinitiv: infinitiv, readingIndex: readingIndex, stem: $0) }
  }

  private func store(_ getterSetter: GetterSetter = GetterSetterFake()) -> PracticeStore {
    PracticeStore(getterSetter: getterSetter, calendar: calendar)
  }

  @Test func anAnswerClimbsWhenDueAndStartsOverWhenWrong() {
    var record = PracticeRecord()

    record.recordAnswer(präsensDu, isCorrect: true, at: date(1), calendar: calendar)
    #expect(record.entry(for: präsensDu)?.schedule == ReviewSchedule(box: 1, due: startOf(4)))

    record.recordAnswer(präsensDu, isCorrect: true, at: date(2), calendar: calendar)
    #expect(record.entry(for: präsensDu)?.schedule == ReviewSchedule(box: 1, due: startOf(4)))

    record.recordAnswer(präsensDu, isCorrect: true, at: date(4), calendar: calendar)
    #expect(record.entry(for: präsensDu)?.schedule == ReviewSchedule(box: 2, due: startOf(11)))

    record.recordAnswer(präsensDu, isCorrect: false, at: date(5), calendar: calendar)
    #expect(record.entry(for: präsensDu)?.schedule == ReviewSchedule(box: 0, due: startOf(6)))
    #expect(record.entry(for: präsensDu)?.lastAnswerWasRight == false)
    #expect(record.entry(for: präsensDu)?.lastAnswered == date(5))
  }

  @Test func dueItemsComeLongestOverdueFirst() {
    var record = PracticeRecord()
    record.recordAnswer(präsensDu, isCorrect: false, at: date(3), calendar: calendar)
    record.recordAnswer(perfektpartizip, isCorrect: false, at: date(1), calendar: calendar)
    record.recordLookup(keys("singen"), at: date(2), calendar: calendar)
    record.recordAnswer(.pattern(tableKey: "imperativ", person: "sp"), isCorrect: true, at: date(9), calendar: calendar)

    #expect(record.dueItems(at: date(9)) == [perfektpartizip] + keys("singen").sorted { $0.key < $1.key } + [präsensDu])
    #expect(record.dueItems(at: date(1)).isEmpty)
  }

  @Test func aLookupSendsKeyConjugationsBackToTheFirstBox() {
    var record = PracticeRecord()
    let präteritum = PracticeItem.keyConjugation(infinitiv: "singen", readingIndex: 0, stem: .präteritum)
    record.recordAnswer(präteritum, isCorrect: true, at: date(1), calendar: calendar)
    record.recordAnswer(präteritum, isCorrect: true, at: date(4), calendar: calendar)

    record.recordLookup(keys("singen"), at: date(6), calendar: calendar)

    for item in keys("singen") {
      #expect(record.entry(for: item)?.schedule == ReviewSchedule(box: 0, due: startOf(7)))
      #expect(record.entry(for: item)?.lastLookedUp == date(6))
    }
  }

  @Test func aLookupFromTheCardKeepsTheSchedule() {
    var record = PracticeRecord()
    record.recordLookup(keys("singen"), at: date(1), calendar: calendar)
    record.recordReview(keys("singen"), at: date(2), calendar: calendar)
    let reviewed = record.entry(for: keys("singen")[0])?.schedule

    record.recordLookup(keys("singen"), at: date(2), reschedules: false, calendar: calendar)

    #expect(reviewed == ReviewSchedule(box: 1, due: startOf(5)))
    #expect(record.entry(for: keys("singen")[0])?.schedule == reviewed)
  }

  @Test func aReviewAndASnoozeMoveOnlyDueItems() {
    var record = PracticeRecord()
    let präsens = keys("singen")[0]
    let präteritum = keys("singen")[1]
    record.recordAnswer(präsens, isCorrect: false, at: date(1), calendar: calendar)
    record.recordAnswer(präteritum, isCorrect: true, at: date(1), calendar: calendar)

    record.recordReview([präsens, präteritum], at: date(2), calendar: calendar)
    #expect(record.entry(for: präsens)?.schedule == ReviewSchedule(box: 1, due: startOf(5)))
    #expect(record.entry(for: präteritum)?.schedule == ReviewSchedule(box: 1, due: startOf(4)))

    record.snooze([präsens, präteritum], at: date(4), calendar: calendar)
    #expect(record.entry(for: präsens)?.schedule == ReviewSchedule(box: 1, due: startOf(5)))
    #expect(record.entry(for: präteritum)?.schedule == ReviewSchedule(box: 1, due: startOf(5)))
  }

  @Test func theRecordSurvivesTheJSONRoundTrip() throws {
    var record = PracticeRecord()
    record.recordAnswer(präsensDu, isCorrect: false, at: date(1), calendar: calendar)
    record.recordLookup(keys("singen"), at: date(2), calendar: calendar)

    let json = try #require(record.json)
    #expect(PracticeRecord(json: json) == record)
  }

  @Test(arguments: [(10, 23, 0), (11, 0, 1), (13, 7, 3)])
  func daysBetweenCountsCalendarDays(day: Int, hour: Int, expected: Int) {
    #expect(PracticeRecord.daysBetween(date(10, hour: 22), and: date(day, hour: hour), calendar: calendar) == expected)
  }

  @Test func everyAnswerUpdatesItsItemAndSurvivesARelaunch() throws {
    let getterSetter = GetterSetterFake()
    let practice = store(getterSetter)
    let machen = try #require(Verb.verbs["machen"])
    practice.recordAnswer(verb: machen, conjugationgroup: .präteritumIndikativ(.secondSingular), readingIndex: 0, isCorrect: false, at: date(1))

    let relaunched = store(getterSetter)
    let entry = relaunched.record.entry(for: .pattern(tableKey: "praeteritum_indikativ", person: "ss"))
    #expect(entry?.schedule == ReviewSchedule(box: 0, due: startOf(2)))
    #expect(entry?.lastAnswerWasRight == false)
  }

  @Test func aLookupOfAWeakVerbSchedulesNothing() throws {
    let practice = store()
    practice.recordLookup(try #require(Verb.verbs["machen"]), source: .browse, at: date(1))

    #expect(practice.isEmpty)
  }

  @Test func theCardOffersTheStrongVerbLongestOverdueAndSaysHowItGotThere() throws {
    let practice = store()
    let singen = try #require(Verb.verbs["singen"])
    let machen = try #require(Verb.verbs["machen"])
    practice.recordAnswer(verb: machen, conjugationgroup: .präsensIndikativ(.firstSingular), readingIndex: 0, isCorrect: false, at: date(1))
    practice.recordLookup(singen, source: .search, at: date(2))

    let offer = try #require(practice.cardOffer(at: date(5)))
    #expect(offer.verb == singen)
    #expect(offer.items == keys("singen").sorted { $0.key < $1.key })
    #expect(offer.daysSinceActivity == 3)
    #expect(offer.wasLookedUp)

    practice.recordAnswer(verb: singen, conjugationgroup: .perfektIndikativ(.firstSingular), readingIndex: 0, isCorrect: false, at: date(6))
    let practiced = try #require(practice.cardOffer(at: date(8)))
    #expect(practiced.daysSinceActivity == 2)
    #expect(!practiced.wasLookedUp)
  }

  @Test func revealingTheCardRaisesItsVerbAndDismissingItWaitsADay() throws {
    let practice = store()
    let singen = try #require(Verb.verbs["singen"])
    let sinken = try #require(Verb.verbs["sinken"])
    practice.recordLookup(singen, source: .search, at: date(1))
    practice.recordLookup(sinken, source: .search, at: date(2))

    practice.recordReview(try #require(practice.cardOffer(at: date(3))), at: date(3))
    #expect(practice.cardOffer(at: date(3))?.verb == sinken)

    practice.snooze(try #require(practice.cardOffer(at: date(3))), at: date(3))
    #expect(practice.cardOffer(at: date(3)) == nil)
    let snoozed = try #require(practice.cardOffer(at: date(4)))
    #expect(snoozed.verb == sinken)

    practice.recordReview(snoozed, at: date(4))
    #expect(practice.cardOffer(at: date(5)) == nil)
    #expect(practice.cardOffer(at: date(6))?.verb == singen)
  }

  @Test func aWeakPatternIsDueButNeverOnTheCard() throws {
    let practice = store()
    practice.recordAnswer(verb: try #require(Verb.verbs["machen"]), conjugationgroup: .perfektpartizip, readingIndex: 0, isCorrect: false, at: date(1))

    #expect(practice.dueItems(at: date(5)) == [perfektpartizip])
    #expect(practice.cardOffer(at: date(5)) == nil)
  }

  @Test func aResetIsKept() throws {
    let getterSetter = GetterSetterFake()
    let practice = store(getterSetter)
    practice.recordLookup(try #require(Verb.verbs["singen"]), source: .browse, at: date(4))
    #expect(!practice.isEmpty)

    practice.reset()

    #expect(practice.isEmpty)
    #expect(store(getterSetter).isEmpty)
  }
}
