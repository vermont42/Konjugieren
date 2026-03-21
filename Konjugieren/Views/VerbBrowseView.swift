// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct VerbBrowseView: View {
  @Bindable var world = Current
  @State private var sortOrder: SortOrder = .frequency
  @State private var sortedVerbs: [Verb] = Verb.verbsSortedByFrequency
  @State private var searchText: String = ""
  @State private var navigationPath = NavigationPath()
  @Environment(\.horizontalSizeClass) private var sizeClass
  private let tryQuizTip = TryQuizTip()

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
            TipView(tryQuizTip)
              .padding(.horizontal)

            if filteredVerbs.isEmpty {
              ContentUnavailableView(L.VerbBrowse.noVerbsFound, systemImage: "magnifyingglass")
            } else {
              Text(L.VerbBrowse.verbCount(filteredVerbs.count))
                .font(.caption.smallCaps())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, Layout.defaultSpacing)

              if sizeClass == .regular {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.verbGridMinimum))], spacing: 0) {
                  ForEach(filteredVerbs) { verb in
                    VerbGridCell(verb: verb) { navigationPath.append(verb) }
                  }
                }
                .padding(.horizontal)
              } else {
                LazyVStack(spacing: 0) {
                  ForEach(Array(filteredVerbs.enumerated()), id: \.element.id) { index, verb in
                    VerbRowView(verb: verb) { navigationPath.append(verb) }
                      .background(index.isMultiple(of: 2) ? Color.clear : Color.customYellow.opacity(0.03))

                    Divider()
                      .padding(.leading)
                  }
                }
              }
            }
          }
          .onChange(of: sortOrder) {
            withAnimation(.easeInOut(duration: 0.3)) {
              updateSortedVerbs()
            }
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
      .sensoryFeedback(.selection, trigger: sortOrder)
      .onAppear {
        Current.analytics.signal(name: .viewVerbBrowseView)
        Current.reviewPrompter.promptableActionHappened()
      }
      .navigationTitle(L.Navigation.verbs)
      .navigationDestination(for: Verb.self) { verb in
        VerbView(verb: verb)
      }
      .searchable(text: $searchText, prompt: L.VerbBrowse.searchPrompt)
      .onChange(of: world.verb) {
        if let verb = world.verb {
          navigationPath = NavigationPath()
          navigationPath.append(verb)
          world.verb = nil
        }
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

@ViewBuilder
private func verbNameTexts(verb: Verb, navigate: @escaping () -> Void) -> some View {
  Text(verbatim: verb.infinitiv)
    .tableText()
    .germanPronunciation()
    .accessibilityAddTraits(UserLocale.isGerman ? .isButton : [])
    .accessibilityRemoveTraits(UserLocale.isGerman ? [] : .isButton)
    .accessibilityAction { navigate() }
  Text(verbatim: verb.translation)
    .tableSubtext()
    .englishPronunciation()
    .accessibilityAddTraits(UserLocale.isEnglish ? .isButton : [])
    .accessibilityRemoveTraits(UserLocale.isEnglish ? [] : .isButton)
    .accessibilityAction { navigate() }
}

private func verbFamilyText(verb: Verb, navigate: @escaping () -> Void) -> some View {
  Text(verbatim: verb.family.displayName)
    .font(.caption)
    .foregroundStyle(.secondary)
    .accessibilityAddTraits(.isButton)
    .accessibilityAction { navigate() }
}

struct VerbRowView: View {
  let verb: Verb
  let navigate: () -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        verbNameTexts(verb: verb, navigate: navigate)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 4) {
        verbFamilyText(verb: verb, navigate: navigate)
        Text("#\(verb.frequency)")
          .font(.caption.monospacedDigit())
          .foregroundStyle(.secondary)
      }
    }
    .contentShape(Rectangle())
    .padding(.horizontal)
    .padding(.vertical, 12)
    .onTapGesture { navigate() }
    .scrollTransition(.animated) { content, phase in
      content.opacity(1 - abs(phase.value) * 0.15)
    }
  }
}

private struct VerbGridCell: View {
  let verb: Verb
  let navigate: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      verbNameTexts(verb: verb, navigate: navigate)
      verbFamilyText(verb: verb, navigate: navigate)
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
