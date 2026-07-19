// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import TipKit

enum OnboardingDisplay {
  // Workaround: the welcome tour auto-presents over whatever screen is being captured, so an
  // App Store screenshot sweep sets this false, then restores it to true. Only the automatic
  // first-launch presentation in KonjugierenApp consults it; the Settings "Show Onboarding"
  // button ignores it, so the flow stays manually reachable for review. Because the cover never
  // presents when this is false, hasSeenOnboarding is left untouched rather than marked seen.
  static let onboardingEnabled = true
}

enum TipDisplay {
  // Workaround: TipKit popovers surface unpredictably mid-sweep, so an App Store screenshot
  // sweep sets this false, then restores it to true. TipKit displays nothing until it is
  // configured, so skipping Tips.configure() in KonjugierenApp hides every TipView and
  // popoverTip app-wide with no per-call-site changes.
  static let tipsEnabled = true
}

enum TutorDisplay {
  // Workaround: the tutor needs Apple Intelligence, which does not resolve as available on the
  // screenshot host (see CLAUDE.md on the iOS 26.3+ host-eligibility gate), so InfoBrowseView
  // renders a reason row there — "Apple Intelligence isn't available on this device." That is
  // honest on a device but reads as a defect in a store listing, so the info_browse shots hide
  // it. Ordinarily true; set false before an App Store screenshot sweep, then restore. Only the
  // reason row is suppressed: when the model is available the section still renders
  // TutorRowView, so this switch cannot hide a working feature.
  static let tutorUnavailableRowEnabled = true
}

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
