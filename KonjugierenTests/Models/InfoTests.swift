// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

@MainActor
@Suite("Info")
struct InfoTests {
  @Test(arguments: ["de", "en"])
  func everyLanguageHasAHeadingAndATextForEveryArticle(language: String) throws {
    let strings = try #require(Self.strings(language: language))
    let headings = strings.keys.filter { $0.hasPrefix("Info.") && $0.hasSuffix("Heading") }
    let texts = strings.keys.filter { $0.hasPrefix("Info.") && $0.hasSuffix("Text") }
    #expect(headings.count == Info.infos.count)
    #expect(texts.count == Info.infos.count)
  }

  @Test(arguments: ["de", "en"])
  func everyLinkInAnArticleOpensAnArticleOrAVerb(language: String) throws {
    let strings = try #require(Self.strings(language: language))
    let headings = Set(
      strings
        .filter { $0.key.hasPrefix("Info.") && $0.key.hasSuffix("Heading") }
        .map { $0.value.lowercased() }
    )
    let texts = strings.filter { $0.key.hasPrefix("Info.") && $0.key.hasSuffix("Text") }

    for (key, text) in texts {
      for target in Self.linkTargets(in: text) where !target.hasPrefix("http") {
        let cleaned = Info.linkTarget(target)
        let opens = headings.contains(cleaned.lowercased()) || Verb.verbs[cleaned] != nil
        #expect(opens, "\(key) [\(language)] links to “\(target)”, which is neither an article heading nor a verb.")
      }
    }
  }

  // A link reaches the view as a URL, so a target with an umlaut arrives percent-encoded.
  @Test(arguments: zip(
    ["Ablaut", "(Gehen)", "%C3%9Cben", "aufstehen"],
    ["ablaut", "gehen", "üben", "aufstehen"]
  ))
  func aLinkNamesItsTargetAsTheAppSpellsIt(link: String, target: String) {
    #expect(Info.linkTarget(link) == target)
  }

  @Test func stableKeysAreUnique() {
    let keys = Info.infos.map(\.stableKey)
    #expect(Set(keys).count == keys.count)
  }

  @Test func futurIIFollowsTheFuturArticles() throws {
    let keys = Info.infos.map(\.stableKey)
    let futurII = try #require(keys.firstIndex(of: "futur_ii"))
    #expect(keys[futurII - 1] == "futur_konjunktiv_ii")
  }

  private static func strings(language: String) -> [String: String]? {
    guard let url = Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: language) else {
      return nil
    }
    return NSDictionary(contentsOf: url) as? [String: String]
  }

  private static func linkTargets(in text: String) -> [String] {
    let pieces = text.split(separator: String.linkSeparator, omittingEmptySubsequences: false)
    return pieces.enumerated().filter { !$0.offset.isMultiple(of: 2) }.map { String($0.element) }
  }
}
