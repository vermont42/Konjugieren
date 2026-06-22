// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

extension GameState {
  func checkCollisions() {
    collidePlayerBulletWithHatchlings()
    collidePlayerBulletWithEnemies()
    collidePlayerBulletWithZigzagger()
    collideEnemyBulletWithPlayer()
    collideDivingEnemiesWithPlayer()
    collideZigzaggerWithPlayer()
    collectCoins()
    collectPowerUps()
    collectEggs()
    collideHatchlingsWithPlayer()
    collidePlayerBulletWithWurst()
    collidePlayerBulletWithPretzels()
    collideEnemyBulletWithPretzels()
    collideWurstWithPlayer()
    collideFussballWithEnemies()
    collideFussballWithPlayer()
    collidePlayerBulletWithFussball()
    collideFussballWithPretzels()
    collidePlayerBulletWithKristallkugel()
    collidePlayerBulletWithGoldenDots()
    collideGhostsWithPlayer()
    collidePlayerBulletWithRobotBrain()
    collidePlayerBulletWithRobotMinion()
    collideRobotMinionWithPlayer()
  }

  private func collidePlayerBulletWithHatchlings() {
    if let bullet = playerBullet {
      if let idx = hatchlings.firstIndex(where: { h in
        rectsIntersect(ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
                       bx: h.x, by: h.y, bSize: Self.hatchlingSize)
      }) {
        hatchlings.remove(at: idx)
        playerBullet = nil
        score += Self.hatchlingScore
        Current.soundPlayer.play(.pop, shouldDebounce: false)
        HapticPlayer.playImpact(.medium)
      }
    }
  }

  private func collidePlayerBulletWithEnemies() {
    if let bullet = playerBullet {
      for i in enemies.indices where enemies[i].isAlive {
        if rectsIntersect(
          ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
          bx: enemies[i].x, by: enemies[i].y, bSize: Self.enemySize
        ) {
          let wasDiving = enemies[i].isDiving
          deathEffects.append(DeathEffect(x: enemies[i].x, y: enemies[i].y, imageName: enemies[i].imageName, useRed: Bool.random()))
          enemies[i].isAlive = false
          playerBullet = nil
          score += wasDiving ? Self.scorePerKill * Self.diveScoreMultiplier : Self.scorePerKill
          Current.soundPlayer.play(.pop, shouldDebounce: false)
          HapticPlayer.playImpact(.medium)
          if Double.random(in: 0...1) < Self.powerUpDropChance {
            let kind = PowerUpKind.allCases.randomElement() ?? .bratwurst
            powerUps.append(PowerUp(x: enemies[i].x, y: enemies[i].y, kind: kind))
          }
          break
        }
      }
    }
  }

  private func collidePlayerBulletWithZigzagger() {
    if let z = zigzagger, let bullet = playerBullet {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: z.x, by: z.y, bSize: Self.zigzaggerSize
      ) {
        eggs.append(Egg(x: z.x, y: z.y, velocityY: Self.eggInitialFallSpeed))
        zigzagger = nil
        playerBullet = nil
        score += Self.scorePerKill
        Current.soundPlayer.play(.chime, shouldDebounce: false)
        HapticPlayer.playImpact(.medium)
      }
    }
  }

  private func collideEnemyBulletWithPlayer() {
    if let bullet = enemyBullet {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        enemyBullet = nil
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
          portalSide = nil
        }
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
        HapticPlayer.playImpact(.heavy)
      }
    }
  }

  private func collideDivingEnemiesWithPlayer() {
    for i in enemies.indices where enemies[i].isAlive && enemies[i].isDiving {
      if rectsIntersect(
        ax: enemies[i].x, ay: enemies[i].y, aSize: Self.enemySize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        deathEffects.append(DeathEffect(x: enemies[i].x, y: enemies[i].y, imageName: enemies[i].imageName, useRed: Bool.random()))
        enemies[i].isAlive = false
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
          portalSide = nil
        }
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
        HapticPlayer.playImpact(.heavy)
      }
    }
  }

  private func collideZigzaggerWithPlayer() {
    if let z = zigzagger {
      if rectsIntersect(
        ax: z.x, ay: z.y, aSize: Self.zigzaggerSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        zigzagger = nil
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
          portalSide = nil
        }
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
        HapticPlayer.playImpact(.heavy)
      }
    }
  }

  private func collectCoins() {
    coins.removeAll { coin in
      if rectsIntersect(
        ax: coin.x, ay: coin.y, aSize: Self.coinSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        score += Self.coinScore
        Current.soundPlayer.play(.coin, shouldDebounce: false)
        HapticPlayer.playImpact(.light)
        return true
      }
      return false
    }
  }

  private func collectPowerUps() {
    powerUps.removeAll { powerUp in
      if rectsIntersect(
        ax: powerUp.x, ay: powerUp.y, aSize: Self.powerUpSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        switch powerUp.kind {
        case .bratwurst:
          playerHealth = min(1.0, playerHealth + Self.healthRestoreAmount)
          Current.soundPlayer.play(.coin, shouldDebounce: false)
        case .bier:
          shieldActive = true
          shieldTimer = Self.shieldDuration
          Current.soundPlayer.play(.shieldActivate, shouldDebounce: false)
        case .kartoffel:
          rapidFireActive = true
          rapidFireTimer = Self.rapidFireDuration
          rapidFireCooldown = 0
          rapidFireSound = .randomLongFire
          Current.soundPlayer.play(rapidFireSound, shouldDebounce: false, volume: 0.5)
        }
        HapticPlayer.playImpact(.light)
        return true
      }
      return false
    }
  }

  private func collectEggs() {
    eggs.removeAll { egg in
      if rectsIntersect(
        ax: egg.x, ay: egg.y, aSize: Self.eggSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        score += Self.eggScore
        Current.soundPlayer.play(.coin, shouldDebounce: false)
        HapticPlayer.playImpact(.light)
        return true
      }
      return false
    }
  }

  private func collideHatchlingsWithPlayer() {
    hatchlings.removeAll { hatchling in
      if rectsIntersect(
        ax: hatchling.x, ay: hatchling.y, aSize: Self.hatchlingSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
          portalSide = nil
        }
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
        HapticPlayer.playImpact(.heavy)
        return true
      }
      return false
    }
  }

  private func collidePlayerBulletWithWurst() {
    if let bullet = playerBullet {
      var consumed = false
      for chainIdx in wurstChains.indices.reversed() {
        for segIdx in wurstChains[chainIdx].segments.indices {
          let seg = wurstChains[chainIdx].segments[segIdx]
          if rectsIntersect(
            ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
            bx: seg.x, by: seg.y, bSize: Self.wurstSegmentSize
          ) {
            score += Self.wurstSegmentScore
            playerBullet = nil
            consumed = true
            Current.soundPlayer.play(.pop, shouldDebounce: false)
            HapticPlayer.playImpact(.medium)
            pretzelObstacles.append(PretzelObstacle(x: seg.x, y: seg.y))
            let chain = wurstChains[chainIdx]
            var newChains: [WurstChain] = []
            if segIdx > 0 {
              let leftSegments = Array(chain.segments[0..<segIdx])
              newChains.append(WurstChain(segments: leftSegments, movingRight: chain.movingRight, speed: chain.speed))
            }
            if segIdx < chain.segments.count - 1 {
              let rightSegments = Array(chain.segments[(segIdx + 1)...])
              newChains.append(WurstChain(segments: rightSegments, movingRight: chain.movingRight, speed: chain.speed))
            }
            wurstChains.remove(at: chainIdx)
            wurstChains.append(contentsOf: newChains)
            break
          }
        }
        if consumed {
          break
        }
      }
    }
  }

  private func collidePlayerBulletWithPretzels() {
    if let bullet = playerBullet {
      if let idx = pretzelObstacles.firstIndex(where: { p in
        p.hitsRemaining > 0 && rectsIntersect(ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
                       bx: p.x, by: p.y, bSize: Self.pretzelObstacleSize)
      }) {
        playerBullet = nil
        pretzelObstacles[idx].hitsRemaining -= 1
        Current.soundPlayer.play(.chime, shouldDebounce: false)
        HapticPlayer.playImpact(.light)
      }
    }
  }

  private func collideEnemyBulletWithPretzels() {
    if let bullet = enemyBullet {
      if let idx = pretzelObstacles.firstIndex(where: { p in
        p.hitsRemaining > 0 && rectsIntersect(ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
                       bx: p.x, by: p.y, bSize: Self.pretzelObstacleSize)
      }) {
        enemyBullet = nil
        pretzelObstacles[idx].hitsRemaining -= 1
        Current.soundPlayer.play(.chime, shouldDebounce: false)
      }
    }
  }

  private func collideWurstWithPlayer() {
    for chain in wurstChains {
      for seg in chain.segments {
        if rectsIntersect(
          ax: seg.x, ay: seg.y, aSize: Self.wurstSegmentSize,
          bx: playerX, by: playerY, bSize: Self.playerSize
        ) {
          if !shieldActive {
            playerHealth -= Self.healthLossPerHit
            portalSide = nil
          }
          Current.soundPlayer.play(.playerHit, shouldDebounce: false)
          HapticPlayer.playImpact(.heavy)
        }
      }
    }
  }

  private func collideFussballWithEnemies() {
    if var ball = fussball {
      for i in enemies.indices where enemies[i].isAlive {
        if rectsIntersect(
          ax: ball.x, ay: ball.y, aSize: Self.fussballSize,
          bx: enemies[i].x, by: enemies[i].y, bSize: Self.enemySize
        ) {
          deathEffects.append(DeathEffect(x: enemies[i].x, y: enemies[i].y, imageName: enemies[i].imageName, useRed: Bool.random()))
          enemies[i].isAlive = false
          score += Self.fussballEnemyKillScore
          Current.soundPlayer.play(.pop, shouldDebounce: false)
          HapticPlayer.playImpact(.medium)
          ball.velocityY = -ball.velocityY
          if Double.random(in: 0...1) < Self.powerUpDropChance {
            let kind = PowerUpKind.allCases.randomElement() ?? .bratwurst
            powerUps.append(PowerUp(x: enemies[i].x, y: enemies[i].y, kind: kind))
          }
        }
      }
      fussball = ball
    }
  }

  private func collideFussballWithPlayer() {
    if let ball = fussball {
      if rectsIntersect(
        ax: ball.x, ay: ball.y, aSize: Self.fussballSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
          portalSide = nil
        }
        fussball?.velocityY = -abs(ball.velocityY)
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
        HapticPlayer.playImpact(.heavy)
      }
    }
  }

  private func collidePlayerBulletWithFussball() {
    if var ball = fussball, let bullet = playerBullet {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: ball.x, by: ball.y, bSize: Self.fussballSize
      ) {
        playerBullet = nil
        ball.velocityY = -abs(ball.velocityY)
        ball.velocityX += CGFloat.random(in: -80...80)
        Current.soundPlayer.play(.soccerKick, shouldDebounce: false)
        HapticPlayer.playImpact(.medium)
        fussball = ball
      }
    }
  }

  private func collideFussballWithPretzels() {
    if var ball = fussball {
      for i in pretzelObstacles.indices.reversed() {
        guard pretzelObstacles[i].hitsRemaining > 0 else { continue }
        if rectsIntersect(
          ax: ball.x, ay: ball.y, aSize: Self.fussballSize,
          bx: pretzelObstacles[i].x, by: pretzelObstacles[i].y, bSize: Self.pretzelObstacleSize
        ) {
          ball.velocityY = -ball.velocityY
          pretzelObstacles[i].hitsRemaining -= 1
          Current.soundPlayer.play(.soccerKick, shouldDebounce: false)
        }
      }
      fussball = ball
    }
  }

  private func collidePlayerBulletWithKristallkugel() {
    if let bullet = playerBullet, let kugel = kristallkugel {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: kugel.x, by: kugel.y, bSize: Self.kristallkugelSize
      ) {
        playerBullet = nil
        kristallkugel = nil
        geisterjagdActive = true
        geisterjagdTimer = Self.geisterjagdDuration
        Current.soundPlayer.play(.magicActivate, shouldDebounce: false)
        HapticPlayer.playImpact(.medium)
        for i in ghosts.indices {
          if ghosts[i].phase == .pursuing || ghosts[i].phase == .descending {
            ghosts[i].phase = .fleeing
          }
        }
      }
    }
  }

  private func collidePlayerBulletWithGoldenDots() {
    if let bullet = playerBullet {
      var hitDot = false
      goldenDots.removeAll { dot in
        if rectsIntersect(ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
                          bx: dot.x, by: dot.y, bSize: Self.dotSize) {
          score += Self.dotScore
          hitDot = true
          return true
        }
        return false
      }
      if hitDot {
        Current.soundPlayer.play(.coin, shouldDebounce: false)
        HapticPlayer.playImpact(.light)
      }
    }
  }

  private func collideGhostsWithPlayer() {
    for i in ghosts.indices {
      guard rectsIntersect(
        ax: ghosts[i].x, ay: ghosts[i].y, aSize: Self.ghostSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) else {
        continue
      }
      switch ghosts[i].phase {
      case .pursuing:
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
          portalSide = nil
        }
        ghosts[i].phase = .exiting
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
        HapticPlayer.playImpact(.heavy)
      case .fleeing:
        ghosts[i].phase = .devoured
        ghosts[i].dotTimer = 0
        score += Self.ghostDevourScore
        Current.soundPlayer.play(.chomp, shouldDebounce: false)
        HapticPlayer.playImpact(.medium)
      default:
        break
      }
    }
  }

  private func collidePlayerBulletWithRobotBrain() {
    if let bullet = playerBullet, var brain = robotBrain {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: brain.x, by: brain.y, bSize: Self.brainSize
      ) {
        playerBullet = nil
        brain.hitsRemaining -= 1
        if brain.hitsRemaining <= 0 {
          let imageName = brain.targetEnemyIndex.flatMap { idx in
            idx < enemies.count ? enemies[idx].imageName : nil
          } ?? "Hat"
          deathEffects.append(DeathEffect(x: brain.x, y: brain.y, imageName: imageName, useRed: Bool.random()))
          score += Self.brainScore
          robotBrain = nil
          if activeMechanic == .robot && robotMinion == nil {
            activeMechanic = nil
          }
        } else {
          robotBrain = brain
        }
        Current.soundPlayer.play(.pop, shouldDebounce: false)
        HapticPlayer.playImpact(.medium)
      }
    }
  }

  private func collidePlayerBulletWithRobotMinion() {
    if let bullet = playerBullet, var minion = robotMinion {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: minion.x, by: minion.y, bSize: Self.robotMinionSize
      ) {
        playerBullet = nil
        let offset = bullet.x - minion.x
        let hitLeft = offset < -Self.armHitZone && minion.hasLeftArm
        let hitRight = offset > Self.armHitZone && minion.hasRightArm

        let destroyed: Bool
        if hitLeft {
          minion.hasLeftArm = false
          destroyed = false
        } else if hitRight {
          minion.hasRightArm = false
          destroyed = false
        } else if !minion.isArmed {
          destroyed = true
        } else if minion.hasLeftArm && minion.hasRightArm {
          if Bool.random() {
            minion.hasLeftArm = false
          } else {
            minion.hasRightArm = false
          }
          destroyed = false
        } else {
          if minion.hasLeftArm {
            minion.hasLeftArm = false
          } else {
            minion.hasRightArm = false
          }
          destroyed = false
        }

        deathEffects.append(DeathEffect(x: minion.x, y: minion.y, imageName: minion.originalEnemyImageName, useRed: Bool.random()))
        if destroyed {
          score += Self.robotMinionScore
          robotMinion = nil
          if activeMechanic == .robot && robotBrain == nil {
            activeMechanic = nil
          }
        } else {
          robotMinion = minion
        }
        Current.soundPlayer.play(.pop, shouldDebounce: false)
        HapticPlayer.playImpact(.medium)
      }
    }
  }

  private func collideRobotMinionWithPlayer() {
    if let minion = robotMinion, minion.isDiving {
      if rectsIntersect(
        ax: minion.x, ay: minion.y, aSize: Self.robotMinionSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
          portalSide = nil
        }
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
        HapticPlayer.playImpact(.heavy)
      }
    }
  }

  private func rectsIntersect(ax: CGFloat, ay: CGFloat, aSize: CGFloat, bx: CGFloat, by: CGFloat, bSize: CGFloat) -> Bool {
    let aHalf = aSize / 2
    let bHalf = bSize / 2
    return ax - aHalf < bx + bHalf
      && ax + aHalf > bx - bHalf
      && ay - aHalf < by + bHalf
      && ay + aHalf > by - bHalf
  }
}
