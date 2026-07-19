// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension String {
  /// Rewrites a conjugation into the orthography of a given variety.
  ///
  /// The uppercase half is not cosmetic. Ablaut replacements spell the sibilant with the
  /// capital sharp s `ẞ` (U+1E9E) so that mixed-case highlighting covers it; see
  /// `docs/adding-verbs.md`. Mapping `ẞ` to `SS` keeps both output characters uppercase,
  /// so `MixedCaseSegmenter` still sees one unbroken irregular run rather than two.
  nonisolated func inRegion(_ region: Region) -> String {
    guard !region.writesSharpS else { return self }
    return replacingOccurrences(of: "ß", with: "ss")
      .replacingOccurrences(of: "ẞ", with: "SS")
  }

  /// Rewrites a conjugation into the variety the user selected in Settings.
  var inUserRegion: String {
    inRegion(Current.settings.region)
  }

  /// Collapses the ß/ss distinction so that spellings from different varieties compare equal.
  /// For matching only: never render this, because it discards the ß a northern user expects.
  nonisolated var sharpSNormalized: String {
    inRegion(.switzerland)
  }
}

/// Conjugation as the user should see it, as opposed to `Conjugator`, which is deliberately
/// region-free so that it can keep serving as the oracle for the classify-and-verify pipeline.
/// Everything region-sensitive lives here: the auxiliary a regionally conditioned verb takes,
/// and Swiss orthography.
enum RegionalConjugator {
  static func conjugate(
    infinitiv: String,
    conjugationgroup: Conjugationgroup,
    region: Region = Current.settings.region,
    readingIndex: Int = 0
  ) -> Result<String, ConjugatorError> {
    // The auxiliary is read off the selected reading rather than the verb, because the two
    // kinds of auxiliary variation compose: schmelzen picks its auxiliary by meaning, and a
    // regionally conditioned verb picks its own by where the speaker lives.
    let auxiliary = Verb.verbs[infinitiv]?.reading(at: readingIndex)?.regionalAuxiliary(in: region)
    let result = Conjugator.conjugate(
      infinitiv: infinitiv,
      conjugationgroup: conjugationgroup,
      auxiliary: auxiliary,
      readingIndex: readingIndex
    )
    switch result {
    case .success(let conjugation):
      return .success(conjugation.inRegion(region))
    case .failure(let error):
      return .failure(error)
    }
  }

  static func conjugateUnsafely(
    infinitiv: String,
    conjugationgroup: Conjugationgroup,
    region: Region = Current.settings.region,
    readingIndex: Int = 0
  ) -> String {
    switch conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup, region: region, readingIndex: readingIndex) {
    case .success(let conjugation):
      return conjugation
    case .failure(let error):
      Current.fatalError.fatalError("Conjugation of \(infinitiv) for conjugationgroup \(conjugationgroup) resulted in error \(error).")
      return ""
    }
  }
}
