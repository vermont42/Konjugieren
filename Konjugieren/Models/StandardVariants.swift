// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// Standard conjugations that Duden lists beside the one the conjugator writes, such as komme
/// beside komm and stünde beside stände. The quiz accepts them; the verb page keeps showing the
/// conjugator's conjugation. Josh ruled on each kind on 2026-11-13, from the audit in
/// `plans/pedagogy-phase1-variant-audit.md`, whose row letters the comments below cite.
enum StandardVariants {
  /// The variants of one conjugation, as one region and clause write it. Variants keep the
  /// conjugator's capitals where they keep its letters; the caller lowercases them for grading.
  static func variants(of conjugation: String, reading: Reading, conjugationgroup: Conjugationgroup, region: Region) -> [String] {
    var variants: [String] = []
    func add(_ variant: String?) {
      if let variant, variant != conjugation, !variants.contains(variant) {
        variants.append(variant)
      }
    }
    let infinitiv = reading.infinitiv
    let isStrong = reading.family.isStrong
    let isEln = infinitiv.hasSuffix("eln")
    let isElnOrErn = isEln || infinitiv.hasSuffix("ern")

    switch conjugationgroup {
    case .imperativ(.secondSingular):
      // A1: komm and komme. A changed stem (sieh, nimm) never takes the -e.
      add(replacingFirstWord(of: conjugation) { word in
        word.hasCapital || word.hasSuffix("e") ? nil : word + "e"
      })
      // A2: a strong verb's -d or -t stem may drop the -e (bitt, halt, find). A weak verb's
      // may not (arbeite only).
      if isStrong {
        add(replacingFirstWord(of: conjugation) { word in
          !word.hasCapital && (word.hasSuffix("de") || word.hasSuffix("te")) ? String(word.dropLast()) : nil
        })
      }
      // B1: sammle beside sammel and sammele.
      if isEln {
        add(replacingFirstWord(of: conjugation) { word in
          word.hasSuffix("el") ? String(word.dropLast(2)) + "le" : nil
        })
      }

    case .präsensIndikativ(.firstSingular), .präsensKonjunktivI(.firstSingular), .präsensKonjunktivI(.thirdSingular):
      // B1: ich sammle beside sammele. An -ern verb keeps its e: Duden has no ich wandre.
      if isEln {
        add(replacingFirstWord(of: conjugation) { word in
          word.hasSuffix("ele") ? String(word.dropLast(3)) + "le" : nil
        })
      }

    case .präsensKonjunktivI(.secondSingular):
      // B3: du sammelst, du wanderst. The syllabic el or er already supplies the e.
      if isElnOrErn {
        add(replacingFirstWord(of: conjugation) { word in
          word.hasSuffix("elest") || word.hasSuffix("erest") ? String(word.dropLast(3)) + "st" : nil
        })
      }
      add(seiest(conjugation))

    case .präsensKonjunktivI(.secondPlural):
      if isElnOrErn {
        add(replacingFirstWord(of: conjugation) { word in
          word.hasSuffix("elet") || word.hasSuffix("eret") ? String(word.dropLast(2)) + "t" : nil
        })
      }

    case .perfektKonjunktivI(.secondSingular):
      // C3: du seiest gegangen.
      add(seiest(conjugation))

    case .präteritumKonjunktivII(let personNumber), .plusquamperfektKonjunktivII(let personNumber):
      // C1: kämst beside kämest, wärt beside wäret, and so wärst gegangen.
      add(replacingFirstWord(of: conjugation) { word in
        contractedKonjunktivII(word, personNumber: personNumber)
      })
      if case .präteritumKonjunktivII = conjugationgroup, isStrong {
        // D1: stünde beside stände, and the like.
        add(replacingFirstWord(of: conjugation) { word in
          konjunktivIIVowelDoublet(word, infinitiv: infinitiv)
        })
      }

    case .präteritumIndikativ(.secondSingular):
      // C2: batst beside batest, aßest beside aßt.
      if isStrong {
        add(replacingFirstWord(of: conjugation) { word in
          präteritumSecondSingularDoublet(word)
        })
      }

    default:
      break
    }

    for variant in doubletVariants(of: conjugation, reading: reading, conjugationgroup: conjugationgroup, region: region) {
      add(variant)
    }
    for variant in anerkennenVariants(of: conjugation, reading: reading, conjugationgroup: conjugationgroup) {
      add(variant)
    }
    return variants
  }


  private static let noSyncopeAfter: Set<Character> = ["a", "e", "i", "o", "u", "ä", "ö", "ü", "s", "ß", "z", "x", "d", "t"]

  /// kämest to kämst and kämet to kämt. Not after a sibilant, d, or t (äßest only, hättest
  /// only), and not after a vowel, where the e may be the stem's own (schriest).
  private static func contractedKonjunktivII(_ word: String, personNumber: PersonNumber) -> String? {
    let lowered = word.lowercased()
    let ending: String
    switch personNumber {
    case .secondSingular:
      ending = "est"
    case .secondPlural:
      ending = "et"
    case .firstSingular, .thirdSingular, .firstPlural, .thirdPlural:
      return nil
    }
    guard lowered.hasSuffix(ending), let before = lowered.dropLast(ending.count).last, !noSyncopeAfter.contains(before) else {
      return nil
    }
    return String(word.dropLast(ending.count)) + String(ending.dropFirst())
  }

  /// A strong Präteritum's du takes or drops the e on either side of a stem's last consonant:
  /// batest and batst, aßt and aßest.
  private static func präteritumSecondSingularDoublet(_ word: String) -> String? {
    let lowered = word.lowercased()
    if lowered.hasSuffix("dest") || lowered.hasSuffix("test") {
      return String(word.dropLast(3)) + "st"
    }
    if lowered.hasSuffix("t"), let before = lowered.dropLast().last, ["s", "ß", "z", "x"].contains(before) {
      return String(word.dropLast()) + "est"
    }
    return nil
  }

  private static func seiest(_ conjugation: String) -> String? {
    replacingFirstWord(of: conjugation) { word in
      word.lowercased() == "seist" ? "seiest" : nil
    }
  }


  /// Verbs whose Konjunktiv II Duden gives with either vowel, keyed by the infinitive's ending
  /// so that derivatives match (verstehen, entgelten). The conjugator writes the first vowel,
  /// in capitals, since it is ablaut.
  private static let konjunktivIIVowels: [(ending: String, shipped: Character, alternative: Character)] = [
    ("beginnen", "Ä", "Ö"),
    ("empfehlen", "Ä", "Ö"),
    ("gelten", "Ö", "Ä"),
    ("helfen", "Ä", "Ü"),
    ("schwimmen", "Ä", "Ö"),
    ("stehen", "Ä", "Ü"),
    ("stehlen", "Ä", "Ö")
  ]

  private static func konjunktivIIVowelDoublet(_ word: String, infinitiv: String) -> String? {
    guard
      let doublet = konjunktivIIVowels.first(where: { infinitiv.hasSuffix($0.ending) }),
      let index = word.firstIndex(of: doublet.shipped)
    else {
      return nil
    }
    var result = word
    result.replaceSubrange(index...index, with: String(doublet.alternative))
    return result
  }


  /// A verb that Duden conjugates two ways, keyed by the base verb, which a derivative ends
  /// with (versenden, abwinken). The conjugator writes one way; this gives the other.
  private struct Doublet {
    let base: String
    /// The alternative Präteritum's stem, before its endings (sand: sandte), or nil.
    var präteritumStem: String?
    /// Weak endings (sandte, sandtest) or strong (hieb, hiebst).
    var präteritumIsWeak = true
    /// Whether a weak ending takes an epenthetic e (siedete).
    var takesEpentheticE = false
    /// The alternative participle after any ge- (sandt: gesandt), or nil.
    var participle: String?
    /// Whether derivatives share the doublet. Not for hauen, since abhauen (scram) has only
    /// haute ab.
    var derivativesShare = true
  }

  private static let doublets: [Doublet] = [
    Doublet(base: "gären", präteritumStem: "gär"),
    Doublet(base: "hauen", präteritumStem: "hieb", präteritumIsWeak: false, derivativesShare: false),
    Doublet(base: "melken", präteritumStem: "melk", participle: "melkt"),
    Doublet(base: "salzen", participle: "salzt"),
    Doublet(base: "senden", präteritumStem: "sand", participle: "sandt"),
    Doublet(base: "sieden", präteritumStem: "sied", takesEpentheticE: true, participle: "siedet"),
    Doublet(base: "wenden", präteritumStem: "wand", participle: "wandt"),
    Doublet(base: "winken", participle: "wunken")
  ]

  private static let weakEndings = ["te", "test", "te", "ten", "tet", "ten"]
  private static let strongEndings = ["", "st", "", "en", "t", "en"]

  private static func doubletVariants(of conjugation: String, reading: Reading, conjugationgroup: Conjugationgroup, region: Region) -> [String] {
    let infinitiv = reading.infinitiv
    guard
      let doublet = doublets.first(where: { infinitiv == $0.base || ($0.derivativesShare && infinitiv.hasSuffix($0.base)) })
    else {
      return []
    }
    // The prefixes in front of the base verb, which must be exactly the reading's prefixes so
    // that ge- and the separable run land where the conjugator puts them.
    let head = String(infinitiv.dropLast(doublet.base.count))
    guard head.count == reading.prefixes.totalLength else {
      return []
    }
    let separableRun = reading.prefixes.separableRun

    switch conjugationgroup {
    case .präteritumIndikativ(let personNumber):
      guard let stem = doublet.präteritumStem, let index = PersonNumber.allCases.firstIndex(of: personNumber) else {
        return []
      }
      let ending = doublet.präteritumIsWeak ? (doublet.takesEpentheticE ? "e" : "") + weakEndings[index] : strongEndings[index]
      let joined = (head + stem + ending).inRegion(region)
      guard !separableRun.isEmpty else {
        return [joined]
      }
      return [joined, String(joined.dropFirst(separableRun.count)) + " " + separableRun]

    case .perfektpartizip:
      return alternativeParticiple(doublet: doublet, head: head, reading: reading, region: region).map { [$0] } ?? []

    case .perfektIndikativ, .perfektKonjunktivI, .plusquamperfektIndikativ, .plusquamperfektKonjunktivII:
      guard let participle = alternativeParticiple(doublet: doublet, head: head, reading: reading, region: region) else {
        return []
      }
      var words = conjugation.split(separator: " ").map(String.init)
      guard words.count == 2 else {
        return []
      }
      words[1] = participle
      return [words.joined(separator: " ")]

    default:
      return []
    }
  }

  private static func alternativeParticiple(doublet: Doublet, head: String, reading: Reading, region: Region) -> String? {
    doublet.participle.map { participle in
      (head + (reading.prefixes.takesGe ? "ge" : "") + participle).inRegion(region)
    }
  }


  /// Duden gives anerkennen split (erkennt an) and, "besonders schweizerisch", joined
  /// (anerkennt). The corpus encodes it inseparable, so the conjugator writes only the joined
  /// one, and every cell whose finite verb a main clause would split takes the split one too.
  private static func anerkennenVariants(of conjugation: String, reading: Reading, conjugationgroup: Conjugationgroup) -> [String] {
    guard reading.infinitiv == "anerkennen" else {
      return []
    }
    switch conjugationgroup {
    case .präsensIndikativ, .präsensKonjunktivI, .präteritumIndikativ, .präteritumKonjunktivII, .imperativ:
      var words = conjugation.split(separator: " ").map(String.init)
      guard let first = words.first, first.lowercased().hasPrefix("an") else {
        return []
      }
      words[0] = String(first.dropFirst(2))
      return [(words + ["an"]).joined(separator: " ")]
    default:
      return []
    }
  }


  /// The finite verb is the first word: the only one in a simple conjugation, the one before
  /// the particle in a main clause (sammle ein), and the auxiliary in a compound one.
  private static func replacingFirstWord(of conjugation: String, with transform: (String) -> String?) -> String? {
    var words = conjugation.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
    guard let first = words.first, let replacement = transform(first) else {
      return nil
    }
    words[0] = replacement
    return words.joined(separator: " ")
  }
}

private extension String {
  /// The conjugator capitalizes what ablaut changed, so a capital marks a changed stem.
  var hasCapital: Bool {
    contains { $0.isUppercase }
  }
}

private extension Family {
  var isStrong: Bool {
    if case .strong = self {
      return true
    }
    return false
  }
}
