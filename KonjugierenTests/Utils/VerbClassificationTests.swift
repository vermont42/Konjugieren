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
  /// True when the verb ships today but Verbs.xml's own encoding of it did not reproduce
  /// Wiktionary's table, even though some other hypothesis did.
  ///
  /// Without this the at-odds count silently undercounts. `ablautGroupIsNew` catches only a
  /// verb whose repair needs a group that does not ship; a verb repairable with a group that
  /// *does* ship (beschreiben, scheinen, schwimmen) was reported "verified" while the app
  /// went on conjugating it wrongly.
  let shippedEncodingFailed: Bool
  /// How many readings the verb ships with. A verb with more than one cannot be judged by
  /// `shippedEncodingFailed` alone: the classifier tests only the primary reading, against a
  /// Wiktionary table that aggregates every sense, so a verb whose table happens to describe
  /// the *second* reading registers as a failure that is not one.
  let readingCount: Int
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
      for prefix in verb.primaryReading.prefixes {
        switch prefix {
        case .separable(let value):
          separable.insert(value)
        case .inseparable(let value):
          inseparable.insert(value)
        case .none:
          break
        }
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
    var shippedEncodingFailed = false

    // For a verb that already ships, the encoding in Verbs.xml is the hypothesis that
    // matters. Testing it first keeps the search from reporting an equivalent-but-
    // different encoding (n^eh^men for the shipped n^ehm^en) as though the shipped
    // one were wrong.
    if candidate.alreadyShipping, let shipped = originalVerbs[candidate.word] {
      Verb.verbs[candidate.word] = shipped
      let mismatches = verify(word: candidate.word, prefixes: shipped.primaryReading.prefixes, expectations: expectations)
      if mismatches.isEmpty {
        return Classification(
          word: candidate.word,
          alreadyShipping: true,
          status: "verified",
          markedInfinitiv: Self.marked(word: candidate.word, prefixes: shipped.primaryReading.prefixes, region: nil),
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
          mismatches: [],
          shippedEncodingFailed: false,
          readingCount: shipped.readings.count
        )
      }
      record(mismatches, count: expectations.count, into: &best)
      shippedEncodingFailed = true
    }

    for prefixes in prefixHypotheses(for: candidate) {
      if let solution = solve(candidate: candidate, prefixes: prefixes, expectations: expectations, best: &best) {
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
          mismatches: [],
          shippedEncodingFailed: shippedEncodingFailed,
          readingCount: originalVerbs[candidate.word]?.readings.count ?? 1
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
      mismatches: best.checked == .max ? ["no hypothesis produced a conjugation"] : Array(best.mismatches.prefix(6)),
      shippedEncodingFailed: shippedEncodingFailed,
      readingCount: originalVerbs[candidate.word]?.readings.count ?? 1
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
    prefixes: [Prefix],
    expectations: [(group: Conjugationgroup, slot: String, forms: [String])],
    best: inout (mismatches: [String], checked: Int)
  ) -> Solution? {
    let word = candidate.word

    // Regular families first: they need no ablaut region and cover the large majority.
    let regularFamilies: [(Family, String)] = word.hasSuffix("ieren")
      ? [(.ieren, "i"), (.weak, "w")]
      : [(.weak, "w")]

    for (family, code) in regularFamilies {
      install(word: word, family: family, prefixes: prefixes)
      let mismatches = verify(word: word, prefixes: prefixes, expectations: expectations)
      if mismatches.isEmpty {
        return Solution(
          markedInfinitiv: Self.marked(word: word, prefixes: prefixes, region: nil),
          familyCode: code,
          ablautGroupName: nil,
          ablautGroupIsNew: false,
          pattern: nil
        )
      }
      record(mismatches, count: expectations.count, into: &best)
    }

    let stammLength = word.hasSuffix("en") ? word.count - 2 : word.count - 1
    let prefixLength = prefixes.totalLength
    guard stammLength > prefixLength else { return nil }

    // Shortest regions first, so k^om^men beats k^omm^en when neither matches anything.
    let regions = Self.regions(in: word, from: prefixLength, to: stammLength)

    // But shortest-first is only the tiebreak, because a verb usually admits several regions
    // that all reproduce Wiktionary's table, and the narrowest is the one least likely to match
    // a shipping group: beissen verifies as b^ei^ssen with the replacement I, while the corpus
    // writes reißen as r^eiss^en with ISS, splitting no consonant off its vowel. Returning on
    // the first region that verified therefore proposed a brand-new group for a pattern that
    // already ships, 183 times over. Keep looking, and prefer reuse over minimality; the
    // full-table verification below is what makes that safe, since a region only reaches this
    // comparison once it is known to conjugate the whole verb correctly.
    var fallback: Solution?

    for (familyKind, code) in [(FamilyKind.strong, "s"), (FamilyKind.mixed, "m")] {
      for region in regions {
        guard let derived = derive(
          word: word,
          prefixes: prefixes,
          familyKind: familyKind,
          region: region,
          expectations: expectations
        ) else {
          continue
        }

        let minimized = minimize(
          ablauts: derived,
          word: word,
          prefixes: prefixes,
          familyKind: familyKind,
          region: region,
          expectations: expectations
        )

        // A group whose every replacement merely extends the original region encodes
        // no ablaut at all; it is Conjugator's missing epenthetic e wearing a
        // costume, arbeit → arbeite. Such a verb is weak and belongs in the queue,
        // not in a fabricated ablaut group. Genuine groups that happen to carry an
        // e for the same phonological reason, like binden's INDE beside AND, survive
        // because the test is on the group as a whole.
        let original = String(Array(word)[region])
        guard minimized.values.contains(where: { !$0.lowercased().hasPrefix(original.lowercased()) }) else {
          continue
        }

        let normalized = minimized.mapValues { $0.lowercased() }
        let sortedGroups = shippedAblautGroups.sorted { $0.key < $1.key }
        // A replacement equal to the region it replaces spells no new letters; it exists only
        // to mark the region for the mixed-case highlighting convention. treten carries one --
        // getrETen has the same et as treten, and `minimize` correctly drops it from a
        // proposal, since removing it still reproduces Wiktionary. That asymmetry alone kept
        // 20 derivatives of treten from matching a group they conjugate identically to. Ignore
        // such entries when comparing, and the derivative inherits the family's highlighting
        // rather than proposing a group that differs from it in nothing a reader would see.
        let regionText = original.lowercased()
        let match = sortedGroups.first { $0.value.mapValues { $0.lowercased() } == normalized }
          ?? sortedGroups.first {
            $0.value.mapValues { $0.lowercased() }.filter { $0.value != regionText } == normalized
          }
        let solution = Solution(
          markedInfinitiv: Self.marked(word: word, prefixes: prefixes, region: region),
          familyCode: code,
          ablautGroupName: match?.key ?? word,
          ablautGroupIsNew: match == nil,
          pattern: Self.pattern(from: minimized)
        )
        if match != nil {
          return solution
        }

        // The derived pattern is not the only one that can work, so failing to match a shipping
        // group is not proof that none reproduces the table. `derive` computes each slot's
        // replacement by string arithmetic against the expected form, which makes it prefer the
        // shortest replacement that lands: for anschreien it reads I from schrien, because
        // schr + I + en spells it, and IE from schrie, where no ending follows. That split
        // pattern verifies and matches nothing, so eight schreien derivatives proposed a new
        // group: while IE everywhere, the group schreien itself ships, verifies just as well
        // now that Conjugator absorbs the ending-initial e (schrIE + en is schrIEn).
        //
        // So before giving up, try the shipping groups themselves against the full table. This
        // runs only where the classifier would otherwise fabricate a group, which is a few dozen
        // verbs per run rather than all 9,217, so the cost is not the 73-group scan it looks
        // like. Verification is what makes preferring reuse safe here, exactly as it does above:
        // a group is adopted only once it is known to conjugate the whole verb correctly.
        for (name, ablauts) in sortedGroups {
          install(word: word, family: familyKind.family(group: Self.syntheticGroupKey, region: region), prefixes: prefixes)
          installAblauts(ablauts)
          if verify(word: word, prefixes: prefixes, expectations: expectations).isEmpty {
            return Solution(
              markedInfinitiv: Self.marked(word: word, prefixes: prefixes, region: region),
              familyCode: code,
              ablautGroupName: name,
              ablautGroupIsNew: false,
              pattern: Self.pattern(from: ablauts)
            )
          }
        }
        install(word: word, family: familyKind.family(group: Self.syntheticGroupKey, region: region), prefixes: prefixes)
        installAblauts(minimized)

        fallback = fallback ?? solution
      }
    }

    return fallback
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
  /// beißst, so a probe's ending is not the real one. Only the probe's head, the
  /// untouched text to the left of the region, is reliable, and it bounds the search
  /// to the suffixes of the expected form.
  private func derive(
    word: String,
    prefixes: [Prefix],
    familyKind: FamilyKind,
    region: Range<Int>,
    expectations: [(group: Conjugationgroup, slot: String, forms: [String])]
  ) -> [Conjugationgroup: String]? {
    let family = familyKind.family(group: Self.syntheticGroupKey, region: region)
    var ablauts: [Conjugationgroup: String] = [:]

    for expectation in expectations {
      let accepted = Self.accepted(expectation: expectation, prefixes: prefixes)

      install(word: word, family: family, prefixes: prefixes)
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
        prefixes: prefixes,
        siblings: ablauts
      ) else {
        return nil
      }
      ablauts[expectation.group] = replacement
    }

    guard !ablauts.isEmpty else { return nil }

    install(word: word, family: family, prefixes: prefixes)
    installAblauts(ablauts)
    guard verify(word: word, prefixes: prefixes, expectations: expectations).isEmpty else { return nil }
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
    prefixes: [Prefix],
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
        install(word: word, family: family, prefixes: prefixes)
        installAblauts(trial)
        if case .success(let produced) = Conjugator.conjugate(infinitiv: word, conjugationgroup: group),
           accepted.contains(produced.lowercased()) {
          return replacement
        }
      }
    }
    return nil
  }

  /// Drops every entry the Conjugator can infer on its own, chiefly the e→i
  /// Imperativ stem change, which `applyEToIStemChange` derives from the Präsens 2s
  /// ablaut. Without this the derived group would never equal a shipped one.
  private func minimize(
    ablauts: [Conjugationgroup: String],
    word: String,
    prefixes: [Prefix],
    familyKind: FamilyKind,
    region: Range<Int>,
    expectations: [(group: Conjugationgroup, slot: String, forms: [String])]
  ) -> [Conjugationgroup: String] {
    var minimized = ablauts
    for key in ablauts.keys {
      var trial = minimized
      trial.removeValue(forKey: key)
      guard !trial.isEmpty else { continue }
      install(word: word, family: familyKind.family(group: Self.syntheticGroupKey, region: region), prefixes: prefixes)
      installAblauts(trial)
      if verify(word: word, prefixes: prefixes, expectations: expectations).isEmpty {
        minimized = trial
      }
    }
    install(word: word, family: familyKind.family(group: Self.syntheticGroupKey, region: region), prefixes: prefixes)
    installAblauts(minimized)
    return minimized
  }

  private func verify(
    word: String,
    prefixes: [Prefix],
    expectations: [(group: Conjugationgroup, slot: String, forms: [String])]
  ) -> [String] {
    var mismatches: [String] = []
    for expectation in expectations {
      guard case .success(let produced) = Conjugator.conjugate(infinitiv: word, conjugationgroup: expectation.group) else {
        mismatches.append("\(expectation.slot): conjugation failed")
        continue
      }
      let accepted = Self.accepted(expectation: expectation, prefixes: prefixes)
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
    prefixes: [Prefix]
  ) -> Set<String> {
    var accepted: Set<String> = []
    let particle = prefixes.separableRun
    for form in expectation.forms {
      var spellings = [form]
      if !particle.isEmpty {
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

  private func install(word: String, family: Family, prefixes: [Prefix]) {
    Verb.verbs[word] = Verb(
      infinitiv: word,
      hits: 0,
      hitsAreProvisional: false,
      frequency: 0,
      frequencyIcon: "figure",
      readings: [
        Reading(
          infinitiv: word,
          translation: "",
          family: family,
          auxiliary: .haben,
          prefixes: prefixes,
          auxiliaryIsRegional: false
        )
      ]
    )
  }

  private func installAblauts(_ ablauts: [Conjugationgroup: String]) {
    var group = AblautGroup(exemplar: Self.syntheticGroupKey, xmlString: "x,pp")
    group.ablauts = ablauts
    AblautGroup.ablautGroups[Self.syntheticGroupKey] = group
  }

  // MARK: Prefixes

  private func prefixHypotheses(for candidate: Candidate) -> [[Prefix]] {
    let word = candidate.word
    var hypotheses: [[Prefix]] = []

    // The Perfektpartizip usually decides separability, an+ge+kommen against
    // ver+standen, but Wiktionary omits the ge on some doubly prefixed verbs, so a
    // finite form written with a trailing particle counts as evidence too.
    let participles = candidate.forms["perfektpartizip"] ?? []
    let split = Set(candidate.forms.values.flatMap { $0 }.compactMap { $0.split(separator: " ").last.map(String.init) })

    // The shipped inventory only knows the prefixes 1,068 verbs happen to use, which left
    // 747 incoming verbs unclassifiable: nothing proposed separating the first element of
    // wegllaufen, niederschreiben, totschlagen or achtgeben, so every hypothesis failed and
    // the no-prefix fallback produced *geachtgeben* for *achtgegeben*.
    //
    // But the evidence for "this element separates" is sitting in the data: German infixes
    // the participle's ge- *after* a separable first element, so wherever Wiktionary writes
    // ge- somewhere other than the front, the text before it names the element. Reading the
    // head off each participle needs no inventory and no maintenance, and it generalizes
    // past particles to the adjective and noun compounds that behave identically:
    // kaputtgemacht, eisgelaufen, achtgegeben. A wrong guess costs nothing: every hypothesis
    // still has to reproduce the entire table before it is accepted.
    //
    // Every occurrence of "ge" is tried, not just the first, so that a head which itself
    // begins with ge- is still found: gegengehalten yields "gegen" only at the second.
    var discoveredHeads: [String] = []
    for participle in participles {
      let characters = Array(participle)
      for index in 1..<max(1, characters.count - 1) where characters[index] == "g" && characters[index + 1] == "e" {
        let head = String(characters[0..<index])
        if word.hasPrefix(head), word.count - head.count >= Verb.minVerbLength {
          discoveredHeads.append(head)
        }
      }
    }
    // Inventory first: a well-attested prefix should win over a coincidence of spelling.
    let separableCandidates = separablePrefixes + discoveredHeads.filter { !separablePrefixes.contains($0) }

    var separableHeads: [String] = []
    for prefix in separableCandidates where word.hasPrefix(prefix) && word.count - prefix.count >= Verb.minVerbLength {
      if participles.contains(where: { $0.hasPrefix(prefix + "ge") }) || split.contains(prefix) {
        hypotheses.append([.separable(prefix)])
        separableHeads.append(prefix)
      } else if split.contains(prefix) == false && participles.contains(where: { $0.hasPrefix(prefix) && !$0.hasPrefix(prefix + "ge") }) {
        // No ge after the particle is itself the signature of a separable prefix sitting
        // on an already-prefixed base: abbekommen, not abgebekommen. It is not evidence
        // of a single separable prefix, so it seeds only the two-prefix hypotheses below.
        separableHeads.append(prefix)
      }
    }
    // An inseparable prefix is exactly what suppresses the participle's ge-, so a participle
    // that shows ge- *in front of the candidate prefix* refutes the hypothesis: gebebt rules
    // be- out of beben, and gegeigt rules ge- out of geigen. Testing only for a leading ge-
    // is not enough, because a verb whose prefix genuinely is ge- also starts its participle
    // with one: gehören, gehört. The old escape hatch for that case read `word.hasPrefix("ge")`,
    // which is true of every ge-initial word and so admitted geigen, geifern and geisseln as
    // ge*-verbs; each then needed a fabricated pp-only ablaut to put the swallowed ge- back.
    // Comparing against ge- plus the prefix separates the two and survives ablaut, which the
    // stem itself does not: gewinnen's participle is gewonnen, sharing only its ge- with the
    // infinitive.
    for prefix in inseparablePrefixes where word.hasPrefix(prefix) && word.count - prefix.count >= Verb.minVerbLength {
      if participles.contains(where: { !$0.hasPrefix("ge" + prefix) }) {
        hypotheses.append([.inseparable(prefix)])
      }
    }

    // A separable prefix over an inseparable one: an+ge*hören, ab+be*kommen. The
    // participle keeps no ge because the prefix against the stem is inseparable, which
    // is precisely why a single-prefix hypothesis can never reproduce these. 1,036
    // incoming verbs have this shape.
    for head in separableHeads {
      let rest = String(word.dropFirst(head.count))
      for inner in inseparablePrefixes where rest.hasPrefix(inner) && rest.count - inner.count >= Verb.minVerbLength {
        hypotheses.append([.separable(head), .inseparable(inner)])
      }
    }

    hypotheses.append([])
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

  private static func marked(word: String, prefixes: [Prefix], region: Range<Int>?) -> String {
    var characters = Array(word)
    if let region {
      characters.insert("^", at: region.upperBound)
      characters.insert("^", at: region.lowerBound)
    }
    // Right to left, so that inserting the inner marker does not shift the offset the
    // outer one is measured against: an+ge*hören.
    var offset = prefixes.totalLength
    for prefix in prefixes.reversed() {
      switch prefix {
      case .separable(let value):
        characters.insert("+", at: offset)
        offset -= value.count
      case .inseparable(let value):
        characters.insert("*", at: offset)
        offset -= value.count
      case .none:
        break
      }
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
