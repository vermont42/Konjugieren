// Copyright © 2026 Josh Adams. All rights reserved.

import AVFoundation
import os

private let soundLogger = KonjugierenLogger.logger(category: "Sound")

class SoundPlayerReal: SoundPlayer {
  private var sounds: [String: AVAudioPlayer] = [:]
  private let soundExtension = "mp3"
  private var instantOfLastPlay: TimeInterval = 0.0
  private var musicPlayer: AVAudioPlayer?
  private var savedMusicTime: TimeInterval?
  private static let musicVolume: Float = 0.15
  private static let musicFadeDuration: TimeInterval = 2.0

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
      }
    }
    guard let player = musicPlayer else { return }
    if let saved = savedMusicTime {
      player.currentTime = saved
      savedMusicTime = nil
    } else {
      player.currentTime = TimeInterval.random(in: 0..<player.duration)
    }
    player.volume = 0
    player.play()
    player.setVolume(Self.musicVolume, fadeDuration: Self.musicFadeDuration)
  }

  func stopMusic() {
    if let player = musicPlayer, player.isPlaying {
      savedMusicTime = player.currentTime
    }
    musicPlayer?.stop()
  }

  func play(_ sound: Sound, shouldDebounce: Bool, volume: Float) {
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
      sounds[sound.rawValue]?.volume = volume
      sounds[sound.rawValue]?.play()
      instantOfLastPlay = instantOfCurrentPlay
    }
  }
}
