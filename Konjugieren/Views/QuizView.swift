// Copyright © 2026 Josh Adams. All rights reserved.

import TelemetryDeck
import SwiftUI

struct QuizView: View {
  @Environment(Quiz.self) var quiz
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var userInput = ""
  @FocusState private var isTextFieldFocused: Bool
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
            } else if !quiz.shouldShowResults {
              Button(L.Quiz.start) {
                quiz.start()
                TelemetryDeck.signal("start.quiz")
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
            }
            Spacer()
          }
          .padding(.bottom, Layout.tripleDefaultSpacing)
        }
      }
      .navigationTitle(L.Navigation.quiz)
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
      Text(labeledText(label: L.Quiz.verb, value: question.verb.infinitiv))

      Text(labeledText(label: L.Quiz.translation, value: question.verb.translation))
        .fixedSize(horizontal: false, vertical: true)

      if let pronoun = question.pronoun {
        Text(labeledText(label: L.Quiz.pronoun, value: pronoun))
      }

      Text(labeledText(label: L.Quiz.conjugationgroup, value: question.displayName(lang: settings.conjugationgroupLang)))
        .fixedSize(horizontal: false, vertical: true)

      HStack {
        Text(labeledText(label: L.Quiz.progress, value: quiz.progressText))
        Spacer()
        Text(labeledText(label: L.Quiz.score, value: "\(quiz.score)"))
      }

      Text(labeledText(label: L.Quiz.elapsed, value: quiz.elapsedText))

      if let lastIncorrect = quiz.lastIncorrectAnswer, let lastCorrect = quiz.lastCorrectAnswer {
        Text(labeledText(label: L.Quiz.lastAnswer, value: lastIncorrect, valueColor: .customYellow))

        Text(labeledTextWithMixedCase(label: L.Quiz.correctAnswer, mixedCaseValue: lastCorrect))
      }

      TextField(L.Quiz.conjugation, text: $userInput)
        .textFieldStyle(.roundedBorder)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .focused($isTextFieldFocused)
        .onSubmit {
          guard !userInput.isEmpty else { return }
          quiz.submitAnswer(userInput)
        }
    }
    .padding(.horizontal, Layout.doubleDefaultSpacing)
    .padding(.top, Layout.doubleDefaultSpacing)
  }

  private func labeledText(label: String, value: String, valueColor: Color = .customForeground) -> AttributedString {
    var result = AttributedString()

    var labelAttr = AttributedString(label + " ")
    labelAttr.foregroundColor = Color.customYellow
    result.append(labelAttr)

    var valueAttr = AttributedString(value)
    valueAttr.foregroundColor = valueColor
    result.append(valueAttr)

    return result
  }

  private func labeledTextWithMixedCase(label: String, mixedCaseValue: String) -> AttributedString {
    var result = AttributedString()

    var labelAttr = AttributedString(label)
    labelAttr.foregroundColor = Color.customYellow
    result.append(labelAttr)

    let spaceAttr = AttributedString(" ")
    result.append(spaceAttr)

    let chars = Array(mixedCaseValue)

    func isFormalSieStart(at index: Int) -> Bool {
      guard index + 2 < chars.count,
            chars[index] == "S",
            chars[index + 1] == "i",
            chars[index + 2] == "e",
            index == 0 || chars[index - 1] == " " else {
        return false
      }
      return index + 3 >= chars.count || !chars[index + 3].isLetter
    }

    var currentRun = ""
    var currentIsIrregular: Bool? = nil

    for (index, char) in chars.enumerated() {
      let isPartOfSie = isFormalSieStart(at: index) ||
                        (index > 0 && isFormalSieStart(at: index - 1)) ||
                        (index > 1 && isFormalSieStart(at: index - 2))

      let isRegular = char.isLowercase || !char.isLetter || isPartOfSie
      let canonicalChar = isPartOfSie ? String(char) : char.lowercased()
      let isIrregular = !isRegular

      if currentIsIrregular == nil {
        currentIsIrregular = isIrregular
        currentRun = canonicalChar
      } else if isIrregular == currentIsIrregular {
        currentRun += canonicalChar
      } else {
        var part = AttributedString(currentRun)
        part.foregroundColor = currentIsIrregular == true ? .customRed : .customYellow
        result.append(part)
        currentRun = canonicalChar
        currentIsIrregular = isIrregular
      }
    }

    if !currentRun.isEmpty {
      var part = AttributedString(currentRun)
      part.foregroundColor = currentIsIrregular == true ? .customRed : .customYellow
      result.append(part)
    }

    return result
  }
}

#Preview {
  QuizView()
    .environment(Quiz())
}
