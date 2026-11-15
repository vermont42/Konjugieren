// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// A recognition question's prompt, the conjugation to name, shown with its ablaut in red.
struct RecognitionPromptView: View {
  let prompt: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(L.Recognition.promptHeading)
        .font(.subheadline)
        .foregroundStyle(.customYellow)
        .accessibilityHidden(true)

      Text(mixedCaseString: prompt)
        .font(.largeTitle.bold())
        .fixedSize(horizontal: false, vertical: true)
        .germanPronunciation()
        .speakOnTap(prompt.lowercased())
        .accessibilityLabel(Text(verbatim: MixedCaseAccessibility.accessibilityLabel(for: prompt)))
        .accessibilityHint(L.Recognition.promptHeading)
        .accessibilityIdentifier("recognition_prompt")
    }
  }
}

/// The level's conjugationgroups and then the chosen table's persons, as chips. A participle has
/// no person, so its row of persons disappears, and a person that the newly chosen table lacks,
/// such as ich in the Imperativ, is cleared.
struct RecognitionChoicesView: View {
  let recognition: RecognitionQuestion
  @Binding var table: ConjugationTable?
  @Binding var personNumber: PersonNumber?
  let lang: ConjugationgroupLang
  /// True while a correction holds, when the choices stay as answered.
  let isLocked: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      heading(L.Recognition.conjugationgroupHeading)

      FlowLayout(spacing: Layout.defaultSpacing) {
        ForEach(recognition.tables, id: \.self) { choice in
          chip(
            choice.representative.displayName(lang: lang),
            isSelected: table == choice,
            isGerman: lang == .german,
            identifier: "recognition_table_\(choice.articleKey)"
          ) {
            table = choice
            if let personNumber, !RecognitionQuestion.persons(of: choice).contains(personNumber) {
              self.personNumber = nil
            }
          }
        }
      }

      if let table, !RecognitionQuestion.persons(of: table).isEmpty {
        heading(L.Recognition.personHeading)
          .padding(.top, 4)

        FlowLayout(spacing: Layout.defaultSpacing) {
          ForEach(RecognitionQuestion.persons(of: table), id: \.self) { choice in
            chip(
              RecognitionQuestion.personLabel(choice, in: table),
              isSelected: personNumber == choice,
              isGerman: true,
              identifier: "recognition_person_\(choice.rawValue)"
            ) {
              personNumber = choice
            }
          }
        }
      }
    }
    .disabled(isLocked)
    .sensoryFeedback(.selection, trigger: table)
    .sensoryFeedback(.selection, trigger: personNumber)
  }

  private func heading(_ text: String) -> some View {
    Text(text)
      .font(.subheadline.bold())
      .foregroundStyle(.customYellow)
      .accessibilityAddTraits(.isHeader)
  }

  private func chip(_ text: String, isSelected: Bool, isGerman: Bool, identifier: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(verbatim: text)
        .font(.subheadline)
        .foregroundStyle(isSelected ? Color.customBackground : Color.customYellow)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(isSelected ? Color.customYellow : Color.customYellow.opacity(0.08), in: Capsule())
        .overlay {
          Capsule()
            .strokeBorder(Color.customYellow.opacity(isSelected ? 0 : 0.35), lineWidth: 1)
        }
        .contentShape(Capsule())
    }
    .buttonStyle(.plain)
    .germanPronunciation(forReal: isGerman)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .accessibilityIdentifier(identifier)
  }
}
