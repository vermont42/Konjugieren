// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import Foundation

nonisolated struct GameActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable, Sendable {
    let wave: Int
    let score: Int
    let healthFraction: Double
    let phase: String
  }
}
