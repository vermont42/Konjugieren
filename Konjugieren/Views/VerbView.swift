// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct VerbView: View {
  let verb: Verb
  private var settings: Settings { Current.settings }

  private func displayName(for group: Conjugationgroup) -> String {
    switch settings.conjugationgroupLang {
    case .german:
      return group.germanDisplayName
    case .english:
      return group.englishDisplayName
    }
  }

  private func conjugationSection(for groupBuilder: (PersonNumber) -> Conjugationgroup) -> ConjugationSectionView {
    ConjugationSectionView(
      title: displayName(for: groupBuilder(.firstSingular)),
      conjugations: PersonNumber.allCases.map { pn in
        ConjugationRow(pronoun: pn.pronoun, form: conjugate(groupBuilder(pn)))
      }
    )
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
          Text(verb.translation)
            .font(.title2)

          HStack(spacing: 16) {
            Label(verb.family.displayName, systemImage: "tag")
            Label(verb.auxiliary.verb, systemImage: "arrow.triangle.branch")
            Label("#\(verb.frequency)", systemImage: verb.frequencyIcon)
          }
          .font(.subheadline)

          if verb.prefix != .none || verb.ablautGroup != nil {
            HStack(spacing: 16) {
              if case .separable = verb.prefix {
                Label(L.BrowseableFamily.separable, systemImage: "arrow.left.arrow.right")
              } else if case .inseparable = verb.prefix {
                Label(L.BrowseableFamily.inseparable, systemImage: "link")
              }

              if let ablautGroup = verb.ablautGroup {
                Label(ablautGroup, systemImage: "figure.and.child.holdinghands")
              }
            }
            .font(.subheadline)
          }
        }
        .padding(.horizontal)

        Divider()

        VStack(alignment: .leading, spacing: 20) {
          ConjugationSectionView(
            title: displayName(for: .perfektpartizip),
            conjugations: [conjugate(.perfektpartizip)]
          )

          ConjugationSectionView(
            title: displayName(for: .präsenspartizip),
            conjugations: [conjugate(.präsenspartizip)]
          )

          conjugationSection(for: Conjugationgroup.präsensIndicativ)
          conjugationSection(for: Conjugationgroup.präteritumIndicativ)
          conjugationSection(for: Conjugationgroup.präsensKonjunktivI)
          conjugationSection(for: Conjugationgroup.präteritumKonjunktivII)

          ConjugationSectionView(
            title: displayName(for: .imperativ(.secondSingular)),
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
        .padding(.horizontal)
      }
      .padding(.vertical)
    }
    .navigationTitle(verb.infinitiv)
    .navigationBarTitleDisplayMode(.large)
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

  init(pronoun: String? = nil, form: String) {
    self.pronoun = pronoun
    self.form = form
  }
}

struct ConjugationSectionView: View {
  let title: String
  let conjugations: [ConjugationRow]

  init(title: String, conjugations: [String]) {
    self.title = title
    self.conjugations = conjugations.map { ConjugationRow(form: $0) }
  }

  init(title: String, conjugations: [ConjugationRow]) {
    self.title = title
    self.conjugations = conjugations
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.headline)
        .foregroundStyle(.primary)

      VStack(alignment: .leading, spacing: 4) {
        ForEach(conjugations) { row in
          HStack(spacing: 8) {
            if let pronoun = row.pronoun {
              Text(pronoun)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .leading)
            }

            Text(mixedCaseString: row.form)
          }
          .font(.body)
        }
      }
      .padding(.leading, 8)
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
