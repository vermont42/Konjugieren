// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents
import CoreSpotlight
import SwiftUI
import TipKit
import WidgetKit

struct KonjugierenApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      MainTabView()
        .onOpenURL(perform: Current.handleURL(_:))
        .onContinueUserActivity(World.viewVerbActivityType) { userActivity in
          Current.handleUserActivity(userActivity)
        }
        .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
          if
            let rawIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String
          {
            let infinitiv = rawIdentifier.replacingOccurrences(of: "VerbEntity/", with: "")
            if let url = URL.verbDeeplink(infinitiv, source: .spotlight) {
              Current.handleURL(url)
            }
          }
        }
        .fullScreenCover(isPresented: Binding(
          get: { OnboardingDisplay.onboardingEnabled && !Current.settings.hasSeenOnboarding },
          set: { newValue in
            if !newValue {
              Current.settings.hasSeenOnboarding = true
            }
          }
        )) {
          OnboardingView()
        }
        .onChange(of: scenePhase) {
          if scenePhase == .active {
            if
              let deeplink = WidgetConstants.sharedDefaults?.string(forKey: WidgetConstants.pendingDeeplinkKey),
              let url = URL(string: deeplink)
            {
              WidgetConstants.sharedDefaults?.removeObject(forKey: WidgetConstants.pendingDeeplinkKey)
              Current.handleURL(url)
            }
            WidgetSnapshotWriter.writeSnapshot()
            WidgetCenter.shared.reloadAllTimelines()
            Current.languageModelService.refreshAvailability()
          }
          // The day may have turned, and the record changed, since the reminders were scheduled.
          if scenePhase == .active || scenePhase == .background {
            Current.rescheduleReminders()
          }
        }
        .onChange(of: Current.settings.thirdPersonPronounGender) {
          WidgetSnapshotWriter.writeSnapshot()
          WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: Current.settings.conjugationgroupLang) {
          WidgetSnapshotWriter.writeSnapshot()
          WidgetCenter.shared.reloadAllTimelines()
        }
        // The quiz widget asks the first question of the day's challenge at the learner's level.
        .onChange(of: Current.settings.quizLevel) {
          WidgetSnapshotWriter.writeSnapshot()
          WidgetCenter.shared.reloadAllTimelines()
        }
    }
    .commands {
      VerbSearchCommands()
    }
  }

  init() {
    Current.soundPlayer.setup()
    Current.utterer.setup()
    Current.gameCenter.authenticate()
    // Held by GameCenterReal until sign-in finishes, which also sends progress made signed out.
    Current.reportAchievements()
    let appID = Bundle.main.infoDictionary?["TelemetryDeckAppID"] as? String ?? ""
    Current.analytics.initialize(appID: appID)
    QuizAbandonment.reportAndClear(getterSetter: Current.getterSetter, analytics: Current.analytics)
    if TipDisplay.tipsEnabled {
      try? Tips.configure()
    }
    KonjugierenShortcuts.updateAppShortcutParameters()
    Current.liveActivities.endAll()
    Task {
      await VerbSpotlight.indexVerbs()
    }
  }
}
