// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension URL {
  var isDeeplink: Bool {
    scheme == URL.deeplinkScheme
  }

  var hasExpectedNumberOfDeeplinkComponents: Bool {
    pathComponents.count == 2
  }

  /// The surface that built this deeplink, which a widget or an intent names in a `source` query
  /// item because the deeplink is all it can hand the app.
  var analyticsSource: AnalyticsSource? {
    deeplinkQueryValue(named: URL.sourceQueryName).flatMap(AnalyticsSource.init(rawValue:))
  }

  /// The value of a query item, such as a search's text. Text always travels in a query item,
  /// never in the path, because it can hold spaces and slashes.
  func deeplinkQueryValue(named name: String) -> String? {
    URLComponents(url: self, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first { $0.name == name }?
      .value
  }

  /// `konjugieren://verb/aufstehen?source=lookup&match=stand%20auf`. A `match` names a
  /// conjugation that the page marks, as it marks a search's match.
  static func verbDeeplink(_ infinitiv: String, source: AnalyticsSource, match: String? = nil) -> URL? {
    deeplink(host: verbHost, target: infinitiv, queryItems: [
      URLQueryItem(name: sourceQueryName, value: source.rawValue),
      match.map { URLQueryItem(name: matchQueryName, value: $0) },
    ])
  }

  /// `konjugieren://search?q=ging&source=control`. With no `q`, search opens empty and focused.
  static func searchDeeplink(text: String?, source: AnalyticsSource) -> URL? {
    deeplink(host: searchHost, target: nil, queryItems: [
      text.map { URLQueryItem(name: searchTextQueryName, value: $0) },
      URLQueryItem(name: sourceQueryName, value: source.rawValue),
    ])
  }

  /// `konjugieren://info/futur_ii`. The stable key survives the reordering of articles, which
  /// an index does not.
  static func infoDeeplink(_ info: Info) -> URL? {
    deeplink(host: infoHost, target: info.stableKey, queryItems: [])
  }

  private static func deeplink(host: String, target: String?, queryItems: [URLQueryItem?]) -> URL? {
    var components = URLComponents()
    components.scheme = deeplinkScheme
    components.host = host
    components.path = target.map { "/\($0)" } ?? ""
    let items = queryItems.compactMap { $0 }
    components.queryItems = items.isEmpty ? nil : items
    return components.url
  }

  /// Konjugieren's App Store page. With no storefront in the path, the App Store opens the
  /// reader's own.
  nonisolated static var appStore: URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "apps.apple.com"
    components.path = "/app/konjugieren/id\(RatingsFetcher.iTunesID)"
    return components.url ?? URL(filePath: "/")
  }

  static let developerEmail = "vermontcoder@gmail.com"

  nonisolated private static let mailtoUnreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

  /// A `mailto:` link with the subject and body filled in. Every character outside RFC 3986's
  /// unreserved set is percent-encoded, because a learner's query can hold &, =, #, or an umlaut.
  nonisolated static func mailto(_ address: String, subject: String, body: String) -> URL? {
    let encode = { (text: String) in text.addingPercentEncoding(withAllowedCharacters: mailtoUnreserved) ?? "" }
    return URL(string: "mailto:\(address)?subject=\(encode(subject))&body=\(encode(body))")
  }

  static let deeplinkScheme = "konjugieren"
  static let konjugierenURLPrefix = "\(deeplinkScheme)://"
  static let quizHost = "quiz"
  static let verbHost = "verb"
  static let familyHost = "family"
  static let infoHost = "info"
  static let searchHost = "search"
  static let sourceQueryName = "source"
  static let matchQueryName = "match"
  static let searchTextQueryName = "q"
}
