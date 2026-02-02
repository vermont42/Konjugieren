// Copyright © 2026 Josh Adams. All rights reserved.

struct FatalErrorReal: FatalError {
  func fatalError(_ message: String) {
    Swift.fatalError(message)
  }
}
