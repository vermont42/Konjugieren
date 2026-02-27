// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum LanguageModelUnavailability {
  case appleIntelligenceNotEnabled
  case deviceNotEligible
  case modelNotReady
  case unknown
}

struct ErrorExplainerContext {
  let infinitiv: String
  let translation: String
  let familyDescription: String
  let conjugationgroupGerman: String
  let conjugationgroupEnglish: String
  let userAnswer: String
  let correctAnswer: String
}

struct ErrorExplanation: Codable, Sendable {
  let explanation: String
  let rule: String
  let mnemonic: String
}

struct PracticeRecommendation: Codable, Sendable {
  let summary: String
  let items: [RecommendationItem]
}

struct RecommendationItem: Codable, Sendable {
  let area: String
  let reason: String
}

struct TutorMessage: Codable, Identifiable, Sendable {
  let id: UUID
  let role: Role
  let content: String
  let timestamp: Date

  enum Role: Codable, Sendable {
    case assistant
    case user
  }

  init(role: Role, content: String) {
    self.id = UUID()
    self.role = role
    self.content = content
    self.timestamp = Date()
  }
}

@MainActor
protocol LanguageModelService {
  var isAvailable: Bool { get }
  var unavailabilityReason: LanguageModelUnavailability? { get }
  func explainError(context: ErrorExplainerContext) async throws -> ErrorExplanation
  func recommendPractice(aggregatedErrors: String) async throws -> PracticeRecommendation
  var lastRetryCount: Int { get }
  func sendTutorMessage(_ message: String) async throws -> String
  func resetTutorSession()
}
