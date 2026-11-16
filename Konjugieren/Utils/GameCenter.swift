// Copyright © 2025 Josh Adams. All rights reserved.

protocol GameCenter {
  var isAuthenticated: Bool { get }
  func authenticate()
  func submitScore(_ score: Int, level: QuizLevel)
  func showLeaderboard(level: QuizLevel)
  func showLeaderboards()
  /// Each achievement's progress, 0 to 100, as the practice record now stands.
  func reportAchievementProgress(_ percentComplete: [Achievement: Double])
  func showAchievements()
}

extension QuizLevel {
  // Leaderboard IDs are permanent in App Store Connect, so these must match
  // docs/game_center_setup.md exactly and never change, even if a level is renamed.
  var leaderboardID: String {
    switch self {
    case .beginner:
      return "konjugieren.level.beginner"
    case .elementary:
      return "konjugieren.level.elementary"
    case .intermediate:
      return "konjugieren.level.intermediate"
    case .advanced:
      return "konjugieren.level.advanced"
    }
  }
}
