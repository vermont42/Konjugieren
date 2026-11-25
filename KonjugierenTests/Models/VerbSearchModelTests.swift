// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import Testing

@MainActor
@Suite("Verb search model")
struct VerbSearchModelTests {
  private final class SoundPlayerSpy: SoundPlayer {
    private(set) var playCount = 0

    func setup() {}

    func play(_ sound: Sound, shouldDebounce: Bool, volume: Float) {
      playCount += 1
    }

    func startMusic() {}
    func stopMusic() {}
  }

  private let analytics = AnalyticsSpy()
  private let soundPlayer = SoundPlayerSpy()

  private func model(includeGlosses: Bool = true) -> VerbSearchModel {
    VerbSearchModel(includeGlosses: includeGlosses, analytics: analytics, soundPlayer: soundPlayer)
  }

  private func shown(_ query: String) -> VerbSearchResults {
    VerbSearchResults(query: query, verbs: Verb.verbsSortedByFrequency, includeGlosses: true, includesGuess: false)
  }

  private func firstHit(of search: VerbSearchModel) throws -> VerbSearchResults.Hit {
    try #require(search.entries.first?.hit)
  }

  @Test func typingShowsResultsAndReportsNothing() {
    let search = model()
    for text in ["g", "ge", "geh"] {
      search.text = text
    }
    #expect(search.query == "geh")
    #expect(search.results.matchCount == shown("geh").matchCount)
    #expect(search.guessTask == nil)
    #expect(analytics.signalNames.isEmpty)
    #expect(soundPlayer.playCount == 0)
  }

  @Test func whitespaceIsNoSearch() {
    let search = model()
    search.text = "  "
    #expect(!search.isSearching)
    #expect(search.results.isEmpty)
    #expect(!search.hasFailed)
  }

  @Test func clearingReportsTheSearchWithTheResultsItShowed() {
    let search = model()
    search.text = "geh"
    search.text = ""
    #expect(!search.isSearching)
    #expect(search.results.isEmpty)
    #expect(analytics.signalNames == [.finishSearch])
    #expect(analytics.signalParameters == [SearchReport.ended(query: "geh", results: shown("geh")).parameters])
  }

  @Test func clearingAFailedSearchReportsNoResult() {
    let search = model()
    search.text = "xyzzyq"
    search.text = ""
    #expect(analytics.signalParameters.first?["outcome"] == SearchOutcome.noResult.rawValue)
  }

  @Test func aFailedSearchShowsNoVerbsAtOnceAndItsGuessLater() async throws {
    let search = model()
    search.text = "ginng"
    #expect(search.hasFailed)
    #expect(search.guess == nil)
    #expect(search.keyboardTargetCount == 0)
    let pending = try #require(search.guessTask)
    await pending.value
    let guess = try #require(search.guess)
    #expect(guess.verb.infinitiv == "gehen")
    #expect(guess.conjugation?.text == "ging")
    #expect(guess.conjugation?.conjugationgroups.isEmpty == false)
    #expect(search.keyboardTargetCount == 1)
  }

  @Test func nonsenseGetsNoGuess() async throws {
    let search = model()
    search.text = "xyzzyq"
    try await #require(search.guessTask).value
    #expect(search.guess == nil)
  }

  // ginn finds beginnen, so a stale guess for ginng would show beside results it does not
  // belong to.
  @Test func theNextLetterCancelsAGuessInFlight() async throws {
    let search = model()
    search.text = "ginng"
    let pending = try #require(search.guessTask)
    search.text = "ginn"
    #expect(pending.isCancelled)
    await pending.value
    #expect(search.guess == nil)
    #expect(!search.hasFailed)
    #expect(search.guessTask == nil)
  }

  @Test func aFailingSearchGuessesAgainForItsNewText() async throws {
    let search = model()
    search.text = "gehnx"
    let first = try #require(search.guessTask)
    search.text = "gehn"
    #expect(first.isCancelled)
    try await #require(search.guessTask).value
    #expect(search.guess?.verb.infinitiv == "gehen")
  }

  @Test func theTromboneSoundsOncePerFailedSearch() {
    let search = model()
    search.text = "geh"
    #expect(soundPlayer.playCount == 0)
    search.text = "xyzzy"
    search.text = "xyzzyq"
    #expect(soundPlayer.playCount == 1)
    search.text = ""
    search.text = "xyzzyq"
    #expect(soundPlayer.playCount == 2)
  }

  @Test func openingAResultReportsWhichAndWhere() throws {
    let search = model()
    search.text = "geh"
    let hit = try firstHit(of: search)
    let destination = search.open(hit, at: 0)
    #expect(destination.verb.infinitiv == "gehen")
    #expect(destination.source == .search)
    let kind = try #require(hit.kind)
    #expect(analytics.signalParameters == [
      SearchReport.opened(query: "geh", resultCount: shown("geh").matchCount, kind: kind, position: 0).parameters
    ])
  }

  @Test func aSearchEndedByAnOpenIsNotReportedAgainWhenCleared() throws {
    let search = model()
    search.text = "geh"
    _ = search.open(try firstHit(of: search), at: 0)
    search.text = ""
    #expect(analytics.signalNames.count == 1)
  }

  @Test func openingTheGuessReportsAGuess() async throws {
    let search = model()
    search.text = "ginng"
    #expect(search.openGuess() == nil)
    try await #require(search.guessTask).value
    let destination = try #require(search.openGuess())
    #expect(destination.verb.infinitiv == "gehen")
    #expect(destination.source == .searchGuess)
    #expect(destination.marks != nil)
    #expect(analytics.signalParameters == [SearchReport.openedGuess(query: "ginng").parameters])
  }

  @Test func editingClearsTheSelectionAndClosesTheFoldedRow() {
    let search = model()
    search.text = "hielt"
    search.toggleSeparableVerbs()
    search.moveKeyboardSelection(by: 1, count: search.keyboardTargetCount)
    #expect(search.separableVerbsAreShown)
    #expect(search.keyboardSelection == 0)
    search.text = "hielte"
    #expect(!search.separableVerbsAreShown)
    #expect(search.keyboardSelection == nil)
  }

  @Test func anOpenFoldedRowAddsItsVerbsToTheRows() {
    let search = model()
    search.text = "hielt"
    let closed = search.entries.count
    search.toggleSeparableVerbs()
    #expect(search.entries.count > closed)
    #expect(search.keyboardTargetCount == search.entries.count)
  }

  @Test func aRequestBeginsASearchOfTheSurfaceThatSentIt() throws {
    let search = model()
    search.request(text: "geh", source: .control)
    _ = search.open(try firstHit(of: search), at: 0)
    #expect(analytics.signalParameters.first?["source"] == AnalyticsSource.control.rawValue)
  }

  @Test func aRequestForTheSameTextEndsTheOldSearchAndBeginsAnother() {
    let search = model()
    search.text = "geh"
    search.request(text: "geh", source: .control)
    #expect(analytics.signalParameters.first?["source"] == AnalyticsSource.tab.rawValue)
    search.appLeftForeground()
    #expect(analytics.signalParameters.dropFirst().first?["source"] == AnalyticsSource.control.rawValue)
  }

  @Test func leavingTheForegroundEndsTheSearch() {
    let search = model()
    search.text = "geh"
    search.appLeftForeground()
    #expect(analytics.signalParameters == [SearchReport.ended(query: "geh", results: shown("geh")).parameters])
    search.appLeftForeground()
    #expect(analytics.signalNames.count == 1)
  }

  @Test func changingTheScopeSearchesAgain() {
    let search = model(includeGlosses: false)
    search.text = "eat"
    #expect(search.entries.first?.hit?.verb.infinitiv != "essen")
    search.includeGlosses = true
    #expect(search.entries.first?.hit?.verb.infinitiv == "essen")
  }
}
