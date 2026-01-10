// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum TimeFormatter {
  static func formatIntTime(_ time: Int) -> String {
    guard time >= 0 else { return "0" }

    let hours = time / 3600
    let minutes = (time % 3600) / 60
    let seconds = time % 60

    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else if minutes > 0 {
      return String(format: "%d:%02d", minutes, seconds)
    } else {
      return "\(seconds)"
    }
  }
}
