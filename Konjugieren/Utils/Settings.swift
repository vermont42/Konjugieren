// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Observation

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

  init(getterSetter: GetterSetter) {
    self.getterSetter = getterSetter
    if let conjugationgroupLangString = getterSetter.get(key: Settings.conjugationgroupLangKey) {
      conjugationgroupLang = ConjugationgroupLang(rawValue: conjugationgroupLangString) ?? Settings.conjugationgroupLangDefault
    } else {
      getterSetter.set(key: Settings.conjugationgroupLangKey, value: "\(conjugationgroupLang)")
    }

    if let thirdPersonPronounGenderString = getterSetter.get(key: Settings.thirdPersonPronounGenderKey) {
      thirdPersonPronounGender = ThirdPersonPronounGender(rawValue: thirdPersonPronounGenderString) ?? Settings.thirdPersonPronounGenderDefault
    } else {
      getterSetter.set(key: Settings.thirdPersonPronounGenderKey, value: "\(thirdPersonPronounGender)")
    }

    if let quizDifficultyString = getterSetter.get(key: Settings.quizDifficultyKey) {
      quizDifficulty = QuizDifficulty(rawValue: quizDifficultyString) ?? Settings.quizDifficultyDefault
    } else {
      getterSetter.set(key: Settings.quizDifficultyKey, value: "\(quizDifficulty)")
    }

    if let audioFeedbackString = getterSetter.get(key: Settings.audioFeedbackKey) {
      audioFeedback = AudioFeedback(rawValue: audioFeedbackString) ?? Settings.audioFeedbackDefault
    } else {
      getterSetter.set(key: Settings.audioFeedbackKey, value: "\(audioFeedback)")
    }

    if let searchScopeString = getterSetter.get(key: Settings.searchScopeKey) {
      searchScope = SearchScope(rawValue: searchScopeString) ?? Settings.searchScopeDefault
    } else {
      getterSetter.set(key: Settings.searchScopeKey, value: "\(searchScope)")
    }
  }
}
