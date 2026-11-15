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

  private var lang: ConjugationgroupLang {
    Current.settings.conjugationgroupLang
  }

  private var reading: Reading {
    question.verb.reading(at: question.readingIndex) ?? question.verb.primaryReading
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      VStack(alignment: .leading, spacing: 6) {
        if let recognition = question.recognition, let answer = correction.recognitionAnswer {
          // Stacked under their labels, since an answer of three parts runs longer than a line.
          VStack(alignment: .leading, spacing: 2) {
            Text(L.Quiz.yourAnswer)
              .foregroundStyle(.customYellow)
            recognitionGivenText(answer)
              .font(.title3)
              .fixedSize(horizontal: false, vertical: true)
          }
          VStack(alignment: .leading, spacing: 2) {
            Text(L.Quiz.correctAnswer)
              .foregroundStyle(.customYellow)
            ForEach(recognition.answerLines(lang: lang), id: \.self) { line in
              Text(verbatim: line)
                .font(.title3)
                .foregroundStyle(.customYellow)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
        } else {
          answerRow(label: L.Quiz.yourAnswer, text: Self.givenText(difference))
          answerRow(label: L.Quiz.correctAnswer, text: Self.expectedText(difference))
        }
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(spokenCorrection)
      .accessibilityHint(L.Accessibility.quizCorrectionHint)
      .accessibilityFocused(accessibilityIsFocused)
      .accessibilityIdentifier("quiz_correction")

      // The sentence read whole, with the conjugation in place (Phase 18 of the pedagogy plan).
      if let sentence = question.sentence {
        Label {
          Text(verbatim: sentence.completed.inUserRegion)
            .italic()
            .germanPronunciation()
        } icon: {
          Image(systemName: "text.quote")
        }
        .font(.subheadline)
        .foregroundStyle(.customForeground)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityHidden(true)
        .accessibilityIdentifier("quiz_correction_sentence")
      }

      if let diagnosis = correction.diagnosis {
        Label(diagnosis.line, systemImage: "lightbulb.fill")
          .font(.subheadline)
          .foregroundStyle(.customForeground)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityHidden(true)
          .accessibilityIdentifier("quiz_diagnosis")
      }

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
  /// are named only while there are few enough to help, and the diagnosis follows them.
  private var spokenCorrection: String {
    if let recognition = question.recognition, let answer = correction.recognitionAnswer {
      var spoken = L.Accessibility.quizCorrection(
        given: answer.summary(lang: lang).replacingOccurrences(of: " · ", with: ", "),
        expected: recognition.answerLines(lang: lang).map { $0.replacingOccurrences(of: " · ", with: ", ") }.joined(separator: "; ")
      )
      if correction.willBeReasked {
        spoken += " " + L.Quiz.willAskAgain
      }
      return spoken
    }
    var spoken = L.Accessibility.quizCorrection(
      given: difference.given,
      expected: MixedCaseAccessibility.accessibilityLabel(for: difference.expected)
    )
    let letters = difference.expectedMarkedLetters
    if !letters.isEmpty, letters.count <= Self.maxSpokenLetters {
      spoken += " " + L.Accessibility.quizDifferingLetters(letters.joined(separator: ", "))
    }
    if let diagnosis = correction.diagnosis {
      spoken += " " + diagnosis.line
    }
    if let sentence = question.sentence {
      spoken += " " + sentence.completed
    }
    if correction.willBeReasked {
      spoken += " " + L.Quiz.willAskAgain
    }
    return spoken
  }

  private static let maxSpokenLetters = 3

  /// A recognition answer part by part: the infinitive, then the conjugationgroup and the person,
  /// each in red where the grade found it wrong. A wrong infinitive is red throughout, since one
  /// that lacks letters, as fallen lacks reinfallen's, has nothing of its own to mark.
  private func recognitionGivenText(_ answer: RecognitionAnswer) -> Text {
    let wrong = correction.recognitionGrade?.wrongParts ?? Set(RecognitionPart.allCases)
    var result = AttributedString()
    if wrong.contains(.infinitive) {
      var infinitive = Self.givenAttributedText(difference)
      infinitive.foregroundColor = .customRed
      result.append(infinitive)
    } else {
      var infinitive = AttributedString(AnswerSpelling.normalized(answer.infinitiv))
      infinitive.foregroundColor = .customForeground
      result.append(infinitive)
    }
    let parts: [(String, RecognitionPart)] = [(answer.table.representative.displayName(lang: lang), .conjugationgroup)]
      + (answer.personNumber.map { [(RecognitionQuestion.personLabel($0, in: answer.table), .person)] } ?? [])
    for (text, part) in parts {
      var separator = AttributedString(" · ")
      separator.foregroundColor = .secondary
      result.append(separator)
      var piece = AttributedString(text)
      piece.foregroundColor = wrong.contains(part) ? .customRed : .customForeground
      if wrong.contains(part) {
        piece.strikethroughStyle = Text.LineStyle(pattern: .solid, color: .customRed)
      }
      result.append(piece)
    }
    return Text(result)
  }

  // The red letters of a conjugation mark its irregularity, so a difference is shown another
  // way: a tinted background, struck through in the learner's answer and underlined in the right
  // one.
  static func givenText(_ difference: AnswerDifference) -> Text {
    Text(givenAttributedText(difference))
  }

  private static func givenAttributedText(_ difference: AnswerDifference) -> AttributedString {
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
    return result
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
