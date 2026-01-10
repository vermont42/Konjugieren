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
  case silence

  static var randomGun: Sound {
    randomSound(base: "gun", count: [Sound.gun1, .gun2].count, defaultSound: .gun1)
  }

  static var randomApplause: Sound {
    randomSound(base: "applause", count: [Sound.applause1, .applause2, .applause3].count, defaultSound: .applause1)
  }

  static var randomSadTrombone: Sound {
    randomSound(base: "sadTrombone", count: [Sound.sadTrombone1, .sadTrombone2, .sadTrombone3, .sadTrombone4].count, defaultSound: .sadTrombone1)
  }

  private static func randomSound(base: String, count: Int, defaultSound: Sound) -> Sound {
    let randomIndex = Int.random(in: 1 ... count)
    return Sound(rawValue: base + "\(randomIndex)") ?? defaultSound
  }
}
