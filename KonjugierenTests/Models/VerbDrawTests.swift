// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite("FrequencyBand")
@MainActor
struct FrequencyBandTests {
  @Test(arguments: FrequencyBand.allCases)
  func bandHoldsItsCount(band: FrequencyBand) {
    #expect(Verb.verbs(in: band).count == band.verbCount)
  }

  @Test(arguments: FrequencyBand.allCases)
  func bandHoldsExactlyTheVerbsInIt(band: FrequencyBand) {
    let inBand = Set(Verb.verbs(in: band).map(\.infinitiv))
    let counted = Set(Verb.verbs.values.filter { $0.isIn(band) }.map(\.infinitiv))
    #expect(inBand == counted)
  }

  @Test func bandsNest() {
    let top100 = Set(Verb.verbs(in: .top100).map(\.infinitiv))
    let top300 = Set(Verb.verbs(in: .top300).map(\.infinitiv))
    let top1000 = Set(Verb.verbs(in: .top1000).map(\.infinitiv))
    #expect(top100.isSubset(of: top300))
    #expect(top300.isSubset(of: top1000))
  }

  @Test func mostFrequentVerbsAreInTheNarrowestBand() throws {
    for infinitiv in ["sein", "haben", "werden", "gehen"] {
      let verb = try #require(Verb.verbs[infinitiv])
      #expect(verb.isIn(.top100), "\(infinitiv)")
    }
  }
}

@Suite("VerbDraw")
@MainActor
struct VerbDrawTests {
  /// Returns its values in turn, so a test can steer each decision the draw makes.
  private struct ScriptedGenerator: RandomNumberGenerator {
    var values: [UInt64]

    mutating func next() -> UInt64 {
      values.isEmpty ? 0 : values.removeFirst()
    }
  }

  private let frequent = VerbDraw.frequentVerbs

  private func verbs(_ infinitivs: [String]) -> [Verb] {
    infinitivs.compactMap { Verb.verbs[$0] }
  }

  private func days(_ count: Int) -> [Date] {
    let calendar = WidgetConstants.gregorianCalendar
    let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? .now
    return (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
  }

  @Test(arguments: zip(["gehen", "aufstehen", "machen", "abarbeiten", "studieren"], [4, 2, 2, 1, 2]))
  func weightFavorsStrongAndUnprefixedVerbs(infinitiv: String, weight: Int) throws {
    let verb = try #require(Verb.verbs[infinitiv])
    #expect(VerbDraw.weight(of: verb) == UInt64(weight))
  }

  @Test func frequentVerbsAreTheWidestBand() {
    #expect(VerbDraw.frequentVerbs.map(\.infinitiv) == Verb.verbs(in: .top1000).map(\.infinitiv))
  }

  @Test func drawForMyVerbsPicksAmongThem() {
    var generator = ScriptedGenerator(values: [1])
    let myVerbs = verbs(["sein", "aufstehen"])
    #expect(VerbDraw.draw(goesToMyVerbs: true, myVerbs: myVerbs, frequentVerbs: frequent, using: &generator)?.infinitiv == "aufstehen")
  }

  @Test func otherDrawsGoToTheFrequentVerbs() {
    var generator = ScriptedGenerator(values: [0])
    let myVerbs = verbs(["aufstehen"])
    #expect(VerbDraw.draw(goesToMyVerbs: false, myVerbs: myVerbs, frequentVerbs: frequent, using: &generator) == frequent.first)
  }

  @Test func weightedDrawStepsPastEachVerbsWeight() throws {
    let candidates = verbs(["abarbeiten", "gehen"])
    let abarbeiten = try #require(candidates.first)
    var generator = ScriptedGenerator(values: [VerbDraw.weight(of: abarbeiten)])
    #expect(VerbDraw.draw(goesToMyVerbs: false, myVerbs: [], frequentVerbs: candidates, using: &generator)?.infinitiv == "gehen")
  }

  @Test func emptyMyVerbsFallsBackToTheFrequentVerbs() {
    var generator = ScriptedGenerator(values: [0])
    #expect(VerbDraw.draw(goesToMyVerbs: true, myVerbs: [], frequentVerbs: frequent, using: &generator) == frequent.first)
  }

  @Test func noFrequentVerbsFallsBackToMyVerbs() {
    var generator = ScriptedGenerator(values: [0])
    #expect(VerbDraw.draw(goesToMyVerbs: false, myVerbs: verbs(["aufstehen"]), frequentVerbs: [], using: &generator)?.infinitiv == "aufstehen")
  }

  @Test func verbOfTheDayIsStableForADay() throws {
    let calendar = WidgetConstants.gregorianCalendar
    let morning = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 1, hour: 6)))
    let evening = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 1, hour: 23)))
    let myVerbs = verbs(["aufstehen", "verstehen"])
    let first = VerbDraw.verbOfTheDay(on: morning, myVerbs: myVerbs, frequentVerbs: frequent)
    #expect(first != nil)
    #expect(first == VerbDraw.verbOfTheDay(on: evening, myVerbs: myVerbs, frequentVerbs: frequent))
  }

  @Test func verbOfTheDayVaries() {
    let drawn = days(10).compactMap { VerbDraw.verbOfTheDay(on: $0, myVerbs: [], frequentVerbs: frequent) }
    #expect(Set(drawn.map(\.infinitiv)).count >= 8)
  }

  @Test func withoutMyVerbsEveryDrawIsFrequent() {
    for day in days(365) {
      let verb = VerbDraw.verbOfTheDay(on: day, myVerbs: [], frequentVerbs: frequent)
      #expect(verb?.isIn(.top1000) == true)
    }
  }

  @Test func myVerbsGetsEveryThirdDayAndChangesNoOther() {
    let myVerbs = verbs(["abbehalten"])
    let changed = days(60).map { day in
      VerbDraw.verbOfTheDay(on: day, myVerbs: myVerbs, frequentVerbs: frequent) != VerbDraw.verbOfTheDay(on: day, myVerbs: [], frequentVerbs: frequent)
    }
    let firstChanged = changed.firstIndex(of: true) ?? 0
    #expect(firstChanged < 3)
    for (index, didChange) in changed.enumerated() {
      #expect(didChange == ((index - firstChanged) % 3 == 0), "day \(index)")
    }
  }

  @Test func myVerbsDaysTakeMyVerbsInTurn() {
    let myVerbs = verbs(["abbehalten", "abbeißen", "abberufen"])
    let drawn = days(27).compactMap { VerbDraw.verbOfTheDay(on: $0, myVerbs: myVerbs, frequentVerbs: frequent) }
    let fromMyVerbs = drawn.filter { myVerbs.contains($0) }
    #expect(fromMyVerbs.count == 9)
    for (index, verb) in fromMyVerbs.enumerated() {
      #expect(verb == fromMyVerbs[index % 3], "turn \(index)")
    }
    #expect(Set(fromMyVerbs.prefix(3)).count == 3)
  }

  @Test func strongAndUnprefixedVerbsAreFavored() {
    let drawn = days(1000).compactMap { VerbDraw.verbOfTheDay(on: $0, myVerbs: [], frequentVerbs: frequent) }
    let favored = drawn.filter { VerbDraw.weight(of: $0) > 1 }
    let baseRate = Double(frequent.filter { VerbDraw.weight(of: $0) > 1 }.count) / Double(frequent.count)
    let drawnRate = Double(favored.count) / Double(drawn.count)
    #expect(drawnRate > baseRate + 0.08, "drawn \(drawnRate), base \(baseRate)")
  }

  @Test func randomVerbComesFromMyVerbsOrTheFrequentVerbs() {
    let myVerbs = verbs(["abbehalten"])
    for _ in 0..<50 {
      let verb = VerbDraw.randomVerb(myVerbs: myVerbs)
      #expect(verb?.isIn(.top1000) == true || verb?.infinitiv == "abbehalten")
    }
  }
}
