// Copyright © 2025 Josh Adams. All rights reserved.

class GameCenterDummy: GameCenter {
  var isAuthenticated: Bool { true }
  func authenticate() {}
  func submitScore(_ score: Int) async {}
  func showLeaderboard() {}
}
