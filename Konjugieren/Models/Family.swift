// Copyright © 2026 Josh Adams. All rights reserved.

enum Family: Hashable {
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
}
