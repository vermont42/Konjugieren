// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// The results of the last quiz the learner saw, which the Quiz tab's hub shows. It is kept on the
/// device beside the practice record and sent nowhere.
struct LastQuizResult: Codable, Equatable {
  /// What was quizzed. A kind, not a title, so that the hub names it in the app's current
  /// language.
  enum Kind: String, Codable {
    case ablautAlone
    case ablautMixed
    case allVerbs
    case challenge
    case collection
    case custom
    case daily
    case mistakes
    case myVerbs
    case practiceSet
    case recognition
    case review
    case sentences
    case speedRound
    case verbEssentials
    case verbPage
  }

  static let storageKey = "lastQuizResult"

  let kind: Kind
  /// The verb of a verb page's quiz, or the key of a collection's or of a practiced ablaut group's.
  let subject: String?
  /// Nil for Review, My Mistakes, and an ablaut group's practice, which do not ask by level.
  let levelKey: String?
  let score: Int
  let correctCount: Int
  let secondAttemptCount: Int
  let questionCount: Int
  let date: Date

  var level: QuizLevel? {
    levelKey.flatMap(QuizLevel.init(rawValue:))
  }

  init(kind: Kind, subject: String?, level: QuizLevel?, score: Int, correctCount: Int, secondAttemptCount: Int, questionCount: Int, date: Date) {
    self.kind = kind
    self.subject = subject
    levelKey = level?.rawValue
    self.score = score
    self.correctCount = correctCount
    self.secondAttemptCount = secondAttemptCount
    self.questionCount = questionCount
    self.date = date
  }

  /// A Ten More round's results replace its first round's, so the hub shows the session so far.
  init(quiz: Quiz, date: Date = .now) {
    let kind = Kind(scope: quiz.scope)
    let subject: String?
    switch kind {
    case .ablautAlone, .ablautMixed, .collection:
      subject = quiz.scope.collectionKey
    case .verbPage:
      subject = quiz.scope.verbs?.first?.infinitiv
    case .allVerbs, .challenge, .custom, .daily, .mistakes, .myVerbs, .practiceSet, .recognition, .review, .sentences, .speedRound, .verbEssentials:
      subject = nil
    }
    self.init(
      kind: kind,
      subject: subject,
      level: quiz.scope.asksByLevel ? quiz.level : nil,
      score: quiz.score,
      correctCount: quiz.correctCount,
      secondAttemptCount: quiz.secondAttemptCount,
      questionCount: quiz.questionCount,
      date: date
    )
  }

  /// The quiz's name on the hub: "All Verbs", "Strong Verbs Like singen", "fahren".
  var title: String {
    switch kind {
    case .ablautAlone:
      return ablautSession(.alone)?.title ?? L.AblautPractice.title
    case .ablautMixed:
      return ablautSession(.mixed)?.title ?? L.AblautPractice.title
    case .allVerbs:
      return L.Quiz.allVerbs
    case .challenge:
      return L.DailyChallenge.title
    case .collection:
      return subject.flatMap(VerbCollection.init(key:))?.title ?? L.PracticeSet.title
    case .custom:
      return L.CustomQuiz.title
    case .daily:
      return L.DailySession.title
    case .mistakes:
      return QuizRecordSession.mistakes.title
    case .myVerbs:
      return L.MyVerbs.title
    case .practiceSet:
      return L.PracticeSet.title
    case .recognition:
      return L.Recognition.title
    case .review:
      return QuizRecordSession.review.title
    case .sentences:
      return L.Sentences.title
    case .speedRound:
      return L.SpeedRound.title
    case .verbEssentials:
      return L.VerbEssentials.title
    case .verbPage:
      return subject.flatMap { Verb.verbs[$0]?.infinitiv.inUserRegion } ?? subject ?? L.Quiz.allVerbs
    }
  }

  private func ablautSession(_ mode: AblautPracticeSession.Mode) -> AblautPracticeSession? {
    guard case .ablautGroup(let exemplar) = subject.flatMap(VerbCollection.init(key:)) else {
      return nil
    }
    return AblautPracticeSession(exemplar: exemplar, mode: mode)
  }
}

extension LastQuizResult.Kind {
  /// A practice set is a custom quiz opened from a link or a code, and a custom quiz over a
  /// collection counts as custom, since the learner chose it in the editor.
  init(scope: QuizScope) {
    if let session = scope.recordSession {
      switch session {
      case .mistakes:
        self = .mistakes
      case .review:
        self = .review
      }
    } else if let session = scope.ablautPractice {
      switch session.mode {
      case .alone:
        self = .ablautAlone
      case .mixed:
        self = .ablautMixed
      }
    } else if scope.isVerbEssentials {
      self = .verbEssentials
    } else if scope.isRecognition {
      self = .recognition
    } else if scope.isSentences {
      self = .sentences
    } else if scope.isSpeedRound {
      self = .speedRound
    } else if scope.isDaily {
      self = .daily
    } else if scope.isChallenge {
      self = .challenge
    } else if scope.source == .verbPage {
      self = .verbPage
    } else if scope.custom != nil {
      self = scope.source == .custom ? .custom : .practiceSet
    } else if scope.collectionKey != nil {
      self = .collection
    } else if scope.verbs != nil {
      self = .myVerbs
    } else {
      self = .allVerbs
    }
  }
}
