// Copyright © 2025 Josh Adams. All rights reserved.

enum Auxiliary: String {
  case haben = "h"
  case sein = "s"

  var verb: String {
    switch self {
    case .haben:
      return "haben"
    case .sein:
      return "sein"
    }
  }
}
