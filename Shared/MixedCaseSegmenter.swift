// Copyright © 2026 Josh Adams. All rights reserved.

enum MixedCaseSegmenter {
  struct Segment {
    let text: String
    let isIrregular: Bool
  }

  nonisolated static func segments(for mixedCaseString: String) -> [Segment] {
    enum ParsingState {
      case notStarted
      case inRegularPart
      case inIrregularPart
    }

    var result: [Segment] = []
    var state = ParsingState.notStarted
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
          result.append(Segment(text: currentRegularPart, isIrregular: false))
          currentRegularPart = ""
          currentIrregularPart = canonicalChar
          state = .inIrregularPart
        }
      case .inIrregularPart:
        if isRegular {
          result.append(Segment(text: currentIrregularPart, isIrregular: true))
          currentRegularPart = canonicalChar
          currentIrregularPart = ""
          state = .inRegularPart
        } else {
          currentIrregularPart += canonicalChar
        }
      }
    }

    result.append(Segment(text: currentRegularPart, isIrregular: false))
    result.append(Segment(text: currentIrregularPart, isIrregular: true))

    return result
  }
}
