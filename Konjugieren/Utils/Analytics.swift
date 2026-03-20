// Copyright © 2026 Josh Adams. All rights reserved.

enum ParameterKey: String {
  case difficulty
  case questionNumber
}

enum AnalyticsName: String {
  case completeQuiz
  case completeWave
  case loseGame
  case quitQuiz
  case startGame
  case startQuiz
  case tapDeleteChatHistory
  case tapExplainError
  case tapPlayGame
  case tapSendTutorMessage
  case tapShowOnboarding
  case tapViewLeaderboard
  case viewFamilyBrowseView
  case viewFamilyDetailView
  case viewInfoBrowseView
  case viewInfoView
  case viewQuizView
  case viewSettingsView
  case viewTutorView
  case viewVerbBrowseView
  case viewVerbView
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
