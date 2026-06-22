// Copyright © 2026 Josh Adams. All rights reserved.

import GameKit
import Observation
import UIKit
import os

private let gameCenterLogger = KonjugierenLogger.logger(category: "GameCenter")

@MainActor
@Observable
class GameCenterReal: GameCenter {
  static let leaderboardID = "Leaderboard"

  private(set) var isAuthenticated = false

  func authenticate() {
    GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
      if let error {
        gameCenterLogger.warning("Unable to authenticate GameCenter: \(error.localizedDescription)")
        return
      }

      if let viewController {
        Self.topViewController()?.present(viewController, animated: true)
        return
      }

      self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
    }
  }

  private static func topViewController() -> UIViewController? {
    let scene = UIApplication.shared.connectedScenes
      .first { $0.activationState == .foregroundActive } as? UIWindowScene
    let keyWindow = scene?.windows.first { $0.isKeyWindow } ?? scene?.windows.first
    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
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
    } catch {
      gameCenterLogger.warning("Failed to submit score: \(error.localizedDescription)")
    }
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
