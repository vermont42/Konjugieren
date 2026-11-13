// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct VerbBrowseView: View {
  @Bindable var world = Current
  @State private var listMode: VerbListMode = .frequency
  @State private var sortedVerbs: [Verb] = Verb.verbsSortedByFrequency
  @State private var searchText: String = ""
  @State private var navigationPath = NavigationPath()
  @State private var keyboardSelection: Int?
  @State private var addressWasCopied = false
  @State private var searchTracker = SearchTracker()
  @State private var resultsCache = SearchResultsCache()
  @State private var separableVerbsAreShown = false
  @State private var verbToUnstar: Verb?
  @State private var searchIsEngaged = false
  @State private var searchFocusLostAt: Date?
  @FocusState private var searchIsFocused: Bool
  @Environment(\.horizontalSizeClass) private var sizeClass
  @Environment(\.scenePhase) private var scenePhase
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

  private var isSearching: Bool {
    !trimmedSearchText.isEmpty
  }

  private var searchResults: VerbSearchResults {
    isSearching ? resultsCache.results(for: trimmedSearchText, includeGlosses: searchIncludesGlosses) : .empty
  }

  private var learnerVerbs: LearnerVerbStore { Current.learnerVerbs }

  /// The verbs last opened, shown while the field is focused and empty, before anything is typed.
  private var showsRecents: Bool {
    searchIsEngaged && !isSearching && !learnerVerbs.recentVerbs.isEmpty
  }

  // Hack: on iPad, a tap outside an empty search field ends the search at touch-down, before the
  // tap completes. Views that followed the focus (the recent verbs, the letter row) vanished
  // under the finger, so tapping a recent verb or ä did nothing. They follow this instead, which
  // lets go of the focus a moment later. See also pushFromSearch.
  private func searchFocusChanged() {
    guard !searchIsFocused else {
      searchIsEngaged = true
      searchFocusLostAt = nil
      return
    }
    searchFocusLostAt = .now
    Task {
      try? await Task.sleep(for: Self.searchLingering)
      if !searchIsFocused {
        searchIsEngaged = false
      }
    }
  }

  private static let searchLingering = Duration.milliseconds(700)

  // A tap that ends an empty search on iPad would push while the search is still animating away,
  // and UIKit drops such a push; see ViewControllerTransitions. A typed search does not end on
  // that tap, and on iPhone nothing is animating, so both push at once.
  private func pushFromSearch(_ destination: VerbDestination) {
    guard !isSearching, searchFocusLostAt != nil else {
      navigationPath.append(destination)
      return
    }
    Task {
      await ViewControllerTransitions.waitUntilIdle()
      navigationPath.append(destination)
    }
  }

  // On iPad a key's tap ends an empty search, and the search clears its text as it goes, so a
  // letter set meanwhile is lost or shows in the results but not the field. The letter waits for
  // the search to be gone, then reopens it, as a search request from outside the app does.
  private func insertLetter(_ letter: String) {
    guard !searchIsFocused else {
      searchText.append(letter)
      return
    }
    Task {
      await ViewControllerTransitions.waitUntilIdle()
      searchText.append(letter)
      searchIsFocused = true
    }
  }

  private var showsMyVerbs: Bool {
    listMode == .myVerbs && !isSearching && !showsRecents
  }

  private var entries: [VerbSearchResults.Entry] {
    guard isSearching else {
      if showsMyVerbs {
        return []
      }
      let verbs = showsRecents ? learnerVerbs.recentVerbs : sortedVerbs
      return verbs.map { .hit(VerbSearchResults.Hit(verb: $0, kind: nil, conjugation: nil), isInSeparableVerbs: false) }
    }
    return searchResults.entries(separableVerbsAreShown: separableVerbsAreShown)
  }

  /// The source of a row opened with the field empty. Settled as the row is drawn, because a tap
  /// can take the focus from the field, and with it the recents, before the row's action runs.
  private var browseSource: AnalyticsSource {
    showsRecents ? .recent : .browse
  }

  private var conjugationgroupLang: ConjugationgroupLang {
    settings.conjugationgroupLang
  }

  var body: some View {
    let results = searchResults
    let entries = self.entries
    let browseSource = self.browseSource
    NavigationStack(path: $navigationPath) {
      VStack(spacing: 0) {
        // My Verbs is a List of its own, because only a List's rows can be swiped to delete.
        if showsMyVerbs {
          myVerbsList
        } else {
          ScrollViewReader { proxy in
            ScrollView {
              TipView(tryQuizTip)
                .padding(.horizontal)

              if entries.isEmpty {
                ContentUnavailableView(L.VerbBrowse.noVerbsFound, systemImage: "magnifyingglass")
                  .onAppear {
                    Current.soundPlayer.play(.randomSadTrombone)
                  }

                failedSearchHelp(guess: results.guess)
              } else {
                if showsRecents {
                  listHeading(L.MyVerbs.recent)
                    .accessibilityIdentifier("recent_verbs_heading")
                } else {
                  listHeading(L.VerbBrowse.verbCount(isSearching ? results.matchCount : sortedVerbs.count))
                    .accessibilityIdentifier("verb_browse_anchor")
                }

                if sizeClass == .regular {
                  LazyVGrid(columns: [GridItem(.adaptive(minimum: Layout.verbGridMinimum))], spacing: 0) {
                    ForEach(Self.gridSections(of: entries), id: \.first?.offset) { section in
                      if let header = section.first, case .separableVerbs(let hits) = header.element {
                        Section {
                          ForEach(section.dropFirst(), id: \.element.id) { index, entry in
                            gridCell(entry, at: index, browseSource: browseSource)
                          }
                        } header: {
                          separableVerbsRow(hits, at: header.offset)
                        }
                      } else {
                        Section {
                          ForEach(section, id: \.element.id) { index, entry in
                            gridCell(entry, at: index, browseSource: browseSource)
                          }
                        }
                      }
                    }
                  }
                  .padding(.horizontal)
                } else {
                  LazyVStack(spacing: 0) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                      Group {
                        switch entry {
                        case .hit(let hit, let isInSeparableVerbs):
                          VerbRowView(verb: hit.verb, match: hit.conjugation, conjugationgroupLang: conjugationgroupLang, isIndented: isInSeparableVerbs) {
                            openResult(hit, at: index, browseSource: browseSource)
                          }
                        case .separableVerbs(let hits):
                          SeparableVerbsRow(hits: hits, isShown: separableVerbsAreShown, toggle: toggleSeparableVerbs)
                        }
                      }
                      .background(rowBackground(index: index))

                      Divider()
                        .padding(.leading)
                    }
                  }
                }
              }
            }
            .onChange(of: keyboardSelection) {
              if let keyboardSelection, entries.indices.contains(keyboardSelection) {
                proxy.scrollTo(entries[keyboardSelection].id)
              }
            }
            .onChange(of: listMode) {
              Task { @MainActor in
                if listMode.sortOrder != nil, let firstVerb = sortedVerbs.first {
                  proxy.scrollTo(firstVerb.id, anchor: .top)
                }
              }
            }
          }
        }

        Divider()

        // A keyboard toolbar does not attach to the navigation bar's search field, so the row
        // takes the sort picker's place while the field is focused. Search ranks by frequency
        // whatever the sort order, so the picker has nothing to do then.
        if searchIsEngaged {
          GermanLetterKeyRow { letter in
            insertLetter(letter)
          }
          .padding(.vertical, Layout.defaultSpacing)
        } else {
          Picker(L.VerbBrowse.sortOrder, selection: $listMode) {
            ForEach(VerbListMode.allCases, id: \.self) { mode in
              Text(mode.displayName)
                .tag(mode)
            }
          }
          .pickerStyle(.segmented)
          .padding()
          .accessibilityIdentifier("verb_list_mode_picker")
        }
      }
      .sensoryFeedback(.selection, trigger: listMode)
      // Here rather than on the ScrollView, which is absent while My Verbs shows, so that
      // leaving My Verbs for the other order still re-sorts.
      .onChange(of: listMode) {
        withAnimation(.easeInOut(duration: 0.3)) {
          updateSortedVerbs()
        }
      }
      .onAppear {
        Current.analytics.signal(name: .viewVerbBrowseView)
        Current.reviewPrompter.promptableActionHappened()
        // A deeplink that switched to this tab can arrive before the tab first appears, when
        // no onChange below is yet watching.
        openRequestedVerb()
        openRequestedSearch()
      }
      .navigationTitle(L.Navigation.verbs)
      .navigationDestination(for: VerbDestination.self) { destination in
        // A deeplink replaces the path with a one-verb path, which reuses this destination's
        // identity, so without the id a VerbView kept the previous verb's selected reading.
        VerbView(verb: destination.verb, source: destination.source, marks: destination.marks)
          .id(destination)
      }
      .navigationDestination(for: RelatedVerbListDestination.self) { destination in
        RelatedVerbListView(destination: destination)
      }
      .navigationDestination(for: BrowseableFamily.self) { family in
        FamilyDetailView(family: family) { verb in navigationPath.append(VerbDestination(verb: verb, source: .family)) }
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
        searchFocusChanged()
        if searchIsFocused {
          VerbSearchArrowKeys.install { offset in
            moveKeyboardSelection(by: offset)
          }
        } else {
          VerbSearchArrowKeys.uninstall()
          searchTracker.fieldClosed()
        }
      }
      .onChange(of: searchText) {
        keyboardSelection = nil
        separableVerbsAreShown = false
        if let search = searchTracker.textChanged(to: searchText) {
          signalEndedSearch(search)
        }
      }
      .onChange(of: scenePhase) {
        if scenePhase == .background, let search = searchTracker.finish() {
          signalEndedSearch(search)
        }
      }
      .onChange(of: world.searchRequest) {
        openRequestedSearch()
      }
      .task {
        // Building the index decompresses the map and folds 50,000 conjugations, which the
        // first keystroke should not wait for.
        await Task.detached(priority: .utility) {
          _ = ConjugationIndex.bundled
        }.value
      }
      .onChange(of: world.verb) {
        openRequestedVerb()
      }
    }
    .environment(\.verbPagePush, VerbPagePush { navigationPath.append($0) })
  }

  private func listHeading(_ text: String) -> some View {
    Text(text)
      .font(.caption.smallCaps())
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal)
      .padding(.top, Layout.defaultSpacing)
  }

  /// The starred verbs, then the recent ones not starred. Search ignores this choice, as it
  /// ignores the sort order. A swipe deletes a verb, star and opens alike, so it leaves the list;
  /// a starred verb asks first, since its star was put there on purpose.
  @ViewBuilder
  private var myVerbsList: some View {
    let starred = learnerVerbs.starredVerbs
    let recent = learnerVerbs.recentUnstarredVerbs
    if starred.isEmpty, recent.isEmpty {
      ContentUnavailableView(L.MyVerbs.emptyTitle, systemImage: "star", description: Text(L.MyVerbs.emptyDescription))
        .frame(maxHeight: .infinity)
        .accessibilityIdentifier("my_verbs_empty")
    } else {
      List {
        if !starred.isEmpty {
          Section {
            ForEach(starred) { verb in
              myVerbRow(verb)
                .swipeActions(edge: .trailing) {
                  // Not .destructive: that role removes the row at once, before the learner answers.
                  Button {
                    verbToUnstar = verb
                  } label: {
                    Label(L.MyVerbs.delete, systemImage: "star.slash")
                  }
                  .tint(.customRed)
                }
            }
          } header: {
            myVerbsHeading(L.MyVerbs.starred)
              .accessibilityIdentifier("my_verbs_starred_heading")
          }
        }
        if !recent.isEmpty {
          Section {
            ForEach(recent) { verb in
              myVerbRow(verb)
                .swipeActions(edge: .trailing) {
                  Button(role: .destructive) {
                    withAnimation {
                      learnerVerbs.remove(verb)
                    }
                  } label: {
                    Label(L.MyVerbs.delete, systemImage: "trash")
                  }
                }
            }
          } header: {
            HStack(alignment: .firstTextBaseline) {
              myVerbsHeading(L.MyVerbs.recent)
              Spacer()
              Button(L.MyVerbs.clearRecent) {
                withAnimation {
                  learnerVerbs.clearRecents()
                }
              }
              .font(.caption)
              .buttonStyle(.borderless)
              .accessibilityIdentifier("my_verbs_clear_recent")
            }
          }
        }
      }
      .listStyle(.plain)
      .accessibilityIdentifier("my_verbs_list")
      .alert(
        L.MyVerbs.unstarTitle(verbToUnstar?.infinitiv.inUserRegion ?? ""),
        isPresented: Binding(get: { verbToUnstar != nil }, set: { if !$0 { verbToUnstar = nil } }),
        presenting: verbToUnstar
      ) { verb in
        Button(L.MyVerbs.unstarConfirm, role: .destructive) {
          withAnimation {
            learnerVerbs.remove(verb)
          }
        }
        Button(role: .cancel) {}
      } message: { _ in
        Text(L.MyVerbs.unstarMessage)
      }
    }
  }

  private func myVerbsHeading(_ text: String) -> some View {
    Text(text)
      .font(.caption.smallCaps())
      .foregroundStyle(.secondary)
      .accessibilityAddTraits(.isHeader)
  }

  private func myVerbRow(_ verb: Verb) -> some View {
    VerbRowView(verb: verb) {
      navigationPath.append(VerbDestination(verb: verb, source: .myVerbs))
    }
    .listRowInsets(EdgeInsets())
  }

  private func failedSearchHelp(guess: VerbSearchResults.Hit?) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      if let guess {
        Text(L.VerbBrowse.guessIntro)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .padding(.horizontal)
          .accessibilityIdentifier("search_guess_intro")

        VerbRowView(verb: guess.verb, match: guess.conjugation, conjugationgroupLang: conjugationgroupLang) { openGuess(guess) }
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

  private func openRequestedVerb() {
    guard let verb = world.verb else {
      return
    }
    navigationPath = NavigationPath()
    navigationPath.append(VerbDestination(verb: verb, source: world.verbSource, marks: world.verbMarks))
    world.verb = nil
    world.verbMarks = nil
  }

  /// Text that arrives with the request is shown as results, with the keyboard down so that
  /// they are visible. A request with no text, or with empty text, is for typing, so it focuses
  /// the field.
  private func openRequestedSearch() {
    guard let request = world.searchRequest else {
      return
    }
    world.searchRequest = nil
    if let text = request.text {
      if let ended = searchTracker.fieldOpened(from: request.source) {
        signalEndedSearch(ended)
      }
      searchText = text
      // onChange(of: searchText) does not fire when the text is unchanged, and the request
      // still begins a search.
      _ = searchTracker.textChanged(to: text)
    }
    let wantsKeyboard = request.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    Task {
      await showSearch(focused: wantsKeyboard)
    }
  }

  private func showSearch(focused: Bool) async {
    if !navigationPath.isEmpty {
      navigationPath = NavigationPath()
      // Hack: focus requested while the pop animates sets the focus state without making the
      // field first responder, so typing goes nowhere. Wait out the animation.
      try? await Task.sleep(for: .milliseconds(500))
    }
    searchIsFocused = focused
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

  private func gridSelectionBackground(index: Int) -> some View {
    RoundedRectangle(cornerRadius: Layout.defaultSpacing)
      .fill(index == keyboardSelection ? Color.customRed.opacity(0.2) : Color.clear)
  }

  @ViewBuilder
  private func gridCell(_ entry: VerbSearchResults.Entry, at index: Int, browseSource: AnalyticsSource) -> some View {
    if case .hit(let hit, _) = entry {
      VerbGridCell(verb: hit.verb, match: hit.conjugation, conjugationgroupLang: conjugationgroupLang) { openResult(hit, at: index, browseSource: browseSource) }
        .background(gridSelectionBackground(index: index))
    }
  }

  private func separableVerbsRow(_ hits: [VerbSearchResults.Hit], at index: Int) -> some View {
    SeparableVerbsRow(hits: hits, isShown: separableVerbsAreShown, toggle: toggleSeparableVerbs)
      .background(gridSelectionBackground(index: index))
  }

  /// The grid's entries in runs that each become a section: those before the separable verbs'
  /// row, that row with the verbs it shows, and those after. The row heads its own section,
  /// because a grid cell is too narrow for it and a section header spans the grid. Each entry
  /// keeps its offset in `entries`, which is what the keyboard selection counts.
  nonisolated static func gridSections<Entry>(
    of entries: [Entry],
    isHeader: (Entry) -> Bool,
    isUnderHeader: (Entry) -> Bool
  ) -> [[(offset: Int, element: Entry)]] {
    var sections: [[(offset: Int, element: Entry)]] = []
    var current: [(offset: Int, element: Entry)] = []
    for (offset, entry) in entries.enumerated() {
      let startsSection = isHeader(entry) || (current.first.map { isHeader($0.element) } == true && !isUnderHeader(entry))
      if startsSection, !current.isEmpty {
        sections.append(current)
        current = []
      }
      current.append((offset, entry))
    }
    if !current.isEmpty {
      sections.append(current)
    }
    return sections
  }

  private static func gridSections(of entries: [VerbSearchResults.Entry]) -> [[(offset: Int, element: VerbSearchResults.Entry)]] {
    gridSections(of: entries) { entry in
      if case .separableVerbs = entry {
        return true
      }
      return false
    } isUnderHeader: { entry in
      if case .hit(_, true) = entry {
        return true
      }
      return false
    }
  }

  private func toggleSeparableVerbs() {
    withAnimation {
      separableVerbsAreShown.toggle()
    }
  }

  /// The rows that Return and the arrow keys move through: the entries as shown, or the guess
  /// when a search found nothing.
  private var keyboardTargetCount: Int {
    let count = entries.count
    if count == 0, isSearching, searchResults.guess != nil {
      return 1
    }
    return count
  }

  private func moveKeyboardSelection(by offset: Int) {
    guard navigationPath.isEmpty else {
      return
    }
    keyboardSelection = Self.keyboardSelection(after: keyboardSelection, moving: offset, count: keyboardTargetCount)
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
    let index = keyboardSelection ?? 0
    let entries = self.entries
    if entries.isEmpty, index == 0, let guess = searchResults.guess {
      openGuess(guess)
      return
    }
    guard entries.indices.contains(index) else {
      return
    }
    switch entries[index] {
    case .hit(let hit, _):
      openResult(hit, at: index, browseSource: browseSource)
    case .separableVerbs:
      toggleSeparableVerbs()
    }
  }

  private func openResult(_ hit: VerbSearchResults.Hit, at index: Int, browseSource: AnalyticsSource) {
    guard isSearching, let kind = hit.kind else {
      pushFromSearch(VerbDestination(verb: hit.verb, source: browseSource))
      return
    }
    if let search = searchTracker.finish() {
      signal(.opened(query: search.query, source: search.source, resultCount: searchResults.matchCount, kind: kind, position: index))
    }
    pushFromSearch(VerbDestination(verb: hit.verb, source: .search, marks: hit.conjugation?.marks(on: hit.verb)))
  }

  private func openGuess(_ guess: VerbSearchResults.Hit) {
    if let search = searchTracker.finish() {
      signal(.openedGuess(query: search.query, source: search.source))
    }
    pushFromSearch(VerbDestination(verb: guess.verb, source: .searchGuess, marks: guess.conjugation?.marks(on: guess.verb)))
  }

  private func signalEndedSearch(_ search: SearchTracker.Search) {
    let matches = VerbSearch.matches(for: search.query, in: Verb.verbsSortedByFrequency, includeGlosses: searchIncludesGlosses)
    signal(.ended(query: search.query, source: search.source, matches: matches))
  }

  private func signal(_ report: SearchReport) {
    Current.analytics.signal(name: .finishSearch, parameters: report.parameters)
  }

  private func updateSortedVerbs() {
    switch listMode.sortOrder {
    case .alphabetical:
      sortedVerbs = Verb.verbsSortedAlphabetically
    case .frequency:
      sortedVerbs = Verb.verbsSortedByFrequency
    case nil:
      break
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

/// The line that says what a search matched: "ging: Präteritum Indikativ (ich, er)". The
/// conjugation and the names of its cells are separate elements, because the conjugation is
/// always German and the names follow the conjugationgroup-language setting.
@ViewBuilder
private func matchTexts(_ match: MatchedConjugation?, lang: ConjugationgroupLang, navigate: @escaping () -> Void) -> some View {
  if let match {
    let cellNames = match.cellNames(lang: lang)
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      Text(verbatim: cellNames == nil ? match.shownConjugation : "\(match.shownConjugation): ")
        .fixedSize(horizontal: true, vertical: false)
        .germanPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { navigate() }
      if let cellNames {
        Text(verbatim: cellNames)
          .germanPronunciation(forReal: lang == .german)
          .accessibilityAddTraits(.isButton)
          .accessibilityAction { navigate() }
      }
    }
    .font(.caption)
    .foregroundStyle(Color.customYellow)
  }
}

struct VerbRowView: View {
  let verb: Verb
  var match: MatchedConjugation?
  var conjugationgroupLang: ConjugationgroupLang = .german
  var isIndented = false
  let navigate: () -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        verbNameTexts(verb: verb, navigate: navigate)
        matchTexts(match, lang: conjugationgroupLang, navigate: navigate)
      }
      .padding(.leading, isIndented ? Layout.doubleDefaultSpacing : 0)

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
  let match: MatchedConjugation?
  let conjugationgroupLang: ConjugationgroupLang
  let navigate: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      verbNameTexts(verb: verb, navigate: navigate)
      matchTexts(match, lang: conjugationgroupLang, navigate: navigate)
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

/// One row for the separable verbs in which the query is the part a main clause leaves behind:
/// hielt, of anhalten, aufhalten, and 65 more. Tapping it shows or hides their own rows.
private struct SeparableVerbsRow: View {
  let hits: [VerbSearchResults.Hit]
  let isShown: Bool
  let toggle: () -> Void

  private static let exampleCount = 3

  private var examples: String {
    hits.prefix(Self.exampleCount).compactMap { $0.conjugation?.shownConjugation }.joined(separator: ", ")
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(L.VerbBrowse.separableVerbs(hits.count))
          .tableText()
          .accessibilityAddTraits(.isButton)
          .accessibilityValue(Text(isShown ? L.VerbBrowse.separableVerbsShown : L.VerbBrowse.separableVerbsHidden))
          .accessibilityAction { toggle() }
        Text(verbatim: examples)
          .tableSubtext()
          .germanPronunciation()
          .accessibilityAddTraits(.isButton)
          .accessibilityAction { toggle() }
      }

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundStyle(.secondary)
        .rotationEffect(.degrees(isShown ? 90 : 0))
        .accessibilityHidden(true)
    }
    .contentShape(Rectangle())
    .padding(.horizontal)
    .padding(.vertical, 12)
    .onTapGesture { toggle() }
    .accessibilityIdentifier("separable_verbs_row")
  }
}

/// The last search's results. SwiftUI evaluates the list's body several times per keystroke,
/// and naming a matched conjugation's cells costs a few hundred conjugations.
final class SearchResultsCache {
  private var key: (query: String, includeGlosses: Bool)?
  private var results = VerbSearchResults.empty

  func results(for query: String, includeGlosses: Bool) -> VerbSearchResults {
    if let key, key == (query, includeGlosses) {
      return results
    }
    results = VerbSearchResults(query: query, verbs: Verb.verbsSortedByFrequency, includeGlosses: includeGlosses)
    key = (query, includeGlosses)
    return results
  }
}

#Preview {
  VerbBrowseView()
}
