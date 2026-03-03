// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
  let snapshot: WidgetSnapshot

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(alignment: .firstTextBaseline) {
        Text(snapshot.infinitiv)
          .font(.title3)
          .fontWeight(.bold)
        Text("— \(snapshot.translation)")
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(1)
        Spacer()
        Button(intent: NextVerbIntent()) {
          Image(systemName: "forward.fill")
            .font(.caption2)
        }
        .buttonStyle(.plain)
      }

      HStack(spacing: 2) {
        Text(snapshot.familyDisplay)
        Text("·")
        Text(snapshot.auxiliary)
        Text("·")
        Text("pp:")
        Text(widgetMixedCase: snapshot.perfektpartizip)
          .fontWeight(.medium)
      }
      .font(.caption2)
      .foregroundStyle(.secondary)

      Divider()

      Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 1) {
        ForEach(0..<3, id: \.self) { row in
          GridRow {
            conjugationCell(snapshot.präsensParadigm[row])
            conjugationCell(snapshot.präsensParadigm[row + 3])
          }
        }
      }

      if let german = snapshot.exampleGerman {
        Divider()
        VStack(alignment: .leading, spacing: 1) {
          Text(german)
            .font(.caption2)
            .italic()
            .lineLimit(2)
          if let source = snapshot.exampleSource {
            Text("— \(source)")
              .font(.system(size: 9))
              .foregroundStyle(.tertiary)
          }
        }
      }

      if let etymology = snapshot.etymologySnippet {
        Divider()
        Text(etymology)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }

      Spacer(minLength: 0)
    }
    .widgetURL(URL(string: "konjugieren://verb/\(snapshot.infinitiv)"))
  }

  private func conjugationCell(_ conjugation: WidgetConjugation) -> some View {
    HStack(spacing: 3) {
      Text(conjugation.pronoun)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .frame(width: 20, alignment: .trailing)
      Text(widgetMixedCase: conjugation.mixedCaseForm)
        .font(.caption)
        .fontWeight(.medium)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
  }
}
