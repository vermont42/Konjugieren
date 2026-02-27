// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct QuizView: View {
  @Environment(Quiz.self) var quiz
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var userInput = ""
  @FocusState private var isTextFieldFocused: Bool
  @AccessibilityFocusState private var isTextFieldA11yFocused: Bool
  private var settings: Settings { Current.settings }
  @State private var currentAnimationAmount = 2.5
  private let initialAnimationAmount = 2.5
  private let animationModifier = 1.5
  private let animationDuration = 2.0

  var body: some View {
    @Bindable var quiz = quiz

    NavigationStack {
      ZStack {
        Color.customBackground
          .ignoresSafeArea()

        VStack {
          ScrollView {
            VStack(alignment: .leading) {
              if quiz.isInProgress, let question = quiz.currentQuestion {
                quizContent(question: question)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          Spacer()

          HStack {
            Spacer()
            if quiz.isInProgress {
              Button(L.Quiz.quit) {
                quiz.quit()
              }
              .funButton()
              .accessibilityHint(L.Accessibility.quizQuitHint)
            } else if !quiz.shouldShowResults {
              Button(L.Quiz.start) {
                quiz.start()
              }
              .onAppear {
                self.currentAnimationAmount = initialAnimationAmount - animationModifier
              }
              .onDisappear {
                self.currentAnimationAmount = initialAnimationAmount
              }
              .scaleEffect(currentAnimationAmount)
              .animation(reduceMotion ? nil : .linear(duration: animationDuration), value: currentAnimationAmount)
              .funButton()
              .accessibilityHint(L.Accessibility.quizStartHint)
            }
            Spacer()
          }
          .padding(.bottom, Layout.tripleDefaultSpacing)
        }
      }
      .onAppear { Current.analytics.signal(name: .viewQuizView) }
      .navigationTitle(L.Navigation.quiz)
    }
    .sheet(isPresented: $quiz.shouldShowResults) {
      ResultsView(quiz: quiz)
    }
    .onChange(of: quiz.currentIndex) {
      userInput = ""
      isTextFieldFocused = true
      isTextFieldA11yFocused = true
    }
  }

  @ViewBuilder
  private func quizContent(question: QuizItem) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack(alignment: .top, spacing: 0) {
        Text(L.Quiz.verb + " ")
          .foregroundStyle(.customYellow)
          .fixedSize(horizontal: true, vertical: false)
        Text(verbatim: question.verb.infinitiv)
          .foregroundStyle(.customForeground)
          .germanPronunciation()
}

      HStack(alignment: .top, spacing: 0) {
        Text(L.Quiz.translation + " ")
          .foregroundStyle(.customYellow)
          .fixedSize(horizontal: true, vertical: false)
        Text(verbatim: question.verb.translation)
          .foregroundStyle(.customForeground)
          .fixedSize(horizontal: false, vertical: true)
          .englishPronunciation()
      }

      if let pronoun = question.pronoun {
        HStack(alignment: .top, spacing: 0) {
          Text(L.Quiz.pronoun + " ")
            .foregroundStyle(.customYellow)
            .fixedSize(horizontal: true, vertical: false)
          Text(verbatim: pronoun)
            .foregroundStyle(.customForeground)
            .germanPronunciation()
        }
      }

      HStack(alignment: .top, spacing: 0) {
        Text(L.Quiz.conjugationgroup + " ")
          .foregroundStyle(.customYellow)
          .fixedSize(horizontal: true, vertical: false)
        Text(verbatim: question.displayName(lang: settings.conjugationgroupLang))
          .foregroundStyle(.customForeground)
          .fixedSize(horizontal: false, vertical: true)
          .germanPronunciation(forReal: settings.conjugationgroupLang == .german)
      }

      HStack {
        Text(labeledText(label: L.Quiz.progress, value: quiz.progressText))
        Spacer()
        Text(labeledText(label: L.Quiz.score, value: "\(quiz.score)"))
      }

      Text(labeledText(label: L.Quiz.elapsed, value: quiz.elapsedText))

      if let lastIncorrect = quiz.lastIncorrectAnswer, let lastCorrect = quiz.lastCorrectAnswer {
        HStack(alignment: .top, spacing: 0) {
          Text(L.Quiz.lastAnswer + " ")
            .foregroundStyle(.customYellow)
            .fixedSize(horizontal: true, vertical: false)
          Text(verbatim: lastIncorrect)
            .foregroundStyle(.customYellow)
            .germanPronunciation()
        }

        HStack(alignment: .top, spacing: 0) {
          Text(L.Quiz.correctAnswer + " ")
            .foregroundStyle(.customYellow)
            .fixedSize(horizontal: true, vertical: false)
          Text(mixedCaseString: lastCorrect)
            .germanPronunciation()
            .accessibilityLabel(Text(verbatim: MixedCaseAccessibility.accessibilityLabel(for: lastCorrect)))
        }

        if let errorContext = quiz.lastErrorContext,
           Current.languageModelService.isAvailable {
          ErrorExplainerView(context: errorContext)
        }
      }

      TextField(L.Quiz.conjugation, text: $userInput)
        .textFieldStyle(.roundedBorder)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .focused($isTextFieldFocused)
        .accessibilityFocused($isTextFieldA11yFocused)
        .accessibilityHint(L.Accessibility.quizTextFieldHint)
        .submitLabel(.go)
        .onSubmit {
          guard !userInput.isEmpty else { return }
          quiz.submitAnswer(userInput)
        }
    }
    .padding(.horizontal, Layout.doubleDefaultSpacing)
    .padding(.top, Layout.doubleDefaultSpacing)
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
  QuizView()
    .environment(Quiz())
}
