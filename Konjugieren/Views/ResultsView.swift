// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct ResultsView: View {
  let quiz: Quiz
  @Environment(\.dismiss) private var dismiss

  private var settings: Settings { Current.settings }

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Spacer(minLength: Layout.tripleDefaultSpacing)

        Text(L.Quiz.results)
          .subheadingLabel()
          .padding(.horizontal, Layout.doubleDefaultSpacing)

        VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
          Text("\(L.Quiz.score) \(quiz.finalScore)")
          Text("\(L.Quiz.correct) \(quiz.correctCount) / \(Quiz.questionCount)")
          Text("\(quiz.difficultyText) \(L.Quiz.difficulty)")
          Text("\(L.Quiz.time) \(quiz.elapsedSeconds)")
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
        .padding(.top, Layout.doubleDefaultSpacing)

        List {
          ForEach(quiz.questions) { question in
            resultRow(for: question)
              .listRowBackground(Color.customBackground)
          }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)

        Spacer()
      }
    }
  }

  @ViewBuilder
  private func resultRow(for question: QuizItem) -> some View {
    VStack(alignment: .center, spacing: 4) {
      if question.isCorrect == false {
        Text("\(question.verb.infinitiv) \u{2717}")
      } else {
        Text(question.verb.infinitiv)
      }

      Text("\(question.displayName(lang: settings.conjugationgroupLang)) - \(question.pronoun ?? "")")
        .font(.caption)
        .foregroundStyle(.secondary)

      Text(mixedCaseString: question.correctAnswer)

      if question.isCorrect == false, let userAnswer = question.userAnswer {
        Text(userAnswer)
          .foregroundStyle(.customRed)
      }
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  let quiz = Quiz()
  quiz.start()
  return ResultsView(quiz: quiz)
}
