// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The spellings of a quiz answer that the quiz accepts beyond the conjugation as the conjugator
/// writes it. Search folds far more loosely (`VerbSearch.fold` reads fahrt as fährt), which is
/// right for finding a verb and wrong for grading one.
enum AnswerSpelling {
  /// Case and runs of whitespace are not part of an answer: "  Kommt   an " is kommt an.
  nonisolated static func normalized(_ answer: String) -> String {
    answer.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased()
  }

  nonisolated private static let digraphs: [Character: String] = ["ä": "ae", "ö": "oe", "ü": "ue"]

  /// Every way to write a lowercased conjugation with any of its umlauts as a digraph, the
  /// conjugation itself included: übernähme gives übernähme, uebernähme, übernaehme, and
  /// uebernaehme. The expansion runs from the umlaut to the digraph and never the other way, so
  /// a genuine ue, as in baue, cannot be typed as baü, and a missing umlaut stays wrong.
  nonisolated static func digraphSpellings(of conjugation: String) -> Set<String> {
    var spellings = [""]
    for character in conjugation {
      if let digraph = digraphs[character] {
        spellings = spellings.flatMap { [$0 + String(character), $0 + digraph] }
      } else {
        spellings = spellings.map { $0 + String(character) }
      }
    }
    return Set(spellings)
  }

  /// Two accepted spellings with the same key differ only in how they write the umlauts and ß.
  /// For deciding whether to show a learner the conjugation's own spelling, never for grading.
  nonisolated static func orthographicKey(_ text: String) -> String {
    var key = text.lowercased()
    for (from, to) in [("ä", "ae"), ("ö", "oe"), ("ü", "ue"), ("ß", "ss")] {
      key = key.replacingOccurrences(of: from, with: to)
    }
    return key
  }

  /// The pronouns a learner may type before an answer in a given cell: ihr habt ferngeguckt is
  /// the Perfekt for ihr, pronoun and all. The Imperativ takes none, since its wir and Sie
  /// conjugations already contain theirs after the verb (steigen wir nach), and a pronoun in
  /// front of a du or ihr imperative is not German. Every third-person singular pronoun matches
  /// that person, whichever one the settings show.
  nonisolated static func leadingPronouns(for conjugationgroup: Conjugationgroup) -> [String] {
    switch conjugationgroup {
    case .präsenspartizip, .perfektpartizip, .imperativ:
      return []
    case .präsensIndikativ(let personNumber), .präsensKonjunktivI(let personNumber),
      .präteritumIndikativ(let personNumber), .präteritumKonjunktivII(let personNumber),
      .perfektIndikativ(let personNumber), .perfektKonjunktivI(let personNumber),
      .plusquamperfektIndikativ(let personNumber), .plusquamperfektKonjunktivII(let personNumber),
      .futurIndikativ(let personNumber), .futurKonjunktivI(let personNumber), .futurKonjunktivII(let personNumber):
      switch personNumber {
      case .firstSingular:
        return ["ich"]
      case .secondSingular:
        return ["du"]
      case .thirdSingular:
        return ["er", "sie", "es"]
      case .firstPlural:
        return ["wir"]
      case .secondPlural:
        return ["ihr"]
      case .thirdPlural:
        return ["sie"]
      }
    }
  }

  /// A normalized answer, then the same answer without a leading pronoun that matches the cell.
  nonisolated static func candidates(for answer: String, in conjugationgroup: Conjugationgroup) -> [String] {
    let normalized = normalized(answer)
    var candidates = [normalized]
    for pronoun in leadingPronouns(for: conjugationgroup) where normalized.hasPrefix(pronoun + " ") {
      candidates.append(String(normalized.dropFirst(pronoun.count + 1)))
    }
    return candidates
  }
}
