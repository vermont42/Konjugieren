// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import SwiftUI
import Testing

@MainActor
@Suite("SearchPrompt")
struct SearchPromptTests {
  struct Field: Sendable {
    let width: CGFloat
    let size: DynamicTypeSize
    var sizeClass = UserInterfaceSizeClass.compact
  }

  nonisolated private static let ladder = ["Verb, conjugation, or meaning", "Verb or meaning", "Search"]

  @Test("The longest prompt that fits the field", arguments: zip(
    [
      Field(width: 402, size: .xxxLarge),
      Field(width: 375, size: .xxxLarge),
      Field(width: 375, size: .large),
      Field(width: 375, size: .accessibility1),
      Field(width: 375, size: .accessibility5),
      Field(width: 834, size: .xxxLarge, sizeClass: .regular),
      Field(width: 0, size: .xxxLarge),
      Field(width: 150, size: .xxxLarge),
      Field(width: 100, size: .xxxLarge)
    ],
    [
      ladder[0],
      ladder[1],
      ladder[0],
      ladder[0],
      ladder[0],
      ladder[0],
      ladder[0],
      ladder[2],
      ladder[2]
    ]
  ))
  func longestFitting(field: Field, expected: String) {
    let prompt = SearchPrompt.longestFitting(Self.ladder, containerWidth: field.width, dynamicTypeSize: field.size, sizeClass: field.sizeClass)
    #expect(prompt == expected)
  }
}
