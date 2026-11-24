// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

@MainActor
@Suite("Verb Essentials")
struct VerbEssentialsTests {
  static let keyCells: [Conjugationgroup] = [.präsensIndikativ(.thirdSingular), .präteritumIndikativ(.thirdSingular), .perfektIndikativ(.thirdSingular)]

  /// Strong verbs with one reading, sorted, so that a seeded draw is the same in every process.
  static func strongVerbs(_ count: Int) -> [Verb] {
    QuizRecordSessionTests.strongVerbs(count)
  }

  @Test func aStepAsksTheThreeKeyConjugationsInTheVerbPagesOrder() throws {
    let fahren = try #require(Verb.verbs["fahren"])

    let step = QuizDraw.verbEssentialsStep(verb: fahren, readingIndex: 0)

    #expect(step.map(\.conjugationgroup) == Self.keyCells)
    #expect(step.allSatisfy { $0.verb == fahren && $0.readingIndex == 0 })
    let items = step.map { PracticeItem.exercised(by: $0.conjugationgroup, of: fahren, readingIndex: 0) }
    // fahren has two strong readings, and the step asks only the first's.
    #expect(items == Array(PracticeItem.keyConjugations(of: fahren).prefix(3)))
  }

  /// A separable, an inseparable, two sein-taking, and a mixed verb, with the main clause's and
  /// the subordinate clause's word order both right for a separable Präsens and Präteritum.
  /// fahren's first reading, drive a vehicle, takes haben, and its second, travel, sein.
  @Test(arguments: [
    ("aufstehen", 0, ["steht auf", "stand auf", "ist aufgestanden"]),
    ("aufstehen", 0, ["aufsteht", "aufstand", "ist aufgestanden"]),
    ("verstehen", 0, ["versteht", "verstand", "hat verstanden"]),
    ("fahren", 0, ["fährt", "fuhr", "hat gefahren"]),
    ("fahren", 1, ["fährt", "fuhr", "ist gefahren"]),
    ("gehen", 0, ["geht", "ging", "ist gegangen"]),
    ("denken", 0, ["denkt", "dachte", "hat gedacht"])
  ])
  func eachBlankAcceptsItsKeyConjugation(infinitiv: String, readingIndex: Int, answers: [String]) throws {
    let verb = try #require(Verb.verbs[infinitiv])
    let quiz = Quiz()

    let items = QuizDraw.verbEssentialsStep(verb: verb, readingIndex: readingIndex).map { question in
      quiz.makeQuizItem(verb: verb, conjugationgroup: question.conjugationgroup, readingIndex: readingIndex)
    }

    #expect(zip(items, answers).allSatisfy { $0.accepts($1) })
    // Each blank is graded alone: the Präsens blank does not take the Präteritum.
    #expect(!items[0].accepts(answers[1]))
  }

  @Test func aRoundDrawsDistinctStrongVerbsFromTheBand() {
    let band = Quiz.defaultVerbs(for: .beginner)
    var generator = SeededRNG(seed: 11)

    let steps = QuizDraw.verbEssentialsSteps(verbs: band, count: QuizScope.verbEssentialsVerbCount, using: &generator)

    #expect(steps.count == QuizScope.verbEssentialsVerbCount)
    #expect(Set(steps.map { $0[0].verb.infinitiv }).count == steps.count)
    for step in steps {
      #expect(step.map(\.conjugationgroup) == Self.keyCells)
      #expect(band.contains(step[0].verb))
      #expect(step[0].verb.reading(at: step[0].readingIndex).map(QuizDraw.isStrong) == true)
    }
  }

  @Test func weakVerbsAreNeverDrawnAndAMixedReadingVerbIsAskedItsStrongReading() throws {
    let machen = try #require(Verb.verbs["machen"])
    let sagen = try #require(Verb.verbs["sagen"])
    // anhängen's first reading is weak (anhängte) and its second strong (hing an).
    let anhängen = try #require(Verb.verbs["anhängen"])
    var generator = SeededRNG(seed: 5)

    let steps = QuizDraw.verbEssentialsSteps(verbs: [machen, sagen, anhängen], count: 5, using: &generator)

    #expect(steps.count == 1)
    #expect(steps.first?.first?.verb == anhängen)
    #expect(steps.first?.allSatisfy { $0.readingIndex == 1 } == true)
  }

  @Test func verbsAskedInTheSessionWaitUntilEveryOtherHasBeenAsked() {
    let verbs = Self.strongVerbs(7)
    let asked = verbs.prefix(5).flatMap(PracticeItem.keyConjugations(of:)).map(\.key)
    var generator = SeededRNG(seed: 9)

    let steps = QuizDraw.verbEssentialsSteps(verbs: verbs, count: 5, excluded: Set(asked), using: &generator)
    let drawn = steps.map { $0[0].verb.infinitiv }

    #expect(drawn.count == 5)
    #expect(Array(drawn.prefix(2)).sorted() == verbs.suffix(2).map(\.infinitiv))
    #expect(Set(drawn).count == 5)
  }

  @Test func theScopeIsNeverRankedMixesInNothingAndContinues() throws {
    let scope = QuizScope.verbEssentials()

    #expect(scope.isVerbEssentials)
    #expect(scope.questionCount == 15)
    #expect(!scope.isRanked)
    #expect(!scope.mixesDueItems)
    #expect(scope.continues)
    #expect(scope.sendsQuestionCounts)
    #expect(scope.source == .verbEssentials)
    #expect(LastQuizResult.Kind(scope: scope) == .verbEssentials)
    let fahren = try #require(Verb.verbs["fahren"])
    #expect(LastQuizResult.Kind(scope: .verbEssentials([fahren])) == .verbEssentials)
    #expect(!QuizScope.allVerbs.isVerbEssentials)
  }

  /// Three steps of three, A, B, and C, with the re-ask of a miss in A placed after B, and a second
  /// miss in A joining the first's re-ask.
  @Test func aMissedBlankReturnsAfterTheNextVerbAndASecondMissJoinsIt() {
    let quiz = Quiz()
    let verbs = Self.strongVerbs(3)
    var questions = verbs.flatMap { verb in
      let stepID = UUID()
      return QuizDraw.verbEssentialsStep(verb: verb, readingIndex: 0).map {
        quiz.makeQuizItem(verb: verb, conjugationgroup: $0.conjugationgroup, readingIndex: 0, stepID: stepID)
      }
    }

    let first = Quiz.reaskPlacement(of: 1, in: questions)
    #expect(first.position == 6)
    #expect(first.stepID != nil)
    #expect(first.stepID != questions[0].stepID)
    #expect(first.stepID != questions[3].stepID)
    questions.insert(questions[1].reasked(stepID: first.stepID), at: first.position)

    let second = Quiz.reaskPlacement(of: 2, in: questions)
    #expect(second.position == 7)
    #expect(second.stepID == first.stepID)

    let last = Quiz.reaskPlacement(of: 8, in: questions)
    #expect(last.position == questions.count)
    #expect(last.stepID != nil)
  }

  @Test func aQuestionShownAloneReturnsAfterThreeOthers() throws {
    let quiz = Quiz()
    let machen = try #require(Verb.verbs["machen"])
    let questions = (0..<10).map { _ in quiz.makeQuizItem(verb: machen, conjugationgroup: .präsensIndikativ(.firstSingular), readingIndex: 0) }

    let placement = Quiz.reaskPlacement(of: 2, in: questions)

    #expect(placement.position == 2 + 1 + Quiz.reaskGap)
    #expect(placement.stepID == nil)
    #expect(Quiz.reaskPlacement(of: 9, in: questions).position == 10)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Verb Essentials sessions")
  struct VerbEssentialsSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func started(_ scope: QuizScope = .verbEssentials(), level: QuizLevel = .beginner, seed: UInt64 = 3) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: seed))
      quiz.start(scope: scope)
      return quiz
    }

    private func answer(_ quiz: Quiz, correctly: Bool) throws {
      let question = try #require(quiz.currentQuestion)
      quiz.submitAnswer(correctly ? question.correctAnswer : "definitelywrong")
      if quiz.correction != nil {
        quiz.continueAfterCorrection()
      }
    }

    private func finish(_ quiz: Quiz, correctly: Bool) throws {
      while quiz.isInProgress {
        try answer(quiz, correctly: correctly)
      }
    }

    private func rowKinds(_ quiz: Quiz) -> [String] {
      (quiz.essentialsRows ?? []).map { row in
        switch row.content {
        case .answered:
          return "answered"
        case .current:
          return "current"
        case .given:
          return "given"
        case .pending:
          return "pending"
        }
      }
    }

    private var spy: AnalyticsSpy {
      Current.analytics as! AnalyticsSpy
    }

    @Test func aRoundAsksFiveVerbsOfTheBandInStepsOfThree() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }

      let quiz = started()
      defer { quiz.quit() }

      #expect(quiz.questions.count == 15)
      #expect(quiz.questionCount == 15)
      let band = Quiz.defaultVerbs(for: .beginner)
      for start in stride(from: 0, to: 15, by: 3) {
        let step = Array(quiz.questions[start..<(start + 3)])
        #expect(step.map(\.conjugationgroup) == VerbEssentialsTests.keyCells)
        #expect(Set(step.map(\.stepID)).count == 1)
        #expect(step[0].stepID != nil)
        #expect(band.contains(step[0].verb))
      }
      #expect(quiz.currentStepRange == 0..<3)
      #expect(rowKinds(quiz) == ["current", "pending", "pending"])
    }

    @Test func eachBlankIsGradedAloneAndRecordsItsOwnItem() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let singen = try #require(Verb.verbs["singen"])
      let quiz = started(.verbEssentials([singen]))
      defer { quiz.quit() }

      try answer(quiz, correctly: true)
      #expect(rowKinds(quiz) == ["answered", "current", "pending"])
      try answer(quiz, correctly: false)
      #expect(rowKinds(quiz) == ["answered", "answered", "current"])
      try answer(quiz, correctly: true)

      let record = practice.record
      let präsens = try #require(record.entry(for: .keyConjugation(infinitiv: "singen", readingIndex: 0, stem: .präsens)))
      let präteritum = try #require(record.entry(for: .keyConjugation(infinitiv: "singen", readingIndex: 0, stem: .präteritum)))
      let perfekt = try #require(record.entry(for: .keyConjugation(infinitiv: "singen", readingIndex: 0, stem: .perfekt)))
      #expect(präsens.lastAnswerWasRight == true)
      #expect(präteritum.lastAnswerWasRight == false)
      #expect(perfekt.lastAnswerWasRight == true)
      #expect(quiz.score == 2 * Quiz.pointsPerCorrect)
    }

    @Test func aMissedBlankReturnsAsItsOwnStepWithTheOthersGiven() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let verbs = VerbEssentialsTests.strongVerbs(3)
      let quiz = started(.verbEssentials(verbs))
      defer { quiz.quit() }
      let firstVerb = quiz.questions[0].verb

      try answer(quiz, correctly: true)
      try answer(quiz, correctly: false)
      try answer(quiz, correctly: true)

      #expect(quiz.questions.count == 10)
      let reask = quiz.questions[6]
      #expect(reask.isReask)
      #expect(reask.verb == firstVerb)
      #expect(reask.conjugationgroup == .präteritumIndikativ(.thirdSingular))
      for _ in 0..<3 {
        try answer(quiz, correctly: true)
      }
      #expect(quiz.currentIndex == 6)
      #expect(quiz.currentStepRange == 6..<7)
      #expect(rowKinds(quiz) == ["given", "current", "given"])
      try answer(quiz, correctly: true)
      #expect(quiz.questions[7].verb != firstVerb)
      #expect(rowKinds(quiz) == ["current", "pending", "pending"])
    }

    @Test func aDiagnosedBlankGetsOneMoreTryForHalfPoints() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let gehen = try #require(Verb.verbs["gehen"])
      let quiz = started(.verbEssentials([gehen]))
      defer { quiz.quit() }
      try answer(quiz, correctly: true)

      quiz.submitAnswer("gehte")
      #expect(quiz.isAwaitingSecondAttempt)
      #expect(quiz.questions[1].firstAttemptDiagnosis != nil)
      #expect(rowKinds(quiz) == ["answered", "current", "pending"])
      quiz.submitAnswer("ging")

      #expect(quiz.questions[1].state == .correctOnSecondAttempt)
      #expect(quiz.score == Quiz.pointsPerCorrect + Quiz.pointsPerSecondAttempt)
      #expect(rowKinds(quiz) == ["answered", "answered", "current"])
    }

    @Test func fiveMoreVerbsAreNewWhileTheBandLasts() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      try finish(quiz, correctly: true)
      #expect(quiz.canContinue)
      let firstRound = Set(quiz.questions.map(\.verb.infinitiv))

      quiz.continueSession()

      #expect(quiz.questions.count == 30)
      #expect(quiz.questionCount == 30)
      #expect(firstRound.isDisjoint(with: quiz.questions.dropFirst(15).map(\.verb.infinitiv)))
      quiz.quit()
    }

    @Test func aFinishedRoundSignalsItsSourceKeepsItsResultAndPostsNoScore() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let gameCenter = Current.gameCenter as! GameCenterSpy
      let submissions = gameCenter.submissions.count
      let before = spy.signalNames.count

      let quiz = started(level: .intermediate)
      try finish(quiz, correctly: true)

      let signals = Array(zip(spy.signalNames, spy.signalParameters).dropFirst(before))
      let start = try #require(signals.first { $0.0 == .startQuiz })
      #expect(start.1[ParameterKey.source.rawValue] == "verbEssentials")
      #expect(start.1[ParameterKey.level.rawValue] == "intermediate")
      let complete = try #require(signals.first { $0.0 == .completeQuiz })
      #expect(complete.1[ParameterKey.questionCount.rawValue] == "15")
      #expect(gameCenter.submissions.count == submissions)
      #expect(practice.lastResult?.kind == .verbEssentials)
      #expect(practice.lastResult?.level == .intermediate)
      #expect(practice.lastResult?.questionCount == 15)
    }
  }
}
