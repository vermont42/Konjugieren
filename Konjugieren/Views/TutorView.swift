// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct TutorView: View {
  @State private var messages: [TutorMessage] = []
  @State private var inputText = ""
  @State private var isGenerating = false
  @State private var recommendation: PracticeRecommendation?
  @State private var isLoadingRecommendation = false
  @State private var showingTests = false
  @State private var showingRecommendations = false
  @State private var showingSampleQueries = false
  @State private var showingHint = true
  @State private var hasQuizHistory = false
  @State private var hasLoadedHistory = false
  @FocusState private var isInputFocused: Bool

  private static let suggestions = [
    "Conjugate singen in the Präteritum.",
    "What is the Konjunktiv II of sein?",
    "What is the past participle of trinken?",
    "Conjugate laufen in the future tense.",
    "What is the imperative of helfen?",
    "How do you say \u{2018}I would have sung\u{2019} in German?",
    "What is the Perfekt of gehen?",
    "Conjugate sprechen in the Präsens.",
    "How do you say \u{2018}we had written\u{2019} in German?",
    "What is the Konjunktiv I of geben?",
    "Conjugate anfangen in the Perfekt.",
    "What are all the Präsens conjugations of wissen?",
    "How do you conjugate können in the Präteritum?",
    "What is the Futur of nehmen?",
    "Conjugate essen in the Plusquamperfekt.",
    "How do you say \u{2018}they would carry\u{2019} in German?"
  ]

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(spacing: 0) {
        ScrollViewReader { proxy in
          ScrollView {
            VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
              if hasQuizHistory {
                Button(L.Tutor.getSuggestions) {
                  showingRecommendations = true
                }
                .funButton()
                .frame(maxWidth: .infinity)

                Text(L.Tutor.practiceRecommendationsDescription)
                  .settingsLabel()
              }

              Button(L.Tutor.getSampleQuery) {
                showingSampleQueries = true
              }
              .funButton()
              .frame(maxWidth: .infinity)

              Text(L.Tutor.getSampleQueryDescription)
                .settingsLabel()

              Text(L.Tutor.poweredBy)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, Layout.defaultSpacing)

              ForEach(messages) { message in
                messageBubble(message)
                  .id(message.id)
              }
            }
            .padding(Layout.doubleDefaultSpacing)
          }
          .onChange(of: messages.count) {
            if hasLoadedHistory, let lastMessage = messages.last {
              withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
              }
            }
          }
        }

        if showingHint {
          Text(L.Tutor.inputPlaceholder)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, Layout.defaultSpacing)
        }

        Rectangle()
          .fill(Color.customYellow)
          .frame(height: 1)
          .padding(.horizontal, Layout.doubleDefaultSpacing)

        inputBar
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(L.Tutor.heading)
          .font(.headline)
          .onTapGesture(count: 3) {
            showingTests = true
          }
      }
    }
    .sheet(isPresented: $showingTests) {
      TutorTestView()
    }
    .sheet(isPresented: $showingRecommendations) {
      recommendationsSheet
    }
    .sheet(isPresented: $showingSampleQueries) {
      sampleQueriesSheet
    }
    .onAppear {
      Current.analytics.signal(name: .viewTutorView)
      messages = TutorChatHistory.load(getterSetter: Current.getterSetter)
      hasQuizHistory = !QuizErrorHistory.load(getterSetter: Current.getterSetter).isEmpty
    }
    .task {
      hasLoadedHistory = true
    }
    .onDisappear {
      Current.languageModelService.resetTutorSession()
    }
    .onChange(of: isInputFocused) {
      if isInputFocused {
        showingHint = false
      }
    }
  }

  private var sampleQueriesSheet: some View {
    NavigationStack {
      ZStack {
        Color.customBackground
          .ignoresSafeArea()

        ScrollView {
          VStack(spacing: Layout.defaultSpacing) {
            ForEach(Self.suggestions, id: \.self) { suggestion in
              Button {
                inputText = suggestion
                isInputFocused = true
                showingSampleQueries = false
              } label: {
                Text(suggestion)
                  .fixedSize(horizontal: false, vertical: true)
              }
              .font(.subheadline)
              .foregroundStyle(.customYellow)
              .padding(.horizontal, Layout.defaultSpacing + 4)
              .padding(.vertical, Layout.defaultSpacing / 2)
              .background(
                Capsule()
                  .strokeBorder(Color.customYellow.opacity(0.4))
              )
            }
          }
          .padding(Layout.doubleDefaultSpacing)
        }
      }
      .navigationTitle(L.Tutor.getSampleQuery)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(L.Navigation.dismiss) {
            showingSampleQueries = false
          }
        }
      }
    }
  }

  private var recommendationsSheet: some View {
    NavigationStack {
      ZStack {
        Color.customBackground
          .ignoresSafeArea()

        ScrollView {
          recommendationContent
            .padding(Layout.doubleDefaultSpacing)
        }
      }
      .navigationTitle(L.Tutor.practiceRecommendations)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(L.Navigation.dismiss) {
            showingRecommendations = false
          }
        }
      }
    }
    .onAppear {
      loadRecommendations()
    }
  }

  @ViewBuilder
  private var recommendationContent: some View {
    if isLoadingRecommendation {
      HStack(spacing: Layout.defaultSpacing) {
        ProgressView()
        Text(L.Tutor.loading)
          .foregroundStyle(.customForeground)
          .font(.subheadline)
      }
      .frame(maxWidth: .infinity)
      .padding(.top, Layout.tripleDefaultSpacing)
    } else if let recommendation, !recommendation.items.isEmpty {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        Text(recommendation.summary)
          .foregroundStyle(.customForeground)
          .font(.subheadline)
          .fixedSize(horizontal: false, vertical: true)

        ForEach(recommendation.items, id: \.area) { item in
          HStack(alignment: .top, spacing: Layout.defaultSpacing) {
            Image(systemName: "target")
              .foregroundStyle(.customYellow)
            VStack(alignment: .leading, spacing: 2) {
              Text(item.area)
                .foregroundStyle(.customForeground)
                .font(.subheadline.weight(.semibold))
              Text(item.reason)
                .foregroundStyle(.customForeground)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
        }
      }
    }
  }

  private func messageBubble(_ message: TutorMessage) -> some View {
    HStack {
      if message.role == .user {
        Spacer(minLength: 60)
      }

      Text(message.content)
        .foregroundStyle(message.role == .user ? .white : .customForeground)
        .padding(Layout.defaultSpacing + 4)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(message.role == .user ? Color.accentColor : Color.customBackground)
            .shadow(radius: 1)
        )
        .fixedSize(horizontal: false, vertical: true)

      if message.role == .assistant {
        Spacer(minLength: 60)
      }
    }
  }

  private var inputBar: some View {
    HStack(spacing: Layout.defaultSpacing) {
      TextField("", text: $inputText, axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .lineLimit(1...4)
        .focused($isInputFocused)
        .submitLabel(.send)
        .onSubmit { sendMessage() }

      Button {
        sendMessage()
      } label: {
        if isGenerating {
          ProgressView()
            .frame(width: 24, height: 24)
        } else {
          Image(systemName: "arrow.up.circle.fill")
            .font(.title2)
            .foregroundStyle(.customYellow)
        }
      }
      .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isGenerating)
      .accessibilityLabel(L.Tutor.send)
    }
    .padding(Layout.doubleDefaultSpacing)
    .background(Color.customBackground)
  }

  private func sendMessage() {
    let trimmed = inputText.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty, !isGenerating else { return }

    let userMessage = TutorMessage(role: .user, content: trimmed)
    messages.append(userMessage)
    inputText = ""
    isGenerating = true
    Current.soundPlayer.play(.pop)
    Current.analytics.signal(name: .tapSendTutorMessage)
    saveMessages()

    Task {
      do {
        let response = try await Current.languageModelService.sendTutorMessage(trimmed)
        let assistantMessage = TutorMessage(role: .assistant, content: response)
        messages.append(assistantMessage)
        Current.soundPlayer.play(.pop)
      } catch {
        let errorMessage = TutorMessage(role: .assistant, content: L.Tutor.unavailable)
        messages.append(errorMessage)
        Current.soundPlayer.play(.pop)
      }
      isGenerating = false
      saveMessages()
    }
  }

  private func saveMessages() {
    var trimmed = messages
    if trimmed.count > TutorChatHistory.maxMessages {
      trimmed = Array(trimmed.suffix(TutorChatHistory.maxMessages))
    }
    TutorChatHistory.save(trimmed, getterSetter: Current.getterSetter)
  }

  private func loadRecommendations() {
    let aggregated = QuizErrorHistory.aggregated(getterSetter: Current.getterSetter)
    guard !aggregated.isEmpty else { return }

    isLoadingRecommendation = true
    Task {
      do {
        recommendation = try await Current.languageModelService.recommendPractice(aggregatedErrors: aggregated)
        Current.soundPlayer.play(.pop)
      } catch {
        // Silently fail — recommendations are supplementary
      }
      isLoadingRecommendation = false
    }
  }
}

struct FlowLayout: SwiftUI.Layout {
  let spacing: CGFloat

  func sizeThatFits(proposal: ProposedViewSize, subviews: SwiftUI.Layout.Subviews, cache: inout ()) -> CGSize {
    let result = arrangeSubviews(proposal: proposal, subviews: subviews)
    return result.size
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: SwiftUI.Layout.Subviews, cache: inout ()) {
    let result = arrangeSubviews(proposal: proposal, subviews: subviews)
    for (index, subview) in subviews.enumerated() {
      let point = result.positions[index]
      subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
    }
  }

  private func arrangeSubviews(proposal: ProposedViewSize, subviews: SwiftUI.Layout.Subviews) -> FlowLayoutResult {
    let maxWidth = proposal.width ?? .infinity
    var positions: [CGPoint] = []
    var x: CGFloat = 0
    var y: CGFloat = 0
    var rowHeight: CGFloat = 0

    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if x + size.width > maxWidth && x > 0 {
        x = 0
        y += rowHeight + spacing
        rowHeight = 0
      }
      positions.append(CGPoint(x: x, y: y))
      rowHeight = max(rowHeight, size.height)
      x += size.width + spacing
    }

    return FlowLayoutResult(
      size: CGSize(width: maxWidth, height: y + rowHeight),
      positions: positions
    )
  }
}

private struct FlowLayoutResult {
  let size: CGSize
  let positions: [CGPoint]
}
