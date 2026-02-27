// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct Info: Hashable, Identifiable {
  var id: String { heading }
  let heading: String
  let richTextBlocks: [RichTextBlock]
  let alwaysUsesGermanPronunciation: Bool
  let media: InfoMedia

  private init(heading: String, text: String, alwaysUsesGermanPronunciation: Bool = false, media: InfoMedia) {
    self.heading = heading
    richTextBlocks = text.richTextBlocks
    self.alwaysUsesGermanPronunciation = alwaysUsesGermanPronunciation
    self.media = media
  }

  static let infos: [Info] = [
    Info(heading: L.Info.dedicationHeading, text: L.Info.dedicationText, media: .photo(filename: "CliffSchmiesing", accessibilityLabel: L.ImageInfo.cliffSchmiesing)),
    Info(heading: L.Info.verbHistoryHeading, text: L.Info.verbHistoryText, media: .sfSymbol(name: "book.pages.fill")),
    Info(heading: L.Info.terminologyHeading, text: L.Info.terminologyText, media: .sfSymbol(name: "character.book.closed.fill")),
    Info(heading: L.Info.tenseHeading, text: L.Info.tenseText, media: .sfSymbol(name: "clock.fill")),
    Info(heading: L.Info.moodHeading, text: L.Info.moodText, media: .sfSymbol(name: "theatermasks.fill")),
    Info(heading: L.Info.voiceHeading, text: L.Info.voiceText, media: .sfSymbol(name: "megaphone.fill")),
    Info(heading: L.Info.perfektpartizipHeading, text: L.Info.perfektpartizipText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "checkmark.seal.fill")),
    Info(heading: L.Info.präsenspartizipHeading, text: L.Info.präsenspartizipText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "arrow.forward.circle.fill")),
    Info(heading: L.Info.präsensIndikativHeading, text: L.Info.präsensIndikativText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "sun.max.fill")),
    Info(heading: L.Info.präteritumIndikativHeading, text: L.Info.präteritumIndikativText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "clock.arrow.circlepath")),
    Info(heading: L.Info.präsensKonjunktivIHeading, text: L.Info.präsensKonjunktivIText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "cloud.fill")),
    Info(heading: L.Info.präteritumKonjunktivIIHeading, text: L.Info.präteritumKonjunktivIIText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "cloud.bolt.fill")),
    Info(heading: L.Info.imperativHeading, text: L.Info.imperativText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "exclamationmark.bubble.fill")),
    Info(heading: L.Info.perfektIndikativHeading, text: L.Info.perfektIndikativText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "checkmark.circle.fill")),
    Info(heading: L.Info.perfektKonjunktivIHeading, text: L.Info.perfektKonjunktivIText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "checkmark.diamond.fill")),
    Info(heading: L.Info.plusquamperfektIndikativHeading, text: L.Info.plusquamperfektIndikativText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "clock.badge.checkmark.fill")),
    Info(heading: L.Info.plusquamperfektKonjunktivIIHeading, text: L.Info.plusquamperfektKonjunktivIIText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "arrow.counterclockwise.circle.fill")),
    Info(heading: L.Info.futurIndikativHeading, text: L.Info.futurIndikativText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "forward.fill")),
    Info(heading: L.Info.futurKonjunktivIHeading, text: L.Info.futurKonjunktivIText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "forward.circle.fill")),
    Info(heading: L.Info.futurKonjunktivIIHeading, text: L.Info.futurKonjunktivIIText, alwaysUsesGermanPronunciation: true, media: .sfSymbol(name: "forward.end.fill")),
    Info(heading: L.Info.gameHeading, text: L.Info.gameText, media: .sfSymbol(name: "gamecontroller.fill")),
    Info(heading: L.Info.creditsHeading, text: L.Info.creditsText, media: .photo(filename: "JoshAdams", accessibilityLabel: L.ImageInfo.joshAdams)),
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
