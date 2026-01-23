// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

// MARK: - RichTextBlock

enum RichTextBlock: Hashable {
  case subheading(String)
  case body([TextSegment])
}

// MARK: - ConjugationPart

enum ConjugationPart: Hashable {
  case regular(String)    // Expected characters (yellow)
  case irregular(String)  // Changed characters (red)
}

// MARK: - TextSegment

enum TextSegment: Hashable {
  case plain(String)
  case bold(String)
  case link(text: String, url: URL)
  case conjugation([ConjugationPart])  // Alternating regular/irregular parts
}

// MARK: - String Extensions

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

  // MARK: - Rich Text Block Parser

  var richTextBlocks: [RichTextBlock] {
    // Convert literal \n from Localizable.xcstrings to actual newlines
    let processedString = self.replacingOccurrences(of: "\\n", with: "\n")

    var blocks: [RichTextBlock] = []
    var currentText = ""
    var inSubheading = false

    for char in processedString {
      if char == String.subheadingSeparator {
        if inSubheading {
          // Closing backtick: emit subheading block
          let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
          if !trimmed.isEmpty {
            blocks.append(.subheading(trimmed))
          }
          currentText = ""
          inSubheading = false
        } else {
          // Opening backtick: emit any pending body text first
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

    // Emit any remaining text as body
    if !currentText.isEmpty {
      let segments = currentText.parseBodyToSegments()
      blocks.append(.body(segments))
    }

    return blocks
  }

  // MARK: - Body Text Parser (Bold, Links, Conjugations)

  private func parseBodyToSegments() -> [TextSegment] {
    var segments: [TextSegment] = []
    var currentText = ""

    var inBold = false
    var inLink = false
    var inConjugation = false
    var markupStart = self.startIndex

    for (offset, char) in self.enumerated() {
      let index = self.index(self.startIndex, offsetBy: offset)

      if char == String.boldSeparator {
        if inBold {
          // Closing bold
          let content = String(self[self.index(after: markupStart)..<index])
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          segments.append(.bold(content))
          inBold = false
        } else {
          // Opening bold
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          inBold = true
          markupStart = index
        }
      } else if char == String.linkSeparator {
        if inLink {
          // Closing link
          let content = String(self[self.index(after: markupStart)..<index])
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          // Create URL
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
          // Opening link
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          inLink = true
          markupStart = index
        }
      } else if char == String.conjugationSeparator {
        if inConjugation {
          // Closing conjugation
          let content = String(self[self.index(after: markupStart)..<index])
          if !currentText.isEmpty {
            segments.append(.plain(currentText))
            currentText = ""
          }
          // Parse conjugation into parts
          let conjugationSegment = content.parseConjugationToSegment()
          segments.append(conjugationSegment)
          inConjugation = false
        } else {
          // Opening conjugation
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

    // Append any remaining plain text
    if !currentText.isEmpty {
      segments.append(.plain(currentText))
    }

    return segments
  }

  // MARK: - Conjugation Parser (Uppercase → Red, Lowercase → Yellow)

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
        // First character
        currentIsUpper = isUpper
        currentRun = lowercasedChar
      } else if isUpper == currentIsUpper {
        // Same case as current run, append
        currentRun += lowercasedChar
      } else {
        // Case changed, emit current run and start new one
        if currentIsUpper == true {
          parts.append(.irregular(currentRun))
        } else {
          parts.append(.regular(currentRun))
        }
        currentRun = lowercasedChar
        currentIsUpper = isUpper
      }
    }

    // Emit final run
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
