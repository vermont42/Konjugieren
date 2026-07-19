// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents
import CoreSpotlight
import SwiftUI
import TipKit
import WidgetKit

struct KonjugierenApp: App {
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
            if let url = URL(string: "konjugieren://verb/\(infinitiv)") {
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
        }
        .onChange(of: Current.settings.thirdPersonPronounGender) {
          WidgetSnapshotWriter.writeSnapshot()
          WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: Current.settings.conjugationgroupLang) {
          WidgetSnapshotWriter.writeSnapshot()
          WidgetCenter.shared.reloadAllTimelines()
        }
    }
  }

  init() {
    Current.soundPlayer.setup()
    Current.utterer.setup()
    Current.gameCenter.authenticate()
    let appID = Bundle.main.infoDictionary?["TelemetryDeckAppID"] as? String ?? ""
    Current.analytics.initialize(appID: appID)
    if TipDisplay.tipsEnabled {
      try? Tips.configure()
    }
    KonjugierenShortcuts.updateAppShortcutParameters()
    LiveActivityManager.endAllActivities()
    Task {
      let entities = await VerbEntityQuery().allEntities()
      try? await CSSearchableIndex.default().indexAppEntities(entities)
    }
  }
}
