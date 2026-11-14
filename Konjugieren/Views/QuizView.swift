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
  @State private var answerBlanks: [String] = []
  @FocusState private var focusedBlank: Int?
  @AccessibilityFocusState private var accessibilityFocusedBlank: Int?
  @AccessibilityFocusState private var correctionHasAccessibilityFocus: Bool
  /// Pages opened from a held correction, pushed over the quiz, which waits beneath them.
  @State private var navigationPath = NavigationPath()
  private var settings: Settings { Current.settings }
  @State private var shakeOffset: CGFloat = 0
  @State private var showCorrectCheck = false
  @State private var showIncorrectFlash = false
  @State private var rightAnswerCount = 0

  var body: some View {
    @Bindable var quiz = quiz

    NavigationStack(path: $navigationPath) {
      ZStack {
        Color.customBackground
          .ignoresSafeArea()

        VStack {
          if quiz.isInProgress, let question = quiz.currentQuestion {
            ScrollViewReader { proxy in
              ScrollView {
                quizContent(question: question)
              }
              .onChange(of: quiz.correction != nil) { _, isHeld in
                guard isHeld else {
                  return
                }
                correctionHasAccessibilityFocus = true
                refocusAnswer(after: .milliseconds(50))
                withAnimation(reduceMotion ? nil : .default) {
                  proxy.scrollTo(QuizCorrectionView.continueButtonID, anchor: .bottom)
                }
              }
              // Return resigned the field, and the learner edits the first attempt in it.
              .onChange(of: quiz.isAwaitingSecondAttempt) { _, isAwaiting in
                guard isAwaiting else {
                  return
                }
                accessibilityFocusedBlank = 0
                refocusAnswer(after: .milliseconds(50))
              }
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
      .sensoryFeedback(.success, trigger: rightAnswerCount)
      .sensoryFeedback(.error, trigger: showIncorrectFlash)
      .onAppear {
        TryQuizTip().invalidate(reason: .actionPerformed)
        guard let sheetScope else {
          Current.analytics.signal(name: .viewQuizView)
          return
        }
        if !quiz.isInProgress, !quiz.shouldShowResults {
          quiz.start(scope: sheetScope)
          focusedBlank = 0
        }
      }
      .navigationTitle(sheetScope?.title ?? L.Navigation.quiz)
      .navigationBarTitleDisplayMode(sheetScope == nil ? .automatic : .inline)
      .navigationDestination(for: VerbDestination.self) { destination in
        VerbView(verb: destination.verb, source: destination.source, marks: destination.marks)
      }
      .navigationDestination(for: RelatedVerbListDestination.self) { destination in
        RelatedVerbListView(destination: destination)
      }
      .navigationDestination(for: BrowseableFamily.self) { family in
        FamilyDetailView(family: family) { verb in navigationPath.append(VerbDestination(verb: verb, source: .family)) }
      }
      .navigationDestination(for: VerbCollectionRequest.self) { request in
        FamilyDetailView(family: .ablaut, collectionRequest: request) { verb in navigationPath.append(VerbDestination(verb: verb, source: .family)) }
      }
    }
    .environment(\.verbPagePush, VerbPagePush { navigationPath.append($0) })
    .environment(\.isBeneathQuiz, true)
    .accessibilityAction(.magicTap) {
      if quiz.correction != nil {
        quiz.continueAfterCorrection()
      }
    }
    .sheet(isPresented: $quiz.shouldShowResults, onDismiss: {
      if sheetScope != nil {
        dismiss()
      }
    }) {
      ResultsView(quiz: quiz)
    }
    .onChange(of: quiz.currentIndex) {
      answerBlanks = []
      focusedBlank = 0
      accessibilityFocusedBlank = 0
    }
    // Back from a page opened from the correction, the keyboard returns, so Return continues.
    .onChange(of: navigationPath.isEmpty) { _, isEmpty in
      if isEmpty, quiz.correction != nil {
        refocusAnswer(after: .milliseconds(450))
      }
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

        if let spelling = quiz.lastPreferredSpelling {
          HStack(spacing: 6) {
            Image(systemName: "checkmark.circle")
              .foregroundStyle(.green)
            Text(mixedCaseString: spelling)
              .germanPronunciation()
          }
          .font(.subheadline)
          .accessibilityElement(children: .ignore)
          .accessibilityLabel(L.Quiz.announceCorrectSpelling(MixedCaseAccessibility.accessibilityLabel(for: spelling)))
          .accessibilityIdentifier("quiz_preferred_spelling")
        }

        AnswerFrameView(
          frame: question.answerFrame,
          blanks: $answerBlanks,
          focusedBlank: $focusedBlank,
          accessibilityFocusedBlank: $accessibilityFocusedBlank,
          identifier: "quiz_answer_field",
          returnAlwaysSubmits: quiz.correction != nil
        ) {
          if quiz.correction != nil {
            quiz.continueAfterCorrection()
          } else {
            submit(question)
          }
        }
        .offset(x: shakeOffset)

        // Animated here alone, so that the next question still replaces this one at once.
        VStack {
          if quiz.isAwaitingSecondAttempt {
            Label(L.Quiz.almost, systemImage: "hand.raised.fill")
              .font(.headline)
              .foregroundStyle(QuizItem.State.correctOnSecondAttempt.dotColor)
              .transition(.opacity.combined(with: .scale(scale: 0.9)))
              .accessibilityIdentifier("quiz_almost")
          }
        }
        .animation(reduceMotion ? nil : .default, value: quiz.isAwaitingSecondAttempt)

        if let correction = quiz.correction {
          QuizCorrectionView(
            question: question,
            correction: correction,
            showsVerbLink: quiz.scope.source != .verbPage,
            accessibilityIsFocused: $correctionHasAccessibilityFocus,
            onOpen: { navigationPath.append($0) },
            onContinue: { quiz.continueAfterCorrection() }
          )
          .transition(.opacity)

          // TODO: 1.0-disabled surface. FM hallucinates fake grammar rules
          // (e.g., singen Präteritum → "-en changes to -t"). See "Currently
          // disabled in 1.0" in docs/cloud-llm-tier.md. Restore when
          // HybridLanguageModelService ships.
          // if Current.languageModelService.isAvailable {
          //   ErrorExplainerView(context: correction.errorContext)
          //     .id(correction.errorContext)
          // }
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
        secondTry: quiz.questions.filter { $0.state == .correctOnSecondAttempt }.count,
        incorrect: quiz.questions.filter { $0.state == .incorrect }.count,
        remaining: quiz.questionCount - quiz.currentIndex - 1
      ))
    }
  }

  /// Gives the answer field the keyboard while a correction is held, so that Return continues,
  /// and after a slip, so that the learner can edit the first attempt. Return resigns the field,
  /// and a push takes the keyboard away, yet the focus state can still read 0 afterward, so it
  /// is cleared and set again once the field is back on screen.
  private func refocusAnswer(after delay: Duration) {
    focusedBlank = nil
    Task { @MainActor in
      try? await Task.sleep(for: delay)
      if navigationPath.isEmpty, quiz.correction != nil || quiz.isAwaitingSecondAttempt {
        focusedBlank = 0
      }
    }
  }

  private func submit(_ question: QuizItem) {
    let index = quiz.currentIndex
    quiz.submitAnswer(question.answerFrame.answer(filling: answerBlanks))
    guard index < quiz.questions.count else {
      return
    }
    switch quiz.questions[index].state {
    case .unanswered:
      // A slip, which waits for one more attempt. Its cue is the "almost" line, not a shake.
      break
    case .correct, .correctOnSecondAttempt:
      rightAnswerCount += 1
      if !reduceMotion {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
          showCorrectCheck = true
        }
        Task { @MainActor in
          try? await Task.sleep(for: .seconds(0.6))
          withAnimation { showCorrectCheck = false }
        }
      }
    case .incorrect:
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

  private var myVerbs: [Verb] {
    Current.learnerVerbs.myVerbs
  }

  private var level: QuizLevel {
    settings.quizLevel
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
            QuizFactTile(systemImage: level.systemImage, value: level.localizedName, label: L.Quiz.levelLabel, isLarge: isLarge)
            QuizFactTile(systemImage: "trophy.fill", value: "\(Quiz.pointsPerCorrect)", label: L.Quiz.pointsPerAnswer, isLarge: isLarge)
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

extension QuizItem.State {
  var dotColor: Color {
    switch self {
    case .correct:
      return .customYellow
    case .correctOnSecondAttempt:
      return .orange
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
