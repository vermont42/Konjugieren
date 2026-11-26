// Copyright © 2026 Josh Adams. All rights reserved.

/// The cells of a verb page that a search matched. The page opens on their reading, scrolls to
/// the first of them, and marks them.
struct MarkedConjugations: Hashable {
  let readingIndex: Int
  let conjugationgroups: Set<Conjugationgroup>
}

extension MarkedConjugations {
  init(_ cells: (readingIndex: Int, conjugationgroups: [Conjugationgroup])) {
    self.init(readingIndex: cells.readingIndex, conjugationgroups: Set(cells.conjugationgroups))
  }

  /// The cells of `verb` that `text` fills, for a deeplink's `match`. Whole conjugations come
  /// first; failing those, finite parts.
  init?(text: String, on verb: Verb) {
    guard let cells = verb.cells(filledBy: text, preferring: .wholeThenFinitePart) else {
      return nil
    }
    self.init(cells)
  }
}
