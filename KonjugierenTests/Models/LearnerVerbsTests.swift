// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
struct LearnerVerbsTests {
  private let day: TimeInterval = 86_400

  private func date(_ days: Double) -> Date {
    Date(timeIntervalSinceReferenceDate: days * day)
  }

  @Test func recordOpenKeepsFirstAndLastDatesAndCount() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1))
    record.recordOpen("gehen", at: date(3))

    let entry = record.entries["gehen"]
    #expect(entry?.firstOpened == date(1))
    #expect(entry?.lastOpened == date(3))
    #expect(entry?.openCount == 2)
    #expect(entry?.isStarred == false)
  }

  @Test func recentIsNewestFirst() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1))
    record.recordOpen("sein", at: date(2))
    record.recordOpen("haben", at: date(3))
    record.recordOpen("gehen", at: date(4))

    #expect(record.recent() == ["gehen", "haben", "sein"])
  }

  @Test func recentStopsAtItsLimit() {
    var record = LearnerVerbs()
    for index in 0..<(LearnerVerbs.recentLimit + 5) {
      record.recordOpen("verb\(index)", at: date(Double(index)))
    }

    let recent = record.recent()
    #expect(recent.count == LearnerVerbs.recentLimit)
    #expect(recent.first == "verb\(LearnerVerbs.recentLimit + 4)")
  }

  @Test func equalDatesFallBackToTheInfinitive() {
    var record = LearnerVerbs()
    record.recordOpen("sein", at: date(1))
    record.recordOpen("gehen", at: date(1))

    #expect(record.recent() == ["gehen", "sein"])
  }

  @Test func starringAndUnstarring() {
    var record = LearnerVerbs()
    record.setStarred(true, infinitiv: "gehen", at: date(1))
    record.setStarred(true, infinitiv: "sein", at: date(2))
    #expect(record.isStarred("gehen"))
    #expect(record.starred == ["sein", "gehen"])

    record.setStarred(false, infinitiv: "gehen", at: date(3))
    #expect(!record.isStarred("gehen"))
    #expect(record.starred == ["sein"])
  }

  @Test func starringAgainKeepsTheFirstDate() {
    var record = LearnerVerbs()
    record.setStarred(true, infinitiv: "gehen", at: date(1))
    record.setStarred(true, infinitiv: "gehen", at: date(5))

    #expect(record.entries["gehen"]?.starred == date(1))
  }

  @Test func unstarringAVerbNeverOpenedForgetsIt() {
    var record = LearnerVerbs()
    record.setStarred(true, infinitiv: "gehen", at: date(1))
    record.setStarred(false, infinitiv: "gehen", at: date(2))

    #expect(record.entries.isEmpty)
  }

  @Test func unstarringAnOpenedVerbKeepsItsOpens() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1))
    record.setStarred(true, infinitiv: "gehen", at: date(2))
    record.setStarred(false, infinitiv: "gehen", at: date(3))

    #expect(record.recent() == ["gehen"])
    #expect(record.entries["gehen"]?.openCount == 1)
  }

  @Test func myVerbsListsStarredThenRecentWithoutRepeats() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1))
    record.recordOpen("sein", at: date(2))
    record.setStarred(true, infinitiv: "sein", at: date(3))
    record.setStarred(true, infinitiv: "können", at: date(4))

    #expect(record.myVerbs == ["können", "sein", "gehen"])
  }

  @Test func clearRecentsKeepsStars() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1))
    record.recordOpen("sein", at: date(2))
    record.setStarred(true, infinitiv: "sein", at: date(3))

    record.clearRecents()

    #expect(record.recent().isEmpty)
    #expect(record.starred == ["sein"])
    #expect(record.entries.count == 1)
    #expect(record.entries["sein"]?.openCount == 0)
  }

  @Test func removingAStarredVerbThatWasOpenedForgetsItEntirely() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1))
    record.setStarred(true, infinitiv: "gehen", at: date(2))
    record.recordOpen("sein", at: date(3))

    record.remove("gehen")

    #expect(record.starred.isEmpty)
    #expect(record.recent() == ["sein"])
    #expect(record.myVerbs == ["sein"])
  }

  @Test func removingAVerbNotInTheRecordChangesNothing() {
    var record = LearnerVerbs()
    record.recordOpen("sein", at: date(1))
    let before = record

    record.remove("gehen")

    #expect(record == before)
  }

  @Test func jsonRoundTrips() throws {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1))
    record.setStarred(true, infinitiv: "sein", at: date(2))

    let json = try #require(record.json)
    #expect(LearnerVerbs(json: json) == record)
  }

  /// A field added later, such as a due date, must stay optional, so that what an older build
  /// wrote still decodes. This pins the decoding of an entry that carries only its key and count.
  @Test func anEntryWithoutItsOptionalFieldsDecodes() throws {
    let json = #"{"entries":{"gehen":{"infinitiv":"gehen","openCount":0}}}"#

    let record = try #require(LearnerVerbs(json: json))
    #expect(record.entries["gehen"]?.lastOpened == nil)
    #expect(record.entries["gehen"]?.isStarred == false)
  }

  @Test func garbageDoesNotDecode() {
    #expect(LearnerVerbs(json: "not json") == nil)
  }

  @Test func theStoreSavesAndReloads() {
    let getterSetter = GetterSetterFake()
    let store = LearnerVerbStore(getterSetter: getterSetter)
    let gehen = Verb.verbs["gehen"]!
    let sein = Verb.verbs["sein"]!

    store.recordOpen(gehen, at: date(1))
    #expect(store.toggleStar(sein, at: date(2)))

    let reloaded = LearnerVerbStore(getterSetter: getterSetter)
    #expect(reloaded.recentVerbs.map(\.infinitiv) == ["gehen"])
    #expect(reloaded.starredVerbs.map(\.infinitiv) == ["sein"])
    #expect(reloaded.myVerbs.map(\.infinitiv) == ["sein", "gehen"])
    #expect(reloaded.isStarred(sein))

    #expect(!reloaded.toggleStar(sein, at: date(3)))
    #expect(!LearnerVerbStore(getterSetter: getterSetter).isStarred(sein))
  }

  @Test func theStoreSavesARemoval() {
    let getterSetter = GetterSetterFake()
    let store = LearnerVerbStore(getterSetter: getterSetter)
    let gehen = Verb.verbs["gehen"]!
    store.recordOpen(gehen, at: date(1))
    store.toggleStar(gehen, at: date(2))

    store.remove(gehen)

    let reloaded = LearnerVerbStore(getterSetter: getterSetter)
    #expect(reloaded.myVerbs.isEmpty)
    #expect(!reloaded.isStarred(gehen))
  }

  @Test func theStoreSkipsAVerbNoLongerInTheCorpus() {
    var record = LearnerVerbs()
    record.recordOpen("gehen", at: date(1))
    record.recordOpen("nichtverben", at: date(2))
    let getterSetter = GetterSetterFake(dictionary: [LearnerVerbs.storageKey: record.json!])

    let store = LearnerVerbStore(getterSetter: getterSetter)
    #expect(store.recentVerbs.map(\.infinitiv) == ["gehen"])
  }

  @Test func recentUnstarredLeavesOutStarredVerbs() {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let gehen = Verb.verbs["gehen"]!
    let sein = Verb.verbs["sein"]!
    store.recordOpen(gehen, at: date(1))
    store.recordOpen(sein, at: date(2))
    store.toggleStar(sein, at: date(3))

    #expect(store.recentVerbs.map(\.infinitiv) == ["sein", "gehen"])
    #expect(store.recentUnstarredVerbs.map(\.infinitiv) == ["gehen"])
  }
}
