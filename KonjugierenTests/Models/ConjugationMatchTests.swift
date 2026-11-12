// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
@Suite("ConjugationMatch")
struct ConjugationMatchTests {
  private func matches(_ text: String, of infinitiv: String) -> [ConjugationMatch] {
    Verb.verbs[infinitiv]?.conjugations(matching: text) ?? []
  }

  private func whole(_ conjugationgroup: Conjugationgroup, reading: Int = 0) -> ConjugationMatch {
    ConjugationMatch(readingIndex: reading, conjugationgroup: conjugationgroup, isFinitePart: false)
  }

  @Test func namesEveryCellThatMatches() {
    #expect(matches("ging", of: "gehen") == [
      whole(.präteritumIndikativ(.firstSingular)),
      whole(.präteritumIndikativ(.thirdSingular)),
    ])
  }

  @Test(arguments: ["stand auf", "aufstand", "Stand  AUF"])
  func acceptsEitherClauseCaseAndSpacing(text: String) {
    #expect(matches(text, of: "aufstehen") == [
      whole(.präteritumIndikativ(.firstSingular)),
      whole(.präteritumIndikativ(.thirdSingular)),
    ])
  }

  @Test func marksAFinitePart() {
    let found = matches("halte", of: "aufhalten")
    #expect(found.contains(ConjugationMatch(readingIndex: 0, conjugationgroup: .präsensIndikativ(.firstSingular), isFinitePart: true)))
    #expect(found.allSatisfy { $0.isFinitePart })
  }

  @Test func givesNoFinitePartToAnInseparableVerb() {
    #expect(matches("halten", of: "halten").allSatisfy { !$0.isFinitePart })
  }

  @Test(arguments: ["hat gestanden", "ist gestanden"])
  func acceptsEveryRegionsAuxiliary(text: String) {
    #expect(matches(text, of: "stehen").contains(whole(.perfektIndikativ(.thirdSingular))))
  }

  @Test(arguments: ["heißt", "heisst"])
  func acceptsEveryRegionsSpelling(text: String) {
    #expect(matches(text, of: "heißen").contains(whole(.präsensIndikativ(.thirdSingular))))
  }

  @Test func tellsReadingsApart() {
    #expect(matches("hing", of: "hängen").map(\.readingIndex).allSatisfy { $0 == 0 })
    #expect(matches("hängte", of: "hängen").map(\.readingIndex).allSatisfy { $0 == 1 })
    #expect(!matches("hängte", of: "hängen").isEmpty)
  }

  @Test(arguments: ["", "   ", "xyzzy", "gehen gehen"])
  func findsNothingForOtherText(text: String) {
    #expect(matches(text, of: "gehen").isEmpty)
  }

  @Test func coversEveryCellOnce() {
    #expect(Conjugationgroup.allCells.count == 2 + 4 * 6 + 4 + 7 * 6)
    #expect(Set(Conjugationgroup.allCells).count == Conjugationgroup.allCells.count)
  }
}
