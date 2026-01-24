// Copyright © 2026 Josh Adams. All rights reserved.

enum Family: Hashable, CustomStringConvertible {
  case strong(ablautGroup: String, ablautStartIndex: Int, ablautEndIndex: Int)
  case mixed(ablautGroup: String, ablautStartIndex: Int, ablautEndIndex: Int)
  case weak
  case ieren

  var pastParticiplePrefix: String {
    switch self {
    case .strong, .mixed, .weak:
      return "ge"
    case .ieren:
      return ""
    }
  }

  var displayName: String {
    switch self {
    case .strong:
      return L.Family.strong
    case .mixed:
      return L.Family.mixed
    case .weak:
      return L.Family.weak
    case .ieren:
      return L.Family.ieren
    }
  }

  var description: String {
    switch self {
    case .strong(ablautGroup: let ablautGroup, ablautStartIndex: let ablautStartIndex, ablautEndIndex: let ablautEndIndex):
      return "strong: \(ablautGroup), \(ablautStartIndex), \(ablautEndIndex)"
    case .mixed(ablautGroup: let ablautGroup, ablautStartIndex: let ablautStartIndex, ablautEndIndex: let ablautEndIndex):
      return "mixed: \(ablautGroup), \(ablautStartIndex), \(ablautEndIndex)"
    case .weak:
      return "weak"
    case .ieren:
      return "ieren"
    }
  }
}
