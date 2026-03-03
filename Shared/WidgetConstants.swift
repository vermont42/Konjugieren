// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum WidgetConstants {
  static let appGroupID = "group.biz.joshadams.Konjugieren"
  static let snapshotFilename = "widget-snapshot.json"
  static let debugOffsetKey = "widgetDebugOffset"
  static let quizAnsweredKey = "widgetQuizAnswered"
  static let quizCorrectKey = "widgetQuizCorrect"
  static let quizQuestionIDKey = "widgetQuizQuestionID"

  static var sharedContainerURL: URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
  }

  static var snapshotURL: URL? {
    sharedContainerURL?.appendingPathComponent(snapshotFilename)
  }

  static var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: appGroupID)
  }
}
