// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

/// No bundled choice may show a wrong conjugation in either sentence, or be asked at a level that
/// does not ask its answer. Each test walks every item and records each failure with the item's
/// id, so that one run lists every draft that needs fixing.
@MainActor
@Suite("Choice questions")
struct ChoiceQuestionTests {
  static func item(_ id: String) throws -> ChoiceQuestion {
    try #require(ChoiceQuestions.all.first { $0.id == id })
  }

  /// An item written here rather than bundled, decoded as the bundle's are.
  static func item(level: String = "elementary", reviewed: Bool = true) -> ChoiceQuestion {
    let json: [String: Any] = [
      "id": "machen.test.\(reviewed ? 1 : 2)",
      "verb": "machen",
      "person": "ss",
      "level": level,
      "setting": "conversation",
      "reason": "perfekt_in_conversation",
      "right": ["table": "perfekt_indikativ", "de": "Was {hast} du {gemacht}?"],
      "other": ["table": "praeteritum_indikativ", "de": "Was {machtest} du?"],
      "en": "What did you do?",
      "reviewed": reviewed
    ]
    let data = (try? JSONSerialization.data(withJSONObject: [json])) ?? Data()
    return ChoiceQuestions.decode(data)[0]
  }

  /// The first batch, as Josh chose on 2026-11-15: about forty.
  @Test func theBundleHoldsTheItems() {
    #expect(ChoiceQuestions.all.count >= 40)
  }

  @Test func everyItemIsWellFormed() {
    var ids: Set<String> = []
    for item in ChoiceQuestions.all {
      let id = item.id
      if !ids.insert(id).inserted {
        Issue.record("\(id): the id is not unique")
      }
      if !id.hasPrefix("\(item.verb).") {
        Issue.record("\(id): the id does not begin with its verb")
      }
      guard let verb = Verb.verbs[item.verb] else {
        Issue.record("\(id): \(item.verb) is not in the corpus")
        continue
      }
      if verb.reading(at: item.readingIndex) == nil {
        Issue.record("\(id): \(item.verb) has no reading \(item.readingIndex)")
      }
      if item.quizLevel == nil || item.quizLevel == .beginner {
        Issue.record("\(id): \(item.level) is not a level from Elementary up")
      }
      if item.choiceSetting == nil {
        Issue.record("\(id): \(item.setting) is not a setting")
      }
      if item.choiceReason == nil {
        Issue.record("\(id): \(item.reason) is not a reason")
      }
      for sentence in [item.rightSentence, item.otherSentence] {
        if sentence.conjugationgroup == nil {
          Issue.record("\(id): \(sentence.table) and \(item.person) name no cell")
        }
        let opening = sentence.german.filter { $0 == "{" }.count
        let closing = sentence.german.filter { $0 == "}" }.count
        if opening != closing || opening != sentence.blankAnswers.count || !(1...2).contains(opening) {
          Issue.record("\(id): a sentence takes one or two well-formed conjugation words")
        }
        if !(sentence.german.last.map { ".!?".contains($0) } ?? false) {
          Issue.record("\(id): each sentence ends with . ! or ?")
        }
      }
      if item.right.table == item.other.table {
        Issue.record("\(id): the two sentences ask the same conjugationgroup")
      }
      if item.rightSentence.completed == item.otherSentence.completed {
        Issue.record("\(id): the two sentences read alike")
      }
      if !(item.english.last.map { ".!?".contains($0) } ?? false) || item.english.contains("{") {
        Issue.record("\(id): the English ends with . ! or ? and has no braces")
      }
    }
  }

  /// The gap sentences' check, applied to each sentence: its braces, read in order, are the
  /// conjugator's conjugation of its cell in one clause's word order, in every region, Swiss ss
  /// for ß aside, so that neither sentence can show a wrong conjugation.
  @Test func bothSentencesAreTheConjugatorsConjugations() {
    for item in ChoiceQuestions.all {
      for sentence in [item.rightSentence, item.otherSentence] {
        guard let conjugationgroup = sentence.conjugationgroup, Verb.verbs[sentence.verb] != nil else {
          continue
        }
        let answer = Self.folded(sentence.answer)
        for region in Region.allCases {
          let conjugations = Clause.allCases.map { clause in
            Self.folded(RegionalConjugator.conjugateUnsafely(infinitiv: sentence.verb, conjugationgroup: conjugationgroup, region: region, readingIndex: sentence.readingIndex, clause: clause))
          }
          if !conjugations.contains(answer) {
            Issue.record("\(sentence.id): the braces give \"\(sentence.answer)\", but \(region) conjugates \(conjugations.joined(separator: " or "))")
          }
        }
      }
    }
  }

  /// An item's own level asks its verb, in its band, the right sentence's cell.
  @Test func everyItemsLevelAsksItsAnswer() {
    for item in ChoiceQuestions.all {
      guard let level = item.quizLevel else {
        continue
      }
      if !item.isAskable(at: level) {
        Issue.record("\(item.id): \(level) does not ask \(item.verb) in \(item.right.table)")
      }
    }
  }

  @Test func everyReasonReadsInBothLanguagesOfNames() {
    for item in ChoiceQuestions.all {
      for lang in ConjugationgroupLang.allCases {
        let line = item.reasonLine(lang: lang)
        let rightName = item.rightSentence.conjugationgroup?.displayName(lang: lang) ?? "?"
        if !line.contains(rightName) || line.contains("%") {
          Issue.record("\(item.id): the reason \"\(line)\" does not name \(rightName)")
        }
      }
    }
  }

  @Test func theBatchCoversEveryContrastAndLevel() {
    #expect(Set(ChoiceQuestions.all.compactMap(\.choiceReason)) == Set(ChoiceReason.allCases))
    #expect(Set(ChoiceQuestions.all.compactMap(\.choiceSetting)) == Set(ChoiceSetting.allCases))
    #expect(Set(ChoiceQuestions.all.compactMap(\.quizLevel)) == [.elementary, .intermediate, .advanced])
  }

  private static func folded(_ text: String) -> String {
    text.lowercased().replacingOccurrences(of: "ß", with: "ss")
  }

  @Test func anItemReadsItsTwoSentences() throws {
    let item = try Self.item("machen.perfekt.1")
    #expect(item.rightSentence.answer == "hast gemacht")
    #expect(item.otherSentence.answer == "machtest")
    #expect(item.rightSentence.conjugationgroup == .perfektIndikativ(.secondSingular))
    #expect(item.otherSentence.conjugationgroup == .präteritumIndikativ(.secondSingular))
    #expect(item.choiceSetting == .conversation)
    #expect(item.reasonLine(lang: .german).contains("Perfekt Indikativ"))
    #expect(item.reasonLine(lang: .english).contains("Present Perfect Indicative"))
  }

  @Test func aReasonCanNameBothConjugationgroups() throws {
    let line = try Self.item("regnen.futur.1").reasonLine(lang: .german)
    #expect(line.contains("Futur Indikativ"))
    #expect(line.contains("Präsens Indikativ"))
  }

  @Test(arguments: [0, 1])
  func aPromptPutsTheRightSentenceWhereItSays(rightIndex: Int) throws {
    let item = try Self.item("sein.praeteritum.1")
    let prompt = ChoicePrompt(question: item, rightIndex: rightIndex)
    #expect(prompt.options[rightIndex] == item.rightSentence)
    #expect(prompt.options[1 - rightIndex] == item.otherSentence)
  }

  @Test func anItemIsAskedFromItsLevelUp() {
    let item = Self.item(level: "intermediate")
    #expect(!item.isAskable(at: .beginner))
    #expect(!item.isAskable(at: .elementary))
    #expect(item.isAskable(at: .intermediate))
    #expect(item.isAskable(at: .advanced))
  }

  @Test func beginnerHasNoChoices() {
    #expect(ChoiceQuestions.askable(at: .beginner).isEmpty)
    #expect(!ChoiceQuestions.askable(at: .elementary).isEmpty)
    #expect(ChoiceQuestions.askable(at: .advanced).count == ChoiceQuestions.all.count)
  }

  @Test func eachLevelAsksMoreThanTheOneBefore() {
    let counts = QuizLevel.allCases.map { ChoiceQuestions.askable(at: $0).count }
    #expect(counts == counts.sorted())
    #expect(ChoiceQuestions.askable(at: .elementary).allSatisfy { $0.quizLevel == .elementary })
  }

  @Test func aReleaseBuildAsksOnlyReviewedItems() {
    let draft = Self.item(reviewed: false)
    let reviewed = Self.item()
    #expect(ChoiceQuestions.askable(at: .advanced, from: [draft, reviewed], includesDrafts: false) == [reviewed])
    #expect(ChoiceQuestions.askable(at: .advanced, from: [draft, reviewed], includesDrafts: true).count == 2)
  }

  @Test func theItemsAnswerIsTheRightSentencesConjugation() throws {
    let quiz = Quiz()
    let item = try #require(quiz.makeChoiceItem(ChoicePrompt(question: try Self.item("kaufen.wuerde.1"), rightIndex: 1)))
    #expect(item.verb.infinitiv == "kaufen")
    #expect(item.conjugationgroup == .futurKonjunktivII(.firstSingular))
    #expect(item.correctAnswer.lowercased() == "würde kaufen")
    #expect(item.choice?.rightIndex == 1)
    #expect(item.reasked().choice == item.choice)
  }

  @Test func theDrawPrefersUnaskedItems() throws {
    var generator = SeededRNG(seed: 4)
    let pool = ChoiceQuestions.all.filter { $0.verb == "sein" }
    let unasked = try #require(pool.last)
    let excluded = Set(pool.dropLast().map(\.id))
    for _ in 0..<10 {
      #expect(QuizDraw.choice(from: pool, excluded: excluded, using: &generator)?.question == unasked)
    }
  }

  @Test func onceEveryItemIsAskedTheDrawStartsOver() {
    var generator = SeededRNG(seed: 4)
    let pool = ChoiceQuestions.all.filter { $0.verb == "sein" }
    let drawn = QuizDraw.choice(from: pool, excluded: Set(pool.map(\.id)), using: &generator)
    #expect(drawn.map { pool.contains($0.question) } == true)
    #expect(QuizDraw.choice(from: [], excluded: [], using: &generator) == nil)
  }

  @Test func theRightSentenceTakesEitherPlace() {
    var generator = SeededRNG(seed: 2)
    let places = (0..<40).compactMap { _ in QuizDraw.choice(from: ChoiceQuestions.all, excluded: [], using: &generator)?.rightIndex }
    #expect(Set(places) == [0, 1])
  }

  @Test func aChoiceIsNeverFirst() {
    var generator = SeededRNG(seed: 9)
    let positions = (0..<200).map { _ in QuizDraw.choicePosition(in: 9, using: &generator) }
    #expect(positions.allSatisfy { (1...9).contains($0) })
    #expect(Set(positions).count == 9)
  }
}

extension QuizTests {
  @MainActor
  @Suite("Choice questions in the quiz")
  struct ChoiceSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func started(level: QuizLevel = .elementary, scope: QuizScope = .allVerbs, seed: UInt64 = 7) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: seed))
      quiz.start(scope: scope)
      return quiz
    }

    /// Answers every question of the round rightly up to the choice, which it returns.
    private func advanceToChoice(_ quiz: Quiz) throws -> ChoicePrompt {
      while let question = quiz.currentQuestion, question.choice == nil {
        quiz.submitAnswer(question.correctAnswer)
      }
      return try #require(quiz.currentQuestion?.choice)
    }

    @Test(arguments: [QuizLevel.elementary, .intermediate, .advanced])
    func aDefaultRoundAsksOneChoiceOfItsLevel(level: QuizLevel) throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      for seed in UInt64(1)...5 {
        let quiz = started(level: level, seed: seed)
        defer { quiz.quit() }
        #expect(quiz.questions.count == Quiz.questionCount)
        let choices = quiz.questions.compactMap(\.choice)
        #expect(choices.count == 1)
        #expect(quiz.questions.first?.choice == nil)
        #expect(choices.allSatisfy { $0.question.isAskable(at: level) })
      }
    }

    @Test func beginnerAsksNoChoice() {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started(level: .beginner)
      defer { quiz.quit() }
      #expect(quiz.questions.count == Quiz.questionCount)
      #expect(quiz.questions.allSatisfy { $0.choice == nil })
    }

    @Test func otherQuizzesAskNoChoice() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let verbs = try ["kommen", "gehen", "machen"].map { try #require(Verb.verbs[$0]) }
      for scope in [QuizScope.myVerbs(verbs), .sentences(), .recognition(), .verbPage(verbs[0], readingIndex: 0)] {
        #expect(!scope.mixesChoiceQuestions)
        let quiz = started(level: .advanced, scope: scope)
        #expect(quiz.questions.allSatisfy { $0.choice == nil })
        quiz.quit()
      }
      #expect(QuizScope.allVerbs.mixesChoiceQuestions)
    }

    @Test func aRightChoiceScoresAndHoldsItsReasonUntilContinue() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      defer { quiz.quit() }
      let choice = try advanceToChoice(quiz)
      let index = quiz.currentIndex
      let scoreBefore = quiz.score
      let recordBefore = practice.record.entries.count
      let errorsBefore = QuizErrorHistory.load(getterSetter: Current.getterSetter).count

      quiz.submitChoice(choice.rightIndex)
      #expect(quiz.isHoldingChoice)
      #expect(quiz.isHeld)
      #expect(quiz.correction == nil)
      #expect(quiz.currentIndex == index)
      #expect(quiz.questions[index].state == .correct)
      #expect(quiz.questions[index].chosenOption == choice.rightIndex)
      #expect(quiz.score == scoreBefore + Quiz.pointsPerCorrect)
      #expect(practice.record.entries.count == recordBefore)
      #expect(QuizErrorHistory.load(getterSetter: Current.getterSetter).count == errorsBefore)

      quiz.submitChoice(1 - choice.rightIndex)
      #expect(quiz.questions[index].state == .correct)
      quiz.submitAnswer("anything")
      #expect(quiz.currentIndex == index)

      quiz.continueAfterCorrection()
      #expect(!quiz.isHoldingChoice)
      #expect(quiz.currentIndex == index + 1 || !quiz.isInProgress)
    }

    @Test func aWrongChoiceHoldsAndIsNotAskedAgain() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started(level: .intermediate, seed: 3)
      defer { quiz.quit() }
      let choice = try advanceToChoice(quiz)
      let index = quiz.currentIndex
      let count = quiz.questions.count
      let scoreBefore = quiz.score

      quiz.submitChoice(1 - choice.rightIndex)
      #expect(quiz.isHoldingChoice)
      #expect(quiz.questions[index].state == .incorrect)
      #expect(quiz.questions[index].userAnswer == choice.options[1 - choice.rightIndex].answer)
      #expect(quiz.score == scoreBefore)
      #expect(quiz.questions.count == count)
      #expect(!quiz.questions.contains { $0.isReask && $0.choice != nil })
    }

    @Test func tenMoreAsksAnotherChoiceNotYetAsked() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started(level: .elementary, seed: 11)
      while let question = quiz.currentQuestion {
        if let choice = question.choice {
          quiz.submitChoice(choice.rightIndex)
          quiz.continueAfterCorrection()
        } else {
          quiz.submitAnswer(question.correctAnswer)
        }
      }
      #expect(quiz.shouldShowResults)
      #expect(quiz.score == Quiz.questionCount * Quiz.pointsPerCorrect)
      let first = try #require(quiz.questions.compactMap(\.choice).first)

      quiz.continueSession()
      let second = quiz.questions.suffix(Quiz.questionCount).compactMap(\.choice)
      #expect(second.count == 1)
      #expect(second.first?.question != first.question)
      quiz.quit()
    }

    @Test func aRankedRoundPostsOutOfAHundred() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let gameCenter = Current.gameCenter as! GameCenterSpy
      let quiz = started(level: .advanced, seed: 5)
      while let question = quiz.currentQuestion {
        if let choice = question.choice {
          quiz.submitChoice(choice.rightIndex)
          quiz.continueAfterCorrection()
        } else {
          quiz.submitAnswer(question.correctAnswer)
        }
      }
      #expect(gameCenter.submissions.last?.score == Quiz.questionCount * Quiz.pointsPerCorrect)
    }
  }
}
