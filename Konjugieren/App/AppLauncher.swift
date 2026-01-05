// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

@main
enum AppLauncher {
  static func main() throws {
    Verb.verbs = VerbParser().parse()
    AblautGroup.ablautGroups = AblautGroupParser().parse()
    
    for (_, value) in Verb.verbs {
      print(Conjugator.conjugate(infinitiv: value.infinitiv, conjugationgroup: .perfektpartizip))
    }

    for (_, value) in AblautGroup.ablautGroups {
      print(value)
    }

    if NSClassFromString("XCTestCase") == nil {
      KonjugierenApp.main()
    } else {
      TestApp.main()
    }
  }
}
