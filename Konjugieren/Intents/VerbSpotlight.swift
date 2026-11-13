// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents
import CoreSpotlight

/// Konjugieren's Spotlight entries, one per verb, in a named index. Each can be found by its
/// infinitive, by the gloss of every reading, and by its conjugations, so that typing
/// aufgestanden or "get up" on the Home Screen finds aufstehen.
enum VerbSpotlight {
  struct Text: Hashable, Sendable {
    /// The glosses' phrases, then the key conjugations of every reading (steht auf, stand auf,
    /// ist aufgestanden). Spotlight shows the first under the description, so the gloss leads.
    let alternateNames: [String]

    /// Every one-word conjugation in the conjugation map, every finite part with its particle
    /// (steht auf), and the glosses' phrases with and without "to".
    let keywords: [String]

    /// Shown under the title: the first reading's key conjugations, which stand alone with no
    /// label. Spotlight shows a description on one line, so a gloss beside them would run into
    /// them.
    let description: String
  }

  static let indexName = "verbs"

  /// Until 2026-11-12 the verbs went into the default index, whose entries would otherwise
  /// stay beside the named index's and appear twice.
  private static let leftDefaultIndexKey = "spotlightLeftDefaultIndex"

  /// Builds every verb's entry and indexes them. It runs at each launch, as indexing always has,
  /// and yields between batches, because the key conjugations need the Conjugator, which
  /// shares the main actor with the interface.
  static func indexVerbs() async {
    // Deleting app entities by type empties every index of the app, not only the one it is
    // called on (seen in the iOS 26.3 simulator), so the old entries go before the new arrive.
    if Current.getterSetter.get(key: leftDefaultIndexKey) == nil {
      try? await CSSearchableIndex.default().deleteAppEntities(ofType: VerbEntity.self)
      Current.getterSetter.set(key: leftDefaultIndexKey, value: "true")
    }

    let conjugations = await Task.detached(priority: .utility) {
      conjugationsByInfinitiv(in: .bundled)
    }.value
    let region = Current.settings.region
    var entities: [VerbEntity] = []
    for (offset, verb) in Verb.verbsSortedAlphabetically.enumerated() {
      entities.append(entity(for: verb, conjugations: conjugations[verb.infinitiv] ?? [], region: region))
      if offset.isMultiple(of: 100) {
        await Task.yield()
      }
    }
    try? await CSSearchableIndex(name: indexName).indexAppEntities(entities)
  }

  static func entity(for verb: Verb, conjugations: Set<String>, region: Region) -> VerbEntity {
    VerbEntity(id: verb.infinitiv, translation: verb.translation, spotlight: text(for: verb, conjugations: conjugations, region: region))
  }

  static func text(for verb: Verb, conjugations: Set<String>, region: Region) -> Text {
    let glosses = verb.readings.map(\.translation).uniqued()
    let glossPhrases = glosses.flatMap(glossPhrases(in:)).uniqued()
    let keyConjugations = verb.readings.indices
      .flatMap { verb.keyConjugations(readingIndex: $0, region: region).map { $0.lowercased() } }
      .uniqued()
    return Text(
      alternateNames: (glossPhrases + keyConjugations).uniqued(),
      keywords: (conjugations.sorted() + glosses + glossPhrases + glossPhrases.map { "to \($0)" }).uniqued(),
      description: verb.keyConjugations(region: region).map { $0.lowercased() }.joined(separator: " · ")
    )
  }

  /// The phrases a reader might type for a gloss: "set fire to, burn down (something)" gives
  /// "set fire to" and "burn down". The parentheses only say what the verb takes.
  nonisolated static func glossPhrases(in gloss: String) -> [String] {
    gloss
      .replacing(/\([^)]*\)/, with: "")
      .split(whereSeparator: { $0 == "," || $0 == ";" })
      .map { $0.split(whereSeparator: \.isWhitespace).joined(separator: " ") }
      .filter { !$0.isEmpty }
  }

  /// Every whole-verb conjugation of each infinitive (ging, gegangen), and every finite part
  /// with its particle as a main clause writes it (steht auf). A finite part alone would make
  /// steht find dozens of separable verbs.
  nonisolated static func conjugationsByInfinitiv(in map: ConjugationMap) -> [String: Set<String>] {
    var conjugations: [String: Set<String>] = [:]
    for (conjugation, entries) in map.entriesByConjugation {
      for entry in entries {
        conjugations[entry.infinitiv, default: []].insert(entry.particle.map { "\(conjugation) \($0)" } ?? conjugation)
      }
    }
    return conjugations
  }
}

extension Array where Element: Hashable {
  /// The elements in order, each at its first appearance.
  nonisolated func uniqued() -> [Element] {
    var seen: Set<Element> = []
    return filter { seen.insert($0).inserted }
  }
}
