# KonjugierenWidget

Claude Code loads this file when working with files under `KonjugierenWidget/`.

## Widget Localization (WidgetL)

The `KonjugierenWidget` extension ships as its own `.appex` bundle with its **own** string catalog, `KonjugierenWidget/Localizable.xcstrings`, separate from the app's `Konjugieren/Assets/Localizable.xcstrings`. Widget user-facing strings (gallery names/descriptions, Control Center labels, Live Activity "Wave"/"Game Over", quiz "Correct!"/"Incorrect") route through `WidgetL` (`KonjugierenWidget/WidgetL.swift`), the widget's analogue to the app's `L`. Catalog keys follow `L`'s `Group.member` convention.

`WidgetL` exposes **two accessor styles**, dictated by isolation and the type the call site needs:

```swift
enum WidgetL {
  enum Game {
    static var over: String { String(localized: "Game.over") }          // @MainActor SwiftUI / WidgetConfiguration
    static func wave(_ number: Int) -> String { String(localized: "Game.wave \(number)") }
  }

  enum QuickQuiz {
    nonisolated static var name: LocalizedStringResource {              // nonisolated control modifiers
      LocalizedStringResource("QuickQuiz.name")
    }
  }
}
```

- **`String` via `String(localized:)`** for `@MainActor` SwiftUI / `WidgetConfiguration` strings (mirrors `L`).
- **`nonisolated` `LocalizedStringResource`** accessors for the Control Center modifiers that require that type in a nonisolated context.

Two important exceptions where strings **cannot** route through `WidgetL` and stay inline against the same catalog keys:

1. **AppIntent titles and `@Parameter(title:)`**: `appintentsmetadataprocessor` parses source statically and requires a string literal or a direct `LocalizedStringResource(...)` initializer call, not an accessor. These four sites are inline by necessity.
2. **`Shared/` intents (`OpenQuizIntent`, `OpenRandomVerbIntent`)**: `Shared/` compiles into **both** the app and widget targets, and `LocalizedStringResource` resolves against whichever bundle runs. Their keys therefore live in **both** `Localizable.xcstrings` catalogs.
