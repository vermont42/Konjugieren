// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
@Suite("Verb search")
struct VerbSearchTests {
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

  @Test func searchFindsTheGlossOfASecondReading() throws {
    let fahren = try #require(Verb.verbs["fahren"])
    #expect(!fahren.translation.contains("travel"), "the guard is meaningless if the primary gloss matches")
    #expect(fahren.anyTranslationContains("travel"))
    #expect(fahren.anyTranslationContains("TRAVEL"))
    #expect(VerbEntityQuery.verbs(matching: "travel").contains { $0.infinitiv == "fahren" })
  }
}
