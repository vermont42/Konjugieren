// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// A verb looked up some days ago, offered above the verb list with its key conjugations hidden.
/// A tap anywhere on the card reveals them; after that, a tap opens the verb's page. The ✕
/// dismisses the card. Which verb, and what each tap does to its schedule, is the caller's.
struct ReviewCardView: View {
  let verb: Verb
  let daysSinceLookup: Int?
  let isRevealed: Bool
  let reveal: () -> Void
  let open: () -> Void
  let dismiss: () -> Void

  private var conjugations: [String] {
    verb.keyConjugations()
  }

  private func tap() {
    if isRevealed {
      open()
    } else {
      reveal()
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(L.ReviewCard.lookedUp(daysAgo: daysSinceLookup))
        .font(.caption.smallCaps())
        .foregroundStyle(.secondary)
        .englishPronunciation()
        .padding(.trailing, 44)

      Text(verbatim: verb.infinitiv.inUserRegion)
        .tableText()
        .germanPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { tap() }

      Text(verbatim: verb.translation)
        .tableSubtext()
        .englishPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { tap() }

      if isRevealed {
        revealedConjugations
      } else {
        hiddenConjugations
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .overlay(alignment: .topTrailing) {
      // The button's 44-point frame reaches into the card's padding rather than pushing the
      // infinitive down.
      Button(action: dismiss) {
        Image(systemName: "xmark")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.secondary)
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .offset(x: 14, y: -14)
      .accessibilityLabel(Text(L.ReviewCard.dismiss))
      .accessibilityIdentifier("review_card_dismiss")
    }
    .konjCardWithAccentBar()
    .contentShape(Rectangle())
    .onTapGesture { tap() }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("review_card")
  }

  private var hiddenConjugations: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(verbatim: conjugations.map { $0.lowercased() }.joined(separator: " · "))
        .font(.body)
        .redacted(reason: .placeholder)
        .accessibilityHidden(true)

      Text(L.ReviewCard.prompt)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .englishPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { tap() }
        .accessibilityIdentifier("review_card_reveal")
    }
    .padding(.top, Layout.defaultSpacing)
  }

  private var revealedConjugations: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(mixedCaseString: conjugations.joined(separator: " · "))
        .font(.body)
        .germanPronunciation()
        .accessibilityLabel(Text(verbatim: conjugations.map(MixedCaseAccessibility.accessibilityLabel(for:)).joined(separator: "; ")))
        .accessibilityHint(Text(L.ReviewCard.openHint))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { tap() }
        .accessibilityIdentifier("review_card_conjugations")

      Spacer(minLength: 0)

      Image(systemName: "chevron.right")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)
    }
    .padding(.top, Layout.defaultSpacing)
    .transition(.opacity)
  }
}
