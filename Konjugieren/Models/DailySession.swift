// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The daily session (Phase 22 of the pedagogy plan, T6.3): ten questions at the learner's level,
/// filled first from what the practice record has due and then with the default quiz's draw
/// (Josh, 2026-11-13). Finishing one extends the streak.
enum DailySession {
  static let questionCount = Quiz.questionCount
}

extension QuizScope {
  /// The daily session, from the hub's row or from the reminder. Never ranked and never continued,
  /// since a second session is a session of its own, which a repair counts.
  static func daily(source: AnalyticsSource = .daily) -> QuizScope {
    QuizScope(verbs: nil, readingIndex: nil, questionCount: DailySession.questionCount, source: source, isDaily: true)
  }
}

extension QuizDraw {
  /// A daily session's questions: the due items that the level asks and the band holds, most
  /// overdue first, up to `count`, and the default quiz's balanced draw for the rest, with the due
  /// questions placed among them at random. An item the level does not ask waits for Review, as in
  /// the default quiz.
  static func dailyQuestions(
    for dueItems: [PracticeItem],
    pool: [QuizPoolEntry],
    verbs: [Verb],
    count: Int = DailySession.questionCount,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizDrawnQuestion] {
    let due = dueQuestions(for: dueItems, pool: pool, verbs: verbs, limit: count, using: &generator)
    let drawn = questions(pool: pool, verbs: verbs, readingIndex: nil, count: count - due.count, distinctCells: false, mixesVerbs: true, using: &generator)
    return mixing(due, into: drawn, using: &generator)
  }
}

extension AnalyticsBand {
  /// The streak a daily session leaves, in the bands Josh chose on 2026-11-13.
  nonisolated static func streak(_ length: Int) -> String {
    switch length {
    case ...1:
      return "1"
    case 2...6:
      return "2-6"
    case 7...29:
      return "7-29"
    default:
      return "30+"
    }
  }
}

extension DailyStreak.Status {
  /// What the hub's row says about the streak.
  var hubDetail: String {
    switch self {
    case .none:
      return L.DailySession.description
    case let .active(length, isDoneToday):
      return isDoneToday ? L.DailySession.streakDoneToday(length) : L.DailySession.streakKeepGoing(length)
    case let .repairable(length, sessionsToday):
      return sessionsToday == 0 ? L.DailySession.repairTwo(length) : L.DailySession.repairOne(length)
    }
  }

  /// What the results say about the streak after a daily session.
  var resultsLine: String {
    switch self {
    case .none:
      return ""
    case let .active(length, _):
      return L.DailySession.streak(length)
    case let .repairable(length, sessionsToday):
      return sessionsToday == 0 ? L.DailySession.repairTwo(length) : L.DailySession.repairOne(length)
    }
  }

  /// Whether one more session today would keep the streak, which the results offer.
  var awaitsRepairSession: Bool {
    if case let .repairable(_, sessionsToday) = self {
      return sessionsToday > 0
    }
    return false
  }
}
