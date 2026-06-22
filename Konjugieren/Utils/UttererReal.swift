// Copyright © 2026 Josh Adams. All rights reserved.

import AVFoundation
import os

private let uttererLogger = KonjugierenLogger.logger(category: "Utterer")

class UttererReal: Utterer {
  private let synth = AVSpeechSynthesizer()
  private let rate: Float = 0.5
  private let pitchMultiplier: Float = 0.8

  func setup() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, options: .mixWithOthers)
    } catch {
      uttererLogger.warning("Failed to set audio session category: \(error.localizedDescription)")
    }
    utter("", localeString: UttererLocale.german)
  }

  func utter(_ text: String, localeString: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.rate = rate
    utterance.voice = AVSpeechSynthesisVoice(language: localeString)
    utterance.pitchMultiplier = pitchMultiplier
    synth.stopSpeaking(at: .immediate)
    synth.speak(utterance)
    Current.soundPlayer.play(.silence)
  }
}
