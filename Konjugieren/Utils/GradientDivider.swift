// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct GradientDivider: View {
  var color: Color = .customYellow

  var body: some View {
    Rectangle()
      .fill(
        LinearGradient(
          colors: [.clear, color.opacity(0.3), .clear],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .frame(height: 1)
  }
}
