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
  private var isMusicActive = false
  private var instantOfLastRebuild: TimeInterval = 0.0
  private static let musicVolume: Float = 0.15
  private static let musicFadeDuration: TimeInterval = 2.0
  private static let minRebuildInterval: TimeInterval = 5.0

  func setup() {
    configureSession()
    observeSessionDisruptions()
    preloadSounds()
    play(.silence) // https://forums.developer.apple.com/thread/23160
  }

  private func configureSession() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, options: .mixWithOthers)
      try session.setActive(true)
    } catch {
      soundLogger.warning("Failed to configure audio session: \(error.localizedDescription)")
    }
  }

  /// Media services reset when `mediaserverd` restarts, which another audio-heavy app on the
  /// device can provoke. The reset reverts this app's session to the system-default
  /// `.soloAmbient` category and orphans every existing `AVAudioPlayer`: `play()` then returns
  /// `false` and the app is silent for the rest of the process, with no error surfaced anywhere.
  /// Apple's prescribed recovery is to rebuild every audio object and re-establish the session,
  /// which is what `rebuildAudio` does. Interruptions (a phone call, Siri) leave the players
  /// intact but deactivate the session, so those need only reactivation.
  private func observeSessionDisruptions() {
    let center = NotificationCenter.default
    center.addObserver(
      forName: AVAudioSession.mediaServicesWereResetNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      MainActor.assumeIsolated {
        self?.rebuildAudio()
      }
    }
    center.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      // Notification is not Sendable, so the interruption type is read here and only the Bool
      // crosses into the main actor.
      let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
      let didEnd = rawType.flatMap(AVAudioSession.InterruptionType.init(rawValue:)) == .ended
      MainActor.assumeIsolated {
        guard didEnd else { return }
        self?.configureSession()
      }
    }
  }

  private func rebuildAudio() {
    soundLogger.warning("Rebuilding audio players after an audio-session disruption.")
    sounds.removeAll()
    let shouldResumeMusic = isMusicActive
    savedMusicTime = musicPlayer?.currentTime ?? savedMusicTime
    musicPlayer = nil
    configureSession()
    preloadSounds()
    if shouldResumeMusic {
      startMusic()
    }
  }

  private func makePlayer(for sound: Sound) -> AVAudioPlayer? {
    guard let audioURL = Bundle.main.url(forResource: sound.rawValue, withExtension: soundExtension) else {
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: audioURL)
      player.prepareToPlay()
      return player
    } catch {
      soundLogger.warning("Failed to load sound \(sound.rawValue): \(error.localizedDescription)")
      return nil
    }
  }

  private func preloadSounds() {
    for sound in Sound.allCases where sounds[sound.rawValue] == nil {
      sounds[sound.rawValue] = makePlayer(for: sound)
    }
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
      player.currentTime = player.duration > 0 ? TimeInterval.random(in: 0..<player.duration) : 0
    }
    player.volume = 0
    player.play()
    player.setVolume(Self.musicVolume, fadeDuration: Self.musicFadeDuration)
    isMusicActive = true
  }

  func stopMusic() {
    if let player = musicPlayer, player.isPlaying {
      savedMusicTime = player.currentTime
    }
    musicPlayer?.stop()
    isMusicActive = false
  }

  func play(_ sound: Sound, shouldDebounce: Bool, volume: Float) {
    if Current.settings.audioFeedback == .disable {
      return
    }

    if sounds[sound.rawValue] == nil {
      sounds[sound.rawValue] = makePlayer(for: sound)
    }

    let instantOfCurrentPlay = Date().timeIntervalSince1970
    let minSoundInterval: TimeInterval = 1.0
    guard !shouldDebounce || (instantOfCurrentPlay - instantOfLastPlay > minSoundInterval) else {
      return
    }

    guard let player = sounds[sound.rawValue] else { return }
    player.volume = volume
    // A player orphaned by a media-services reset returns false rather than throwing, so this is
    // the only in-band signal that the session and the players need rebuilding. Recovering here as
    // well as in the notification handler costs one sound and keeps a missed or late-delivered
    // notification from silencing the app until the next launch. The interval throttles the case
    // where a single sound fails to start for some other reason: without it, a game frame that
    // plays that sound would reallocate all of `Sound.allCases` on the main actor every frame.
    if !player.play(), instantOfCurrentPlay - instantOfLastRebuild > Self.minRebuildInterval {
      instantOfLastRebuild = instantOfCurrentPlay
      rebuildAudio()
      let rebuilt = sounds[sound.rawValue]
      rebuilt?.volume = volume
      rebuilt?.play()
    }
    instantOfLastPlay = instantOfCurrentPlay
  }
}
