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
| `QuizErrorHistory.swift` | Persists recent wrong answers (up to 200) for AI analysis |
| `ErrorExplainerView.swift` | On-demand AI explanation of why an answer was wrong |
| `LiveActivityManager.swift` | Starts/updates/ends quiz Live Activity on lock screen |

### Quiz Flow

1. User taps "Start" → `quiz.start()` generates 30 questions and starts a Live Activity
2. Timer begins, questions presented one at a time; Live Activity updates on each answer
3. User types conjugation, presses return → `quiz.submitAnswer()`
4. Wrong answers are recorded to `QuizErrorHistory` and offer an `ErrorExplainerView` for AI explanation
5. After 30 questions → `quiz.finishQuiz()` shows ResultsView and ends the Live Activity

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
| `lastErrorContext` | `ErrorExplainerContext?` | Context for the most recent wrong answer |

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
| `Info.swift` | Model defining articles with heading, rich text, and required media |
| `InfoMedia.swift` | Enum: `.photo` (filename + accessibility label) or `.sfSymbol` (system name) |
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

## Game System

A space-invaders-style arcade game where players shoot descending enemies by conjugating verbs. The game features wave-based progression, power-ups, special mechanics, and Live Activity integration.

### Architecture

| File | Purpose |
|------|---------|
| `GameState.swift` | `@Observable` class with all game state: enemies, bullets, power-ups, waves, physics |
| `GameView.swift` | SwiftUI view using `TimelineView(.animation)` for 60fps rendering |
| `LiveActivityManager.swift` | Starts/updates/ends game Live Activity showing wave, score, and health |

### Game Entities

| Entity | Description |
|--------|-------------|
| `Enemy` | Grid-positioned enemies with dive attacks; uses app-icon images |
| `Bullet` | Player (🇩🇪) and enemy (🏴󠁧󠁢󠁥󠁮󠁧󠁿) projectiles |
| `PowerUp` | Collectible items: 🌭 Bratwurst, 🍺 Bier, 🥔 Kartoffel |
| `Zigzagger` | Horizontal bonus targets that drop coins |
| `Egg` / `Hatchling` | Eggs that hatch into hatchlings on impact |
| `PretzelObstacle` | Destructible barriers (2 hits) |
| `WurstChain` | Horizontal chain of bratwurst segments |
| `Fussball` | Bouncing soccer ball projectile |
| `RobotBrain` / `RobotMinion` | Boss mechanic with convertible enemies |

### Special Mechanics

Each wave randomly selects from `SpecialMechanic`:
- **Bratwurstkette:** Horizontal bratwurst chains cross the screen
- **Fussball:** Bouncing soccer balls ricochet off walls
- **Geisterstunde:** Ghost-themed enemies with spooky sounds
- **Robot:** Boss brain that converts enemies into robot minions

### Game Flow

1. Game starts in `.playing` phase with a grid of enemies
2. Player fires via tap; enemies descend and dive-attack
3. All enemies defeated → `.waveComplete` → next wave spawns with increased difficulty
4. Player health reaches zero → `.lost` → high score saved to `Settings.gameHighScore`
5. Live Activity tracks wave, score, and health fraction throughout

### Motion Controls

The game uses `CMMotionManager` for accelerometer-based player movement — tilting the device moves the player ship horizontally.

## AI Tutor System

An on-device AI tutor powered by Apple's Foundation Models framework (Apple Intelligence). Provides two capabilities: explaining quiz errors and free-form conjugation tutoring.

### Architecture

| File | Purpose |
|------|---------|
| `LanguageModelService.swift` | Protocol + data types (`ErrorExplanation`, `TutorMessage`, etc.) |
| `LanguageModelServiceReal.swift` | Real implementation using `FoundationModels` framework |
| `LanguageModelServiceDummy.swift` | No-op stub for tests and unsupported devices |
| `TutorView.swift` | Chat interface with sample queries and practice recommendations |
| `TutorChatHistory.swift` | Persists chat messages across sessions |
| `ErrorExplainerView.swift` | Inline error explanation triggered from quiz results |
| `QuizErrorHistory.swift` | Stores up to 200 recent quiz errors for pattern analysis |

### Error Explainer Flow

1. User answers incorrectly in quiz → `QuizErrorHistory.record()` persists the error
2. `ErrorExplainerView` appears with a "Why was I wrong?" button
3. On tap, sends `ErrorExplainerContext` (verb, conjugationgroup, user answer, correct answer) to `LanguageModelService.explainError()`
4. Returns `ErrorExplanation` with three fields: `explanation`, `rule`, `mnemonic`

### Tutor Flow

1. User opens tutor tab → chat history loaded from `TutorChatHistory`
2. If quiz errors exist, a "Get Suggestions" button offers `PracticeRecommendation` based on aggregated error patterns
3. User types a free-form question → `LanguageModelService.sendTutorMessage()` returns a response
4. 16 sample queries are available for users unsure what to ask

### Availability

The service checks Apple Intelligence availability and reports `LanguageModelUnavailability` reasons:
- `.appleIntelligenceNotEnabled` — user hasn't enabled Apple Intelligence
- `.deviceNotEligible` — hardware doesn't support Foundation Models
- `.modelNotReady` — model is downloading or not yet available
- `.unknown` — unexpected unavailability

## Widget System

The app provides home screen, lock screen, and Control Center widgets via a separate `KonjugierenWidget` extension target.

### Architecture

| File | Purpose |
|------|---------|
| `KonjugierenWidgetBundle.swift` | Widget bundle entry point combining all widgets and live activities |
| `VerbDesTagesWidget.swift` | Daily verb widget with timeline refreshing at midnight |
| `QuizWidget.swift` | Daily quiz question widget with interactive answer buttons |
| `SnapshotReader.swift` | Reads `WidgetSnapshot` from shared App Group container |
| `WidgetSnapshotWriter.swift` | App-side: generates and writes snapshots to shared container |
| `WidgetSnapshot.swift` | Data model for serialized widget state (verb + quiz question) |
| `WidgetConstants.swift` | Shared App Group ID, storage keys, and file paths |

### Data Flow

The app and widget extension communicate via an App Group shared container:

```
App (WidgetSnapshotWriter)
    → writes WidgetSnapshot JSON to shared container
    → calls WidgetCenter.shared.reloadAllTimelines()

Widget (SnapshotReader)
    → reads WidgetSnapshot from shared container
    → falls back to placeholder if unavailable
```

### Verb des Tages Widget

Displays a daily featured verb with conjugation details. Supported widget families:
- **Small:** Verb name and translation
- **Medium:** Verb with selected conjugations
- **Large:** Full Präsens paradigm, etymology snippet, and example sentence
- **Accessory Rectangular / Inline:** Lock screen verb display

Timeline refreshes daily at midnight via `.after(nextMidnight)` policy.

### Quiz Widget

Presents a daily multiple-choice conjugation question. Users tap an answer directly on the widget via `AnswerQuizIntent`. State (answered/correct) is tracked in shared `UserDefaults`.

### Widget Views

| View | Description |
|------|-------------|
| `SmallWidgetView` | Compact verb name and translation |
| `MediumWidgetView` | Verb with selected conjugations |
| `LargeWidgetView` | Full paradigm, etymology, example sentence |
| `AccessoryWidgetView` | Lock screen accessory formats |
| `QuizWidgetView` | Multiple-choice quiz question |
| `WidgetAblautText` | Text rendering for ablaut-highlighted conjugations in widgets |

## Live Activities

Both the quiz and game use ActivityKit Live Activities to show real-time progress on the lock screen and Dynamic Island.

### Architecture

| File | Purpose |
|------|---------|
| `LiveActivityManager.swift` | Static methods to start, update, and end activities |
| `QuizActivityAttributes.swift` | ActivityKit model: difficulty, total questions, current state |
| `GameActivityAttributes.swift` | ActivityKit model: wave, score, health fraction, phase |
| `QuizLiveActivityView.swift` | Widget-side view rendering quiz progress |
| `GameLiveActivityView.swift` | Widget-side view rendering game state |

### Quiz Live Activity State

| Field | Description |
|-------|-------------|
| `currentQuestion` | Question number (1–30) |
| `score` | Running score |
| `correctCount` | Running correct count |
| `elapsedTime` | Formatted elapsed time string |
| `isFinished` | Whether the quiz has ended |

### Game Live Activity State

| Field | Description |
|-------|-------------|
| `wave` | Current wave number |
| `score` | Running score |
| `healthFraction` | Player health as 0.0–1.0 |
| `phase` | Game phase string (playing/waveComplete/lost) |

## Control Center Controls

Two Control Center buttons provide quick access to app features.

| File | Purpose |
|------|---------|
| `QuickQuizControl.swift` | Control Center button that launches the quiz via deeplink |
| `RandomVerbControl.swift` | Control Center button that opens a random verb via deeplink |

Both controls use `OpenURLIntent` to trigger deeplinks (`konjugieren://quiz`, `konjugieren://verb/random`) because ControlWidget extensions cannot use `openAppWhenRun` directly.

## Siri Shortcuts / App Intents

The app registers four Siri Shortcuts via the App Intents framework.

### Architecture

| File | Purpose |
|------|---------|
| `KonjugierenShortcuts.swift` | `AppShortcutsProvider` registering all shortcuts with phrases |
| `ConjugateVerbIntent.swift` | Intent: conjugate a verb in a specific conjugationgroup |
| `OpenVerbIntent.swift` | Intent: open a verb's detail view |
| `VerbEntity.swift` | `AppEntity` for verb selection with entity query |
| `SiriConjugationgroup.swift` | `AppEnum` mapping conjugationgroups for Siri voice commands |
| `OpenQuizIntent.swift` | Shared intent to open quiz (used by Siri and widgets) |
| `OpenRandomVerbIntent.swift` | Shared intent to open a random verb (used by Siri and widgets) |

### Registered Shortcuts

| Shortcut | Example Phrase |
|----------|---------------|
| Conjugate a Verb | "Conjugate singen with Konjugieren" |
| Open Verb | "Show singen with Konjugieren" |
| Start Quiz | "Start a quiz with Konjugieren" |
| Random Verb | "Show a random verb with Konjugieren" |

## Review Prompting

The app prompts users to leave an App Store review after sufficient engagement.

### Architecture

| File | Purpose |
|------|---------|
| `ReviewPrompter.swift` | Protocol defining review-prompting behavior |
| `ReviewPrompterReal.swift` | Real implementation tracking action count and cooldown |
| `ReviewPrompterDummy.swift` | No-op stub for tests |

### Triggering Logic

Review prompts are gated by `Settings.promptActionCount` (number of meaningful actions taken) and `Settings.lastReviewPromptDate` (cooldown between prompts). The real implementation calls `SKStoreReviewController.requestReview()` when both thresholds are met.
