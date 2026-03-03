// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
  let snapshot: WidgetSnapshot

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(snapshot.infinitiv)
          .font(.title2)
          .fontWeight(.bold)
          .minimumScaleFactor(0.7)
        Spacer()
        Button(intent: NextVerbIntent()) {
          Image(systemName: "forward.fill")
            .font(.caption2)
        }
        .buttonStyle(.plain)
      }

      Text(snapshot.translation)
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)

      Spacer()

      if let ich = snapshot.präsensParadigm.first {
        conjugationRow(ich)
      }
      if let sie = snapshot.präsensParadigm.last {
        conjugationRow(sie)
      }
    }
    .widgetURL(URL(string: "konjugieren://verb/\(snapshot.infinitiv)"))
  }

  private func conjugationRow(_ conjugation: WidgetConjugation) -> some View {
    HStack(spacing: 2) {
      Text(conjugation.pronoun)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Text(widgetMixedCase: conjugation.mixedCaseForm)
        .font(.subheadline)
        .fontWeight(.semibold)
    }
    .lineLimit(1)
    .minimumScaleFactor(0.4)
  }
}
