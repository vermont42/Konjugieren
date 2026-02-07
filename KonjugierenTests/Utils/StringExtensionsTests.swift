// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
@testable import Konjugieren
import Testing

struct StringExtensionsTests {
  // MARK: - Subheading Delimiter Tests

  @Test func subheadingParsing() {
    let input = "`Heading`"
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    #expect(blocks[0] == .subheading("Heading"))
  }

  @Test func subheadingWithBody() {
    let input = "`Section Title` Some body text follows."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 2)
    #expect(blocks[0] == .subheading("Section Title"))
    if case .body(let segments) = blocks[1] {
      #expect(segments.count == 1)
      if case .plain(let text) = segments[0] {
        #expect(text.contains("Some body text follows."))
      }
    }
  }

  @Test func multipleSubheadings() {
    let input = "`First` Body one. `Second` Body two."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 4)
    #expect(blocks[0] == .subheading("First"))
    #expect(blocks[2] == .subheading("Second"))
  }

  // MARK: - Subheading Trailing Newline Tests

  @Test func subheadingTrailingNewlineConsumed() {
    let input = "`Heading`\\nBody text."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 2)
    #expect(blocks[0] == .subheading("Heading"))
    if case .body(let segments) = blocks[1] {
      #expect(segments.count == 1)
      if case .plain(let text) = segments[0] {
        #expect(text == "Body text.")
      }
    }
  }

  @Test func subheadingDoubleNewlinePreservesOne() {
    let input = "`Heading`\\n\\nBody text."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 2)
    #expect(blocks[0] == .subheading("Heading"))
    if case .body(let segments) = blocks[1] {
      #expect(segments.count == 1)
      if case .plain(let text) = segments[0] {
        #expect(text == "\nBody text.")
      }
    }
  }

  @Test func subheadingNoNewlineUnchanged() {
    let input = "`Heading`Body text."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 2)
    #expect(blocks[0] == .subheading("Heading"))
    if case .body(let segments) = blocks[1] {
      #expect(segments.count == 1)
      if case .plain(let text) = segments[0] {
        #expect(text == "Body text.")
      }
    }
  }

  @Test func consecutiveSubheadingsWithNewlines() {
    let input = "`First`\\n`Second`\\nBody."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 3)
    #expect(blocks[0] == .subheading("First"))
    #expect(blocks[1] == .subheading("Second"))
    if case .body(let segments) = blocks[2] {
      #expect(segments.count == 1)
      if case .plain(let text) = segments[0] {
        #expect(text == "Body.")
      }
    }
  }

  // MARK: - Bold Delimiter Tests

  @Test func boldParsing() {
    let input = "~bold text~"
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 1)
      #expect(segments[0] == .bold("bold text"))
    }
  }

  @Test func boldInContext() {
    let input = "This is ~emphasized~ text."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 3)
      #expect(segments[0] == .plain("This is "))
      #expect(segments[1] == .bold("emphasized"))
      #expect(segments[2] == .plain(" text."))
    }
  }

  @Test func multipleBoldSegments() {
    let input = "~first~ and ~second~"
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 3)
      #expect(segments[0] == .bold("first"))
      #expect(segments[1] == .plain(" and "))
      #expect(segments[2] == .bold("second"))
    }
  }

  // MARK: - Link Delimiter Tests

  @Test func linkParsing() {
    let input = "%https://example.com%"
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 1)
      if case .link(let text, let url) = segments[0] {
        #expect(text == "https://example.com")
        #expect(url.absoluteString == "https://example.com")
      }
    }
  }

  @Test func linkInContext() {
    let input = "Visit %https://apple.com% for more."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 3)
      #expect(segments[0] == .plain("Visit "))
      if case .link(let text, _) = segments[1] {
        #expect(text == "https://apple.com")
      }
      #expect(segments[2] == .plain(" for more."))
    }
  }

  // MARK: - Conjugation Delimiter Tests

  @Test func conjugationParsing() {
    let input = "$sAng$"
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 1)
      if case .conjugation(let parts) = segments[0] {
        #expect(parts.count == 3)
        #expect(parts[0] == .regular("s"))
        #expect(parts[1] == .irregular("a"))
        #expect(parts[2] == .regular("ng"))
      }
    }
  }

  @Test func conjugationAllRegular() {
    let input = "$machen$"
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 1)
      if case .conjugation(let parts) = segments[0] {
        #expect(parts.count == 1)
        #expect(parts[0] == .regular("machen"))
      }
    }
  }

  @Test func conjugationAllIrregular() {
    let input = "$BIN$"
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 1)
      if case .conjugation(let parts) = segments[0] {
        #expect(parts.count == 1)
        #expect(parts[0] == .irregular("bin"))
      }
    }
  }

  @Test func conjugationInContext() {
    let input = "The past tense is $sAng$ (sang)."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 3)
      #expect(segments[0] == .plain("The past tense is "))
      if case .conjugation(let parts) = segments[1] {
        #expect(parts.count == 3)
      }
      #expect(segments[2] == .plain(" (sang)."))
    }
  }

  // MARK: - Plain Text Tests

  @Test func plainTextOnly() {
    let input = "Just plain text without markup."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 1)
      #expect(segments[0] == .plain("Just plain text without markup."))
    }
  }

  @Test func emptyString() {
    let input = ""
    let blocks = input.richTextBlocks
    #expect(blocks.isEmpty)
  }

  // MARK: - Combined Markup Tests

  @Test func combinedMarkup() {
    let input = "Text with ~bold~ and $sAng$ forms"
    let blocks = input.richTextBlocks
    #expect(blocks.count == 1)
    if case .body(let segments) = blocks[0] {
      #expect(segments.count == 5)
      #expect(segments[0] == .plain("Text with "))
      #expect(segments[1] == .bold("bold"))
      #expect(segments[2] == .plain(" and "))
      if case .conjugation(let parts) = segments[3] {
        #expect(parts.count == 3)
      }
      #expect(segments[4] == .plain(" forms"))
    }
  }

  @Test func subheadingWithMixedBody() {
    let input = "`Verb Forms` The verb ~singen~ conjugates as $sAng$ in past."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 2)
    #expect(blocks[0] == .subheading("Verb Forms"))
    if case .body(let segments) = blocks[1] {
      #expect(segments.count == 5)
      #expect(segments[1] == .bold("singen"))
    }
  }

  @Test func allMarkupTypes() {
    let input = "`Header` Visit ~Apple~ at %https://apple.com% to see $wIrd$."
    let blocks = input.richTextBlocks
    #expect(blocks.count == 2)
    #expect(blocks[0] == .subheading("Header"))
    if case .body(let segments) = blocks[1] {
      #expect(segments.count == 7)
      #expect(segments[0] == .plain(" Visit "))
      #expect(segments[1] == .bold("Apple"))
      #expect(segments[2] == .plain(" at "))
      if case .link(_, let url) = segments[3] {
        #expect(url.absoluteString == "https://apple.com")
      }
      #expect(segments[4] == .plain(" to see "))
      if case .conjugation(let parts) = segments[5] {
        #expect(parts[0] == .regular("w"))
        #expect(parts[1] == .irregular("i"))
        #expect(parts[2] == .regular("rd"))
      }
      #expect(segments[6] == .plain("."))
    }
  }

  // MARK: - Unterminated Delimiter Tests

  @MainActor @Test func unterminatedSubheadingDelimiter() {
    let spy = FatalErrorSpy()
    Current.fatalError = spy
    let input = "`Unclosed heading"
    _ = input.richTextBlocks
    #expect(spy.messages.contains("Unterminated delimiter: `"))
  }

  @MainActor @Test func unterminatedBoldDelimiter() {
    let spy = FatalErrorSpy()
    Current.fatalError = spy
    let input = "~unclosed bold"
    _ = input.richTextBlocks
    #expect(spy.messages.contains("Unterminated delimiter: ~"))
  }

  @MainActor @Test func unterminatedLinkDelimiter() {
    let spy = FatalErrorSpy()
    Current.fatalError = spy
    let input = "%https://unclosed.com"
    _ = input.richTextBlocks
    #expect(spy.messages.contains("Unterminated delimiter: %"))
  }

  @MainActor @Test func unterminatedConjugationDelimiter() {
    let spy = FatalErrorSpy()
    Current.fatalError = spy
    let input = "$sAng"
    _ = input.richTextBlocks
    #expect(spy.messages.contains("Unterminated delimiter: $"))
  }
}
