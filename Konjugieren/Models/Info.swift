// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct Info: Hashable {
  let heading: String
  let richTextBlocks: [RichTextBlock]
  let alwaysUsesGermanPronunciation: Bool
  let imageInfo: ImageInfo?

  private init(heading: String, text: String, alwaysUsesGermanPronunciation: Bool = false, imageInfo: ImageInfo? = nil) {
    self.heading = heading
    richTextBlocks = text.richTextBlocks
    self.alwaysUsesGermanPronunciation = alwaysUsesGermanPronunciation
    self.imageInfo = imageInfo
  }

  static let infos: [Info] = [
    Info(heading: L.Info.dedicationHeading, text: L.Info.dedicationText, imageInfo: ImageInfo(filename: "CliffSchmiesing", accessibilityLabel: L.ImageInfo.cliffSchmiesing)),
    Info(heading: L.Info.verbHistoryHeading, text: L.Info.verbHistoryText),
    Info(heading: L.Info.terminologyHeading, text: L.Info.terminologyText),
    Info(heading: L.Info.perfektpartizipHeading, text: L.Info.perfektpartizipText, alwaysUsesGermanPronunciation: true),
    Info(heading: L.Info.präsenspartizipHeading, text: L.Info.präsenspartizipText, alwaysUsesGermanPronunciation: true),
    Info(heading: L.Info.präsensIndikativHeading, text: L.Info.präsensIndikativText, alwaysUsesGermanPronunciation: true),
    Info(heading: L.Info.präteritumIndikativHeading, text: L.Info.präteritumIndikativText, alwaysUsesGermanPronunciation: true),
    Info(heading: L.Info.präsensKonjunktivIHeading, text: L.Info.präsensKonjunktivIText, alwaysUsesGermanPronunciation: true),
    Info(heading: L.Info.präteritumKonditionalHeading, text: L.Info.präteritumKonditionalText, alwaysUsesGermanPronunciation: true),
    Info(heading: L.Info.imperativHeading, text: L.Info.imperativText, alwaysUsesGermanPronunciation: true),
    Info(heading: L.Info.perfektIndikativHeading, text: L.Info.perfektIndikativText, alwaysUsesGermanPronunciation: true),
    Info(heading: L.Info.perfektKonjunktivIHeading, text: L.Info.perfektKonjunktivIText, alwaysUsesGermanPronunciation: true),
    Info(heading: L.Info.questionsAndAnwersHeading, text: L.Info.questionsAndAnwersText),
    Info(heading: L.Info.creditsHeading, text: L.Info.creditsText, imageInfo: ImageInfo(filename: "JoshAdams", accessibilityLabel: L.ImageInfo.joshAdams)),
  ]

  static func headingToIndex(heading: String) -> Int? {
    for (i, info) in infos.enumerated() {
      if info.heading.lowercased() == heading.lowercased() {
        return i
      }
    }

    return nil
  }

  var previewSegments: [TextSegment] {
    for block in richTextBlocks {
      if case .body(let segments) = block {
        // Strip leading newlines from the first segment if it's plain text
        guard !segments.isEmpty else { return segments }
        var result = segments
        if case .plain(let text) = result[0] {
          let trimmed = text.trimmingLeadingNewlines()
          result[0] = .plain(trimmed)
        }
        return result
      }
    }
    return []
  }

  var hasPreview: Bool {
    !previewSegments.isEmpty
  }
}
