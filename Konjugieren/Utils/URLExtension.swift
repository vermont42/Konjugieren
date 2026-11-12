// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension URL {
  var isDeeplink: Bool {
    scheme == "konjugieren"
  }

  var hasExpectedNumberOfDeeplinkComponents: Bool {
    pathComponents.count == 2
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
}
