// Copyright © 2026 Josh Adams. All rights reserved.

enum Prefix: Equatable, Hashable {
  case separable(String)
  case inseparable(String)
  case none
}
