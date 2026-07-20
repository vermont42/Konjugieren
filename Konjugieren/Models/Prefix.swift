// Copyright © 2026 Josh Adams. All rights reserved.

enum Prefix: Equatable, Hashable {
  case separable(String)
  case inseparable(String)
  case none

  var name: String? {
    switch self {
    case .separable(let name), .inseparable(let name):
      return name
    case .none:
      return nil
    }
  }
}
