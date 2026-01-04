// Copyright © 2025 Josh Adams. All rights reserved.

import Foundation

struct Verb: Identifiable, Hashable, CustomStringConvertible {
  static var verbs: [String: Verb] = [:]
  static let minVerbLength = 3
  let id = UUID()
  let infinitiv: String
  let translation: String
  let family: Family
  let auxiliary: Auxiliary
  let frequency: Int
  let prefix: Prefix

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
