// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

@main
enum AppLauncher {
  static func main() {
    Verb.verbs = VerbParser().parse()
    AblautGroup.ablautGroups = AblautGroupParser().parse()
    if World.isRunningUnitTests {
      TestApp.main()
    } else {
      KonjugierenApp.main()
    }
  }
}
