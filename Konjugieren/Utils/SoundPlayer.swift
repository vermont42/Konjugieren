// Copyright © 2026 Josh Adams. All rights reserved.

protocol SoundPlayer {
  func setup()
  func play(_ sound: Sound, shouldDebounce: Bool)
}

extension SoundPlayer {
  func play(_ sound: Sound) {
    play(sound, shouldDebounce: true)
  }
}
