// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

@main
enum AppLauncher {
  static func main() throws {
    Verb.verbs = VerbParser().parse()
    AblautGroup.ablautGroups = AblautGroupParser().parse()
    if NSClassFromString("XCTestCase") == nil {
      KonjugierenApp.main()
    } else {
      TestApp.main()
    }
  }
}
