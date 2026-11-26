// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

@MainActor
@Suite("RelatedVerbs")
struct RelatedVerbsTests {
  private func related(_ infinitiv: String, readingIndex: Int = 0) throws -> RelatedVerbs {
    try #require(Verb.verbs[infinitiv]).related(readingIndex: readingIndex)
  }

  @Test(arguments: [
    ("aufstehen", "stehen"),
    ("stehen", "stehen"),
    ("verstehen", "stehen"),
    ("anerkennen", "kennen"),
    ("beginnen", "ginnen"),
    ("machen", "machen")
  ])
  func root(infinitiv: String, expected: String) throws {
    #expect(try #require(Verb.verbs[infinitiv]).root == expected)
  }

  @Test func baseVerbComesFirstAndThePageItselfIsLeftOut() throws {
    let builtOn = try related("aufstehen").builtOnRoot.map(\.infinitiv)

    #expect(builtOn.first == "stehen")
    #expect(!builtOn.contains("aufstehen"))
    #expect(builtOn.contains("verstehen"))
    #expect(builtOn.contains("bestehen"))
  }

  @Test func derivativesFollowTheBaseByFrequency() throws {
    let derivatives = try related("aufstehen").builtOnRoot.dropFirst()

    #expect(zip(derivatives, derivatives.dropFirst()).allSatisfy { $0.frequency < $1.frequency })
  }

  @Test func baseVerbPageListsItsDerivatives() throws {
    let builtOn = try related("stehen").builtOnRoot.map(\.infinitiv)

    #expect(!builtOn.contains("stehen"))
    #expect(builtOn.contains("aufstehen"))
    #expect(builtOn.count == Verb.verbsByRoot["stehen"].map { $0.count - 1 })
  }

  // anerkennen's own base is erkennen, so stopping after one prefix would separate it from
  // kennen, bekennen, and the rest.
  @Test func nestedDerivativeJoinsTheRootsFamily() throws {
    let builtOn = try related("anerkennen").builtOnRoot.map(\.infinitiv)

    #expect(builtOn.first == "kennen")
    #expect(builtOn.contains("erkennen"))
    #expect(builtOn.contains("bekennen"))
  }

  @Test func rootOutsideTheCorpusGivesNoBaseVerb() throws {
    let related = try related("beginnen")

    #expect(Verb.verbs[related.root] == nil)
    #expect(!related.builtOnRoot.contains { $0.infinitiv == "beginnen" })
  }

  @Test func ablautRelativesAreOtherBasesNotDerivatives() throws {
    let relatives = try related("singen").ablautRelatives.map(\.infinitiv)

    #expect(relatives.contains("trinken"))
    #expect(relatives.contains("springen"))
    #expect(!relatives.contains("singen"))
    #expect(!relatives.contains("mitsingen"))
    #expect(!relatives.contains("ertrinken"))
  }

  // Every verb in the stehen group is built on stehen, so the page has no other base to offer.
  @Test func groupWithOneRootHasNoAblautRelatives() throws {
    #expect(try related("aufstehen").ablautRelatives.isEmpty)
  }

  // ginnen is not a verb, so beginnen stands for its root on schwimmen's page.
  @Test func rootOutsideTheCorpusIsRepresentedByAVerbBuiltOnIt() throws {
    let relatives = try related("schwimmen").ablautRelatives.map(\.infinitiv)

    #expect(relatives.contains("beginnen"))
    #expect(!relatives.contains("ginnen"))
  }

  @Test func weakVerbHasNoAblautGroup() throws {
    let related = try related("machen")

    #expect(related.ablautGroup == nil)
    #expect(related.ablautRelatives.isEmpty)
  }

  @Test(arguments: [
    ("aufstehen", [BrowseableFamily.strong, .separable]),
    ("verstehen", [.strong, .inseparable]),
    ("machen", [.weak]),
    ("denken", [.mixed]),
    ("studieren", [.ieren])
  ])
  func families(infinitiv: String, expected: [BrowseableFamily]) throws {
    #expect(try related(infinitiv).families == expected)
  }

  // hängen is strong when something hangs and weak when someone hangs it, and the page shows
  // one reading at a time.
  @Test func relationsFollowTheShownReading() throws {
    let hängen = try #require(Verb.verbs["hängen"])
    try #require(hängen.hasMultipleReadings)
    let groups = hängen.readings.indices.map { hängen.related(readingIndex: $0).ablautGroup }

    #expect(groups.contains(nil))
    #expect(groups.contains("hängen"))
  }

  // bewegen is weak when it moves something and strong, like bieten, when it induces. The row
  // read only the primary reading's group, so bewegen appeared on no group-mate's page.
  @Test func strongSecondReadingJoinsItsGroupsRow() throws {
    let bewegen = try #require(Verb.verbs["bewegen"])
    try #require(bewegen.ablautGroup == nil)
    try #require(bewegen.readings.contains { $0.ablautGroup == "bieten" })

    #expect(try related("bieten").ablautRelatives.contains(bewegen))
    #expect(Verb.verbsByAblautGroup["bieten"]?.count { $0 == bewegen } == 1)
  }

  @Test func ablautGroupIndexListsEachGroupByFrequency() {
    for (group, verbs) in Verb.verbsByAblautGroup {
      #expect(zip(verbs, verbs.dropFirst()).allSatisfy { $0.frequency < $1.frequency }, "\(group)")
    }
  }

  // The captions received the root and the group as stored, so with Swiss spelling aufschließen's
  // card read "Built on schließen" above chips that read schliessen and beschliessen.
  @Test func relationTitlesFollowTheRegion() throws {
    let related = try related("aufschließen")
    try #require(related.root == "schließen")
    let ablautGroup = try #require(related.ablautGroup)
    Current.settings.region = .switzerland
    defer { Current.settings.region = .north }

    let titles = [
      RelatedVerbListDestination.Relation.builtOn(related.root).title,
      RelatedVerbListDestination.Relation.ablautGroup(ablautGroup).title
    ]
    for title in titles {
      #expect(title.contains("schliessen"), "\(title)")
      #expect(!title.contains("ß"), "\(title)")
    }
  }

  // .alphabetical returned its input unsorted, on the ground that every caller passed an
  // alphabetical list, which the prefix pages did not.
  @Test func alphabeticalSortIsGermanOrder() {
    let verbs = ["abziehen", "abändern", "abbauen"].compactMap { Verb.verbs[$0] }

    #expect(verbs.sorted(by: .alphabetical).map(\.infinitiv) == ["abändern", "abbauen", "abziehen"])
  }

  @Test func frequencySortPutsTheMostFrequentFirst() {
    let verbs = Verb.verbsSortedAlphabetically.filter { $0.ablautGroup == "singen" }
    let sorted = verbs.sorted(by: .frequency)

    #expect(sorted.first?.infinitiv == verbs.min { $0.frequency < $1.frequency }?.infinitiv)
    #expect(verbs.sorted(by: .alphabetical) == verbs)
  }
}
