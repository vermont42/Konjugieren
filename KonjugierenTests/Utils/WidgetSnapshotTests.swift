// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
import Foundation
@testable import Konjugieren

@Suite("WidgetSnapshot")
@MainActor
struct WidgetSnapshotTests {
  private func date(_ string: String) -> Date {
    let formatter = DateFormatter()
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
}
