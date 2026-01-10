// Copyright © 2026 Josh Adams. All rights reserved.

enum AudioFeedback: String, CaseIterable {
  case enable
  case disable

  var localizedAudioFeedback: String {
    switch self {
    case .enable:
      return L.AudioFeedback.enable
    case .disable:
      return L.AudioFeedback.disable
    }
  }
}
