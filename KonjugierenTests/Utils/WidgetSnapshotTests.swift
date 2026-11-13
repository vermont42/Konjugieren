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

  private func gehen() throws -> Verb {
    try #require(Verb.verbs["gehen"])
  }

  @Test func everyCachedVerbHasAnExampleSentence() throws {
    let myVerbs = ["abbehalten", "aufstehen"].compactMap { Verb.verbs[$0] }
    let bundle = try #require(WidgetSnapshotWriter.generateBundle(startDate: date("2026-03-01"), myVerbs: myVerbs))
    for snapshot in bundle.snapshots {
      #expect(ExampleSentences.pair(for: snapshot.infinitiv) != nil, "\(snapshot.infinitiv)")
    }
  }

  @Test func bundleWithoutMyVerbsDrawsFrequentVerbs() throws {
    let bundle = try #require(WidgetSnapshotWriter.generateBundle(startDate: date("2026-03-01")))
    for snapshot in bundle.snapshots {
      #expect(Verb.verbs[snapshot.infinitiv]?.isIn(.top1000) == true, "\(snapshot.infinitiv)")
    }
  }

  @Test(arguments: [0, 3, 12, -1])
  func keptVerbIsTheOneDisplayedToday(pageOffset: Int) throws {
    let start = date("2026-03-01")
    let kept = try #require(Verb.verbs["abbehalten"])
    let bundle = try #require(WidgetSnapshotWriter.generateBundle(startDate: start, keeping: kept, pageOffset: pageOffset))
    #expect(bundle.displayedSnapshot(at: start, pageOffset: pageOffset)?.infinitiv == "abbehalten")
  }

  @Test(arguments: [0, 4])
  func rewriteLaterInTheDayKeepsTheDisplayedVerb(pageOffset: Int) throws {
    let morning = date("2026-03-01").addingTimeInterval(7 * 3600)
    let evening = morning.addingTimeInterval(14 * 3600)
    let first = try #require(WidgetSnapshotWriter.generateBundle(startDate: morning, pageOffset: pageOffset))
    let shown = try #require(first.displayedSnapshot(at: evening, pageOffset: pageOffset))
    let myVerbs = ["abbehalten", "aufstehen", "verstehen"].compactMap { Verb.verbs[$0] }
    let second = try #require(WidgetSnapshotWriter.generateBundle(startDate: evening, myVerbs: myVerbs, keeping: Verb.verbs[shown.infinitiv], pageOffset: pageOffset))
    #expect(second.displayedSnapshot(at: evening, pageOffset: pageOffset) == shown)
  }

  @Test func rewriteOnALaterDayKeepsThatDaysVerb() throws {
    let first = try #require(WidgetSnapshotWriter.generateBundle(startDate: date("2026-03-01")))
    let nextDay = date("2026-03-03")
    let shown = try #require(first.displayedSnapshot(at: nextDay, pageOffset: 0))
    #expect(shown == first.snapshots[2])
    let second = try #require(WidgetSnapshotWriter.generateBundle(startDate: nextDay, myVerbs: [try gehen()], keeping: Verb.verbs[shown.infinitiv]))
    #expect(second.snapshots[0] == shown)
  }

  @Test func displayedSnapshotIsNilOutsideTheCachedDays() throws {
    let bundle = try #require(WidgetSnapshotWriter.generateBundle(startDate: date("2026-03-10")))
    #expect(bundle.displayedSnapshot(at: date("2026-03-09"), pageOffset: 0) == nil)
    #expect(bundle.displayedSnapshot(at: date("2026-03-20"), pageOffset: 0) == nil)
    #expect(bundle.displayedSnapshot(at: date("2026-03-19"), pageOffset: 0) == bundle.snapshots[9])
  }

  @Test func snapshotContainsSixPräsensConjugations() throws {
    let snapshot = WidgetSnapshotWriter.generateSnapshot(verb: try gehen(), date: date("2026-03-01"))
    #expect(snapshot.präsensParadigm.count == 6)
  }

  @Test func quizQuestionHasFourOptions() throws {
    let snapshot = WidgetSnapshotWriter.generateSnapshot(verb: try gehen(), date: date("2026-03-01"))
    let quiz = snapshot.quizQuestion
    #expect(quiz.wrongAnswers.count == 3)
    #expect(!quiz.correctAnswer.isEmpty)
    #expect(!quiz.wrongAnswers.contains(quiz.correctAnswer))
  }

  @Test func snapshotRoundTrips() throws {
    let original = WidgetSnapshotWriter.generateSnapshot(verb: try gehen(), date: date("2026-03-01"))
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
      let frequentVerbs = VerbDraw.frequentVerbs.filter(WidgetSnapshotWriter.isEligible)
      let verb = try #require(VerbDraw.verbOfTheDay(on: day, myVerbs: [], frequentVerbs: frequentVerbs))
      let standalone = WidgetSnapshotWriter.generateSnapshot(verb: verb, date: day)
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
