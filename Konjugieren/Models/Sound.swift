// Copyright © 2026 Josh Adams. All rights reserved.

enum Sound: String {
  case applause1
  case applause2
  case applause3
  case buzz
  case chime
  case chomp
  case coin
  case cow
  case eggCrack
  case ghostSpooky
  case goat
  case gun1
  case gun2
  case horse
  case longFire1
  case longFire2
  case longFire3
  case magicActivate
  case pig
  case playerHit
  case pop
  case sadTrombone1
  case sadTrombone2
  case sadTrombone3
  case sadTrombone4
  case sheep
  case shieldActivate
  case silence
  case sizzle
  case soccerKick

  private static let guns: [Sound] = [.gun1, .gun2]
  private static let longFires: [Sound] = [.longFire1, .longFire2, .longFire3]
  private static let applauses: [Sound] = [.applause1, .applause2, .applause3]
  private static let sadTrombones: [Sound] = [.sadTrombone1, .sadTrombone2, .sadTrombone3, .sadTrombone4]

  static var randomGun: Sound {
    guns.randomElement() ?? .gun1
  }

  static var randomLongFire: Sound {
    longFires.randomElement() ?? .longFire1
  }

  static var randomApplause: Sound {
    applauses.randomElement() ?? .applause1
  }

  static var randomSadTrombone: Sound {
    sadTrombones.randomElement() ?? .sadTrombone1
  }
}
