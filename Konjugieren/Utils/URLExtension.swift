// Copyright © 2025 Josh Adams. All rights reserved.

import Foundation

extension URL {
  var isDeeplink: Bool {
    scheme == "konjugieren"
  }

  var hasExpectedNumberOfDeeplinkComponents: Bool {
    pathComponents.count == 2
  }

  static let konjugierenURLPrefix = "konjugieren://"
  static let verbHost = "verb"
  static let familyHost = "family"
  static let infoHost = "info"
}
