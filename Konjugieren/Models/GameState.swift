// Copyright © 2026 Josh Adams. All rights reserved.

import CoreMotion
import SwiftUI

struct Enemy: Identifiable {
  let id = UUID()
  let row: Int
  let col: Int
  var x: CGFloat
  var y: CGFloat
  var isAlive: Bool = true
  let imageName: String
}

struct Bullet: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  let isPlayerBullet: Bool
}

struct Horse {
  var x: CGFloat
  var y: CGFloat
  var movingRight: Bool
}

enum GamePhase {
  case playing
  case won
  case lost
}

@MainActor
@Observable
class GameState {
  var phase: GamePhase = .playing
  var playerX: CGFloat = 0
  var playerY: CGFloat = 0
  var playerHealth: CGFloat = 1.0
  var enemies: [Enemy] = []
  var playerBullet: Bullet?
  var enemyBullet: Bullet?
  var horse: Horse?
  var score: Int = 0
  var highScore: Int = 0
  var finalScore: Int = 0
  var startTime: Date = .now
  var enemyDirection: CGFloat = 1
  var enemySpeed: CGFloat = 30
  var sineTime: Double = 0
  var screenWidth: CGFloat = 0
  var screenHeight: CGFloat = 0
  private var topInset: CGFloat = 0

  private var horseSpawnTimer: CGFloat = 0

  private let motionManager = CMMotionManager()
  private var lastUpdateTime: Date?

  private static let rows = 6
  private static let cols = 6
  private static let enemySpacingX: CGFloat = 45
  private static let enemySpacingY: CGFloat = 40
  private static let playerBulletSpeed: CGFloat = 450
  private static let enemyBulletSpeed: CGFloat = 300
  private static let playerSize: CGFloat = 40
  private static let enemySize: CGFloat = 30
  private static let bulletSize: CGFloat = 20
  private static let accelerometerThreshold: Double = 0.02
  private static let accelerometerSensitivity: CGFloat = 800
  private static let healthLossPerHit: CGFloat = 0.334
  private static let enemyFireChance: Double = 0.02
  private static let speedUpFactor: CGFloat = 0.95
  private static let sineAmplitude: CGFloat = 8
  private static let sineFrequency: Double = 2.0
  private static let scorePerKill: Int = 100
  private static let horseSize: CGFloat = 40
  private static let horseSpeedH: CGFloat = 160
  private static let horseSpeedV: CGFloat = 80
  private static let horseSpawnInterval: CGFloat = 20
  private static let enemyImages = ["Hat", "Bundestag", "Stein", "Dachshund", "Clock", "Nutcracker"]

  func startGame(screenWidth: CGFloat, screenHeight: CGFloat, topInset: CGFloat) {
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.topInset = topInset

    phase = .playing
    score = 0
    playerHealth = 1.0
    enemyDirection = 1
    enemySpeed = 30
    sineTime = 0
    playerBullet = nil
    enemyBullet = nil
    horse = nil
    horseSpawnTimer = 0
    startTime = .now
    lastUpdateTime = nil

    highScore = Current.settings.gameHighScore

    playerX = screenWidth / 2
    playerY = screenHeight - 60

    enemies = []
    let gridWidth = CGFloat(Self.cols - 1) * Self.enemySpacingX
    let startX = (screenWidth - gridWidth) / 2
    let startY = topInset + 40

    for row in 0..<Self.rows {
      for col in 0..<Self.cols {
        let x = startX + CGFloat(col) * Self.enemySpacingX
        let y = startY + CGFloat(row) * Self.enemySpacingY
        let imageName = Self.enemyImages[row % Self.enemyImages.count]
        enemies.append(Enemy(row: row, col: col, x: x, y: y, imageName: imageName))
      }
    }

    startMotion()
    Current.analytics.signal(name: .startGame)
  }

  func update(currentTime: Date) {
    guard phase == .playing else { return }

    let dt: CGFloat
    if let last = lastUpdateTime {
      dt = CGFloat(currentTime.timeIntervalSince(last))
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime

    guard dt > 0, dt < 1 else { return }

    updatePlayerPosition(dt: dt)
    updateEnemies(dt: dt)
    updateBullets(dt: dt)
    updateHorse(dt: dt)
    checkCollisions()
    attemptEnemyFire()
    checkGameOver()
  }

  func playerFire() {
    guard phase == .playing, playerBullet == nil else { return }
    playerBullet = Bullet(x: playerX, y: playerY - Self.playerSize / 2, isPlayerBullet: true)
    Current.soundPlayer.play(.chime, shouldDebounce: false)
  }

  func computeFinalScore() -> Int {
    let elapsed = Date.now.timeIntervalSince(startTime)
    let raw = Float(score) * (Float(playerHealth) + 1.0) - Float(elapsed)
    return max(0, Int(raw))
  }

  func stopMotion() {
    if motionManager.isAccelerometerActive {
      motionManager.stopAccelerometerUpdates()
    }
  }

  func resumeMotion() {
    lastUpdateTime = nil
    startMotion()
  }

  func restartGame() {
    startGame(screenWidth: screenWidth, screenHeight: screenHeight, topInset: topInset)
  }

  // MARK: - Private

  private func startMotion() {
    guard motionManager.isAccelerometerAvailable, !motionManager.isAccelerometerActive else { return }
    motionManager.accelerometerUpdateInterval = 1.0 / 60.0
    motionManager.startAccelerometerUpdates()
  }

  private func updatePlayerPosition(dt: CGFloat) {
    guard let data = motionManager.accelerometerData else { return }
    let tilt = data.acceleration.x
    if abs(tilt) > Self.accelerometerThreshold {
      playerX += CGFloat(tilt) * Self.accelerometerSensitivity * dt
      playerX = max(Self.playerSize / 2, min(screenWidth - Self.playerSize / 2, playerX))
    }
  }

  private func updateEnemies(dt: CGFloat) {
    var hitEdge = false

    for i in enemies.indices where enemies[i].isAlive {
      enemies[i].x += enemyDirection * enemySpeed * dt
      if enemies[i].x <= Self.enemySize / 2 || enemies[i].x >= screenWidth - Self.enemySize / 2 {
        hitEdge = true
      }
    }

    if hitEdge {
      enemyDirection *= -1
      for i in enemies.indices where enemies[i].isAlive {
        enemies[i].y += Self.enemySpacingY / 2
      }
      enemySpeed /= Self.speedUpFactor
    }

    sineTime += Double(dt) * Self.sineFrequency
  }

  private func updateBullets(dt: CGFloat) {
    if var bullet = playerBullet {
      bullet.y -= Self.playerBulletSpeed * dt
      if bullet.y < -Self.bulletSize {
        playerBullet = nil
      } else {
        playerBullet = Bullet(x: bullet.x, y: bullet.y, isPlayerBullet: true)
      }
    }

    if var bullet = enemyBullet {
      bullet.y += Self.enemyBulletSpeed * dt
      if bullet.y > screenHeight + Self.bulletSize {
        enemyBullet = nil
      } else {
        enemyBullet = Bullet(x: bullet.x, y: bullet.y, isPlayerBullet: false)
      }
    }
  }

  private func updateHorse(dt: CGFloat) {
    horseSpawnTimer += dt

    if horse == nil && horseSpawnTimer >= Self.horseSpawnInterval {
      horse = Horse(x: screenWidth - Self.horseSize / 2, y: topInset + Self.horseSize / 2, movingRight: false)
      Current.soundPlayer.play(.neigh, shouldDebounce: false)
      horseSpawnTimer = 0
    }

    guard var h = horse else { return }

    let dx = Self.horseSpeedH * dt * (h.movingRight ? 1 : -1)
    h.x += dx
    h.y += Self.horseSpeedV * dt

    if h.y > screenHeight + Self.horseSize {
      horse = nil
      return
    }

    let halfSize = Self.horseSize / 2
    if h.x <= halfSize {
      h.x = halfSize
      h.movingRight = true
      Current.soundPlayer.play(.neigh, shouldDebounce: false)
    } else if h.x >= screenWidth - halfSize {
      h.x = screenWidth - halfSize
      h.movingRight = false
      Current.soundPlayer.play(.neigh, shouldDebounce: false)
    }

    horse = h
  }

  private func checkCollisions() {
    if let bullet = playerBullet {
      for i in enemies.indices where enemies[i].isAlive {
        if rectsIntersect(
          ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
          bx: enemies[i].x, by: enemies[i].y, bSize: Self.enemySize
        ) {
          enemies[i].isAlive = false
          playerBullet = nil
          score += Self.scorePerKill
          Current.soundPlayer.play(.buzz, shouldDebounce: false)
          break
        }
      }
    }

    if let bullet = enemyBullet {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        enemyBullet = nil
        playerHealth -= Self.healthLossPerHit
        Current.soundPlayer.play(.buzz, shouldDebounce: false)
      }
    }

    if let h = horse {
      if let bullet = playerBullet, rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: h.x, by: h.y, bSize: Self.horseSize
      ) {
        horse = nil
        playerBullet = nil
        score += Self.scorePerKill
        Current.soundPlayer.play(.buzz, shouldDebounce: false)
      } else if rectsIntersect(
        ax: h.x, ay: h.y, aSize: Self.horseSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        horse = nil
        playerHealth -= Self.healthLossPerHit
        Current.soundPlayer.play(.buzz, shouldDebounce: false)
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

  private func attemptEnemyFire() {
    guard enemyBullet == nil else { return }
    let aliveEnemies = enemies.filter(\.isAlive)
    guard !aliveEnemies.isEmpty else { return }

    if Double.random(in: 0...1) < Self.enemyFireChance {
      let shooter = aliveEnemies.randomElement() ?? aliveEnemies[0]
      enemyBullet = Bullet(x: shooter.x, y: shooter.y + Self.enemySize / 2, isPlayerBullet: false)
      Current.soundPlayer.play(.chime, shouldDebounce: false)
    }
  }

  private func checkGameOver() {
    guard !enemies.isEmpty else { return }
    let aliveEnemies = enemies.filter(\.isAlive)

    if aliveEnemies.isEmpty {
      phase = .won
      Current.soundPlayer.play(.randomApplause, shouldDebounce: false)
      persistHighScore()
      Current.analytics.signal(name: .winGame)
      return
    }

    if playerHealth <= 0 {
      phase = .lost
      Current.soundPlayer.play(.randomSadTrombone, shouldDebounce: false)
      persistHighScore()
      Current.analytics.signal(name: .loseGame)
      return
    }

    let bottomThreshold = playerY - Self.playerSize
    for enemy in aliveEnemies where enemy.y >= bottomThreshold {
      phase = .lost
      Current.soundPlayer.play(.randomSadTrombone, shouldDebounce: false)
      persistHighScore()
      Current.analytics.signal(name: .loseGame)
      return
    }
  }

  private func persistHighScore() {
    finalScore = computeFinalScore()
    if finalScore > highScore {
      highScore = finalScore
      Current.settings.gameHighScore = finalScore
    }
  }

  func sineOffset(forRow row: Int) -> CGFloat {
    Self.sineAmplitude * CGFloat(sin(sineTime + Double(row) * 0.5))
  }
}
