// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents

struct OpenRandomVerbIntent: PendingDeeplinkIntent {
  static let title = LocalizedStringResource("Intent.openRandomVerbTitle")
  static let openAppWhenRun = true
  static let pendingDeeplink = WidgetDeeplink.randomVerbFromShortcut
}
