// Copyright © 2025 Josh Adams. All rights reserved.

import Observation
import SwiftUI

var Current = World.chooseWorld()

@Observable
class World {
  var settings: Settings

  init(settings: Settings) {
    self.settings = settings
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
    return World(settings: settings)
  }()

  static let simulator: World = {
    let settings = Settings(getterSetter: GetterSetterReal())
    return World(settings: settings)
  }()

  static let unitTest: World = {
    let settings = Settings(getterSetter: GetterSetterFake())
    return World(settings: settings)
  }()
}
