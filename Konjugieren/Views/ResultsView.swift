// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct ResultsView: View {
  let quiz: Quiz
  private var settings: Settings { Current.settings }
  @State private var displayedScore = 0

  private var scoreColor: Color {
    let percentage = Double(quiz.correctCount) / Double(Quiz.questionCount)
    if percentage > 0.8 {
      return .green
    } else if percentage >= 0.5 {
      return .customYellow
    } else {
      return .customRed
    }
  }

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading, spacing: 0) {
        VStack(spacing: Layout.defaultSpacing) {
          Text(L.Quiz.results)
            .subheadingLabel()
            .accessibilityAddTraits(.isHeader)

          Text("\(displayedScore)")
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundStyle(scoreColor)
            .contentTransition(.numericText())
            .accessibilityLabel(Text(verbatim: "\(L.Quiz.score) \(quiz.finalScore)"))

          HStack(spacing: Layout.doubleDefaultSpacing) {
            Text(label: L.Quiz.correct, value: "\(quiz.correctCount) / \(Quiz.questionCount)")
              .font(.caption.monospacedDigit())
            Text(label: quiz.difficultyText, value: L.Quiz.difficulty)
              .font(.caption)
            Text(label: L.Quiz.time, value: TimeFormatter.formatIntTime(quiz.elapsedSeconds))
              .font(.caption.monospacedDigit())
          }
          .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity)
        .padding(Layout.doubleDefaultSpacing)
        .background(Color(.secondarySystemBackground).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, Layout.doubleDefaultSpacing)
        .padding(.top, Layout.tripleDefaultSpacing)

        if Current.gameCenter.isAuthenticated {
          Button(L.GameCenter.viewLeaderboard) {
            Current.gameCenter.showLeaderboard()
          }
          .funButton()
          .frame(maxWidth: .infinity)
          .padding(.top, Layout.defaultSpacing)
          .accessibilityHint(L.Accessibility.leaderboardHint)
        }

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
    .onAppear {
      withAnimation(.easeOut(duration: 0.6)) {
        displayedScore = quiz.finalScore
      }
    }
  }

  @ViewBuilder
  private func resultRow(for question: QuizItem) -> some View {
    let titleIsGerman = settings.conjugationgroupLang == .german

    let infinitivDisplay = question.isCorrect == false
      ? "\(question.verb.infinitiv) \u{2717}"
      : question.verb.infinitiv

    VStack(alignment: .center, spacing: 4) {
      Text(verbatim: infinitivDisplay)
        .germanPronunciation()

      Text(verbatim: "\(question.displayName(lang: settings.conjugationgroupLang)) - \(question.pronoun ?? "")")
        .font(.caption)
        .foregroundStyle(.secondary)
        .germanPronunciation(forReal: titleIsGerman)

      Text(mixedCaseString: question.correctAnswer)
        .germanPronunciation()
        .accessibilityLabel(Text(verbatim: MixedCaseAccessibility.accessibilityLabel(for: question.correctAnswer)))

      if question.isCorrect == false, let userAnswer = question.userAnswer {
        Text(verbatim: userAnswer)
          .foregroundStyle(.customRed)
          .germanPronunciation()
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
