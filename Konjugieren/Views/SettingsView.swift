// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct SettingsView: View {
  @State private var showingOnboarding = false
  @State private var showingGame = false

  var body: some View {
    @Bindable var settings = Current.settings

    NavigationStack {
      ZStack {
        Color.customBackground
          .ignoresSafeArea()

        VStack(alignment: .leading) {
          ScrollView(.vertical) {
            Text(L.Settings.conjugationgroupLangHeading)
              .subheadingLabel()

            Picker(L.Settings.conjugationgroupLangHeading, selection: $settings.conjugationgroupLang) {
              ForEach(ConjugationgroupLang.allCases, id: \.self) { conjugationgroupLang in
                Text(conjugationgroupLang.localizedConjugationgroupLang).tag(conjugationgroupLang)
              }
            }
            .segmentedPicker()

            Text(L.Settings.conjugationgroupLangDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            Text(L.Settings.thirdPersonPronounGenderHeading)
              .subheadingLabel()

            Picker(L.Settings.thirdPersonPronounGenderHeading, selection: $settings.thirdPersonPronounGender) {
              ForEach(ThirdPersonPronounGender.allCases, id: \.self) { thirdPersonPronounGender in
                Text(thirdPersonPronounGender.localizedThirdPersonPronounGender).tag(thirdPersonPronounGender)
              }
            }
            .segmentedPicker()

            Text(L.Settings.thirdPersonPronounGenderDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            Text(L.Settings.quizDifficultyHeading)
              .subheadingLabel()

            Picker(L.Settings.quizDifficultyHeading, selection: $settings.quizDifficulty) {
              ForEach(QuizDifficulty.allCases, id: \.self) { quizDifficulty in
                Text(quizDifficulty.localizedQuizDifficulty).tag(quizDifficulty)
              }
            }
            .segmentedPicker()

            Text(L.Settings.quizDifficultyDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            Text(L.Settings.audioFeedbackHeading)
              .subheadingLabel()

            Picker(L.Settings.audioFeedbackHeading, selection: $settings.audioFeedback) {
              ForEach(AudioFeedback.allCases, id: \.self) { audioFeedback in
                Text(audioFeedback.localizedAudioFeedback).tag(audioFeedback)
              }
            }
            .segmentedPicker()

            Text(L.Settings.audioFeedbackDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            Text(L.Settings.searchScopeHeading)
              .subheadingLabel()

            Picker(L.Settings.searchScopeHeading, selection: $settings.searchScope) {
              ForEach(SearchScope.allCases, id: \.self) { searchScope in
                Text(searchScope.localizedSearchScope).tag(searchScope)
              }
            }
            .segmentedPicker()

            Text(L.Settings.searchScopeDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            Text(L.Settings.appIconHeading)
              .subheadingLabel()

            Picker(L.Settings.appIconHeading, selection: $settings.appIcon) {
              ForEach(AppIcon.allCases, id: \.self) { appIcon in
                Text(appIcon.localizedAppIcon).tag(appIcon)
              }
            }
            .segmentedPicker()

            Text(L.Settings.appIconDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            GeometryReader { geometry in
              let dotDiameter: CGFloat = 6
              let dotSpacing: CGFloat = 4
              let availableWidth = geometry.size.width - 2 * Layout.doubleDefaultSpacing
              let dotCount = Int(availableWidth / (dotDiameter + dotSpacing))
              HStack(spacing: dotSpacing) {
                ForEach(0..<dotCount, id: \.self) { index in
                  Circle()
                    .fill(index.isMultiple(of: 2) ? Color.customRed : Color.customYellow)
                    .frame(width: dotDiameter, height: dotDiameter)
                }
              }
              .frame(maxWidth: .infinity)
              .padding(.horizontal, Layout.doubleDefaultSpacing)
            }
            .frame(height: 6)

            Spacer(minLength: Layout.tripleDefaultSpacing)

            if Current.gameCenter.isAuthenticated {
              Button(L.GameCenter.viewLeaderboard) {
                Current.gameCenter.showLeaderboard()
                Current.analytics.signal(name: .tapViewLeaderboard)
              }
              .funButton()
              .frame(maxWidth: .infinity)
              .accessibilityHint(L.Accessibility.leaderboardHint)

              Text(L.GameCenter.viewLeaderboardDescription)
                .settingsLabel()

              Spacer(minLength: Layout.tripleDefaultSpacing)
            }

            Button(L.Onboarding.showOnboarding) {
              showingOnboarding = true
              Current.analytics.signal(name: .tapShowOnboarding)
            }
            .funButton()
            .frame(maxWidth: .infinity)
            .accessibilityHint(L.Accessibility.showOnboardingHint)

            Text(L.Onboarding.showOnboardingDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            Button(L.Game.playGame) {
              showingGame = true
              Current.analytics.signal(name: .tapPlayGame)
            }
            .funButton()
            .frame(maxWidth: .infinity)

            Text(L.Game.playGameDescription)
              .settingsLabel()
              .padding(.bottom, Layout.doubleDefaultSpacing)
          }
        }
        .onAppear {
          Current.analytics.signal(name: .viewSettingsView)
        }
      }
      .navigationTitle(L.Navigation.settings)
      .fullScreenCover(isPresented: $showingOnboarding) {
        OnboardingView(isReshow: true)
      }
      .fullScreenCover(isPresented: $showingGame) {
        GameView()
      }
    }
  }
}
