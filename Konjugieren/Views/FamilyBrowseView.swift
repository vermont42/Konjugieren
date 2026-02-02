// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct FamilyBrowseView: View {
  var body: some View {
    NavigationStack {
      ScrollView {
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

#Preview {
  FamilyBrowseView()
}
