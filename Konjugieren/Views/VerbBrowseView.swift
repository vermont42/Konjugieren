// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct VerbBrowseView: View {
  @State private var sortOrder: SortOrder = .frequency
  @State private var sortedVerbs: [Verb] = Verb.verbsSortedByFrequency
  @State private var searchText: String = ""
  @State private var navigationPath = NavigationPath()
  @Environment(\.horizontalSizeClass) private var sizeClass

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
    NavigationStack(path: $navigationPath) {
      VStack(spacing: 0) {
        ScrollViewReader { proxy in
          ScrollView {
            if sizeClass == .regular {
              LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.verbGridMinimum))], spacing: 0) {
                ForEach(filteredVerbs) { verb in
                  VerbGridCell(verb: verb) { navigationPath.append(verb) }
                }
              }
              .padding(.horizontal)
            } else {
              LazyVStack(spacing: 0) {
                ForEach(filteredVerbs) { verb in
                  VerbRowView(verb: verb) { navigationPath.append(verb) }

                  Divider()
                    .padding(.leading)
                }
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
      .onAppear { Current.analytics.signal(name: .viewVerbBrowseView) }
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
  let navigate: () -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(verbatim: verb.infinitiv)
          .tableText()
          .germanPronunciation()
          .accessibilityAddTraits(.isButton)
          .accessibilityAction { navigate() }
        Text(verbatim: verb.translation)
          .tableSubtext()
          .englishPronunciation()
          .accessibilityAddTraits(.isButton)
          .accessibilityAction { navigate() }
      }

      Spacer()

      Text(verbatim: verb.family.displayName)
        .font(.caption)
        .foregroundStyle(.secondary)
        .englishPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { navigate() }
    }
    .contentShape(Rectangle())
    .padding(.horizontal)
    .padding(.vertical, 12)
    .onTapGesture { navigate() }
  }
}

private struct VerbGridCell: View {
  let verb: Verb
  let navigate: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(verbatim: verb.infinitiv)
        .tableText()
        .germanPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { navigate() }
      Text(verbatim: verb.translation)
        .tableSubtext()
        .englishPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { navigate() }
      Text(verbatim: verb.family.displayName)
        .font(.caption)
        .foregroundStyle(.secondary)
        .englishPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { navigate() }
    }
    .padding(.horizontal)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(Rectangle())
    .onTapGesture { navigate() }
  }
}

#Preview {
  VerbBrowseView()
}
