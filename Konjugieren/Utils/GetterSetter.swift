// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

protocol GetterSetter {
  func get(key: String) -> String?
  func set(key: String, value: String)
}

extension GetterSetter {
  func setCodable<T: Encodable>(key: String, value: T) {
    guard
      let data = try? JSONEncoder().encode(value),
      let jsonString = String(data: data, encoding: .utf8)
    else {
      return
    }
    set(key: key, value: jsonString)
  }

  func getCodable<T: Decodable>(key: String) -> T? {
    guard
      let jsonString = get(key: key),
      let data = jsonString.data(using: .utf8)
    else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: data)
  }
}
