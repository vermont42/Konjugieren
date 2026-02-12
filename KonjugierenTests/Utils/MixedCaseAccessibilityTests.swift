// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

struct MixedCaseAccessibilityTests {
  @Test func noIrregularLetters() {
    let result = MixedCaseAccessibility.accessibilityLabel(for: "machte")
    #expect(result == "machte")
  }

  @Test func singleIrregularLetter() {
    let result = MixedCaseAccessibility.accessibilityLabel(for: "sAng")
    #expect(result == "sang, a is irregular")
  }

  @Test func multipleIrregularLetters() {
    let result = MixedCaseAccessibility.accessibilityLabel(for: "BIN")
    #expect(result == "bin, b i n are irregular")
  }

  @Test func compoundFormWithIrregular() {
    let result = MixedCaseAccessibility.accessibilityLabel(for: "hat geSUNGen")
    #expect(result == "hat gesungen, s u n g are irregular")
  }

  @Test func formalSieNotIrregular() {
    let result = MixedCaseAccessibility.accessibilityLabel(for: "Sie machen")
    #expect(result == "Sie machen")
  }

  @Test func formalSieAtEndNotIrregular() {
    let result = MixedCaseAccessibility.accessibilityLabel(for: "machen Sie")
    #expect(result == "machen Sie")
  }

  @Test func mixedWithSie() {
    let result = MixedCaseAccessibility.accessibilityLabel(for: "Sie sAng")
    #expect(result == "Sie sang, a is irregular")
  }

  @Test func allLowercase() {
    let result = MixedCaseAccessibility.accessibilityLabel(for: "gehen")
    #expect(result == "gehen")
  }

  @Test func singleCharIrregular() {
    let result = MixedCaseAccessibility.accessibilityLabel(for: "wEIsS")
    #expect(result == "weiss, e i s are irregular")
  }
}
