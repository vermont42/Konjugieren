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
            .font(.system(size: 18, weight: .bold))
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

// MARK: - Body Text View (AttributedString-based)

struct BodyTextView: View {
  let segments: [TextSegment]

  var body: some View {
    Text(buildAttributedString())
  }

  private func buildAttributedString() -> AttributedString {
    var result = AttributedString()

    for segment in segments {
      switch segment {
      case .plain(let text):
        var attributed = AttributedString(text)
        attributed.foregroundColor = Color.customForeground
        result.append(attributed)

      case .bold(let text):
        var attributed = AttributedString(text)
        attributed.inlinePresentationIntent = .stronglyEmphasized
        attributed.foregroundColor = Color.customForeground
        result.append(attributed)

      case .link(let text, let url):
        // Use markdown syntax for tappable links
        let markdownLink = "[\(text)](\(url.absoluteString))"
        if let attributedLink = try? AttributedString(markdown: markdownLink) {
          result.append(attributedLink)
        } else {
          var attributed = AttributedString(text)
          attributed.foregroundColor = Color.accentColor
          attributed.underlineStyle = .single
          result.append(attributed)
        }

      case .conjugation(let regular, let irregular, let trailing):
        var regularAttr = AttributedString(regular)
        regularAttr.foregroundColor = Color.customForeground
        result.append(regularAttr)

        var irregularAttr = AttributedString(irregular)
        irregularAttr.foregroundColor = Color.customRed
        result.append(irregularAttr)

        var trailingAttr = AttributedString(trailing)
        trailingAttr.foregroundColor = Color.customForeground
        result.append(trailingAttr)
      }
    }

    return result
  }
}
