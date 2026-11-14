// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import Foundation

nonisolated struct QuizActivityAttributes: ActivityAttributes {
  let level: String

  struct ContentState: Codable, Hashable, Sendable {
    let currentQuestion: Int
    /// The session's questions so far, which grows with each re-ask and Ten More.
    let totalQuestions: Int
    let score: Int
    let correctCount: Int
    /// Nil while the quiz clock is hidden.
    let elapsedTime: String?
    let isFinished: Bool
  }
}
