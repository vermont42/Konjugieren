// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TelemetryDeck

struct KonjugierenApp: App {
  var body: some Scene {
    WindowGroup {
      MainTabView()
        .onOpenURL(perform: Current.handleURL(_:))
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
    Current.gameCenter.authenticate()
    TelemetryDeck.initialize(config: .init(appID: ""))
  }
}
