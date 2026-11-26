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
  /// shows them. A text matches any region's spelling in either clause's word order, case and
  /// spacing ignored, so "stand auf" and "aufstand" both match aufstehen's Präteritum, and "ist
  /// gestanden" matches stehen as Austria and Switzerland write it. The infinitive is not a cell
  /// and never matches. The quiz grades more leniently (`QuizItem.accepts` also takes a leading
  /// pronoun, digraphs, and Duden's other standard conjugations); this does not, since it names
  /// cells of the conjugator's own tables.
  func conjugations(matching text: String) -> [ConjugationMatch] {
    let wanted = AnswerSpelling.normalized(text)
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
            )
            .get()
            .lowercased()
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

extension Verb {
  /// Which of a text's matching cells a caller wants.
  enum CellPreference {
    case finitePart
    case whole

    /// Whole conjugations, and failing those, finite parts, so that hielt marks aufhalten's
    /// "ich hielt auf".
    case wholeThenFinitePart
  }

  /// The cells that `text` fills in the first reading that has any of the kind `preference`
  /// wants, in page order. Nil when it fills none.
  func cells(filledBy text: String, preferring preference: CellPreference) -> (readingIndex: Int, conjugationgroups: [Conjugationgroup])? {
    let matches = conjugations(matching: text)
    let wholeMatches = matches.filter { !$0.isFinitePart }
    let chosen: [ConjugationMatch]
    switch preference {
    case .finitePart:
      chosen = matches.filter(\.isFinitePart)
    case .whole:
      chosen = wholeMatches
    case .wholeThenFinitePart:
      chosen = wholeMatches.isEmpty ? matches : wholeMatches
    }
    guard let first = chosen.first else {
      return nil
    }
    return (first.readingIndex, chosen.filter { $0.readingIndex == first.readingIndex }.map(\.conjugationgroup))
  }
}
