// Copyright © 2025 Josh Adams. All rights reserved.

import AppIntents

struct VerbEntity: AppEntity, IndexedEntity {
  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Verb")
  static let defaultQuery = VerbEntityQuery()

  let id: String
  let translation: String

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(id)", subtitle: "\(translation)")
  }
}

struct VerbEntityQuery: EntityStringQuery, EnumerableEntityQuery {
  static let matchLimit = 25

  // Ranking happens before the limit. Cutting an alphabetical list at 25 hid kommen behind
  // abkommen, ankommen, and their siblings, so the verb asked for never appeared.
  @MainActor static func verbs(matching string: String) -> [Verb] {
    VerbSearch.matches(for: string, in: Verb.verbsSortedByFrequency, includeGlosses: true)
      .prefix(matchLimit)
      .map(\.verb)
  }

  func entities(for identifiers: [String]) async -> [VerbEntity] {
    await MainActor.run {
      identifiers.compactMap { infinitiv in
        guard let verb = Verb.verbs[infinitiv] else { return nil }
        return VerbEntity(id: verb.infinitiv, translation: verb.translation)
      }
    }
  }

  func entities(matching string: String) async -> [VerbEntity] {
    await MainActor.run {
      guard !Verb.verbs.isEmpty else { return [] }
      return Self.verbs(matching: string)
        .map { VerbEntity(id: $0.infinitiv, translation: $0.translation) }
    }
  }

  func suggestedEntities() async -> [VerbEntity] {
    await MainActor.run {
      guard !Verb.verbs.isEmpty else { return [] }
      return Verb.verbsSortedByFrequency
        .prefix(10)
        .map { VerbEntity(id: $0.infinitiv, translation: $0.translation) }
    }
  }

  func allEntities() async -> [VerbEntity] {
    await MainActor.run {
      guard !Verb.verbs.isEmpty else { return [] }
      return Verb.verbsSortedAlphabetically
        .map { VerbEntity(id: $0.infinitiv, translation: $0.translation) }
    }
  }
}
