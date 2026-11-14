// Copyright © 2026 Josh Adams. All rights reserved.

/// A question as drawn, before it is conjugated.
struct QuizDrawnQuestion: Equatable {
  let verb: Verb
  let conjugationgroup: Conjugationgroup
  let readingIndex: Int
}

/// Chooses a quiz's questions from a level's pool. Each question draws a kind by its weight, then
/// a verb that fits the kind, then one of its cells, so that a cell restricted to a few verbs, such
/// as the Präteritum of sein, haben, and the modals, is never asked of another verb. A kind that
/// no verb of the scope fits is left out.
enum QuizDraw {
  /// With `distinctCells`, for a quiz as short as three questions on a verb's page, no cell is
  /// asked twice and no participle is asked, since every Perfekt among the questions tests the
  /// participle anyway.
  static func questions(
    level: QuizLevel,
    verbs: [Verb],
    readingIndex: Int?,
    count: Int,
    distinctCells: Bool,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizDrawnQuestion] {
    var candidatesByVerbs: [QuizVerbs: [Candidate]] = [:]
    let kinds: [Kind] = level.pool.compactMap { entry in
      if distinctCells, entry.isParticiple {
        return nil
      }
      let candidates = candidatesByVerbs[entry.verbs] ?? candidates(of: verbs, admittedBy: entry.verbs, readingIndex: readingIndex)
      candidatesByVerbs[entry.verbs] = candidates
      return candidates.isEmpty ? nil : Kind(entry: entry, candidates: candidates)
    }
    guard !kinds.isEmpty, count > 0 else {
      return []
    }

    guard distinctCells else {
      return (0..<count).compactMap { _ in
        question(from: kinds, using: &generator)
      }
    }

    var questions: [QuizDrawnQuestion] = []
    var attempts = 0
    while questions.count < count, attempts < count * 20 {
      if let question = question(from: kinds, using: &generator),
         !questions.contains(where: { $0.conjugationgroup == question.conjugationgroup }) {
        questions.append(question)
      }
      attempts += 1
    }
    return questions
  }

  private struct Candidate {
    let verb: Verb
    let readingIndices: [Int]
  }

  private struct Kind {
    let entry: QuizPoolEntry
    let candidates: [Candidate]
  }

  private static func candidates(of verbs: [Verb], admittedBy quizVerbs: QuizVerbs, readingIndex: Int?) -> [Candidate] {
    verbs.compactMap { verb in
      let indices = (readingIndex.map { [$0] } ?? Array(verb.readings.indices)).filter { index in
        guard let reading = verb.reading(at: index) else {
          return false
        }
        return quizVerbs.admits(verb, reading: reading)
      }
      return indices.isEmpty ? nil : Candidate(verb: verb, readingIndices: indices)
    }
  }

  private static func question(from kinds: [Kind], using generator: inout some RandomNumberGenerator) -> QuizDrawnQuestion? {
    let totalWeight = kinds.reduce(0) { $0 + $1.entry.weight }
    guard totalWeight > 0 else {
      return nil
    }
    var roll = Int.random(in: 0..<totalWeight, using: &generator)
    guard let kind = kinds.first(where: { kind in
      if roll < kind.entry.weight {
        return true
      }
      roll -= kind.entry.weight
      return false
    }),
      let candidate = kind.candidates.randomElement(using: &generator),
      let readingIndex = candidate.readingIndices.randomElement(using: &generator),
      let conjugationgroup = kind.entry.cells.randomElement(using: &generator) else {
      return nil
    }
    return QuizDrawnQuestion(verb: candidate.verb, conjugationgroup: conjugationgroup, readingIndex: readingIndex)
  }
}

/// Lets `Quiz` hold either the system's generator or a seeded one for tests.
struct AnyRandomNumberGenerator: RandomNumberGenerator {
  private var base: any RandomNumberGenerator

  init(_ base: any RandomNumberGenerator) {
    self.base = base
  }

  mutating func next() -> UInt64 {
    base.next()
  }
}
