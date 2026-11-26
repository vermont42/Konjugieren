// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// A session drawn from the practice record rather than from a level's pool: Review, of whatever
/// is due, and Practice My Mistakes, of what was last answered wrongly.
enum QuizRecordSession: CaseIterable {
  case mistakes
  case review

  /// The record's items for the session, in the order it asks them: the most overdue first for
  /// Review, and the most recently missed first for My Mistakes.
  func items(from practice: PracticeStore, at date: Date = .now) -> [PracticeItem] {
    switch self {
    case .mistakes:
      return practice.missedItems()
    case .review:
      return practice.dueItems(at: date)
    }
  }

  /// How many of the session's items can be asked, which the Quiz tab shows. An item whose verb
  /// has left the corpus, or whose reading is no longer strong, is not counted.
  func askableCount(from practice: PracticeStore, at date: Date = .now) -> Int {
    items(from: practice, at: date).filter(\.isAskable).count
  }

  var title: String {
    switch self {
    case .mistakes:
      return L.PracticeSession.mistakes
    case .review:
      return L.PracticeSession.review
    }
  }

  var source: AnalyticsSource {
    switch self {
    case .mistakes:
      return .mistakes
    case .review:
      return .review
    }
  }
}

extension PracticeItem {
  /// Whether a Review or My Mistakes session can ask the item: a pattern this version can read,
  /// or a key conjugation of a verb still in the corpus whose reading is still strong or mixed.
  var isAskable: Bool {
    switch self {
    case .keyConjugation:
      return verb != nil && conjugationgroup != nil
    case .pattern:
      return conjugationgroup != nil
    }
  }
}

extension QuizDraw {
  /// A round of a Review or My Mistakes session: a question for each of the first `limit` items
  /// that can be asked, beyond the level's pool and band, since the learner practiced or looked up
  /// each one (the default quiz leaves Review the items its level keeps out). A pattern asks
  /// its cell of a weak verb from `verbs`, the learner's band. Items in `excluded`, the session's
  /// earlier rounds, are skipped, since a mistake missed again would otherwise return in Ten More.
  ///
  /// A verb's key conjugations sit together, in the order the verb page shows them, at the place
  /// of the first one drawn, so that a review of fahren reads fährt · fuhr · ist gefahren.
  static func sessionQuestions(
    for items: [PracticeItem],
    verbs: [Verb],
    excluded: Set<String> = [],
    limit: Int = Quiz.questionCount, // swiftlint:disable:this function_default_parameter_at_end
    using generator: inout some RandomNumberGenerator
  ) -> [QuizDrawnQuestion] {
    let available = items.filter { !excluded.contains($0.key) }
    let drawn = recordQuestions(for: available, pool: nil, verbs: verbs, limit: limit, using: &generator)
    var groupOrder: [String] = []
    var groups: [String: [(item: PracticeItem, question: QuizDrawnQuestion)]] = [:]
    for entry in drawn {
      let groupKey: String
      if case let .keyConjugation(infinitiv, readingIndex, _) = entry.item {
        groupKey = "\(infinitiv):\(readingIndex)"
      } else {
        groupKey = entry.item.key
      }
      if groups[groupKey] == nil {
        groupOrder.append(groupKey)
      }
      groups[groupKey, default: []].append(entry)
    }
    return groupOrder.flatMap { groupKey in
      (groups[groupKey] ?? [])
        .sorted { stemOrder($0.item) < stemOrder($1.item) }
        .map(\.question)
    }
  }

  private static func stemOrder(_ item: PracticeItem) -> Int {
    guard case let .keyConjugation(_, _, stem) = item else {
      return 0
    }
    return PracticeItem.Stem.allCases.firstIndex(of: stem) ?? 0
  }
}

extension QuizScope {
  /// Review or My Mistakes, from the Quiz tab: up to ten items, then Ten More while any remain,
  /// never ranked, and mixing in nothing.
  static func recordSession(_ session: QuizRecordSession) -> QuizScope {
    QuizScope(kind: .recordSession(session), verbs: nil, readingIndex: nil, questionCount: Quiz.questionCount, source: session.source)
  }
}
