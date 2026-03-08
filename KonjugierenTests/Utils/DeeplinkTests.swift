// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@Suite("Deeplinks", .serialized)
@MainActor
struct DeeplinkTests {
  init() {
    Current.verb = nil
    Current.family = nil
    Current.info = nil
  }

  @Test func isDeeplink() {
    let valid = URL(string: "konjugieren://verb/machen")!
    #expect(valid.isDeeplink == true)

    let invalid = URL(string: "https://example.com/verb/machen")!
    #expect(invalid.isDeeplink == false)
  }

  @Test func hasExpectedNumberOfDeeplinkComponents() {
    let valid = URL(string: "konjugieren://verb/machen")!
    #expect(valid.hasExpectedNumberOfDeeplinkComponents == true)

    let tooFew = URL(string: "konjugieren://verb")!
    #expect(tooFew.hasExpectedNumberOfDeeplinkComponents == false)

    let tooMany = URL(string: "konjugieren://verb/machen/extra")!
    #expect(tooMany.hasExpectedNumberOfDeeplinkComponents == false)
  }

  @Test func handleURLVerbDeeplink() {
    let url = URL(string: "konjugieren://verb/machen")!
    Current.handleURL(url)
    #expect(Current.verb?.infinitiv == "machen")
    #expect(Current.family == nil)
    #expect(Current.info == nil)
  }

  @Test func handleURLVerbDeeplinkUnknownVerb() {
    let url = URL(string: "konjugieren://verb/nonexistent")!
    Current.handleURL(url)
    #expect(Current.verb == nil)
  }

  @Test func handleURLInfoDeeplink() {
    let url = URL(string: "konjugieren://info/0")!
    Current.handleURL(url)
    #expect(Current.info != nil)
    #expect(Current.info?.heading == Info.infos[0].heading)
    #expect(Current.verb == nil)
  }

  @Test func handleURLInfoDeeplinkOutOfBounds() {
    let url = URL(string: "konjugieren://info/99999")!
    Current.handleURL(url)
    #expect(Current.info == nil)
  }

  @Test func handleURLFamilyDeeplink() {
    let url = URL(string: "konjugieren://family/strong")!
    Current.handleURL(url)
    #expect(Current.family == "strong")
    #expect(Current.verb == nil)
    #expect(Current.info == nil)
  }

  @Test func handleURLInvalidScheme() {
    let url = URL(string: "https://verb/machen")!
    Current.handleURL(url)
    #expect(Current.verb == nil)
    #expect(Current.family == nil)
    #expect(Current.info == nil)
  }

  @Test func handleURLUnknownHost() {
    let url = URL(string: "konjugieren://unknown/test")!
    Current.handleURL(url)
    #expect(Current.verb == nil)
    #expect(Current.family == nil)
    #expect(Current.info == nil)
  }

  @Test func handleURLClearsPreviousState() {
    let verbURL = URL(string: "konjugieren://verb/machen")!
    Current.handleURL(verbURL)
    #expect(Current.verb != nil)

    let infoURL = URL(string: "konjugieren://info/0")!
    Current.handleURL(infoURL)
    #expect(Current.verb == nil)
    #expect(Current.info != nil)
  }

  @Test func handleUserActivityValidVerb() {
    let activity = NSUserActivity(activityType: World.viewVerbActivityType)
    activity.userInfo = ["infinitiv": "machen"]
    Current.handleUserActivity(activity)
    #expect(Current.verb?.infinitiv == "machen")
  }

  @Test func handleUserActivityUnknownVerb() {
    let activity = NSUserActivity(activityType: World.viewVerbActivityType)
    activity.userInfo = ["infinitiv": "nonexistent"]
    Current.handleUserActivity(activity)
    #expect(Current.verb == nil)
  }

  @Test func handleUserActivityMissingInfinitiv() {
    let activity = NSUserActivity(activityType: World.viewVerbActivityType)
    activity.userInfo = [:]
    Current.handleUserActivity(activity)
    #expect(Current.verb == nil)
    #expect(Current.family == nil)
    #expect(Current.info == nil)
  }

  @Test func handleUserActivityWrongType() {
    let activity = NSUserActivity(activityType: "com.example.wrongType")
    activity.userInfo = ["infinitiv": "machen"]
    Current.handleUserActivity(activity)
    #expect(Current.verb == nil)
  }

  @Test func handleURLQuizDeeplink() {
    let url = URL(string: "konjugieren://quiz/start")!
    Current.handleURL(url)
    #expect(Current.selectedTab == .quiz)
    #expect(Current.verb == nil)
    #expect(Current.family == nil)
    #expect(Current.info == nil)
  }

  @Test func handleURLRandomVerbDeeplink() {
    let url = URL(string: "konjugieren://verb/random")!
    Current.handleURL(url)
    #expect(Current.verb != nil)
    #expect(Current.selectedTab == .verbs)
  }

  @Test func handleURLRandomVerbDeeplinkIsDifferent() {
    var infinitivs: Set<String> = []
    for _ in 0..<20 {
      let url = URL(string: "konjugieren://verb/random")!
      Current.handleURL(url)
      if let v = Current.verb { infinitivs.insert(v.infinitiv) }
    }
    #expect(infinitivs.count > 1)
  }

  @Test func handleUserActivityClearsPreviousState() {
    Current.verb = Verb.verbs["machen"]
    Current.family = "strong"
    Current.info = Info.infos[0]
    #expect(Current.verb != nil)
    #expect(Current.family != nil)
    #expect(Current.info != nil)

    let activity = NSUserActivity(activityType: World.viewVerbActivityType)
    activity.userInfo = ["infinitiv": "gehen"]
    Current.handleUserActivity(activity)
    #expect(Current.verb?.infinitiv == "gehen")
    #expect(Current.family == nil)
    #expect(Current.info == nil)
  }
}
