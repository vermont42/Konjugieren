// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import Testing

@MainActor
@Suite("Search report")
struct SearchReportTests {
  private func matches(_ query: String) -> [VerbSearch.Match] {
    VerbSearch.matches(for: query, in: Verb.verbsSortedByFrequency, includeGlosses: true)
  }

  private func results(_ query: String) -> VerbSearchResults {
    VerbSearchResults(query: query, verbs: Verb.verbsSortedByFrequency, includeGlosses: true, includesGuess: false)
  }

  private func openedFirst(_ query: String) throws -> SearchReport {
    let found = matches(query)
    let kind = try #require(found.first?.kind)
    return SearchReport.opened(query: query, resultCount: found.count, kind: kind, position: 0)
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
    #expect(tracker.textChanged(to: "")?.query == "geh")
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
    #expect(tracker.finish()?.query == "geh")
    #expect(tracker.finish() == nil)
    #expect(tracker.textChanged(to: "") == nil)
  }

  @Test func editingAfterAnOpenBeginsANewSearch() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "geh")
    _ = tracker.finish()
    _ = tracker.textChanged(to: "gehe")
    #expect(tracker.finish()?.query == "gehe")
  }

  @Test func aSearchTypedInTheTabIsTheTabs() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "geh")
    #expect(tracker.finish()?.source == .tab)
  }

  @Test func aSearchTakesTheSourceOfTheSurfaceThatOpenedTheField() {
    var tracker = SearchTracker()
    #expect(tracker.fieldOpened(from: .control) == nil)
    _ = tracker.textChanged(to: "g")
    _ = tracker.textChanged(to: "geh")
    #expect(tracker.finish() == SearchTracker.Search(query: "geh", source: .control))
  }

  @Test func onlyTheFirstSearchAfterTheFieldOpensTakesItsSource() {
    var tracker = SearchTracker()
    _ = tracker.fieldOpened(from: .quickAction)
    _ = tracker.textChanged(to: "geh")
    _ = tracker.textChanged(to: "")
    _ = tracker.textChanged(to: "kom")
    #expect(tracker.finish()?.source == .tab)
  }

  @Test func openingTheFieldEndsASearchInProgress() {
    var tracker = SearchTracker()
    _ = tracker.textChanged(to: "geh")
    #expect(tracker.fieldOpened(from: .lookup) == SearchTracker.Search(query: "geh", source: .tab))
    _ = tracker.textChanged(to: "ging")
    #expect(tracker.finish()?.source == .lookup)
  }

  @Test func closingAnUntouchedFieldForgetsItsSource() {
    var tracker = SearchTracker()
    _ = tracker.fieldOpened(from: .control)
    tracker.fieldClosed()
    _ = tracker.textChanged(to: "geh")
    #expect(tracker.finish()?.source == .tab)
  }

  @Test func closingTheFieldMidSearchKeepsItsSource() {
    var tracker = SearchTracker()
    _ = tracker.fieldOpened(from: .control)
    _ = tracker.textChanged(to: "geh")
    tracker.fieldClosed()
    #expect(tracker.finish()?.source == .control)
  }

  @Test func openedReportNamesTheOpenedResultsKind() throws {
    let report = try openedFirst("gehen")
    #expect(report.outcome == .opened)
    #expect(report.matchKind == .exactInfinitive)
    #expect(report.parameters == [
      "source": "tab",
      "outcome": "opened",
      "queryLength": "3-5",
      "resultCount": AnalyticsBand.resultCount(matches("gehen").count),
      "matchKind": "exactInfinitive",
      "resultPosition": "1"
    ])
  }

  @Test func foldedQueryReportsAFoldedMatch() throws {
    #expect(try openedFirst("konnen").matchKind == .exactFoldedInfinitive)
  }

  @Test func glossQueryReportsAGlossMatch() throws {
    #expect(try openedFirst("eat").matchKind == .wholeWordGloss)
  }

  @Test(arguments: zip(
    ["ging", "stand auf", "muß", "gehort"],
    [SearchMatchKind.conjugation, .conjugation, .foldedConjugation, .foldedConjugation]
  ))
  func conjugationQueryReportsAConjugationMatch(query: String, kind: SearchMatchKind) throws {
    #expect(try openedFirst(query).matchKind == kind)
  }

  @Test func openingAFinitePartReportsAFinitePart() {
    let report = SearchReport.opened(query: "hielt", resultCount: 68, kind: .finitePart, position: 2)
    #expect(report.parameters["matchKind"] == "finitePart")
    #expect(report.parameters["resultCount"] == "11+")
    #expect(report.parameters["resultPosition"] == "2-5")
  }

  // geh is gehen's Imperativ, so its top result is a conjugation, not an infinitive prefix.
  @Test func searchWithResultsAndNoOpenIsAbandoned() {
    let report = SearchReport.ended(query: "geh", results: results("geh"))
    #expect(report.outcome == .abandoned)
    #expect(report.matchKind == .conjugation)
    #expect(report.parameters["resultPosition"] == "none")
  }

  @Test func searchWithNoResultsIsNoResult() {
    let report = SearchReport.ended(query: "xyzzyq", results: results("xyzzyq"))
    #expect(report.outcome == .noResult)
    #expect(report.matchKind == .none)
    #expect(report.parameters["resultCount"] == "0")
  }

  // The verb list reports a search's end from the results it showed, where it once searched
  // again. hielt and fuhren have folded rows, whose verbs count one by one.
  @Test(arguments: ["geh", "hielt", "fuhren", "eat", "xyzzyq"])
  func aReportFromTheResultsMatchesOneFromASearch(query: String) {
    let found = matches(query)
    let shown = results(query)
    #expect(shown.matchCount == found.count)
    #expect(shown.topKind == found.first?.kind)
  }

  // A word that is only ever a stranded part puts the folded row first, and the row stands
  // for its verbs' kind.
  @Test func aFoldedRowOnTopReportsItsVerbsKind() throws {
    let map = ConjugationMap.bundled
    let part = try #require(map.entriesByConjugation.keys.sorted().first { key in
      let entries = map.entries(for: key)
      return entries.count > 1 && entries.allSatisfy { $0.particle != nil } && !key.contains(" ")
    })
    let shown = results(part)
    guard case .separableVerbs = shown.entries.first else {
      Issue.record("Expected \(part) to put its folded row first")
      return
    }
    #expect(shown.topKind == .finitePart)
    #expect(shown.topKind == matches(part).first?.kind)
  }

  @Test func openingTheGuessIsAnOpenWithNoResults() {
    let report = SearchReport.openedGuess(query: "gehn", source: .control)
    #expect(report.parameters == [
      "source": "control",
      "outcome": "opened",
      "queryLength": "3-5",
      "resultCount": "0",
      "matchKind": "guess",
      "resultPosition": "1"
    ])
  }

  // The privacy policy promises that nothing typed is sent. Every value must come from a fixed
  // vocabulary or a band, so none can echo the query.
  @Test(arguments: ["gehen", "es", "1", "10+", "opened", "Schmiesing"])
  func noParameterValueEchoesTheQuery(query: String) {
    let vocabulary = Set(
      SearchOutcome.allCases.map(\.rawValue)
        + SearchMatchKind.allCases.map(\.rawValue)
        + AnalyticsSource.allCases.map(\.rawValue)
        + ["1-2", "3-5", "6-9", "10+", "0", "1", "2-10", "11+", "2-5", "6+", "none"]
    )
    let found = matches(query)
    let reports = [
      SearchReport.ended(query: query, results: results(query)),
      SearchReport.opened(query: query, resultCount: found.count, kind: found.first?.kind ?? .glossSubstring, position: 0),
      SearchReport.openedGuess(query: query)
    ]
    for report in reports {
      #expect(Set(report.parameters.values).isSubset(of: vocabulary))
    }
  }
}
