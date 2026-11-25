// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Observation

/// The verb list's search: what is typed, what it found, the guess when it found nothing, the
/// hardware keyboard's selection, and the `finishSearch` reports. The view keeps the field's
/// focus and the navigation.
@Observable
final class VerbSearchModel {
  /// The field's text, as typed. Every change, whether typed, inserted from the letter row, or
  /// requested by another surface, goes through `textChanged`.
  var text = "" {
    didSet {
      if text != oldValue {
        textChanged()
      }
    }
  }

  var includeGlosses: Bool {
    didSet {
      if includeGlosses != oldValue {
        refreshResults(hadFailed: hasFailed)
      }
    }
  }

  /// The text trimmed, which is what is searched.
  private(set) var query = ""
  private(set) var results = VerbSearchResults.empty

  /// Nil until the guess arrives, and when no verb is near enough to guess.
  private(set) var guess: VerbSearchResults.Hit?

  var keyboardSelection: Int?
  private(set) var separableVerbsAreShown = false

  @ObservationIgnored private var tracker = SearchTracker()
  @ObservationIgnored private(set) var guessTask: Task<Void, Never>?
  @ObservationIgnored private var guessCandidates: [VerbSearch.GuessCandidate]?
  @ObservationIgnored private let analytics: Analytics
  @ObservationIgnored private let soundPlayer: SoundPlayer

  init(includeGlosses: Bool, analytics: Analytics = Current.analytics, soundPlayer: SoundPlayer = Current.soundPlayer) {
    self.includeGlosses = includeGlosses
    self.analytics = analytics
    self.soundPlayer = soundPlayer
  }

  var isSearching: Bool {
    !query.isEmpty
  }

  /// Nothing matched. The guess, if there is one, arrives later.
  var hasFailed: Bool {
    isSearching && results.isEmpty
  }

  /// The rows as shown, with the folded row's verbs after it when it is open.
  var entries: [VerbSearchResults.Entry] {
    results.entries(separableVerbsAreShown: separableVerbsAreShown)
  }

  /// The rows that Return and the arrow keys move through: the entries, or the guess when
  /// nothing matched.
  var keyboardTargetCount: Int {
    hasFailed ? (guess == nil ? 0 : 1) : entries.count
  }

  func moveKeyboardSelection(by offset: Int, count: Int) {
    keyboardSelection = Self.keyboardSelection(after: keyboardSelection, moving: offset, count: count)
  }

  /// The first arrow press lands on the first result, and the selection stops at either end
  /// rather than wrapping.
  nonisolated static func keyboardSelection(after current: Int?, moving offset: Int, count: Int) -> Int? {
    guard count > 0 else {
      return nil
    }
    guard let current else {
      return offset > 0 ? 0 : nil
    }
    return min(max(current + offset, 0), count - 1)
  }

  func toggleSeparableVerbs() {
    separableVerbsAreShown.toggle()
  }

  /// Ends the search, reporting which result was opened, and says where it leads.
  func open(_ hit: VerbSearchResults.Hit, at position: Int) -> VerbDestination {
    if let search = tracker.finish(), let kind = hit.kind {
      signal(.opened(query: search.query, resultCount: results.matchCount, kind: kind, position: position, source: search.source))
    }
    return VerbDestination(verb: hit.verb, source: .search, marks: hit.conjugation?.marks(on: hit.verb))
  }

  /// Nil while the guess is still being found, or when there is none.
  func openGuess() -> VerbDestination? {
    guard let guess else {
      return nil
    }
    if let search = tracker.finish() {
      signal(.openedGuess(query: search.query, source: search.source))
    }
    return VerbDestination(verb: guess.verb, source: .searchGuess, marks: guess.conjugation?.marks(on: guess.verb))
  }

  /// Another surface put text in the field, so the search that follows is that surface's. A
  /// search in progress ends here, because its text is about to be replaced.
  func request(text: String, source: AnalyticsSource) {
    if let ended = tracker.fieldOpened(from: source) {
      signalEnded(ended)
    }
    self.text = text
    // An unchanged text sets off no didSet, and the request still begins a search.
    _ = tracker.textChanged(to: text)
  }

  /// The field closed. A surface that opened it with nothing typed began no search.
  func fieldClosed() {
    tracker.fieldClosed()
  }

  /// The app left the foreground, which ends a search in progress.
  func appLeftForeground() {
    if let ended = tracker.finish() {
      signalEnded(ended)
    }
  }

  private func textChanged() {
    keyboardSelection = nil
    separableVerbsAreShown = false
    // A search ended by clearing the field is reported with the results it showed, which are
    // still these.
    if let ended = tracker.textChanged(to: text) {
      signalEnded(ended)
    }
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed != query else {
      return
    }
    let hadFailed = hasFailed
    query = trimmed
    refreshResults(hadFailed: hadFailed)
  }

  /// The results come at once, because an ordinary search is cheap. The guess measures edit
  /// distance against every conjugation of about the query's length, which took most of a
  /// second on the main actor, so it comes from a task that the next change cancels. The sad
  /// trombone plays once as a search begins to fail, not again for each letter it fails on.
  private func refreshResults(hadFailed: Bool) {
    guessTask?.cancel()
    guessTask = nil
    guess = nil
    results = isSearching ? VerbSearchResults(query: query, verbs: Verb.verbsSortedByFrequency, includeGlosses: includeGlosses, includesGuess: false) : .empty
    guard hasFailed else {
      return
    }
    if !hadFailed {
      soundPlayer.play(.randomSadTrombone)
    }
    startGuess()
  }

  private func startGuess() {
    let query = self.query
    let candidates = guessCandidates ?? VerbSearch.guessCandidates(of: Verb.verbsSortedByFrequency)
    guessCandidates = candidates
    guessTask = Task {
      let finding = await Self.guess(for: query, among: candidates)
      guard !Task.isCancelled, let finding, let verb = Verb.verbs[finding.infinitiv] else {
        return
      }
      guess = VerbSearchResults.hit(for: VerbSearch.Guess(verb: verb, conjugation: finding.conjugation))
    }
  }

  @concurrent
  private nonisolated static func guess(for query: String, among candidates: [VerbSearch.GuessCandidate]) async -> VerbSearch.GuessFinding? {
    VerbSearch.guess(for: query, among: candidates)
  }

  private func signalEnded(_ search: SearchTracker.Search) {
    signal(.ended(query: search.query, results: results, source: search.source))
  }

  private func signal(_ report: SearchReport) {
    analytics.signal(name: .finishSearch, parameters: report.parameters)
  }
}
