# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

This project uses the [`ios-build-verify`](https://github.com/vermont42/ios-build-verify) Claude Code skill for build and test. The scripts pipe `xcodebuild` through `xcbeautify` for concise output and tee raw output to `build.log` as a fallback. Per-project config lives in `.claude/ios-build-verify.config.sh` (gitignored).

Future Claude Code sessions in this project resolve the skill via plugin metadata and invoke `build_app.sh` / `run_tests.sh` by name. For terminal use, `--only-testing "Target/Suite/method()"` filters to a single test (Swift Testing requires the trailing `()` on method names — omitting them silently runs zero tests).

The skill also provides a verify half (launch the app, tap by accessibility identifier, screenshot, audit views). See its `SKILL.md` for the full operation surface.

### Verification configuration

| Setting | Value | Notes |
|---|---|---|
| `FIRST_SCREEN_ID` | `verb_browse_anchor` | On the verb-count `Text` in `VerbBrowseView.swift`. `launch_app.sh` polls for this identifier to confirm the app rendered. |
| `ONBOARDING_DISMISS_LABEL` | `Skip` | `launch_app.sh` interleaves a Skip-tap during wait-for-render so onboarding auto-dismisses. |
| `MAIN_TABS_COORDS` | per-project (5 tabs) | Calibrated via `measure_tab_pill.sh` (Pillow centroid detection); the shipped 3-tab defaults don't fit. Re-measure if tab-bar geometry changes. |

### App-specific friction: review-prompt UserDefaults accumulation

Konjugieren shows a custom "Enjoying Konjugieren?" review prompt gated by `promptActionCount` and `lastReviewPromptDate` cooldowns (see `Settings.swift`). On a simulator with accumulated UserDefaults — typical after exploratory testing — the prompt fires on launch and gates the AXTree, and `launch_app.sh` exits 5 with the modal-gating hint pointing at SKILL.md "Modal AXTree gating". Recovery: tap "Not Now" once (cooldown blocks subsequent prompts) or `xcrun simctl uninstall <UDID> biz.joshadams.Konjugieren` for a clean reset.

### Diagnostic fallback (raw xcodebuild)

When `xcbeautify`'s lossy filter drops an early-stage error or you need raw `xcodebuild` output:

```bash
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' build

xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test -only-testing:KonjugierenTests/ConjugatorTests/perfektpartizip\(\)
```

`build.log` (gitignored) preserves raw output from the last skill-script invocation; `grep -B2 -A20 'error:' build.log` is the deepest fallback for surfacing errors.

### Secrets Configuration

The TelemetryDeck app ID is stored in `Konjugieren/Secrets.xcconfig`, which is gitignored. To set up a fresh clone:

1. Copy `Konjugieren/Secrets.example.xcconfig` to `Konjugieren/Secrets.xcconfig`
2. Fill in the `TELEMETRY_DECK_APP_ID` value

If the app ID is empty (or `Secrets.xcconfig` is missing), analytics silently disables: the app builds and runs normally without it.

## Test Suite

The project uses Swift Testing (`import Testing`) for unit tests. Tests are located in `KonjugierenTests/`.

### ConjugatorTests Structure

`ConjugatorTests.swift` is a critical test file for conjugations, containing ~50 test functions organized by conjugationgroup and feature.

### The expectConjugation Helper

All conjugation tests use a private helper function:

```swift
private func expectConjugation(infinitiv: String, conjugationgroup: Conjugationgroup, expected: String) {
  let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup)
  switch result {
  case .success(let conjugation):
    #expect(conjugation == expected, "Expected \(infinitiv) → \(expected), got \(conjugation)")
  case .failure(let err):
    Issue.record("Failed to conjugate \(infinitiv): \(err)")
  }
}
```

### Mixed-Case Convention in Test Expectations

Test expected values use mixed case to indicate ablaut changes:
- **Lowercase** = expected/unchanged portions of the conjugation
- **UPPERCASE** = unexpected/ablaut-changed portions

Examples:
```swift
// Strong verb singen: i→a in Präteritum
expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndicativ(.firstSingular), expected: "sAng")

// Modal verb wissen: irregular Präsens
expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "wEIsS")

// Irregular sein: highly irregular forms
expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndicativ(.firstSingular), expected: "BIN")
```

This convention helps verify that `Conjugator` correctly identifies and marks ablaut regions for UI highlighting.

### Adding Tests for New Verbs

When adding tests for a new verb or ablaut pattern:

1. **Find the appropriate test function** based on what you're testing (e.g., `modalVerbs()` for modal verbs, `newAblautGroups()` for new patterns)

2. **Add test cases** using the helper:
   ```swift
   // Comment explaining the verb pattern
   expectConjugation(infinitiv: "verbname", conjugationgroup: .conjugationgroup(.person), expected: "expectedForm")
   ```

3. **Follow the mixed-case convention** for expected values: uppercase letters mark the ablaut-changed portions

4. **Run the specific test** to verify:
   ```bash
   xcodebuild ... -only-testing:KonjugierenTests/ConjugatorTests/testFunctionName()
   ```

## Architecture Overview

Konjugieren is an iOS app for learning German verb conjugations. It will eventually conjugate 1,000 verbs across all German conjugationgroups ("tenses" in ordinary (and incorrect) parlance). Konjugieren uses SwiftUI for its user interface.

## About the Human Developer

Josh Adams (pronouns: he/him/his) is the human developer of Konjugieren. He is an iOS-app developer, from New England but based near San Francisco, California. He also created Conjuguer (French), Conjugar (Spanish), and RaceRunner, all available in the iOS App Store. When thinking or speaking about him, say "he" or "Josh", not "they" or "the developer".

Josh created Konjugieren as a tribute to his grandfather, Clifford August Schmiesing (1904–1944), who was born in Minster, Ohio, a town where German was the language of daily life. Cliff served as an Army doctor in World War II and died in Oran, Algeria. The dedication in the app tells his story.

Josh explicitly identifies with a Weltanschauung of curiosity and delight at seeing connections, especially etymological, historical, and cross-domain links. He appreciates when Claude traces roots, surfaces unexpected cognates, and makes the invisible threads between concepts visible. This isn't just tolerance of tangents; it's a shared value. Lean into it when the work naturally surfaces something worth connecting.

## About Claude Code, the Other Developer

The Claude Code mascot is **Clawd** 🦀, a small, pixelated, crab-like character introduced in late 2025. When referring to Claude Code in informal contexts or celebrating a successful collaboration, use the crab emoji. Example: 🧠🤜🤛🦀 (human-AI fist bump).

## Project Structure

See [`docs/project-structure.md`](docs/project-structure.md) for the full annotated directory tree.

**Cache maintenance:** When you add, remove, or rename a source file, update `docs/project-structure.md` to match. This doc is a cache. Future contexts rely on it to orient quickly, so staleness has a real cost.

## Xcode Project Organization: Folders, Not Groups

This project uses **folder references** (the modern Xcode default) rather than the legacy flat-group structure. The filesystem directory hierarchy *is* the project hierarchy; Xcode mirrors it automatically. Consequences:

- **Adding a file** to the correct filesystem directory is sufficient. There is no need to manually edit `Konjugieren.xcodeproj/project.pbxproj` to register new files.
- **Do not** use `PBXGroup`/`PBXFileReference` manipulation scripts or worry about stale `.pbxproj` entries when creating or moving files.

## Memory Feature

Do not save facts to Claude Code's memory system. If a fact from the conversation seems worth preserving across sessions, inform Josh and propose a location inside the project, typically CLAUDE.md or a doc under `docs/`, so it lives in git alongside the code. Josh's reasoning: for a solo developer, project-stored facts are more visible, reviewable in diffs, and backed up by GitHub.

## Comments

Code should be well-written and therefore self-explanatory. Explanatory and MARK comments result in clutter and increased maintenance burden. Only use comments for the following purposes:

* File headers
* TODOs
* Hacks or workarounds

When reviewing code, do not flag these types of comments.

## English Writing Conventions

When writing or editing any English text (localization strings, documentation, comments), consult [`docs/english_writing_style.md`](docs/english_writing_style.md).

## Swift Coding Conventions

### Avoid Force-Unwrapping

In production code, use the nil-coalescing operator (`??`) with an appropriate fallback rather than force-unwrapping (`!`). If the nature of the fallback is non-obvious, ask Josh.

```swift
// Prefer this
static var random: String {
  allCases.randomElement()?.rawValue ?? fallback
}

// Avoid this
static var random: String {
  allCases.randomElement()!.rawValue
}
```

This rule does not apply in unit tests, where force-unwrapping is, by convention, acceptable.

### Switch Statement Formatting

Place code executed in switch cases on separate lines from the case label. This aids both reading and debugging.

```swift
// Prefer this
switch setting {
case .optionA:
  return L.Setting.optionA
case .optionB:
  return L.Setting.optionB
}

// Avoid this
switch setting {
case .optionA: return L.Setting.optionA
case .optionB: return L.Setting.optionB
}
```

### One Enum Case Per Line

Declare each enum case on its own line. Do not combine multiple cases with commas.

```swift
// Prefer this
enum Foo {
  case qux
  case baz
}

// Avoid this
enum Foo {
  case qux, baz
}
```

### Alphabetize Enum Cases

Declare enum cases in alphabetical order. This makes it easy to find cases in large enums and ensures a consistent ordering convention.

Exception: Enums whose case order carries semantic meaning (lifecycle states, linguistic conventions, UI display order) may retain their natural ordering. Add a comment like `// Semantic ordering: <reason>` above such enums.

### @ViewBuilder Has No Child Limit

The old 10-child `@ViewBuilder` limit was removed in Swift 5.9 via variadic generics. Do not wrap children in `Group {}` to work around a limit that no longer exists.

## Swift 6 and Default Main-Actor Isolation

The project uses **Swift 6** (`SWIFT_VERSION = 6.0`) with **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`** (an Xcode 26 / Swift 6.2 setting). This means every type in the app module defaults to `@MainActor` unless explicitly opted out. Key consequences:

### Pure Functions Need `nonisolated`

Static or instance methods that perform pure computation (no UI, no `@MainActor`-isolated dependencies) must be marked `nonisolated`. Otherwise, nonisolated callers (including test code) cannot invoke them.

```swift
enum TimeFormatter {
  // Pure math: explicitly nonisolated
  nonisolated static func formatIntTime(_ time: Int) -> String { ... }
}
```

### Nonisolated Protocol Conformances

Some protocols (e.g., TipKit's `Tip`) declare their properties as `nonisolated`. Because `L.*` accessors use `String(localized:)` (which is `@MainActor` via `Bundle.main`), you cannot call `L.*` from nonisolated protocol properties. Instead, use `LocalizedStringKey` string literals:

```swift
// Correct: string literal becomes LocalizedStringKey, resolved at render time
var title: Text { Text("Tips.tryQuizTitle") }

// Wrong: L.Tips.tryQuizTitle is @MainActor, but Tip.title is nonisolated
var title: Text { Text(L.Tips.tryQuizTitle) }
```

### Test Suites Need `@MainActor`

Test suites that call into `@MainActor`-isolated app code must be annotated `@MainActor`. In Swift Testing, **`@MainActor` does not propagate to nested `@Suite` structs**. Each nested struct needs its own annotation:

```swift
@MainActor
@Suite("Outer")
struct OuterTests {
  @MainActor  // Required, not inherited from parent
  @Suite("Inner")
  struct InnerTests {
    @Test func example() { ... }
  }
}
```

## Terminology

See [`docs/terminology.md`](docs/terminology.md) for conjugationgroup definitions, tense/mood/voice distinctions, and the full conjugationgroup table. Key rule: avoid using "tense" to describe conjugationgroups.

### Prefer "Conjugation" Over "Form"

When referring to a specific inflected verb in English text, use "conjugation" rather than "form." Example: "every conjugation of every verb," not "every form of every verb."

## Writing Conjugationgroup Articles

These are instructions for writing a description (e.g., `perfektpartizipText`) for a new conjugationgroup. See [`docs/conjugationgroupText.md`](docs/conjugationgroupText.md) for:

- Literary source URLs (Goethe, Kafka, Mann - German and English)
- Old High German text references (Hildebrandslied, Tatian)
- Rich-text markup conventions
- Article structure template
- Content guidelines and verification steps

When asked to create a new conjugationgroup article (e.g., "Please create präsensIndikativText, English only"), consult that template file.

## Adding Verbs

See [`docs/adding-verbs.md`](docs/adding-verbs.md) for the complete verb-addition guide, including XML formats, the ablaut system, verb families, and lessons learned.

## Dependency Injection

The app uses a simple dependency injection pattern via `Models/World.swift`:

```swift
var Current = World.chooseWorld()

@MainActor
@Observable
class World {
  var settings: Settings
  var gameCenter: GameCenter
  var soundPlayer: SoundPlayer
  var verb: Verb?       // For deeplink navigation
  var family: String?   // For deeplink navigation
  var info: Info?       // For deeplink navigation
}
```

`World.chooseWorld()` selects the appropriate configuration:
- **Device/Simulator**: Uses `GetterSetterReal`, `GameCenterReal`, `SoundPlayerReal`
- **Unit Tests**: Uses `GetterSetterFake`, `GameCenterDummy`, `SoundPlayerDummy`

Access dependencies anywhere using syntax like `Current.settings`. This pattern enables:
- Easy mocking in tests (swap `Current` with a test-configured `World`)
- Centralized dependency management
- Reactive UI updates (World uses `@Observable`)
- Deeplink handling via `Current.handleURL(_:)`

## Settings System

Settings are managed by `Settings.swift`, an `@Observable` class that persists to UserDefaults via `GetterSetter`.

### Current Settings

| Setting | Enum / Type | Default | Description |
|---------|-------------|---------|-------------|
| `conjugationgroupLang` | `ConjugationgroupLang` | `.german` | Display conjugationgroup names in German or English |
| `thirdPersonPronounGender` | `ThirdPersonPronounGender` | `.er` | Which 3rd-person-singular pronoun to show (er/sie/es) |
| `quizDifficulty` | `QuizDifficulty` | `.regular` | Quiz difficulty level |
| `audioFeedback` | `AudioFeedback` | `.enable` | Enable/disable sound effects |
| `searchScope` | `SearchScope` | `.infinitiveOnly` | Search by infinitive only or also by translation |
| `appIcon` | `AppIcon` | `.hat` | Alternate app icon (hat/pretzel/bundestag) |
| `hasSeenOnboarding` | `Bool` | `false` | Whether the user has completed onboarding |
| `gameHighScore` | `Int` | `0` | Highest score achieved in the game |
| `promptActionCount` | `Int` | `0` | Action count for review-prompt eligibility |
| `lastReviewPromptDate` | `Date?` | `nil` | When the user was last prompted to review |

### Adding a New Setting

1. **Create the enum** in `Models/` following this pattern:

```swift
enum MySetting: String, CaseIterable {
  case optionA
  case optionB

  var localizedMySetting: String {
    switch self {
    case .optionA: return L.MySetting.optionA
    case .optionB: return L.MySetting.optionB
    }
  }
}
```

2. **Add to Settings.swift**:

```swift
var mySetting: MySetting = mySettingDefault {
  didSet {
    if mySetting != oldValue {
      getterSetter.set(key: Settings.mySettingKey, value: "\(mySetting)")
    }
  }
}
static let mySettingKey = "mySetting"
static let mySettingDefault: MySetting = .optionA

// In init(), add:
if let mySettingString = getterSetter.get(key: Settings.mySettingKey) {
  mySetting = MySetting(rawValue: mySettingString) ?? Settings.mySettingDefault
} else {
  getterSetter.set(key: Settings.mySettingKey, value: "\(mySetting)")
}
```

3. **Add localization strings** to `L.swift` and `Localizable.xcstrings`

4. **Add UI** to `SettingsView.swift`

### Setting Description Consistency

Setting descriptions in `Localizable.xcstrings` should begin with "This setting determines..." to maintain consistency across all settings.

## Feature Architecture

See [`docs/feature-architecture.md`](docs/feature-architecture.md) for architecture details on the Quiz, Game Center, Info, and Deeplink systems.

## On-Device Tool Design

See [`docs/on-device-tool-design.md`](docs/on-device-tool-design.md) for lessons learned from implementing Foundation Models `Tool` conformances. Key rule: minimize what the model must decide. Push complexity into tool code, not the tool schema.

## Control Center Controls

See [`docs/control-center-controls.md`](docs/control-center-controls.md) for iOS 18+ constraints on `openAppWhenRun` and `OpenURLIntent` from widget extensions, plus the `Shared/` dual-target pattern that makes ControlWidget intents actually open the app.

## Localization System

The app uses a two-part localization system:

### L.swift

Type-safe localization accessors organized by feature:

```swift
enum L {
  enum Settings {
    static var conjugationgroupLangHeading: String {
      String(localized: "Settings.conjugationgroupLangHeading")
    }
  }

  enum ThirdPersonPronounGender {
    static var er: String { String(localized: "ThirdPersonPronounGender.er") }
    static var sie: String { String(localized: "ThirdPersonPronounGender.sie") }
    static var es: String { String(localized: "ThirdPersonPronounGender.es") }
  }
}
```

### Localizable.xcstrings

JSON-based string catalog supporting multiple languages. Each key maps to translations:

```json
"Settings.thirdPersonPronounGenderHeading" : {
  "localizations" : {
    "de" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Pronomen 3. Person"
      }
    },
    "en" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "3P-Pronoun Gender"
      }
    }
  }
}
```

### Editing Localizable.xcstrings Safely

The Edit tool operates on **rendered text**, not raw JSON. This means the JSON escape sequence `\"` appears as a plain `"` in Edit's view. Consequently, any edit that adds, removes, or changes an ASCII double quote (`"`, U+0022) inside a JSON string value silently produces an unescaped `"` in the raw file, breaking JSON syntax.

**Safe quote types:** Unicode curly quotes (`"` `"` `„`) need no JSON escaping and can be edited freely with the Edit tool.

**The rule:** When an edit to a `.xcstrings` string value involves adding, removing, or changing ASCII `"` (U+0022) characters, use Python via Bash to perform the replacement on the raw file content, not the Edit tool. For example:

```bash
python3 -c "
import pathlib, re
p = pathlib.Path('Konjugieren/Assets/Localizable.xcstrings')
t = p.read_text()
t = t.replace('old escaped content', 'new escaped content')
p.write_text(t)
"
```

**Validation:** After every `.xcstrings` edit (regardless of tool used), validate JSON integrity before building:

```bash
python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"
```

### Searching Within Localizable.xcstrings

Each localization value in `Localizable.xcstrings` occupies a single very long JSON line. Grep matches against these lines are truncated to `[Omitted long matching line]`, making Grep results useless for inspecting content. Instead:

1. **To find which key contains a phrase:** Use Grep to get the line number, then use Read with an offset to view that line.
2. **To find and replace text:** Use Python via Bash. Use a unique nearby string as an anchor to target the correct language section (e.g., a German word like `könnte bedeuten` to distinguish `de` from `en`).

### Adding New Localized Strings

1. Add the accessor to `L.swift` in the appropriate enum
2. Add the key and translations to `Localizable.xcstrings`
3. Use via `L.FeatureName.stringName` in code

### Naming Conventions

- Keys follow the pattern: `FeatureName.stringPurpose`
- Examples: `Settings.conjugationgroupLangHeading`, `Navigation.verbs`, `History.stardustTitle`

### Rich Text Markup in Localizable.xcstrings

Long-form Info text (like `verbHistoryText`, `dedicationText`, `creditsText`) uses a custom markup system. The markup is parsed by `StringExtensions.swift` and rendered by `RichTextView.swift`:

| Marker | Purpose | Example |
|--------|---------|---------|
| `` ` `` | Section headings (rendered larger/styled) | `` `Von Sternenstaub zur Sprache` `` |
| `~` | Bold/emphasis | `~Homo sapiens~`, `~ablaut~` |
| `$...$` | Ablaut highlighting (uppercase = changed vowel) | `$sAng$`, `$gesUngen$`, `$kÄme$` |
| `%...%` | Clickable URLs | `%https://github.com/vermont42/Konjugieren%` |
| 🇩🇪 | Bullet points in lists | `🇩🇪 ~Imperfektiv~: andauernde Handlung` |

Other emoji are sometimes appropriate for bullet lists. For example, 🏴󠁧󠁢󠁥󠁮󠁧󠁿 should precede an English bullet item, and 🐎 should precede a Proto-Indo-European bullet item.

**Headings concatenate directly: no preceding newline.** `RichTextView` adds its own top/bottom spacing around backtick-delimited headings. Inserting `\n` or `\n\n` before a heading produces a visible extra blank line in the rendered view on top of the parser's built-in margin. Match the surrounding convention: sections run `"…end of paragraph.\`Next Heading\`\nFirst line…"` with no whitespace before the opening backtick. Before inserting a new section into a long-form Info text, scan the existing headings with `re.finditer(r'\`[^\`]+\`', value)` in Python to confirm the article's convention, since raw JSON hides the rendered spacing.

### Relocalization Workflow

When the English version of a long text is edited, the German version must be relocalized:

1. **Translate the prose** while maintaining natural German flow
2. **Preserve all markup** in equivalent positions
3. **Do NOT localize**:
   - English example words with translations: `(sing, $sAng$, $sUng$)`
   - God names: Wōðanaz, Þunaraz, Wōden, Óðinn, Þórr, Týr, etc.
   - Reconstructed PIE forms: `*bʰer-`, `*e-`, `*dō-`
   - Latin scholarly terms used in context: ~Germani~, ~comitatus~, ~limes~, ~kurgans~
4. **Match heading structure** exactly between languages

## VoiceOver and Mixed-Language Pronunciation

See [`docs/voiceover.md`](docs/voiceover.md) for VoiceOver pronunciation patterns, workarounds, and per-screen strategy. Key constraint: per-child `.environment(\.locale)` does NOT work inside `NavigationLink` or `Button`. Use programmatic `NavigationPath` navigation instead.

## On the Moral Underpinnings of Anthropic Models
- Constitution co-authored by Amanda Askell and Joe Carlsmith
- Contributors included Father Brendan McGuire (CS/Math, Los Altos) and Bishop Paul Tighe (Roman curia, moral theology)
- Virtue ethics was chosen deliberately over deontological rules