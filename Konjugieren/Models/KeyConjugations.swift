// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension Verb {
  /// The three conjugations from which a learner can rebuild most of a verb: the er form of the
  /// Präsens, Präteritum, and Perfekt Indikativ, as a main clause writes them (steht auf, stand
  /// auf, ist aufgestanden). They show a vowel change, a separable prefix, and the auxiliary at a
  /// glance. They are always shown with no heading, because the textbook name for them means
  /// little to most learners.
  ///
  /// Mixed case, as the Conjugator writes it, so that a caller can show the red letters. A
  /// conjugation the Conjugator cannot produce is left out.
  func keyConjugations(readingIndex: Int = 0, region: Region = Current.settings.region) -> [String] {
    Self.keyConjugationgroups.compactMap { conjugationgroup in
      switch RegionalConjugator.conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup, region: region, readingIndex: readingIndex) {
      case .success(let conjugation):
        return conjugation
      case .failure:
        return nil
      }
    }
  }

  /// What the verb page's share button sends: the verb, its gloss, its key conjugations, and the
  /// App Store link, in the learner's language.
  func shareText(readingIndex: Int = 0, region: Region = Current.settings.region) -> String {
    let gloss = reading(at: readingIndex)?.translation ?? primaryReading.translation
    let conjugations = keyConjugations(readingIndex: readingIndex, region: region)
      .map { $0.lowercased() }
      .joined(separator: " · ")
    return L.VerbView.shareText(
      infinitiv: infinitiv.inRegion(region),
      gloss: gloss,
      keyConjugations: conjugations,
      link: URL.appStore.absoluteString
    )
  }

  private static let keyConjugationgroups: [Conjugationgroup] = [
    .präsensIndikativ(.thirdSingular),
    .präteritumIndikativ(.thirdSingular),
    .perfektIndikativ(.thirdSingular),
  ]
}
