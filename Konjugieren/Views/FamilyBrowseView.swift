// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct FamilyBrowseView: View {
  @Environment(\.horizontalSizeClass) private var sizeClass

  var body: some View {
    NavigationStack {
      ScrollView {
        if sizeClass == .regular {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.showcaseCardGridMinimum))], spacing: Layout.doubleDefaultSpacing) {
            ForEach(BrowseableFamily.allCases) { family in
              NavigationLink(value: family) {
                FamilyShowcaseCard(family: family)
              }
              .buttonStyle(.plain)
            }
          }
          .padding(.horizontal)
        } else {
          LazyVStack(spacing: 0) {
            ForEach(BrowseableFamily.allCases) { family in
              NavigationLink(value: family) {
                FamilyRowView(family: family)
              }
              .buttonStyle(.plain)

              Divider()
                .padding(.leading)
            }
          }
        }
      }
      .onAppear { Current.analytics.signal(name: .viewFamilyBrowseView) }
      .navigationTitle(L.Navigation.families)
      .navigationDestination(for: BrowseableFamily.self) { family in
        FamilyDetailView(family: family)
      }
    }
  }
}

struct FamilyRowView: View {
  let family: BrowseableFamily

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: family.systemImageName)
        .font(.title2)
        .foregroundStyle(.customYellow)
        .frame(width: 32)

      VStack(alignment: .leading, spacing: 4) {
        Text(family.displayName)
          .tableText()
        Text(family.shortDescription)
          .tableSubtext()
      }

      Spacer()

      Text("\(family.verbCount)")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .contentShape(Rectangle())
    .padding(.horizontal)
    .padding(.vertical, 12)
  }
}

private struct FamilyShowcaseCard: View {
  let family: BrowseableFamily
  private var settings: Settings { Current.settings }

  private static let previewPersonNumbers: [PersonNumber] = [.firstSingular, .secondSingular, .thirdSingular]

  private var conjugationgroupLabel: String {
    let group = Conjugationgroup.präsensIndicativ(.firstSingular)
    switch settings.conjugationgroupLang {
    case .german:
      return group.germanDisplayName
    case .english:
      return group.englishDisplayName
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack {
        Image(systemName: family.systemImageName)
          .font(.title2)
          .foregroundStyle(.customYellow)

        Spacer()

        Text("\(family.verbCount)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Text(family.displayName)
        .tableText()
      Text(family.shortDescription)
        .tableSubtext()

      Divider()

      Text(conjugationgroupLabel)
        .font(.caption)
        .foregroundStyle(.secondary)

      VStack(alignment: .leading, spacing: 4) {
        ForEach(Self.previewPersonNumbers, id: \.self) { personNumber in
          conjugationRow(personNumber: personNumber)
        }
      }

      HStack(spacing: Layout.defaultSpacing) {
        ForEach(family.topVerbs) { verb in
          Text(verb.infinitiv)
            .font(.caption)
            .foregroundStyle(.customYellow)
            .padding(.horizontal, Layout.defaultSpacing)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(0.05))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .contentShape(Rectangle())
  }

  private func conjugationRow(personNumber: PersonNumber) -> some View {
    let infinitiv = family.representativeInfinitiv
    let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: .präsensIndicativ(personNumber))
    let conjugation: String
    switch result {
    case .success(let value):
      conjugation = value
    case .failure:
      conjugation = "—"
    }

    return HStack(spacing: Layout.defaultSpacing) {
      Text(personNumber.pronoun)
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(width: 28, alignment: .leading)
      Text(mixedCaseString: conjugation)
        .font(.callout)
    }
  }
}

#Preview {
  FamilyBrowseView()
}
