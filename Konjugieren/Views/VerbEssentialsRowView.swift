// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// A row of Verb Essentials other than the one the answer field asks: a key conjugation already
/// answered, with how it went, one given as a hint in a re-ask, or one still to come. The answer
/// field's own row is drawn by `QuizView`, which keeps the field in one place in its hierarchy so
/// that the keyboard stays up as the field moves down the rows.
struct VerbEssentialsRowView: View {
  let row: Quiz.EssentialsRow
  /// The question's frame, for the pronoun in front of the conjugation: er, or sie (3s).
  let frame: AnswerFrame
  let lang: ConjugationgroupLang

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      VerbEssentialsRowLabel(conjugationgroup: row.conjugationgroup, lang: lang)

      HStack(spacing: Layout.defaultSpacing) {
        VerbEssentialsFrameLead(frame: frame)
        content
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(spokenRow)
  }

  @ViewBuilder
  private var content: some View {
    switch row.content {
    case .answered(let item):
      Text(mixedCaseString: item.correctAnswer)
        .foregroundStyle(.customForeground)
      Spacer(minLength: 0)
      if let systemImage = Self.systemImage(for: item.state) {
        Image(systemName: systemImage)
          .foregroundStyle(item.state.dotColor)
      }
    case .given(let conjugation):
      Text(mixedCaseString: conjugation)
        .foregroundStyle(.secondary)
      Spacer(minLength: 0)
    case .pending:
      Text(verbatim: " ")
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .overlay {
          RoundedRectangle(cornerRadius: 6)
            .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
        }
    case .current:
      EmptyView()
    }
  }

  private static func systemImage(for state: QuizItem.State) -> String? {
    switch state {
    case .correct, .correctOnSecondAttempt:
      return "checkmark.circle.fill"
    case .incorrect:
      return "xmark.circle.fill"
    case .unanswered:
      return nil
    }
  }

  /// "Präsens Indikativ, er fährt, right", or for a row to come, "Perfekt Indikativ, er, not yet
  /// asked".
  private var spokenRow: String {
    let name = row.conjugationgroup.displayName(lang: lang)
    let pronoun = VerbEssentialsFrameLead.spokenLead(of: frame)
    switch row.content {
    case .answered(let item):
      let conjugation = "\(pronoun) \(MixedCaseAccessibility.accessibilityLabel(for: item.correctAnswer))"
      return [name, conjugation, Self.spokenState(item.state)].compactMap { $0 }.joined(separator: ", ")
    case .given(let conjugation):
      return "\(name), \(pronoun) \(MixedCaseAccessibility.accessibilityLabel(for: conjugation))"
    case .pending:
      return "\(name), \(pronoun), \(L.Accessibility.verbEssentialsNotYet)"
    case .current:
      return name
    }
  }

  private static func spokenState(_ state: QuizItem.State) -> String? {
    switch state {
    case .correct:
      return L.Accessibility.verbEssentialsRight
    case .correctOnSecondAttempt:
      return L.Accessibility.verbEssentialsRightSecondTry
    case .incorrect:
      return L.Accessibility.verbEssentialsWrong
    case .unanswered:
      return nil
    }
  }
}

/// The conjugationgroup a row asks, above its conjugation, in the learner's chosen language.
struct VerbEssentialsRowLabel: View {
  let conjugationgroup: Conjugationgroup
  let lang: ConjugationgroupLang

  var body: some View {
    Text(verbatim: conjugationgroup.displayName(lang: lang))
      .font(.subheadline)
      .foregroundStyle(.customYellow)
      .germanPronunciation(forReal: lang == .german)
  }
}

/// The words of a frame in front of its blank, which a row shows before its conjugation as the
/// answer field shows them before the field: er, or sie (3s).
struct VerbEssentialsFrameLead: View {
  let frame: AnswerFrame

  var body: some View {
    HStack(spacing: Layout.defaultSpacing / 2) {
      ForEach(Array(Self.lead(of: frame).enumerated()), id: \.offset) { _, segment in
        switch segment {
        case .number(let isPlural):
          Text(verbatim: isPlural ? "(3p)" : "(3s)")
            .font(.caption)
            .foregroundStyle(.secondary)
        case .addressee(let text), .pronoun(let text), .punctuation(let text), .word(let text):
          Text(verbatim: text)
            .fontWeight(.semibold)
            .foregroundStyle(.customForeground)
            .germanPronunciation()
        case .blank:
          EmptyView()
        }
      }
    }
    .fixedSize()
  }

  private static func lead(of frame: AnswerFrame) -> [AnswerFrame.Segment] {
    Array(frame.segments.prefix { $0 != .blank })
  }

  /// The lead as VoiceOver reads it: "er", or "sie, singular".
  static func spokenLead(of frame: AnswerFrame) -> String {
    lead(of: frame).compactMap { segment in
      switch segment {
      case .number(let isPlural):
        return isPlural ? L.Accessibility.quizPlural : L.Accessibility.quizSingular
      case .addressee(let text), .pronoun(let text), .punctuation(let text), .word(let text):
        return text
      case .blank:
        return nil
      }
    }
    .joined(separator: ", ")
  }
}
