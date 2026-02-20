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
  var isDiving: Bool = false
  var diveProgress: CGFloat = 0
  var diveStartX: CGFloat = 0
  var diveStartY: CGFloat = 0
  var homeX: CGFloat = 0
  var homeY: CGFloat = 0
}

struct Bullet: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  let isPlayerBullet: Bool
}

struct Zigzagger {
  var x: CGFloat
  var y: CGFloat
  var movingRight: Bool
  let emoji: String
  let sound: Sound
  var coinTimer: CGFloat = 0
}

struct Coin: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
}

enum PowerUpKind: CaseIterable {
  case bratwurst
  case bier
  case kartoffel

  var emoji: String {
    switch self {
    case .bratwurst:
      return "🌭"
    case .bier:
      return "🍺"
    case .kartoffel:
      return "🥔"
    }
  }
}

struct PowerUp: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  let kind: PowerUpKind
}

struct Egg: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  var velocityY: CGFloat
  var age: CGFloat = 0
}

struct Hatchling: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
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
  var zigzagger: Zigzagger?
  var coins: [Coin] = []
  var powerUps: [PowerUp] = []
  var shieldActive: Bool = false
  var rapidFireActive: Bool = false
  var eggs: [Egg] = []
  var hatchlings: [Hatchling] = []
  var score: Int = 0
  var highScore: Int = 0
  var finalScore: Int = 0
  var startTime: Date = .now
  var enemyDirection: CGFloat = 1
  var enemySpeed: CGFloat = 21
  var sineTime: Double = 0
  var screenWidth: CGFloat = 0
  var screenHeight: CGFloat = 0

  private var topInset: CGFloat = 0
  private var zigzaggerSpawnTimer: CGFloat = 0
  private var zigzaggerBag: [(emoji: String, sound: Sound)] = []
  private var shieldTimer: CGFloat = 0
  private var rapidFireTimer: CGFloat = 0
  private var rapidFireCooldown: CGFloat = 0
  private var diveTimer: CGFloat = 0
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
  private static let zigzaggerSize: CGFloat = 40
  private static let zigzaggerSpeedH: CGFloat = 160
  private static let zigzaggerSpeedV: CGFloat = 80
  private static let zigzaggerSpawnInterval: CGFloat = 15.0
  private static let coinDropInterval: CGFloat = 2.0
  private static let coinFallSpeed: CGFloat = 200
  private static let coinSize: CGFloat = 25
  private static let coinScore: Int = 100
  private static let powerUpDropChance: Double = 0.15
  private static let powerUpFallSpeed: CGFloat = 200
  private static let powerUpSize: CGFloat = 30
  private static let healthRestoreAmount: CGFloat = 0.334
  private static let shieldDuration: CGFloat = 3.0
  private static let rapidFireDuration: CGFloat = 5.0
  private static let rapidFireInterval: CGFloat = 0.3
  private static let diveInterval: CGFloat = 12.0
  private static let diveDuration: CGFloat = 6.0
  private static let diveDepthFactor: CGFloat = 0.7
  private static let diveWidthAmplitude: CGFloat = 80
  private static let diveBombersPerWave: ClosedRange<Int> = 2...3
  private static let diveScoreMultiplier: Int = 2
  private static let eggSize: CGFloat = 25
  private static let eggInitialFallSpeed: CGFloat = 200
  private static let eggBounceRestitution: CGFloat = 0.6
  private static let eggGravity: CGFloat = 400
  private static let eggHatchTime: CGFloat = 4.0
  private static let eggScore: Int = 150
  private static let hatchlingSize: CGFloat = 25
  private static let hatchlingSpeed: CGFloat = 250
  private static let hatchlingScore: Int = 150
  private static let zigzaggerKinds: [(emoji: String, sound: Sound)] = [
    ("🐎", .horse), ("🐖", .pig), ("🐑", .sheep), ("🐐", .goat), ("🐄", .cow)
  ]
  private static let enemyImages = ["Hat", "Bundestag", "Stein", "Dachshund", "Clock", "Nutcracker"]

  func startGame(screenWidth: CGFloat, screenHeight: CGFloat, topInset: CGFloat) {
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.topInset = topInset

    phase = .playing
    score = 0
    playerHealth = 1.0
    enemyDirection = 1
    enemySpeed = 21
    sineTime = 0
    playerBullet = nil
    enemyBullet = nil
    zigzagger = nil
    zigzaggerSpawnTimer = 0
    zigzaggerBag = []
    coins = []
    powerUps = []
    shieldActive = false
    rapidFireActive = false
    shieldTimer = 0
    rapidFireTimer = 0
    rapidFireCooldown = 0
    diveTimer = 0
    eggs = []
    hatchlings = []
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
    updateDivers(dt: dt)
    updateBullets(dt: dt)
    updateZigzagger(dt: dt)
    updateCoins(dt: dt)
    updatePowerUps(dt: dt)
    updateEggs(dt: dt)
    updateHatchlings(dt: dt)
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

  private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
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
      if enemies[i].isDiving {
        enemies[i].homeX += enemyDirection * enemySpeed * dt
      } else {
        enemies[i].x += enemyDirection * enemySpeed * dt
        if enemies[i].x <= Self.enemySize / 2 || enemies[i].x >= screenWidth - Self.enemySize / 2 {
          hitEdge = true
        }
      }
    }

    if hitEdge {
      enemyDirection *= -1
      for i in enemies.indices where enemies[i].isAlive {
        if enemies[i].isDiving {
          enemies[i].homeY += Self.enemySpacingY / 2
        } else {
          enemies[i].y += Self.enemySpacingY / 2
        }
      }
      enemySpeed /= Self.speedUpFactor
    }

    sineTime += Double(dt) * Self.sineFrequency
  }

  private func updateDivers(dt: CGFloat) {
    diveTimer += dt

    if diveTimer >= Self.diveInterval {
      let candidates = enemies.indices.filter { enemies[$0].isAlive && !enemies[$0].isDiving }
      if !candidates.isEmpty {
        let count = Int.random(in: Self.diveBombersPerWave)
        let selected = candidates.shuffled().prefix(count)
        for i in selected {
          enemies[i].isDiving = true
          enemies[i].diveProgress = 0
          enemies[i].diveStartX = enemies[i].x
          enemies[i].diveStartY = enemies[i].y
          enemies[i].homeX = enemies[i].x
          enemies[i].homeY = enemies[i].y
        }
      }
      diveTimer = 0
    }

    let depth = screenHeight * Self.diveDepthFactor

    for i in enemies.indices where enemies[i].isAlive && enemies[i].isDiving {
      enemies[i].diveProgress += dt / Self.diveDuration
      if enemies[i].diveProgress >= 1.0 {
        enemies[i].x = enemies[i].homeX
        enemies[i].y = enemies[i].homeY
        enemies[i].isDiving = false
        enemies[i].diveProgress = 0
      } else {
        let t = enemies[i].diveProgress
        let baselineY = enemies[i].diveStartY * (1 - t) + enemies[i].homeY * t
        let diveOffset = 4 * depth * t * (1 - t)
        enemies[i].y = baselineY + diveOffset
        enemies[i].x = enemies[i].homeX + Self.diveWidthAmplitude * CGFloat(sin(Double(t) * .pi * 4))
      }
    }
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

  private func updateZigzagger(dt: CGFloat) {
    zigzaggerSpawnTimer += dt

    if zigzagger == nil && zigzaggerSpawnTimer >= Self.zigzaggerSpawnInterval {
      if zigzaggerBag.isEmpty {
        zigzaggerBag = Self.zigzaggerKinds.shuffled()
      }
      let kind = zigzaggerBag.removeLast()
      zigzagger = Zigzagger(
        x: screenWidth - Self.zigzaggerSize / 2,
        y: topInset + Self.zigzaggerSize / 2,
        movingRight: false,
        emoji: kind.emoji,
        sound: kind.sound
      )
      Current.soundPlayer.play(kind.sound, shouldDebounce: false)
      zigzaggerSpawnTimer = 0
    }

    guard var z = zigzagger else { return }

    let dx = Self.zigzaggerSpeedH * dt * (z.movingRight ? 1 : -1)
    z.x += dx
    z.y += Self.zigzaggerSpeedV * dt

    if z.y > screenHeight + Self.zigzaggerSize {
      zigzagger = nil
      return
    }

    let halfSize = Self.zigzaggerSize / 2
    if z.x <= halfSize {
      z.x = halfSize
      z.movingRight = true
      Current.soundPlayer.play(z.sound, shouldDebounce: false)
    } else if z.x >= screenWidth - halfSize {
      z.x = screenWidth - halfSize
      z.movingRight = false
      Current.soundPlayer.play(z.sound, shouldDebounce: false)
    }

    z.coinTimer += dt
    if z.coinTimer >= Self.coinDropInterval {
      coins.append(Coin(x: z.x, y: z.y))
      z.coinTimer = 0
    }

    zigzagger = z
  }

  private func updateCoins(dt: CGFloat) {
    coins = coins.compactMap { coin in
      var c = coin
      c.y += Self.coinFallSpeed * dt
      if c.y > screenHeight + Self.coinSize {
        return nil
      }
      return c
    }
  }

  private func updatePowerUps(dt: CGFloat) {
    powerUps = powerUps.compactMap { powerUp in
      var p = powerUp
      p.y += Self.powerUpFallSpeed * dt
      if p.y > screenHeight + Self.powerUpSize {
        return nil
      }
      return p
    }

    if shieldActive {
      shieldTimer -= dt
      if shieldTimer <= 0 {
        shieldActive = false
        shieldTimer = 0
      }
    }

    if rapidFireActive {
      rapidFireTimer -= dt
      if rapidFireTimer <= 0 {
        rapidFireActive = false
        rapidFireTimer = 0
      }
      rapidFireCooldown -= dt
      if rapidFireCooldown <= 0 && playerBullet == nil {
        playerBullet = Bullet(x: playerX, y: playerY - Self.playerSize / 2, isPlayerBullet: true)
        Current.soundPlayer.play(.chime, shouldDebounce: false)
        rapidFireCooldown = Self.rapidFireInterval
      }
    }
  }

  private func updateEggs(dt: CGFloat) {
    var newHatchlings: [Hatchling] = []

    eggs = eggs.compactMap { egg in
      var e = egg
      e.age += dt
      e.velocityY += Self.eggGravity * dt
      e.y += e.velocityY * dt

      if e.age >= Self.eggHatchTime {
        newHatchlings.append(Hatchling(x: e.x, y: e.y))
        Current.soundPlayer.play(.chime, shouldDebounce: false)
        return nil
      }

      if e.y >= screenHeight - Self.eggSize / 2 {
        e.y = screenHeight - Self.eggSize / 2
        e.velocityY = -abs(e.velocityY) * Self.eggBounceRestitution
        if abs(e.velocityY) < 20 {
          e.velocityY = 0
        }
      }

      return e
    }

    hatchlings.append(contentsOf: newHatchlings)
  }

  private func updateHatchlings(dt: CGFloat) {
    for i in hatchlings.indices {
      let dx = playerX - hatchlings[i].x
      let direction: CGFloat = dx > 0 ? 1 : -1
      hatchlings[i].x += direction * Self.hatchlingSpeed * dt
    }
  }

  private func checkCollisions() {
    // 1. Player bullet vs hatchlings
    if let bullet = playerBullet {
      if let idx = hatchlings.firstIndex(where: { h in
        rectsIntersect(ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
                       bx: h.x, by: h.y, bSize: Self.hatchlingSize)
      }) {
        hatchlings.remove(at: idx)
        playerBullet = nil
        score += Self.hatchlingScore
        Current.soundPlayer.play(.buzz, shouldDebounce: false)
        haptic(.medium)
      }
    }

    // 2. Player bullet vs enemies (power-up drop on kill; double score if diving)
    if let bullet = playerBullet {
      for i in enemies.indices where enemies[i].isAlive {
        if rectsIntersect(
          ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
          bx: enemies[i].x, by: enemies[i].y, bSize: Self.enemySize
        ) {
          let wasDiving = enemies[i].isDiving
          enemies[i].isAlive = false
          playerBullet = nil
          score += wasDiving ? Self.scorePerKill * Self.diveScoreMultiplier : Self.scorePerKill
          Current.soundPlayer.play(.buzz, shouldDebounce: false)
          haptic(.medium)
          if Double.random(in: 0...1) < Self.powerUpDropChance {
            let kind = PowerUpKind.allCases.randomElement() ?? .bratwurst
            powerUps.append(PowerUp(x: enemies[i].x, y: enemies[i].y, kind: kind))
          }
          break
        }
      }
    }

    // 3. Player bullet vs zigzagger (egg spawn on bullet kill)
    if let z = zigzagger, let bullet = playerBullet {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: z.x, by: z.y, bSize: Self.zigzaggerSize
      ) {
        eggs.append(Egg(x: z.x, y: z.y, velocityY: Self.eggInitialFallSpeed))
        zigzagger = nil
        playerBullet = nil
        score += Self.scorePerKill
        Current.soundPlayer.play(.buzz, shouldDebounce: false)
        haptic(.medium)
      }
    }

    // 4. Enemy bullet vs player (shield check)
    if let bullet = enemyBullet {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        enemyBullet = nil
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
        }
        Current.soundPlayer.play(.buzz, shouldDebounce: false)
        haptic(.heavy)
      }
    }

    // 5. Diving enemy vs player (shield check)
    for i in enemies.indices where enemies[i].isAlive && enemies[i].isDiving {
      if rectsIntersect(
        ax: enemies[i].x, ay: enemies[i].y, aSize: Self.enemySize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        enemies[i].isAlive = false
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
        }
        Current.soundPlayer.play(.buzz, shouldDebounce: false)
        haptic(.heavy)
      }
    }

    // 6. Zigzagger vs player (no egg; shield check)
    if let z = zigzagger {
      if rectsIntersect(
        ax: z.x, ay: z.y, aSize: Self.zigzaggerSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        zigzagger = nil
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
        }
        Current.soundPlayer.play(.buzz, shouldDebounce: false)
        haptic(.heavy)
      }
    }

    // 7. Coin collection
    coins.removeAll { coin in
      if rectsIntersect(
        ax: coin.x, ay: coin.y, aSize: Self.coinSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        score += Self.coinScore
        Current.soundPlayer.play(.coin, shouldDebounce: false)
        haptic(.light)
        return true
      }
      return false
    }

    // 8. Power-up collection
    powerUps.removeAll { powerUp in
      if rectsIntersect(
        ax: powerUp.x, ay: powerUp.y, aSize: Self.powerUpSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        switch powerUp.kind {
        case .bratwurst:
          playerHealth = min(1.0, playerHealth + Self.healthRestoreAmount)
        case .bier:
          shieldActive = true
          shieldTimer = Self.shieldDuration
        case .kartoffel:
          rapidFireActive = true
          rapidFireTimer = Self.rapidFireDuration
          rapidFireCooldown = 0
        }
        Current.soundPlayer.play(.coin, shouldDebounce: false)
        haptic(.light)
        return true
      }
      return false
    }

    // 9. Egg collection
    eggs.removeAll { egg in
      if rectsIntersect(
        ax: egg.x, ay: egg.y, aSize: Self.eggSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        score += Self.eggScore
        Current.soundPlayer.play(.coin, shouldDebounce: false)
        haptic(.light)
        return true
      }
      return false
    }

    // 10. Hatchling vs player (shield check)
    hatchlings.removeAll { hatchling in
      if rectsIntersect(
        ax: hatchling.x, ay: hatchling.y, aSize: Self.hatchlingSize,
        bx: playerX, by: playerY, bSize: Self.playerSize
      ) {
        if !shieldActive {
          playerHealth -= Self.healthLossPerHit
        }
        Current.soundPlayer.play(.buzz, shouldDebounce: false)
        haptic(.heavy)
        return true
      }
      return false
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
    let aliveEnemies = enemies.filter { $0.isAlive && !$0.isDiving }
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
    for enemy in aliveEnemies where !enemy.isDiving && enemy.y >= bottomThreshold {
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
