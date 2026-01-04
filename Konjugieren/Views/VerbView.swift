// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct VerbView: View {
  let verb: Verb

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        // Header section
        VStack(alignment: .leading, spacing: 8) {
          Text(verb.translation)
            .font(.title2)

          HStack(spacing: 16) {
            Label(verb.family.displayName, systemImage: "tag")
            Label(verb.auxiliary.verb, systemImage: "arrow.triangle.branch")
          }
          .font(.subheadline)
        }
        .padding(.horizontal)

        Divider()

        // Conjugations
        VStack(alignment: .leading, spacing: 20) {
          // Participles
          ConjugationSectionView(
            title: ConjugationGroup.perfektpartizip.displayName,
            conjugations: [conjugate(.perfektpartizip)]
          )

          ConjugationSectionView(
            title: ConjugationGroup.präsenspartizip.displayName,
            conjugations: [conjugate(.präsenspartizip)]
          )

          // Präsens Indikativ
          ConjugationSectionView(
            title: ConjugationGroup.präsensIndicativ(.firstSingular).displayName,
            conjugations: PersonNumber.allCases.map { pn in
              ConjugationRow(pronoun: pn.pronoun, form: conjugate(.präsensIndicativ(pn)))
            }
          )

          // Präteritum Indikativ
          ConjugationSectionView(
            title: ConjugationGroup.präteritumIndicativ(.firstSingular).displayName,
            conjugations: PersonNumber.allCases.map { pn in
              ConjugationRow(pronoun: pn.pronoun, form: conjugate(.präteritumIndicativ(pn)))
            }
          )

          // Präsens Konjunktiv I
          ConjugationSectionView(
            title: ConjugationGroup.präsensKonjunktivI(.firstSingular).displayName,
            conjugations: PersonNumber.allCases.map { pn in
              ConjugationRow(pronoun: pn.pronoun, form: conjugate(.präsensKonjunktivI(pn)))
            }
          )

          // Präteritum Konditional
          ConjugationSectionView(
            title: ConjugationGroup.präteritumKonditional(.firstSingular).displayName,
            conjugations: PersonNumber.allCases.map { pn in
              ConjugationRow(pronoun: pn.pronoun, form: conjugate(.präteritumKonditional(pn)))
            }
          )

          // Imperativ
          ConjugationSectionView(
            title: ConjugationGroup.imperativ(.secondSingular).displayName,
            conjugations: imperativConjugations()
          )
        }
        .padding(.horizontal)
      }
      .padding(.vertical)
    }
    .navigationTitle(verb.infinitiv)
    .navigationBarTitleDisplayMode(.large)
  }

  private func conjugate(_ group: ConjugationGroup) -> String {
    switch Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationGroup: group) {
    case .success(let form):
      return form
    case .failure:
      return "—"
    }
  }

  private func imperativConjugations() -> [ConjugationRow] {
    PersonNumber.imperativPersonNumbers.map { pn in
      let form = conjugate(.imperativ(pn))
      // For 2s and 2p, we show the pronoun separately
      // For 1p and 3p, the form already includes the pronoun (e.g., "gehen wir")
      switch pn {
      case .secondSingular:
        return ConjugationRow(pronoun: "du", form: form)
      case .secondPlural:
        return ConjugationRow(pronoun: "ihr", form: form)
      case .firstPlural, .thirdPlural:
        // Form already includes pronoun, so don't duplicate it
        return ConjugationRow(pronoun: nil, form: form)
      default:
        return ConjugationRow(pronoun: pn.pronoun, form: form)
      }
    }
  }
}

struct ConjugationRow: Identifiable {
  let id = UUID()
  let pronoun: String?
  let form: String

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
      prefix: .none
    ))
  }
}
