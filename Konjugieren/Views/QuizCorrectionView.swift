// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

extension EnvironmentValues {
  /// True on the pages a quiz pushes over a held correction.
  @Entry var isBeneathQuiz = false
}

/// A wrong answer, held: what the learner typed and the right answer, with the letters that
/// differ marked, links to the verb's page and its ablaut group or family, and Continue.
struct QuizCorrectionView: View {
  let question: QuizItem
  let correction: QuizCorrection
  /// False in a quiz begun from the verb's own page, where a link back to it would be circular.
  let showsVerbLink: Bool
  var accessibilityIsFocused: AccessibilityFocusState<Bool>.Binding
  let onOpen: (any Hashable) -> Void
  let onContinue: () -> Void

  private var difference: AnswerDifference {
    correction.difference
  }

  private var reading: Reading {
    question.verb.reading(at: question.readingIndex) ?? question.verb.primaryReading
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      VStack(alignment: .leading, spacing: 6) {
        answerRow(label: L.Quiz.yourAnswer, text: Self.givenText(difference))
        answerRow(label: L.Quiz.correctAnswer, text: Self.expectedText(difference))
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(spokenCorrection)
      .accessibilityHint(L.Accessibility.quizCorrectionHint)
      .accessibilityFocused(accessibilityIsFocused)
      .accessibilityIdentifier("quiz_correction")

      if correction.willBeReasked {
        Label(L.Quiz.willAskAgain, systemImage: "arrow.counterclockwise")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .accessibilityHidden(true)
          .accessibilityIdentifier("quiz_will_ask_again")
      }

      FlowLayout(spacing: Layout.defaultSpacing) {
        if showsVerbLink {
          link(
            Text(verbatim: question.verb.infinitiv.inUserRegion),
            systemImage: "text.book.closed",
            isGerman: true,
            identifier: "quiz_correction_verb"
          ) {
            onOpen(VerbDestination(
              verb: question.verb,
              source: .quizCorrection,
              marks: MarkedConjugations(readingIndex: question.readingIndex, conjugationgroups: [question.conjugationgroup])
            ))
          }
        }
        groupLink
      }

      Button(action: onContinue) {
        Label(L.Quiz.continueAfterCorrection, systemImage: "arrow.right")
          .frame(maxWidth: Self.continueMaxWidth)
      }
      .funButton()
      .controlSize(.large)
      .frame(maxWidth: .infinity)
      .accessibilityHint(L.Accessibility.quizContinueHint)
      .accessibilityIdentifier("quiz_continue_button")
      .id(Self.continueButtonID)
    }
  }

  static let continueButtonID = "quiz_continue_button"

  // As wide as an iPhone's card, and no wider on an iPad, where the card spans the screen.
  private static let continueMaxWidth: CGFloat = 400

  // A strong or mixed verb links to its ablaut group, which shows the verbs that change their
  // vowels the same way. A weak verb has none, so it links to its family.
  @ViewBuilder
  private var groupLink: some View {
    if let ablautGroup = reading.ablautGroup {
      link(
        Text(L.VerbCollection.ablautGroupTitle(ablautGroup.inUserRegion)),
        systemImage: BrowseableFamily.ablaut.systemImageName,
        isGerman: UserLocale.isGerman,
        identifier: "quiz_correction_group"
      ) {
        onOpen(VerbCollectionRequest(collection: .ablautGroup(ablautGroup), source: .quizCorrection))
      }
    } else if let family = BrowseableFamily.families(of: reading).first {
      link(
        Text(family.displayName),
        systemImage: family.systemImageName,
        isGerman: UserLocale.isGerman,
        identifier: "quiz_correction_group"
      ) {
        onOpen(family)
      }
    }
  }

  private func answerRow(label: String, text: Text) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      Text(label + " ")
        .foregroundStyle(.customYellow)
        .fixedSize(horizontal: true, vertical: false)
      text
        .font(.title3)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private func link(_ text: Text, systemImage: String, isGerman: Bool, identifier: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Label {
        text
      } icon: {
        Image(systemName: systemImage)
      }
      .font(.subheadline)
      .foregroundStyle(.customYellow)
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(Color.customYellow.opacity(0.08), in: Capsule())
    }
    .buttonStyle(.plain)
    .germanPronunciation(forReal: isGerman)
    .accessibilityHint(L.Accessibility.quizCorrectionLinkHint)
    .accessibilityIdentifier(identifier)
  }

  /// "Incorrect. Your answer: fahrt. Correct answer: fährt. Letters that differ: ä." The letters
  /// are named only while there are few enough to help.
  private var spokenCorrection: String {
    var spoken = L.Accessibility.quizCorrection(
      given: difference.given,
      expected: MixedCaseAccessibility.accessibilityLabel(for: difference.expected)
    )
    let letters = difference.expectedMarkedLetters
    if !letters.isEmpty, letters.count <= Self.maxSpokenLetters {
      spoken += " " + L.Accessibility.quizDifferingLetters(letters.joined(separator: ", "))
    }
    if correction.willBeReasked {
      spoken += " " + L.Quiz.willAskAgain
    }
    return spoken
  }

  private static let maxSpokenLetters = 3

  // The red letters of a conjugation mark its irregularity, so a difference is shown another
  // way: a tinted background, struck through in the learner's answer and underlined in the right
  // one.
  static func givenText(_ difference: AnswerDifference) -> Text {
    var result = AttributedString()
    for (character, isMarked) in zip(Array(difference.given), difference.givenMarks) {
      var part = AttributedString(String(character))
      part.foregroundColor = .customForeground
      if isMarked {
        part.foregroundColor = .customRed
        part.backgroundColor = Color.customRed.opacity(0.3)
        part.strikethroughStyle = Text.LineStyle(pattern: .solid, color: .customRed)
      }
      result.append(part)
    }
    return Text(result)
  }

  static func expectedText(_ difference: AnswerDifference) -> Text {
    var result = AttributedString()
    var marks = difference.expectedMarks.makeIterator()
    for segment in MixedCaseSegmenter.segments(for: difference.expected) {
      for character in segment.text {
        var part = AttributedString(String(character))
        part.foregroundColor = segment.isIrregular ? .customRed : .customYellow
        if marks.next() == true {
          part.backgroundColor = Color.green.opacity(0.35)
          part.underlineStyle = Text.LineStyle(pattern: .solid, color: .green)
        }
        result.append(part)
      }
    }
    return Text(result)
  }
}
