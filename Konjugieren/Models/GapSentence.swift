// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension QuizScope {
  static func sentences() -> QuizScope {
    QuizScope(verbs: nil, readingIndex: nil, questionCount: Quiz.questionCount, source: .sentences, isSentences: true)
  }
}

/// A short authored sentence with its verb blanked, "Gestern {sind} wir ins Kino {gegangen}.",
/// which ties a conjugation to a meaning (Phase 18 of the pedagogy plan). The sentences live in
/// `GapSentences.json`. Claude drafts them, `GapSentenceTests` confirms every blank against the
/// conjugator, and Josh reviews each one before it ships, which `reviewed` records.
struct GapSentence: Decodable, Identifiable, Equatable {
  let id: String
  /// The infinitive, a key of `Verb.verbs`.
  let verb: String
  let reading: Int?
  /// A `ConjugationTable.articleKey`.
  let table: String
  /// A `PersonNumber` raw value, absent for a participle.
  let person: String?
  /// The sentence, with each word of the conjugation in braces.
  let german: String
  let english: String
  let reviewed: Bool

  private enum CodingKeys: String, CodingKey {
    case english = "en"
    case german = "de"
    case id
    case person
    case reading
    case reviewed
    case table
    case verb
  }

  var readingIndex: Int {
    reading ?? 0
  }

  var conjugationgroup: Conjugationgroup? {
    guard let table = ConjugationTable.allCases.first(where: { $0.articleKey == table }) else {
      return nil
    }
    return table.cells.first { $0.personNumber?.rawValue == person }
  }

  /// The texts in braces, in order.
  var blankAnswers: [String] {
    pieces.compactMap { piece in
      if case .blank(let answer) = piece {
        return answer
      }
      return nil
    }
  }

  /// The sentence as it reads with its conjugation written in.
  var completed: String {
    german.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
  }

  /// The sentence's frame: its words, and a blank for each braced word. In the wir and Sie
  /// Imperativ the pronoun follows the verb and belongs to the answer (nehmen Sie), so a pronoun
  /// right after the first blank is a word of the answer that the frame supplies.
  var frame: AnswerFrame {
    var segments: [AnswerFrame.Segment] = []
    let pronoun = conjugationgroup.flatMap(Self.imperativPronoun(in:))
    for piece in pieces {
      switch piece {
      case .blank:
        segments.append(.blank)
      case .text(let text):
        let isAfterFirstBlank = segments.last == .blank && segments.filter { $0 == .blank }.count == 1
        if let pronoun, isAfterFirstBlank, text.hasPrefix(" \(pronoun)") {
          let rest = String(text.dropFirst(pronoun.count + 1))
          if rest.isEmpty || rest.first?.isLetter == false {
            segments.append(.word(pronoun))
            if !rest.isEmpty {
              segments.append(.context(rest))
            }
            continue
          }
        }
        segments.append(.context(text))
      }
    }
    return AnswerFrame(segments: segments)
  }

  /// The answer the braces give, as the quiz grades it: "sind gegangen", "nehmen Sie".
  var answer: String {
    frame.answer(filling: blankAnswers)
  }

  private enum Piece: Equatable {
    case blank(String)
    case text(String)
  }

  private var pieces: [Piece] {
    var result: [Piece] = []
    var text = ""
    var blank: String?
    for character in german {
      switch character {
      case "{":
        if !text.isEmpty {
          result.append(.text(text))
        }
        text = ""
        blank = ""
      case "}":
        result.append(.blank(blank ?? ""))
        blank = nil
      default:
        if blank != nil {
          blank?.append(character)
        } else {
          text.append(character)
        }
      }
    }
    if !text.isEmpty {
      result.append(.text(text))
    }
    return result
  }

  private static func imperativPronoun(in conjugationgroup: Conjugationgroup) -> String? {
    guard case .imperativ(let personNumber) = conjugationgroup else {
      return nil
    }
    switch personNumber {
    case .firstPlural:
      return "wir"
    case .thirdPlural:
      return "Sie"
    case .firstSingular, .secondPlural, .secondSingular, .thirdSingular:
      return nil
    }
  }

  /// Whether the braces write the conjugation in the subordinate clause's word order (weil ich um
  /// sechs {aufstehe}) rather than the main clause's. Only then are the two different, so a
  /// sentence is graded in its own clause's order alone: "stehe auf" cannot fill a blank after
  /// weil.
  var clause: Clause {
    guard let conjugationgroup else {
      return .main
    }
    let main = RegionalConjugator.conjugateUnsafely(infinitiv: verb, conjugationgroup: conjugationgroup, region: .north, readingIndex: readingIndex, clause: .main)
    return main.lowercased() == answer.lowercased() ? .main : .subordinate
  }

  /// Whether a level asks this sentence: its verb is in the level's band, and its cell is one the
  /// level's pool asks of that verb.
  func isAskable(at level: QuizLevel) -> Bool {
    guard let verb = Verb.verbs[verb], let reading = verb.reading(at: readingIndex), let conjugationgroup else {
      return false
    }
    if let band = level.band, !verb.isIn(band) {
      return false
    }
    return level.pool.contains { $0.cells.contains(conjugationgroup) && $0.verbs.admits(verb, reading: reading) }
  }
}

enum GapSentences {
  @MainActor private static var loaded: [GapSentence]?

  /// Every sentence in the bundle, drafts included.
  @MainActor static var all: [GapSentence] {
    if let loaded {
      return loaded
    }
    let sentences = Bundle.main.url(forResource: "GapSentences", withExtension: "json")
      .flatMap { try? Data(contentsOf: $0) }
      .map(decode) ?? []
    loaded = sentences
    return sentences
  }

  static func decode(_ data: Data) -> [GapSentence] {
    (try? JSONDecoder().decode([GapSentence].self, from: data)) ?? []
  }

  // A debug build asks drafts too, marked as drafts on the card, so that Josh can try a sentence
  // in the app before he approves it. A release build asks only what he has approved.
  #if DEBUG
  static let includesDrafts = true
  #else
  static let includesDrafts = false
  #endif

  /// The sentences a level asks.
  @MainActor static func askable(at level: QuizLevel, from sentences: [GapSentence]? = nil, includesDrafts: Bool = includesDrafts) -> [GapSentence] {
    (sentences ?? all).filter { ($0.reviewed || includesDrafts) && $0.isAskable(at: level) }
  }
}

extension QuizDraw {
  /// A round of sentences: the session's unasked ones first, and one sentence a verb where the
  /// sentences allow, so that a round of ten is not four of gehen's. A pool smaller than the round
  /// makes a shorter round, and once every sentence has been asked, Ten More asks them again.
  static func sentences(
    from candidates: [GapSentence],
    count: Int,
    excluded: Set<String>,
    using generator: inout some RandomNumberGenerator
  ) -> [GapSentence] {
    let shuffled = candidates.sorted { $0.id < $1.id }.shuffled(using: &generator)
    var round: [GapSentence] = []
    var verbs: Set<String> = []
    for group in [shuffled.filter { !excluded.contains($0.id) }, shuffled.filter { excluded.contains($0.id) }] {
      for sentence in group where round.count < count && !verbs.contains(sentence.verb) {
        round.append(sentence)
        verbs.insert(sentence.verb)
      }
      for sentence in group where round.count < count && !round.contains(sentence) {
        round.append(sentence)
      }
    }
    return round
  }
}
