// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct ErrorExplainerView: View {
  let context: ErrorExplainerContext

  @State private var explanation: ErrorExplanation?
  @State private var isLoading = false
  @State private var isExpanded = false
  @State private var hasFailed = false

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Button {
        if !isExpanded {
          isExpanded = true
          Current.soundPlayer.play(.pop)
          fetchExplanation()
        } else {
          isExpanded = false
        }
      } label: {
        HStack(spacing: 4) {
          Image(systemName: "lightbulb.fill")
          Text(L.ErrorExplainer.whyWrong)
        }
        .foregroundStyle(.customYellow)
        .font(.subheadline.weight(.semibold))
      }
      .accessibilityHint(L.ErrorExplainer.whyWrong)

      if isExpanded {
        if isLoading {
          HStack(spacing: Layout.defaultSpacing) {
            ProgressView()
            Text(L.ErrorExplainer.loading)
              .foregroundStyle(.customForeground)
              .font(.subheadline)
          }
        } else if let explanation {
          VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
            explanationRow(label: L.ErrorExplainer.explanation, text: explanation.explanation)
            explanationRow(label: L.ErrorExplainer.rule, text: explanation.rule)
            explanationRow(label: L.ErrorExplainer.mnemonic, text: explanation.mnemonic)
          }
        } else if hasFailed {
          Button {
            fetchExplanation()
          } label: {
            Label(L.ErrorExplainer.retry, systemImage: "arrow.clockwise")
              .foregroundStyle(.customYellow)
              .font(.subheadline)
          }
        }
      }
    }
    .padding(.top, Layout.defaultSpacing)
  }

  private func explanationRow(label: String, text: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(label)
        .foregroundStyle(.customYellow)
        .font(.caption.weight(.semibold))
      Text(text)
        .foregroundStyle(.customForeground)
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private func fetchExplanation() {
    isLoading = true
    hasFailed = false
    Current.analytics.signal(name: .tapExplainError)
    Task {
      do {
        let result = try await Current.languageModelService.explainError(context: context)
        explanation = result
        Current.soundPlayer.play(.pop)
      } catch {
        hasFailed = true
      }
      isLoading = false
    }
  }
}
