// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct ExampleSentence: Codable {
  let sentence: String
  let source: String
}

struct ExampleSentencePair {
  let german: ExampleSentence
  let english: ExampleSentence
}

enum ExampleSentences {
  @MainActor private static var pairs: [String: ExampleSentencePair]?

  @MainActor private static func loadIfNeeded() {
    guard pairs == nil else { return }
    guard let url = Bundle.main.url(forResource: "ExampleSentences", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let file = try? JSONDecoder().decode([String: [String: ExampleSentence]].self, from: data),
          let de = file["de"],
          let en = file["en"]
    else {
      pairs = [:]
      return
    }
    var result: [String: ExampleSentencePair] = [:]
    for (verb, german) in de {
      if let english = en[verb] {
        result[verb] = ExampleSentencePair(german: german, english: english)
      }
    }
    pairs = result
  }

  @MainActor static func pair(for infinitiv: String) -> ExampleSentencePair? {
    loadIfNeeded()
    return pairs?[infinitiv]
  }
}
