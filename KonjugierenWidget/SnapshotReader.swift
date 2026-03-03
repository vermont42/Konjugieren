// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum SnapshotReader {
  static func read() -> WidgetSnapshot? {
    guard let url = WidgetConstants.snapshotURL,
          let data = try? Data(contentsOf: url),
          let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    else {
      return nil
    }
    return snapshot
  }

  static var placeholder: WidgetSnapshot {
    WidgetSnapshot(
      infinitiv: "gehen",
      translation: "go, walk",
      familyDisplay: "strong",
      auxiliary: "sein",
      frequency: 1,
      präsensParadigm: [
        WidgetConjugation(pronoun: "ich", mixedCaseForm: "gehe"),
        WidgetConjugation(pronoun: "du", mixedCaseForm: "gEHst"),
        WidgetConjugation(pronoun: "er", mixedCaseForm: "gEHt"),
        WidgetConjugation(pronoun: "wir", mixedCaseForm: "gehen"),
        WidgetConjugation(pronoun: "ihr", mixedCaseForm: "gEHt"),
        WidgetConjugation(pronoun: "sie", mixedCaseForm: "gehen")
      ],
      perfektpartizip: "gegAngen",
      etymologySnippet: "From Old High German gan, gangan.",
      exampleGerman: "Er geht jeden Morgen zur Arbeit.",
      exampleEnglish: "He goes to work every morning.",
      exampleSource: "Example",
      quizQuestion: WidgetQuizQuestion(
        infinitiv: "gehen",
        conjugationgroupDisplay: "Present Indicative",
        pronoun: "ich",
        correctAnswer: "gehe",
        wrongAnswers: ["geht", "gehen", "gehst"],
        questionID: "placeholder"
      ),
      dateString: "2026-01-01",
      debugOffset: 0
    )
  }
}
