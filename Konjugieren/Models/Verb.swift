// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct Verb: Identifiable, Hashable, CustomStringConvertible {
  static var verbs: [String: Verb] = [:]
  static let minVerbLength = 3

  static var verbsSortedAlphabetically: [Verb] {
    Array(verbs.values).sorted { $0.infinitiv < $1.infinitiv }
  }

  static var verbsSortedByFrequency: [Verb] {
    Array(verbs.values).sorted { $0.frequency < $1.frequency }
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
