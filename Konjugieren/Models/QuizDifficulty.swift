// Copyright © 2026 Josh Adams. All rights reserved.

enum QuizDifficulty: String, CaseIterable {
  case regular
  case ridiculous

  var localizedQuizDifficulty: String {
    switch self {
    case .regular:
      return L.QuizDifficulty.regular
    case .ridiculous:
      return L.QuizDifficulty.ridiculous
    }
  }
}
