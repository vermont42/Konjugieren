// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
struct PracticeItemTests {
  private func verb(_ infinitiv: String) throws -> Verb {
    try #require(Verb.verbs[infinitiv], "\(infinitiv) is not in the corpus")
  }

  private func strongReadingIndex(of verb: Verb) throws -> Int {
    try #require(verb.readings.indices.first { verb.reading(at: $0).map(QuizDraw.isStrong) == true })
  }

  @Test func keysArePinned() {
    #expect(PracticeItem.keyConjugation(infinitiv: "fahren", readingIndex: 0, stem: .präteritum).key == "key:fahren:0:praeteritum")
    #expect(PracticeItem.pattern(tableKey: "praesens_indikativ", person: "ss").key == "pattern:praesens_indikativ:ss")
    #expect(PracticeItem.pattern(tableKey: "perfektpartizip", person: nil).key == "pattern:perfektpartizip")
  }

  @Test func keysRoundTrip() {
    let items: [PracticeItem] = [
      .keyConjugation(infinitiv: "aufstehen", readingIndex: 2, stem: .perfekt),
      .keyConjugation(infinitiv: "fahren", readingIndex: 0, stem: .präsens),
      .pattern(tableKey: "imperativ", person: "fp"),
      .pattern(tableKey: "praesenspartizip", person: nil)
    ]
    for item in items {
      #expect(PracticeItem(key: item.key) == item)
    }
  }

  @Test(arguments: ["", "key", "key:fahren:x:praesens", "key:fahren:0:futur", "key::0:praesens", "pattern", "pattern:", "pattern:a:b:c", "verb:fahren"])
  func unreadableKeysAreNil(key: String) {
    #expect(PracticeItem(key: key) == nil)
  }

  @Test func aStrongVerbsQuestionsMapToTheStemTheyAreBuiltOn() throws {
    let fahren = try verb("fahren")
    let readingIndex = try strongReadingIndex(of: fahren)
    let expected: [ConjugationTable: PracticeItem.Stem?] = [
      .präsensIndikativ: .präsens,
      .präsensKonjunktivI: .präsens,
      .imperativ: .präsens,
      .präsenspartizip: .präsens,
      .präteritumIndikativ: .präteritum,
      .präteritumKonjunktivII: .präteritum,
      .perfektpartizip: .perfekt,
      .perfektIndikativ: .perfekt,
      .perfektKonjunktivI: .perfekt,
      .plusquamperfektIndikativ: .perfekt,
      .plusquamperfektKonjunktivII: .perfekt,
      .futurIndikativ: nil,
      .futurKonjunktivI: nil,
      .futurKonjunktivII: nil
    ]
    #expect(Set(expected.keys) == Set(ConjugationTable.allCases))
    for table in ConjugationTable.allCases {
      for cell in table.cells {
        let item = PracticeItem.exercised(by: cell, of: fahren, readingIndex: readingIndex)
        if let stem = expected[table] ?? nil {
          #expect(item == .keyConjugation(infinitiv: "fahren", readingIndex: readingIndex, stem: stem), "\(cell)")
        } else {
          #expect(item == PracticeItem.pattern(of: cell), "\(cell)")
        }
      }
    }
  }

  @Test(arguments: ["machen", "sagen", "studieren", "verkaufen", "aufmachen"])
  func everyWeakVerbSharesOnePatternPerCell(infinitiv: String) throws {
    let weak = try verb(infinitiv)
    let kaufen = try verb("kaufen")
    for cell in Conjugationgroup.allCells {
      let item = PracticeItem.exercised(by: cell, of: weak, readingIndex: 0)
      #expect(item == PracticeItem.exercised(by: cell, of: kaufen, readingIndex: 0), "\(cell)")
      #expect(item == .pattern(tableKey: cell.table.articleKey, person: cell.personNumber?.rawValue), "\(cell)")
    }
  }

  @Test(arguments: ["aufstehen", "verstehen"])
  func aPrefixedStrongVerbHasItsOwnKeyConjugations(infinitiv: String) throws {
    let prefixed = try verb(infinitiv)
    let readingIndex = try strongReadingIndex(of: prefixed)

    let item = PracticeItem.exercised(by: .präteritumIndikativ(.firstPlural), of: prefixed, readingIndex: readingIndex)

    #expect(item == .keyConjugation(infinitiv: infinitiv, readingIndex: readingIndex, stem: .präteritum))
  }

  @Test func aTwoReadingVerbIsJudgedByTheAskedReading() throws {
    let hängen = try verb("hängen")
    let strong = try strongReadingIndex(of: hängen)
    let weak = try #require(hängen.readings.indices.first { verb in hängen.reading(at: verb).map(QuizDraw.isStrong) == false })

    #expect(PracticeItem.exercised(by: .präteritumIndikativ(.thirdSingular), of: hängen, readingIndex: strong) == .keyConjugation(infinitiv: "hängen", readingIndex: strong, stem: .präteritum))
    #expect(PracticeItem.exercised(by: .präteritumIndikativ(.thirdSingular), of: hängen, readingIndex: weak) == .pattern(tableKey: "praeteritum_indikativ", person: "ts"))
  }

  @Test func aLookupSchedulesEachStrongReadingsThreeKeyConjugationsAndNothingForAWeakVerb() throws {
    let hängen = try verb("hängen")
    let strong = try strongReadingIndex(of: hängen)

    #expect(PracticeItem.keyConjugations(of: hängen) == PracticeItem.Stem.allCases.map { .keyConjugation(infinitiv: "hängen", readingIndex: strong, stem: $0) })
    #expect(try PracticeItem.keyConjugations(of: verb("machen")).isEmpty)
  }

  @Test func anItemsCellAsksTheSameItemBack() throws {
    let kaufen = try verb("kaufen")
    for cell in Conjugationgroup.allCells {
      let pattern = PracticeItem.pattern(of: cell)
      let asked = try #require(pattern.conjugationgroup)
      #expect(asked == cell)
      #expect(PracticeItem.exercised(by: asked, of: kaufen, readingIndex: 0) == pattern)
    }

    let fahren = try verb("fahren")
    let readingIndex = try strongReadingIndex(of: fahren)
    for stem in PracticeItem.Stem.allCases {
      let item = PracticeItem.keyConjugation(infinitiv: "fahren", readingIndex: readingIndex, stem: stem)
      let asked = try #require(item.conjugationgroup)
      #expect(PracticeItem.exercised(by: asked, of: fahren, readingIndex: readingIndex) == item)
      #expect(item.verb == fahren)
    }
  }

  @Test func aKeyConjugationOfAVerbNoLongerStrongHasNoVerb() {
    #expect(PracticeItem.keyConjugation(infinitiv: "machen", readingIndex: 0, stem: .präsens).verb == nil)
    #expect(PracticeItem.keyConjugation(infinitiv: "nichtverben", readingIndex: 0, stem: .präsens).verb == nil)
  }

  @Test func theStemsAreTheVerbPagesKeyConjugations() throws {
    let aufstehen = try verb("aufstehen")
    let readingIndex = try strongReadingIndex(of: aufstehen)
    let expected = PracticeItem.Stem.allCases.map { stem in
      RegionalConjugator.conjugateUnsafely(infinitiv: "aufstehen", conjugationgroup: stem.keyConjugationgroup, region: .north, readingIndex: readingIndex)
    }

    #expect(aufstehen.keyConjugations(readingIndex: readingIndex, region: .north) == expected)
  }
}
