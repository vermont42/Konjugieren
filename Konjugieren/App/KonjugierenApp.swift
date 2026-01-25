// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct KonjugierenApp: App {
  var body: some Scene {
    WindowGroup {
      MainTabView()
        .onOpenURL(perform: Current.handleURL(_:))
    }
  }

  init() {
    SoundPlayer.setup()
    Current.gameCenter.authenticate()
  }
}
