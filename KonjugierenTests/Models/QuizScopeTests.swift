// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

// Nested in QuizTests so that its .serialized trait keeps the quizzes these start from racing it
// over Current.
extension QuizTests {
  @MainActor
  @Suite("Scopes")
  struct ScopeTests {
    init() {
      Current.settings.region = .north
    }

    /// Every scope the app can start, each built as the app builds it.
    private func everyScope() throws -> [(kind: LastQuizResult.Kind, scope: QuizScope)] {
      let gehen = try #require(Verb.verbs["gehen"])
      let custom = CustomQuiz(tables: [.präsensIndikativ])
      let practiceSet = PracticeSet(custom: custom, level: .beginner)
      return [
        (.ablautAlone, .ablautPractice(AblautPracticeSession(exemplar: "singen", mode: .alone))),
        (.ablautMixed, .ablautPractice(AblautPracticeSession(exemplar: "singen", mode: .mixed))),
        (.allVerbs, .allVerbs),
        (.challenge, .challenge(DailyChallenge.Key(day: "2026-11-26", level: .intermediate))),
        (.collection, .collection(.modals)),
        (.custom, .custom(custom, myVerbs: [gehen])),
        (.daily, .daily()),
        (.mistakes, .recordSession(.mistakes)),
        (.myVerbs, .myVerbs([gehen])),
        (.practiceSet, practiceSet.scope(source: .sharedLink)),
        (.recognition, .recognition()),
        (.review, .recordSession(.review)),
        (.sentences, .sentences()),
        (.speedRound, .speedRound()),
        (.verbEssentials, .verbEssentials()),
        (.verbPage, .verbPage(gehen, readingIndex: 0))
      ]
    }

    @Test func onlyTheDefaultQuizIsRankedOrMixesAnythingIn() throws {
      let scopes = try everyScope()
      #expect(Set(scopes.map(\.kind)).count == scopes.count)
      for (kind, scope) in scopes {
        let isDefault = kind == .allVerbs
        #expect(scope.isRanked == isDefault, "\(kind)")
        #expect(scope.mixesDueItems == isDefault, "\(kind)")
        #expect(scope.mixesChoiceQuestions == isDefault, "\(kind)")
      }
    }

    @Test func onlyTestMeHidesTheVerbLink() throws {
      for (kind, scope) in try everyScope() {
        #expect(scope.showsVerbLink == (kind != .verbPage), "\(kind)")
      }
    }

    @Test func eachScopeIsRememberedAsItsKind() throws {
      for (kind, scope) in try everyScope() {
        #expect(LastQuizResult.Kind(scope: scope) == kind)
      }
    }

    // A link's source is any value `AnalyticsSource` has, so konjugieren://quiz/practiceSet with
    // source=verbPage once hid a practice set's verb links and was remembered as a verb's quiz.
    @Test func aLinksSourceDecidesNothingButAnalytics() {
      let practiceSet = PracticeSet(custom: CustomQuiz(tables: [.präsensIndikativ]), level: .beginner)
      for source in [AnalyticsSource.custom, .verbPage] {
        let scope = practiceSet.scope(source: source)
        #expect(scope.showsVerbLink, "\(source)")
        #expect(LastQuizResult.Kind(scope: scope) == .practiceSet, "\(source)")
        #expect(!scope.isRanked, "\(source)")
      }
      #expect(QuizScope.daily(source: .verbPage).showsVerbLink)
      #expect(QuizScope.challenge(DailyChallenge.Key(day: "2026-11-26", level: .beginner), source: .verbPage).showsVerbLink)
    }

    @Test func theSeinVerbsAdmitOnlyTheirSeinReadings() throws {
      let fahren = try #require(Verb.verbs["fahren"])
      let liegen = try #require(Verb.verbs["liegen"])
      #expect(fahren.readings.map { VerbCollection.sein.admits($0, region: .north) } == fahren.readings.map { $0.auxiliary == .sein })
      #expect(Set(fahren.readings.map(\.auxiliary)) == [.haben, .sein])
      #expect(!VerbCollection.sein.admits(liegen.primaryReading, region: .north))
      #expect(VerbCollection.sein.admits(liegen.primaryReading, region: .switzerland))
    }

    // hängen, schaffen, and weichen are the corpus's verbs whose primary reading is in a group
    // and whose other reading is weak.
    @Test func anAblautGroupAdmitsOnlyItsOwnReadings() throws {
      for infinitiv in ["hängen", "schaffen"] {
        let verb = try #require(Verb.verbs[infinitiv])
        let group = VerbCollection.ablautGroup(try #require(verb.ablautGroup))
        #expect(group.contains(verb))
        #expect(verb.readings.map { group.admits($0) } == [true, false], "\(infinitiv)")
      }
    }

    @Test func aModalOrFrequentVerbAdmitsEveryReading() throws {
      let hängen = try #require(Verb.verbs["hängen"])
      #expect(hängen.readings.allSatisfy { VerbCollection.top100.admits($0) && VerbCollection.modals.admits($0) })
      #expect(hängen.readings.allSatisfy { QuizScope.allVerbs.admits($0) })
    }

    @Test func everyQuizOverTheSeinVerbsAsksOnlySeinReadings() throws {
      let fahren = try #require(Verb.verbs["fahren"])
      let haben = try #require(fahren.readings.first { $0.auxiliary == .haben })
      let sein = CustomQuiz(verbSet: .collection(.sein))
      #expect(!QuizScope.collection(.sein).admits(haben))
      #expect(!QuizScope.custom(sein, myVerbs: []).admits(haben))
      #expect(!PracticeSet(custom: sein, level: .beginner).scope(source: .sharedLink).admits(haben))
    }

    // fahren alone, so that each question has even odds of its haben reading if the draw
    // ignores the collection: 1 in 2^100 of passing by chance.
    @Test func theSeinCollectionsQuizNeverAsksAHabenReading() throws {
      let fahren = try #require(Verb.verbs["fahren"])
      let scope = QuizScope(kind: .collection, verbs: [fahren], readingIndex: nil, questionCount: Quiz.questionCount, source: .list, collection: .sein)
      Current.settings.quizLevel = .intermediate
      var asked = 0
      for seed in UInt64(1)...10 {
        let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: seed))
        quiz.start(scope: scope)
        for question in quiz.questions {
          let reading = try #require(fahren.reading(at: question.readingIndex))
          #expect(reading.auxiliary == .sein, "seed \(seed): \(question.conjugationgroup)")
          asked += 1
        }
        quiz.quit()
      }
      #expect(asked == 10 * Quiz.questionCount)
    }
  }
}
