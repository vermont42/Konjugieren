// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// When a verb page's visits begin and end, and what each beginning records. A visit lasts while
/// the page is on screen, the app is in the foreground, and no sheet covers the page, so that
/// `leaveVerbView`'s dwell counts neither another app nor an article or a Test Me quiz as reading
/// (Josh, 2026-11-26). The page's first visit carries the way the learner reached it and records
/// the open; every later one is a `resume`.
final class VerbVisitTracker {
  private(set) var visit: VerbVisit?
  private var hasVisited = false
  private var isOnScreen = false
  private var isInBackground = false
  private var isCovered = false
  private var visibleSections: Set<VerbPageSection> = []
  private let verb: Verb
  private let source: AnalyticsSource
  private let learnerVerbs: LearnerVerbStore
  private let practice: PracticeStore
  private let analytics: Analytics
  private let now: () -> Date

  init(
    verb: Verb,
    source: AnalyticsSource,
    learnerVerbs: LearnerVerbStore = Current.learnerVerbs,
    practice: PracticeStore = Current.practice,
    analytics: Analytics = Current.analytics,
    now: @escaping () -> Date = { .now }
  ) {
    self.verb = verb
    self.source = source
    self.learnerVerbs = learnerVerbs
    self.practice = practice
    self.analytics = analytics
    self.now = now
  }

  func pageAppeared() {
    isOnScreen = true
    update()
  }

  func pageDisappeared() {
    isOnScreen = false
    update()
  }

  /// Only the background ends a visit. An inactive scene, under Control Center or the app
  /// switcher, is still the page on screen.
  func scenePhaseChanged(to scenePhase: ScenePhase) {
    switch scenePhase {
    case .background:
      isInBackground = true
    case .active:
      isInBackground = false
    default:
      return
    }
    update()
  }

  func coverChanged(isCovered: Bool) {
    self.isCovered = isCovered
    update()
  }

  /// A section on screen when a visit begins counts as reached by it.
  func sectionVisibilityChanged(_ section: VerbPageSection, isVisible: Bool) {
    if isVisible {
      visibleSections.insert(section)
      visit?.reach(section)
    } else {
      visibleSections.remove(section)
    }
  }

  private func update() {
    if isOnScreen, !isInBackground, !isCovered {
      begin()
    } else {
      end()
    }
  }

  private func begin() {
    guard visit == nil else {
      return
    }
    let source = hasVisited ? AnalyticsSource.resume : self.source
    let newVisit = VerbVisit(source: source, start: now(), visibleSections: visibleSections)
    visit = newVisit
    hasVisited = true
    if source != .resume {
      learnerVerbs.recordOpen(verb)
      practice.recordLookup(verb, source: source)
    }
    analytics.signal(name: .viewVerbView, parameters: newVisit.viewParameters)
  }

  private func end() {
    guard let visit else {
      return
    }
    analytics.signal(name: .leaveVerbView, parameters: visit.leaveParameters(end: now()))
    self.visit = nil
  }
}
