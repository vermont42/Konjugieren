// Copyright © 2026 Josh Adams. All rights reserved.

enum SortOrder: String, CaseIterable {
  case frequency
  case alphabetical

  var displayName: String {
    switch self {
    case .frequency:
      return L.VerbBrowse.frequency
    case .alphabetical:
      return L.VerbBrowse.alphabetical
    }
  }
}
