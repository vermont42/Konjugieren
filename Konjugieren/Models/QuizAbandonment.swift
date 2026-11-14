// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The quizzes in progress, kept so that the next launch can report one the app was left during
/// (the report's M2). A quiz writes its entry as it starts and at each question, and removes it
/// when it is quit or reaches its results, so an entry still present at launch belongs to a quiz
/// that ended with the app. Entries are keyed by quiz, since a quiz in a sheet can run beside the
/// Quiz tab's.
enum QuizAbandonment {
  struct Entry: Codable, Equatable {
    let level: String
    let source: String
    let questionNumber: Int
  }

  static let key = "quizzesInProgress"

  static func record(_ entry: Entry, id: String, getterSetter: GetterSetter) {
    var entries = entries(getterSetter: getterSetter)
    entries[id] = entry
    store(entries, getterSetter: getterSetter)
  }

  static func clear(id: String, getterSetter: GetterSetter) {
    var entries = entries(getterSetter: getterSetter)
    guard entries.removeValue(forKey: id) != nil else {
      return
    }
    store(entries, getterSetter: getterSetter)
  }

  /// Sends `abandonQuiz` for each quiz left in progress by the last run, and forgets them.
  static func reportAndClear(getterSetter: GetterSetter, analytics: Analytics) {
    let entries = entries(getterSetter: getterSetter)
    guard !entries.isEmpty else {
      return
    }
    for entry in entries.values {
      analytics.signal(name: .abandonQuiz, parameters: [
        ParameterKey.level.rawValue: entry.level,
        ParameterKey.questionNumber.rawValue: "\(entry.questionNumber)",
        ParameterKey.source.rawValue: entry.source
      ])
    }
    getterSetter.remove(key: key)
  }

  static func entries(getterSetter: GetterSetter) -> [String: Entry] {
    guard
      let stored = getterSetter.get(key: key),
      let data = stored.data(using: .utf8),
      let entries = try? JSONDecoder().decode([String: Entry].self, from: data)
    else {
      return [:]
    }
    return entries
  }

  private static func store(_ entries: [String: Entry], getterSetter: GetterSetter) {
    guard !entries.isEmpty else {
      getterSetter.remove(key: key)
      return
    }
    guard
      let data = try? JSONEncoder().encode(entries),
      let string = String(data: data, encoding: .utf8)
    else {
      return
    }
    getterSetter.set(key: key, value: string)
  }
}
