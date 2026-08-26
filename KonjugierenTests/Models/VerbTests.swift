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
  // the parsed model; the raw XML is the only place this can be checked.
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
    //
    // The comparison is `>=` rather than `>` because ties are real. Until 2026-08-26 the
    // corpus had none, and a strict `>` passed; the corpus-wide DWDS fetch that day gave
    // 96 verbs a count some other verb also has. Measured counts collide because the
    // corpus is finite, so this will keep happening, and tightening this back to `>`
    // would be asserting an accident of the data rather than the property under test.
    // The tiebreak that makes the order total is checked separately below.
    for (moreCommon, lessCommon) in zip(Verb.verbsSortedByFrequency, Verb.verbsSortedByFrequency.dropFirst()) {
      #expect(moreCommon.hits >= lessCommon.hits, "\(moreCommon.infinitiv) outranks \(lessCommon.infinitiv) but has fewer hits")
    }
  }

  @Test func tiedHitCountsBreakOnTheInfinitive() {
    // Without a tiebreak, two verbs with equal hits would order by whatever `Dictionary`
    // iteration produced that launch, so a verb's displayed rank could differ between
    // runs of the same build. `VerbParser.ranked` sorts equal counts by infinitive; this
    // is the only place that promise is checked.
    for (moreCommon, lessCommon) in zip(Verb.verbsSortedByFrequency, Verb.verbsSortedByFrequency.dropFirst())
    where moreCommon.hits == lessCommon.hits {
      #expect(
        moreCommon.infinitiv < lessCommon.infinitiv,
        "\(moreCommon.infinitiv) and \(lessCommon.infinitiv) tie at \(moreCommon.hits) but are not in infinitive order"
      )
    }
  }

  @Test func onlyUnmeasurableVerbsHaveProvisionalHitCounts() {
    // `hp` shipped on 2026-07-19 with no verb carrying it, then rose to 2,582 across three
    // tranches imported while bulk DWDS querying was blocked pending BBAW. Permission
    // arrived 2026-08-26, the whole corpus was re-fetched, and 2,499 of those estimates
    // became measurements. The 83 that remain are not leftovers of the import: they are the
    // verbs DWDS cannot measure, and re-running the fetch will not shrink the number.
    //
    // What happens to them is worth knowing before someone tries. DWDS has no lemma entry
    // for these compounds, so rather than failing it echoes the query string back
    // capitalized and reports that *string's* raw count: starkmachen comes back as
    // `Starkmachen`, hits 10,015. That figure is a form count where every other verb in the
    // corpus carries a lemma total across all inflections, so adopting it would rank
    // starkmachen against a different unit than its neighbours. An editorial estimate is
    // the better value precisely because it does not look measured. Probing inflected forms
    // does not help: `starkgemacht` comes back as `starkgemacht`.
    //
    // So this expectation does not go to zero, and a drop below 83 means someone found a
    // probe that works, which is a real result worth writing down here. A rise means a new
    // tranche shipped estimates, which is also worth saying out loud. Both are why the
    // number is pinned rather than bounded.
    let provisional = Verb.verbs.values.filter(\.hitsAreProvisional).count
    #expect(provisional == 83)
    #expect(Verb.verbs.count - provisional == 3489, "measured hit counts drifted from the 2026-08-26 fetch")
  }

  @Test func theMostFrequentVerbIsRankedFirst() {
    let mostHits = Verb.verbs.values.max { $0.hits < $1.hits }
    #expect(mostHits?.frequency == 1)
    #expect(Verb.verbsSortedByFrequency.first?.infinitiv == mostHits?.infinitiv)
  }
}
