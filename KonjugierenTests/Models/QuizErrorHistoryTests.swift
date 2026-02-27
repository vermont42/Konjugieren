// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite("QuizErrorHistory", .serialized)
@MainActor
struct QuizErrorHistoryTests {
  private func makeRecord(
    infinitiv: String = "singen",
    conjugationgroupKey: String = "Present Indicative",
    familyDescription: String = "Strong",
    userAnswer: String = "singt",
    correctAnswer: String = "singe"
  ) -> QuizErrorRecord {
    QuizErrorRecord(
      infinitiv: infinitiv,
      conjugationgroupKey: conjugationgroupKey,
      familyDescription: familyDescription,
      userAnswer: userAnswer,
      correctAnswer: correctAnswer,
      timestamp: Date()
    )
  }

  @Test func loadReturnsEmptyForFreshStorage() {
    let fake = GetterSetterFake()
    let records = QuizErrorHistory.load(getterSetter: fake)
    #expect(records.isEmpty)
  }

  @Test func recordAndLoad() {
    let fake = GetterSetterFake()
    let record = makeRecord()
    QuizErrorHistory.record(record, getterSetter: fake)
    let loaded = QuizErrorHistory.load(getterSetter: fake)
    #expect(loaded.count == 1)
    #expect(loaded[0].infinitiv == "singen")
    #expect(loaded[0].conjugationgroupKey == "Present Indicative")
  }

  @Test func multipleRecords() {
    let fake = GetterSetterFake()
    QuizErrorHistory.record(makeRecord(infinitiv: "gehen"), getterSetter: fake)
    QuizErrorHistory.record(makeRecord(infinitiv: "sehen"), getterSetter: fake)
    QuizErrorHistory.record(makeRecord(infinitiv: "fahren"), getterSetter: fake)
    let loaded = QuizErrorHistory.load(getterSetter: fake)
    #expect(loaded.count == 3)
  }

  @Test func capsAtMaxRecords() {
    let fake = GetterSetterFake()
    for i in 0..<(QuizErrorHistory.maxRecords + 10) {
      QuizErrorHistory.record(makeRecord(infinitiv: "verb\(i)"), getterSetter: fake)
    }
    let loaded = QuizErrorHistory.load(getterSetter: fake)
    #expect(loaded.count == QuizErrorHistory.maxRecords)
    #expect(loaded[0].infinitiv == "verb10")
  }

  @Test func aggregatedGroupsByConjugationgroup() {
    let fake = GetterSetterFake()
    QuizErrorHistory.record(makeRecord(conjugationgroupKey: "Present Indicative"), getterSetter: fake)
    QuizErrorHistory.record(makeRecord(conjugationgroupKey: "Present Indicative"), getterSetter: fake)
    QuizErrorHistory.record(makeRecord(conjugationgroupKey: "Simple Past"), getterSetter: fake)

    let aggregated = QuizErrorHistory.aggregated(getterSetter: fake)
    #expect(aggregated.contains("Present Indicative: 2"))
    #expect(aggregated.contains("Simple Past: 1"))
  }

  @Test func aggregatedReturnsEmptyForNoRecords() {
    let fake = GetterSetterFake()
    let aggregated = QuizErrorHistory.aggregated(getterSetter: fake)
    #expect(aggregated.isEmpty)
  }

  @Test func loadHandlesCorruptData() {
    let fake = GetterSetterFake()
    fake.set(key: QuizErrorHistory.storageKey, value: "not valid json")
    let records = QuizErrorHistory.load(getterSetter: fake)
    #expect(records.isEmpty)
  }
}
