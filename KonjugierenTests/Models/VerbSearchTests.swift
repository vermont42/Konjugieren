// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
@Suite("Verb search")
struct VerbSearchTests {
  private func results(_ query: String, in verbs: [Verb] = Verb.verbsSortedByFrequency, includeGlosses: Bool = true) -> [String] {
    VerbSearch.matches(for: query, in: verbs, includeGlosses: includeGlosses).map(\.verb.infinitiv)
  }

  // The rows of "What Search Returns" in docs/browse-and-verb-ideas.md that Phase 1 of
  // plans/browse-and-verb-implementation.md addresses, plus Josh's own example, "es".
  @Test(arguments: zip(
    ["konnen", "koennen", "können", "go", "to go", "eat", "essen", "es", "mussen", "Gehen", " gehen "],
    ["können", "können", "können", "gehen", "gehen", "essen", "essen", "essen", "müssen", "gehen", "gehen"]
  ))
  func queryFindsTheWantedVerbFirst(query: String, wanted: String) {
    #expect(results(query).first == wanted)
  }

  @Test func exactMatchLeadsInAlphabeticalOrderToo() {
    #expect(results("kommen", in: Verb.verbsSortedAlphabetically).first == "kommen")
  }

  @Test func germanPrefixMatchRanksAboveEnglishSubstringMatch() throws {
    let ranked = results("es")
    let essen = try #require(ranked.firstIndex(of: "essen"))
    let ruhen = try #require(ranked.firstIndex(of: "ruhen"), "ruhen should match through its gloss, rest")
    #expect(essen < ruhen)
  }

  @Test func wholeWordGlossRanksAboveGermanSubstring() throws {
    let ranked = results("eat")
    let essen = try #require(ranked.firstIndex(of: "essen"))
    let beatmen = try #require(ranked.firstIndex(of: "beatmen"))
    #expect(essen < beatmen)
  }

  @Test func exactFoldedMatchFollowsExactMatch() {
    #expect(Array(results("zahlen").prefix(2)) == ["zahlen", "zählen"])
  }

  // "zahl" spells the zahlen family literally and the zählen family only after folding.
  @Test func unfoldedMatchesRankAboveFoldedOnes() throws {
    let ranked = results("zahl")
    let lastLiteral = try #require(ranked.lastIndex { $0.contains("zahl") })
    let firstFolded = try #require(ranked.firstIndex { $0.contains("zähl") })
    #expect(lastLiteral < firstFolded)
  }

  @Test func sharpSAndSSFindEachOther() {
    #expect(results("schliessen").first == "schließen")
    #expect(results("weiss").contains("weißen"))
  }

  // The ß/ss rule once made schließen a match for essen ahead of essen itself.
  @Test func ssFoldingDoesNotDisplaceALiteralMatch() throws {
    let ranked = results("essen")
    let vergessen = try #require(ranked.firstIndex(of: "vergessen"))
    let schließen = try #require(ranked.firstIndex(of: "schließen"))
    #expect(vergessen < schließen)
  }

  @Test func infinitiveOnlyScopeIgnoresGlosses() {
    #expect(!results("eat", includeGlosses: false).contains("essen"))
    #expect(results("eat", includeGlosses: false) == ["beatmen"])
  }

  @Test func blankQueryMatchesNothing() {
    #expect(results("   ").isEmpty)
  }

  @Test(arguments: zip(
    ["Können", "koennen", "konnen", "schließen", "SCHLIEẞEN", "Füße", "gehen"],
    ["konnen", "konnen", "konnen", "schliessen", "schliessen", "fusse", "gehen"]
  ))
  func foldCollapsesUmlautsDigraphsAndSharpS(text: String, folded: String) {
    #expect(VerbSearch.fold(text) == folded)
  }

  @Test(arguments: [
    ("eat", "eat (of animals)", true),
    ("eat", "beat, create", false),
    ("eat", "threaten", false),
    ("go out", "go out, assume", true),
    ("go", "forgo", false),
    ("come", "come off, come loose", true),
  ])
  func wholeWordMatchNeedsNonLettersAround(word: String, text: String, expected: Bool) {
    #expect(VerbSearch.containsWholeWord(word, in: text) == expected)
  }

  @Test(arguments: zip(["to go", "To Go", "to", "go", "to  go"], ["go", "go", "to", "go", "go"]))
  func glossQueryDropsALeadingTo(query: String, expected: String) {
    #expect(VerbSearch.glossQuery(from: query) == expected)
  }

  // Seven of the fifty most frequent verbs, each of which the shortcut picker left out of its
  // own results until 2026-11-10, because it cut the alphabetical list at 25 before ranking.
  @Test(arguments: ["halten", "kommen", "machen", "setzen", "stehen", "stellen", "ziehen"])
  func shortcutQueryRanksTheExactInfinitiveFirst(infinitiv: String) {
    #expect(VerbEntityQuery.verbs(matching: infinitiv).first?.infinitiv == infinitiv)
  }

  @Test func shortcutQueryRanksPrefixMatchesBeforeOtherMatches() {
    let results = VerbEntityQuery.verbs(matching: "komm")
    let firstNonPrefix = results.firstIndex { !$0.infinitiv.hasPrefix("komm") } ?? results.endIndex
    #expect(results[firstNonPrefix...].allSatisfy { !$0.infinitiv.hasPrefix("komm") })
    #expect(results.count == VerbEntityQuery.matchLimit)
  }

  @Test(arguments: ["konnen", "eat", "es", "to go"])
  func shortcutPickerAndListAgree(query: String) {
    let picker = VerbEntityQuery.verbs(matching: query).map(\.infinitiv)
    #expect(picker == Array(results(query).prefix(VerbEntityQuery.matchLimit)))
  }

  @Test func searchFindsTheGlossOfASecondReading() throws {
    let fahren = try #require(Verb.verbs["fahren"])
    #expect(!fahren.translation.contains("travel"), "the guard is meaningless if the primary gloss matches")
    #expect(results("TRAVEL").contains("fahren"))
    #expect(VerbEntityQuery.verbs(matching: "travel").contains { $0.infinitiv == "fahren" })
  }

  // A4 in docs/browse-and-verb-ideas.md: a failed search offers the nearest verb as a guess.
  @Test(arguments: zip(
    ["gehn", "gheen", "konen", "machn", "sprechn", "Schwimen"],
    ["gehen", "gehen", "können", "machen", "sprechen", "schwimmen"]
  ))
  func closestVerbGuessesTheMisspelledVerb(query: String, wanted: String) {
    #expect(VerbSearch.closestVerb(to: query, in: Verb.verbsSortedAlphabetically)?.infinitiv == wanted)
  }

  @Test(arguments: ["xyzzyq", "qqqq", "   "])
  func closestVerbOffersNoGuessForNonsense(query: String) {
    #expect(VerbSearch.closestVerb(to: query, in: Verb.verbsSortedByFrequency) == nil)
  }

  @Test(arguments: [
    ("gehen", "gehen", 0),
    ("gehn", "gehen", 1),
    ("gheen", "gehen", 1),
    ("kitten", "sitting", 3),
    ("", "abc", 3),
    ("abc", "", 3),
  ])
  func editDistanceCountsASwapAsOneEdit(lhs: String, rhs: String, expected: Int) {
    #expect(VerbSearch.editDistance(Array(lhs), Array(rhs)) == expected)
  }

  @Test(arguments: zip([1, 4, 6, 9, 20], [1, 1, 2, 3, 3]))
  func guessDistanceGrowsWithTheQueryAndIsCapped(length: Int, expected: Int) {
    #expect(VerbSearch.maxGuessDistance(forQueryLength: length) == expected)
  }
}
