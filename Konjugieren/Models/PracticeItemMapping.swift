// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension PracticeItem {
  /// The item a question exercises. A strong or mixed reading's question exercises the key
  /// conjugation of the stem its cell is built on, judged per reading, as the quiz judges strength.
  /// A weak or -ieren reading's question exercises its cell's pattern, and so does any verb's Futur,
  /// since werden and the infinitive are the same for every verb.
  static func exercised(by conjugationgroup: Conjugationgroup, of verb: Verb, readingIndex: Int) -> PracticeItem {
    let reading = verb.reading(at: readingIndex) ?? verb.primaryReading
    if QuizDraw.isStrong(reading), let stem = Stem(conjugationgroup.table) {
      return .keyConjugation(infinitiv: verb.infinitiv, readingIndex: readingIndex, stem: stem)
    }
    return pattern(of: conjugationgroup)
  }

  static func pattern(of conjugationgroup: Conjugationgroup) -> PracticeItem {
    .pattern(tableKey: conjugationgroup.table.articleKey, person: conjugationgroup.personNumber?.rawValue)
  }

  /// The items a lookup of the verb schedules: the key conjugations of each strong or mixed
  /// reading. A weak verb has none, since its conjugations are patterns (Josh, 2026-11-14).
  static func keyConjugations(of verb: Verb) -> [PracticeItem] {
    verb.readings.indices.flatMap { readingIndex -> [PracticeItem] in
      guard let reading = verb.reading(at: readingIndex), QuizDraw.isStrong(reading) else {
        return []
      }
      return Stem.allCases.map { .keyConjugation(infinitiv: verb.infinitiv, readingIndex: readingIndex, stem: $0) }
    }
  }

  /// The cell a review of the item asks: a key conjugation's own cell, or the pattern's. Nil for a
  /// key this version cannot read.
  var conjugationgroup: Conjugationgroup? {
    switch self {
    case let .keyConjugation(_, _, stem):
      return stem.keyConjugationgroup
    case let .pattern(tableKey, person):
      guard let table = ConjugationTable.allCases.first(where: { $0.articleKey == tableKey }) else {
        return nil
      }
      return table.cells.first { $0.personNumber?.rawValue == person }
    }
  }

  /// The verb a key conjugation belongs to, if it is still in the corpus and the reading is still
  /// strong or mixed. Nil for a pattern.
  var verb: Verb? {
    guard case let .keyConjugation(infinitiv, readingIndex, _) = self,
          let verb = Verb.verbs[infinitiv],
          let reading = verb.reading(at: readingIndex),
          QuizDraw.isStrong(reading) else {
      return nil
    }
    return verb
  }
}

extension PracticeItem.Stem {
  /// The stem a table's cells are built on. Nil for the Futurs, which use the infinitive with
  /// werden or würde and show nothing of a strong verb. The Präsens Konjunktiv I and the
  /// Präsenspartizip are present-stem conjugations, so a slip in er fähre or fahrend counts
  /// against fährt; the Präteritum Konjunktiv II is built on the past stem (führe from fuhr).
  init?(_ table: ConjugationTable) {
    switch table {
    case .imperativ, .präsensIndikativ, .präsensKonjunktivI, .präsenspartizip:
      self = .präsens
    case .präteritumIndikativ, .präteritumKonjunktivII:
      self = .präteritum
    case .perfektIndikativ, .perfektKonjunktivI, .perfektpartizip, .plusquamperfektIndikativ, .plusquamperfektKonjunktivII:
      self = .perfekt
    case .futurIndikativ, .futurKonjunktivI, .futurKonjunktivII:
      return nil
    }
  }

  /// The key conjugation's cell: the er form, as the verb page's key conjugations show it.
  var keyConjugationgroup: Conjugationgroup {
    switch self {
    case .präsens:
      return .präsensIndikativ(.thirdSingular)
    case .präteritum:
      return .präteritumIndikativ(.thirdSingular)
    case .perfekt:
      return .perfektIndikativ(.thirdSingular)
    }
  }
}
