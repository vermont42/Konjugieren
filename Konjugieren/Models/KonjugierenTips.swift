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

/// Explains the verb page's red letters. It stays until the learner closes it, and appears
/// only on a page that has red letters, since machen's page would leave it nothing to point at.
struct RedLettersTip: Tip {
  var title: Text {
    Text("Tips.redLettersTitle")
  }

  var message: Text? {
    Text("Tips.redLettersMessage")
  }

  var image: Image? {
    Image(systemName: "character.cursor.ibeam")
  }
}

/// Points to the etymology and the example sentence at the bottom of the verb page. It waits
/// until a page visit after `RedLettersTip` was closed, so the two never appear one straight
/// after the other, and the page invalidates it once the learner scrolls that far unprompted.
struct ScrollToBottomTip: Tip {
  @Parameter
  static var isUnlocked: Bool = false

  var title: Text {
    Text("Tips.scrollToBottomTitle")
  }

  var message: Text? {
    Text("Tips.scrollToBottomMessage")
  }

  var image: Image? {
    Image(systemName: "arrow.down.to.line")
  }

  var rules: [Rule] {
    #Rule(Self.$isUnlocked) {
      $0 == true
    }
  }
}
