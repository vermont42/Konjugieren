// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct HistoryView: View {
  @State private var expandedSections: Set<UUID> = []

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(HistoryContent.sections) { section in
          HistorySectionView(
            section: section,
            isExpanded: expandedSections.contains(section.id),
            onToggle: {
              withAnimation(.easeInOut(duration: 0.3)) {
                if expandedSections.contains(section.id) {
                  expandedSections.remove(section.id)
                } else {
                  expandedSections.insert(section.id)
                }
              }
            }
          )

          Divider()
            .padding(.leading)
        }
      }
    }
    .navigationTitle(L.Info.history)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          withAnimation(.easeInOut(duration: 0.3)) {
            if expandedSections.count == HistoryContent.sections.count {
              expandedSections.removeAll()
            } else {
              expandedSections = Set(HistoryContent.sections.map { $0.id })
            }
          }
        } label: {
          Image(systemName: expandedSections.count == HistoryContent.sections.count
                ? "arrow.down.right.and.arrow.up.left"
                : "arrow.up.left.and.arrow.down.right")
        }
      }
    }
  }
}

struct HistorySectionView: View {
  let section: HistorySection
  let isExpanded: Bool
  let onToggle: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Button(action: onToggle) {
        HStack {
          Text(section.title)
            .font(.headline)
            .foregroundStyle(.customYellow)
            .multilineTextAlignment(.leading)

          Spacer()

          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            .foregroundStyle(.secondary)
            .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if isExpanded {
        Text(section.content)
          .font(.body)
          .foregroundStyle(.primary)
          .padding(.horizontal)
          .padding(.bottom, 16)
          .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
  }
}

#Preview {
  NavigationStack {
    HistoryView()
  }
}
