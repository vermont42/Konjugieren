// Copyright © 2026 Josh Adams. All rights reserved.

/// What the verb list shows while its search field is empty: every verb in an order, or My Verbs.
enum VerbListMode: String, CaseIterable {
  case alphabetical
  case frequency
  case myVerbs

  var displayName: String {
    switch self {
    case .alphabetical:
      return L.VerbBrowse.alphabetical
    case .frequency:
      return L.VerbBrowse.frequency
    case .myVerbs:
      return L.MyVerbs.title
    }
  }

  var sortOrder: SortOrder? {
    switch self {
    case .alphabetical:
      return .alphabetical
    case .frequency:
      return .frequency
    case .myVerbs:
      return nil
    }
  }
}
