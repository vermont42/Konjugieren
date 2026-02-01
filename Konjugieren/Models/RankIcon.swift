// Copyright © 2026 Josh Adams. All rights reserved.

enum RankIcon: String, CaseIterable {
  case highIntensity = "figure.highintensity.intervaltraining"
  case strengthTraining = "figure.strengthtraining.functional"
  case running = "figure.roll.runningpace"
  case yoga = "figure.yoga"
  case squash = "figure.squash"
  case fencing = "figure.fencing"
  case dance = "figure.dance"
  case climbing = "figure.climbing"
  private static let fallback = "figure.fall"

  static var random: String {
    allCases.randomElement()?.rawValue ?? fallback
  }
}
