// Copyright © 2026 Josh Adams. All rights reserved.

import AVFoundation

class UttererReal: Utterer {
  private let synth = AVSpeechSynthesizer()
  private let rate: Float = 0.5
  private let pitchMultiplier: Float = 0.8

  func setup() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, options: .mixWithOthers)
    } catch {}
    utter("", localeString: Self.germanLocaleString)
  }

  func utter(_ text: String, localeString: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.rate = rate
    utterance.voice = AVSpeechSynthesisVoice(language: localeString)
    utterance.pitchMultiplier = pitchMultiplier
    synth.speak(utterance)
    Current.soundPlayer.play(.silence)
  }
}
