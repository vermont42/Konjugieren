// Copyright © 2026 Josh Adams. All rights reserved.

import GameKit
import Observation

@Observable
class GameCenterManager {
  static let leaderboardID = "Leaderboard"

  private(set) var isAuthenticated = false

  func authenticate() {
    GKLocalPlayer.local.authenticateHandler = { [weak self] _, error in
      guard error == nil else {
        return
      }

      self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
    }
  }

  func submitScore(_ score: Int) async {
    guard isAuthenticated else { return }

    do {
      try await GKLeaderboard.submitScore(
        score,
        context: 0,
        player: GKLocalPlayer.local,
        leaderboardIDs: [Self.leaderboardID]
      )
    } catch {}
  }

  func showLeaderboard() {
    guard isAuthenticated else { return }

    GKAccessPoint.shared.trigger(
      leaderboardID: Self.leaderboardID,
      playerScope: .global,
      timeScope: .allTime
    ) {}
  }
}
