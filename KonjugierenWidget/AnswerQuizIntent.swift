// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents
import WidgetKit

struct AnswerQuizIntent: AppIntent {
  static let title: LocalizedStringResource = "Answer Quiz"

  @Parameter(title: "Selected Answer")
  var selectedAnswer: String

  @Parameter(title: "Question ID")
  var questionID: String

  init() {}

  init(selectedAnswer: String, questionID: String) {
    self.selectedAnswer = selectedAnswer
    self.questionID = questionID
  }

  func perform() async throws -> some IntentResult {
    guard let defaults = WidgetConstants.sharedDefaults else {
      return .result()
    }

    guard let snapshot = SnapshotReader.read() else {
      return .result()
    }

    let isCorrect = selectedAnswer == snapshot.quizQuestion.correctAnswer
    defaults.set(true, forKey: WidgetConstants.quizAnsweredKey)
    defaults.set(isCorrect, forKey: WidgetConstants.quizCorrectKey)
    defaults.set(questionID, forKey: WidgetConstants.quizQuestionIDKey)

    WidgetCenter.shared.reloadTimelines(ofKind: "QuizWidget")
    return .result()
  }
}
