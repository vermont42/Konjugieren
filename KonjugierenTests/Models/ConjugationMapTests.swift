// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("ConjugationMap")
struct ConjugationMapTests {
  @MainActor
  @Suite("The bundled map")
  struct Bundled {
    // The build phase regenerates the map when Verbs.xml, AblautGroups.xml, or the tool's
    // executable is newer than it. This catches the case that dependency analysis misses: a
    // source the Conjugator depends on that the tool does not compile, so that the app and
    // the map disagree.
    @Test func matchesAFreshBuild() {
      let bundled = ConjugationMap.bundled
      let fresh = ConjugationMap.build()
      let keys = Set(bundled.entriesByConjugation.keys).union(fresh.entriesByConjugation.keys)
      let differing = keys.filter { bundled.entriesByConjugation[$0] != fresh.entriesByConjugation[$0] }.sorted()
      #expect(bundled.entriesByConjugation.count > 50_000)
      #expect(differing.isEmpty, "Stale entries, first few: \(differing.prefix(5))")
    }

    // The method is Scan 2 of plans/fix-reference-defects.md, so that this test and that scan
    // count the same thing. ß and ss are folded on both sides, as search folds them, so Kafka's
    // läßt counts. A finite part counts only when its particle is also in the sentence: halt
    // attests warmhalten only beside warm. On 2026-11-12 it found 3,547 of 3,572 (99.3%). The
    // 25 misses are sorted in docs/browse-and-verb-ideas.md, "Appendix: What the Map Misses":
    // conjugations the Conjugator does not produce, adjective endings, short imperatives, and
    // spellings older than the ß rule.
    @Test func findsTheVerbOfNearlyEveryExampleSentence() {
      func fold(_ text: some StringProtocol) -> String {
        text.lowercased().replacingOccurrences(of: "ß", with: "ss")
      }
      var foldedEntries: [String: [ConjugationMap.Entry]] = [:]
      for (conjugation, entries) in ConjugationMap.bundled.entriesByConjugation {
        foldedEntries[fold(conjugation), default: []].append(contentsOf: entries)
      }
      let letters = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzÄÖÜäöüß")

      var sentenceCount = 0
      var foundCount = 0
      for infinitiv in Verb.verbs.keys {
        guard let sentence = ExampleSentences.pair(for: infinitiv)?.german.sentence else {
          continue
        }
        sentenceCount += 1
        let words = sentence.split { !letters.contains($0) }.map(fold)
        let wordSet = Set(words)
        let found = words.contains { word in
          foldedEntries[word, default: []].contains { entry in
            entry.infinitiv == infinitiv && (entry.particle.map { wordSet.contains(fold($0)) } ?? true)
          }
        }
        if found {
          foundCount += 1
        }
      }
      #expect(sentenceCount > 3_500)
      #expect(Double(foundCount) / Double(sentenceCount) >= 0.99, "Found \(foundCount) of \(sentenceCount)")
    }
  }

  @MainActor
  @Suite("Entries")
  struct Entries {
    @Test(arguments: [
      ("ging", "gehen", nil),
      ("Ging", "gehen", nil),
      ("sang", "singen", nil),
      ("angefangen", "anfangen", nil),
      ("anzufangen", "anfangen", nil),
      ("fängt", "fangen", nil),
      ("fängt", "anfangen", "an"),
      ("gehört", "hören", nil),
      ("gehört", "gehören", nil),
      ("hing", "hängen", nil),
      ("hängte", "hängen", nil),
      ("steh", "aufstehen", "auf"),
    ] as [(String, String, String?)])
    func contains(conjugation: String, infinitiv: String, particle: String?) {
      #expect(ConjugationMap.bundled.entries(for: conjugation).contains(ConjugationMap.Entry(infinitiv: infinitiv, particle: particle)))
    }

    @Test func wholeVerbsComeBeforeFiniteParts() {
      let entries = ConjugationMap.bundled.entries(for: "halte")
      #expect(entries.first == ConjugationMap.Entry(infinitiv: "halten", particle: nil))
      #expect(entries.dropFirst().allSatisfy { $0.particle != nil })
      #expect(entries.count > 60)
    }

    @Test func compoundConjugationsHaveNoEntries() {
      #expect(ConjugationMap.bundled.entries(for: "hat gefunden").isEmpty)
      #expect(ConjugationMap.bundled.entries(for: "gefunden").contains(ConjugationMap.Entry(infinitiv: "finden", particle: nil)))
    }

    @Test func unknownTextHasNoEntries() {
      #expect(ConjugationMap.bundled.entries(for: "xyzzy").isEmpty)
    }
  }

  @Suite("Format")
  struct Format {
    let map = ConjugationMap(entriesByConjugation: [
      "fängt": [
        ConjugationMap.Entry(infinitiv: "fangen", particle: nil),
        ConjugationMap.Entry(infinitiv: "anfangen", particle: "an"),
      ],
      "ging": [ConjugationMap.Entry(infinitiv: "gehen", particle: nil)],
    ])

    @Test func writesOneLinePerConjugation() {
      #expect(map.text == "fängt\tfangen\tanfangen an\nging\tgehen")
    }

    @Test func readsWhatItWrites() throws {
      #expect(ConjugationMap(text: map.text) == map)
      #expect(try ConjugationMap(compressed: map.compressed()) == map)
    }
  }
}
