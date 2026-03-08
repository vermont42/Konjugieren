// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import SwiftUI
import WidgetKit

struct GameLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: GameActivityAttributes.self) { context in
      GameLockScreenView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Label("Wave \(context.state.wave)", systemImage: "wind")
            .font(.headline)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Label("\(context.state.score)", systemImage: "star.fill")
            .font(.headline)
        }
        DynamicIslandExpandedRegion(.bottom) {
          HealthBarView(fraction: context.state.healthFraction)
            .frame(height: 8)
        }
      } compactLeading: {
        Text("W\(context.state.wave)")
          .font(.caption)
      } compactTrailing: {
        Text("\(context.state.score)")
          .font(.caption)
          .monospacedDigit()
      } minimal: {
        Text("\(context.state.wave)")
          .font(.caption)
      }
    }
  }
}

private struct GameLockScreenView: View {
  let context: ActivityViewContext<GameActivityAttributes>

  private var isGameOver: Bool {
    context.state.phase == "lost"
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 8) {
        Text(isGameOver ? "Game Over" : "Konjugieren")
          .font(.headline)

        Text("Wave \(context.state.wave)")
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

        HealthBarView(fraction: context.state.healthFraction)
          .frame(width: 80, height: 8)
      }
    }
    .padding()
  }
}

private struct HealthBarView: View {
  let fraction: Double

  private var barColor: Color {
    if fraction > 0.5 {
      return .green
    } else if fraction > 0.25 {
      return .yellow
    } else {
      return .red
    }
  }

  var body: some View {
    GeometryReader { geometry in
      Capsule()
        .fill(Color.gray.opacity(0.3))
        .overlay(alignment: .leading) {
          Capsule()
            .fill(barColor)
            .frame(width: geometry.size.width * max(fraction, 0))
        }
    }
  }
}
