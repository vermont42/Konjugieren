// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct Verb: Identifiable, Hashable, CustomStringConvertible {
  static var verbs: [String: Verb] = [:]
  static let minVerbLength = 3
  private static var cachedAlpha: [Verb]?
  private static var cachedFreq: [Verb]?

  static var verbsSortedAlphabetically: [Verb] {
    if let cachedAlpha {
      return cachedAlpha
    }
    let sorted = Array(verbs.values).sorted {
      $0.infinitiv.compare($1.infinitiv, locale: Locale(identifier: "de")) == .orderedAscending
    }
    cachedAlpha = sorted
    return sorted
  }

  static var verbsSortedByFrequency: [Verb] {
    if let cachedFreq {
      return cachedFreq
    }
    let sorted = Array(verbs.values).sorted { $0.frequency < $1.frequency }
    cachedFreq = sorted
    return sorted
  }

  let id = UUID()
  let infinitiv: String
  let translation: String
  let family: Family
  let auxiliary: Auxiliary
  let frequency: Int
  let prefix: Prefix
  let frequencyIcon: String

  var stamm: String {
    if infinitiv.hasSuffix("en") {
      return String(infinitiv.dropLast(2))
    } else {
      return String(infinitiv.dropLast())
    }
  }

  var ablautGroup: String? {
    switch family {
    case .strong(let group, _, _), .mixed(let group, _, _):
      return group
    case .weak, .ieren:
      return nil
    }
  }

  static func endingIsValid(infinitiv: String) -> Bool {
    ["en", "rn", "ln", "in", "un"].contains(String(infinitiv.suffix(2)))
  }

  var description: String {
    var output = infinitiv
    output += " " + translation
    output += " " + auxiliary.verb
    output += " " + family.description
    output += " " + "\(frequency)"
    if prefix != .none {
      output.append(" " + prefix.description)
    }
    return output
  }
}
