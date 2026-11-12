// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct VerbBrowseView: View {
  @Bindable var world = Current
  @State private var sortOrder: SortOrder = .frequency
  @State private var sortedVerbs: [Verb] = Verb.verbsSortedByFrequency
  @State private var searchText: String = ""
  @State private var navigationPath = NavigationPath()
  @State private var keyboardSelection: Int?
  @State private var addressWasCopied = false
  @FocusState private var searchIsFocused: Bool
  @Environment(\.horizontalSizeClass) private var sizeClass
  private let tryQuizTip = TryQuizTip()

  private var settings: Settings { Current.settings }

  private static let isPadOrMac = UIDevice.current.userInterfaceIdiom == .pad

  // iPadOS 26 shrinks .automatic search into a toolbar button that ignores .searchFocused, so
  // Command-F could not open it. A drawer that stays put accepts programmatic focus.
  private var searchPlacement: SearchFieldPlacement {
    Self.isPadOrMac ? .navigationBarDrawer(displayMode: .always) : .automatic
  }

  private var searchIncludesGlosses: Bool {
    settings.searchScope == .infinitiveAndTranslation
  }

  private var trimmedSearchText: String {
    searchText.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var filteredVerbs: [Verb] {
    guard !trimmedSearchText.isEmpty else {
      return sortedVerbs
    }
    return VerbSearch.matches(for: searchText, in: sortedVerbs, includeGlosses: searchIncludesGlosses)
      .map(\.verb)
  }

  private var guessedVerb: Verb? {
    VerbSearch.closestVerb(to: searchText, in: sortedVerbs)
  }

  var body: some View {
    let filteredVerbs = self.filteredVerbs
    NavigationStack(path: $navigationPath) {
      VStack(spacing: 0) {
        ScrollViewReader { proxy in
          ScrollView {
            TipView(tryQuizTip)
              .padding(.horizontal)

            if filteredVerbs.isEmpty {
              ContentUnavailableView(L.VerbBrowse.noVerbsFound, systemImage: "magnifyingglass")
                .onAppear {
                  Current.soundPlayer.play(.randomSadTrombone)
                }

              failedSearchHelp
            } else {
              Text(L.VerbBrowse.verbCount(filteredVerbs.count))
                .font(.caption.smallCaps())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, Layout.defaultSpacing)
                .accessibilityIdentifier("verb_browse_anchor")

              if sizeClass == .regular {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.verbGridMinimum))], spacing: 0) {
                  ForEach(Array(filteredVerbs.enumerated()), id: \.element.id) { index, verb in
                    VerbGridCell(verb: verb) { navigationPath.append(verb) }
                      .background(
                        RoundedRectangle(cornerRadius: Layout.defaultSpacing)
                          .fill(index == keyboardSelection ? Color.customRed.opacity(0.2) : Color.clear)
                      )
                  }
                }
                .padding(.horizontal)
              } else {
                LazyVStack(spacing: 0) {
                  ForEach(Array(filteredVerbs.enumerated()), id: \.element.id) { index, verb in
                    VerbRowView(verb: verb) { navigationPath.append(verb) }
                      .background(rowBackground(index: index))

                    Divider()
                      .padding(.leading)
                  }
                }
              }
            }
          }
          .onChange(of: keyboardSelection) {
            if let keyboardSelection, filteredVerbs.indices.contains(keyboardSelection) {
              proxy.scrollTo(filteredVerbs[keyboardSelection].id)
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

        // A keyboard toolbar does not attach to the navigation bar's search field, so the row
        // takes the sort picker's place while the field is focused. Search ranks by frequency
        // whatever the sort order, so the picker has nothing to do then.
        if searchIsFocused {
          GermanLetterKeyRow { letter in
            searchText.append(letter)
          }
          .padding(.vertical, Layout.defaultSpacing)
        } else {
          Picker(L.VerbBrowse.sortOrder, selection: $sortOrder) {
            ForEach(SortOrder.allCases, id: \.self) { order in
              Text(order.displayName)
                .tag(order)
            }
          }
          .pickerStyle(.segmented)
          .padding()
        }
      }
      .sensoryFeedback(.selection, trigger: sortOrder)
      .onAppear {
        Current.analytics.signal(name: .viewVerbBrowseView)
        Current.reviewPrompter.promptableActionHappened()
      }
      .navigationTitle(L.Navigation.verbs)
      .navigationDestination(for: Verb.self) { verb in
        // A deeplink replaces the path with a one-verb path, which reuses this destination's
        // identity, so without the id a VerbView kept the previous verb's selected reading.
        VerbView(verb: verb)
          .id(verb.id)
      }
      .searchable(
        text: $searchText,
        placement: searchPlacement,
        prompt: searchIncludesGlosses ? L.VerbBrowse.searchPromptInfinitiveOrMeaning : L.VerbBrowse.searchPromptInfinitive
      )
      .searchFocused($searchIsFocused)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .onSubmit(of: .search) {
        if Self.isPadOrMac {
          openKeyboardSelection()
        }
      }
      .onChange(of: searchIsFocused) {
        if searchIsFocused {
          VerbSearchArrowKeys.install { offset in
            moveKeyboardSelection(by: offset)
          }
        } else {
          VerbSearchArrowKeys.uninstall()
        }
      }
      .onChange(of: searchText) {
        keyboardSelection = nil
      }
      .onChange(of: world.shouldFocusVerbSearch) {
        if world.shouldFocusVerbSearch {
          world.shouldFocusVerbSearch = false
          Task {
            await focusSearch()
          }
        }
      }
      .onChange(of: world.verb) {
        if let verb = world.verb {
          navigationPath = NavigationPath()
          navigationPath.append(verb)
          world.verb = nil
        }
      }
    }
  }

  private var failedSearchHelp: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      if let guessedVerb {
        Text(L.VerbBrowse.guessIntro)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .padding(.horizontal)
          .accessibilityIdentifier("search_guess_intro")

        VerbRowView(verb: guessedVerb) { navigationPath.append(guessedVerb) }
          .background(keyboardSelection == 0 ? Color.customRed.opacity(0.2) : Color.clear)

        Divider()
          .padding(.leading)
      }

      Text(verbRequestText(query: trimmedSearchText))
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.horizontal)
        .padding(.top, Layout.defaultSpacing)
        .accessibilityIdentifier("verb_request_link")
        .environment(\.openURL, OpenURLAction { url in
          Task {
            await openVerbRequest(url)
          }
          return .handled
        })

      if addressWasCopied {
        Text(L.VerbBrowse.addressCopied)
          .font(.footnote)
          .foregroundStyle(Color.customYellow)
          .padding(.horizontal)
          .transition(.opacity)
          .accessibilityIdentifier("address_copied_note")
      }
    }
  }

  /// A device with no email app, such as the simulator, cannot open the link, so the address
  /// goes to the clipboard instead of nowhere.
  private func openVerbRequest(_ url: URL) async {
    guard !(await UIApplication.shared.open(url)) else {
      return
    }
    UIPasteboard.general.string = URL.developerEmail
    AccessibilityNotification.Announcement(L.VerbBrowse.addressCopied).post()
    withAnimation {
      addressWasCopied = true
    }
    try? await Task.sleep(for: .seconds(4))
    withAnimation {
      addressWasCopied = false
    }
  }

  private func focusSearch() async {
    if !navigationPath.isEmpty {
      navigationPath = NavigationPath()
      // Hack: focus requested while the pop animates sets the focus state without making the
      // field first responder, so typing goes nowhere. Wait out the animation.
      try? await Task.sleep(for: .milliseconds(500))
    }
    searchIsFocused = true
  }

  private func verbRequestText(query: String) -> AttributedString {
    let address = URL.developerEmail
    var text = AttributedString(L.VerbBrowse.verbRequest(query: query, address: address))
    if
      let range = text.range(of: address, options: .backwards),
      let url = URL.mailto(address, subject: L.VerbBrowse.verbRequestSubject(query: query), body: L.VerbBrowse.verbRequestBody(query: query))
    {
      text[range].link = url
    }
    return text
  }

  private func rowBackground(index: Int) -> Color {
    if index == keyboardSelection {
      return Color.customRed.opacity(0.2)
    }
    return index.isMultiple(of: 2) ? Color.clear : Color.customYellow.opacity(0.03)
  }

  /// The verbs that Return and the arrow keys move through: the results, or the guess when
  /// a search found nothing.
  private var keyboardTargets: [Verb] {
    let verbs = filteredVerbs
    if verbs.isEmpty, let guessedVerb {
      return [guessedVerb]
    }
    return verbs
  }

  private func moveKeyboardSelection(by offset: Int) {
    guard navigationPath.isEmpty else {
      return
    }
    keyboardSelection = Self.keyboardSelection(after: keyboardSelection, moving: offset, count: keyboardTargets.count)
  }

  /// The first arrow press lands on the first result, and the selection stops at either end
  /// rather than wrapping.
  nonisolated static func keyboardSelection(after current: Int?, moving offset: Int, count: Int) -> Int? {
    guard count > 0 else {
      return nil
    }
    guard let current else {
      return offset > 0 ? 0 : nil
    }
    return min(max(current + offset, 0), count - 1)
  }

  private func openKeyboardSelection() {
    let targets = keyboardTargets
    let index = keyboardSelection ?? 0
    guard targets.indices.contains(index) else {
      return
    }
    navigationPath.append(targets[index])
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
  Text(verbatim: verb.infinitiv.inUserRegion)
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
    .accessibilityIdentifier("verb_row_\(verb.infinitiv)")
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
    .accessibilityIdentifier("verb_row_\(verb.infinitiv)")
  }
}

#Preview {
  VerbBrowseView()
}
