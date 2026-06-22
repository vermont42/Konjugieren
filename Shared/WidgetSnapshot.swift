// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct WidgetSnapshot: Codable, Equatable {
  let infinitiv: String
  let translation: String
  let familyDisplay: String
  let auxiliary: String
  let frequency: Int
  let präsensParadigm: [WidgetConjugation]
  let perfektpartizip: String
  let etymologySnippet: String?
  let exampleGerman: String?
  let exampleEnglish: String?
  let exampleSource: String?
  let quizQuestion: WidgetQuizQuestion
  let dateString: String
  let debugOffset: Int

  // präsensParadigm is written in PersonNumber.allCases order (fs/ss/ts/fp/sp/tp),
  // so the third-person-singular row is always at index 2.
  var thirdSingularConjugation: WidgetConjugation? {
    präsensParadigm.indices.contains(2) ? präsensParadigm[2] : nil
  }
}

struct WidgetConjugation: Codable, Equatable {
  let pronoun: String
  let mixedCaseForm: String
}

struct WidgetQuizQuestion: Codable, Equatable {
  let infinitiv: String
  let conjugationgroupDisplay: String
  let pronoun: String?
  let correctAnswer: String
  let wrongAnswers: [String]
  let questionID: String
}
