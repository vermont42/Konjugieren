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
    Info(heading: L.Info.dedicationHeading, text: L.Info.dedicationText, imageInfo: ImageInfo(filename: "JoshAdams", accessibilityLabel: L.ImageInfo.joshAdams)),
    Info(heading: L.Info.aboutHeading, text: L.Info.aboutText),
    Info(heading: L.Info.präsensIndicativHeading, text: L.Info.präsensIndicativText),
    Info(heading: L.Info.perfektpartizipHeading, text: L.Info.perfektpartizipText, alwaysUsesGermanPronunciation: true),
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
        return segments
      }
    }
    return []
  }

  var hasPreview: Bool {
    !previewSegments.isEmpty
  }
}
