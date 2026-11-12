// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The one matching and ranking rule for verb search, shared by the verb list and the shortcut
/// picker so that the two cannot drift.
enum VerbSearch {
  // Semantic ordering: rank, best first. Whole-word gloss matches sit between German prefix
  // and German substring matches because Josh wanted "eat" to find essen ahead of beatmen and
  // "go" to find gehen ahead of gönnen, while "es" still finds essen ahead of ruhen (rest).
  enum MatchKind: Int, CaseIterable, Comparable {
    case exactInfinitive
    case exactFoldedInfinitive
    case infinitivePrefix
    case wholeWordGloss
    case infinitiveSubstring
    case foldedInfinitivePrefix
    case foldedInfinitiveSubstring
    case glossSubstring

    static func < (lhs: MatchKind, rhs: MatchKind) -> Bool {
      lhs.rawValue < rhs.rawValue
    }
  }

  struct Match: Equatable {
    let verb: Verb
    let kind: MatchKind
  }

  /// Ranked by match kind, then by frequency, whatever order `verbs` arrives in.
  static func matches(for query: String, in verbs: [Verb], includeGlosses: Bool) -> [Match] {
    let germanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !germanQuery.isEmpty else {
      return []
    }
    let foldedQuery = fold(germanQuery)
    let englishQuery = includeGlosses ? glossQuery(from: germanQuery) : nil

    return verbs
      .compactMap { verb -> Match? in
        guard let kind = kind(of: keys(for: verb), germanQuery: germanQuery, foldedQuery: foldedQuery, englishQuery: englishQuery) else {
          return nil
        }
        return Match(verb: verb, kind: kind)
      }
      .sorted { ($0.kind, $0.verb.frequency, $0.verb.infinitiv) < ($1.kind, $1.verb.frequency, $1.verb.infinitiv) }
  }

  /// Collapses the spellings a learner without a German keyboard types (konnen, koennen) and
  /// the Swiss ss onto one key. For matching only: never render it.
  nonisolated static func fold(_ text: String) -> String {
    var folded = text.lowercased()
    // Digraphs fold before umlauts. In the other order, ü followed by e would become a false
    // ue digraph and lose its e.
    for (from, to) in [("ß", "ss"), ("ae", "a"), ("oe", "o"), ("ue", "u"), ("ä", "a"), ("ö", "o"), ("ü", "u")] {
      folded = folded.replacingOccurrences(of: from, with: to)
    }
    return folded
  }

  /// Glosses are stored without a leading "to", so a learner who types "to go" means "go".
  nonisolated static func glossQuery(from query: String) -> String {
    let lowered = query.lowercased()
    guard lowered.hasPrefix("to ") else {
      return lowered
    }
    let stripped = lowered.dropFirst(3).trimmingCharacters(in: .whitespaces)
    return stripped.isEmpty ? lowered : stripped
  }

  nonisolated static func containsWholeWord(_ word: String, in text: String) -> Bool {
    var searchRange = text.startIndex..<text.endIndex
    while let range = text.range(of: word, range: searchRange) {
      let letterBefore = range.lowerBound > text.startIndex && text[text.index(before: range.lowerBound)].isLetter
      let letterAfter = range.upperBound < text.endIndex && text[range.upperBound].isLetter
      if !letterBefore && !letterAfter {
        return true
      }
      searchRange = text.index(after: range.lowerBound)..<text.endIndex
    }
    return false
  }

  private struct Keys {
    let infinitiv: String
    let foldedInfinitiv: String
    let glosses: [String]
  }

  private static var keysCache: [String: Keys] = [:]

  private static func keys(for verb: Verb) -> Keys {
    if let cached = keysCache[verb.infinitiv] {
      return cached
    }
    let infinitiv = verb.infinitiv.lowercased()
    let keys = Keys(
      infinitiv: infinitiv,
      foldedInfinitiv: fold(infinitiv),
      glosses: verb.readings.map { $0.translation.lowercased() }
    )
    keysCache[verb.infinitiv] = keys
    return keys
  }

  private static func kind(of keys: Keys, germanQuery: String, foldedQuery: String, englishQuery: String?) -> MatchKind? {
    if keys.infinitiv == germanQuery {
      return .exactInfinitive
    }
    if keys.foldedInfinitiv == foldedQuery {
      return .exactFoldedInfinitive
    }
    if keys.infinitiv.hasPrefix(germanQuery) {
      return .infinitivePrefix
    }
    if let englishQuery, keys.glosses.contains(where: { containsWholeWord(englishQuery, in: $0) }) {
      return .wholeWordGloss
    }
    if keys.infinitiv.contains(germanQuery) {
      return .infinitiveSubstring
    }
    if keys.foldedInfinitiv.hasPrefix(foldedQuery) {
      return .foldedInfinitivePrefix
    }
    if keys.foldedInfinitiv.contains(foldedQuery) {
      return .foldedInfinitiveSubstring
    }
    if let englishQuery, keys.glosses.contains(where: { $0.contains(englishQuery) }) {
      return .glossSubstring
    }
    return nil
  }
}
