// Copyright © 2026 Josh Adams. All rights reserved.

import CoreSpotlight
import Foundation
@testable import Konjugieren
import Testing

@MainActor
@Suite("Verb Spotlight")
struct VerbSpotlightTests {
  private static let conjugations = VerbSpotlight.conjugationsByInfinitiv(in: .bundled)

  private func text(_ infinitiv: String, region: Region = .north) -> VerbSpotlight.Text {
    VerbSpotlight.text(for: Verb.verbs[infinitiv]!, conjugations: Self.conjugations[infinitiv] ?? [], region: region)
  }

  @Test(arguments: zip(
    ["set fire to, burn down (something)", "wind, wrap; gulp", "move (something) away", "get up"],
    [["set fire to", "burn down"], ["wind", "wrap", "gulp"], ["move away"], ["get up"]]
  ))
  func glossPhrases(gloss: String, phrases: [String]) {
    #expect(VerbSpotlight.glossPhrases(in: gloss) == phrases)
  }

  @Test func conjugationsIncludeEveryOneWordConjugationAndEachFinitePartWithItsParticle() throws {
    let aufstehen = try #require(Self.conjugations["aufstehen"])
    #expect(aufstehen.isSuperset(of: ["aufgestanden", "aufstand", "aufzustehen", "steht auf", "stand auf"]))
    #expect(!aufstehen.contains("steht"))
  }

  // The case from docs/browse_and_verb_ideas.md that Spotlight missed: aufgestanden and "get up"
  // found nothing.
  @Test func aufstehenCanBeFoundByItsParticipleAndItsGloss() {
    let aufstehen = text("aufstehen")
    #expect(aufstehen.keywords.contains("aufgestanden"))
    #expect(aufstehen.keywords.contains("get up"))
    #expect(aufstehen.keywords.contains("to get up"))
    #expect(aufstehen.alternateNames.contains("ist aufgestanden"))
  }

  @Test func theDescriptionShowsTheKeyConjugationsWithNoLabel() {
    #expect(text("aufstehen").description == "steht auf · stand auf · ist aufgestanden")
  }

  @Test func theGlossLeadsTheAlternateNames() {
    #expect(text("aufstehen").alternateNames.first == "get up")
  }

  @Test func everyReadingContributesItsKeyConjugationsAndGloss() {
    let hängen = text("hängen")
    #expect(hängen.alternateNames.contains("hing"))
    #expect(hängen.alternateNames.contains("hängte"))
    let glosses = Verb.verbs["hängen"]!.readings.map(\.translation)
    #expect(glosses.allSatisfy(hängen.keywords.contains))
  }

  @Test func theKeyConjugationsFollowTheRegion() {
    #expect(text("stehen", region: .austria).alternateNames.contains("ist gestanden"))
    #expect(text("stehen", region: .north).alternateNames.contains("hat gestanden"))
  }

  @Test func indexedEntitiesCarryTheirText() {
    let entity = VerbSpotlight.entity(for: Verb.verbs["gehen"]!, conjugations: Self.conjugations["gehen"] ?? [], region: .north)
    #expect(entity.id == "gehen")
    #expect(entity.spotlight?.keywords.contains("ging") == true)
    #expect(entity.attributeSet.keywords?.contains("ging") == true)
  }

  @MainActor
  @Suite("Indexing")
  struct IndexingTests {
    private let verbs = ["gehen", "machen"].map { Verb.verbs[$0]! }
    private let spy = SpotlightIndexSpy()

    private func indexed(_ getterSetter: GetterSetterFake) -> String? {
      getterSetter.get(key: VerbSpotlight.indexedVerbsKey)
    }

    private func migrated(remembering indexed: String? = nil) -> GetterSetterFake {
      var dictionary = [VerbSpotlight.leftDefaultIndexKey: "true"]
      dictionary[VerbSpotlight.indexedVerbsKey] = indexed
      return GetterSetterFake(dictionary: dictionary)
    }

    @Test func theFirstRunEmptiesEveryIndexBeforeIndexing() async {
      let getterSetter = GetterSetterFake()
      await VerbSpotlight.indexVerbs(verbs, in: spy, getterSetter: getterSetter)
      #expect(spy.calls == [.deleteEveryVerb, .indexVerbs(["gehen", "machen"])])
      #expect(getterSetter.get(key: VerbSpotlight.leftDefaultIndexKey) == "true")
      #expect(indexed(getterSetter) == "gehen\nmachen")
    }

    @Test func aFailedEmptyingIsTriedAgainAtTheNextLaunch() async {
      let getterSetter = GetterSetterFake()
      spy.deletesFail = true
      await VerbSpotlight.indexVerbs(verbs, in: spy, getterSetter: getterSetter)
      #expect(getterSetter.get(key: VerbSpotlight.leftDefaultIndexKey) == nil)
      #expect(spy.calls.last == .indexVerbs(["gehen", "machen"]))
    }

    @Test func aVerbThatLeftTheCorpusLeavesSpotlightBeforeTheRestAreIndexed() async {
      let getterSetter = migrated(remembering: "gehen\nmachen\nxyzzyq")
      await VerbSpotlight.indexVerbs(verbs, in: spy, getterSetter: getterSetter)
      #expect(spy.calls == [.deleteVerbs(["xyzzyq"]), .indexVerbs(["gehen", "machen"])])
      #expect(indexed(getterSetter) == "gehen\nmachen")
    }

    @Test func aVerbWhoseDeletionFailedIsRememberedForTheNextLaunch() async {
      let getterSetter = migrated(remembering: "gehen\nxyzzyq")
      spy.deletesFail = true
      await VerbSpotlight.indexVerbs(verbs, in: spy, getterSetter: getterSetter)
      #expect(indexed(getterSetter) == "gehen\nmachen\nxyzzyq")
    }

    @Test func nothingIsDeletedWhenNoVerbLeft() async {
      let getterSetter = migrated(remembering: "gehen")
      await VerbSpotlight.indexVerbs(verbs, in: spy, getterSetter: getterSetter)
      #expect(spy.calls == [.indexVerbs(["gehen", "machen"])])
    }
  }
}
