// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

@MainActor
@Suite("Verb search")
struct VerbSearchTests {
  private func results(_ query: String, in verbs: [Verb] = Verb.verbsSortedByFrequency, includeGlosses: Bool = true) -> [String] {
    VerbSearch.matches(for: query, in: verbs, includeGlosses: includeGlosses).map(\.verb.infinitiv)
  }

  // The rows of "What Search Returns" in docs/browse_and_verb_ideas.md whose query is an
  // infinitive or a gloss, plus Josh's own example, "es".
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

  // fuhren is wir fuhren of fahren, and führen only once folded. Josh, 2026-11-25: the literal
  // reading leads.
  @Test func literalConjugationOutranksFoldedInfinitive() throws {
    let found = VerbSearch.matches(for: "fuhren", in: Verb.verbsSortedByFrequency, includeGlosses: true)
    #expect(found.first?.verb.infinitiv == "fahren")
    #expect(found.first?.kind == .conjugation)
    let führen = try #require(found.firstIndex { $0.verb.infinitiv == "führen" })
    #expect(found[führen].kind == .exactFoldedInfinitive)
    #expect(found[..<führen].allSatisfy { $0.kind == .conjugation || $0.kind == .finitePart })
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
    #expect(Verb.SearchKeys.fold(text) == folded)
  }

  @Test(arguments: [
    ("eat", "eat (of animals)", true),
    ("eat", "beat, create", false),
    ("eat", "threaten", false),
    ("go out", "go out, assume", true),
    ("go", "forgo", false),
    ("come", "come off, come loose", true)
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

  @Test(arguments: zip(
    ["gehn", "gheen", "konen", "machn", "sprechn", "Schwimen"],
    ["gehen", "gehen", "können", "machen", "sprechen", "schwimmen"]
  ))
  func guessFindsTheMisspelledVerb(query: String, wanted: String) {
    let guess = VerbSearch.guess(for: query, in: Verb.verbsSortedAlphabetically)
    #expect(guess?.verb.infinitiv == wanted)
    #expect(guess?.conjugation == nil)
  }

  @Test(arguments: zip(["ginng", "gign", "stnad"], [("gehen", "ging"), ("gehen", "ging"), ("stehen", "stand")]))
  func guessFindsTheMisspelledConjugation(query: String, wanted: (infinitiv: String, conjugation: String)) {
    let guess = VerbSearch.guess(for: query, in: Verb.verbsSortedByFrequency)
    #expect(guess?.verb.infinitiv == wanted.infinitiv)
    #expect(guess?.conjugation == wanted.conjugation)
  }

  @Test(arguments: ["xyzzyq", "qqqq", "   "])
  func guessOffersNothingForNonsense(query: String) {
    #expect(VerbSearch.guess(for: query, in: Verb.verbsSortedByFrequency) == nil)
  }

  @Test(arguments: [
    ("gehen", "gehen", 0),
    ("gehn", "gehen", 1),
    ("gheen", "gehen", 1),
    ("kitten", "sitting", 3),
    ("", "abc", 3),
    ("abc", "", 3)
  ])
  func editDistanceCountsASwapAsOneEdit(lhs: String, rhs: String, expected: Int) {
    #expect(VerbSearch.editDistance(Array(lhs), Array(rhs)) == expected)
  }

  // A limit may only shorten the work: below it, the distance is exact, and above it, the answer
  // is one past it, which every caller reads as too far.
  @Test(arguments: [
    ("gehen", "gehen"),
    ("gheen", "gehen"),
    ("kitten", "sitting"),
    ("xyzzyq", "gehen"),
    ("abcdef", "badcfe"),
    ("", "abc"),
    ("abc", "")
  ])
  func aLimitedDistanceIsExactUpToTheLimit(lhs: String, rhs: String) {
    let distance = VerbSearch.editDistance(Array(lhs), Array(rhs))
    for limit in 0...4 {
      #expect(VerbSearch.editDistance(Array(lhs), Array(rhs), limit: limit) == min(distance, limit + 1))
    }
  }

  // The verb list cancels a guess when the text changes, and the guess stops rather than finish
  // for text no longer in the field.
  @Test func aCancelledGuessFindsNothing() async {
    let candidates = VerbSearch.guessCandidates(of: Verb.verbsSortedByFrequency)
    #expect(VerbSearch.guess(for: "ginng", among: candidates) != nil)
    let task = Task.detached { () -> VerbSearch.GuessFinding? in
      withUnsafeCurrentTask { $0?.cancel() }
      return VerbSearch.guess(for: "ginng", among: candidates)
    }
    #expect(await task.value == nil)
  }

  @Test(arguments: zip([1, 4, 6, 9, 20], [1, 1, 2, 3, 3]))
  func guessDistanceGrowsWithTheQueryAndIsCapped(length: Int, expected: Int) {
    #expect(VerbSearch.maxGuessDistance(forQueryLength: length) == expected)
  }

  // A verb made in a test shares its infinitive with a corpus verb but not its gloss. Keys
  // memoized by infinitive served it the corpus verb's gloss once the corpus had been searched.
  @Test func aVerbIsSearchedByItsOwnKeys() throws {
    #expect(results("go").first == "gehen")
    let real = try #require(Verb.verbs["gehen"])
    let reading = Reading(
      infinitiv: "gehen",
      translation: "wander",
      family: real.family,
      auxiliary: real.auxiliary,
      prefixes: [],
      auxiliaryIsRegional: false
    )
    let impostor = Verb(infinitiv: "gehen", hits: 0, hitsAreProvisional: false, frequency: 0, frequencyIcon: "", readings: [reading])
    #expect(results("wander", in: [impostor]) == ["gehen"])
    #expect(results("go", in: [impostor]).isEmpty)
  }

  // Folding was seven passes of replacingOccurrences, in this order, until it became one pass.
  // The order is the rule: ß before the digraphs, and the digraphs before the umlauts.
  @Test func foldMatchesItsOrderedReplacementsOnEveryInfinitiveAndConjugation() {
    func replaced(_ text: String) -> String {
      var folded = text.lowercased()
      for (from, to) in [("ß", "ss"), ("ae", "a"), ("oe", "o"), ("ue", "u"), ("ä", "a"), ("ö", "o"), ("ü", "u")] {
        folded = folded.replacingOccurrences(of: from, with: to)
      }
      return folded
    }
    let texts = Array(Verb.verbs.keys) + Array(ConjugationMap.bundled.entriesByConjugation.keys) + ["Aee", "äe", "Straße", "ÜE", "quaeoe"]
    let mismatches = texts.filter { Verb.SearchKeys.fold($0) != replaced($0) }
    #expect(texts.count > 50_000)
    #expect(mismatches.isEmpty, "\(mismatches.prefix(5))")
  }
}
