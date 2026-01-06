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

    let chars = Array(mixedCaseString)

    // Check if position is the start of the formal pronoun "Sie"
    // (capital S followed by lowercase "ie", at start or after space).
    func isFormalSieStart(at index: Int) -> Bool {
      guard index + 2 < chars.count,
            chars[index] == "S",
            chars[index + 1] == "i",
            chars[index + 2] == "e",
            index == 0 || chars[index - 1] == " " else {
        return false
      }
      // Ensure "Sie" is at end or followed by non-letter to avoid matching "Sieg" or "Siegel".
      return index + 3 >= chars.count || !chars[index + 3].isLetter
    }

    for (index, char) in chars.enumerated() {
      // Check if this char is part of the formal pronoun "Sie".
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
