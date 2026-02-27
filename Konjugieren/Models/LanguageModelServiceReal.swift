// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import os

#if canImport(FoundationModels)
import FoundationModels
#endif

nonisolated private let lmsLogger = KonjugierenLogger.logger(category: "LanguageModelService")

@available(iOS 26, *)
@MainActor
class LanguageModelServiceReal: LanguageModelService {
  private let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)

  private var tutorSession: LanguageModelSession?

  private static let errorExplainerInstructions = """
    You are a German grammar tutor. Explain conjugation errors briefly. \
    Reference the verb family and any ablaut pattern. Keep all fields under two sentences. \
    Respond ONLY with a JSON object matching this schema, no other text: \
    {"explanation": "brief explanation of why the answer was wrong", "rule": "the grammar rule that applies", "mnemonic": "a short memory aid for the correct conjugation"}
    """

  private static let tutorInstructions = """
    You are a German verb conjugation tutor. \
    For conjugation questions, call conjugateVerb EXACTLY ONCE with the \
    German infinitive and the SINGLE tense the user asked about. Do not \
    call the tool multiple times for different tenses. \
    Present the German conjugations from the tool result directly. \
    NEVER translate conjugations into English. Always show German words \
    like "ich sang", never English like "I sang". \
    List ALL six persons from the tool result. \
    Tense mappings: Partizip I = present participle. \
    Partizip II = past participle. \
    Konjunktiv I = Present Subjunctive. Konjunktiv II = Past Conditional. \
    "Future subjunctive" = Futur Konjunktiv I. \
    "Future conditional" = Futur Konjunktiv II. \
    "Would have [participle]" = Plusquamperfekt Konjunktiv II. \
    Präsens = present tense = Present Indicative. \
    Plusquamperfekt alone = Plusquamperfekt Indikativ. \
    Ablaut = strong-verb vowel change (singen/sang/gesungen). \
    Grammar concept questions are welcome. If the user asks about \
    grammar concepts like ablaut, tense differences, or verb families, \
    answer directly and helpfully without calling the tool. \
    Only redirect questions that have nothing to do with German language.
    """

  private static let practiceInstructions = """
    You are a German grammar tutor analyzing quiz results. Identify the weakest areas \
    and recommend specific practice focus. Be concise. \
    Respond ONLY with a JSON object matching this schema, no other text: \
    {"summary": "one-sentence summary of weakest areas", "items": [{"area": "conjugation area to practice", "reason": "why this area needs practice"}]} \
    Include 1 to 3 items.
    """

  var lastRetryCount = 0

  var isAvailable: Bool {
    model.availability == .available
  }

  var unavailabilityReason: LanguageModelUnavailability? {
    switch model.availability {
    case .available:
      return nil
    case .unavailable(.appleIntelligenceNotEnabled):
      return .appleIntelligenceNotEnabled
    case .unavailable(.deviceNotEligible):
      return .deviceNotEligible
    case .unavailable(.modelNotReady):
      return .modelNotReady
    case .unavailable:
      return .unknown
    @unknown default:
      return .unknown
    }
  }

  func explainError(context: ErrorExplainerContext) async throws -> ErrorExplanation {
    let session = LanguageModelSession(model: model, instructions: Self.errorExplainerInstructions)
    let prompt = """
      The user conjugated "\(context.infinitiv)" (\(context.translation), \
      \(context.familyDescription) verb) in the \(context.conjugationgroupEnglish). \
      They wrote "\(context.userAnswer)" but the correct answer is "\(context.correctAnswer)".
      """
    let response = try await session.respond(to: prompt)
    let cleaned = Self.extractJSON(from: response.content)
    lmsLogger.info("explainError raw response: \(response.content)")
    guard let data = cleaned.data(using: .utf8),
          let result = try? JSONDecoder().decode(ErrorExplanation.self, from: data) else {
      lmsLogger.warning("explainError JSON decoding failed. Cleaned: \(cleaned)")
      throw LanguageModelServiceError.jsonDecodingFailed
    }
    return result
  }

  func recommendPractice(aggregatedErrors: String) async throws -> PracticeRecommendation {
    let session = LanguageModelSession(model: model, instructions: Self.practiceInstructions)
    let prompt = "Recent conjugation errors (area: count): \(aggregatedErrors). Identify the weakest areas and recommend specific practice focus."
    let response = try await session.respond(to: prompt)
    let cleaned = Self.extractJSON(from: response.content)
    lmsLogger.info("recommendPractice raw response: \(response.content)")
    guard let data = cleaned.data(using: .utf8),
          let result = try? JSONDecoder().decode(PracticeRecommendation.self, from: data) else {
      lmsLogger.warning("recommendPractice JSON decoding failed. Cleaned: \(cleaned)")
      throw LanguageModelServiceError.jsonDecodingFailed
    }
    return result
  }

  private static func extractJSON(from text: String) -> String {
    var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

    // Strip markdown code fences: ```json ... ``` or ``` ... ```
    if cleaned.hasPrefix("```") {
      if let endRange = cleaned.range(of: "```", options: [], range: cleaned.index(cleaned.startIndex, offsetBy: 3)..<cleaned.endIndex) {
        let startOfContent = cleaned.index(cleaned.startIndex, offsetBy: 3)
        var content = String(cleaned[startOfContent..<endRange.lowerBound])
        // Remove optional language label on first line (e.g., "json\n")
        if let newline = content.firstIndex(of: "\n") {
          let firstLine = content[content.startIndex..<newline]
          if firstLine.allSatisfy({ $0.isLetter || $0.isWhitespace }) {
            content = String(content[content.index(after: newline)...])
          }
        }
        cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
      }
    }

    // Fallback: extract from first { to last }
    if let openBrace = cleaned.firstIndex(of: "{"),
       let closeBrace = cleaned.lastIndex(of: "}") {
      cleaned = String(cleaned[openBrace...closeBrace])
    }

    return cleaned
  }

  func sendTutorMessage(_ message: String) async throws -> String {
    let maxRetries = 3
    var lastRefusalResponse: String?
    var lastError: Error?

    for attempt in 0...maxRetries {
      ConjugationTool.resetCallCount()
      if attempt > 0 {
        tutorSession = LanguageModelSession(model: model, tools: [ConjugationTool()], instructions: Self.tutorInstructions)
      } else if tutorSession == nil {
        tutorSession = LanguageModelSession(model: model, tools: [ConjugationTool()], instructions: Self.tutorInstructions)
      }
      guard let session = tutorSession else {
        throw LanguageModelServiceError.sessionUnavailable
      }
      do {
        let response = try await session.respond(to: message)
        let cleaned = Self.stripMarkdown(response.content)
        let trimmed = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !Self.isLikelyRefusal(cleaned) {
          lastRetryCount = attempt
          return cleaned
        }
        let reason = trimmed.isEmpty ? "empty response" : "likely refusal"
        lmsLogger.info("Detected \(reason) on attempt \(attempt + 1), retrying")
        lastRefusalResponse = cleaned
      } catch {
        lmsLogger.warning("Attempt \(attempt + 1) failed: \(error.localizedDescription)")
        lastError = error
      }
    }

    lastRetryCount = maxRetries
    tutorSession = LanguageModelSession(model: model, tools: [ConjugationTool()], instructions: Self.tutorInstructions)
    if let refusal = lastRefusalResponse {
      let trimmed = refusal.trimmingCharacters(in: .whitespacesAndNewlines)
      if trimmed.count < 10 {
        return "I wasn't able to answer that question. Please try rephrasing or ask a different question."
      }
      return refusal
    }
    throw lastError ?? LanguageModelServiceError.sessionUnavailable
  }

  private static func stripMarkdown(_ text: String) -> String {
    text.replacingOccurrences(of: "**", with: "")
  }

  private static func isLikelyRefusal(_ response: String) -> Bool {
    let lowercased = response.lowercased()
    return lowercased.contains("can't assist")
      || lowercased.contains("cannot assist")
      || lowercased.contains("can't help")
      || lowercased.contains("cannot help")
      || lowercased.contains("ethical guidelines")
      || lowercased.contains("what's your next question")
      || lowercased.contains("null")
      || lowercased.contains("away from the task at hand")
      || lowercased.contains("unable to assist")
      || lowercased.contains("unable to provide")
      || lowercased.contains("no more data at my disposal")
      || lowercased.contains("not what i was programmed")
      || lowercased.contains("inappropriate content")
      || lowercased.contains("cannot answer")
      || lowercased.contains("can't answer")
      || lowercased.contains("cannot provide")
      || lowercased.contains("cannot fulfill")
      || lowercased.contains("can't fulfill")
      || lowercased.contains("unable to fulfill")
      || lowercased.contains("outside of the scope")
      || lowercased.contains("outside the scope")
      || lowercased.contains("no response to this")
      || lowercased.contains("i have no response")
      || lowercased.contains("can't do that")
      || lowercased.contains("cannot do that")
      || lowercased.contains("can't continue")
      || lowercased.contains("cannot continue")
  }

  func resetTutorSession() {
    tutorSession = nil
  }
}

@available(iOS 26, *)
struct ConjugationTool: Tool {
  let name = "conjugateVerb"
  let description = "Look up a German verb conjugation"

  nonisolated(unsafe) private static var callCount = 0
  private static let maxCallsPerSession = 3

  static func resetCallCount() {
    callCount = 0
  }

  @Generable(description: "A German verb conjugation lookup")
  struct Arguments {
    @Guide(description: "The verb infinitive")
    var infinitiv: String

    @Guide(description: "Tense from the question", .anyOf([
      "Präsens", "Präteritum", "Perfekt", "Plusquamperfekt",
      "Futur", "Imperativ", "Partizip I", "Partizip II",
      "Konjunktiv I", "Konjunktiv II",
      "Perfekt Konjunktiv I", "Plusquamperfekt Konjunktiv II",
      "Futur Konjunktiv I", "Futur Konjunktiv II"]))
    var conjugationgroup: String
  }

  func call(arguments: Arguments) async throws -> String {
    Self.callCount += 1
    if Self.callCount > Self.maxCallsPerSession {
      lmsLogger.warning("Tool call limit reached (\(Self.maxCallsPerSession))")
      return "Limit reached. Respond with the conjugations you already have."
    }
    lmsLogger.info("Tool call: infinitiv=\(arguments.infinitiv) conjugationgroup=\(arguments.conjugationgroup)")
    let result = await Self.performLookup(infinitiv: arguments.infinitiv, conjugationgroupName: arguments.conjugationgroup)
    lmsLogger.info("Tool result: \(result)")
    return result
  }

  // Tool.call is nonisolated, but Conjugator.conjugate and englishDisplayName
  // are @MainActor (via SWIFT_DEFAULT_ACTOR_ISOLATION). This helper bridges the gap.
  @MainActor private static func performLookup(infinitiv: String, conjugationgroupName: String) -> String {
    if let conjugationgroup = buildConjugationgroup(name: conjugationgroupName, personNumber: nil) {
      let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup)
      switch result {
      case .success(let conjugation):
        return "\(conjugation.lowercased()) (\(conjugationgroup.englishDisplayName))"
      case .failure(let error):
        return "Conjugation failed for \(infinitiv): \(error)"
      }
    }

    let imperativ = isImperativ(name: conjugationgroupName)
    let personNumbers = imperativ ? PersonNumber.imperativPersonNumbers : PersonNumber.allCases
    var lines: [String] = []
    for personNumber in personNumbers {
      guard let conjugationgroup = buildConjugationgroup(name: conjugationgroupName, personNumber: personNumber) else {
        continue
      }
      let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup)
      if case .success(let conjugation) = result {
        if imperativ {
          lines.append(conjugation.lowercased())
        } else {
          lines.append("\(personNumber.pronoun) \(conjugation.lowercased())")
        }
      }
    }
    if lines.isEmpty {
      return buildErrorMessage(infinitiv: infinitiv, conjugationgroupName: conjugationgroupName)
    }
    let label = buildConjugationgroup(name: conjugationgroupName, personNumber: .firstSingular)?.englishDisplayName ?? conjugationgroupName
    return "\(infinitiv) in the \(label): \(lines.joined(separator: ", "))"
  }

  private static func isImperativ(name: String) -> Bool {
    let lowercased = name.lowercased()
    return lowercased.contains("imperativ") || lowercased.contains("imperative")
  }

  @MainActor private static func buildErrorMessage(infinitiv: String, conjugationgroupName: String) -> String {
    if Verb.verbs[infinitiv] == nil {
      return "\"\(infinitiv)\" is not a recognized verb."
    }
    return "Could not parse conjugationgroup \"\(conjugationgroupName)\". Valid names include: "
      + "Präsens, Präteritum, Perfekt, Plusquamperfekt, Futur, Konjunktiv I, Konjunktiv II, "
      + "Imperativ, Past Participle, Present Participle."
  }

  private static func buildConjugationgroup(name: String, personNumber: PersonNumber?) -> Conjugationgroup? {
    let lowercasedName = name.lowercased()

    if lowercasedName.contains("past participle") || lowercasedName.contains("perfekt partizip") || lowercasedName.contains("perfektpartizip") || lowercasedName.contains("partizip ii") {
      return .perfektpartizip
    }
    if lowercasedName.contains("present participle") || lowercasedName.contains("präsens partizip") || lowercasedName.contains("präsenspartizip") || lowercasedName.contains("partizip i") {
      return .präsenspartizip
    }
    if lowercasedName == "partizip" || lowercasedName == "participle" {
      return .perfektpartizip
    }

    guard let personNumber else {
      return nil
    }

    // Ordered specificity: longer compound names before shorter substrings.
    // "plusquamperfekt konjunktiv" contains "perfekt konjunktiv";
    // "futur konjunktiv ii" contains "futur konjunktiv i".
    if lowercasedName.contains("pluperfect conditional") || lowercasedName.contains("plusquamperfekt konjunktiv") {
      return .plusquamperfektKonjunktivII(personNumber)
    }
    if lowercasedName.contains("pluperfect") || lowercasedName.contains("plusquamperfekt indikativ") {
      return .plusquamperfektIndikativ(personNumber)
    }
    if lowercasedName.contains("present perfect subjunctive") || lowercasedName.contains("perfekt konjunktiv") {
      return .perfektKonjunktivI(personNumber)
    }
    if lowercasedName.contains("present perfect") || lowercasedName.contains("perfekt indikativ") {
      return .perfektIndikativ(personNumber)
    }
    if lowercasedName.contains("present subjunctive") || lowercasedName.contains("präsens konjunktiv") {
      return .präsensKonjunktivI(personNumber)
    }
    if lowercasedName.contains("present indicative") || lowercasedName.contains("präsens indikativ") {
      return .präsensIndicativ(personNumber)
    }
    if lowercasedName.contains("past conditional") || lowercasedName.contains("präteritum konjunktiv") {
      return .präteritumKonjunktivII(personNumber)
    }
    if lowercasedName.contains("past indicative") || lowercasedName.contains("präteritum") {
      return .präteritumIndicativ(personNumber)
    }
    if lowercasedName.contains("future conditional") || lowercasedName.contains("futur konjunktiv ii") {
      return .futurKonjunktivII(personNumber)
    }
    if lowercasedName.contains("future subjunctive") || lowercasedName.contains("futur konjunktiv i") {
      return .futurKonjunktivI(personNumber)
    }
    if lowercasedName.contains("future") || lowercasedName.contains("futur indikativ") {
      return .futurIndikativ(personNumber)
    }
    if lowercasedName.contains("imperative") || lowercasedName.contains("imperativ") {
      return .imperativ(personNumber)
    }

    // Bare-name fallbacks for short German tense names
    if lowercasedName == "plusquamperfekt" {
      return .plusquamperfektIndikativ(personNumber)
    }
    if lowercasedName.contains("konjunktiv ii") || lowercasedName.contains("konjunktiv 2") {
      return .präteritumKonjunktivII(personNumber)
    }
    if lowercasedName.contains("konjunktiv i") || lowercasedName.contains("konjunktiv 1") {
      return .präsensKonjunktivI(personNumber)
    }
    if lowercasedName == "konjunktiv" || lowercasedName == "subjunctive" || lowercasedName == "conditional" {
      return .präteritumKonjunktivII(personNumber)
    }
    if lowercasedName == "perfekt" || lowercasedName == "perfect" {
      return .perfektIndikativ(personNumber)
    }
    if lowercasedName == "futur" || lowercasedName == "future" {
      return .futurIndikativ(personNumber)
    }
    if lowercasedName == "präsens" || lowercasedName == "present" {
      return .präsensIndicativ(personNumber)
    }
    if lowercasedName == "präteritum" || lowercasedName == "past" {
      return .präteritumIndicativ(personNumber)
    }

    return nil
  }
}

enum LanguageModelServiceError: Error {
  case jsonDecodingFailed
  case sessionUnavailable
}
