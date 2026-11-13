// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
struct AnswerDifferenceTests {
  private func marked(_ text: String, _ marks: [Bool]) -> String {
    String(zip(Array(text), marks).compactMap { $1 ? $0 : nil })
  }

  @Test func aMissingUmlautIsMarkedOnBothSides() {
    let difference = AnswerDifference.between(given: "fahrt", expected: "fÄhrt")

    #expect(difference.givenMarks == [false, true, false, false, false])
    #expect(difference.expectedMarks == [false, true, false, false, false])
    #expect(difference.expectedMarkedLetters == ["ä"])
  }

  @Test func aMissingLetterIsMarkedOnlyInTheRightAnswer() {
    let difference = AnswerDifference.between(given: "komst", expected: "kommst")

    #expect(!difference.givenMarks.contains(true))
    #expect(marked(difference.expected, difference.expectedMarks) == "m")
  }

  @Test func anExtraLetterIsMarkedOnlyInTheLearnersAnswer() {
    let difference = AnswerDifference.between(given: "kommmst", expected: "kommst")

    #expect(marked(difference.given, difference.givenMarks) == "m")
    #expect(!difference.expectedMarks.contains(true))
  }

  @Test func aSwapMarksBothLettersOnBothSides() {
    let difference = AnswerDifference.between(given: "gehne", expected: "gehen")

    #expect(marked(difference.given, difference.givenMarks) == "ne")
    #expect(marked(difference.expected, difference.expectedMarks) == "en")
  }

  // The capitals of a conjugation are its red letters, not a difference.
  @Test(arguments: [("sang", "sAng"), ("Kommt An", "kommt an"), ("weiß", "wEIẞ")])
  func caseIsNotADifference(given: String, expected: String) {
    let difference = AnswerDifference.between(given: given, expected: expected)

    #expect(!difference.givenMarks.contains(true))
    #expect(!difference.expectedMarks.contains(true))
    #expect(difference.givenMarks.count == given.count)
    #expect(difference.expectedMarks.count == expected.count)
  }

  @Test func aStrongVerbMadeWeakMarksTheVowelAndTheEnding() {
    let difference = AnswerDifference.between(given: "singte", expected: "sAng")

    #expect(marked(difference.given, difference.givenMarks) == "ite")
    #expect(marked(difference.expected, difference.expectedMarks) == "A")
  }

  @Test func anEmptyAnswerMarksTheWholeRightAnswer() {
    let difference = AnswerDifference.between(given: "", expected: "geht")

    #expect(difference.givenMarks.isEmpty)
    #expect(difference.expectedMarks == [true, true, true, true])
  }

  @Test func aCorrectionShowsTheNearerWordOrder() {
    let item = Quiz().makeQuizItem(verb: Verb.verbs["ankommen"]!, conjugationgroup: .präsensIndikativ(.thirdSingular), readingIndex: 0)

    #expect(item.difference(from: "ankomt").expected == "ankommt")
    #expect(item.difference(from: "komt an").expected == "kommt an")
  }

  @Test func aCorrectionDropsTheAskedPronounAndKeepsTheLearnersCapitals() {
    let item = Quiz().makeQuizItem(verb: Verb.verbs["ferngucken"]!, conjugationgroup: .perfektIndikativ(.secondPlural), readingIndex: 0)
    let difference = item.difference(from: "Ihr  Habt geguckt")

    #expect(difference.given == "Habt geguckt")
    #expect(difference.expected == item.correctAnswer)
  }

  @Test func aCorrectionKeepsAnotherPersonsPronoun() {
    let item = Quiz().makeQuizItem(verb: Verb.verbs["machen"]!, conjugationgroup: .präsensIndikativ(.firstSingular), readingIndex: 0)

    #expect(item.difference(from: "du machst").given == "du machst")
  }
}
