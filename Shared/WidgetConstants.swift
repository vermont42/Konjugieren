// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum WidgetConstants {
  static let appGroupID = "group.biz.joshadams.Konjugieren"
  static let snapshotFilename = "widget-snapshot.json"
  static let debugOffsetKey = "widgetDebugOffset"
  static let quizAnsweredKey = "widgetQuizAnswered"
  static let quizCorrectKey = "widgetQuizCorrect"
  static let quizQuestionIDKey = "widgetQuizQuestionID"
  static let pendingDeeplinkKey = "widgetPendingDeeplink"

  static let snapshotDayCount = 10

  static let gregorianCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
  }()

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
