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
  /// The verbs in the given order. Alphabetical keeps the order they arrive in, which every
  /// caller already gives alphabetically, so a list keeps its own collation.
  func sorted(by order: SortOrder) -> [Verb] {
    switch order {
    case .alphabetical:
      return self
    case .frequency:
      return sorted { $0.frequency < $1.frequency }
    }
  }
}

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
