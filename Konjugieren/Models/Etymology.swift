// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum Etymology {
  @MainActor private static var etymologies: [String: String]?

  @MainActor private static func loadIfNeeded() {
    guard etymologies == nil else { return }
    guard let url = Bundle.main.url(forResource: "Etymologies", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let file = try? JSONDecoder().decode([String: [String: String]].self, from: data)
    else {
      etymologies = [:]
      return
    }
    let lang = Locale.current.language.languageCode?.identifier ?? "en"
    etymologies = file[lang] ?? file["en"] ?? [:]
  }

  @MainActor static func text(for infinitiv: String) -> String? {
    loadIfNeeded()
    return etymologies?[infinitiv]
  }
}
