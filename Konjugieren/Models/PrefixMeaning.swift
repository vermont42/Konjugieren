// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct PrefixMeaning: Identifiable {
  let prefix: String
  let englishMeaning: String
  let pie: String

  var id: String { prefix }

  var pieMeaning: String {
    let key = String(prefix.dropLast())
    return NSLocalizedString("PIEMeaning.\(key)", comment: "")
  }

  private static let separableData: [(String, String, String)] = [
    ("ab-", "off, away, down", "*h₂epó"),
    ("an-", "at, on, to", "*h₂en"),
    ("auf-", "up, open, on", "*upó"),
    ("aus-", "out, from, off", "*úd"),
    ("bei-", "with, near, alongside", "*h₁epi"),
    ("ein-", "in, into", "*h₁én"),
    ("fest-", "firm, fixed, tight", "*pastV"),
    ("fort-", "away, onward, continuing", "*per"),
    ("her-", "toward speaker, hither", "*ḱís"),
    ("hin-", "away from speaker, thither", "*ḱís"),
    ("hoch-", "up, high", "*kewk"),
    ("mit-", "along, with, co-", "*me"),
    ("nach-", "after, following, re-", "*h₂neḱ"),
    ("um-", "around, over, re-", "*h₂m̥bʰi"),
    ("vor-", "forward, before, pre-", "*preh₂"),
    ("zu-", "to, toward, closed", "*doh₁"),
    ("zurück-", "back, returning", "*doh₁ + *(s)krewk"),
    ("zusammen-", "together, combined", "*doh₁ + *sem")
  ]

  private static let inseparableData: [(String, String, String)] = [
    ("be-", "makes verb transitive", "*h₁epi"),
    ("emp-", "variant of ent- (receiving)", "*h₂ent-"),
    ("ent-", "away, un-, de-", "*h₂ent-"),
    ("er-", "achievement, completion", "*úd"),
    ("ge-", "collective, completion (various)", "*ḱóm"),
    ("ver-", "away, wrongly, completion", "*per"),
    ("zer-", "to pieces, apart", "*dwís")
  ]

  private static func fromData(_ data: [(String, String, String)]) -> [PrefixMeaning] {
    data.map { PrefixMeaning(prefix: $0.0, englishMeaning: $0.1, pie: $0.2) }
  }

  static let separablePrefixes: [PrefixMeaning] = fromData(separableData)
  static let inseparablePrefixes: [PrefixMeaning] = fromData(inseparableData)
}
