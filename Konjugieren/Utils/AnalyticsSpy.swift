// Copyright © 2026 Josh Adams. All rights reserved.

class AnalyticsSpy: Analytics {
  private(set) var signalNames: [AnalyticsName] = []
  private(set) var signalParameters: [[String: String]] = []

  func initialize(appID: String) {}

  func signal(name: AnalyticsName, parameters: [String: String]) {
    signalNames.append(name)
    signalParameters.append(parameters)
  }
}
