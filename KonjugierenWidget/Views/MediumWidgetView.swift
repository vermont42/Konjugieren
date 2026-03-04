// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
  let snapshot: WidgetSnapshot
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(snapshot.infinitiv)
          .font(.title3)
          .fontWeight(.bold)
        Text("— \(snapshot.translation)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(1)
        Spacer()
        Button(intent: NextVerbIntent()) {
          Image(systemName: "forward.fill")
            .font(.caption2)
        }
        .buttonStyle(.plain)
      }

      HStack(alignment: .top, spacing: 16) {
        VStack(alignment: .leading, spacing: 2) {
          ForEach(Array(snapshot.präsensParadigm.prefix(3).enumerated()), id: \.offset) { _, conjugation in
            HStack(spacing: 4) {
              Text(conjugation.pronoun)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .trailing)
              Text(widgetMixedCase: conjugation.mixedCaseForm, colorScheme: colorScheme)
                .font(.caption)
                .fontWeight(.medium)
            }
          }
        }

        VStack(alignment: .leading, spacing: 2) {
          ForEach(Array(snapshot.präsensParadigm.suffix(3).enumerated()), id: \.offset) { _, conjugation in
            HStack(spacing: 4) {
              Text(conjugation.pronoun)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .trailing)
              Text(widgetMixedCase: conjugation.mixedCaseForm, colorScheme: colorScheme)
                .font(.caption)
                .fontWeight(.medium)
            }
          }
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 2) {
          Text(snapshot.familyDisplay)
            .font(.caption2)
            .foregroundStyle(.secondary)
          Text(snapshot.auxiliary)
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }
    }
    .widgetURL(URL(string: "konjugieren://verb/\(snapshot.infinitiv)"))
  }
}
