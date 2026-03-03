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

      if let thirdPerson = snapshot.präsensParadigm.first(where: { $0.pronoun != "ich" && $0.pronoun != "du" && $0.pronoun != "wir" && $0.pronoun != "ihr" && $0.pronoun != "sie" }) {
        HStack(spacing: 2) {
          Text(thirdPerson.pronoun)
            .font(.subheadline)
            .foregroundStyle(.secondary)
          Text(widgetMixedCase: thirdPerson.mixedCaseForm)
            .font(.subheadline)
            .fontWeight(.semibold)
        }
      } else if let first = snapshot.präsensParadigm.first {
        HStack(spacing: 2) {
          Text(first.pronoun)
            .font(.subheadline)
            .foregroundStyle(.secondary)
          Text(widgetMixedCase: first.mixedCaseForm)
            .font(.subheadline)
            .fontWeight(.semibold)
        }
      }

      Text(snapshot.familyDisplay)
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .widgetURL(URL(string: "konjugieren://verb/\(snapshot.infinitiv)"))
  }
}
