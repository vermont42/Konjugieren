// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("Conjugation search")
struct ConjugationSearchTests {
  private static func matches(_ query: String, includeFiniteParts: Bool = true) -> [VerbSearch.Match] {
    VerbSearch.matches(for: query, in: Verb.verbsSortedByFrequency, includeGlosses: true, includeFiniteParts: includeFiniteParts)
  }

  private static func results(_ query: String) -> [String] {
    matches(query).map(\.verb.infinitiv)
  }

  @MainActor
  @Suite("Matching")
  struct Matching {
    // The rows of "What Search Returns" in docs/browse-and-verb-ideas.md that Phase 6 of
    // plans/browse-and-verb-implementation.md addresses.
    @Test(arguments: zip(
      ["ging", "gefunden", "war", "ist", "kam", "wurde", "geht", "muss", "will", "darf", "stand auf", "weiß"],
      ["gehen", "finden", "sein", "sein", "kommen", "werden", "gehen", "müssen", "wollen", "dürfen", "aufstehen", "wissen"]
    ))
    func conjugationFindsItsVerbFirst(query: String, wanted: String) {
      #expect(results(query).first == wanted)
    }

    @Test(arguments: ["gehört", "gestanden", "gefallen", "gedacht"])
    func sharedConjugationShowsBothVerbs(query: String) {
      let conjugationMatches = matches(query).filter { $0.kind <= .conjugation }
      #expect(conjugationMatches.count == 2)
    }

    @Test(arguments: zip(["war", "bin"], ["warten", "binden"]))
    func conjugationOutranksAnInfinitivePrefix(query: String, prefixMatch: String) throws {
      let ranked = results(query)
      let prefixIndex = try #require(ranked.firstIndex(of: prefixMatch))
      #expect(ranked.firstIndex(of: "sein") ?? .max < prefixIndex)
    }

    @Test func conjugationNamesItsConjugation() throws {
      let ging = try #require(matches("ging").first)
      #expect(ging.kind == .conjugation)
      #expect(ging.conjugation == "ging")
      #expect(ging.particle == nil)
    }

    @Test func strandedPartComesAfterItsBaseVerb() {
      let found = matches("hielt")
      #expect(found.first?.verb.infinitiv == "halten")
      let parts = found.filter { $0.kind == .finitePart }
      #expect(parts.count > 60)
      #expect(parts.contains { $0.verb.infinitiv == "aufhalten" && $0.particle == "auf" && $0.conjugation == "hielt" })
      #expect(parts.map(\.verb.frequency) == parts.map(\.verb.frequency).sorted())
    }

    // Josh, 2026-11-12: fold unless the query is itself an infinitive, so that searching gehen
    // lists its derivatives as it did before Phase 6.
    @Test(arguments: ["gehen", "kommen", "halten", "konnen"])
    func infinitiveQueryHasNoStrandedParts(query: String) {
      #expect(!matches(query).contains { $0.kind == .finitePart })
    }

    @Test func strandedPartTakesInItsSeparableVerbsButNotOthers() throws {
      let found = matches("halte")
      #expect(found.first?.verb.infinitiv == "halten")
      #expect(found.first { $0.verb.infinitiv == "aufhalten" }?.kind == .finitePart)
      #expect(found.first { $0.verb.infinitiv == "erhalten" }?.kind == .infinitiveSubstring)
    }

    @Test func pickerLeavesOutStrandedParts() {
      #expect(!matches("hielt", includeFiniteParts: false).contains { $0.kind == .finitePart })
      #expect(VerbEntityQuery.verbs(matching: "hielt").map(\.infinitiv) == ["halten"])
    }

    @Test(arguments: zip(
      ["stand auf", "steh auf", "ich stand auf", "Stand  Auf", "läßt zu"],
      ["aufstehen", "aufstehen", "aufstehen", "aufstehen", "zulassen"]
    ))
    func particleSettlesASeparableVerb(query: String, wanted: String) {
      let found = matches(query)
      #expect(found.first?.verb.infinitiv == wanted)
      #expect(found.first?.kind != .finitePart)
    }

    @Test(arguments: zip(
      ["hat gefunden", "ist gestanden", "ich bin gegangen", "wird gehen", "ich ging"],
      ["finden", "stehen", "gehen", "gehen", "gehen"]
    ))
    func compoundOrPronounedConjugationFindsItsVerb(query: String, wanted: String) {
      #expect(results(query).first == wanted)
    }

    @Test func compoundConjugationIsConfirmedByTheVerbsCells() {
      #expect(results("hat gegangen").isEmpty)
    }

    @Test(arguments: zip(
      ["muß", "läßt", "wußte", "gehort"],
      ["müssen", "lassen", "wissen", "gehören"]
    ))
    func olderAndUnumlautedSpellingsFindTheirVerb(query: String, wanted: String) throws {
      let found = matches(query)
      let match = try #require(found.first { $0.verb.infinitiv == wanted })
      #expect(match.kind == .foldedConjugation)
      #expect(found.first?.kind == .foldedConjugation)
    }

    @Test func foldedConjugationNamesTheAppsSpelling() {
      #expect(matches("muß").first?.conjugation == "muss")
    }

    @Test(arguments: zip(
      ["geklebte", "vorgeschlagenen", "laufende", "gemachtes"],
      [("kleben", "geklebt"), ("vorschlagen", "vorgeschlagen"), ("laufen", "laufend"), ("machen", "gemacht")]
    ))
    func participleWithAnAdjectiveEndingFindsItsVerb(query: String, wanted: (infinitiv: String, conjugation: String)) throws {
      let match = try #require(matches(query).first { $0.verb.infinitiv == wanted.infinitiv })
      #expect(match.conjugation == wanted.conjugation)
    }

    // gehorten is wir gehörten once folded, so it needs no ending stripped to find gehören.
    @Test func endingIsStrippedOnlyWhenNothingElseMatches() {
      #expect(matches("gehorten").first?.conjugation == "gehörten")
    }

    @Test func endingIsStrippedOnlyFromAParticiple() {
      #expect(!matches("zahlte").contains { $0.conjugation == "zahlt" })
    }
  }

  @MainActor
  @Suite("Results")
  struct Results {
    private func results(_ query: String) -> VerbSearchResults {
      VerbSearchResults(query: query, verbs: Verb.verbsSortedByFrequency, includeGlosses: true)
    }

    @Test func strandedPartFoldsItsVerbsIntoOneRowAfterTheBaseVerb() throws {
      let found = results("hielt")
      guard case .hit(let halten) = found.rows.first, case .separableVerbs(let hits) = found.rows.dropFirst().first else {
        Issue.record("Expected halten, then the separable verbs")
        return
      }
      #expect(halten.verb.infinitiv == "halten")
      #expect(hits.count > 60)
      #expect(found.matchCount == hits.count + 1)
      #expect(hits.first?.conjugation?.shownConjugation.hasPrefix("hielt … ") == true)
    }

    @Test func openRowShowsItsVerbsAfterIt() {
      let found = results("hielt")
      let closed = found.entries(separableVerbsAreShown: false)
      let open = found.entries(separableVerbsAreShown: true)
      #expect(closed.count == found.rows.count)
      #expect(open.count == found.matchCount + 1)
      #expect(open[1].id == VerbSearchResults.Entry.separableVerbsID)
      if case .hit(_, let isInSeparableVerbs) = open[2] {
        #expect(isInSeparableVerbs)
      } else {
        Issue.record("Expected a separable verb after the row")
      }
    }

    @Test func infinitiveQueryHasNoFoldedRow() {
      #expect(!results("gehen").rows.contains { row in
        if case .separableVerbs = row {
          return true
        }
        return false
      })
    }

    // A conjugation that strands in exactly one separable verb gets that verb's own row, since
    // a folded row of one would only hide it.
    @Test func lonePartIsAnOrdinaryRow() throws {
      let map = ConjugationMap.bundled
      let lone = try #require(map.entriesByConjugation.first { key, entries in
        entries.count == 1 && entries[0].particle != nil && Verb.verbs[key] == nil && !key.contains(" ")
      })
      let found = results(lone.key)
      #expect(found.rows.allSatisfy { row in
        if case .hit = row {
          return true
        }
        return false
      })
      #expect(found.rows.contains { row in
        if case .hit(let hit) = row {
          return hit.kind == .finitePart
        }
        return false
      })
    }

    @Test func emptySearchHasAGuessWithItsConjugation() throws {
      let found = results("ginng")
      #expect(found.isEmpty)
      let guess = try #require(found.guess)
      #expect(guess.verb.infinitiv == "gehen")
      #expect(guess.conjugation?.text == "ging")
      #expect(guess.conjugation?.conjugationgroups.isEmpty == false)
    }

    @Test func searchWithResultsHasNoGuess() {
      #expect(results("ging").guess == nil)
    }
  }

  @MainActor
  @Suite("Matched conjugation")
  struct Matched {
    private func whole(_ text: String, of infinitiv: String) throws -> MatchedConjugation {
      MatchedConjugation(whole: text, of: try #require(Verb.verbs[infinitiv]))
    }

    // "3s" stands for the third-person-singular pronoun, which follows a setting.
    @Test(arguments: [
      ("ging", "gehen", "Präteritum Indikativ (ich, 3s)"),
      ("geht", "gehen", "Präsens Indikativ (3s, ihr) · Imperativ (ihr)"),
      ("gegangen", "gehen", "Perfektpartizip"),
      ("hat gefunden", "finden", "Perfekt Indikativ (3s)"),
      ("anzufangen", "anfangen", "zu-Infinitiv"),
    ])
    func namesTheCellsInGerman(text: String, infinitiv: String, expected: String) throws {
      let pronoun = PersonNumber.thirdSingular.pronoun
      #expect(try whole(text, of: infinitiv).cellNames(lang: .german) == expected.replacingOccurrences(of: "3s", with: pronoun))
    }

    @Test func namesTheCellsInEnglish() throws {
      #expect(try whole("gegangen", of: "gehen").cellNames(lang: .english) == "Past Participle")
    }

    @Test func picksTheReadingThatMatches() throws {
      let hängte = try whole("hängte", of: "hängen")
      #expect(hängte.readingIndex == 1)
      #expect(hängte.conjugationgroups.contains(.präteritumIndikativ(.firstSingular)))
    }

    @Test func finitePartIsShownWithItsParticle() {
      let part = MatchedConjugation(finitePart: "hielt", particle: "auf")
      #expect(part.shownConjugation == "hielt … auf")
      #expect(part.cellNames(lang: .german) == nil)
    }

    @Test func finitePartMarksItsCellsWhenOpened() throws {
      let aufhalten = try #require(Verb.verbs["aufhalten"])
      let marks = try #require(MatchedConjugation(finitePart: "hielt", particle: "auf").marks(on: aufhalten))
      #expect(marks.conjugationgroups == [.präteritumIndikativ(.firstSingular), .präteritumIndikativ(.thirdSingular)])
    }

    @Test func zuInfinitiveMarksNothing() throws {
      let anfangen = try #require(Verb.verbs["anfangen"])
      #expect(MatchedConjugation(whole: "anzufangen", of: anfangen).marks(on: anfangen) == nil)
    }
  }

  @MainActor
  @Suite("Index")
  struct Index {
    @Test func spellingsPutTheLiteralSpellingFirst() {
      let index = ConjugationIndex.bundled
      #expect(index.spellings(of: "ging") == [ConjugationIndex.Spelling(conjugation: "ging", isFolded: false)])
      #expect(index.spellings(of: "muß").first == ConjugationIndex.Spelling(conjugation: "muss", isFolded: true))
      #expect(index.spellings(of: "muß").allSatisfy { $0.isFolded })
      #expect(index.spellings(of: "xyzzy").isEmpty)
    }

    @Test func pageOrderPutsPräteritumIndikativBeforeKonjunktivI() throws {
      let cells = Conjugationgroup.allCells
      let präteritum = try #require(cells.firstIndex(of: .präteritumIndikativ(.firstSingular)))
      let konjunktivI = try #require(cells.firstIndex(of: .präsensKonjunktivI(.firstSingular)))
      #expect(präteritum < konjunktivI)
    }
  }
}
