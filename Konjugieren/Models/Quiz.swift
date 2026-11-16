// Copyright © 2026 Josh Adams. All rights reserved.

import ActivityKit
import Foundation
import TipKit
import UIKit

@MainActor
@Observable
class Quiz {
  /// The questions of a session's first round, and of each Ten More after it.
  static let questionCount = 10
  static let pointsPerCorrect = 10
  /// A right second attempt, and a right re-ask, earn half.
  static let pointsPerSecondAttempt = pointsPerCorrect / 2
  /// A missed question returns once, after this many others, or before the results if fewer
  /// remain.
  static let reaskGap = 3

  private(set) var isInProgress = false
  var shouldShowResults = false
  private(set) var currentIndex = 0
  private(set) var elapsedSeconds = 0
  /// How many rounds the session has begun: 1 at the start, and one more for each Ten More.
  private(set) var roundCount = 0

  /// The correction of a wrong answer, which holds the quiz on its question, with the clock
  /// stopped, until `continueAfterCorrection()`. A right answer advances at once.
  private(set) var correction: QuizCorrection?
  /// True once a choice question is answered, right or wrong: its reason stays on screen, with the
  /// clock stopped, until `continueAfterCorrection()`, since a choice of two can be a lucky guess
  /// and the reason is the lesson (Josh, 2026-11-15).
  private(set) var isHoldingChoice = false

  /// Whether the quiz waits on its question for Continue.
  var isHeld: Bool {
    correction != nil || isHoldingChoice
  }
  /// The conjugation's own spelling of the last answer, when that answer was right but written
  /// another way, such as with a digraph for an umlaut.
  private(set) var lastPreferredSpelling: String?
  /// A Speed Round's last question when it was missed, whose right answer the next question shows,
  /// since the round does not stop for a correction (Josh, 2026-11-15).
  private(set) var speedRoundMiss: QuizItem?
  /// The best a Speed Round had to beat, read as it finished. Nil when there was none.
  private(set) var speedRoundPreviousBest: Int?
  /// Whether the finished Speed Round set a new personal best.
  private(set) var isNewSpeedRoundBest = false
  /// The streak a finished daily session left, which its results show. Nil for any other quiz.
  private(set) var dailyStreakStatus: DailyStreak.Status?
  /// The best at its level that a ranked session's first round had to beat, read as the round
  /// finished. Nil when there was none, or the session is not ranked (Phase 23).
  private(set) var levelPreviousBest: Int?
  /// Whether a ranked session's first round set a new best at its level.
  private(set) var isNewLevelBest = false
  /// A finished challenge's result, which its results show and share (Phase 24). Nil for any
  /// other quiz.
  private(set) var challengeResult: DailyChallengeResult?

  /// Whether the results show the level's best: a ranked session's first round only, since Ten
  /// More's results show more than the ten questions the best measures.
  var showsLevelBest: Bool {
    isNewLevelBest || levelPreviousBest != nil
  }

  /// The seconds a Speed Round has left.
  var speedRoundSecondsLeft: Int {
    max(SpeedRound.duration - elapsedSeconds, 0)
  }

  private(set) var questions: [QuizItem] = []
  private(set) var scope = QuizScope.allVerbs

  /// The questions the session's rounds have asked, re-asks not included: 10, then 20 after Ten
  /// More, or 3 on a verb's page. A Review of four due items asks four.
  var questionCount: Int {
    questions.filter { !$0.isReask }.count
  }

  var score: Int {
    questions.reduce(0) { $0 + $1.points }
  }

  /// The most `score` could be, were every question and re-ask right on the first attempt.
  var maximumScore: Int {
    questions.reduce(0) { $0 + $1.maximumPoints }
  }

  /// The score of the first round's questions, re-asks not counted, which is what a ranked
  /// session posts (Phase 8 of the pedagogy plan).
  var firstRoundScore: Int {
    questions.filter { !$0.isReask }.prefix(scope.questionCount).reduce(0) { $0 + $1.points }
  }

  /// Right on the first attempt, re-asks not included. A right second attempt is counted apart,
  /// in `secondAttemptCount`.
  var correctCount: Int {
    questions.filter { !$0.isReask && $0.state == .correct }.count
  }

  var secondAttemptCount: Int {
    questions.filter { !$0.isReask && $0.state == .correctOnSecondAttempt }.count
  }

  var reaskCount: Int {
    questions.filter(\.isReask).count
  }

  var reaskCorrectCount: Int {
    questions.filter { $0.isReask && $0.isCorrect == true }.count
  }

  /// Whether the results offer Ten More. A verb page's three questions do not continue, and a
  /// Review or My Mistakes session continues only while the record has items it has not asked.
  var canContinue: Bool {
    guard scope.continues else {
      return false
    }
    guard let session = scope.recordSession else {
      return true
    }
    let asked = askedItemKeys
    return session.items(from: Current.practice).contains { $0.isAskable && !asked.contains($0.key) }
  }

  /// The record's items this session has asked, which a record session's Ten More skips.
  private var askedItemKeys: Set<String> {
    Set(questions.filter { $0.choice == nil }.map { PracticeItem.exercised(by: $0.conjugationgroup, of: $0.verb, readingIndex: $0.readingIndex).key })
  }

  private var timer: Timer?
  private(set) var level: QuizLevel = Settings.quizLevelDefault
  private let timerInterval: TimeInterval
  private var randomSource: AnyRandomNumberGenerator
  /// The clock a daily session's streak is recorded by, which tests set to other days.
  private let now: () -> Date
  private var liveActivity: Activity<QuizActivityAttributes>?
  private var startDate = Date()
  /// Names this quiz's entry in `QuizAbandonment`, since a quiz in a sheet can run beside the
  /// Quiz tab's.
  private let abandonmentID = UUID().uuidString

  var currentQuestion: QuizItem? {
    guard isInProgress, currentIndex < questions.count else { return nil }
    return questions[currentIndex]
  }

  /// True after a slip, while the question waits for its one more attempt.
  var isAwaitingSecondAttempt: Bool {
    currentQuestion?.isAwaitingSecondAttempt ?? false
  }

  var progressText: String {
    "\(currentIndex + 1) / \(questions.count)"
  }

  var elapsedText: String {
    TimeFormatter.formatIntTime(elapsedSeconds)
  }

  /// Nil while the quiz clock is hidden, so that the Live Activity shows no time either.
  var elapsedTimeLiveActivity: String? {
    guard Current.settings.quizClock == .show else {
      return nil
    }
    return TimeFormatter.formatMinutesSeconds(elapsedSeconds)
  }

  // Every level scores alike, since each has its own leaderboard and no score compares across
  // levels.
  var finalScore: Int {
    score
  }

  init(timerInterval: TimeInterval = 1.0, randomSource: any RandomNumberGenerator = SystemRandomNumberGenerator(), now: @escaping () -> Date = Date.init) {
    self.timerInterval = timerInterval
    self.randomSource = AnyRandomNumberGenerator(randomSource)
    self.now = now
  }

  func start(scope: QuizScope = .allVerbs) {
    self.scope = scope
    level = scope.level ?? Current.settings.quizLevel
    questions = generateQuestions(excluding: [])
    guard !questions.isEmpty else {
      return
    }
    resetProgressState()
    roundCount = 1
    startDate = Date()
    isInProgress = true
    shouldShowResults = false
    startTimer()
    startLiveActivity()
    recordProgress()
    Current.soundPlayer.play(Sound.randomGun)
    HapticPlayer.playMediumImpact()
    var parameters = [
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.source.rawValue: scope.source.rawValue
    ]
    if let collectionKey = scope.collectionKey {
      parameters[ParameterKey.collection.rawValue] = collectionKey
    }
    if let custom = scope.custom {
      parameters[ParameterKey.customChoice.rawValue] = custom.choiceParameter
    }
    Current.analytics.signal(name: .startQuiz, parameters: parameters)
    announceQuestion()
  }

  /// Ten More: another round in the same session, offered by the results. The score, the clock,
  /// and the questions so far carry on, and the new questions are a fresh draw, so that every
  /// round has the default quiz's mix of verbs.
  func continueSession() {
    guard shouldShowResults, !isInProgress, canContinue else { return }
    let more = generateQuestions(excluding: askedItemKeys.union(questions.compactMap(\.sentence?.id)).union(questions.compactMap(\.choice?.question.id)))
    guard !more.isEmpty else {
      return
    }
    questions += more
    roundCount += 1
    levelPreviousBest = nil
    isNewLevelBest = false
    correction = nil
    isHoldingChoice = false
    lastPreferredSpelling = nil
    isInProgress = true
    shouldShowResults = false
    startTimer()
    startLiveActivity()
    recordProgress()
    Current.soundPlayer.play(Sound.randomGun)
    HapticPlayer.playMediumImpact()
    announceQuestion()
  }

  // A three-question quiz on a verb's page is over before a Live Activity would be noticed.
  private func startLiveActivity() {
    guard scope.continues || scope.isDaily else {
      return
    }
    liveActivity = LiveActivityManager.start(
      attributes: QuizActivityAttributes(level: level.localizedName),
      initialState: makeContentState(isFinished: false)
    )
  }

  func submitAnswer(_ answer: String) {
    guard isInProgress, !isHeld, currentIndex < questions.count else { return }
    if scope.isSpeedRound {
      submitSpeedRoundAnswer(answer)
      return
    }

    let isCorrect = questions[currentIndex].accepts(answer)
    let isSecondAttempt = questions[currentIndex].isAwaitingSecondAttempt

    // A question gets one more attempt at most, whether a diagnosis or a slip earned it, so a
    // second wrong answer goes to the correction. A diagnosis comes first, since naming the
    // error says more than "almost": fahrst is a slip, and also fahren conjugated as weak.
    if !isCorrect, !isSecondAttempt {
      let diagnosis = questions[currentIndex].diagnosis(of: answer)
      if diagnosis != nil || questions[currentIndex].isSlip(answer) {
        questions[currentIndex].firstAttempt = answer
        questions[currentIndex].firstAttemptDiagnosis = diagnosis
        awaitSecondAttempt(prompt: questions[currentIndex].secondAttemptPrompt)
        return
      }
    }

    questions[currentIndex].userAnswer = answer
    questions[currentIndex].isCorrect = isCorrect
    recordPractice(of: questions[currentIndex], isCorrect: isCorrect)

    if isCorrect {
      acceptAnswer(preferredSpelling: questions[currentIndex].preferredSpelling(of: answer))
    } else {
      let question = questions[currentIndex]
      holdCorrection { willBeReasked in
        QuizCorrection(
          willBeReasked: willBeReasked,
          difference: question.difference(from: answer),
          diagnosis: question.diagnosis(of: answer),
          errorContext: question.errorContext(userAnswer: answer)
        )
      }
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
    }
  }

  /// A Name the Conjugation answer (Phase 17 of the pedagogy plan). An answer with any part right
  /// earns one more try at half points, its line saying which parts to check; otherwise it goes to
  /// the correction, which lists every right answer. Recognizing fuhr is not evidence of producing
  /// it, so the answer moves neither the practice record nor `QuizErrorHistory`, whose misses the
  /// Tutor reads as production errors (Josh, 2026-11-15).
  func submitRecognition(_ answer: RecognitionAnswer) {
    guard isInProgress, !isHeld, currentIndex < questions.count, let recognition = questions[currentIndex].recognition else { return }
    let grade = recognition.grade(answer)
    let summary = answer.summary(lang: Current.settings.conjugationgroupLang)

    if grade.earnsSecondAttempt, !questions[currentIndex].isAwaitingSecondAttempt {
      questions[currentIndex].firstAttempt = summary
      questions[currentIndex].firstAttemptRecognition = grade
      awaitSecondAttempt(prompt: questions[currentIndex].secondAttemptPrompt)
      return
    }

    questions[currentIndex].userAnswer = summary
    questions[currentIndex].isCorrect = grade.isCorrect
    if grade.isCorrect {
      acceptAnswer(preferredSpelling: recognition.preferredSpelling(of: answer.infinitiv))
    } else {
      let question = questions[currentIndex]
      holdCorrection { willBeReasked in
        QuizCorrection(
          willBeReasked: willBeReasked,
          difference: AnswerDifference.between(given: AnswerSpelling.normalized(answer.infinitiv), expected: recognition.nearestInfinitive(to: answer.infinitiv)),
          diagnosis: nil,
          errorContext: question.errorContext(userAnswer: summary),
          recognitionAnswer: answer,
          recognitionGrade: grade
        )
      }
    }
  }

  /// A choice question's answer (Phase 19 of the pedagogy plan), which holds the card with its
  /// reason whether right or wrong. A choice of two is not given a second attempt or a re-ask,
  /// since the learner would then know the answer. Choosing a sentence is not evidence of
  /// producing its conjugation, so the choice moves neither the practice record nor
  /// `QuizErrorHistory`, as with Name the Conjugation.
  func submitChoice(_ index: Int) {
    guard isInProgress, !isHeld, currentIndex < questions.count, let choice = questions[currentIndex].choice, choice.options.indices.contains(index) else { return }
    let isCorrect = index == choice.rightIndex
    questions[currentIndex].chosenOption = index
    questions[currentIndex].userAnswer = choice.options[index].answer
    questions[currentIndex].isCorrect = isCorrect
    lastPreferredSpelling = nil
    stopTimer()
    isHoldingChoice = true
    if isCorrect {
      Current.soundPlayer.play(.chime)
      HapticPlayer.playSuccess()
    } else {
      Current.soundPlayer.play(.buzz)
      HapticPlayer.playError()
    }
    announceChoice(choice, isCorrect: isCorrect)
  }

  /// A Speed Round's answer, which never holds the round: no second attempt, no correction, no
  /// re-ask, and nothing recorded. A miss's right answer rides on the next question.
  private func submitSpeedRoundAnswer(_ answer: String) {
    let isCorrect = questions[currentIndex].accepts(answer)
    questions[currentIndex].userAnswer = answer
    questions[currentIndex].isCorrect = isCorrect
    if isCorrect {
      speedRoundMiss = nil
      acceptAnswer(preferredSpelling: questions[currentIndex].preferredSpelling(of: answer))
    } else {
      let question = questions[currentIndex]
      speedRoundMiss = question
      lastPreferredSpelling = nil
      Current.soundPlayer.play(.buzz)
      HapticPlayer.playError()
      announceSpeedRoundMiss(question)
      advance()
    }
  }

  private func awaitSecondAttempt(prompt: String) {
    lastPreferredSpelling = nil
    Current.soundPlayer.play(.pop)
    HapticPlayer.playImpact(.light)
    announceSecondAttempt(prompt)
  }

  private func acceptAnswer(preferredSpelling: String?) {
    lastPreferredSpelling = preferredSpelling
    Current.soundPlayer.play(.chime)
    HapticPlayer.playSuccess()
    announceAnswerResult(correct: true, preferredSpelling: preferredSpelling)
    advance()
  }

  /// Stops the clock on a wrong final answer, schedules its re-ask, and holds its correction.
  private func holdCorrection(_ makeCorrection: (_ willBeReasked: Bool) -> QuizCorrection) {
    let question = questions[currentIndex]
    lastPreferredSpelling = nil
    stopTimer()
    // A re-ask is not asked a third time, whatever its answer, so that one stubborn question
    // cannot fill a ten-question round (Josh, T3.1). A challenge asks none, so that its results
    // are the five questions its shared text reports.
    if !question.isReask, !scope.isChallenge {
      let placement = Self.reaskPlacement(of: currentIndex, in: questions)
      questions.insert(question.reasked(stepID: placement.stepID), at: placement.position)
    }
    correction = makeCorrection(!question.isReask && !scope.isChallenge)
    Current.soundPlayer.play(.buzz)
    HapticPlayer.playError()
  }

  /// Each final answer goes into the practice record as it is given, so that a quiz quit after
  /// six questions has still practiced six (T6.4). A slip's right second attempt counts as right,
  /// since one letter was all that stood between the learner and the conjugation.
  private func recordPractice(of question: QuizItem, isCorrect: Bool) {
    Current.practice.recordAnswer(
      verb: question.verb,
      conjugationgroup: question.conjugationgroup,
      readingIndex: question.readingIndex,
      isCorrect: isCorrect
    )
  }

  /// Leaves a held correction for the next question, or for the results after the last.
  func continueAfterCorrection() {
    guard isInProgress, isHeld else { return }
    correction = nil
    isHoldingChoice = false
    advance()
    if isInProgress {
      startTimer()
    }
  }

  private func advance() {
    currentIndex += 1
    // A Speed Round draws its next batch as it reaches the last question of this one.
    if scope.isSpeedRound, currentIndex >= questions.count - 1 {
      questions += generateQuestions(excluding: [])
    }

    if let liveActivity {
      LiveActivityManager.update(liveActivity, state: makeContentState(isFinished: false))
    }

    if currentIndex >= questions.count {
      if scope.isSpeedRound {
        finishSpeedRound()
      } else {
        finishQuiz()
      }
    } else {
      recordProgress()
      announceQuestion()
    }
  }

  func quit() {
    let questionNumber = currentIndex + 1
    let duration = Date().timeIntervalSince(startDate)
    stopTimer()
    QuizAbandonment.clear(id: abandonmentID, getterSetter: Current.getterSetter)
    isInProgress = false
    if let liveActivity {
      LiveActivityManager.end(liveActivity, finalState: makeContentState(isFinished: false))
      self.liveActivity = nil
    }
    resetProgressState()
    questions = []
    Current.soundPlayer.play(Sound.randomSadTrombone)
    var parameters = [
      ParameterKey.duration.rawValue: AnalyticsBand.quizDuration(duration),
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.source.rawValue: scope.source.rawValue
    ]
    if scope.sendsQuestionCounts {
      parameters[ParameterKey.questionNumber.rawValue] = "\(questionNumber)"
    }
    Current.analytics.signal(name: .quitQuiz, parameters: parameters)
    // The answers given before quitting are in the record already.
    Current.reportAchievements()
  }

  /// Where the quiz has reached, for the next launch to report should the app be left during it
  /// (M2).
  private func recordProgress() {
    QuizAbandonment.record(
      QuizAbandonment.Entry(level: level.rawValue, source: scope.source.rawValue, questionNumber: scope.sendsQuestionCounts ? currentIndex + 1 : nil),
      id: abandonmentID,
      getterSetter: Current.getterSetter
    )
  }

  private func resetProgressState() {
    currentIndex = 0
    roundCount = 0
    elapsedSeconds = 0
    correction = nil
    isHoldingChoice = false
    lastPreferredSpelling = nil
    speedRoundMiss = nil
    speedRoundPreviousBest = nil
    isNewSpeedRoundBest = false
    dailyStreakStatus = nil
    levelPreviousBest = nil
    isNewLevelBest = false
    challengeResult = nil
  }

  /// `excluded` names the record's items the session has already asked, which a Review, My
  /// Mistakes, or Verb Essentials round reads.
  private func generateQuestions(excluding excluded: Set<String>) -> [QuizItem] {
    #if DEBUG
    switch UserDefaults.standard.string(forKey: "KONJUGIEREN_QUIZ_FIXTURE") {
    case "screenshot":
      let items = Array(generateScreenshotFixture().prefix(scope.questionCount))
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
    case "diagnoses":
      return generateDiagnosesFixture()
    case "essentials" where scope.isVerbEssentials && scope.ablautPractice == nil:
      return generateVerbEssentialsFixture()
    case "recognition" where scope.isRecognition:
      return generateRecognitionFixture()
    case "sentences" where scope.isSentences:
      return generateSentencesFixture()
    case "choices" where scope.mixesChoiceQuestions:
      return generateChoicesFixture()
    default:
      break
    }
    #endif

    if let challenge = scope.challenge {
      return DailyChallenge.questions(for: challenge).map { question in
        makeQuizItem(verb: question.verb, conjugationgroup: question.conjugationgroup, readingIndex: question.readingIndex)
      }
    }

    let verbs = scope.verbs ?? Self.defaultVerbs(for: level)
    if scope.isSpeedRound {
      // The batch before ends with the round's current question, which the next must not repeat.
      let previous = isInProgress ? questions.last.map { PracticeItem.exercised(by: $0.conjugationgroup, of: $0.verb, readingIndex: $0.readingIndex) } : nil
      return QuizDraw.speedRoundQuestions(
        for: SpeedRound.masteredItems(in: Current.practice.record),
        pool: level.pool,
        verbs: verbs,
        count: SpeedRound.batchSize,
        after: previous,
        using: &randomSource
      ).map { question in
        makeQuizItem(verb: question.verb, conjugationgroup: question.conjugationgroup, readingIndex: question.readingIndex)
      }
    }
    if let session = scope.ablautPractice {
      return QuizDraw.ablautPracticeSteps(for: session, record: Current.practice.record, excluded: excluded, using: &randomSource)
        .flatMap(makeStep)
    }
    if scope.isVerbEssentials {
      return QuizDraw.verbEssentialsSteps(verbs: verbs, count: QuizScope.verbEssentialsVerbCount, excluded: excluded, using: &randomSource)
        .flatMap(makeStep)
    }
    if let session = scope.recordSession {
      return QuizDraw.sessionQuestions(
        for: session.items(from: Current.practice),
        verbs: verbs,
        excluded: excluded,
        limit: scope.questionCount,
        using: &randomSource
      ).map { question in
        makeQuizItem(verb: question.verb, conjugationgroup: question.conjugationgroup, readingIndex: question.readingIndex)
      }
    }

    if scope.isDaily {
      return QuizDraw.dailyQuestions(for: Current.practice.dueItems(at: now()), pool: level.pool, verbs: verbs, count: scope.questionCount, using: &randomSource)
        .map { question in
          makeQuizItem(verb: question.verb, conjugationgroup: question.conjugationgroup, readingIndex: question.readingIndex)
        }
    }

    if scope.isSentences {
      return QuizDraw.sentences(from: GapSentences.askable(at: level), count: scope.questionCount, excluded: excluded, using: &randomSource)
        .compactMap(makeSentenceItem)
    }

    let pool = scope.pool(level: level)
    if scope.isRecognition {
      // The default quiz's draw from the level's pool and band, so that the prompts are the
      // conjugations the learner is asked to produce at the level.
      let tables = RecognitionQuestion.tables(for: pool)
      return QuizDraw.questions(
        pool: pool,
        verbs: verbs,
        readingIndex: nil,
        count: scope.questionCount,
        distinctCells: false,
        mixesVerbs: true,
        using: &randomSource
      ).map { question in
        makeRecognitionItem(verb: question.verb, conjugationgroup: question.conjugationgroup, readingIndex: question.readingIndex, tables: tables)
      }
    }
    let due = scope.mixesDueItems
      ? QuizDraw.dueQuestions(for: Current.practice.dueItems(), pool: pool, verbs: verbs, using: &randomSource)
      : []
    // One question of each default round asks a choice from Elementary up (Josh, 2026-11-15), so
    // that every ranked round of a level asks the same mix.
    let choice = scope.mixesChoiceQuestions
      ? QuizDraw.choice(from: ChoiceQuestions.askable(at: level), excluded: excluded, using: &randomSource).flatMap(makeChoiceItem)
      : nil
    let drawn = QuizDraw.questions(
      pool: pool,
      verbs: verbs,
      readingIndex: scope.readingIndex,
      count: scope.questionCount - due.count - (choice == nil ? 0 : 1),
      distinctCells: !scope.continues,
      mixesVerbs: scope.mixesVerbs,
      relaxesRestrictions: scope.custom != nil,
      using: &randomSource
    )
    var items = QuizDraw.mixing(due, into: drawn, using: &randomSource).map { question in
      makeQuizItem(verb: question.verb, conjugationgroup: question.conjugationgroup, readingIndex: question.readingIndex)
    }
    if let choice {
      items.insert(choice, at: QuizDraw.choicePosition(in: items.count, using: &randomSource))
    }
    return items
  }

  /// The verbs of the level's band. Sorted so that a seeded random source draws the same quiz in
  /// every process, since a dictionary's order changes from launch to launch.
  static func defaultVerbs(for level: QuizLevel) -> [Verb] {
    let verbs = level.band.map { Verb.verbs(in: $0) } ?? Array(Verb.verbs.values)
    return verbs.sorted { $0.infinitiv < $1.infinitiv }
  }

  /// Questions shown together, sharing one step.
  private func makeStep(_ step: [QuizDrawnQuestion]) -> [QuizItem] {
    let stepID = UUID()
    return step.map { question in
      makeQuizItem(verb: question.verb, conjugationgroup: question.conjugationgroup, readingIndex: question.readingIndex, stepID: stepID)
    }
  }

  /// - Parameter clauses: The word orders a right answer may take. A sentence's blanks take its
  ///   own clause's alone.
  func makeQuizItem(
    verb: Verb,
    conjugationgroup: Conjugationgroup,
    readingIndex: Int? = nil,
    stepID: UUID? = nil,
    clauses: [Clause] = Clause.allCases,
    sentence: GapSentence? = nil,
    choice: ChoicePrompt? = nil
  ) -> QuizItem {
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
      clauses.flatMap { clause in
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
    let regionalSpellings = clauses.map { clause in
      RegionalConjugator.conjugateUnsafely(
        infinitiv: verb.infinitiv,
        conjugationgroup: conjugationgroup,
        readingIndex: readingIndex,
        clause: clause
      )
    }
    // A sentence after weil shows anfängt, not fängt an, as the answer it wanted.
    let correctAnswer = RegionalConjugator.conjugateUnsafely(
      infinitiv: verb.infinitiv,
      conjugationgroup: conjugationgroup,
      readingIndex: readingIndex,
      clause: clauses.first ?? .main
    )
    return QuizItem(
      verb: verb,
      conjugationgroup: conjugationgroup,
      correctAnswer: correctAnswer,
      acceptableAnswers: acceptableAnswers,
      regionalSpellings: regionalSpellings,
      readingIndex: readingIndex,
      stepID: stepID,
      sentence: sentence,
      choice: choice
    )
  }

  /// A choice question: the item's verb and the right sentence's cell, whose conjugation, in that
  /// sentence's word order, the results show as the answer. Nil for an item this version cannot
  /// read.
  func makeChoiceItem(_ choice: ChoicePrompt) -> QuizItem? {
    let right = choice.question.rightSentence
    guard let verb = Verb.verbs[right.verb], verb.reading(at: right.readingIndex) != nil, let conjugationgroup = right.conjugationgroup, choice.question.otherSentence.conjugationgroup != nil else {
      return nil
    }
    return makeQuizItem(verb: verb, conjugationgroup: conjugationgroup, readingIndex: right.readingIndex, clauses: [right.clause], choice: choice)
  }

  /// A Sentences question (Phase 18 of the pedagogy plan): the sentence's verb and cell, graded in
  /// the sentence's own word order. Nil for a sentence whose verb or cell this version cannot read.
  func makeSentenceItem(_ sentence: GapSentence) -> QuizItem? {
    guard let verb = Verb.verbs[sentence.verb], verb.reading(at: sentence.readingIndex) != nil, let conjugationgroup = sentence.conjugationgroup else {
      return nil
    }
    return makeQuizItem(verb: verb, conjugationgroup: conjugationgroup, readingIndex: sentence.readingIndex, clauses: [sentence.clause], sentence: sentence)
  }

  func makeRecognitionItem(verb: Verb, conjugationgroup: Conjugationgroup, readingIndex: Int, tables: [ConjugationTable]) -> QuizItem {
    let recognition = RecognitionQuestion(verb: verb, conjugationgroup: conjugationgroup, readingIndex: readingIndex, tables: tables)
    return QuizItem(
      verb: verb,
      conjugationgroup: conjugationgroup,
      correctAnswer: recognition.prompt,
      readingIndex: readingIndex,
      recognition: recognition
    )
  }

  #if DEBUG
  // Prompts for Name the Conjugation (Phase 17 of the pedagogy plan), each offered every table,
  // several with more than one right answer: käme (ich or er), fuhr (either reading of fahren),
  // kam an (ankommen, not kommen), weiß (wissen's ich or er, or weißen's du Imperativ), machte
  // (the Präteritum or the Konjunktiv II), ist gegangen, gesungen (no person), kommen (the
  // Präsens or the Konjunktiv I, wir or sie), seien Sie, and hättest gehabt. Answers worth
  // trying: komen with the right cell (check the infinitive), kommen · Präteritum Indikativ · ich
  // for käme (check the conjugationgroup), fahren · Präteritum Indikativ · du for fuhr (check
  // the person), kommen · Präteritum Indikativ · ich for kam an (check the infinitive: kam alone
  // is kommen's, but kam an is ankommen's), and gehen · Perfektpartizip for fuhr (nothing right,
  // so the correction at once).
  private func generateRecognitionFixture() -> [QuizItem] {
    let plan: [(infinitiv: String, group: Conjugationgroup)] = [
      ("kommen", .präteritumKonjunktivII(.firstSingular)),
      ("fahren", .präteritumIndikativ(.thirdSingular)),
      ("ankommen", .präteritumIndikativ(.firstSingular)),
      ("wissen", .präsensIndikativ(.firstSingular)),
      ("machen", .präteritumIndikativ(.thirdSingular)),
      ("gehen", .perfektIndikativ(.thirdSingular)),
      ("singen", .perfektpartizip),
      ("kommen", .präsensIndikativ(.firstPlural)),
      ("sein", .imperativ(.thirdPlural)),
      ("haben", .plusquamperfektKonjunktivII(.secondSingular))
    ]
    let tables = RecognitionQuestion.tables(for: QuizLevel.advanced.pool)
    return plan.map { spec in
      guard let verb = Verb.verbs[spec.infinitiv] else {
        preconditionFailure("Quiz fixture references missing verb: \(spec.infinitiv)")
      }
      return makeRecognitionItem(verb: verb, conjugationgroup: spec.group, readingIndex: 0, tables: tables)
    }
  }

  // Sentences for Phase 18 of the pedagogy plan, one per kind of frame, drafts included, with
  // answers worth trying: one blank (kommst), the Perfekt's two (sind / gegangen), a separable
  // verb's two in a main clause (fängt / an) and its one after weil (anfängt, where "fängt an" is
  // wrong), the Sie Imperativ with Sie given (Nehmen), the du Imperativ (Komm), a Präteritum
  // (war), a würde (würde / kommen), and a Konjunktiv I in reported speech (habe).
  private func generateSentencesFixture() -> [QuizItem] {
    let ids = [
      "kommen.praesens.1",
      "gehen.perfekt.1",
      "anfangen.praesens.1",
      "anfangen.praesens.2",
      "nehmen.imperativ.1",
      "kommen.imperativ.1",
      "sein.praeteritum.1",
      "kommen.futur_konjunktiv_ii.1",
      "haben.konjunktiv_i.1",
      "machen.perfekt.1"
    ]
    return ids.map { id in
      guard let sentence = GapSentences.all.first(where: { $0.id == id }), let item = makeSentenceItem(sentence) else {
        preconditionFailure("Quiz fixture references missing sentence: \(id)")
      }
      return item
    }
  }

  // A default round of choice questions for Phase 19 of the pedagogy plan, one per reason and
  // drafts included, the right sentence first and second by turns, at whatever level is set.
  private func generateChoicesFixture() -> [QuizItem] {
    let ids = [
      "machen.perfekt.1",
      "sein.praeteritum.1",
      "rufen.erzaehlung.1",
      "kaufen.wuerde.1",
      "können.konjunktiv_ii.1",
      "fahren.zukunft.1",
      "regnen.futur.1",
      "sein.konjunktiv_i.1",
      "kommen.indikativ.1",
      "sein.futur.1"
    ]
    return ids.enumerated().map { index, id in
      guard let question = ChoiceQuestions.all.first(where: { $0.id == id }), let item = makeChoiceItem(ChoicePrompt(question: question, rightIndex: index % 2)) else {
        preconditionFailure("Quiz fixture references missing choice: \(id)")
      }
      return item
    }
  }

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
  // sandte, and erkennt an.
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

  // One question per diagnosis from Phase 14 of the pedagogy plan, with the wrong answer that
  // shows it: hängte (hängen's other reading), aufsteh (the prefix at the end), gestanden auf
  // (the participle is one word), gegangen (the auxiliary missing), hat gegangen (the wrong
  // auxiliary), macht (no ge-), geverstanden (ge- on an inseparable verb), gestudiert (on an
  // -ieren verb), geaufstanden (ge- before the prefix), gehte (strong made weak), denkte (mixed
  // made weak), kommt (another person), and ging (another conjugationgroup). Each prompts one
  // more try; a second wrong answer shows the correction with the line again.
  private func generateDiagnosesFixture() -> [QuizItem] {
    let plan: [(infinitiv: String, group: Conjugationgroup, readingIndex: Int)] = [
      ("hängen", .präteritumIndikativ(.firstSingular), 0),
      ("aufstehen", .imperativ(.secondSingular), 0),
      ("aufstehen", .perfektpartizip, 0),
      ("gehen", .perfektIndikativ(.firstSingular), 0),
      ("gehen", .perfektIndikativ(.thirdSingular), 0),
      ("machen", .perfektpartizip, 0),
      ("verstehen", .perfektpartizip, 0),
      ("studieren", .perfektpartizip, 0),
      ("aufstehen", .perfektpartizip, 0),
      ("gehen", .präteritumIndikativ(.firstSingular), 0),
      ("denken", .präteritumIndikativ(.firstSingular), 0),
      ("kommen", .präsensIndikativ(.secondSingular), 0),
      ("gehen", .perfektIndikativ(.firstSingular), 0)
    ]
    return plan.map { spec in
      guard let verb = Verb.verbs[spec.infinitiv] else {
        preconditionFailure("Quiz fixture references missing verb: \(spec.infinitiv)")
      }
      return makeQuizItem(verb: verb, conjugationgroup: spec.group, readingIndex: spec.readingIndex)
    }
  }

  // Five verbs for Verb Essentials, one of each kind the phase names (Phase 15 of the pedagogy
  // plan): fahren as travel (an umlaut and sein: fährt, fuhr, ist gefahren), aufstehen (separable: steht
  // auf, stand auf, ist aufgestanden), verstehen (inseparable: versteht, verstand, hat
  // verstanden), denken (mixed: denkt, dachte, hat gedacht), and gehen (sein: geht, ging, ist
  // gegangen). Wrong answers worth typing: fahrt, standete auf, hat verstehen, denkte, and hat
  // gegangen.
  private func generateVerbEssentialsFixture() -> [QuizItem] {
    let plan: [(infinitiv: String, readingIndex: Int)] = [("fahren", 1), ("aufstehen", 0), ("verstehen", 0), ("denken", 0), ("gehen", 0)]
    return plan.flatMap { spec in
      guard let verb = Verb.verbs[spec.infinitiv] else {
        preconditionFailure("Quiz fixture references missing verb: \(spec.infinitiv)")
      }
      return makeStep(QuizDraw.verbEssentialsStep(verb: verb, readingIndex: spec.readingIndex))
    }
  }

  // Repeated to a round's length, so that the progress dots and the finish behave as usual.
  // Each repeat is a new item, since the dots tell items apart by id.
  private func repeatedFixture(_ plan: [(infinitiv: String, group: Conjugationgroup)]) -> [QuizItem] {
    (0..<scope.questionCount).map { index in
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
        self?.clockTicked()
      }
    }
  }

  /// One second of the clock. A Speed Round ends when its minute is up. Called by the timer, and
  /// by tests, which do not wait sixty seconds.
  func clockTicked() {
    guard isInProgress else {
      return
    }
    elapsedSeconds += 1
    updateLiveActivityTime()
    guard scope.isSpeedRound else {
      return
    }
    if speedRoundSecondsLeft == SpeedRound.warningSecondsLeft {
      announceSpeedRoundWarning()
    }
    if speedRoundSecondsLeft == 0 {
      finishSpeedRound()
    }
  }

  /// Time is up. The question on screen, unanswered, and the rest of the batch are dropped, so the
  /// results list what was answered, and the right answers are measured against the best.
  private func finishSpeedRound() {
    questions = Array(questions.prefix(currentIndex))
    speedRoundMiss = nil
    speedRoundPreviousBest = Current.practice.speedRoundBest
    isNewSpeedRoundBest = Current.practice.recordSpeedRound(correctCount)
    finishQuiz()
  }

  private func updateLiveActivityTime() {
    guard let liveActivity, Current.settings.quizClock == .show else { return }
    LiveActivityManager.update(liveActivity, state: makeContentState(isFinished: false))
  }

  private func makeContentState(isFinished: Bool) -> QuizActivityAttributes.ContentState {
    QuizActivityAttributes.ContentState(
      currentQuestion: min(currentIndex + 1, questions.count),
      totalQuestions: questions.count,
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
    guard isInProgress, !isHeld, timer == nil else { return }
    startTimer()
  }

  private func finishQuiz() {
    stopTimer()
    QuizAbandonment.clear(id: abandonmentID, getterSetter: Current.getterSetter)
    isInProgress = false
    shouldShowResults = true
    if let liveActivity {
      LiveActivityManager.end(liveActivity, finalState: makeContentState(isFinished: true))
      self.liveActivity = nil
    }
    Current.soundPlayer.play(Sound.randomApplause, shouldDebounce: false)
    HapticPlayer.playSuccess()
    var parameters = [
      ParameterKey.level.rawValue: level.rawValue,
      ParameterKey.source.rawValue: scope.source.rawValue
    ]
    if scope.sendsQuestionCounts {
      parameters[ParameterKey.questionCount.rawValue] = "\(questionCount)"
    }
    if scope.isDaily {
      let status = Current.practice.recordDailySession(at: now())
      dailyStreakStatus = status
      parameters[ParameterKey.streak.rawValue] = AnalyticsBand.streak(status.length)
      Current.rescheduleReminders(now: now())
    }
    Current.analytics.signal(name: .completeQuiz, parameters: parameters)
    if let challenge = scope.challenge {
      challengeResult = Current.practice.recordChallenge(DailyChallengeResult(key: challenge, questions: questions))
    }
    Current.practice.recordResult(LastQuizResult(quiz: self))
    let isFirstRound = roundCount == 1
    if isFirstRound, scope.isRanked {
      levelPreviousBest = Current.practice.levelBest(at: level)
      isNewLevelBest = Current.practice.recordRankedScore(firstRoundScore, level: level)
    }
    announceQuizCompletion()
    // The tip suggests another level, which a session drawn from the record does not ask by, and
    // whose pool Verb Essentials does not ask, an ablaut group's included.
    if isFirstRound, scope.continues, scope.recordSession == nil, !scope.isVerbEssentials {
      ChangeLevelTip.quizCompleted.sendDonation()
    }

    // Only the first round ranks, and without its re-asks, so that every ranked score has the
    // same ceiling, 100, on its level's leaderboard (Josh, 2026-11-13). Ten More's points are the
    // learner's alone.
    if isFirstRound, scope.isRanked {
      Current.gameCenter.submitScore(firstRoundScore, level: level)
    }
    Current.reportAchievements()
    Current.reviewPrompter.promptableActionHappened()
  }

  /// A step's later questions are not announced, since the verb is already on screen, and VoiceOver
  /// moves to the next blank, whose label names what it asks. A recognition question speaks its
  /// prompt alone, since the verb and its gloss are what it asks for.
  private func announceQuestion() {
    guard UIAccessibility.isVoiceOverRunning, let question = currentQuestion, currentStepRange.lowerBound == currentIndex else { return }
    var delay = 1.0
    if question.isReask {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        UIAccessibility.post(notification: .announcement, argument: L.Quiz.askedAgain)
      }
      delay += 1.0
    }
    if let recognition = question.recognition {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        Current.utterer.utter(recognition.prompt.lowercased())
      }
      return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
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
  private func announceSecondAttempt(_ prompt: String) {
    guard UIAccessibility.isVoiceOverRunning else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      UIAccessibility.post(notification: .announcement, argument: prompt)
    }
  }

  /// "Correct. In conversation, most verbs take the Perfekt Indikativ." A wrong choice reads the
  /// right sentence before the reason.
  private func announceChoice(_ choice: ChoicePrompt, isCorrect: Bool) {
    guard UIAccessibility.isVoiceOverRunning else { return }
    let reason = choice.question.reasonLine(lang: Current.settings.conjugationgroupLang)
    let announcement = isCorrect
      ? L.Choice.announceRight(reason)
      : L.Choice.announceWrong(right: choice.question.rightSentence.completed.inUserRegion, reason: reason)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      UIAccessibility.post(notification: .announcement, argument: announcement)
    }
  }

  private func announceSpeedRoundMiss(_ question: QuizItem) {
    guard UIAccessibility.isVoiceOverRunning else { return }
    let answer = [question.pronoun, MixedCaseAccessibility.accessibilityLabel(for: question.correctAnswer)].compactMap { $0 }.joined(separator: " ")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      UIAccessibility.post(notification: .announcement, argument: L.SpeedRound.missed(answer))
    }
  }

  private func announceSpeedRoundWarning() {
    guard UIAccessibility.isVoiceOverRunning else { return }
    UIAccessibility.post(notification: .announcement, argument: L.SpeedRound.announceWarning)
  }

  private func announceQuizCompletion() {
    guard UIAccessibility.isVoiceOverRunning else { return }
    if scope.isSpeedRound {
      var announcement = L.SpeedRound.announceTimeUp(correctCount)
      if isNewSpeedRoundBest {
        announcement += " " + L.SpeedRound.newBest
      } else if let speedRoundPreviousBest {
        announcement += " " + L.SpeedRound.best(speedRoundPreviousBest)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        UIAccessibility.post(notification: .announcement, argument: announcement)
      }
      return
    }
    var announcement = "\(L.Quiz.results). \(L.Quiz.score) \(finalScore). \(L.Quiz.correct) \(correctCount) / \(questionCount)."
    if secondAttemptCount > 0 {
      announcement += " \(L.Quiz.secondTry) \(secondAttemptCount)."
    }
    if reaskCount > 0 {
      announcement += " \(L.Quiz.askedAgainLabel) \(reaskCorrectCount) / \(reaskCount)."
    }
    if isNewLevelBest {
      announcement += " " + L.PersonalBest.newBest
    } else if let levelPreviousBest {
      announcement += " " + L.PersonalBest.best(levelPreviousBest)
    }
    if let line = dailyStreakStatus?.resultsLine, !line.isEmpty {
      announcement += " \(line)"
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
  /// Nil asks about the level's band of verbs.
  let verbs: [Verb]?

  /// The reading every question asks about. Nil picks one per question.
  let readingIndex: Int?

  let questionCount: Int
  let source: AnalyticsSource

  /// What a quiz in a sheet shows as its title. Nil for the Quiz tab, which is titled Quiz.
  var title: String?

  /// The collection a quiz was started from, which `startQuiz` names (Phase 16).
  var collectionKey: String?

  /// The learner's own choice of conjugationgroups and verbs, from the Quiz tab, or a practice
  /// set's.
  var custom: CustomQuiz?

  /// A practice set's level, so that every learner who opens it is asked the same set (Phase 10).
  /// Nil asks at the learner's own level.
  var level: QuizLevel?

  /// Review or My Mistakes, which draw from the practice record (Phase 12). Nil for every other
  /// quiz.
  var recordSession: QuizRecordSession?

  /// Verb Essentials, which asks each verb's three key conjugations together (Phase 15).
  var isVerbEssentials = false

  /// Verb Essentials over an ablaut group, alone or mixed with the known groups (Phase 16).
  var ablautPractice: AblautPracticeSession?

  /// Name the Conjugation, which shows a conjugation and asks which verb and cell it is (Phase 17).
  var isRecognition = false

  /// Sentences, which asks a conjugation in a short sentence (Phase 18).
  var isSentences = false

  /// The Speed Round, sixty seconds on mastered items (Phase 21).
  var isSpeedRound = false

  /// The daily session, whose results extend the streak (Phase 22).
  var isDaily = false

  /// A day's challenge, the same five questions on every device (Phase 24).
  var challenge: DailyChallenge.Key?

  var isChallenge: Bool {
    challenge != nil
  }

  /// Only a default quiz posts, to the leaderboard of its level, as Josh decided on 2026-11-13: a
  /// score over a learner's own verbs or conjugationgroups, or over three questions, compares with
  /// nothing. Only its first round posts.
  var isRanked: Bool {
    isDefaultQuiz
  }

  /// Only the default quiz mixes in items the practice record says are due, up to
  /// `QuizDraw.dueItemLimit` a round (Phase 11). A quiz over chosen verbs or conjugationgroups asks
  /// what was chosen.
  var mixesDueItems: Bool {
    isDefaultQuiz
  }

  /// Only the default quiz, and its Ten More, asks a choice question, one a round, at the levels
  /// that have them (Phase 19).
  var mixesChoiceQuestions: Bool {
    isDefaultQuiz
  }

  private var isDefaultQuiz: Bool {
    verbs == nil && custom == nil && recordSession == nil && !isVerbEssentials && !isRecognition && !isSentences && !isSpeedRound && !isDaily && !isChallenge && continues
  }

  /// A Review or My Mistakes session's length is the number of items due or missed, when fewer
  /// than ten, so its signals carry neither the questions asked nor the question reached: either
  /// would tell how many answers were wrong, which Decision 5 of the pedagogy plan forbids. A
  /// mixed ablaut round can be short too, when the known groups hold few verbs, and which groups
  /// are known comes from the learner's answers. A Speed Round's length is how many questions the
  /// learner answered in a minute, which measures the answers themselves.
  var sendsQuestionCounts: Bool {
    recordSession == nil && ablautPractice?.mode != .mixed && !isSpeedRound
  }

  /// A Review, My Mistakes, or ablaut-group session asks the same whatever the level.
  var asksByLevel: Bool {
    recordSession == nil && ablautPractice == nil
  }

  /// A quiz whose verbs the learner did not list is balanced as the default quiz is (Phase 6).
  var mixesVerbs: Bool {
    verbs == nil || custom?.verbSet?.mixesVerbs == true
  }

  func pool(level: QuizLevel) -> [QuizPoolEntry] {
    custom?.pool(level: level) ?? level.pool
  }

  /// Whether the results offer Ten More, or for Verb Essentials five more verbs. Every quiz does but
  /// a verb page's three questions, a Speed Round, whose results offer a new round instead, a
  /// daily session, whose next session is one of its own, and a challenge, taken once.
  var continues: Bool {
    !isSpeedRound && !isDaily && !isChallenge && (isVerbEssentials || questionCount == Quiz.questionCount)
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
  /// False for a re-ask, which does not return again.
  let willBeReasked: Bool
  let difference: AnswerDifference
  /// Why the final answer is wrong, when that is certain (Phase 14 of the pedagogy plan).
  let diagnosis: AnswerDiagnosis?
  /// What `ErrorExplainerView` would explain, were it enabled.
  let errorContext: ErrorExplainerContext
  /// A recognition question's final answer and its grade, which the correction shows part by
  /// part. `difference` then marks the typed infinitive against the nearest right one.
  var recognitionAnswer: RecognitionAnswer?
  var recognitionGrade: RecognitionGrade?
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
  /// A wrong first answer that earned one more attempt, a slip or a diagnosed error, kept for
  /// the results.
  var firstAttempt: String?
  /// Why the first attempt was wrong, when a diagnosis rather than a slip earned the second.
  var firstAttemptDiagnosis: AnswerDiagnosis?
  /// For a recognition question, which parts of the first attempt were wrong.
  var firstAttemptRecognition: RecognitionGrade?
  /// Set for a Name the Conjugation question, whose prompt is `correctAnswer` and whose answer is
  /// a verb and a cell rather than a conjugation (Phase 17 of the pedagogy plan).
  let recognition: RecognitionQuestion?
  /// Set for a Sentences question, whose frame is the sentence (Phase 18).
  let sentence: GapSentence?
  /// Set for a choice question, whose answer is one of two sentences (Phase 19).
  let choice: ChoicePrompt?
  /// Which of a choice question's sentences the learner chose.
  var chosenOption: Int?
  /// A missed question asked once more, a few questions later. It earns half points.
  let isReask: Bool
  /// The questions shown together on one screen, such as a verb's three key conjugations in Verb
  /// Essentials, share a step. Nil for a question shown alone.
  let stepID: UUID?

  var isAwaitingSecondAttempt: Bool {
    firstAttempt != nil && isCorrect == nil
  }

  /// What the quiz says while the question waits for its second attempt: the diagnosis with
  /// "Try once more.", or, after a slip, "Almost! Try once more."
  var secondAttemptPrompt: String {
    if let firstAttemptRecognition {
      return firstAttemptRecognition.line + " " + L.Quiz.tryOnceMore
    }
    guard let firstAttemptDiagnosis else {
      return L.Quiz.almost
    }
    return firstAttemptDiagnosis.line + " " + L.Quiz.tryOnceMore
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
    readingIndex: Int = 0,
    isReask: Bool = false,
    stepID: UUID? = nil,
    recognition: RecognitionQuestion? = nil,
    sentence: GapSentence? = nil,
    choice: ChoicePrompt? = nil
  ) {
    self.isReask = isReask
    self.stepID = stepID
    self.recognition = recognition
    self.sentence = sentence
    self.choice = choice
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

  /// The question asked again, unanswered, as a new item, since the dots tell items apart by id.
  func reasked(stepID: UUID? = nil) -> QuizItem {
    QuizItem(
      verb: verb,
      conjugationgroup: conjugationgroup,
      correctAnswer: correctAnswer,
      acceptableAnswers: acceptableAnswers,
      regionalSpellings: regionalSpellings,
      readingIndex: readingIndex,
      isReask: true,
      stepID: stepID,
      recognition: recognition,
      sentence: sentence,
      choice: choice
    )
  }

  func errorContext(userAnswer: String) -> ErrorExplainerContext {
    ErrorExplainerContext(
      infinitiv: verb.infinitiv,
      translation: translation,
      familyDescription: verb.family.displayName,
      conjugationgroupGerman: conjugationgroup.germanDisplayName,
      conjugationgroupEnglish: conjugationgroup.englishDisplayName,
      userAnswer: userAnswer,
      correctAnswer: correctAnswer
    )
  }

  var maximumPoints: Int {
    isReask ? Quiz.pointsPerSecondAttempt : Quiz.pointsPerCorrect
  }

  /// A right re-ask earns half points, as a right second attempt does, on whichever attempt.
  var points: Int {
    switch state {
    case .correct:
      return maximumPoints
    case .correctOnSecondAttempt:
      return Quiz.pointsPerSecondAttempt
    case .incorrect, .unanswered:
      return 0
    }
  }

  var state: State {
    guard let isCorrect else { return .unanswered }
    guard isCorrect else { return .incorrect }
    return firstAttempt == nil ? .correct : .correctOnSecondAttempt
  }

  var pronoun: String? {
    conjugationgroup.quizPronoun
  }

  /// The shape of the answer around the field, built when shown so that it follows the
  /// third-person pronoun setting.
  var answerFrame: AnswerFrame {
    // A recognition question's one blank takes the infinitive.
    if recognition != nil {
      return AnswerFrame(segments: [.blank])
    }
    if let sentence {
      return sentence.frame
    }
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

extension Conjugationgroup {
  /// The pronoun a question shows beside the cell, as the quiz and the quiz widget ask it. Nil
  /// for a participle.
  var quizPronoun: String? {
    switch self {
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
}
