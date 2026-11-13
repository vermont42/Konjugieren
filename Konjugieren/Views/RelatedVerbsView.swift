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
        relation(
          title: L.VerbView.builtOn(related.root),
          verbs: related.builtOnRoot,
          destination: RelatedVerbListDestination(relation: .builtOn(related.root), verbs: related.builtOnRoot)
        )
      }

      if let ablautGroup = related.ablautGroup, !related.ablautRelatives.isEmpty {
        relation(
          title: L.VerbView.sameAblaut(ablautGroup),
          verbs: related.ablautRelatives,
          destination: RelatedVerbListDestination(relation: .ablautGroup(ablautGroup), verbs: related.ablautRelatives)
        )
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

  private func relation(title: String, verbs: [Verb], destination: RelatedVerbListDestination) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
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

  private var title: String {
    switch destination.relation {
    case .ablautGroup(let group):
      return L.VerbView.sameAblaut(group)
    case .builtOn(let root):
      return L.VerbView.builtOn(root)
    }
  }

  private var verbs: [Verb] {
    switch sortOrder {
    case .alphabetical:
      return destination.verbs.sorted {
        $0.infinitiv.compare($1.infinitiv, locale: Locale(identifier: "de")) == .orderedAscending
      }
    case .frequency:
      return destination.verbs.sorted(by: .frequency)
    }
  }

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          Picker(L.VerbBrowse.sortOrder, selection: $sortOrder) {
            ForEach(SortOrder.allCases, id: \.self) { order in
              Text(order.displayName)
                .tag(order)
            }
          }
          .pickerStyle(.segmented)
          .sensoryFeedback(.selection, trigger: sortOrder)
          .padding(.bottom, Layout.defaultSpacing)

          VerbListSection(verbs: verbs) { verb in
            push?(VerbDestination(verb: verb, source: .related))
          }
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
      }
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

/// Lays its children out in rows, wrapping to a new row when the next child would not fit.
struct FlowLayout: SwiftUI.Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let rows = rows(for: subviews, width: proposal.width ?? .infinity)
    let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
    let width = rows.map(\.width).max() ?? 0
    return CGSize(width: proposal.width ?? width, height: height)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    var y = bounds.minY
    for row in rows(for: subviews, width: bounds.width) {
      var x = bounds.minX
      for index in row.indices {
        let size = subviews[index].sizeThatFits(.unspecified)
        subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
        x += size.width + spacing
      }
      y += row.height + spacing
    }
  }

  private struct Row {
    var indices: [Int] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
  }

  private func rows(for subviews: Subviews, width: CGFloat) -> [Row] {
    var rows: [Row] = []
    var current = Row()
    for index in subviews.indices {
      let size = subviews[index].sizeThatFits(.unspecified)
      let widthWithChild = current.indices.isEmpty ? size.width : current.width + spacing + size.width
      if widthWithChild > width, !current.indices.isEmpty {
        rows.append(current)
        current = Row()
      }
      current.width = current.indices.isEmpty ? size.width : current.width + spacing + size.width
      current.height = max(current.height, size.height)
      current.indices.append(index)
    }
    if !current.indices.isEmpty {
      rows.append(current)
    }
    return rows
  }
}
