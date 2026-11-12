// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents

/// The Random Verb control's action. It differs from `OpenRandomVerbIntent` only in the source
/// its deeplink names: the control and the Random Verb shortcut would otherwise run one intent,
/// and an intent cannot tell which of them ran it. Hidden from Shortcuts, which already offers
/// `OpenRandomVerbIntent`.
struct OpenRandomVerbControlIntent: AppIntent {
  static let title = LocalizedStringResource("Intent.openRandomVerbTitle")
  static let openAppWhenRun = true
  static let isDiscoverable = false
  static let pendingDeeplink = "konjugieren://verb/random?source=control"

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set(Self.pendingDeeplink, forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
