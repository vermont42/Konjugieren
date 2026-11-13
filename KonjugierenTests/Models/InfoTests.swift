// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

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
        let cleaned = target.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        let verb = cleaned.prefix(1).lowercased() + cleaned.dropFirst()
        let opens = headings.contains(cleaned.lowercased()) || Verb.verbs[verb] != nil
        #expect(opens, "\(key) [\(language)] links to “\(target)”, which is neither an article heading nor a verb.")
      }
    }
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
