// Copyright © 2026 Josh Adams. All rights reserved.

import Observation
import UIKit

@MainActor var Current = World.chooseWorld()

@MainActor
@Observable
class World {
  var settings: Settings
  var gameCenter: GameCenter
  let getterSetter: GetterSetter
  var languageModelService: LanguageModelService
  var reviewPrompter: ReviewPrompter
  var soundPlayer: SoundPlayer
  var utterer: Utterer
  var fatalError: FatalError
  var analytics: Analytics
  var session: URLSession
  var verb: Verb?
  var verbSource: AnalyticsSource = .deeplink
  var verbMarks: MarkedConjugations?
  var family: String?
  var info: Info?
  var searchRequest: SearchRequest?
  var selectedTab: TabSelection = .verbs
  var shouldNavigateToTutor = false

  init(settings: Settings, gameCenter: GameCenter, getterSetter: GetterSetter, languageModelService: LanguageModelService, reviewPrompter: ReviewPrompter, soundPlayer: SoundPlayer, utterer: Utterer, fatalError: FatalError, analytics: Analytics, session: URLSession) {
    self.settings = settings
    self.gameCenter = gameCenter
    self.getterSetter = getterSetter
    self.languageModelService = languageModelService
    self.reviewPrompter = reviewPrompter
    self.soundPlayer = soundPlayer
    self.utterer = utterer
    self.fatalError = fatalError
    self.analytics = analytics
    self.session = session
  }

  nonisolated static let isRunningUnitTests = NSClassFromString("XCTestCase") != nil

  static func chooseWorld() -> World {
    isRunningUnitTests ? World.unitTest : World.real
  }

  static let real: World = {
    let getterSetter = GetterSetterReal()
    let settings = Settings(getterSetter: getterSetter)
    return World(settings: settings, gameCenter: GameCenterReal(), getterSetter: getterSetter, languageModelService: LanguageModelServiceReal(), reviewPrompter: ReviewPrompterReal(settings: settings), soundPlayer: SoundPlayerReal(), utterer: UttererReal(), fatalError: FatalErrorReal(), analytics: AnalyticsReal(), session: .shared)
  }()

  static let unitTest: World = {
    let getterSetter = GetterSetterFake()
    let settings = Settings(getterSetter: getterSetter)
    return World(settings: settings, gameCenter: GameCenterDummy(), getterSetter: getterSetter, languageModelService: LanguageModelServiceDummy(), reviewPrompter: ReviewPrompterDummy(), soundPlayer: SoundPlayerDummy(), utterer: UttererDummy(), fatalError: FatalErrorSpy(), analytics: AnalyticsSpy(), session: .stubSession(ratingsCount: 1))
  }()

  static let viewVerbActivityType = "biz.joshadams.Konjugieren.viewVerb"

  private func clearDeeplinkTargets() {
    verb = nil
    verbMarks = nil
    family = nil
    info = nil
    searchRequest = nil
  }

  /// Shows the verb list with its search field. A nil `text` keeps what the field holds, as
  /// Command-F does; an empty one clears it.
  func openSearch(text: String?, source: AnalyticsSource) {
    clearDeeplinkTargets()
    selectedTab = .verbs
    searchRequest = SearchRequest(text: text, source: source)
  }

  func handleUserActivity(_ userActivity: NSUserActivity) {
    guard
      userActivity.activityType == Self.viewVerbActivityType,
      let infinitiv = userActivity.userInfo?["infinitiv"] as? String
    else {
      return
    }
    clearDeeplinkTargets()
    verb = Verb.verbs[infinitiv]
    verbSource = .handoff
    if verb != nil {
      selectedTab = .verbs
    }
  }

  /// The grammar is in docs/feature-architecture.md § Deeplink System.
  func handleURL(_ url: URL) {
    guard url.isDeeplink else {
      return
    }

    // The search route alone takes no target, so it comes before the check for one.
    if url.host == URL.searchHost {
      if url.pathComponents.count <= 1 {
        openSearch(text: url.deeplinkQueryValue(named: URL.searchTextQueryName) ?? "", source: url.analyticsSource ?? .deeplink)
      }
      return
    }

    guard url.hasExpectedNumberOfDeeplinkComponents else {
      return
    }

    clearDeeplinkTargets()

    switch url.host {
    case URL.verbHost:
      let target = url.pathComponents[1]
      let found = target == "random" ? Array(Verb.verbs.values).randomElement() : Verb.verbs[target]
      verbSource = url.analyticsSource ?? .deeplink
      if let found {
        verbMarks = url.deeplinkQueryValue(named: URL.matchQueryName).flatMap { MarkedConjugations(text: $0, on: found) }
        verb = found
        selectedTab = .verbs
      }
    case URL.quizHost:
      selectedTab = .quiz
    case URL.familyHost:
      if BrowseableFamily(rawValue: url.pathComponents[1]) != nil {
        family = url.pathComponents[1]
        selectedTab = .families
      }
    case URL.infoHost:
      if let found = Info.info(deeplinkTarget: url.pathComponents[1]) {
        info = found
        selectedTab = .info
      }
    default:
      return
    }
  }
}

/// A request, from a deeplink or a command, that the verb list show its search field.
struct SearchRequest: Equatable {
  /// Nil keeps what the field holds.
  let text: String?
  let source: AnalyticsSource
}
