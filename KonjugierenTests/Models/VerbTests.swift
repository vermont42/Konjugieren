// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("Verb")
struct VerbTests {
  // Nothing checked this until 2026-07-19, and the strong-bases tranche shipped 14 verbs out
  // of order because of it: the import script inserted back-to-front without accounting for
  // repeated insert() at one index reversing the batch, so verbs sharing an anchor came out
  // as glimmen before gleiten. Verb.verbs is a dictionary, so file order survives nowhere in
  // the parsed model — the raw XML is the only place this can be checked.
  @Test func verbsXMLIsAlphabeticallyOrdered() throws {
    let url = try #require(Bundle(for: VerbParser.self).url(forResource: "Verbs", withExtension: "xml"))
    let text = try String(contentsOf: url, encoding: .utf8)

    let pattern = try NSRegularExpression(pattern: "<verb in=\"([^\"]+)\"")
    let range = NSRange(text.startIndex..., in: text)
    let keys = pattern.matches(in: text, range: range).compactMap { match -> String? in
      guard let matched = Range(match.range(at: 1), in: text) else { return nil }
      // The documented collation: prefix and ablaut markers ignored, umlauts folded to their
      // base vowel, sharp s left where its code point falls. See docs/adding-verbs.md.
      var folded = String(text[matched]).replacingOccurrences(of: "[+*^]", with: "", options: .regularExpression).lowercased()
      for (umlaut, base) in [("ä", "a"), ("ö", "o"), ("ü", "u")] {
        folded = folded.replacingOccurrences(of: umlaut, with: base)
      }
      return folded
    }

    #expect(keys.count == Verb.verbs.count)
    // Non-decreasing rather than strictly sorted: folding makes drücken/drucken and
    // zählen/zahlen tie, and the file breaks those ties the opposite way from a naive sort.
    for (earlier, later) in zip(keys, keys.dropFirst()) {
      #expect(earlier <= later, "Verbs.xml is out of order: \(earlier) precedes \(later)")
    }
  }
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

  @Test func onlyImportedTranchesHaveProvisionalHitCounts() {
    // The `hp` attribute shipped on 2026-07-19 with no verb carrying it: all 990 counts came
    // from DWDS. Two tranches have since been imported while bulk querying was still blocked
    // pending BBAW — 78 strong bases (roadmap step 7) and 2,303 prefixed derivatives (step 8)
    // — so 2,381 verbs carry an estimate rather than a measurement. The two tranches were
    // estimated by different rules, both documented: verbdata/import_tranche1.py placed each
    // count by hand between comparable shipping verbs, and verbdata/import_tranche2.py
    // derives each from its base by a ratio measured off the corpus's own real counts.
    //
    // When permission arrives, re-query with probes, replace the counts, drop `hp`, and this
    // expectation goes back to zero. Pinning the exact numbers, not merely an upper bound, is
    // the point: a later tranche that ships estimates has to come here and say so.
    let provisional = Verb.verbs.values.filter(\.hitsAreProvisional).count
    #expect(provisional == 78 + 2303)
    #expect(Verb.verbs.count - provisional == 990, "measured hit counts drifted from the original corpus")
  }

  @Test func theMostFrequentVerbIsRankedFirst() {
    let mostHits = Verb.verbs.values.max { $0.hits < $1.hits }
    #expect(mostHits?.frequency == 1)
    #expect(Verb.verbsSortedByFrequency.first?.infinitiv == mostHits?.infinitiv)
  }
}
