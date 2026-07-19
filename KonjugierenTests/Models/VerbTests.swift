// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
@Suite("Verb")
struct VerbTests {
  @Test func stammDropsEnSuffix() {
    #expect(Verb.verbs["machen"]?.stamm == "mach")
    #expect(Verb.verbs["singen"]?.stamm == "sing")
  }

  @Test func stammKeepsSeparablePrefix() {
    #expect(Verb.verbs["ankommen"]?.stamm == "ankomm")
  }

  @Test func stammDropsSingleCharacterForNonEnSuffix() {
    // "ändern" ends in "rn", not "en", so stamm drops only the trailing "n".
    #expect(Verb.verbs["ändern"]?.stamm == "änder")
  }

  @Test(arguments: ["machen", "ändern", "segeln", "tun", "sein"])
  func endingIsValidForRecognizedSuffixes(infinitiv: String) {
    #expect(Verb.endingIsValid(infinitiv: infinitiv))
  }

  @Test(arguments: ["xyzzy", "blorf", "auto", "haus"])
  func endingIsInvalidForUnrecognizedSuffixes(infinitiv: String) {
    #expect(!Verb.endingIsValid(infinitiv: infinitiv))
  }

  @Test func frequencyIsADenseRankOverTheWholeCorpus() {
    let ranks = Verb.verbs.values.map(\.frequency).sorted()
    #expect(ranks == Array(1...Verb.verbs.count))
  }

  @Test func moreHitsMeansALowerFrequencyRank() {
    // The direction that has no other guard. Every call site sorts frequency ascending
    // to mean most-common-first, so a rank derived from hits ascending would invert the
    // browse list and make each family screen showcase its three rarest verbs.
    for (moreCommon, lessCommon) in zip(Verb.verbsSortedByFrequency, Verb.verbsSortedByFrequency.dropFirst()) {
      #expect(moreCommon.hits > lessCommon.hits, "\(moreCommon.infinitiv) outranks \(lessCommon.infinitiv) but has fewer hits")
    }
  }

  @Test func everyShippingHitCountIsMeasuredNotProvisional() {
    // Documents the state the `hp` attribute was introduced in, on 2026-07-19: all 990 counts
    // come from DWDS. A tranche imported while bulk querying is blocked will make this fail,
    // which is the point — updating it should be a deliberate act, not a silent drift. Replace
    // the expectation with the tranche's size and say where the estimates came from.
    let provisional = Verb.verbs.values.filter(\.hitsAreProvisional).map(\.infinitiv).sorted()
    #expect(provisional.isEmpty, "provisional hit counts: \(provisional)")
  }

  @Test func theMostFrequentVerbIsRankedFirst() {
    let mostHits = Verb.verbs.values.max { $0.hits < $1.hits }
    #expect(mostHits?.frequency == 1)
    #expect(Verb.verbsSortedByFrequency.first?.infinitiv == mostHits?.infinitiv)
  }
}
