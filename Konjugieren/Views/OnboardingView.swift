// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct OnboardingView: View {
  let isReshow: Bool
  @Environment(\.dismiss) private var dismiss
  @State private var currentPage = 0
  @State private var getStartedOffset: CGFloat = 100
  @State private var getStartedOpacity: Double = 0

  private static let lastPage = 4
  fileprivate static let entranceAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)

  init(isReshow: Bool = false) {
    self.isReshow = isReshow
  }

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack {
        HStack {
          Spacer()
          if currentPage < OnboardingView.lastPage {
            Button(isReshow ? L.Onboarding.dismiss : L.Onboarding.skip) {
              finishOnboarding()
            }
            .foregroundStyle(.customYellow)
            .padding(.trailing, Layout.doubleDefaultSpacing)
          }
        }

        TabView(selection: $currentPage) {
          OnboardingPageView(
            symbolName: "mug.fill",
            title: L.Onboarding.welcomeTitle,
            bodyText: L.Onboarding.welcomeBody,
            infoButtonTitle: L.Onboarding.conjugationgroupButtonTitle,
            sheetHeading: L.Onboarding.conjugationgroupHeading,
            sheetBody: L.Onboarding.conjugationgroupBody
          )
          .tag(0)

          OnboardingPageView(
            symbolName: "list.bullet.rectangle.portrait.fill",
            title: L.Onboarding.browseTitle,
            bodyText: L.Onboarding.browseBody,
            navigationButtonTitle: L.Onboarding.browseVerbsButton,
            navigationAction: .navigateToTab(.verbs),
            onNavigate: { finishOnboarding() }
          )
          .tag(1)

          OnboardingPageView(
            symbolName: "figure.and.child.holdinghands",
            title: L.Onboarding.familiesTitle,
            bodyText: L.Onboarding.familiesBody,
            navigationButtonTitle: L.Onboarding.exploreFamiliesButton,
            navigationAction: .navigateToTab(.families),
            onNavigate: { finishOnboarding() }
          )
          .tag(2)

          OnboardingPageView(
            symbolName: "trophy.fill",
            title: L.Onboarding.quizTitle,
            bodyText: L.Onboarding.quizBody,
            navigationButtonTitle: L.Onboarding.startQuizButton,
            navigationAction: .navigateToTab(.quiz),
            onNavigate: { finishOnboarding() }
          )
          .tag(3)

          OnboardingPageView(
            symbolName: "figure.water.fitness",
            title: L.Onboarding.learnTitle,
            bodyText: L.Onboarding.learnBody,
            navigationButtonTitle: L.Onboarding.readArticlesButton,
            navigationAction: .navigateToTab(.info),
            onNavigate: { finishOnboarding() },
            animateContent: true
          )
          .tag(4)
        }
        .tabViewStyle(.page)

        if currentPage == OnboardingView.lastPage {
          Button(L.Onboarding.getStarted) {
            Current.soundPlayer.play(.chime)
            finishOnboarding()
          }
          .funButton()
          .padding(.bottom, Layout.tripleDefaultSpacing)
          .offset(y: getStartedOffset)
          .opacity(getStartedOpacity)
        }
      }
    }
    .onChange(of: currentPage) { oldValue, newValue in
      if newValue == OnboardingView.lastPage {
        withAnimation(OnboardingView.entranceAnimation) {
          getStartedOffset = 0
          getStartedOpacity = 1
        }
      } else if oldValue == OnboardingView.lastPage {
        getStartedOffset = 100
        getStartedOpacity = 0
      }
    }
  }

  private func finishOnboarding() {
    if !isReshow {
      Current.settings.hasSeenOnboarding = true
    }
    dismiss()
  }
}

private enum OnboardingNavigationAction {
  case none
  case navigateToTab(TabSelection)
}

private struct OnboardingPageView: View {
  let symbolName: String
  let title: String
  let bodyText: String
  let infoButtonTitle: String?
  let sheetHeading: String?
  let sheetBody: String?
  let navigationButtonTitle: String?
  let navigationAction: OnboardingNavigationAction
  let onNavigate: () -> Void
  let animateContent: Bool

  @State private var showingSheet = false
  @State private var contentOffset: CGFloat = 100
  @State private var contentOpacity: Double = 0

  init(
    symbolName: String,
    title: String,
    bodyText: String,
    infoButtonTitle: String? = nil,
    sheetHeading: String? = nil,
    sheetBody: String? = nil,
    navigationButtonTitle: String? = nil,
    navigationAction: OnboardingNavigationAction = .none,
    onNavigate: @escaping () -> Void = {},
    animateContent: Bool = false
  ) {
    self.symbolName = symbolName
    self.title = title
    self.bodyText = bodyText
    self.infoButtonTitle = infoButtonTitle
    self.sheetHeading = sheetHeading
    self.sheetBody = sheetBody
    self.navigationButtonTitle = navigationButtonTitle
    self.navigationAction = navigationAction
    self.onNavigate = onNavigate
    self.animateContent = animateContent
  }

  var body: some View {
    VStack(spacing: Layout.doubleDefaultSpacing) {
      Spacer()

      Image(systemName: symbolName)
        .font(.system(size: 80))
        .foregroundStyle(.customYellow)

      Text(title)
        .headingLabel()
        .foregroundStyle(.customForeground)

      Text(bodyText)
        .font(.system(size: 16))
        .foregroundStyle(.customForeground)
        .multilineTextAlignment(.center)
        .padding(.horizontal, Layout.tripleDefaultSpacing)

      if let infoButtonTitle {
        Button(infoButtonTitle) {
          showingSheet = true
        }
        .funButton()
      }

      if let navigationButtonTitle {
        Button(navigationButtonTitle) {
          Current.soundPlayer.play(.chime)
          if case .navigateToTab(let tab) = navigationAction {
            Current.selectedTab = tab
          }
          onNavigate()
        }
        .funButton()
      }

      Spacer()
    }
    .offset(y: animateContent ? contentOffset : 0)
    .opacity(animateContent ? contentOpacity : 1)
    .onAppear {
      if animateContent {
        withAnimation(OnboardingView.entranceAnimation) {
          contentOffset = 0
          contentOpacity = 1
        }
      }
    }
    .sheet(isPresented: $showingSheet) {
      if let sheetHeading, let sheetBody {
        OnboardingInfoSheet(heading: sheetHeading, bodyText: sheetBody)
      }
    }
  }
}

private struct OnboardingInfoSheet: View {
  let heading: String
  let bodyText: String

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          Spacer()
            .frame(height: Layout.tripleDefaultSpacing + Layout.doubleDefaultSpacing)

          Text(heading)
            .font(.largeTitle.bold())
            .foregroundStyle(.customYellow)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, Layout.defaultSpacing)

          RichTextView(blocks: bodyText.richTextBlocks)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
      }
    }
    .overlay(alignment: .topTrailing) {
      Button(L.Onboarding.dismiss) {
        dismiss()
      }
      .foregroundStyle(.customYellow)
      .padding(.trailing, Layout.doubleDefaultSpacing)
      .padding(.top, Layout.defaultSpacing)
    }
  }
}
