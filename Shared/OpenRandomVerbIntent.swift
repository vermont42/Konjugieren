// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents

struct OpenRandomVerbIntent: AppIntent {
  static let title: LocalizedStringResource = "Open Random Verb"
  static let openAppWhenRun = true

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set("konjugieren://verb/random", forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
