// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct InfoBrowseView: View {
  var body: some View {
    NavigationStack {
      List {
        NavigationLink {
          HistoryView()
        } label: {
          InfoRowView(
            title: L.Info.history,
            subtitle: L.Info.historySubtitle,
            systemImage: "clock.arrow.circlepath"
          )
        }
      }
      .listStyle(.plain)
      .navigationTitle(L.Navigation.info)
    }
  }
}

struct InfoRowView: View {
  let title: String
  let subtitle: String
  let systemImage: String

  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: systemImage)
        .font(.title2)
        .foregroundStyle(.customYellow)
        .frame(width: 32)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
          .foregroundStyle(.primary)

        Text(subtitle)
          .font(.subheadline)
          .foregroundStyle(.primary)
      }
    }
    .padding(.vertical, 8)
  }
}

#Preview {
  InfoBrowseView()
}
