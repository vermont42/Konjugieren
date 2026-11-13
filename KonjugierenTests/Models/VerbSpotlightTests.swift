// Copyright © 2026 Josh Adams. All rights reserved.

import CoreSpotlight
import Foundation
import Testing
@testable import Konjugieren

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

  // The case from docs/browse-and-verb-ideas.md that Spotlight missed: aufgestanden and "get up"
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
}
