// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct QuickQuizControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "QuickQuizControl") {
      ControlWidgetButton(action: OpenQuizIntent()) {
        Label {
          Text(WidgetL.QuickQuiz.name)
        } icon: {
          Image(systemName: "pencil.circle.fill")
        }
      }
    }
    .displayName(WidgetL.QuickQuiz.name)
    .description(WidgetL.QuickQuiz.controlDescription)
  }
}
