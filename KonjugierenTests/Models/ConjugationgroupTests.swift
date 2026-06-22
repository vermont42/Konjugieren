// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
@Suite("Conjugationgroup")
struct ConjugationgroupTests {
  private static let strong = Family.strong(ablautGroup: "test", ablautStartIndex: 0, ablautEndIndex: 0)
  private static let weak = Family.weak
  private static let ieren = Family.ieren

  private func expectEnding(
    _ conjugationgroup: Conjugationgroup,
    family: Family,
    _ expected: String,
    sourceLocation: SourceLocation = #_sourceLocation
  ) {
    #expect(conjugationgroup.ending(family: family) == expected, sourceLocation: sourceLocation)
  }

  @Test func präsensIndikativEndingsAreFamilyIndependent() {
    for family in [Self.strong, Self.weak, Self.ieren] {
      expectEnding(.präsensIndikativ(.firstSingular), family: family, "e")
      expectEnding(.präsensIndikativ(.secondSingular), family: family, "st")
      expectEnding(.präsensIndikativ(.thirdSingular), family: family, "t")
      expectEnding(.präsensIndikativ(.firstPlural), family: family, "en")
      expectEnding(.präsensIndikativ(.secondPlural), family: family, "t")
      expectEnding(.präsensIndikativ(.thirdPlural), family: family, "en")
    }
  }

  @Test func präsensKonjunktivIEndings() {
    expectEnding(.präsensKonjunktivI(.firstSingular), family: Self.weak, "e")
    expectEnding(.präsensKonjunktivI(.secondSingular), family: Self.weak, "est")
    expectEnding(.präsensKonjunktivI(.thirdSingular), family: Self.weak, "e")
    expectEnding(.präsensKonjunktivI(.firstPlural), family: Self.weak, "en")
    expectEnding(.präsensKonjunktivI(.secondPlural), family: Self.weak, "et")
    expectEnding(.präsensKonjunktivI(.thirdPlural), family: Self.weak, "en")
  }

  @Test func präteritumIndikativStrongEndings() {
    expectEnding(.präteritumIndikativ(.firstSingular), family: Self.strong, "")
    expectEnding(.präteritumIndikativ(.secondSingular), family: Self.strong, "st")
    expectEnding(.präteritumIndikativ(.thirdSingular), family: Self.strong, "")
    expectEnding(.präteritumIndikativ(.firstPlural), family: Self.strong, "en")
    expectEnding(.präteritumIndikativ(.secondPlural), family: Self.strong, "t")
    expectEnding(.präteritumIndikativ(.thirdPlural), family: Self.strong, "en")
  }

  @Test func präteritumIndikativWeakEndingsCarryTheDental() {
    expectEnding(.präteritumIndikativ(.firstSingular), family: Self.weak, "te")
    expectEnding(.präteritumIndikativ(.secondSingular), family: Self.weak, "test")
    expectEnding(.präteritumIndikativ(.thirdSingular), family: Self.weak, "te")
    expectEnding(.präteritumIndikativ(.firstPlural), family: Self.weak, "ten")
    expectEnding(.präteritumIndikativ(.secondPlural), family: Self.weak, "tet")
    expectEnding(.präteritumIndikativ(.thirdPlural), family: Self.weak, "ten")
  }

  @Test func präteritumKonjunktivIIEndings() {
    expectEnding(.präteritumKonjunktivII(.firstSingular), family: Self.strong, "e")
    expectEnding(.präteritumKonjunktivII(.secondSingular), family: Self.strong, "est")
    expectEnding(.präteritumKonjunktivII(.firstSingular), family: Self.weak, "te")
    expectEnding(.präteritumKonjunktivII(.secondSingular), family: Self.weak, "test")
  }

  @Test func partizipEndings() {
    expectEnding(.perfektpartizip, family: Self.strong, "en")
    expectEnding(.perfektpartizip, family: Self.weak, "t")
    expectEnding(.perfektpartizip, family: Self.ieren, "t")
    expectEnding(.präsenspartizip, family: Self.weak, "end")
  }

  @Test func imperativEndings() {
    expectEnding(.imperativ(.secondSingular), family: Self.weak, "")
    expectEnding(.imperativ(.secondPlural), family: Self.weak, "t")
    expectEnding(.imperativ(.firstPlural), family: Self.weak, "en")
    expectEnding(.imperativ(.thirdPlural), family: Self.weak, "en")
  }
}
