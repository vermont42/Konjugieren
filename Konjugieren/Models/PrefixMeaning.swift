// Copyright © 2026 Josh Adams. All rights reserved.

struct PrefixMeaning: Identifiable {
  let prefix: String
  let meaning: String
  let pie: String
  let pieMeaning: String

  var id: String { prefix }

  static let separablePrefixes: [PrefixMeaning] = [
    PrefixMeaning(prefix: "ab-", meaning: L.PrefixMeaning.ab, pie: "*h₂epó", pieMeaning: "off, away"),
    PrefixMeaning(prefix: "an-", meaning: L.PrefixMeaning.an, pie: "*h₂en", pieMeaning: "on, onto"),
    PrefixMeaning(prefix: "auf-", meaning: L.PrefixMeaning.auf, pie: "*upó", pieMeaning: "up, from below"),
    PrefixMeaning(prefix: "aus-", meaning: L.PrefixMeaning.aus, pie: "*úd", pieMeaning: "upwards, away, out, outward"),
    PrefixMeaning(prefix: "bei-", meaning: L.PrefixMeaning.bei, pie: "*h₁epi", pieMeaning: "on, at, near"),
    PrefixMeaning(prefix: "ein-", meaning: L.PrefixMeaning.ein, pie: "*h₁én", pieMeaning: "in"),
    PrefixMeaning(prefix: "fest-", meaning: L.PrefixMeaning.fest, pie: "*pastV", pieMeaning: "solid, stable"),
    PrefixMeaning(prefix: "fort-", meaning: L.PrefixMeaning.fort, pie: "*per", pieMeaning: "to cross; across, before, in front"),
    PrefixMeaning(prefix: "her-", meaning: L.PrefixMeaning.her, pie: "*ḱís", pieMeaning: "this (here)"),
    PrefixMeaning(prefix: "hin-", meaning: L.PrefixMeaning.hin, pie: "*ḱís", pieMeaning: "this (here)"),
    PrefixMeaning(prefix: "hoch-", meaning: L.PrefixMeaning.hoch, pie: "*kewk", pieMeaning: "to bend; crooked"),
    PrefixMeaning(prefix: "mit-", meaning: L.PrefixMeaning.mit, pie: "*me", pieMeaning: "in the middle of, near, by, around, with"),
    PrefixMeaning(prefix: "nach-", meaning: L.PrefixMeaning.nach, pie: "*h₂neḱ", pieMeaning: "to reach, attain"),
    PrefixMeaning(prefix: "um-", meaning: L.PrefixMeaning.um, pie: "*h₂m̥bʰi", pieMeaning: "around, on either side of, about"),
    PrefixMeaning(prefix: "vor-", meaning: L.PrefixMeaning.vor, pie: "*preh₂", pieMeaning: "before, in front"),
    PrefixMeaning(prefix: "zu-", meaning: L.PrefixMeaning.zu, pie: "*doh₁", pieMeaning: "to"),
    PrefixMeaning(prefix: "zurück-", meaning: L.PrefixMeaning.zurueck, pie: "*doh₁ + *(s)krewk", pieMeaning: "to + heap, hill; back, spine"),
    PrefixMeaning(prefix: "zusammen-", meaning: L.PrefixMeaning.zusammen, pie: "*doh₁ + *sem", pieMeaning: "to + together, one")
  ]

  static let inseparablePrefixes: [PrefixMeaning] = [
    PrefixMeaning(prefix: "be-", meaning: L.PrefixMeaning.be, pie: "*h₁epi", pieMeaning: "on, at, near"),
    PrefixMeaning(prefix: "emp-", meaning: L.PrefixMeaning.emp, pie: "*h₂ent-", pieMeaning: "face, forehead, front"),
    PrefixMeaning(prefix: "ent-", meaning: L.PrefixMeaning.ent, pie: "*h₂ent-", pieMeaning: "face, forehead, front"),
    PrefixMeaning(prefix: "er-", meaning: L.PrefixMeaning.er, pie: "*úd", pieMeaning: "upwards, away, out, outward"),
    PrefixMeaning(prefix: "ge-", meaning: L.PrefixMeaning.ge, pie: "*ḱóm", pieMeaning: "beside, near, by, with"),
    PrefixMeaning(prefix: "ver-", meaning: L.PrefixMeaning.ver, pie: "*per", pieMeaning: "before, in front, first"),
    PrefixMeaning(prefix: "zer-", meaning: L.PrefixMeaning.zer, pie: "*dwís", pieMeaning: "twice, doubly, in two")
  ]
}
