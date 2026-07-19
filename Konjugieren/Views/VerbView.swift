// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct VerbView: View {
  let verb: Verb
  @Environment(\.horizontalSizeClass) private var sizeClass
  private var settings: Settings { Current.settings }

  private func displayName(for group: Conjugationgroup) -> String {
    group.displayName(lang: settings.conjugationgroupLang)
  }

  private var titleIsGerman: Bool {
    settings.conjugationgroupLang == .german
  }

  private func conjugationSection(for groupBuilder: (PersonNumber) -> Conjugationgroup) -> ConjugationSectionView {
    ConjugationSectionView(
      title: displayName(for: groupBuilder(.firstSingular)),
      titleIsGerman: titleIsGerman,
      conjugations: PersonNumber.allCases.map { pn in
        ConjugationRow(pronoun: pn.pronoun, form: conjugate(groupBuilder(pn)))
      }
    )
  }

  var body: some View {
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

          Text(verb.translation)
            .font(.title2)
            .fontDesign(.serif)
            .englishPronunciation()
            .speakOnTap(verb.translation, localeString: UttererLocale.english)

          HStack(spacing: 8) {
            metadataPill(tint: .customYellow) {
              Label(verb.family.displayName, systemImage: "tag")
                .accessibilityLabel(Text(verbatim: verb.family.displayName))
                .englishPronunciation()
            }
            metadataPill(tint: .customRed) {
              Label {
                Text(verbatim: auxiliaryPillText)
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

          if verb.auxiliaryIsRegional {
            Text(L.Region.southernNote(example: southernAuxiliaryExample))
              .font(.caption)
              .foregroundStyle(.secondary)
              .germanPronunciation(forReal: UserLocale.isGerman)
          }

          if verb.prefix != .none || verb.ablautGroup != nil {
            HStack(spacing: 8) {
              if case .separable = verb.prefix {
                metadataPill(tint: .customRed) {
                  Label(L.BrowseableFamily.separable, systemImage: "arrow.left.arrow.right")
                }
              } else if case .inseparable = verb.prefix {
                metadataPill(tint: .customRed) {
                  Label(L.BrowseableFamily.inseparable, systemImage: "link")
                }
              }

              if let ablautGroup = verb.ablautGroup {
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

        if sizeClass == .regular {
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 20) {
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
          .padding(.horizontal)
        }
      }
      .padding(.vertical)
    }
    .onAppear { Current.analytics.signal(name: .viewVerbView) }
    .navigationTitle(verb.infinitiv.inUserRegion)
    .navigationBarTitleDisplayMode(.inline)
    .userActivity(World.viewVerbActivityType) { activity in
      activity.title = verb.infinitiv
      activity.isEligibleForHandoff = true
      activity.userInfo = ["infinitiv": verb.infinitiv]
    }
  }

  @ViewBuilder
  private var conjugationSections: some View {
    ConjugationSectionView(
      title: displayName(for: .perfektpartizip),
      titleIsGerman: titleIsGerman,
      conjugations: [conjugate(.perfektpartizip)]
    )

    ConjugationSectionView(
      title: displayName(for: .präsenspartizip),
      titleIsGerman: titleIsGerman,
      conjugations: [conjugate(.präsenspartizip)]
    )

    conjugationSection(for: Conjugationgroup.präsensIndikativ)
    conjugationSection(for: Conjugationgroup.präteritumIndikativ)
    conjugationSection(for: Conjugationgroup.präsensKonjunktivI)
    conjugationSection(for: Conjugationgroup.präteritumKonjunktivII)

    ConjugationSectionView(
      title: displayName(for: .imperativ(.secondSingular)),
      titleIsGerman: titleIsGerman,
      conjugations: imperativConjugations()
    )

    conjugationSection(for: Conjugationgroup.perfektIndikativ)
    conjugationSection(for: Conjugationgroup.perfektKonjunktivI)
    conjugationSection(for: Conjugationgroup.plusquamperfektIndikativ)
    conjugationSection(for: Conjugationgroup.plusquamperfektKonjunktivII)
    conjugationSection(for: Conjugationgroup.futurIndikativ)
    conjugationSection(for: Conjugationgroup.futurKonjunktivI)
    conjugationSection(for: Conjugationgroup.futurKonjunktivII)
  }

  // A verb whose auxiliary is regionally conditioned shows both forms with their flags, so
  // that a user learns the other exists rather than seeing only whichever the setting picked.
  // The setting still decides which auxiliary the conjugation table and the quiz use.
  private var auxiliaryPillText: String {
    guard verb.auxiliaryIsRegional else {
      return verb.auxiliary.verb
    }
    let north = Region.north
    let south: [Region] = [.austria, .switzerland]
    let southFlags = south.map(\.flag).joined()
    return "\(verb.regionalAuxiliary(in: north).verb) \(north.flag)  ·  \(verb.regionalAuxiliary(in: .austria).verb) \(southFlags)"
  }

  // VoiceOver must not read the flags as "flag of Germany, flag of Austria" mid-verb, so the
  // spoken label names the varieties instead of showing the glyphs.
  private var auxiliaryAccessibilityLabel: String {
    verb.auxiliaryIsRegional ? L.Region.auxiliaryVariesLabel : verb.auxiliary.verb
  }

  // A concrete example of the sein-Perfekt for the southern-German note, e.g. "ist gestanden".
  // Forced to a sein-writing region so the example shows sein regardless of the user's setting;
  // the northern user reading this is precisely the one who needs to see what the other form is.
  private var southernAuxiliaryExample: String {
    RegionalConjugator.conjugateUnsafely(
      infinitiv: verb.infinitiv,
      conjugationgroup: .perfektIndikativ(.thirdSingular),
      region: .austria
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
    switch RegionalConjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: group) {
    case .success(let form):
      return form
    case .failure:
      return "—"
    }
  }

  private func imperativConjugations() -> [ConjugationRow] {
    PersonNumber.imperativPersonNumbers.map { personNumber in
      let form = conjugate(.imperativ(personNumber))
      switch personNumber {
      case .secondSingular:
        return ConjugationRow(pronoun: "du", form: form)
      case .secondPlural:
        return ConjugationRow(pronoun: "ihr", form: form)
      case .firstPlural, .thirdPlural:
        return ConjugationRow(pronoun: nil, form: form)
      case .firstSingular, .thirdSingular:
        return ConjugationRow(pronoun: personNumber.pronoun, form: form)
      }
    }
  }
}

struct ConjugationRow: Identifiable {
  let pronoun: String?
  let form: String

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

  var speechText: String {
    let spokenForm = form.lowercased()
    if let pronoun {
      return "\(pronoun) \(spokenForm)"
    }
    return spokenForm
  }

  init(pronoun: String? = nil, form: String) {
    self.pronoun = pronoun
    self.form = form
  }
}

struct ConjugationSectionView: View {
  let title: String
  let titleIsGerman: Bool
  let conjugations: [ConjugationRow]

  init(title: String, titleIsGerman: Bool = true, conjugations: [String]) {
    self.title = title
    self.titleIsGerman = titleIsGerman
    self.conjugations = conjugations.map { ConjugationRow(form: $0) }
  }

  init(title: String, titleIsGerman: Bool = true, conjugations: [ConjugationRow]) {
    self.title = title
    self.titleIsGerman = titleIsGerman
    self.conjugations = conjugations
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline.smallCaps().weight(.semibold))
        .fontDesign(.serif)
        .foregroundStyle(.primary)
        .accessibilityAddTraits(.isHeader)
        .germanPronunciation(forReal: titleIsGerman)

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
          .accessibilityElement(children: .combine)
          .accessibilityLabel(Text(verbatim: row.accessibilityDescription))
          .speakOnTap(row.speechText)
        }
      }
      .padding(.leading, 8)
      .germanPronunciation()
    }
    .konjCardWithAccentBar()
  }
}

#Preview {
  NavigationStack {
    VerbView(verb: Verb(
      infinitiv: "gehen",
      translation: "go",
      family: .strong(ablautGroup: "gehen", ablautStartIndex: 0, ablautEndIndex: 2),
      auxiliary: .sein,
      frequency: 10,
      prefix: .none,
      frequencyIcon: "figure.walk",
      auxiliaryIsRegional: false
    ))
  }
}
