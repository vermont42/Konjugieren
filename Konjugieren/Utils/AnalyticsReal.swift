// Copyright © 2026 Josh Adams. All rights reserved.

import TelemetryDeck

class AnalyticsReal: Analytics {
  private var isInitialized = false

  func initialize(appID: String) {
    guard !appID.isEmpty else { return }
    TelemetryDeck.initialize(config: TelemetryDeck.Config(appID: appID))
    isInitialized = true
  }

  func signal(name: AnalyticsName, parameters: [String: String]) {
    guard isInitialized else { return }
    TelemetryDeck.signal(name.rawValue, parameters: parameters)
  }
}
