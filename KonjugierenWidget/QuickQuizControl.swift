// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct QuickQuizControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "QuickQuizControl") {
      ControlWidgetButton(action: OpenQuizIntent()) {
        Label("Quick Quiz", systemImage: "pencil.circle.fill")
      }
    }
    .displayName("Quick Quiz")
    .description("Launch the conjugation quiz.")
  }
}
