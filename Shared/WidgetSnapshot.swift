// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct WidgetSnapshotBundle: Codable, Equatable {
  let baseDate: Date
  let snapshots: [WidgetSnapshot]

  // For each cached day (index = days since baseDate), the snapshot index to show.
  // The page offset advances the verb on a Next tap and wraps around the cached range.
  func pagedSnapshotIndices(pageOffset: Int) -> [Int] {
    let count = snapshots.count
    guard count > 0 else { return [] }
    return (0..<count).map { dayOffset in
      Self.snapshotIndex(dayOffset: dayOffset, pageOffset: pageOffset, count: count)
    }
  }

  static func snapshotIndex(dayOffset: Int, pageOffset: Int, count: Int) -> Int {
    (((dayOffset + pageOffset) % count) + count) % count
  }

  /// The snapshot the widget shows at a moment, or nil when the moment falls outside the cached
  /// days. The app keeps this verb when it rewrites the bundle, so the widget's verb holds
  /// through the day.
  func displayedSnapshot(at date: Date, pageOffset: Int) -> WidgetSnapshot? {
    let calendar = WidgetConstants.gregorianCalendar
    guard
      let dayOffset = calendar.dateComponents([.day], from: calendar.startOfDay(for: baseDate), to: calendar.startOfDay(for: date)).day,
      snapshots.indices.contains(dayOffset)
    else {
      return nil
    }
    return snapshots[Self.snapshotIndex(dayOffset: dayOffset, pageOffset: pageOffset, count: snapshots.count)]
  }
}

struct WidgetSnapshot: Codable, Equatable {
  let infinitiv: String
  let translation: String
  let familyDisplay: String
  let auxiliary: String
  let präsensParadigm: [WidgetConjugation]
  let perfektpartizip: String
  let etymologySnippet: String?
  let exampleGerman: String?
  let exampleSource: String?
  let quizQuestion: WidgetQuizQuestion

  // präsensParadigm is written in PersonNumber.allCases order (fs/ss/ts/fp/sp/tp),
  // so the third-person-singular row is always at index 2.
  var thirdSingularConjugation: WidgetConjugation? {
    präsensParadigm.indices.contains(2) ? präsensParadigm[2] : nil
  }
}

struct WidgetConjugation: Codable, Equatable {
  let pronoun: String
  let mixedCaseForm: String
}

struct WidgetQuizQuestion: Codable, Equatable {
  let infinitiv: String
  let conjugationgroupDisplay: String
  let pronoun: String?
  let correctAnswer: String
  let wrongAnswers: [String]
  let questionID: String
}
