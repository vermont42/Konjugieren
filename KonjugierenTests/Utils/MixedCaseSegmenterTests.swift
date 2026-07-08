// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
@Suite("MixedCaseSegmenter")
struct MixedCaseSegmenterTests {
  private static func describe(_ input: String) -> [String] {
    MixedCaseSegmenter.segments(for: input).map { "\($0.text)|\($0.isIrregular)" }
  }

  @Test("Segments a variety of mixed-case strings", arguments: zip(
    ["", "machen", "BIN", "wEIsS", "Sie", "machen Sie", "Sie sAng", "machen Sie sAng"],
    [
      [],
      ["machen|false"],
      ["bin|true"],
      ["w|false", "ei|true", "s|false", "s|true"],
      ["Sie|false"],
      ["machen Sie|false"],
      ["Sie s|false", "a|true", "ng|false"],
      ["machen Sie s|false", "a|true", "ng|false"]
    ]
  ))
  func segments(input: String, expected: [String]) {
    #expect(Self.describe(input) == expected)
  }

  @Test("Emits no phantom empty segment")
  func noEmptySegments() {
    for input in ["", "machen", "BIN", "Sie sAng"] {
      let segments = MixedCaseSegmenter.segments(for: input)
      #expect(segments.allSatisfy { !$0.text.isEmpty })
    }
  }
}
