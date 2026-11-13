// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// What the Look Up a Verb shortcut says about a word, and where it then opens the app. It
/// reads the same search the verb list does, so the two cannot disagree.
struct VerbLookup {
  enum Finding: Equatable {
    /// The word is this verb's infinitive.
    case infinitive(Verb)

    /// The word is a conjugation of this verb: ging, of gehen.
    case conjugation(MatchedConjugation, of: Verb)

    /// The word is also the finite part of separable verbs (steht, of aufstehen), shown as a
    /// main clause leaves it (steht … auf) with the most frequent such verb.
    case finitePart(shown: String, example: Verb, count: Int)

    /// The word is neither an infinitive nor a conjugation, but other kinds of match found
    /// verbs: a gloss, or part of an infinitive.
    case otherMatches(first: Verb, count: Int)

    /// Nothing matched, and this is the empty state's guess.
    case guess(Verb, conjugation: String?)

    case nothing
  }

  /// At most this many verbs are named, so that a spoken answer stays short.
  static let maxNamedVerbs = 4

  private static let literalAnswerKinds: Set<VerbSearch.MatchKind> = [.exactInfinitive, .exactFoldedInfinitive, .conjugation]

  let word: String
  let findings: [Finding]

  /// A verb's page, when one verb answers; otherwise the verb list searched for the word, which
  /// shows every match and, failing them, the guess. The separable verbs of a finite part do
  /// not count against the page: ging is a part of ausgehen and 30 more, and a learner who
  /// says ging nearly always means gehen. The answer names them instead.
  let destination: URL?

  init(word: String, verbs: [Verb], includeGlosses: Bool, index: ConjugationIndex = .bundled) {
    let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
    self.word = trimmed
    let results = VerbSearchResults(query: trimmed, verbs: verbs, includeGlosses: includeGlosses, index: index)
    let hits = results.rows.flatMap { row -> [VerbSearchResults.Hit] in
      switch row {
      case .hit(let hit):
        return [hit]
      case .separableVerbs(let hits):
        return hits
      }
    }

    // An infinitive and a conjugation answer the question equally: gefallen is a verb and
    // fallen's Perfektpartizip, and naming only the first would mislead a reader of the second.
    // A folded spelling answers only when nothing literal does, as it ranks in the list.
    let literalAnswers = hits.filter { $0.kind.map(Self.literalAnswerKinds.contains) ?? false }
    let answers = literalAnswers.isEmpty ? hits.filter { $0.kind == .foldedConjugation } : literalAnswers
    let finiteParts = hits.filter { $0.kind == .finitePart }

    var findings: [Finding] = answers.prefix(Self.maxNamedVerbs).map { hit in
      if let conjugation = hit.conjugation, hit.kind == .conjugation || hit.kind == .foldedConjugation {
        return .conjugation(conjugation, of: hit.verb)
      }
      return .infinitive(hit.verb)
    }
    if let example = finiteParts.first, let conjugation = example.conjugation {
      findings.append(.finitePart(shown: conjugation.shownConjugation, example: example.verb, count: finiteParts.count))
    }
    if findings.isEmpty {
      if let first = hits.first {
        findings.append(.otherMatches(first: first.verb, count: results.matchCount))
      } else if let guess = results.guess {
        findings.append(.guess(guess.verb, conjugation: guess.conjugation?.text))
      } else {
        findings.append(.nothing)
      }
    }
    self.findings = findings

    if answers.count == 1, let answer = answers.first {
      destination = URL.verbDeeplink(answer.verb.infinitiv, source: .lookup, match: answer.conjugation?.text)
    } else {
      destination = URL.searchDeeplink(text: trimmed, source: .lookup)
    }
  }

  /// The answer as the shortcut speaks and shows it, one finding per line.
  func answer(lang: ConjugationgroupLang, region: Region) -> String {
    findings.map { finding in
      switch finding {
      case .infinitive(let verb):
        let heading = L.Lookup.verbWithGloss(infinitiv: verb.infinitiv.inRegion(region), gloss: verb.translation)
        let conjugations = verb.keyConjugations(region: region).map { $0.lowercased() }
        return conjugations.isEmpty ? heading : "\(heading): \(conjugations.joined(separator: " · "))"
      case .conjugation(let conjugation, let verb):
        let cells = conjugation.cellNames(lang: lang) ?? ""
        return L.Lookup.conjugation(conjugation.text.inRegion(region), cells: cells, infinitiv: verb.infinitiv.inRegion(region))
      case .finitePart(let shown, let example, let count):
        let infinitiv = example.infinitiv.inRegion(region)
        return count == 1
          ? L.Lookup.finitePartOne(word, infinitiv: infinitiv, shown: shown.inRegion(region))
          : L.Lookup.finitePartMany(word, infinitiv: infinitiv, shown: shown.inRegion(region), others: count - 1)
      case .otherMatches(let first, let count):
        let firstVerb = L.Lookup.verbWithGloss(infinitiv: first.infinitiv.inRegion(region), gloss: first.translation)
        return count == 1
          ? L.Lookup.otherMatchesOne(word, verb: firstVerb)
          : L.Lookup.otherMatchesMany(word, count: count, verb: firstVerb)
      case .guess(let verb, let conjugation):
        if let conjugation {
          return L.Lookup.guessConjugation(word, conjugation: conjugation.inRegion(region), infinitiv: verb.infinitiv.inRegion(region))
        }
        return L.Lookup.guessVerb(word, infinitiv: verb.infinitiv.inRegion(region))
      case .nothing:
        return L.Lookup.nothing(word)
      }
    }
    .joined(separator: "\n")
  }
}
