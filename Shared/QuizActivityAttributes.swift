// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import Foundation

nonisolated struct QuizActivityAttributes: ActivityAttributes {
  let difficulty: String
  let totalQuestions: Int

  struct ContentState: Codable, Hashable, Sendable {
    let currentQuestion: Int
    let score: Int
    let correctCount: Int
    let elapsedTime: String
    let isFinished: Bool
  }
}
