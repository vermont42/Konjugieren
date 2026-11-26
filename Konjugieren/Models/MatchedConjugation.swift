// Copyright © 2026 Josh Adams. All rights reserved.

/// The conjugation that a search result matched, and the cells of the verb's page it fills.
struct MatchedConjugation: Hashable {
  /// As the app spells it, which is not always as typed: ging, stand auf, muss for muß. For a
  /// finite part, the part alone.
  let text: String

  /// For a finite part, the separable prefix that a main clause sends to the end.
  let particle: String?

  /// The first reading with a matching cell, and its matching cells in page order. Empty for
  /// a finite part, whose cells are found only when its row is opened, and for a zu-infinitive,
  /// which is not a cell.
  let readingIndex: Int
  let conjugationgroups: [Conjugationgroup]

  let isZuInfinitive: Bool

  /// Names the cells of `verb` that `text` fills, which costs a few hundred conjugations, so the
  /// list does this only for whole-verb matches, of which a query has few.
  init(whole text: String, of verb: Verb) {
    let cells = verb.cells(filledBy: text, preferring: .whole)
    self.text = text
    particle = nil
    readingIndex = cells?.readingIndex ?? 0
    conjugationgroups = cells?.conjugationgroups ?? []
    isZuInfinitive = cells == nil && verb.readings.contains { $0.zuInfinitive == text }
  }

  init(finitePart text: String, particle: String) {
    self.text = text
    self.particle = particle
    readingIndex = 0
    conjugationgroups = []
    isZuInfinitive = false
  }

  /// hielt … auf, as a learner meets it in a main clause.
  var shownConjugation: String {
    particle.map { "\(text) … \($0)" } ?? text
  }

  /// "Präteritum Indikativ (ich, er)", or several such joined by a dot. Nil for a finite part.
  func cellNames(lang: ConjugationgroupLang) -> String? {
    guard particle == nil else {
      return nil
    }
    if isZuInfinitive {
      return lang == .german ? "zu-Infinitiv" : "zu-infinitive"
    }
    var sections: [(name: String, persons: [String])] = []
    for group in conjugationgroups {
      let name = group.displayName(lang: lang)
      let person = group.personNumber.map { personNumber in
        group.isImperativ ? personNumber.imperativPronoun ?? personNumber.pronoun : personNumber.pronoun
      }
      if let index = sections.firstIndex(where: { $0.name == name }) {
        sections[index].persons += person.map { [$0] } ?? []
      } else {
        sections.append((name, person.map { [$0] } ?? []))
      }
    }
    guard !sections.isEmpty else {
      return nil
    }
    return sections
      .map { $0.persons.isEmpty ? $0.name : "\($0.name) (\($0.persons.joined(separator: ", ")))" }
      .joined(separator: " · ")
  }

  /// The cells the verb page marks. A finite part's are found here, for the one verb opened.
  func marks(on verb: Verb) -> MarkedConjugations? {
    guard particle != nil else {
      return conjugationgroups.isEmpty ? nil : MarkedConjugations((readingIndex, conjugationgroups))
    }
    return verb.cells(filledBy: text, preferring: .finitePart).map(MarkedConjugations.init)
  }
}
