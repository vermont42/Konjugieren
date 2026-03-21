// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct VerbView: View {
  let verb: Verb
  @Environment(\.horizontalSizeClass) private var sizeClass
  private var settings: Settings { Current.settings }

  private func displayName(for group: Conjugationgroup) -> String {
    switch settings.conjugationgroupLang {
    case .german:
      return group.germanDisplayName
    case .english:
      return group.englishDisplayName
    }
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
          Text(verb.infinitiv)
            .font(.largeTitle)
            .fontWeight(.bold)
            .fontDesign(.serif)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .accessibilityAddTraits(UserLocale.isGerman ? .isHeader : [])
            .germanPronunciation()
            .speakOnTap(verb.infinitiv)

          Text(verb.translation)
            .font(.title2)
            .fontDesign(.serif)
            .englishPronunciation()
            .speakOnTap(verb.translation, localeString: UttererLocale.english)

          HStack(spacing: 8) {
            metadataPill {
              Label(verb.family.displayName, systemImage: "tag")
                .accessibilityLabel(Text(verbatim: verb.family.displayName))
                .englishPronunciation()
            }
            metadataPill {
              Label {
                Text(verbatim: verb.auxiliary.verb)
              } icon: {
                Image(systemName: "arrow.triangle.branch")
              }
              .accessibilityLabel(Text(verbatim: verb.auxiliary.verb))
              .germanPronunciation()
            }
            metadataPill {
              Label("#\(verb.frequency)", systemImage: verb.frequencyIcon)
                .accessibilityLabel(Text(verbatim: "#\(verb.frequency)"))
            }
          }
          .font(.subheadline)

          if verb.prefix != .none || verb.ablautGroup != nil {
            HStack(spacing: 8) {
              if case .separable = verb.prefix {
                metadataPill {
                  Label(L.BrowseableFamily.separable, systemImage: "arrow.left.arrow.right")
                }
              } else if case .inseparable = verb.prefix {
                metadataPill {
                  Label(L.BrowseableFamily.inseparable, systemImage: "link")
                }
              }

              if let ablautGroup = verb.ablautGroup {
                metadataPill {
                  Label(ablautGroup, systemImage: "figure.and.child.holdinghands")
                    .accessibilityLabel(Text(verbatim: ablautGroup))
                    .germanPronunciation()
                    .speakOnTap(ablautGroup)
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
              .font(.headline)
              .foregroundStyle(.primary)
              .accessibilityAddTraits(.isHeader)
              .foregroundStyle(.customYellow)
            RichTextView(blocks: etymologyText.richTextBlocks)
          }
          .padding(.horizontal)
        }

        if let pair = ExampleSentences.pair(for: verb.infinitiv) {
          Divider()
          VStack(alignment: .leading, spacing: 8) {
            Text(L.VerbView.exampleSentenceHeading)
              .font(.headline)
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
          .padding(.horizontal)
        }
      }
      .padding(.vertical)
    }
    .onAppear { Current.analytics.signal(name: .viewVerbView) }
    .navigationTitle(verb.infinitiv)
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

    conjugationSection(for: Conjugationgroup.präsensIndicativ)
    conjugationSection(for: Conjugationgroup.präteritumIndicativ)
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

  private func metadataPill<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    content()
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(Color.customYellow.opacity(0.08))
      .clipShape(Capsule())
  }

  private func conjugate(_ group: Conjugationgroup) -> String {
    switch Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: group) {
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
    .padding()
    .background(Color(.secondarySystemBackground).opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(alignment: .leading) {
      Rectangle()
        .fill(.customYellow.opacity(0.3))
        .frame(width: 2)
        .clipShape(RoundedRectangle(cornerRadius: 1))
    }
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
      frequencyIcon: "figure.walk"
    ))
  }
}
