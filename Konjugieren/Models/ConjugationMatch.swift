// Copyright © 2026 Josh Adams. All rights reserved.

/// A cell of a verb's conjugation tables whose conjugation equals a given text. Search names a
/// result with these (ging: Präteritum Indikativ, ich and er, of gehen), and the quiz can use
/// them to tell a learner which other cell an answer belongs to.
struct ConjugationMatch: Hashable {
  let readingIndex: Int
  let conjugationgroup: Conjugationgroup

  /// True when the text is only the finite part that a main clause leaves once it sends the
  /// separable prefix to the end: halte, from "ich halte mich auf", matches aufhalten this way.
  /// Only a separable reading has one, as in the conjugation map, whose entries for such a
  /// part carry the particle.
  let isFinitePart: Bool
}

extension Verb {
  /// Every cell of every reading whose conjugation equals `text`, in the order the verb page
  /// shows them. A text matches as the quiz grades an answer: any region's spelling, either
  /// clause's word order, case and spacing ignored. So "stand auf" and "aufstand" both match
  /// aufstehen's Präteritum, and "ist gestanden" matches stehen as Austria and Switzerland
  /// write it. The infinitive is not a cell and never matches.
  func conjugations(matching text: String) -> [ConjugationMatch] {
    let wanted = text.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased()
    guard !wanted.isEmpty else {
      return []
    }
    var matches: [ConjugationMatch] = []
    for (readingIndex, reading) in readings.enumerated() {
      let isSeparable = !reading.prefixes.separableRun.isEmpty
      for conjugationgroup in Conjugationgroup.allCells {
        let spellings = Set(Region.allCases.flatMap { region in
          Clause.allCases.compactMap { clause in
            try? RegionalConjugator.conjugate(
              infinitiv: infinitiv,
              conjugationgroup: conjugationgroup,
              region: region,
              readingIndex: readingIndex,
              clause: clause
            ).get().lowercased()
          }
        })
        if spellings.contains(wanted) {
          matches.append(ConjugationMatch(readingIndex: readingIndex, conjugationgroup: conjugationgroup, isFinitePart: false))
        } else if isSeparable, conjugationgroup.leavesFinitePart, spellings.contains(where: { $0.hasPrefix(wanted + " ") }) {
          matches.append(ConjugationMatch(readingIndex: readingIndex, conjugationgroup: conjugationgroup, isFinitePart: true))
        }
      }
    }
    return matches
  }
}

extension Conjugationgroup {
  /// Every cell of a verb's tables, in the verb page's order.
  static let allCells: [Conjugationgroup] = {
    let finite: [(PersonNumber) -> Conjugationgroup] = [
      Conjugationgroup.präsensIndikativ,
      Conjugationgroup.präteritumIndikativ,
      Conjugationgroup.präsensKonjunktivI,
      Conjugationgroup.präteritumKonjunktivII,
    ]
    let compound: [(PersonNumber) -> Conjugationgroup] = [
      Conjugationgroup.perfektIndikativ,
      Conjugationgroup.perfektKonjunktivI,
      Conjugationgroup.plusquamperfektIndikativ,
      Conjugationgroup.plusquamperfektKonjunktivII,
      Conjugationgroup.futurIndikativ,
      Conjugationgroup.futurKonjunktivI,
      Conjugationgroup.futurKonjunktivII,
    ]
    return [.perfektpartizip, .präsenspartizip]
      + finite.flatMap { PersonNumber.allCases.map($0) }
      + PersonNumber.imperativPersonNumbers.map(Conjugationgroup.imperativ)
      + compound.flatMap { PersonNumber.allCases.map($0) }
  }()

  /// Nil for a participle, which has no person.
  var personNumber: PersonNumber? {
    switch self {
    case .perfektpartizip, .präsenspartizip:
      return nil
    case .präsensIndikativ(let personNumber), .präsensKonjunktivI(let personNumber), .präteritumIndikativ(let personNumber),
      .präteritumKonjunktivII(let personNumber), .imperativ(let personNumber), .perfektIndikativ(let personNumber),
      .perfektKonjunktivI(let personNumber), .plusquamperfektIndikativ(let personNumber), .plusquamperfektKonjunktivII(let personNumber),
      .futurIndikativ(let personNumber), .futurKonjunktivI(let personNumber), .futurKonjunktivII(let personNumber):
      return personNumber
    }
  }

  /// Whether a main clause splits this cell around its separable prefix, leaving a finite part
  /// that is a word on its own. A compound conjugationgroup's first word is the auxiliary,
  /// which belongs to haben, sein, or werden rather than to the verb.
  fileprivate var leavesFinitePart: Bool {
    switch self {
    case .präsensIndikativ, .präsensKonjunktivI, .präteritumIndikativ, .präteritumKonjunktivII, .imperativ:
      return true
    case .perfektpartizip, .präsenspartizip, .perfektIndikativ, .perfektKonjunktivI, .plusquamperfektIndikativ, .plusquamperfektKonjunktivII, .futurIndikativ, .futurKonjunktivI, .futurKonjunktivII:
      return false
    }
  }
}
