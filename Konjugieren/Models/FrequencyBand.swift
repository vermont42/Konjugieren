// Copyright © 2026 Josh Adams. All rights reserved.

// Semantic ordering: narrowest band first.
enum FrequencyBand: Int, CaseIterable {
  case top100 = 100
  case top300 = 300
  case top1000 = 1000

  var verbCount: Int {
    rawValue
  }
}

extension Verb {
  // `frequency` is a rank with no ties, so a band holds exactly `verbCount` verbs.
  func isIn(_ band: FrequencyBand) -> Bool {
    frequency <= band.verbCount
  }

  /// The band's verbs, the most frequent first.
  @MainActor static func verbs(in band: FrequencyBand) -> [Verb] {
    Array(verbsSortedByFrequency.prefix(band.verbCount))
  }
}
