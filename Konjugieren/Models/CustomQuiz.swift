// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// A quiz the learner puts together on the Quiz tab (T2.8): conjugationgroups, a verb set, or
/// both. A part left unchosen is the learner's level's, so a choice of verbs alone asks the level's
/// conjugationgroups, and a choice of conjugationgroups alone asks the level's verbs, mixed as the
/// default quiz's are. Josh decided on 2026-11-13 that any conjugationgroup may be chosen, above
/// the learner's level or not.
struct CustomQuiz: Equatable {
  /// Empty asks the level's conjugationgroups.
  var tables: Set<ConjugationTable> = []
  /// Nil asks the level's verbs.
  var verbSet: QuizVerbSet?

  var isEmpty: Bool {
    tables.isEmpty && verbSet == nil
  }

  /// The chosen tables in the verb page's order.
  var orderedTables: [ConjugationTable] {
    ConjugationTable.allCases.filter(tables.contains)
  }

  /// What the quiz asks. A table's kind is Advanced's, the fullest, so that the Präteritum is
  /// asked of every verb and the Imperativ of wir too.
  func pool(level: QuizLevel) -> [QuizPoolEntry] {
    guard !tables.isEmpty else {
      return level.pool
    }
    return QuizLevel.advanced.pool.filter { tables.contains($0.table) }
  }

  /// What `startQuiz` says the learner chose, without saying what.
  var choiceParameter: String {
    switch (tables.isEmpty, verbSet == nil) {
    case (false, false):
      return "both"
    case (false, true):
      return "conjugationgroups"
    case (true, _):
      return "verbs"
    }
  }

  private static let tablesKey = "groups"
  private static let verbsKey = "verbs"
}

/// Stored as `groups=praesens_indikativ,imperativ&verbs=modals`. The keys are permanent, since a
/// learner's choice is kept between launches and Phase 10 of the pedagogy plan shares it as a link.
/// A key that no longer names anything is dropped rather than failing the whole choice.
extension CustomQuiz: RawRepresentable {
  init?(rawValue: String) {
    var components = URLComponents()
    components.percentEncodedQuery = rawValue
    let items = components.queryItems ?? []
    let tableKeys = items.first { $0.name == Self.tablesKey }?.value?.split(separator: ",").map(String.init) ?? []
    tables = Set(tableKeys.compactMap { key in ConjugationTable.allCases.first { $0.articleKey == key } })
    verbSet = items.first { $0.name == Self.verbsKey }?.value.flatMap(QuizVerbSet.init(key:))
  }

  var rawValue: String {
    var items: [URLQueryItem] = []
    if !tables.isEmpty {
      items.append(URLQueryItem(name: Self.tablesKey, value: orderedTables.map(\.articleKey).joined(separator: ",")))
    }
    if let verbSet {
      items.append(URLQueryItem(name: Self.verbsKey, value: verbSet.key))
    }
    var components = URLComponents()
    components.queryItems = items
    return components.percentEncodedQuery ?? ""
  }
}

/// The verbs a custom quiz may ask about.
enum QuizVerbSet: Hashable {
  case all
  case band(FrequencyBand)
  case collection(VerbCollection)
  case myVerbs

  /// The bands and the corpus are chosen for their size, not their verbs, so they are mixed as the
  /// default quiz's are; a collection and My Verbs are lists, and are not.
  var mixesVerbs: Bool {
    switch self {
    case .all, .band:
      return true
    case .collection, .myVerbs:
      return false
    }
  }

  /// The collection's key, for `startQuiz` to name as a collection's quiz does.
  var collectionKey: String? {
    switch self {
    case .collection(let collection):
      return collection.key
    case .all, .band, .myVerbs:
      return nil
    }
  }

  var key: String {
    switch self {
    case .all:
      return "all"
    case .band(let band):
      return "top\(band.verbCount)"
    case .collection(let collection):
      return collection.key
    case .myVerbs:
      return "myVerbs"
    }
  }

  /// The top-100 collection and the top-100 band hold the same verbs, and both keys are `top100`,
  /// so the key reads back as the band.
  init?(key: String) {
    if let band = FrequencyBand.allCases.first(where: { "top\($0.verbCount)" == key }) {
      self = .band(band)
      return
    }
    switch key {
    case "all":
      self = .all
    case "myVerbs":
      self = .myVerbs
    default:
      guard let collection = VerbCollection(key: key) else {
        return nil
      }
      self = .collection(collection)
    }
  }

  /// Sorted by infinitive, as the default quiz's are, so that a seeded draw is the same in every
  /// process.
  func verbs(myVerbs: [Verb]) -> [Verb] {
    switch self {
    case .all:
      return Verb.verbs.values.sorted { $0.infinitiv < $1.infinitiv }
    case .band(let band):
      return Verb.verbs(in: band).sorted { $0.infinitiv < $1.infinitiv }
    case .collection(let collection):
      return collection.verbs()
    case .myVerbs:
      return myVerbs
    }
  }

  var title: String {
    switch self {
    case .all:
      return L.VerbBrowse.verbCount(Verb.verbs.count)
    case .band(let band):
      return L.CustomQuiz.band(band.verbCount.formatted())
    case .collection(let collection):
      return collection.title
    case .myVerbs:
      return L.MyVerbs.title
    }
  }
}

extension QuizScope {
  /// A custom quiz from the Quiz tab: ten questions, then Ten More, never ranked.
  static func custom(_ custom: CustomQuiz, myVerbs: [Verb]) -> QuizScope {
    QuizScope(
      verbs: custom.verbSet?.verbs(myVerbs: myVerbs),
      readingIndex: nil,
      questionCount: Quiz.questionCount,
      source: .custom,
      collectionKey: custom.verbSet?.collectionKey,
      custom: custom
    )
  }
}
