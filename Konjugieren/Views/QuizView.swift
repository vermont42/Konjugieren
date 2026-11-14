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
    .environment(\.isBeneathQuiz, true)
    .accessibilityAction(.magicTap) {
      if quiz.correction != nil {
        quiz.continueAfterCorrection()
      }
    }
    // Ten More closes the results onto the quiz, which is in progress again, so a sheet stays.
    .sheet(isPresented: $quiz.shouldShowResults, onDismiss: {
      if sheetScope != nil, !quiz.isInProgress {
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
    // Ten More leaves currentIndex where the results found it, at the first new question, and the
    // field returns only once the results sheet has gone.
    .onChange(of: quiz.roundCount) { _, roundCount in
      guard roundCount > 1 else {
        return
      }
      answerBlanks = []
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

  @ViewBuilder
  private func quizContent(question: QuizItem) -> some View {
    VStack(spacing: Layout.doubleDefaultSpacing) {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        if question.isReask {
          Label(L.Quiz.askedAgain, systemImage: "arrow.counterclockwise")
            .font(.subheadline.bold())
            .foregroundStyle(.customYellow)
            .accessibilityIdentifier("quiz_asked_again")
        }

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
          if settings.quizClock == .show {
            Text(label: L.Quiz.elapsed, value: quiz.elapsedText)
              .font(.caption.monospacedDigit())
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

  /// A Review or My Mistakes session names itself in the tab's bar, since its questions look like
  /// any quiz's.
  private var tabSessionTitle: String? {
    guard sheetScope == nil, quiz.isInProgress || quiz.shouldShowResults else {
      return nil
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
          }

          if tabScope == .custom {
            customQuizSummary
          } else {
            HStack(alignment: .top, spacing: Layout.defaultSpacing) {
              QuizFactTile(systemImage: "list.number", value: "\(Quiz.questionCount)", label: L.Quiz.questionsLabel, isLarge: isLarge)
              QuizFactTile(systemImage: level.systemImage, value: level.localizedName, label: L.Quiz.levelLabel, isLarge: isLarge)
              QuizFactTile(systemImage: "trophy.fill", value: "\(Quiz.pointsPerCorrect)", label: L.Quiz.pointsPerAnswer, isLarge: isLarge)
            }
            // Equal heights when one label wraps to two lines.
            .fixedSize(horizontal: false, vertical: true)
          }

          if tabScope == .myVerbs, !myVerbs.isEmpty {
            myVerbChips
          }

          recordSessions
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

  /// Review and My Mistakes, each started directly, or saying why there is nothing to ask (Phase
  /// 12 of the pedagogy plan). Phase 13 moves them into the practice hub.
  private var recordSessions: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.PracticeSession.heading)
        .font(isLarge ? .title3.bold() : .headline)
        .foregroundStyle(.customForeground)
        .accessibilityAddTraits(.isHeader)

      ForEach([QuizRecordSession.review, .mistakes], id: \.self) { session in
        QuizRecordSessionRow(
          session: session,
          count: session.askableCount(from: Current.practice),
          daysUntilNextDue: Current.practice.daysUntilNextDue(),
          isLarge: isLarge
        ) {
          quiz.start(scope: .recordSession(session))
        }
      }
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

/// One of the record's sessions on the Quiz tab: a button that starts it while it has questions,
/// and otherwise a line saying why it has none.
private struct QuizRecordSessionRow: View {
  let session: QuizRecordSession
  let count: Int
  let daysUntilNextDue: Int?
  var isLarge = false
  let start: () -> Void

  var body: some View {
    if count > 0 {
      Button(action: start) {
        content
      }
      .buttonStyle(.plain)
      .accessibilityHint(hint)
      .accessibilityIdentifier("quiz_\(identifier)_button")
    } else {
      content
        .accessibilityIdentifier("quiz_\(identifier)_empty")
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
        Text(session.title)
          .font(isLarge ? .title3.bold() : .headline)
          .foregroundStyle(.customForeground)
        // Color.secondary, not .secondary, which inside a Button takes the app's red tint.
        Text(detail)
          .font(isLarge ? .body : .subheadline)
          .foregroundStyle(Color.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)

      if count > 0 {
        Image(systemName: "play.circle.fill")
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

  private var detail: String {
    switch session {
    case .mistakes:
      return count > 0 ? L.PracticeSession.mistakesCount(count) : L.PracticeSession.mistakesEmpty
    case .review:
      if count > 0 {
        return L.PracticeSession.reviewCount(count)
      }
      return daysUntilNextDue.map { L.PracticeSession.reviewNextDue($0) } ?? L.PracticeSession.reviewEmpty
    }
  }

  private var hint: String {
    switch session {
    case .mistakes:
      return L.Accessibility.mistakesStartHint
    case .review:
      return L.Accessibility.reviewStartHint
    }
  }

  private var systemImage: String {
    switch session {
    case .mistakes:
      return "arrow.uturn.backward.circle"
    case .review:
      return "clock.arrow.circlepath"
    }
  }

  private var identifier: String {
    switch session {
    case .mistakes:
      return "mistakes"
    case .review:
      return "review"
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
