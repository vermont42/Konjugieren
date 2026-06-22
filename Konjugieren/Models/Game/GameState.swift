// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import CoreMotion
import SwiftUI

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
  var portalSide: PortalSide?
  var activeMechanic: SpecialMechanic?
  var fussball: Fussball?
  var wurstChains: [WurstChain] = []
  var pretzelObstacles: [PretzelObstacle] = []
  var ghosts: [Ghost] = []
  var goldenDots: [GoldenDot] = []
  var kristallkugel: Kristallkugel?
  var robotBrain: RobotBrain?
  var robotMinion: RobotMinion?
  var robotBulletUseRed: Bool = false
  var deathEffects: [DeathEffect] = []
  var geisterjagdActive: Bool = false
  var score: Int = 0
  var highScore: Int = 0
  var finalScore: Int = 0
  var wave: Int = 1
  var lastWaveScore: Int = 0
  var waveCompleteTime: Date?
  var startTime: Date = .now
  var gameOverTime: Date?
  var enemyDirection: CGFloat = 1
  var enemySpeed: CGFloat = 21
  var sineTime: Double = 0
  var screenWidth: CGFloat = 0
  var screenHeight: CGFloat = 0

  var topInset: CGFloat = 0
  var geisterjagdTimer: CGFloat = 0
  var kristallkugelSpawnCount: Int = 0
  var shieldTimer: CGFloat = 0
  var rapidFireTimer: CGFloat = 0
  var rapidFireCooldown: CGFloat = 0
  var rapidFireSound: Sound = .longFire1

  private var scoreAtWaveStart: Int = 0
  private var zigzaggerSpawnTimer: CGFloat = 0
  private var zigzaggerBag: [(emoji: String, sound: Sound)] = []
  private var mechanicSpawnTimer: CGFloat = 0
  private var hasSpawnedFirstMechanic = false
  private var mechanicBag: [SpecialMechanic] = []
  private var diveTimer: CGFloat = 0
  private let motionManager = CMMotionManager()
  private var lastUpdateTime: Date?
  private var liveActivity: Activity<GameActivityAttributes>?
  private var lastActivityUpdateTime: Date?
  private static let activityUpdateInterval: TimeInterval = 2.0

  static let rows = 6
  static let cols = 6
  static let enemySpacingX: CGFloat = 45
  static let enemySpacingY: CGFloat = 40
  static let playerBulletSpeed: CGFloat = 700
  static let enemyBulletSpeed: CGFloat = 300
  static let playerSize: CGFloat = 40
  static let enemySize: CGFloat = 30
  static let bulletSize: CGFloat = 20
  static let tiltThreshold: Double = 0.02
  static let tiltSensitivity: CGFloat = 800
  static let healthLossPerHit: CGFloat = 0.25
  static let enemyFiresPerSecond: Double = 1.2
  static let speedUpFactor: CGFloat = 0.95
  static let sineAmplitude: CGFloat = 8
  static let sineFrequency: Double = 2.0
  static let scorePerKill: Int = 100
  static let zigzaggerSize: CGFloat = 40
  static let zigzaggerSpeedH: CGFloat = 160
  static let zigzaggerSpeedV: CGFloat = 80
  static let zigzaggerSpawnInterval: CGFloat = 15.0
  static let coinDropInterval: CGFloat = 2.0
  static let coinFallSpeed: CGFloat = 200
  static let coinSize: CGFloat = 25
  static let coinScore: Int = 100
  static let powerUpDropChance: Double = 0.15
  static let powerUpFallSpeed: CGFloat = 200
  static let powerUpSize: CGFloat = 30
  static let healthRestoreAmount: CGFloat = 0.25
  static let shieldDuration: CGFloat = 6.0
  static let rapidFireDuration: CGFloat = 5.0
  static let rapidFireInterval: CGFloat = 0.3
  static let diveInterval: CGFloat = 24.0
  static let diveDuration: CGFloat = 6.0
  static let diveDepthFactor: CGFloat = 0.7
  static let diveWidthAmplitude: CGFloat = 80
  static let diveBombersPerWave: ClosedRange<Int> = 2...3
  static let diveScoreMultiplier: Int = 2
  static let eggSize: CGFloat = 25
  static let eggInitialFallSpeed: CGFloat = 200
  static let eggBounceRestitution: CGFloat = 0.6
  static let eggGravity: CGFloat = 400
  static let eggHatchTime: CGFloat = 4.0
  static let eggScore: Int = 150
  static let hatchlingSize: CGFloat = 25
  static let hatchlingSpeed: CGFloat = 250
  static let hatchlingScore: Int = 150
  static let gameOverCooldown: TimeInterval = 2.0
  static let waveCompleteDuration: TimeInterval = 3.0
  static let waveSpeedScaling: CGFloat = 1.02
  static let zigzaggerKinds: [(emoji: String, sound: Sound)] = [
    ("🐎", .horse), ("🐖", .pig), ("🐑", .sheep), ("🐐", .goat), ("🐄", .cow)
  ]
  static let enemyImages = ["Hat", "Bundestag", "Stein", "Dachshund", "Clock", "Nutcracker"]

  static let mechanicSpawnInterval: CGFloat = 27.0
  static let initialMechanicDelay: CGFloat = 15.0

  static let fussballSize: CGFloat = 30
  static let fussballBaseSpeed: CGFloat = 200
  static let fussballDuration: CGFloat = 15.0
  static let fussballSpeedUpPerBounce: CGFloat = 1.08
  static let fussballEnemyKillScore: Int = 100

  static let wurstSegmentCount: Int = 5
  static let wurstSegmentSize: CGFloat = 30
  static let wurstSegmentSpacing: CGFloat = 35
  static let wurstBaseSpeed: CGFloat = 240
  static let wurstDescentStep: CGFloat = 35
  static let wurstPlayerRowSpeedMultiplier: CGFloat = 1.8
  static let wurstSegmentScore: Int = 75
  static let pretzelObstacleSize: CGFloat = 30

  static let ghostCount: ClosedRange<Int> = 2...3
  static let ghostSize: CGFloat = 35
  static let ghostDescentSpeed: CGFloat = 48
  static let ghostPursuitSpeed: CGFloat = 150
  static let ghostFleeSpeed: CGFloat = 100
  static let ghostExitSpeed: CGFloat = 200
  static let ghostDevourScore: Int = 300
  static let ghostExitScore: Int = 50
  static let dotSize: CGFloat = 24
  static let dotScore: Int = 25
  static let dotDropInterval: CGFloat = 0.3
  static let kristallkugelSize: CGFloat = 25
  static let kristallkugelMaxSpawns = 3
  static let kristallkugelThresholds: [CGFloat] = [0.25, 0.50, 0.75]
  static let geisterjagdDuration: CGFloat = 5.0

  static let brainSize: CGFloat = 30
  static let brainSpeed: CGFloat = 468
  static let brainAscentSpeed: CGFloat = 40
  static let brainScore: Int = 150
  static let robotMinionSize: CGFloat = 30
  static let armHitZone: CGFloat = 12
  static let robotMinionScore: Int = 150
  static let robotDiveDuration: CGFloat = 6.0
  static let robotDiveDepthFactor: CGFloat = 0.7
  static let robotDiveWidthAmplitude: CGFloat = 80
  static let robotDivePause: CGFloat = 2.0
  static let boltAppearDelay: CGFloat = 1.0
  static let conversionDelay: CGFloat = 2.0
  static let robotBulletSpeedMultiplier: CGFloat = 2.0

  func startGame(screenWidth: CGFloat, screenHeight: CGFloat, topInset: CGFloat) {
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.topInset = topInset

    phase = .playing
    score = 0
    wave = 1
    lastWaveScore = 0
    scoreAtWaveStart = 0
    playerHealth = 1.0
    enemySpeed = 21
    zigzaggerBag = []
    mechanicBag = []
    hasSpawnedFirstMechanic = false
    gameOverTime = nil
    startTime = .now

    resetWaveState()

    highScore = Current.settings.gameHighScore

    playerX = screenWidth / 2
    playerY = screenHeight - 60

    spawnEnemyGrid()

    startMotion()
    liveActivity = LiveActivityManager.start(
      attributes: GameActivityAttributes(),
      initialState: GameActivityAttributes.ContentState(
        wave: 1,
        score: 0,
        healthFraction: 1.0,
        phase: "playing"
      )
    )
    lastActivityUpdateTime = nil
    Current.soundPlayer.startMusic()
    Current.analytics.signal(name: .startGame)
  }

  func update(currentTime: Date) {
    if phase == .waveComplete {
      if let wct = waveCompleteTime,
         currentTime.timeIntervalSince(wct) >= Self.waveCompleteDuration {
        startNextWave()
      }
      return
    }

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
    updateSpecialMechanic(dt: dt)
    updateRobot(dt: dt)
    updateFussball(dt: dt)
    updateWurstChains(dt: dt)
    updatePretzelOpacities(dt: dt)
    updateGhosts(dt: dt)
    updateDeathEffects(dt: dt)
    checkCollisions()
    attemptEnemyFire(dt: dt)
    updateLiveActivity(currentTime: currentTime)
    checkGameOver()
  }

  func playerFire() {
    guard phase == .playing, playerBullet == nil else { return }
    var bullet = Bullet(x: playerX, y: playerY - Self.playerSize / 2, isPlayerBullet: true)
    if isRobotActive {
      bullet.useRed = robotBulletUseRed
      robotBulletUseRed.toggle()
    }
    playerBullet = bullet
    Current.soundPlayer.play(isRobotActive ? .robotWeapon : .pop, shouldDebounce: false)
  }

  func computeFinalScore() -> Int {
    let elapsed = Date.now.timeIntervalSince(startTime)
    let raw = Double(score) * (Double(playerHealth) + 1.0) - Double(elapsed)
    return max(0, Int(raw))
  }

  func stopMotion() {
    if motionManager.isDeviceMotionActive {
      motionManager.stopDeviceMotionUpdates()
    }
    Current.soundPlayer.stopMusic()
  }

  func resumeMotion() {
    lastUpdateTime = nil
    startMotion()
    if phase == .playing || phase == .waveComplete {
      Current.soundPlayer.startMusic()
    }
  }

  func restartGame() {
    endLiveActivity()
    SavedGame.clear(getterSetter: Current.getterSetter)
    startGame(screenWidth: screenWidth, screenHeight: screenHeight, topInset: topInset)
  }

  func quitGame() {
    endLiveActivity()
  }

  func makeSnapshot() -> GameStateSnapshot {
    let elapsed = Date.now.timeIntervalSince(startTime)
    let elapsedWC: TimeInterval? = if let wct = waveCompleteTime {
      Date.now.timeIntervalSince(wct)
    } else {
      nil
    }
    return GameStateSnapshot(
      savedScreenWidth: screenWidth,
      savedScreenHeight: screenHeight,
      topInset: topInset,
      phase: phase,
      playerXFraction: screenWidth > 0 ? playerX / screenWidth : 0.5,
      playerYFraction: screenHeight > 0 ? playerY / screenHeight : 0.9,
      playerHealth: playerHealth,
      enemies: enemies,
      playerBullet: playerBullet,
      enemyBullet: enemyBullet,
      zigzagger: zigzagger,
      coins: coins,
      powerUps: powerUps,
      shieldActive: shieldActive,
      rapidFireActive: rapidFireActive,
      eggs: eggs,
      hatchlings: hatchlings,
      portalSide: portalSide,
      activeMechanic: activeMechanic,
      fussball: fussball,
      wurstChains: wurstChains,
      pretzelObstacles: pretzelObstacles,
      ghosts: ghosts,
      goldenDots: goldenDots,
      kristallkugel: kristallkugel,
      robotBrain: robotBrain,
      robotMinion: robotMinion,
      robotBulletUseRed: robotBulletUseRed,
      geisterjagdActive: geisterjagdActive,
      score: score,
      highScore: highScore,
      wave: wave,
      lastWaveScore: lastWaveScore,
      enemyDirection: enemyDirection,
      enemySpeed: enemySpeed,
      sineTime: sineTime,
      scoreAtWaveStart: scoreAtWaveStart,
      zigzaggerSpawnTimer: zigzaggerSpawnTimer,
      mechanicSpawnTimer: mechanicSpawnTimer,
      hasSpawnedFirstMechanic: hasSpawnedFirstMechanic,
      geisterjagdTimer: geisterjagdTimer,
      kristallkugelSpawnCount: kristallkugelSpawnCount,
      shieldTimer: shieldTimer,
      rapidFireTimer: rapidFireTimer,
      rapidFireCooldown: rapidFireCooldown,
      rapidFireSound: rapidFireSound,
      diveTimer: diveTimer,
      elapsedBeforePause: elapsed,
      elapsedWaveComplete: elapsedWC
    )
  }

  func restoreGame(from snapshot: GameStateSnapshot, screenWidth: CGFloat, screenHeight: CGFloat, topInset: CGFloat) {
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.topInset = topInset

    let scaleX = screenWidth / snapshot.savedScreenWidth
    let scaleY = screenHeight / snapshot.savedScreenHeight

    phase = snapshot.phase
    playerX = snapshot.playerXFraction * screenWidth
    playerY = snapshot.playerYFraction * screenHeight
    playerHealth = snapshot.playerHealth

    enemies = snapshot.enemies.map { e in
      var scaled = e
      scaled.x *= scaleX
      scaled.y *= scaleY
      scaled.diveStartX *= scaleX
      scaled.diveStartY *= scaleY
      scaled.homeX *= scaleX
      scaled.homeY *= scaleY
      return scaled
    }

    playerBullet = snapshot.playerBullet.map { b in
      Bullet(x: b.x * scaleX, y: b.y * scaleY, isPlayerBullet: b.isPlayerBullet, useRed: b.useRed)
    }
    enemyBullet = snapshot.enemyBullet.map { b in
      Bullet(x: b.x * scaleX, y: b.y * scaleY, isPlayerBullet: b.isPlayerBullet, useRed: b.useRed)
    }
    zigzagger = snapshot.zigzagger.map { z in
      var scaled = z
      scaled.x *= scaleX
      scaled.y *= scaleY
      return scaled
    }
    coins = snapshot.coins.map { c in
      Coin(x: c.x * scaleX, y: c.y * scaleY)
    }
    powerUps = snapshot.powerUps.map { p in
      PowerUp(x: p.x * scaleX, y: p.y * scaleY, kind: p.kind)
    }
    shieldActive = snapshot.shieldActive
    rapidFireActive = snapshot.rapidFireActive
    eggs = snapshot.eggs.map { e in
      var scaled = e
      scaled.x *= scaleX
      scaled.y *= scaleY
      return scaled
    }
    hatchlings = snapshot.hatchlings.map { h in
      Hatchling(x: h.x * scaleX, y: h.y * scaleY)
    }
    portalSide = snapshot.portalSide
    activeMechanic = snapshot.activeMechanic
    fussball = snapshot.fussball.map { f in
      var scaled = f
      scaled.x *= scaleX
      scaled.y *= scaleY
      scaled.velocityX *= scaleX
      scaled.velocityY *= scaleY
      return scaled
    }
    wurstChains = snapshot.wurstChains.map { chain in
      var scaled = chain
      scaled.segments = chain.segments.map { s in
        WurstSegment(x: s.x * scaleX, y: s.y * scaleY)
      }
      return scaled
    }
    pretzelObstacles = snapshot.pretzelObstacles.map { p in
      var scaled = p
      scaled.x *= scaleX
      scaled.y *= scaleY
      return scaled
    }
    ghosts = snapshot.ghosts.map { g in
      var scaled = g
      scaled.x *= scaleX
      scaled.y *= scaleY
      return scaled
    }
    goldenDots = snapshot.goldenDots.map { d in
      GoldenDot(x: d.x * scaleX, y: d.y * scaleY)
    }
    kristallkugel = snapshot.kristallkugel.map { k in
      Kristallkugel(x: k.x * scaleX, y: k.y * scaleY)
    }
    robotBrain = snapshot.robotBrain.map { b in
      var scaled = b
      scaled.x *= scaleX
      scaled.y *= scaleY
      return scaled
    }
    robotMinion = snapshot.robotMinion.map { m in
      var scaled = m
      scaled.x *= scaleX
      scaled.y *= scaleY
      scaled.homeX *= scaleX
      scaled.homeY *= scaleY
      scaled.diveStartX *= scaleX
      scaled.diveStartY *= scaleY
      return scaled
    }
    robotBulletUseRed = snapshot.robotBulletUseRed
    geisterjagdActive = snapshot.geisterjagdActive
    score = snapshot.score
    highScore = snapshot.highScore
    wave = snapshot.wave
    lastWaveScore = snapshot.lastWaveScore
    enemyDirection = snapshot.enemyDirection
    enemySpeed = snapshot.enemySpeed
    sineTime = snapshot.sineTime

    scoreAtWaveStart = snapshot.scoreAtWaveStart
    zigzaggerSpawnTimer = snapshot.zigzaggerSpawnTimer
    mechanicSpawnTimer = snapshot.mechanicSpawnTimer
    hasSpawnedFirstMechanic = snapshot.hasSpawnedFirstMechanic
    geisterjagdTimer = snapshot.geisterjagdTimer
    kristallkugelSpawnCount = snapshot.kristallkugelSpawnCount
    shieldTimer = snapshot.shieldTimer
    rapidFireTimer = snapshot.rapidFireTimer
    rapidFireCooldown = snapshot.rapidFireCooldown
    rapidFireSound = snapshot.rapidFireSound
    diveTimer = snapshot.diveTimer

    deathEffects = []
    zigzaggerBag = []
    mechanicBag = []
    gameOverTime = nil

    startTime = Date.now.addingTimeInterval(-snapshot.elapsedBeforePause)
    if let elapsedWC = snapshot.elapsedWaveComplete {
      waveCompleteTime = Date.now.addingTimeInterval(-elapsedWC)
    } else {
      waveCompleteTime = nil
    }

    lastUpdateTime = nil
    startMotion()
    Current.soundPlayer.startMusic()
  }

  var canRestart: Bool {
    guard let gameOverTime else { return false }
    return Date.now.timeIntervalSince(gameOverTime) >= Self.gameOverCooldown
  }

  var isRobotActive: Bool {
    robotBrain != nil || robotMinion != nil
  }

  func sineOffset(forRow row: Int) -> CGFloat {
    Self.sineAmplitude * CGFloat(sin(sineTime + Double(row) * 0.5))
  }

  private func resetWaveState() {
    playerBullet = nil
    enemyBullet = nil
    zigzagger = nil
    zigzaggerSpawnTimer = 0
    coins = []
    powerUps = []
    shieldActive = false
    rapidFireActive = false
    shieldTimer = 0
    rapidFireTimer = 0
    rapidFireCooldown = 0
    rapidFireSound = .longFire1
    diveTimer = 0
    eggs = []
    hatchlings = []
    portalSide = nil
    activeMechanic = nil
    mechanicSpawnTimer = 0
    fussball = nil
    wurstChains = []
    pretzelObstacles = []
    ghosts = []
    goldenDots = []
    kristallkugel = nil
    robotBrain = nil
    robotMinion = nil
    deathEffects = []
    geisterjagdActive = false
    geisterjagdTimer = 0
    kristallkugelSpawnCount = 0
    enemyDirection = 1
    sineTime = 0
    waveCompleteTime = nil
    lastUpdateTime = nil
  }

  private func spawnEnemyGrid() {
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
  }

  private func startNextWave() {
    wave += 1
    scoreAtWaveStart = score

    resetWaveState()

    playerHealth = min(1.0, playerHealth + Self.healthRestoreAmount)
    enemySpeed = 21 * pow(Self.waveSpeedScaling, CGFloat(wave - 1))

    spawnEnemyGrid()

    phase = .playing
    Current.analytics.signal(name: .completeWave)
  }

  private func startMotion() {
    guard motionManager.isDeviceMotionAvailable, !motionManager.isDeviceMotionActive else { return }
    motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    motionManager.startDeviceMotionUpdates()
  }

  private func updatePlayerPosition(dt: CGFloat) {
    guard let data = motionManager.deviceMotion else { return }
    let tilt = data.gravity.x
    if abs(tilt) > Self.tiltThreshold {
      playerX += CGFloat(tilt) * Self.tiltSensitivity * dt
      playerX = max(Self.playerSize / 2, min(screenWidth - Self.playerSize / 2, playerX))
    }

    if let side = portalSide {
      switch side {
      case .left:
        if playerX <= Self.playerSize / 2 + 5 {
          playerX = screenWidth - Self.playerSize / 2
          portalSide = nil
          hatchlings.removeAll()
          HapticPlayer.playImpact(.medium)
        }
      case .right:
        if playerX >= screenWidth - Self.playerSize / 2 - 5 {
          playerX = Self.playerSize / 2
          portalSide = nil
          hatchlings.removeAll()
          HapticPlayer.playImpact(.medium)
        }
      }
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
          enemies[i].x = max(Self.enemySize / 2, min(screenWidth - Self.enemySize / 2, enemies[i].x))
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
    let bulletSpeed = isRobotActive
      ? Self.playerBulletSpeed * Self.robotBulletSpeedMultiplier
      : Self.playerBulletSpeed
    if var bullet = playerBullet {
      bullet.y -= bulletSpeed * dt
      if bullet.y < -Self.bulletSize {
        playerBullet = nil
      } else {
        playerBullet = bullet
      }
    }

    if var bullet = enemyBullet {
      bullet.y += Self.enemyBulletSpeed * dt
      if bullet.y > screenHeight + Self.bulletSize {
        enemyBullet = nil
      } else {
        enemyBullet = bullet
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
        Current.soundPlayer.play(rapidFireSound, shouldDebounce: false, volume: 0.5)
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
        Current.soundPlayer.play(.eggCrack, shouldDebounce: false)
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

    if !newHatchlings.isEmpty && portalSide == nil {
      if let firstHatchling = newHatchlings.first {
        if firstHatchling.x > playerX {
          portalSide = .left
        } else if firstHatchling.x < playerX {
          portalSide = .right
        } else {
          portalSide = Bool.random() ? .left : .right
        }
      }
    }
  }

  private func updateHatchlings(dt: CGFloat) {
    for i in hatchlings.indices {
      let dx = playerX - hatchlings[i].x
      let dy = playerY - hatchlings[i].y
      let distance = hypot(dx, dy)
      guard distance > 1 else { continue }
      hatchlings[i].x += (dx / distance) * Self.hatchlingSpeed * dt
      hatchlings[i].y += (dy / distance) * Self.hatchlingSpeed * dt
    }
  }

  private func updateSpecialMechanic(dt: CGFloat) {
    guard activeMechanic == nil else { return }
    let threshold = hasSpawnedFirstMechanic
      ? Self.mechanicSpawnInterval
      : Self.initialMechanicDelay
    mechanicSpawnTimer += dt
    guard mechanicSpawnTimer >= threshold else { return }
    mechanicSpawnTimer = 0
    hasSpawnedFirstMechanic = true
    if mechanicBag.isEmpty {
      mechanicBag = SpecialMechanic.allCases.shuffled()
    }
    let mechanic = mechanicBag.removeLast()
    activeMechanic = mechanic
    switch mechanic {
    case .fussball:
      Current.soundPlayer.play(.soccerKick, shouldDebounce: false)
      spawnFussball()
    case .bratwurstkette:
      Current.soundPlayer.play(.sizzle, shouldDebounce: false)
      spawnBratwurstkette()
    case .geisterstunde:
      Current.soundPlayer.play(.ghostSpooky, shouldDebounce: false)
      spawnGeisterstunde()
    case .robot:
      Current.soundPlayer.play(.brainLockOn, shouldDebounce: false)
      spawnRobot()
    }
  }

  private func updateDeathEffects(dt: CGFloat) {
    for i in deathEffects.indices {
      deathEffects[i].age += dt
    }
    deathEffects.removeAll { $0.progress >= 1.0 }
  }

  private func attemptEnemyFire(dt: CGFloat) {
    guard enemyBullet == nil else { return }
    let aliveEnemies = enemies.filter { $0.isAlive && !$0.isDiving }
    guard !aliveEnemies.isEmpty else { return }

    if Double.random(in: 0...1) < Self.enemyFiresPerSecond * Double(dt) {
      let shooter = aliveEnemies.randomElement() ?? aliveEnemies[0]
      enemyBullet = Bullet(x: shooter.x, y: shooter.y + Self.enemySize / 2, isPlayerBullet: false)
      Current.soundPlayer.play(.chime, shouldDebounce: false)
    }
  }

  private func updateLiveActivity(currentTime: Date) {
    guard let liveActivity else { return }
    if let last = lastActivityUpdateTime,
       currentTime.timeIntervalSince(last) < Self.activityUpdateInterval {
      return
    }
    lastActivityUpdateTime = currentTime
    let state = GameActivityAttributes.ContentState(
      wave: wave,
      score: score,
      healthFraction: Double(playerHealth),
      phase: phase.rawValue
    )
    LiveActivityManager.update(liveActivity, state: state)
  }

  private func forceLiveActivityUpdate() {
    guard let liveActivity else { return }
    lastActivityUpdateTime = .now
    let state = GameActivityAttributes.ContentState(
      wave: wave,
      score: score,
      healthFraction: Double(playerHealth),
      phase: phase.rawValue
    )
    LiveActivityManager.update(liveActivity, state: state)
  }

  private func endLiveActivity() {
    guard let liveActivity else { return }
    let finalState = GameActivityAttributes.ContentState(
      wave: wave,
      score: score,
      healthFraction: Double(playerHealth),
      phase: phase.rawValue
    )
    LiveActivityManager.end(liveActivity, finalState: finalState)
    self.liveActivity = nil
  }

  private func checkGameOver() {
    guard !enemies.isEmpty else { return }
    let aliveEnemies = enemies.filter(\.isAlive)

    if aliveEnemies.isEmpty {
      phase = .waveComplete
      portalSide = nil
      lastWaveScore = score - scoreAtWaveStart
      waveCompleteTime = .now
      forceLiveActivityUpdate()
      Current.soundPlayer.play(.randomApplause, shouldDebounce: false)
      return
    }

    if playerHealth <= 0 {
      loseGame()
      return
    }

    let bottomThreshold = playerY - Self.playerSize
    for enemy in aliveEnemies where !enemy.isDiving && enemy.y >= bottomThreshold {
      loseGame()
      return
    }
  }

  private func loseGame() {
    phase = .lost
    portalSide = nil
    gameOverTime = .now
    SavedGame.clear(getterSetter: Current.getterSetter)
    Current.soundPlayer.stopMusic()
    Current.soundPlayer.play(.randomSadTrombone, shouldDebounce: false)
    persistHighScore()
    endLiveActivity()
    Current.analytics.signal(name: .loseGame)
  }

  private func persistHighScore() {
    finalScore = computeFinalScore()
    if finalScore > highScore {
      let isFirstGame = highScore == 0
      highScore = finalScore
      Current.settings.gameHighScore = finalScore
      if !isFirstGame {
        Current.reviewPrompter.promptableActionHappened()
      }
    }
  }
}
