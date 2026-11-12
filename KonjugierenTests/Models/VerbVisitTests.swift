// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("Verb visit")
struct VerbVisitTests {
  private let start = Date(timeIntervalSinceReferenceDate: 0)

  @Test func aVisitBeginsAtTheHeader() {
    let visit = VerbVisit(source: .search, start: start)
    #expect(visit.deepestSection == .header)
    #expect(visit.viewParameters == ["source": "search"])
  }

  @Test func scrollingBackUpKeepsTheDeepestSection() {
    var visit = VerbVisit(source: .browse, start: start)
    visit.reach(.simple)
    visit.reach(.etymology)
    visit.reach(.compound)
    #expect(visit.deepestSection == .etymology)
  }

  @Test func aResumedVisitStartsFromWhatIsAlreadyOnScreen() {
    let visit = VerbVisit(source: .resume, start: start, visibleSections: [.etymology, .example])
    #expect(visit.deepestSection == .example)
  }

  @Test func leaveParametersBandTheDwell() {
    var visit = VerbVisit(source: .widget, start: start)
    visit.reach(.compound)
    #expect(visit.leaveParameters(end: start.addingTimeInterval(20)) == [
      "deepestSection": "compound",
      "dwell": "15-60s",
    ])
  }
}
