// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct QuizWidgetView: View {
  let entry: QuizEntry

  private var quiz: WidgetQuizQuestion {
    entry.snapshot.quizQuestion
  }

  var body: some View {
    if entry.isAnswered {
      answeredView
    } else {
      questionView
    }
  }

  private var questionView: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(quiz.conjugationgroupDisplay)
        .font(.system(size: 9))
        .foregroundStyle(.secondary)
        .lineLimit(1)

      HStack(spacing: 3) {
        Text(quiz.infinitiv)
          .font(.caption)
          .fontWeight(.bold)
        if let pronoun = quiz.pronoun {
          Text("(\(pronoun))")
            .font(.system(size: 10))
            .foregroundStyle(.secondary)
        }
      }
      .lineLimit(1)
      .minimumScaleFactor(0.4)

      Spacer(minLength: 0)

      VStack(spacing: 2) {
        ForEach(quiz.shuffledAnswers, id: \.self) { answer in
          answerButton(answer: answer)
        }
      }
    }
    .widgetURL(URL(string: "konjugieren://verb/\(quiz.infinitiv)"))
  }

  private var answeredView: some View {
    VStack(spacing: 8) {
      Image(systemName: entry.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
        .font(.largeTitle)
        .foregroundStyle(entry.wasCorrect ? .green : .red)

      Text(entry.wasCorrect ? WidgetL.Quiz.correct : WidgetL.Quiz.incorrect)
        .font(.headline)

      if !entry.wasCorrect {
        Text(quiz.correctAnswer)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundStyle(.green)
      }
    }
    .widgetURL(URL(string: "konjugieren://verb/\(quiz.infinitiv)"))
  }

  private func answerButton(answer: String) -> some View {
    Button(intent: AnswerQuizIntent(selectedAnswer: answer, questionID: quiz.questionID)) {
      Text(answer)
        .font(.caption2)
        .fontWeight(.medium)
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(.fill.quaternary, in: Capsule())
    }
    .buttonStyle(.plain)
  }
}
