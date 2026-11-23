// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import UIKit

/// The daily challenge: five questions a day at each level,
/// the same on every device on the same date, taken once and shared as a short text (Josh,
/// 2026-11-13 and 2026-11-15).
enum DailyChallenge {
  static let questionCount = 5

  /// Draws repeat until no verb is asked twice, since five questions are few enough that two on
  /// sein would be a fifth of the challenge each. The limit keeps a corpus that cannot comply from
  /// looping forever.
  static let distinctVerbAttempts = 20

  /// A day's challenge at a level. The day is the learner's own calendar day, as `yyyy-MM-dd`, so
  /// that two learners in different time zones share a challenge by date, not by instant.
  struct Key: Codable, Hashable {
    let day: String
    let levelKey: String

    var level: QuizLevel {
      QuizLevel(rawValue: levelKey) ?? Settings.quizLevelDefault
    }

    init(day: String, level: QuizLevel) {
      self.day = day
      levelKey = level.rawValue
    }

    init(date: Date, level: QuizLevel) {
      self.init(day: DailyChallenge.dayString(for: date), level: level)
    }

    /// The challenge a shared link names, or nil for a day that is not a date.
    init?(dayString: String, level: QuizLevel) {
      guard DailyChallenge.date(fromDayString: dayString) != nil else {
        return nil
      }
      self.init(day: dayString, level: level)
    }

    /// The text the seed is made from. Changing it changes every challenge on every device.
    var seedText: String {
      "challenge-\(day)-\(levelKey)"
    }

    /// FNV-1a, which the widget's answer shuffle already relies on for being the same in every
    /// process, unlike Swift's `Hasher`.
    var seed: UInt64 {
      WidgetQuizQuestion.stableSeed(for: seedText)
    }

    /// Noon of the day, which no time-zone change moves to another date.
    var date: Date {
      DailyChallenge.date(fromDayString: day) ?? .now
    }
  }

  /// How one question of a challenge went, as the shared text's dots show it, in the colors of the
  /// quiz's progress dots.
  enum Outcome: String, Codable {
    case right
    case secondTry
    case wrong

    init(_ state: QuizItem.State) {
      switch state {
      case .correct:
        self = .right
      case .correctOnSecondAttempt:
        self = .secondTry
      case .incorrect, .unanswered:
        self = .wrong
      }
    }

    var dot: String {
      switch self {
      case .right:
        return "🟡"
      case .secondTry:
        return "🟠"
      case .wrong:
        return "🔴"
      }
    }

    var points: Int {
      switch self {
      case .right:
        return Quiz.pointsPerCorrect
      case .secondTry:
        return Quiz.pointsPerSecondAttempt
      case .wrong:
        return 0
      }
    }
  }

  static let maximumScore = questionCount * Quiz.pointsPerCorrect

  /// The day of `date` in the learner's calendar, as the widget's question IDs write it.
  static func dayString(for date: Date) -> String {
    dayFormatter.string(from: date)
  }

  static func date(fromDayString day: String) -> Date? {
    guard let start = dayFormatter.date(from: day), dayFormatter.string(from: start) == day else {
      return nil
    }
    return WidgetConstants.gregorianCalendar.date(byAdding: .hour, value: 12, to: start)
  }

  private static var dayFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.calendar = WidgetConstants.gregorianCalendar
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }

  private static var cache: [Key: [QuizDrawnQuestion]] = [:]

  /// The challenge's five questions: the default quiz's balanced draw from the level's pool and
  /// band, seeded by the key alone, so that nothing on the device (the practice record, My Verbs,
  /// the settings) enters it. The corpus is sorted first, as `Quiz.defaultVerbs` does, since a
  /// dictionary's order changes from launch to launch. Two devices agree as long as they run the
  /// same corpus and the same build: `QuizDraw` uses the standard library's `randomElement` and
  /// `shuffled`, whose use of the generator a new toolchain could change, so `DailyChallengeTests`
  /// pins the seed and the draw's determinism.
  static func questions(for key: Key) -> [QuizDrawnQuestion] {
    if let cached = cache[key] {
      return cached
    }
    let drawn = draw(for: key)
    cache[key] = drawn
    return drawn
  }

  /// `questions(for:)` without the cache, which the widget's ten days and the hub would otherwise
  /// draw again at every launch.
  static func draw(for key: Key) -> [QuizDrawnQuestion] {
    let level = key.level
    let verbs = Quiz.defaultVerbs(for: level)
    var generator = SeededRNG(seed: key.seed)
    var drawn: [QuizDrawnQuestion] = []
    for _ in 0..<distinctVerbAttempts {
      drawn = QuizDraw.questions(pool: level.pool, verbs: verbs, readingIndex: nil, count: questionCount, distinctCells: false, mixesVerbs: true, using: &generator)
      if Set(drawn.map(\.verb.infinitiv)).count == drawn.count {
        break
      }
    }
    return drawn
  }
}

/// A finished challenge, kept on the device and sent nowhere, so that the hub can show the day's
/// result and share it, and so that a challenge is taken once.
struct DailyChallengeResult: Codable, Equatable {
  static let storageKey = "dailyChallengeResults"
  /// Enough for a week's challenges at a level, and a few opened from links.
  static let keptCount = 12

  let key: DailyChallenge.Key
  let outcomes: [DailyChallenge.Outcome]

  var score: Int {
    outcomes.reduce(0) { $0 + $1.points }
  }

  var dots: String {
    outcomes.map(\.dot).joined()
  }

  /// "35 / 50", which the hub shows above the dots drawn as views.
  var pointsLine: String {
    "\(score) / \(DailyChallenge.maximumScore)"
  }

  /// What VoiceOver reads for the dots, which it would otherwise read as five colored circles.
  var spokenSummary: String {
    let right = outcomes.filter { $0 == .right }.count
    let secondTry = outcomes.filter { $0 == .secondTry }.count
    return L.DailyChallenge.spokenResult(right: right, secondTry: secondTry, count: outcomes.count, score: score, maximum: DailyChallenge.maximumScore)
  }

  /// The challenge's five questions as first asked, a slip's second attempt included.
  init(key: DailyChallenge.Key, questions: [QuizItem]) {
    self.key = key
    outcomes = questions.filter { !$0.isReask }.prefix(DailyChallenge.questionCount).map { DailyChallenge.Outcome($0.state) }
  }

  init(key: DailyChallenge.Key, outcomes: [DailyChallenge.Outcome]) {
    self.key = key
    self.outcomes = outcomes
  }

  /// The text the results and the hub share, as Josh approved it on 2026-11-15: the date, the
  /// level, the dots, the points, a link that opens the same challenge, and the App Store.
  func shareText(locale: Locale = DailyChallenge.appLocale) -> String {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return L.DailyChallenge.shareText(
      date: formatter.string(from: key.date),
      level: key.level.localizedName,
      dots: dots,
      score: score,
      maximum: DailyChallenge.maximumScore,
      link: URL.challengeDeeplink(key, source: .challengeLink)?.absoluteString ?? "",
      appStoreLink: URL.appStore.absoluteString
    )
  }
}

extension DailyChallengeResult {
  /// The share sheet with `shareText()`, and `tapShareChallenge`, which names the level and never
  /// the result, since no signal carries accuracy.
  func share(anchorRect: CGRect?) {
    signalShare()
    ShareSheet.present(
      text: shareText(),
      title: L.DailyChallenge.title,
      icon: UIImage(named: Current.settings.appIcon.previewAssetName),
      anchorLabel: L.DailyChallenge.share,
      anchorRect: anchorRect == .zero ? nil : anchorRect
    )
  }
}

extension DailyChallengeResult {
  func signalShare() {
    Current.analytics.signal(name: .tapShareChallenge, parameters: [ParameterKey.level.rawValue: key.levelKey])
  }
}

extension DailyChallenge {
  /// The app's language, which can differ from the region's, for the shared date.
  static var appLocale: Locale {
    Locale(identifier: Bundle.main.preferredLocalizations.first ?? "en")
  }
}

extension QuizScope {
  /// A day's challenge, at the key's level whatever the learner's, since a challenge opened from
  /// a friend's link must ask the friend's questions. Never ranked, never continued, and never
  /// re-asked, so that the results show what the shared text says.
  static func challenge(_ key: DailyChallenge.Key, source: AnalyticsSource = .challenge) -> QuizScope {
    QuizScope(verbs: nil, readingIndex: nil, questionCount: DailyChallenge.questionCount, source: source, title: nil, level: key.level, challenge: key)
  }
}

/// A request, from a shared link or the quiz widget, that the Quiz tab start a challenge.
struct DailyChallengeRequest: Equatable {
  let id = UUID()
  /// Nil asks for today's at the learner's level.
  let key: DailyChallenge.Key?
  let source: AnalyticsSource
}
