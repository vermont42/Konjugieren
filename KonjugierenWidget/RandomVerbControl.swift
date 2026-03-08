// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct RandomVerbControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "RandomVerbControl") {
      ControlWidgetButton(action: OpenRandomVerbIntent()) {
        Label("Random Verb", systemImage: "shuffle")
      }
    }
    .displayName("Random Verb")
    .description("Open a random German verb.")
  }
}
