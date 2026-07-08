// Copyright © 2026 Josh Adams. All rights reserved.

enum MixedCaseAccessibility {
  static func accessibilityLabel(for mixedCaseString: String) -> String {
    let segments = MixedCaseSegmenter.segments(for: mixedCaseString)
    let lowercasedWord = segments.map(\.text).joined()
    let irregularLetters = segments
      .filter(\.isIrregular)
      .flatMap { $0.text.map(String.init) }

    if irregularLetters.isEmpty {
      return lowercasedWord
    }

    let joined = irregularLetters.joined(separator: " ")

    if irregularLetters.count == 1 {
      return "\(lowercasedWord), \(joined) \(L.Accessibility.isIrregular)"
    } else {
      return "\(lowercasedWord), \(joined) \(L.Accessibility.areIrregular)"
    }
  }
}
