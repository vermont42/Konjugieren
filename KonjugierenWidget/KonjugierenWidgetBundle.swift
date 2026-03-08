// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

@main
struct KonjugierenWidgetBundle: WidgetBundle {
  var body: some Widget {
    QuickQuizControl()
    QuizWidget()
    RandomVerbControl()
    VerbDesTagesWidget()
    QuizLiveActivity()
    GameLiveActivity()
  }
}
