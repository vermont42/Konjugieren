// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct FindVerbControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "FindVerbControl") {
      ControlWidgetButton(action: OpenVerbSearchIntent()) {
        Label {
          Text(WidgetL.FindVerb.name)
        } icon: {
          Image(systemName: "magnifyingglass")
        }
      }
    }
    .displayName(WidgetL.FindVerb.name)
    .description(WidgetL.FindVerb.controlDescription)
  }
}
