// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("KeyConjugations")
struct KeyConjugationsTests {
  private func verb(_ infinitiv: String) throws -> Verb {
    try #require(Verb.verbs[infinitiv])
  }

  @Test(arguments: [
    ("aufstehen", ["steht auf", "stAND auf", "IST aufgestANDen"]),
    ("machen", ["macht", "machte", "hAt gemacht"]),
    ("sein", ["IST", "WAR", "IST geWESen"]),
    ("können", ["kAnn", "kOnnte", "hAt gekOnnt"]),
  ])
  func keyConjugations(infinitiv: String, expected: [String]) throws {
    let actual = try verb(infinitiv).keyConjugations(region: .north)

    #expect(actual == expected)
  }

  @Test func followTheReadingOnScreen() throws {
    let hängen = try verb("hängen")

    #expect(hängen.keyConjugations(readingIndex: 0, region: .north).map { $0.lowercased() } == ["hängt", "hing", "hat gehangen"])
    #expect(hängen.keyConjugations(readingIndex: 1, region: .north).map { $0.lowercased() } == ["hängt", "hängte", "hat gehängt"])
  }

  @Test func followTheRegion() throws {
    #expect(try verb("stehen").keyConjugations(region: .austria).last?.lowercased() == "ist gestanden")
    #expect(try verb("heißen").keyConjugations(region: .switzerland).first?.lowercased() == "heisst")
  }

  @Test func shareTextNamesTheVerbItsGlossItsConjugationsAndTheAppStore() throws {
    let text = try verb("aufstehen").shareText(region: .north)

    #expect(text.contains("aufstehen"))
    #expect(text.contains(try verb("aufstehen").primaryReading.translation))
    #expect(text.contains("steht auf · stand auf · ist aufgestanden"))
    #expect(text.contains("https://apps.apple.com/app/konjugieren/id6758258747"))
  }

  @Test func shareTextUsesTheGlossOfTheReadingOnScreen() throws {
    let hängen = try verb("hängen")
    let text = hängen.shareText(readingIndex: 1, region: .north)

    #expect(text.contains(try #require(hängen.reading(at: 1)).translation))
    #expect(text.contains("hängte"))
  }

  @Test func shareTextWritesSwissSpelling() throws {
    let text = try verb("heißen").shareText(region: .switzerland)

    #expect(text.contains("heissen"))
    #expect(!text.contains("ß"))
  }

  @Test(arguments: [
    ("stEhe auf", "stehe auf"),
    ("ist gewEsen", "ist gewesen"),
    ("gefÄhrlich", "gefährlich"),
  ])
  func copyTextIsLowercase(form: String, expected: String) {
    #expect(ConjugationRow(pronoun: "ich", form: form).copyText == expected)
  }

  @Test func unavailableCellCopiesNothing() {
    #expect(ConjugationRow(form: ConjugationRow.unavailable).copyText == nil)
  }
}
