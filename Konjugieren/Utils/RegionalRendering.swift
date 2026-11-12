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
}

/// Conjugation as the user should see it, as opposed to `Conjugator`, which is deliberately
/// region-free so that it can keep serving as the oracle for the classify-and-verify pipeline.
/// Everything region-sensitive lives here: the auxiliary a regionally conditioned verb takes,
/// and Swiss orthography. It also shows a separable verb as a main clause writes it (ich
/// stehe auf), since that is what a learner reads and writes most often.
enum RegionalConjugator {
  static func conjugate(
    infinitiv: String,
    conjugationgroup: Conjugationgroup,
    region: Region = Current.settings.region,
    readingIndex: Int = 0,
    clause: Clause = .main
  ) -> Result<String, ConjugatorError> {
    // The auxiliary is read off the selected reading rather than the verb, because the two
    // kinds of auxiliary variation compose: schmelzen picks its auxiliary by meaning, and a
    // regionally conditioned verb picks its own by which codified standard is selected.
    let auxiliary = Verb.verbs[infinitiv]?.reading(at: readingIndex)?.regionalAuxiliary(in: region)
    let result = Conjugator.conjugate(
      infinitiv: infinitiv,
      conjugationgroup: conjugationgroup,
      auxiliary: auxiliary,
      readingIndex: readingIndex,
      clause: clause
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
    readingIndex: Int = 0,
    clause: Clause = .main
  ) -> String {
    switch conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup, region: region, readingIndex: readingIndex, clause: clause) {
    case .success(let conjugation):
      return conjugation
    case .failure(let error):
      Current.fatalError.fatalError("Conjugation of \(infinitiv) for conjugationgroup \(conjugationgroup) resulted in error \(error).")
      return ""
    }
  }
}
