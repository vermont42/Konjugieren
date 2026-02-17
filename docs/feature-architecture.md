# Feature Architecture

Architecture details for Konjugieren's major feature systems.

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
