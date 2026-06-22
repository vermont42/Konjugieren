// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

extension GameState {
  func spawnRobot() {
    robotBrain = RobotBrain(
      x: screenWidth / 2,
      y: playerY - 30,
      movingRight: Bool.random()
    )
  }

  func updateRobot(dt: CGFloat) {
    updateRobotBrain(dt: dt)
    updateRobotMinion(dt: dt)
  }

  private func updateRobotBrain(dt: CGFloat) {
    guard var brain = robotBrain else { return }

    switch brain.phase {
    case .ascending:
      let dx = Self.brainSpeed * dt * (brain.movingRight ? 1 : -1)
      brain.x += dx
      brain.y -= Self.brainAscentSpeed * dt
      let half = Self.brainSize / 2
      if brain.x <= half || brain.x >= screenWidth - half {
        brain.x = max(half, min(screenWidth - half, brain.x))
        brain.movingRight.toggle()
      }

      let topAliveEnemies = enemies.indices.filter { enemies[$0].isAlive && !enemies[$0].isDiving }
      if !topAliveEnemies.isEmpty {
        let topRow = topAliveEnemies.map { enemies[$0].row }.min() ?? 0
        let topRowEnemies = topAliveEnemies.filter { enemies[$0].row == topRow }
        let closestIdx = topRowEnemies.min(by: { abs(enemies[$0].x - brain.x) < abs(enemies[$1].x - brain.x) })
        if let targetIdx = closestIdx {
          let targetY = enemies[targetIdx].y - 40
          if brain.y <= targetY {
            brain.phase = .lockedOn
            brain.targetEnemyIndex = targetIdx
            brain.lockOnTimer = 0
            Current.soundPlayer.play(.brainLockOn, shouldDebounce: false)
          }
        }
      }

      if brain.y < topInset - 50 {
        robotBrain = nil
        if activeMechanic == .robot {
          activeMechanic = nil
        }
        return
      }

    case .lockedOn:
      brain.lockOnTimer += dt
      if let targetIdx = brain.targetEnemyIndex, targetIdx < enemies.count, enemies[targetIdx].isAlive {
        brain.x = enemies[targetIdx].x
        brain.y = enemies[targetIdx].y - 40
      }

      if brain.lockOnTimer >= Self.boltAppearDelay {
        brain.showBolt = true
      }

      if brain.lockOnTimer >= Self.boltAppearDelay + Self.conversionDelay {
        brain.phase = .converting
      }

    case .converting:
      if let targetIdx = brain.targetEnemyIndex, targetIdx < enemies.count, enemies[targetIdx].isAlive {
        let enemy = enemies[targetIdx]
        let midX = (brain.x + enemy.x) / 2
        let midY = (brain.y + enemy.y) / 2
        deathEffects.append(DeathEffect(x: midX, y: midY, imageName: enemy.imageName, useRed: Bool.random()))
        Current.soundPlayer.play(.brainConvert, shouldDebounce: false)
        HapticPlayer.playImpact(.heavy)

        robotMinion = RobotMinion(
          x: enemy.x,
          y: enemy.y,
          homeX: enemy.x,
          homeY: enemy.y,
          originalEnemyImageName: enemy.imageName
        )
        enemies[targetIdx].isAlive = false
      }
      robotBrain = nil
      return
    }

    robotBrain = brain
  }

  private func updateRobotMinion(dt: CGFloat) {
    guard var minion = robotMinion else { return }

    if minion.isDiving {
      minion.diveProgress += dt / Self.robotDiveDuration
      if minion.diveProgress >= 1.0 {
        minion.x = minion.homeX
        minion.y = minion.homeY
        minion.isDiving = false
        minion.diveProgress = 0
        minion.divePauseTimer = 0
      } else {
        let t = minion.diveProgress
        let depth = screenHeight * Self.robotDiveDepthFactor
        let baselineY = minion.diveStartY * (1 - t) + minion.homeY * t
        let diveOffset = 4 * depth * t * (1 - t)
        minion.y = baselineY + diveOffset
        minion.x = minion.homeX + Self.robotDiveWidthAmplitude * CGFloat(sin(Double(t) * .pi * 4))
      }
    } else {
      minion.divePauseTimer += dt
      if minion.divePauseTimer >= Self.robotDivePause {
        minion.isDiving = true
        minion.diveProgress = 0
        minion.diveStartX = minion.x
        minion.diveStartY = minion.y
        Current.soundPlayer.play(.brainLockOn, shouldDebounce: false)
      }
    }

    robotMinion = minion
  }
}
