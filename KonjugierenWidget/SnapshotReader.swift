// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum SnapshotReader {
  static func readBundle() -> WidgetSnapshotBundle? {
    guard let url = WidgetConstants.snapshotURL,
          let data = try? Data(contentsOf: url),
          let bundle = try? JSONDecoder().decode(WidgetSnapshotBundle.self, from: data)
    else {
      return nil
    }
    return bundle
  }

  /// One (date, snapshot) pair per cached day, in ascending date order, with the
  /// page offset applied. Emitting one timeline entry per pair lets WidgetKit advance
  /// the displayed day at each midnight with no app launch; the offset lets NextVerbIntent
  /// page forward. Falls back to a single placeholder entry when no bundle is cached yet.
  static func dailyEntries(now: Date, pageOffset: Int) -> [(date: Date, snapshot: WidgetSnapshot)] {
    guard let bundle = readBundle(), !bundle.snapshots.isEmpty else {
      return [(now, placeholder)]
    }
    let calendar = WidgetConstants.gregorianCalendar
    let baseDay = calendar.startOfDay(for: bundle.baseDate)
    return bundle.pagedSnapshotIndices(pageOffset: pageOffset).enumerated().map { dayOffset, index in
      let entryDate = calendar.date(byAdding: .day, value: dayOffset, to: baseDay) ?? baseDay
      return (date: entryDate, snapshot: bundle.snapshots[index])
    }
  }

  /// The snapshot the widget should show right now: the latest entry whose day has
  /// begun, or the first cached day if the bundle is entirely in the future.
  static func currentSnapshot(now: Date, pageOffset: Int) -> WidgetSnapshot {
    let entries = dailyEntries(now: now, pageOffset: pageOffset)
    let current = entries.last { $0.date <= now } ?? entries.first
    return current?.snapshot ?? placeholder
  }

  /// The cached snapshot whose quiz question matches a given ID, used by AnswerQuizIntent
  /// to grade an answer against the exact question the user was shown (which may be any
  /// paged day, not just today).
  static func snapshot(forQuestionID id: String) -> WidgetSnapshot? {
    readBundle()?.snapshots.first { $0.quizQuestion.questionID == id }
  }

  static var placeholder: WidgetSnapshot {
    WidgetSnapshot(
      infinitiv: "gehen",
      translation: "go, walk",
      familyDisplay: "strong",
      auxiliary: "sein",
      präsensParadigm: [
        WidgetConjugation(pronoun: "ich", mixedCaseForm: "gehe"),
        WidgetConjugation(pronoun: "du", mixedCaseForm: "gEHst"),
        WidgetConjugation(pronoun: "er", mixedCaseForm: "gEHt"),
        WidgetConjugation(pronoun: "wir", mixedCaseForm: "gehen"),
        WidgetConjugation(pronoun: "ihr", mixedCaseForm: "gEHt"),
        WidgetConjugation(pronoun: "sie", mixedCaseForm: "gehen")
      ],
      perfektpartizip: "gegAngen",
      etymologySnippet: "From Old High German gan, gangan.",
      exampleGerman: "Er geht jeden Morgen zur Arbeit.",
      exampleSource: "Example",
      quizQuestion: WidgetQuizQuestion(
        infinitiv: "gehen",
        conjugationgroupDisplay: "Present Indicative",
        pronoun: "ich",
        correctAnswer: "gehe",
        wrongAnswers: ["geht", "gehen", "gehst"],
        questionID: "placeholder"
      )
    )
  }
}
