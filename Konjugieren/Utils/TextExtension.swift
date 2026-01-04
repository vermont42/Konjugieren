// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

extension Text {
  init(mixedCaseString: String) {
    enum ColorParsingState {
      case notStarted
      case inRegularPart
      case inIrregularPart
    }

    var attributedString = AttributedString()
    var state = ColorParsingState.notStarted
    var currentRegularPart = ""
    var currentIrregularPart = ""

    for char in mixedCaseString {
      let isRegular = char.isLowercase || !char.isLetter
      let canonicalChar = char.lowercased()
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
          part.foregroundColor = .customYellow
          attributedString.append(part)
          currentRegularPart = ""
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inIrregularPart:
        if isRegular {
          var part = AttributedString(currentIrregularPart)
          part.foregroundColor = .customRed
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
    regularPart.foregroundColor = .customYellow
    attributedString.append(regularPart)

    var irregularPart = AttributedString(currentIrregularPart)
    irregularPart.foregroundColor = .customRed
    attributedString.append(irregularPart)

    self.init(attributedString)
  }
}
