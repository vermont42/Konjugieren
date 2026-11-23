// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit

/// A started Live Activity, as a quiz or the game holds it. `LiveActivitiesReal` wraps the
/// system's `Activity`, which nothing outside ActivityKit can make, so `LiveActivitiesSpy`'s
/// handles wrap none.
struct LiveActivity<Attributes: ActivityAttributes> {
  let id: String
  let activity: Activity<Attributes>?
}

/// Starts, updates, and ends Live Activities. `LiveActivitiesReal` uses ActivityKit, and
/// `LiveActivitiesSpy` records under unit tests, which would otherwise start hundreds of real
/// activities and meet the system's limit (`targetMaximumExceeded`) partway through a run.
protocol LiveActivities {
  /// Nil when the learner has turned Live Activities off, or the system refuses one.
  func start<Attributes: ActivityAttributes>(attributes: Attributes, initialState: Attributes.ContentState) -> LiveActivity<Attributes>?
  func update<Attributes: ActivityAttributes>(_ liveActivity: LiveActivity<Attributes>, state: Attributes.ContentState)
  func end<Attributes: ActivityAttributes>(_ liveActivity: LiveActivity<Attributes>, finalState: Attributes.ContentState)
  /// Ends every quiz and game activity, which a launch does, since none survives its quiz or game.
  func endAll()
}
