// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

// Phase 1 of prompts/uses_etymologies.md: drive Conjugator over the whole corpus and emit a
// form → lemma map, so that the Phase 2 indexer can match corpus tokens deterministically
// instead of making subagents search 6.5 MB of German prose per verb.
//
// Consumes: Verb.verbs and AblautGroup.ablautGroups, as loaded by the test host app.
// Produces: JSON at $KONJUGIEREN_FORMS_OUT, shaped
//
//   { "angefangen": [{"verb": "anfangen", "contiguous": true}],
//     "fängt":      [{"verb": "anfangen", "contiguous": false, "particle": "an"},
//                    {"verb": "fangen",   "contiguous": true}] }
//
// Run: TEST_RUNNER_KONJUGIEREN_FORMS_OUT="$PWD/corpus/working/forms.json" \
//        "$IBV_SCRIPTS/run_tests.sh" --only-testing "KonjugierenTests/CorpusFormsDump/dumpForms()"
//
// The TEST_RUNNER_ prefix is required and is stripped by xcodebuild before the variable
// reaches the test process; the bare name stays invisible to the simulator, leaving the
// gate below false and the suite silently skipped. Same convention as
// docs/verb-classification.md.
//
// Gated on the environment variable, like VerbClassificationTests, so that ordinary test
// runs neither write files nor pay the cost of ~3,572 verbs × ~30 conjugations.
//
// Three things about Conjugator's output shape drive the design here, none of them obvious
// from the call site:
//
// 1. Conjugations come back MIXED CASE. applyAblaut splices the replacement region from
//    AblautGroups.xml in uppercase, so singen's Präteritum is "sAng". That casing is
//    highlighting metadata for the UI, not orthography, so every form is lowercased before
//    it becomes a key. Character COUNTS survive lowercasing, which is why prefix stripping
//    below can safely operate on the raw string.
//
// 2. Only the Imperativ splits a separable prefix. conjugateSimpleTense returns
//    stamm + ending with the prefix still attached ("anfängt"), because the app displays
//    paradigms rather than sentences and a paradigm cell has no clause to strand a particle
//    in. Real main-clause German writes "er fängt … an", which is the single largest
//    matching problem this pipeline faces — 76% of the target verbs take a separable
//    prefix. So the split finite forms are SYNTHESIZED here rather than harvested, by
//    dropping the separable run off each contiguous finite form.
//
// 3. Compound conjugationgroups are deliberately NOT enumerated. conjugateCompoundTense
//    returns auxiliary + " " + secondPart, where the second part is either the
//    Perfektpartizip or the bare infinitive — both of which this harness already emits
//    directly. Walking the compound groups would add no form for the verb itself while
//    mapping "habe" and "werde" onto every verb in the corpus, which is a false
//    attestation: "habe" attests haben, and haben emits it from its own Präsens.
//
// Every reading is walked, not just the primary one, because readings differ in family and
// therefore in forms — hängen is both hing and hängte, and both attest hängen.
//
// A form maps to SEVERAL verbs and disambiguation is deliberately left to the Phase 4
// subagent, which has the sentence in front of it. Cf. Conjugar's fue → ir/ser.

@MainActor
@Suite("CorpusFormsDump", .enabled(if: ProcessInfo.processInfo.environment["KONJUGIEREN_FORMS_OUT"] != nil))
struct CorpusFormsDumpTests {
  /// The four groups whose forms are finite, single-token, and prefix-contiguous. These are
  /// the ones that strand their particle in a main clause, so each also yields a split form.
  private static let finiteFactories: [(PersonNumber) -> Conjugationgroup] = [
    Conjugationgroup.präsensIndikativ,
    Conjugationgroup.präsensKonjunktivI,
    Conjugationgroup.präteritumIndikativ,
    Conjugationgroup.präteritumKonjunktivII
  ]

  /// Injected by conjugateImperativ for the two persons that carry one. Not part of any form.
  private static let imperativPronouns: Set<String> = ["wir", "Sie"]

  @Test func dumpForms() throws {
    let outputPath = ProcessInfo.processInfo.environment["KONJUGIEREN_FORMS_OUT"] ?? ""
    var index = FormIndex()

    for infinitiv in Verb.verbs.keys.sorted() {
      guard let verb = Verb.verbs[infinitiv] else {
        continue
      }
      for readingIndex in verb.readings.indices {
        collectForms(verb: verb, readingIndex: readingIndex, into: &index)
      }
    }

    let map = index.finished()
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    try encoder.encode(map).write(to: URL(fileURLWithPath: outputPath))

    let splitForms = map.values.filter { $0.contains { !$0.contiguous } }.count
    print("dumped \(map.count) forms (\(splitForms) with a split reading) → \(outputPath)")

    // Anchors rather than a count: anfangen is the pipeline's worked example, and a form
    // shared with its own base verb is exactly the ambiguity Phase 4 must resolve.
    #expect(map["angefangen"]?.contains { $0.verb == "anfangen" && $0.contiguous } == true)
    #expect(map["fängt"]?.contains { $0.verb == "anfangen" && $0.particle == "an" } == true)
    #expect(map["fängt"]?.contains { $0.verb == "fangen" && $0.contiguous } == true)
  }

  private func collectForms(verb: Verb, readingIndex: Int, into index: inout FormIndex) {
    guard let reading = verb.reading(at: readingIndex) else {
      return
    }
    let lemma = verb.infinitiv
    let run = reading.prefixes.separableRun

    index.add(form: reading.infinitiv, lemma: lemma, particle: nil)

    // The zu-infinitive is contiguous only when a separable prefix wraps the zu:
    // anzufangen, but "zu vermeiden" as two tokens, which the plain infinitive covers.
    if !run.isEmpty {
      index.add(form: run + "zu" + reading.infinitiv.dropFirst(run.count), lemma: lemma, particle: nil)
    }

    for group in [Conjugationgroup.perfektpartizip, .präsenspartizip] {
      if let form = conjugate(verb: verb, readingIndex: readingIndex, group: group) {
        index.add(form: form, lemma: lemma, particle: nil)
      }
    }

    for factory in Self.finiteFactories {
      for personNumber in PersonNumber.allCases {
        guard let form = conjugate(verb: verb, readingIndex: readingIndex, group: factory(personNumber)) else {
          continue
        }
        index.add(form: form, lemma: lemma, particle: nil)
        if let stranded = strandingParticle(form: form, run: run) {
          index.add(form: stranded, lemma: lemma, particle: run)
        }
      }
    }

    for personNumber in PersonNumber.imperativPersonNumbers {
      guard
        let form = conjugate(verb: verb, readingIndex: readingIndex, group: .imperativ(personNumber)),
        // Already split by withSeparablePrefix, and possibly carrying an injected pronoun,
        // so only the head token is the verb: "fangen wir an" contributes "fangen".
        let head = form.split(separator: " ").first.map(String.init),
        !Self.imperativPronouns.contains(head)
      else {
        continue
      }
      index.add(form: head, lemma: lemma, particle: run.isEmpty ? nil : run)
    }
  }

  /// The main-clause form of `form`, with its separable run stranded at clause end, or nil
  /// when the verb has no separable prefix.
  ///
  /// The `hasPrefix` test is not redundant with `run.isEmpty`. An ablaut group may fully
  /// override the stem — the trailing `*` convention in AblautGroups.xml — and a full
  /// override replaces the stem outright, prefix and all, so the run is not guaranteed to
  /// survive into the conjugated form. Dropping a fixed character count from such a form
  /// would silently emit a mangled token.
  private func strandingParticle(form: String, run: String) -> String? {
    guard !run.isEmpty, form.lowercased().hasPrefix(run.lowercased()) else {
      return nil
    }
    return String(form.dropFirst(run.count))
  }

  private func conjugate(verb: Verb, readingIndex: Int, group: Conjugationgroup) -> String? {
    switch Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: group, readingIndex: readingIndex) {
    case .success(let form):
      return form
    case .failure:
      return nil
    }
  }
}

/// Accumulates form → lemma entries, deduplicating readings and conjugationgroups that
/// produce the same token, and lowercasing every key and every emitted particle.
private struct FormIndex {
  private var map: [String: [FormEntry]] = [:]
  private var seen: Set<String> = []

  mutating func add(form: some StringProtocol, lemma: String, particle: String?) {
    let key = form.lowercased()
    guard !key.isEmpty else {
      return
    }
    let particleKey = particle?.lowercased()
    let dedupeKey = "\(key)|\(lemma)|\(particleKey ?? "")"
    guard seen.insert(dedupeKey).inserted else {
      return
    }
    map[key, default: []].append(
      FormEntry(verb: lemma, contiguous: particleKey == nil, particle: particleKey)
    )
  }

  /// Entries sorted contiguous-first, then by lemma, so the file is stable across runs and
  /// the reading likeliest to be a whole-word match leads.
  func finished() -> [String: [FormEntry]] {
    map.mapValues { entries in
      entries.sorted {
        $0.contiguous == $1.contiguous ? $0.verb < $1.verb : $0.contiguous
      }
    }
  }
}

private struct FormEntry: Encodable {
  let verb: String
  let contiguous: Bool
  /// Omitted for contiguous forms, since JSONEncoder drops nil optionals.
  let particle: String?
}
