// Copyright © 2026 Josh Adams. All rights reserved.

import AVFoundation

class SoundPlayerReal: SoundPlayer {
  private var sounds: [String: AVAudioPlayer] = [:]
  private let soundExtension = "mp3"
  private var instantOfLastPlay: TimeInterval = 0.0

  func setup() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, options: .mixWithOthers)
    } catch {}

    play(.silence) // https://forums.developer.apple.com/thread/23160
  }

  func play(_ sound: Sound, shouldDebounce: Bool) {
    if Current.settings.audioFeedback == .disable {
      return
    }

    if sounds[sound.rawValue] == nil {
      if let audioURL = Bundle.main.url(forResource: sound.rawValue, withExtension: soundExtension) {
        try? sounds[sound.rawValue] = AVAudioPlayer.init(contentsOf: audioURL)
      }
    }

    let instantOfCurrentPlay = Date().timeIntervalSince1970
    let minSoundInterval: TimeInterval = 1.0
    if !shouldDebounce || (instantOfCurrentPlay - instantOfLastPlay > minSoundInterval) {
      sounds[sound.rawValue]?.play()
      instantOfLastPlay = instantOfCurrentPlay
    }
  }
}
