// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// A custom quiz shared as a link or a QR code, so that a teacher can hand a class one practice
/// set without accounts or a server (T2.9, Phase 10 of the pedagogy plan). Opening one shows the
/// set with Start rather than starting a quiz unasked.
struct PracticeSet: Equatable {
  var custom: CustomQuiz

  /// The sharer's level, carried only while a part of the choice is left to the level, so that
  /// every learner who opens the set is asked the same conjugationgroups and verbs.
  var level: QuizLevel?

  init(custom: CustomQuiz, level: QuizLevel?) {
    self.custom = custom
    self.level = level
  }

  /// The set a learner shares from the Quiz tab. Their My Verbs are their own, so the link
  /// carries the verbs themselves (Josh, 2026-11-14), the first `maximumListCount` of them.
  init(sharing custom: CustomQuiz, level: QuizLevel, myVerbs: [Verb]) {
    var shared = custom
    if custom.verbSet == .myVerbs {
      shared.verbSet = QuizVerbSet(infinitives: myVerbs.prefix(Self.maximumListCount).map(\.infinitiv))
    }
    self.custom = shared
    self.level = shared.tables.isEmpty || shared.verbSet == nil ? level : nil
  }

  /// Keeps a projected QR code coarse enough to scan from the back of a classroom.
  static let maximumListCount = 100

  /// `konjugieren://quiz/set?groups=praeteritum_indikativ&verbs=modals&source=sharedLink`.
  /// Nil for any other link, and for a `quiz/set` link that names no conjugationgroup or verb set
  /// this version knows. A link naming My Verbs would ask the opener's own, which no sharer means,
  /// so that part is dropped.
  init?(url: URL) {
    guard
      url.isDeeplink,
      url.host == URL.quizHost,
      url.hasExpectedNumberOfDeeplinkComponents,
      url.pathComponents[1] == URL.practiceSetTarget,
      let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.percentEncodedQuery,
      var custom = CustomQuiz(rawValue: query)
    else {
      return nil
    }
    if custom.verbSet == .myVerbs {
      custom.verbSet = nil
    }
    guard !custom.isEmpty else {
      return nil
    }
    self.custom = custom
    level = url.deeplinkQueryValue(named: URL.levelQueryName).flatMap(QuizLevel.init(rawValue:))
  }

  /// `source` is `sharedLink` in shared text and `qrCode` in a QR code, so that `startQuiz` can
  /// tell which reached the learner.
  func deeplink(source: AnalyticsSource) -> URL? {
    URL.practiceSetDeeplink(custom: custom, level: level, source: source)
  }

  /// What a quiz over this set asks: the custom quiz's rules, at the set's level.
  func scope(source: AnalyticsSource) -> QuizScope {
    QuizScope(
      verbs: custom.verbSet?.verbs(myVerbs: []),
      readingIndex: nil,
      questionCount: Quiz.questionCount,
      source: source,
      title: L.PracticeSet.title,
      collectionKey: custom.verbSet?.collectionKey,
      custom: custom,
      level: level
    )
  }

  /// The tables on one line and the verbs on the next, for the share text and the QR code's
  /// caption. One line read ambiguously, since a list's title holds a separator of its own.
  func summary(lang: ConjugationgroupLang, levelFallback: QuizLevel) -> String {
    let levelName = (level ?? levelFallback).localizedName
    let tables = custom.tables.isEmpty
      ? "\(L.PracticeSet.byLevel): \(levelName)"
      : custom.orderedTables.map { $0.displayName(lang: lang) }.joined(separator: ", ")
    let verbs = custom.verbSet?.title ?? "\(L.PracticeSet.byLevel): \(CustomQuiz.levelVerbsDescription(level ?? levelFallback))"
    return "\(tables)\n\(verbs)"
  }

  /// The summary, a link that opens the set for someone who has the app, and the App Store link
  /// for someone who does not. There is no web domain, so there is no universal link.
  func shareText(lang: ConjugationgroupLang, levelFallback: QuizLevel) -> String {
    L.PracticeSet.shareText(
      summary: summary(lang: lang, levelFallback: levelFallback),
      link: deeplink(source: .sharedLink)?.absoluteString ?? "",
      appStoreLink: URL.appStore.absoluteString
    )
  }

  static let linkMethod = "link"
  static let qrCodeMethod = "qrCode"

  func signalShare(method: String) {
    Current.analytics.signal(name: .tapSharePracticeSet, parameters: [
      ParameterKey.customChoice.rawValue: custom.choiceParameter,
      ParameterKey.method.rawValue: method,
    ])
  }
}

/// A practice-set link to show, from `World.handleURL`. A nil set is a `quiz/set` link that names
/// nothing, which shows a sheet saying so rather than doing nothing.
struct PracticeSetRequest: Identifiable {
  let id = UUID()
  let practiceSet: PracticeSet?
  let source: AnalyticsSource
}
