// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct QuizEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
  let isAnswered: Bool
  let wasCorrect: Bool
}

struct QuizProvider: TimelineProvider {
  func placeholder(in context: Context) -> QuizEntry {
    QuizEntry(date: Date(), snapshot: SnapshotReader.placeholder, isAnswered: false, wasCorrect: false)
  }

  func getSnapshot(in context: Context, completion: @escaping (QuizEntry) -> Void) {
    let now = Date()
    let snapshot = SnapshotReader.currentSnapshot(now: now, pageOffset: pageOffset)
    let (isAnswered, wasCorrect) = readQuizState(snapshot: snapshot)
    completion(QuizEntry(date: now, snapshot: snapshot, isAnswered: isAnswered, wasCorrect: wasCorrect))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<QuizEntry>) -> Void) {
    let entries = SnapshotReader.dailyEntries(now: Date(), pageOffset: pageOffset).map { pair in
      let (isAnswered, wasCorrect) = readQuizState(snapshot: pair.snapshot)
      return QuizEntry(date: pair.date, snapshot: pair.snapshot, isAnswered: isAnswered, wasCorrect: wasCorrect)
    }
    let refreshDate = (entries.last?.date ?? Date()).addingTimeInterval(86400)
    completion(Timeline(entries: entries, policy: .after(refreshDate)))
  }

  private var pageOffset: Int {
    WidgetConstants.sharedDefaults?.integer(forKey: WidgetConstants.debugOffsetKey) ?? 0
  }

  private func readQuizState(snapshot: WidgetSnapshot) -> (isAnswered: Bool, wasCorrect: Bool) {
    guard let defaults = WidgetConstants.sharedDefaults else { return (false, false) }
    let storedID = defaults.string(forKey: WidgetConstants.quizQuestionIDKey) ?? ""
    guard storedID == snapshot.quizQuestion.questionID else { return (false, false) }
    let isAnswered = defaults.bool(forKey: WidgetConstants.quizAnsweredKey)
    let wasCorrect = defaults.bool(forKey: WidgetConstants.quizCorrectKey)
    return (isAnswered, wasCorrect)
  }
}

struct QuizWidget: Widget {
  let kind = "QuizWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: QuizProvider()) { entry in
      QuizWidgetView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName(WidgetL.Quiz.configDisplayName)
    .description(WidgetL.Quiz.configDescription)
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
