// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// A choice question's two sentences, each with its conjugation highlighted and its
/// conjugationgroup named beneath, and, once one is chosen, the reason and Continue (Phase 19 of
/// the pedagogy plan).
struct ChoiceQuestionView: View {
  let choice: ChoicePrompt
  /// The chosen sentence, once the learner has chosen.
  let chosenOption: Int?
  let lang: ConjugationgroupLang
  var reasonIsFocused: AccessibilityFocusState<Bool>.Binding
  let onChoose: (Int) -> Void
  let onContinue: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text(L.Choice.prompt)
        .font(.subheadline.bold())
        .foregroundStyle(.customYellow)
        .accessibilityAddTraits(.isHeader)

      ForEach(Array(choice.options.enumerated()), id: \.offset) { index, option in
        optionButton(option, index: index)
      }

      Text(verbatim: choice.question.english)
        .font(.subheadline)
        .italic()
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
        .englishPronunciation()
        .accessibilityIdentifier("choice_english")

      if chosenOption != nil {
        Label(choice.question.reasonLine(lang: lang), systemImage: "lightbulb.fill")
          .font(.subheadline)
          .foregroundStyle(.customForeground)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityFocused(reasonIsFocused)
          .accessibilityIdentifier("choice_reason")

        Button(action: onContinue) {
          Label(L.Quiz.continueAfterCorrection, systemImage: "arrow.right")
            .frame(maxWidth: 400)
        }
        .funButton()
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        // Return continues from a hardware keyboard, as it does from a correction's field.
        .keyboardShortcut(.defaultAction)
        .accessibilityHint(L.Accessibility.quizContinueHint)
        .accessibilityIdentifier("quiz_continue_button")
        .id(QuizCorrectionView.continueButtonID)
      }
    }
  }

  private func optionButton(_ option: GapSentence, index: Int) -> some View {
    let isRight = index == choice.rightIndex
    let isChosen = index == chosenOption
    let isAnswered = chosenOption != nil
    let name = option.conjugationgroup?.displayName(lang: lang) ?? ""
    let borderColor: Color = !isAnswered ? .customCardBorder : isRight ? .green : isChosen ? .customRed : .customCardBorder

    return Button {
      onChoose(index)
    } label: {
      VStack(alignment: .leading, spacing: 6) {
        HStack(alignment: .firstTextBaseline) {
          Self.sentenceText(option.german)
            .font(.title3)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .germanPronunciation()
          Spacer(minLength: 0)
          if isAnswered, isRight || isChosen {
            Image(systemName: isRight ? "checkmark.circle.fill" : "xmark.circle.fill")
              .foregroundStyle(isRight ? .green : .customRed)
              .font(.title3)
          }
        }
        Text(verbatim: name)
          .font(.caption)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .trailing)
          .germanPronunciation(forReal: lang == .german)
      }
      .padding(12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.customBackground.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .strokeBorder(borderColor, lineWidth: isAnswered && (isRight || isChosen) ? 2 : 1)
      )
      .opacity(isAnswered && !isRight && !isChosen ? 0.6 : 1)
    }
    .buttonStyle(.plain)
    // Not disabled, which would dim the right sentence just when the learner should read it.
    .allowsHitTesting(!isAnswered)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(verbatim: "\(option.completed.inUserRegion) \(name)"))
    .accessibilityValue(Self.accessibilityValue(isRight: isRight, isChosen: isChosen, isAnswered: isAnswered))
    .accessibilityHint(isAnswered ? "" : L.Accessibility.choiceOptionHint)
    .accessibilityAddTraits(.isButton)
    .accessibilityIdentifier("choice_option_\(index)")
  }

  private static func accessibilityValue(isRight: Bool, isChosen: Bool, isAnswered: Bool) -> String {
    guard isAnswered else {
      return ""
    }
    return [isChosen ? L.Choice.yourChoice : nil, isRight ? L.Choice.rightChoice : nil].compactMap { $0 }.joined(separator: ", ")
  }

  /// The sentence with its braced words, the conjugation, in bold yellow.
  static func sentenceText(_ german: String) -> Text {
    var result = AttributedString()
    var piece = ""
    func flush(isConjugation: Bool) {
      guard !piece.isEmpty else {
        return
      }
      var part = AttributedString(piece.inUserRegion)
      part.foregroundColor = isConjugation ? .customYellow : .customForeground
      if isConjugation {
        part.inlinePresentationIntent = .stronglyEmphasized
      }
      result.append(part)
      piece = ""
    }
    for character in german {
      switch character {
      case "{":
        flush(isConjugation: false)
      case "}":
        flush(isConjugation: true)
      default:
        piece.append(character)
      }
    }
    flush(isConjugation: false)
    return Text(result)
  }
}
