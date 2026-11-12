// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct RandomVerbControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "RandomVerbControl") {
      ControlWidgetButton(action: OpenRandomVerbControlIntent()) {
        Label {
          Text(WidgetL.RandomVerb.name)
        } icon: {
          Image(systemName: "shuffle")
        }
      }
    }
    .displayName(WidgetL.RandomVerb.name)
    .description(WidgetL.RandomVerb.controlDescription)
  }
}
