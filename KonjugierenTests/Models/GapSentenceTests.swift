// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

/// The machine check of Phase 18 of the pedagogy plan: no bundled sentence may teach a wrong
/// conjugation. Each test walks every sentence and records each failure with the sentence's id,
/// so that one run lists every draft that needs fixing.
@MainActor
@Suite("Gap sentences")
struct GapSentenceTests {
  static func sentence(_ id: String) throws -> GapSentence {
    try #require(GapSentences.all.first { $0.id == id })
  }

  /// A sentence written here rather than bundled, decoded as the bundle's are.
  static func sentence(verb: String, table: String, person: String?, german: String, reviewed: Bool = true) -> GapSentence {
    var json: [String: Any] = ["id": "\(verb).test.\(reviewed ? 1 : 2)", "verb": verb, "table": table, "de": german, "en": "English.", "reviewed": reviewed]
    json["person"] = person
    let data = (try? JSONSerialization.data(withJSONObject: [json])) ?? Data()
    return GapSentences.decode(data)[0]
  }


  @Test func theBundleHoldsTheSentences() {
    #expect(GapSentences.all.count >= 100)
  }

  @Test func everySentenceIsWellFormed() {
    var ids: Set<String> = []
    for sentence in GapSentences.all {
      let id = sentence.id
      if !ids.insert(id).inserted {
        Issue.record("\(id): the id is not unique")
      }
      if !id.hasPrefix("\(sentence.verb).") {
        Issue.record("\(id): the id does not begin with its verb")
      }
      guard let verb = Verb.verbs[sentence.verb] else {
        Issue.record("\(id): \(sentence.verb) is not in the corpus")
        continue
      }
      if !verb.isIn(.top300) {
        Issue.record("\(id): \(sentence.verb) is not among the 300 most frequent verbs")
      }
      if verb.reading(at: sentence.readingIndex) == nil {
        Issue.record("\(id): \(sentence.verb) has no reading \(sentence.readingIndex)")
      }
      if sentence.conjugationgroup == nil {
        Issue.record("\(id): \(sentence.table) and \(sentence.person ?? "no person") name no cell")
      }
      let opening = sentence.german.filter { $0 == "{" }.count
      let closing = sentence.german.filter { $0 == "}" }.count
      if opening != closing || opening != sentence.blankAnswers.count || !(1...2).contains(opening) {
        Issue.record("\(id): a sentence takes one or two well-formed blanks")
      }
      if sentence.blankAnswers.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty || $0.contains(" ") }) {
        Issue.record("\(id): each blank holds one word")
      }
      if !(sentence.german.last.map { ".!?".contains($0) } ?? false) || !(sentence.english.last.map { ".!?".contains($0) } ?? false) {
        Issue.record("\(id): both sentences end with . ! or ?")
      }
      if sentence.english.isEmpty || sentence.english.contains("{") {
        Issue.record("\(id): the English has no blanks")
      }
    }
  }

  /// The check the phase asks for: each sentence's braces, read in order, are the conjugator's
  /// conjugation of its cell, in the main clause's word order or the subordinate clause's. The
  /// same words must be right in every region, Swiss ss for ß aside, so that a sentence never shows
  /// an Austrian learner a German auxiliary (habe gestanden) as the answer.
  @Test func everyBlankIsTheConjugatorsConjugation() {
    for sentence in GapSentences.all {
      guard let conjugationgroup = sentence.conjugationgroup, Verb.verbs[sentence.verb] != nil else {
        continue
      }
      let answer = Self.folded(sentence.answer)
      for region in Region.allCases {
        let conjugations = Clause.allCases.map { clause in
          Self.folded(RegionalConjugator.conjugateUnsafely(infinitiv: sentence.verb, conjugationgroup: conjugationgroup, region: region, readingIndex: sentence.readingIndex, clause: clause))
        }
        if !conjugations.contains(answer) {
          Issue.record("\(sentence.id): the blanks give \"\(sentence.answer)\", but \(region) conjugates \(conjugations.joined(separator: " or "))")
        }
      }
    }
  }

  @Test func everySentenceIsAskedAtSomeLevel() {
    for sentence in GapSentences.all where !QuizLevel.allCases.contains(where: sentence.isAskable(at:)) {
      Issue.record("\(sentence.id): no level asks this verb in this cell")
    }
  }

  @Test func aWirOrSieImperativSuppliesItsPronoun() {
    for sentence in GapSentences.all {
      guard case .imperativ(let personNumber) = sentence.conjugationgroup, personNumber == .firstPlural || personNumber == .thirdPlural else {
        continue
      }
      let pronoun = personNumber == .firstPlural ? "wir" : "Sie"
      if !sentence.frame.segments.contains(.word(pronoun)) {
        Issue.record("\(sentence.id): \(pronoun) must follow the first blank")
      }
    }
  }

  /// The first batch, as Josh chose on 2026-11-15: the 25 most frequent verbs.
  @Test func theFirstBatchCoversTheTwentyFiveMostFrequentVerbs() {
    let covered = Set(GapSentences.all.map(\.verb))
    for verb in Verb.verbsSortedByFrequency.prefix(25) where !covered.contains(verb.infinitiv) {
      Issue.record("\(verb.infinitiv) has no sentence")
    }
  }

  private static func folded(_ text: String) -> String {
    text.lowercased().replacingOccurrences(of: "ß", with: "ss")
  }


  @Test func thePerfektTakesTwoBlanksAroundTheSentence() throws {
    let sentence = try Self.sentence("gehen.perfekt.1")
    #expect(sentence.frame == AnswerFrame(segments: [.context("Gestern "), .blank, .context(" wir ins Kino "), .blank, .context(".")]))
    #expect(sentence.frame.sentenceTokens == [.word("Gestern"), .blank(index: 0, trailing: ""), .word("wir"), .word("ins"), .word("Kino"), .blank(index: 1, trailing: ".")])
    #expect(sentence.answer == "sind gegangen")
    #expect(sentence.completed == "Gestern sind wir ins Kino gegangen.")
  }

  @Test func aSieImperativGivesItsSie() throws {
    let sentence = try Self.sentence("nehmen.imperativ.1")
    #expect(sentence.frame == AnswerFrame(segments: [.blank, .word("Sie"), .context(" bitte Platz!")]))
    #expect(sentence.frame.sentenceTokens.first == .blank(index: 0, trailing: ""))
    #expect(sentence.frame.sentenceTokens[1] == .answerWord("Sie"))
    #expect(sentence.answer == "Nehmen Sie")
  }

  @Test func aSeparableSieImperativKeepsItsSecondBlank() throws {
    let sentence = try Self.sentence("anfangen.imperativ.1")
    #expect(sentence.frame == AnswerFrame(segments: [.blank, .word("Sie"), .context(" bitte "), .blank, .context("!")]))
    #expect(sentence.answer == "Fangen Sie an")
  }

  @Test func aSieThatIsNotAnImperativIsPartOfTheSentence() {
    let sentence = Self.sentence(verb: "kommen", table: "praesens_indikativ", person: "tp", german: "{Kommen} Sie aus Berlin?")
    #expect(sentence.frame == AnswerFrame(segments: [.blank, .context(" Sie aus Berlin?")]))
  }

  @Test func aCommaAgainstABlankTravelsWithIt() {
    let sentence = Self.sentence(verb: "kommen", table: "praesens_indikativ", person: "ss", german: "Wenn du {kommst}, essen wir.")
    #expect(sentence.frame.sentenceTokens == [.word("Wenn"), .word("du"), .blank(index: 0, trailing: ","), .word("essen"), .word("wir.")])
  }

  @Test func anUnreadableCellIsNoCell() {
    #expect(Self.sentence(verb: "kommen", table: "praesens_indikativ", person: "xx", german: "{Kommt}.").conjugationgroup == nil)
    #expect(Self.sentence(verb: "kommen", table: "nonsense", person: "ts", german: "{Kommt}.").conjugationgroup == nil)
  }


  @Test func aSeparableVerbAfterWeilIsInTheSubordinateClause() throws {
    #expect(try Self.sentence("anfangen.praesens.1").clause == .main)
    #expect(try Self.sentence("anfangen.praesens.2").clause == .subordinate)
    #expect(try Self.sentence("gehen.perfekt.1").clause == .main)
  }

  @Test func aSentenceIsGradedInItsOwnWordOrder() throws {
    let quiz = Quiz()
    let subordinate = try #require(quiz.makeSentenceItem(try Self.sentence("anfangen.praesens.2")))
    #expect(subordinate.accepts("anfängt"))
    #expect(subordinate.accepts("anfaengt"))
    #expect(!subordinate.accepts("fängt an"))
    #expect(subordinate.correctAnswer.lowercased() == "anfängt")
    #expect(subordinate.difference(from: "fängt an").expected.lowercased() == "anfängt")

    let main = try #require(quiz.makeSentenceItem(try Self.sentence("anfangen.praesens.1")))
    #expect(main.accepts(main.answerFrame.answer(filling: ["fängt", "an"])))
    #expect(!main.accepts(main.answerFrame.answer(filling: ["anfängt", "x"])))

    let imperativ = try #require(quiz.makeSentenceItem(try Self.sentence("nehmen.imperativ.1")))
    #expect(imperativ.accepts(imperativ.answerFrame.answer(filling: ["Nehmen"])))
    #expect(imperativ.answerFrame.blankCount == 1)
  }

  @Test func theOneLineQuizStillTakesEitherOrder() throws {
    let verb = try #require(Verb.verbs["anfangen"])
    let item = Quiz().makeQuizItem(verb: verb, conjugationgroup: .präsensIndikativ(.thirdSingular))
    #expect(item.accepts("fängt an"))
    #expect(item.accepts("anfängt"))
    #expect(item.sentence == nil)
  }

  @Test func aSentenceItemAsksItsVerbAndCell() throws {
    let sentence = try Self.sentence("gehen.perfekt.1")
    let item = try #require(Quiz().makeSentenceItem(sentence))
    #expect(item.verb.infinitiv == "gehen")
    #expect(item.conjugationgroup == .perfektIndikativ(.firstPlural))
    #expect(item.answerFrame == sentence.frame)
    #expect(item.reasked().sentence == sentence)
  }


  @Test func aLevelAsksItsBandAndPool() throws {
    let beginner = GapSentences.askable(at: .beginner)
    #expect(!beginner.isEmpty)
    #expect(beginner.allSatisfy { sentence in
      sentence.table == "praesens_indikativ" || sentence.table == "imperativ"
    })
    // anfangen is #286, beyond Beginner's 100.
    #expect(!beginner.contains { $0.verb == "anfangen" })

    let elementary = GapSentences.askable(at: .elementary).map(\.id)
    #expect(elementary.contains("sein.praeteritum.1"))
    #expect(elementary.contains("anfangen.praesens.1"))
    #expect(!elementary.contains("machen.praeteritum.1"))

    let advanced = GapSentences.askable(at: .advanced)
    #expect(advanced.count == GapSentences.all.count)
  }

  @Test func aReleaseBuildAsksOnlyReviewedSentences() {
    let draft = Self.sentence(verb: "gehen", table: "perfekt_indikativ", person: "fp", german: "Gestern {sind} wir ins Kino {gegangen}.", reviewed: false)
    let reviewed = Self.sentence(verb: "gehen", table: "perfekt_indikativ", person: "fp", german: "Gestern {sind} wir ins Kino {gegangen}.")
    #expect(GapSentences.askable(at: .advanced, from: [draft, reviewed], includesDrafts: false) == [reviewed])
    #expect(GapSentences.askable(at: .advanced, from: [draft, reviewed], includesDrafts: true).count == 2)
  }


  @Test func aRoundAsksOneSentenceAVerbWhereItCan() {
    var generator = SeededRNG(seed: 3)
    let round = QuizDraw.sentences(from: GapSentences.all, count: 10, excluded: [], using: &generator)
    #expect(round.count == 10)
    #expect(Set(round.map(\.verb)).count == 10)
  }

  @Test func unaskedSentencesComeFirst() {
    var generator = SeededRNG(seed: 5)
    let pool = GapSentences.all.filter { $0.verb == "kommen" || $0.verb == "gehen" }
    let asked = Set(pool.prefix(pool.count - 3).map(\.id))
    let round = QuizDraw.sentences(from: pool, count: 3, excluded: asked, using: &generator)
    #expect(Set(round.map(\.id)) == Set(pool.suffix(3).map(\.id)))
  }

  @Test func aSmallPoolMakesAShortRoundAndThenRepeats() {
    var generator = SeededRNG(seed: 1)
    let pool = GapSentences.all.filter { $0.verb == "kommen" }
    let first = QuizDraw.sentences(from: pool, count: 10, excluded: [], using: &generator)
    #expect(first.count == pool.count)
    let again = QuizDraw.sentences(from: pool, count: 10, excluded: Set(pool.map(\.id)), using: &generator)
    #expect(Set(again.map(\.id)) == Set(pool.map(\.id)))
  }

  @Test func theScopeIsItsOwnMode() {
    let scope = QuizScope.sentences()
    #expect(scope.isSentences)
    #expect(scope.source == .sentences)
    #expect(scope.questionCount == Quiz.questionCount)
    #expect(scope.continues)
    #expect(!scope.isRanked)
    #expect(!scope.mixesDueItems)
    #expect(scope.sendsQuestionCounts)
    #expect(scope.asksByLevel)
    #expect(LastQuizResult.Kind(scope: scope) == .sentences)
  }
}

extension QuizTests {
  @MainActor
  @Suite("Sentence sessions")
  struct SentenceSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func started(level: QuizLevel = .elementary, seed: UInt64 = 7) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: seed))
      quiz.start(scope: .sentences())
      return quiz
    }

    private func rightAnswer(_ question: QuizItem) throws -> String {
      let sentence = try #require(question.sentence)
      return question.answerFrame.answer(filling: sentence.blankAnswers)
    }

    private var spy: AnalyticsSpy {
      Current.analytics as! AnalyticsSpy
    }

    @Test func aRoundAsksTenSentencesOfTheLevel() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started(level: .beginner)
      defer { quiz.quit() }

      #expect(quiz.questions.count == Quiz.questionCount)
      for question in quiz.questions {
        let sentence = try #require(question.sentence)
        #expect(sentence.isAskable(at: .beginner))
        #expect(question.answerFrame.isSentence)
        #expect(question.conjugationgroup == sentence.conjugationgroup)
      }
    }

    @Test func aRightAnswerScoresAndIsRecorded() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      defer { quiz.quit() }

      quiz.submitAnswer(try rightAnswer(try #require(quiz.currentQuestion)))
      #expect(quiz.score == Quiz.pointsPerCorrect)
      #expect(quiz.currentIndex == 1)
      #expect(!practice.record.entries.isEmpty)
    }

    @Test func aWrongAnswerHoldsItsCorrectionAndReturnsWithItsSentence() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let quiz = started()
      defer { quiz.quit() }
      let question = try #require(quiz.currentQuestion)

      quiz.submitAnswer("definitelywrong")
      #expect(quiz.correction != nil)
      let reask = quiz.questions[1 + Quiz.reaskGap]
      #expect(reask.isReask)
      #expect(reask.sentence == question.sentence)
    }

    @Test func aFinishedRoundSignalsItsSourceKeepsItsResultAndPostsNoScore() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let gameCenter = Current.gameCenter as! GameCenterSpy
      let submissions = gameCenter.submissions.count
      let before = spy.signalNames.count

      let quiz = started(level: .advanced)
      while let question = quiz.currentQuestion {
        quiz.submitAnswer(try rightAnswer(question))
      }

      #expect(quiz.score == Quiz.questionCount * Quiz.pointsPerCorrect)
      let signals = Array(zip(spy.signalNames, spy.signalParameters).dropFirst(before))
      let start = try #require(signals.first { $0.0 == .startQuiz })
      #expect(start.1[ParameterKey.source.rawValue] == "sentences")
      #expect(start.1[ParameterKey.level.rawValue] == "advanced")
      let complete = try #require(signals.first { $0.0 == .completeQuiz })
      #expect(complete.1[ParameterKey.questionCount.rawValue] == "10")
      #expect(gameCenter.submissions.count == submissions)
      #expect(practice.lastResult?.kind == .sentences)
      #expect(practice.lastResult?.level == .advanced)

      let firstRound = Set(quiz.questions.compactMap(\.sentence?.id))
      #expect(quiz.canContinue)
      quiz.continueSession()
      #expect(quiz.questions.count == 2 * Quiz.questionCount)
      let secondRound = quiz.questions.suffix(Quiz.questionCount).compactMap(\.sentence?.id)
      #expect(secondRound.count == Quiz.questionCount)
      #expect(firstRound.isDisjoint(with: secondRound))
      quiz.quit()
    }
  }
}
