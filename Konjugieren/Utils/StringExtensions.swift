// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

enum RichTextBlock: Hashable {
  case subheading(String)
  case body([TextSegment])
}

enum ConjugationPart: Hashable {
  case regular(String)
  case irregular(String)
}

enum TextSegment: Hashable {
  case plain(String)
  case bold(String)
  case link(text: String, url: URL)
  case conjugation([ConjugationPart])
}

extension String {
  static var subheadingSeparator: Character { "`" }
  static var boldSeparator: Character { "~" }
  static var linkSeparator: Character { "%" }
  static var conjugationSeparator: Character { "$" }

  func replaceFirstOccurence(of oldSubstring: String, with newSubstring: String) -> String {
    if let range = self.range(of: oldSubstring) {
      return self.replacingCharacters(in: range, with: newSubstring)
    }
    return self
  }

  func trimmingLeadingNewlines() -> String {
    var result = self
    while result.hasPrefix("\n") {
      result.removeFirst()
    }
    return result
  }

  var richTextBlocks: [RichTextBlock] {
    let processedString = self.replacingOccurrences(of: "\\n", with: "\n")

    var blocks: [RichTextBlock] = []
    var currentText = ""
    var inSubheading = false

    for char in processedString {
      if char == String.subheadingSeparator {
        if inSubheading {
          let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
          if !trimmed.isEmpty {
            blocks.append(.subheading(trimmed))
          }
          currentText = ""
          inSubheading = false
        } else {
          if !currentText.isEmpty {
            let segments = currentText.parseBodyToSegments()
            blocks.append(.body(segments))
            currentText = ""
          }
          inSubheading = true
        }
      } else {
        currentText.append(char)
      }
    }

    if !currentText.isEmpty {
      let segments = currentText.parseBodyToSegments()
      blocks.append(.body(segments))
    }

    if inSubheading {
      Current.fatalError.fatalError("Unterminated delimiter: `")
    }

    return blocks
  }

  private func parseBodyToSegments() -> [TextSegment] {
    var segments: [TextSegment] = []
    var currentText = ""

    var inBold = false
    var inLink = false
    var inConjugation = false
    var markupStart = self.startIndex

    for index in self.indices {
      let char = self[index]

      if char == String.boldSeparator {
        if inBold {
          let content = String(self[self.index(after: markupStart)..<index])
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          segments.append(.bold(content))
          inBold = false
        } else {
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          inBold = true
          markupStart = index
        }
      } else if char == String.linkSeparator {
        if inLink {
          let content = String(self[self.index(after: markupStart)..<index])
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          let urlString: String
          if content.hasPrefix("http") {
            urlString = content
          } else {
            urlString = content.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? content
          }
          if let url = URL(string: urlString) {
            segments.append(.link(text: content, url: url))
          } else {
            segments.append(.plain(content))
          }
          inLink = false
        } else {
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          inLink = true
          markupStart = index
        }
      } else if char == String.conjugationSeparator {
        if inConjugation {
          let content = String(self[self.index(after: markupStart)..<index])
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          let conjugationSegment = content.parseConjugationToSegment()
          segments.append(conjugationSegment)
          inConjugation = false
        } else {
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          inConjugation = true
          markupStart = index
        }
      } else if !inBold && !inLink && !inConjugation {
        currentText.append(char)
      }
    }

    if !currentText.isEmpty {
      segments.append(.plain(currentText))
    }

    if inBold {
      Current.fatalError.fatalError("Unterminated delimiter: ~")
    }
    if inLink {
      Current.fatalError.fatalError("Unterminated delimiter: %")
    }
    if inConjugation {
      Current.fatalError.fatalError("Unterminated delimiter: $")
    }

    return segments
  }

  private func parseConjugationToSegment() -> TextSegment {
    guard !self.isEmpty else {
      return .conjugation([])
    }

    var parts: [ConjugationPart] = []
    var currentRun = ""
    var currentIsUpper: Bool? = nil

    for char in self {
      let isUpper = char.isUppercase
      let lowercasedChar = char.lowercased()

      if currentIsUpper == nil {
        currentIsUpper = isUpper
        currentRun = lowercasedChar
      } else if isUpper == currentIsUpper {
        currentRun += lowercasedChar
      } else {
        if currentIsUpper == true {
          parts.append(.irregular(currentRun))
        } else {
          parts.append(.regular(currentRun))
        }
        currentRun = lowercasedChar
        currentIsUpper = isUpper
      }
    }

    if !currentRun.isEmpty {
      if currentIsUpper == true {
        parts.append(.irregular(currentRun))
      } else {
        parts.append(.regular(currentRun))
      }
    }

    return .conjugation(parts)
  }
}
