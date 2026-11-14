// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite(.serialized)
@MainActor
struct QuizTests {
  init() {
    Current.settings.quizLevel = .elementary
  }

  @Test func initialState() {
    let quiz = Quiz()
    #expect(quiz.isInProgress == false)
    #expect(quiz.shouldShowResults == false)
    #expect(quiz.currentIndex == 0)
    #expect(quiz.score == 0)
    #expect(quiz.elapsedSeconds == 0)
    #expect(quiz.correctCount == 0)
    #expect(quiz.correction == nil)
    #expect(quiz.questions.isEmpty)
    #expect(quiz.currentQuestion == nil)
  }

  @Test func startQuiz() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    #expect(quiz.isInProgress == true)
    #expect(quiz.shouldShowResults == false)
    #expect(quiz.currentIndex == 0)
    #expect(quiz.score == 0)
    #expect(quiz.correctCount == 0)
    #expect(quiz.questions.count == Quiz.questionCount)
    #expect(quiz.currentQuestion != nil)

    quiz.quit()
  }

  @Test func startQuizGeneratesCorrectQuestionCount() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    #expect(quiz.questions.count == 30)

    quiz.quit()
  }

  @Test(arguments: QuizLevel.allCases)
  func startQuizAsksOnlyTheLevelsCells(level: QuizLevel) {
    Current.settings.quizLevel = level
    let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 5))
    quiz.start()

    let cells = Set(level.pool.flatMap(\.cells))
    #expect(quiz.questions.allSatisfy { cells.contains($0.conjugationgroup) })
    #expect(quiz.level == level)

    quiz.quit()
  }

  @Test func theSameSeedDrawsTheSameQuiz() {
    let first = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 42))
    first.start()
    let second = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 42))
    second.start()

    #expect(first.questions.map(\.verb.infinitiv) == second.questions.map(\.verb.infinitiv))
    #expect(first.questions.map(\.conjugationgroup) == second.questions.map(\.conjugationgroup))
    #expect(first.questions.map(\.readingIndex) == second.questions.map(\.readingIndex))

    first.quit()
    second.quit()
  }

  @Test func quitQuiz() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()
    quiz.quit()

    #expect(quiz.isInProgress == false)
    #expect(quiz.currentIndex == 0)
    #expect(quiz.score == 0)
    #expect(quiz.correctCount == 0)
    #expect(quiz.elapsedSeconds == 0)
    #expect(quiz.correction == nil)
    #expect(quiz.questions.isEmpty)
  }

  @Test func submitCorrectAnswer() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    let correctAnswer = quiz.questions[0].correctAnswer
    quiz.submitAnswer(correctAnswer)

    #expect(quiz.score == Quiz.pointsPerCorrect)
    #expect(quiz.correctCount == 1)
    #expect(quiz.currentIndex == 1)
    #expect(quiz.correction == nil)
    #expect(quiz.questions[0].isCorrect == true)
    #expect(quiz.questions[0].userAnswer == correctAnswer)

    quiz.quit()
  }

  @Test func submitIncorrectAnswerHoldsTheQuestion() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    let correctAnswer = quiz.questions[0].correctAnswer
    let wrongAnswer = "definitelywrong"
    quiz.submitAnswer(wrongAnswer)

    #expect(quiz.score == 0)
    #expect(quiz.correctCount == 0)
    #expect(quiz.currentIndex == 0)
    #expect(quiz.currentQuestion?.id == quiz.questions[0].id)
    #expect(quiz.correction?.difference.given == wrongAnswer)
    #expect(quiz.correction?.errorContext.correctAnswer == correctAnswer)
    #expect(quiz.questions[0].isCorrect == false)
    #expect(quiz.questions[0].userAnswer == wrongAnswer)

    quiz.quit()
  }

  @Test func continueLeavesTheHeldQuestion() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()
    quiz.submitAnswer("definitelywrong")
    quiz.continueAfterCorrection()

    #expect(quiz.correction == nil)
    #expect(quiz.currentIndex == 1)
    #expect(quiz.currentQuestion?.id == quiz.questions[1].id)
    #expect(quiz.isInProgress)

    quiz.quit()
  }

  @Test func anAnswerWhileHeldIsIgnored() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()
    quiz.submitAnswer("definitelywrong")
    quiz.submitAnswer(quiz.questions[0].correctAnswer)

    #expect(quiz.currentIndex == 0)
    #expect(quiz.correctCount == 0)
    #expect(quiz.questions[0].isCorrect == false)
    #expect(quiz.questions[0].userAnswer == "definitelywrong")

    quiz.quit()
  }

  @Test func continueWithoutACorrectionDoesNothing() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()
    quiz.continueAfterCorrection()

    #expect(quiz.currentIndex == 0)

    quiz.quit()
  }

  @Test func theClockStopsWhileACorrectionIsHeld() {
    let quiz = Quiz(timerInterval: 0.01)
    quiz.start()
    quiz.submitAnswer("definitelywrong")
    let heldAt = quiz.elapsedSeconds

    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
    #expect(quiz.elapsedSeconds == heldAt)

    // Returning to the foreground must not restart a clock that a correction stopped.
    quiz.resumeTimer()
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
    #expect(quiz.elapsedSeconds == heldAt)

    quiz.continueAfterCorrection()
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
    #expect(quiz.elapsedSeconds > heldAt)

    quiz.quit()
  }

  @Test func aWrongLastAnswerHoldsBeforeTheResults() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .verbPage(Verb.verbs["gehen"]!, readingIndex: 0))
    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    quiz.submitAnswer(quiz.questions[1].correctAnswer)
    quiz.submitAnswer("definitelywrong")

    #expect(quiz.isInProgress)
    #expect(!quiz.shouldShowResults)
    #expect(quiz.correction != nil)

    quiz.continueAfterCorrection()

    #expect(!quiz.isInProgress)
    #expect(quiz.shouldShowResults)
    #expect(quiz.correction == nil)
    #expect(quiz.correctCount == 2)
  }

  @Test func quittingWhileHeldReportsTheHeldQuestion() {
    let spy = Current.analytics as! AnalyticsSpy
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()
    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    quiz.submitAnswer("definitelywrong")
    let initialCount = spy.signalNames.count
    quiz.quit()

    let signals = zip(spy.signalNames, spy.signalParameters).dropFirst(initialCount)
    let parameters = signals.first { $0.0 == .quitQuiz }?.1
    #expect(parameters?[ParameterKey.questionNumber.rawValue] == "2")
    #expect(quiz.correction == nil)
  }

  @Test func submitAnswerCaseInsensitive() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    let correctAnswer = quiz.questions[0].correctAnswer
    let uppercaseAnswer = correctAnswer.uppercased()
    quiz.submitAnswer(uppercaseAnswer)

    #expect(quiz.questions[0].isCorrect == true)
    #expect(quiz.correctCount == 1)

    quiz.quit()
  }

  @Test func submitAnswerTrimsWhitespace() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    let correctAnswer = quiz.questions[0].correctAnswer
    let paddedAnswer = "  \(correctAnswer)  "
    quiz.submitAnswer(paddedAnswer)

    #expect(quiz.questions[0].isCorrect == true)
    #expect(quiz.correctCount == 1)

    quiz.quit()
  }

  // A separable verb's canonical answer is the main-clause one the verb page shows, and the
  // joined one is accepted too, since the prompt gives no sentence to decide between them.
  @Test func separableVerbAcceptsSplitAndJoinedConjugations() {
    let quiz = Quiz(timerInterval: 0.001)
    let verb = Verb.verbs["ankommen"]!
    let item = quiz.makeQuizItem(verb: verb, conjugationgroup: .präsensIndikativ(.thirdSingular), readingIndex: 0)

    #expect(item.correctAnswer == "kommt an")
    #expect(item.accepts("kommt an"))
    #expect(item.accepts("ankommt"))
    #expect(item.accepts("  Kommt   an "))
    #expect(!item.accepts("an kommt"))
    #expect(!item.accepts("kommtan"))
  }

  @Test func compoundConjugationOfSeparableVerbIsUnchanged() {
    let quiz = Quiz(timerInterval: 0.001)
    let verb = Verb.verbs["ankommen"]!
    let item = quiz.makeQuizItem(verb: verb, conjugationgroup: .perfektIndikativ(.firstSingular), readingIndex: 0)

    #expect(item.correctAnswer == "BIN angekommen")
    #expect(item.acceptableAnswers == ["bin angekommen"])
  }

  @Test func submitAnswerWhenNotInProgressDoesNothing() {
    let quiz = Quiz()
    quiz.submitAnswer("anything")

    #expect(quiz.currentIndex == 0)
    #expect(quiz.score == 0)
  }

  @Test func submitAllAnswersFinishesQuiz() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    for i in 0..<Quiz.questionCount {
      let answer = quiz.questions[i].correctAnswer
      quiz.submitAnswer(answer)
    }

    #expect(quiz.isInProgress == false)
    #expect(quiz.shouldShowResults == true)
    #expect(quiz.currentIndex == Quiz.questionCount)
    #expect(quiz.correctCount == Quiz.questionCount)
    #expect(quiz.score == Quiz.questionCount * Quiz.pointsPerCorrect)
  }

  @Test func currentQuestionReturnsCorrectQuestion() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    #expect(quiz.currentQuestion?.id == quiz.questions[0].id)

    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    #expect(quiz.currentQuestion?.id == quiz.questions[1].id)

    quiz.quit()
  }

  @Test func currentQuestionReturnsNilWhenNotInProgress() {
    let quiz = Quiz()
    #expect(quiz.currentQuestion == nil)
  }

  @Test func progressText() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    #expect(quiz.progressText == "1 / 30")

    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    #expect(quiz.progressText == "2 / 30")

    quiz.quit()
  }

  @Test func elapsedTextUsesTimeFormatter() {
    let quiz = Quiz()
    #expect(quiz.elapsedText == "0")

    let quiz2 = Quiz(timerInterval: 0.001)
    quiz2.start()
    #expect(quiz2.elapsedText == "0")

    quiz2.quit()
  }

  @Test(arguments: QuizLevel.allCases)
  func aRightAnswerScoresAlikeAtEveryLevel(level: QuizLevel) {
    let quiz = Quiz(timerInterval: 0.001)
    Current.settings.quizLevel = level
    quiz.start()

    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    #expect(quiz.finalScore == Quiz.pointsPerCorrect)

    quiz.quit()
  }

  @Test func timerIncrementsElapsedSeconds() {
    let quiz = Quiz(timerInterval: 0.01)
    quiz.start()

    #expect(quiz.elapsedSeconds == 0)

    // Pump the run loop to allow the timer to fire.
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

    #expect(quiz.elapsedSeconds > 0)

    quiz.quit()
  }

  @Test func quizItemPronounForParticiples() {
    let verb = Verb.verbs["machen"]!
    let präsensItem = QuizItem(
      verb: verb,
      conjugationgroup: .präsenspartizip,
      correctAnswer: "machend"
    )
    let perfektItem = QuizItem(
      verb: verb,
      conjugationgroup: .perfektpartizip,
      correctAnswer: "gemacht"
    )

    #expect(präsensItem.pronoun == nil)
    #expect(perfektItem.pronoun == nil)
  }

  @Test func quizItemPronounForIndicativ() {
    let verb = Verb.verbs["machen"]!
    let item = QuizItem(
      verb: verb,
      conjugationgroup: .präsensIndikativ(.firstSingular),
      correctAnswer: "mache"
    )

    #expect(item.pronoun == "ich")
  }

  @Test func quizItemPronounForImperativ() {
    let verb = Verb.verbs["machen"]!

    let duItem = QuizItem(
      verb: verb,
      conjugationgroup: .imperativ(.secondSingular),
      correctAnswer: "mach"
    )
    #expect(duItem.pronoun == "du")

    let ihrItem = QuizItem(
      verb: verb,
      conjugationgroup: .imperativ(.secondPlural),
      correctAnswer: "macht"
    )
    #expect(ihrItem.pronoun == "ihr")

    let wirItem = QuizItem(
      verb: verb,
      conjugationgroup: .imperativ(.firstPlural),
      correctAnswer: "machen wir"
    )
    #expect(wirItem.pronoun == "wir")

    let sieItem = QuizItem(
      verb: verb,
      conjugationgroup: .imperativ(.thirdPlural),
      correctAnswer: "machen Sie"
    )
    #expect(sieItem.pronoun == "Sie")
  }

  @Test func quizItemDisplayNameGerman() {
    let verb = Verb.verbs["machen"]!
    let item = QuizItem(
      verb: verb,
      conjugationgroup: .präsensIndikativ(.firstSingular),
      correctAnswer: "mache"
    )

    let germanName = item.displayName(lang: .german)
    #expect(germanName.contains("Präsens") || germanName.contains("Indikativ"))
  }

  @Test func quizItemDisplayNameEnglish() {
    let verb = Verb.verbs["machen"]!
    let item = QuizItem(
      verb: verb,
      conjugationgroup: .präsensIndikativ(.firstSingular),
      correctAnswer: "mache"
    )

    let englishName = item.displayName(lang: .english)
    #expect(englishName.contains("Present") || englishName.contains("Indicative"))
  }

  @Test func startQuizFiresAnalytics() {
    let spy = Current.analytics as! AnalyticsSpy
    let initialCount = spy.signalNames.count
    let quiz = Quiz(timerInterval: 0.001)
    Current.settings.quizLevel = .intermediate
    quiz.start()

    #expect(spy.signalNames.dropFirst(initialCount).contains(.startQuiz))
    let signals = zip(spy.signalNames, spy.signalParameters).dropFirst(initialCount)
    #expect(signals.first { $0.0 == .startQuiz }?.1[ParameterKey.level.rawValue] == "intermediate")

    quiz.quit()
  }

  @Test func quitQuizFiresAnalytics() {
    let spy = Current.analytics as! AnalyticsSpy
    let quiz = Quiz(timerInterval: 0.001)
    Current.settings.quizLevel = .elementary
    quiz.start()

    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    let initialCount = spy.signalNames.count
    quiz.quit()

    let newNames = Array(spy.signalNames.dropFirst(initialCount))
    let newParams = Array(spy.signalParameters.dropFirst(initialCount))
    #expect(newNames.contains(.quitQuiz))

    if let quitIndex = newNames.firstIndex(of: .quitQuiz) {
      let params = newParams[quitIndex]
      #expect(params[ParameterKey.level.rawValue] == "elementary")
      #expect(params[ParameterKey.questionNumber.rawValue] == "2")
    }
  }

  @Test func completeQuizFiresAnalytics() {
    let spy = Current.analytics as! AnalyticsSpy
    let quiz = Quiz(timerInterval: 0.001)
    Current.settings.quizLevel = .advanced
    quiz.start()

    let initialCount = spy.signalNames.count
    for i in 0..<Quiz.questionCount {
      quiz.submitAnswer(quiz.questions[i].correctAnswer)
    }

    let newNames = Array(spy.signalNames.dropFirst(initialCount))
    let newParams = Array(spy.signalParameters.dropFirst(initialCount))
    #expect(newNames.contains(.completeQuiz))

    if let completeIndex = newNames.firstIndex(of: .completeQuiz) {
      let params = newParams[completeIndex]
      #expect(params[ParameterKey.level.rawValue] == "advanced")
    }
  }

  @Test func quizConstants() {
    #expect(Quiz.questionCount == 30)
    #expect(Quiz.pointsPerCorrect == 10)
  }

  @Test func quizItemStateIsUnansweredBeforeSubmit() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    for i in 0..<Quiz.questionCount {
      #expect(quiz.questions[i].state == .unanswered)
    }

    quiz.quit()
  }

  @Test func quizItemStateIsCorrectAfterCorrectAnswer() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    let correctAnswer = quiz.questions[0].correctAnswer
    quiz.submitAnswer(correctAnswer)

    #expect(quiz.questions[0].state == .correct)
    #expect(quiz.questions[1].state == .unanswered)

    quiz.quit()
  }

  @Test func quizItemStateIsIncorrectAfterIncorrectAnswer() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    quiz.submitAnswer("definitelywrong")

    #expect(quiz.questions[0].state == .incorrect)
    #expect(quiz.questions[1].state == .unanswered)

    quiz.quit()
  }

  @Test func quitClearsAllQuestionsAndStates() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()
    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    quiz.submitAnswer("wrong")
    quiz.continueAfterCorrection()
    quiz.quit()

    #expect(quiz.questions.isEmpty)
  }

  @Test func pauseTimerStopsElapsedIncrement() {
    let quiz = Quiz(timerInterval: 0.01)
    quiz.start()
    quiz.pauseTimer()

    // With the timer invalidated, pumping the run loop must not advance elapsedSeconds.
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
    #expect(quiz.elapsedSeconds == 0)

    quiz.quit()
  }

  @Test func resumeTimerRestartsElapsedIncrement() {
    let quiz = Quiz(timerInterval: 0.01)
    quiz.start()
    quiz.pauseTimer()
    quiz.resumeTimer()

    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
    #expect(quiz.elapsedSeconds > 0)

    quiz.quit()
  }

  @Test func pauseTimerWhenNotInProgressDoesNothing() {
    let quiz = Quiz(timerInterval: 0.01)
    quiz.pauseTimer()

    #expect(quiz.isInProgress == false)
    #expect(quiz.elapsedSeconds == 0)
  }

  @Test func resumeTimerWhenNotInProgressDoesNothing() {
    let quiz = Quiz(timerInterval: 0.01)
    quiz.resumeTimer()

    // resumeTimer guards on isInProgress, so no timer starts and the quiz stays idle.
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
    #expect(quiz.isInProgress == false)
    #expect(quiz.elapsedSeconds == 0)
  }

  @Test func resumeTimerWhileRunningDoesNotStartASecondTimer() {
    let quiz = Quiz(timerInterval: 0.01)
    quiz.start()
    // resumeTimer guards on timer == nil, so calling it while the timer is live is a no-op
    // rather than scheduling a second timer that would double the increment rate.
    quiz.resumeTimer()

    #expect(quiz.isInProgress == true)

    quiz.quit()
  }

  @Test func aMyVerbsQuizAsksOnlyAboutItsVerbs() {
    let verbs = ["gehen", "sein", "machen"].map { Verb.verbs[$0]! }
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .myVerbs(verbs))

    #expect(quiz.questions.count == Quiz.questionCount)
    #expect(Set(quiz.questions.map(\.verb.infinitiv)).isSubset(of: ["gehen", "sein", "machen"]))
    #expect(!quiz.scope.isRanked)

    quiz.quit()
  }

  @Test func aVerbPageQuizAsksThreeDifferentQuestionsAboutTheReadingOnScreen() {
    let hängen = Verb.verbs["hängen"]!
    #expect(hängen.readings.count == 2)
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .verbPage(hängen, readingIndex: 1))

    #expect(quiz.questionCount == QuizScope.verbPageQuestionCount)
    #expect(quiz.questions.count == QuizScope.verbPageQuestionCount)
    #expect(quiz.questions.allSatisfy { $0.verb.infinitiv == "hängen" && $0.readingIndex == 1 })
    #expect(Set(quiz.questions.map(\.conjugationgroup)).count == QuizScope.verbPageQuestionCount)
    #expect(quiz.progressText == "1 / 3")
    #expect(!quiz.scope.isRanked)

    quiz.quit()
  }

  @Test func aVerbPageQuizAsksNoParticiple() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .verbPage(Verb.verbs["gehen"]!, readingIndex: 0))

    let participles = quiz.questions.filter { item in
      switch item.conjugationgroup {
      case .präsenspartizip, .perfektpartizip:
        return true
      default:
        return false
      }
    }
    #expect(participles.isEmpty)

    quiz.quit()
  }

  @Test func aVerbPageQuizFinishesAfterThreeAnswers() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .verbPage(Verb.verbs["gehen"]!, readingIndex: 0))
    for index in 0..<QuizScope.verbPageQuestionCount {
      quiz.submitAnswer(quiz.questions[index].correctAnswer)
    }

    #expect(quiz.isInProgress == false)
    #expect(quiz.shouldShowResults == true)
    #expect(quiz.correctCount == 3)
  }

  @Test func aQuizOverNoVerbsDoesNotStart() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .myVerbs([]))

    #expect(quiz.isInProgress == false)
    #expect(quiz.questions.isEmpty)
  }

  @Test func onlyTheFullQuizOverEveryVerbIsRanked() {
    #expect(QuizScope.allVerbs.isRanked)
    #expect(!QuizScope.myVerbs(Array(Verb.verbs.values)).isRanked)
    #expect(!QuizScope.verbPage(Verb.verbs["gehen"]!, readingIndex: 0).isRanked)
  }

  @Test func collectionQuizNamesItsCollection() {
    let spy = Current.analytics as! AnalyticsSpy
    let initialCount = spy.signalNames.count
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .collection(.modals))
    quiz.quit()

    let signals = zip(spy.signalNames, spy.signalParameters).dropFirst(initialCount)
    let parameters = signals.first { $0.0 == .startQuiz }?.1
    #expect(parameters?[ParameterKey.source.rawValue] == "list")
    #expect(parameters?[ParameterKey.collection.rawValue] == "modals")
    #expect(quiz.questions.allSatisfy { VerbCollection.modalInfinitives.contains($0.verb.infinitiv) })
  }

  @Test func onlyACollectionQuizNamesACollection() {
    let spy = Current.analytics as! AnalyticsSpy
    let initialCount = spy.signalNames.count
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: .myVerbs([Verb.verbs["gehen"]!]))
    quiz.quit()

    let signals = zip(spy.signalNames, spy.signalParameters).dropFirst(initialCount)
    let parameters = signals.first { $0.0 == .startQuiz }?.1
    #expect(parameters?[ParameterKey.collection.rawValue] == nil)
  }

  @Test(arguments: ["tab", "myVerbs", "verbPage"])
  func quizSignalsCarryTheSource(sourceName: String) {
    let gehen = Verb.verbs["gehen"]!
    let source = AnalyticsSource(rawValue: sourceName)!
    let scope: QuizScope
    switch source {
    case .myVerbs:
      scope = .myVerbs([gehen])
    case .verbPage:
      scope = .verbPage(gehen, readingIndex: 0)
    default:
      scope = .allVerbs
    }
    let spy = Current.analytics as! AnalyticsSpy
    let initialCount = spy.signalNames.count
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start(scope: scope)
    quiz.quit()
    quiz.start(scope: scope)
    for index in 0..<quiz.questionCount {
      quiz.submitAnswer(quiz.questions[index].correctAnswer)
    }

    let signals = zip(spy.signalNames, spy.signalParameters).dropFirst(initialCount)
    for name in [AnalyticsName.startQuiz, .quitQuiz, .completeQuiz] {
      let parameters = signals.first { $0.0 == name }?.1
      #expect(parameters?[ParameterKey.source.rawValue] == source.rawValue, "\(name)")
    }
  }
}
