// Copyright © 2026 Josh Adams. All rights reserved.

protocol Utterer {
  func setup()
  func utter(_ text: String, localeString: String)
}

extension Utterer {
  static var germanLocaleString: String { "de-DE" }
  static var englishLocaleString: String { "en-US" }

  func utter(_ text: String) {
    utter(text, localeString: Self.germanLocaleString)
  }
}
