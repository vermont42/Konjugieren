// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import Foundation

enum LiveActivityManager {
  static func start<Attributes: ActivityAttributes>(
    attributes: Attributes,
    initialState: Attributes.ContentState
  ) -> Activity<Attributes>? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return nil }

    let content = ActivityContent(state: initialState, staleDate: nil)

    do {
      return try Activity.request(attributes: attributes, content: content, pushType: nil)
    } catch {
      return nil
    }
  }

  static func update<Attributes: ActivityAttributes>(
    _ activity: Activity<Attributes>,
    state: Attributes.ContentState
  ) {
    let content = ActivityContent(state: state, staleDate: nil)
    Task { @MainActor in
      await activity.update(content)
    }
  }

  static func end<Attributes: ActivityAttributes>(
    _ activity: Activity<Attributes>,
    finalState: Attributes.ContentState
  ) {
    let content = ActivityContent(state: finalState, staleDate: nil)
    Task { @MainActor in
      await activity.end(content, dismissalPolicy: .immediate)
    }
  }

  static func endAllActivities() {
    Task { @MainActor in
      for activity in Activity<QuizActivityAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
      for activity in Activity<GameActivityAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }
}
