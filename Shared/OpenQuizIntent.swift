// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents

struct OpenQuizIntent: PendingDeeplinkIntent {
  static let title = LocalizedStringResource("Intent.openQuizTitle")
  static let openAppWhenRun = true
  static let pendingDeeplink = WidgetDeeplink.quiz
}
