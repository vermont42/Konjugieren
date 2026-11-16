// Copyright © 2026 Josh Adams. All rights reserved.

import GameKit
import Observation
import UIKit
import os

private let gameCenterLogger = KonjugierenLogger.logger(category: "GameCenter")

@MainActor
@Observable
class GameCenterReal: GameCenter {
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
      if GKLocalPlayer.local.isAuthenticated {
        self?.loadReportedAchievements()
      }
    }
  }

  /// What Game Center holds for the signed-in player, by achievement ID, once loaded. Until then,
  /// reports wait in `pendingAchievements`, so that progress made while signed out, or before
  /// sign-in finished at launch, is sent once the player is known.
  private var reportedAchievements: [String: Double]?
  private var pendingAchievements: [Achievement: Double] = [:]

  /// The handler may run again for another player, so each sign-in loads afresh.
  private func loadReportedAchievements() {
    reportedAchievements = nil
    GKAchievement.loadAchievements { [weak self] achievements, error in
      let failure = error?.localizedDescription
      let loaded = Dictionary((achievements ?? []).map { ($0.identifier, $0.percentComplete) }, uniquingKeysWith: max)
      Task { @MainActor in
        if let failure {
          gameCenterLogger.warning("Unable to load achievements: \(failure)")
        }
        self?.reportedAchievements = loaded
        self?.sendPendingAchievements()
      }
    }
  }

  func reportAchievementProgress(_ percentComplete: [Achievement: Double]) {
    pendingAchievements.merge(percentComplete, uniquingKeysWith: max)
    sendPendingAchievements()
  }

  /// Sends only progress that has risen. The practice record can fall, a wrong answer sending an
  /// item down the ladder, but an achievement once earned stays earned, so a fall is never sent.
  private func sendPendingAchievements() {
    guard isAuthenticated, let reported = reportedAchievements else { return }

    let risen = pendingAchievements.filter { achievement, percent in
      percent > (reported[achievement.identifier] ?? 0)
    }
    pendingAchievements = [:]
    guard !risen.isEmpty else { return }

    let achievements = risen.map { achievement, percent in
      let gkAchievement = GKAchievement(identifier: achievement.identifier)
      gkAchievement.percentComplete = percent
      gkAchievement.showsCompletionBanner = true
      return gkAchievement
    }
    let sent = Dictionary(uniqueKeysWithValues: risen.map { ($0.key.identifier, $0.value) })
    GKAchievement.report(achievements) { [weak self] error in
      let failure = error?.localizedDescription
      Task { @MainActor in
        if let failure {
          gameCenterLogger.warning("Failed to report achievements: \(failure)")
          return
        }
        self?.reportedAchievements?.merge(sent, uniquingKeysWith: max)
      }
    }
  }

  func showAchievements() {
    guard isAuthenticated else { return }

    GKAccessPoint.shared.trigger(state: .achievements) {}
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

  func submitScore(_ score: Int, level: QuizLevel) {
    guard isAuthenticated else { return }

    let leaderboardID = level.leaderboardID
    Task {
      do {
        try await GKLeaderboard.submitScore(
          score,
          context: 0,
          player: GKLocalPlayer.local,
          leaderboardIDs: [leaderboardID]
        )
      } catch {
        gameCenterLogger.warning("Failed to submit score to \(leaderboardID): \(error.localizedDescription)")
      }
    }
  }

  func showLeaderboard(level: QuizLevel) {
    guard isAuthenticated else { return }

    GKAccessPoint.shared.trigger(
      leaderboardID: level.leaderboardID,
      playerScope: .global,
      timeScope: .allTime
    ) {}
  }

  func showLeaderboards() {
    guard isAuthenticated else { return }

    GKAccessPoint.shared.trigger(state: .leaderboards) {}
  }
}
