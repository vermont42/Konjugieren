// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import Foundation

final class LiveActivitiesSpy: LiveActivities {
  /// The activities started and not yet ended, by ID.
  private(set) var activeIDs: Set<String> = []
  private(set) var startCount = 0
  private(set) var updateCount = 0
  private(set) var endCount = 0
  private(set) var endAllCount = 0

  func start<Attributes: ActivityAttributes>(attributes: Attributes, initialState: Attributes.ContentState) -> LiveActivity<Attributes>? {
    startCount += 1
    let id = UUID().uuidString
    activeIDs.insert(id)
    return LiveActivity(id: id, activity: nil)
  }

  func update<Attributes: ActivityAttributes>(_ liveActivity: LiveActivity<Attributes>, state: Attributes.ContentState) {
    updateCount += 1
  }

  func end<Attributes: ActivityAttributes>(_ liveActivity: LiveActivity<Attributes>, finalState: Attributes.ContentState) {
    endCount += 1
    activeIDs.remove(liveActivity.id)
  }

  func endAll() {
    endAllCount += 1
    activeIDs.removeAll()
  }
}
