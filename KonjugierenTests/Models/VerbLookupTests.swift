// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("Verb lookup")
struct VerbLookupTests {
  private func lookup(_ word: String, includeGlosses: Bool = true) -> VerbLookup {
    VerbLookup(word: word, verbs: Verb.verbsSortedByFrequency, includeGlosses: includeGlosses)
  }

  private func verb(_ infinitiv: String) -> Verb {
    Verb.verbs[infinitiv]!
  }

  @Test func aConjugationOpensItsVerbOnTheMatch() {
    let found = lookup("ging")
    #expect(found.findings.first == .conjugation(MatchedConjugation(whole: "ging", of: verb("gehen")), of: verb("gehen")))
    #expect(found.destination == URL.verbDeeplink("gehen", source: .lookup, match: "ging"))
  }

  // ging is also a part of ausgehen and its siblings, which the answer names without letting
  // them keep the learner from gehen's page.
  @Test func aConjugationThatIsAlsoAFinitePartNamesTheSeparableVerbs() throws {
    let found = lookup("ging")
    let finitePart = try #require(found.findings.last)
    guard case .finitePart(let shown, _, let count) = finitePart else {
      Issue.record("Expected a finite part, found \(finitePart)")
      return
    }
    #expect(shown.hasPrefix("ging … "))
    #expect(count > 1)
  }

  @Test func anInfinitiveOpensItsPageUnmarked() {
    let found = lookup("gehen")
    #expect(found.findings == [.infinitive(verb("gehen"))])
    #expect(found.destination == URL.verbDeeplink("gehen", source: .lookup))
  }

  @Test func aFoldedInfinitiveIsAnInfinitive() {
    #expect(lookup("konnen").findings == [.infinitive(verb("können"))])
  }

  @Test func aFoldedConjugationAnswersInTheAppsSpelling() {
    let found = lookup("muß")
    #expect(found.findings.first == .conjugation(MatchedConjugation(whole: "muss", of: verb("müssen")), of: verb("müssen")))
    #expect(found.destination == URL.verbDeeplink("müssen", source: .lookup, match: "muss"))
  }

  @Test func aConjugationOfTwoVerbsNamesBothAndOpensTheSearch() {
    let found = lookup("gehört")
    let named = found.findings.compactMap { finding -> String? in
      if case .conjugation(_, let verb) = finding {
        return verb.infinitiv
      }
      return nil
    }
    #expect(Set(named) == ["gehören", "hören"])
    #expect(found.destination == URL.searchDeeplink(text: "gehört", source: .lookup))
  }

  // gefallen is a verb and fallen's Perfektpartizip. Naming only the verb would mislead a
  // learner who met the participle.
  @Test func anInfinitiveThatIsAlsoAConjugationNamesBoth() {
    let found = lookup("gefallen")
    #expect(found.findings.first == .infinitive(verb("gefallen")))
    #expect(found.findings.contains { finding in
      if case .conjugation(_, let verb) = finding {
        return verb.infinitiv == "fallen"
      }
      return false
    })
    #expect(found.destination == URL.searchDeeplink(text: "gefallen", source: .lookup))
  }

  @Test func aGlossNamesItsFirstVerbAndOpensTheSearch() {
    let found = lookup("eat")
    guard case .otherMatches(let first, let count) = found.findings.first else {
      Issue.record("Expected other matches, found \(found.findings)")
      return
    }
    #expect(first.infinitiv == "essen")
    #expect(count > 1)
    #expect(found.destination == URL.searchDeeplink(text: "eat", source: .lookup))
  }

  @Test func aMisspellingOffersTheGuess() {
    #expect(lookup("gehn").findings == [.guess(verb("gehen"), conjugation: nil)])
  }

  @Test func nonsenseFindsNothingAndOpensTheSearch() {
    let found = lookup("  xyzzyq ")
    #expect(found.findings == [.nothing])
    #expect(found.destination == URL.searchDeeplink(text: "xyzzyq", source: .lookup))
  }

  // The third person's pronoun follows a setting that other suites change, so only ich is pinned.
  @Test func theAnswerNamesTheCellsAndTheVerb() {
    let answer = lookup("ging").answer(lang: .german, region: .north)
    #expect(answer.hasPrefix("ging: Präteritum Indikativ (ich, "))
    #expect(answer.components(separatedBy: "\n").first?.hasSuffix("gehen") == true)
  }

  @Test func anInfinitivesAnswerGivesItsKeyConjugations() {
    let answer = lookup("aufstehen").answer(lang: .german, region: .north)
    #expect(answer.hasSuffix(": steht auf · stand auf · ist aufgestanden"))
  }

  @Test func theAnswerFollowsTheRegion() {
    #expect(lookup("stehen").answer(lang: .german, region: .austria).hasSuffix("ist gestanden"))
    #expect(lookup("stehen").answer(lang: .german, region: .north).hasSuffix("hat gestanden"))
  }
}
