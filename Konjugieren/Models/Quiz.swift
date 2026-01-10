// Copyright © 2025 Josh Adams. All rights reserved.

import Foundation

@Observable
class Quiz {
  static let questionCount = 30
  static let pointsPerCorrect = 10

  // MARK: - Public State

  private(set) var isInProgress = false
  var shouldShowResults = false
  private(set) var currentIndex = 0
  private(set) var score = 0
  private(set) var elapsedSeconds = 0
  private(set) var correctCount = 0

  // Wrong answer feedback (shown after incorrect submission)
  private(set) var lastIncorrectAnswer: String?
  private(set) var lastCorrectAnswer: String?

  // MARK: - Quiz Data

  private(set) var questions: [QuizItem] = []

  // MARK: - Private

  private var timer: Timer?
  private var difficultyUsed: QuizDifficulty = .regular

  // MARK: - Computed Properties

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

  // MARK: - Public Methods

  func start() {
    difficultyUsed = Current.settings.quizDifficulty
    questions = generateQuestions()
    currentIndex = 0
    score = 0
    correctCount = 0
    elapsedSeconds = 0
    lastIncorrectAnswer = nil
    lastCorrectAnswer = nil
    isInProgress = true
    shouldShowResults = false
    startTimer()
    SoundPlayer.play(Sound.randomGun)
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
      SoundPlayer.play(.chime)
    } else {
      lastIncorrectAnswer = answer
      lastCorrectAnswer = questions[currentIndex].correctAnswer
      SoundPlayer.play(.buzz)
    }

    currentIndex += 1

    if currentIndex >= Quiz.questionCount {
      finishQuiz()
    }
  }

  func quit() {
    stopTimer()
    isInProgress = false
    currentIndex = 0
    score = 0
    correctCount = 0
    elapsedSeconds = 0
    lastIncorrectAnswer = nil
    lastCorrectAnswer = nil
    questions = []
    SoundPlayer.play(Sound.randomSadTrombone)
  }

  // MARK: - Private Methods

  private func generateQuestions() -> [QuizItem] {
    let allVerbs = Array(Verb.verbs.values)
    guard !allVerbs.isEmpty else { return [] }

    var items: [QuizItem] = []

    // Add exactly 1 präsenspartizip
    items.append(makeQuizItem(verb: allVerbs.randomElement()!, conjugationgroup: .präsenspartizip))

    // Add exactly 2 perfektpartizips
    for _ in 0..<2 {
      items.append(makeQuizItem(verb: allVerbs.randomElement()!, conjugationgroup: .perfektpartizip))
    }

    // Fill remaining 27 questions with non-participle conjugationgroups
    let remainingCount = Quiz.questionCount - 3
    for _ in 0..<remainingCount {
      let verb = allVerbs.randomElement()!
      let conjugationgroup = randomNonPartizipConjugationgroup()
      items.append(makeQuizItem(verb: verb, conjugationgroup: conjugationgroup))
    }

    // Shuffle so participles aren't always first
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

    // Non-participle conjugationgroups for regular difficulty
    options.append { .präsensIndicativ(self.randomPersonNumber()) }
    options.append { .perfektIndikativ(self.randomPersonNumber()) }
    options.append { .imperativ(self.randomImperativPersonNumber()) }

    if difficultyUsed == .ridiculous {
      // Additional conjugationgroups for ridiculous difficulty
      options.append { .präsensKonjunktivI(self.randomPersonNumber()) }
      options.append { .präteritumIndicativ(self.randomPersonNumber()) }
      options.append { .präteritumKonditional(self.randomPersonNumber()) }
      options.append { .perfektKonjunktivI(self.randomPersonNumber()) }
    }

    return options.randomElement()!()
  }

  private func randomPersonNumber() -> PersonNumber {
    PersonNumber.allCases.randomElement()!
  }

  private func randomImperativPersonNumber() -> PersonNumber {
    PersonNumber.imperativPersonNumbers.randomElement()!
  }

  private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.elapsedSeconds += 1
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
    SoundPlayer.play(Sound.randomApplause, shouldDebounce: false)
  }

  deinit {
    stopTimer()
  }
}

// MARK: - QuizItem

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
         .präteritumIndicativ(let pn), .präteritumKonditional(let pn),
         .perfektIndikativ(let pn), .perfektKonjunktivI(let pn):
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
