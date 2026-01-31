# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

This is an Xcode project. Use the following commands:

```bash
# Build the app
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run tests (disable parallel testing to avoid simulator flakiness)
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test

# Run a single test class
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test -only-testing:KonjugierenTests/Models/ConjugatorTests

# Run a single test method
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test -only-testing:KonjugierenTests/Models/ConjugatorTests/perfektpartizip
```

## Architecture Overview

Konjugieren is an iOS app for learning German verb conjugations. It will eventually conjugate 1,000 verbs across all German conjugationgroups ("tenses" in ordinary (and incorrect) parlance). Konjugieren uses SwiftUI for its user interface.

## About the Developer

Josh Adams (pronouns: he/him/his) is the developer of Konjugieren. He is an iOS-app developer, from New England but based near San Francisco, California. He also created Conjuguer (French), Conjugar (Spanish), and RaceRunner, all available in the iOS App Store. When thinking or speaking about him, say "he" or "Josh", not "they" or "the developer".

Josh created Konjugieren as a tribute to his grandfather, Clifford August Schmiesing (1904–1944), who was born in Minster, Ohio—a town where German was the language of daily life. Cliff served as an Army doctor in World War II and died in Oran, Algeria. The dedication in the app tells his story.

## Project Structure

```
Konjugieren/
├── App/
│   ├── KonjugierenApp.swift    # Main app entry point with Game Center auth
│   ├── AppLauncher.swift       # Chooses TestApp vs KonjugierenApp based on environment
│   └── TestApp.swift           # Minimal app for unit test environment
├── Assets/
│   ├── Localizable.xcstrings   # Localization strings (JSON format, EN/DE)
│   └── Assets.xcassets/        # Colors, app icon, images (CliffSchmiesing, JoshAdams)
├── Models/
│   ├── Verb.swift              # Verb model with stamm/ablaut-region computation
│   ├── VerbParser.swift        # XMLParser delegate that parses Verbs.xml
│   ├── Verbs.xml               # ~200 verb definitions with markers and metadata
│   ├── Conjugator.swift        # Core conjugation logic for all conjugationgroups
│   ├── ConjugatorError.swift   # Error enum for conjugation failures
│   ├── Conjugationgroup.swift  # Enum of all conjugationgroups with endings
│   ├── ConjugationgroupLang.swift  # Setting enum: german/english display
│   ├── ThirdPersonPronounGender.swift  # Setting enum: er/sie/es preference
│   ├── Ablaut.swift            # Single ablaut: replacement + target conjugationgroups
│   ├── AblautGroup.swift       # Named collection of ablauts for a verb pattern
│   ├── AblautGroupParser.swift # XMLParser delegate that parses AblautGroups.xml
│   ├── AblautGroups.xml        # ~40 ablaut pattern definitions
│   ├── Family.swift            # Verb families (strong/weak/mixed/ieren)
│   ├── PersonNumber.swift      # 1s, 2s, 3s, 1p, 2p, 3p with localized pronouns
│   ├── Prefix.swift            # Separable/inseparable prefix enum
│   ├── Auxiliary.swift         # haben/sein auxiliary verb enum
│   ├── Quiz.swift              # @Observable quiz state: questions, timer, scoring
│   ├── QuizDifficulty.swift    # Setting enum: regular vs ridiculous
│   ├── AudioFeedback.swift     # Setting enum: enable/disable sound effects
│   ├── SortOrder.swift         # Enum for verb list sorting (alphabetical/frequency)
│   ├── Sound.swift             # Sound effect definitions (guns, chimes, applause)
│   ├── Info.swift              # Info article model with rich text and images
│   ├── ImageInfo.swift         # Struct pairing image filename with accessibility label
│   └── World.swift             # @Observable DI container with environment selection
├── Utils/
│   ├── Settings.swift          # @Observable settings with UserDefaults persistence
│   ├── L.swift                 # Type-safe localization string accessors
│   ├── GetterSetter.swift      # Protocol for key-value storage abstraction
│   ├── GetterSetterReal.swift  # UserDefaults implementation of GetterSetter
│   ├── GetterSetterFake.swift  # In-memory dictionary implementation for tests
│   ├── GameCenter.swift        # Protocol for Game Center operations
│   ├── GameCenterReal.swift    # Real GKLocalPlayer authentication and scores
│   ├── GameCenterDummy.swift   # No-op implementation for tests/simulator
│   ├── SoundPlayer.swift       # Protocol for audio playback
│   ├── SoundPlayerReal.swift   # AVAudioPlayer implementation with debouncing
│   ├── SoundPlayerDummy.swift  # No-op implementation for tests
│   ├── TimeFormatter.swift     # Formats elapsed seconds as h:mm:ss
│   ├── Fonts.swift             # Font constants for consistent typography
│   ├── Layout.swift            # Spacing constants (8pt, 16pt, 24pt)
│   ├── Modifiers.swift         # Custom ViewModifiers (headingLabel, funButton, etc.)
│   ├── StringExtensions.swift  # Rich text markup parsing to RichTextBlock/TextSegment
│   ├── TextExtension.swift     # Text(mixedCaseString:) for ablaut-highlighted display
│   └── URLExtension.swift      # Deeplink URL helpers (konjugieren:// scheme)
└── Views/
    ├── MainTabView.swift       # Root TabView with five tabs
    ├── VerbBrowseView.swift    # Searchable, sortable list of all verbs
    ├── VerbView.swift          # Verb detail showing all conjugations
    ├── FamilyBrowseView.swift  # Placeholder for verb family browser (coming soon)
    ├── QuizView.swift          # Quiz gameplay: questions, timer, answer input
    ├── ResultsView.swift       # Modal showing quiz results and leaderboard button
    ├── InfoBrowseView.swift    # List of Info articles (dedication, history, etc.)
    ├── InfoView.swift          # Detail view for a single Info article
    ├── RichTextView.swift      # Renders RichTextBlock content with styling
    └── SettingsView.swift      # Settings UI with segmented pickers
```

## Comments

Code should be well-written and therefore self-explanatory. Explanatory and MARK comments result in clutter and increased maintenance burden. Only use comments for the following purposes:

* File headers
* TODOs
* Hacks or workarounds

When reviewing code, do not flag these two types of comments.

## Terminology

### Conjugation Group

The term "conjugationgroup" was invented for this project because no existing term adequately described the concept. A conjugationgroup with more than one member, like Präsens Indikativ, combines tense, mood, and voice to identify a specific set of verb forms. The conjugationgroups with one member are Infinitiv (infinitive), Perfektpartizip (past participle), and Präsenspartizip (present participle). When translating conjugationgroup to German, use the word "Conjugationgroup", plural "Conjugationgroups". By analogy with Gruppe, Conjugationgroup is a feminine noun.

### Tense, Mood, and Voice

In discourse about Indo-European languages, "tense" refers only to the time that an action occurs. German conjugationgroups have three tenses:
- **Präsens** (present)
- **Präteritum** (past)
- **Futur** (future)

There is no Futur Partizip (participle).

Multiple-member (not Perfektpartizip or Präsenspartizip) German verbs are also encoded with **mood**. German has four moods:
- **Indikativ** - corresponds to the English indicative mood
- **Konjunktiv I** - corresponds to the English subjunctive mood
- **Konjunktiv II** - corresponds to the English conditional mood
- **Imperativ** - corresponds to the English imperative mood

Multiple-member conjugationgroup have a tense and mood. For example, Präsens Indikativ has Präsens tense and Indikativ mood. Certain tense/mood combinations do not occur. For example, there is no conjugationgroup for Futur/Imperativ.

Multi-member conjugationgroups also sometimes encode **voice**. In English, the two voices are active and passive. German has Aktiv (active) voice and two passive voices, Vorgangspassiv and Zustandpassiv.

### Conjugationgroups Currently in This Codebase

#### Simple Conjugationgroups

| Conjugationgroup | Tense | Mood | English Equivalent |
|-------------------|-------|------|-------------------|
| Präsens Indikativ | Präsens | Indikativ | Present indicative |
| Präteritum Indikativ | Präteritum | Indikativ | Past indicative |
| Präsens Konjunktiv I | Präsens | Konjunktiv I | Present subjunctive |
| Präteritum Konjunktiv II | Präteritum | Konjunktiv II | Past conditional |
| Imperativ | - | Imperativ | Imperative |
| Perfektpartizip | Präteritum | - | Past participle |
| Präsenspartizip | Präsens | - | Present participle |

#### Compound Conjugationgroups

These conjugationgroups use auxiliary verbs (haben/sein or werden) combined with the Perfektpartizip or Infinitiv:

**Perfekt (auxiliary in Präsens + Perfektpartizip):**

| Conjugation Group | Auxiliary Tense | Auxiliary Mood | English Equivalent |
|-------------------|-----------------|----------------|-------------------|
| Perfekt Indikativ | Präsens | Indikativ | Present perfect indicative |
| Perfekt Konjunktiv I | Präsens | Konjunktiv I | Present perfect subjunctive |

**Plusquamperfekt (auxiliary in Präteritum + Perfektpartizip):**

| Conjugation Group | Auxiliary Tense | Auxiliary Mood | English Equivalent |
|-------------------|-----------------|----------------|-------------------|
| Plusquamperfekt Indikativ | Präteritum | Indikativ | Pluperfect indicative |
| Plusquamperfekt Konjunktiv II | Präteritum | Konjunktiv II | Pluperfect conditional |

**Futur (werden + Infinitiv):**

| Conjugation Group | Auxiliary Tense | Auxiliary Mood | English Equivalent |
|-------------------|-----------------|----------------|-------------------|
| Futur Indikativ | Präsens | Indikativ | Future indicative |
| Futur Konjunktiv I | Präsens | Konjunktiv I | Future subjunctive |
| Futur Konjunktiv II | Präsens | Konjunktiv II | Future conditional |

### Usage Notes

- Avoid using "tense" to describe conjugationgroups
- The participles (Perfektpartizip, Präsenspartizip) do not have mood
- Compound conjugationgroups combine an auxiliary verb conjugation with the Perfektpartizip

## Writing Conjugationgroup Articles

These are instructions for writing a description (e.g., `perfektpartizipText`) for a new conjugationgroup. See `conjugationgroupText.md` in the project root for:

- Literary source URLs (Goethe, Kafka, Mann - German and English)
- Old High German text references (Hildebrandslied, Tatian)
- Rich-text markup conventions
- Article structure template
- Content guidelines and verification steps

When asked to create a new conjugationgroup article (e.g., "Please create präsensIndikativText, English only"), consult that template file.

## XML File Formats

### Verbs.xml

Defines verbs with their properties:

```xml
<verb in="an+k^om^men" tn="arrive" ay="s" fr="255" ag="kommen" fa="s" />
```

| Attribute | Meaning | Required |
|-----------|---------|----------|
| `in` | Infinitive with markers (see below) | Yes |
| `tn` | Translation | Yes |
| `fa` | Family: `s`=strong, `m`=mixed, `w`=weak, `i`=ieren | Yes |
| `fr` | Frequency rank (lower = more common) | Yes |
| `ag` | Ablaut group name (required for strong/mixed) | Conditional |
| `ay` | Auxiliary: `s`=sein, `h`=haben (default: haben) | No |

**Infinitive markers:**
- `+` separates a separable prefix (e.g., `an+kommen` → ankommen)
- `*` separates an inseparable prefix (e.g., `ver*stehen` → verstehen)
- `^` marks ablaut region boundaries (e.g., `k^om^men` → ablaut region is "om")

### AblautGroups.xml

Defines vowel/consonant changes for strong and mixed verbs:

```xml
<ag e="sehen" a="ie,a2s,a3s|a,bA|ä,dA" />
```

| Attribute | Meaning |
|-----------|---------|
| `e` | Exemplar (name of the ablaut group) |
| `a` | Ablaut patterns separated by `\|` |

**Ablaut pattern format:** `replacement,group1,group2,...`

**Conjugation group codes:**
- `a` = Präsens Indikativ (a1s, a2s, a3s, a1p, a2p, a3p, aA=all)
- `b` = Präteritum Indikativ (b1s, b2s, b3s, b1p, b2p, b3p, bA=all)
- `c` = Präsens Konjunktiv I (c1s, c2s, c3s, c1p, c2p, c3p, cA=all)
- `d` = Präteritum Konjunktiv II (d1s, d2s, d3s, d1p, d2p, d3p, dA=all)
- `pp` = Perfektpartizip
- `i` = Imperativ (i2s, i1p, i2p, i3p, iA=all)

**Full override:** Append `*` to replacement to use it as the complete conjugated form, not adding the usual ending. This is used for highly irregular verbs like sein:

```xml
<ag e="sein" a="bin*,a1s|bist*,a2s|ist*,a3s|..." />
```

## The Ablaut System

German strong and mixed verbs undergo vowel and other changes (ablaut) in different conjugation groups. The system works as follows:

1. **Verb definition** marks the ablaut region with `^` characters
2. **Ablaut group** defines what replacements occur for each conjugation group
3. **Conjugator** applies the replacement at runtime

**Example: sehen (to see)**
- Infinitive: `s^e^hen` (ablaut region is "e" at indices 1..<2)
- Stamm: "seh"
- Ablaut group: `IE,a2s,a3s|A,bA|Ä,dA`
- Results:
  - Präsens 2s: replace "e" with "ie" → "sieh" + "st" = "siehst"
  - Präteritum: replace "e" with "a" → "sah" + endings
  - Konjunktiv II: replace "e" with "ä" → "säh" + endings

## Adding a New Verb

### Weak or -ieren Verb (Regular)

Simply add to Verbs.xml without ablaut markers:

```xml
<verb in="machen" tn="make, do" fr="8" fa="w" />
<verb in="studieren" tn="study" fr="353" fa="i" />
```

### Strong or Mixed Verb

1. **Add to Verbs.xml** with ablaut markers and group reference:
   ```xml
   <verb in="s^i^ngen" tn="sing" fr="354" ag="singen" fa="s" />
   ```

2. **Add ablaut group to AblautGroups.xml** (if new pattern):
   ```xml
   <ag e="singen" a="A,bA|Ä,dA|U,pp" />
   ```

3. **Look up conjugation** on German Wiktionary: `https://de.wiktionary.org/wiki/Flexion:VERB`

### Verb with Prefix

- Separable prefix: use `+` (e.g., `an+kommen`)
- Inseparable prefix: use `*` (e.g., `ver*stehen`)

Prefixed verbs can share an ablaut group with their base verb.

### Alphabetical Ordering

Both XML files must maintain alphabetical order:

- **Verbs.xml**: Sort by the German verb name, ignoring prefix markers (`+`, `*`) and ablaut markers (`^`). For example, `an+k^om^men` sorts as "ankommen" and `g^e^lten` sorts as "gelten". Umlauts sort as their base vowels (ä≈a, ö≈o, ü≈u).

- **AblautGroups.xml**: Sort by the exemplar verb name (`e` attribute).

## Verb Families

| Family | Description | Präteritum Endings | Perfektpartizip |
|--------|-------------|-------------------|-----------------|
| Strong | Vowel change (ablaut) | No -te suffix | ge- + stamm + -en |
| Mixed | Vowel change + weak endings | -te suffix | ge- + stamm + -t |
| Weak | Regular, no vowel change | -te suffix | ge- + stamm + -t |
| -ieren | Verbs ending in -ieren | -te suffix | stamm + -t (no ge-) |

## Common Wiktionary Reference

For verb conjugations: `https://de.wiktionary.org/wiki/Flexion:VERBNAME`

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

| Setting | Enum | Default | Description |
|---------|------|---------|-------------|
| `conjugationgroupLang` | `ConjugationgroupLang` | `.german` | Display conjugationgroup names in German or English |
| `thirdPersonPronounGender` | `ThirdPersonPronounGender` | `.er` | Which 3rd-person-singular pronoun to show (er/sie/es) |
| `quizDifficulty` | `QuizDifficulty` | `.regular` | Quiz difficulty level |
| `audioFeedback` | `AudioFeedback` | `.enable` | Enable/disable sound effects |

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

## Quiz System

The quiz tests users' knowledge of German verb conjugations with timed, scored gameplay.

### Architecture

| File | Purpose |
|------|---------|
| `Quiz.swift` | `@Observable` class managing quiz state and logic |
| `QuizView.swift` | SwiftUI view for active quiz gameplay |
| `ResultsView.swift` | Modal sheet showing final results |
| `QuizDifficulty.swift` | Difficulty setting enum |

### Quiz Flow

1. User taps "Start" → `quiz.start()` generates 30 questions
2. Timer begins, questions presented one at a time
3. User types conjugation, presses return → `quiz.submitAnswer()`
4. After 30 questions → `quiz.finishQuiz()` shows ResultsView

### Question Generation

- **1** Präsenspartizip question
- **2** Perfektpartizip questions
- **27** other conjugationgroups (varies by difficulty)

**Regular difficulty:** Präsens Indikativ, Perfekt Indikativ, Imperativ

**Ridiculous difficulty:** Adds Präsens Konjunktiv I, Präteritum Indikativ, Präteritum Konjunktiv II, Perfekt Konjunktiv I

### Scoring

- **10 points** per correct answer
- **Ridiculous difficulty:** 2x multiplier on final score
- `quiz.finalScore` returns the multiplied score

### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `isInProgress` | `Bool` | Quiz currently active |
| `currentIndex` | `Int` | Current question (0-29) |
| `score` | `Int` | Raw score (before multiplier) |
| `finalScore` | `Int` | Score with difficulty multiplier |
| `elapsedSeconds` | `Int` | Time elapsed |
| `correctCount` | `Int` | Number correct |
| `questions` | `[QuizItem]` | All 30 questions |

### Sound Effects

Quiz uses `SoundPlayer` for audio feedback:
- **Start:** Random gun sound
- **Correct answer:** Chime
- **Incorrect answer:** Buzz
- **Quit:** Random sad trombone
- **Finish:** Random applause

## Game Center Integration

The app integrates with Game Center to submit quiz scores to a global leaderboard.

### Architecture

| File | Purpose |
|------|---------|
| `GameCenter.swift` | Protocol defining authentication and score submission |
| `GameCenterReal.swift` | Real GKLocalPlayer implementation |
| `GameCenterDummy.swift` | No-op implementation for tests |
| `ResultsView.swift` | Shows "View Leaderboard" button when authenticated |

### Leaderboard Configuration

- **Leaderboard ID:** `Leaderboard`
- **Score:** `quiz.finalScore` (includes 2x multiplier for ridiculous difficulty)
- **Sort Order:** High to Low

### iOS 26 API Notes

The implementation uses `GKAccessPoint.shared.trigger(leaderboardID:playerScope:timeScope:handler:)` to display the leaderboard. This replaces the deprecated `GKGameCenterViewController` and `GKGameCenterControllerDelegate` APIs.

### Authentication Flow

1. `KonjugierenApp.init()` calls `Current.gameCenter.authenticate()`
2. iOS presents Game Center login UI if needed
3. `gameCenter.isAuthenticated` becomes `true` when successful

### Score Submission

Scores are submitted automatically in `Quiz.finishQuiz()`:

```swift
Task {
  await Current.gameCenter.submitScore(finalScore)
}
```

### Key Methods

| Method | Description |
|--------|-------------|
| `authenticate()` | Initiates Game Center authentication |
| `submitScore(_ score: Int)` | Submits score to leaderboard (async) |
| `showLeaderboard()` | Triggers Game Center leaderboard via `GKAccessPoint` |

### App Store Connect Setup

Before the leaderboard works, configure in App Store Connect:
1. Navigate to **Features** → **Game Center**
2. Enable Game Center for the app
3. Create leaderboard with ID `Leaderboard`

## Info System

The Info system provides educational content about German verb conjugation, the dedication, and credits. It replaces the original single-view approach with a flexible article-based architecture.

### Architecture

| File | Purpose |
|------|---------|
| `Info.swift` | Model defining articles with heading, rich text, and optional image |
| `ImageInfo.swift` | Pairs image filename with accessibility label |
| `InfoBrowseView.swift` | List of all Info articles with previews |
| `InfoView.swift` | Detail view rendering a single article |
| `RichTextView.swift` | Renders `RichTextBlock` content with styling |
| `StringExtensions.swift` | Parses markup strings into `RichTextBlock`/`TextSegment` |

### Info Articles

`Info.infos` is a static array containing all articles in display order:

1. **Dedication** - Tribute to Clifford August Schmiesing (with photo)
2. **Verb History** - 3,000-word essay on the evolution of German verbs
3. **Terminology** - Explanation of conjugationgroup terminology
4. **Tense/Mood/Voice** - Grammar concept explanations
5. **Conjugationgroup guides** - One article per conjugationgroup (Perfektpartizip, Präsens Indikativ, etc.)
6. **Credits** - App credits and developer info (with photo)

### Rich Text Pipeline

```
Localized string (L.Info.verbHistoryText)
    ↓
String.richTextBlocks (StringExtensions.swift)
    ↓
[RichTextBlock] - .subheading(String) or .body([TextSegment])
    ↓
RichTextView renders with appropriate styling
```

### Deeplinks

Info articles support internal linking via the `konjugieren://info/{index}` scheme. Links in article text can reference other articles or verbs, handled by `InfoView.handleInfoLink(_:)`.

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

### The verbHistoryText

The `Info.verbHistoryText` entry is an extensive (~3,000 word) educational essay tracing the German verb system from:
- The formation of the Solar System (supernova-forged elements)
- Human migration out of Africa to the Pontic-Caspian steppe
- The Yamnaya people and Proto-Indo-European language
- PIE verb system and ablaut
- Germanic migrations and the Battle of Teutoburg Forest
- Evolution through Old High German to modern German

This text exists in both English and German versions. When one is edited, the other requires careful relocalization preserving all markup and technical content.

## Deeplink System

The app supports internal navigation via custom URL schemes, enabling links within Info articles and potential external integration.

### URL Scheme

```
konjugieren://{host}/{path}
```

| Host | Path | Action |
|------|------|--------|
| `verb` | Verb infinitive | Navigate to VerbView for that verb |
| `family` | Family name | Navigate to family (future feature) |
| `info` | Index (0-based) | Navigate to Info article at that index |

### Architecture

| File | Purpose |
|------|---------|
| `URLExtension.swift` | URL helpers: `isDeeplink`, `konjugierenURLPrefix`, host constants |
| `World.swift` | `handleURL(_:)` parses URL and sets `verb`/`family`/`info` properties |
| `KonjugierenApp.swift` | Receives URLs via `.onOpenURL` and delegates to `Current.handleURL` |

### Examples

```
konjugieren://verb/singen     → Opens VerbView for "singen"
konjugieren://info/0          → Opens the Dedication article
konjugieren://info/1          → Opens the Verb History article
```

### Internal Linking

Info articles can link to verbs or other articles using the `%...%` markup. When tapped, `InfoView.handleInfoLink(_:)` constructs the appropriate deeplink URL and calls `Current.handleURL(_:)`.
