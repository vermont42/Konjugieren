// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum WidgetSnapshotWriter {
  private static let calendar = WidgetConstants.gregorianCalendar

  @MainActor static func writeSnapshot(now: Date = Date()) {
    guard let url = WidgetConstants.snapshotURL else { return }
    let pageOffset = WidgetConstants.sharedDefaults?.integer(forKey: WidgetConstants.debugOffsetKey) ?? 0
    let displayed = (try? Data(contentsOf: url))
      .flatMap { try? JSONDecoder().decode(WidgetSnapshotBundle.self, from: $0) }
      .flatMap { $0.displayedSnapshot(at: now, pageOffset: pageOffset) }
      .flatMap { Verb.verbs[$0.infinitiv] }
    guard let bundle = generateBundle(startDate: now, myVerbs: Current.learnerVerbs.myVerbs, keeping: displayed, pageOffset: pageOffset) else { return }
    guard let data = try? JSONEncoder().encode(bundle) else { return }
    try? data.write(to: url, options: .atomic)
  }

  /// `keeping` is the verb the widget shows now. It stays in the place the widget will show
  /// today, so that a change to My Verbs since the last write cannot replace it.
  @MainActor static func generateBundle(startDate: Date = Date(), myVerbs: [Verb] = [], keeping displayed: Verb? = nil, pageOffset: Int = 0, level: QuizLevel = Current.settings.quizLevel) -> WidgetSnapshotBundle? {
    let baseDay = calendar.startOfDay(for: startDate)
    let dayCount = WidgetConstants.snapshotDayCount
    let displayedIndex = WidgetSnapshotBundle.snapshotIndex(dayOffset: 0, pageOffset: pageOffset, count: dayCount)
    let eligibleMyVerbs = myVerbs.filter(isEligible)
    let eligibleFrequentVerbs = VerbDraw.frequentVerbs.filter(isEligible)
    var snapshots: [WidgetSnapshot] = []
    for dayOffset in 0..<dayCount {
      guard let day = calendar.date(byAdding: .day, value: dayOffset, to: baseDay) else { continue }
      let kept = dayOffset == displayedIndex ? displayed : nil
      guard let verb = kept ?? VerbDraw.verbOfTheDay(on: day, myVerbs: eligibleMyVerbs, frequentVerbs: eligibleFrequentVerbs) else { return nil }
      snapshots.append(generateSnapshot(verb: verb, date: day, level: level))
    }
    guard !snapshots.isEmpty else { return nil }
    return WidgetSnapshotBundle(baseDate: baseDay, snapshots: snapshots)
  }

  /// The large widget shows the example sentence.
  @MainActor static func isEligible(_ verb: Verb) -> Bool {
    ExampleSentences.pair(for: verb.infinitiv) != nil
  }

  @MainActor static func generateSnapshot(verb: Verb, date: Date, level: QuizLevel = Current.settings.quizLevel) -> WidgetSnapshot {
    let paradigm = präsensParadigm(for: verb.infinitiv)
    let partizip = RegionalConjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: .perfektpartizip)
    let partizipString: String
    switch partizip {
    case .success(let value):
      partizipString = value
    case .failure:
      partizipString = ""
    }

    let examplePair = ExampleSentences.pair(for: verb.infinitiv)
    let etymology = Etymology.text(for: verb.infinitiv)
    let truncatedEtymology = etymology.map { truncateToSentenceBoundary($0, maxLength: 450) }
    let quiz = quizQuestion(on: date, level: level, fallbackVerb: verb)

    return WidgetSnapshot(
      infinitiv: verb.infinitiv,
      translation: verb.translation,
      familyDisplay: verb.family.displayName,
      auxiliary: verb.auxiliary.verb,
      präsensParadigm: paradigm,
      perfektpartizip: partizipString,
      etymologySnippet: truncatedEtymology,
      exampleGerman: examplePair?.german.sentence,
      exampleSource: examplePair?.german.source,
      quizQuestion: quiz
    )
  }

  @MainActor private static func präsensParadigm(for infinitiv: String) -> [WidgetConjugation] {
    PersonNumber.allCases.map { pn in
      let result = RegionalConjugator.conjugate(infinitiv: infinitiv, conjugationgroup: .präsensIndikativ(pn))
      let form: String
      switch result {
      case .success(let value):
        form = value
      case .failure:
        form = "?"
      }
      return WidgetConjugation(pronoun: pn.pronoun, mixedCaseForm: form)
    }
  }

  /// The quiz widget's question for a day: the first question of that day's challenge at the
  /// level, so that the widget and the challenge agree. Its wrong
  /// answers are the same reading's other cells: one of the same table, one of the same person in
  /// another of the level's tables, and one more of either, chosen by a generator seeded with the
  /// question's ID.
  @MainActor static func quizQuestion(on date: Date, level: QuizLevel, fallbackVerb verb: Verb) -> WidgetQuizQuestion {
    let key = DailyChallenge.Key(date: date, level: level)
    let question = DailyChallenge.questions(for: key).first
      ?? QuizDrawnQuestion(verb: verb, conjugationgroup: .präsensIndikativ(.thirdSingular), readingIndex: 0)
    return quizQuestion(for: question, key: key)
  }

  @MainActor static func quizQuestion(for question: QuizDrawnQuestion, key: DailyChallenge.Key) -> WidgetQuizQuestion {
    let cell = question.conjugationgroup
    let correctAnswer = conjugation(of: question, in: cell) ?? "?"
    let questionID = "\(key.day)-\(key.levelKey)-\(question.verb.infinitiv)"
    var generator = SeededRNG(seed: WidgetQuizQuestion.stableSeed(for: questionID))
    return WidgetQuizQuestion(
      infinitiv: question.verb.infinitiv,
      conjugationgroupDisplay: cell.displayName(lang: Current.settings.conjugationgroupLang),
      pronoun: cell.quizPronoun,
      correctAnswer: correctAnswer,
      wrongAnswers: wrongAnswers(for: question, correctAnswer: correctAnswer, tables: key.level.pool.map(\.table), using: &generator),
      questionID: questionID
    )
  }

  @MainActor private static func wrongAnswers(for question: QuizDrawnQuestion, correctAnswer: String, tables: [ConjugationTable], using generator: inout SeededRNG) -> [String] {
    let cell = question.conjugationgroup
    // An Imperativ carries its pronoun (dürfen wir, kommen Sie), so it would stand out among a
    // finite question's options as plainly wrong.
    let tables = cell.table == .imperativ ? tables : tables.filter { $0 != .imperativ }
    let sameTable = cell.table.cells.filter { $0 != cell }.shuffled(using: &generator)
    let samePerson = tables
      .filter { $0 != cell.table }
      .compactMap { table in table.cells.first { $0.personNumber == cell.personNumber } }
      .shuffled(using: &generator)
    let anyCell = tables.flatMap(\.cells).filter { $0 != cell }.shuffled(using: &generator)
    var answers: [String] = []
    func take(from cells: [Conjugationgroup], upTo count: Int) {
      for candidate in cells where answers.count < count {
        if let form = conjugation(of: question, in: candidate), form != correctAnswer, !answers.contains(form) {
          answers.append(form)
        }
      }
    }
    take(from: sameTable, upTo: 1)
    take(from: samePerson, upTo: answers.count + 1)
    take(from: anyCell, upTo: wrongAnswerCount)
    // A level whose tables give too few distinct conjugations, which none does today.
    while answers.count < wrongAnswerCount {
      answers.append(correctAnswer + String(repeating: "x", count: wrongAnswerCount - answers.count))
    }
    return answers
  }

  private static let wrongAnswerCount = 3

  /// Lowercased, since the conjugator's capitals mark ablaut for the app to highlight and the
  /// widget's buttons show plain text.
  @MainActor private static func conjugation(of question: QuizDrawnQuestion, in cell: Conjugationgroup) -> String? {
    switch RegionalConjugator.conjugate(infinitiv: question.verb.infinitiv, conjugationgroup: cell, readingIndex: question.readingIndex) {
    case .success(let form):
      return form.lowercased()
    case .failure:
      return nil
    }
  }

  private static func truncateToSentenceBoundary(_ text: String, maxLength: Int) -> String {
    guard text.count > maxLength else { return text }
    let prefix = String(text.prefix(maxLength))
    if let lastPeriod = prefix.lastIndex(of: ".") {
      return String(prefix[...lastPeriod])
    }
    return prefix + "..."
  }
}
