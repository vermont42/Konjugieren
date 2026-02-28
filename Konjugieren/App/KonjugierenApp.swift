// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  static var orientationLock: UIInterfaceOrientationMask = .allButUpsideDown

  func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    Self.orientationLock
  }
}

struct KonjugierenApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene {
    WindowGroup {
      MainTabView()
        .onOpenURL(perform: Current.handleURL(_:))
        .onContinueUserActivity(World.viewVerbActivityType) { userActivity in
          Current.handleUserActivity(userActivity)
        }
        .fullScreenCover(isPresented: Binding(
          get: { !Current.settings.hasSeenOnboarding },
          set: { newValue in
            if !newValue {
              Current.settings.hasSeenOnboarding = true
            }
          }
        )) {
          OnboardingView()
        }
    }
  }

  init() {
    Current.soundPlayer.setup()
    Current.utterer.setup()
    Current.gameCenter.authenticate()
    let appID = Bundle.main.infoDictionary?["TelemetryDeckAppID"] as? String ?? ""
    Current.analytics.initialize(appID: appID)
    try? Tips.configure()
  }
}
