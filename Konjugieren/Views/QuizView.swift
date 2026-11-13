// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct QuizView: View {
  /// Nil for the Quiz tab. A scope makes this a sheet that starts that quiz as it appears and
  /// closes when the quiz ends.
  var sheetScope: QuizScope?

  @Environment(Quiz.self) var quiz
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.dismiss) private var dismiss
  @Environment(\.horizontalSizeClass) private var sizeClass
  @State private var tabScope = TabQuizScope.allVerbs
  @State private var userInput = ""
  @FocusState private var isTextFieldFocused: Bool
  @AccessibilityFocusState private var isTextFieldA11yFocused: Bool
  private var settings: Settings { Current.settings }
  @State private var shakeOffset: CGFloat = 0
  @State private var showCorrectCheck = false
  @State private var showIncorrectFlash = false
  @State private var lastSubmittedCorrectCount = 0

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
          } else if !quiz.shouldShowResults, sheetScope == nil {
            startScreen
          }
        }
      }
      .toolbar {
        if quiz.isInProgress {
          ToolbarItem(placement: .cancellationAction) {
            Button(L.Quiz.quit) {
              quiz.quit()
              if sheetScope != nil {
                dismiss()
              }
            }
            .accessibilityHint(L.Accessibility.quizQuitHint)
          }
        }
      }
      .sensoryFeedback(.success, trigger: lastSubmittedCorrectCount)
      .sensoryFeedback(.error, trigger: showIncorrectFlash)
      .onAppear {
        TryQuizTip().invalidate(reason: .actionPerformed)
        guard let sheetScope else {
          Current.analytics.signal(name: .viewQuizView)
          return
        }
        if !quiz.isInProgress, !quiz.shouldShowResults {
          quiz.start(scope: sheetScope)
          isTextFieldFocused = true
        }
      }
      .navigationTitle(sheetScope?.title ?? L.Navigation.quiz)
      .navigationBarTitleDisplayMode(sheetScope == nil ? .automatic : .inline)
    }
    .sheet(isPresented: $quiz.shouldShowResults, onDismiss: {
      if sheetScope != nil {
        dismiss()
      }
    }) {
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
        Text(verbatim: question.verb.infinitiv.inUserRegion)
          .font(.title.bold())
          .foregroundStyle(.customForeground)
          .germanPronunciation()
          .speakOnTap(question.verb.infinitiv.inUserRegion)

        Text(verbatim: question.translation)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .englishPronunciation()

        if let pronoun = question.pronoun {
          labeledRow(L.Quiz.pronoun) {
            Text(verbatim: pronoun)
              .foregroundStyle(.customForeground)
              .germanPronunciation()
          }
        }

        labeledRow(L.Quiz.conjugationgroup) {
          Text(verbatim: question.displayName(lang: settings.conjugationgroupLang))
            .foregroundStyle(.customForeground)
            .fixedSize(horizontal: false, vertical: true)
            .germanPronunciation(forReal: settings.conjugationgroupLang == .german)
        }

        HStack {
          Text(label: L.Quiz.score, value: "\(quiz.score)")
            .font(.caption.monospacedDigit())
          Spacer()
          Text(label: L.Quiz.elapsed, value: quiz.elapsedText)
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
          labeledRow(L.Quiz.lastAnswer) {
            Text(verbatim: lastIncorrect)
              .foregroundStyle(.customRed)
              .germanPronunciation()
          }

          labeledRow(L.Quiz.correctAnswer) {
            Text(mixedCaseString: lastCorrect)
              .germanPronunciation()
              .accessibilityLabel(Text(verbatim: MixedCaseAccessibility.accessibilityLabel(for: lastCorrect)))
          }

          // TODO: 1.0-disabled surface. FM hallucinates fake grammar rules
          // (e.g., singen Präteritum → "-en changes to -t"). See "Currently
          // disabled in 1.0" in docs/cloud-llm-tier.md. Restore when
          // HybridLanguageModelService ships.
          // if let errorContext = quiz.lastErrorContext,
          //    Current.languageModelService.isAvailable {
          //   ErrorExplainerView(context: errorContext)
          //     .id(errorContext)
          // }
        }

        TextField(L.Quiz.conjugation, text: $userInput)
          .textFieldStyle(.roundedBorder)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .focused($isTextFieldFocused)
          .accessibilityFocused($isTextFieldA11yFocused)
          .accessibilityHint(L.Accessibility.quizTextFieldHint)
          .accessibilityIdentifier("quiz_answer_field")
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
      .konjCard()
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .strokeBorder(showIncorrectFlash && !reduceMotion ? Color.customRed.opacity(0.5) : Color.clear, lineWidth: 2)
      )
      .padding(.horizontal, Layout.doubleDefaultSpacing)
      .padding(.top, Layout.doubleDefaultSpacing)

      HStack(spacing: 4) {
        ForEach(Array(quiz.questions.enumerated()), id: \.element.id) { index, item in
          Image(systemName: "circle.fill")
            .font(.system(size: 8))
            .frame(width: 8, height: 8)
            .foregroundStyle(item.state.dotColor)
            .scaleEffect(index == quiz.currentIndex ? 1.4 : 1.0)
            .symbolEffect(
              .pulse.byLayer,
              options: reduceMotion ? .nonRepeating : .repeating,
              isActive: index == quiz.currentIndex
            )
            .animation(.spring(duration: 0.3), value: item.isCorrect)
        }
      }
      .padding(.horizontal, Layout.doubleDefaultSpacing)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(L.Accessibility.quizDotRow(
        current: quiz.currentIndex + 1,
        total: quiz.questionCount,
        correct: quiz.questions.filter { $0.state == .correct }.count,
        incorrect: quiz.questions.filter { $0.state == .incorrect }.count,
        remaining: quiz.questionCount - quiz.currentIndex - 1
      ))
    }
  }

  private var myVerbs: [Verb] {
    Current.learnerVerbs.myVerbs
  }

  private var difficulty: QuizDifficulty {
    settings.quizDifficulty
  }

  // Ridiculous doubles the final score, so each right answer is worth twice as much.
  private var pointsPerAnswer: Int {
    difficulty == .ridiculous ? Quiz.pointsPerCorrect * 2 : Quiz.pointsPerCorrect
  }

  // An iPad's start screen has room for a bigger composition, and at the iPhone's size it left
  // most of the screen empty.
  private var isLarge: Bool {
    sizeClass == .regular
  }

  private var startScreen: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(spacing: isLarge ? Layout.tripleDefaultSpacing * 2 : Layout.tripleDefaultSpacing) {
          scopeHero

          VStack(spacing: Layout.doubleDefaultSpacing) {
            Picker(L.Quiz.scope, selection: $tabScope.animation(.snappy)) {
              ForEach(TabQuizScope.allCases, id: \.self) { scope in
                Text(scope.displayName)
                  .tag(scope)
              }
            }
            .pickerStyle(.segmented)
            .controlSize(isLarge ? .large : .regular)
            .accessibilityIdentifier("quiz_scope_picker")

            Button {
              switch tabScope {
              case .allVerbs:
                quiz.start()
              case .myVerbs:
                quiz.start(scope: .myVerbs(myVerbs))
              }
            } label: {
              Label(L.Quiz.start, systemImage: "play.fill")
                .symbolEffect(.pulse.byLayer, options: reduceMotion ? .nonRepeating : .repeating)
            }
            .funButton()
            // FunButton fixes its own font, so a scale is the way to enlarge it on an iPad.
            .scaleEffect(isLarge ? 1.4 : 1)
            .padding(.vertical, isLarge ? Layout.defaultSpacing : 0)
            .disabled(tabScope == .myVerbs && myVerbs.isEmpty)
            .accessibilityHint(L.Accessibility.quizStartHint)
            .accessibilityIdentifier("quiz_start_button")
          }

          HStack(alignment: .top, spacing: Layout.defaultSpacing) {
            QuizFactTile(systemImage: "list.number", value: "\(Quiz.questionCount)", label: L.Quiz.questionsLabel, isLarge: isLarge)
            QuizFactTile(
              systemImage: difficulty == .ridiculous ? "flame.fill" : "gauge.with.dots.needle.33percent",
              value: difficulty.localizedQuizDifficulty,
              label: L.Quiz.difficultyLabel,
              isLarge: isLarge
            )
            QuizFactTile(systemImage: "trophy.fill", value: "\(pointsPerAnswer)", label: L.Quiz.pointsPerAnswer, isLarge: isLarge)
          }
          // Equal heights when one label wraps to two lines.
          .fixedSize(horizontal: false, vertical: true)

          if tabScope == .myVerbs, !myVerbs.isEmpty {
            myVerbChips
          }
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
        .padding(.vertical, Layout.doubleDefaultSpacing)
        .frame(maxWidth: isLarge ? 680 : 560)
        .frame(maxWidth: .infinity, minHeight: geometry.size.height)
      }
      .scrollBounceBehavior(.basedOnSize)
    }
  }

  /// A big symbol for the chosen scope, its name, and a line saying what the quiz will ask about.
  private var scopeHero: some View {
    VStack(spacing: Layout.defaultSpacing) {
      Image(systemName: heroSymbol)
        .font(.system(size: isLarge ? 180 : 96, weight: .semibold))
        .foregroundStyle(
          LinearGradient(colors: [.customYellow, .customYellow.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        )
        .contentTransition(.symbolEffect(.replace))
        .symbolEffect(.bounce, value: reduceMotion ? TabQuizScope.allVerbs : tabScope)
        .frame(height: isLarge ? 220 : 120)
        .accessibilityHidden(true)

      Text(tabScope == .allVerbs ? L.VerbBrowse.verbCount(Verb.verbs.count) : L.MyVerbs.title)
        .font(isLarge ? .largeTitle.bold() : .title.bold())
        .fontDesign(.serif)
        .foregroundStyle(.customForeground)
        .contentTransition(.opacity)

      Text(heroDescription)
        .font(isLarge ? .title3 : .subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("quiz_my_verbs_note")
    }
    .accessibilityElement(children: .combine)
  }

  private var heroSymbol: String {
    switch tabScope {
    case .allVerbs:
      return "books.vertical.fill"
    case .myVerbs:
      return myVerbs.isEmpty ? "star" : "star.fill"
    }
  }

  private var heroDescription: String {
    switch tabScope {
    case .allVerbs:
      return L.Quiz.allVerbsDescription
    case .myVerbs:
      return myVerbs.isEmpty ? L.Quiz.myVerbsEmpty : L.Quiz.myVerbsCount(myVerbs.count)
    }
  }

  private static let chipLimit = 12

  /// The verbs a My Verbs quiz will ask about, so the learner sees the list before starting.
  private var myVerbChips: some View {
    let shown = myVerbs.prefix(Self.chipLimit)
    let hiddenCount = myVerbs.count - shown.count
    return FlowLayout(spacing: Layout.defaultSpacing, centersRows: true) {
      ForEach(Array(shown)) { verb in
        Text(verbatim: verb.infinitiv.inUserRegion)
          .font(isLarge ? .title3 : .subheadline)
          .foregroundStyle(.customYellow)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(Color.customYellow.opacity(0.08), in: Capsule())
          .germanPronunciation()
      }
      if hiddenCount > 0 {
        Text(L.Quiz.moreVerbs(hiddenCount))
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .padding(.vertical, 6)
      }
    }
    .frame(maxWidth: .infinity)
    .transition(.opacity.combined(with: .move(edge: .bottom)))
    .accessibilityIdentifier("quiz_my_verbs_chips")
  }

  @ViewBuilder
  private func labeledRow<Value: View>(_ label: String, @ViewBuilder value: () -> Value) -> some View {
    HStack(alignment: .top, spacing: 0) {
      Text(label + " ")
        .foregroundStyle(.customYellow)
        .fixedSize(horizontal: true, vertical: false)
      value()
    }
  }
}

/// One fact about the quiz about to start: a yellow symbol, a value, and what the value is.
private struct QuizFactTile: View {
  let systemImage: String
  let value: String
  let label: String
  var isLarge = false

  var body: some View {
    VStack(spacing: 6) {
      Image(systemName: systemImage)
        .font(isLarge ? .system(size: 48) : .title)
        .foregroundStyle(.customYellow)
        .contentTransition(.symbolEffect(.replace))
        .frame(height: isLarge ? 64 : 36)
        .accessibilityHidden(true)
      Text(verbatim: value)
        .font(isLarge ? .title2.bold() : .headline)
        .foregroundStyle(.customForeground)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      Text(label)
        .font(isLarge ? .subheadline : .caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.vertical, Layout.doubleDefaultSpacing)
    .padding(.horizontal, Layout.defaultSpacing)
    .background(Color.customYellow.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(Color.customYellow.opacity(0.25), lineWidth: 1)
    }
    .accessibilityElement(children: .combine)
  }
}

/// What the Quiz tab's picker offers. A quiz over one verb starts from that verb's page instead.
/// A quiz in a sheet, such as "Test me on this verb" or a collection's quiz, so the learner
/// closes it onto the page it was started from. A quiz in the Quiz tab is a separate quiz and
/// carries on. While a question waits, the sheet closes only through Quit, so every quiz started
/// here ends with `quitQuiz` or `completeQuiz`.
struct QuizSheet: View {
  let scope: QuizScope
  @State private var quiz = Quiz()

  var body: some View {
    QuizView(sheetScope: scope)
      .environment(quiz)
      .interactiveDismissDisabled(quiz.isInProgress)
  }
}

enum TabQuizScope: CaseIterable {
  case allVerbs
  case myVerbs

  var displayName: String {
    switch self {
    case .allVerbs:
      return L.Quiz.allVerbs
    case .myVerbs:
      return L.MyVerbs.title
    }
  }
}

private extension QuizItem.State {
  var dotColor: Color {
    switch self {
    case .correct:
      return .customYellow
    case .incorrect:
      return .customRed
    case .unanswered:
      return .gray.opacity(0.4)
    }
  }
}

#Preview {
  QuizView()
    .environment(Quiz())
}
