// Copyright © 2026 Josh Adams. All rights reserved.

enum AppIcon: String, CaseIterable {
  case hat
  case pretzel
  case bundestag

  var localizedAppIcon: String {
    switch self {
    case .hat:
      return L.AppIcon.hat
    case .pretzel:
      return L.AppIcon.pretzel
    case .bundestag:
      return L.AppIcon.bundestag
    }
  }

  var alternateIconName: String? {
    switch self {
    case .hat:
      return nil
    case .pretzel:
      return "Pretzel"
    case .bundestag:
      return "Bundestag"
    }
  }
}
