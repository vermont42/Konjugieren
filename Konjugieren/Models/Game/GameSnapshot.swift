// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

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
  let hasSpawnedFirstMechanic: Bool
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
    getterSetter.setCodable(key: storageKey, value: snapshot)
  }

  static func load(getterSetter: GetterSetter) -> GameStateSnapshot? {
    getterSetter.getCodable(key: storageKey)
  }

  static func clear(getterSetter: GetterSetter) {
    getterSetter.set(key: storageKey, value: "")
  }
}
