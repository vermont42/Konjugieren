// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import SwiftUI
import WidgetKit

struct QuizLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: QuizActivityAttributes.self) { context in
      QuizLockScreenView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Label("\(context.state.currentQuestion)/\(context.attributes.totalQuestions)", systemImage: "list.number")
            .font(.headline)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Label("\(context.state.score)", systemImage: "star.fill")
            .font(.headline)
        }
        DynamicIslandExpandedRegion(.center) {
          Text(context.state.elapsedTime)
            .font(.title2)
            .monospacedDigit()
        }
        DynamicIslandExpandedRegion(.bottom) {
          ProgressView(
            value: Double(context.state.currentQuestion),
            total: Double(context.attributes.totalQuestions)
          )
          .tint(.blue)
        }
      } compactLeading: {
        Text("\(context.state.currentQuestion)/\(context.attributes.totalQuestions)")
          .font(.caption)
          .monospacedDigit()
      } compactTrailing: {
        Text("\(context.state.score)")
          .font(.caption)
          .monospacedDigit()
      } minimal: {
        Text("\(context.state.currentQuestion)")
          .font(.caption)
          .monospacedDigit()
      }
    }
  }
}

private struct QuizLockScreenView: View {
  let context: ActivityViewContext<QuizActivityAttributes>

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 8) {
        Text("Konjugieren Quiz")
          .font(.headline)

        Text(context.attributes.difficulty)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 8) {
        HStack(spacing: 4) {
          Image(systemName: "star.fill")
            .foregroundStyle(.yellow)
          Text("\(context.state.score)")
            .font(.title2.bold())
            .monospacedDigit()
        }

        HStack(spacing: 4) {
          Text("\(context.state.currentQuestion) / \(context.attributes.totalQuestions)")
            .monospacedDigit()

          Text("·")

          Text(context.state.elapsedTime)
            .monospacedDigit()
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
      }
    }
    .padding()
  }
}
