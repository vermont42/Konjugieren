// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct QuizErrorRecord: Codable {
  let infinitiv: String
  let conjugationgroupKey: String
  let familyDescription: String
  let userAnswer: String
  let correctAnswer: String
  let timestamp: Date
}

enum QuizErrorHistory {
  static let storageKey = "quizErrorHistory"
  static let maxRecords = 200

  static func record(_ record: QuizErrorRecord, getterSetter: GetterSetter) {
    var records = load(getterSetter: getterSetter)
    records.append(record)
    if records.count > maxRecords {
      records = Array(records.suffix(maxRecords))
    }
    save(records, getterSetter: getterSetter)
  }

  static func load(getterSetter: GetterSetter) -> [QuizErrorRecord] {
    getterSetter.getCodable(key: storageKey) ?? []
  }

  static func aggregated(getterSetter: GetterSetter) -> String {
    let records = load(getterSetter: getterSetter)
    guard !records.isEmpty else { return "" }

    var counts: [String: Int] = [:]
    for record in records {
      counts[record.conjugationgroupKey, default: 0] += 1
    }

    return counts
      .sorted { $0.value > $1.value }
      .map { "\($0.key): \($0.value)" }
      .joined(separator: ", ")
  }

  private static func save(_ records: [QuizErrorRecord], getterSetter: GetterSetter) {
    getterSetter.setCodable(key: storageKey, value: records)
  }
}
