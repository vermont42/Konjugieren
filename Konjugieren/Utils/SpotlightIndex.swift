// Copyright © 2026 Josh Adams. All rights reserved.

/// The Spotlight calls that `VerbSpotlight` makes. `SpotlightIndexReal` uses Core Spotlight, and
/// `SpotlightIndexSpy` records under unit tests, where the order of the calls is what matters.
protocol SpotlightIndex {
  /// Deletes every verb entity the app has indexed, from every index, not only the default.
  func deleteEveryVerb() async throws
  func deleteVerbs(_ infinitivs: [String]) async throws
  func indexVerbs(_ entities: [VerbEntity]) async throws
}
