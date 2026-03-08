// Copyright © 2025 Josh Adams. All rights reserved.

import AppIntents

struct OpenVerbIntent: AppIntent {
  static let title: LocalizedStringResource = "Open Verb"
  static let description: IntentDescription = "Opens a specific verb in Konjugieren."
  static let openAppWhenRun = true

  @Parameter(title: "Verb")
  var verb: VerbEntity

  func perform() async throws -> some IntentResult {
    await MainActor.run {
      Current.verb = nil
      Current.verb = Verb.verbs[verb.id]
      Current.selectedTab = .verbs
    }
    return .result()
  }
}
