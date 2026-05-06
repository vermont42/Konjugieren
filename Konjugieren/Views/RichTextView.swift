// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct RichTextView: View {
  let blocks: [RichTextBlock]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(blocks, id: \.self) { block in
        switch block {
        case .subheading(let text):
          Text(text)
            .font(.headline)
            .foregroundStyle(Color.customYellow)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)

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
    segments.reduce(Text(verbatim: "")) { $0 + text(for: $1) }
      .lineSpacing(4)
  }

  private func text(for segment: TextSegment) -> Text {
    switch segment {
    case .emoji(let content):
      if let assetName = EmojiAsset.assetName(for: content) {
        return Text("\(Image(assetName).renderingMode(.original))")
      }
      return Text(verbatim: content).foregroundStyle(Color.customForeground)
    default:
      return Text(attributedString(for: segment))
    }
  }

  private func attributedString(for segment: TextSegment) -> AttributedString {
    switch segment {
    case .plain(let text):
      var attributed = AttributedString(text)
      attributed.foregroundColor = Color.customForeground
      return attributed

    case .bold(let text):
      var attributed = AttributedString(text)
      attributed.inlinePresentationIntent = .stronglyEmphasized
      attributed.foregroundColor = Color.customForeground
      return attributed

    case .link(let text, let url):
      let markdownLink = "[\(text)](\(url.absoluteString))"
      if let attributedLink = try? AttributedString(markdown: markdownLink) {
        return attributedLink
      }
      var attributed = AttributedString(text)
      attributed.foregroundColor = Color.accentColor
      attributed.underlineStyle = .single
      return attributed

    case .conjugation(let parts):
      var result = AttributedString()
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
      return result

    case .emoji(let text):
      var attributed = AttributedString(text)
      attributed.foregroundColor = Color.customForeground
      return attributed
    }
  }
}

enum EmojiAsset {
  private static let assetNames: [String: String] = [
    "\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}": "EmojiEnglandFlag",
    "\u{1F40E}": "EmojiHorse",
  ]

  static func assetName(for emoji: String) -> String? {
    assetNames[emoji]
  }
}
