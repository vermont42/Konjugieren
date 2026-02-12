// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum UserLocale {
  static var isGerman: Bool {
    Locale.current.language.languageCode == .init("de")
  }

  static var isEnglish: Bool {
    Locale.current.language.languageCode == .init("en")
  }
}
