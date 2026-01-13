// Copyright © 2025 Josh Adams. All rights reserved.

import Foundation

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
  let result = NSMutableAttributedString()
  result.append(left)
  result.append(right)
  return result
}

func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
  lhs = lhs + rhs
}
