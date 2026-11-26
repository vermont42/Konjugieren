// Copyright © 2026 Josh Adams. All rights reserved.

enum SortOrder: String, CaseIterable {
  case alphabetical
  case frequency

  var displayName: String {
    switch self {
    case .frequency:
      return L.VerbBrowse.frequency
    case .alphabetical:
      return L.VerbBrowse.alphabetical
    }
  }
}

extension [Verb] {
  func sorted(by order: SortOrder) -> [Verb] {
    switch order {
    case .alphabetical:
      return sorted(by: Verb.precedesAlphabetically)
    case .frequency:
      return sorted { $0.frequency < $1.frequency }
    }
  }
}
