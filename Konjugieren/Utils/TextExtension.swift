// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

extension Text {
  init(label: String, value: String) {
    var result = AttributedString()

    var labelAttr = AttributedString(label + " ")
    labelAttr.foregroundColor = Color.customYellow
    result.append(labelAttr)

    var valueAttr = AttributedString(value)
    valueAttr.foregroundColor = Color.customForeground
    result.append(valueAttr)

    self.init(result)
  }

  init(mixedCaseString: String) {
    var attributedString = AttributedString()
    for segment in MixedCaseSegmenter.segments(for: mixedCaseString) {
      var part = AttributedString(segment.text)
      part.foregroundColor = segment.isIrregular ? .customRed : .customYellow
      attributedString.append(part)
    }
    self.init(attributedString)
  }
}
