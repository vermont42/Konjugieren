// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct FamilyDetailView: View {
  let family: BrowseableFamily

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

          RichTextView(blocks: family.longDescription.richTextBlocks)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

          if family.hasPrefixList {
            PrefixGroupedVerbList(family: family)
          } else {
            VerbListSection(verbs: family.verbs)
          }
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
      }
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct PrefixGroupedVerbList: View {
  let family: BrowseableFamily

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(family.verbsByPrefix, id: \.prefix.id) { group in
        PrefixHeaderView(prefix: group.prefix)

        ForEach(group.verbs) { verb in
          NavigationLink(value: verb) {
            PrefixVerbRow(verb: verb)
          }
          .buttonStyle(.plain)

          Divider()
        }
      }
    }
    .padding(.top, 24)
    .navigationDestination(for: Verb.self) { verb in
      VerbView(verb: verb)
    }
  }
}

struct PrefixHeaderView: View {
  let prefix: PrefixMeaning

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(prefix.prefix)
        .font(.title2.bold())
        .foregroundStyle(.customYellow)

      HStack(spacing: 4) {
        Text("🏴󠁧󠁢󠁥󠁮󠁧󠁿")
        Text(prefix.englishMeaning)
          .foregroundStyle(.customForeground)
      }
      .font(.subheadline)

      HStack(spacing: 4) {
        Text("🐎")
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

struct PrefixVerbRow: View {
  let verb: Verb

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(verb.infinitiv)
          .font(.system(size: 16))
          .foregroundStyle(.customYellow)
        Text(verb.translation)
          .font(.system(size: 14))
          .foregroundStyle(.customForeground)
      }

      Spacer()

      Text(verb.family.displayName)
        .font(.system(size: 14))
        .foregroundStyle(.secondary)

      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 8)
    .contentShape(Rectangle())
  }
}

struct VerbListSection: View {
  let verbs: [Verb]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(L.FamilyDetail.verbsHeading)
        .font(.title2.bold())
        .foregroundStyle(.customYellow)
        .padding(.top, 24)

      LazyVStack(spacing: 0) {
        ForEach(verbs) { verb in
          NavigationLink(value: verb) {
            HStack {
              VStack(alignment: .leading, spacing: 2) {
                Text(verb.infinitiv)
                  .font(.system(size: 16))
                  .foregroundStyle(.customYellow)
                Text(verb.translation)
                  .font(.system(size: 14))
                  .foregroundStyle(.customForeground)
              }

              Spacer()

              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)

          Divider()
        }
      }
    }
    .navigationDestination(for: Verb.self) { verb in
      VerbView(verb: verb)
    }
  }
}

#Preview {
  NavigationStack {
    FamilyDetailView(family: .separable)
  }
}
