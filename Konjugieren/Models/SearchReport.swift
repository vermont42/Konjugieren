// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// Follows one search from its first letter until it ends, so that `finishSearch` is sent once
/// per search. A search ends when a result is opened, when the field is cleared, or when the app
/// leaves the foreground with text in the field. Returning to the results and opening another
/// verb from the same text is not a new search; editing the text is.
struct SearchTracker {
  private(set) var query: String?

  /// The query of the search that this change ended by clearing the field, if it ended one.
  mutating func textChanged(to text: String) -> String? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isEmpty else {
      query = trimmed
      return nil
    }
    return finish()
  }

  /// The query of the search in progress, which this call ends.
  mutating func finish() -> String? {
    defer {
      query = nil
    }
    return query
  }
}

/// The parameters of one `finishSearch` signal. Every value comes from a fixed vocabulary or a
/// band, so nothing typed leaves the device.
struct SearchReport: Equatable {
  let outcome: SearchOutcome
  let queryLength: Int
  let resultCount: Int
  let matchKind: SearchMatchKind
  let resultPosition: Int?

  /// `resultCount` counts verbs, including those inside a folded row. `position` counts rows
  /// as shown, so an open folded row's verbs follow it.
  static func opened(query: String, resultCount: Int, kind: VerbSearch.MatchKind, position: Int) -> SearchReport {
    SearchReport(
      outcome: .opened,
      queryLength: query.count,
      resultCount: resultCount,
      matchKind: kind.analyticsValue,
      resultPosition: position
    )
  }

  static func openedGuess(query: String) -> SearchReport {
    SearchReport(outcome: .opened, queryLength: query.count, resultCount: 0, matchKind: .guess, resultPosition: 0)
  }

  /// A search that ended without a verb opened. Its match kind is the top result's, which says
  /// what the learner saw first and passed over.
  static func ended(query: String, matches: [VerbSearch.Match]) -> SearchReport {
    SearchReport(
      outcome: matches.isEmpty ? .noResult : .abandoned,
      queryLength: query.count,
      resultCount: matches.count,
      matchKind: matches.first?.kind.analyticsValue ?? .none,
      resultPosition: nil
    )
  }

  var parameters: [String: String] {
    [
      ParameterKey.outcome.rawValue: outcome.rawValue,
      ParameterKey.queryLength.rawValue: AnalyticsBand.queryLength(queryLength),
      ParameterKey.resultCount.rawValue: AnalyticsBand.resultCount(resultCount),
      ParameterKey.matchKind.rawValue: matchKind.rawValue,
      ParameterKey.resultPosition.rawValue: AnalyticsBand.resultPosition(resultPosition),
    ]
  }
}

extension VerbSearch.MatchKind {
  var analyticsValue: SearchMatchKind {
    switch self {
    case .exactInfinitive:
      return .exactInfinitive
    case .exactFoldedInfinitive:
      return .exactFoldedInfinitive
    case .conjugation:
      return .conjugation
    case .finitePart:
      return .finitePart
    case .infinitivePrefix:
      return .infinitivePrefix
    case .wholeWordGloss:
      return .wholeWordGloss
    case .infinitiveSubstring:
      return .infinitiveSubstring
    case .foldedConjugation:
      return .foldedConjugation
    case .foldedInfinitivePrefix:
      return .foldedInfinitivePrefix
    case .foldedInfinitiveSubstring:
      return .foldedInfinitiveSubstring
    case .glossSubstring:
      return .glossSubstring
    }
  }
}
