// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

class GetterSetterFake: GetterSetter {
  var dictionary: [String: String] = [:]

  init() {}

  init(dictionary: [String: String]) {
    self.dictionary = dictionary
  }

  func get(key: String) -> String? {
    dictionary[key]
  }

  func set(key: String, value: String) {
    dictionary[key] = value
  }
}
