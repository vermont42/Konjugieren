// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

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
