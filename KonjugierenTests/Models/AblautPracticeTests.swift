// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("Ablaut Practice")
struct AblautPracticeTests {
  private let calendar = Calendar.current
  private let now = Date(timeIntervalSince1970: 1_800_000_000)

  private func group(_ exemplar: String) throws -> AblautPracticeGroup {
    try #require(AblautPracticeGroup.group(exemplar))
  }

  /// One item for each of the group's key conjugations: its first asked reading's.
  private func items(of group: AblautPracticeGroup) -> [PracticeItem] {
    group.keyConjugations.compactMap(\.first)
  }

  /// A record in which the first `count` of the items have each been answered right once, which
  /// moves a new item past the first box.
  private func record(answeringRight items: [PracticeItem], count: Int? = nil) -> PracticeRecord {
    var record = PracticeRecord()
    for item in items.prefix(count ?? items.count) {
      record.recordAnswer(item, isCorrect: true, at: now, calendar: calendar)
    }
    return record
  }

  /// A group made of the corpus's verbs, for drawing mixes without depending on which verbs an
  /// ablaut group holds.
  private func madeGroup(_ exemplar: String, _ verbs: [Verb]) -> AblautPracticeGroup {
    AblautPracticeGroup(exemplar: exemplar, members: verbs.map { AblautPracticeGroup.Member(verb: $0, readingIndices: [0]) })
  }

  private func infinitives(_ steps: [[QuizDrawnQuestion]]) -> [String] {
    steps.compactMap { $0.first?.verb.infinitiv }
  }

  @Test func aLargeGroupIsItsTenMostFrequentVerbs() throws {
    let bleiben = try group("bleiben")
    let all = VerbCollection.ablautGroup("bleiben").verbs().sorted(by: .frequency)

    #expect(all.count > AblautPracticeGroup.verbLimit)
    #expect(bleiben.verbs == Array(all.prefix(AblautPracticeGroup.verbLimit)))
    #expect(bleiben.verbs.first?.infinitiv == "bleiben")
  }

  @Test func aSmallGroupIsAllOfItsVerbsMostFrequentFirst() throws {
    let singen = try group("singen")
    let all = VerbCollection.ablautGroup("singen").verbs()

    #expect(all.count < AblautPracticeGroup.verbLimit)
    #expect(Set(singen.verbs) == Set(all))
    #expect(singen.verbs.map(\.frequency) == singen.verbs.map(\.frequency).sorted())
  }

  @Test func everyGroupOfTheAblautPageHasItsPracticeGroup() {
    #expect(AblautPracticeGroup.all.map(\.exemplar) == AblautGroupInfo.allGroups.map(\.exemplar))
    #expect(AblautPracticeGroup.all.allSatisfy { !$0.members.isEmpty && $0.members.count <= AblautPracticeGroup.verbLimit })
  }

  /// One verb is not a pattern (Josh, 2026-11-13).
  @Test func theSingleVerbGroupsOfferNoPracticeAlone() throws {
    let single = AblautPracticeGroup.all.filter { !$0.offersPracticeAlone }

    #expect(single.count == 18)
    #expect(single.allSatisfy { $0.members.count == 1 })
    #expect(Set(single.map(\.exemplar)).isSuperset(of: ["sein", "essen", "wissen"]))
    #expect(try group("singen").offersPracticeAlone)
    #expect(try group("werfen").offersPracticeAlone)
  }

  /// fahren drives with haben and travels with sein, and both readings follow the pattern. hängen
  /// is strong when something hangs and weak when someone hangs it, and hängte is not the pattern.
  @Test func aMemberIsAskedOnlyItsReadingsOfTheGroup() throws {
    let fahren = try #require(try group("fahren").members.first { $0.verb.infinitiv == "fahren" })
    let hängen = try #require(try group("hängen").members.first { $0.verb.infinitiv == "hängen" })

    #expect(fahren.readingIndices == [0, 1])
    #expect(hängen.readingIndices == [0])
  }

  @Test func aGroupHasThreeKeyConjugationsAVerbEachWithItsReadingsItems() throws {
    let singen = try group("singen")
    let fahren = try group("fahren")

    for group in [singen, fahren] {
      #expect(group.keyConjugations.count == group.members.count * 3)
      #expect(Set(group.keyConjugations.flatMap { $0 }.map(\.key)).count == group.members.map(\.readingIndices.count).reduce(0, +) * 3)
    }
    #expect(singen.keyConjugations.contains([.keyConjugation(infinitiv: "singen", readingIndex: 0, stem: .präteritum)]))
    #expect(fahren.keyConjugations.contains([
      .keyConjugation(infinitiv: "fahren", readingIndex: 0, stem: .perfekt),
      .keyConjugation(infinitiv: "fahren", readingIndex: 1, stem: .perfekt)
    ]))
  }

  /// fahren's group is ten verbs, and fahren has two readings in it. A round asks one reading of
  /// each of five verbs, and that must be enough, whichever reading it was.
  @Test func oneRoundOfFiveVerbsAnsweredRightMakesAGroupOfTenKnown() throws {
    let fahren = try group("fahren")
    #expect(fahren.members.count == AblautPracticeGroup.verbLimit)
    let asked = fahren.members.prefix(5).flatMap { member in
      PracticeItem.Stem.allCases.map { stem in
        PracticeItem.keyConjugation(infinitiv: member.verb.infinitiv, readingIndex: member.readingIndices.last ?? 0, stem: stem)
      }
    }

    #expect(fahren.isKnown(in: record(answeringRight: asked)))
    #expect(!fahren.isKnown(in: record(answeringRight: asked, count: 14)))
  }

  /// Both readings of a key conjugation past the first box count once, not twice.
  @Test func aKeyConjugationRightInBothReadingsCountsOnce() throws {
    let fahren = try group("fahren")
    let twice = fahren.keyConjugations.filter { $0.count == 2 }
    let once = fahren.keyConjugations.filter { $0.count == 1 }.compactMap(\.first)
    #expect(twice.count >= 3)
    let needed = (fahren.keyConjugations.count + 1) / 2 - twice.count
    let both = twice.flatMap { $0 }

    #expect(!fahren.isKnown(in: record(answeringRight: both + Array(once.prefix(needed - 1)))))
    #expect(fahren.isKnown(in: record(answeringRight: both + Array(once.prefix(needed)))))
  }

  @Test func aGroupIsKnownOnceHalfOfItsItemsArePastTheFirstBox() throws {
    let singen = try group("singen")
    let half = (singen.keyConjugations.count + 1) / 2

    #expect(!singen.isKnown(in: PracticeRecord()))
    #expect(!singen.isKnown(in: record(answeringRight: items(of: singen), count: half - 1)))
    #expect(singen.isKnown(in: record(answeringRight: items(of: singen), count: half)))
    #expect(singen.isKnown(in: record(answeringRight: items(of: singen))))
  }

  /// A group of an odd number of items needs the larger half: two of a single verb's three.
  @Test func aSingleVerbGroupIsKnownOnceTwoOfItsThreeItemsHaveClimbed() throws {
    let essen = try group("essen")

    #expect(essen.keyConjugations.count == 3)
    #expect(!essen.isKnown(in: record(answeringRight: items(of: essen), count: 1)))
    #expect(essen.isKnown(in: record(answeringRight: items(of: essen), count: 2)))
  }

  @Test func wrongAnswersAndLookupsLeaveItemsInTheFirstBox() throws {
    let singen = try group("singen")
    var wrong = PracticeRecord()
    var lookedUp = PracticeRecord()
    for item in items(of: singen) {
      wrong.recordAnswer(item, isCorrect: false, at: now, calendar: calendar)
    }
    lookedUp.recordLookup(items(of: singen), at: now, calendar: calendar)

    #expect(!singen.isKnown(in: wrong))
    #expect(!singen.isKnown(in: lookedUp))
  }

  /// A wrong answer starts an item over, so a group at exactly half stops being known.
  @Test func aWrongAnswerCanMakeAKnownGroupUnknownAgain() throws {
    let singen = try group("singen")
    let half = (singen.keyConjugations.count + 1) / 2
    var record = record(answeringRight: items(of: singen), count: half)
    #expect(singen.isKnown(in: record))

    record.recordAnswer(items(of: singen)[0], isCorrect: false, at: now.addingTimeInterval(60), calendar: calendar)

    #expect(!singen.isKnown(in: record))
  }

  @Test func theKnownGroupsAreInThePagesOrderAndIncludeSingleVerbGroups() throws {
    let singen = try group("singen")
    let essen = try group("essen")
    let bleiben = try group("bleiben")
    let record = record(answeringRight: items(of: singen) + items(of: essen) + Array(items(of: bleiben).prefix(3)))

    #expect(AblautPracticeGroup.known(in: record).map(\.exemplar) == ["essen", "singen"])
    #expect(AblautPracticeGroup.known(in: PracticeRecord()).isEmpty)
  }

  /// Mixed opens for a group once another group is known, whether or not the group itself is
  /// (Josh, 2026-11-15).
  @Test func aGroupsMixPartnersAreTheOtherKnownGroups() throws {
    let singen = try group("singen")
    let bleiben = try group("bleiben")
    let record = record(answeringRight: items(of: singen))

    #expect(singen.mixPartners(in: record).isEmpty)
    #expect(bleiben.mixPartners(in: record).map(\.exemplar) == ["singen"])
    #expect(!bleiben.isKnown(in: record))
  }

  @Test func practiceAloneDrawsFiveDistinctVerbsOfTheGroupInItsReadings() throws {
    let fahren = try group("fahren")
    var generator = SeededRNG(seed: 4)

    let steps = QuizDraw.ablautPracticeSteps(for: AblautPracticeSession(exemplar: "fahren", mode: .alone), record: PracticeRecord(), using: &generator)

    #expect(steps.count == QuizScope.verbEssentialsVerbCount)
    #expect(Set(infinitives(steps)).count == steps.count)
    for step in steps {
      let member = try #require(fahren.members.first { $0.verb == step[0].verb })
      #expect(step.map(\.conjugationgroup) == VerbEssentialsTests.keyCells)
      #expect(step.allSatisfy { member.readingIndices.contains($0.readingIndex) })
    }
  }

  @Test func aGroupOfTwoVerbsMakesARoundOfTwo() throws {
    let werfen = try group("werfen")
    var generator = SeededRNG(seed: 4)

    let steps = QuizDraw.ablautPracticeSteps(for: AblautPracticeSession(exemplar: "werfen", mode: .alone), record: PracticeRecord(), using: &generator)

    #expect(werfen.members.count == 2)
    #expect(Set(infinitives(steps)) == Set(werfen.verbs.map(\.infinitiv)))
  }

  @Test func anotherRoundAsksTheGroupsUnaskedVerbsFirst() throws {
    let singen = try group("singen")
    let asked = singen.members.prefix(5)
    let excluded = Set(asked.flatMap { PracticeItem.keyConjugations(of: $0.verb) }.map(\.key))
    var generator = SeededRNG(seed: 8)

    let steps = QuizDraw.ablautPracticeSteps(for: AblautPracticeSession(exemplar: "singen", mode: .alone), record: PracticeRecord(), excluded: excluded, using: &generator)

    let fresh = Set(singen.members.dropFirst(5).map(\.verb.infinitiv))
    #expect(Set(infinitives(steps).prefix(fresh.count)) == fresh)
    #expect(steps.count == QuizScope.verbEssentialsVerbCount)
  }

  /// Three of a mixed round's five verbs are the group's own (Josh, 2026-11-15).
  @Test func aMixedRoundIsThreeVerbsOfTheGroupAndTwoOfThePartners() {
    let verbs = VerbEssentialsTests.strongVerbs(30)
    let own = madeGroup("own", Array(verbs[0..<10]))
    let partners = [madeGroup("first", Array(verbs[10..<20])), madeGroup("second", Array(verbs[20..<30]))]

    for seed in UInt64(1)...20 {
      var generator = SeededRNG(seed: seed)
      let drawn = infinitives(QuizDraw.ablautMixSteps(group: own, partners: partners, count: 5, groupCount: QuizDraw.ablautMixGroupVerbCount, using: &generator))

      #expect(drawn.count == 5)
      #expect(Set(drawn).count == 5)
      #expect(drawn.filter { own.verbs.map(\.infinitiv).contains($0) }.count == 3)
    }
    #expect(QuizDraw.ablautMixGroupVerbCount == 3)
  }

  /// One verb from each partner in turn, so that a partner of ten verbs does not crowd out a
  /// partner of one.
  @Test func thePartnersVerbsAreDrawnOneGroupAtATime() {
    let verbs = VerbEssentialsTests.strongVerbs(23)
    let own = madeGroup("own", Array(verbs[0..<10]))
    let large = madeGroup("large", Array(verbs[10..<20]))
    let singles = (20..<23).map { madeGroup("single\($0)", [verbs[$0]]) }

    for seed in UInt64(1)...20 {
      var generator = SeededRNG(seed: seed)
      let three = infinitives(QuizDraw.ablautMixSteps(group: own, partners: [large, singles[0], singles[1]], count: 5, groupCount: 2, using: &generator))
      #expect(three.contains(verbs[20].infinitiv))
      #expect(three.contains(verbs[21].infinitiv))
      #expect(three.filter { large.verbs.map(\.infinitiv).contains($0) }.count == 1)

      let four = infinitives(QuizDraw.ablautMixSteps(group: own, partners: [large] + singles, count: 5, groupCount: 2, using: &generator))
      #expect(four.filter { large.verbs.map(\.infinitiv).contains($0) }.count <= 1)
    }
  }

  @Test func whicheverSideIsShortLeavesTheRestToTheOther() {
    let verbs = VerbEssentialsTests.strongVerbs(13)
    let ten = madeGroup("ten", Array(verbs[0..<10]))
    let two = madeGroup("two", Array(verbs[10..<12]))
    let one = madeGroup("one", [verbs[12]])
    var generator = SeededRNG(seed: 6)

    // The only partner has one verb, so the group gives four.
    let shortPartners = infinitives(QuizDraw.ablautMixSteps(group: ten, partners: [one], count: 5, groupCount: 2, using: &generator))
    #expect(shortPartners.count == 5)
    #expect(shortPartners.contains(verbs[12].infinitiv))

    // A group of one verb cannot give two, so the partners give four.
    let shortGroup = infinitives(QuizDraw.ablautMixSteps(group: one, partners: [ten], count: 5, groupCount: 2, using: &generator))
    #expect(shortGroup.count == 5)
    #expect(shortGroup.contains(verbs[12].infinitiv))

    // Three verbs in all make a round of three.
    let shortBoth = infinitives(QuizDraw.ablautMixSteps(group: two, partners: [one], count: 5, groupCount: 2, using: &generator))
    #expect(Set(shortBoth) == Set(verbs[10..<13].map(\.infinitiv)))

    // With no partner the round is the group's alone, though the card does not offer it.
    let alone = infinitives(QuizDraw.ablautMixSteps(group: ten, partners: [], count: 5, groupCount: 2, using: &generator))
    #expect(Set(alone).isSubset(of: Set(ten.verbs.map(\.infinitiv))))
    #expect(alone.count == 5)
  }

  @Test func aMixedRoundAsksUnaskedVerbsFirstOnEachSide() {
    let verbs = VerbEssentialsTests.strongVerbs(20)
    let own = madeGroup("own", Array(verbs[0..<10]))
    let partner = madeGroup("partner", Array(verbs[10..<20]))
    let asked = Array(verbs[0..<8]) + Array(verbs[10..<17])
    let excluded = Set(asked.flatMap(PracticeItem.keyConjugations(of:)).map(\.key))
    var generator = SeededRNG(seed: 12)

    let drawn = Set(infinitives(QuizDraw.ablautMixSteps(group: own, partners: [partner], count: 5, groupCount: 2, excluded: excluded, using: &generator)))

    #expect(drawn == Set((verbs[8..<10] + verbs[17..<20]).map(\.infinitiv)))
  }

  @Test func aMixedSessionDrawsItsPartnersFromTheRecord() throws {
    let singen = try group("singen")
    let bleiben = try group("bleiben")
    let record = record(answeringRight: items(of: singen))
    var generator = SeededRNG(seed: 2)

    let drawn = infinitives(QuizDraw.ablautPracticeSteps(for: AblautPracticeSession(exemplar: "bleiben", mode: .mixed), record: record, using: &generator))

    #expect(drawn.count == 5)
    #expect(drawn.filter { bleiben.verbs.map(\.infinitiv).contains($0) }.count == 3)
    #expect(drawn.filter { singen.verbs.map(\.infinitiv).contains($0) }.count == 2)
  }

  @Test func theScopesAreVerbEssentialsOverTheGroupAndNeverRanked() throws {
    let alone = QuizScope.ablautPractice(AblautPracticeSession(exemplar: "singen", mode: .alone))
    let mixed = QuizScope.ablautPractice(AblautPracticeSession(exemplar: "singen", mode: .mixed))
    let singen = try group("singen")

    for scope in [alone, mixed] {
      #expect(scope.isVerbEssentials)
      #expect(!scope.isRanked)
      #expect(!scope.mixesDueItems)
      #expect(scope.continues)
      #expect(!scope.asksByLevel)
      #expect(scope.collectionKey == "ablaut-singen")
      #expect(scope.verbs == singen.verbs)
    }
    #expect(alone.source == .ablautAlone)
    #expect(mixed.source == .ablautMixed)
    #expect(alone.title == VerbCollection.ablautGroup("singen").title)
    #expect(mixed.title == L.AblautPractice.mixedTitle("singen"))
    #expect(LastQuizResult.Kind(scope: alone) == .ablautAlone)
    #expect(LastQuizResult.Kind(scope: mixed) == .ablautMixed)
    #expect(QuizScope.verbEssentials().asksByLevel)
    #expect(QuizScope.verbEssentials().ablautPractice == nil)
  }

  /// A mixed round's length can depend on which groups are known, which comes from the learner's
  /// answers, so it sends no counts.
  @Test func onlyAMixedSessionWithholdsItsQuestionCounts() {
    #expect(QuizScope.ablautPractice(AblautPracticeSession(exemplar: "singen", mode: .alone)).sendsQuestionCounts)
    #expect(!QuizScope.ablautPractice(AblautPracticeSession(exemplar: "singen", mode: .mixed)).sendsQuestionCounts)
  }

  @Test func theLastResultNamesTheGroupInBothModes() {
    let alone = LastQuizResult(kind: .ablautAlone, subject: "ablaut-singen", level: nil, score: 150, correctCount: 15, secondAttemptCount: 0, questionCount: 15, date: now)
    let mixed = LastQuizResult(kind: .ablautMixed, subject: "ablaut-singen", level: nil, score: 150, correctCount: 15, secondAttemptCount: 0, questionCount: 15, date: now)
    let lost = LastQuizResult(kind: .ablautMixed, subject: "ablaut-nichts", level: nil, score: 0, correctCount: 0, secondAttemptCount: 0, questionCount: 15, date: now)

    #expect(alone.title == VerbCollection.ablautGroup("singen").title)
    #expect(mixed.title == L.AblautPractice.mixedTitle("singen"))
    #expect(lost.title == L.AblautPractice.title)
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Ablaut practice sessions")
  struct AblautPracticeSessionTests {
    private func freshPractice() -> PracticeStore {
      let practice = PracticeStore(getterSetter: GetterSetterFake())
      Current.practice = practice
      return practice
    }

    private func started(_ exemplar: String, _ mode: AblautPracticeSession.Mode, seed: UInt64 = 3) -> Quiz {
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: seed))
      quiz.start(scope: .ablautPractice(AblautPracticeSession(exemplar: exemplar, mode: mode)))
      return quiz
    }

    private func finish(_ quiz: Quiz, correctly: Bool) throws {
      while quiz.isInProgress {
        let question = try #require(quiz.currentQuestion)
        quiz.submitAnswer(correctly ? question.correctAnswer : "definitelywrong")
        if quiz.correction != nil {
          quiz.continueAfterCorrection()
        }
      }
    }

    private var spy: AnalyticsSpy {
      Current.analytics as! AnalyticsSpy
    }

    private func signals(since count: Int) -> [(AnalyticsName, [String: String])] {
      Array(zip(spy.signalNames, spy.signalParameters).dropFirst(count))
    }

    /// Ablaut practice end to end in one session: a group practiced alone becomes known, and
    /// then another group's mix draws on it.
    @Test func aGroupPracticedAloneBecomesKnownAndJoinsAnotherGroupsMix() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let singen = try #require(AblautPracticeGroup.group("singen"))
      let bleiben = try #require(AblautPracticeGroup.group("bleiben"))
      #expect(bleiben.mixPartners(in: practice.record).isEmpty)

      let alone = started("singen", .alone)
      #expect(alone.questions.count == 15)
      #expect(alone.questions.allSatisfy { singen.verbs.contains($0.verb) && $0.stepID != nil })
      try finish(alone, correctly: true)

      // A round moves fifteen of the group's twenty-four key conjugations past the first box.
      #expect(singen.keyConjugations.count == 24)
      #expect(singen.isKnown(in: practice.record))
      #expect(bleiben.mixPartners(in: practice.record).map(\.exemplar) == ["singen"])

      let mixed = started("bleiben", .mixed)
      defer { mixed.quit() }
      let verbs = Set(mixed.questions.map(\.verb))
      #expect(verbs.count == 5)
      #expect(verbs.filter { bleiben.verbs.contains($0) }.count == 3)
      #expect(verbs.filter { singen.verbs.contains($0) }.count == 2)
    }

    @Test func aRoundAnsweredWrongLeavesTheGroupUnknown() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let singen = try #require(AblautPracticeGroup.group("singen"))

      try finish(started("singen", .alone), correctly: false)

      #expect(!singen.isKnown(in: practice.record))
    }

    @Test func anotherRoundAsksTheRestOfTheGroupFirst() throws {
      _ = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let singen = try #require(AblautPracticeGroup.group("singen"))
      let quiz = started("singen", .alone)
      try finish(quiz, correctly: true)
      #expect(quiz.canContinue)
      let firstRound = Set(quiz.questions.map(\.verb.infinitiv))

      quiz.continueSession()
      defer { quiz.quit() }

      let secondRound = quiz.questions.dropFirst(15).map(\.verb.infinitiv)
      let fresh = Set(singen.verbs.map(\.infinitiv)).subtracting(firstRound)
      #expect(fresh.count == 3)
      #expect(Set(secondRound.prefix(9)) == fresh)
    }

    @Test func practiceAloneSignalsItsGroupAndKeepsItsResultWithoutALevel() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let gameCenter = Current.gameCenter as! GameCenterSpy
      let submissions = gameCenter.submissions.count
      let before = spy.signalNames.count

      try finish(started("singen", .alone), correctly: true)

      let signals = signals(since: before)
      let start = try #require(signals.first { $0.0 == .startQuiz })
      #expect(start.1[ParameterKey.source.rawValue] == "ablautAlone")
      #expect(start.1[ParameterKey.collection.rawValue] == "ablaut-singen")
      let complete = try #require(signals.first { $0.0 == .completeQuiz })
      #expect(complete.1[ParameterKey.questionCount.rawValue] == "15")
      #expect(gameCenter.submissions.count == submissions)
      #expect(practice.lastResult?.kind == .ablautAlone)
      #expect(practice.lastResult?.subject == "ablaut-singen")
      #expect(practice.lastResult?.level == nil)
      #expect(practice.lastResult?.questionCount == 15)
    }

    @Test func aMixedSessionSignalsNoCounts() throws {
      let practice = freshPractice()
      defer { Current.practice = PracticeStore(getterSetter: GetterSetterFake()) }
      let singen = try #require(AblautPracticeGroup.group("singen"))
      for member in singen.members {
        for cell in VerbEssentialsTests.keyCells {
          practice.recordAnswer(verb: member.verb, conjugationgroup: cell, readingIndex: member.readingIndices[0], isCorrect: true)
        }
      }
      #expect(singen.isKnown(in: practice.record))
      let before = spy.signalNames.count

      let quit = started("bleiben", .mixed)
      quit.quit()
      try finish(started("bleiben", .mixed), correctly: true)

      let signals = signals(since: before)
      let start = try #require(signals.first { $0.0 == .startQuiz })
      #expect(start.1[ParameterKey.source.rawValue] == "ablautMixed")
      let quitSignal = try #require(signals.first { $0.0 == .quitQuiz })
      #expect(quitSignal.1[ParameterKey.questionNumber.rawValue] == nil)
      let complete = try #require(signals.first { $0.0 == .completeQuiz })
      #expect(complete.1[ParameterKey.questionCount.rawValue] == nil)
      #expect(practice.lastResult?.kind == .ablautMixed)
    }
  }
}
