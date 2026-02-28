// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct FamilyBrowseView: View {
  @Environment(\.horizontalSizeClass) private var sizeClass
  private let exploreFamiliesTip = ExploreFamiliesTip()
  @State private var decorations = DecorationImage.allCases.shuffled()
  @State private var gridWidth: CGFloat = 0
  @State private var navigationPath = NavigationPath()

  private var fillerCount: Int {
    guard gridWidth > 0 else { return 0 }
    let spacing = Layout.doubleDefaultSpacing
    let minimum = Layout.showcaseCardGridMinimum
    let columnCount = max(1, Int((gridWidth + spacing) / (minimum + spacing)))
    let itemCount = BrowseableFamily.allCases.count
    return (columnCount - (itemCount % columnCount)) % columnCount
  }

  var body: some View {
    NavigationStack(path: $navigationPath) {
      ScrollView {
        TipView(exploreFamiliesTip)
          .padding(.horizontal)

        if sizeClass == .regular {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.showcaseCardGridMinimum))], spacing: Layout.doubleDefaultSpacing) {
            ForEach(BrowseableFamily.allCases) { family in
              NavigationLink(value: family) {
                FamilyShowcaseCard(family: family)
              }
              .buttonStyle(.plain)
            }

            ForEach(decorations.prefix(fillerCount)) { decoration in
              DecorationImageCard(decoration: decoration)
            }
          }
          .padding(.horizontal)
          .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
          } action: { newWidth in
            gridWidth = newWidth
          }
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
        FamilyDetailView(family: family) { verb in navigationPath.append(verb) }
      }
      .navigationDestination(for: Verb.self) { verb in
        VerbView(verb: verb)
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
    .accessibilityElement(children: .combine)
  }
}

private struct FamilyShowcaseCard: View {
  let family: BrowseableFamily
  private var settings: Settings { Current.settings }

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

      HStack(alignment: .top, spacing: Layout.doubleDefaultSpacing) {
        VStack(alignment: .leading, spacing: 4) {
          ForEach(PersonNumber.allCases.prefix(3), id: \.self) { personNumber in
            conjugationRow(personNumber: personNumber)
          }
        }
        VStack(alignment: .leading, spacing: 4) {
          ForEach(PersonNumber.allCases.suffix(3), id: \.self) { personNumber in
            conjugationRow(personNumber: personNumber)
          }
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
    .accessibilityElement(children: .combine)
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
        .frame(width: Layout.pronounColumnWidth, alignment: .leading)
      Text(mixedCaseString: conjugation)
        .font(.callout)
    }
  }
}

private enum DecorationImage: String, CaseIterable, Identifiable {
  case hat = "Hat"
  case bundestag = "Bundestag"
  case pretzel = "Pretzel"
  var id: String { rawValue }
}

private struct DecorationImageCard: View {
  let decoration: DecorationImage

  var body: some View {
    Image(decoration.rawValue)
      .resizable()
      .scaledToFit()
      .padding(Layout.tripleDefaultSpacing)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.white.opacity(0.05))
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .accessibilityHidden(true)
  }
}

#Preview {
  FamilyBrowseView()
}
