// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct QuizWidgetView: View {
  let entry: QuizEntry
  @Environment(\.widgetFamily) var family

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

      Spacer(minLength: 0)

      let allAnswers = shuffledAnswers
      if family == .systemMedium {
        HStack(spacing: 6) {
          ForEach(allAnswers, id: \.self) { answer in
            answerButton(answer: answer)
          }
        }
      } else {
        VStack(spacing: 2) {
          ForEach(allAnswers, id: \.self) { answer in
            answerButton(answer: answer)
          }
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

      Text(entry.wasCorrect ? "Correct!" : "Incorrect")
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(.fill.quaternary, in: Capsule())
    }
    .buttonStyle(.plain)
  }

  private var shuffledAnswers: [String] {
    var answers = quiz.wrongAnswers
    answers.append(quiz.correctAnswer)
    // Deterministic shuffle based on questionID
    var hasher = Hasher()
    hasher.combine(quiz.questionID)
    let seed = hasher.finalize()
    var rng = SeededRNG(seed: UInt64(bitPattern: Int64(seed)))
    answers.shuffle(using: &rng)
    return answers
  }
}

private struct SeededRNG: RandomNumberGenerator {
  var state: UInt64

  init(seed: UInt64) {
    state = seed
  }

  mutating func next() -> UInt64 {
    state &+= 0x9E3779B97F4A7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
    z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
    return z ^ (z >> 31)
  }
}
