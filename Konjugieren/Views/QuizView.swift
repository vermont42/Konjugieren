// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct QuizView: View {
  @Environment(Quiz.self) var quiz
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase
  @State private var userInput = ""
  @FocusState private var isTextFieldFocused: Bool
  @AccessibilityFocusState private var isTextFieldA11yFocused: Bool
  private var settings: Settings { Current.settings }
  @State private var shakeOffset: CGFloat = 0
  @State private var showCorrectCheck = false
  @State private var showIncorrectFlash = false
  @State private var lastSubmittedCorrectCount = 0
  @State private var lastSubmittedIndex = 0

  var body: some View {
    @Bindable var quiz = quiz

    NavigationStack {
      ZStack {
        Color.customBackground
          .ignoresSafeArea()

        VStack {
          if quiz.isInProgress, let question = quiz.currentQuestion {
            ScrollView {
              quizContent(question: question)
            }
          } else if !quiz.shouldShowResults {
            Spacer()

            Button {
              quiz.start()
            } label: {
              Label(L.Quiz.start, systemImage: "play.fill")
                .symbolEffect(.pulse.byLayer, options: reduceMotion ? .nonRepeating : .repeating)
            }
            .funButton()
            .accessibilityHint(L.Accessibility.quizStartHint)

            Spacer()
          }
        }
      }
      .toolbar {
        if quiz.isInProgress {
          ToolbarItem(placement: .cancellationAction) {
            Button(L.Quiz.quit) {
              quiz.quit()
            }
            .accessibilityHint(L.Accessibility.quizQuitHint)
          }
        }
      }
      .sensoryFeedback(.success, trigger: lastSubmittedCorrectCount)
      .sensoryFeedback(.error, trigger: showIncorrectFlash)
      .onAppear {
        Current.analytics.signal(name: .viewQuizView)
        TryQuizTip().invalidate(reason: .actionPerformed)
      }
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
    .onChange(of: scenePhase) { _, newPhase in
      switch newPhase {
      case .active:
        quiz.resumeTimer()
      case .inactive, .background:
        quiz.pauseTimer()
      @unknown default:
        break
      }
    }
  }

  @ViewBuilder
  private func quizContent(question: QuizItem) -> some View {
    VStack(spacing: Layout.doubleDefaultSpacing) {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        ProgressView(value: Double(quiz.currentIndex), total: Double(Quiz.questionCount))
          .tint(.customYellow)

        Text(verbatim: question.verb.infinitiv)
          .font(.title.bold())
          .foregroundStyle(.customForeground)
          .germanPronunciation()

        Text(verbatim: question.verb.translation)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .englishPronunciation()

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
            .font(.caption.monospacedDigit())
          Spacer()
          Text(labeledText(label: L.Quiz.score, value: "\(quiz.score)"))
            .font(.caption.monospacedDigit())
          Spacer()
          Text(labeledText(label: L.Quiz.elapsed, value: quiz.elapsedText))
            .font(.caption.monospacedDigit())
        }

        if showCorrectCheck {
          HStack {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
              .font(.title)
              .foregroundStyle(.green)
              .transition(.scale.combined(with: .opacity))
            Spacer()
          }
        }

        if let lastIncorrect = quiz.lastIncorrectAnswer, let lastCorrect = quiz.lastCorrectAnswer {
          HStack(alignment: .top, spacing: 0) {
            Text(L.Quiz.lastAnswer + " ")
              .foregroundStyle(.customYellow)
              .fixedSize(horizontal: true, vertical: false)
            Text(verbatim: lastIncorrect)
              .foregroundStyle(.customRed)
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
          .offset(x: shakeOffset)
          .onSubmit {
            guard !userInput.isEmpty else { return }
            let wasCorrectCount = quiz.correctCount
            quiz.submitAnswer(userInput)
            if quiz.correctCount > wasCorrectCount {
              lastSubmittedCorrectCount = quiz.correctCount
              if !reduceMotion {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                  showCorrectCheck = true
                }
                Task { @MainActor in
                  try? await Task.sleep(for: .seconds(0.6))
                  withAnimation { showCorrectCheck = false }
                }
              }
            } else {
              showIncorrectFlash.toggle()
              if !reduceMotion {
                withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) {
                  shakeOffset = 10
                }
                Task { @MainActor in
                  try? await Task.sleep(for: .milliseconds(80))
                  withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) {
                    shakeOffset = -8
                  }
                  try? await Task.sleep(for: .milliseconds(80))
                  withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) {
                    shakeOffset = 5
                  }
                  try? await Task.sleep(for: .milliseconds(80))
                  withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) {
                    shakeOffset = 0
                  }
                }
              }
            }
          }
      }
      .padding(Layout.doubleDefaultSpacing)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color(.secondarySystemBackground))
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .strokeBorder(showIncorrectFlash && !reduceMotion ? Color.customRed.opacity(0.5) : Color.clear, lineWidth: 2)
          )
      )
      .padding(.horizontal, Layout.doubleDefaultSpacing)
      .padding(.top, Layout.doubleDefaultSpacing)
    }
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
