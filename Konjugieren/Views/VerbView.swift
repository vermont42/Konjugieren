// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct VerbView: View {
  let verb: Verb
  let source: AnalyticsSource
  let marks: MarkedConjugations?
  @Environment(\.horizontalSizeClass) private var sizeClass
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.isBeneathQuiz) private var isBeneathQuiz
  @State private var readingIndex = 0
  @State private var visit: VerbVisit?
  @State private var visibleSections: Set<VerbPageSection> = []
  @State private var isOnScreen = false
  @State private var hasAppeared = false
  @State private var article: Info?
  @State private var isTestingVerb = false
  private let redLettersTip = RedLettersTip()
  private let scrollToBottomTip = ScrollToBottomTip()
  private var settings: Settings { Current.settings }

  init(verb: Verb, source: AnalyticsSource, marks: MarkedConjugations? = nil) {
    self.verb = verb
    self.source = source
    self.marks = marks
    _readingIndex = State(initialValue: marks?.readingIndex ?? 0)
  }

  /// The reading the screen is currently showing. Every piece of metadata below (family,
  /// auxiliary, prefix, ablaut group) belongs to the reading rather than to the verb,
  /// because hängen is strong in one reading and weak in the other.
  private var reading: Reading {
    verb.reading(at: readingIndex) ?? verb.primaryReading
  }

  private var titleIsGerman: Bool {
    settings.conjugationgroupLang == .german
  }

  private func isMarked(_ group: Conjugationgroup) -> Bool {
    guard let marks, marks.readingIndex == readingIndex else {
      return false
    }
    return marks.conjugationgroups.contains(group)
  }

  /// The section of the first marked cell, which the page scrolls to when it opens.
  private var markedSectionID: String? {
    guard let marks else {
      return nil
    }
    return Conjugationgroup.allCells.first { marks.conjugationgroups.contains($0) }?.table.scrollID
  }

  /// Whether any conjugation on the page has a red letter, which the Conjugator marks by
  /// writing it in uppercase. `RedLettersTip` has nothing to explain on a page without one.
  private var hasRedLetters: Bool {
    Conjugationgroup.allCells.contains { conjugate($0).contains(where: \.isUppercase) }
  }

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          VStack(alignment: .leading, spacing: 8) {
            Text(verb.infinitiv.inUserRegion)
              .font(.largeTitle)
              .fontWeight(.bold)
              .fontDesign(.serif)
              .minimumScaleFactor(0.5)
              .accessibilityAddTraits(UserLocale.isGerman ? .isHeader : [])
              .germanPronunciation()
              .speakOnTap(verb.infinitiv.inUserRegion)
              .copyOnLongPress(verb.infinitiv.inUserRegion)

            // The picker's segments already carry the glosses, so a separate translation line
            // would print the selected one twice.
            if verb.hasMultipleReadings {
              readingPicker
            } else {
              Text(reading.translation)
                .font(.title2)
                .fontDesign(.serif)
                .englishPronunciation()
                .speakOnTap(reading.translation, localeString: UttererLocale.english)
            }

            HStack(spacing: 8) {
              metadataPill(tint: .customYellow) {
                Label(reading.family.displayName, systemImage: "tag")
                  .accessibilityLabel(Text(verbatim: reading.family.displayName))
                  .englishPronunciation()
              }
              metadataPill(tint: .customRed) {
                Label {
                  EmojiAsset.text(substitutingIn: auxiliaryPillText)
                } icon: {
                  Image(systemName: "arrow.triangle.branch")
                }
                .accessibilityLabel(Text(verbatim: auxiliaryAccessibilityLabel))
                .germanPronunciation()
              }
              metadataPill(tint: .customYellow) {
                Label("#\(verb.frequency)", systemImage: verb.frequencyIcon)
                  .accessibilityLabel(Text(verbatim: "#\(verb.frequency)"))
              }
            }
            .font(.subheadline)

            if reading.auxiliaryIsRegional {
              Text(L.Region.southernNote(example: southernAuxiliaryExample))
                .font(.caption)
                .foregroundStyle(.secondary)
                .germanPronunciation(forReal: UserLocale.isGerman)
            }

            if reading.prefix != .none || reading.ablautGroup != nil {
              HStack(spacing: 8) {
                if case .separable = reading.prefix {
                  metadataPill(tint: .customRed) {
                    Label(L.BrowseableFamily.separable, systemImage: "arrow.left.arrow.right")
                  }
                } else if case .inseparable = reading.prefix {
                  metadataPill(tint: .customRed) {
                    Label(L.BrowseableFamily.inseparable, systemImage: "link")
                  }
                }

                if let ablautGroup = reading.ablautGroup {
                  metadataPill(tint: .customYellow, bordered: true) {
                    Label(ablautGroup.inUserRegion, systemImage: "figure.and.child.holdinghands")
                      .accessibilityLabel(Text(verbatim: ablautGroup.inUserRegion))
                      .germanPronunciation()
                      .speakOnTap(ablautGroup.inUserRegion)
                  }
                }
              }
              .font(.subheadline)
            }
          }
          .padding(.horizontal)

          Divider()

          if hasRedLetters {
            TipView(redLettersTip)
              .padding(.horizontal)
          }
          TipView(scrollToBottomTip)
            .padding(.horizontal)

          if sizeClass == .regular {
            LazyVGrid(columns: [GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top)], alignment: .leading, spacing: 20) {
              conjugationSections
            }
            .padding(.horizontal)
          } else {
            VStack(alignment: .leading, spacing: 20) {
              conjugationSections
            }
            .padding(.horizontal)
          }

          if let etymologyText = Etymology.text(for: verb.infinitiv) {
            Divider()
            VStack(alignment: .leading, spacing: 8) {
              Text(L.VerbView.etymologyHeading)
                .font(.subheadline.smallCaps().weight(.semibold))
                .fontDesign(.serif)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
                .foregroundStyle(.customYellow)
              RichTextView(blocks: etymologyText.richTextBlocks)
            }
            .konjCardWithAccentBar()
            .onScrollVisibilityChange(threshold: Self.sectionVisibilityThreshold) { isVisible in
              sectionVisibilityChanged(.etymology, isVisible: isVisible)
            }
            .padding(.horizontal)
          }

          if let pair = ExampleSentences.pair(for: verb.infinitiv) {
            Divider()
            VStack(alignment: .leading, spacing: 8) {
              Text(L.VerbView.exampleSentenceHeading)
                .font(.subheadline.smallCaps().weight(.semibold))
                .fontDesign(.serif)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
                .foregroundStyle(.customYellow)

              Text(pair.german.sentence)
                .font(.body)
                .italic()
                .germanPronunciation()

              Text(pair.english.sentence)
                .font(.body)
                .italic()
                .englishPronunciation()

              Text("— \(pair.german.source)")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .konjCardWithAccentBar()
            .onScrollVisibilityChange(threshold: Self.sectionVisibilityThreshold) { isVisible in
              sectionVisibilityChanged(.example, isVisible: isVisible)
            }
            .padding(.horizontal)
          }

          Divider()
          RelatedVerbsView(related: verb.related(readingIndex: readingIndex))
            .padding(.horizontal)
        }
        .padding(.vertical)
      }
      .onAppear {
        if !hasAppeared, let markedSectionID {
          Task {
            proxy.scrollTo(markedSectionID, anchor: .top)
          }
        }
        isOnScreen = true
        beginVisit(source: hasAppeared ? .resume : source)
        hasAppeared = true
        unlockScrollTipIfDue()
      }
    }
    .sheet(item: $article) { info in
      ConjugationgroupArticleSheet(info: info)
    }
    .sheet(isPresented: $isTestingVerb) {
      QuizSheet(scope: .verbPage(verb, readingIndex: readingIndex))
    }
    .onDisappear {
      isOnScreen = false
      endVisit()
    }
    .onChange(of: scenePhase) {
      switch scenePhase {
      case .background:
        endVisit()
      case .active:
        if isOnScreen {
          beginVisit(source: .resume)
        }
      default:
        break
      }
    }
    .navigationTitle(verb.infinitiv.inUserRegion)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      // A page opened from a quiz's held correction starts no second quiz over the first.
      if !isBeneathQuiz {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            Current.analytics.signal(name: .tapTestVerb)
            isTestingVerb = true
          } label: {
            Label(L.VerbView.testMe, systemImage: "pencil.and.list.clipboard")
          }
          .accessibilityIdentifier("verb_test_button")
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        let isStarred = Current.learnerVerbs.isStarred(verb)
        Button {
          let isNowStarred = Current.learnerVerbs.toggleStar(verb)
          Current.analytics.signal(name: .tapStarVerb, parameters: [
            ParameterKey.starred.rawValue: "\(isNowStarred)"
          ])
        } label: {
          Label(isStarred ? L.VerbView.unstar : L.VerbView.star, systemImage: isStarred ? "star.fill" : "star")
        }
        .sensoryFeedback(.selection, trigger: isStarred)
        .accessibilityIdentifier("verb_star_button")
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          Current.analytics.signal(name: .tapShareVerb)
          ShareSheet.present(
            text: verb.shareText(readingIndex: readingIndex),
            title: verb.infinitiv.inUserRegion,
            icon: UIImage(named: settings.appIcon.previewAssetName),
            anchorLabel: L.VerbView.share
          )
        } label: {
          Label(L.VerbView.share, systemImage: "square.and.arrow.up")
        }
      }
    }
    .userActivity(World.viewVerbActivityType) { activity in
      activity.title = verb.infinitiv
      activity.isEligibleForHandoff = true
      activity.userInfo = ["infinitiv": verb.infinitiv]
    }
  }

  // A verb whose readings differ in meaning shows one conjugation table at a time, because
  // the readings genuinely inflect differently and showing both at once would invite reading
  // a row from the wrong paradigm.
  //
  // Deliberately not a segmented Picker, for two reasons found by inspection. UISegmentedControl
  // renders every segment on one line and truncates the overflow, and these labels are glosses
  // of arbitrary length: antreten's "take up (office), begin (a journey)" lost half of itself,
  // which defeats the point of naming the readings at all. It also exposed itself to VoiceOver
  // as an AXTabGroup with no children, so the segments could not be reached by label.
  //
  // Capsules sit side by side while they fit on one line each and stack full-width when they do
  // not, so a long gloss wraps instead of truncating. ViewThatFits chooses by measuring the
  // single-line variant, which is why that one pins .lineLimit(1).
  //
  // Nothing accessibility-related belongs on the container. Both a label on the Picker this
  // replaced and an .accessibilityElement(children: .contain) plus .accessibilityLabel here
  // collapsed the whole control into one element named "Meaning", leaving VoiceOver no way to
  // tell the readings apart, the exact failure the control exists to avoid. The buttons name
  // themselves by their glosses and carry .isSelected, which is what a user needs.
  private var readingPicker: some View {
    ViewThatFits(in: .horizontal) {
      HStack(spacing: 8) {
        readingButtons(lineLimit: 1)
      }
      VStack(alignment: .leading, spacing: 8) {
        readingButtons(lineLimit: nil)
      }
    }
    .englishPronunciation()
  }

  @ViewBuilder
  private func readingButtons(lineLimit: Int?) -> some View {
    ForEach(Array(verb.readings.enumerated()), id: \.offset) { index, reading in
      let isSelected = index == readingIndex
      Button {
        readingIndex = index
      } label: {
        Text(verbatim: reading.translation)
          .font(.subheadline)
          .lineLimit(lineLimit)
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
          .foregroundStyle(isSelected ? Color.customBackground : .primary)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(isSelected ? Color.customYellow : Color.customYellow.opacity(0.08))
          .clipShape(Capsule())
          .overlay {
            Capsule().strokeBorder(Color.customYellow.opacity(isSelected ? 0 : 0.4), lineWidth: 1.5)
          }
      }
      .buttonStyle(.plain)
      .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
  }

  // Each stack is one cell of the iPad grid, so the participles sit under the Imperativ there as
  // they do on an iPhone, instead of flowing into the next cell beside it.
  @ViewBuilder
  private var conjugationSections: some View {
    ForEach(ConjugationTable.stacks, id: \.self) { stack in
      VStack(alignment: .leading, spacing: 20) {
        ForEach(stack, id: \.self) { table in
          conjugationSection(for: table)
        }
      }
    }
  }

  @ViewBuilder
  private func conjugationSection(for table: ConjugationTable) -> some View {
    let section = ConjugationSectionView(
      title: table.displayName(lang: settings.conjugationgroupLang),
      titleIsGerman: titleIsGerman,
      secondName: table.secondName(lang: settings.conjugationgroupLang),
      conjugations: rows(for: table),
      openArticle: table.article.map { info in
        {
          Current.analytics.signal(name: .tapConjugationgroupArticle)
          article = info
        }
      }
    )
    .id(table.scrollID)

    if table == Self.firstSimpleTable {
      section.onScrollVisibilityChange(threshold: Self.sectionVisibilityThreshold) { isVisible in
        sectionVisibilityChanged(.simple, isVisible: isVisible)
      }
    } else if table == Self.firstCompoundTable {
      section.onScrollVisibilityChange(threshold: Self.sectionVisibilityThreshold) { isVisible in
        sectionVisibilityChanged(.compound, isVisible: isVisible)
      }
    } else {
      section
    }

  }

  private static let firstSimpleTable = ConjugationTable.allCases.first { !$0.isCompound }
  private static let firstCompoundTable = ConjugationTable.allCases.first { $0.isCompound }

  private func rows(for table: ConjugationTable) -> [ConjugationRow] {
    switch table {
    case .perfektpartizip, .präsenspartizip:
      return table.cells.map { ConjugationRow(form: conjugate($0), isMarked: isMarked($0)) }
    case .imperativ:
      return imperativConjugations()
    case .präsensIndikativ, .präteritumIndikativ, .präteritumKonjunktivII, .präsensKonjunktivI, .perfektIndikativ, .futurIndikativ,
      .plusquamperfektIndikativ, .futurKonjunktivII, .plusquamperfektKonjunktivII, .perfektKonjunktivI, .futurKonjunktivI:
      return table.cells.map { cell in
        ConjugationRow(pronoun: cell.personNumber?.pronoun, form: conjugate(cell), isMarked: isMarked(cell))
      }
    }
  }

  // The scroll tip waits for a page visit after the red-letter tip was closed, rather than
  // replacing it in place the moment it closes. It is pointless for a learner who already
  // scrolls to the bottom, so reaching the etymology or the example retires it. With tips
  // switched off for screenshots and video, TipKit is never configured, so this leaves its
  // datastore alone.
  private func unlockScrollTipIfDue() {
    guard TipDisplay.tipsEnabled else {
      return
    }
    if case .invalidated = redLettersTip.status {
      ScrollToBottomTip.isUnlocked = true
    }
  }

  // A third of a block's first card on screen counts as reaching the block. A higher threshold
  // could never be met by an etymology card taller than the screen.
  private static let sectionVisibilityThreshold = 0.3

  private func beginVisit(source: AnalyticsSource) {
    guard visit == nil else {
      return
    }
    let newVisit = VerbVisit(source: source, start: .now, visibleSections: visibleSections)
    visit = newVisit
    if source != .resume {
      Current.learnerVerbs.recordOpen(verb, source: source)
    }
    Current.analytics.signal(name: .viewVerbView, parameters: newVisit.viewParameters)
  }

  private func endVisit() {
    guard let visit else {
      return
    }
    Current.analytics.signal(name: .leaveVerbView, parameters: visit.leaveParameters(end: .now))
    self.visit = nil
  }

  private func sectionVisibilityChanged(_ section: VerbPageSection, isVisible: Bool) {
    if isVisible {
      visibleSections.insert(section)
      visit?.reach(section)
      if section >= .etymology, TipDisplay.tipsEnabled {
        scrollToBottomTip.invalidate(reason: .actionPerformed)
      }
    } else {
      visibleSections.remove(section)
    }
  }

  // A verb whose auxiliary is regionally conditioned shows both forms with their flags, so
  // that a user learns the other exists rather than seeing only whichever the setting picked.
  // The setting still decides which auxiliary the conjugation table and the quiz use.
  private var auxiliaryPillText: String {
    guard reading.auxiliaryIsRegional else {
      return reading.auxiliary.verb
    }
    let north = Region.north
    let south: [Region] = [.austria, .switzerland]
    let southFlags = south.map(\.flag).joined()
    return "\(reading.regionalAuxiliary(in: north).verb) \(north.flag)  ·  \(reading.regionalAuxiliary(in: .austria).verb) \(southFlags)"
  }

  // VoiceOver must not read the flags as "flag of Germany, flag of Austria" mid-verb, so the
  // spoken label names the varieties instead of showing the glyphs.
  private var auxiliaryAccessibilityLabel: String {
    reading.auxiliaryIsRegional ? L.Region.auxiliaryVariesLabel : reading.auxiliary.verb
  }

  // A concrete example of the sein-Perfekt for the southern-German note, e.g. "ist gestanden".
  // Forced to a sein-writing region so the example shows sein regardless of the user's setting;
  // the northern user reading this is precisely the one who needs to see what the other form is.
  private var southernAuxiliaryExample: String {
    RegionalConjugator.conjugateUnsafely(
      infinitiv: verb.infinitiv,
      conjugationgroup: .perfektIndikativ(.thirdSingular),
      region: .austria,
      readingIndex: readingIndex
    ).lowercased()
  }

  private func metadataPill<Content: View>(
    tint: Color = .customYellow,
    bordered: Bool = false,
    @ViewBuilder content: () -> Content
  ) -> some View {
    content()
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(tint.opacity(0.08))
      .overlay {
        if bordered {
          Capsule().strokeBorder(tint.opacity(0.4), lineWidth: 1.5)
        }
      }
      .clipShape(Capsule())
  }

  private func conjugate(_ group: Conjugationgroup) -> String {
    switch RegionalConjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: group, readingIndex: readingIndex) {
    case .success(let form):
      return form
    case .failure:
      return ConjugationRow.unavailable
    }
  }

  private func imperativConjugations() -> [ConjugationRow] {
    PersonNumber.imperativPersonNumbers.map { personNumber in
      let form = conjugate(.imperativ(personNumber))
      let isMarked = isMarked(.imperativ(personNumber))
      switch personNumber {
      case .secondSingular:
        return ConjugationRow(pronoun: "du", form: form, isMarked: isMarked)
      case .secondPlural:
        return ConjugationRow(pronoun: "ihr", form: form, isMarked: isMarked)
      case .firstPlural, .thirdPlural:
        return ConjugationRow(pronoun: nil, form: form, isMarked: isMarked)
      case .firstSingular, .thirdSingular:
        return ConjugationRow(pronoun: personNumber.pronoun, form: form, isMarked: isMarked)
      }
    }
  }
}

struct ConjugationRow: Identifiable {
  let pronoun: String?
  let form: String

  /// True for a cell that the search which opened the page matched.
  let isMarked: Bool

  var id: String {
    "\(pronoun ?? ""):\(form)"
  }

  var accessibilityDescription: String {
    let formLabel = MixedCaseAccessibility.accessibilityLabel(for: form)
    if let pronoun {
      return "\(pronoun) \(formLabel)"
    }
    return formLabel
  }

  /// What a long press copies: the conjugation alone, in lowercase, since the capitals only
  /// mark the red letters. Nothing for a cell the Conjugator could not fill.
  var copyText: String? {
    form == Self.unavailable ? nil : form.lowercased()
  }

  static let unavailable = "—"

  var speechText: String {
    let spokenForm = form.lowercased()
    if let pronoun {
      return "\(pronoun) \(spokenForm)"
    }
    return spokenForm
  }

  init(pronoun: String? = nil, form: String, isMarked: Bool = false) {
    self.pronoun = pronoun
    self.form = form
    self.isMarked = isMarked
  }
}

struct ConjugationSectionView: View {
  let title: String
  let titleIsGerman: Bool
  let secondName: ConjugationTable.SecondName?
  let conjugations: [ConjugationRow]

  /// Opens the conjugationgroup's Info article. Nil hides the button.
  let openArticle: (() -> Void)?

  init(
    title: String,
    titleIsGerman: Bool = true,
    secondName: ConjugationTable.SecondName? = nil,
    conjugations: [ConjugationRow],
    openArticle: (() -> Void)? = nil
  ) {
    self.title = title
    self.titleIsGerman = titleIsGerman
    self.secondName = secondName
    self.conjugations = conjugations
    self.openArticle = openArticle
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .top, spacing: 8) {
        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.subheadline.smallCaps().weight(.semibold))
            .fontDesign(.serif)
            .foregroundStyle(.primary)
            .accessibilityAddTraits(.isHeader)
            .germanPronunciation(forReal: titleIsGerman)

          // VoiceOver hears only the name, in its own language: "also" in the learner's
          // language and Partizip II in German cannot share one element's voice.
          if let secondName {
            Text(L.VerbView.secondName(secondName.text))
              .font(.caption)
              .foregroundStyle(.secondary)
              .accessibilityLabel(Text(verbatim: secondName.text))
              .germanPronunciation(forReal: secondName.isGerman)
          }
        }

        Spacer(minLength: 0)

        if let openArticle {
          Button(action: openArticle) {
            Image(systemName: "info.circle")
              .font(.body)
              .foregroundStyle(.customYellow)
              .frame(minWidth: 44, minHeight: 44, alignment: .topTrailing)
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .padding(.top, -6)
          .accessibilityLabel(Text(L.VerbView.openArticle))
        }
      }

      VStack(alignment: .leading, spacing: 4) {
        ForEach(conjugations) { row in
          HStack(spacing: 8) {
            if let pronoun = row.pronoun {
              Text(verbatim: pronoun)
                .foregroundStyle(.secondary)
                .frame(width: Layout.pronounColumnWidth, alignment: .leading)
            }

            Text(mixedCaseString: row.form)
          }
          .font(.body)
          .background {
            if row.isMarked {
              RoundedRectangle(cornerRadius: 6)
                .fill(Color.customYellow.opacity(0.25))
                .padding(-4)
            }
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel(Text(verbatim: row.accessibilityDescription))
          .accessibilityValue(Text(verbatim: row.isMarked ? L.VerbView.matchesSearch : ""))
          .speakOnTap(row.speechText)
          .copyOnLongPress(row.copyText)
        }
      }
      .padding(.leading, 8)
      .germanPronunciation()
    }
    .konjCardWithAccentBar()
  }
}

/// A conjugationgroup's Info article, opened from its heading on the verb page. A link to
/// another article opens that article here, so the learner can follow the thread and still
/// close the sheet onto the same verb page. A link to a verb closes the sheet and opens the verb
/// in the Verbs tab, as an article in the Info tab does.
private struct ConjugationgroupArticleSheet: View {
  let info: Info
  @Environment(\.dismiss) private var dismiss
  @State private var path: [Info] = []

  var body: some View {
    NavigationStack(path: $path) {
      article(info)
        .navigationDestination(for: Info.self) { next in
          article(next)
        }
    }
  }

  private func article(_ info: Info) -> some View {
    InfoView(info: info, openLink: open)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(L.Navigation.dismiss) {
            dismiss()
          }
        }
      }
  }

  private func open(_ url: URL) {
    if
      url.host == URL.infoHost,
      let info = url.pathComponents.dropFirst().first.flatMap(Info.info(deeplinkTarget:))
    {
      path.append(info)
      return
    }
    dismiss()
    // The verb page that presented this sheet is about to be replaced, and SwiftUI drops a
    // navigation change made while a sheet is still animating away.
    Task {
      try? await Task.sleep(for: .milliseconds(400))
      Current.handleURL(url)
    }
  }
}

#Preview {
  NavigationStack {
    VerbView(verb: Verb(
      infinitiv: "gehen",
      hits: 10_000_000,
      hitsAreProvisional: false,
      frequency: 10,
      frequencyIcon: "figure.walk",
      readings: [
        Reading(
          infinitiv: "gehen",
          translation: "go",
          family: .strong(ablautGroup: "gehen", ablautStartIndex: 0, ablautEndIndex: 2),
          auxiliary: .sein,
          prefixes: [],
          auxiliaryIsRegional: false
        )
      ]
    ), source: .browse)
  }
}
