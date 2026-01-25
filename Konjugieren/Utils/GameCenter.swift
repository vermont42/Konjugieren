// Copyright © 2025 Josh Adams. All rights reserved.

protocol GameCenter{
  var isAuthenticated: Bool { get }
  func authenticate()
  func submitScore(_ score: Int) async
  func showLeaderboard()
}
