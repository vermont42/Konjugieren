// Copyright © 2026 Josh Adams. All rights reserved.

@MainActor
class LanguageModelServiceDummy: LanguageModelService {
  var lastRetryCount: Int { 0 }
  var isAvailable: Bool { false }
  var unavailabilityReason: LanguageModelUnavailability? { .deviceNotEligible }

  func explainError(context: ErrorExplainerContext) async throws -> ErrorExplanation {
    ErrorExplanation(explanation: "", rule: "", mnemonic: "")
  }

  func recommendPractice(aggregatedErrors: String) async throws -> PracticeRecommendation {
    PracticeRecommendation(summary: "", items: [])
  }

  func sendTutorMessage(_ message: String) async throws -> String {
    ""
  }

  func resetTutorSession() {}
}
