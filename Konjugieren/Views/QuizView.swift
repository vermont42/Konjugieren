// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct QuizView: View {
  @Environment(Quiz.self) var quiz
  @State private var userInput = ""
  @FocusState private var isTextFieldFocused: Bool

  private var settings: Settings { Current.settings }

  var body: some View {
    @Bindable var quiz = quiz

    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Text(L.Navigation.quiz)
          .subheadingLabel()
          .padding(.horizontal, Layout.doubleDefaultSpacing)
          .padding(.top, Layout.tripleDefaultSpacing)

        if quiz.isInProgress, let question = quiz.currentQuestion {
          quizContent(question: question)
        }

        Spacer()

        HStack {
          Spacer()
          if quiz.isInProgress {
            Button(L.Quiz.quit) {
              quiz.quit()
            }
            .funButton()
          } else if !quiz.shouldShowResults {
            Button(L.Quiz.start) {
              quiz.start()
            }
            .funButton()
          }
          Spacer()
        }
        .padding(.bottom, Layout.tripleDefaultSpacing)
      }
    }
    .sheet(isPresented: $quiz.shouldShowResults) {
      ResultsView(quiz: quiz)
    }
    .onChange(of: quiz.currentIndex) {
      userInput = ""
      isTextFieldFocused = true
    }
  }

  @ViewBuilder
  private func quizContent(question: QuizItem) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text("\(L.Quiz.verb) \(question.verb.infinitiv)")

      Text("\(L.Quiz.translation) \(question.verb.translation)")

      if let pronoun = question.pronoun {
        Text("\(L.Quiz.pronoun) \(pronoun)")
      }

      Text("\(L.Quiz.conjugationgroup) \(question.displayName(lang: settings.conjugationgroupLang))")
        .fixedSize(horizontal: false, vertical: true)

      HStack {
        Text("\(L.Quiz.progress) \(quiz.progressText)")
        Spacer()
        Text("\(L.Quiz.score) \(quiz.score)")
      }

      Text("\(L.Quiz.elapsed) \(quiz.elapsedText)")

      if let lastIncorrect = quiz.lastIncorrectAnswer, let lastCorrect = quiz.lastCorrectAnswer {
        Text("\(L.Quiz.lastAnswer) \(lastIncorrect)")
          .foregroundStyle(.customYellow)

        HStack(spacing: 4) {
          Text(L.Quiz.correctAnswer)
          Text(mixedCaseString: lastCorrect)
        }
      }

      TextField(L.Quiz.conjugation, text: $userInput)
        .textFieldStyle(.roundedBorder)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .focused($isTextFieldFocused)
        .onSubmit {
          guard !userInput.isEmpty else { return }
          quiz.submitAnswer(userInput)
        }
    }
    .padding(.horizontal, Layout.doubleDefaultSpacing)
    .padding(.top, Layout.doubleDefaultSpacing)
  }
}

#Preview {
  QuizView()
    .environment(Quiz())
}
