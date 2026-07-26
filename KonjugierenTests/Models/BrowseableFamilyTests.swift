// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("BrowseableFamily")
struct BrowseableFamilyTests {
  // The defect this suite exists to pin: verbsByPrefix bucketed verbs into a hand-curated
  // prefix list and silently dropped anything else, while verbCount kept counting the
  // dropped verbs. The Separable card said 2,035 and its own detail screen listed 1,245.
  // Curation cannot close this: German's separable slot is open class, taking adjectives
  // (tot-, frei-) and nouns (heim-) as well as particles, so the fix was a catch-all
  // section rather than a longer list, and this test is what proves the catch-all is total.
  @Test(arguments: [BrowseableFamily.separable, BrowseableFamily.inseparable])
  func prefixSectionsAccountForEveryVerb(family: BrowseableFamily) {
    let listed = family.verbsByPrefix.reduce(0) { $0 + $1.verbs.count }

    #expect(
      listed == family.verbCount,
      "\(family.rawValue): card shows \(family.verbCount) but sections list \(listed)"
    )
  }

  // The .other bucket is defined by exclusion, so an off-by-one in its predicate could
  // duplicate or drop verbs in ways that leave the total above unchanged.
  @Test(arguments: [BrowseableFamily.separable, BrowseableFamily.inseparable])
  func everyVerbAppearsInExactlyOneSection(family: BrowseableFamily) {
    let listed = family.verbsByPrefix.flatMap(\.verbs).map(\.infinitiv)
    let duplicated = Dictionary(grouping: listed, by: { $0 }).filter { $0.value.count > 1 }.keys
    // Report a sample of the difference rather than the sets themselves: these hold
    // thousands of infinitives, and #expect interpolates both sides on failure.
    let missing = Set(family.verbs.map(\.infinitiv)).subtracting(listed)

    #expect(duplicated.isEmpty, "\(family.rawValue): listed in more than one section: \(duplicated.sorted().prefix(10))")
    #expect(missing.isEmpty, "\(family.rawValue): \(missing.count) verbs in no section, e.g. \(missing.sorted().prefix(10))")
  }

  // pieMeaning builds its catalog key by dropping the prefix's trailing hyphen, and
  // String(localized:) hands back the key itself when it misses. An entry added without
  // its catalog key therefore renders a literal "PIEMeaning.durch" in the UI, visible
  // only to someone who opens that exact section.
  // The catch-all section's heading is the one user-facing string this feature added, and it
  // sits below 2,035 rows on the Separable screen. Nobody is going to scroll there to notice
  // it rendering as its own key, and the simulator's AXTree collapses on a list that long, so
  // this assertion is the only practical guard.
  @Test func otherPrefixesHeadingIsLocalized() {
    #expect(L.FamilyDetail.otherPrefixesHeading != "FamilyDetail.otherPrefixesHeading")
  }

  @Test func everyPrefixMeaningResolvesItsPIEKey() {
    for meaning in PrefixMeaning.separablePrefixes + PrefixMeaning.inseparablePrefixes {
      #expect(
        meaning.pieMeaning != "PIEMeaning.\(meaning.prefix.dropLast())",
        "\(meaning.prefix) has no PIEMeaning key in Localizable.xcstrings"
      )
    }
  }
}
