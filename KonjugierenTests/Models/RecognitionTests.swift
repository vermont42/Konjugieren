// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("Recognition")
struct RecognitionTests {
  static let advancedTables = RecognitionQuestion.tables(for: QuizLevel.advanced.pool)

  static func question(_ infinitiv: String, _ conjugationgroup: Conjugationgroup, readingIndex: Int = 0, tables: [ConjugationTable] = advancedTables) throws -> RecognitionQuestion {
    let verb = try #require(Verb.verbs[infinitiv])
    return RecognitionQuestion(verb: verb, conjugationgroup: conjugationgroup, readingIndex: readingIndex, tables: tables)
  }

  static func answer(_ infinitiv: String, _ table: ConjugationTable, _ personNumber: PersonNumber?) -> RecognitionAnswer {
    RecognitionAnswer(infinitiv: infinitiv, table: table, personNumber: personNumber)
  }

  @Test func kämeIsKommensKonjunktivIIForIchAndEr() throws {
    let question = try Self.question("kommen", .präteritumKonjunktivII(.firstSingular))
    #expect(question.prompt.lowercased() == "käme")
    #expect(question.cells == [
      RecognitionCell(infinitiv: "kommen", readingIndex: 0, conjugationgroup: .präteritumKonjunktivII(.firstSingular)),
      RecognitionCell(infinitiv: "kommen", readingIndex: 0, conjugationgroup: .präteritumKonjunktivII(.thirdSingular))
    ])
  }

  @Test func fuhrIsEitherReadingOfFahrenAndNoPrefixedVerb() throws {
    let question = try Self.question("fahren", .präteritumIndikativ(.thirdSingular))
    #expect(Set(question.cells.map(\.infinitiv)) == ["fahren"])
    #expect(Set(question.cells.map(\.readingIndex)) == [0, 1])
    #expect(Set(question.cells.map(\.conjugationgroup)) == [.präteritumIndikativ(.firstSingular), .präteritumIndikativ(.thirdSingular)])
  }

  @Test func kamAnIsAnkommenAlone() throws {
    let question = try Self.question("ankommen", .präteritumIndikativ(.firstSingular))
    #expect(question.prompt.lowercased() == "kam an")
    #expect(Set(question.cells.map(\.infinitiv)) == ["ankommen"])
    #expect(question.cells.count == 2)
  }

  @Test func weißBelongsToWissenAndWeißen() throws {
    let question = try Self.question("wissen", .präsensIndikativ(.firstSingular))
    #expect(question.cells.contains(RecognitionCell(infinitiv: "wissen", readingIndex: 0, conjugationgroup: .präsensIndikativ(.thirdSingular))))
    #expect(question.cells.contains(RecognitionCell(infinitiv: "weißen", readingIndex: 0, conjugationgroup: .imperativ(.secondSingular))))
    #expect(question.cells.first?.infinitiv == "wissen")
  }

  @Test func kommenIsThePräsensAndTheKonjunktivIForWirAndSie() throws {
    let question = try Self.question("kommen", .präsensIndikativ(.firstPlural))
    #expect(Set(question.cells.map(\.conjugationgroup)) == [
      .präsensIndikativ(.firstPlural), .präsensIndikativ(.thirdPlural),
      .präsensKonjunktivI(.firstPlural), .präsensKonjunktivI(.thirdPlural)
    ])
  }

  @Test func onlyTheOfferedTablesCount() throws {
    let beginner = RecognitionQuestion.tables(for: QuizLevel.beginner.pool)
    #expect(beginner == [.präsensIndikativ, .imperativ])
    let kommen = try Self.question("kommen", .präsensIndikativ(.firstPlural), tables: beginner)
    #expect(Set(kommen.cells.map(\.conjugationgroup)) == [.präsensIndikativ(.firstPlural), .präsensIndikativ(.thirdPlural)])

    let elementary = RecognitionQuestion.tables(for: QuizLevel.elementary.pool)
    let machte = try Self.question("machen", .präteritumIndikativ(.thirdSingular), tables: elementary)
    #expect(Set(machte.cells.map(\.conjugationgroup.table)) == [.präteritumIndikativ])
    let machteAdvanced = try Self.question("machen", .präteritumIndikativ(.thirdSingular))
    #expect(Set(machteAdvanced.cells.map(\.conjugationgroup.table)) == [.präteritumIndikativ, .präteritumKonjunktivII])
  }

  @Test func compoundsAndParticiplesAreTheirVerbsAlone() throws {
    let gegangen = try Self.question("gehen", .perfektIndikativ(.thirdSingular))
    #expect(gegangen.cells == [RecognitionCell(infinitiv: "gehen", readingIndex: 0, conjugationgroup: .perfektIndikativ(.thirdSingular))])
    let gesungen = try Self.question("singen", .perfektpartizip)
    #expect(gesungen.cells == [RecognitionCell(infinitiv: "singen", readingIndex: 0, conjugationgroup: .perfektpartizip)])
    let seienSie = try Self.question("sein", .imperativ(.thirdPlural))
    #expect(seienSie.cells.contains(RecognitionCell(infinitiv: "sein", readingIndex: 0, conjugationgroup: .imperativ(.thirdPlural))))
  }

  @Test func everyCellWritesThePrompt() throws {
    for (infinitiv, group) in [("kommen", Conjugationgroup.präteritumKonjunktivII(.firstSingular)), ("wissen", .präsensIndikativ(.firstSingular)), ("hängen", .präsensIndikativ(.thirdSingular))] {
      let question = try Self.question(infinitiv, group)
      for cell in question.cells {
        let verb = try #require(Verb.verbs[cell.infinitiv])
        #expect(verb.conjugations(matching: question.prompt).contains { $0.readingIndex == cell.readingIndex && $0.conjugationgroup == cell.conjugationgroup })
      }
    }
  }

  @Test func anyRightCellIsRightInAnySpelling() throws {
    let käme = try Self.question("kommen", .präteritumKonjunktivII(.firstSingular))
    #expect(käme.grade(Self.answer("kommen", .präteritumKonjunktivII, .firstSingular)).isCorrect)
    #expect(käme.grade(Self.answer(" Kommen ", .präteritumKonjunktivII, .thirdSingular)).isCorrect)

    let übernahm = try Self.question("übernehmen", .präteritumIndikativ(.firstSingular))
    #expect(übernahm.grade(Self.answer("uebernehmen", .präteritumIndikativ, .thirdSingular)).isCorrect)
    #expect(übernahm.preferredSpelling(of: "uebernehmen") == "übernehmen")
    #expect(übernahm.preferredSpelling(of: "übernehmen") == nil)

    let hieß = try Self.question("heißen", .präteritumIndikativ(.firstSingular))
    #expect(hieß.grade(Self.answer("heissen", .präteritumIndikativ, .firstSingular)).isCorrect)

    let weiß = try Self.question("wissen", .präsensIndikativ(.firstSingular))
    #expect(weiß.grade(Self.answer("weißen", .imperativ, .secondSingular)).isCorrect)
    // Judged against wissen's own cells, the Präsens of ich and er, not weißen's du Imperativ.
    #expect(weiß.grade(Self.answer("wissen", .imperativ, .secondSingular)).wrongParts == [.conjugationgroup, .person])
    #expect(weiß.grade(Self.answer("wissen", .präteritumIndikativ, .firstSingular)).wrongParts == [.conjugationgroup])
  }

  @Test func theGradeNamesOnlyThePartsToChange() throws {
    let käme = try Self.question("kommen", .präteritumKonjunktivII(.firstSingular))
    let cases: [(RecognitionAnswer, Set<RecognitionPart>, Bool)] = [
      (Self.answer("komen", .präteritumKonjunktivII, .firstSingular), [.infinitive], true),
      (Self.answer("kommen", .präteritumIndikativ, .firstSingular), [.conjugationgroup], true),
      (Self.answer("kommen", .präteritumKonjunktivII, .secondSingular), [.person], true),
      (Self.answer("kommen", .präteritumIndikativ, .secondSingular), [.conjugationgroup, .person], true),
      (Self.answer("gehen", .präteritumKonjunktivII, .secondSingular), [.infinitive, .person], true),
      (Self.answer("gehen", .präsensIndikativ, .thirdSingular), [.infinitive, .conjugationgroup], true),
      (Self.answer("gehen", .präsensIndikativ, .secondSingular), [.infinitive, .conjugationgroup, .person], false),
      (Self.answer("kommen", .perfektpartizip, nil), [.conjugationgroup], true)
    ]
    for (answer, wrong, hasRightPart) in cases {
      let grade = käme.grade(answer)
      #expect(grade.wrongParts == wrong, "\(answer)")
      #expect(grade.hasRightPart == hasRightPart, "\(answer)")
      #expect(grade.earnsSecondAttempt == hasRightPart, "\(answer)")
    }

    let gesungen = try Self.question("singen", .perfektpartizip)
    #expect(gesungen.grade(Self.answer("singen", .perfektIndikativ, .firstSingular)).wrongParts == [.conjugationgroup])
    #expect(gesungen.grade(Self.answer("singen", .perfektpartizip, nil)).isCorrect)
  }

  @Test func eachGradeHasItsLine() {
    let lines: [(Set<RecognitionPart>, String)] = [
      ([.infinitive], "Check the infinitive."),
      ([.conjugationgroup], "Check the conjugationgroup."),
      ([.person], "Check the person."),
      ([.infinitive, .conjugationgroup], "Check the infinitive and the conjugationgroup."),
      ([.infinitive, .person], "Check the infinitive and the person."),
      ([.conjugationgroup, .person], "Check the conjugationgroup and the person.")
    ]
    for (wrong, line) in lines {
      #expect(RecognitionGrade(wrongParts: wrong, hasRightPart: true).line == line)
    }
  }

  @Test func theCorrectionListsEveryRightAnswer() throws {
    let er = PersonNumber.thirdSingular.pronounWithSieDisambiguation
    let käme = try Self.question("kommen", .präteritumKonjunktivII(.firstSingular))
    #expect(käme.answerLines(lang: .english) == ["kommen · Past Conditional · ich, \(er)"])
    let fuhr = try Self.question("fahren", .präteritumIndikativ(.thirdSingular))
    #expect(fuhr.answerLines(lang: .german) == ["fahren · Präteritum Indikativ · ich, \(er)"])
    let gesungen = try Self.question("singen", .perfektpartizip)
    #expect(gesungen.answerLines(lang: .german) == ["singen · Perfektpartizip"])
    #expect(Self.answer("Komen", .präteritumIndikativ, .firstSingular).summary(lang: .german) == "komen · Präteritum Indikativ · ich")
    #expect(käme.nearestInfinitive(to: "komen") == "kommen")
  }

  @Test func theChipsOfferEachTablesPersons() {
    #expect(RecognitionQuestion.persons(of: .präsensIndikativ) == PersonNumber.allCases)
    #expect(RecognitionQuestion.persons(of: .imperativ) == PersonNumber.imperativPersonNumbers)
    #expect(RecognitionQuestion.persons(of: .perfektpartizip).isEmpty)
    #expect(RecognitionQuestion.personLabel(.thirdPlural, in: .imperativ) == "Sie")
  }

  @Test func theScopeIsNeverRankedAndMixesNoDueItems() {
    let scope = QuizScope.recognition()
    #expect(scope.isRecognition)
    #expect(!scope.isRanked)
    #expect(!scope.mixesDueItems)
    #expect(scope.continues)
    #expect(scope.asksByLevel)
    #expect(scope.sendsQuestionCounts)
    #expect(LastQuizResult.Kind(scope: scope) == .recognition)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Recognition sessions")
  struct RecognitionSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func started(level: QuizLevel = .elementary, seed: UInt64 = 7) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: seed))
      quiz.start(scope: .recognition())
      return quiz
    }

    private func rightAnswer(_ question: QuizItem) throws -> RecognitionAnswer {
      let cell = try #require(question.recognition?.cells.last)
      return RecognitionAnswer(infinitiv: cell.infinitiv, table: cell.conjugationgroup.table, personNumber: cell.conjugationgroup.personNumber)
    }

    /// Nothing right: another verb, and a table and person that no right cell has.
    private func wrongAnswer(_ question: QuizItem) throws -> RecognitionAnswer {
      let recognition = try #require(question.recognition)
      let tables = Set(recognition.cells.map(\.conjugationgroup.table))
      let persons = Set(recognition.cells.compactMap(\.conjugationgroup.personNumber))
      let table = try #require(recognition.tables.first { !tables.contains($0) && !RecognitionQuestion.persons(of: $0).isEmpty })
      let person = RecognitionQuestion.persons(of: table).first { !persons.contains($0) }
      return RecognitionAnswer(infinitiv: "definitelywrong", table: table, personNumber: person)
    }

    private func finish(_ quiz: Quiz) throws {
      while let question = quiz.currentQuestion {
        quiz.submitRecognition(try rightAnswer(question))
      }
    }

    private var spy: AnalyticsSpy {
      Current.analytics as! AnalyticsSpy
    }

    @Test func aRoundAsksTenPromptsOfTheLevelsBandAndTables() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started(level: .beginner)
      defer { quiz.quit() }

      #expect(quiz.questions.count == Quiz.questionCount)
      let band = Set(Quiz.defaultVerbs(for: .beginner))
      let cells = Set(QuizLevel.beginner.pool.flatMap(\.cells))
      for question in quiz.questions {
        let recognition = try #require(question.recognition)
        #expect(band.contains(question.verb))
        #expect(cells.contains(question.conjugationgroup))
        #expect(recognition.tables == [.präsensIndikativ, .imperativ])
        #expect(recognition.prompt == question.correctAnswer)
        #expect(recognition.cells.contains(RecognitionCell(infinitiv: question.verb.infinitiv, readingIndex: question.readingIndex, conjugationgroup: question.conjugationgroup)))
      }
    }

    @Test func aRightAnswerScoresAndLeavesTheRecordAlone() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let errorsBefore = QuizErrorHistory.load(getterSetter: Current.getterSetter).count
      let quiz = started()
      defer { quiz.quit() }

      quiz.submitRecognition(try rightAnswer(try #require(quiz.currentQuestion)))
      #expect(quiz.score == Quiz.pointsPerCorrect)
      #expect(quiz.currentIndex == 1)
      quiz.submitRecognition(try wrongAnswer(try #require(quiz.currentQuestion)))
      #expect(quiz.correction != nil)

      #expect(practice.record.entries.isEmpty)
      #expect(QuizErrorHistory.load(getterSetter: Current.getterSetter).count == errorsBefore)
    }

    @Test func aPartlyRightAnswerGetsOneMoreTryForHalfPoints() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      defer { quiz.quit() }
      let question = try #require(quiz.currentQuestion)
      let right = try rightAnswer(question)

      quiz.submitRecognition(RecognitionAnswer(infinitiv: "definitelywrong", table: right.table, personNumber: right.personNumber))
      #expect(quiz.isAwaitingSecondAttempt)
      #expect(quiz.questions[0].firstAttemptRecognition?.wrongParts == [.infinitive])
      #expect(quiz.questions[0].secondAttemptPrompt == "Check the infinitive. Try once more.")
      quiz.submitRecognition(right)

      #expect(quiz.questions[0].state == .correctOnSecondAttempt)
      #expect(quiz.score == Quiz.pointsPerSecondAttempt)
      #expect(quiz.correction == nil)
    }

    @Test func aWrongAnswerHoldsItsCorrectionAndReturnsOnce() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      defer { quiz.quit() }
      let question = try #require(quiz.currentQuestion)
      let wrong = try wrongAnswer(question)

      quiz.submitRecognition(wrong)
      #expect(!quiz.isAwaitingSecondAttempt)
      let correction = try #require(quiz.correction)
      #expect(correction.recognitionAnswer == wrong)
      #expect(correction.recognitionGrade?.hasRightPart == false)
      #expect(correction.willBeReasked)
      #expect(quiz.questions[0].isCorrect == false)
      #expect(quiz.questions.count == Quiz.questionCount + 1)
      let reask = quiz.questions[1 + Quiz.reaskGap]
      #expect(reask.isReask)
      #expect(reask.recognition == question.recognition)

      quiz.continueAfterCorrection()
      #expect(quiz.currentIndex == 1)
    }

    @Test func aFinishedRoundSignalsItsSourceKeepsItsResultAndPostsNoScore() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let gameCenter = Current.gameCenter as! GameCenterSpy
      let submissions = gameCenter.submissions.count
      let before = spy.signalNames.count

      let quiz = started(level: .intermediate)
      try finish(quiz)

      #expect(quiz.score == Quiz.questionCount * Quiz.pointsPerCorrect)
      let signals = Array(zip(spy.signalNames, spy.signalParameters).dropFirst(before))
      let start = try #require(signals.first { $0.0 == .startQuiz })
      #expect(start.1[ParameterKey.source.rawValue] == "recognition")
      #expect(start.1[ParameterKey.level.rawValue] == "intermediate")
      let complete = try #require(signals.first { $0.0 == .completeQuiz })
      #expect(complete.1[ParameterKey.questionCount.rawValue] == "10")
      #expect(gameCenter.submissions.count == submissions)
      #expect(practice.lastResult?.kind == .recognition)
      #expect(practice.lastResult?.level == .intermediate)

      #expect(quiz.canContinue)
      quiz.continueSession()
      #expect(quiz.questions.count == 2 * Quiz.questionCount)
      #expect(quiz.questions.allSatisfy { $0.recognition != nil })
      quiz.quit()
    }
  }
}
