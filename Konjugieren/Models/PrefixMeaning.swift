// Copyright © 2026 Josh Adams. All rights reserved.

struct PrefixMeaning: Identifiable {
  let prefix: String
  let englishMeaning: String
  let pie: String
  let pieMeaning: String

  var id: String { prefix }

  static let separablePrefixes: [PrefixMeaning] = [
    PrefixMeaning(prefix: "ab-", englishMeaning: "off, away, down", pie: "*h₂epó", pieMeaning: L.PIEMeaning.ab),
    PrefixMeaning(prefix: "an-", englishMeaning: "at, on, to", pie: "*h₂en", pieMeaning: L.PIEMeaning.an),
    PrefixMeaning(prefix: "auf-", englishMeaning: "up, open, on", pie: "*upó", pieMeaning: L.PIEMeaning.auf),
    PrefixMeaning(prefix: "aus-", englishMeaning: "out, from, off", pie: "*úd", pieMeaning: L.PIEMeaning.aus),
    PrefixMeaning(prefix: "bei-", englishMeaning: "with, near, alongside", pie: "*h₁epi", pieMeaning: L.PIEMeaning.bei),
    PrefixMeaning(prefix: "ein-", englishMeaning: "in, into", pie: "*h₁én", pieMeaning: L.PIEMeaning.ein),
    PrefixMeaning(prefix: "fest-", englishMeaning: "firm, fixed, tight", pie: "*pastV", pieMeaning: L.PIEMeaning.fest),
    PrefixMeaning(prefix: "fort-", englishMeaning: "away, onward, continuing", pie: "*per", pieMeaning: L.PIEMeaning.fort),
    PrefixMeaning(prefix: "her-", englishMeaning: "toward speaker, hither", pie: "*ḱís", pieMeaning: L.PIEMeaning.her),
    PrefixMeaning(prefix: "hin-", englishMeaning: "away from speaker, thither", pie: "*ḱís", pieMeaning: L.PIEMeaning.hin),
    PrefixMeaning(prefix: "hoch-", englishMeaning: "up, high", pie: "*kewk", pieMeaning: L.PIEMeaning.hoch),
    PrefixMeaning(prefix: "mit-", englishMeaning: "along, with, co-", pie: "*me", pieMeaning: L.PIEMeaning.mit),
    PrefixMeaning(prefix: "nach-", englishMeaning: "after, following, re-", pie: "*h₂neḱ", pieMeaning: L.PIEMeaning.nach),
    PrefixMeaning(prefix: "um-", englishMeaning: "around, over, re-", pie: "*h₂m̥bʰi", pieMeaning: L.PIEMeaning.um),
    PrefixMeaning(prefix: "vor-", englishMeaning: "forward, before, pre-", pie: "*preh₂", pieMeaning: L.PIEMeaning.vor),
    PrefixMeaning(prefix: "zu-", englishMeaning: "to, toward, closed", pie: "*doh₁", pieMeaning: L.PIEMeaning.zu),
    PrefixMeaning(prefix: "zurück-", englishMeaning: "back, returning", pie: "*doh₁ + *(s)krewk", pieMeaning: L.PIEMeaning.zurueck),
    PrefixMeaning(prefix: "zusammen-", englishMeaning: "together, combined", pie: "*doh₁ + *sem", pieMeaning: L.PIEMeaning.zusammen)
  ]

  static let inseparablePrefixes: [PrefixMeaning] = [
    PrefixMeaning(prefix: "be-", englishMeaning: "makes verb transitive", pie: "*h₁epi", pieMeaning: L.PIEMeaning.be),
    PrefixMeaning(prefix: "emp-", englishMeaning: "variant of ent- (receiving)", pie: "*h₂ent-", pieMeaning: L.PIEMeaning.emp),
    PrefixMeaning(prefix: "ent-", englishMeaning: "away, un-, de-", pie: "*h₂ent-", pieMeaning: L.PIEMeaning.ent),
    PrefixMeaning(prefix: "er-", englishMeaning: "achievement, completion", pie: "*úd", pieMeaning: L.PIEMeaning.er),
    PrefixMeaning(prefix: "ge-", englishMeaning: "collective, completion (various)", pie: "*ḱóm", pieMeaning: L.PIEMeaning.ge),
    PrefixMeaning(prefix: "ver-", englishMeaning: "away, wrongly, completion", pie: "*per", pieMeaning: L.PIEMeaning.ver),
    PrefixMeaning(prefix: "zer-", englishMeaning: "to pieces, apart", pie: "*dwís", pieMeaning: L.PIEMeaning.zer)
  ]
}
