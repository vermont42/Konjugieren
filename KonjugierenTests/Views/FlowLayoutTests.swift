// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import SwiftUI
import Testing
import UIKit

@MainActor
@Suite("FlowLayout")
struct FlowLayoutTests {
  private let width: CGFloat = 120

  private func height(of view: some View) -> CGFloat {
    UIHostingController(rootView: view)
      .sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude))
      .height
  }

  private var lineHeight: CGFloat {
    height(of: FlowLayout { Text(verbatim: "Wort") })
  }

  // Each child was offered an unspecified size, so a chip wider than its row stayed one line
  // and ran past the edge.
  @Test func childWiderThanARowWraps() {
    let long = Text(verbatim: Array(repeating: "Wort", count: 20).joined(separator: " "))

    #expect(height(of: FlowLayout { long }) > lineHeight * 2)
  }

  @Test func childrenThatFitShareARow() {
    let chips = FlowLayout {
      Text(verbatim: "ab")
      Text(verbatim: "an")
    }

    #expect(height(of: chips) == lineHeight)
  }

  @Test func childrenThatDoNotFitWrapToANewRow() {
    let chips = FlowLayout(spacing: 8) {
      Text(verbatim: "Wortwort")
      Text(verbatim: "Wortwort")
      Text(verbatim: "Wortwort")
    }

    #expect(height(of: chips) > lineHeight * 2)
  }
}
