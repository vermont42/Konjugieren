// Copyright © 2026 Josh Adams. All rights reserved.

enum ParameterKey: String {
  case difficulty
  case questionNumber
}

enum AnalyticsName: String {
  case completeQuiz = "complete.quiz"
  case loseGame = "lose.game"
  case quitQuiz = "quit.quiz"
  case startGame = "start.game"
  case startQuiz = "start.quiz"
  case tapPlayGame = "tap.playGame"
  case winGame = "win.game"
  case tapShowOnboarding = "tap.showOnboarding"
  case tapViewLeaderboard = "tap.viewLeaderboard"
  case viewFamilyBrowseView = "view.FamilyBrowseView"
  case viewFamilyDetailView = "view.FamilyDetailView"
  case viewInfoBrowseView = "view.InfoBrowseView"
  case viewInfoView = "view.InfoView"
  case viewQuizView = "view.QuizView"
  case viewSettingsView = "view.SettingsView"
  case viewVerbBrowseView = "view.VerbBrowseView"
  case viewVerbView = "view.VerbView"
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
