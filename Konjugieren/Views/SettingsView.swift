// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct SettingsView: View {
  @State private var hasChatHistory = false
  @State private var hasQuizErrors = false
  @State private var isConfirmingReset = false
  /// Notifications are not allowed, so the reminder cannot appear.
  @State private var areRemindersDenied = false
  @State private var rateReviewDescription = ""
  @State private var showingOnboarding = false
  @State private var showingGame = false
  // The tab stays alive once visited, and a popover tip that becomes eligible while it is hidden,
  // as ChangeLevelTip does when a quiz finishes, would float over another tab pointing at nothing.
  @State private var isOnScreen = false
  private let changeLevelTip = ChangeLevelTip()
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
                heading: L.Settings.regionHeading,
                description: L.Settings.regionDescription
              ) {
                Picker(L.Settings.regionHeading, selection: $settings.region) {
                  ForEach(Region.allCases, id: \.self) { region in
                    regionSegment(for: region).tag(region)
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

              GradientDivider()

              settingSection(
                heading: L.Settings.reviewCardSuppressionHeading,
                description: L.Settings.reviewCardSuppressionDescription
              ) {
                Picker(L.Settings.reviewCardSuppressionHeading, selection: $settings.reviewCardSuppression) {
                  ForEach(ReviewCardSuppression.allCases, id: \.self) { suppression in
                    Text(suppression.localizedReviewCardSuppression).tag(suppression)
                  }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("review_card_suppression_picker")
              }
            }

            settingsCard {
              settingSection(
                heading: L.Settings.quizLevelHeading,
                description: L.Settings.quizLevelDescription,
                tip: isOnScreen ? changeLevelTip : nil
              ) {
                quizLevelPicker
              }

              GradientDivider()

              settingSection(
                heading: L.Settings.quizClockHeading,
                description: L.Settings.quizClockDescription
              ) {
                Picker(L.Settings.quizClockHeading, selection: $settings.quizClock) {
                  ForEach(QuizClock.allCases, id: \.self) { quizClock in
                    Text(quizClock.localizedQuizClock).tag(quizClock)
                  }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("quiz_clock_picker")
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

              GradientDivider()

              settingSection(
                heading: L.DailyReminder.heading,
                description: L.DailyReminder.description
              ) {
                dailyReminderControls
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
                    title: L.GameCenter.viewLeaderboards,
                    systemImage: "trophy.fill",
                    description: L.GameCenter.viewLeaderboardsDescription,
                    accessibilityHint: L.Accessibility.leaderboardsHint
                  ) {
                    Current.gameCenter.showLeaderboards()
                    Current.analytics.signal(name: .tapViewLeaderboard)
                  }

                  settingsAction(
                    title: L.GameCenter.viewAchievements,
                    systemImage: "rosette",
                    description: L.GameCenter.viewAchievementsDescription,
                    accessibilityHint: L.Accessibility.achievementsHint
                  ) {
                    Current.gameCenter.showAchievements()
                    Current.analytics.signal(name: .tapViewAchievements)
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
                  tip: isOnScreen ? playGameTip : nil
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

                if !Current.practice.isEmpty || Current.practice.lastResult != nil || !Current.practice.dailyStreak.isEmpty || hasQuizErrors {
                  settingsAction(
                    title: L.Settings.resetPractice,
                    systemImage: "arrow.counterclockwise",
                    description: L.Settings.resetPracticeDescription
                  ) {
                    isConfirmingReset = true
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

            aboutFooter
          }
          .padding(.horizontal, Layout.doubleDefaultSpacing)
          .padding(.bottom, Layout.doubleDefaultSpacing)
        }
      }
      .onAppear {
        isOnScreen = true
        Current.analytics.signal(name: .viewSettingsView)
        hasChatHistory = !TutorChatHistory.isEmpty(getterSetter: Current.getterSetter)
        hasQuizErrors = !QuizErrorHistory.load(getterSetter: Current.getterSetter).isEmpty
      }
      // Notifications can be turned off in the Settings app while the reminder is on.
      .task(id: isOnScreen) {
        guard isOnScreen, Current.settings.dailyReminder == .on else {
          return
        }
        areRemindersDenied = !(await Current.reminderScheduler.isAuthorized())
      }
      .alert(L.Settings.resetPracticeConfirmTitle, isPresented: $isConfirmingReset) {
        Button(L.Settings.resetPracticeConfirm, role: .destructive) {
          resetPractice()
        }
        Button(role: .cancel) {}
      } message: {
        Text(L.Settings.resetPracticeConfirmMessage)
      }
      .onDisappear {
        isOnScreen = false
      }
      .onChange(of: settings.quizLevel) {
        changeLevelTip.invalidate(reason: .actionPerformed)
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

  /// Forgets the practice record and the wrong answers kept for the Tutor, which are practice too
  /// (Josh, 2026-11-14). Starred and recent verbs stay.
  private func resetPractice() {
    Current.practice.reset()
    QuizErrorHistory.clear(getterSetter: Current.getterSetter)
    hasQuizErrors = false
    Current.rescheduleReminders()
    Current.analytics.signal(name: .tapResetPractice)
  }

  /// Off and On, the time while on, and a way to the Settings app while notifications are not
  /// allowed. Permission is asked for only when the learner turns the reminder on.
  @ViewBuilder
  private var dailyReminderControls: some View {
    Picker(L.DailyReminder.heading, selection: Binding(get: { Current.settings.dailyReminder }, set: { setDailyReminder($0) })) {
      ForEach(DailyReminder.allCases, id: \.self) { reminder in
        Text(reminder.localizedDailyReminder).tag(reminder)
      }
    }
    .pickerStyle(.segmented)
    .accessibilityIdentifier("daily_reminder_picker")

    if Current.settings.dailyReminder == .on {
      DatePicker(L.DailyReminder.time, selection: dailyReminderTime, displayedComponents: .hourAndMinute)
        .foregroundStyle(.customForeground)
        .accessibilityIdentifier("daily_reminder_time")
    }

    if areRemindersDenied {
      Text(L.DailyReminder.denied)
        .font(.callout)
        .foregroundStyle(.customRed)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("daily_reminder_denied")
      Button(L.DailyReminder.openSettings) {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
          UIApplication.shared.open(url)
        }
      }
      .buttonStyle(.bordered)
      .tint(.customYellow)
      .accessibilityIdentifier("daily_reminder_open_settings")
    }
  }

  /// Today at the reminder's time, which the picker shows as a time alone.
  private var dailyReminderTime: Binding<Date> {
    Binding {
      let minutes = Current.settings.dailyReminderMinutes
      return Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: .now) ?? .now
    } set: { date in
      let components = Calendar.current.dateComponents([.hour, .minute], from: date)
      Current.settings.dailyReminderMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
      Current.rescheduleReminders()
    }
  }

  /// Turning the reminder on asks for permission, and a refusal leaves it off, with a line saying
  /// why. The signal says which: `true`, `false`, or `denied`.
  private func setDailyReminder(_ reminder: DailyReminder) {
    guard reminder == .on else {
      Current.settings.dailyReminder = .off
      areRemindersDenied = false
      Current.rescheduleReminders()
      Current.analytics.signal(name: .tapDailyReminder, parameters: [ParameterKey.enabled.rawValue: "false"])
      return
    }
    Task {
      let isAllowed = await Current.reminderScheduler.requestAuthorization()
      Current.settings.dailyReminder = isAllowed ? .on : .off
      areRemindersDenied = !isAllowed
      Current.rescheduleReminders()
      Current.analytics.signal(name: .tapDailyReminder, parameters: [ParameterKey.enabled.rawValue: isAllowed ? "true" : Self.deniedValue])
    }
  }

  static let deniedValue = "denied"

  private var aboutFooter: some View {
    VStack(spacing: Layout.defaultSpacing / 2) {
      Text(verbatim: "Konjugieren")
        .font(.headline)
        .fontDesign(.serif)
        .foregroundStyle(.customYellow)
      if let version = Self.versionString {
        Text(verbatim: version)
          .font(.caption.monospacedDigit())
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, Layout.defaultSpacing)
    .accessibilityElement(children: .combine)
  }

  private static var versionString: String? {
    let info = Bundle.main.infoDictionary
    guard let short = info?["CFBundleShortVersionString"] as? String else {
      return nil
    }
    if let build = info?["CFBundleVersion"] as? String {
      return "v\(short) (\(build))"
    }
    return "v\(short)"
  }

  // A segmented picker renders a plain Text or a plain Image per segment and silently drops
  // any image attachment inside a Text, so no one segment can pair a word with a flag. The
  // flags have to be images rather than emoji because iOS 26 renders regional-indicator pairs
  // as tofu (docs/emoji_assets.md). Labelling those images with the flag emoji keeps
  // VoiceOver saying "flag of Austria", exactly as it did when the segments were emoji Text.
  @ViewBuilder
  private func regionSegment(for region: Region) -> some View {
    if let assetName = EmojiAsset.assetName(for: region.localizedRegion) {
      Image(assetName)
        .renderingMode(.original)
        .accessibilityLabel(Text(verbatim: region.localizedRegion))
    } else {
      Text(region.localizedRegion)
    }
  }

  // A segmented control truncated Intermediate and Mittelstufe on an iPhone, so the levels are
  // tiles like the app icons below, each with a gauge whose needle rises with the level.
  private var quizLevelPicker: some View {
    LazyVGrid(
      columns: Array(repeating: GridItem(.flexible(), spacing: Layout.defaultSpacing), count: QuizLevel.allCases.count),
      spacing: Layout.defaultSpacing
    ) {
      ForEach(QuizLevel.allCases, id: \.self) { quizLevel in
        let isSelected = Current.settings.quizLevel == quizLevel
        Button {
          Current.settings.quizLevel = quizLevel
        } label: {
          VStack(spacing: 4) {
            Image(systemName: quizLevel.systemImage)
              .font(.system(size: 30))
              .foregroundStyle(isSelected ? Color.customYellow : Color.secondary)
              .frame(width: 60, height: 60)
              .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                  .fill(Color.customBackground)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                  .strokeBorder(isSelected ? Color.customYellow : Color.clear, lineWidth: 3)
              )
              .accessibilityHidden(true)
            Text(quizLevel.localizedName)
              .font(.caption2)
              .foregroundStyle(.customForeground)
              .lineLimit(1)
              .minimumScaleFactor(0.8)
          }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("quiz_level_\(quizLevel.rawValue)")
      }
    }
    .sensoryFeedback(.selection, trigger: Current.settings.quizLevel)
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
    if let hint, let tip {
      accessibilityHint(hint)
        .popoverTip(tip)
    } else if let hint {
      accessibilityHint(hint)
    } else if let tip {
      popoverTip(tip)
    } else {
      self
    }
  }
}
