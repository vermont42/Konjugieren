// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct PrefixMeaning: Identifiable {
  let prefix: String
  let englishMeaning: String
  let pie: String

  var id: String { prefix }

  var pieMeaning: String {
    let key = String(prefix.dropLast())
    return String(localized: String.LocalizationValue(stringLiteral: "PIEMeaning.\(key)"))
  }

  // Alphabetical, folding umlauts to their base vowel, which is the collation Verbs.xml
  // uses; see docs/adding-verbs.md. The array order is the display order.
  private static let separableData: [(String, String, String)] = [
    ("ab-", "off, away, down", "*h₂epó"),
    ("an-", "at, on, to", "*h₂en"),
    ("auf-", "up, open, on", "*upó"),
    ("aus-", "out, from, off", "*úd"),
    ("bei-", "with, near, alongside", "*h₁epi"),
    ("davon-", "away, off from there", "*tó- + *h₂epó"),
    ("durch-", "through, all the way", "*terh₂-"),
    ("ein-", "in, into", "*h₁én"),
    ("empor-", "upward, aloft", "*bʰer-"),
    ("entgegen-", "toward, counter to", "*h₂ent-"),
    ("fest-", "firm, fixed, tight", "*pastV"),
    ("fort-", "away, onward, continuing", "*per"),
    ("frei-", "free, unrestricted; an adjective in a prefix slot", "*preyH-"),
    ("heim-", "home, homeward; a noun in a prefix slot", "*ḱóymos"),
    ("her-", "toward speaker, hither", "*ḱís"),
    ("heran-", "up to, closer", "*ḱís + *h₂en"),
    ("heraus-", "out, outward toward the speaker", "*ḱís + *úd"),
    ("herum-", "around, about", "*ḱís + *h₂m̥bʰi"),
    ("herunter-", "down, downward toward the speaker", "*ḱís + *n̥dʰer"),
    ("hervor-", "forth, out from", "*ḱís + *preh₂"),
    ("hin-", "away from speaker, thither", "*ḱís"),
    ("hinaus-", "out, outward away from the speaker", "*ḱís + *úd"),
    ("hinein-", "in, into, away from the speaker", "*ḱís + *h₁én"),
    ("hoch-", "up, high", "*kewk"),
    ("los-", "loose, off, starting", "*lewH-"),
    ("mit-", "along, with, co-", "*me"),
    ("nach-", "after, following, re-", "*h₂neḱ"),
    ("nieder-", "down, low", "*ni"),
    ("tot-", "to death; an adjective in a prefix slot", "*dʰewh₂-"),
    ("über-", "over, across; stressed, unlike inseparable über-", "*upér"),
    ("um-", "around, over, re-", "*h₂m̥bʰi"),
    ("unter-", "down, under; stressed, unlike inseparable unter-", "*n̥dʰer"),
    ("vor-", "forward, before, pre-", "*preh₂"),
    ("voraus-", "ahead, in advance", "*preh₂ + *úd"),
    ("weg-", "away, off", "*wegʰ-"),
    ("weiter-", "onward, continuing", "*wi"),
    ("wieder-", "again; stressed, unlike inseparable wieder-", "*wi-tero-"),
    ("zu-", "to, toward, closed", "*doh₁"),
    ("zurück-", "back, returning", "*doh₁ + *(s)krewk"),
    ("zusammen-", "together, combined", "*doh₁ + *sem")
  ]

  private static let inseparableData: [(String, String, String)] = [
    ("an-", "on, onto; unstressed, unlike separable an-", "*h₂en"),
    ("be-", "makes verb transitive", "*h₁epi"),
    ("emp-", "variant of ent- (receiving)", "*h₂ent-"),
    ("ent-", "away, un-, de-", "*h₂ent-"),
    ("er-", "achievement, completion", "*úd"),
    ("ge-", "collective, completion (various)", "*ḱóm"),
    ("hinter-", "behind, after", "*ḱi-tero-"),
    ("über-", "across, beyond, excessively; unstressed, unlike separable über-", "*upér"),
    ("um-", "encircling, surrounding; unstressed, unlike separable um-", "*h₂m̥bʰi"),
    ("unter-", "beneath, insufficiently; unstressed, unlike separable unter-", "*n̥dʰer"),
    ("ver-", "away, wrongly, completion", "*per"),
    ("voll-", "fully, completely", "*pl̥h₁nós"),
    ("wider-", "against, counter to", "*wi-tero-"),
    ("wieder-", "again, repeating; unstressed, unlike separable wieder-", "*wi-tero-"),
    ("zer-", "to pieces, apart", "*dwís")
  ]

  private static func fromData(_ data: [(String, String, String)]) -> [PrefixMeaning] {
    data.map { PrefixMeaning(prefix: $0.0, englishMeaning: $0.1, pie: $0.2) }
  }

  static let separablePrefixes: [PrefixMeaning] = fromData(separableData)
  static let inseparablePrefixes: [PrefixMeaning] = fromData(inseparableData)
}
