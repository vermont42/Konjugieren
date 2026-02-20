// Copyright © 2026 Josh Adams. All rights reserved.

import AVFoundation
import os

private let soundLogger = KonjugierenLogger.logger(category: "Sound")

class SoundPlayerReal: SoundPlayer {
  private var sounds: [String: AVAudioPlayer] = [:]
  private let soundExtension = "mp3"
  private var instantOfLastPlay: TimeInterval = 0.0
  private var musicPlayer: AVAudioPlayer?
  private static let musicVolume: Float = 0.15

  func setup() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, options: .mixWithOthers)
    } catch {
      soundLogger.warning("Failed to set audio session category: \(error.localizedDescription)")
    }

    play(.silence) // https://forums.developer.apple.com/thread/23160
  }

  func startMusic() {
    if Current.settings.audioFeedback == .disable { return }
    if musicPlayer == nil {
      if let url = Bundle.main.url(forResource: "beethoven", withExtension: soundExtension) {
        musicPlayer = try? AVAudioPlayer(contentsOf: url)
        musicPlayer?.numberOfLoops = -1
        musicPlayer?.volume = Self.musicVolume
      }
    }
    musicPlayer?.currentTime = 0
    musicPlayer?.play()
  }

  func stopMusic() {
    musicPlayer?.stop()
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
