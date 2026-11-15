// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// A context and the same sentence in two conjugationgroups, of which the learner picks the one a
/// German speaker or writer would use: "Am Samstag habe ich lange geschlafen." over "Am Samstag
/// schlief ich lange." in conversation (Phase 19 of the pedagogy plan). The items live in
/// `ChoiceQuestions.json`. Claude drafts them, `ChoiceQuestionTests` confirms both sentences
/// against the conjugator, and Josh reviews each before it ships, which `reviewed` records.
struct ChoiceQuestion: Decodable, Identifiable, Equatable {
  struct Option: Decodable, Equatable {
    /// A `ConjugationTable.articleKey`.
    let table: String
    /// The sentence, with each word of the conjugation in braces.
    let german: String

    private enum CodingKeys: String, CodingKey {
      case german = "de"
      case table
    }
  }

  let id: String
  /// The infinitive, a key of `Verb.verbs`.
  let verb: String
  let reading: Int?
  /// A `PersonNumber` raw value, which both sentences share.
  let person: String
  /// The `QuizLevel` from which the item is asked.
  let level: String
  /// A `ChoiceSetting` raw value.
  let setting: String
  /// A `ChoiceReason` raw value.
  let reason: String
  let right: Option
  let other: Option
  let english: String
  let reviewed: Bool

  private enum CodingKeys: String, CodingKey {
    case english = "en"
    case id
    case level
    case other
    case person
    case reading
    case reason
    case reviewed
    case right
    case setting
    case verb
  }

  var readingIndex: Int {
    reading ?? 0
  }

  var quizLevel: QuizLevel? {
    QuizLevel(rawValue: level)
  }

  var choiceSetting: ChoiceSetting? {
    ChoiceSetting(rawValue: setting)
  }

  var choiceReason: ChoiceReason? {
    ChoiceReason(rawValue: reason)
  }

  /// The right sentence, read as a Sentences item reads, so that one machine check confirms both.
  var rightSentence: GapSentence {
    sentence(right, suffix: "right")
  }

  var otherSentence: GapSentence {
    sentence(other, suffix: "other")
  }

  private func sentence(_ option: Option, suffix: String) -> GapSentence {
    GapSentence(id: "\(id).\(suffix)", verb: verb, reading: reading, table: option.table, person: person, german: option.german, english: english, reviewed: reviewed)
  }

  /// Whether a level asks this item: the item's own level or a later one, which asks the right
  /// sentence's verb in its cell. The other sentence's cell may be one no level asks, as kaufte for
  /// kaufen's Konjunktiv II is, since the learner reads it but is never asked to write it.
  func isAskable(at level: QuizLevel) -> Bool {
    guard let quizLevel, let from = QuizLevel.allCases.firstIndex(of: quizLevel), let at = QuizLevel.allCases.firstIndex(of: level), at >= from else {
      return false
    }
    return rightSentence.isAskable(at: level)
  }

  /// The one-line reason the card shows after the choice, naming both conjugationgroups in the
  /// learner's chosen language for their names.
  func reasonLine(lang: ConjugationgroupLang) -> String {
    let rightName = rightSentence.conjugationgroup?.displayName(lang: lang) ?? ""
    let otherName = otherSentence.conjugationgroup?.displayName(lang: lang) ?? ""
    return choiceReason?.line(right: rightName, other: otherName) ?? ""
  }
}

/// Where the sentence is said or written, which decides between some conjugationgroups: the
/// Perfekt in conversation, the Präteritum in a written story. Shown in German with its English
/// gloss, as a verb is.
enum ChoiceSetting: String, CaseIterable {
  case conversation
  case news
  case story

  var german: String {
    switch self {
    case .conversation:
      return "Im Gespräch"
    case .news:
      return "In einer Nachrichtenmeldung"
    case .story:
      return "In einer Erzählung"
    }
  }

  var english: String {
    switch self {
    case .conversation:
      return "In conversation"
    case .news:
      return "In a news report"
    case .story:
      return "In a written story"
    }
  }
}

/// Why a speaker or writer uses the right sentence's conjugationgroup. Few reasons serve many
/// items, so each is written and translated once, in `Localizable.xcstrings`.
enum ChoiceReason: String, CaseIterable {
  case futurWithoutTimeWord = "futur_without_time_word"
  case indikativInConversation = "indikativ_in_conversation"
  case konjunktivIInReports = "konjunktiv_i_in_reports"
  case oneWordKonjunktivII = "one_word_konjunktiv_ii"
  case perfektInConversation = "perfekt_in_conversation"
  case präsensForFuture = "praesens_for_future"
  case präteritumInWriting = "praeteritum_in_writing"
  case präteritumOfSeinHaben = "praeteritum_of_sein_haben"
  case würdeForMostVerbs = "wuerde_for_most_verbs"

  func line(right: String, other: String) -> String {
    switch self {
    case .futurWithoutTimeWord:
      return L.Choice.reasonFuturWithoutTimeWord(right: right, other: other)
    case .indikativInConversation:
      return L.Choice.reasonIndikativInConversation(right: right, other: other)
    case .konjunktivIInReports:
      return L.Choice.reasonKonjunktivIInReports(right)
    case .oneWordKonjunktivII:
      return L.Choice.reasonOneWordKonjunktivII(right)
    case .perfektInConversation:
      return L.Choice.reasonPerfektInConversation(right)
    case .präsensForFuture:
      return L.Choice.reasonPräsensForFuture(right)
    case .präteritumInWriting:
      return L.Choice.reasonPräteritumInWriting(right)
    case .präteritumOfSeinHaben:
      return L.Choice.reasonPräteritumOfSeinHaben(right)
    case .würdeForMostVerbs:
      return L.Choice.reasonWürdeForMostVerbs(right)
    }
  }
}

/// A choice as asked: the item, and which of the two places shows the right sentence, so that the
/// right one is not always first.
struct ChoicePrompt: Equatable {
  let question: ChoiceQuestion
  let rightIndex: Int

  var options: [GapSentence] {
    rightIndex == 0 ? [question.rightSentence, question.otherSentence] : [question.otherSentence, question.rightSentence]
  }
}

enum ChoiceQuestions {
  @MainActor private static var loaded: [ChoiceQuestion]?

  /// Every item in the bundle, drafts included.
  @MainActor static var all: [ChoiceQuestion] {
    if let loaded {
      return loaded
    }
    let items = Bundle.main.url(forResource: "ChoiceQuestions", withExtension: "json")
      .flatMap { try? Data(contentsOf: $0) }
      .map(decode) ?? []
    loaded = items
    return items
  }

  static func decode(_ data: Data) -> [ChoiceQuestion] {
    (try? JSONDecoder().decode([ChoiceQuestion].self, from: data)) ?? []
  }

  /// The items a level asks. A debug build asks drafts too, as Sentences does, so that Josh can
  /// judge an item where a learner meets it.
  @MainActor static func askable(at level: QuizLevel, from items: [ChoiceQuestion]? = nil, includesDrafts: Bool = GapSentences.includesDrafts) -> [ChoiceQuestion] {
    (items ?? all).filter { ($0.reviewed || includesDrafts) && $0.isAskable(at: level) }
  }
}

extension QuizDraw {
  /// One choice for a round, from those the session has not asked, or from all once every one
  /// has been. Nil when the level has none, as Beginner has none.
  static func choice(
    from candidates: [ChoiceQuestion],
    excluded: Set<String>,
    using generator: inout some RandomNumberGenerator
  ) -> ChoicePrompt? {
    let sorted = candidates.sorted { $0.id < $1.id }
    let unasked = sorted.filter { !excluded.contains($0.id) }
    guard let question = (unasked.isEmpty ? sorted : unasked).randomElement(using: &generator) else {
      return nil
    }
    return ChoicePrompt(question: question, rightIndex: Int.random(in: 0...1, using: &generator))
  }

  /// Where a round's choice goes: anywhere but first, so that a round opens on a typed question
  /// with the keyboard up.
  static func choicePosition(in count: Int, using generator: inout some RandomNumberGenerator) -> Int {
    count < 1 ? count : Int.random(in: 1...count, using: &generator)
  }
}
