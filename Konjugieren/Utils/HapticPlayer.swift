// Copyright © 2026 Josh Adams. All rights reserved.

import UIKit

enum HapticPlayer {
  static func playSuccess() {
    guard Current.settings.audioFeedback == .enable else { return }
    UINotificationFeedbackGenerator().notificationOccurred(.success)
  }

  static func playError() {
    guard Current.settings.audioFeedback == .enable else { return }
    UINotificationFeedbackGenerator().notificationOccurred(.error)
  }

  static func playMediumImpact() {
    guard Current.settings.audioFeedback == .enable else { return }
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
  }
}
