Konjugieren
=========

![Swift](https://img.shields.io/badge/Swift-6.1-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2026-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3.0-green.svg)
![Xcode](https://img.shields.io/badge/Xcode-26-blue.svg)

| App Icon 1 | App Icon 2 | App Icon 3 |
| --- | --- | --- |
| ![](Images/Hat.png) | ![](Images/Bundestag.png) | ![](Images/Pretzel.png) |

**Konjugieren** is an iOS app for learning German-verb conjugations. It conjugates 988 verbs—strong, weak, mixed, and _-ieren_—across all 14 German [conjugationgroups](https://www.linkedin.com/posts/racecondition_i-have-written-elsewhere-about-how-my-experience-activity-7404189320758280192-tiAL), from Präsens Indikativ to Plusquamperfekt Konjunktiv II. The app is fully localized in English and German.

Under the hood, **Konjugieren** features a domain-specific ablaut engine that models the vowel and consonant changes of German strong verbs, a hand-written rich-text parser, protocol-oriented dependency injection, and a comprehensive [Swift Testing](https://developer.apple.com/xcode/swift-testing/) suite with 95 tests across 1,800+ lines.

### Screenshots

| Verb List | Verb | Quiz | Family List |
| --- | --- | --- | --- |
| ![](Images/verbList.png) | ![](Images/verb.png) | ![](Images/quiz.png) | ![](Images/familyList.png) |

| Family | Info List | Verb History | Dedication |
| --- | --- | --- | --- |
| ![](Images/family.png) | ![](Images/InfoList.png) | ![](Images/history.png) | ![](Images/dedication.png) |

### Why Konjugieren?

Josh Adams created **Konjugieren** as a tribute to his grandfather, [Clifford August Schmiesing](https://www.findagrave.com/memorial/56382498/clifford-august-schmiesing) (1904–1944), an Army doctor who grew up speaking German in Minster, Ohio and died serving in World War II. The app's dedication tells his story.

**Konjugieren** is also an experiment in human-AI collaboration. Josh is developing the entire app with [Claude Code](https://www.youtube.com/watch?v=AJpK3YTTKZ4)—not as a crutch, but as a deliberate productivity multiplier. He spent twelve months on [Conjuguer](https://apps.apple.com/us/app/conjuguer/id1588624373) (French) and nine months on [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467?mt=8) (Spanish). With Claude Code, **Konjugieren** reached feature parity in six weeks—and then surpassed both predecessors with features they lack: onboarding, visually distinctive icons for each verb, variable search scope, and a 3,000-word history of the German language from the formation of the Solar System to today.

The collaboration goes beyond speed. Claude Code added TelemetryDeck analytics in a single pass, but Josh then directed two successive architectural refinements: first, wrapping the SDK behind an `Analytics` protocol with Real and Spy implementations—extending the app's existing dependency-injection pattern—and second, replacing stringly typed signal names with a compiler-checked `AnalyticsName` enum. A coding assistant executes quickly, but an experienced developer knows _what_ to ask for.

### Architecture

**Protocol-oriented dependency injection** — [`World.swift`](Konjugieren/Models/World.swift) is a lightweight DI container that injects six dependencies (`Settings`, `GameCenter`, `SoundPlayer`, `Utterer`, `FatalError`, `Analytics`), each defined as a protocol with Real, Dummy, Spy, or Fake implementations. This enables full testability with zero third-party frameworks: production code crashes early on invalid data via `FatalErrorReal`, while tests capture those errors with `FatalErrorSpy`.

**Ablaut engine** — German strong verbs undergo vowel and consonant changes (_ablaut_) that differ by conjugationgroup. The engine uses region-based substring replacement: each verb's [XML definition](Konjugieren/Models/Verbs.xml) marks the mutable region with `^` delimiters, and [ablaut-group definitions](Konjugieren/Models/AblautGroups.xml) (66 patterns) specify replacements per conjugationgroup. A full-override syntax (`*` suffix) handles highly irregular verbs like _sein_ and _haben_. [`Conjugator.swift`](Konjugieren/Models/Conjugator.swift) applies these rules at runtime.

**Rich-text parser** — A [hand-written state machine](Konjugieren/Utils/StringExtensions.swift) parses four markup syntaxes (backtick headings, tilde bold, dollar-sign ablaut highlighting, percent-delimited URLs) into a recursive `RichTextBlock`/`TextSegment` enum AST, rendered by [`RichTextView.swift`](Konjugieren/Views/RichTextView.swift). This powers the app's 3,000-word bilingual essay on German-verb history.

**@Observable reactive state** — The app uses Swift's modern [Observation](https://developer.apple.com/documentation/observation) framework throughout (`@Observable` on `World`, `Quiz`, `Settings`), with no Combine or third-party reactive dependencies.

### Accessibility

Konjugieren is fully accessible to VoiceOver users. The implementation spans five new files and modifications to fourteen existing views, using four distinct accessibility strategies:

**Ablaut-aware accessibility labels** — The app's core pedagogical feature — color-coded ablaut highlighting where `sAng` renders "s" in one color and "A" in another — is invisible to screen readers. [`MixedCaseAccessibility.swift`](Konjugieren/Utils/MixedCaseAccessibility.swift) solves this with a pure function that walks the mixed-case string using the same `isFormalSieStart` algorithm as the visual renderer ([`TextExtension.swift`](Konjugieren/Utils/TextExtension.swift)), collecting uppercase characters as irregular, and producing labels like `"sang, a is irregular"` or `"bin, b i n are irregular"`. The formal pronoun "Sie" is correctly excluded from irregular-letter detection despite its initial capital.

**Speech-synthesis DI** — Quiz questions are spoken aloud using `AVSpeechSynthesizer`, following the same protocol-oriented DI pattern as `SoundPlayer`. The [`Utterer`](Konjugieren/Utils/Utterer.swift) protocol defines `setup()` and `utter(_:localeString:)`, with [`UttererReal`](Konjugieren/Utils/UttererReal.swift) tuning rate (0.5) and pitch (0.8) for clear German speech, and [`UttererDummy`](Konjugieren/Utils/UttererDummy.swift) keeping tests silent. Verb names are spoken in `de-DE`, translations in `en-US` — the locale switch happens mid-question so VoiceOver users hear correct pronunciation for both languages.

**Semantic structure** — Every section heading uses `.accessibilityAddTraits(.isHeader)`, enabling VoiceOver's rotor to jump between sections. The `SubheadingLabel` ViewModifier applies this trait globally, so all views using `.subheadingLabel()` gain heading semantics automatically. Conjugation rows use `.accessibilityElement(children: .combine)` to merge pronoun and verb form into a single element — VoiceOver reads "er sang, a is irregular" instead of "er" ... "sang" as separate swipes.

**Quiz VoiceOver flow** — Three announcement methods in [`Quiz.swift`](Konjugieren/Models/Quiz.swift), all gated on `UIAccessibility.isVoiceOverRunning`: `announceQuestion()` uses `Current.utterer` for locale-aware speech synthesis; `announceAnswerResult()` and `announceQuizCompletion()` use `UIAccessibility.post(notification: .announcement)` for VoiceOver-native feedback. Timing uses `DispatchQueue.main.asyncAfter` to avoid interrupting the screen reader's UI-change announcements. An `@AccessibilityFocusState` binding in [`QuizView.swift`](Konjugieren/Views/QuizView.swift) automatically moves VoiceOver focus to the text field when the quiz advances.

**`CFBundleSpokenName`** — The [`Info.plist`](Konjugieren/Info.plist) key `CFBundleSpokenName` provides VoiceOver with a phonetic pronunciation guide (`"cone you gear en"`) so the app name is spoken correctly in English contexts.

### Technology Stack

- **SwiftUI** — Declarative UI with custom `ViewModifier`s and `TabView` navigation
- **Swift Testing** — Modern test framework (`@Test`, `#expect`) with 95 test functions
- **Game Center** — Global leaderboard for quiz scores via `GKAccessPoint`
- **XMLParser** — Streaming parser for verb and ablaut-group data (988 verbs, 66 patterns)
- **Custom URL scheme** — `konjugieren://` deeplinks for inter-article and verb navigation
- **Localization** — Full EN/DE support via `.xcstrings` string catalogs
- **Accessibility** — VoiceOver support with `AVSpeechSynthesizer`, `@AccessibilityFocusState`, `UIAccessibility.post`, and `CFBundleSpokenName`

### Testing

The test suite spans **1,800+ lines** across five files, with **95 test functions** covering conjugation logic, quiz state management, rich-text parsing, and time formatting.

The conjugation tests use a **mixed-case convention** to verify ablaut highlighting: lowercase letters represent unchanged portions, and UPPERCASE letters mark ablaut-changed regions. For example, `"sAng"` asserts that _singen_'s Präteritum changes "i" to "a" and the UI will highlight that change. This convention makes it immediately visible when a test expectation involves an ablaut transformation.

Crash-early validation in the XML parsers is tested via `FatalErrorSpy`, which captures error messages that would be `fatalError` calls in production. This ensures developer-controlled data files are validated without allowing silent corruption.

### Getting Started

```bash
git clone https://github.com/vermont42/Konjugieren.git
cd Konjugieren
open Konjugieren.xcodeproj
```

Select the **Konjugieren** scheme, choose an iOS 26 simulator, and build (Cmd-B). To run tests:

```bash
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -parallel-testing-enabled NO test
```

### Related Projects

- [**Conjuguer**](https://apps.apple.com/us/app/conjuguer/id1588624373) — French-verb conjugation app (iOS)
- [**Conjugar**](https://itunes.apple.com/us/app/conjugar/id1236500467?mt=8) — Spanish-verb conjugation app (iOS)
- [**racecondition.software**](https://racecondition.software) — Josh's development blog

### License

**Konjugieren** is licensed under the [GNU General Public License v3.0](LICENSE) in order to discourage release of low-quality clones to the App Store™.
