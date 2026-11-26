// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents
import CoreSpotlight

final class SpotlightIndexReal: SpotlightIndex {
  // Deleting app entities by type empties every index of the app, not only the one it is
  // called on (seen in the iOS 26.3 simulator).
  func deleteEveryVerb() async throws {
    try await CSSearchableIndex.default().deleteAppEntities(ofType: VerbEntity.self)
  }

  func deleteVerbs(_ infinitivs: [String]) async throws {
    try await CSSearchableIndex(name: VerbSpotlight.indexName).deleteAppEntities(identifiedBy: infinitivs, ofType: VerbEntity.self)
  }

  func indexVerbs(_ entities: [VerbEntity]) async throws {
    try await CSSearchableIndex(name: VerbSpotlight.indexName).indexAppEntities(entities)
  }
}
