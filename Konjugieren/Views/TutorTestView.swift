// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

private struct TutorTestResult: Identifiable {
  let id = UUID()
  let index: Int
  let query: String
  let response: String
  let isError: Bool
  let retryCount: Int
}

struct TutorTestView: View {
  @State private var results: [TutorTestResult] = []
  @State private var currentIndex = 0
  @State private var isRunning = false

  @Environment(\.dismiss) private var dismiss

  private static let queries = [
    "How do you conjugate singen in the Präteritum?",
    "What is the Perfekt of gehen?",
    "Conjugate haben in the Präsens.",
    "What is the Konjunktiv II of sein?",
    "What is the past participle of trinken?",
    "Conjugate laufen in the future tense.",
    "How is sprechen conjugated in the present indicative?",
    "What is the Präteritum of studieren?",
    "Conjugate wissen in the Präsens.",
    "What is the present participle of machen?",
    "What is the imperative of geben?",
    "How do you say \"I would have sung\" in German?",
    "What is the difference between Präteritum and Perfekt?",
    "How do you conjugate pizza?",
    "Tell me about the weather.",
    "What is the Konjunktiv I of kommen?",
    "Conjugate schreiben in the Plusquamperfekt.",
    "What is the Perfekt Konjunktiv I of fahren?",
    "What is the future subjunctive of nehmen?",
    "What is the Futur Konjunktiv II of finden?",
    "How do you conjugate tragen in the past?",
    "Conjugate essen in the Präsens.",
    "What is the Perfekt of werden?",
    "What is the Konjunktiv II of können?",
    "What is the past participle of lesen?",
    "What is the imperative of helfen?",
    "Conjugate bleiben in the Plusquamperfekt Konjunktiv II.",
    "What is the present participle of schlafen?",
    "Conjugate dürfen in the Futur.",
    "What does ablaut mean?"
  ]

  private static let errorExplainerContexts = [
    ErrorExplainerContext(
      infinitiv: "singen",
      translation: "to sing",
      familyDescription: "Strong",
      conjugationgroupGerman: "Präteritum Indikativ",
      conjugationgroupEnglish: "Past Indicative",
      userAnswer: "singte",
      correctAnswer: "sang"
    ),
    ErrorExplainerContext(
      infinitiv: "gehen",
      translation: "to go",
      familyDescription: "Strong",
      conjugationgroupGerman: "Perfekt Indikativ",
      conjugationgroupEnglish: "Present Perfect Indicative",
      userAnswer: "hat gegangen",
      correctAnswer: "ist gegangen"
    ),
    ErrorExplainerContext(
      infinitiv: "sein",
      translation: "to be",
      familyDescription: "Irregular",
      conjugationgroupGerman: "Präsens Indikativ",
      conjugationgroupEnglish: "Present Indicative",
      userAnswer: "seid",
      correctAnswer: "bin"
    )
  ]

  private static let practiceAggregatedErrors = "Present Indicative: 5, Past Indicative: 3, Present Perfect Indicative: 2"

  private static var totalTestCount: Int {
    queries.count + errorExplainerContexts.count + 1
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
          statusBanner

          ForEach(results) { result in
            resultCard(result)
          }
        }
        .padding(Layout.doubleDefaultSpacing)
      }
      .background(Color.customBackground)
      .navigationTitle("Tutor Tests")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(L.Navigation.dismiss) {
            dismiss()
          }
        }
        if !isRunning && results.count == Self.totalTestCount {
          ToolbarItem(placement: .primaryAction) {
            ShareLink(item: shareReport)
          }
        }
      }
      .task {
        await runAllTests()
      }
    }
  }

  @ViewBuilder
  private var statusBanner: some View {
    if isRunning {
      HStack(spacing: Layout.defaultSpacing) {
        ProgressView()
        Text("Running test \(currentIndex) of \(Self.totalTestCount)…")
          .foregroundStyle(.customForeground)
          .font(.subheadline)
      }
    } else if results.count == Self.totalTestCount {
      let errorCount = results.filter(\.isError).count
      Text(errorCount == 0
        ? "All \(Self.totalTestCount) tests complete."
        : "Done. \(errorCount) of \(Self.totalTestCount) returned errors.")
        .foregroundStyle(.customYellow)
        .font(.subheadline.weight(.semibold))
    }
  }

  private func resultCard(_ result: TutorTestResult) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text("#\(result.index) (R: \(result.retryCount))")
        .font(.caption.weight(.bold))
        .foregroundStyle(.customYellow)

      Text(result.query)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(.customForeground)

      Text(result.response)
        .font(.caption)
        .foregroundStyle(result.isError ? .red : .customForeground)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(Layout.defaultSpacing + 4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.customBackground)
        .shadow(radius: 1)
    )
  }

  private var shareReport: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    let date = dateFormatter.string(from: Date())
    var lines = ["Tutor Test Results — \(date)", ""]
    for result in results {
      lines.append("#\(result.index) (R: \(result.retryCount)) \(result.query)")
      lines.append("Response: \(result.response)")
      lines.append("")
    }
    return lines.joined(separator: "\n")
  }

  private func runAllTests() async {
    guard Current.languageModelService.isAvailable else {
      results.append(TutorTestResult(
        index: 0,
        query: "Availability check",
        response: "Language model is not available.",
        isError: true,
        retryCount: 0
      ))
      return
    }

    isRunning = true
    for (index, query) in Self.queries.enumerated() {
      currentIndex = index + 1
      Current.languageModelService.resetTutorSession()
      do {
        let response = try await Current.languageModelService.sendTutorMessage(query)
        let retryCount = Current.languageModelService.lastRetryCount
        results.append(TutorTestResult(
          index: index + 1,
          query: query,
          response: response,
          isError: false,
          retryCount: retryCount
        ))
      } catch {
        let retryCount = Current.languageModelService.lastRetryCount
        results.append(TutorTestResult(
          index: index + 1,
          query: query,
          response: "Error: \(error.localizedDescription)",
          isError: true,
          retryCount: retryCount
        ))
      }
    }

    for (index, context) in Self.errorExplainerContexts.enumerated() {
      let testNumber = Self.queries.count + index + 1
      currentIndex = testNumber
      let query = "Error Explainer: \(context.infinitiv) (\(context.userAnswer) → \(context.correctAnswer))"
      do {
        let explanation = try await Current.languageModelService.explainError(context: context)
        let response = "Explanation: \(explanation.explanation) | Rule: \(explanation.rule) | Mnemonic: \(explanation.mnemonic)"
        results.append(TutorTestResult(
          index: testNumber,
          query: query,
          response: response,
          isError: false,
          retryCount: 0
        ))
      } catch {
        results.append(TutorTestResult(
          index: testNumber,
          query: query,
          response: "Error: \(error.localizedDescription)",
          isError: true,
          retryCount: 0
        ))
      }
    }

    let practiceTestNumber = Self.queries.count + Self.errorExplainerContexts.count + 1
    currentIndex = practiceTestNumber
    do {
      let recommendation = try await Current.languageModelService.recommendPractice(aggregatedErrors: Self.practiceAggregatedErrors)
      let items = recommendation.items.map { "\($0.area): \($0.reason)" }.joined(separator: "; ")
      let response = "Summary: \(recommendation.summary) | Items: \(items)"
      results.append(TutorTestResult(
        index: practiceTestNumber,
        query: "Practice Recommender: \(Self.practiceAggregatedErrors)",
        response: response,
        isError: false,
        retryCount: 0
      ))
    } catch {
      results.append(TutorTestResult(
        index: practiceTestNumber,
        query: "Practice Recommender: \(Self.practiceAggregatedErrors)",
        response: "Error: \(error.localizedDescription)",
        isError: true,
        retryCount: 0
      ))
    }

    isRunning = false
  }
}
