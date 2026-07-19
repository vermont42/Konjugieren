// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct Verb: Identifiable, Hashable {
  @MainActor static var verbs: [String: Verb] = [:]
  static let minVerbLength = 3
  @MainActor private static var cachedAlpha: [Verb]?
  @MainActor private static var cachedFreq: [Verb]?

  @MainActor static var verbsSortedAlphabetically: [Verb] {
    if let cachedAlpha {
      return cachedAlpha
    }
    let sorted = Array(verbs.values).sorted {
      $0.infinitiv.compare($1.infinitiv, locale: Locale(identifier: "de")) == .orderedAscending
    }
    cachedAlpha = sorted
    return sorted
  }

  @MainActor static var verbsSortedByFrequency: [Verb] {
    if let cachedFreq {
      return cachedFreq
    }
    let sorted = Array(verbs.values).sorted { $0.frequency < $1.frequency }
    cachedFreq = sorted
    return sorted
  }

  var id: String { infinitiv }
  let infinitiv: String
  let frequency: Int
  let frequencyIcon: String

  /// Ordered, never empty. Most verbs have exactly one; a verb whose meaning splits the
  /// auxiliary, the paradigm, or the prefix has more. See `Reading`.
  let readings: [Reading]

  /// The reading that answers for the verb wherever a single answer is required — the
  /// browse list, the widget, deeplinks, and anything else with room for one gloss.
  var primaryReading: Reading {
    readings.first ?? Reading(
      infinitiv: infinitiv,
      translation: "",
      family: .weak,
      auxiliary: .haben,
      prefixes: [],
      auxiliaryIsRegional: false
    )
  }

  var hasMultipleReadings: Bool { readings.count > 1 }

  func reading(at index: Int) -> Reading? {
    readings.indices.contains(index) ? readings[index] : nil
  }

  var translation: String { primaryReading.translation }
  var family: Family { primaryReading.family }
  var auxiliary: Auxiliary { primaryReading.auxiliary }
  var prefix: Prefix { primaryReading.prefix }
  var auxiliaryIsRegional: Bool { primaryReading.auxiliaryIsRegional }
  var stamm: String { primaryReading.stamm }
  var ablautGroup: String? { primaryReading.ablautGroup }

  /// The auxiliary a speaker of `region` uses. `auxiliary` itself always holds the northern
  /// standard value, so that Conjugator and the classify-and-verify oracle stay region-free.
  func regionalAuxiliary(in region: Region) -> Auxiliary {
    primaryReading.regionalAuxiliary(in: region)
  }

  static func endingIsValid(infinitiv: String) -> Bool {
    ["en", "rn", "ln", "in", "un"].contains(String(infinitiv.suffix(2)))
  }
}
