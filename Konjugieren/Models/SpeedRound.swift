// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The Speed Round (Phase 21 of the pedagogy plan, T5.7): sixty seconds of questions on what the
/// practice record says is mastered, counting right answers. It is Paul Nation's fluency strand,
/// speed for material already accurate, and the one place the quiz's clock counts.
///
/// The round leaves the record untouched. A miss does not send an item down the ladder, since
/// speed errors are often haste (Josh, 2026-11-13), and a record that counted only a timed
/// round's hits would be one-sided (Josh, 2026-11-15).
enum SpeedRound {
  /// Seconds in a round (Josh, 2026-11-13).
  static let duration = 60

  /// The round opens once this many items are mastered, and repeats them as a round needs (Josh,
  /// 2026-11-15).
  static let minimumMasteredCount = 5

  /// Questions drawn at a time. The round draws more as it reaches the last of them, since nobody
  /// knows in advance how many a learner answers in a minute.
  static let batchSize = 10

  /// VoiceOver hears how much time is left at this many seconds.
  static let warningSecondsLeft = 10

  /// The mastered items a round can ask, in key order, so that a seeded draw is the same in every
  /// process.
  static func masteredItems(in record: PracticeRecord) -> [PracticeItem] {
    record.entries
      .filter { $0.value.schedule.box >= MasteryState.masteredBox }
      .keys
      .sorted()
      .compactMap(PracticeItem.init(key:))
      .filter(\.isAskable)
  }
}

extension QuizScope {
  /// The Speed Round, from the hub's Exercises. Never ranked, never continued, and mixing in
  /// nothing.
  static func speedRound() -> QuizScope {
    QuizScope(verbs: nil, readingIndex: nil, questionCount: SpeedRound.batchSize, source: .speedRound, isSpeedRound: true)
  }
}

extension QuizDraw {
  /// `count` questions on mastered items, each item asked once before any is asked again, and never
  /// the same item twice running, `previous` included, which is the last question of the batch
  /// before. A key conjugation asks any cell of its stem that the level asks, as Phase 11's mapping
  /// credits them, or its own er cell, which is what was mastered: mastered fuhr can ask du fuhrst
  /// (Josh, 2026-11-15). A pattern asks its cell of a weak verb from `verbs`, the level's band, a
  /// fresh one each time it comes back. Neither is held to the level otherwise, since a mastered item
  /// stays mastered when the level changes.
  static func speedRoundQuestions(
    for items: [PracticeItem],
    pool: [QuizPoolEntry],
    verbs: [Verb],
    count: Int,
    after previous: PracticeItem? = nil,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizDrawnQuestion] {
    var weakVerbs: [(verb: Verb, readingIndices: [Int])]?
    var askable = items
    var drawn: [QuizDrawnQuestion] = []
    var last = previous

    func question(for item: PracticeItem) -> QuizDrawnQuestion? {
      switch item {
      case let .keyConjugation(_, readingIndex, stem):
        guard let verb = item.verb, let reading = verb.reading(at: readingIndex) else {
          return nil
        }
        let cells = speedRoundCells(of: stem, verb: verb, reading: reading, pool: pool)
        guard let cell = cells.randomElement(using: &generator) else {
          return nil
        }
        return QuizDrawnQuestion(verb: verb, conjugationgroup: cell, readingIndex: readingIndex)
      case .pattern:
        guard let cell = item.conjugationgroup else {
          return nil
        }
        let candidates = weakVerbs ?? verbs.compactMap { verb in
          let indices = verb.readings.indices.filter { index in
            verb.reading(at: index).map { !isStrong($0) } ?? false
          }
          return indices.isEmpty ? nil : (verb, indices)
        }
        weakVerbs = candidates
        guard let match = candidates.randomElement(using: &generator),
              let readingIndex = match.readingIndices.randomElement(using: &generator) else {
          return nil
        }
        return QuizDrawnQuestion(verb: match.verb, conjugationgroup: cell, readingIndex: readingIndex)
      }
    }

    while drawn.count < count, !askable.isEmpty {
      var cycle = askable.shuffled(using: &generator)
      if cycle.count > 1, let last, cycle.first == last {
        cycle.swapAt(0, Int.random(in: 1..<cycle.count, using: &generator))
      }
      for item in cycle where drawn.count < count {
        guard let question = question(for: item) else {
          askable.removeAll { $0 == item }
          continue
        }
        drawn.append(question)
        last = item
      }
    }
    return drawn
  }

  /// The cells a mastered key conjugation can ask: its own, and every cell of the level's
  /// conjugationgroups built on the same stem that the level asks of this verb.
  static func speedRoundCells(of stem: PracticeItem.Stem, verb: Verb, reading: Reading, pool: [QuizPoolEntry]) -> [Conjugationgroup] {
    var cells = [stem.keyConjugationgroup]
    for entry in pool where PracticeItem.Stem(entry.table) == stem && entry.verbs.admits(verb, reading: reading) {
      cells += entry.cells.filter { !cells.contains($0) }
    }
    return cells
  }
}
