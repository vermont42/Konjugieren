// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import CoreMotion
import SwiftUI

struct Enemy: Identifiable, Codable {
  var id = UUID()
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

struct Bullet: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
  let isPlayerBullet: Bool
  var useRed: Bool = false
}

struct Zigzagger: Codable {
  var x: CGFloat
  var y: CGFloat
  var movingRight: Bool
  let emoji: String
  let sound: Sound
  var coinTimer: CGFloat = 0
}

struct Coin: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
}

enum PowerUpKind: String, CaseIterable, Codable {
  case bier
  case bratwurst
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

struct PowerUp: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
  let kind: PowerUpKind
}

struct Egg: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
  var velocityY: CGFloat
  var age: CGFloat = 0
}

struct Hatchling: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
}

struct DeathEffect: Identifiable {
  static let duration: CGFloat = 0.3
  static let particleCount = 8

  let id = UUID()
  let x: CGFloat
  let y: CGFloat
  let imageName: String
  let useRed: Bool
  var age: CGFloat = 0

  var progress: CGFloat { min(age / Self.duration, 1.0) }
}

enum GamePhase: String, Codable {
  case playing
  case waveComplete
  case lost
}

enum PortalSide: String, Codable {
  case left
  case right
}

enum SpecialMechanic: String, CaseIterable, Codable {
  case bratwurstkette
  case fussball
  case geisterstunde
  case robot
}

enum BrainPhase: String, Codable {
  case ascending
  case lockedOn
  case converting
}

struct RobotBrain: Codable {
  var x: CGFloat
  var y: CGFloat
  var movingRight: Bool
  var phase: BrainPhase = .ascending
  var hitsRemaining: Int = 3
  var targetEnemyIndex: Int?
  var lockOnTimer: CGFloat = 0
  var showBolt: Bool = false
}

struct RobotMinion: Codable {
  var x: CGFloat
  var y: CGFloat
  var homeX: CGFloat
  var homeY: CGFloat
  var hasLeftArm: Bool = true
  var hasRightArm: Bool = true
  var isDiving: Bool = false
  var diveProgress: CGFloat = 0
  var diveStartX: CGFloat = 0
  var diveStartY: CGFloat = 0
  var divePauseTimer: CGFloat = 0
  var originalEnemyImageName: String

  var isArmed: Bool { hasLeftArm || hasRightArm }
}

struct Fussball: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
  var velocityX: CGFloat
  var velocityY: CGFloat
  var remainingTime: CGFloat
  var bounceCount: Int = 0
}

struct WurstSegment: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
}

struct WurstChain: Identifiable, Codable {
  var id = UUID()
  var segments: [WurstSegment]
  var movingRight: Bool
  var speed: CGFloat
}

struct PretzelObstacle: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
  var hitsRemaining: Int = 2
  var opacity: CGFloat = 1.0
}

enum GhostPhase: String, Codable {
  case descending
  case pursuing
  case fleeing
  case devoured
  case exiting
}

struct Ghost: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
  var phase: GhostPhase = .descending
  var dotTimer: CGFloat = 0
}

struct GoldenDot: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
}

struct Kristallkugel: Identifiable, Codable {
  var id = UUID()
  var x: CGFloat
  var y: CGFloat
}

struct GameStateSnapshot: Codable {
  let savedScreenWidth: CGFloat
  let savedScreenHeight: CGFloat
  let topInset: CGFloat

  let phase: GamePhase
  let playerXFraction: CGFloat
  let playerYFraction: CGFloat
  let playerHealth: CGFloat
  let enemies: [Enemy]
  let playerBullet: Bullet?
  let enemyBullet: Bullet?
  let zigzagger: Zigzagger?
  let coins: [Coin]
  let powerUps: [PowerUp]
  let shieldActive: Bool
  let rapidFireActive: Bool
  let eggs: [Egg]
  let hatchlings: [Hatchling]
  let portalSide: PortalSide?
  let activeMechanic: SpecialMechanic?
  let fussball: Fussball?
  let wurstChains: [WurstChain]
  let pretzelObstacles: [PretzelObstacle]
  let ghosts: [Ghost]
  let goldenDots: [GoldenDot]
  let kristallkugel: Kristallkugel?
  let robotBrain: RobotBrain?
  let robotMinion: RobotMinion?
  let robotBulletUseRed: Bool
  let geisterjagdActive: Bool
  let score: Int
  let highScore: Int
  let wave: Int
  let lastWaveScore: Int
  let enemyDirection: CGFloat
  let enemySpeed: CGFloat
  let sineTime: Double

  let scoreAtWaveStart: Int
  let zigzaggerSpawnTimer: CGFloat
  let mechanicSpawnTimer: CGFloat
  let geisterjagdTimer: CGFloat
  let kristallkugelSpawnCount: Int
  let shieldTimer: CGFloat
  let rapidFireTimer: CGFloat
  let rapidFireCooldown: CGFloat
  let rapidFireSound: Sound
  let diveTimer: CGFloat

  let elapsedBeforePause: TimeInterval
  let elapsedWaveComplete: TimeInterval?
}

enum SavedGame {
  static let storageKey = "savedGameState"

  static func save(_ snapshot: GameStateSnapshot, getterSetter: GetterSetter) {
    guard
      let data = try? JSONEncoder().encode(snapshot),
      let jsonString = String(data: data, encoding: .utf8)
    else {
      return
    }
    getterSetter.set(key: storageKey, value: jsonString)
  }

  static func load(getterSetter: GetterSetter) -> GameStateSnapshot? {
    guard
      let jsonString = getterSetter.get(key: storageKey),
      let data = jsonString.data(using: .utf8)
    else {
      return nil
    }
    return try? JSONDecoder().decode(GameStateSnapshot.self, from: data)
  }

  static func clear(getterSetter: GetterSetter) {
    getterSetter.set(key: storageKey, value: "")
  }
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

  private var topInset: CGFloat = 0
  private var scoreAtWaveStart: Int = 0
  private var zigzaggerSpawnTimer: CGFloat = 0
  private var zigzaggerBag: [(emoji: String, sound: Sound)] = []
  private var mechanicSpawnTimer: CGFloat = 0
  private var mechanicBag: [SpecialMechanic] = []
  private var geisterjagdTimer: CGFloat = 0
  private var kristallkugelSpawnCount: Int = 0
  private var shieldTimer: CGFloat = 0
  private var rapidFireTimer: CGFloat = 0
  private var rapidFireCooldown: CGFloat = 0
  private var rapidFireSound: Sound = .longFire1
  private var diveTimer: CGFloat = 0
  private let motionManager = CMMotionManager()
  private var lastUpdateTime: Date?
  private var liveActivity: Activity<GameActivityAttributes>?
  private var lastActivityUpdateTime: Date?
  private static let activityUpdateInterval: TimeInterval = 2.0

  private static let rows = 6
  private static let cols = 6
  private static let enemySpacingX: CGFloat = 45
  private static let enemySpacingY: CGFloat = 40
  private static let playerBulletSpeed: CGFloat = 700
  private static let enemyBulletSpeed: CGFloat = 300
  private static let playerSize: CGFloat = 40
  private static let enemySize: CGFloat = 30
  private static let bulletSize: CGFloat = 20
  private static let tiltThreshold: Double = 0.02
  private static let tiltSensitivity: CGFloat = 800
  private static let healthLossPerHit: CGFloat = 0.25
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
  private static let healthRestoreAmount: CGFloat = 0.25
  private static let shieldDuration: CGFloat = 6.0
  private static let rapidFireDuration: CGFloat = 5.0
  private static let rapidFireInterval: CGFloat = 0.3
  private static let diveInterval: CGFloat = 24.0
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
  private static let gameOverCooldown: TimeInterval = 2.0
  private static let waveCompleteDuration: TimeInterval = 3.0
  private static let waveSpeedScaling: CGFloat = 1.02
  private static let zigzaggerKinds: [(emoji: String, sound: Sound)] = [
    ("🐎", .horse), ("🐖", .pig), ("🐑", .sheep), ("🐐", .goat), ("🐄", .cow)
  ]
  private static let enemyImages = ["Hat", "Bundestag", "Stein", "Dachshund", "Clock", "Nutcracker"]

  private static let mechanicSpawnInterval: CGFloat = 27.0
  private static let initialMechanicDelay: CGFloat = 15.0

  private static let fussballSize: CGFloat = 30
  private static let fussballBaseSpeed: CGFloat = 200
  private static let fussballDuration: CGFloat = 15.0
  private static let fussballSpeedUpPerBounce: CGFloat = 1.08
  private static let fussballEnemyKillScore: Int = 100

  private static let wurstSegmentCount: Int = 5
  private static let wurstSegmentSize: CGFloat = 30
  private static let wurstSegmentSpacing: CGFloat = 35
  private static let wurstBaseSpeed: CGFloat = 240
  private static let wurstDescentStep: CGFloat = 35
  private static let wurstPlayerRowSpeedMultiplier: CGFloat = 1.8
  private static let wurstSegmentScore: Int = 75
  private static let pretzelObstacleSize: CGFloat = 30

  private static let ghostCount: ClosedRange<Int> = 2...3
  private static let ghostSize: CGFloat = 35
  private static let ghostDescentSpeed: CGFloat = 48
  private static let ghostPursuitSpeed: CGFloat = 150
  private static let ghostFleeSpeed: CGFloat = 100
  private static let ghostExitSpeed: CGFloat = 200
  private static let ghostDevourScore: Int = 300
  private static let ghostExitScore: Int = 50
  private static let dotSize: CGFloat = 24
  private static let dotScore: Int = 25
  private static let dotDropInterval: CGFloat = 0.3
  private static let kristallkugelSize: CGFloat = 25
  private static let kristallkugelMaxSpawns = 3
  private static let kristallkugelThresholds: [CGFloat] = [0.25, 0.50, 0.75]
  private static let geisterjagdDuration: CGFloat = 5.0

  private static let brainSize: CGFloat = 30
  private static let brainSpeed: CGFloat = 468
  private static let brainAscentSpeed: CGFloat = 40
  private static let brainScore: Int = 150
  private static let robotMinionSize: CGFloat = 30
  private static let armHitZone: CGFloat = 12
  private static let robotMinionScore: Int = 150
  private static let robotDiveDuration: CGFloat = 6.0
  private static let robotDiveDepthFactor: CGFloat = 0.7
  private static let robotDiveWidthAmplitude: CGFloat = 80
  private static let robotDivePause: CGFloat = 2.0
  static let boltAppearDelay: CGFloat = 1.0
  static let conversionDelay: CGFloat = 2.0
  private static let robotBulletSpeedMultiplier: CGFloat = 2.0

  func startGame(screenWidth: CGFloat, screenHeight: CGFloat, topInset: CGFloat) {
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.topInset = topInset

    phase = .playing
    score = 0
    wave = 1
    lastWaveScore = 0
    scoreAtWaveStart = 0
    waveCompleteTime = nil
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
    rapidFireSound = .longFire1
    diveTimer = 0
    eggs = []
    hatchlings = []
    portalSide = nil
    activeMechanic = nil
    mechanicSpawnTimer = 0
    mechanicBag = []
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
    gameOverTime = nil
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
    liveActivity = LiveActivityManager.startGameActivity()
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
    attemptEnemyFire()
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
    let raw = Float(score) * (Float(playerHealth) + 1.0) - Float(elapsed)
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


  // MARK: - Private

  private func startNextWave() {
    wave += 1
    scoreAtWaveStart = score

    playerBullet = nil
    enemyBullet = nil
    zigzagger = nil
    coins = []
    powerUps = []
    shieldActive = false
    rapidFireActive = false
    shieldTimer = 0
    rapidFireTimer = 0
    rapidFireCooldown = 0
    rapidFireSound = .longFire1
    eggs = []
    hatchlings = []
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
    activeMechanic = nil
    mechanicSpawnTimer = 0
    zigzaggerSpawnTimer = 0
    diveTimer = 0

    playerHealth = min(1.0, playerHealth + Self.healthRestoreAmount)
    enemySpeed = 21 * pow(Self.waveSpeedScaling, CGFloat(wave - 1))
    enemyDirection = 1
    sineTime = 0
    waveCompleteTime = nil
    lastUpdateTime = nil

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

    phase = .playing
    Current.analytics.signal(name: .completeWave)
  }

  private func startMotion() {
    guard motionManager.isDeviceMotionAvailable, !motionManager.isDeviceMotionActive else { return }
    motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    motionManager.startDeviceMotionUpdates()
  }

  private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    guard Current.settings.audioFeedback == .enable else { return }
    UIImpactFeedbackGenerator(style: style).impactOccurred()
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
          haptic(.medium)
        }
      case .right:
        if playerX >= screenWidth - Self.playerSize / 2 - 5 {
          playerX = Self.playerSize / 2
          portalSide = nil
          hatchlings.removeAll()
          haptic(.medium)
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
    let threshold = mechanicBag.isEmpty && mechanicSpawnTimer == 0
      ? Self.initialMechanicDelay
      : Self.mechanicSpawnInterval
    mechanicSpawnTimer += dt
    guard mechanicSpawnTimer >= threshold else { return }
    mechanicSpawnTimer = 0
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

  private func spawnFussball() {
    let angle = CGFloat.random(in: 0.3...0.8) * (Bool.random() ? 1 : -1)
    fussball = Fussball(
      x: screenWidth / 2,
      y: topInset + 50,
      velocityX: Self.fussballBaseSpeed * angle,
      velocityY: Self.fussballBaseSpeed * abs(1 - abs(angle)),
      remainingTime: Self.fussballDuration
    )
  }

  private func updateFussball(dt: CGFloat) {
    guard var ball = fussball else { return }
    ball.remainingTime -= dt
    if ball.remainingTime <= 0 {
      fussball = nil
      if activeMechanic == .fussball {
        activeMechanic = nil
      }
      return
    }
    ball.x += ball.velocityX * dt
    ball.y += ball.velocityY * dt
    let half = Self.fussballSize / 2
    if ball.x <= half {
      ball.x = half
      ball.velocityX = abs(ball.velocityX) * Self.fussballSpeedUpPerBounce
      ball.velocityY *= Self.fussballSpeedUpPerBounce
      ball.bounceCount += 1
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
    } else if ball.x >= screenWidth - half {
      ball.x = screenWidth - half
      ball.velocityX = -abs(ball.velocityX) * Self.fussballSpeedUpPerBounce
      ball.velocityY *= Self.fussballSpeedUpPerBounce
      ball.bounceCount += 1
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
    }
    if ball.y <= topInset + half {
      ball.y = topInset + half
      ball.velocityY = abs(ball.velocityY) * Self.fussballSpeedUpPerBounce
      ball.velocityX *= Self.fussballSpeedUpPerBounce
      ball.bounceCount += 1
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
    } else if ball.y >= screenHeight - half {
      ball.y = screenHeight - half
      ball.velocityY = -abs(ball.velocityY) * Self.fussballSpeedUpPerBounce
      ball.velocityX *= Self.fussballSpeedUpPerBounce
      ball.bounceCount += 1
      Current.soundPlayer.play(.soccerKick, shouldDebounce: true)
    }
    fussball = ball
  }

  private func spawnBratwurstkette() {
    var segments: [WurstSegment] = []
    let startX = (screenWidth - CGFloat(Self.wurstSegmentCount - 1) * Self.wurstSegmentSpacing) / 2
    let startY = topInset + 30
    for i in 0..<Self.wurstSegmentCount {
      segments.append(WurstSegment(x: startX + CGFloat(i) * Self.wurstSegmentSpacing, y: startY))
    }
    wurstChains = [WurstChain(segments: segments, movingRight: Bool.random(), speed: Self.wurstBaseSpeed)]
  }

  private func updateWurstChains(dt: CGFloat) {
    guard !wurstChains.isEmpty else { return }
    var chainsToRemove: [UUID] = []
    for i in wurstChains.indices {
      let nearPlayer = wurstChains[i].segments.contains { abs($0.y - playerY) < 100 }
      let speed = nearPlayer
        ? wurstChains[i].speed * Self.wurstPlayerRowSpeedMultiplier
        : wurstChains[i].speed
      let dx = speed * dt * (wurstChains[i].movingRight ? 1 : -1)
      var hitEdge = false
      for j in wurstChains[i].segments.indices {
        wurstChains[i].segments[j].x += dx
        let half = Self.wurstSegmentSize / 2
        if wurstChains[i].segments[j].x <= half || wurstChains[i].segments[j].x >= screenWidth - half {
          hitEdge = true
        }
      }
      if hitEdge {
        wurstChains[i].movingRight.toggle()
        for j in wurstChains[i].segments.indices {
          wurstChains[i].segments[j].y += Self.wurstDescentStep
          let half = Self.wurstSegmentSize / 2
          wurstChains[i].segments[j].x = max(half, min(screenWidth - half, wurstChains[i].segments[j].x))
        }
      }
      if wurstChains[i].segments.allSatisfy({ $0.y > screenHeight + Self.wurstSegmentSize }) {
        chainsToRemove.append(wurstChains[i].id)
      }
    }
    wurstChains.removeAll { chain in chainsToRemove.contains(chain.id) }
    if wurstChains.isEmpty && activeMechanic == .bratwurstkette {
      activeMechanic = nil
    }
  }

  private func updatePretzelOpacities(dt: CGFloat) {
    let fadeSpeed: CGFloat = 3.0
    for i in pretzelObstacles.indices {
      let target: CGFloat = switch pretzelObstacles[i].hitsRemaining {
      case 2:
        1.0
      case 1:
        0.5
      default:
        0.0
      }
      if pretzelObstacles[i].opacity > target {
        pretzelObstacles[i].opacity = max(target, pretzelObstacles[i].opacity - fadeSpeed * dt)
      }
    }
    pretzelObstacles.removeAll { $0.opacity <= 0 }
  }

  private func spawnGeisterstunde() {
    let count = Int.random(in: Self.ghostCount)
    ghosts = (0..<count).map { i in
      let spacing = screenWidth / CGFloat(count + 1)
      return Ghost(x: spacing * CGFloat(i + 1), y: topInset + 20)
    }
    goldenDots = []
    kristallkugel = nil
    geisterjagdActive = false
    geisterjagdTimer = 0
    kristallkugelSpawnCount = 0
  }

  private func updateGhosts(dt: CGFloat) {
    guard !ghosts.isEmpty || geisterjagdActive else { return }

    if geisterjagdActive {
      geisterjagdTimer -= dt
      if geisterjagdTimer <= 0 {
        geisterjagdActive = false
        geisterjagdTimer = 0
        for i in ghosts.indices {
          if ghosts[i].phase == .fleeing {
            ghosts[i].phase = .exiting
            score += Self.ghostExitScore
          }
        }
      }
    }

    let descentStart = topInset + 20
    let descentRange = playerY - descentStart
    var dotsToAdd: [GoldenDot] = []

    for i in ghosts.indices {
      switch ghosts[i].phase {
      case .descending:
        ghosts[i].y += Self.ghostDescentSpeed * dt
        ghosts[i].dotTimer += dt
        if ghosts[i].dotTimer >= Self.dotDropInterval {
          dotsToAdd.append(GoldenDot(x: ghosts[i].x, y: ghosts[i].y))
          ghosts[i].dotTimer = 0
        }
        if kristallkugel == nil && kristallkugelSpawnCount < Self.kristallkugelMaxSpawns {
          let threshold = descentStart + descentRange * Self.kristallkugelThresholds[kristallkugelSpawnCount]
          if ghosts[i].y >= threshold {
            kristallkugel = Kristallkugel(x: ghosts[i].x, y: ghosts[i].y)
            kristallkugelSpawnCount += 1
          }
        }
        if ghosts[i].y >= playerY {
          ghosts[i].phase = .pursuing
        }
      case .pursuing:
        if kristallkugel == nil && kristallkugelSpawnCount < Self.kristallkugelMaxSpawns {
          kristallkugel = Kristallkugel(x: ghosts[i].x, y: (topInset + ghosts[i].y) / 2)
          kristallkugelSpawnCount += 1
        }
        let dx = playerX - ghosts[i].x
        let direction: CGFloat = dx > 0 ? 1 : -1
        ghosts[i].x += direction * Self.ghostPursuitSpeed * dt
      case .fleeing:
        let dx = ghosts[i].x - playerX
        let direction: CGFloat = dx > 0 ? 1 : -1
        ghosts[i].x += direction * Self.ghostFleeSpeed * dt
        ghosts[i].x = max(Self.ghostSize / 2, min(screenWidth - Self.ghostSize / 2, ghosts[i].x))
      case .devoured:
        ghosts[i].dotTimer += dt
      case .exiting:
        ghosts[i].y -= Self.ghostExitSpeed * dt
      }
    }

    goldenDots.append(contentsOf: dotsToAdd)
    ghosts.removeAll { ghost in
      switch ghost.phase {
      case .devoured:
        return ghost.dotTimer >= 0.3
      case .exiting:
        return ghost.y < -Self.ghostSize
      default:
        return false
      }
    }

    if ghosts.isEmpty && !geisterjagdActive && activeMechanic == .geisterstunde {
      activeMechanic = nil
      goldenDots = []
      kristallkugel = nil
    }
  }

  private func spawnRobot() {
    robotBrain = RobotBrain(
      x: screenWidth / 2,
      y: playerY - 30,
      movingRight: Bool.random()
    )
  }

  private func updateRobot(dt: CGFloat) {
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
        haptic(.heavy)

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

  private func updateDeathEffects(dt: CGFloat) {
    for i in deathEffects.indices {
      deathEffects[i].age += dt
    }
    deathEffects.removeAll { $0.progress >= 1.0 }
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
        Current.soundPlayer.play(.pop, shouldDebounce: false)
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
          deathEffects.append(DeathEffect(x: enemies[i].x, y: enemies[i].y, imageName: enemies[i].imageName, useRed: Bool.random()))
          enemies[i].isAlive = false
          playerBullet = nil
          score += wasDiving ? Self.scorePerKill * Self.diveScoreMultiplier : Self.scorePerKill
          Current.soundPlayer.play(.pop, shouldDebounce: false)
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
        Current.soundPlayer.play(.chime, shouldDebounce: false)
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
          portalSide = nil
        }
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
        haptic(.heavy)
      }
    }

    // 5. Diving enemy vs player (shield check)
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
          portalSide = nil
        }
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
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
          portalSide = nil
        }
        Current.soundPlayer.play(.playerHit, shouldDebounce: false)
        haptic(.heavy)
        return true
      }
      return false
    }

    // 11. Player bullet vs wurst segments (chain split + pretzel spawn)
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
            haptic(.medium)
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

    // 12. Player bullet vs pretzel obstacles
    if let bullet = playerBullet {
      if let idx = pretzelObstacles.firstIndex(where: { p in
        p.hitsRemaining > 0 && rectsIntersect(ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
                       bx: p.x, by: p.y, bSize: Self.pretzelObstacleSize)
      }) {
        playerBullet = nil
        pretzelObstacles[idx].hitsRemaining -= 1
        Current.soundPlayer.play(.chime, shouldDebounce: false)
        haptic(.light)
      }
    }

    // 13. Enemy bullet vs pretzel obstacles
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

    // 14. Wurst segment vs player (shield check)
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
          haptic(.heavy)
        }
      }
    }

    // 15. Fussball vs enemies
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
          haptic(.medium)
          ball.velocityY = -ball.velocityY
          if Double.random(in: 0...1) < Self.powerUpDropChance {
            let kind = PowerUpKind.allCases.randomElement() ?? .bratwurst
            powerUps.append(PowerUp(x: enemies[i].x, y: enemies[i].y, kind: kind))
          }
        }
      }
      fussball = ball
    }

    // 16. Fussball vs player (shield check)
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
        haptic(.heavy)
      }
    }

    // 17. Player bullet vs fussball (deflect)
    if var ball = fussball, let bullet = playerBullet {
      if rectsIntersect(
        ax: bullet.x, ay: bullet.y, aSize: Self.bulletSize,
        bx: ball.x, by: ball.y, bSize: Self.fussballSize
      ) {
        playerBullet = nil
        ball.velocityY = -abs(ball.velocityY)
        ball.velocityX += CGFloat.random(in: -80...80)
        Current.soundPlayer.play(.soccerKick, shouldDebounce: false)
        haptic(.medium)
        fussball = ball
      }
    }

    // 18. Fussball vs pretzel obstacles
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

    // 19. Player bullet vs Kristallkugel (trigger Geisterjagd)
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
        haptic(.medium)
        for i in ghosts.indices {
          if ghosts[i].phase == .pursuing || ghosts[i].phase == .descending {
            ghosts[i].phase = .fleeing
          }
        }
      }
    }

    // 20. Player bullet vs golden dots (bullet passes through)
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
        haptic(.light)
      }
    }

    // 21. Ghost vs player
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
        haptic(.heavy)
      case .fleeing:
        ghosts[i].phase = .devoured
        ghosts[i].dotTimer = 0
        score += Self.ghostDevourScore
        Current.soundPlayer.play(.chomp, shouldDebounce: false)
        haptic(.medium)
      default:
        break
      }
    }

    // 22. Player bullet vs robot brain (3 hits)
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
        haptic(.medium)
      }
    }

    // 23. Player bullet vs robot minion (arm-targeted hits)
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
        haptic(.medium)
      }
    }

    // 24. Robot minion vs player (when diving, shield check)
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
        haptic(.heavy)
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
    let aliveEnemies = enemies.filter { $0.isAlive && !$0.isDiving }
    guard !aliveEnemies.isEmpty else { return }

    if Double.random(in: 0...1) < Self.enemyFireChance {
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
    LiveActivityManager.updateGameActivity(liveActivity, state: state)
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
    LiveActivityManager.updateGameActivity(liveActivity, state: state)
  }

  private func endLiveActivity() {
    guard let liveActivity else { return }
    let finalState = GameActivityAttributes.ContentState(
      wave: wave,
      score: score,
      healthFraction: Double(playerHealth),
      phase: phase.rawValue
    )
    LiveActivityManager.endGameActivity(liveActivity, finalState: finalState)
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
      phase = .lost
      portalSide = nil
      gameOverTime = .now
      SavedGame.clear(getterSetter: Current.getterSetter)
      Current.soundPlayer.stopMusic()
      Current.soundPlayer.play(.randomSadTrombone, shouldDebounce: false)
      persistHighScore()
      endLiveActivity()
      Current.analytics.signal(name: .loseGame)
      return
    }

    let bottomThreshold = playerY - Self.playerSize
    for enemy in aliveEnemies where !enemy.isDiving && enemy.y >= bottomThreshold {
      phase = .lost
      portalSide = nil
      gameOverTime = .now
      SavedGame.clear(getterSetter: Current.getterSetter)
      Current.soundPlayer.stopMusic()
      Current.soundPlayer.play(.randomSadTrombone, shouldDebounce: false)
      persistHighScore()
      endLiveActivity()
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
