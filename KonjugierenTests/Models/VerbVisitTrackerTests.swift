// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import SwiftUI
import Testing

@MainActor
@Suite("Verb visit tracker")
struct VerbVisitTrackerTests {
  private let learnerVerbs = LearnerVerbStore(getterSetter: GetterSetterFake())
  private let practice = PracticeStore(getterSetter: GetterSetterFake())
  private let analytics = AnalyticsSpy()
  private let clock = Clock()

  private final class Clock {
    var now = Date(timeIntervalSinceReferenceDate: 0)

    func advance(_ seconds: TimeInterval) {
      now = now.addingTimeInterval(seconds)
    }
  }

  private func tracker(source: AnalyticsSource = .search) throws -> VerbVisitTracker {
    let clock = self.clock
    return VerbVisitTracker(
      verb: try #require(Verb.verbs["singen"]),
      source: source,
      learnerVerbs: learnerVerbs,
      practice: practice,
      analytics: analytics
    ) {
      clock.now
    }
  }

  private var sources: [String?] {
    zip(analytics.signalNames, analytics.signalParameters).map { name, parameters in
      name == .viewVerbView ? parameters["source"] : nil
    }
  }

  private var openCount: Int? {
    learnerVerbs.record.entries["singen"]?.openCount
  }

  @Test func theFirstVisitCarriesItsSourceAndRecordsTheOpen() throws {
    let tracker = try tracker(source: .widget)
    tracker.pageAppeared()

    #expect(analytics.signalNames == [.viewVerbView])
    #expect(sources == ["widget"])
    #expect(openCount == 1)
    #expect(!practice.isEmpty)
  }

  @Test func aSheetEndsTheVisitAndItsCloseResumesIt() throws {
    let tracker = try tracker()
    tracker.pageAppeared()
    clock.advance(3)
    tracker.coverChanged(isCovered: true)
    clock.advance(120)
    tracker.coverChanged(isCovered: false)

    #expect(analytics.signalNames == [.viewVerbView, .leaveVerbView, .viewVerbView])
    #expect(sources == ["search", nil, "resume"])
    #expect(analytics.signalParameters.dropFirst().first?["dwell"] == "0-5s")
    #expect(openCount == 1)
  }

  @Test func onlyTheBackgroundEndsAVisit() throws {
    let tracker = try tracker()
    tracker.pageAppeared()
    tracker.scenePhaseChanged(to: .inactive)
    tracker.scenePhaseChanged(to: .active)
    #expect(analytics.signalNames == [.viewVerbView])

    tracker.scenePhaseChanged(to: .background)
    tracker.scenePhaseChanged(to: .inactive)
    #expect(analytics.signalNames == [.viewVerbView, .leaveVerbView])

    tracker.scenePhaseChanged(to: .active)
    #expect(sources == ["search", nil, "resume"])
  }

  @Test func aReturnToTheForegroundUnderASheetWaitsForTheSheet() throws {
    let tracker = try tracker()
    tracker.pageAppeared()
    tracker.coverChanged(isCovered: true)
    tracker.scenePhaseChanged(to: .background)
    tracker.scenePhaseChanged(to: .active)
    #expect(analytics.signalNames == [.viewVerbView, .leaveVerbView])

    tracker.coverChanged(isCovered: false)
    #expect(sources == ["search", nil, "resume"])
  }

  @Test func aReturnToTheForegroundOffScreenBeginsNothing() throws {
    let tracker = try tracker()
    tracker.pageAppeared()
    tracker.pageDisappeared()
    tracker.scenePhaseChanged(to: .background)
    tracker.scenePhaseChanged(to: .active)

    #expect(analytics.signalNames == [.viewVerbView, .leaveVerbView])
  }

  @Test func aPageThatAppearsAgainResumesFromWhatIsOnScreen() throws {
    let tracker = try tracker()
    tracker.pageAppeared()
    tracker.sectionVisibilityChanged(.simple, isVisible: true)
    tracker.sectionVisibilityChanged(.related, isVisible: true)
    tracker.sectionVisibilityChanged(.simple, isVisible: false)
    tracker.pageDisappeared()
    tracker.pageAppeared()

    #expect(sources == ["search", nil, "resume"])
    #expect(analytics.signalParameters.dropFirst().first?["deepestSection"] == "related")
    #expect(tracker.visit?.deepestSection == .related)
    #expect(openCount == 1)
  }

  @Test func everyViewIsFollowedByExactlyOneLeave() throws {
    let tracker = try tracker()
    tracker.pageAppeared()
    tracker.pageAppeared()
    tracker.coverChanged(isCovered: true)
    tracker.coverChanged(isCovered: true)
    tracker.scenePhaseChanged(to: .background)
    tracker.pageDisappeared()
    tracker.coverChanged(isCovered: false)
    tracker.scenePhaseChanged(to: .active)
    tracker.pageAppeared()
    tracker.coverChanged(isCovered: true)
    tracker.coverChanged(isCovered: false)
    tracker.pageDisappeared()
    tracker.pageDisappeared()

    let names = analytics.signalNames
    #expect(names.count == 6)
    #expect(names.enumerated().allSatisfy { index, name in
      name == (index.isMultiple(of: 2) ? .viewVerbView : .leaveVerbView)
    })
  }
}
