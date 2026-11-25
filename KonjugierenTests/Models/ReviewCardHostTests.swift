// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import SwiftUI
import Testing

@MainActor
@Suite("Review card host")
struct ReviewCardHostTests {
  private let practice = PracticeStore(getterSetter: GetterSetterFake())
  private let settings = Settings(getterSetter: GetterSetterFake())
  private let analytics = AnalyticsSpy()
  private let achievementReports = Counter()

  private final class Counter {
    var count = 0
  }

  private static let monthAgo = Date.now.addingTimeInterval(-30 * 24 * 60 * 60)

  private func host(lookingUp infinitivs: String...) throws -> ReviewCardHost {
    for (offset, infinitiv) in infinitivs.enumerated() {
      practice.recordLookup(try #require(Verb.verbs[infinitiv]), source: .search, at: Self.monthAgo.addingTimeInterval(Double(offset) * 24 * 60 * 60))
    }
    let achievementReports = self.achievementReports
    return ReviewCardHost(practice: practice, settings: settings, analytics: analytics) {
      achievementReports.count += 1
    }
  }

  @Test func theCardIsChosenOncePerOpening() throws {
    let host = try host(lookingUp: "singen", "sinken")
    host.listAppeared()
    #expect(host.shownCard?.offer.verb.infinitiv == "singen")

    host.reveal()
    host.listAppeared()
    #expect(host.shownCard?.offer.verb.infinitiv == "singen")
    #expect(host.shownCard?.isRevealed == true)
  }

  @Test func onlyAReturnFromTheBackgroundChoosesAgain() throws {
    let host = try host(lookingUp: "singen", "sinken")
    host.listAppeared()
    host.reveal()

    host.scenePhaseChanged(to: .inactive)
    host.scenePhaseChanged(to: .active)
    #expect(host.shownCard?.offer.verb.infinitiv == "singen")

    host.scenePhaseChanged(to: .background)
    host.scenePhaseChanged(to: .inactive)
    host.scenePhaseChanged(to: .active)
    #expect(host.shownCard?.offer.verb.infinitiv == "sinken")
    #expect(host.shownCard?.isRevealed == false)
  }

  @Test func revealingRecordsOneReviewAndSignalsOnce() throws {
    let host = try host(lookingUp: "singen")
    host.listAppeared()
    host.reveal()
    host.reveal()
    #expect(analytics.signalNames == [.tapRevealReviewCard])
    #expect(achievementReports.count == 1)
    #expect(practice.cardOffer() == nil)
  }

  @Test func showingSignalsOnce() throws {
    let host = try host(lookingUp: "singen")
    host.listAppeared()
    host.signalShown()
    host.signalShown()
    #expect(analytics.signalNames == [.viewReviewCard])
  }

  @Test func dismissingUnrevealedSnoozesUntilTomorrow() throws {
    let host = try host(lookingUp: "singen")
    host.listAppeared()
    host.dismiss()
    #expect(host.shownCard == nil)
    #expect(practice.cardOffer() == nil)
    #expect(practice.cardOffer(at: Date.now.addingTimeInterval(2 * 24 * 60 * 60))?.verb.infinitiv == "singen")
  }

  @Test func theCardOpensItsVerbFromTheReviewCard() throws {
    let host = try host(lookingUp: "singen")
    #expect(host.destination == nil)
    host.listAppeared()
    #expect(host.destination == VerbDestination(verb: try #require(Verb.verbs["singen"]), source: .reviewCard))
  }

  @Test func suppressionHidesTheCardItChoseAndShowsItAgain() throws {
    let host = try host(lookingUp: "singen")
    host.listAppeared()
    settings.reviewCardSuppression = .on
    host.suppressionChanged()
    #expect(host.shownCard == nil)
    #expect(host.card != nil)

    settings.reviewCardSuppression = .off
    host.suppressionChanged()
    #expect(host.shownCard?.offer.verb.infinitiv == "singen")
  }

  @Test func aSuppressedOpeningChoosesWhenSuppressionEnds() throws {
    settings.reviewCardSuppression = .on
    let host = try host(lookingUp: "singen")
    host.listAppeared()
    #expect(host.card == nil)

    settings.reviewCardSuppression = .off
    host.suppressionChanged()
    #expect(host.shownCard?.offer.verb.infinitiv == "singen")
  }
}
