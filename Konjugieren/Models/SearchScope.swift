// Copyright © 2026 Josh Adams. All rights reserved.

enum SearchScope: String, CaseIterable {
  case infinitiveAndTranslation
  case infinitiveOnly

  var localizedSearchScope: String {
    switch self {
    case .infinitiveOnly:
      return L.SearchScope.infinitiveOnly
    case .infinitiveAndTranslation:
      return L.SearchScope.infinitiveAndTranslation
    }
  }
}
