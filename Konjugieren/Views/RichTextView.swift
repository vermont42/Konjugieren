// Copyright © 2026 Josh Adams. All rights reserved.

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
            .foregroundStyle(Color.customYellow)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

        case .body(let segments):
          BodyTextView(segments: segments)
        }
      }
    }
  }
}

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
        let markdownLink = "[\(text)](\(url.absoluteString))"
        if let attributedLink = try? AttributedString(markdown: markdownLink) {
          result.append(attributedLink)
        } else {
          var attributed = AttributedString(text)
          attributed.foregroundColor = Color.accentColor
          attributed.underlineStyle = .single
          result.append(attributed)
        }

      case .conjugation(let parts):
        for part in parts {
          switch part {
          case .regular(let text):
            var regularAttr = AttributedString(text)
            regularAttr.foregroundColor = Color.customForeground
            result.append(regularAttr)
          case .irregular(let text):
            var irregularAttr = AttributedString(text)
            irregularAttr.foregroundColor = Color.customRed
            result.append(irregularAttr)
          }
        }
      }
    }

    return result
  }
}
