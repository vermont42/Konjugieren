// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// What the Quiz tab's hub pushes for its Ablaut Groups row.
struct AblautPracticeDestination: Hashable {}

/// The ablaut groups that can be practiced alone, the most used first, each opening onto its
/// practice (Phase 16 of the pedagogy plan). The Families tab's Ablaut page offers the same
/// practice in each expanded group, below an article too long to put between the hub and a round.
struct AblautPracticeListView: View {
  @State private var expandedGroups: Set<String> = []
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    let record = Current.practice.record

    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
          Text(L.AblautPractice.listIntro)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, Layout.defaultSpacing)

          ForEach(AblautPracticeGroup.practicedAloneByUse) { group in
            let isExpanded = expandedGroups.contains(group.exemplar)

            VStack(alignment: .leading, spacing: 0) {
              AblautPracticeGroupHeader(group: group, isKnown: group.isKnown(in: record), isExpanded: isExpanded)
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("ablaut_practice_group_\(group.exemplar)")
                .onTapGesture {
                  withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                    if isExpanded {
                      expandedGroups.remove(group.exemplar)
                    } else {
                      expandedGroups.insert(group.exemplar)
                    }
                  }
                }

              if isExpanded {
                AblautPracticeCard(exemplar: group.exemplar, showsKnown: false)
                  .padding(.bottom, Layout.doubleDefaultSpacing)
              }

              Divider()
            }
          }
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
        .padding(.vertical, Layout.doubleDefaultSpacing)
        .frame(maxWidth: 680)
        .frame(maxWidth: .infinity)
      }
    }
    .navigationTitle(L.AblautPractice.title)
    .navigationBarTitleDisplayMode(.inline)
  }
}

private struct AblautPracticeGroupHeader: View {
  let group: AblautPracticeGroup
  let isKnown: Bool
  let isExpanded: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(verbatim: group.exemplar.inUserRegion)
          .font(.title3.bold())
          .foregroundStyle(.customYellow)
          .germanPronunciation()

        if isKnown {
          Image(systemName: "checkmark.seal.fill")
            .font(.subheadline)
            .foregroundStyle(.customYellow)
            .accessibilityLabel(L.AblautPractice.known)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundStyle(.secondary)
          .rotationEffect(.degrees(isExpanded ? 90 : 0))
          .animation(.easeInOut(duration: 0.2), value: isExpanded)
          .accessibilityHidden(true)
      }

      BodyTextView(segments: AblautGroupInfo(exemplar: group.exemplar).description.parseBodyToSegments())
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.vertical, 12)
    .accessibilityElement(children: .combine)
  }
}
