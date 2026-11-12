// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@Suite("Verb browse keyboard selection")
struct VerbBrowseViewTests {
  @Test(arguments: [
    (nil, 1, 5, 0),
    (nil, -1, 5, nil),
    (0, 1, 5, 1),
    (3, -1, 5, 2),
    (4, 1, 5, 4),
    (0, -1, 5, 0),
    (nil, 1, 0, nil),
    (2, 1, 0, nil),
  ] as [(Int?, Int, Int, Int?)])
  func arrowKeysMoveTheSelectionAndStopAtTheEnds(current: Int?, offset: Int, count: Int, expected: Int?) {
    #expect(VerbBrowseView.keyboardSelection(after: current, moving: offset, count: count) == expected)
  }
}
