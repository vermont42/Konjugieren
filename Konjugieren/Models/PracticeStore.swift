// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The app's view of `PracticeRecord`: it maps questions and lookups to items, saves each change
/// to the App Group's defaults, and answers in verbs for the review card.
@Observable
final class PracticeStore {
  private(set) var record: PracticeRecord
  /// The results of the last quiz the learner saw, for the Quiz tab's hub.
  private(set) var lastResult: LastQuizResult?
  /// The most right answers in one Speed Round, kept on the device and sent nowhere (Phase 21).
  private(set) var speedRoundBest: Int?
  /// The days a daily session was finished, kept on the device and sent nowhere but as a band
  /// (Phase 22).
  private(set) var dailyStreak = DailyStreak()
  /// The best ranked score at each level, by `QuizLevel.rawValue`: the first ten questions of a
  /// default quiz, what the level's leaderboard takes. Kept on the device and sent nowhere
  /// (Phase 23).
  private(set) var levelBests: [String: Int] = [:]
  private let getterSetter: GetterSetter
  private let calendar: Calendar

  /// The verb the review card offers, and what to say about it.
  struct CardOffer: Equatable {
    let verb: Verb
    let readingIndex: Int
    let items: [PracticeItem]
    /// Whole days since the item was last looked up or answered.
    let daysSinceActivity: Int?
    /// Whether that was a lookup rather than a quiz answer.
    let wasLookedUp: Bool
  }

  /// `getterSetter` must be the store that holds `LearnerVerbs`, since the first launch with a
  /// practice record migrates its review schedules.
  init(getterSetter: GetterSetter, calendar: Calendar = .current, now: Date = .now) {
    self.getterSetter = getterSetter
    self.calendar = calendar
    if let stored = getterSetter.get(key: PracticeRecord.storageKey).flatMap(PracticeRecord.init(json:)) {
      record = stored
    } else {
      record = Self.migrated(from: getterSetter, calendar: calendar)
      save()
    }
    lastResult = getterSetter.getCodable(key: LastQuizResult.storageKey)
    speedRoundBest = getterSetter.getCodable(key: Self.speedRoundBestKey)
    dailyStreak = getterSetter.getCodable(key: DailyStreak.storageKey) ?? DailyStreak()
    levelBests = getterSetter.getCodable(key: Self.levelBestsKey) ?? [:]
  }

  static let speedRoundBestKey = "speedRoundBest"
  static let levelBestsKey = "levelBests"

  var isEmpty: Bool {
    record.isEmpty
  }

  func recordAnswer(verb: Verb, conjugationgroup: Conjugationgroup, readingIndex: Int, isCorrect: Bool, at date: Date = .now) {
    let item = PracticeItem.exercised(by: conjugationgroup, of: verb, readingIndex: readingIndex)
    record.recordAnswer(item, isCorrect: isCorrect, at: date, calendar: calendar)
    save()
  }

  /// A verb page was opened. An open from the review card does not reschedule, since the learner
  /// has just reviewed the verb.
  func recordLookup(_ verb: Verb, source: AnalyticsSource, at date: Date = .now) {
    let items = PracticeItem.keyConjugations(of: verb)
    guard !items.isEmpty else {
      return
    }
    record.recordLookup(items, at: date, reschedules: source != .reviewCard, calendar: calendar)
    save()
  }

  /// The items due at `date`, the longest overdue first.
  func dueItems(at date: Date = .now) -> [PracticeItem] {
    record.dueItems(at: date)
  }

  /// The items whose last answer was wrong, the most recently missed first.
  func missedItems() -> [PracticeItem] {
    record.missedItems()
  }

  /// Whole days until Review next has an item to ask: 1 for tomorrow. Nil when nothing is
  /// scheduled.
  func daysUntilNextDue(at date: Date = .now) -> Int? {
    record.nextDue(after: date).flatMap { PracticeRecord.daysBetween(date, and: $0, calendar: calendar) }
  }

  /// The strong or mixed verb whose key conjugation is longest overdue, with every due key
  /// conjugation of that reading, since the card shows all three.
  func cardOffer(at date: Date = .now) -> CardOffer? {
    let due = record.dueItems(at: date)
    guard let first = due.first(where: { $0.verb != nil }),
          case let .keyConjugation(infinitiv, readingIndex, _) = first,
          let verb = first.verb else {
      return nil
    }
    let items = due.filter { item in
      if case let .keyConjugation(otherInfinitiv, otherReading, _) = item {
        return otherInfinitiv == infinitiv && otherReading == readingIndex
      }
      return false
    }
    let entries = PracticeItem.Stem.allCases.compactMap { stem in
      record.entry(for: .keyConjugation(infinitiv: infinitiv, readingIndex: readingIndex, stem: stem))
    }
    let latest = entries.max { ($0.lastActivity ?? .distantPast) < ($1.lastActivity ?? .distantPast) }
    return CardOffer(
      verb: verb,
      readingIndex: readingIndex,
      items: items,
      daysSinceActivity: latest?.lastActivity.flatMap { PracticeRecord.daysBetween($0, and: date, calendar: calendar) },
      wasLookedUp: latest?.wasLastLookedUp ?? true
    )
  }

  func recordReview(_ offer: CardOffer, at date: Date = .now) {
    record.recordReview(offer.items, at: date, calendar: calendar)
    save()
  }

  func snooze(_ offer: CardOffer, at date: Date = .now) {
    record.snooze(offer.items, at: date, calendar: calendar)
    save()
  }

  func recordResult(_ result: LastQuizResult) {
    lastResult = result
    getterSetter.setCodable(key: LastQuizResult.storageKey, value: result)
  }

  /// A finished Speed Round's right answers, kept when they beat the best. Returns whether they did.
  /// A round with none right sets no best.
  @discardableResult
  func recordSpeedRound(_ correctCount: Int) -> Bool {
    guard correctCount > (speedRoundBest ?? 0) else {
      return false
    }
    speedRoundBest = correctCount
    getterSetter.setCodable(key: Self.speedRoundBestKey, value: correctCount)
    return true
  }

  func levelBest(at level: QuizLevel) -> Int? {
    levelBests[level.rawValue]
  }

  /// A ranked session's score at its level, kept when it beats the level's best. Returns whether
  /// it did. A score of nothing sets no best.
  @discardableResult
  func recordRankedScore(_ score: Int, level: QuizLevel) -> Bool {
    guard score > (levelBest(at: level) ?? 0) else {
      return false
    }
    levelBests[level.rawValue] = score
    getterSetter.setCodable(key: Self.levelBestsKey, value: levelBests)
    return true
  }

  /// A daily session was finished. Returns the streak it leaves.
  @discardableResult
  func recordDailySession(at date: Date = .now) -> DailyStreak.Status {
    dailyStreak.recordSession(at: date, calendar: calendar)
    getterSetter.setCodable(key: DailyStreak.storageKey, value: dailyStreak)
    return dailyStreak.status(at: date, calendar: calendar)
  }

  func streakStatus(at date: Date = .now) -> DailyStreak.Status {
    dailyStreak.status(at: date, calendar: calendar)
  }

  /// Settings' Reset Practice, which forgets the last result, the Speed Round's best, the daily
  /// streak, and each level's best too. The record is saved empty
  /// rather than removed, so that the next launch does not migrate the old schedules again.
  func reset() {
    record.reset()
    save()
    lastResult = nil
    getterSetter.remove(key: LastQuizResult.storageKey)
    speedRoundBest = nil
    getterSetter.remove(key: Self.speedRoundBestKey)
    dailyStreak = DailyStreak()
    getterSetter.remove(key: DailyStreak.storageKey)
    levelBests = [:]
    getterSetter.remove(key: Self.levelBestsKey)
  }

  private func save() {
    if let json = record.json {
      getterSetter.set(key: PracticeRecord.storageKey, value: json)
    }
  }

  /// Browse Phase 15 kept one review schedule per verb, on `LearnerVerbs.Entry.review`, and an
  /// entry from before that phase counted as looked up on its last open. Each strong or mixed
  /// verb's schedule becomes its key conjugations' schedule. A weak verb's is dropped, since the
  /// card no longer offers weak verbs (Josh, 2026-11-14).
  private static func migrated(from getterSetter: GetterSetter, calendar: Calendar) -> PracticeRecord {
    var record = PracticeRecord()
    guard let legacy: LegacyLearnerVerbs = getterSetter.getCodable(key: LearnerVerbs.storageKey) else {
      return record
    }
    for entry in legacy.entries.values {
      guard let verb = Verb.verbs[entry.infinitiv],
            let schedule = entry.review ?? entry.lastOpened.map({ ReviewSchedule.start(at: $0, calendar: calendar) }) else {
        continue
      }
      for item in PracticeItem.keyConjugations(of: verb) {
        record.adopt(item, schedule: schedule, lastLookedUp: entry.lastOpened)
      }
    }
    return record
  }

  /// The fields of a `LearnerVerbs` record that the migration reads. Decoding ignores the rest.
  private struct LegacyLearnerVerbs: Decodable {
    struct Entry: Decodable {
      let infinitiv: String
      let lastOpened: Date?
      let review: ReviewSchedule?
    }

    let entries: [String: Entry]
  }
}
