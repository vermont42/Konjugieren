// Copyright © 2026 Josh Adams. All rights reserved.

import Observation
import SwiftUI

var Current = World.chooseWorld()

@MainActor
@Observable
class World {
  var settings: Settings
  var gameCenter: GameCenterManager
  var verb: Verb?
  var family: String?
  var info: Info?

  init(settings: Settings, gameCenter: GameCenterManager) {
    self.settings = settings
    self.gameCenter = gameCenter
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
    let settings = Settings(getterSetter: GetterSetterReal())
    return World(settings: settings, gameCenter: GameCenterManager())
  }()

  static let simulator: World = {
    let settings = Settings(getterSetter: GetterSetterReal())
    return World(settings: settings, gameCenter: GameCenterManager())
  }()

  static let unitTest: World = {
    let settings = Settings(getterSetter: GetterSetterFake())
    return World(settings: settings, gameCenter: GameCenterManager())
  }()

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
