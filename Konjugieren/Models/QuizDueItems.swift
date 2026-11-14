// Copyright © 2026 Josh Adams. All rights reserved.

/// How a default session mixes in items the practice record says are due, so that a learner who
/// never opens Review still relearns (Josh, 2026-11-13).
extension QuizDraw {
  /// At most this many of a round's questions come from the record.
  static let dueItemLimit = 3

  /// A question for each due item that the level asks and the band holds, in the record's order,
  /// most overdue first, and at most `limit`. A key conjugation asks its own cell of its verb. A
  /// pattern asks its cell of a weak verb from `verbs`. An item the level does not ask, such as a
  /// Präteritum looked up by a Beginner, or a looked-up verb beyond the band, waits for Review
  /// (Phase 12), so that the default quiz stays within its level.
  static func dueQuestions(
    for items: [PracticeItem],
    pool: [QuizPoolEntry],
    verbs: [Verb],
    limit: Int = dueItemLimit,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizDrawnQuestion] {
    recordQuestions(for: items, pool: pool, verbs: verbs, limit: limit, using: &generator).map(\.question)
  }

  /// A question for each item that can be asked, in the items' order, and at most `limit`. With a
  /// `pool`, as for the default quiz, an item must be one the pool asks, and a key conjugation's
  /// verb must be in `verbs`. Without one, as for Review, any item is asked whose verb is still in
  /// the corpus. A pattern always asks its cell of a weak verb from `verbs`.
  static func recordQuestions(
    for items: [PracticeItem],
    pool: [QuizPoolEntry]?,
    verbs: [Verb],
    limit: Int,
    using generator: inout some RandomNumberGenerator
  ) -> [(item: PracticeItem, question: QuizDrawnQuestion)] {
    let bandInfinitives = Set(verbs.map(\.infinitiv))
    var weakVerbs: [(verb: Verb, readingIndices: [Int])]?
    var drawn: [(item: PracticeItem, question: QuizDrawnQuestion)] = []

    func admits(_ cell: Conjugationgroup, _ verb: Verb, _ reading: Reading) -> Bool {
      guard let pool else {
        return true
      }
      return pool.contains { $0.cells.contains(cell) && $0.verbs.admits(verb, reading: reading) }
    }

    for item in items where drawn.count < limit {
      guard let cell = item.conjugationgroup else {
        continue
      }
      switch item {
      case let .keyConjugation(_, readingIndex, _):
        guard let verb = item.verb,
              pool == nil || bandInfinitives.contains(verb.infinitiv),
              let reading = verb.reading(at: readingIndex),
              admits(cell, verb, reading) else {
          continue
        }
        drawn.append((item, QuizDrawnQuestion(verb: verb, conjugationgroup: cell, readingIndex: readingIndex)))
      case .pattern:
        let candidates = weakVerbs ?? verbs.compactMap { verb in
          let indices = verb.readings.indices.filter { index in
            verb.reading(at: index).map { !isStrong($0) } ?? false
          }
          return indices.isEmpty ? nil : (verb, indices)
        }
        weakVerbs = candidates
        let fitting = candidates.compactMap { candidate -> (verb: Verb, readingIndices: [Int])? in
          let indices = candidate.readingIndices.filter { index in
            candidate.verb.reading(at: index).map { admits(cell, candidate.verb, $0) } ?? false
          }
          return indices.isEmpty ? nil : (candidate.verb, indices)
        }
        guard let match = fitting.randomElement(using: &generator),
              let readingIndex = match.readingIndices.randomElement(using: &generator) else {
          continue
        }
        drawn.append((item, QuizDrawnQuestion(verb: match.verb, conjugationgroup: cell, readingIndex: readingIndex)))
      }
    }
    return drawn
  }

  /// The drawn questions with the due ones placed among them at random.
  static func mixing(_ due: [QuizDrawnQuestion], into drawn: [QuizDrawnQuestion], using generator: inout some RandomNumberGenerator) -> [QuizDrawnQuestion] {
    var questions = drawn
    for question in due {
      questions.insert(question, at: Int.random(in: 0...questions.count, using: &generator))
    }
    return questions
  }
}
