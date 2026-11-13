// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// An `AnswerFrame` drawn on one line, with a text field for each blank: `ihr [ ]`, or
/// `[ ] Sie [ ] !`. Return moves to the next empty blank and submits once every blank is filled,
/// and the ä ö ü ß key row inserts into whichever blank has the cursor, as Josh chose on
/// 2026-11-13. Clearing every blank also clears the cursors, so a new question can reuse the
/// fields, and keep the keyboard up, without inheriting a selection from the last answer.
struct AnswerFrameView: View {
  let frame: AnswerFrame
  @Binding var blanks: [String]
  var focusedBlank: FocusState<Int?>.Binding
  var accessibilityFocusedBlank: AccessibilityFocusState<Int?>.Binding
  /// The first blank's accessibility identifier. Later blanks append their position: `_2`.
  let identifier: String
  /// While a wrong answer is held, Return continues from any blank, empty or not.
  var returnAlwaysSubmits = false
  let onSubmit: () -> Void
  @State private var selections: [Int: TextSelection] = [:]

  var body: some View {
    HStack(spacing: 0) {
      // Keyed so that a blank keeps its identity, and the keyboard its focus, when the next
      // question's frame puts a pronoun in front of it.
      ForEach(frame.segments.indices.map(segmentID), id: \.self) { id in
        let offset = frame.segments.indices.first { segmentID(at: $0) == id } ?? 0
        segmentView(frame.segments[offset], blankIndex: blankIndex(ofSegmentAt: offset))
          .padding(.leading, leadingSpace(beforeSegmentAt: offset))
      }
    }
    .onChange(of: blanks) {
      if blanks.allSatisfy(\.isEmpty) {
        selections = [:]
      }
    }
    .toolbar {
      ToolbarItem(placement: .keyboard) {
        GermanLetterKeyRow { letter in
          insertLetter(letter)
        }
      }
    }
  }

  @ViewBuilder
  private func segmentView(_ segment: AnswerFrame.Segment, blankIndex: Int) -> some View {
    switch segment {
    case .blank:
      field(at: blankIndex)
    case .pronoun(let text), .word(let text):
      frameText(text)
        .fontWeight(.semibold)
        .foregroundStyle(.customForeground)
    case .addressee(let addressee):
      frameText("(\(addressee))")
        .foregroundStyle(.secondary)
    case .number(let isPlural):
      frameText(isPlural ? "(3p)" : "(3s)")
        .font(.caption)
        .foregroundStyle(.secondary)
    case .punctuation(let punctuation):
      frameText(punctuation)
        .fontWeight(.semibold)
        .foregroundStyle(.customForeground)
    }
  }

  // Hidden, because each field's label reads the whole frame, so VoiceOver hears it as one
  // prompt instead of a pronoun, a field, and a stray exclamation mark.
  private func frameText(_ text: String) -> some View {
    Text(verbatim: text)
      .fixedSize()
      .germanPronunciation()
      .accessibilityHidden(true)
  }

  private func field(at index: Int) -> some View {
    TextField(frame.blankCount == 1 ? L.Quiz.conjugation : "", text: text(at: index), selection: selection(at: index))
      .textFieldStyle(.roundedBorder)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .focused(focusedBlank, equals: index)
      .accessibilityFocused(accessibilityFocusedBlank, equals: index)
      .accessibilityLabel(spokenPrompt(blankIndex: index))
      .accessibilityHint(L.Accessibility.quizTextFieldHint)
      .accessibilityIdentifier(index == 0 ? identifier : "\(identifier)_\(index + 1)")
      .submitLabel(index == frame.blankCount - 1 ? .go : .next)
      .onSubmit {
        if !returnAlwaysSubmits, let next = frame.blankAfterReturn(from: index, blanks: blanks) {
          focusedBlank.wrappedValue = next
        } else {
          onSubmit()
        }
      }
  }

  /// The frame as VoiceOver reads it: "ihr, blank", or "blank, Sie, blank. Blank 1 of 2."
  private func spokenPrompt(blankIndex: Int) -> String {
    let parts: [String] = frame.segments.compactMap { segment in
      switch segment {
      case .blank:
        return L.Accessibility.quizBlank
      case .pronoun(let text), .word(let text), .addressee(let text):
        return text
      case .number(let isPlural):
        return isPlural ? L.Accessibility.quizPlural : L.Accessibility.quizSingular
      case .punctuation:
        return nil
      }
    }
    let prompt = parts.joined(separator: ", ")
    guard frame.blankCount > 1 else {
      return prompt
    }
    return "\(prompt). \(L.Accessibility.quizBlankPosition(blankIndex + 1, frame.blankCount))"
  }

  /// An exclamation mark sits against the word it ends, as in Sie!, and a little apart from a
  /// field, whose border would otherwise touch it. The (3s) or (3p) after sie stays close to the
  /// pronoun it qualifies.
  private func leadingSpace(beforeSegmentAt offset: Int) -> CGFloat {
    guard offset > 0 else {
      return 0
    }
    switch frame.segments[offset] {
    case .punctuation:
      return frame.segments[offset - 1] == .blank ? Layout.defaultSpacing / 2 : 0
    case .number:
      return Layout.defaultSpacing / 2
    case .addressee, .blank, .pronoun, .word:
      return Layout.defaultSpacing
    }
  }

  private func segmentID(at offset: Int) -> String {
    frame.segments[offset] == .blank ? "blank\(blankIndex(ofSegmentAt: offset))" : "text\(offset)"
  }

  private func blankIndex(ofSegmentAt offset: Int) -> Int {
    frame.segments[..<offset].filter { $0 == .blank }.count
  }

  private func text(at index: Int) -> Binding<String> {
    Binding(
      get: { blanks.indices.contains(index) ? blanks[index] : "" },
      set: { newValue in
        while blanks.count <= index {
          blanks.append("")
        }
        blanks[index] = newValue
      }
    )
  }

  private func selection(at index: Int) -> Binding<TextSelection?> {
    Binding(
      get: { selections[index] },
      set: { selections[index] = $0 }
    )
  }

  /// Replaces the focused blank's selection, or inserts at its cursor, and leaves the cursor
  /// after the letter.
  private func insertLetter(_ letter: String) {
    let index = focusedBlank.wrappedValue ?? 0
    var text = text(at: index).wrappedValue
    guard
      case .selection(let range) = selections[index]?.indices,
      range.lowerBound >= text.startIndex,
      range.upperBound <= text.endIndex
    else {
      text.append(letter)
      self.text(at: index).wrappedValue = text
      return
    }
    let offset = text.distance(from: text.startIndex, to: range.lowerBound) + letter.count
    text.replaceSubrange(range, with: letter)
    self.text(at: index).wrappedValue = text
    selections[index] = TextSelection(insertionPoint: text.index(text.startIndex, offsetBy: offset))
  }
}
