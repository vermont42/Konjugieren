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
    let bandInfinitives = Set(verbs.map(\.infinitiv))
    var weakVerbs: [(verb: Verb, readingIndices: [Int])]?
    var questions: [QuizDrawnQuestion] = []

    func admits(_ cell: Conjugationgroup, _ verb: Verb, _ reading: Reading) -> Bool {
      pool.contains { $0.cells.contains(cell) && $0.verbs.admits(verb, reading: reading) }
    }

    for item in items where questions.count < limit {
      guard let cell = item.conjugationgroup else {
        continue
      }
      switch item {
      case let .keyConjugation(_, readingIndex, _):
        guard let verb = item.verb,
              bandInfinitives.contains(verb.infinitiv),
              let reading = verb.reading(at: readingIndex),
              admits(cell, verb, reading) else {
          continue
        }
        questions.append(QuizDrawnQuestion(verb: verb, conjugationgroup: cell, readingIndex: readingIndex))
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
        questions.append(QuizDrawnQuestion(verb: match.verb, conjugationgroup: cell, readingIndex: readingIndex))
      }
    }
    return questions
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
