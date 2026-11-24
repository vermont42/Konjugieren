// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

@Suite("Custom quiz")
@MainActor
struct CustomQuizTests {
  private static let customs: [CustomQuiz] = [
    CustomQuiz(),
    CustomQuiz(tables: [.präteritumIndikativ]),
    CustomQuiz(verbSet: .collection(.modals)),
    CustomQuiz(tables: Set(ConjugationTable.allCases), verbSet: .all),
    CustomQuiz(tables: [.imperativ, .futurKonjunktivI], verbSet: .band(.top1000)),
    CustomQuiz(tables: [.perfektpartizip], verbSet: .myVerbs),
    CustomQuiz(verbSet: .collection(.ablautGroup("singen")))
  ]

  private func verbs(_ infinitives: [String]) -> [Verb] {
    infinitives.map { Verb.verbs[$0]! }
  }

  private func draw(pool: [QuizPoolEntry], verbs: [Verb], relaxesRestrictions: Bool = false, seed: UInt64 = 7) -> [QuizDrawnQuestion] {
    var generator = SeededRNG(seed: seed)
    return QuizDraw.questions(pool: pool, verbs: verbs, readingIndex: nil, count: 200, distinctCells: false, relaxesRestrictions: relaxesRestrictions, using: &generator)
  }

  // The cases are looped rather than passed as arguments, which Swift Testing builds off the main
  // actor, where CustomQuiz's conformances are not available.
  @Test func aChoiceSurvivesItsStoredForm() {
    for custom in Self.customs {
      #expect(CustomQuiz(rawValue: custom.rawValue) == custom)
    }
  }

  // The stored form is permanent: it is kept between launches and carried in shared links.
  @Test func theStoredFormIsPinned() {
    let custom = CustomQuiz(tables: [.präteritumIndikativ, .präsensIndikativ], verbSet: .collection(.modals))
    #expect(custom.rawValue == "groups=praesens_indikativ,praeteritum_indikativ&verbs=modals")
    #expect(CustomQuiz().rawValue == "")
    #expect(CustomQuiz(rawValue: "") == CustomQuiz())
  }

  @Test(arguments: ConjugationTable.allCases)
  func everyTableHasAKey(table: ConjugationTable) {
    #expect(CustomQuiz(rawValue: CustomQuiz(tables: [table]).rawValue)?.tables == [table])
  }

  @Test func everyVerbSetHasAKey() {
    let verbSets: [QuizVerbSet] = FrequencyBand.allCases.map(QuizVerbSet.band) + [.all, .myVerbs, .collection(.modals), .collection(.sein)]
      + AblautGroupInfo.allGroups.map { .collection(.ablautGroup($0.exemplar)) }
    for verbSet in verbSets {
      #expect(QuizVerbSet(key: verbSet.key) == verbSet)
    }
    #expect(Set(verbSets.map(\.key)).count == verbSets.count)
  }

  @Test func theTop100CollectionReadsBackAsTheBand() {
    #expect(QuizVerbSet(key: VerbCollection.top100.key) == .band(.top100))
    #expect(Set(QuizVerbSet.band(.top100).verbs(myVerbs: []).map(\.infinitiv)) == Set(VerbCollection.top100.verbs().map(\.infinitiv)))
  }

  @Test func aKeyThatNamesNothingIsDropped() {
    let custom = CustomQuiz(rawValue: "groups=praesens_indikativ,bogus&verbs=ablaut-nonexistent")
    #expect(custom == CustomQuiz(tables: [.präsensIndikativ]))
  }

  @Test(arguments: QuizLevel.allCases)
  func noTablesAsksTheLevelsPool(level: QuizLevel) {
    #expect(CustomQuiz(verbSet: .collection(.modals)).pool(level: level) == level.pool)
  }

  @Test(arguments: QuizLevel.allCases)
  func chosenTablesAreAskedAtAnyLevel(level: QuizLevel) {
    let tables: Set<ConjugationTable> = [.präsensKonjunktivI, .imperativ, .präsenspartizip]
    let pool = CustomQuiz(tables: tables).pool(level: level)
    #expect(Set(pool.map(\.table)) == tables)
    // Advanced's kinds, the fullest: the wir Imperativ too.
    #expect(pool.first { $0.table == .imperativ }?.cells == ConjugationTable.imperativ.cells)
  }

  @Test func aBeginnerCustomDrawAsksOnlyTheChosenTables() {
    let pool = CustomQuiz(tables: [.plusquamperfektKonjunktivII, .präsenspartizip]).pool(level: .beginner)
    let cells = Set(ConjugationTable.plusquamperfektKonjunktivII.cells + ConjugationTable.präsenspartizip.cells)
    let questions = draw(pool: pool, verbs: Quiz.defaultVerbs(for: .beginner))
    #expect(questions.count == 200)
    #expect(questions.allSatisfy { cells.contains($0.conjugationgroup) })
    #expect(Set(questions.map(\.conjugationgroup.table)) == [.plusquamperfektKonjunktivII, .präsenspartizip])
  }

  // Präteritum Konjunktiv II is asked of strong and mixed readings, but a custom quiz of weak verbs
  // alone asks it of them rather than asking nothing.
  @Test func aChosenRestrictedTableFallsBackToEveryVerb() {
    let pool = CustomQuiz(tables: [.präteritumKonjunktivII]).pool(level: .beginner)
    let weak = verbs(["machen", "sagen", "spielen"])
    #expect(draw(pool: pool, verbs: weak).isEmpty)
    let relaxed = draw(pool: pool, verbs: weak, relaxesRestrictions: true)
    #expect(relaxed.count == 200)
    #expect(relaxed.allSatisfy { $0.conjugationgroup.table == .präteritumKonjunktivII })
  }

  @Test func theRestrictionHoldsWhereAVerbFitsIt() {
    let pool = CustomQuiz(tables: [.präteritumKonjunktivII]).pool(level: .beginner)
    let questions = draw(pool: pool, verbs: verbs(["machen", "sagen", "singen"]), relaxesRestrictions: true)
    #expect(questions.allSatisfy { $0.verb.infinitiv == "singen" })
  }

  @Test func aCustomScopeNeverRanksAndAlwaysContinues() {
    for custom in Self.customs where !custom.isEmpty {
      let scope = QuizScope.custom(custom, myVerbs: verbs(["gehen"]))
      #expect(!scope.isRanked)
      #expect(scope.continues)
      #expect(scope.source == .custom)
      #expect(scope.questionCount == Quiz.questionCount)
    }
  }

  /// A nil key is the level's verbs.
  @Test(arguments: zip(
    [nil, "all", "top300", "modals", "myVerbs"],
    [true, true, true, false, false]
  ))
  func onlyUnlistedVerbsAreMixed(verbSetKey: String?, mixes: Bool) {
    let custom = CustomQuiz(tables: [.präsensIndikativ], verbSet: verbSetKey.flatMap(QuizVerbSet.init(key:)))
    #expect(QuizScope.custom(custom, myVerbs: verbs(["gehen"])).mixesVerbs == mixes)
  }

  @Test func aCustomScopesVerbsAreItsSets() {
    let myVerbs = verbs(["gehen", "machen"])
    #expect(QuizScope.custom(CustomQuiz(tables: [.präsensIndikativ]), myVerbs: myVerbs).verbs == nil)
    #expect(QuizScope.custom(CustomQuiz(verbSet: .myVerbs), myVerbs: myVerbs).verbs?.map(\.infinitiv) == ["gehen", "machen"])
    #expect(QuizScope.custom(CustomQuiz(verbSet: .band(.top300)), myVerbs: myVerbs).verbs?.count == 300)
    #expect(QuizScope.custom(CustomQuiz(verbSet: .all), myVerbs: myVerbs).verbs?.count == Verb.verbs.count)
    let modals = QuizScope.custom(CustomQuiz(verbSet: .collection(.modals)), myVerbs: myVerbs)
    #expect(Set(modals.verbs?.map(\.infinitiv) ?? []) == VerbCollection.modalInfinitives)
    #expect(modals.collectionKey == "modals")
  }

  @Test func startQuizSaysWhatKindOfChoice() {
    #expect(CustomQuiz(tables: [.imperativ]).choiceParameter == "conjugationgroups")
    #expect(CustomQuiz(verbSet: .all).choiceParameter == "verbs")
    #expect(CustomQuiz(tables: [.imperativ], verbSet: .all).choiceParameter == "both")
  }

  @Test func theChoiceIsKeptBetweenLaunches() {
    let fake = GetterSetterFake()
    let settings = Settings(getterSetter: fake)
    #expect(settings.customQuiz == CustomQuiz())
    let custom = CustomQuiz(tables: [.perfektIndikativ], verbSet: .collection(.sein))
    settings.customQuiz = custom
    #expect(fake.get(key: Settings.customQuizKey) == custom.rawValue)
    #expect(Settings(getterSetter: fake).customQuiz == custom)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Custom quiz sessions")
  struct CustomQuizSessionTests {
    private func startedQuiz(_ custom: CustomQuiz, level: QuizLevel = .beginner) -> Quiz {
      Current.settings.quizLevel = level
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 11))
      quiz.start(scope: .custom(custom, myVerbs: []))
      return quiz
    }

    @Test func aSessionAsksOnlyItsChoice() {
      let quiz = startedQuiz(CustomQuiz(tables: [.präteritumIndikativ], verbSet: .collection(.modals)))
      #expect(quiz.questions.count == Quiz.questionCount)
      #expect(quiz.questions.allSatisfy { $0.conjugationgroup.table == .präteritumIndikativ })
      #expect(quiz.questions.allSatisfy { VerbCollection.modalInfinitives.contains($0.verb.infinitiv) })
      quiz.quit()
    }

    @Test func tablesAloneAskTheLevelsBand() {
      let quiz = startedQuiz(CustomQuiz(tables: [.futurKonjunktivI]))
      #expect(quiz.questions.allSatisfy { $0.conjugationgroup.table == .futurKonjunktivI && $0.verb.isIn(.top100) })
      quiz.quit()
    }

    @Test func aVerbSetAloneAsksTheLevelsTables() {
      let quiz = startedQuiz(CustomQuiz(verbSet: .collection(.ablautGroup("singen"))))
      let beginnerTables = Set(QuizLevel.beginner.pool.map(\.table))
      #expect(quiz.questions.allSatisfy { beginnerTables.contains($0.conjugationgroup.table) && $0.verb.ablautGroup == "singen" })
      quiz.quit()
    }

    @Test func aCustomSessionPostsNoScore() {
      let spy = Current.gameCenter as! GameCenterSpy
      let before = spy.submissions.count
      let quiz = startedQuiz(CustomQuiz(tables: [.präsensIndikativ]))
      while quiz.isInProgress {
        quiz.submitAnswer(quiz.currentQuestion!.correctAnswer)
      }
      #expect(quiz.shouldShowResults)
      #expect(quiz.canContinue)
      #expect(spy.submissions.count == before)
    }

    @Test func startQuizNamesTheCustomSource() {
      let spy = Current.analytics as! AnalyticsSpy
      let before = spy.signalNames.count
      let quiz = startedQuiz(CustomQuiz(tables: [.imperativ], verbSet: .collection(.modals)))
      let signals = Array(zip(spy.signalNames, spy.signalParameters).dropFirst(before))
      let start = signals.first { $0.0 == .startQuiz }?.1
      #expect(start?[ParameterKey.source.rawValue] == "custom")
      #expect(start?[ParameterKey.customChoice.rawValue] == "both")
      #expect(start?[ParameterKey.collection.rawValue] == "modals")
      quiz.quit()
    }
  }
}
