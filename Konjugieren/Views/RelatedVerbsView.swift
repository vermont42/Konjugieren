// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// Pushes a value onto whichever navigation stack shows the verb page, so the page's links work
/// in the Verbs tab and the Families tab alike. The value's stack needs a destination for its type.
struct VerbPagePush {
  let push: (any Hashable) -> Void

  func callAsFunction(_ value: some Hashable) {
    push(value)
  }
}

extension EnvironmentValues {
  @Entry var verbPagePush: VerbPagePush?
}

/// Every verb of one relation, which a verb page's short list leads to.
struct RelatedVerbListDestination: Hashable {
  enum Relation: Hashable {
    case ablautGroup(String)
    case builtOn(String)

    var title: String {
      switch self {
      case .ablautGroup(let group):
        return L.VerbView.sameAblaut(group.inUserRegion)
      case .builtOn(let root):
        return L.VerbView.builtOn(root.inUserRegion)
      }
    }
  }

  let relation: Relation
  let verbs: [Verb]
}

/// The verb page's ways out: a few verbs built on the same base, a few that share its ablaut, and
/// its pages in the Families tab.
struct RelatedVerbsView: View {
  let related: RelatedVerbs

  static let shortListLength = 6

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L.VerbView.relatedHeading)
        .font(.subheadline.smallCaps().weight(.semibold))
        .fontDesign(.serif)
        .foregroundStyle(.customYellow)
        .accessibilityAddTraits(.isHeader)

      if !related.builtOnRoot.isEmpty {
        relation(RelatedVerbListDestination(relation: .builtOn(related.root), verbs: related.builtOnRoot))
      }

      if let ablautGroup = related.ablautGroup, !related.ablautRelatives.isEmpty {
        relation(RelatedVerbListDestination(relation: .ablautGroup(ablautGroup), verbs: related.ablautRelatives))
      }

      VStack(alignment: .leading, spacing: 6) {
        Text(L.VerbView.familiesHeading)
          .font(.caption)
          .foregroundStyle(.secondary)
        FlowLayout(spacing: 8) {
          ForEach(related.families) { family in
            RelatedChip(text: family.displayName, systemImage: family.systemImageName, isGerman: UserLocale.isGerman) { push in
              push(family)
            }
          }
        }
      }
    }
    .konjCardWithAccentBar()
  }

  private func relation(_ destination: RelatedVerbListDestination) -> some View {
    let verbs = destination.verbs
    return VStack(alignment: .leading, spacing: 6) {
      Text(destination.relation.title)
        .font(.caption)
        .foregroundStyle(.secondary)
      FlowLayout(spacing: 8) {
        ForEach(verbs.prefix(Self.shortListLength)) { verb in
          RelatedChip(text: verb.infinitiv.inUserRegion, isGerman: true) { push in
            push(VerbDestination(verb: verb, source: .related))
          }
        }
        if verbs.count > Self.shortListLength {
          RelatedChip(text: L.VerbView.allRelated(verbs.count), systemImage: "list.bullet", isGerman: UserLocale.isGerman, bordered: true) { push in
            push(destination)
          }
        }
      }
    }
  }
}

private struct RelatedChip: View {
  let text: String
  var systemImage: String?
  let isGerman: Bool
  var bordered = false
  let action: (VerbPagePush) -> Void
  @Environment(\.verbPagePush) private var push

  var body: some View {
    Group {
      if let systemImage {
        Label(text, systemImage: systemImage)
      } else {
        Text(verbatim: text)
      }
    }
    .font(.subheadline)
    .foregroundStyle(.customYellow)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(Color.customYellow.opacity(0.08))
    .overlay {
      Capsule().strokeBorder(Color.customYellow.opacity(bordered ? 0.4 : 0), lineWidth: 1.5)
    }
    .clipShape(Capsule())
    .contentShape(Capsule())
    .accessibilityElement(children: .combine)
    .germanPronunciation(forReal: isGerman)
    .accessibilityAddTraits(.isButton)
    .accessibilityAction { activate() }
    .onTapGesture { activate() }
  }

  private func activate() {
    if let push {
      action(push)
    }
  }
}

/// Every verb of one relation, by frequency or alphabetically.
struct RelatedVerbListView: View {
  let destination: RelatedVerbListDestination
  @Environment(\.verbPagePush) private var push
  @State private var sortOrder = SortOrder.frequency

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          SortOrderPicker(selection: $sortOrder)
            .padding(.bottom, Layout.defaultSpacing)

          VerbListSection(verbs: destination.verbs.sorted(by: sortOrder)) { verb in
            push?(VerbDestination(verb: verb, source: .related))
          }
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
      }
      .navigationTitle(destination.relation.title)
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
