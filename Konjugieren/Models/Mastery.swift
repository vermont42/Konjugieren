// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// How far up the review ladder an item has come, as the Mastery page shows it (T6.2).
// Semantic ordering: up the ladder.
enum MasteryState: Equatable {
  case notPracticed
  case learning
  case mastered

  /// The third box, whose interval is seven days. Phase 21's speed round draws the same items
  /// (Josh, 2026-11-13).
  static let masteredBox = 2

  init(_ entry: PracticeRecord.Entry?) {
    guard let entry else {
      self = .notPracticed
      return
    }
    self = entry.schedule.box >= Self.masteredBox ? .mastered : .learning
  }
}

extension PracticeRecord {
  func masteryState(of item: PracticeItem) -> MasteryState {
    MasteryState(entry(for: item))
  }
}

/// What the practice record has made secure at a level, in the two kinds of item it keeps
/// (Josh chose the split over a verb-by-conjugationgroup grid on 2026-11-15). A weak verb's cells
/// are patterns that every weak verb shares, so they appear once, as patterns, rather than as a
/// row per weak verb filling in together. A strong verb shows its key conjugations, as far as the
/// level asks them.
struct Mastery {
  /// One cell of a pattern row: a person, or nil for a participle.
  struct PatternCell: Identifiable {
    let conjugationgroup: Conjugationgroup
    let state: MasteryState

    var id: String {
      conjugationgroup.personNumber?.rawValue ?? "participle"
    }
  }

  /// A conjugationgroup's patterns at the level.
  struct PatternRow: Identifiable {
    let table: ConjugationTable
    let cells: [PatternCell]

    var id: String {
      table.articleKey
    }

    /// A Futur's patterns serve every verb, since werden and the infinitive show nothing of a
    /// strong verb. Every other pattern serves the weak verbs alone.
    var servesEveryVerb: Bool {
      PracticeItem.Stem(table) == nil
    }
  }

  /// One key conjugation of a strong reading: fährt, fuhr, or ist gefahren.
  struct KeyConjugation: Identifiable {
    let infinitiv: String
    let readingIndex: Int
    let stem: PracticeItem.Stem
    let state: MasteryState

    var id: String {
      stem.rawValue
    }

    /// Conjugated when shown rather than when counted, since the hub's row needs only the
    /// counts and would otherwise conjugate some 150 cells each time it draws.
    func conjugation(region: Region = Current.settings.region) -> String {
      let result = RegionalConjugator.conjugate(infinitiv: infinitiv, conjugationgroup: stem.keyConjugationgroup, region: region, readingIndex: readingIndex)
      return (try? result.get()) ?? infinitiv
    }
  }

  /// A strong or mixed reading of one of the core verbs. fahren and ziehen, whose two strong
  /// readings take different auxiliaries, have a row for each.
  struct VerbRow: Identifiable {
    let verb: Verb
    let readingIndex: Int
    let keyConjugations: [KeyConjugation]

    var id: String {
      "\(verb.infinitiv):\(readingIndex)"
    }
  }

  /// The verbs the page lists, the same at every level (Josh, 2026-11-15). Beginner's band, the
  /// 100 most frequent verbs, holds 57 strong and mixed verbs, so these 50 are within every
  /// level's band.
  static let coreVerbCount = 50

  let level: QuizLevel
  let patterns: [PatternRow]
  let verbs: [VerbRow]

  init(level: QuizLevel, record: PracticeRecord) {
    self.level = level
    patterns = Self.patternTables(at: level).map { entry in
      PatternRow(
        table: entry.table,
        cells: entry.cells.map { cell in
          PatternCell(conjugationgroup: cell, state: record.masteryState(of: PracticeItem.pattern(of: cell)))
        }
      )
    }
    verbs = Self.coreVerbs.flatMap { verb in
      Self.strongReadingIndices(of: verb).map { readingIndex in
        VerbRow(
          verb: verb,
          readingIndex: readingIndex,
          keyConjugations: Self.stems(askedAt: level, of: verb, readingIndex: readingIndex).map { stem in
            let item = PracticeItem.keyConjugation(infinitiv: verb.infinitiv, readingIndex: readingIndex, stem: stem)
            return KeyConjugation(infinitiv: verb.infinitiv, readingIndex: readingIndex, stem: stem, state: record.masteryState(of: item))
          }
        )
      }
    }
  }

  var patternCount: Int {
    patterns.reduce(0) { $0 + $1.cells.count }
  }

  var masteredPatternCount: Int {
    patterns.reduce(0) { $0 + $1.cells.filter { $0.state == .mastered }.count }
  }

  var verbCount: Int {
    Set(verbs.map(\.verb.infinitiv)).count
  }

  /// A verb counts once every key conjugation the level asks, in every strong reading, is
  /// mastered.
  var masteredVerbCount: Int {
    let byVerb = Dictionary(grouping: verbs, by: \.verb.infinitiv)
    return byVerb.values.filter { rows in
      rows.allSatisfy { row in row.keyConjugations.allSatisfy { $0.state == .mastered } }
    }.count
  }

  /// The 50 most frequent verbs with a strong or mixed reading, the most frequent first.
  static var coreVerbs: [Verb] {
    Array(Verb.verbsSortedByFrequency.lazy.filter { !strongReadingIndices(of: $0).isEmpty }.prefix(coreVerbCount))
  }

  /// The level's conjugationgroups that a weak verb may be asked, whose cells are patterns. A
  /// conjugationgroup restricted to sein, haben, werden, the modals, or strong verbs asks no weak
  /// verb, so it has no pattern to show.
  static func patternTables(at level: QuizLevel) -> [QuizPoolEntry] {
    level.pool.filter { $0.verbs == .all }
  }

  /// The stems the level asks of a strong reading: the Präsens at Beginner, and the Präteritum
  /// at Elementary only for sein, haben, and the modals.
  static func stems(askedAt level: QuizLevel, of verb: Verb, readingIndex: Int) -> [PracticeItem.Stem] {
    guard let reading = verb.reading(at: readingIndex) else {
      return []
    }
    return PracticeItem.Stem.allCases.filter { stem in
      level.pool.contains { entry in
        PracticeItem.Stem(entry.table) == stem && entry.verbs.admits(verb, reading: reading)
      }
    }
  }

  /// Whether every key conjugation of every strong reading is mastered, whatever the level asks,
  /// as the strong-verb achievements count a verb (Phase 23), so that changing the level to
  /// Beginner, which asks only the Präsens, cannot earn one.
  static func isFullyMastered(_ verb: Verb, in record: PracticeRecord) -> Bool {
    let readingIndices = strongReadingIndices(of: verb)
    return !readingIndices.isEmpty && readingIndices.allSatisfy { readingIndex in
      PracticeItem.Stem.allCases.allSatisfy { stem in
        record.masteryState(of: .keyConjugation(infinitiv: verb.infinitiv, readingIndex: readingIndex, stem: stem)) == .mastered
      }
    }
  }

  private static func strongReadingIndices(of verb: Verb) -> [Int] {
    verb.readings.indices.filter { QuizDraw.isStrong(verb.readings[$0]) }
  }
}
