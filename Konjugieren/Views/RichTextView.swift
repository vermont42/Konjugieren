// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct RichTextView: View {
  let blocks: [RichTextBlock]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
        switch block {
        case .subheading(let text):
          Text(text)
            .font(.custom(workSansSemiBold, size: 18))
            .foregroundStyle(Color.customForeground)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

        case .body(let segments):
          BodyTextView(segments: segments)
        }
      }
    }
  }
}

// MARK: - Body Text View (Text Concatenation)

struct BodyTextView: View {
  let segments: [TextSegment]

  var body: some View {
    buildText()
  }

  private func buildText() -> Text {
    var result = Text("")

    for segment in segments {
      switch segment {
      case .plain(let text):
        result = result + Text(text)
          .foregroundColor(.customForeground)

      case .bold(let text):
        result = result + Text(text)
          .bold()
          .foregroundColor(.customForeground)

      case .link(let text, let url):
        // Use markdown syntax for tappable links
        let markdownLink = "[\(text)](\(url.absoluteString))"
        if let attributedLink = try? AttributedString(markdown: markdownLink) {
          result = result + Text(attributedLink)
        } else {
          result = result + Text(text)
            .foregroundColor(.accentColor)
            .underline()
        }

      case .conjugation(let regular, let irregular, let trailing):
        result = result +
          Text(regular).foregroundColor(.customForeground) +
          Text(irregular).foregroundColor(.customRed) +
          Text(trailing).foregroundColor(.customForeground)
      }
    }

    return result
  }
}
