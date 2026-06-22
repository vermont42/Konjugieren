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

              GradientDivider()

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

              GradientDivider()

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

              GradientDivider()

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
                LazyVGrid(
                  columns: Array(
                    repeating: GridItem(.flexible(), spacing: Layout.defaultSpacing),
                    count: 4
                  ),
                  spacing: Layout.defaultSpacing
                ) {
                  ForEach(AppIcon.allCases, id: \.self) { appIcon in
                    Button {
                      settings.appIcon = appIcon
                    } label: {
                      VStack(spacing: 4) {
                        Image(appIcon.previewAssetName)
                          .resizable()
                          .aspectRatio(1, contentMode: .fit)
                          .frame(width: 60, height: 60)
                          .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                          .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                              .strokeBorder(
                                settings.appIcon == appIcon ? Color.customYellow : Color.clear,
                                lineWidth: 3
                              )
                          )
                          .accessibilityHidden(true)
                        Text(appIcon.localizedAppIcon)
                          .font(.caption2)
                          .foregroundStyle(.customForeground)
                      }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(settings.appIcon == appIcon ? .isSelected : [])
                  }
                }
                .sensoryFeedback(.selection, trigger: settings.appIcon)
              }
            }

            settingsCard {
              VStack(spacing: Layout.doubleDefaultSpacing) {
                if Current.gameCenter.isAuthenticated {
                  settingsAction(
                    title: L.GameCenter.viewLeaderboard,
                    systemImage: "trophy.fill",
                    description: L.GameCenter.viewLeaderboardDescription,
                    accessibilityHint: L.Accessibility.leaderboardHint
                  ) {
                    Current.gameCenter.showLeaderboard()
                    Current.analytics.signal(name: .tapViewLeaderboard)
                  }
                }

                settingsAction(
                  title: L.Onboarding.showOnboarding,
                  systemImage: "questionmark.circle.fill",
                  description: L.Onboarding.showOnboardingDescription,
                  accessibilityHint: L.Accessibility.showOnboardingHint
                ) {
                  showingOnboarding = true
                  Current.analytics.signal(name: .tapShowOnboarding)
                }

                settingsAction(
                  title: L.Game.playGame,
                  systemImage: "gamecontroller.fill",
                  description: playGameDescription,
                  tip: playGameTip
                ) {
                  showingGame = true
                  playGameTip.invalidate(reason: .actionPerformed)
                  Current.analytics.signal(name: .tapPlayGame)
                }

                if Current.languageModelService.isAvailable, hasChatHistory {
                  settingsAction(
                    title: L.Tutor.deleteChatHistory,
                    systemImage: "trash",
                    description: L.Tutor.deleteChatHistoryDescription
                  ) {
                    TutorChatHistory.clear(getterSetter: Current.getterSetter)
                    hasChatHistory = false
                    Current.analytics.signal(name: .tapDeleteChatHistory)
                  }
                }

                settingsAction(
                  title: L.Settings.rateOrReview,
                  systemImage: "star.fill",
                  description: rateReviewDescription
                ) {
                  UIApplication.shared.open(RatingsFetcher.reviewURL)
                  Current.analytics.signal(name: .tapRateOrReview)
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
    .konjCard()
  }

  private func settingSection<Picker: View>(
    heading: String,
    description: String,
    tip: (any Tip)? = nil,
    @ViewBuilder picker: () -> Picker
  ) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      let styledHeading = Text(heading)
        .font(.title3.bold())
        .foregroundStyle(.customYellow)
        .accessibilityAddTraits(.isHeader)
      if let tip {
        styledHeading.popoverTip(tip)
      } else {
        styledHeading
      }

      picker()

      Text(description)
        .font(.callout)
        .foregroundStyle(.customForeground)
    }
  }

  @ViewBuilder
  private func settingsAction(
    title: String,
    systemImage: String,
    description: String,
    accessibilityHint: String? = nil,
    tip: (any Tip)? = nil,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Label(title, systemImage: systemImage)
    }
    .funButton()
    .frame(maxWidth: .infinity)
    .settingsActionDecoration(hint: accessibilityHint, tip: tip)

    if !description.isEmpty {
      Text(description)
        .font(.callout)
        .foregroundStyle(.customForeground)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

private extension View {
  @ViewBuilder
  func settingsActionDecoration(hint: String?, tip: (any Tip)?) -> some View {
    if let hint {
      accessibilityHint(hint)
    } else if let tip {
      popoverTip(tip)
    } else {
      self
    }
  }
}
