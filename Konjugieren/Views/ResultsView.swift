// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct ResultsView: View {
  let quiz: Quiz
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
          .accessibilityAddTraits(.isHeader)

        VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
          Text("\(L.Quiz.score) \(quiz.finalScore)")
          Text("\(L.Quiz.correct) \(quiz.correctCount) / \(Quiz.questionCount)")
          Text("\(quiz.difficultyText) \(L.Quiz.difficulty)")
          Text("\(L.Quiz.time) \(TimeFormatter.formatIntTime(quiz.elapsedSeconds))")
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
        .padding(.top, Layout.doubleDefaultSpacing)
        .accessibilityElement(children: .combine)

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
}

#Preview {
  let quiz = Quiz()
  quiz.start()
  return ResultsView(quiz: quiz)
}
