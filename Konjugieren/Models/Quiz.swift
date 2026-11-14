// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import Foundation
import TipKit
import UIKit

@MainActor
@Observable
class Quiz {
  static let questionCount = 30
  static let pointsPerCorrect = 10
  static let pointsPerSecondAttempt = pointsPerCorrect / 2

  private(set) var isInProgress = false
  var shouldShowResults = false
  private(set) var currentIndex = 0
  private(set) var score = 0
  private(set) var elapsedSeconds = 0
  /// Right on the first attempt. A right second attempt is counted apart, in
  /// `secondAttemptCount`.
  private(set) var correctCount = 0
  private(set) var secondAttemptCount = 0

  /// The correction of a wrong answer, which holds the quiz on its question, with the clock
  /// stopped, until `continueAfterCorrection()`. A right answer advances at once.
  private(set) var correction: QuizCorrection?
  /// The conjugation's own spelling of the last answer, when that answer was right but written
  /// another way, such as with a digraph for an umlaut.
  private(set) var lastPreferredSpelling: String?

  private(set) var questions: [QuizItem] = []
  private(set) var scope = QuizScope.allVerbs

  var questionCount: Int {
    scope.questionCount
  }

  private var timer: Timer?
  private(set) var level: QuizLevel = Settings.quizLevelDefault
  private let timerInterval: TimeInterval
  private var randomSource: AnyRandomNumberGenerator
  private var liveActivity: Activity<QuizActivityAttributes>?

  var currentQuestion: QuizItem? {
    guard isInProgress, currentIndex < questions.count else { return nil }
    return questions[currentIndex]
  }

  /// True after a slip, while the question waits for its one more attempt.
  var isAwaitingSecondAttempt: Bool {
    currentQuestion?.isAwaitingSecondAttempt ?? false
  }

  var progressText: String {
    "\(currentIndex + 1) / \(questionCount)"
  }

  var elapsedText: String {
    TimeFormatter.formatIntTime(elapsedSeconds)
  }

  var elapsedTimeLiveActivity: String {
    TimeFormatter.formatMinutesSeconds(elapsedSeconds)
  }

  // Every level scores alike, since each will have its own leaderboard (Phase 8 of the pedagogy
  // plan) and no score compares across levels.
  var finalScore: Int {
    score
  }

  init(timerInterval: TimeInterval = 1.0, randomSource: any RandomNumberGenerator = SystemRandomNumberGenerator()) {
    self.timerInterval = timerInterval
    self.randomSource = AnyRandomNumberGenerator(randomSource)
  }

  func start(scope: QuizScope = .allVerbs) {
    self.scope = scope
    level = Current.settings.quizLevel
    questions = generateQuestions()
    guard !questions.isEmpty else {
      return
    }
    resetProgressState()
    isInProgress = true
    shouldShowResults = false
    startTimer()
    // A three-question quiz on a verb's page is over before a Live Activity would be noticed.
    if questionCount == Quiz.questionCount {
      let attributes = QuizActivityAttributes(
        level: level.localizedName,
        totalQuestions: questionCount
      )
      liveActivity = LiveActivityManager.start(
        attributes: attributes,
        initialState: makeContentState(isFinished: false)
      )
    }
    Current.soundPlayer.play(Sound.randomGun)
    HapticPlayer.playMediumImpact()
    var parameters = [
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.source.rawValue: scope.source.rawValue
    ]
    if let collectionKey = scope.collectionKey {
      parameters[ParameterKey.collection.rawValue] = collectionKey
    }
    Current.analytics.signal(name: .startQuiz, parameters: parameters)
    announceQuestion()
  }

  func submitAnswer(_ answer: String) {
    guard isInProgress, correction == nil, currentIndex < questions.count else { return }

    let isCorrect = questions[currentIndex].accepts(answer)
    let isSecondAttempt = questions[currentIndex].isAwaitingSecondAttempt

    // A question gets one more attempt at most, so a second slip goes to the correction.
    if !isCorrect, !isSecondAttempt, questions[currentIndex].isSlip(answer) {
      questions[currentIndex].firstAttempt = answer
      lastPreferredSpelling = nil
      Current.soundPlayer.play(.pop)
      HapticPlayer.playImpact(.light)
      announceSecondAttempt()
      return
    }

    questions[currentIndex].userAnswer = answer
    questions[currentIndex].isCorrect = isCorrect

    if isCorrect {
      if isSecondAttempt {
        score += Quiz.pointsPerSecondAttempt
        secondAttemptCount += 1
      } else {
        score += Quiz.pointsPerCorrect
        correctCount += 1
      }
      lastPreferredSpelling = questions[currentIndex].preferredSpelling(of: answer)
      Current.soundPlayer.play(.chime)
      HapticPlayer.playSuccess()
      announceAnswerResult(correct: true, preferredSpelling: lastPreferredSpelling)
      advance()
    } else {
      let question = questions[currentIndex]
      lastPreferredSpelling = nil
      stopTimer()
      correction = QuizCorrection(
        difference: question.difference(from: answer),
        errorContext: ErrorExplainerContext(
          infinitiv: question.verb.infinitiv,
          translation: question.translation,
          familyDescription: question.verb.family.displayName,
          conjugationgroupGerman: question.conjugationgroup.germanDisplayName,
          conjugationgroupEnglish: question.conjugationgroup.englishDisplayName,
          userAnswer: answer,
          correctAnswer: question.correctAnswer
        )
      )
      QuizErrorHistory.record(
        QuizErrorRecord(
          infinitiv: question.verb.infinitiv,
          conjugationgroupKey: question.conjugationgroup.englishDisplayName,
          familyDescription: question.verb.family.displayName,
          userAnswer: answer,
          correctAnswer: question.correctAnswer,
          timestamp: Date()
        ),
        getterSetter: Current.getterSetter
      )
      Current.soundPlayer.play(.buzz)
      HapticPlayer.playError()
    }
  }

  /// Leaves a held correction for the next question, or for the results after the last.
  func continueAfterCorrection() {
    guard isInProgress, correction != nil else { return }
    correction = nil
    advance()
    if isInProgress {
      startTimer()
    }
  }

  private func advance() {
    currentIndex += 1

    if let liveActivity {
      LiveActivityManager.update(liveActivity, state: makeContentState(isFinished: false))
    }

    if currentIndex >= questionCount {
      finishQuiz()
    } else {
      announceQuestion()
    }
  }

  func quit() {
    let questionNumber = currentIndex + 1
    stopTimer()
    isInProgress = false
    if let liveActivity {
      LiveActivityManager.end(liveActivity, finalState: makeContentState(isFinished: false))
      self.liveActivity = nil
    }
    resetProgressState()
    questions = []
    Current.soundPlayer.play(Sound.randomSadTrombone)
    Current.analytics.signal(name: .quitQuiz, parameters: [
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.questionNumber.rawValue: "\(questionNumber)",
      ParameterKey.source.rawValue: scope.source.rawValue
    ])
  }

  private func resetProgressState() {
    currentIndex = 0
    score = 0
    correctCount = 0
    secondAttemptCount = 0
    elapsedSeconds = 0
    correction = nil
    lastPreferredSpelling = nil
  }

  private func generateQuestions() -> [QuizItem] {
    #if DEBUG
    switch UserDefaults.standard.string(forKey: "KONJUGIEREN_QUIZ_FIXTURE") {
    case "screenshot":
      let items = generateScreenshotFixture()
      exportFixtureAnswers(items)
      return items
    case "grading":
      return generateGradingFixture()
    case "frames":
      return generateFramesFixture()
    case "corrections":
      return generateCorrectionsFixture()
    case "slips":
      return generateSlipsFixture()
    default:
      break
    }
    #endif

    return QuizDraw.questions(
      level: level,
      verbs: scope.verbs ?? Self.defaultVerbs(for: level),
      readingIndex: scope.readingIndex,
      count: scope.questionCount,
      distinctCells: scope.questionCount < Quiz.questionCount,
      mixesVerbs: scope.verbs == nil,
      using: &randomSource
    ).map { question in
      makeQuizItem(verb: question.verb, conjugationgroup: question.conjugationgroup, readingIndex: question.readingIndex)
    }
  }

  /// The verbs of the level's band. Sorted so that a seeded random source draws the same quiz in
  /// every process, since a dictionary's order changes from launch to launch.
  static func defaultVerbs(for level: QuizLevel) -> [Verb] {
    let verbs = level.band.map { Verb.verbs(in: $0) } ?? Array(Verb.verbs.values)
    return verbs.sorted { $0.infinitiv < $1.infinitiv }
  }

  func makeQuizItem(verb: Verb, conjugationgroup: Conjugationgroup, readingIndex: Int? = nil) -> QuizItem {
    // A question asks about exactly one reading, and the prompt shows that reading's gloss,
    // so a two-reading verb has one right answer rather than two. Without this, hängen in
    // the Präteritum would accept hing and hängte indistinguishably and teach neither.
    let readingIndex = readingIndex ?? verb.readings.indices.randomElement() ?? 0

    // The region setting governs presentation and never marks a learner wrong: a user who
    // types a correct conjugation from another standard variety has answered correctly.
    // Only the canonical answer, shown in results and error history, follows the setting.
    // The same holds for word order: the prompt gives no sentence, so a separable verb's
    // subordinate-clause conjugation (ankommt) is as right as the main-clause one shown
    // (kommt an).
    //
    // Duden's other standard conjugations of a cell, such as komme beside komm and stünde
    // beside stände, are right answers too, though the verb page shows only the conjugator's.
    let reading = verb.reading(at: readingIndex) ?? verb.primaryReading
    let acceptableAnswers = Set(Region.allCases.flatMap { region in
      Clause.allCases.flatMap { clause in
        let conjugation = RegionalConjugator.conjugateUnsafely(
          infinitiv: verb.infinitiv,
          conjugationgroup: conjugationgroup,
          region: region,
          readingIndex: readingIndex,
          clause: clause
        )
        let variants = StandardVariants.variants(of: conjugation, reading: reading, conjugationgroup: conjugationgroup, region: region)
        return ([conjugation] + variants).map { $0.lowercased() }
      }
    })
    let regionalSpellings = Clause.allCases.map { clause in
      RegionalConjugator.conjugateUnsafely(
        infinitiv: verb.infinitiv,
        conjugationgroup: conjugationgroup,
        readingIndex: readingIndex,
        clause: clause
      )
    }
    let correctAnswer = RegionalConjugator.conjugateUnsafely(
      infinitiv: verb.infinitiv,
      conjugationgroup: conjugationgroup,
      readingIndex: readingIndex
    )
    return QuizItem(
      verb: verb,
      conjugationgroup: conjugationgroup,
      correctAnswer: correctAnswer,
      acceptableAnswers: acceptableAnswers,
      regionalSpellings: regionalSpellings,
      readingIndex: readingIndex
    )
  }

  #if DEBUG
  private func generateScreenshotFixture() -> [QuizItem] {
    let plan: [(infinitiv: String, group: Conjugationgroup)] = [
      ("machen", .präsensIndikativ(.firstSingular)),
      ("haben", .präsensIndikativ(.thirdSingular)),
      ("sein", .perfektIndikativ(.firstSingular)),
      ("werden", .futurIndikativ(.thirdSingular)),
      ("gehen", .perfektpartizip),
      ("kommen", .perfektpartizip),
      ("lesen", .präsenspartizip),
      ("sprechen", .präsensIndikativ(.secondSingular)),
      ("singen", .präteritumIndikativ(.firstSingular)),
      ("denken", .präteritumIndikativ(.firstSingular)),
      ("sehen", .präsensIndikativ(.thirdSingular)),
      ("essen", .perfektIndikativ(.firstSingular)),
      ("trinken", .präteritumIndikativ(.firstSingular)),
      ("fahren", .präsensIndikativ(.thirdSingular)),
      ("laufen", .präsensIndikativ(.thirdSingular)),
      ("geben", .präsensIndikativ(.firstSingular)),
      ("nehmen", .präsensIndikativ(.firstSingular)),
      ("finden", .perfektIndikativ(.thirdSingular)),
      ("helfen", .imperativ(.secondSingular)),
      ("geben", .imperativ(.secondSingular)),
      ("studieren", .perfektIndikativ(.firstSingular)),
      ("verstehen", .präsensIndikativ(.firstSingular)),
      ("bringen", .präteritumIndikativ(.firstSingular)),
      ("wissen", .präsensIndikativ(.firstSingular)),
      ("können", .präsensIndikativ(.firstSingular)),
      ("müssen", .präsensIndikativ(.firstSingular)),
      ("wollen", .präsensIndikativ(.firstSingular)),
      ("schreiben", .präteritumIndikativ(.firstSingular)),
      ("bleiben", .perfektIndikativ(.thirdSingular)),
      ("ankommen", .präsensIndikativ(.thirdSingular))
    ]
    return plan.map { spec in
      guard let verb = Verb.verbs[spec.infinitiv] else {
        preconditionFailure("Screenshot fixture references missing verb: \(spec.infinitiv)")
      }
      return makeQuizItem(verb: verb, conjugationgroup: spec.group)
    }
  }

  // The answers Phase 1 of the pedagogy plan made right, one per question, for trying by hand:
  // ihr habt ferngeguckt, uebernehme, stossen Sie um, stuende, sammle, verglich, gehe, kämst,
  // sandte, and erkennt an. Any question count other than 30 is fine here, since the quiz
  // finishes at questionCount.
  private func generateGradingFixture() -> [QuizItem] {
    let plan: [(infinitiv: String, group: Conjugationgroup)] = [
      ("ferngucken", .perfektIndikativ(.secondPlural)),
      ("übernehmen", .präsensIndikativ(.firstSingular)),
      ("umstoßen", .imperativ(.thirdPlural)),
      ("stehen", .präteritumKonjunktivII(.firstSingular)),
      ("sammeln", .präsensIndikativ(.firstSingular)),
      ("vergleichen", .präteritumIndikativ(.firstSingular)),
      ("gehen", .imperativ(.secondSingular)),
      ("kommen", .präteritumKonjunktivII(.secondSingular)),
      ("senden", .präteritumIndikativ(.firstSingular)),
      ("anerkennen", .präsensIndikativ(.thirdSingular))
    ]
    return repeatedFixture(plan)
  }

  // One question per shape of answer frame from Phase 2 of the pedagogy plan, with its right
  // answer: angekommen, ankommend, ich stehe auf, sie (3p) kommen an, ihr seid angekommen,
  // (du) komm an!, (ihr) geht!, steigen wir nach!, stoßen Sie um!, and gehen Sie!
  private func generateFramesFixture() -> [QuizItem] {
    let plan: [(infinitiv: String, group: Conjugationgroup)] = [
      ("ankommen", .perfektpartizip),
      ("ankommen", .präsenspartizip),
      ("aufstehen", .präsensIndikativ(.firstSingular)),
      ("ankommen", .präsensIndikativ(.thirdPlural)),
      ("ankommen", .perfektIndikativ(.secondPlural)),
      ("ankommen", .imperativ(.secondSingular)),
      ("gehen", .imperativ(.secondPlural)),
      ("nachsteigen", .imperativ(.firstPlural)),
      ("umstoßen", .imperativ(.thirdPlural)),
      ("gehen", .imperativ(.thirdPlural))
    ]
    return repeatedFixture(plan)
  }

  // Questions to answer wrongly by hand for Phase 3 of the pedagogy plan, with a wrong answer
  // for each that shows a kind of marking: fahrt (a missing umlaut), komst (a missing letter),
  // ankomt (nearer the joined conjugation than kommt an), hat gemachen (a weak verb, which links
  // to its family), studirt (an -ieren verb), dachte (a mixed verb's wrong cell), gehne Sie (two
  // swapped letters), and singte (a strong verb made weak).
  private func generateCorrectionsFixture() -> [QuizItem] {
    let plan: [(infinitiv: String, group: Conjugationgroup)] = [
      ("fahren", .präsensIndikativ(.thirdSingular)),
      ("kommen", .präsensIndikativ(.secondSingular)),
      ("ankommen", .präsensIndikativ(.thirdSingular)),
      ("machen", .perfektIndikativ(.thirdSingular)),
      ("studieren", .präsensIndikativ(.thirdSingular)),
      ("denken", .präsensIndikativ(.firstSingular)),
      ("gehen", .imperativ(.thirdPlural)),
      ("singen", .präteritumIndikativ(.firstSingular))
    ]
    return repeatedFixture(plan)
  }

  // Answers to type by hand for Phase 4 of the pedagogy plan. Each slip below is offered one
  // more try: fahrst (a missing umlaut), komst (a missing letter), weis (a missing ß), sanf (a
  // wrong letter), ubernehme (a missing umlaut, which is not a digraph), and bin aufgestandn. Each
  // of these goes straight to the correction instead: kommt (er's cell, not du's), geb (under
  // four letters), musstest (the Präteritum Indikativ, not the Konjunktiv II), and fahrt for er
  // fährt (a missing umlaut, but also ihr fahrt).
  private func generateSlipsFixture() -> [QuizItem] {
    let plan: [(infinitiv: String, group: Conjugationgroup)] = [
      ("fahren", .präsensIndikativ(.secondSingular)),
      ("kommen", .präsensIndikativ(.secondSingular)),
      ("wissen", .präsensIndikativ(.firstSingular)),
      ("singen", .präteritumIndikativ(.firstSingular)),
      ("übernehmen", .präsensIndikativ(.firstSingular)),
      ("aufstehen", .perfektIndikativ(.firstSingular)),
      ("kommen", .präsensIndikativ(.secondSingular)),
      ("geben", .imperativ(.secondSingular)),
      ("müssen", .präteritumKonjunktivII(.secondSingular)),
      ("fahren", .präsensIndikativ(.thirdSingular))
    ]
    return repeatedFixture(plan)
  }

  // Repeated to the quiz's length, so that the progress dots and the finish behave as usual.
  // Each repeat is a new item, since the dots tell items apart by id.
  private func repeatedFixture(_ plan: [(infinitiv: String, group: Conjugationgroup)]) -> [QuizItem] {
    (0..<questionCount).map { index in
      let spec = plan[index % plan.count]
      guard let verb = Verb.verbs[spec.infinitiv] else {
        preconditionFailure("Quiz fixture references missing verb: \(spec.infinitiv)")
      }
      return makeQuizItem(verb: verb, conjugationgroup: spec.group)
    }
  }

  private func exportFixtureAnswers(_ items: [QuizItem]) {
    let payload = items.map { item -> [String: String] in
      [
        "infinitiv": item.verb.infinitiv,
        "group": "\(item.conjugationgroup)",
        // Lowercased because this JSON exists to be typed into the answer field by
        // scripts/take_screenshots.sh, and a screenshot depicts what a user typed. The
        // conjugator's capitals are correct output, marking ablaut for the UI to highlight,
        // and 22 of these 30 answers carry them, so pasting them verbatim puts "IST
        // geblIEben" where a human would write "ist geblieben". Nothing about the
        // conjugator or the highlighting should change to accommodate this; only what gets
        // typed. Grading is unaffected: it compares against correctAnswer in memory and
        // never reads this file.
        //
        // Lowercasing here rather than in the shell is deliberate. `tr '[:upper:]'
        // '[:lower:]'` operates on bytes and would leave fÄhrt, lÄUft, and the capital ẞ in
        // wEIẞ untouched; String.lowercased() maps all of them, ẞ to ß included. Safe for
        // the whole fixture today because no answer contains a legitimately capitalized
        // word. Revisit if the plan above ever adds a formal-Sie imperative.
        "answer": item.correctAnswer.lowercased()
      ]
    }
    guard let data = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted),
          let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return
    }
    try? data.write(to: docs.appendingPathComponent("screenshot_fixture_answers.json"))
  }
  #endif

  private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
      MainActor.assumeIsolated {
        guard let self else { return }
        self.elapsedSeconds += 1
        self.updateLiveActivityTime()
      }
    }
  }

  private func updateLiveActivityTime() {
    guard let liveActivity else { return }
    LiveActivityManager.update(liveActivity, state: makeContentState(isFinished: false))
  }

  private func makeContentState(isFinished: Bool) -> QuizActivityAttributes.ContentState {
    QuizActivityAttributes.ContentState(
      currentQuestion: min(currentIndex + 1, questionCount),
      score: score,
      correctCount: correctCount,
      elapsedTime: elapsedTimeLiveActivity,
      isFinished: isFinished
    )
  }

  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  func pauseTimer() {
    guard isInProgress else { return }
    timer?.invalidate()
    timer = nil
  }

  func resumeTimer() {
    guard isInProgress, correction == nil, timer == nil else { return }
    startTimer()
  }

  private func finishQuiz() {
    stopTimer()
    isInProgress = false
    shouldShowResults = true
    if let liveActivity {
      LiveActivityManager.end(liveActivity, finalState: makeContentState(isFinished: true))
      self.liveActivity = nil
    }
    Current.soundPlayer.play(Sound.randomApplause, shouldDebounce: false)
    HapticPlayer.playSuccess()
    Current.analytics.signal(name: .completeQuiz, parameters: [
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.source.rawValue: scope.source.rawValue
    ])
    announceQuizCompletion()
    if questionCount == Quiz.questionCount {
      ChangeLevelTip.quizCompleted.sendDonation()
    }

    if scope.isRanked {
      Task {
        await Current.gameCenter.submitScore(finalScore)
      }
    }
    Current.reviewPrompter.promptableActionHappened()
  }

  private func announceQuestion() {
    guard UIAccessibility.isVoiceOverRunning, let question = currentQuestion else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      Current.utterer.utter(question.verb.infinitiv)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        Current.utterer.utter(question.translation, localeString: UttererLocale.english)
      }
    }
  }

  // A wrong answer is not announced here: QuizView moves VoiceOver to the held correction,
  // which reads the result, both answers, and the letters that differ.
  private func announceAnswerResult(correct: Bool, preferredSpelling: String? = nil) {
    guard UIAccessibility.isVoiceOverRunning else { return }
    let announcement: String
    if let preferredSpelling {
      announcement = L.Quiz.announceCorrectSpelling(MixedCaseAccessibility.accessibilityLabel(for: preferredSpelling))
    } else {
      announcement = L.Quiz.announceCorrect
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      UIAccessibility.post(notification: .announcement, argument: announcement)
    }
  }

  // The answer stays in the field for the learner to edit, and VoiceOver's focus with it.
  private func announceSecondAttempt() {
    guard UIAccessibility.isVoiceOverRunning else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      UIAccessibility.post(notification: .announcement, argument: L.Quiz.almost)
    }
  }

  private func announceQuizCompletion() {
    guard UIAccessibility.isVoiceOverRunning else { return }
    var announcement = "\(L.Quiz.results). \(L.Quiz.score) \(finalScore). \(L.Quiz.correct) \(correctCount) / \(questionCount)."
    if secondAttemptCount > 0 {
      announcement += " \(L.Quiz.secondTry) \(secondAttemptCount)."
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      UIAccessibility.post(notification: .announcement, argument: announcement)
    }
  }

  @MainActor
  deinit {
    timer?.invalidate()
  }
}

/// What a quiz asks about, how many questions it asks, and where it was begun. The quiz track
/// can add scopes, such as Phase 16's collections, as further constructors.
struct QuizScope {
  /// Nil asks about every verb.
  let verbs: [Verb]?

  /// The reading every question asks about. Nil picks one per question.
  let readingIndex: Int?

  let questionCount: Int
  let source: AnalyticsSource

  /// What a quiz in a sheet shows as its title. Nil for the Quiz tab, which is titled Quiz.
  var title: String?

  /// The collection a quiz was started from, which `startQuiz` names (Phase 16).
  var collectionKey: String?

  /// Only a full quiz over every verb posts to the leaderboard, as Josh decided on 2026-11-13:
  /// a score over a learner's own verbs, or over three questions, compares with nothing.
  var isRanked: Bool {
    verbs == nil && questionCount == Quiz.questionCount
  }

  static let verbPageQuestionCount = 3

  static let allVerbs = QuizScope(verbs: nil, readingIndex: nil, questionCount: Quiz.questionCount, source: .tab)

  static func myVerbs(_ verbs: [Verb]) -> QuizScope {
    QuizScope(verbs: verbs, readingIndex: nil, questionCount: Quiz.questionCount, source: .myVerbs)
  }

  static func verbPage(_ verb: Verb, readingIndex: Int) -> QuizScope {
    QuizScope(verbs: [verb], readingIndex: readingIndex, questionCount: verbPageQuestionCount, source: .verbPage, title: verb.infinitiv.inUserRegion)
  }
}

/// A wrong answer held on screen with the right one until the learner continues.
struct QuizCorrection: Equatable {
  let difference: AnswerDifference
  /// What `ErrorExplainerView` would explain, were it enabled.
  let errorContext: ErrorExplainerContext
}

struct QuizItem: Identifiable {
  enum State {
    case correct
    case correctOnSecondAttempt
    case incorrect
    case unanswered
  }

  let id = UUID()
  let verb: Verb
  let conjugationgroup: Conjugationgroup
  /// The single answer shown to the user, in the variety the region setting selects. This is
  /// what reaches results, `QuizErrorHistory`, telemetry, and the VoiceOver readout.
  let correctAnswer: String
  /// Every standard variety's spelling of this conjugation, lowercased. Answers are graded
  /// against this set, so no variety is ever marked wrong.
  let acceptableAnswers: Set<String>
  /// The conjugation in the user's region, in each clause's word order, as the conjugator writes
  /// it. An accepted answer that differs from one of these only in spelling, such as uebernehme,
  /// is shown this spelling beside the checkmark.
  let regionalSpellings: [String]
  /// `acceptableAnswers` with every umlaut also writable as a digraph.
  let acceptedSpellings: Set<String>
  /// Which of the verb's readings this question asks about. The prompt shows this reading's
  /// gloss, so the learner knows whether hängen here means "be suspended" or "suspend
  /// something": the two inflect differently.
  let readingIndex: Int
  /// The final answer: the second attempt, if a slip earned one.
  var userAnswer: String?
  var isCorrect: Bool?
  /// A slip that earned one more attempt, kept for the results.
  var firstAttempt: String?

  var isAwaitingSecondAttempt: Bool {
    firstAttempt != nil && isCorrect == nil
  }

  /// The gloss to show with the prompt. Always the asked reading's, which for a
  /// single-reading verb is exactly the verb's translation as before.
  var translation: String {
    (verb.reading(at: readingIndex) ?? verb.primaryReading).translation
  }

  init(
    verb: Verb,
    conjugationgroup: Conjugationgroup,
    correctAnswer: String,
    acceptableAnswers: Set<String>? = nil,
    regionalSpellings: [String]? = nil,
    readingIndex: Int = 0
  ) {
    self.verb = verb
    self.conjugationgroup = conjugationgroup
    self.correctAnswer = correctAnswer
    self.readingIndex = readingIndex
    // The canonical answer is always acceptable, so a caller that knows of no other variety
    // still grades correctly.
    let acceptableAnswers = acceptableAnswers ?? [correctAnswer.lowercased()]
    self.acceptableAnswers = acceptableAnswers
    self.regionalSpellings = regionalSpellings ?? [correctAnswer]
    acceptedSpellings = acceptableAnswers.reduce(into: []) { spellings, answer in
      spellings.formUnion(AnswerSpelling.digraphSpellings(of: answer))
    }
  }

  /// Whether an answer as typed is right. Case is ignored, and so is spacing, which matters
  /// now that a separable verb's answer has two words: "kommt  an" is still kommt an. A
  /// leading pronoun of the asked person is ignored too, and an umlaut may be written as a
  /// digraph: "ich uebernehme" is übernehme.
  func accepts(_ answer: String) -> Bool {
    acceptedCandidate(of: answer) != nil
  }

  /// The user's region's spelling of an accepted answer that was written differently, such as
  /// übernehme for uebernehme or stoßen Sie um for stossen sie um, for the quiz to show quietly.
  /// Nil for a wrong answer, and for one already spelled as the conjugation is. A spelling of
  /// another region that differs in more than orthography, such as Austria's ist gestanden, is
  /// a right answer in its own right and gets no correction.
  func preferredSpelling(of answer: String) -> String? {
    guard let candidate = acceptedCandidate(of: answer) else {
      return nil
    }
    let key = AnswerSpelling.orthographicKey(candidate)
    let regionalSpelling = regionalSpellings.first { spelling in
      spelling.lowercased() != candidate && AnswerSpelling.orthographicKey(spelling) == key
    }
    // A digraph spelling of a variant, such as stuende for stünde, has no regional spelling
    // with the same letters, so it is shown the variant it spells.
    return regionalSpelling ?? acceptableAnswers.sorted().first { answer in
      answer != candidate && AnswerSpelling.digraphSpellings(of: answer).contains(candidate)
    }
  }

  private func acceptedCandidate(of answer: String) -> String? {
    AnswerSpelling.candidates(for: answer, in: conjugationgroup).first { acceptedSpellings.contains($0) }
  }

  var state: State {
    guard let isCorrect else { return .unanswered }
    guard isCorrect else { return .incorrect }
    return firstAttempt == nil ? .correct : .correctOnSecondAttempt
  }

  var pronoun: String? {
    switch conjugationgroup {
    case .präsenspartizip, .perfektpartizip:
      return nil
    case .präsensIndikativ(let pn), .präsensKonjunktivI(let pn),
         .präteritumIndikativ(let pn), .präteritumKonjunktivII(let pn),
         .perfektIndikativ(let pn), .perfektKonjunktivI(let pn),
         .plusquamperfektIndikativ(let pn), .plusquamperfektKonjunktivII(let pn),
         .futurIndikativ(let pn), .futurKonjunktivI(let pn), .futurKonjunktivII(let pn):
      return pn.pronounWithSieDisambiguation
    case .imperativ(let pn):
      return pn.imperativPronoun
    }
  }

  /// The shape of the answer around the field, built when shown so that it follows the
  /// third-person pronoun setting.
  var answerFrame: AnswerFrame {
    let reading = verb.reading(at: readingIndex) ?? verb.primaryReading
    return AnswerFrame.quizFrame(
      for: conjugationgroup,
      isSeparable: !reading.prefixes.separableRun.isEmpty,
      thirdSingularPronoun: Current.settings.thirdPersonPronounGender.pronoun
    )
  }

  func displayName(lang: ConjugationgroupLang) -> String {
    conjugationgroup.displayName(lang: lang)
  }
}
