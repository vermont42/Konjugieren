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

  /// The verb whose folded infinitive is fewest edits from the folded query, the more frequent
  /// on a tie, for a search that matched nothing. Nil when no verb is near enough to be a
  /// plausible misspelling.
  static func closestVerb(to query: String, in verbs: [Verb]) -> Verb? {
    let foldedQuery = Array(fold(query.trimmingCharacters(in: .whitespacesAndNewlines)))
    guard !foldedQuery.isEmpty else {
      return nil
    }
    let maxDistance = maxGuessDistance(forQueryLength: foldedQuery.count)
    var best: (verb: Verb, distance: Int)?
    for verb in verbs {
      let candidate = Array(keys(for: verb).foldedInfinitiv)
      guard abs(candidate.count - foldedQuery.count) <= maxDistance else {
        continue
      }
      let distance = editDistance(foldedQuery, candidate)
      guard distance <= maxDistance else {
        continue
      }
      if let current = best, (current.distance, current.verb.frequency) <= (distance, verb.frequency) {
        continue
      }
      best = (verb, distance)
    }
    return best?.verb
  }

  // One edit in three letters, and never more than three, keeps a guess recognizable: gehn
  // finds gehen, but a four-letter query never "finds" a verb that shares one letter with it.
  nonisolated static func maxGuessDistance(forQueryLength length: Int) -> Int {
    min(3, max(1, length / 3))
  }

  /// Insertions, deletions, substitutions, and swaps of two adjacent letters each cost one,
  /// because a swap is the commonest slip on a keyboard (ghen for gehen).
  nonisolated static func editDistance(_ lhs: [Character], _ rhs: [Character]) -> Int {
    guard !lhs.isEmpty else {
      return rhs.count
    }
    guard !rhs.isEmpty else {
      return lhs.count
    }
    var twoRowsBack = [Int](repeating: 0, count: rhs.count + 1)
    var previousRow = Array(0...rhs.count)
    var currentRow = [Int](repeating: 0, count: rhs.count + 1)
    for i in 1...lhs.count {
      currentRow[0] = i
      for j in 1...rhs.count {
        let substitutionCost = lhs[i - 1] == rhs[j - 1] ? 0 : 1
        currentRow[j] = min(previousRow[j] + 1, currentRow[j - 1] + 1, previousRow[j - 1] + substitutionCost)
        if i > 1, j > 1, lhs[i - 1] == rhs[j - 2], lhs[i - 2] == rhs[j - 1] {
          currentRow[j] = min(currentRow[j], twoRowsBack[j - 2] + 1)
        }
      }
      (twoRowsBack, previousRow, currentRow) = (previousRow, currentRow, twoRowsBack)
    }
    return previousRow[rhs.count]
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
