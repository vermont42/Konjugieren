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
    case .bundestag:
      return L.AppIcon.bundestag
    case .hat:
      return L.AppIcon.hat
    case .pretzel:
      return L.AppIcon.pretzel
    }
  }

  var alternateIconName: String? {
    switch self {
    case .bratwurst:
      return "BratwurstIcon"
    case .bundestag:
      return "BundestagIcon"
    case .hat:
      return nil
    case .pretzel:
      return "PretzelIcon"
    }
  }

  var previewAssetName: String {
    switch self {
    case .bratwurst:
      return "BratwurstIconPreview"
    case .bundestag:
      return "Bundestag"
    case .hat:
      return "Hat"
    case .pretzel:
      return "Pretzel"
    }
  }
}
