// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

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
      .futurKonjunktivI,
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

  @Test func allCellsFollowsThePage() {
    #expect(Conjugationgroup.allCells == ConjugationTable.allCases.flatMap(\.cells))
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
