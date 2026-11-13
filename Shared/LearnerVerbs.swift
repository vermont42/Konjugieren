// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The learner's own verbs: each verb opened, when and how often, each verb starred, and when
/// each is due on the review card. It is kept in the App Group's shared defaults, so the widget
/// extension can read what the app writes. It names verbs by infinitive, because the widget has
/// no corpus.
nonisolated struct LearnerVerbs: Codable, Equatable, Sendable {
  // A field added later must be optional. Synthesized decoding ignores a default value and
  // requires the key, so any other field would fail to decode every record written before it,
  // and the learner's verbs would silently vanish.
  struct Entry: Codable, Equatable, Sendable {
    let infinitiv: String
    var firstOpened: Date?
    var lastOpened: Date?
    var openCount = 0
    var starred: Date?
    var review: ReviewSchedule?

    var isStarred: Bool {
      starred != nil
    }

    /// An entry written before the review card had no schedule. It is treated as looked up on
    /// its last open, so the card has verbs to offer from the first day.
    func reviewSchedule(calendar: Calendar) -> ReviewSchedule? {
      review ?? lastOpened.map { ReviewSchedule.lookedUp(at: $0, calendar: calendar) }
    }
  }

  static let storageKey = "learnerVerbs"
  static let recentLimit = 20

  private(set) var entries: [String: Entry] = [:]

  init() {}

  init?(json: String) {
    guard
      let data = json.data(using: .utf8),
      let decoded = try? JSONDecoder().decode(LearnerVerbs.self, from: data)
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

  func isStarred(_ infinitiv: String) -> Bool {
    entries[infinitiv]?.isStarred ?? false
  }

  /// Whether the verb has been opened since its opens were last forgotten. A collection counts
  /// these toward its progress.
  func hasOpened(_ infinitiv: String) -> Bool {
    entries[infinitiv]?.lastOpened != nil
  }

  /// Starred verbs, the most recently starred first.
  var starred: [String] {
    newestFirst(by: \.starred)
  }

  /// Opened verbs, the most recently opened first.
  func recent(limit: Int = recentLimit) -> [String] {
    Array(newestFirst(by: \.lastOpened).prefix(limit))
  }

  /// What My Verbs holds: the starred verbs, then the recent ones not starred.
  var myVerbs: [String] {
    let starred = self.starred
    let starredSet = Set(starred)
    return starred + recent().filter { !starredSet.contains($0) }
  }

  /// The verbs due on the review card, the longest overdue first.
  func dueForReview(at date: Date, calendar: Calendar = .current) -> [String] {
    let due: [(infinitiv: String, due: Date)] = entries.values.compactMap { entry in
      guard let schedule = entry.reviewSchedule(calendar: calendar), schedule.isDue(at: date) else {
        return nil
      }
      return (entry.infinitiv, schedule.due)
    }
    return due
      .sorted { lhs, rhs in
        lhs.due != rhs.due ? lhs.due < rhs.due : lhs.infinitiv < rhs.infinitiv
      }
      .map(\.infinitiv)
  }

  /// Whole days from the verb's last open to `date`, counted by the calendar: 1 for yesterday.
  func daysSinceOpened(_ infinitiv: String, at date: Date, calendar: Calendar = .current) -> Int? {
    guard let lastOpened = entries[infinitiv]?.lastOpened else {
      return nil
    }
    return calendar.dateComponents([.day], from: calendar.startOfDay(for: lastOpened), to: calendar.startOfDay(for: date)).day
  }

  /// An open puts the verb in the review ladder's first box, or back there: looking a verb up
  /// again suggests it was forgotten, Leitner's wrong answer. An open from the review card itself
  /// is the exception, since the learner has just reviewed the verb.
  mutating func recordOpen(_ infinitiv: String, at date: Date, schedulesReview: Bool = true, calendar: Calendar = .current) {
    var entry = entries[infinitiv] ?? Entry(infinitiv: infinitiv)
    entry.firstOpened = entry.firstOpened ?? date
    entry.lastOpened = date
    entry.openCount += 1
    if schedulesReview || entry.review == nil {
      entry.review = .lookedUp(at: date, calendar: calendar)
    }
    entries[infinitiv] = entry
  }

  mutating func recordReview(_ infinitiv: String, at date: Date, calendar: Calendar = .current) {
    updateSchedule(of: infinitiv, calendar: calendar) { $0.reviewed(at: date, calendar: calendar) }
  }

  mutating func snoozeReview(_ infinitiv: String, at date: Date, calendar: Calendar = .current) {
    updateSchedule(of: infinitiv, calendar: calendar) { $0.snoozed(at: date, calendar: calendar) }
  }

  mutating func setStarred(_ isStarred: Bool, infinitiv: String, at date: Date) {
    var entry = entries[infinitiv] ?? Entry(infinitiv: infinitiv)
    entry.starred = isStarred ? (entry.starred ?? date) : nil
    store(entry)
  }

  /// Forgets the verb: its star and its opens. Unstarring alone would move an opened verb from
  /// the starred verbs to the recent ones, and a verb deleted from My Verbs should leave it.
  mutating func remove(_ infinitiv: String) {
    entries[infinitiv] = nil
  }

  /// Forgets every verb opened, and with the opens their reviews. Stars stay.
  mutating func clearRecents() {
    for (infinitiv, entry) in entries {
      store(Entry(infinitiv: infinitiv, starred: entry.starred))
    }
  }

  /// The infinitives of the entries that have the date, newest first. Equal dates fall back to
  /// the infinitive, so the order never depends on the dictionary's.
  private func newestFirst(by date: KeyPath<Entry, Date?>) -> [String] {
    let dated: [(infinitiv: String, date: Date)] = entries.values.compactMap { entry in
      guard let date = entry[keyPath: date] else {
        return nil
      }
      return (entry.infinitiv, date)
    }
    return dated
      .sorted { lhs, rhs in
        lhs.date != rhs.date ? lhs.date > rhs.date : lhs.infinitiv < rhs.infinitiv
      }
      .map(\.infinitiv)
  }

  private mutating func updateSchedule(of infinitiv: String, calendar: Calendar, _ change: (ReviewSchedule) -> ReviewSchedule) {
    guard var entry = entries[infinitiv], let schedule = entry.reviewSchedule(calendar: calendar) else {
      return
    }
    entry.review = change(schedule)
    entries[infinitiv] = entry
  }

  private mutating func store(_ entry: Entry) {
    entries[entry.infinitiv] = entry.starred == nil && entry.lastOpened == nil ? nil : entry
  }
}
