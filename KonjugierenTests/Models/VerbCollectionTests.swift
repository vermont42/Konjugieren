// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
struct VerbCollectionTests {
  // A parameterized test evaluates its arguments off the main actor, where AblautGroupInfo's
  // groups, isolated by the module's default, cannot be read. So these tests loop instead.
  private var allCollections: [VerbCollection] {
    VerbCollection.featured + AblautGroupInfo.allGroups.map { VerbCollection.ablautGroup($0.exemplar) }
  }

  @Test func everyKeyRoundTrips() {
    for collection in allCollections {
      #expect(VerbCollection(key: collection.key) == collection, "\(collection.key)")
    }
  }

  @Test(arguments: ["", "top99", "ablaut-", "ablaut-nope", "Modals"])
  func unknownKeyFindsNothing(key: String) {
    #expect(VerbCollection(key: key) == nil)
  }

  @Test func everyCollectionHasVerbs() {
    for collection in allCollections {
      #expect(!collection.verbs(region: .north).isEmpty, "\(collection.key)")
    }
  }

  @Test func modalsAreTheSixModalVerbs() {
    let infinitives = Set(VerbCollection.modals.verbs(region: .north).map(\.infinitiv))
    #expect(infinitives == ["dürfen", "können", "mögen", "müssen", "sollen", "wollen"])
  }

  @Test func top100IsTheBand() {
    let verbs = VerbCollection.top100.verbs(region: .north)
    #expect(verbs.count == FrequencyBand.top100.verbCount)
    #expect(verbs.allSatisfy { $0.isIn(.top100) })
  }

  @Test func verbsArriveAlphabetically() {
    let verbs = VerbCollection.top100.verbs(region: .north)
    let expected = Verb.verbsSortedAlphabetically.filter { $0.isIn(.top100) }
    #expect(verbs.map(\.infinitiv) == expected.map(\.infinitiv))
  }

  @Test func everyAblautGroupMatchesTheAblautPage() {
    for group in AblautGroupInfo.allGroups {
      let verbs = VerbCollection.ablautGroup(group.exemplar).verbs(region: .north)
      #expect(verbs.map(\.infinitiv) == group.verbs.map(\.infinitiv), "\(group.exemplar)")
    }
  }

  @Test(arguments: ["gehen", "kommen", "werden", "fahren"])
  func seinHoldsVerbsThatTakeSein(infinitiv: String) {
    let infinitives = VerbCollection.sein.verbs(region: .north).map(\.infinitiv)
    #expect(infinitives.contains(infinitiv))
  }

  @Test(arguments: ["machen", "haben", "sagen"])
  func seinLeavesOutVerbsThatTakeHaben(infinitiv: String) {
    let infinitives = VerbCollection.sein.verbs(region: .north).map(\.infinitiv)
    #expect(!infinitives.contains(infinitiv))
  }

  @Test(arguments: zip([Region.north, .austria, .switzerland], [false, true, true]))
  func seinFollowsTheRegionForRegionalVerbs(region: Region, includesLiegen: Bool) {
    let infinitives = VerbCollection.sein.verbs(region: region).map(\.infinitiv)
    #expect(infinitives.contains("liegen") == includesLiegen)
  }

  @Test func deeplinkNamesTheCollectionAndSharedLink() throws {
    let url = try #require(VerbCollection.ablautGroup("hängen").deeplink)
    #expect(url.host == URL.listHost)
    #expect(url.pathComponents.last == "ablaut-hängen")
    #expect(url.analyticsSource == .sharedLink)
  }

  @Test func shareTextCarriesBothLinksAndStartsWithTheMostFrequentVerb() throws {
    let text = VerbCollection.modals.shareText(region: .north)
    let link = try #require(VerbCollection.modals.deeplink)
    let mostFrequent = try #require(VerbCollection.modals.verbs(region: .north).min { $0.frequency < $1.frequency })
    #expect(text.contains(link.absoluteString))
    #expect(text.contains(URL.appStore.absoluteString))
    #expect(text.contains("(6 verbs): \(mostFrequent.infinitiv),"))
    #expect(!text.contains("…"))
  }

  @Test func shareTextOfALongListSaysThereIsMore() {
    #expect(VerbCollection.top100.shareText(region: .north).contains(" …"))
  }

  @Test func quizScopeAsksAboutTheCollectionUnranked() {
    let scope = QuizScope.collection(.modals)
    #expect(Set(scope.verbs?.map(\.infinitiv) ?? []) == VerbCollection.modalInfinitives)
    #expect(scope.source == .list)
    #expect(scope.collectionKey == "modals")
    #expect(scope.questionCount == Quiz.questionCount)
    #expect(scope.title == VerbCollection.modals.title)
    #expect(!scope.isRanked)
  }

  @Test func storeCountsOpenedVerbs() throws {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let verbs = VerbCollection.modals.verbs(region: .north)
    let können = try #require(Verb.verbs["können"])
    let müssen = try #require(Verb.verbs["müssen"])
    store.recordOpen(können, source: .browse)
    store.toggleStar(müssen)
    #expect(store.openedCount(of: verbs) == 1)
    #expect(store.hasOpened(können))
    #expect(!store.hasOpened(müssen))
  }
}
