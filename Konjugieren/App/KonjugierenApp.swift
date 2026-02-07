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
    TelemetryDeck.initialize(config: .init(appID: "9B191B75-5933-427A-8114-B2E3C3E81E7E"))
  }
}
