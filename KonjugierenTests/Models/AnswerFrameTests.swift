// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite(.serialized)
@MainActor
struct AnswerFrameTests {
  init() {
    Current.settings.region = .north
    Current.settings.thirdPersonPronounGender = .er
  }

  private func item(_ infinitiv: String, _ conjugationgroup: Conjugationgroup, readingIndex: Int = 0) throws -> QuizItem {
    let verb = try #require(Verb.verbs[infinitiv])
    return Quiz().makeQuizItem(verb: verb, conjugationgroup: conjugationgroup, readingIndex: readingIndex)
  }

  private static let personNumbers: [(PersonNumber) -> Conjugationgroup] = [
    Conjugationgroup.präsensIndikativ,
    Conjugationgroup.präsensKonjunktivI,
    Conjugationgroup.präteritumIndikativ,
    Conjugationgroup.präteritumKonjunktivII,
    Conjugationgroup.perfektIndikativ,
    Conjugationgroup.perfektKonjunktivI,
    Conjugationgroup.plusquamperfektIndikativ,
    Conjugationgroup.plusquamperfektKonjunktivII,
    Conjugationgroup.futurIndikativ,
    Conjugationgroup.futurKonjunktivI,
    Conjugationgroup.futurKonjunktivII
  ]

  /// Every cell the quiz can ask.
  private static var allConjugationgroups: [Conjugationgroup] {
    [.präsenspartizip, .perfektpartizip]
      + personNumbers.flatMap { make in PersonNumber.allCases.map(make) }
      + PersonNumber.imperativPersonNumbers.map(Conjugationgroup.imperativ)
  }

  /// The conjugation cut into the frame's blanks, as a learner who knows it would type it: the
  /// frame's own words come out, and what lies between them goes in the blanks.
  private func blanks(of answer: String, in frame: AnswerFrame) -> [String] {
    let words = frame.segments.compactMap { segment -> String? in
      if case .word(let word) = segment {
        return word
      }
      return nil
    }
    var blanks: [String] = []
    var current: [String] = []
    for token in answer.split(separator: " ").map(String.init) {
      if words.contains(token) {
        blanks.append(current.joined(separator: " "))
        current = []
      } else {
        current.append(token)
      }
    }
    blanks.append(current.joined(separator: " "))
    return blanks.filter { !$0.isEmpty }
  }

  @Test(arguments: ["gehen", "ankommen", "umstoßen", "ferngucken", "sein", "übersetzen"])
  func everyCellHasAFrameThatTheRightAnswerFits(infinitiv: String) throws {
    for conjugationgroup in Self.allConjugationgroups {
      let item = try item(infinitiv, conjugationgroup)
      let frame = item.answerFrame
      let blanks = blanks(of: item.correctAnswer, in: frame)
      #expect(frame.blankCount >= 1, "\(infinitiv) \(conjugationgroup)")
      #expect(blanks.count == frame.blankCount, "\(infinitiv) \(conjugationgroup): \(blanks)")
      #expect(item.accepts(frame.answer(filling: blanks)), "\(infinitiv) \(conjugationgroup): \(blanks)")
    }
  }

  @Test func participlesAreABareBlank() throws {
    #expect(try item("ankommen", .perfektpartizip).answerFrame == AnswerFrame(segments: [.blank]))
    #expect(try item("ankommen", .präsenspartizip).answerFrame == AnswerFrame(segments: [.blank]))
  }

  @Test(arguments: [
    (PersonNumber.firstSingular, AnswerFrame.Segment.pronoun("ich")),
    (.secondSingular, .pronoun("du")),
    (.thirdSingular, .pronoun("er")),
    (.firstPlural, .pronoun("wir")),
    (.secondPlural, .pronoun("ihr"))
  ])
  func finiteCellsPutThePronounOutsideOneBlank(personNumber: PersonNumber, pronoun: AnswerFrame.Segment) throws {
    for conjugationgroup in Self.personNumbers.map({ $0(personNumber) }) {
      #expect(try item("ankommen", conjugationgroup).answerFrame == AnswerFrame(segments: [pronoun, .blank]))
    }
  }

  @Test func thirdPersonSieIsDisambiguated() throws {
    #expect(try item("gehen", .präsensIndikativ(.thirdPlural)).answerFrame == AnswerFrame(segments: [.pronoun("sie"), .number(isPlural: true), .blank]))
    Current.settings.thirdPersonPronounGender = .sie
    #expect(try item("gehen", .präsensIndikativ(.thirdSingular)).answerFrame == AnswerFrame(segments: [.pronoun("sie"), .number(isPlural: false), .blank]))
    Current.settings.thirdPersonPronounGender = .es
    #expect(try item("gehen", .präsensIndikativ(.thirdSingular)).answerFrame == AnswerFrame(segments: [.pronoun("es"), .blank]))
    Current.settings.thirdPersonPronounGender = .er
  }

  @Test func duAndIhrImperativesNameTheirAddressee() throws {
    #expect(try item("ankommen", .imperativ(.secondSingular)).answerFrame == AnswerFrame(segments: [.addressee("du"), .blank, .punctuation("!")]))
    #expect(try item("gehen", .imperativ(.secondPlural)).answerFrame == AnswerFrame(segments: [.addressee("ihr"), .blank, .punctuation("!")]))
  }

  @Test func separableWirAndSieImperativesHaveTwoBlanks() throws {
    #expect(try item("umstoßen", .imperativ(.thirdPlural)).answerFrame == AnswerFrame(segments: [.blank, .word("Sie"), .blank, .punctuation("!")]))
    #expect(try item("nachsteigen", .imperativ(.firstPlural)).answerFrame == AnswerFrame(segments: [.blank, .word("wir"), .blank, .punctuation("!")]))
  }

  @Test func otherWirAndSieImperativesHaveOneBlank() throws {
    #expect(try item("gehen", .imperativ(.thirdPlural)).answerFrame == AnswerFrame(segments: [.blank, .word("Sie"), .punctuation("!")]))
    // übersetzen's first reading, translate, is inseparable.
    #expect(try item("übersetzen", .imperativ(.firstPlural)).answerFrame == AnswerFrame(segments: [.blank, .word("wir"), .punctuation("!")]))
  }

  // The frame follows the asked reading, not the verb: übersetzen in the sense of ferrying
  // across is separable (setzen wir über).
  @Test func theFrameFollowsTheAskedReading() throws {
    let ferry = try item("übersetzen", .imperativ(.firstPlural), readingIndex: 1)
    #expect(ferry.answerFrame == AnswerFrame(segments: [.blank, .word("wir"), .blank, .punctuation("!")]))
    #expect(ferry.accepts(ferry.answerFrame.answer(filling: ["setzen", "über"])))
  }

  @Test func theFrameSuppliesTheImperativPronoun() throws {
    let sie = try item("umstoßen", .imperativ(.thirdPlural))
    #expect(sie.answerFrame.answer(filling: ["stoßen", "um"]) == "stoßen Sie um")
    #expect(sie.accepts(sie.answerFrame.answer(filling: ["stoßen", "um"])))
    #expect(!sie.accepts(sie.answerFrame.answer(filling: ["stoßen", ""])))
    #expect(!sie.accepts(sie.answerFrame.answer(filling: ["um", "stoßen"])))
    let gehen = try item("gehen", .imperativ(.thirdPlural))
    #expect(gehen.accepts(gehen.answerFrame.answer(filling: ["gehen"])))
  }

  // A separable verb's Präsens is one blank, so the subordinate clause's joined conjugation
  // stays as easy to type as the main clause's split one.
  @Test func separablePräsensAcceptsSplitAndJoined() throws {
    let item = try item("ankommen", .präsensIndikativ(.secondPlural))
    #expect(item.accepts(item.answerFrame.answer(filling: ["kommt an"])))
    #expect(item.accepts(item.answerFrame.answer(filling: ["ankommt"])))
  }

  @Test func aPronounTypedInsideTheBlankIsStillRight() throws {
    let item = try item("ankommen", .präsensIndikativ(.secondPlural))
    #expect(item.answerFrame.answer(filling: ["ihr kommt an"]) == "ihr kommt an")
    #expect(item.accepts(item.answerFrame.answer(filling: ["ihr kommt an"])))
  }

  @Test func answerTrimsBlanksAndToleratesMissingOnes() {
    let frame = AnswerFrame(segments: [.blank, .word("Sie"), .blank, .punctuation("!")])
    #expect(frame.answer(filling: ["  stoßen ", " um"]) == "stoßen Sie um")
    #expect(frame.answer(filling: ["stoßen"]) == "stoßen Sie")
    #expect(frame.answer(filling: []) == "Sie")
  }

  @Test func returnWithOneBlankSubmitsOnlyWhenFilled() {
    let frame = AnswerFrame(segments: [.pronoun("ihr"), .blank])
    #expect(frame.blankAfterReturn(from: 0, blanks: []) == 0)
    #expect(frame.blankAfterReturn(from: 0, blanks: ["   "]) == 0)
    #expect(frame.blankAfterReturn(from: 0, blanks: ["kommt an"]) == nil)
  }

  @Test func returnWithTwoBlanksFillsThenSubmits() {
    let frame = AnswerFrame(segments: [.blank, .word("Sie"), .blank, .punctuation("!")])
    #expect(frame.blankAfterReturn(from: 0, blanks: ["stoßen", ""]) == 1)
    #expect(frame.blankAfterReturn(from: 0, blanks: ["stoßen"]) == 1)
    #expect(frame.blankAfterReturn(from: 1, blanks: ["", "um"]) == 0)
    #expect(frame.blankAfterReturn(from: 1, blanks: ["stoßen", "um"]) == nil)
    #expect(frame.blankAfterReturn(from: 0, blanks: ["stoßen", "um"]) == nil)
  }
}
