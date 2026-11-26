// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents

/// An intent that opens the app on a link. A control's intent cannot open a URL itself (see
/// docs/control_center_controls.md), so it leaves the link in the shared defaults, and the app
/// follows it when it becomes active.
nonisolated protocol PendingDeeplinkIntent: AppIntent {
  static var pendingDeeplink: WidgetDeeplink { get }
}

extension PendingDeeplinkIntent {
  func perform() async throws -> some IntentResult {
    let deeplink = Self.pendingDeeplink.url?.absoluteString
    // perform() is nonisolated, and WidgetConstants is main-actor-isolated in the app.
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set(deeplink, forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
