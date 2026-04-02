// Copyright © 2026 Josh Adams. All rights reserved.

enum AppIcon: String, CaseIterable {
  case bratwurst
  case bundestag
  case hat
  case pretzel

  var localizedAppIcon: String {
    switch self {
    case .bratwurst:
      return L.AppIcon.bratwurst
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
    case .bratwurst:
      return "BratwurstIcon"
    case .hat:
      return nil
    case .pretzel:
      return "PretzelIcon"
    case .bundestag:
      return "BundestagIcon"
    }
  }
}
