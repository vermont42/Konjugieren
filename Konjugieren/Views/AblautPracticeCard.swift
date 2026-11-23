// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// An expanded ablaut group's practice: Verb Essentials over the
/// group alone, and mixed with the groups the learner knows. A single-verb group says why it has
/// neither.
struct AblautPracticeCard: View {
  let exemplar: String
  /// False where the group's heading already says so.
  var showsKnown = true
  @State private var session: AblautPracticeSession?
  @Environment(\.isBeneathQuiz) private var isBeneathQuiz

  private static let partnerPreviewCount = 4

  var body: some View {
    // Opened from a quiz's held correction, a group starts no second quiz over the first.
    if !isBeneathQuiz, let group = AblautPracticeGroup.group(exemplar) {
      let record = Current.practice.record
      let partners = group.mixPartners(in: record)
      let isMarkedKnown = showsKnown && group.isKnown(in: record)

      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        // A single-verb group has no pattern to practice, so only a known one has a first line.
        if group.offersPracticeAlone || isMarkedKnown {
          HStack {
            if group.offersPracticeAlone {
              Text(L.AblautPractice.heading)
                .font(.subheadline.bold())
                .foregroundStyle(.customForeground)
                .accessibilityAddTraits(.isHeader)
            }

            Spacer()

            if isMarkedKnown {
              Label(L.AblautPractice.known, systemImage: "checkmark.seal.fill")
                .font(.caption.bold())
                .foregroundStyle(.customYellow)
                .accessibilityIdentifier("ablaut_practice_known")
            }
          }
        }

        if group.offersPracticeAlone {
          Text(group.members.count < AblautPracticeGroup.verbLimit ? L.AblautPractice.descriptionAll : L.AblautPractice.descriptionFrequent)
            .font(.subheadline)
            .foregroundStyle(.customForeground)
            .fixedSize(horizontal: false, vertical: true)

          HStack(spacing: Layout.defaultSpacing) {
            Button {
              session = AblautPracticeSession(exemplar: exemplar, mode: .alone)
            } label: {
              Label(L.AblautPractice.alone, systemImage: "square.3.layers.3d")
            }
            .accessibilityHint(L.Accessibility.ablautPracticeAloneHint)
            .accessibilityIdentifier("ablaut_practice_alone_button")

            Button {
              session = AblautPracticeSession(exemplar: exemplar, mode: .mixed)
            } label: {
              Label(L.AblautPractice.mixed, systemImage: "shuffle")
            }
            .disabled(partners.isEmpty)
            .accessibilityHint(L.Accessibility.ablautPracticeMixedHint)
            .accessibilityIdentifier("ablaut_practice_mixed_button")
          }
          .buttonStyle(.bordered)
          .tint(.customYellow)

          Text(partners.isEmpty ? L.AblautPractice.mixedLocked : L.AblautPractice.mixedWith(Self.preview(of: partners)))
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("ablaut_practice_mixed_note")
        } else {
          Text(L.AblautPractice.singleVerb)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("ablaut_practice_single_verb_note")
        }
      }
      .konjCard()
      .sheet(item: $session) { session in
        QuizSheet(scope: .ablautPractice(session))
      }
    }
  }

  /// "bleiben, fahren, sein, singen …": the first known groups, by their exemplars.
  private static func preview(of partners: [AblautPracticeGroup]) -> String {
    let shown = partners.prefix(partnerPreviewCount).map(\.exemplar.inUserRegion)
    return shown.joined(separator: ", ") + (partners.count > shown.count ? " …" : "")
  }
}
