// Copyright © 2025 Josh Adams. All rights reserved.

import AppIntents

struct ConjugateVerbIntent: AppIntent {
  static let title: LocalizedStringResource = "Conjugate a Verb"
  static let description: IntentDescription = "Conjugates a German verb in the selected conjugationgroup."

  @Parameter(title: "Verb")
  var verb: VerbEntity

  @Parameter(title: "Conjugationgroup")
  var conjugationgroup: SiriConjugationgroup

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let table = await MainActor.run {
      let groups = conjugationgroup.conjugationgroups()
      var lines: [String] = []

      for group in groups {
        let result = Conjugator.conjugate(infinitiv: verb.id, conjugationgroup: group)
        switch result {
        case .success(let conjugation):
          let cleaned = conjugation.lowercased()
          switch group {
          case .perfektpartizip, .präsenspartizip:
            lines.append(cleaned)
          default:
            if let personNumber = group.personNumber {
              lines.append("\(personNumber.pronoun) \(cleaned)")
            } else {
              lines.append(cleaned)
            }
          }
        case .failure:
          lines.append("?")
        }
      }

      let groupName = groups.first?.englishDisplayName ?? conjugationgroup.rawValue
      return "\(verb.id) — \(groupName):\n\(lines.joined(separator: "\n"))"
    }
    return .result(dialog: "\(table)")
  }
}

private extension Conjugationgroup {
  var personNumber: PersonNumber? {
    switch self {
    case .perfektpartizip, .präsenspartizip:
      return nil
    case .präsensIndicativ(let pn),
         .präsensKonjunktivI(let pn),
         .präteritumIndicativ(let pn),
         .präteritumKonjunktivII(let pn),
         .imperativ(let pn),
         .perfektIndikativ(let pn),
         .perfektKonjunktivI(let pn),
         .plusquamperfektIndikativ(let pn),
         .plusquamperfektKonjunktivII(let pn),
         .futurIndikativ(let pn),
         .futurKonjunktivI(let pn),
         .futurKonjunktivII(let pn):
      return pn
    }
  }
}
