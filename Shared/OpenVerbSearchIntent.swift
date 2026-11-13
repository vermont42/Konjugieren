// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents

/// The Find a Verb control's action: the verb list, with the search field focused for typing.
/// Hidden from Shortcuts, which offers Look Up a Verb instead.
struct OpenVerbSearchIntent: AppIntent {
  static let title = LocalizedStringResource("Intent.openVerbSearchTitle")
  static let openAppWhenRun = true
  static let isDiscoverable = false
  static let pendingDeeplink = "konjugieren://search?source=control"

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set(Self.pendingDeeplink, forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
