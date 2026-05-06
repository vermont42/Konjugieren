// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import UIKit

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

  func speakOnTap(_ text: String, localeString: String = UttererLocale.german) -> some View {
    modifier(SpeakOnTap(text: text, localeString: localeString))
  }

  func konjCard() -> some View {
    modifier(KonjCard())
  }

  func konjCardWithAccentBar(_ color: Color = .customYellow) -> some View {
    modifier(KonjCardWithAccentBar(color: color))
  }

  func konjCardRim() -> some View {
    modifier(KonjCardRim())
  }
}

private struct SubheadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.title3.bold())
      .foregroundStyle(.customYellow)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
      .accessibilityAddTraits(.isHeader)
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
        .environment(\.locale, .init(identifier: UttererLocale.german))
    } else {
      content
    }
  }
}

private struct EnglishPronunciation: ViewModifier {
  func body(content: Content) -> some View {
    content
      .environment(\.locale, .init(identifier: UttererLocale.english))
  }
}

private struct SpeakOnTap: ViewModifier {
  let text: String
  let localeString: String
  @State private var isSpeaking = false

  func body(content: Content) -> some View {
    content
      .background(Color.customYellow.opacity(isSpeaking ? 0.15 : 0))
      .animation(.easeOut(duration: 0.15), value: isSpeaking)
      .onTapGesture {
        guard !UIAccessibility.isVoiceOverRunning else { return }
        Current.utterer.utter(text, localeString: localeString)
        isSpeaking = true
        Task { @MainActor in
          try? await Task.sleep(for: .milliseconds(300))
          isSpeaking = false
        }
      }
  }
}

private struct KonjCard: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding()
      .background(Color.customCardBackground)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .strokeBorder(Color.customCardBorder, lineWidth: 1)
      )
  }
}

private struct KonjCardWithAccentBar: ViewModifier {
  let color: Color

  func body(content: Content) -> some View {
    content
      .konjCard()
      .overlay(alignment: .leading) {
        Rectangle()
          .fill(color.opacity(0.3))
          .frame(width: 2)
          .clipShape(RoundedRectangle(cornerRadius: 1))
      }
  }
}

private struct KonjCardRim: ViewModifier {
  func body(content: Content) -> some View {
    content
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .strokeBorder(Color.customCardBorder, lineWidth: 1)
      )
  }
}
