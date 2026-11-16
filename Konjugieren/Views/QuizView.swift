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
  @State private var recognitionTable: ConjugationTable?
  @State private var recognitionPerson: PersonNumber?
  @FocusState private var focusedBlank: Int?
  @AccessibilityFocusState private var accessibilityFocusedBlank: Int?
  @AccessibilityFocusState private var correctionHasAccessibilityFocus: Bool
  @AccessibilityFocusState private var choiceReasonHasAccessibilityFocus: Bool
  /// Pages opened from a held correction, pushed over the quiz, which waits beneath them.
  @State private var navigationPath = NavigationPath()
  private var settings: Settings { Current.settings }
  @State private var shakeOffset: CGFloat = 0
  @State private var showCorrectCheck = false
  @State private var showIncorrectFlash = false
  @State private var wrongAnswerCount = 0
  @State private var rightAnswerCount = 0
  @State private var isShowingQRCode = false
  @State private var shareButtonFrame = CGRect.zero

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
              // A choice's reason and Continue appear below its sentences, out of sight on a small
              // screen.
              .onChange(of: quiz.isHoldingChoice) { _, isHeld in
                guard isHeld else {
                  return
                }
                choiceReasonHasAccessibilityFocus = true
                withAnimation(reduceMotion ? nil : .default) {
                  proxy.scrollTo(QuizCorrectionView.continueButtonID, anchor: .bottom)
                }
              }
              // Return resigned the field, and the learner edits the first attempt in it. A
              // recognition card's chips push its field low, so the line is scrolled into sight.
              .onChange(of: quiz.isAwaitingSecondAttempt) { _, isAwaiting in
                guard isAwaiting else {
                  return
                }
                accessibilityFocusedBlank = 0
                refocusAnswer(after: .milliseconds(50))
                withAnimation(reduceMotion ? nil : .default) {
                  proxy.scrollTo(Self.secondAttemptLineID, anchor: .bottom)
                }
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
      .sensoryFeedback(.error, trigger: wrongAnswerCount)
      .onAppear {
        TryQuizTip().invalidate(reason: .actionPerformed)
        guard let sheetScope else {
          Current.analytics.signal(name: .viewQuizView)
          startRequestedDailySession()
          return
        }
        if !quiz.isInProgress, !quiz.shouldShowResults {
          quiz.start(scope: sheetScope)
          focusedBlank = 0
        }
      }
      .navigationTitle(sheetScope?.title ?? tabSessionTitle ?? L.Navigation.quiz)
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
      .navigationDestination(for: AblautPracticeDestination.self) { _ in
        AblautPracticeListView()
      }
      .navigationDestination(for: MasteryDestination.self) { _ in
        MasteryView()
      }
      .navigationDestination(for: CustomQuizDestination.self) { destination in
        switch destination {
        case .ablautGroups:
          CustomQuizAblautGroupList()
        case .editor:
          CustomQuizEditor()
        }
      }
    }
    .environment(\.verbPagePush, VerbPagePush { navigationPath.append($0) })
    // Only while a question waits. The hub pushes the ablaut groups with no quiz running, and
    // their practice must start from there.
    .environment(\.isBeneathQuiz, quiz.isInProgress)
    .accessibilityAction(.magicTap) {
      if quiz.isHeld {
        quiz.continueAfterCorrection()
      }
    }
    // Ten More closes the results onto the quiz, which is in progress again, so a sheet stays.
    .sheet(isPresented: $quiz.shouldShowResults, onDismiss: {
      if sheetScope != nil, !quiz.isInProgress {
        dismiss()
      }
      // Another Speed Round, started from the results, runs its clock from the start, so the
      // field takes the keyboard as soon as the sheet has gone.
      if quiz.isInProgress {
        focusedBlank = 0
      }
    }) {
      ResultsView(quiz: quiz)
    }
    // A session started from the hub takes the keyboard at once, as a sheet's does, which a Speed
    // Round's running clock needs most.
    .onChange(of: quiz.isInProgress) { _, isInProgress in
      guard isInProgress, sheetScope == nil, quiz.roundCount == 1 else {
        return
      }
      Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(100))
        focusedBlank = 0
      }
    }
    .onChange(of: Current.dailySessionRequest) {
      startRequestedDailySession()
    }
    .onChange(of: quiz.currentIndex) {
      answerBlanks = []
      recognitionTable = nil
      recognitionPerson = nil
      focusedBlank = 0
      accessibilityFocusedBlank = 0
    }
    // A choice question has no field, so the next question's field must take the keyboard anew
    // once it is on screen.
    .onChange(of: quiz.currentQuestion?.choice != nil) { _, isChoice in
      guard !isChoice, quiz.isInProgress else {
        return
      }
      Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(100))
        focusedBlank = 0
      }
    }
    // Ten More leaves currentIndex where the results found it, at the first new question, and the
    // field returns only once the results sheet has gone.
    .onChange(of: quiz.roundCount) { _, roundCount in
      guard roundCount > 1 else {
        return
      }
      answerBlanks = []
      recognitionTable = nil
      recognitionPerson = nil
      Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(450))
        focusedBlank = 0
        accessibilityFocusedBlank = 0
      }
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

  // A Verb Essentials verb shows its three rows, with the answer field in the current one. The
  // rows before and after the field are separate children around it, so that the field keeps its
  // place in the hierarchy, and the keyboard its focus, as it moves down the rows.
  @ViewBuilder
  private func quizContent(question: QuizItem) -> some View {
    let essentialsRows = quiz.essentialsRows
    let currentRowIndex = essentialsRows?.firstIndex { row in
      if case .current = row.content {
        return true
      }
      return false
    }
    let currentRow = currentRowIndex.flatMap { essentialsRows?[$0] }
    VStack(spacing: Layout.doubleDefaultSpacing) {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        if let miss = quiz.speedRoundMiss {
          SpeedRoundMissLine(question: miss)
        }

        if question.isReask {
          Label(L.Quiz.askedAgain, systemImage: "arrow.counterclockwise")
            .font(.subheadline.bold())
            .foregroundStyle(.customYellow)
            .accessibilityIdentifier("quiz_asked_again")
        }

        // Only a debug build asks a sentence or a choice Josh has not yet approved.
        if question.sentence?.reviewed == false || question.choice?.question.reviewed == false {
          Label(L.Sentences.draft, systemImage: "pencil.and.list.clipboard")
            .font(.caption.bold())
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("quiz_sentence_draft")
        }

        if let recognition = question.recognition {
          // The verb and its gloss are what a recognition question asks for, so neither is shown.
          RecognitionPromptView(prompt: recognition.prompt)
        } else if let setting = question.choice?.question.choiceSetting {
          // The setting decides the choice, so it takes the verb's place, with its gloss.
          Text(verbatim: setting.german)
            .font(.title.bold())
            .foregroundStyle(.customForeground)
            .fixedSize(horizontal: false, vertical: true)
            .germanPronunciation()
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("choice_setting")

          Text(verbatim: setting.english)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .englishPronunciation()
        } else {
          Text(verbatim: question.verb.infinitiv.inUserRegion)
            .font(.title.bold())
            .foregroundStyle(.customForeground)
            .germanPronunciation()
            .speakOnTap(question.verb.infinitiv.inUserRegion)

          Text(verbatim: question.translation)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .englishPronunciation()
        }

        if essentialsRows == nil, question.recognition == nil, question.choice == nil {
          labeledRow(L.Quiz.conjugationgroup) {
            Text(verbatim: question.displayName(lang: settings.conjugationgroupLang))
              .foregroundStyle(.customForeground)
              .fixedSize(horizontal: false, vertical: true)
              .germanPronunciation(forReal: settings.conjugationgroupLang == .german)
          }
        }

        if quiz.scope.isSpeedRound {
          speedRoundStatus
        } else {
          HStack {
            Text(label: L.Quiz.score, value: "\(quiz.score)")
              .font(.caption.monospacedDigit())
            Spacer()
            if settings.quizClock == .show {
              Text(label: L.Quiz.elapsed, value: quiz.elapsedText)
                .font(.caption.monospacedDigit())
            }
          }
        }

        if let essentialsRows, let currentRowIndex {
          ForEach(essentialsRows.prefix(currentRowIndex)) { row in
            VerbEssentialsRowView(row: row, frame: question.answerFrame, lang: settings.conjugationgroupLang)
          }
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

        if let currentRow {
          VerbEssentialsRowLabel(conjugationgroup: currentRow.conjugationgroup, lang: settings.conjugationgroupLang)
            .accessibilityHidden(true)
        }

        // The choices come before the field, so that they stay in sight above the keyboard and
        // Return can check the answer once the infinitive is typed.
        if let recognition = question.recognition {
          RecognitionChoicesView(
            recognition: recognition,
            table: $recognitionTable,
            personNumber: $recognitionPerson,
            lang: settings.conjugationgroupLang,
            isLocked: quiz.correction != nil
          )

          Text(L.Recognition.infinitiveHeading)
            .font(.subheadline.bold())
            .foregroundStyle(.customYellow)
            .padding(.top, 4)
            .accessibilityHidden(true)
        }

        if let choice = question.choice {
          ChoiceQuestionView(
            choice: choice,
            chosenOption: quiz.isHoldingChoice ? question.chosenOption : nil,
            lang: settings.conjugationgroupLang,
            reasonIsFocused: $choiceReasonHasAccessibilityFocus,
            onChoose: choose,
            onContinue: { quiz.continueAfterCorrection() }
          )
          .offset(x: shakeOffset)
        } else {
          AnswerFrameView(
            frame: question.answerFrame,
            blanks: $answerBlanks,
            focusedBlank: $focusedBlank,
            accessibilityFocusedBlank: $accessibilityFocusedBlank,
            identifier: "quiz_answer_field",
            returnAlwaysSubmits: quiz.correction != nil,
            spokenPrefix: question.recognition == nil ? currentRow?.conjugationgroup.displayName(lang: settings.conjugationgroupLang) : L.Recognition.infinitiveHeading,
            placeholder: question.recognition == nil ? nil : L.Recognition.infinitiveHeading,
            hint: question.recognition == nil ? nil : L.Accessibility.recognitionFieldHint
          ) {
            if quiz.correction != nil {
              quiz.continueAfterCorrection()
            } else {
              submit(question)
            }
          }
          .offset(x: shakeOffset)
        }

        if let sentence = question.sentence {
          Text(verbatim: sentence.english)
            .font(.subheadline)
            .italic()
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .englishPronunciation()
            .accessibilityIdentifier("quiz_sentence_english")
        }

        // Animated here alone, so that the next question still replaces this one at once.
        VStack {
          if quiz.isAwaitingSecondAttempt {
            Label(question.secondAttemptPrompt, systemImage: "hand.raised.fill")
              .font(.headline)
              .fixedSize(horizontal: false, vertical: true)
              .foregroundStyle(QuizItem.State.correctOnSecondAttempt.dotColor)
              .transition(.opacity.combined(with: .scale(scale: 0.9)))
              .accessibilityIdentifier("quiz_almost")
              .id(Self.secondAttemptLineID)
          }
        }
        .animation(reduceMotion ? nil : .default, value: quiz.isAwaitingSecondAttempt)

        if question.recognition != nil, quiz.correction == nil {
          Button {
            submit(question)
          } label: {
            Label(L.Recognition.check, systemImage: "checkmark")
              .frame(maxWidth: 400)
          }
          .funButton()
          .frame(maxWidth: .infinity)
          .disabled(recognitionAnswer(for: question) == nil)
          .accessibilityHint(L.Accessibility.recognitionCheckHint)
          .accessibilityIdentifier("recognition_check_button")
        }

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

        if let essentialsRows, let currentRowIndex {
          ForEach(essentialsRows.dropFirst(currentRowIndex + 1)) { row in
            VerbEssentialsRowView(row: row, frame: question.answerFrame, lang: settings.conjugationgroupLang)
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

      // A Speed Round's questions are drawn as it goes, so it has no row of what is to come.
      if !quiz.scope.isSpeedRound {
        progressDots
      }
    }
  }

  /// The right answers so far and the time left, which shows whatever the clock setting, since this
  /// is the one place the clock counts (T5.7). The last seconds turn red.
  private var speedRoundStatus: some View {
    HStack {
      Text(label: L.Quiz.correct, value: "\(quiz.correctCount)")
        .accessibilityIdentifier("speed_round_correct")
      Spacer()
      Text(label: L.SpeedRound.timeLeft, value: TimeFormatter.formatMinutesSeconds(quiz.speedRoundSecondsLeft))
        .foregroundStyle(quiz.speedRoundSecondsLeft <= SpeedRound.warningSecondsLeft ? Color.customRed : Color.customForeground)
        .contentTransition(.numericText(countsDown: true))
        .accessibilityIdentifier("speed_round_time_left")
    }
    .font(.headline.monospacedDigit())
  }

  private var progressDots: some View {
    // Wraps, since Ten More and re-asks can take the row past thirty dots, wider than an iPhone.
    FlowLayout(spacing: 4, centersRows: true) {
      ForEach(Array(quiz.questions.enumerated()), id: \.element.id) { index, item in
        // A re-ask's dot is a diamond, so the row shows which questions return.
        Image(systemName: item.isReask ? "diamond.fill" : "circle.fill")
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
      total: quiz.questions.count,
      correct: quiz.questions.filter { $0.state == .correct }.count,
      secondTry: quiz.questions.filter { $0.state == .correctOnSecondAttempt }.count,
      incorrect: quiz.questions.filter { $0.state == .incorrect }.count,
      remaining: quiz.questions.count - quiz.currentIndex - 1
    ))
  }

  private static let secondAttemptLineID = "quiz_second_attempt_line"

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

  /// The recognition answer the card holds, or nil until the infinitive, the conjugationgroup,
  /// and, unless it is a participle, the person are all given.
  private func recognitionAnswer(for question: QuizItem) -> RecognitionAnswer? {
    let infinitiv = question.answerFrame.answer(filling: answerBlanks)
    guard question.recognition != nil, !infinitiv.isEmpty, let recognitionTable else {
      return nil
    }
    let answer = RecognitionAnswer(infinitiv: infinitiv, table: recognitionTable, personNumber: recognitionPerson)
    return answer.conjugationgroup == nil ? nil : answer
  }

  private func submit(_ question: QuizItem) {
    let index = quiz.currentIndex
    if question.recognition != nil {
      guard let answer = recognitionAnswer(for: question) else {
        // Return with a choice missing: the field keeps the keyboard, and VoiceOver says what is
        // missing.
        UIAccessibility.post(notification: .announcement, argument: L.Recognition.incomplete)
        Task { @MainActor in
          try? await Task.sleep(for: .milliseconds(50))
          focusedBlank = 0
        }
        return
      }
      quiz.submitRecognition(answer)
    } else {
      quiz.submitAnswer(question.answerFrame.answer(filling: answerBlanks))
    }
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
      flashIncorrect()
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

  private func flashIncorrect() {
    wrongAnswerCount += 1
    showIncorrectFlash = true
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(0.6))
      withAnimation { showIncorrectFlash = false }
    }
  }

  private func choose(_ index: Int) {
    let questionIndex = quiz.currentIndex
    quiz.submitChoice(index)
    guard questionIndex < quiz.questions.count else {
      return
    }
    switch quiz.questions[questionIndex].isCorrect {
    case true:
      rightAnswerCount += 1
    case false:
      flashIncorrect()
    case nil:
      break
    }
  }

  /// The reminder's daily session, unless a quiz is under way or showing its results, which the
  /// learner returns to instead.
  private func startRequestedDailySession() {
    guard sheetScope == nil, let request = Current.dailySessionRequest else {
      return
    }
    Current.dailySessionRequest = nil
    guard !quiz.isInProgress, !quiz.shouldShowResults else {
      return
    }
    navigationPath = NavigationPath()
    quiz.start(scope: .daily(source: request.source))
  }

  /// A Review, My Mistakes, or Verb Essentials session names itself in the tab's bar, since its
  /// questions look like any quiz's.
  private var tabSessionTitle: String? {
    guard sheetScope == nil, quiz.isInProgress || quiz.shouldShowResults else {
      return nil
    }
    if quiz.scope.isVerbEssentials {
      return L.VerbEssentials.title
    }
    if quiz.scope.isRecognition {
      return L.Recognition.title
    }
    if quiz.scope.isSentences {
      return L.Sentences.title
    }
    if quiz.scope.isSpeedRound {
      return L.SpeedRound.title
    }
    if quiz.scope.isDaily {
      return L.DailySession.title
    }
    return quiz.scope.recordSession?.title
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

  /// The practice hub (Phase 13 of the pedagogy plan): what a session is, how long it takes, the
  /// level, Start, what the record has due or missed, the last result, the exercises beside the
  /// quiz, and the leaderboard last.
  private var startScreen: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(spacing: isLarge ? Layout.tripleDefaultSpacing * 2 : Layout.doubleDefaultSpacing) {
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

            if tabScope == .custom {
              customQuizSummary
            } else {
              sessionFacts
            }

            if tabScope == .myVerbs, !myVerbs.isEmpty {
              myVerbChips
            }

            Button {
              switch tabScope {
              case .allVerbs:
                quiz.start()
              case .custom:
                quiz.start(scope: .custom(customQuiz, myVerbs: myVerbs))
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
            .disabled(!canStart)
            .accessibilityHint(tabScope == .custom ? L.Accessibility.customQuizStartHint : L.Accessibility.quizStartHint)
            .accessibilityIdentifier("quiz_start_button")

            if tabScope == .allVerbs, let best = Current.practice.levelBest(at: level) {
              Label(L.PersonalBest.hubLine(best), systemImage: "star.fill")
                .font(isLarge ? .body : .subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("quiz_level_best")
            }
          }

          practiceSection

          exercisesSection

          if Current.gameCenter.isAuthenticated {
            // A flow, since the two German labels need more than an iPhone's line at large sizes.
            FlowLayout(spacing: Layout.defaultSpacing, centersRows: true) {
              leaderboardButton
              achievementsButton
            }
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

  /// How many questions, how long they take, and the level, which a tap changes here rather than
  /// in Settings.
  private var sessionFacts: some View {
    HStack(alignment: .top, spacing: Layout.defaultSpacing) {
      QuizFactTile(systemImage: "list.number", value: "\(Quiz.questionCount)", label: L.Quiz.questionsLabel, isLarge: isLarge)
      QuizFactTile(systemImage: "timer", value: L.Quiz.sessionMinutes, label: L.Quiz.minutesLabel, accessibilityLabel: L.Accessibility.quizSessionLength, isLarge: isLarge)
      levelMenu
    }
    // Equal heights when one label wraps to two lines.
    .fixedSize(horizontal: false, vertical: true)
    .transition(.opacity)
  }

  private var levelMenu: some View {
    Menu {
      Picker(L.Quiz.levelLabel, selection: Binding(get: { settings.quizLevel }, set: { settings.quizLevel = $0 })) {
        ForEach(QuizLevel.allCases, id: \.self) { quizLevel in
          Label(quizLevel.localizedName, systemImage: quizLevel.systemImage)
            .tag(quizLevel)
        }
      }
    } label: {
      QuizFactTile(systemImage: level.systemImage, value: level.localizedName, label: L.Quiz.levelLabel, showsMenuIndicator: true, isLarge: isLarge)
    }
    .buttonStyle(.plain)
    .accessibilityHint(L.Accessibility.quizLevelMenuHint)
    .accessibilityIdentifier("quiz_level_menu")
    .sensoryFeedback(.selection, trigger: settings.quizLevel)
  }

  /// A modest control below everything else, since the leaderboard is beside the point of
  /// practice, though one tap away (T6.6).
  private var leaderboardButton: some View {
    Button {
      Current.gameCenter.showLeaderboard(level: level)
      Current.analytics.signal(name: .tapViewLeaderboard, parameters: [ParameterKey.source.rawValue: AnalyticsSource.tab.rawValue])
    } label: {
      Label(L.GameCenter.viewLeaderboard, systemImage: "trophy")
        .font(isLarge ? .body : .subheadline)
    }
    .buttonStyle(.bordered)
    .tint(.customYellow)
    .controlSize(isLarge ? .regular : .small)
    .accessibilityHint(L.Accessibility.leaderboardHint)
    .accessibilityIdentifier("quiz_leaderboard_button")
  }

  private var achievementsButton: some View {
    Button {
      Current.gameCenter.showAchievements()
      Current.analytics.signal(name: .tapViewAchievements, parameters: [ParameterKey.source.rawValue: AnalyticsSource.tab.rawValue])
    } label: {
      Label(L.GameCenter.viewAchievements, systemImage: "rosette")
        .font(isLarge ? .body : .subheadline)
    }
    .buttonStyle(.bordered)
    .tint(.customYellow)
    .controlSize(isLarge ? .regular : .small)
    .accessibilityHint(L.Accessibility.achievementsHint)
    .accessibilityIdentifier("quiz_achievements_button")
  }

  /// A big symbol for the chosen scope, its name, and a line saying what the quiz will ask about.
  private var scopeHero: some View {
    VStack(spacing: Layout.defaultSpacing) {
      Image(systemName: heroSymbol)
        .font(.system(size: isLarge ? 180 : 64, weight: .semibold))
        .foregroundStyle(
          LinearGradient(colors: [.customYellow, .customYellow.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        )
        .contentTransition(.symbolEffect(.replace))
        .symbolEffect(.bounce, value: reduceMotion ? TabQuizScope.allVerbs : tabScope)
        .frame(height: isLarge ? 220 : 76)
        .accessibilityHidden(true)

      Text(heroTitle)
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
    case .custom:
      return "slider.horizontal.3"
    case .myVerbs:
      return myVerbs.isEmpty ? "star" : "star.fill"
    }
  }

  private var heroTitle: String {
    switch tabScope {
    case .allVerbs:
      return L.VerbBrowse.verbCount(Verb.verbs.count)
    case .custom:
      return L.CustomQuiz.title
    case .myVerbs:
      return L.MyVerbs.title
    }
  }

  private var heroDescription: String {
    switch tabScope {
    case .allVerbs:
      return L.Quiz.allVerbsDescription
    case .custom:
      if customQuiz.isEmpty {
        return L.CustomQuiz.emptyDescription
      }
      return customQuizLacksMyVerbs ? L.Quiz.myVerbsEmpty : L.CustomQuiz.description
    case .myVerbs:
      return myVerbs.isEmpty ? L.Quiz.myVerbsEmpty : L.Quiz.myVerbsCount(myVerbs.count)
    }
  }

  private var customQuiz: CustomQuiz {
    settings.customQuiz
  }

  /// A custom quiz kept from an earlier launch may name My Verbs after they have been cleared.
  private var customQuizLacksMyVerbs: Bool {
    customQuiz.verbSet == .myVerbs && myVerbs.isEmpty
  }

  private var canStart: Bool {
    switch tabScope {
    case .allVerbs:
      return true
    case .custom:
      return !customQuiz.isEmpty && !customQuizLacksMyVerbs
    case .myVerbs:
      return !myVerbs.isEmpty
    }
  }

  /// What a custom quiz will ask, and the way to change it, one tap from Start.
  private var customQuizSummary: some View {
    VStack(spacing: Layout.doubleDefaultSpacing) {
      if !customQuiz.isEmpty {
        CustomQuizSummaryCard(custom: customQuiz, level: level, byLevelLabel: L.CustomQuiz.byLevel, isLarge: isLarge)
          .accessibilityIdentifier("custom_quiz_summary")
      }

      HStack(spacing: Layout.defaultSpacing) {
        NavigationLink(value: CustomQuizDestination.editor) {
          Label(customQuiz.isEmpty ? L.CustomQuiz.choose : L.CustomQuiz.change, systemImage: "slider.horizontal.3")
            .font(isLarge ? .title3.bold() : .headline)
            .padding(.horizontal, Layout.defaultSpacing)
            .padding(.vertical, 4)
            .frame(maxHeight: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.customYellow)
        .accessibilityHint(L.Accessibility.customQuizEditHint)
        .accessibilityIdentifier("custom_quiz_choose_button")

        if canStart {
          practiceSetShareMenu
        }
      }
      // Equal heights, since a Menu's bordered label sits a little taller than a NavigationLink's.
      .fixedSize(horizontal: false, vertical: true)
    }
    .transition(.opacity)
    .fullScreenCover(isPresented: $isShowingQRCode) {
      PracticeSetQRView(practiceSet: sharedPracticeSet)
    }
  }

  /// The custom quiz as a practice set, for a teacher to hand a class (Phase 10).
  private var sharedPracticeSet: PracticeSet {
    PracticeSet(sharing: customQuiz, level: level, myVerbs: myVerbs)
  }

  private var practiceSetShareMenu: some View {
    Menu {
      Button {
        sharedPracticeSet.signalShare(method: PracticeSet.linkMethod)
        ShareSheet.present(
          text: sharedPracticeSet.shareText(lang: settings.conjugationgroupLang, levelFallback: level),
          title: L.PracticeSet.title,
          icon: UIImage(named: settings.appIcon.previewAssetName),
          anchorLabel: L.VerbView.share,
          anchorRect: shareButtonFrame == .zero ? nil : shareButtonFrame
        )
      } label: {
        Label(L.PracticeSet.shareLink, systemImage: "link")
      }
      .accessibilityIdentifier("practice_set_share_link")

      Button {
        sharedPracticeSet.signalShare(method: PracticeSet.qrCodeMethod)
        isShowingQRCode = true
      } label: {
        Label(L.PracticeSet.showQRCode, systemImage: "qrcode")
      }
      .accessibilityIdentifier("practice_set_show_qr_code")
    } label: {
      Label(L.VerbView.share, systemImage: "square.and.arrow.up")
        .font(isLarge ? .title3.bold() : .headline)
        .padding(.horizontal, Layout.defaultSpacing)
        .padding(.vertical, 4)
        .frame(maxHeight: .infinity)
    }
    .buttonStyle(.bordered)
    .tint(.customYellow)
    .onGeometryChange(for: CGRect.self) { proxy in
      proxy.frame(in: .global)
    } action: { frame in
      shareButtonFrame = frame
    }
    .accessibilityHint(L.Accessibility.practiceSetShareHint)
    .accessibilityIdentifier("custom_quiz_share_button")
  }

  /// The daily session with its streak (Phase 22 of the pedagogy plan), Review and My Mistakes,
  /// each started directly or saying why there is nothing to ask (Phase 12), Mastery (Phase 20),
  /// and the last quiz's results.
  private var practiceSection: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.PracticeSession.heading)
        .font(isLarge ? .title3.bold() : .headline)
        .foregroundStyle(.customForeground)
        .accessibilityAddTraits(.isHeader)

      let streak = Current.practice.streakStatus()
      QuizHubRow(
        title: L.DailySession.title,
        detail: streak.hubDetail,
        systemImage: streak.length > 0 ? "flame.fill" : "calendar",
        identifier: "quiz_daily",
        hint: L.Accessibility.dailySessionStartHint,
        isLarge: isLarge
      ) {
        quiz.start(scope: .daily())
      }

      ForEach([QuizRecordSession.review, .mistakes], id: \.self) { session in
        let count = session.askableCount(from: Current.practice)
        QuizHubRow(
          title: session.title,
          detail: session.hubDetail(count: count, daysUntilNextDue: Current.practice.daysUntilNextDue()),
          systemImage: session.hubSystemImage,
          identifier: session.hubIdentifier,
          hint: session.hubHint,
          isLarge: isLarge,
          start: count > 0 ? { quiz.start(scope: .recordSession(session)) } : nil
        )
      }

      let mastery = Mastery(level: level, record: Current.practice.record)
      QuizHubRow(
        title: L.Mastery.title,
        detail: L.Mastery.hubSummary(mastery.masteredPatternCount, mastery.patternCount, mastery.masteredVerbCount, mastery.verbCount),
        systemImage: "circle.grid.3x3.fill",
        identifier: "quiz_mastery",
        hint: L.Accessibility.masteryHubHint,
        isLarge: isLarge,
        trailingSystemImage: "chevron.right.circle.fill"
      ) {
        navigationPath.append(MasteryDestination())
      }

      if let lastResult = Current.practice.lastResult {
        LastQuizResultRow(result: lastResult, isLarge: isLarge)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  /// Ways to practice beside the quiz: Verb Essentials (Phase 15 of the pedagogy plan), the ablaut
  /// groups' practice (Phase 16), which opens a list of the groups, Name the Conjugation (Phase
  /// 17), Sentences (Phase 18), and the exercises of later phases.
  private var exercisesSection: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.Quiz.exercises)
        .font(isLarge ? .title3.bold() : .headline)
        .foregroundStyle(.customForeground)
        .accessibilityAddTraits(.isHeader)

      QuizHubRow(
        title: L.VerbEssentials.title,
        detail: L.VerbEssentials.description,
        systemImage: "square.3.layers.3d",
        identifier: "quiz_verb_essentials",
        hint: L.Accessibility.verbEssentialsStartHint,
        isLarge: isLarge
      ) {
        quiz.start(scope: .verbEssentials())
      }

      QuizHubRow(
        title: L.AblautPractice.title,
        detail: L.AblautPractice.hubDescription,
        systemImage: "waveform.path",
        identifier: "quiz_ablaut_practice",
        hint: L.Accessibility.ablautPracticeHubHint,
        isLarge: isLarge,
        trailingSystemImage: "chevron.right.circle.fill"
      ) {
        navigationPath.append(AblautPracticeDestination())
      }

      QuizHubRow(
        title: L.Recognition.title,
        detail: L.Recognition.description,
        systemImage: "text.magnifyingglass",
        identifier: "quiz_recognition",
        hint: L.Accessibility.recognitionStartHint,
        isLarge: isLarge
      ) {
        quiz.start(scope: .recognition())
      }

      let hasSentences = !GapSentences.askable(at: level).isEmpty
      QuizHubRow(
        title: L.Sentences.title,
        detail: hasSentences ? L.Sentences.description : L.Sentences.empty,
        systemImage: "text.insert",
        identifier: "quiz_sentences",
        hint: L.Accessibility.sentencesStartHint,
        isLarge: isLarge,
        start: hasSentences ? { quiz.start(scope: .sentences()) } : nil
      )

      let masteredCount = SpeedRound.masteredItems(in: Current.practice.record).count
      let opensSpeedRound = masteredCount >= SpeedRound.minimumMasteredCount
      QuizHubRow(
        title: L.SpeedRound.title,
        detail: opensSpeedRound
          ? Current.practice.speedRoundBest.map { L.SpeedRound.descriptionWithBest($0) } ?? L.SpeedRound.description
          : L.SpeedRound.locked(needed: SpeedRound.minimumMasteredCount, mastered: masteredCount),
        systemImage: "bolt.fill",
        identifier: "quiz_speed_round",
        hint: L.Accessibility.speedRoundStartHint,
        isLarge: isLarge,
        start: opensSpeedRound ? { quiz.start(scope: .speedRound()) } : nil
      )
    }
    .frame(maxWidth: .infinity, alignment: .leading)
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
  // The value moves below the label rather than wrapping beside it, since at large text sizes
  // "Conjugationgroup:" leaves "Präsens Indikativ" a column one word wide.
  private func labeledRow<Value: View>(_ label: String, @ViewBuilder value: () -> Value) -> some View {
    ViewThatFits(in: .horizontal) {
      HStack(alignment: .firstTextBaseline, spacing: 0) {
        Text(label + " ")
          .foregroundStyle(.customYellow)
        value()
      }
      .fixedSize(horizontal: true, vertical: false)

      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .foregroundStyle(.customYellow)
        value()
      }
    }
  }
}

/// A Speed Round's missed question, shown above the next one, since the round does not stop for a
/// correction: "fahren · er fuhr".
private struct SpeedRoundMissLine: View {
  let question: QuizItem

  var body: some View {
    let answer = [question.pronoun, question.correctAnswer].compactMap { $0 }.joined(separator: " ")
    HStack(spacing: 6) {
      Image(systemName: "xmark.circle.fill")
        .foregroundStyle(.customRed)
      Text(verbatim: question.verb.infinitiv.inUserRegion + " ·")
        .foregroundStyle(Color.secondary)
      Text(mixedCaseString: answer)
        .foregroundStyle(.customForeground)
    }
    .font(.subheadline)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(L.SpeedRound.missed(MixedCaseAccessibility.accessibilityLabel(for: answer)))
    .accessibilityIdentifier("speed_round_miss")
  }
}

/// One fact about the quiz about to start: a yellow symbol, a value, and what the value is.
private struct QuizFactTile: View {
  let systemImage: String
  let value: String
  let label: String
  var accessibilityLabel: String?
  /// The level's tile is a menu, and its chevron says so.
  var showsMenuIndicator = false
  var isLarge = false

  var body: some View {
    VStack(spacing: 6) {
      Image(systemName: systemImage)
        .font(isLarge ? .system(size: 48) : .title)
        .foregroundStyle(.customYellow)
        .contentTransition(.symbolEffect(.replace))
        .frame(height: isLarge ? 64 : 36)
        .accessibilityHidden(true)
      HStack(spacing: 3) {
        Text(verbatim: value)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        if showsMenuIndicator {
          Image(systemName: "chevron.up.chevron.down")
            .font(isLarge ? .subheadline.bold() : .caption2.bold())
            .foregroundStyle(.customYellow)
            .accessibilityHidden(true)
        }
      }
      .font(isLarge ? .title2.bold() : .headline)
      .foregroundStyle(.customForeground)
      // Color.secondary, not .secondary, which inside a Menu takes the app's red tint.
      Text(label)
        .font(isLarge ? .subheadline : .caption)
        .foregroundStyle(Color.secondary)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.vertical, isLarge ? Layout.doubleDefaultSpacing : Layout.defaultSpacing * 1.5)
    .padding(.horizontal, Layout.defaultSpacing)
    .background(Color.customYellow.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(Color.customYellow.opacity(0.25), lineWidth: 1)
    }
    .contentShape(RoundedRectangle(cornerRadius: 16))
    .accessibilityElement(children: .combine)
    .modifier(OptionalAccessibilityLabel(label: accessibilityLabel))
  }
}

private struct OptionalAccessibilityLabel: ViewModifier {
  let label: String?

  func body(content: Content) -> some View {
    if let label {
      content.accessibilityLabel(label)
    } else {
      content
    }
  }
}

/// The last quiz's results, kept on the device: what was quizzed, at which level, how it went, and
/// when.
private struct LastQuizResultRow: View {
  let result: LastQuizResult
  var isLarge = false

  var body: some View {
    HStack(spacing: Layout.doubleDefaultSpacing) {
      Image(systemName: "flag.checkered")
        .font(isLarge ? .largeTitle : .title2)
        .foregroundStyle(.customYellow)
        .frame(width: isLarge ? 56 : 36)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 2) {
        Text(L.Quiz.lastQuiz)
          .font(isLarge ? .title3.bold() : .headline)
          .foregroundStyle(.customForeground)
        Text(verbatim: subjectLine)
          .font(isLarge ? .body : .subheadline)
          .foregroundStyle(.customForeground)
          .germanPronunciation(forReal: result.kind == .verbPage)
          .fixedSize(horizontal: false, vertical: true)
        Text(verbatim: resultLine)
          .font((isLarge ? Font.body : .subheadline).monospacedDigit())
          .foregroundStyle(Color.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)
    }
    .padding(Layout.doubleDefaultSpacing)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.customYellow.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(Color.customYellow.opacity(0.25), lineWidth: 1)
    }
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("quiz_last_result")
  }

  /// "All Verbs · Elementary · today"
  private var subjectLine: String {
    [result.title, result.level?.localizedName, relativeDay].compactMap { $0 }.joined(separator: " · ")
  }

  /// "Correct: 8 / 10 · Score: 85", with a second try's count when there was one.
  private var resultLine: String {
    var parts = ["\(L.Quiz.correct) \(result.correctCount) / \(result.questionCount)"]
    if result.secondAttemptCount > 0 {
      parts.append("\(L.Quiz.secondTry) \(result.secondAttemptCount)")
    }
    // A Speed Round counts right answers and scores no points.
    if result.kind != .speedRound {
      parts.append("\(L.Quiz.score) \(result.score)")
    }
    return parts.joined(separator: " · ")
  }

  private var relativeDay: String? {
    guard let days = PracticeRecord.daysBetween(result.date, and: .now) else {
      return nil
    }
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .named
    formatter.unitsStyle = .full
    // The app's language, which can differ from the region's.
    formatter.locale = Locale(identifier: Bundle.main.preferredLocalizations.first ?? "en")
    // A clock set back would otherwise make the last quiz tomorrow's.
    return formatter.localizedString(from: DateComponents(day: -max(days, 0)))
  }
}

/// A row of the Quiz tab's hub: a button that starts a session while it has questions, and
/// otherwise a line saying why it has none.
private struct QuizHubRow: View {
  let title: String
  let detail: String
  let systemImage: String
  /// Ends in `_button` while the row starts something, and in `_empty` otherwise.
  let identifier: String
  let hint: String
  var isLarge = false
  /// A row that opens a page rather than starting a session shows a chevron.
  var trailingSystemImage = "play.circle.fill"
  /// Nil for a row with nothing to start.
  let start: (() -> Void)?

  var body: some View {
    if let start {
      Button(action: start) {
        content
      }
      .buttonStyle(.plain)
      .accessibilityHint(hint)
      .accessibilityIdentifier("\(identifier)_button")
    } else {
      content
        .accessibilityIdentifier("\(identifier)_empty")
    }
  }

  private var content: some View {
    HStack(spacing: Layout.doubleDefaultSpacing) {
      Image(systemName: systemImage)
        .font(isLarge ? .largeTitle : .title2)
        .foregroundStyle(.customYellow)
        .frame(width: isLarge ? 56 : 36)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(isLarge ? .title3.bold() : .headline)
          .foregroundStyle(.customForeground)
        // Color.secondary, not .secondary, which inside a Button takes the app's red tint.
        Text(detail)
          .font(isLarge ? .body : .subheadline)
          .foregroundStyle(Color.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)

      if start != nil {
        Image(systemName: trailingSystemImage)
          .font(isLarge ? .largeTitle : .title)
          .foregroundStyle(.customYellow)
          .accessibilityHidden(true)
      }
    }
    .padding(Layout.doubleDefaultSpacing)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.customYellow.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(Color.customYellow.opacity(0.25), lineWidth: 1)
    }
    .contentShape(RoundedRectangle(cornerRadius: 16))
    .accessibilityElement(children: .combine)
  }
}

/// What a record session's row on the hub says, shows, and is called.
private extension QuizRecordSession {
  func hubDetail(count: Int, daysUntilNextDue: Int?) -> String {
    switch self {
    case .mistakes:
      return count > 0 ? L.PracticeSession.mistakesCount(count) : L.PracticeSession.mistakesEmpty
    case .review:
      if count > 0 {
        return L.PracticeSession.reviewCount(count)
      }
      return daysUntilNextDue.map { L.PracticeSession.reviewNextDue($0) } ?? L.PracticeSession.reviewEmpty
    }
  }

  var hubHint: String {
    switch self {
    case .mistakes:
      return L.Accessibility.mistakesStartHint
    case .review:
      return L.Accessibility.reviewStartHint
    }
  }

  var hubSystemImage: String {
    switch self {
    case .mistakes:
      return "arrow.uturn.backward.circle"
    case .review:
      return "clock.arrow.circlepath"
    }
  }

  var hubIdentifier: String {
    switch self {
    case .mistakes:
      return "quiz_mistakes"
    case .review:
      return "quiz_review"
    }
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

// Semantic ordering: the picker's segments, the default first.
enum TabQuizScope: CaseIterable {
  case allVerbs
  case myVerbs
  case custom

  var displayName: String {
    switch self {
    case .allVerbs:
      return L.Quiz.allVerbs
    case .custom:
      return L.CustomQuiz.segment
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
