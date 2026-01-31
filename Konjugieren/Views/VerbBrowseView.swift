// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct VerbBrowseView: View {
  @State private var sortOrder: SortOrder = .frequency
  @State private var sortedVerbs: [Verb] = Verb.verbsSortedByFrequency

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(sortedVerbs) { verb in
              NavigationLink(value: verb) {
                VerbRowView(verb: verb)
              }
              .buttonStyle(.plain)

              Divider()
                .padding(.leading)
            }
          }
        }

        Divider()

        Picker(L.VerbBrowse.alphabetical, selection: $sortOrder) {
          ForEach(SortOrder.allCases, id: \.self) { order in
            Text(order.displayName)
              .tag(order)
          }
        }
        .pickerStyle(.segmented)
        .padding()
      }
      .navigationTitle(L.Navigation.verbs)
      .navigationDestination(for: Verb.self) { verb in
        VerbView(verb: verb)
      }
      .onChange(of: sortOrder) {
        updateSortedVerbs()
      }
    }
  }

  private func updateSortedVerbs() {
    switch sortOrder {
    case .alphabetical:
      sortedVerbs = Verb.verbsSortedAlphabetically
    case .frequency:
      sortedVerbs = Verb.verbsSortedByFrequency
    }
  }
}

struct VerbRowView: View {
  let verb: Verb

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(verb.infinitiv)
          .tableText()
        Text(verb.translation)
          .tableSubtext()
      }

      Spacer()

      Text(verb.family.displayName)
        .font(.caption)
        .foregroundStyle(.secondary)

    }
    .contentShape(Rectangle())
    .padding(.horizontal)
    .padding(.vertical, 12)
  }
}

#Preview {
  VerbBrowseView()
}
