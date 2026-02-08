// Copyright © 2026 Josh Adams. All rights reserved.

import TelemetryDeck

class AnalyticsReal: Analytics {
  func initialize(appID: String) {
    TelemetryDeck.initialize(config: TelemetryDeck.Config(appID: appID))
  }

  func signal(name: AnalyticsName, parameters: [String: String]) {
    TelemetryDeck.signal(name.rawValue, parameters: parameters)
  }
}
