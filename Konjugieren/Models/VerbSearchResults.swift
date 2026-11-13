// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The conjugation that a search result matched, and the cells of the verb's page it fills.
struct MatchedConjugation: Hashable {
  /// As the app spells it, which is not always as typed: ging, stand auf, muss for muß. For a
  /// finite part, the part alone.
  let text: String

  /// For a finite part, the separable prefix that a main clause sends to the end.
  let particle: String?

  /// The first reading with a matching cell, and its matching cells in page order. Empty for
  /// a finite part, whose cells are found only when its row is opened, and for a zu-infinitive,
  /// which is not a cell.
  let readingIndex: Int
  let conjugationgroups: [Conjugationgroup]

  let isZuInfinitive: Bool

  /// Names the cells of `verb` that `text` fills, which costs a few hundred conjugations, so the
  /// list does this only for whole-verb matches, of which a query has few.
  init(whole text: String, of verb: Verb) {
    let cells = verb.conjugations(matching: text).filter { !$0.isFinitePart }
    let readingIndex = cells.first?.readingIndex ?? 0
    self.text = text
    particle = nil
    self.readingIndex = readingIndex
    conjugationgroups = cells.filter { $0.readingIndex == readingIndex }.map(\.conjugationgroup)
    isZuInfinitive = cells.isEmpty && verb.readings.contains { $0.zuInfinitive == text }
  }

  init(finitePart text: String, particle: String) {
    self.text = text
    self.particle = particle
    readingIndex = 0
    conjugationgroups = []
    isZuInfinitive = false
  }

  /// hielt … auf, as a learner meets it in a main clause.
  var shownConjugation: String {
    particle.map { "\(text) … \($0)" } ?? text
  }

  /// "Präteritum Indikativ (ich, er)", or several such joined by a dot. Nil for a finite part.
  func cellNames(lang: ConjugationgroupLang) -> String? {
    guard particle == nil else {
      return nil
    }
    if isZuInfinitive {
      return lang == .german ? "zu-Infinitiv" : "zu-infinitive"
    }
    var sections: [(name: String, persons: [String])] = []
    for group in conjugationgroups {
      let name = group.displayName(lang: lang)
      let person = group.personNumber.map { personNumber in
        group.isImperativ ? personNumber.imperativPronoun ?? personNumber.pronoun : personNumber.pronoun
      }
      if let index = sections.firstIndex(where: { $0.name == name }) {
        sections[index].persons += person.map { [$0] } ?? []
      } else {
        sections.append((name, person.map { [$0] } ?? []))
      }
    }
    guard !sections.isEmpty else {
      return nil
    }
    return sections
      .map { $0.persons.isEmpty ? $0.name : "\($0.name) (\($0.persons.joined(separator: ", ")))" }
      .joined(separator: " · ")
  }

  /// The cells the verb page marks. A finite part's are found here, for the one verb opened.
  func marks(on verb: Verb) -> MarkedConjugations? {
    guard particle != nil else {
      return conjugationgroups.isEmpty ? nil : MarkedConjugations(readingIndex: readingIndex, conjugationgroups: Set(conjugationgroups))
    }
    let cells = verb.conjugations(matching: text).filter(\.isFinitePart)
    guard let first = cells.first else {
      return nil
    }
    return MarkedConjugations(
      readingIndex: first.readingIndex,
      conjugationgroups: Set(cells.filter { $0.readingIndex == first.readingIndex }.map(\.conjugationgroup))
    )
  }
}

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

  enum Row {
    case hit(Hit)
    case separableVerbs([Hit])
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
  }

  static let empty = VerbSearchResults(rows: [], matchCount: 0, guess: nil)

  let rows: [Row]
  let matchCount: Int
  let guess: Hit?

  init(rows: [Row], matchCount: Int, guess: Hit?) {
    self.rows = rows
    self.matchCount = matchCount
    self.guess = guess
  }

  init(query: String, verbs: [Verb], includeGlosses: Bool, index: ConjugationIndex = .bundled) {
    let matches = VerbSearch.matches(for: query, in: verbs, includeGlosses: includeGlosses, index: index)
    let hits = matches.map { match in
      Hit(verb: match.verb, kind: match.kind, conjugation: Self.conjugation(of: match))
    }
    let separableVerbs = hits.filter { $0.kind == .finitePart }
    var rows: [Row] = []
    for hit in hits {
      guard separableVerbs.count > 1, hit.kind == .finitePart else {
        rows.append(.hit(hit))
        continue
      }
      if hit == separableVerbs.first {
        rows.append(.separableVerbs(separableVerbs))
      }
    }
    self.rows = rows
    matchCount = matches.count
    guess = matches.isEmpty ? VerbSearch.guess(for: query, in: verbs, index: index).map { guess in
      Hit(verb: guess.verb, kind: nil, conjugation: guess.conjugation.map { MatchedConjugation(whole: $0, of: guess.verb) })
    } : nil
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
    rows.isEmpty
  }

  /// The rows as shown, with the separable verbs' own rows after theirs when it is open.
  func entries(separableVerbsAreShown: Bool) -> [Entry] {
    rows.flatMap { row -> [Entry] in
      switch row {
      case .hit(let hit):
        return [.hit(hit, isInSeparableVerbs: false)]
      case .separableVerbs(let hits):
        return [.separableVerbs(hits)] + (separableVerbsAreShown ? hits.map { .hit($0, isInSeparableVerbs: true) } : [])
      }
    }
  }
}

extension Conjugationgroup {
  var isParticiple: Bool {
    self == .perfektpartizip || self == .präsenspartizip
  }

  var isImperativ: Bool {
    if case .imperativ = self {
      return true
    }
    return false
  }
}

extension Reading {
  /// anzufangen. Nil when the zu stands apart (zu vermeiden), since that is two words.
  var zuInfinitive: String? {
    let run = prefixes.separableRun
    guard !run.isEmpty else {
      return nil
    }
    return (run + "zu" + infinitiv.dropFirst(run.count)).lowercased()
  }
}
