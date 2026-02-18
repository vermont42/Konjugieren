// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite("MixedCaseAccessibility")
struct MixedCaseAccessibilityTests {
  @Test("Generates correct accessibility labels", arguments: zip(
    ["machte", "sAng", "BIN", "hat geSUNGen", "Sie machen", "machen Sie", "Sie sAng", "gehen", "wEIsS"],
    ["machte", "sang, a is irregular", "bin, b i n are irregular", "hat gesungen, s u n g are irregular", "Sie machen", "machen Sie", "Sie sang, a is irregular", "gehen", "weiss, e i s are irregular"]
  ))
  func accessibilityLabel(input: String, expected: String) throws {
    try #require(
      Locale.current.language.languageCode == .english,
      "Simulator locale must be English. Change it in Settings → General → Language & Region."
    )
    #expect(MixedCaseAccessibility.accessibilityLabel(for: input) == expected)
  }
}
