// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct VerbBrowseView: View {
  @State private var sortOrder: SortOrder = .alphabetical

  private var sortedVerbs: [Verb] {
    let verbs = Array(Verb.verbs.values)
    switch sortOrder {
    case .alphabetical:
      return verbs.sorted { $0.infinitiv < $1.infinitiv }
    case .frequency:
      return verbs.sorted { $0.frequency < $1.frequency }
    }
  }

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
    .padding(.horizontal)
    .padding(.vertical, 12)
  }
}

#Preview {
  VerbBrowseView()
}
