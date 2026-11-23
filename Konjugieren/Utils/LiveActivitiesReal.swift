// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import Foundation

final class LiveActivitiesReal: LiveActivities {
  func start<Attributes: ActivityAttributes>(attributes: Attributes, initialState: Attributes.ContentState) -> LiveActivity<Attributes>? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      return nil
    }

    let content = ActivityContent(state: initialState, staleDate: nil)

    do {
      let activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
      return LiveActivity(id: activity.id, activity: activity)
    } catch {
      return nil
    }
  }

  func update<Attributes: ActivityAttributes>(_ liveActivity: LiveActivity<Attributes>, state: Attributes.ContentState) {
    guard let activity = liveActivity.activity else {
      return
    }
    let content = ActivityContent(state: state, staleDate: nil)
    Task { @MainActor in
      await activity.update(content)
    }
  }

  func end<Attributes: ActivityAttributes>(_ liveActivity: LiveActivity<Attributes>, finalState: Attributes.ContentState) {
    guard let activity = liveActivity.activity else {
      return
    }
    let content = ActivityContent(state: finalState, staleDate: nil)
    Task { @MainActor in
      await activity.end(content, dismissalPolicy: .immediate)
    }
  }

  // The lists are read now, not in the Task, which runs only after the caller returns. A cold
  // launch by a deeplink can start a quiz before then, and the Task would end its activity.
  func endAll() {
    let quizActivities = Activity<QuizActivityAttributes>.activities
    let gameActivities = Activity<GameActivityAttributes>.activities
    Task { @MainActor in
      for activity in quizActivities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
      for activity in gameActivities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }
}
