// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// The review card above the verb list: which offer it shows, and what choosing, showing,
/// revealing, and dismissing it record. The verb list owns one for its lifetime, because the
/// card's place in the list comes and goes with search and My Verbs, and the choice must not.
@Observable
final class ReviewCardHost {
  struct Card {
    let offer: PracticeStore.CardOffer
    var isRevealed = false
    var wasSignaled = false
  }

  /// The card chosen, which suppression hides without forgetting.
  private(set) var card: Card?
  @ObservationIgnored private var wasChosen = false
  @ObservationIgnored private var appWasInBackground = false
  @ObservationIgnored private let practice: PracticeStore
  @ObservationIgnored private let settings: Settings
  @ObservationIgnored private let analytics: Analytics
  @ObservationIgnored private let reportAchievements: () -> Void

  init(
    practice: PracticeStore = Current.practice,
    settings: Settings = Current.settings,
    analytics: Analytics = Current.analytics,
    reportAchievements: @escaping () -> Void = { Current.reportAchievements() }
  ) {
    self.practice = practice
    self.settings = settings
    self.analytics = analytics
    self.reportAchievements = reportAchievements
  }

  /// The card to draw, if any.
  var shownCard: Card? {
    settings.reviewCardSuppression == .off ? card : nil
  }

  var destination: VerbDestination? {
    card.map { VerbDestination(verb: $0.offer.verb, source: .reviewCard) }
  }

  /// The choice is made once per opening, so a list that appears again keeps its card.
  func listAppeared() {
    if !wasChosen {
      choose()
    }
  }

  /// A return from the background is a new opening.
  func scenePhaseChanged(to scenePhase: ScenePhase) {
    switch scenePhase {
    case .background:
      appWasInBackground = true
    case .active where appWasInBackground:
      appWasInBackground = false
      choose()
    default:
      break
    }
  }

  /// Turning suppression off shows the card chosen before it was turned on, or else a new one.
  func suppressionChanged() {
    if settings.reviewCardSuppression == .off, card == nil {
      choose()
    }
  }

  func signalShown() {
    guard card?.wasSignaled == false else {
      return
    }
    card?.wasSignaled = true
    analytics.signal(name: .viewReviewCard)
  }

  func reveal() {
    guard let card, !card.isRevealed else {
      return
    }
    practice.recordReview(card.offer)
    reportAchievements()
    analytics.signal(name: .tapRevealReviewCard)
    withAnimation {
      self.card?.isRevealed = true
    }
  }

  /// A card dismissed before its conjugations were seen was no review, so its verb's due key
  /// conjugations return tomorrow in the same box.
  func dismiss() {
    guard let card else {
      return
    }
    if !card.isRevealed {
      practice.snooze(card.offer)
    }
    withAnimation {
      self.card = nil
    }
  }

  /// Offers the strong or mixed verb whose key conjugation is longest overdue in the practice
  /// record, if any.
  private func choose() {
    wasChosen = true
    guard settings.reviewCardSuppression == .off else {
      card = nil
      return
    }
    card = practice.cardOffer().map { Card(offer: $0) }
  }
}
