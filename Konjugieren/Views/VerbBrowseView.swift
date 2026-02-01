// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct VerbBrowseView: View {
  @State private var sortOrder: SortOrder = .frequency
  @State private var sortedVerbs: [Verb] = Verb.verbsSortedByFrequency
  @State private var searchText: String = ""

  private var settings: Settings { Current.settings }

  private var filteredVerbs: [Verb] {
    guard !searchText.isEmpty else { return sortedVerbs }
    return sortedVerbs.filter { verb in
      if verb.infinitiv.localizedCaseInsensitiveContains(searchText) {
        return true
      }
      if settings.searchScope == .infinitiveAndTranslation {
        return verb.translation.localizedCaseInsensitiveContains(searchText)
      }
      return false
    }
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack(spacing: 0) {
              ForEach(filteredVerbs) { verb in
                NavigationLink(value: verb) {
                  VerbRowView(verb: verb)
                }
                .buttonStyle(.plain)

                Divider()
                  .padding(.leading)
              }
            }
          }
          .onChange(of: sortOrder) {
            updateSortedVerbs()
            Task { @MainActor in
              if let firstVerb = sortedVerbs.first {
                proxy.scrollTo(firstVerb.id, anchor: .top)
              }
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
      .searchable(text: $searchText, prompt: L.VerbBrowse.searchPrompt)
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
