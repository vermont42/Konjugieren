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

  @Test func onlyTheStrongBasesTrancheHasProvisionalHitCounts() {
    // The `hp` attribute shipped on 2026-07-19 with no verb carrying it: all 990 counts came
    // from DWDS. The strong-bases tranche (docs/roadmap.md step 7) added 78 verbs while bulk
    // querying was still blocked pending BBAW, so each of those carries an editorial estimate
    // placed between the real counts of comparable shipping verbs — see the header of
    // verbdata/import_tranche1.py. When permission arrives, re-query with probes, replace the
    // counts, drop `hp`, and this expectation goes back to zero.
    //
    // Pinning the exact number, not merely an upper bound, is the point: a later tranche that
    // ships estimates has to come here and say so.
    let provisional = Verb.verbs.values.filter(\.hitsAreProvisional).map(\.infinitiv).sorted()
    #expect(provisional.count == 78, "provisional hit counts: \(provisional)")
    #expect(Verb.verbs.count - provisional.count == 990, "measured hit counts drifted from the original corpus")
  }

  @Test func theMostFrequentVerbIsRankedFirst() {
    let mostHits = Verb.verbs.values.max { $0.hits < $1.hits }
    #expect(mostHits?.frequency == 1)
    #expect(Verb.verbsSortedByFrequency.first?.infinitiv == mostHits?.infinitiv)
  }
}
