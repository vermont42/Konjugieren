// Copyright © 2026 Josh Adams. All rights reserved.

import StoreKit
import UIKit

class ReviewPrompterReal: ReviewPrompter {
  private let settings: Settings
  private let now: () -> Date
  private let requestReview: () -> Void

  private static let promptInterval = 10
  private static let daysBetweenPrompts = 180

  init(
    settings: Settings,
    now: @escaping () -> Date = { Date() },
    requestReview: @escaping () -> Void = {
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        AppStore.requestReview(in: windowScene)
      }
    }
  ) {
    self.settings = settings
    self.now = now
    self.requestReview = requestReview
  }

  func promptableActionHappened() {
    settings.promptActionCount += 1

    guard settings.promptActionCount % Self.promptInterval == 0 else { return }

    let currentDate = now()
    if let lastDate = settings.lastReviewPromptDate {
      let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastDate, to: currentDate).day ?? 0
      guard daysSinceLastPrompt >= Self.daysBetweenPrompts else { return }
    }

    settings.lastReviewPromptDate = currentDate
    requestReview()
  }
}
