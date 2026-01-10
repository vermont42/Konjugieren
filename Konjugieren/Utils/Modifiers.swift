// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

extension View {
  func subheadingLabel() -> some View {
    modifier(SubheadingLabel())
  }

  func settingsLabel() -> some View {
    modifier(SettingsLabel())
  }

  func headingLabel() -> some View {
    modifier(HeadingLabel())
  }

  func segmentedPicker() -> some View {
    modifier(SegmentedPicker())
  }

  func funButton() -> some View {
    modifier(FunButton())
  }
}

private struct SubheadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 20))
      .foregroundColor(.customYellow)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

private struct SettingsLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 16))
      .foregroundColor(.customForeground)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

private struct HeadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 22))
      .accessibility(addTraits: [.isHeader])
  }
}

private struct SegmentedPicker: ViewModifier {
  func body(content: Content) -> some View {
    content
      .pickerStyle(.segmented)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

private struct FunButton: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor(.customRed)
      .buttonStyle(.bordered)
      .tint(.customRed)
  }
}
