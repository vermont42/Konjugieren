// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import UIKit

enum SearchPrompt {
  private static let trailingInset: CGFloat = 7

  static func longestFitting(
    _ candidates: [String],
    containerWidth: CGFloat,
    dynamicTypeSize: DynamicTypeSize,
    sizeClass: UserInterfaceSizeClass?
  ) -> String {
    let longest = candidates.first ?? ""
    // UIKit shrinks the placeholder to fit at accessibility sizes, but truncates it below them.
    guard !dynamicTypeSize.isAccessibilitySize, containerWidth > 0 else {
      return longest
    }
    let font = UIFont.preferredFont(
      forTextStyle: .body,
      compatibleWith: UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(dynamicTypeSize))
    )
    let fieldMargin: CGFloat = sizeClass == .regular ? 20 : 16
    let available = containerWidth - 2 * fieldMargin - leadingInset(dynamicTypeSize) - trailingInset
    return candidates.first { width(of: $0, in: font) <= available } ?? candidates.last ?? longest
  }

  private static func width(of prompt: String, in font: UIFont) -> CGFloat {
    ceil((prompt as NSString).size(withAttributes: [.font: font]).width)
  }

  // Where UISearchTextField's text begins, past the magnifying glass, as measured on iOS 26.
  private static func leadingInset(_ dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    switch dynamicTypeSize {
    case .xSmall:
      return 36
    case .small:
      return 37
    case .medium:
      return 39
    case .large:
      return 40
    case .xLarge:
      return 42
    case .xxLarge:
      return 45
    default:
      return 47
    }
  }
}
