// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// The review card that `ReviewCardHost` chose, placed above the verb list.
struct ReviewCardHostView: View {
  let host: ReviewCardHost
  let open: (VerbDestination) -> Void
  @Environment(\.horizontalSizeClass) private var sizeClass

  private static let maxWidth: CGFloat = 560

  var body: some View {
    if let card = host.shownCard {
      ReviewCardView(
        verb: card.offer.verb,
        readingIndex: card.offer.readingIndex,
        caption: L.ReviewCard.caption(daysAgo: card.offer.daysSinceActivity, wasLookedUp: card.offer.wasLookedUp),
        isRevealed: card.isRevealed,
        reveal: host.reveal,
        open: {
          if let destination = host.destination {
            open(destination)
          }
        },
        dismiss: host.dismiss
      )
      .frame(maxWidth: sizeClass == .regular ? Self.maxWidth : .infinity)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal)
      .padding(.top, Layout.defaultSpacing)
      .transition(.opacity)
      .onAppear {
        host.signalShown()
      }
    }
  }
}
