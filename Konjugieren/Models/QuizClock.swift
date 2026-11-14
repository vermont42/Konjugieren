// Copyright © 2026 Josh Adams. All rights reserved.

/// Whether the quiz shows the time spent answering. Hidden by default, since a clock turns
/// practice into a race (T6.5).
enum QuizClock: String, CaseIterable {
  case hide
  case show

  var localizedQuizClock: String {
    switch self {
    case .hide:
      return L.QuizClock.hide
    case .show:
      return L.QuizClock.show
    }
  }
}
