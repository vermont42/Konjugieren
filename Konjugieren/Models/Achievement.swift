// Copyright © 2026 Josh Adams. All rights reserved.

/// Game Center achievements for mastery milestones, never for volume of play (Josh approved the
/// list on 2026-11-15). Each counts what the Mastery page counts, an item in the third box or
/// beyond, so the record that fills the page also earns these. Their titles, descriptions, and
/// artwork live in App Store Connect and `GameCenterResources.gamekit`; see
/// docs/game_center_setup.md.
// Semantic ordering: as Game Center lists them, the patterns level by level, then the verbs.
enum Achievement: String, CaseIterable {
  case patternsBeginner
  case patternsElementary
  case patternsIntermediate
  case patternsAdvanced
  case pillars
  case tenStrong
  case twentyFiveStrong
  case fiftyStrong

  /// How far the record has come toward an achievement.
  struct Progress: Equatable {
    let mastered: Int
    let required: Int

    var isComplete: Bool {
      mastered >= required
    }

    /// What Game Center takes, from 0 to 100.
    var percentComplete: Double {
      guard required > 0 else {
        return 0
      }
      return Double(min(mastered, required)) / Double(required) * 100
    }
  }

  // Achievement IDs are permanent in App Store Connect, so these must match
  // docs/game_center_setup.md exactly and never change, even if an achievement is renamed.
  var identifier: String {
    switch self {
    case .patternsBeginner:
      return "konjugieren.achievement.patterns.beginner"
    case .patternsElementary:
      return "konjugieren.achievement.patterns.elementary"
    case .patternsIntermediate:
      return "konjugieren.achievement.patterns.intermediate"
    case .patternsAdvanced:
      return "konjugieren.achievement.patterns.advanced"
    case .pillars:
      return "konjugieren.achievement.verbs.pillars"
    case .tenStrong:
      return "konjugieren.achievement.verbs.core10"
    case .twentyFiveStrong:
      return "konjugieren.achievement.verbs.core25"
    case .fiftyStrong:
      return "konjugieren.achievement.verbs.core50"
    }
  }

  /// Game Center's points, at most 100 each and 1,000 in all. App Store Connect fixes a value
  /// once the achievement has been live.
  var points: Int {
    switch self {
    case .patternsBeginner:
      return 10
    case .patternsElementary, .pillars, .tenStrong:
      return 25
    case .patternsIntermediate, .twentyFiveStrong:
      return 50
    case .patternsAdvanced, .fiftyStrong:
      return 100
    }
  }

  /// The level whose every pattern a pattern achievement asks for.
  var patternLevel: QuizLevel? {
    switch self {
    case .patternsBeginner:
      return .beginner
    case .patternsElementary:
      return .elementary
    case .patternsIntermediate:
      return .intermediate
    case .patternsAdvanced:
      return .advanced
    case .pillars, .tenStrong, .twentyFiveStrong, .fiftyStrong:
      return nil
    }
  }

  /// Every achievement's progress in `record`.
  static func progress(in record: PracticeRecord) -> [Achievement: Progress] {
    let masteredCore = Set(Mastery.coreVerbs.filter { Mastery.isFullyMastered($0, in: record) }.map(\.infinitiv))
    let pillarInfinitives = Set(pillarVerbs.map(\.infinitiv))
    var result: [Achievement: Progress] = [:]
    for achievement in allCases {
      switch achievement {
      case .patternsBeginner, .patternsElementary, .patternsIntermediate, .patternsAdvanced:
        let mastery = Mastery(level: achievement.patternLevel ?? .beginner, record: record)
        result[achievement] = Progress(mastered: mastery.masteredPatternCount, required: mastery.patternCount)
      case .pillars:
        result[achievement] = Progress(mastered: masteredCore.intersection(pillarInfinitives).count, required: pillarInfinitives.count)
      case .tenStrong:
        result[achievement] = Progress(mastered: masteredCore.count, required: 10)
      case .twentyFiveStrong:
        result[achievement] = Progress(mastered: masteredCore.count, required: 25)
      case .fiftyStrong:
        result[achievement] = Progress(mastered: masteredCore.count, required: Mastery.coreVerbCount)
      }
    }
    return result
  }

  /// sein, haben, werden, and the six modals, all among the 50 core verbs.
  static var pillarVerbs: [Verb] {
    Mastery.coreVerbs.filter(QuizDraw.isCore)
  }
}

extension World {
  /// Sends Game Center the achievements' progress as the record now stands. Called when the app
  /// launches, when a quiz finishes or is quit, and when a review card is revealed, the moments
  /// an item can reach the third box. `GameCenterReal` holds it until the player is signed in and
  /// sends only what has risen, so calling it often costs nothing.
  func reportAchievements() {
    gameCenter.reportAchievementProgress(Achievement.progress(in: practice.record).mapValues(\.percentComplete))
  }
}
