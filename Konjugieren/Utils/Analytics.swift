// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum ParameterKey: String {
  case collection
  case deepestSection
  case dwell
  case level
  case matchKind
  case outcome
  case queryLength
  case questionNumber
  case resultCount
  case resultPosition
  case source
  case starred
}

enum AnalyticsName: String {
  case completeQuiz
  case completeWave
  case finishSearch
  case leaveVerbView
  case loseGame
  case quitQuiz
  case startGame
  case startQuiz
  case tapConjugationgroupArticle
  case tapDeleteChatHistory
  case tapExplainError
  case tapPlayGame
  case tapRateOrReview
  case tapRevealReviewCard
  case tapSendTutorMessage
  case tapShareCollection
  case tapShareVerb
  case tapShowOnboarding
  case tapStarVerb
  case tapTestVerb
  case tapViewLeaderboard
  case viewCollection
  case viewFamilyBrowseView
  case viewFamilyDetailView
  case viewInfoBrowseView
  case viewInfoView
  case viewQuizView
  case viewReviewCard
  case viewSettingsView
  case viewTutorView
  case viewVerbBrowseView
  case viewVerbView
}

/// How the learner reached a verb page, began a search, or, once the quiz track sends it, began
/// a quiz. The signals share one vocabulary so that a verb page, a search, and a quiz reached
/// from the same surface carry the same value. `docs/feature-architecture.md` says which values
/// are sent today.
enum AnalyticsSource: String, CaseIterable {
  case browse
  case control
  case deeplink
  case family
  case handoff
  case infoLink
  case list
  case lookup
  case myVerbs
  case quickAction
  case quizCorrection
  case recent
  case related
  case resume
  case reviewCard
  case search
  case searchGuess
  case sharedLink
  case shortcut
  case spotlight
  case tab
  case verbPage
  case widget
}

enum SearchOutcome: String, CaseIterable {
  case abandoned
  case noResult
  case opened
}

enum SearchMatchKind: String, CaseIterable {
  case conjugation
  case exactFoldedInfinitive
  case exactInfinitive
  case finitePart
  case foldedConjugation
  case foldedInfinitivePrefix
  case foldedInfinitiveSubstring
  case glossSubstring
  case guess
  case infinitivePrefix
  case infinitiveSubstring
  case none
  case wholeWordGloss
}

// Semantic ordering: top of the verb page to bottom.
enum VerbPageSection: String, CaseIterable, Comparable {
  case header
  case simple
  case compound
  case etymology
  case example

  nonisolated static func < (lhs: VerbPageSection, rhs: VerbPageSection) -> Bool {
    let order = allCases
    return (order.firstIndex(of: lhs) ?? 0) < (order.firstIndex(of: rhs) ?? 0)
  }
}

/// Coarse bands for counts and durations. The privacy policy promises that nothing typed is
/// sent, and an exact query length or dwell time would come closer to identifying what was
/// typed or read than a band does.
enum AnalyticsBand {
  nonisolated static let noPosition = "none"

  nonisolated static func queryLength(_ length: Int) -> String {
    switch length {
    case ...2:
      return "1-2"
    case 3...5:
      return "3-5"
    case 6...9:
      return "6-9"
    default:
      return "10+"
    }
  }

  nonisolated static func resultCount(_ count: Int) -> String {
    switch count {
    case ...0:
      return "0"
    case 1:
      return "1"
    case 2...10:
      return "2-10"
    default:
      return "11+"
    }
  }

  /// `index` counts from zero, as the list does. The band counts from one, as a reader does.
  nonisolated static func resultPosition(_ index: Int?) -> String {
    guard let index else {
      return noPosition
    }
    switch index {
    case ...0:
      return "1"
    case 1...4:
      return "2-5"
    default:
      return "6+"
    }
  }

  nonisolated static func dwell(_ seconds: TimeInterval) -> String {
    switch seconds {
    case ..<5:
      return "0-5s"
    case ..<15:
      return "5-15s"
    case ..<60:
      return "15-60s"
    default:
      return "60s+"
    }
  }
}

protocol Analytics {
  func initialize(appID: String)
  func signal(name: AnalyticsName, parameters: [String: String])
}

extension Analytics {
  func signal(name: AnalyticsName) {
    signal(name: name, parameters: [:])
  }
}
