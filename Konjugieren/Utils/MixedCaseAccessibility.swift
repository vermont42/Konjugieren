// Copyright © 2026 Josh Adams. All rights reserved.

enum MixedCaseAccessibility {
  static func accessibilityLabel(for mixedCaseString: String) -> String {
    let chars = Array(mixedCaseString)
    var lowercasedWord = ""
    var irregularLetters: [String] = []

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

      lowercasedWord += canonicalChar

      if !isRegular {
        irregularLetters.append(canonicalChar)
      }
    }

    if irregularLetters.isEmpty {
      return lowercasedWord
    }

    let joined = irregularLetters.joined(separator: " ")

    if irregularLetters.count == 1 {
      return "\(lowercasedWord), \(joined) \(L.Accessibility.isIrregular)"
    } else {
      return "\(lowercasedWord), \(joined) \(L.Accessibility.areIrregular)"
    }
  }
}
