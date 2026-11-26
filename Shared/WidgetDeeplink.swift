// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The links that the widget extension and the intents in `Shared/` hand the app. Neither can see
/// `AnalyticsSource` or the app's link builders, so their sources are spelled here, once, and
/// `DeeplinkTests` pins each to the vocabulary and each verb link to `URL.verbDeeplink`.
nonisolated enum WidgetDeeplink: Hashable, Sendable {
  /// Today's challenge at the learner's level, from the quiz widget.
  case challenge
  /// The verb list with its search field focused, from the Find a Verb control.
  case findVerb
  /// The Quiz tab, from the Quick Quiz control and the shortcut.
  case quiz
  case randomVerbFromControl
  case randomVerbFromShortcut
  /// A verb's page, from a widget.
  case verb(String)

  var url: URL? {
    var components = URLComponents()
    components.scheme = "konjugieren"
    let source: String?
    switch self {
    case .challenge:
      components.host = "quiz"
      components.path = "/challenge"
      source = "challengeWidget"
    case .findVerb:
      components.host = "search"
      source = "control"
    case .quiz:
      components.host = "quiz"
      components.path = "/start"
      source = nil
    case .randomVerbFromControl:
      components.host = "verb"
      components.path = "/random"
      source = "control"
    case .randomVerbFromShortcut:
      components.host = "verb"
      components.path = "/random"
      source = "shortcut"
    case .verb(let infinitiv):
      components.host = "verb"
      components.path = "/\(infinitiv)"
      source = "widget"
    }
    components.queryItems = source.map { [URLQueryItem(name: "source", value: $0)] }
    return components.url
  }
}
