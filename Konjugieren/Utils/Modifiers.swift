// Copyright © 2026 Josh Adams. All rights reserved.

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

  func tableText() -> some View {
    modifier(TableText())
  }

  func tableSubtext() -> some View {
    modifier(TableSubtext())
  }

  func buttonLabel() -> some View {
    modifier(ButtonLabel())
  }

  func germanPronunciation(forReal: Bool = true) -> some View {
    modifier(GermanPronunciation(forReal: forReal))
  }

  func englishPronunciation() -> some View {
    modifier(EnglishPronunciation())
  }
}

private struct SubheadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.title3.bold())
      .foregroundStyle(.customYellow)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

private struct SettingsLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.callout)
      .foregroundStyle(.customForeground)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

private struct HeadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.title2.bold())
      .accessibilityAddTraits(.isHeader)
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
      .foregroundStyle(.customYellow)
      .buttonStyle(.bordered)
      .tint(.customRed)
  }
}

private struct TableText: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.headline)
      .foregroundStyle(.customYellow)
  }
}

private struct TableSubtext: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.subheadline)
      .foregroundStyle(.customForeground)
  }
}

private struct ButtonLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.title3.bold())
  }
}

private struct GermanPronunciation: ViewModifier {
  let forReal: Bool

  func body(content: Content) -> some View {
    if forReal {
      content
        .environment(\.locale, .init(identifier: "de-DE"))
    } else {
      content
    }
  }
}

private struct EnglishPronunciation: ViewModifier {
  func body(content: Content) -> some View {
    content
      .environment(\.locale, .init(identifier: "en-US"))
  }
}
