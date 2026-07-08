// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension WidgetQuizQuestion {
  var shuffledAnswers: [String] {
    var answers = wrongAnswers
    answers.append(correctAnswer)
    var rng = SeededRNG(seed: Self.stableSeed(for: questionID))
    answers.shuffle(using: &rng)
    return answers
  }

  // Swift's Hasher is randomly seeded per process (SE-0206), so seeding a shuffle
  // from it silently reorders the options across widget-process relaunches. FNV-1a
  // over the questionID bytes is stable for a given ID for all time.
  static func stableSeed(for string: String) -> UInt64 {
    var hash: UInt64 = 0xcbf2_9ce4_8422_2325
    for byte in string.utf8 {
      hash ^= UInt64(byte)
      hash = hash &* 0x0000_0100_0000_01b3
    }
    return hash
  }
}

struct SeededRNG: RandomNumberGenerator {
  var state: UInt64

  init(seed: UInt64) {
    state = seed
  }

  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
  }
}
