// Copyright © 2025 Josh Adams. All rights reserved.

import Foundation
import Observation

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
  }
}
