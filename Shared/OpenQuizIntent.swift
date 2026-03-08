// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents

struct OpenQuizIntent: AppIntent {
  static let title: LocalizedStringResource = "Open Quiz"
  static let openAppWhenRun = true

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      WidgetConstants.sharedDefaults?.set("konjugieren://quiz/start", forKey: WidgetConstants.pendingDeeplinkKey)
    }
    return .result()
  }
}
