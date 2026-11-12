// Copyright © 2026 Josh Adams. All rights reserved.

enum Family: Hashable {
  case strong(ablautGroup: String, ablautStartIndex: Int, ablautEndIndex: Int)
  case mixed(ablautGroup: String, ablautStartIndex: Int, ablautEndIndex: Int)
  case weak
  case ieren
}
