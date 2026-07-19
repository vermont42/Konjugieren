// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

// Stage B of the classify-and-verify pipeline described in docs/verb-sources.md.
//
// Consumes verbdata/candidates.json (written by verbdata/build_candidates.py) and,
// for every candidate, searches for the Verbs.xml encoding whose Conjugator output
// reproduces Wiktionary's conjugation table exactly. A hit confirms family, ablaut
// group, ablaut region, and prefix simultaneously; a miss lands in a queue with its
// closest near miss attached.
//
// Not part of ordinary test runs: it mutates Verb.verbs and AblautGroup.ablautGroups,
// which every other suite reads, and it takes minutes. Gated on an environment
// variable; see docs/verb-sources.md for the invocation.

@MainActor
@Suite("VerbClassification", .serialized, .enabled(if: ProcessInfo.processInfo.environment["KONJUGIEREN_CLASSIFY_IN"] != nil))
struct VerbClassificationTests {
  @Test func classifyCandidates() throws {
    let environment = ProcessInfo.processInfo.environment
    let inputPath = environment["KONJUGIEREN_CLASSIFY_IN"] ?? ""
    let outputPath = environment["KONJUGIEREN_CLASSIFY_OUT"]
      ?? FileManager.default.temporaryDirectory.appendingPathComponent("classification.json").path

    let data = try Data(contentsOf: URL(fileURLWithPath: inputPath))
    let file = try JSONDecoder().decode(CandidateFile.self, from: data)

    let limit = environment["KONJUGIEREN_CLASSIFY_LIMIT"].flatMap(Int.init) ?? .max
    let candidates = Array(file.candidates.prefix(limit))

    let classifier = Classifier()
    let classifications = candidates.map { classifier.classify($0) }
    classifier.restore()

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    try encoder.encode(Report(classifications: classifications)).write(to: URL(fileURLWithPath: outputPath))

    let verified = classifications.filter { $0.status == "verified" }.count
    print("classified \(verified)/\(classifications.count) verified → \(outputPath)")
    #expect(!classifications.isEmpty)
  }
}

// MARK: - Input

private struct CandidateFile: Decodable {
  let candidates: [Candidate]
}

private struct Candidate: Decodable {
  let word: String
  let glosses: [String]
  let auxiliary: [String]
  let tableTags: [String]
  let verbClass: String?
  let hasEtymology: Bool
  let forms: [String: [String]]
  let alreadyShipping: Bool
}

// MARK: - Output

private struct Report: Encodable {
  let classifications: [Classification]
}

private struct Classification: Encodable {
  let word: String
  let alreadyShipping: Bool
  let status: String
  let markedInfinitiv: String?
  let family: String?
  let ablautGroup: String?
  let ablautGroupIsNew: Bool
  let proposedAblautPattern: String?
  let auxiliary: String?
  let dualAuxiliary: Bool
  let translation: String?
  let hasEtymology: Bool
  let kaikkiClass: String?
  let slotsChecked: Int
  let mismatches: [String]
}

// MARK: - Classifier

@MainActor
private final class Classifier {
  // A replacement no German stem contains, so a probe's output reveals where the
  // ablaut region lands. Only the text *before* the sentinel is trusted: the ending
  // after it depends on the real replacement's final letter, which the sentinel does
  // not model. The replacement itself is searched, not read off the probe.
  private static let sentinel = "ΩΩ"
  private static let syntheticGroupKey = "__classifier__"

  private let originalVerbs: [String: Verb]
  private let originalAblautGroups: [String: AblautGroup]
  private let shippedAblautGroups: [String: [Conjugationgroup: String]]
  private let separablePrefixes: [String]
  private let inseparablePrefixes: [String]

  init() {
    originalVerbs = Verb.verbs
    originalAblautGroups = AblautGroup.ablautGroups
    shippedAblautGroups = originalAblautGroups.mapValues { $0.ablauts }

    var separable: Set<String> = []
    var inseparable: Set<String> = []
    for verb in originalVerbs.values {
      switch verb.prefix {
      case .separable(let prefix):
        separable.insert(prefix)
      case .inseparable(let prefix):
        inseparable.insert(prefix)
      case .none:
        break
      }
    }
    // Longest first, so "vorbei" is tried before "vor".
    separablePrefixes = separable.sorted { $0.count > $1.count }
    inseparablePrefixes = inseparable.sorted { $0.count > $1.count }
  }

  func restore() {
    Verb.verbs = originalVerbs
    AblautGroup.ablautGroups = originalAblautGroups
  }

  func classify(_ candidate: Candidate) -> Classification {
    let expectations = Self.expectations(from: candidate.forms)
    let auxiliary = Self.auxiliary(from: candidate.auxiliary)
    let translation = candidate.glosses.first.map(Self.shortened)

    var best: (mismatches: [String], checked: Int) = ([], .max)

    // For a verb that already ships, the encoding in Verbs.xml is the hypothesis that
    // matters. Testing it first keeps the search from reporting an equivalent-but-
    // different encoding — n^eh^men for the shipped n^ehm^en — as though the shipped
    // one were wrong.
    if candidate.alreadyShipping, let shipped = originalVerbs[candidate.word] {
      Verb.verbs[candidate.word] = shipped
      let mismatches = verify(word: candidate.word, prefix: shipped.prefix, expectations: expectations)
      if mismatches.isEmpty {
        return Classification(
          word: candidate.word,
          alreadyShipping: true,
          status: "verified",
          markedInfinitiv: Self.marked(word: candidate.word, prefix: shipped.prefix, region: nil),
          family: Self.familyCode(shipped.family),
          ablautGroup: shipped.ablautGroup,
          ablautGroupIsNew: false,
          proposedAblautPattern: nil,
          auxiliary: auxiliary.code,
          dualAuxiliary: auxiliary.isDual,
          translation: translation,
          hasEtymology: candidate.hasEtymology,
          kaikkiClass: candidate.verbClass,
          slotsChecked: expectations.count,
          mismatches: []
        )
      }
      record(mismatches, count: expectations.count, into: &best)
    }

    for prefix in prefixHypotheses(for: candidate) {
      if let solution = solve(candidate: candidate, prefix: prefix, expectations: expectations, best: &best) {
        return Classification(
          word: candidate.word,
          alreadyShipping: candidate.alreadyShipping,
          status: "verified",
          markedInfinitiv: solution.markedInfinitiv,
          family: solution.familyCode,
          ablautGroup: solution.ablautGroupName,
          ablautGroupIsNew: solution.ablautGroupIsNew,
          proposedAblautPattern: solution.pattern,
          auxiliary: auxiliary.code,
          dualAuxiliary: auxiliary.isDual,
          translation: translation,
          hasEtymology: candidate.hasEtymology,
          kaikkiClass: candidate.verbClass,
          slotsChecked: expectations.count,
          mismatches: []
        )
      }
    }

    return Classification(
      word: candidate.word,
      alreadyShipping: candidate.alreadyShipping,
      status: "unverified",
      markedInfinitiv: nil,
      family: nil,
      ablautGroup: nil,
      ablautGroupIsNew: false,
      proposedAblautPattern: nil,
      auxiliary: auxiliary.code,
      dualAuxiliary: auxiliary.isDual,
      translation: translation,
      hasEtymology: candidate.hasEtymology,
      kaikkiClass: candidate.verbClass,
      slotsChecked: expectations.count,
      mismatches: best.checked == .max ? ["no hypothesis produced a conjugation"] : Array(best.mismatches.prefix(6))
    )
  }

  // MARK: Hypothesis search

  private struct Solution {
    let markedInfinitiv: String
    let familyCode: String
    let ablautGroupName: String?
    let ablautGroupIsNew: Bool
    let pattern: String?
  }

  private func solve(
    candidate: Candidate,
    prefix: Prefix,
    expectations: [(group: Conjugationgroup, slot: String, forms: [String])],
    best: inout (mismatches: [String], checked: Int)
  ) -> Solution? {
    let word = candidate.word

    // Regular families first: they need no ablaut region and cover the large majority.
    let regularFamilies: [(Family, String)] = word.hasSuffix("ieren")
      ? [(.ieren, "i"), (.weak, "w")]
      : [(.weak, "w")]

    for (family, code) in regularFamilies {
      install(word: word, family: family, prefix: prefix)
      let mismatches = verify(word: word, prefix: prefix, expectations: expectations)
      if mismatches.isEmpty {
        return Solution(
          markedInfinitiv: Self.marked(word: word, prefix: prefix, region: nil),
          familyCode: code,
          ablautGroupName: nil,
          ablautGroupIsNew: false,
          pattern: nil
        )
      }
      record(mismatches, count: expectations.count, into: &best)
    }

    let stammLength = word.hasSuffix("en") ? word.count - 2 : word.count - 1
    let prefixLength = Self.length(of: prefix)
    guard stammLength > prefixLength else { return nil }

    // Shortest regions first, so k^om^men beats k^omm^en when both verify.
    let regions = Self.regions(in: word, from: prefixLength, to: stammLength)

    for (familyKind, code) in [(FamilyKind.strong, "s"), (FamilyKind.mixed, "m")] {
      for region in regions {
        guard let derived = derive(
          word: word,
          prefix: prefix,
          familyKind: familyKind,
          region: region,
          expectations: expectations
        ) else {
          continue
        }

        let minimized = minimize(
          ablauts: derived,
          word: word,
          prefix: prefix,
          familyKind: familyKind,
          region: region,
          expectations: expectations
        )

        // A group whose every replacement merely extends the original region encodes
        // no ablaut at all — it is Conjugator's missing epenthetic e wearing a
        // costume, arbeit → arbeite. Such a verb is weak and belongs in the queue,
        // not in a fabricated ablaut group. Genuine groups that happen to carry an
        // e for the same phonological reason, like binden's INDE beside AND, survive
        // because the test is on the group as a whole.
        let original = String(Array(word)[region])
        guard minimized.values.contains(where: { !$0.lowercased().hasPrefix(original.lowercased()) }) else {
          continue
        }

        let normalized = minimized.mapValues { $0.lowercased() }
        let match = shippedAblautGroups
          .sorted { $0.key < $1.key }
          .first { $0.value.mapValues { $0.lowercased() } == normalized }
        return Solution(
          markedInfinitiv: Self.marked(word: word, prefix: prefix, region: region),
          familyCode: code,
          ablautGroupName: match?.key ?? word,
          ablautGroupIsNew: match == nil,
          pattern: Self.pattern(from: minimized)
        )
      }
    }

    return nil
  }

  private enum FamilyKind {
    case strong
    case mixed

    func family(group: String, region: Range<Int>) -> Family {
      switch self {
      case .strong:
        return .strong(ablautGroup: group, ablautStartIndex: region.lowerBound, ablautEndIndex: region.upperBound)
      case .mixed:
        return .mixed(ablautGroup: group, ablautStartIndex: region.lowerBound, ablautEndIndex: region.upperBound)
      }
    }
  }

  /// For each slot, finds the replacement that makes Conjugator reproduce Wiktionary's
  /// form, then verifies the assembled group reproduces the whole table. Returns nil
  /// the moment a slot admits no replacement, which is what kills a wrong region.
  ///
  /// The replacement is searched rather than read off the probe because Conjugator's
  /// ending depends on the stem's final letter: beißen's Präsens 2s is beißt, not
  /// beißst, so a probe's ending is not the real one. Only the probe's head — the
  /// untouched text to the left of the region — is reliable, and it bounds the search
  /// to the suffixes of the expected form.
  private func derive(
    word: String,
    prefix: Prefix,
    familyKind: FamilyKind,
    region: Range<Int>,
    expectations: [(group: Conjugationgroup, slot: String, forms: [String])]
  ) -> [Conjugationgroup: String]? {
    let family = familyKind.family(group: Self.syntheticGroupKey, region: region)
    var ablauts: [Conjugationgroup: String] = [:]

    for expectation in expectations {
      let accepted = Self.accepted(expectation: expectation, prefix: prefix)

      install(word: word, family: family, prefix: prefix)
      installAblauts(ablauts)
      if case .success(let produced) = Conjugator.conjugate(infinitiv: word, conjugationgroup: expectation.group),
         accepted.contains(produced.lowercased()) {
        continue
      }
      guard Self.isAblautable(expectation.group) else { return nil }

      installAblauts([expectation.group: Self.sentinel])
      guard
        case .success(let template) = Conjugator.conjugate(infinitiv: word, conjugationgroup: expectation.group),
        let sentinelRange = template.range(of: Self.sentinel)
      else {
        return nil
      }
      let head = String(template[template.startIndex ..< sentinelRange.lowerBound]).lowercased()

      guard let replacement = search(
        head: head,
        accepted: accepted,
        group: expectation.group,
        word: word,
        family: family,
        prefix: prefix,
        siblings: ablauts
      ) else {
        return nil
      }
      ablauts[expectation.group] = replacement
    }

    guard !ablauts.isEmpty else { return nil }

    install(word: word, family: family, prefix: prefix)
    installAblauts(ablauts)
    guard verify(word: word, prefix: prefix, expectations: expectations).isEmpty else { return nil }
    return ablauts
  }

  /// Every prefix of the expected form beyond the probe's head is a replacement
  /// candidate; the one Conjugator turns back into the expected form wins.
  private func search(
    head: String,
    accepted: Set<String>,
    group: Conjugationgroup,
    word: String,
    family: Family,
    prefix: Prefix,
    siblings: [Conjugationgroup: String]
  ) -> String? {
    for expected in accepted.sorted() {
      guard expected.hasPrefix(head) else { continue }
      let rest = expected.dropFirst(head.count)
      guard !rest.isEmpty else { continue }
      for length in 1 ... rest.count {
        let replacement = String(rest.prefix(length)).uppercased()
        var trial = siblings
        trial[group] = replacement
        install(word: word, family: family, prefix: prefix)
        installAblauts(trial)
        if case .success(let produced) = Conjugator.conjugate(infinitiv: word, conjugationgroup: group),
           accepted.contains(produced.lowercased()) {
          return replacement
        }
      }
    }
    return nil
  }

  /// Drops every entry the Conjugator can infer on its own — chiefly the e→i
  /// Imperativ stem change, which `applyEToIStemChange` derives from the Präsens 2s
  /// ablaut. Without this the derived group would never equal a shipped one.
  private func minimize(
    ablauts: [Conjugationgroup: String],
    word: String,
    prefix: Prefix,
    familyKind: FamilyKind,
    region: Range<Int>,
    expectations: [(group: Conjugationgroup, slot: String, forms: [String])]
  ) -> [Conjugationgroup: String] {
    var minimized = ablauts
    for key in ablauts.keys {
      var trial = minimized
      trial.removeValue(forKey: key)
      guard !trial.isEmpty else { continue }
      install(word: word, family: familyKind.family(group: Self.syntheticGroupKey, region: region), prefix: prefix)
      installAblauts(trial)
      if verify(word: word, prefix: prefix, expectations: expectations).isEmpty {
        minimized = trial
      }
    }
    install(word: word, family: familyKind.family(group: Self.syntheticGroupKey, region: region), prefix: prefix)
    installAblauts(minimized)
    return minimized
  }

  private func verify(
    word: String,
    prefix: Prefix,
    expectations: [(group: Conjugationgroup, slot: String, forms: [String])]
  ) -> [String] {
    var mismatches: [String] = []
    for expectation in expectations {
      guard case .success(let produced) = Conjugator.conjugate(infinitiv: word, conjugationgroup: expectation.group) else {
        mismatches.append("\(expectation.slot): conjugation failed")
        continue
      }
      let accepted = Self.accepted(expectation: expectation, prefix: prefix)
      if !accepted.contains(produced.lowercased()) {
        mismatches.append("\(expectation.slot): expected \(expectation.forms.joined(separator: "/")), got \(produced)")
      }
    }
    return mismatches
  }

  /// Every spelling of a slot that should count as a match, lowercased.
  ///
  /// Three tolerances, each grounded in the data rather than in leniency. Conjugator
  /// uppercases ablaut regions for the highlighting convention (sAng), so comparison
  /// is case-insensitive. Wiktionary lists a separable verb's finite forms both joined
  /// and split (abbeiße beside beiße ab) while Conjugator joins everywhere but the
  /// Imperativ, so both spellings are admitted. And the Imperativ 2s -e is optional in
  /// standard German (beiß / beiße), so it is allowed either way.
  private static func accepted(
    expectation: (group: Conjugationgroup, slot: String, forms: [String]),
    prefix: Prefix
  ) -> Set<String> {
    var accepted: Set<String> = []
    for form in expectation.forms {
      var spellings = [form]
      if case .separable(let particle) = prefix {
        let suffix = " " + particle
        if form.hasSuffix(suffix) {
          spellings.append(particle + form.dropLast(suffix.count))
        }
      }
      if case .imperativ(.secondSingular) = expectation.group {
        // The optional -e attaches to the verb, not to a trailing separable particle.
        spellings += spellings.map { spelling in
          var tokens = spelling.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
          tokens[0] = tokens[0].hasSuffix("e") ? String(tokens[0].dropLast()) : tokens[0] + "e"
          return tokens.joined(separator: " ")
        }
      }
      accepted.formUnion(spellings.map { $0.lowercased() })
    }
    return accepted
  }

  private func record(_ mismatches: [String], count: Int, into best: inout (mismatches: [String], checked: Int)) {
    if mismatches.count < best.checked {
      best = (mismatches, mismatches.count)
    }
  }

  // MARK: World mutation

  private func install(word: String, family: Family, prefix: Prefix) {
    Verb.verbs[word] = Verb(
      infinitiv: word,
      translation: "",
      family: family,
      auxiliary: .haben,
      frequency: 0,
      prefix: prefix,
      frequencyIcon: "figure",
      auxiliaryIsRegional: false
    )
  }

  private func installAblauts(_ ablauts: [Conjugationgroup: String]) {
    var group = AblautGroup(exemplar: Self.syntheticGroupKey, xmlString: "x,pp")
    group.ablauts = ablauts
    AblautGroup.ablautGroups[Self.syntheticGroupKey] = group
  }

  // MARK: Prefixes

  private func prefixHypotheses(for candidate: Candidate) -> [Prefix] {
    let word = candidate.word
    var hypotheses: [Prefix] = []

    // The Perfektpartizip usually decides separability — an+ge+kommen against
    // ver+standen — but Wiktionary omits the ge on some doubly prefixed verbs, so a
    // finite form written with a trailing particle counts as evidence too.
    let participles = candidate.forms["perfektpartizip"] ?? []
    let split = Set(candidate.forms.values.flatMap { $0 }.compactMap { $0.split(separator: " ").last.map(String.init) })

    for prefix in separablePrefixes where word.hasPrefix(prefix) && word.count - prefix.count >= Verb.minVerbLength {
      if participles.contains(where: { $0.hasPrefix(prefix + "ge") }) || split.contains(prefix) {
        hypotheses.append(.separable(prefix))
      }
    }
    for prefix in inseparablePrefixes where word.hasPrefix(prefix) && word.count - prefix.count >= Verb.minVerbLength {
      if participles.contains(where: { !$0.hasPrefix("ge") || word.hasPrefix("ge") }) {
        hypotheses.append(.inseparable(prefix))
      }
    }
    hypotheses.append(.none)
    return hypotheses
  }

  private static func familyCode(_ family: Family) -> String {
    switch family {
    case .strong:
      return "s"
    case .mixed:
      return "m"
    case .weak:
      return "w"
    case .ieren:
      return "i"
    }
  }

  private static func length(of prefix: Prefix) -> Int {
    switch prefix {
    case .separable(let value), .inseparable(let value):
      return value.count
    case .none:
      return 0
    }
  }

  // MARK: Expectations

  private static func expectations(from forms: [String: [String]]) -> [(group: Conjugationgroup, slot: String, forms: [String])] {
    // Präteritum and Perfektpartizip lead: they are where ablaut shows, so a wrong
    // region dies on the first slot instead of after twenty-odd needless probes.
    let priority = ["präteritumIndikativ.fs": 0, "perfektpartizip": 1, "präsensIndikativ.ts": 2, "präteritumKonjunktivII.fs": 3]
    return forms.compactMap { slot, values in
      guard let group = conjugationgroup(slot: slot), !values.isEmpty else { return nil }
      return (group, slot, values)
    }
    .sorted { ((priority[$0.slot] ?? 9), $0.slot) < ((priority[$1.slot] ?? 9), $1.slot) }
  }

  private static func conjugationgroup(slot: String) -> Conjugationgroup? {
    let parts = slot.split(separator: ".", maxSplits: 1)
    let name = String(parts[0])

    if parts.count == 1 {
      switch name {
      case "perfektpartizip":
        return .perfektpartizip
      case "präsenspartizip":
        return .präsenspartizip
      default:
        return nil
      }
    }

    guard let personNumber = PersonNumber(rawValue: String(parts[1])) else { return nil }
    switch name {
    case "präsensIndikativ":
      return .präsensIndikativ(personNumber)
    case "präteritumIndikativ":
      return .präteritumIndikativ(personNumber)
    case "präsensKonjunktivI":
      return .präsensKonjunktivI(personNumber)
    case "präteritumKonjunktivII":
      return .präteritumKonjunktivII(personNumber)
    case "imperativ":
      return .imperativ(personNumber)
    default:
      return nil
    }
  }

  private static func isAblautable(_ group: Conjugationgroup) -> Bool {
    switch group {
    case .präsensIndikativ, .präsensKonjunktivI, .präteritumIndikativ, .präteritumKonjunktivII, .imperativ, .perfektpartizip:
      return true
    case .präsenspartizip, .perfektIndikativ, .perfektKonjunktivI, .plusquamperfektIndikativ,
         .plusquamperfektKonjunktivII, .futurIndikativ, .futurKonjunktivI, .futurKonjunktivII:
      return false
    }
  }

  // MARK: Regions and rendering

  private static func regions(in word: String, from lowerLimit: Int, to upperLimit: Int) -> [Range<Int>] {
    let characters = Array(word)
    var regions: [Range<Int>] = []
    for length in 1 ... max(1, upperLimit - lowerLimit) {
      for start in lowerLimit ... max(lowerLimit, upperLimit - length) {
        let end = start + length
        guard end <= upperLimit else { continue }
        // German ablaut alternates a vowel nucleus and whatever consonants travel with
        // it, so a region always opens on a vowel: k^om^men, schn^eid^en, br^ing^en.
        guard let first = characters[start ..< end].first, "aeiouäöü".contains(first) else { continue }
        regions.append(start ..< end)
      }
    }
    return regions
  }

  private static func marked(word: String, prefix: Prefix, region: Range<Int>?) -> String {
    var characters = Array(word)
    if let region {
      characters.insert("^", at: region.upperBound)
      characters.insert("^", at: region.lowerBound)
    }
    switch prefix {
    case .separable(let value):
      characters.insert("+", at: value.count)
    case .inseparable(let value):
      characters.insert("*", at: value.count)
    case .none:
      break
    }
    return String(characters)
  }

  private static func pattern(from ablauts: [Conjugationgroup: String]) -> String {
    var byReplacement: [String: [Conjugationgroup]] = [:]
    for (group, replacement) in ablauts {
      byReplacement[replacement, default: []].append(group)
    }
    let entries = byReplacement.map { replacement, groups in
      (replacement, codes(for: groups))
    }
    .sorted { $0.1.joined() < $1.1.joined() }

    return entries.map { "\($0.0),\($0.1.joined(separator: ","))" }.joined(separator: "|")
  }

  private static func codes(for groups: [Conjugationgroup]) -> [String] {
    var byTense: [String: Set<String>] = [:]
    var flat: [String] = []

    for group in groups {
      switch group {
      case .perfektpartizip:
        flat.append("pp")
      case .präsensIndikativ(let personNumber):
        byTense["a", default: []].insert(code(for: personNumber))
      case .präteritumIndikativ(let personNumber):
        byTense["b", default: []].insert(code(for: personNumber))
      case .präsensKonjunktivI(let personNumber):
        byTense["c", default: []].insert(code(for: personNumber))
      case .präteritumKonjunktivII(let personNumber):
        byTense["d", default: []].insert(code(for: personNumber))
      case .imperativ(let personNumber):
        byTense["i", default: []].insert(code(for: personNumber))
      default:
        break
      }
    }

    for (tense, personNumbers) in byTense.sorted(by: { $0.key < $1.key }) {
      let all = tense == "i"
        ? Set(PersonNumber.imperativPersonNumbers.map(code(for:)))
        : Set(PersonNumber.allCases.map(code(for:)))
      if personNumbers == all {
        flat.append("\(tense)A")
      } else {
        flat.append(contentsOf: personNumbers.sorted().map { "\(tense)\($0)" })
      }
    }
    return flat.sorted()
  }

  private static func code(for personNumber: PersonNumber) -> String {
    switch personNumber {
    case .firstSingular:
      return "1s"
    case .secondSingular:
      return "2s"
    case .thirdSingular:
      return "3s"
    case .firstPlural:
      return "1p"
    case .secondPlural:
      return "2p"
    case .thirdPlural:
      return "3p"
    }
  }

  // MARK: Glosses and auxiliary

  private static func shortened(_ gloss: String) -> String {
    var text = gloss
    if text.hasPrefix("to ") {
      text = String(text.dropFirst(3))
    }
    return String(text.prefix(60))
  }

  private static func auxiliary(from values: [String]) -> (code: String?, isDual: Bool) {
    guard let value = values.first(where: { $0.contains("or") }) ?? values.first else {
      return (nil, false)
    }
    if value.contains("or") {
      // kaikki's ordering names the primary reading first; the interim policy in
      // prompts/dual_auxiliary.md governs which one ships.
      return (value.hasPrefix("sein") ? "s" : "h", true)
    }
    return (value == "sein" ? "s" : "h", false)
  }
}
