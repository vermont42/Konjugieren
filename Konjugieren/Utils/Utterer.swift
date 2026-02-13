// Copyright © 2026 Josh Adams. All rights reserved.

protocol Utterer {
  func setup()
  func utter(_ text: String, localeString: String)
}

extension Utterer {
  func utter(_ text: String) {
    utter(text, localeString: UttererLocale.german)
  }
}

enum UttererLocale {
  static let german = "de-DE"
  static let english = "en-US"
}
