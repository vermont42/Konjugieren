// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The one matching and ranking rule for verb search, shared by the verb list and the shortcut
/// picker so that the two cannot drift.
enum VerbSearch {
  // Semantic ordering: rank, best first. Folding is a guess at what a learner meant, and a
  // query that literally spells a conjugation is not a guess, so a literal conjugation, and
  // the separable verbs it is a part of, outrank a folded infinitive: fuhren is wir fuhren,
  // and finds fahren ahead of führen (Josh, 2026-11-25). A folded infinitive still outranks
  // every partial match, so zahlen is followed directly by zählen. Whole-word gloss matches sit
  // between German prefix and German substring matches because Josh wanted "eat" to find essen
  // ahead of beatmen and "go" to find gehen ahead of gönnen, while "es" still finds essen ahead
  // of ruhen (rest). A conjugation outranks an infinitive prefix, so that war finds sein ahead
  // of warten, and a folded conjugation ranks below every literal match: zahl is zahlen's
  // Imperativ, and zählen's only after folding.
  enum MatchKind: Int, CaseIterable, Comparable {
    case exactInfinitive
    case conjugation
    case finitePart
    case exactFoldedInfinitive
    case infinitivePrefix
    case wholeWordGloss
    case infinitiveSubstring
    case foldedConjugation
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

    /// For a conjugation match, the conjugation as the app spells it, which is not always what
    /// was typed: muss for muß, and "bin gegangen" for "ich bin gegangen". For a finite part,
    /// the finite part. Nil for an infinitive or gloss match.
    let conjugation: String?

    /// For a finite part, the separable prefix that a main clause sends to the end: auf, for
    /// hielt as a part of aufhalten.
    let particle: String?

    init(verb: Verb, kind: MatchKind, conjugation: String? = nil, particle: String? = nil) {
      self.verb = verb
      self.kind = kind
      self.conjugation = conjugation
      self.particle = particle
    }
  }

  /// Ranked by match kind, then by frequency, whatever order `verbs` arrives in, with one match
  /// per verb, its best.
  ///
  /// A stranded finite part (hielt, of aufhalten) matches only with `includeFiniteParts`, and
  /// never when the query is itself an infinitive. Searching gehen lists ausgehen as a
  /// substring match, as it always has, rather than as a place where gehen is a word. A query
  /// that is an infinitive only once folded is not one: fuhren keeps fahren's separable verbs.
  static func matches(
    for query: String,
    in verbs: [Verb],
    includeGlosses: Bool,
    includeFiniteParts: Bool = true,
    index: ConjugationIndex = .bundled
  ) -> [Match] {
    let germanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !germanQuery.isEmpty else {
      return []
    }
    let foldedQuery = Verb.SearchKeys.fold(germanQuery)
    let englishQuery = includeGlosses ? glossQuery(from: germanQuery) : nil

    var verbsByInfinitiv: [String: Verb] = [:]
    var best: [String: Match] = [:]
    for verb in verbs {
      verbsByInfinitiv[verb.infinitiv] = verb
      if let kind = kind(of: verb.searchKeys, germanQuery: germanQuery, foldedQuery: foldedQuery, englishQuery: englishQuery) {
        best[verb.infinitiv] = Match(verb: verb, kind: kind)
      }
    }

    let queryIsInfinitive = best.values.contains { $0.kind == .exactInfinitive }
    let conjugationMatches = self.conjugationMatches(
      for: germanQuery,
      includeFiniteParts: includeFiniteParts && !queryIsInfinitive,
      index: index
    ) { verbsByInfinitiv[$0] }
    for match in conjugationMatches {
      if let current = best[match.verb.infinitiv], current.kind <= match.kind {
        continue
      }
      best[match.verb.infinitiv] = match
    }

    return best.values.sorted { ($0.kind, $0.verb.frequency, $0.verb.infinitiv) < ($1.kind, $1.verb.frequency, $1.verb.infinitiv) }
  }

  private static let pronouns: Set<String> = ["du", "er", "es", "ich", "ihr", "man", "sie", "wir"]

  /// One word is looked up in the conjugation map. Two words can name a separable verb by its
  /// particle (stand auf), and the last word of more than one can be the participle or
  /// infinitive of a compound conjugation (hat gefunden, wird gehen), which the verb's own
  /// cells confirm. A leading pronoun is dropped, so "ich ging" works as ging does.
  private static func conjugationMatches(
    for query: String,
    includeFiniteParts: Bool,
    index: ConjugationIndex,
    verbNamed: (String) -> Verb?
  ) -> [Match] {
    var words = query.split(whereSeparator: \.isWhitespace).map(String.init)
    if words.count > 1, pronouns.contains(words[0]) {
      words.removeFirst()
    }
    guard let lastWord = words.last else {
      return []
    }

    if words.count == 1 {
      let spellings = index.spellings(of: lastWord)
      guard !spellings.isEmpty else {
        return participleMatches(for: lastWord, index: index, verbNamed: verbNamed)
      }
      return spellings.flatMap { spelling in
        index.map.entries(for: spelling.conjugation).compactMap { entry -> Match? in
          guard let verb = verbNamed(entry.infinitiv) else {
            return nil
          }
          guard let particle = entry.particle else {
            return Match(verb: verb, kind: spelling.isFolded ? .foldedConjugation : .conjugation, conjugation: spelling.conjugation)
          }
          // Folding would let zahl gather zählen's separable verbs among zahlen's.
          guard includeFiniteParts, !spelling.isFolded else {
            return nil
          }
          return Match(verb: verb, kind: .finitePart, conjugation: spelling.conjugation, particle: particle)
        }
      }
    }

    var found: [Match] = []
    if words.count == 2 {
      let typedParticle = Verb.SearchKeys.fold(words[1])
      for spelling in index.spellings(of: words[0]) {
        for entry in index.map.entries(for: spelling.conjugation) {
          guard let particle = entry.particle, Verb.SearchKeys.fold(particle) == typedParticle, let verb = verbNamed(entry.infinitiv) else {
            continue
          }
          let isFolded = spelling.isFolded || particle != words[1]
          found.append(Match(verb: verb, kind: isFolded ? .foldedConjugation : .conjugation, conjugation: "\(spelling.conjugation) \(particle)"))
        }
      }
    }

    let leadingWords = words.dropLast().joined(separator: " ")
    for spelling in index.spellings(of: lastWord) {
      for entry in index.map.entries(for: spelling.conjugation) where entry.particle == nil {
        let conjugation = "\(leadingWords) \(spelling.conjugation)"
        guard let verb = verbNamed(entry.infinitiv), !verb.conjugations(matching: conjugation).isEmpty else {
          continue
        }
        found.append(Match(verb: verb, kind: spelling.isFolded ? .foldedConjugation : .conjugation, conjugation: conjugation))
      }
    }
    return found
  }

  private static let adjectiveEndings = ["em", "en", "er", "es", "e"]

  /// A participle used as an adjective carries an ending that the map does not: geklebte,
  /// vorgeschlagenen, laufende. Without its ending, the word must be a participle cell of the
  /// verb, so that strippable words that merely look like one (gehe less its e) match nothing.
  private static func participleMatches(for word: String, index: ConjugationIndex, verbNamed: (String) -> Verb?) -> [Match] {
    for ending in adjectiveEndings where word.hasSuffix(ending) && word.count > ending.count + 3 {
      let stem = String(word.dropLast(ending.count))
      let found = index.spellings(of: stem).flatMap { spelling in
        index.map.entries(for: spelling.conjugation).compactMap { entry -> Match? in
          guard
            entry.particle == nil,
            let verb = verbNamed(entry.infinitiv),
            verb.conjugations(matching: spelling.conjugation).contains(where: { $0.conjugationgroup.isParticiple })
          else {
            return nil
          }
          return Match(verb: verb, kind: spelling.isFolded ? .foldedConjugation : .conjugation, conjugation: spelling.conjugation)
        }
      }
      if !found.isEmpty {
        return found
      }
    }
    return []
  }

  /// A verb offered when a search matched nothing, with the conjugation it was guessed from,
  /// if it was guessed from one.
  struct Guess: Equatable {
    let verb: Verb
    let conjugation: String?
  }

  /// What the guess needs of a verb, as values that can leave the main actor.
  nonisolated struct GuessCandidate: Sendable {
    let infinitiv: String
    let foldedInfinitiv: String
    let frequency: Int
  }

  /// A guess by name, before its verb is looked up again on the main actor.
  nonisolated struct GuessFinding: Equatable, Sendable {
    let infinitiv: String
    let conjugation: String?
  }

  static func guessCandidates(of verbs: [Verb]) -> [GuessCandidate] {
    verbs.map { GuessCandidate(infinitiv: $0.infinitiv, foldedInfinitiv: $0.searchKeys.foldedInfinitiv, frequency: $0.frequency) }
  }

  static func guess(for query: String, in verbs: [Verb], index: ConjugationIndex = .bundled) -> Guess? {
    guard let finding = guess(for: query, among: guessCandidates(of: verbs), index: index) else {
      return nil
    }
    return verbs.first { $0.infinitiv == finding.infinitiv }.map { Guess(verb: $0, conjugation: finding.conjugation) }
  }

  /// The verb whose folded infinitive, or one of whose folded conjugations, is fewest edits
  /// from the folded query. On a tie, an infinitive beats a conjugation, and then the more
  /// frequent verb wins. Nil when no verb is near enough to be a plausible misspelling, and
  /// when the task running it is cancelled, since a guess for text since edited is not wanted.
  nonisolated static func guess(for query: String, among candidates: [GuessCandidate], index: ConjugationIndex = .bundled) -> GuessFinding? {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    let foldedQuery = Array(Verb.SearchKeys.fold(trimmed))
    guard !foldedQuery.isEmpty else {
      return nil
    }
    let maxDistance = maxGuessDistance(forQueryLength: foldedQuery.count)
    var best: (finding: GuessFinding, rank: (distance: Int, isConjugation: Int, frequency: Int))?

    func consider(_ finding: GuessFinding, frequency: Int, distance: Int) {
      let rank = (distance: distance, isConjugation: finding.conjugation == nil ? 0 : 1, frequency: frequency)
      if let current = best, current.rank <= rank {
        return
      }
      best = (finding, rank)
    }

    var candidatesByInfinitiv: [String: GuessCandidate] = [:]
    for candidate in candidates {
      candidatesByInfinitiv[candidate.infinitiv] = candidate
      let folded = Array(candidate.foldedInfinitiv)
      guard abs(folded.count - foldedQuery.count) <= maxDistance else {
        continue
      }
      let distance = editDistance(foldedQuery, folded, limit: maxDistance)
      if distance <= maxDistance {
        consider(GuessFinding(infinitiv: candidate.infinitiv, conjugation: nil), frequency: candidate.frequency, distance: distance)
      }
    }

    guard !trimmed.contains(" ") else {
      return best?.finding
    }
    for (folded, conjugations) in index.foldedConjugations(nearLength: foldedQuery.count, distance: maxDistance) {
      if Task.isCancelled {
        return nil
      }
      let limit = min(maxDistance, best?.rank.distance ?? maxDistance)
      let distance = editDistance(foldedQuery, Array(folded), limit: limit)
      guard distance <= limit else {
        continue
      }
      for conjugation in conjugations {
        for entry in index.map.entries(for: conjugation) where entry.particle == nil {
          guard let candidate = candidatesByInfinitiv[entry.infinitiv] else {
            continue
          }
          let isInfinitive = conjugation == candidate.infinitiv.lowercased()
          consider(GuessFinding(infinitiv: candidate.infinitiv, conjugation: isInfinitive ? nil : conjugation), frequency: candidate.frequency, distance: distance)
        }
      }
    }
    return Task.isCancelled ? nil : best?.finding
  }

  // One edit in three letters, and never more than three, keeps a guess recognizable: gehn
  // finds gehen, but a four-letter query never "finds" a verb that shares one letter with it.
  nonisolated static func maxGuessDistance(forQueryLength length: Int) -> Int {
    min(3, max(1, length / 3))
  }

  /// Insertions, deletions, substitutions, and swaps of two adjacent letters each cost one,
  /// because a swap is the commonest slip on a keyboard (ghen for gehen).
  ///
  /// With a `limit`, any distance above it is reported as `limit + 1`, and the work stops once
  /// a whole row exceeds it. That is safe because no later row has a smaller value: each cell is
  /// at most one more than the cell above it, and a swap costs one more than a cell two rows up.
  nonisolated static func editDistance(_ lhs: [Character], _ rhs: [Character], limit: Int = .max) -> Int {
    let beyondLimit = limit == .max ? limit : limit + 1
    guard !lhs.isEmpty else {
      return min(rhs.count, beyondLimit)
    }
    guard !rhs.isEmpty else {
      return min(lhs.count, beyondLimit)
    }
    var twoRowsBack = [Int](repeating: 0, count: rhs.count + 1)
    var previousRow = Array(0...rhs.count)
    var currentRow = [Int](repeating: 0, count: rhs.count + 1)
    for i in 1...lhs.count {
      currentRow[0] = i
      var rowMinimum = i
      for j in 1...rhs.count {
        let substitutionCost = lhs[i - 1] == rhs[j - 1] ? 0 : 1
        currentRow[j] = min(previousRow[j] + 1, currentRow[j - 1] + 1, previousRow[j - 1] + substitutionCost)
        if i > 1, j > 1, lhs[i - 1] == rhs[j - 2], lhs[i - 2] == rhs[j - 1] {
          currentRow[j] = min(currentRow[j], twoRowsBack[j - 2] + 1)
        }
        rowMinimum = min(rowMinimum, currentRow[j])
      }
      if rowMinimum > limit {
        return beyondLimit
      }
      (twoRowsBack, previousRow, currentRow) = (previousRow, currentRow, twoRowsBack)
    }
    return min(previousRow[rhs.count], beyondLimit)
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

  private static func kind(of keys: Verb.SearchKeys, germanQuery: String, foldedQuery: String, englishQuery: String?) -> MatchKind? {
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
