// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Observation
import os
import UIKit

nonisolated private let settingsLogger = KonjugierenLogger.logger(category: "Settings")

@MainActor
@Observable
class Settings {
  private let getterSetter: GetterSetter

  var conjugationgroupLang: ConjugationgroupLang = conjugationgroupLangDefault {
    didSet {
      if conjugationgroupLang != oldValue {
        getterSetter.set(key: Settings.conjugationgroupLangKey, value: "\(conjugationgroupLang)")
      }
    }
  }
  static let conjugationgroupLangKey = "conjugationgroupLang"
  static let conjugationgroupLangDefault: ConjugationgroupLang = .german

  var thirdPersonPronounGender: ThirdPersonPronounGender = thirdPersonPronounGenderDefault {
    didSet {
      if thirdPersonPronounGender != oldValue {
        getterSetter.set(key: Settings.thirdPersonPronounGenderKey, value: "\(thirdPersonPronounGender)")
      }
    }
  }
  static let thirdPersonPronounGenderKey = "thirdPersonPronounGender"
  static let thirdPersonPronounGenderDefault: ThirdPersonPronounGender = .er

  var quizDifficulty: QuizDifficulty = quizDifficultyDefault {
    didSet {
      if quizDifficulty != oldValue {
        getterSetter.set(key: Settings.quizDifficultyKey, value: "\(quizDifficulty)")
      }
    }
  }
  static let quizDifficultyKey = "quizDifficulty"
  static let quizDifficultyDefault: QuizDifficulty = .regular

  var audioFeedback: AudioFeedback = audioFeedbackDefault {
    didSet {
      if audioFeedback != oldValue {
        getterSetter.set(key: Settings.audioFeedbackKey, value: "\(audioFeedback)")
      }
    }
  }
  static let audioFeedbackKey = "audioFeedback"
  static let audioFeedbackDefault: AudioFeedback = .enable

  var searchScope: SearchScope = searchScopeDefault {
    didSet {
      if searchScope != oldValue {
        getterSetter.set(key: Settings.searchScopeKey, value: "\(searchScope)")
      }
    }
  }
  static let searchScopeKey = "searchScope"
  static let searchScopeDefault: SearchScope = .infinitiveOnly

  var appIcon: AppIcon = appIconDefault {
    didSet {
      if appIcon != oldValue {
        getterSetter.set(key: Settings.appIconKey, value: "\(appIcon)")
        setAppIcon(appIcon)
      }
    }
  }
  static let appIconKey = "appIcon"
  static let appIconDefault: AppIcon = .hat

  var hasSeenOnboarding: Bool = hasSeenOnboardingDefault {
    didSet {
      if hasSeenOnboarding != oldValue {
        getterSetter.set(key: Settings.hasSeenOnboardingKey, value: "\(hasSeenOnboarding)")
      }
    }
  }
  static let hasSeenOnboardingKey = "hasSeenOnboarding"
  static let hasSeenOnboardingDefault: Bool = false

  private func setAppIcon(_ icon: AppIcon) {
    guard UIApplication.shared.supportsAlternateIcons else { return }
    UIApplication.shared.setAlternateIconName(icon.alternateIconName) { error in
      if let error {
        settingsLogger.warning("Failed to set icon: \(error.localizedDescription)")
      }
    }
  }

  init(getterSetter: GetterSetter) {
    self.getterSetter = getterSetter
    conjugationgroupLang = restore(key: Settings.conjugationgroupLangKey, default: Settings.conjugationgroupLangDefault)
    thirdPersonPronounGender = restore(key: Settings.thirdPersonPronounGenderKey, default: Settings.thirdPersonPronounGenderDefault)
    quizDifficulty = restore(key: Settings.quizDifficultyKey, default: Settings.quizDifficultyDefault)
    audioFeedback = restore(key: Settings.audioFeedbackKey, default: Settings.audioFeedbackDefault)
    searchScope = restore(key: Settings.searchScopeKey, default: Settings.searchScopeDefault)
    appIcon = restore(key: Settings.appIconKey, default: Settings.appIconDefault)

    if let hasSeenOnboardingString = getterSetter.get(key: Settings.hasSeenOnboardingKey) {
      hasSeenOnboarding = (hasSeenOnboardingString == "true")
    } else {
      getterSetter.set(key: Settings.hasSeenOnboardingKey, value: "\(hasSeenOnboarding)")
    }
  }

  private func restore<T: RawRepresentable>(key: String, default defaultValue: T) -> T where T.RawValue == String {
    if let stored = getterSetter.get(key: key) {
      return T(rawValue: stored) ?? defaultValue
    } else {
      getterSetter.set(key: key, value: "\(defaultValue)")
      return defaultValue
    }
  }
}
