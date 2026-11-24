// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct Info: Hashable, Identifiable {
  var id: String { stableKey }
  let stableKey: String
  let heading: String
  let richTextBlocks: [RichTextBlock]
  let alwaysUsesGermanPronunciation: Bool
  let media: InfoMedia

  private init(stableKey: String, heading: String, text: String, media: InfoMedia, alwaysUsesGermanPronunciation: Bool = false) {
    self.stableKey = stableKey
    self.heading = heading
    richTextBlocks = text.richTextBlocks
    self.alwaysUsesGermanPronunciation = alwaysUsesGermanPronunciation
    self.media = media
  }

  static let infos: [Info] = [
    Info(stableKey: "dedication", heading: L.Info.dedicationHeading, text: L.Info.dedicationText, media: .photo(filename: "CliffSchmiesing", accessibilityLabel: L.ImageInfo.cliffSchmiesing)),
    Info(stableKey: "verb_history", heading: L.Info.verbHistoryHeading, text: L.Info.verbHistoryText, media: .sfSymbol(name: "book.pages.fill")),
    Info(stableKey: "terminology", heading: L.Info.terminologyHeading, text: L.Info.terminologyText, media: .sfSymbol(name: "character.book.closed.fill")),
    Info(stableKey: "tense", heading: L.Info.tenseHeading, text: L.Info.tenseText, media: .sfSymbol(name: "clock.fill")),
    Info(stableKey: "mood", heading: L.Info.moodHeading, text: L.Info.moodText, media: .sfSymbol(name: "theatermasks.fill")),
    Info(stableKey: "voice", heading: L.Info.voiceHeading, text: L.Info.voiceText, media: .sfSymbol(name: "megaphone.fill")),
    Info(stableKey: "perfektpartizip", heading: L.Info.perfektpartizipHeading, text: L.Info.perfektpartizipText, media: .sfSymbol(name: "checkmark.seal.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "praesenspartizip", heading: L.Info.präsenspartizipHeading, text: L.Info.präsenspartizipText, media: .sfSymbol(name: "arrow.forward.circle.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "praesens_indikativ", heading: L.Info.präsensIndikativHeading, text: L.Info.präsensIndikativText, media: .sfSymbol(name: "sun.max.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "praeteritum_indikativ", heading: L.Info.präteritumIndikativHeading, text: L.Info.präteritumIndikativText, media: .sfSymbol(name: "clock.arrow.circlepath"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "praesens_konjunktiv_i", heading: L.Info.präsensKonjunktivIHeading, text: L.Info.präsensKonjunktivIText, media: .sfSymbol(name: "cloud.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "praeteritum_konjunktiv_ii", heading: L.Info.präteritumKonjunktivIIHeading, text: L.Info.präteritumKonjunktivIIText, media: .sfSymbol(name: "cloud.bolt.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "imperativ", heading: L.Info.imperativHeading, text: L.Info.imperativText, media: .sfSymbol(name: "exclamationmark.bubble.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "perfekt_indikativ", heading: L.Info.perfektIndikativHeading, text: L.Info.perfektIndikativText, media: .sfSymbol(name: "checkmark.circle.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "perfekt_konjunktiv_i", heading: L.Info.perfektKonjunktivIHeading, text: L.Info.perfektKonjunktivIText, media: .sfSymbol(name: "checkmark.diamond.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "plusquamperfekt_indikativ", heading: L.Info.plusquamperfektIndikativHeading, text: L.Info.plusquamperfektIndikativText, media: .sfSymbol(name: "clock.badge.checkmark.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "plusquamperfekt_konjunktiv_ii", heading: L.Info.plusquamperfektKonjunktivIIHeading, text: L.Info.plusquamperfektKonjunktivIIText, media: .sfSymbol(name: "arrow.counterclockwise.circle.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "futur_indikativ", heading: L.Info.futurIndikativHeading, text: L.Info.futurIndikativText, media: .sfSymbol(name: "forward.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "futur_konjunktiv_i", heading: L.Info.futurKonjunktivIHeading, text: L.Info.futurKonjunktivIText, media: .sfSymbol(name: "forward.circle.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "futur_konjunktiv_ii", heading: L.Info.futurKonjunktivIIHeading, text: L.Info.futurKonjunktivIIText, media: .sfSymbol(name: "forward.end.fill"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "futur_ii", heading: L.Info.futurIIHeading, text: L.Info.futurIIText, media: .sfSymbol(name: "flag.checkered"), alwaysUsesGermanPronunciation: true),
    Info(stableKey: "duden", heading: L.Info.dudenHeading, text: L.Info.dudenText, media: .sfSymbol(name: "books.vertical.fill")),
    Info(stableKey: "game", heading: L.Info.gameHeading, text: L.Info.gameText, media: .sfSymbol(name: "gamecontroller.fill")),
    Info(stableKey: "credits", heading: L.Info.creditsHeading, text: L.Info.creditsText, media: .photo(filename: "JoshAdams", accessibilityLabel: L.ImageInfo.joshAdams))
  ]

  /// The article an `info/` deeplink names: by stable key, or by position in `infos`, which
  /// links built before 2026-11-12 used.
  static func info(deeplinkTarget target: String) -> Info? {
    if let info = infos.first(where: { $0.stableKey == target }) {
      return info
    }
    if let index = Int(target), infos.indices.contains(index) {
      return infos[index]
    }
    return nil
  }

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
        guard !segments.isEmpty else {
          return segments
        }
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
