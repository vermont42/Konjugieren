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
    enum ColorParsingState {
      case notStarted
      case inRegularPart
      case inIrregularPart
    }

    let widgetYellow = colorScheme == .dark ? widgetYellowDark : widgetYellowLight
    var attributedString = AttributedString()
    var state = ColorParsingState.notStarted
    var currentRegularPart = ""
    var currentIrregularPart = ""

    let chars = Array(mixedCaseString)

    func isFormalSieStart(at index: Int) -> Bool {
      guard index + 2 < chars.count,
            chars[index] == "S",
            chars[index + 1] == "i",
            chars[index + 2] == "e",
            index == 0 || chars[index - 1] == " " else {
        return false
      }
      return index + 3 >= chars.count || !chars[index + 3].isLetter
    }

    for (index, char) in chars.enumerated() {
      let isPartOfSie = isFormalSieStart(at: index) ||
                        (index > 0 && isFormalSieStart(at: index - 1)) ||
                        (index > 1 && isFormalSieStart(at: index - 2))

      let isRegular = char.isLowercase || !char.isLetter || isPartOfSie
      let canonicalChar = isPartOfSie ? String(char) : char.lowercased()
      switch state {
      case .notStarted:
        if isRegular {
          currentRegularPart = canonicalChar
          state = .inRegularPart
        } else {
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inRegularPart:
        if isRegular {
          currentRegularPart += canonicalChar
        } else {
          var part = AttributedString(currentRegularPart)
          part.foregroundColor = widgetYellow
          attributedString.append(part)
          currentRegularPart = ""
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inIrregularPart:
        if isRegular {
          var part = AttributedString(currentIrregularPart)
          part.foregroundColor = widgetRed
          attributedString.append(part)
          currentRegularPart = canonicalChar
          currentIrregularPart = ""
          state = .inRegularPart
        } else {
          currentIrregularPart += canonicalChar
        }
      }
    }

    var regularPart = AttributedString(currentRegularPart)
    regularPart.foregroundColor = widgetYellow
    attributedString.append(regularPart)

    var irregularPart = AttributedString(currentIrregularPart)
    irregularPart.foregroundColor = widgetRed
    attributedString.append(irregularPart)

    self.init(attributedString)
  }
}
