// Copyright © 2026 Josh Adams. All rights reserved.

class FatalErrorSpy: FatalError {
  private(set) var messages: [String] = []

  func fatalError(_ message: String) {
    messages.append(message)
  }
}
