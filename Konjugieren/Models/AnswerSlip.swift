// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// A wrong answer near enough to a right one to earn one more attempt: a typing slip, not a
/// grammatical error.
enum AnswerSlip {
  /// In a shorter answer, one letter off is too large a share of it to call a slip: gib for geb
  /// is a different vowel, not a typo.
  nonisolated static let minimumLetterCount = 4

  /// Whether a normalized answer is one slip from an accepted spelling: one insertion, deletion,
  /// substitution, or swap, or only missing umlauts and ß, however many (ubernahme for
  /// übernähme).
  nonisolated static func isSlip(_ answer: String, of target: String) -> Bool {
    guard answer != target, target.filter({ !$0.isWhitespace }).count >= minimumLetterCount else {
      return false
    }
    return VerbSearch.editDistance(Array(answer), Array(target)) <= 1 || bareSpelling(answer) == bareSpelling(target)
  }

  // Unlike `VerbSearch.fold`, this leaves digraphs alone, since an answer spelling ü as ue is
  // already compared with the target's digraph spellings.
  nonisolated private static func bareSpelling(_ text: String) -> String {
    var bare = text
    for (from, to) in [("ä", "a"), ("ö", "o"), ("ü", "u"), ("ß", "ss")] {
      bare = bare.replacingOccurrences(of: from, with: to)
    }
    return bare
  }
}

extension QuizItem {
  /// Whether a wrong answer is a slip that earns a second attempt. An answer that is itself
  /// another cell of the verb is never one, however near: kommt for kommst is the wrong person,
  /// and musstest for müsstest is the wrong mood.
  func isSlip(_ answer: String) -> Bool {
    guard !accepts(answer) else {
      return false
    }
    let candidates = AnswerSpelling.candidates(for: answer, in: conjugationgroup)
    let isNear = candidates.contains { candidate in
      acceptedSpellings.contains { AnswerSlip.isSlip(candidate, of: $0) }
    }
    guard isNear else {
      return false
    }
    return candidates.allSatisfy { verb.conjugations(matching: $0).isEmpty }
  }
}
