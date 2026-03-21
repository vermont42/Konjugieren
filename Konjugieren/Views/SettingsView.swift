// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct SettingsView: View {
  @State private var hasChatHistory = false
  @State private var rateReviewDescription = ""
  @State private var showingOnboarding = false
  @State private var showingGame = false
  private let changeDifficultyTip = ChangeDifficultyTip()
  private let playGameTip = PlayGameTip()

  private var playGameDescription: String {
    if Current.settings.gameHighScore > 0 {
      return L.Game.playGameDescription + " " + L.Game.highScoreChallenge(score: Current.settings.gameHighScore)
    }
    return L.Game.playGameDescription
  }

  var body: some View {
    @Bindable var settings = Current.settings

    NavigationStack {
      ZStack {
        Color.customBackground
          .ignoresSafeArea()

        ScrollView(.vertical) {
          VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
            settingsCard {
              settingSection(
                heading: L.Settings.conjugationgroupLangHeading,
                description: L.Settings.conjugationgroupLangDescription
              ) {
                Picker(L.Settings.conjugationgroupLangHeading, selection: $settings.conjugationgroupLang) {
                  ForEach(ConjugationgroupLang.allCases, id: \.self) { conjugationgroupLang in
                    Text(conjugationgroupLang.localizedConjugationgroupLang).tag(conjugationgroupLang)
                  }
                }
                .pickerStyle(.segmented)
              }

              gradientDivider

              settingSection(
                heading: L.Settings.thirdPersonPronounGenderHeading,
                description: L.Settings.thirdPersonPronounGenderDescription
              ) {
                Picker(L.Settings.thirdPersonPronounGenderHeading, selection: $settings.thirdPersonPronounGender) {
                  ForEach(ThirdPersonPronounGender.allCases, id: \.self) { thirdPersonPronounGender in
                    Text(thirdPersonPronounGender.localizedThirdPersonPronounGender).tag(thirdPersonPronounGender)
                  }
                }
                .pickerStyle(.segmented)
              }

              gradientDivider

              settingSection(
                heading: L.Settings.searchScopeHeading,
                description: L.Settings.searchScopeDescription
              ) {
                Picker(L.Settings.searchScopeHeading, selection: $settings.searchScope) {
                  ForEach(SearchScope.allCases, id: \.self) { searchScope in
                    Text(searchScope.localizedSearchScope).tag(searchScope)
                  }
                }
                .pickerStyle(.segmented)
              }
            }

            settingsCard {
              settingSection(
                heading: L.Settings.quizDifficultyHeading,
                description: L.Settings.quizDifficultyDescription,
                tip: changeDifficultyTip
              ) {
                Picker(L.Settings.quizDifficultyHeading, selection: $settings.quizDifficulty) {
                  ForEach(QuizDifficulty.allCases, id: \.self) { quizDifficulty in
                    Text(quizDifficulty.localizedQuizDifficulty).tag(quizDifficulty)
                  }
                }
                .pickerStyle(.segmented)
              }

              gradientDivider

              settingSection(
                heading: L.Settings.audioFeedbackHeading,
                description: L.Settings.audioFeedbackDescription
              ) {
                Picker(L.Settings.audioFeedbackHeading, selection: $settings.audioFeedback) {
                  ForEach(AudioFeedback.allCases, id: \.self) { audioFeedback in
                    Text(audioFeedback.localizedAudioFeedback).tag(audioFeedback)
                  }
                }
                .pickerStyle(.segmented)
              }
            }

            settingsCard {
              settingSection(
                heading: L.Settings.appIconHeading,
                description: L.Settings.appIconDescription
              ) {
                Picker(L.Settings.appIconHeading, selection: $settings.appIcon) {
                  ForEach(AppIcon.allCases, id: \.self) { appIcon in
                    Text(appIcon.localizedAppIcon).tag(appIcon)
                  }
                }
                .pickerStyle(.segmented)
              }
            }

            settingsCard {
              VStack(spacing: Layout.doubleDefaultSpacing) {
                if Current.gameCenter.isAuthenticated {
                  Button(L.GameCenter.viewLeaderboard) {
                    Current.gameCenter.showLeaderboard()
                    Current.analytics.signal(name: .tapViewLeaderboard)
                  }
                  .funButton()
                  .frame(maxWidth: .infinity)
                  .accessibilityHint(L.Accessibility.leaderboardHint)

                  Text(L.GameCenter.viewLeaderboardDescription)
                    .font(.callout)
                    .foregroundStyle(.customForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(L.Onboarding.showOnboarding) {
                  showingOnboarding = true
                  Current.analytics.signal(name: .tapShowOnboarding)
                }
                .funButton()
                .frame(maxWidth: .infinity)
                .accessibilityHint(L.Accessibility.showOnboardingHint)

                Text(L.Onboarding.showOnboardingDescription)
                  .font(.callout)
                  .foregroundStyle(.customForeground)
                  .frame(maxWidth: .infinity, alignment: .leading)

                Button(L.Game.playGame) {
                  showingGame = true
                  playGameTip.invalidate(reason: .actionPerformed)
                  Current.analytics.signal(name: .tapPlayGame)
                }
                .funButton()
                .frame(maxWidth: .infinity)
                .popoverTip(playGameTip)

                Text(playGameDescription)
                  .font(.callout)
                  .foregroundStyle(.customForeground)
                  .frame(maxWidth: .infinity, alignment: .leading)

                if Current.languageModelService.isAvailable, hasChatHistory {
                  Button(L.Tutor.deleteChatHistory) {
                    TutorChatHistory.clear(getterSetter: Current.getterSetter)
                    hasChatHistory = false
                    Current.analytics.signal(name: .tapDeleteChatHistory)
                  }
                  .funButton()
                  .frame(maxWidth: .infinity)

                  Text(L.Tutor.deleteChatHistoryDescription)
                    .font(.callout)
                    .foregroundStyle(.customForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(L.Settings.rateOrReview) {
                  UIApplication.shared.open(RatingsFetcher.reviewURL)
                  Current.analytics.signal(name: .tapRateOrReview)
                }
                .funButton()
                .frame(maxWidth: .infinity)

                if !rateReviewDescription.isEmpty {
                  Text(rateReviewDescription)
                    .font(.callout)
                    .foregroundStyle(.customForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
              }
            }
          }
          .padding(.horizontal, Layout.doubleDefaultSpacing)
          .padding(.bottom, Layout.doubleDefaultSpacing)
        }
      }
      .onAppear {
        Current.analytics.signal(name: .viewSettingsView)
        hasChatHistory = !TutorChatHistory.isEmpty(getterSetter: Current.getterSetter)
      }
      .onChange(of: settings.quizDifficulty) {
        changeDifficultyTip.invalidate(reason: .actionPerformed)
      }
      .task {
        if let description = await RatingsFetcher.fetchRatingsDescription(session: Current.session) {
          rateReviewDescription = description
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

  private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
      content()
    }
    .padding(Layout.doubleDefaultSpacing)
    .background(Color(.secondarySystemBackground).opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private func settingSection<Picker: View>(
    heading: String,
    description: String,
    tip: (any Tip)? = nil,
    @ViewBuilder picker: () -> Picker
  ) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      if let tip {
        Text(heading)
          .font(.title3.bold())
          .foregroundStyle(.customYellow)
          .accessibilityAddTraits(.isHeader)
          .popoverTip(tip)
      } else {
        Text(heading)
          .font(.title3.bold())
          .foregroundStyle(.customYellow)
          .accessibilityAddTraits(.isHeader)
      }

      picker()

      Text(description)
        .font(.callout)
        .foregroundStyle(.customForeground)
    }
  }

  private var gradientDivider: some View {
    Rectangle()
      .fill(
        LinearGradient(
          colors: [.clear, .customYellow.opacity(0.3), .clear],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .frame(height: 1)
  }
}
