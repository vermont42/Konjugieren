// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// Verb Essentials: given a strong or mixed verb, the learner
/// supplies its three key conjugations, fährt · fuhr · ist gefahren, as the Goethe-Institut's B1
/// list prints them. Each is its own question, graded alone and recorded as its own item, but the
/// three are shown together as one step, so the learner sees the verb's pattern assemble.
extension QuizScope {
  /// Five verbs make fifteen blanks, about the default quiz's two or three minutes, since a verb's
  /// second and third blanks come quickly (Josh, 2026-11-14).
  static let verbEssentialsVerbCount = 5

  /// Nil asks the strong and mixed verbs of the learner's band. An ablaut group's practice is
  /// `ablautPractice(_:)`, which chooses the readings too.
  static func verbEssentials(_ verbs: [Verb]? = nil) -> QuizScope {
    QuizScope(
      verbs: verbs,
      readingIndex: nil,
      questionCount: verbEssentialsVerbCount * PracticeItem.Stem.allCases.count,
      source: .verbEssentials,
      isVerbEssentials: true
    )
  }
}

extension QuizDraw {
  /// One step of Verb Essentials: the reading's key conjugations, in the order the verb page shows
  /// them. `PracticeItem.exercised` maps each back to its own key conjugation in the record.
  static func verbEssentialsStep(verb: Verb, readingIndex: Int) -> [QuizDrawnQuestion] {
    PracticeItem.Stem.allCases.map { stem in
      QuizDrawnQuestion(verb: verb, conjugationgroup: stem.keyConjugationgroup, readingIndex: readingIndex)
    }
  }

  /// A round of Verb Essentials: `count` distinct verbs with a strong or mixed reading, drawn from
  /// `verbs`, each asked through one such reading. A weak verb has no key conjugations of its own.
  /// Verbs whose key conjugations the session has asked, named in `excluded`, are drawn only once
  /// every other verb has been, so that five more verbs are new for as long as the band lasts.
  static func verbEssentialsSteps(
    verbs: [Verb],
    count: Int,
    excluded: Set<String> = [],
    using generator: inout some RandomNumberGenerator
  ) -> [[QuizDrawnQuestion]] {
    let members: [AblautPracticeGroup.Member] = verbs.compactMap { verb in
      let strong = verb.readings.indices.filter { index in
        verb.reading(at: index).map(isStrong) == true
      }
      return strong.isEmpty ? nil : AblautPracticeGroup.Member(verb: verb, readingIndices: strong)
    }
    return verbEssentialsSteps(members: members, count: count, excluded: excluded, using: &generator)
  }

  /// A round over verbs whose askable readings are already chosen, as an ablaut group's are.
  static func verbEssentialsSteps(
    members: [AblautPracticeGroup.Member],
    count: Int,
    excluded: Set<String> = [],
    using generator: inout some RandomNumberGenerator
  ) -> [[QuizDrawnQuestion]] {
    freshFirst(members, asked: askedInfinitives(excluded), using: &generator)
      .prefix(count)
      .compactMap { step(for: $0, using: &generator) }
  }

  /// The verbs whose key conjugations a session has asked, from its asked items' keys.
  static func askedInfinitives(_ excluded: Set<String>) -> Set<String> {
    Set(excluded.compactMap { PracticeItem(key: $0)?.infinitiv })
  }

  /// The members shuffled, with those the session has asked after the rest.
  static func freshFirst(
    _ members: [AblautPracticeGroup.Member],
    asked: Set<String>,
    using generator: inout some RandomNumberGenerator
  ) -> [AblautPracticeGroup.Member] {
    let fresh = members.filter { !asked.contains($0.verb.infinitiv) }.shuffled(using: &generator)
    let repeated = members.filter { asked.contains($0.verb.infinitiv) }.shuffled(using: &generator)
    return fresh + repeated
  }

  /// A member's step, through one of its readings at random.
  static func step(for member: AblautPracticeGroup.Member, using generator: inout some RandomNumberGenerator) -> [QuizDrawnQuestion]? {
    member.readingIndices.randomElement(using: &generator).map { verbEssentialsStep(verb: member.verb, readingIndex: $0) }
  }
}

extension Quiz {
  /// One of the three rows Verb Essentials shows for a verb.
  struct EssentialsRow: Identifiable {
    enum Content {
      /// Asked earlier in the step, and answered.
      case answered(QuizItem)
      /// The question the answer field asks.
      case current
      /// A re-ask asks only the missed key conjugations, and shows the others as hints.
      case given(String)
      /// Asked later in the step.
      case pending
    }

    let stem: PracticeItem.Stem
    let conjugationgroup: Conjugationgroup
    let content: Content

    var id: PracticeItem.Stem {
      stem
    }
  }

  /// The questions of the current step, which a Verb Essentials verb's three share. Any other
  /// question is a step of its own.
  var currentStepRange: Range<Int> {
    guard currentIndex < questions.count, let stepID = questions[currentIndex].stepID else {
      return currentIndex..<(currentIndex + 1)
    }
    var lower = currentIndex
    while lower > 0, questions[lower - 1].stepID == stepID {
      lower -= 1
    }
    var upper = currentIndex + 1
    while upper < questions.count, questions[upper].stepID == stepID {
      upper += 1
    }
    return lower..<upper
  }

  /// The current verb's three rows, in the verb page's order. Nil unless the question belongs to a
  /// step of Verb Essentials.
  var essentialsRows: [EssentialsRow]? {
    guard scope.isVerbEssentials, let question = currentQuestion, question.stepID != nil else {
      return nil
    }
    let step = currentStepRange
    return PracticeItem.Stem.allCases.map { stem in
      let conjugationgroup = stem.keyConjugationgroup
      guard let index = step.first(where: { questions[$0].conjugationgroup == conjugationgroup }) else {
        let given = RegionalConjugator.conjugateUnsafely(infinitiv: question.verb.infinitiv, conjugationgroup: conjugationgroup, readingIndex: question.readingIndex)
        return EssentialsRow(stem: stem, conjugationgroup: conjugationgroup, content: .given(given))
      }
      let content: EssentialsRow.Content
      if index < currentIndex {
        content = .answered(questions[index])
      } else if index == currentIndex {
        content = .current
      } else {
        content = .pending
      }
      return EssentialsRow(stem: stem, conjugationgroup: conjugationgroup, content: content)
    }
  }

  /// Where a missed question returns, and the step it joins.
  ///
  /// A question shown alone returns after `reaskGap` others. A Verb Essentials blank returns after
  /// the next verb's step, as a step of its own whose other rows are given, so that a re-ask never
  /// lands among another verb's blanks. A second miss in the same verb joins the first's re-ask,
  /// after it, which keeps the verb page's order.
  static func reaskPlacement(of index: Int, in questions: [QuizItem]) -> (position: Int, stepID: UUID?) {
    let question = questions[index]
    guard let stepID = question.stepID else {
      return (min(index + 1 + reaskGap, questions.count), nil)
    }
    let later = questions.indices.dropFirst(index + 1)
    if let joined = later.first(where: { questions[$0].isReask && questions[$0].verb == question.verb && questions[$0].readingIndex == question.readingIndex }),
       let joinedStep = questions[joined].stepID {
      return (stepEnd(from: joined, in: questions, stepID: joinedStep), joinedStep)
    }
    let nextStart = stepEnd(from: index, in: questions, stepID: stepID)
    guard nextStart < questions.count else {
      return (questions.count, UUID())
    }
    return (stepEnd(from: nextStart, in: questions, stepID: questions[nextStart].stepID), UUID())
  }

  /// The index after the last question of the step that holds `index`.
  private static func stepEnd(from index: Int, in questions: [QuizItem], stepID: UUID?) -> Int {
    guard stepID != nil else {
      return index + 1
    }
    return questions.indices.dropFirst(index + 1).first { questions[$0].stepID != stepID } ?? questions.count
  }
}
