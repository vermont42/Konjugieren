// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

// customYellow: light #665300, dark #FFCE00
// customRed: #DD0000

private let widgetYellowLight = Color(red: 0x66 / 255.0, green: 0x53 / 255.0, blue: 0x00 / 255.0)
private let widgetYellowDark = Color(red: 0xFF / 255.0, green: 0xCE / 255.0, blue: 0x00 / 255.0)
private let widgetRed = Color(red: 0xDD / 255.0, green: 0x00 / 255.0, blue: 0x00 / 255.0)

extension Text {
  init(widgetEtymology etymologyString: String) {
    var attributedString = AttributedString()
    let segments = etymologyString.components(separatedBy: "~")
    for (index, segment) in segments.enumerated() {
      var part = AttributedString(segment)
      if index % 2 == 1 {
        part.inlinePresentationIntent = .stronglyEmphasized
      }
      attributedString.append(part)
    }
    self.init(attributedString)
  }

  init(widgetMixedCase mixedCaseString: String, colorScheme: ColorScheme) {
    let widgetYellow = colorScheme == .dark ? widgetYellowDark : widgetYellowLight
    var attributedString = AttributedString()
    for segment in MixedCaseSegmenter.segments(for: mixedCaseString) {
      var part = AttributedString(segment.text)
      part.foregroundColor = segment.isIrregular ? widgetRed : widgetYellow
      attributedString.append(part)
    }
    self.init(attributedString)
  }
}
