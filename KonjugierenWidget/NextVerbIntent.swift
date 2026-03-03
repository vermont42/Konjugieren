// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents
import WidgetKit

struct NextVerbIntent: AppIntent {
  static let title: LocalizedStringResource = "Next Verb"

  func perform() async throws -> some IntentResult {
    guard let defaults = WidgetConstants.sharedDefaults else {
      return .result()
    }

    let currentOffset = defaults.integer(forKey: WidgetConstants.debugOffsetKey)
    defaults.set(currentOffset + 1, forKey: WidgetConstants.debugOffsetKey)

    // Reset quiz state for new verb
    defaults.set(false, forKey: WidgetConstants.quizAnsweredKey)
    defaults.set(false, forKey: WidgetConstants.quizCorrectKey)
    defaults.removeObject(forKey: WidgetConstants.quizQuestionIDKey)

    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}
