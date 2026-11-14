// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@Suite("Quiz verb mix")
@MainActor
struct QuizVerbMixTests {
  private static let seeds: [UInt64] = Array(1...40)

  // About 50 ms a quiz in a debug build, so each level's quizzes are drawn once for the suite.
  private static let quizzes: [QuizLevel: [UInt64: [QuizDrawnQuestion]]] = Dictionary(uniqueKeysWithValues: QuizLevel.allCases.map { level in
    (level, Dictionary(uniqueKeysWithValues: seeds.map { ($0, draw(level, seed: $0, count: Quiz.questionCount)) }))
  })

  private func defaultQuiz(_ level: QuizLevel, seed: UInt64) -> [QuizDrawnQuestion] {
    Self.quizzes[level]?[seed] ?? []
  }

  private static func draw(_ level: QuizLevel, seed: UInt64, count: Int) -> [QuizDrawnQuestion] {
    var generator = SeededRNG(seed: seed)
    return QuizDraw.questions(
      level: level,
      verbs: Quiz.defaultVerbs(for: level),
      readingIndex: nil,
      count: count,
      distinctCells: false,
      mixesVerbs: true,
      using: &generator
    )
  }

  private func reading(of question: QuizDrawnQuestion) -> Reading {
    question.verb.reading(at: question.readingIndex) ?? question.verb.primaryReading
  }

  @Test(arguments: zip(QuizLevel.allCases, [100, 300, 1_000, 3_572]))
  func eachLevelDrawsFromItsBand(level: QuizLevel, bandSize: Int) {
    #expect(Quiz.defaultVerbs(for: level).count == bandSize)
    for seed in Self.seeds {
      #expect(defaultQuiz(level, seed: seed).allSatisfy { $0.verb.frequency <= bandSize })
    }
  }

  @Test(arguments: QuizLevel.allCases)
  func aDefaultQuizAsksEveryQuestion(level: QuizLevel) {
    for seed in Self.seeds {
      #expect(defaultQuiz(level, seed: seed).count == Quiz.questionCount)
    }
  }

  @Test(arguments: QuizLevel.allCases)
  func halfTheQuestionsAskAStrongOrMixedReading(level: QuizLevel) {
    for seed in Self.seeds {
      let strong = defaultQuiz(level, seed: seed).filter { QuizDraw.isStrong(reading(of: $0)) }
      #expect(strong.count == Quiz.questionCount / 2, "seed \(seed)")
    }
  }

  @Test(arguments: QuizLevel.allCases)
  func atLeastTwoQuestionsAskACoreVerb(level: QuizLevel) {
    for seed in Self.seeds {
      let core = defaultQuiz(level, seed: seed).filter { QuizDraw.isCore($0.verb) }
      #expect(core.count >= QuizDraw.minimumCoreQuestions, "seed \(seed)")
    }
  }

  @Test(arguments: QuizLevel.allCases)
  func everyQuizAsksAPrefixedVerb(level: QuizLevel) {
    for seed in Self.seeds {
      #expect(defaultQuiz(level, seed: seed).contains { QuizDraw.isDerivative(reading(of: $0)) }, "seed \(seed)")
    }
  }

  @Test(arguments: [QuizLevel.intermediate, .advanced])
  func oneToThreeQuestionsAskARareDerivative(level: QuizLevel) {
    var counts: Set<Int> = []
    for seed in Self.seeds {
      let rare = defaultQuiz(level, seed: seed).filter { QuizDraw.isRareDerivative($0.verb, reading: reading(of: $0)) }
      #expect(QuizDraw.rareDerivativeRange.contains(rare.count), "seed \(seed)")
      counts.insert(rare.count)
    }
    #expect(counts == Set(QuizDraw.rareDerivativeRange))
  }

  @Test(arguments: [QuizLevel.beginner, .elementary])
  func aNarrowBandHasNoRareDerivatives(level: QuizLevel) {
    #expect(Quiz.defaultVerbs(for: level).allSatisfy { verb in
      verb.readings.allSatisfy { !QuizDraw.isRareDerivative(verb, reading: $0) }
    })
  }

  @Test func frequentDerivativesDrawFreely() {
    let derivatives = Self.seeds.flatMap { defaultQuiz(.beginner, seed: $0) }.filter { QuizDraw.isDerivative(reading(of: $0)) }
    #expect(derivatives.count > Self.seeds.count * QuizDraw.rareDerivativeRange.upperBound)
  }

  @Test(arguments: QuizLevel.allCases)
  func theMixKeepsTheLevelsCells(level: QuizLevel) {
    let cells = Set(level.pool.flatMap(\.cells))
    for seed in Self.seeds {
      #expect(defaultQuiz(level, seed: seed).allSatisfy { cells.contains($0.conjugationgroup) })
    }
  }

  @Test func theElementaryPräteritumStillAsksOnlyCoreVerbs() {
    let präteritum = Self.seeds.flatMap { defaultQuiz(.elementary, seed: $0) }.filter {
      ConjugationTable.präteritumIndikativ.cells.contains($0.conjugationgroup)
    }
    #expect(!präteritum.isEmpty)
    #expect(präteritum.allSatisfy { QuizDraw.isCore($0.verb) && $0.verb.infinitiv != "werden" })
  }

  @Test func aTenQuestionQuizMixesToo() {
    for seed in Self.seeds {
      let questions = Self.draw(.intermediate, seed: seed, count: 10)
      #expect(questions.filter { QuizDraw.isStrong(reading(of: $0)) }.count == 5)
      #expect(questions.filter { QuizDraw.isCore($0.verb) }.count >= QuizDraw.minimumCoreQuestions)
    }
  }

  @Test func noProvisionalCountReachesABand() {
    #expect(Verb.verbs(in: .top1000).allSatisfy { !$0.hitsAreProvisional })
  }
}
