// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The conjugation map, indexed for search: by folded spelling, so that muß finds muss and
/// gehort finds gehört, and by length, so that a guess compares a misspelling only with
/// conjugations of about its length.
nonisolated struct ConjugationIndex: Sendable {
  let map: ConjugationMap
  private let keysByFoldedKey: [String: [String]]
  private let foldedKeysByLength: [Int: [String]]

  init(map: ConjugationMap) {
    self.map = map
    var keysByFoldedKey: [String: [String]] = [:]
    for key in map.entriesByConjugation.keys.sorted() {
      keysByFoldedKey[VerbSearch.fold(key), default: []].append(key)
    }
    self.keysByFoldedKey = keysByFoldedKey
    var foldedKeysByLength: [Int: [String]] = [:]
    for foldedKey in keysByFoldedKey.keys.sorted() {
      foldedKeysByLength[foldedKey.count, default: []].append(foldedKey)
    }
    self.foldedKeysByLength = foldedKeysByLength
  }

  /// Built on first use from `ConjugationMap.bundled`. Building takes a moment, so the verb
  /// list touches it from a background task before the learner types.
  static let bundled = ConjugationIndex(map: .bundled)

  nonisolated struct Spelling: Equatable, Sendable {
    let conjugation: String
    let isFolded: Bool
  }

  /// The conjugations that `word` spells: itself, if it is one, then those equal to it after
  /// folding.
  func spellings(of word: String) -> [Spelling] {
    let lowered = word.lowercased()
    let literal = map.entriesByConjugation[lowered] == nil ? [] : [Spelling(conjugation: lowered, isFolded: false)]
    let folded = (keysByFoldedKey[VerbSearch.fold(lowered)] ?? [])
      .filter { $0 != lowered }
      .map { Spelling(conjugation: $0, isFolded: true) }
    return literal + folded
  }

  /// Folded conjugations whose length is within `distance` of `length`, with the
  /// conjugations each stands for.
  func foldedConjugations(nearLength length: Int, distance: Int) -> [(folded: String, conjugations: [String])] {
    ((length - distance)...(length + distance)).flatMap { candidateLength in
      (foldedKeysByLength[candidateLength] ?? []).map { ($0, keysByFoldedKey[$0] ?? []) }
    }
  }
}
