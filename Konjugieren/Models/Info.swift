// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct Info: Hashable {
  let heading: String
  let attributedText: NSAttributedString
  let alwaysUsesGermanPronunciation: Bool
  let imageInfo: ImageInfo?

  private init(heading: String, text: String, alwaysUsesGermanPronunciation: Bool = false, imageInfo: ImageInfo? = nil) {
    self.heading = heading
    attributedText = text.attributedText
    self.alwaysUsesGermanPronunciation = alwaysUsesGermanPronunciation
    self.imageInfo = imageInfo
  }
//  TODO: Make sure image is working. Do English strings with subheadings and conjugation text.
  static let infos: [Info] = [
    Info(heading: L.Info.dedicationHeading, text: L.Info.dedicationText, imageInfo: ImageInfo(filename: "JoshAdams", accessibilityLabel: L.ImageInfo.joshAdams)),
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
}
