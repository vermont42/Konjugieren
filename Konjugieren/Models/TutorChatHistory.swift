// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum TutorChatHistory {
  static let storageKey = "tutorChatHistory"
  static let maxMessages = 200

  static func save(_ messages: [TutorMessage], getterSetter: GetterSetter) {
    guard let data = try? JSONEncoder().encode(messages),
          let jsonString = String(data: data, encoding: .utf8) else { return }
    getterSetter.set(key: storageKey, value: jsonString)
  }

  static func load(getterSetter: GetterSetter) -> [TutorMessage] {
    guard let jsonString = getterSetter.get(key: storageKey),
          let data = jsonString.data(using: .utf8) else { return [] }
    return (try? JSONDecoder().decode([TutorMessage].self, from: data)) ?? []
  }

  static func clear(getterSetter: GetterSetter) {
    getterSetter.set(key: storageKey, value: "")
  }

  static func isEmpty(getterSetter: GetterSetter) -> Bool {
    load(getterSetter: getterSetter).isEmpty
  }
}
