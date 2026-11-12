// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents

struct OpenRandomVerbIntent: AppIntent {
  static let title = LocalizedStringResource("Intent.openRandomVerbTitle")
  static let openAppWhenRun = true
  static let pendingDeeplink = "konjugieren://verb/random?source=shortcut"

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set(Self.pendingDeeplink, forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
