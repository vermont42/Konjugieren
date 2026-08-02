// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

struct ChangeDifficultyTip: Tip {
  static let quizCompleted = Event(id: "quizCompleted")

  var title: Text {
    Text("Tips.changeDifficultyTitle")
  }

  var message: Text? {
    Text("Tips.changeDifficultyMessage")
  }

  var image: Image? {
    Image(systemName: "slider.horizontal.3")
  }

  var rules: [Rule] {
    #Rule(Self.quizCompleted) {
      $0.donations.count >= 1
    }
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}

struct ExploreFamiliesTip: Tip {
  var title: Text {
    Text("Tips.exploreFamiliesTitle")
  }

  var message: Text? {
    Text("Tips.exploreFamiliesMessage")
  }

  var image: Image? {
    Image(systemName: "figure.and.child.holdinghands")
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}

struct PlayGameTip: Tip {
  var title: Text {
    Text("Tips.playGameTitle")
  }

  var message: Text? {
    Text("Tips.playGameMessage")
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}

struct TryQuizTip: Tip {
  var title: Text {
    Text("Tips.tryQuizTitle")
  }

  var message: Text? {
    Text("Tips.tryQuizMessage")
  }

  var image: Image? {
    Image(systemName: "pencil.circle.fill")
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}
