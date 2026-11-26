// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import Testing

@MainActor
@Suite("ConjugationTable")
struct ConjugationTableTests {
  @Test func ordersEachBlockByCorpusFrequencyWithTheParticiplesLast() {
    #expect(ConjugationTable.allCases == [
      .präsensIndikativ,
      .präteritumIndikativ,
      .präteritumKonjunktivII,
      .präsensKonjunktivI,
      .imperativ,
      .perfektpartizip,
      .präsenspartizip,
      .perfektIndikativ,
      .futurIndikativ,
      .plusquamperfektIndikativ,
      .futurKonjunktivII,
      .plusquamperfektKonjunktivII,
      .perfektKonjunktivI,
      .futurKonjunktivI
    ])
  }

  @Test func putsEverySimpleTableBeforeEveryCompoundOne() {
    let compoundFlags = ConjugationTable.allCases.map(\.isCompound)
    #expect(compoundFlags == compoundFlags.sorted { !$0 && $1 })
    #expect(compoundFlags.filter { $0 }.count == 7)
  }

  @Test func stacksTheParticiplesUnderTheImperativ() {
    let stacks = ConjugationTable.stacks
    #expect(stacks.flatMap { $0 } == ConjugationTable.allCases)
    #expect(stacks.contains([.imperativ, .perfektpartizip, .präsenspartizip]))
    #expect(stacks.filter { $0.count > 1 }.count == 1)
  }

  @Test func theFirstTableOfEachBlockMarksItsSection() {
    #expect(ConjugationTable.allCases.first { !$0.isCompound }?.pageSection == .simple)
    #expect(ConjugationTable.allCases.first { $0.isCompound }?.pageSection == .compound)
    #expect(ConjugationTable.allCases.compactMap(\.pageSection) == [.simple, .compound])
  }

  // machen's page has red auxiliaries in its compound tables and a capital in "machen Sie",
  // and neither is a red letter of the verb's own.
  @Test(arguments: [
    ("machen", false),
    ("singen", true),
    ("sein", true)
  ])
  func redLettersAreTheVerbsOwn(infinitiv: String, expected: Bool) throws {
    let verb = try #require(Verb.verbs[infinitiv])
    for region in Region.allCases {
      #expect(ConjugationTable.hasRedLetters(verb, readingIndex: 0, region: region) == expected)
    }
  }

  // The page draws its tables from the stacks, so a stack that dropped or reordered a table
  // would put the page out of step with allCells, which the search's marks follow.
  @Test func allCellsFollowsThePage() {
    #expect(Conjugationgroup.allCells == ConjugationTable.stacks.flatMap { $0 }.flatMap(\.cells))
  }

  @Test(arguments: ConjugationTable.allCases)
  func everyCellNamesItsTable(table: ConjugationTable) {
    #expect(table.cells.allSatisfy { $0.table == table })
  }

  @Test(arguments: ConjugationTable.allCases)
  func everyTableHasItsArticle(table: ConjugationTable) {
    #expect(table.article?.stableKey == table.articleKey)
  }

  @Test(arguments: ConjugationTable.allCases)
  func everyTableHasTwoSecondNames(table: ConjugationTable) {
    let german = table.secondName(lang: .german)
    let english = table.secondName(lang: .english)
    #expect(german.isGerman)
    #expect(!german.text.isEmpty && !english.text.isEmpty)
    #expect(german.text != table.displayName(lang: .german))
    #expect(english.text != table.displayName(lang: .english))
  }

  @Test func secondNamesMatchJoshsList() {
    #expect(ConjugationTable.perfektpartizip.secondName(lang: .german).text == "Partizip II")
    #expect(ConjugationTable.futurKonjunktivII.secondName(lang: .german).text == "würde-Form")
    #expect(ConjugationTable.perfektIndikativ.secondName(lang: .english).text == "Conversational Past")
    #expect(ConjugationTable.futurKonjunktivII.secondName(lang: .english) == ConjugationTable.SecondName(text: "würde + Infinitive", isGerman: true))
  }
}
