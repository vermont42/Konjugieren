// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct KonjugierenApp: App {
  var body: some Scene {
    WindowGroup {
      MainTabView()
    }
  }

  init() {
    SoundPlayer.setup()
  }
}
