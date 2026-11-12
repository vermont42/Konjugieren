// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// The letters an English keyboard lacks, to show above the keyboard. The caller decides where a
/// letter goes, so a field that tracks its selection can insert at the cursor.
struct GermanLetterKeyRow: View {
  static let letters = ["ä", "ö", "ü", "ß"]

  let insert: (String) -> Void

  var body: some View {
    HStack(spacing: Layout.defaultSpacing) {
      ForEach(Self.letters, id: \.self) { letter in
        Button {
          insert(letter)
        } label: {
          Text(verbatim: letter)
            .font(.title3)
            .foregroundStyle(Color.customYellow)
            .frame(minWidth: 44, minHeight: 32)
        }
        .buttonStyle(.bordered)
        .germanPronunciation()
        .accessibilityIdentifier("german_letter_key_\(letter)")
      }
    }
  }
}

#Preview {
  GermanLetterKeyRow { _ in }
}
