// Copyright © 2026 Josh Adams. All rights reserved.

enum Prefix: Equatable, Hashable, CustomStringConvertible {
  case separable(String)
  case inseparable(String)
  case none

  var description: String {
    switch self {
    case .separable(let prefix):
      return "separable: \(prefix)"
    case .inseparable(let prefix):
      return "inseparable: \(prefix)"
    case .none:
      return "none"
    }
  }
}
