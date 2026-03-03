// Copyright © 2026 Josh Adams. All rights reserved.

import Observation
import SwiftUI

@MainActor var Current = World.chooseWorld()

@MainActor
@Observable
class World {
  var settings: Settings
  var gameCenter: GameCenter
  let getterSetter: GetterSetter
  var languageModelService: LanguageModelService
  var soundPlayer: SoundPlayer
  var utterer: Utterer
  var fatalError: FatalError
  var analytics: Analytics
  var verb: Verb?
  var family: String?
  var info: Info?
  var selectedTab: TabSelection = .verbs

  init(settings: Settings, gameCenter: GameCenter, getterSetter: GetterSetter, languageModelService: LanguageModelService, soundPlayer: SoundPlayer, utterer: Utterer, fatalError: FatalError, analytics: Analytics) {
    self.settings = settings
    self.gameCenter = gameCenter
    self.getterSetter = getterSetter
    self.languageModelService = languageModelService
    self.soundPlayer = soundPlayer
    self.utterer = utterer
    self.fatalError = fatalError
    self.analytics = analytics
  }

  static func chooseWorld() -> World {
#if targetEnvironment(simulator)
    let isRunningUnitTests = NSClassFromString("XCTest") != nil
    if isRunningUnitTests {
      return World.unitTest
    } else {
      return World.simulator
    }
#else
    return World.device
#endif
  }

  static let device: World = {
    let getterSetter = GetterSetterReal()
    let settings = Settings(getterSetter: getterSetter)
    let languageModelService: LanguageModelService = {
      if #available(iOS 26, *) {
        return LanguageModelServiceReal()
      } else {
        return LanguageModelServiceDummy()
      }
    }()
    return World(settings: settings, gameCenter: GameCenterReal(), getterSetter: getterSetter, languageModelService: languageModelService, soundPlayer: SoundPlayerReal(), utterer: UttererReal(), fatalError: FatalErrorReal(), analytics: AnalyticsReal())
  }()

  static let simulator: World = {
    let getterSetter = GetterSetterReal()
    let settings = Settings(getterSetter: getterSetter)
    let languageModelService: LanguageModelService = {
      if #available(iOS 26, *) {
        return LanguageModelServiceReal()
      } else {
        return LanguageModelServiceDummy()
      }
    }()
    return World(settings: settings, gameCenter: GameCenterReal(), getterSetter: getterSetter, languageModelService: languageModelService, soundPlayer: SoundPlayerReal(), utterer: UttererReal(), fatalError: FatalErrorReal(), analytics: AnalyticsReal())
  }()

  static let unitTest: World = {
    let getterSetter = GetterSetterFake()
    let settings = Settings(getterSetter: getterSetter)
    return World(settings: settings, gameCenter: GameCenterDummy(), getterSetter: getterSetter, languageModelService: LanguageModelServiceDummy(), soundPlayer: SoundPlayerDummy(), utterer: UttererDummy(), fatalError: FatalErrorSpy(), analytics: AnalyticsSpy())
  }()

  static let viewVerbActivityType = "biz.joshadams.Konjugieren.viewVerb"

  func handleUserActivity(_ userActivity: NSUserActivity) {
    guard
      userActivity.activityType == Self.viewVerbActivityType,
      let infinitiv = userActivity.userInfo?["infinitiv"] as? String
    else {
      return
    }
    verb = nil
    family = nil
    info = nil
    verb = Verb.verbs[infinitiv]
    if verb != nil {
      selectedTab = .verbs
    }
  }

  func handleURL(_ url: URL) {
    guard
      url.isDeeplink,
      url.hasExpectedNumberOfDeeplinkComponents
    else {
      return
    }

    verb = nil
    family = nil
    info = nil

    switch url.host {
    case URL.verbHost:
      verb = Verb.verbs[url.pathComponents[1]]
      if verb != nil {
        selectedTab = .verbs
      }
    case URL.familyHost:
      family = url.pathComponents[1]
    case URL.infoHost:
      if
        let infoIndex = Int(url.pathComponents[1]),
        infoIndex < Info.infos.count
      {
        info = Info.infos[infoIndex]
      }
    default:
      return
    }
  }
}
