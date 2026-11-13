// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The app's view of `LearnerVerbs`: it records opens and stars, saves each change, and answers
/// in verbs rather than infinitives. A verb that has left the corpus is skipped.
@Observable
final class LearnerVerbStore {
  private(set) var record: LearnerVerbs
  private let getterSetter: GetterSetter

  init(getterSetter: GetterSetter) {
    self.getterSetter = getterSetter
    record = getterSetter.get(key: LearnerVerbs.storageKey).flatMap(LearnerVerbs.init(json:)) ?? LearnerVerbs()
  }

  var starredVerbs: [Verb] {
    verbs(record.starred)
  }

  var recentVerbs: [Verb] {
    verbs(record.recent())
  }

  /// The recent verbs that are not also starred, which My Verbs lists below the starred ones.
  var recentUnstarredVerbs: [Verb] {
    verbs(record.recent().filter { !record.isStarred($0) })
  }

  var myVerbs: [Verb] {
    verbs(record.myVerbs)
  }

  func isStarred(_ verb: Verb) -> Bool {
    record.isStarred(verb.infinitiv)
  }

  /// The verb the review card offers: the longest overdue.
  func verbDueForReview(at date: Date = .now) -> Verb? {
    record.dueForReview(at: date).lazy.compactMap { Verb.verbs[$0] }.first
  }

  func daysSinceOpened(_ verb: Verb, at date: Date = .now) -> Int? {
    record.daysSinceOpened(verb.infinitiv, at: date)
  }

  func recordOpen(_ verb: Verb, source: AnalyticsSource, at date: Date = .now) {
    record.recordOpen(verb.infinitiv, at: date, schedulesReview: source != .reviewCard)
    save()
  }

  func recordReview(_ verb: Verb, at date: Date = .now) {
    record.recordReview(verb.infinitiv, at: date)
    save()
  }

  func snoozeReview(_ verb: Verb, at date: Date = .now) {
    record.snoozeReview(verb.infinitiv, at: date)
    save()
  }

  /// Returns whether the verb is now starred.
  @discardableResult
  func toggleStar(_ verb: Verb, at date: Date = .now) -> Bool {
    let isStarred = !record.isStarred(verb.infinitiv)
    record.setStarred(isStarred, infinitiv: verb.infinitiv, at: date)
    save()
    return isStarred
  }

  func remove(_ verb: Verb) {
    record.remove(verb.infinitiv)
    save()
  }

  func clearRecents() {
    record.clearRecents()
    save()
  }

  private func verbs(_ infinitives: [String]) -> [Verb] {
    infinitives.compactMap { Verb.verbs[$0] }
  }

  private func save() {
    if let json = record.json {
      getterSetter.set(key: LearnerVerbs.storageKey, value: json)
    }
  }
}
