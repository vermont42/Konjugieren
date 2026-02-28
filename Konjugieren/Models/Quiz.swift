// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import TipKit
import UIKit

@MainActor
@Observable
class Quiz {
  static let questionCount = 30
  static let pointsPerCorrect = 10

  private(set) var isInProgress = false
  var shouldShowResults = false
  private(set) var currentIndex = 0
  private(set) var score = 0
  private(set) var elapsedSeconds = 0
  private(set) var correctCount = 0

  private(set) var lastIncorrectAnswer: String?
  private(set) var lastCorrectAnswer: String?
  private(set) var lastErrorContext: ErrorExplainerContext?

  private(set) var questions: [QuizItem] = []

  private var timer: Timer?
  private var difficultyUsed: QuizDifficulty = .regular
  private var timerInterval: TimeInterval = 1.0

  var currentQuestion: QuizItem? {
    guard isInProgress, currentIndex < questions.count else { return nil }
    return questions[currentIndex]
  }

  var progressText: String {
    "\(currentIndex + 1) / \(Quiz.questionCount)"
  }

  var elapsedText: String {
    TimeFormatter.formatIntTime(elapsedSeconds)
  }

  var finalScore: Int {
    difficultyUsed == .ridiculous ? score * 2 : score
  }

  var difficultyText: String {
    difficultyUsed.localizedQuizDifficulty
  }

  init(timerInterval: TimeInterval = 1.0) {
    self.timerInterval = timerInterval
  }

  func start() {
    difficultyUsed = Current.settings.quizDifficulty
    questions = generateQuestions()
    currentIndex = 0
    score = 0
    correctCount = 0
    elapsedSeconds = 0
    lastIncorrectAnswer = nil
    lastCorrectAnswer = nil
    lastErrorContext = nil
    isInProgress = true
    shouldShowResults = false
    startTimer()
    Current.soundPlayer.play(Sound.randomGun)
    HapticPlayer.playMediumImpact()
    Current.analytics.signal(name: .startQuiz)
    announceQuestion()
  }

  func submitAnswer(_ answer: String) {
    guard isInProgress, currentIndex < questions.count else { return }

    let trimmedAnswer = answer.trimmingCharacters(in: .whitespaces).lowercased()
    let correctAnswer = questions[currentIndex].correctAnswer.lowercased()
    let isCorrect = trimmedAnswer == correctAnswer

    questions[currentIndex].userAnswer = answer
    questions[currentIndex].isCorrect = isCorrect

    if isCorrect {
      score += Quiz.pointsPerCorrect
      correctCount += 1
      lastIncorrectAnswer = nil
      lastCorrectAnswer = nil
      lastErrorContext = nil
      Current.soundPlayer.play(.chime)
      HapticPlayer.playSuccess()
      announceAnswerResult(correct: true)
    } else {
      let question = questions[currentIndex]
      lastIncorrectAnswer = answer
      lastCorrectAnswer = question.correctAnswer
      lastErrorContext = ErrorExplainerContext(
        infinitiv: question.verb.infinitiv,
        translation: question.verb.translation,
        familyDescription: question.verb.family.displayName,
        conjugationgroupGerman: question.conjugationgroup.germanDisplayName,
        conjugationgroupEnglish: question.conjugationgroup.englishDisplayName,
        userAnswer: answer,
        correctAnswer: question.correctAnswer
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
      announceAnswerResult(correct: false, correctAnswer: question.correctAnswer)
    }

    currentIndex += 1

    if currentIndex >= Quiz.questionCount {
      finishQuiz()
    } else {
      announceQuestion()
    }
  }

  func quit() {
    let questionNumber = currentIndex + 1
    stopTimer()
    isInProgress = false
    currentIndex = 0
    score = 0
    correctCount = 0
    elapsedSeconds = 0
    lastIncorrectAnswer = nil
    lastCorrectAnswer = nil
    lastErrorContext = nil
    questions = []
    Current.soundPlayer.play(Sound.randomSadTrombone)
    Current.analytics.signal(name: .quitQuiz, parameters: [
      ParameterKey.difficulty.rawValue: "\(difficultyUsed)",
      ParameterKey.questionNumber.rawValue: "\(questionNumber)"
    ])
  }

  private func generateQuestions() -> [QuizItem] {
    let allVerbs = Array(Verb.verbs.values)
    guard !allVerbs.isEmpty else { return [] }

    var items: [QuizItem] = []

    items.append(makeQuizItem(verb: allVerbs.randomElement() ?? allVerbs[0], conjugationgroup: .präsenspartizip))

    for _ in 0..<2 {
      items.append(makeQuizItem(verb: allVerbs.randomElement() ?? allVerbs[0], conjugationgroup: .perfektpartizip))
    }

    let remainingCount = Quiz.questionCount - 3
    for _ in 0..<remainingCount {
      let verb = allVerbs.randomElement() ?? allVerbs[0]
      let conjugationgroup = randomNonPartizipConjugationgroup()
      items.append(makeQuizItem(verb: verb, conjugationgroup: conjugationgroup))
    }

    items.shuffle()

    return items
  }

  private func makeQuizItem(verb: Verb, conjugationgroup: Conjugationgroup) -> QuizItem {
    let correctAnswer = Conjugator.conjugateUnsafely(
      infinitiv: verb.infinitiv,
      conjugationgroup: conjugationgroup
    )
    return QuizItem(
      verb: verb,
      conjugationgroup: conjugationgroup,
      correctAnswer: correctAnswer
    )
  }

  private func randomNonPartizipConjugationgroup() -> Conjugationgroup {
    var options: [() -> Conjugationgroup] = []

    options.append { .präsensIndicativ(self.randomPersonNumber()) }
    options.append { .perfektIndikativ(self.randomPersonNumber()) }
    options.append { .futurIndikativ(self.randomPersonNumber()) }
    options.append { .imperativ(self.randomImperativPersonNumber()) }

    if difficultyUsed == .ridiculous {
      options.append { .präsensKonjunktivI(self.randomPersonNumber()) }
      options.append { .präteritumIndicativ(self.randomPersonNumber()) }
      options.append { .präteritumKonjunktivII(self.randomPersonNumber()) }
      options.append { .perfektKonjunktivI(self.randomPersonNumber()) }
      options.append { .plusquamperfektIndikativ(self.randomPersonNumber()) }
      options.append { .plusquamperfektKonjunktivII(self.randomPersonNumber()) }
      options.append { .futurKonjunktivI(self.randomPersonNumber()) }
      options.append { .futurKonjunktivII(self.randomPersonNumber()) }
    }

    return options.randomElement()?() ?? .präsensIndicativ(.firstSingular)
  }

  private func randomPersonNumber() -> PersonNumber {
    PersonNumber.allCases.randomElement() ?? .firstSingular
  }

  private func randomImperativPersonNumber() -> PersonNumber {
    PersonNumber.imperativPersonNumbers.randomElement() ?? .secondSingular
  }

  private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
      MainActor.assumeIsolated {
        self?.elapsedSeconds += 1
      }
    }
  }

  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  private func finishQuiz() {
    stopTimer()
    isInProgress = false
    shouldShowResults = true
    Current.soundPlayer.play(Sound.randomApplause, shouldDebounce: false)
    HapticPlayer.playSuccess()
    Current.analytics.signal(name: .completeQuiz, parameters: [
      ParameterKey.difficulty.rawValue: "\(difficultyUsed)"
    ])
    announceQuizCompletion()
    ChangeDifficultyTip.quizCompleted.sendDonation()

    Task {
      await Current.gameCenter.submitScore(finalScore)
    }
  }

  private func announceQuestion() {
    guard UIAccessibility.isVoiceOverRunning, let question = currentQuestion else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      Current.utterer.utter(question.verb.infinitiv)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        Current.utterer.utter(question.verb.translation, localeString: UttererLocale.english)
      }
    }
  }

  private func announceAnswerResult(correct: Bool, correctAnswer: String? = nil) {
    guard UIAccessibility.isVoiceOverRunning else { return }
    let announcement: String
    if correct {
      announcement = "Correct"
    } else if let correctAnswer {
      let label = MixedCaseAccessibility.accessibilityLabel(for: correctAnswer)
      announcement = "Incorrect. \(label)"
    } else {
      announcement = "Incorrect"
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      UIAccessibility.post(notification: .announcement, argument: announcement)
    }
  }

  private func announceQuizCompletion() {
    guard UIAccessibility.isVoiceOverRunning else { return }
    let announcement = "\(L.Quiz.results). \(L.Quiz.score) \(finalScore). \(L.Quiz.correct) \(correctCount) / \(Quiz.questionCount)."
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      UIAccessibility.post(notification: .announcement, argument: announcement)
    }
  }

  @MainActor
  deinit {
    timer?.invalidate()
  }
}

struct QuizItem: Identifiable {
  let id = UUID()
  let verb: Verb
  let conjugationgroup: Conjugationgroup
  let correctAnswer: String
  var userAnswer: String?
  var isCorrect: Bool?

  var pronoun: String? {
    switch conjugationgroup {
    case .präsenspartizip, .perfektpartizip:
      return nil
    case .präsensIndicativ(let pn), .präsensKonjunktivI(let pn),
         .präteritumIndicativ(let pn), .präteritumKonjunktivII(let pn),
         .perfektIndikativ(let pn), .perfektKonjunktivI(let pn),
         .plusquamperfektIndikativ(let pn), .plusquamperfektKonjunktivII(let pn),
         .futurIndikativ(let pn), .futurKonjunktivI(let pn), .futurKonjunktivII(let pn):
      return pn.pronounWithSieDisambiguation
    case .imperativ(let pn):
      switch pn {
      case .secondSingular:
        return "du"
      case .secondPlural:
        return "ihr"
      case .firstPlural:
        return "wir"
      case .thirdPlural:
        return "Sie"
      default:
        return nil
      }
    }
  }

  func displayName(lang: ConjugationgroupLang) -> String {
    switch lang {
    case .german:
      return conjugationgroup.germanDisplayName
    case .english:
      return conjugationgroup.englishDisplayName
    }
  }
}
