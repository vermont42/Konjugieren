// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The shape of an expected answer: the blanks the learner fills, and the words around them that
/// the learner does not type. `ihr ______` settles that the pronoun is not part of the answer, and
/// `______ Sie ______!` settles where a separable prefix goes. Phase 15's key conjugations and
/// Phase 18's sentence frames of the pedagogy plan are the same idea with more blanks.
struct AnswerFrame: Equatable {
  enum Segment: Equatable {
    /// Who an Imperativ addresses, shown as (du) or (ihr). The du and ihr imperatives take no
    /// pronoun, but the learner must still know which one is asked.
    case addressee(String)
    case blank
    /// Which sie a third-person question means, since the one pronoun asks for two conjugations.
    case number(isPlural: Bool)
    /// A subject pronoun in front of the answer, which the learner does not type.
    case pronoun(String)
    case punctuation(String)
    /// A word of the answer that the frame supplies, such as the Sie in kommen Sie an.
    case word(String)
  }

  let segments: [Segment]

  var blankCount: Int {
    segments.filter { $0 == .blank }.count
  }

  /// The answer that a set of filled blanks gives, ready for `QuizItem.accepts`: the blanks and
  /// the frame's own words of the answer, in order. A pronoun the frame shows in front of the
  /// answer is not part of it, so a learner who types it anyway is still right.
  func answer(filling blanks: [String]) -> String {
    var blankIndex = 0
    var words: [String] = []
    for segment in segments {
      switch segment {
      case .blank:
        words.append(blanks.indices.contains(blankIndex) ? blanks[blankIndex] : "")
        blankIndex += 1
      case .word(let word):
        words.append(word)
      case .addressee, .number, .pronoun, .punctuation:
        break
      }
    }
    return words
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
      .joined(separator: " ")
  }

  /// Where Return goes from a blank: the next empty blank after it, wrapping around, or nil when
  /// every blank is filled and Return should submit. A blank holding only spaces is empty.
  func blankAfterReturn(from index: Int, blanks: [String]) -> Int? {
    guard blankCount > 0 else {
      return nil
    }
    let isEmpty: (Int) -> Bool = { blankIndex in
      !blanks.indices.contains(blankIndex) || blanks[blankIndex].trimmingCharacters(in: .whitespaces).isEmpty
    }
    for offset in 1...blankCount {
      let candidate = (index + offset) % blankCount
      if isEmpty(candidate) {
        return candidate
      }
    }
    return nil
  }

  /// The frame for one quiz question.
  ///
  /// Only the wir and Sie imperatives put a pronoun inside the answer, after the verb, and a
  /// separable prefix goes after the pronoun (stoßen Sie um), so those alone take two blanks.
  /// Every other answer is one blank. In particular, a separable verb's Präsens stays one blank,
  /// since the quiz accepts both the main clause's kommt an and the subordinate clause's ankommt,
  /// and two blanks would make the second awkward to type. The Imperativ has no subordinate
  /// clause, so its two blanks rule out nothing that is right.
  ///
  /// - Parameters:
  ///   - isSeparable: Whether the asked reading detaches a prefix in the Imperativ. This reveals
  ///     separability for a prefix that can go either way, such as um- in umfahren and umstoßen;
  ///     Josh accepted that hint on 2026-11-13, since the quiz is practice.
  ///   - thirdSingularPronoun: The er, sie, or es that the settings choose.
  static func quizFrame(for conjugationgroup: Conjugationgroup, isSeparable: Bool, thirdSingularPronoun: String) -> AnswerFrame {
    switch conjugationgroup {
    case .präsenspartizip, .perfektpartizip:
      return AnswerFrame(segments: [.blank])

    case .imperativ(let personNumber):
      switch personNumber {
      case .secondSingular, .secondPlural:
        return AnswerFrame(segments: [.addressee(personNumber == .secondSingular ? "du" : "ihr"), .blank, .punctuation("!")])
      case .firstPlural, .thirdPlural:
        let pronoun = personNumber == .firstPlural ? "wir" : "Sie"
        if isSeparable {
          return AnswerFrame(segments: [.blank, .word(pronoun), .blank, .punctuation("!")])
        }
        return AnswerFrame(segments: [.blank, .word(pronoun), .punctuation("!")])
      case .firstSingular, .thirdSingular:
        return AnswerFrame(segments: [.blank, .punctuation("!")])
      }

    case .präsensIndikativ(let personNumber), .präsensKonjunktivI(let personNumber),
      .präteritumIndikativ(let personNumber), .präteritumKonjunktivII(let personNumber),
      .perfektIndikativ(let personNumber), .perfektKonjunktivI(let personNumber),
      .plusquamperfektIndikativ(let personNumber), .plusquamperfektKonjunktivII(let personNumber),
      .futurIndikativ(let personNumber), .futurKonjunktivI(let personNumber), .futurKonjunktivII(let personNumber):
      switch personNumber {
      case .firstSingular:
        return AnswerFrame(segments: [.pronoun("ich"), .blank])
      case .secondSingular:
        return AnswerFrame(segments: [.pronoun("du"), .blank])
      case .thirdSingular:
        if thirdSingularPronoun == "sie" {
          return AnswerFrame(segments: [.pronoun("sie"), .number(isPlural: false), .blank])
        }
        return AnswerFrame(segments: [.pronoun(thirdSingularPronoun), .blank])
      case .firstPlural:
        return AnswerFrame(segments: [.pronoun("wir"), .blank])
      case .secondPlural:
        return AnswerFrame(segments: [.pronoun("ihr"), .blank])
      case .thirdPlural:
        return AnswerFrame(segments: [.pronoun("sie"), .number(isPlural: true), .blank])
      }
    }
  }
}
