// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct ResultsView: View {
  let quiz: Quiz
  private var settings: Settings { Current.settings }
  @State private var displayedScore = 0

  private var scoreColor: Color {
    // A right second attempt earns half the points, and half the credit here.
    let percentage = (Double(quiz.correctCount) + Double(quiz.secondAttemptCount) / 2) / Double(quiz.questionCount)
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
            .accessibilityIdentifier("results_score")

          HStack(spacing: Layout.doubleDefaultSpacing) {
            Text(label: L.Quiz.correct, value: "\(quiz.correctCount) / \(quiz.questionCount)")
              .font(.caption.monospacedDigit())
            if quiz.secondAttemptCount > 0 {
              Text(label: L.Quiz.secondTry, value: "\(quiz.secondAttemptCount)")
                .font(.caption.monospacedDigit())
                .accessibilityIdentifier("results_second_try")
            }
            Text(label: L.Quiz.level, value: quiz.level.localizedName)
              .font(.caption)
            Text(label: L.Quiz.time, value: TimeFormatter.formatIntTime(quiz.elapsedSeconds))
              .font(.caption.monospacedDigit())
          }
          .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity)
        .konjCard()
        .padding(.horizontal, Layout.doubleDefaultSpacing)
        .padding(.top, Layout.tripleDefaultSpacing)

        if quiz.scope.isRanked, Current.gameCenter.isAuthenticated {
          Button(L.GameCenter.viewLeaderboard) {
            Current.gameCenter.showLeaderboard()
          }
          .funButton()
          .frame(maxWidth: .infinity)
          .padding(.top, Layout.defaultSpacing)
          .accessibilityHint(L.Accessibility.leaderboardHint)
        }

        GradientDivider()
          .padding(.horizontal, Layout.doubleDefaultSpacing)
          .padding(.top, Layout.defaultSpacing)

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
      ? "\(question.verb.infinitiv.inUserRegion) \u{2717}"
      : question.verb.infinitiv.inUserRegion

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

      if question.state == .correctOnSecondAttempt, let firstAttempt = question.firstAttempt {
        HStack(spacing: 0) {
          Text(L.Quiz.firstTry + " ")
            .foregroundStyle(.customYellow)
          Text(verbatim: firstAttempt)
            .foregroundStyle(QuizItem.State.correctOnSecondAttempt.dotColor)
            .germanPronunciation()
        }
        .font(.caption)
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
