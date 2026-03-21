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
            Text(labeledText(label: L.Quiz.correct, value: "\(quiz.correctCount) / \(Quiz.questionCount)"))
              .font(.caption.monospacedDigit())
            Text(labeledText(label: quiz.difficultyText, value: L.Quiz.difficulty))
              .font(.caption)
            Text(labeledText(label: L.Quiz.time, value: TimeFormatter.formatIntTime(quiz.elapsedSeconds)))
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

    VStack(alignment: .center, spacing: 4) {
      Group {
        if question.isCorrect == false {
          Text(verbatim: "\(question.verb.infinitiv) \u{2717}")
        } else {
          Text(verbatim: question.verb.infinitiv)
        }
      }
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

  private func labeledText(label: String, value: String) -> AttributedString {
    var result = AttributedString()

    var labelAttr = AttributedString(label + " ")
    labelAttr.foregroundColor = Color.customYellow
    result.append(labelAttr)

    var valueAttr = AttributedString(value)
    valueAttr.foregroundColor = Color.customForeground
    result.append(valueAttr)

    return result
  }
}

#Preview {
  let quiz = Quiz()
  quiz.start()
  return ResultsView(quiz: quiz)
}
