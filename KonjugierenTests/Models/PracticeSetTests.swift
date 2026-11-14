// Copyright © 2026 Josh Adams. All rights reserved.

import CoreImage
import Foundation
import Testing
import UIKit
@testable import Konjugieren

@Suite("Practice sets")
@MainActor
struct PracticeSetTests {
  private static let lists: [QuizVerbSet] = [
    .list(["gehen", "hängen", "grüßen", "fühlen"]),
    .list(["sein"]),
  ]

  private static let sets: [PracticeSet] = [
    PracticeSet(custom: CustomQuiz(tables: [.präteritumIndikativ]), level: .beginner),
    PracticeSet(custom: CustomQuiz(verbSet: .collection(.modals)), level: .advanced),
    PracticeSet(custom: CustomQuiz(tables: Set(ConjugationTable.allCases), verbSet: .all), level: nil),
    PracticeSet(custom: CustomQuiz(tables: [.imperativ, .futurKonjunktivI], verbSet: .band(.top1000)), level: nil),
    PracticeSet(custom: CustomQuiz(tables: [.perfektpartizip], verbSet: lists[0]), level: nil),
    PracticeSet(custom: CustomQuiz(verbSet: lists[1]), level: .intermediate),
    PracticeSet(custom: CustomQuiz(verbSet: .collection(.ablautGroup("hängen"))), level: .elementary),
  ]

  private func verbs(_ infinitives: [String]) -> [Verb] {
    infinitives.map { Verb.verbs[$0]! }
  }

  private func url(_ string: String) -> URL {
    URL(string: string)!
  }

  // Shared links outlive the version that made them, so their form is permanent.
  @Test func theLinkIsPinned() {
    let set = PracticeSet(custom: CustomQuiz(tables: [.präteritumIndikativ, .imperativ], verbSet: .collection(.modals)), level: nil)
    #expect(set.deeplink(source: .sharedLink)?.absoluteString == "konjugieren://quiz/set?groups=praeteritum_indikativ,imperativ&verbs=modals&source=sharedLink")
    let list = PracticeSet(custom: CustomQuiz(verbSet: .list(["gehen", "hängen"])), level: .beginner)
    #expect(list.deeplink(source: .qrCode)?.absoluteString == "konjugieren://quiz/set?infinitives=gehen,h%C3%A4ngen&level=beginner&source=qrCode")
  }

  // Looped rather than passed as arguments, since Swift Testing builds arguments off the main
  // actor, where PracticeSet's conformances are not available.
  @Test func everySetSurvivesItsLink() throws {
    for set in Self.sets {
      for source in [AnalyticsSource.sharedLink, .qrCode] {
        let link = try #require(set.deeplink(source: source))
        #expect(PracticeSet(url: link) == set)
        #expect(link.analyticsSource == source)
      }
    }
  }

  @Test(arguments: ConjugationTable.allCases)
  func everyTableSurvivesALink(table: ConjugationTable) throws {
    let set = PracticeSet(custom: CustomQuiz(tables: [table]), level: .advanced)
    #expect(PracticeSet(url: try #require(set.deeplink(source: .sharedLink)))?.custom.tables == [table])
  }

  @Test func everyVerbSetSurvivesALink() throws {
    let verbSets: [QuizVerbSet] = FrequencyBand.allCases.map(QuizVerbSet.band) + [.all, .collection(.modals), .collection(.sein)]
      + AblautGroupInfo.allGroups.map { .collection(.ablautGroup($0.exemplar)) } + Self.lists
    for verbSet in verbSets {
      let set = PracticeSet(custom: CustomQuiz(verbSet: verbSet), level: .beginner)
      #expect(PracticeSet(url: try #require(set.deeplink(source: .sharedLink)))?.custom.verbSet == verbSet)
    }
  }

  @Test func aListIsStoredApartFromTheSetKeys() {
    let custom = CustomQuiz(tables: [.präsensIndikativ], verbSet: .list(["sein", "gehen"]))
    #expect(custom.rawValue == "groups=praesens_indikativ&infinitives=sein,gehen")
    #expect(CustomQuiz(rawValue: custom.rawValue) == custom)
    // An infinitive that equals a collection's key stays a verb.
    #expect(CustomQuiz(rawValue: "infinitives=sein")?.verbSet == .list(["sein"]))
    #expect(CustomQuiz(rawValue: "verbs=sein")?.verbSet == .collection(.sein))
  }

  @Test func aListDropsUnknownAndRepeatedVerbs() {
    #expect(QuizVerbSet(infinitives: ["gehen", "xyzzy", "gehen", "kommen"]) == .list(["gehen", "kommen"]))
    #expect(QuizVerbSet(infinitives: ["xyzzy"]) == nil)
    #expect(QuizVerbSet(infinitives: []) == nil)
  }

  @Test func aListAsksItsVerbsInOrder() {
    let verbSet = QuizVerbSet.list(["kommen", "gehen"])
    #expect(verbSet.verbs(myVerbs: []).map(\.infinitiv) == ["kommen", "gehen"])
    #expect(!verbSet.mixesVerbs)
    #expect(verbSet.collectionKey == nil)
  }

  @Test func sharingMyVerbsCarriesTheVerbs() {
    let set = PracticeSet(sharing: CustomQuiz(tables: [.imperativ], verbSet: .myVerbs), level: .beginner, myVerbs: verbs(["machen", "gehen"]))
    #expect(set.custom.verbSet == .list(["machen", "gehen"]))
    #expect(set.level == nil)
  }

  @Test func aSharedListIsCapped() {
    let many = Verb.verbs.values.sorted { $0.infinitiv < $1.infinitiv }.prefix(150)
    let set = PracticeSet(sharing: CustomQuiz(verbSet: .myVerbs), level: .beginner, myVerbs: Array(many))
    guard case .list(let infinitives) = set.custom.verbSet else {
      Issue.record("Expected a list")
      return
    }
    #expect(infinitives.count == PracticeSet.maximumListCount)
    #expect(infinitives == many.prefix(PracticeSet.maximumListCount).map(\.infinitiv))
  }

  @Test func sharingAnEmptyMyVerbsLeavesTheVerbsToTheLevel() {
    let set = PracticeSet(sharing: CustomQuiz(tables: [.imperativ], verbSet: .myVerbs), level: .intermediate, myVerbs: [])
    #expect(set.custom.verbSet == nil)
    #expect(set.level == .intermediate)
  }

  @Test func theLevelTravelsOnlyWhileAPartIsLeftToIt() {
    let both = PracticeSet(sharing: CustomQuiz(tables: [.imperativ], verbSet: .all), level: .beginner, myVerbs: [])
    let tables = PracticeSet(sharing: CustomQuiz(tables: [.imperativ]), level: .beginner, myVerbs: [])
    let verbSet = PracticeSet(sharing: CustomQuiz(verbSet: .all), level: .beginner, myVerbs: [])
    #expect(both.level == nil)
    #expect(tables.level == .beginner)
    #expect(verbSet.level == .beginner)
  }

  @Test(arguments: [
    "konjugieren://quiz/set",
    "konjugieren://quiz/set?source=sharedLink",
    "konjugieren://quiz/set?groups=bogus&verbs=nothing",
    "konjugieren://quiz/set?verbs=myVerbs",
    "konjugieren://quiz/set?infinitives=xyzzy,plugh",
    "konjugieren://quiz/start?groups=imperativ",
    "konjugieren://verb/set?groups=imperativ",
    "konjugieren://quiz/set/extra?groups=imperativ",
    "https://example.com/quiz/set?groups=imperativ",
  ])
  func aLinkThatNamesNothingIsNoSet(string: String) {
    #expect(PracticeSet(url: url(string)) == nil)
  }

  @Test func aLinkKeepsWhatItCanRead() {
    let set = PracticeSet(url: url("konjugieren://quiz/set?groups=imperativ,bogus&verbs=ablaut-nonexistent&level=expert"))
    #expect(set == PracticeSet(custom: CustomQuiz(tables: [.imperativ]), level: nil))
  }

  @Test func aLinkNamingMyVerbsDropsThatPart() {
    let set = PracticeSet(url: url("konjugieren://quiz/set?groups=imperativ&verbs=myVerbs"))
    #expect(set == PracticeSet(custom: CustomQuiz(tables: [.imperativ]), level: nil))
  }

  @Test func aSetsScopeIsUnrankedAndCarriesItsLevel() {
    for set in Self.sets {
      let scope = set.scope(source: .qrCode)
      #expect(!scope.isRanked)
      #expect(scope.continues)
      #expect(scope.questionCount == Quiz.questionCount)
      #expect(scope.source == .qrCode)
      #expect(scope.level == set.level)
      #expect(scope.custom == set.custom)
    }
  }

  @Test func aListSetsScopeAsksItsVerbs() {
    let scope = PracticeSet(custom: CustomQuiz(verbSet: .list(["gehen", "hängen"])), level: .beginner).scope(source: .sharedLink)
    #expect(scope.verbs?.map(\.infinitiv) == ["gehen", "hängen"])
    #expect(!scope.mixesVerbs)
  }

  @Test func theShareTextCarriesBothLinks() throws {
    let set = PracticeSet(custom: CustomQuiz(tables: [.präteritumIndikativ], verbSet: .collection(.modals)), level: nil)
    let text = set.shareText(lang: .german, levelFallback: .beginner)
    let link = try #require(set.deeplink(source: .sharedLink))
    #expect(text.contains(link.absoluteString))
    #expect(text.contains(URL.appStore.absoluteString))
    #expect(text.contains(VerbCollection.modals.title))
  }

  @Test func theQRCodeReadsBackAsTheLink() throws {
    let set = PracticeSet(custom: CustomQuiz(tables: [.imperativ], verbSet: .list(["gehen", "hängen", "grüßen"])), level: nil)
    let link = try #require(set.deeplink(source: .qrCode)).absoluteString
    let image = try #require(QRCode.image(for: link))
    let ciImage = try #require(CIImage(image: image))
    let detector = try #require(CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]))
    let messages = detector.features(in: ciImage).compactMap { ($0 as? CIQRCodeFeature)?.messageString }
    #expect(messages == [link])
  }

  // A hundred long infinitives, the most a shared list carries, still fit a code.
  @Test func theLongestListFitsACode() {
    let longest = Verb.verbs.keys.sorted { $0.utf8.count > $1.utf8.count }.prefix(PracticeSet.maximumListCount)
    let set = PracticeSet(custom: CustomQuiz(tables: Set(ConjugationTable.allCases), verbSet: .list(Array(longest))), level: nil)
    let link = set.deeplink(source: .qrCode)?.absoluteString ?? ""
    #expect(QRCode.image(for: link) != nil)
  }

  @Test func aKeptListIsKeptBetweenLaunches() {
    let fake = GetterSetterFake()
    let settings = Settings(getterSetter: fake)
    let custom = CustomQuiz(tables: [.perfektIndikativ], verbSet: .list(["gehen", "hängen"]))
    settings.customQuiz = custom
    #expect(Settings(getterSetter: fake).customQuiz == custom)
  }
}

extension DeeplinkTests {
  @Test func aPracticeSetLinkShowsTheSetWithoutChangingTab() throws {
    let set = PracticeSet(custom: CustomQuiz(tables: [.imperativ], verbSet: .collection(.modals)), level: nil)
    Current.handleURL(try #require(set.deeplink(source: .qrCode)))
    #expect(Current.practiceSet?.practiceSet == set)
    #expect(Current.practiceSet?.source == .qrCode)
    #expect(Current.selectedTab == .settings)
  }

  @Test func aPracticeSetLinkThatNamesNothingShowsTheFailure() {
    Current.handleURL(URL(string: "konjugieren://quiz/set?groups=bogus")!)
    #expect(Current.practiceSet != nil)
    #expect(Current.practiceSet?.practiceSet == nil)
    #expect(Current.practiceSet?.source == .deeplink)
  }

  @Test func theQuizStartLinkStillOpensTheQuizTab() {
    Current.handleURL(URL(string: "konjugieren://quiz/start")!)
    #expect(Current.selectedTab == .quiz)
    #expect(Current.practiceSet == nil)
  }

  @Test func aLaterLinkReplacesAPracticeSet() {
    Current.handleURL(URL(string: "konjugieren://quiz/set?groups=imperativ")!)
    Current.handleURL(URL(string: "konjugieren://verb/gehen")!)
    #expect(Current.practiceSet == nil)
    #expect(Current.verb?.infinitiv == "gehen")
  }
}

// Nested in QuizTests so that its .serialized trait keeps these from racing it over Current.
extension QuizTests {
  @MainActor
  @Suite("Practice set sessions")
  struct PracticeSetSessionTests {
    @Test func aSessionAsksAtTheSetsLevel() {
      Current.settings.quizLevel = .advanced
      let set = PracticeSet(custom: CustomQuiz(tables: [.präsensIndikativ]), level: .beginner)
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 5))
      quiz.start(scope: set.scope(source: .sharedLink))
      #expect(quiz.level == .beginner)
      #expect(quiz.questions.allSatisfy { $0.conjugationgroup.table == .präsensIndikativ && $0.verb.isIn(.top100) })
      #expect(Current.settings.quizLevel == .advanced)
      quiz.quit()
    }

    @Test func startQuizNamesTheLinkAndTheSetsLevel() {
      Current.settings.quizLevel = .advanced
      let spy = Current.analytics as! AnalyticsSpy
      let before = spy.signalNames.count
      let set = PracticeSet(custom: CustomQuiz(verbSet: .collection(.modals)), level: .elementary)
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 5))
      quiz.start(scope: set.scope(source: .qrCode))
      let signals = Array(zip(spy.signalNames, spy.signalParameters).dropFirst(before))
      let start = signals.first { $0.0 == .startQuiz }?.1
      #expect(start?[ParameterKey.source.rawValue] == "qrCode")
      #expect(start?[ParameterKey.level.rawValue] == "elementary")
      #expect(start?[ParameterKey.customChoice.rawValue] == "verbs")
      #expect(start?[ParameterKey.collection.rawValue] == "modals")
      quiz.quit()
    }

    @Test func aSetsSessionPostsNoScore() {
      let spy = Current.gameCenter as! GameCenterSpy
      let before = spy.submissions.count
      let set = PracticeSet(custom: CustomQuiz(tables: [.präsensIndikativ]), level: .beginner)
      let quiz = Quiz(timerInterval: 0.001, randomSource: SeededRNG(seed: 5))
      quiz.start(scope: set.scope(source: .sharedLink))
      while quiz.isInProgress {
        quiz.submitAnswer(quiz.currentQuestion!.correctAnswer)
      }
      #expect(quiz.canContinue)
      #expect(spy.submissions.count == before)
    }
  }
}
