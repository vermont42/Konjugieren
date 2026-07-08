// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite(.serialized)
@MainActor
struct GameStateTests {
  private static let screenWidth: CGFloat = 400
  private static let screenHeight: CGFloat = 800

  private func startedGame() -> GameState {
    let game = GameState()
    game.startGame(screenWidth: Self.screenWidth, screenHeight: Self.screenHeight, topInset: 0)
    return game
  }

  @Suite(.serialized)
  @MainActor
  struct DamageInvulnerability {
    private func startedGame() -> GameState {
      let game = GameState()
      game.startGame(screenWidth: 400, screenHeight: 800, topInset: 0)
      return game
    }

    @Test func firstHitDamagesAndArmsCooldown() {
      let game = startedGame()
      #expect(game.playerHealth == 1.0)
      #expect(game.damageCooldown == 0)

      game.damagePlayer()

      #expect(game.playerHealth == 1.0 - GameState.healthLossPerHit)
      #expect(game.damageCooldown == GameState.damageInvulnerability)
    }

    @Test func secondHitDuringCooldownIsIgnored() {
      let game = startedGame()

      game.damagePlayer()
      let healthAfterFirstHit = game.playerHealth
      game.damagePlayer()

      #expect(game.playerHealth == healthAfterFirstHit)
    }

    @Test func damageResumesAfterCooldownCleared() {
      let game = startedGame()

      game.damagePlayer()
      game.damageCooldown = 0
      game.damagePlayer()

      #expect(game.playerHealth == 1.0 - GameState.healthLossPerHit * 2)
    }

    @Test func updateCountsDownCooldown() {
      let game = startedGame()
      game.damagePlayer()

      let t0 = Date(timeIntervalSinceReferenceDate: 1000)
      game.update(currentTime: t0)
      game.update(currentTime: t0.addingTimeInterval(0.5))

      #expect(abs(game.damageCooldown - (GameState.damageInvulnerability - 0.5)) < 0.0001)
    }

    @Test func shieldedHitStillArmsCooldownButLosesNoHealth() {
      let game = startedGame()
      game.shieldActive = true

      game.damagePlayer()

      #expect(game.playerHealth == 1.0)
      #expect(game.damageCooldown == GameState.damageInvulnerability)
    }
  }

  @Suite(.serialized)
  @MainActor
  struct RobotMechanic {
    private func startedGame() -> GameState {
      let game = GameState()
      game.startGame(screenWidth: 400, screenHeight: 800, topInset: 0)
      return game
    }

    private func convertingBrain(targetEnemyIndex: Int) -> RobotBrain {
      var brain = RobotBrain(x: 200, y: 100, movingRight: true)
      brain.phase = .converting
      brain.targetEnemyIndex = targetEnemyIndex
      return brain
    }

    @Test func deadTargetConversionClearsActiveMechanic() {
      let game = startedGame()
      game.enemies[0].isAlive = false
      game.activeMechanic = .robot
      game.robotMinion = nil
      game.robotBrain = convertingBrain(targetEnemyIndex: 0)

      game.updateRobot(dt: 0.016)

      #expect(game.robotBrain == nil)
      #expect(game.robotMinion == nil)
      #expect(game.activeMechanic == nil)
    }

    @Test func liveTargetConversionKeepsMechanicActive() {
      let game = startedGame()
      game.activeMechanic = .robot
      game.robotMinion = nil
      game.robotBrain = convertingBrain(targetEnemyIndex: 1)

      game.updateRobot(dt: 0.016)

      #expect(game.robotBrain == nil)
      #expect(game.robotMinion != nil)
      #expect(game.activeMechanic == .robot)
    }
  }

  @Suite(.serialized)
  @MainActor
  struct GameOverAndWaves {
    private func startedGame() -> GameState {
      let game = GameState()
      game.startGame(screenWidth: 400, screenHeight: 800, topInset: 0)
      return game
    }

    private func step(_ game: GameState) {
      let t0 = Date(timeIntervalSinceReferenceDate: 1000)
      game.update(currentTime: t0)
      game.update(currentTime: t0.addingTimeInterval(0.1))
    }

    @Test func depletedHealthEndsGame() {
      let game = startedGame()
      game.playerHealth = 0

      step(game)

      #expect(game.phase == .lost)
    }

    @Test func clearingAllEnemiesCompletesWave() {
      let game = startedGame()
      for i in game.enemies.indices {
        game.enemies[i].isAlive = false
      }

      step(game)

      #expect(game.phase == .waveComplete)
      #expect(game.waveCompleteTime != nil)
    }

    @Test func waveCompleteAdvancesToNextWave() {
      let game = startedGame()
      for i in game.enemies.indices {
        game.enemies[i].isAlive = false
      }
      step(game)
      #expect(game.phase == .waveComplete)

      guard let wct = game.waveCompleteTime else {
        Issue.record("Expected waveCompleteTime to be set")
        return
      }
      game.update(currentTime: wct.addingTimeInterval(GameState.waveCompleteDuration + 0.1))

      #expect(game.wave == 2)
      #expect(game.phase == .playing)
      #expect(game.enemies.filter(\.isAlive).count == GameState.rows * GameState.cols)
    }
  }

  @Test func snapshotRoundTripsDamageCooldown() {
    let game = startedGame()
    game.damagePlayer()

    let snapshot = game.makeSnapshot()
    #expect(snapshot.damageCooldown == GameState.damageInvulnerability)

    let restored = GameState()
    restored.restoreGame(from: snapshot, screenWidth: Self.screenWidth, screenHeight: Self.screenHeight, topInset: 0)

    #expect(restored.damageCooldown == GameState.damageInvulnerability)
  }
}
