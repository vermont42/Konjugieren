// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// What the verb list shows for one search: the matches in rank order, with the separable
/// verbs in which the query is a stranded part folded into one row, and a guess when nothing
/// matched.
struct VerbSearchResults {
  struct Hit: Hashable {
    let verb: Verb

    /// Nil for a row of the unsearched list, and for the guess.
    let kind: VerbSearch.MatchKind?

    let conjugation: MatchedConjugation?
  }

  enum Entry: Identifiable {
    case hit(Hit, isInSeparableVerbs: Bool)
    case separableVerbs([Hit])

    var id: String {
      switch self {
      case .hit(let hit, _):
        return hit.verb.infinitiv
      case .separableVerbs:
        return Self.separableVerbsID
      }
    }

    static let separableVerbsID = "separableVerbs"

    var hit: Hit? {
      switch self {
      case .hit(let hit, _):
        return hit
      case .separableVerbs:
        return nil
      }
    }

    var isInSeparableVerbs: Bool {
      switch self {
      case .hit(_, let isInSeparableVerbs):
        return isInSeparableVerbs
      case .separableVerbs:
        return false
      }
    }
  }

  static let empty = VerbSearchResults(entries: [], matchCount: 0, guess: nil)

  /// Every entry in rank order, with the folded row's verbs after it, whether or not it is open.
  let entries: [Entry]
  let matchCount: Int
  let guess: Hit?

  init(entries: [Entry], matchCount: Int, guess: Hit?) {
    self.entries = entries
    self.matchCount = matchCount
    self.guess = guess
  }

  /// The verb list asks for no guess, which it computes off the main actor; see VerbSearchModel.
  init(query: String, verbs: [Verb], includeGlosses: Bool, includesGuess: Bool = true, index: ConjugationIndex = .bundled) {
    let matches = VerbSearch.matches(for: query, in: verbs, includeGlosses: includeGlosses, index: index)
    let hits = matches.map { match in
      Hit(verb: match.verb, kind: match.kind, conjugation: Self.conjugation(of: match))
    }
    let separableVerbs = hits.filter { $0.kind == .finitePart }
    var entries: [Entry] = []
    for hit in hits {
      guard separableVerbs.count > 1, hit.kind == .finitePart else {
        entries.append(.hit(hit, isInSeparableVerbs: false))
        continue
      }
      if hit == separableVerbs.first {
        entries.append(.separableVerbs(separableVerbs))
        entries += separableVerbs.map { .hit($0, isInSeparableVerbs: true) }
      }
    }
    self.entries = entries
    matchCount = matches.count
    guess = matches.isEmpty && includesGuess ? VerbSearch.guess(for: query, in: verbs, index: index).map(Self.hit(for:)) : nil
  }

  static func hit(for guess: VerbSearch.Guess) -> Hit {
    Hit(verb: guess.verb, kind: nil, conjugation: guess.conjugation.map { MatchedConjugation(whole: $0, of: guess.verb) })
  }

  /// The kind of the first row, which is the best match's: a folded row stands where its first
  /// verb would.
  var topKind: VerbSearch.MatchKind? {
    switch entries.first {
    case .hit(let hit, _):
      return hit.kind
    case .separableVerbs(let hits):
      return hits.first?.kind
    case nil:
      return nil
    }
  }

  private static func conjugation(of match: VerbSearch.Match) -> MatchedConjugation? {
    guard let text = match.conjugation else {
      return nil
    }
    if let particle = match.particle {
      return MatchedConjugation(finitePart: text, particle: particle)
    }
    return MatchedConjugation(whole: text, of: match.verb)
  }

  var isEmpty: Bool {
    entries.isEmpty
  }

  /// Every match in rank order, the folded row's verbs where the row stands.
  var hits: [Hit] {
    entries.compactMap(\.hit)
  }

  /// The entries as shown, with the folded row's verbs only when it is open.
  func entries(separableVerbsAreShown: Bool) -> [Entry] {
    separableVerbsAreShown ? entries : entries.filter { !$0.isInSeparableVerbs }
  }
}
