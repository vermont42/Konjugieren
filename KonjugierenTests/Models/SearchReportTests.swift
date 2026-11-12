// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
@Suite("Search report")
struct SearchReportTests {
  private func matches(_ query: String) -> [VerbSearch.Match] {
    VerbSearch.matches(for: query, in: Verb.verbsSortedByFrequency, includeGlosses: true)
  }

  @Test func typingBeginsASearchWithoutEndingOne() {
    var tracker = SearchTracker()
    #expect(tracker.textChanged(to: "g") == nil)
    #expect(tracker.textChanged(to: "geh") == nil)
    #expect(tracker.query == "geh")
  }

  @Test func clearingTheFieldEndsTheSearch() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "geh")
    #expect(tracker.textChanged(to: "") == "geh")
    #expect(tracker.query == nil)
  }

  @Test func whitespaceAloneIsNoSearch() {
    var tracker = SearchTracker()
    #expect(tracker.textChanged(to: "  ") == nil)
    #expect(tracker.query == nil)
  }

  @Test func aFinishedSearchIsNotFinishedAgain() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "geh")
    #expect(tracker.finish() == "geh")
    #expect(tracker.finish() == nil)
    #expect(tracker.textChanged(to: "") == nil)
  }

  @Test func editingAfterAnOpenBeginsANewSearch() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "geh")
    _ = tracker.finish()
    _ = tracker.textChanged(to: "gehe")
    #expect(tracker.finish() == "gehe")
  }

  @Test func openedReportNamesTheOpenedResultsKind() {
    let report = SearchReport.opened(query: "gehen", matches: matches("gehen"), position: 0)
    #expect(report.outcome == .opened)
    #expect(report.matchKind == .exactInfinitive)
    #expect(report.parameters == [
      "outcome": "opened",
      "queryLength": "3-5",
      "resultCount": AnalyticsBand.resultCount(matches("gehen").count),
      "matchKind": "exactInfinitive",
      "resultPosition": "1",
    ])
  }

  @Test func foldedQueryReportsAFoldedMatch() {
    let report = SearchReport.opened(query: "konnen", matches: matches("konnen"), position: 0)
    #expect(report.matchKind == .exactFoldedInfinitive)
  }

  @Test func glossQueryReportsAGlossMatch() {
    let report = SearchReport.opened(query: "eat", matches: matches("eat"), position: 0)
    #expect(report.matchKind == .wholeWordGloss)
  }

  @Test func searchWithResultsAndNoOpenIsAbandoned() {
    let report = SearchReport.ended(query: "geh", matches: matches("geh"))
    #expect(report.outcome == .abandoned)
    #expect(report.matchKind == .infinitivePrefix)
    #expect(report.parameters["resultPosition"] == "none")
  }

  @Test func searchWithNoResultsIsNoResult() {
    let report = SearchReport.ended(query: "xyzzyq", matches: matches("xyzzyq"))
    #expect(report.outcome == .noResult)
    #expect(report.matchKind == .none)
    #expect(report.parameters["resultCount"] == "0")
  }

  @Test func openingTheGuessIsAnOpenWithNoResults() {
    let report = SearchReport.openedGuess(query: "gehn")
    #expect(report.parameters == [
      "outcome": "opened",
      "queryLength": "3-5",
      "resultCount": "0",
      "matchKind": "guess",
      "resultPosition": "1",
    ])
  }

  // The privacy policy promises that nothing typed is sent. Every value must come from a fixed
  // vocabulary or a band, so none can echo the query.
  @Test(arguments: ["gehen", "es", "1", "10+", "opened", "Schmiesing"])
  func noParameterValueEchoesTheQuery(query: String) {
    let vocabulary = Set(
      SearchOutcome.allCases.map(\.rawValue)
        + SearchMatchKind.allCases.map(\.rawValue)
        + ["1-2", "3-5", "6-9", "10+", "0", "1", "2-10", "11+", "2-5", "6+", "none"]
    )
    let found = matches(query)
    let reports = [
      SearchReport.ended(query: query, matches: found),
      SearchReport.opened(query: query, matches: found, position: 0),
      SearchReport.openedGuess(query: query),
    ]
    for report in reports {
      #expect(Set(report.parameters.values).isSubset(of: vocabulary))
    }
  }
}
