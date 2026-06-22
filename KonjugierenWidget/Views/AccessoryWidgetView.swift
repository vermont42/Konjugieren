// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct AccessoryRectangularView: View {
  let snapshot: WidgetSnapshot

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(snapshot.infinitiv)
        .font(.headline)
        .widgetAccentable()
      Text(snapshot.translation)
        .font(.caption)
        .lineLimit(1)
      if let thirdPerson = snapshot.thirdSingularConjugation {
        Text("\(thirdPerson.pronoun) \(thirdPerson.mixedCaseForm.lowercased())")
          .font(.caption2)
      }
    }
    .widgetURL(URL(string: "konjugieren://verb/\(snapshot.infinitiv)"))
  }
}

struct AccessoryInlineView: View {
  let snapshot: WidgetSnapshot

  var body: some View {
    Text("\(snapshot.infinitiv) — \(snapshot.translation)")
      .widgetURL(URL(string: "konjugieren://verb/\(snapshot.infinitiv)"))
  }
}
