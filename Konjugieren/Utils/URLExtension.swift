// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension URL {
  var isDeeplink: Bool {
    scheme == "konjugieren"
  }

  var hasExpectedNumberOfDeeplinkComponents: Bool {
    pathComponents.count == 2
  }

  /// The surface that built this deeplink, which a widget or an intent names in a `source` query
  /// item because the deeplink is all it can hand the app.
  var analyticsSource: AnalyticsSource? {
    URLComponents(url: self, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first { $0.name == URL.sourceQueryName }?
      .value
      .flatMap(AnalyticsSource.init(rawValue:))
  }

  static func verbDeeplink(_ infinitiv: String, source: AnalyticsSource) -> URL? {
    URL(string: "\(konjugierenURLPrefix)\(verbHost)/\(infinitiv)?\(sourceQueryName)=\(source.rawValue)")
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

  static let konjugierenURLPrefix = "konjugieren://"
  static let quizHost = "quiz"
  static let verbHost = "verb"
  static let familyHost = "family"
  static let infoHost = "info"
  static let sourceQueryName = "source"
}
