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

@Suite("Verb browse grid sections")
struct VerbBrowseGridSectionTests {
  // "H" heads the separable verbs' section, and "c" marks a verb shown under it.
  private func sections(_ entries: [String]) -> [[Int]] {
    VerbBrowseView.gridSections(of: entries) { $0 == "H" } isUnderHeader: { $0 == "c" }
      .map { $0.map(\.offset) }
  }

  @Test func openRowGetsItsOwnSectionBetweenTheOthers() {
    #expect(sections(["a", "H", "c", "c", "b", "b"]) == [[0], [1, 2, 3], [4, 5]])
  }

  @Test func closedRowStillSeparatesTheRowsAfterIt() {
    #expect(sections(["a", "H", "b"]) == [[0], [1], [2]])
  }

  @Test func rowsWithoutAHeaderAreOneSection() {
    #expect(sections(["a", "b", "b"]) == [[0, 1, 2]])
  }

  @Test func headerFirstHasNoEmptySectionBeforeIt() {
    #expect(sections(["H", "c", "b"]) == [[0, 1], [2]])
  }
}
