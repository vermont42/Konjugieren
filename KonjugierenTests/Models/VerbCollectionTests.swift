// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

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

  // The title received the exemplar as stored, so the quiz sheet and the share text kept the ß.
  @Test func ablautGroupTitleFollowsTheRegion() {
    Current.settings.region = .switzerland
    defer { Current.settings.region = .north }
    let title = VerbCollection.ablautGroup("schließen").title

    #expect(title.contains("schliessen"), "\(title)")
    #expect(!title.contains("ß"), "\(title)")
  }

  @Test func progressCountsOpenedVerbsOfTheCollection() {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    for infinitiv in ["können", "sollen", "machen"] {
      if let verb = Verb.verbs[infinitiv] {
        store.recordOpen(verb)
      }
    }
    let progress = VerbCollectionProgress(.modals, learnerVerbs: store)

    #expect(progress == VerbCollectionProgress(opened: 2, total: 6))
    #expect(progress.count == "2/6")
    #expect(progress.text == L.VerbCollection.progress(opened: 2, total: 6))
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

  @Test func viewSignalNamesTheCollection() {
    let spy = Current.analytics as! AnalyticsSpy
    let initialCount = spy.signalNames.count
    VerbCollection.ablautGroup("gehen").signalView(source: .family)
    #expect(Array(spy.signalNames.dropFirst(initialCount)) == [.viewCollection])
    #expect(spy.signalParameters.last == [
      ParameterKey.collection.rawValue: "ablaut-gehen",
      ParameterKey.source.rawValue: "family"
    ])
  }

  @Test func viewSignalFromACorrectionNamesNoCollection() {
    let spy = Current.analytics as! AnalyticsSpy
    let initialCount = spy.signalNames.count
    VerbCollection.ablautGroup("gehen").signalView(source: .quizCorrection)
    #expect(Array(spy.signalNames.dropFirst(initialCount)) == [.viewCollection])
    #expect(spy.signalParameters.last == [ParameterKey.source.rawValue: "quizCorrection"])
  }

  @Test func storeCountsOpenedVerbs() throws {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let verbs = VerbCollection.modals.verbs(region: .north)
    let können = try #require(Verb.verbs["können"])
    let müssen = try #require(Verb.verbs["müssen"])
    store.recordOpen(können)
    store.toggleStar(müssen)
    #expect(store.openedCount(of: verbs) == 1)
    #expect(store.hasOpened(können))
    #expect(!store.hasOpened(müssen))
  }
}
