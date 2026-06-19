// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum WidgetL {
  enum Game {
    static var over: String {
      String(localized: "Game.over")
    }

    static func wave(_ number: Int) -> String {
      String(localized: "Game.wave \(number)")
    }
  }

  enum QuickQuiz {
    nonisolated static var controlDescription: LocalizedStringResource {
      LocalizedStringResource("QuickQuiz.description")
    }

    nonisolated static var name: LocalizedStringResource {
      LocalizedStringResource("QuickQuiz.name")
    }
  }

  enum Quiz {
    static var configDescription: String {
      String(localized: "Quiz.configDescription")
    }

    static var configDisplayName: String {
      String(localized: "Quiz.configDisplayName")
    }

    static var correct: String {
      String(localized: "Quiz.correct")
    }

    static var incorrect: String {
      String(localized: "Quiz.incorrect")
    }
  }

  enum RandomVerb {
    nonisolated static var controlDescription: LocalizedStringResource {
      LocalizedStringResource("RandomVerb.description")
    }

    nonisolated static var name: LocalizedStringResource {
      LocalizedStringResource("RandomVerb.name")
    }
  }

  enum VerbDesTages {
    static var configDescription: String {
      String(localized: "VerbDesTages.configDescription")
    }

    static var configDisplayName: String {
      String(localized: "VerbDesTages.configDisplayName")
    }
  }
}
