// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// What one quiz answer exercises, and what the review ladder schedules (T3.5). A strong or mixed
/// reading's question exercises one of the verb's key conjugations, the stem it is built on. A
/// weak verb's question exercises a pattern, a conjugationgroup and person that every weak verb
/// shares, since a learner who can write machte can write sagte. The app decides which question
/// maps to which item (`PracticeItemMapping.swift`). This file only names items, so that the
/// widget, which has no corpus, can read the record.
nonisolated enum PracticeItem: Hashable, Sendable {
  /// The three stems a strong verb's key conjugations show: steht auf, stand auf, ist
  /// aufgestanden.
  // Semantic ordering: the order the key conjugations are shown in.
  enum Stem: String, CaseIterable, Sendable {
    case präsens = "praesens"
    case präteritum = "praeteritum"
    case perfekt
  }

  case keyConjugation(infinitiv: String, readingIndex: Int, stem: Stem)
  /// `tableKey` is a `ConjugationTable.articleKey`, and `person` a `PersonNumber` raw value, nil
  /// for a participle.
  case pattern(tableKey: String, person: String?)

  /// The item's permanent name in the stored record. Changing it would orphan every learner's
  /// schedule for the item.
  var key: String {
    switch self {
    case let .keyConjugation(infinitiv, readingIndex, stem):
      return [Self.keyConjugationPrefix, infinitiv, "\(readingIndex)", stem.rawValue].joined(separator: Self.separator)
    case let .pattern(tableKey, person):
      return ([Self.patternPrefix, tableKey] + (person.map { [$0] } ?? [])).joined(separator: Self.separator)
    }
  }

  init?(key: String) {
    let parts = key.components(separatedBy: Self.separator)
    switch parts.first {
    case Self.keyConjugationPrefix:
      guard parts.count == 4, !parts[1].isEmpty, let readingIndex = Int(parts[2]), let stem = Stem(rawValue: parts[3]) else {
        return nil
      }
      self = .keyConjugation(infinitiv: parts[1], readingIndex: readingIndex, stem: stem)
    case Self.patternPrefix:
      guard parts.count == 2 || parts.count == 3, !parts[1].isEmpty else {
        return nil
      }
      self = .pattern(tableKey: parts[1], person: parts.count == 3 ? parts[2] : nil)
    default:
      return nil
    }
  }

  var infinitiv: String? {
    if case let .keyConjugation(infinitiv, _, _) = self {
      return infinitiv
    }
    return nil
  }

  private static let separator = ":"
  private static let keyConjugationPrefix = "key"
  private static let patternPrefix = "pattern"
}

/// The learner's practice record: a box and a due date for each item a quiz answer, a lookup, or
/// the review card has touched, and how the last answer went. It is kept in the App Group's shared
/// defaults, so that a widget or a reminder can read it, and it is never sent anywhere (Decision 5
/// of the pedagogy plan).
nonisolated struct PracticeRecord: Codable, Equatable, Sendable {
  // A field added later must be optional. Synthesized decoding ignores a default value and
  // requires the key, so any other field would fail to decode every record written before it,
  // and the learner's practice would silently vanish.
  struct Entry: Codable, Equatable, Sendable {
    var schedule: ReviewSchedule
    var lastAnswered: Date?
    /// Whether the most recent answer was right, which Phase 12's "practice my mistakes" reads.
    var lastAnswerWasRight: Bool?
    var lastLookedUp: Date?

    /// The later of the last answer and the last lookup.
    var lastActivity: Date? {
      [lastAnswered, lastLookedUp].compactMap { $0 }.max()
    }

    /// Whether the last thing to touch the item was a lookup rather than an answer.
    var wasLastLookedUp: Bool {
      guard let lastLookedUp else {
        return false
      }
      return lastAnswered.map { lastLookedUp >= $0 } ?? true
    }
  }

  static let storageKey = "practiceRecord"

  /// Keyed by `PracticeItem.key`.
  private(set) var entries: [String: Entry] = [:]

  init() {}

  init?(json: String) {
    guard
      let data = json.data(using: .utf8),
      let decoded = try? JSONDecoder().decode(PracticeRecord.self, from: data)
    else {
      return nil
    }
    self = decoded
  }

  var json: String? {
    guard let data = try? JSONEncoder().encode(self) else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }

  var isEmpty: Bool {
    entries.isEmpty
  }

  func entry(for item: PracticeItem) -> Entry? {
    entries[item.key]
  }

  /// A quiz's answer, recorded as it is given, so that a quiz quit after six questions has still
  /// practiced six (T6.4).
  mutating func recordAnswer(_ item: PracticeItem, isCorrect: Bool, at date: Date, calendar: Calendar = .current) {
    var entry = entries[item.key] ?? Entry(schedule: .new(at: date))
    entry.schedule = entry.schedule.answered(correctly: isCorrect, at: date, calendar: calendar)
    entry.lastAnswered = date
    entry.lastAnswerWasRight = isCorrect
    entries[item.key] = entry
  }

  /// A lookup puts the items in the first box, or back there: looking a verb up again suggests
  /// it was forgotten, Leitner's wrong answer. With `reschedules` false, for an open from the
  /// review card, which the learner has just reviewed, only an item not yet in the record enters.
  mutating func recordLookup(_ items: [PracticeItem], at date: Date, reschedules: Bool = true, calendar: Calendar = .current) {
    for item in items {
      var entry = entries[item.key] ?? Entry(schedule: .start(at: date, calendar: calendar))
      if reschedules {
        entry.schedule = .start(at: date, calendar: calendar)
      }
      entry.lastLookedUp = date
      entries[item.key] = entry
    }
  }

  /// The review card's conjugations were revealed, which moves each due item up a box. An item
  /// not yet due keeps its place.
  mutating func recordReview(_ items: [PracticeItem], at date: Date, calendar: Calendar = .current) {
    updateDue(items, at: date) { $0.reviewed(at: date, calendar: calendar) }
  }

  /// The review card was dismissed before its conjugations were revealed, so each due item keeps
  /// its box and returns tomorrow.
  mutating func snooze(_ items: [PracticeItem], at date: Date, calendar: Calendar = .current) {
    updateDue(items, at: date) { $0.snoozed(at: date, calendar: calendar) }
  }

  /// The items due at `date`, the longest overdue first. Equal due dates fall back to the key, so
  /// the order never depends on the dictionary's.
  func dueItems(at date: Date) -> [PracticeItem] {
    let due: [(key: String, due: Date)] = entries.compactMap { key, entry in
      entry.schedule.isDue(at: date) ? (key, entry.schedule.due) : nil
    }
    return due
      .sorted { lhs, rhs in
        lhs.due != rhs.due ? lhs.due < rhs.due : lhs.key < rhs.key
      }
      .compactMap { PracticeItem(key: $0.key) }
  }

  /// Whole days from `earlier` to `date`, counted by the calendar: 1 for yesterday.
  static func daysBetween(_ earlier: Date, and date: Date, calendar: Calendar = .current) -> Int? {
    calendar.dateComponents([.day], from: calendar.startOfDay(for: earlier), to: calendar.startOfDay(for: date)).day
  }

  mutating func reset() {
    entries = [:]
  }

  /// Folds in a schedule from before the record existed, which only the migration uses.
  mutating func adopt(_ item: PracticeItem, schedule: ReviewSchedule, lastLookedUp: Date?) {
    entries[item.key] = Entry(schedule: schedule, lastLookedUp: lastLookedUp)
  }

  private mutating func updateDue(_ items: [PracticeItem], at date: Date, _ change: (ReviewSchedule) -> ReviewSchedule) {
    for item in items {
      guard var entry = entries[item.key], entry.schedule.isDue(at: date) else {
        continue
      }
      entry.schedule = change(entry.schedule)
      entries[item.key] = entry
    }
  }
}
