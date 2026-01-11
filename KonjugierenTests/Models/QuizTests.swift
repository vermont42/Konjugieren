// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

struct QuizTests {
  // MARK: - Initial State

  @Test func initialState() {
    let quiz = Quiz()
    #expect(quiz.isInProgress == false)
    #expect(quiz.shouldShowResults == false)
    #expect(quiz.currentIndex == 0)
    #expect(quiz.score == 0)
    #expect(quiz.elapsedSeconds == 0)
    #expect(quiz.correctCount == 0)
    #expect(quiz.lastIncorrectAnswer == nil)
    #expect(quiz.lastCorrectAnswer == nil)
    #expect(quiz.questions.isEmpty)
    #expect(quiz.currentQuestion == nil)
  }

  // MARK: - Start Quiz

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

  @Test func startQuizGeneratesCorrectParticiples() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    let präsenspartizipCount = quiz.questions.filter {
      if case .präsenspartizip = $0.conjugationgroup { return true }
      return false
    }.count

    let perfektpartizipCount = quiz.questions.filter {
      if case .perfektpartizip = $0.conjugationgroup { return true }
      return false
    }.count

    #expect(präsenspartizipCount == 1)
    #expect(perfektpartizipCount == 2)

    quiz.quit()
  }

  // MARK: - Quit Quiz

  @Test func quitQuiz() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()
    quiz.quit()

    #expect(quiz.isInProgress == false)
    #expect(quiz.currentIndex == 0)
    #expect(quiz.score == 0)
    #expect(quiz.correctCount == 0)
    #expect(quiz.elapsedSeconds == 0)
    #expect(quiz.lastIncorrectAnswer == nil)
    #expect(quiz.lastCorrectAnswer == nil)
    #expect(quiz.questions.isEmpty)
  }

  // MARK: - Submit Answer

  @Test func submitCorrectAnswer() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    let correctAnswer = quiz.questions[0].correctAnswer
    quiz.submitAnswer(correctAnswer)

    #expect(quiz.score == Quiz.pointsPerCorrect)
    #expect(quiz.correctCount == 1)
    #expect(quiz.currentIndex == 1)
    #expect(quiz.lastIncorrectAnswer == nil)
    #expect(quiz.lastCorrectAnswer == nil)
    #expect(quiz.questions[0].isCorrect == true)
    #expect(quiz.questions[0].userAnswer == correctAnswer)

    quiz.quit()
  }

  @Test func submitIncorrectAnswer() {
    let quiz = Quiz(timerInterval: 0.001)
    quiz.start()

    let correctAnswer = quiz.questions[0].correctAnswer
    let wrongAnswer = "definitelywrong"
    quiz.submitAnswer(wrongAnswer)

    #expect(quiz.score == 0)
    #expect(quiz.correctCount == 0)
    #expect(quiz.currentIndex == 1)
    #expect(quiz.lastIncorrectAnswer == wrongAnswer)
    #expect(quiz.lastCorrectAnswer == correctAnswer)
    #expect(quiz.questions[0].isCorrect == false)
    #expect(quiz.questions[0].userAnswer == wrongAnswer)

    quiz.quit()
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

  // MARK: - Computed Properties

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

  @Test func finalScoreRegularDifficulty() {
    let quiz = Quiz(timerInterval: 0.001)
    Current.settings.quizDifficulty = .regular
    quiz.start()

    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    #expect(quiz.finalScore == Quiz.pointsPerCorrect)

    quiz.quit()
  }

  @Test func finalScoreRidiculousDifficultyDoubles() {
    let quiz = Quiz(timerInterval: 0.001)
    Current.settings.quizDifficulty = .ridiculous
    quiz.start()

    quiz.submitAnswer(quiz.questions[0].correctAnswer)
    #expect(quiz.finalScore == Quiz.pointsPerCorrect * 2)

    quiz.quit()
    Current.settings.quizDifficulty = .regular
  }

  // MARK: - Timer

  @Test @MainActor func timerIncrementsElapsedSeconds() {
    let quiz = Quiz(timerInterval: 0.01)
    quiz.start()

    #expect(quiz.elapsedSeconds == 0)

    // Pump the run loop to allow the timer to fire.
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

    #expect(quiz.elapsedSeconds > 0)

    quiz.quit()
  }

  // MARK: - QuizItem Pronoun

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
      conjugationgroup: .präsensIndicativ(.firstSingular),
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

  // MARK: - QuizItem DisplayName

  @Test func quizItemDisplayNameGerman() {
    let verb = Verb.verbs["machen"]!
    let item = QuizItem(
      verb: verb,
      conjugationgroup: .präsensIndicativ(.firstSingular),
      correctAnswer: "mache"
    )

    let germanName = item.displayName(lang: .german)
    #expect(germanName.contains("Präsens") || germanName.contains("Indikativ"))
  }

  @Test func quizItemDisplayNameEnglish() {
    let verb = Verb.verbs["machen"]!
    let item = QuizItem(
      verb: verb,
      conjugationgroup: .präsensIndicativ(.firstSingular),
      correctAnswer: "mache"
    )

    let englishName = item.displayName(lang: .english)
    #expect(englishName.contains("Present") || englishName.contains("Indicative"))
  }

  // MARK: - Constants

  @Test func quizConstants() {
    #expect(Quiz.questionCount == 30)
    #expect(Quiz.pointsPerCorrect == 10)
  }
}
