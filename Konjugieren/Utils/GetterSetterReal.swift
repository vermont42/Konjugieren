// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

class GetterSetterReal: GetterSetter {
  private let userDefaults = UserDefaults.standard

  func get(key: String) -> String? {
    userDefaults.string(forKey: key)
  }

  func set(key: String, value: String) {
    userDefaults.set(value, forKey: key)
  }
}
