// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct FamilyDetailView: View {
  let family: BrowseableFamily
  let navigateToVerb: (Verb) -> Void

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Image(systemName: family.systemImageName)
              .font(.largeTitle)
              .foregroundStyle(.customYellow)
            Text(family.displayName)
              .font(.largeTitle.bold())
              .foregroundStyle(.customYellow)
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.bottom, 16)
          .accessibilityElement(children: .combine)
          .accessibilityAddTraits(.isHeader)
          .germanPronunciation(forReal: UserLocale.isGerman)

          RichTextView(blocks: family.longDescription.richTextBlocks)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

          if family.hasPrefixList {
            PrefixGroupedVerbList(family: family, navigateToVerb: navigateToVerb)
          } else if family.hasAblautList {
            AblautGroupedVerbList(family: family, navigateToVerb: navigateToVerb)
          } else {
            VerbListSection(verbs: family.verbs, navigateToVerb: navigateToVerb)
          }
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
      }
      .navigationBarTitleDisplayMode(.inline)
    }
    .onAppear {
      Current.analytics.signal(name: .viewFamilyDetailView)
      ExploreFamiliesTip().invalidate(reason: .actionPerformed)
    }
  }
}

struct PrefixGroupedVerbList: View {
  let family: BrowseableFamily
  let navigateToVerb: (Verb) -> Void
  @Environment(\.horizontalSizeClass) private var sizeClass

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(family.verbsByPrefix, id: \.prefix.id) { group in
        PrefixHeaderView(prefix: group.prefix)

        if sizeClass == .regular {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.verbGridMinimum))], spacing: 0) {
            ForEach(group.verbs) { verb in
              VerbRow(verb: verb, showFamilyBadge: true) { navigateToVerb(verb) }
            }
          }
        } else {
          ForEach(group.verbs) { verb in
            VerbRow(verb: verb, showFamilyBadge: true) { navigateToVerb(verb) }

            Divider()
          }
        }
      }
    }
    .padding(.top, 24)
  }
}

struct PrefixHeaderView: View {
  let prefix: PrefixMeaning

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(prefix.prefix)
        .font(.title2.bold())
        .foregroundStyle(.customYellow)
        .accessibilityAddTraits(.isHeader)

      HStack(spacing: 4) {
        Text("\(Image("EmojiEnglandFlag").renderingMode(.original))")
        Text(prefix.englishMeaning)
          .foregroundStyle(.customForeground)
      }
      .font(.subheadline)

      HStack(spacing: 4) {
        Text("\(Image("EmojiHorse").renderingMode(.original))")
        Text(prefix.pie)
          .foregroundStyle(.customYellow)
          .italic()
        Text("• \(prefix.pieMeaning)")
          .foregroundStyle(.customForeground)
      }
      .font(.subheadline)
    }
    .padding(.top, 16)
    .padding(.bottom, 8)
  }
}

struct VerbRow: View {
  let verb: Verb
  var showFamilyBadge: Bool = false
  var leadingInset: CGFloat = 0
  let navigate: () -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(verb.infinitiv)
          .font(.callout)
          .foregroundStyle(.customYellow)
          .germanPronunciation()
          .accessibilityAddTraits(UserLocale.isGerman ? .isButton : [])
          .accessibilityRemoveTraits(UserLocale.isGerman ? [] : .isButton)
          .accessibilityAction { navigate() }
        Text(verb.translation)
          .font(.footnote)
          .foregroundStyle(.customForeground)
          .englishPronunciation()
          .accessibilityAddTraits(UserLocale.isEnglish ? .isButton : [])
          .accessibilityRemoveTraits(UserLocale.isEnglish ? [] : .isButton)
          .accessibilityAction { navigate() }
      }
      .padding(.leading, leadingInset)

      Spacer()

      if showFamilyBadge {
        Text(verb.family.displayName)
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)
    }
    .padding(.vertical, 8)
    .contentShape(Rectangle())
    .onTapGesture { navigate() }
  }
}

struct VerbListSection: View {
  let verbs: [Verb]
  let navigateToVerb: (Verb) -> Void
  @Environment(\.horizontalSizeClass) private var sizeClass

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(L.FamilyDetail.verbsHeading)
        .font(.title2.bold())
        .foregroundStyle(.customYellow)
        .padding(.top, 24)
        .accessibilityAddTraits(.isHeader)

      if sizeClass == .regular {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.verbGridMinimum))], spacing: 0) {
          ForEach(verbs) { verb in
            VerbRow(verb: verb) { navigateToVerb(verb) }
          }
        }
      } else {
        LazyVStack(spacing: 0) {
          ForEach(verbs) { verb in
            VerbRow(verb: verb) { navigateToVerb(verb) }

            Divider()
          }
        }
      }
    }
  }
}

struct AblautGroupedVerbList: View {
  let family: BrowseableFamily
  let navigateToVerb: (Verb) -> Void
  @State private var expandedGroups: Set<String> = []

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      LazyVStack(spacing: 0) {
        ForEach(family.ablautGroups) { group in
          AblautGroupSection(
            group: group,
            isExpanded: expandedGroups.contains(group.exemplar),
            onToggle: {
              if expandedGroups.contains(group.exemplar) {
                expandedGroups.remove(group.exemplar)
              } else {
                expandedGroups.insert(group.exemplar)
              }
            },
            navigateToVerb: navigateToVerb
          )
        }
      }
    }
    .padding(.top, 24)
  }
}

struct AblautGroupSection: View {
  let group: AblautGroupInfo
  let isExpanded: Bool
  let onToggle: () -> Void
  let navigateToVerb: (Verb) -> Void
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.horizontalSizeClass) private var sizeClass

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      AblautGroupHeader(group: group, isExpanded: isExpanded)
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
          withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            onToggle()
          }
        }

      if isExpanded {
        if sizeClass == .regular {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.verbGridMinimum))], spacing: 0) {
            ForEach(group.verbs) { verb in
              VerbRow(verb: verb, showFamilyBadge: true, leadingInset: 16) { navigateToVerb(verb) }
            }
          }
        } else {
          ForEach(group.verbs) { verb in
            VerbRow(verb: verb, showFamilyBadge: true, leadingInset: 16) { navigateToVerb(verb) }

            Divider()
              .padding(.leading, 16)
          }
        }
      }

      Divider()
    }
  }
}

struct AblautGroupHeader: View {
  let group: AblautGroupInfo
  let isExpanded: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(group.exemplar)
          .font(.title2.bold())
          .foregroundStyle(.customYellow)
          .accessibilityAddTraits(.isHeader)

        Spacer()

        Text("\(group.verbCount)")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundStyle(.secondary)
          .rotationEffect(.degrees(isExpanded ? 90 : 0))
          .animation(.easeInOut(duration: 0.2), value: isExpanded)
          .accessibilityHidden(true)
      }

      BodyTextView(segments: group.description.parseBodyToSegments())
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.vertical, 12)
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  @Previewable @State var navigationPath = NavigationPath()
  NavigationStack(path: $navigationPath) {
    FamilyDetailView(family: .separable) { verb in navigationPath.append(verb) }
      .navigationDestination(for: Verb.self) { verb in
        VerbView(verb: verb)
      }
  }
}
