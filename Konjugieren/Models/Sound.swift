// Copyright © 2026 Josh Adams. All rights reserved.

enum Sound: String {
  case applause1
  case applause2
  case applause3
  case buzz
  case chime
  case gun1
  case gun2
  case sadTrombone1
  case sadTrombone2
  case sadTrombone3
  case sadTrombone4
  case horse
  case pig
  case sheep
  case goat
  case cow
  case coin
  case silence
  case playerHit, enemyDestroyed, shieldActivate, soccerKick
  case ghostSpooky, magicActivate, chomp, sizzle, eggCrack, rapidFire

  private static let guns: [Sound] = [.gun1, .gun2]
  private static let applauses: [Sound] = [.applause1, .applause2, .applause3]
  private static let sadTrombones: [Sound] = [.sadTrombone1, .sadTrombone2, .sadTrombone3, .sadTrombone4]

  static var randomGun: Sound {
    guns.randomElement() ?? .gun1
  }

  static var randomApplause: Sound {
    applauses.randomElement() ?? .applause1
  }

  static var randomSadTrombone: Sound {
    sadTrombones.randomElement() ?? .sadTrombone1
  }
}
