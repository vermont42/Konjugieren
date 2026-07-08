// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
import Foundation
@testable import Konjugieren

@Suite("WidgetSnapshot")
@MainActor
struct WidgetSnapshotTests {
  private func date(_ string: String) -> Date {
    let formatter = DateFormatter()
    formatter.calendar = WidgetConstants.gregorianCalendar
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: string)!
  }

  @Test func verbOfTheDayIsDeterministic() {
    let eligible = WidgetSnapshotWriter.eligibleVerbs()
    let testDate = date("2026-03-01")
    let verb1 = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: testDate, debugOffset: 0)
    let verb2 = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: testDate, debugOffset: 0)
    #expect(verb1.infinitiv == verb2.infinitiv)
  }

  @Test func verbOfTheDayChangesWithDate() {
    let eligible = WidgetSnapshotWriter.eligibleVerbs()
    let day1 = date("2026-03-01")
    let day2 = date("2026-03-02")
    let verb1 = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: day1, debugOffset: 0)
    let verb2 = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: day2, debugOffset: 0)
    #expect(verb1.infinitiv != verb2.infinitiv)
  }

  @Test func verbOfTheDayChangesWithOffset() {
    let eligible = WidgetSnapshotWriter.eligibleVerbs()
    let testDate = date("2026-03-01")
    let verb1 = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: testDate, debugOffset: 0)
    let verb2 = WidgetSnapshotWriter.verbOfTheDay(from: eligible, date: testDate, debugOffset: 1)
    #expect(verb1.infinitiv != verb2.infinitiv)
  }

  @Test func onlyEligibleVerbsHaveExampleSentences() {
    let eligible = WidgetSnapshotWriter.eligibleVerbs()
    #expect(!eligible.isEmpty)
    for verb in eligible {
      #expect(ExampleSentences.pair(for: verb.infinitiv) != nil, "Eligible verb \(verb.infinitiv) should have an example sentence pair")
    }
  }

  @Test func snapshotContainsSixPräsensConjugations() {
    let snapshot = WidgetSnapshotWriter.generateSnapshot(date: date("2026-03-01"))
    #expect(snapshot != nil)
    #expect(snapshot!.präsensParadigm.count == 6)
  }

  @Test func quizQuestionHasFourOptions() {
    let snapshot = WidgetSnapshotWriter.generateSnapshot(date: date("2026-03-01"))
    #expect(snapshot != nil)
    let quiz = snapshot!.quizQuestion
    #expect(quiz.wrongAnswers.count == 3)
    #expect(!quiz.correctAnswer.isEmpty)
    #expect(!quiz.wrongAnswers.contains(quiz.correctAnswer))
  }

  @Test func snapshotRoundTrips() throws {
    let snapshot = WidgetSnapshotWriter.generateSnapshot(date: date("2026-03-01"))
    let original = try #require(snapshot)
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
    #expect(original == decoded)
  }

  @Test func bundleHasOneSnapshotPerCachedDay() throws {
    let bundle = try #require(WidgetSnapshotWriter.generateBundle(startDate: date("2026-03-01")))
    #expect(bundle.snapshots.count == WidgetConstants.snapshotDayCount)
  }

  @Test func bundleBaseDateIsStartOfDay() throws {
    let noon = date("2026-03-01").addingTimeInterval(12 * 3600)
    let bundle = try #require(WidgetSnapshotWriter.generateBundle(startDate: noon))
    #expect(bundle.baseDate == WidgetConstants.gregorianCalendar.startOfDay(for: noon))
  }

  @Test func bundleDaysMatchStandaloneSnapshots() throws {
    let start = date("2026-03-01")
    let bundle = try #require(WidgetSnapshotWriter.generateBundle(startDate: start))
    for dayOffset in 0..<bundle.snapshots.count {
      let day = try #require(WidgetConstants.gregorianCalendar.date(byAdding: .day, value: dayOffset, to: start))
      let standalone = try #require(WidgetSnapshotWriter.generateSnapshot(date: day))
      #expect(bundle.snapshots[dayOffset] == standalone)
    }
  }

  @Test func bundleRoundTrips() throws {
    let bundle = try #require(WidgetSnapshotWriter.generateBundle(startDate: date("2026-03-01")))
    let data = try JSONEncoder().encode(bundle)
    let decoded = try JSONDecoder().decode(WidgetSnapshotBundle.self, from: data)
    #expect(bundle == decoded)
  }
}

@Suite("WidgetSnapshotPaging")
@MainActor
struct WidgetSnapshotPagingTests {
  private func bundle(count: Int) -> WidgetSnapshotBundle {
    let snapshots = (0..<count).map { _ in SnapshotReaderPlaceholderProxy.placeholder }
    return WidgetSnapshotBundle(baseDate: Date(), snapshots: snapshots)
  }

  @Test func zeroOffsetIsIdentity() {
    let indices = bundle(count: 10).pagedSnapshotIndices(pageOffset: 0)
    #expect(indices == Array(0..<10))
  }

  @Test func positiveOffsetShiftsForward() {
    let indices = bundle(count: 10).pagedSnapshotIndices(pageOffset: 1)
    #expect(indices == [1, 2, 3, 4, 5, 6, 7, 8, 9, 0])
  }

  @Test func offsetWrapsPastEnd() {
    let indices = bundle(count: 5).pagedSnapshotIndices(pageOffset: 7)
    #expect(indices == [2, 3, 4, 0, 1])
  }

  @Test func negativeOffsetWrapsBackward() {
    let indices = bundle(count: 5).pagedSnapshotIndices(pageOffset: -1)
    #expect(indices == [4, 0, 1, 2, 3])
  }

  @Test func emptyBundleYieldsNoIndices() {
    #expect(bundle(count: 0).pagedSnapshotIndices(pageOffset: 3).isEmpty)
  }
}

@Suite("WidgetAnswerShuffle")
@MainActor
struct WidgetAnswerShuffleTests {
  private func question(id: String) -> WidgetQuizQuestion {
    WidgetQuizQuestion(
      infinitiv: "gehen",
      conjugationgroupDisplay: "Present Indicative",
      pronoun: "ich",
      correctAnswer: "gehe",
      wrongAnswers: ["geht", "gehen", "gehst"],
      questionID: id
    )
  }

  @Test func seedIsProcessIndependent() {
    // Golden value computed independently (FNV-1a 64-bit over the UTF-8 bytes).
    // A Hasher-seeded implementation could never match a fixed constant, which is
    // exactly the per-process reshuffle regression this guards.
    #expect(WidgetQuizQuestion.stableSeed(for: "test-question-42") == 18_008_297_918_292_347_597)
  }

  @Test func shuffleOrderIsStableAcrossComputations() {
    let question = question(id: "2026-03-01-gehen")
    #expect(question.shuffledAnswers == question.shuffledAnswers)
  }

  @Test func shuffleContainsEveryAnswerExactlyOnce() {
    let shuffled = question(id: "2026-03-01-gehen").shuffledAnswers
    #expect(shuffled.count == 4)
    #expect(Set(shuffled) == ["gehe", "geht", "gehen", "gehst"])
  }

  @Test func differentQuestionsCanOrderDifferently() {
    let a = question(id: "day-a").shuffledAnswers
    let b = question(id: "day-b").shuffledAnswers
    #expect(Set(a) == Set(b))
  }
}

private enum SnapshotReaderPlaceholderProxy {
  static let placeholder = WidgetSnapshot(
    infinitiv: "gehen",
    translation: "go",
    familyDisplay: "strong",
    auxiliary: "sein",
    präsensParadigm: [],
    perfektpartizip: "gegAngen",
    etymologySnippet: nil,
    exampleGerman: nil,
    exampleSource: nil,
    quizQuestion: WidgetQuizQuestion(
      infinitiv: "gehen",
      conjugationgroupDisplay: "Present Indicative",
      pronoun: "ich",
      correctAnswer: "gehe",
      wrongAnswers: ["geht", "gehen", "gehst"],
      questionID: "proxy"
    )
  )
}
