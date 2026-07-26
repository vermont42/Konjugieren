// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct RichTextView: View {
  let blocks: [RichTextBlock]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(blocks, id: \.self) { block in
        switch block {
        case .subheading(let text):
          HStack(alignment: .center, spacing: 8) {
            Circle()
              .fill(Color.customRed)
              .frame(width: 4, height: 4)
            Text(text)
              .font(.title3.bold())
              .fontDesign(.serif)
              .foregroundStyle(Color.customYellow)
              .accessibilityAddTraits(.isHeader)
          }
          .padding(.top, 8)
          .frame(maxWidth: .infinity, alignment: .leading)

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
    segments.reduce(Text(verbatim: "")) { Text("\($0)\(text(for: $1))") }
      .lineSpacing(4)
  }

  private func text(for segment: TextSegment) -> Text {
    switch segment {
    case .emoji(let content):
      if let assetName = EmojiAsset.assetName(for: content) {
        return Text("\(Image(assetName).renderingMode(.original))")
      }
      return Text(verbatim: content).foregroundStyle(Color.customForeground)
    // The `^...^` markup is not the only way an affected emoji reaches this renderer. Every
    // bullet in a list is a bare country flag (1,522 of them across the catalog, none wrapped
    // and none inside another delimiter), so they arrive as ordinary plain text and would
    // render as tofu pairs on iOS 26. Substituting on the characters here fixes all of them at
    // once, and keeps articles written later from having to remember the markup.
    case .plain(let content) where EmojiAsset.containsMappedEmoji(content):
      return EmojiAsset.text(substitutingIn: content, color: .customForeground)
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
    "\u{1F1E6}\u{1F1F9}": "EmojiAustrianFlag",
    "\u{1F1E8}\u{1F1ED}": "EmojiSwissFlag",
    "\u{1F1E9}\u{1F1EA}": "EmojiGermanFlag",
    "\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}": "EmojiEnglandFlag",
    "\u{1F40E}": "EmojiHorse",
  ]

  static func assetName(for emoji: String) -> String? {
    assetNames[emoji]
  }

  /// Whether `string` holds any emoji this enum can substitute, so a caller can keep its
  /// ordinary rendering path when there is nothing to swap.
  static func containsMappedEmoji(_ string: String) -> Bool {
    string.contains { assetNames[String($0)] != nil }
  }

  /// Renders `string` as `Text`, replacing each emoji this enum has an asset for with that
  /// asset's image.
  ///
  /// The `^...^` markup in `Localizable.xcstrings` cannot serve every case: it is parsed by
  /// `StringExtensions` on the way into long-form `RichTextView` prose, and short UI labels
  /// never go through that parser. A segmented-picker segment reading "North 🇩🇪" and the
  /// auxiliary pill's "haben 🇩🇪 · sein 🇦🇹🇨🇭" both mix words with emoji in a single string,
  /// so substitution here is driven by the characters themselves rather than by markup.
  ///
  /// Each flag is one grapheme cluster, a regional-indicator pair and the England tag
  /// sequence alike, so iterating `Character` values matches whole emoji without any
  /// scalar-level bookkeeping. Non-emoji characters accumulate into runs rather than becoming
  /// one `Text` apiece, which keeps kerning and line breaking intact within each word.
  static func text(substitutingIn string: String, color: Color? = nil) -> Text {
    var result = Text(verbatim: "")
    var pending = ""

    func flushPending() {
      guard !pending.isEmpty else {
        return
      }
      let run = Text(verbatim: pending)
      result = result + (color.map { run.foregroundStyle($0) } ?? run)
      pending = ""
    }

    for character in string {
      if let assetName = assetNames[String(character)] {
        flushPending()
        result = result + Text("\(Image(assetName).renderingMode(.original))")
      } else {
        pending.append(character)
      }
    }
    flushPending()

    return result
  }
}
