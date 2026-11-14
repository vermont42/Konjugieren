// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@Suite("Quiz levels")
@MainActor
struct QuizLevelTests {
  private static let seinHabenModals: Set<String> = ["dürfen", "haben", "können", "mögen", "müssen", "sein", "sollen", "wollen"]

  private var allVerbs: [Verb] {
    Verb.verbs.values.sorted { $0.infinitiv < $1.infinitiv }
  }

  private func draw(_ level: QuizLevel, verbs: [Verb]? = nil, readingIndex: Int? = nil, count: Int = 5_000, distinctCells: Bool = false, seed: UInt64 = 7) -> [QuizDrawnQuestion] {
    var generator = SeededRNG(seed: seed)
    return QuizDraw.questions(level: level, verbs: verbs ?? allVerbs, readingIndex: readingIndex, count: count, distinctCells: distinctCells, using: &generator)
  }

  private func table(of cell: Conjugationgroup) -> ConjugationTable? {
    ConjugationTable.allCases.first { $0.cells.contains(cell) }
  }

  @Test(arguments: zip(QuizLevel.allCases, [
    [ConjugationTable.präsensIndikativ, .imperativ],
    [.präsensIndikativ, .imperativ, .perfektIndikativ, .perfektpartizip, .präteritumIndikativ],
    [.präsensIndikativ, .imperativ, .perfektIndikativ, .perfektpartizip, .präteritumIndikativ, .plusquamperfektIndikativ, .futurKonjunktivII, .präteritumKonjunktivII, .plusquamperfektKonjunktivII, .futurIndikativ],
    ConjugationTable.allCases
  ]))
  func eachLevelAsksItsTables(level: QuizLevel, tables: [ConjugationTable]) {
    #expect(Set(level.pool.map(\.table)) == Set(tables))
    #expect(level.pool.count == tables.count)
  }

  @Test(arguments: zip(QuizLevel.allCases.dropLast(), QuizLevel.allCases.dropFirst()))
  func eachLevelAddsToTheOneBefore(lower: QuizLevel, higher: QuizLevel) {
    let lowerCells = Set(lower.pool.flatMap(\.cells))
    let higherCells = Set(higher.pool.flatMap(\.cells))
    #expect(lowerCells.isSubset(of: higherCells))
    #expect(lowerCells != higherCells)
  }

  @Test func theWirImperativJoinsAtElementary() {
    let beginnerImperativ = QuizLevel.beginner.pool.first { $0.table == .imperativ }?.cells
    let elementaryImperativ = QuizLevel.elementary.pool.first { $0.table == .imperativ }?.cells
    #expect(beginnerImperativ == [.imperativ(.secondSingular), .imperativ(.secondPlural), .imperativ(.thirdPlural)])
    #expect(elementaryImperativ == ConjugationTable.imperativ.cells)
  }

  @Test(arguments: QuizLevel.allCases)
  func aDrawAsksOnlyTheLevelsCells(level: QuizLevel) {
    let cells = Set(level.pool.flatMap(\.cells))
    #expect(draw(level).allSatisfy { cells.contains($0.conjugationgroup) })
  }

  @Test func theElementaryPräteritumAsksOnlySeinHabenAndTheModals() {
    let präteritum = draw(.elementary).filter { table(of: $0.conjugationgroup) == .präteritumIndikativ }
    #expect(!präteritum.isEmpty)
    #expect(präteritum.allSatisfy { Self.seinHabenModals.contains($0.verb.infinitiv) })
  }

  @Test func theIntermediatePräteritumIsAskedOfAnyVerb() {
    let präteritum = draw(.intermediate).filter { table(of: $0.conjugationgroup) == .präteritumIndikativ }
    #expect(präteritum.contains { !Self.seinHabenModals.contains($0.verb.infinitiv) })
  }

  @Test func theIntermediateKonjunktivIIAsksOnlySeinHabenWerdenAndTheModals() {
    let konjunktivII = draw(.intermediate).filter { table(of: $0.conjugationgroup) == .präteritumKonjunktivII }
    #expect(!konjunktivII.isEmpty)
    #expect(konjunktivII.allSatisfy { Self.seinHabenModals.union(["werden"]).contains($0.verb.infinitiv) })
  }

  @Test func theAdvancedKonjunktivIIAsksNoWeakReadingButTheCoreVerbs() {
    let konjunktivII = draw(.advanced, count: 20_000).filter { table(of: $0.conjugationgroup) == .präteritumKonjunktivII }
    let core = Self.seinHabenModals.union(["werden"])
    #expect(konjunktivII.contains { !core.contains($0.verb.infinitiv) })
    for question in konjunktivII where !core.contains(question.verb.infinitiv) {
      switch question.verb.reading(at: question.readingIndex)?.family {
      case .mixed, .strong:
        break
      default:
        Issue.record("\(question.verb.infinitiv), reading \(question.readingIndex), is weak")
      }
    }
  }

  @Test func aVerbWithAStrongAndAWeakReadingIsAskedTheKonjunktivIIOnlyInItsStrongReading() throws {
    let hängen = try #require(Verb.verbs["hängen"])
    let konjunktivII = draw(.advanced, verbs: [hängen]).filter { table(of: $0.conjugationgroup) == .präteritumKonjunktivII }
    #expect(!konjunktivII.isEmpty)
    #expect(konjunktivII.allSatisfy { question in
      if case .strong = hängen.reading(at: question.readingIndex)?.family {
        return true
      }
      return false
    })
  }

  @Test func aKindThatNoVerbOfTheScopeFitsIsLeftOut() throws {
    let machen = try #require(Verb.verbs["machen"])
    let questions = draw(.elementary, verbs: [machen], count: 500)
    #expect(questions.count == 500)
    #expect(!questions.contains { table(of: $0.conjugationgroup) == .präteritumIndikativ })
  }

  @Test func aWeakVerbsPageIsNeverAskedTheKonjunktivII() throws {
    let machen = try #require(Verb.verbs["machen"])
    for seed in UInt64(0)..<200 {
      let questions = draw(.advanced, verbs: [machen], readingIndex: 0, count: 3, distinctCells: true, seed: seed)
      #expect(questions.count == 3)
      #expect(!questions.contains { table(of: $0.conjugationgroup) == .präteritumKonjunktivII })
    }
  }

  @Test(arguments: QuizLevel.allCases)
  func distinctCellsAreDistinctAndNeverParticiples(level: QuizLevel) throws {
    let gehen = try #require(Verb.verbs["gehen"])
    for seed in UInt64(0)..<50 {
      let questions = draw(level, verbs: [gehen], readingIndex: 0, count: 3, distinctCells: true, seed: seed)
      #expect(questions.count == 3)
      #expect(Set(questions.map(\.conjugationgroup)).count == 3)
      #expect(!questions.contains { $0.conjugationgroup.personNumber == nil })
    }
  }

  // Each kind's share of 40,000 seeded draws should sit near its weight's share of the pool, and
  // the three Futurs, weighted 1, well below the ordinary weight of 2.
  @Test(arguments: QuizLevel.allCases)
  func eachKindIsDrawnByItsWeight(level: QuizLevel) {
    let count = 40_000
    let tableOfCell = Dictionary(uniqueKeysWithValues: ConjugationTable.allCases.flatMap { table in
      table.cells.map { ($0, table) }
    })
    var counts: [ConjugationTable: Int] = [:]
    for question in draw(level, count: count) {
      if let table = tableOfCell[question.conjugationgroup] {
        counts[table, default: 0] += 1
      }
    }
    let totalWeight = Double(level.pool.reduce(0) { $0 + $1.weight })
    for entry in level.pool {
      let drawn = Double(counts[entry.table, default: 0]) / Double(count)
      let expected = Double(entry.weight) / totalWeight
      #expect(abs(drawn - expected) < 0.01, "\(entry.table): drew \(drawn), expected \(expected)")
    }
  }

  @Test func theAuxiliaryOnlyFuturGroupsWeighHalfAsMuchAsTheirNeighbors() {
    let weights = Dictionary(uniqueKeysWithValues: QuizLevel.advanced.pool.map { ($0.table, $0.weight) })
    #expect(weights[.futurIndikativ] == 1)
    #expect(weights[.futurKonjunktivI] == 1)
    #expect(weights[.futurKonjunktivII] == 1)
    #expect(weights[.präsensKonjunktivI] == 2)
    #expect(weights[.präsensIndikativ] == 3)
    #expect(weights[.perfektIndikativ] == 3)
  }

  @Test func theSameSeedDrawsTheSameQuestions() {
    #expect(draw(.advanced, count: 30, seed: 99) == draw(.advanced, count: 30, seed: 99))
    #expect(draw(.advanced, count: 30, seed: 99) != draw(.advanced, count: 30, seed: 100))
  }
}
