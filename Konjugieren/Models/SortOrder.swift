// Copyright © 2025 Josh Adams. All rights reserved.

enum SortOrder: String, CaseIterable {
  case alphabetical
  case frequency

  var displayName: String {
    switch self {
    case .alphabetical:
      return L.VerbBrowse.alphabetical
    case .frequency:
      return L.VerbBrowse.frequency
    }
  }
}
