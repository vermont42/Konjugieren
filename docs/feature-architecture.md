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

**Regular difficulty:** Präsens Indikativ, Perfekt Indikativ, Futur Indikativ, Imperativ

**Ridiculous difficulty:** Adds Präsens Konjunktiv I, Präteritum Indikativ, Präteritum Konjunktiv II, Perfekt Konjunktiv I, Plusquamperfekt Indikativ, Plusquamperfekt Konjunktiv II, Futur Konjunktiv I, Futur Konjunktiv II

The lists are `Quiz.randomNonPartizipConjugationgroup()`. Until 2026-11-10 this section gave three and four, which `plans/pedagogy.md` found against the code.

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

A `verb` link may carry a `source` query item naming the surface that built it, such as
`konjugieren://verb/gehen?source=widget`. `URL.analyticsSource` reads it, and `World.handleURL(_:)`
stores it in `Current.verbSource` beside `Current.verb`, with `deeplink` when it is absent or
unknown. It exists because a widget or an intent can hand the app nothing but a URL. See
[Analytics](#analytics).

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

## Conjugation Map

A map from every one-word conjugation of every verb to the verbs it belongs to: ging → gehen,
gehört → gehören and hören, halte → halten and the 67 separable verbs built on it. Reverse lookup
in search (Phase 6 of [`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md))
reads it. Built 2026-11-12, in Phase 5.

### What It Holds

About 50,000 conjugations: the infinitive, the zu-infinitive of a separable verb (anzufangen),
both participles, the four finite simple conjugationgroups joined (anfängt), the finite part a
main clause leaves when it sends a separable prefix to the end (fängt, with the particle an), and
the first word of each Imperativ. Every reading counts. Compound conjugations have no entries,
because their parts do: hat gefunden resolves through gefunden. Keys are lowercase, because the
Conjugator's uppercase marks ablaut, not spelling. ß is not folded; a caller that wants muß to find
müssen folds both sides.

### How It Is Built

| Piece | Role |
|-------|------|
| `ConjugationMapTool/` | A macOS command-line target. It compiles 17 of the app's own files (the Conjugator, its model types, the two XML parsers, and `ConjugationMap.swift`), lent to it by a membership exception on the `Konjugieren` folder in `project.pbxproj`, plus `ToolWorld.swift`, a stand-in for `Current` that offers only `fatalError`. |
| Generate Conjugation Map | A Run Script phase of the app target, after Resources. It runs the tool and writes `ConjugationMap.lzfse` straight into the app bundle. The app target depends on the tool target, so an iOS build builds the tool for the Mac first. |
| `ConjugationMap.swift` | The map: its builder, its format, and `ConjugationMap.bundled`, a lazy loader that is safe off the main actor. Compiled into both targets, so the tool writes the file with the code the app reads it with. |

**When it regenerates.** The phase declares three inputs (`Verbs.xml`, `AblautGroups.xml`, and the
tool's executable) and one output. Xcode runs it only when an input is newer than the output. The
executable stands for every Conjugator source: Xcode relinks it when a file it compiles changes in
a way that changes the code, and leaves it alone otherwise, so a comment-only edit regenerates
nothing. An unchanged rebuild does not run the tool. `ConjugationMapTests` compares the bundled
map with a fresh in-process build, which catches a Conjugator dependency the tool does not
compile.

**Keeping the core compilable.** The files the tool compiles may not reach `L`, `Settings`,
`Region`, or any other app-only type. Display members of core types live in
`ConjugationLabels.swift` (pronouns, family and conjugationgroup names) and `Region.swift`
(`regionalAuxiliary(in:)`), which the tool does not compile. A build failure in
`ConjugationMapTool` that names `Current` or an app type means a core file has started reaching
outside the core; move the member out rather than growing `ToolWorld`.

**Format.** One line per conjugation, sorted: the conjugation, then a tab before each entry. An
entry is an infinitive, followed by a space and the particle for a finite part (`fängt	fangen	anfangen an`).
Within a line, whole verbs come first, then finite parts, each alphabetical. The text is about
1.4 MB and is LZFSE-compressed to about 173 KB. The tool takes 2 seconds in a Release build.

**Archives.** The tool has `SKIP_INSTALL = YES` and no dSYM, so an archive contains only the app
(checked with an unsigned `xcodebuild archive`, 2026-11-12).

### `forms.json`

The Python pipelines (`corpus/working/build_corpus_index.py`, `verbdata/authored/check_forms.py`,
`verbdata/authored/build_review_shards.py`) read the same map as `corpus/working/forms.json`, in
the older JSON shape `{form: [{verb, contiguous, particle?}]}`. `scripts/write_forms_json.sh`
builds the tool and runs it with `--forms-json`. Until 2026-11-12 a gated test harness,
`CorpusFormsDumpTests`, wrote that file. The tool's first output was byte-identical to the
harness's last, and the harness was deleted, so the pipelines and the app's search share one
writer.

### Which Conjugations Equal a Text

`Verb.conjugations(matching:)` in `ConjugationMatch.swift` returns every cell of every reading
whose conjugation equals a text, as `ConjugationMatch` values (reading, conjugationgroup, and
whether the text is only a finite part). It grades as the quiz does, against every region and both
clauses, ignoring case and spacing: "stand auf" and "aufstand" both match aufstehen's Präteritum,
and "ist gestanden" matches stehen. Search uses it to name a match, and the quiz's Tier 4
diagnosis (`plans/pedagogy.md`) can use it to say which other cell an answer belongs to. The map
says which verbs to ask; this function says which cells. The infinitive and the zu-infinitive are
not cells and never match.

## Game System

A space-invaders-style arcade game where players shoot descending enemies. It involves no conjugation: the enemies carry app-icon images, and nothing in `GameState` asks for or checks a verb form. (Until 2026-11-10 this sentence said players shoot "by conjugating verbs"; `plans/pedagogy.md` discusses whether the game should.) The game features wave-based progression, power-ups, special mechanics, and Live Activity integration.

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
| `VerbDesTagesWidget.swift` | Daily verb widget; emits one timeline entry per cached day so the verb advances at midnight with no app launch |
| `QuizWidget.swift` | Daily quiz question widget with interactive answer buttons; per-day entries, each grading its own question ID |
| `SnapshotReader.swift` | Reads the `WidgetSnapshotBundle` from shared App Group container; derives per-day entries with the page offset |
| `WidgetSnapshotWriter.swift` | App-side: generates and writes an N-day snapshot bundle to shared container |
| `WidgetSnapshot.swift` | Data models for serialized widget state (verb + quiz question); `WidgetSnapshotBundle` holds the N-day array + base date and the paging math |
| `WidgetQuizShuffle.swift` | Process-stable (FNV-1a seeded) answer shuffle, shared by widget and tests |
| `WidgetConstants.swift` | Shared App Group ID, storage keys, file paths, day count, and the pinned Gregorian/POSIX calendar |

### Data Flow

The app and widget extension communicate via an App Group shared container. Because the widget extension bundles only `Shared/` and `KonjugierenWidget/` — no `Conjugator`, `Verbs.xml`, or `WidgetSnapshotWriter` — it can only read what the app last wrote. The app therefore writes a **bundle of `WidgetConstants.snapshotDayCount` daily snapshots** (anchored at the current day), giving the widget up to that many days of runway before it goes stale. The providers turn each cached day into its own timeline entry, dated at that day's local midnight, so WidgetKit advances the content at midnight without an app launch. `NextVerbIntent` pages by incrementing a wrap-around offset that the providers apply when selecting each day's snapshot.

```
App (WidgetSnapshotWriter)
    → writes WidgetSnapshotBundle JSON (N daily snapshots) to shared container
    → calls WidgetCenter.shared.reloadAllTimelines()

Widget (SnapshotReader)
    → reads WidgetSnapshotBundle from shared container
    → emits one entry per cached day (page offset applied), dated at each midnight
    → falls back to placeholder if unavailable

NextVerbIntent
    → increments the page offset in shared defaults, reloads timelines
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

The buttons run `OpenQuizIntent` and `OpenRandomVerbControlIntent` from `Shared/`, which compile into both the app and the widget extension. Each sets `openAppWhenRun = true` and writes a pending deeplink (`konjugieren://quiz/start`, `konjugieren://verb/random?source=control`) to the shared defaults, which the app consumes when it opens. `OpenRandomVerbControlIntent` differs from the Random Verb shortcut's `OpenRandomVerbIntent` only in that source, since one intent cannot tell which of the two ran it, and it is hidden from Shortcuts with `isDiscoverable = false`. Neither uses `OpenURLIntent`, which is a silent no-op from a widget extension for a custom URL scheme; [`control-center-controls.md`](control-center-controls.md) records why, and why the intents must live in `Shared/`.

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

## Analytics

`Analytics.swift` holds every signal name (`AnalyticsName`), parameter key (`ParameterKey`), and
parameter value. `AnalyticsReal` sends through TelemetryDeck, and `AnalyticsSpy` records under unit
tests. **No signal carries a verb or any typed text**, because the privacy policy promises that.
Counts and durations go out in bands (`AnalyticsBand`), never as exact numbers.

### Lookup signals

| Signal | Parameters | Sent |
|---|---|---|
| `viewVerbView` | `source` | When a verb page appears: on arrival, and again with `source` `resume` after the page returns from another tab, a pushed page, or the background |
| `leaveVerbView` | `deepestSection` (`header`, `simple`, `compound`, `etymology`, `example`), `dwell` (`0-5s`, `5-15s`, `15-60s`, `60s+`) | Exactly once for each `viewVerbView`: when the page leaves the screen or the app goes to the background |
| `finishSearch` | `outcome` (`opened`, `abandoned`, `noResult`), `queryLength` (`1-2`, `3-5`, `6-9`, `10+`), `resultCount` (`0`, `1`, `2-10`, `11+`), `matchKind`, `resultPosition` (`1`, `2-5`, `6+`, `none`) | Once per search: when a result or the guess is opened, the field is cleared, or the app goes to the background with text in the field |

`VerbVisit` models one stretch of a verb page on screen, and `SearchTracker` and `SearchReport`
model one search. A section counts as reached when a third of its block's first card is on screen
(`onScrollVisibilityChange`); `simple` is the Perfektpartizip card and `compound` the Perfekt
Indikativ card. Returning to the results and opening another verb without editing the text sends
no second `finishSearch`. An abandoned search's `matchKind` is that of the top result it passed
over.

`matchKind` values are `VerbSearch.MatchKind`'s eight cases by name, plus `guess` (the empty
state's closest verb), `none`, and `conjugation`, which Phase 6 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md) will send.

### The `source` vocabulary

`AnalyticsSource` is one vocabulary for `viewVerbView` and, when the quiz track adds it,
`startQuiz`.

| Value | Sent today? | Meaning |
|---|---|---|
| `browse` | Yes | A row of the verb list with the search field empty |
| `control` | Yes | The Random Verb control in Control Center |
| `deeplink` | Yes | A `konjugieren://` link with no recognized `source` |
| `family` | Yes | A verb on a family's page |
| `handoff` | Yes | Handoff from another device |
| `infoLink` | Yes | A verb linked from an Info article |
| `resume` | Yes | The same page appearing again (see above) |
| `search` | Yes | A search result, opened by tap, Return, or the arrow keys |
| `searchGuess` | Yes | The guess under "No verbs found" |
| `shortcut` | Yes | The Open Verb and Random Verb shortcuts |
| `spotlight` | Yes | A Spotlight result |
| `widget` | Yes | Any home-screen, lock-screen, or quiz widget |
| `related` | Phase 9 | A related verb on a verb page |
| `sharedLink` | Phase 10 | A link inside shared text |
| `myVerbs`, `recent` | Phase 12 | My Verbs, and the recent lookups |
| `list` | Phase 16 | A collection |
| `reviewCard` | Phase 15 | The review card |
| `tab`, `verbPage` | Phase 13 (`startQuiz`) | The Quiz tab, and "Test me on this verb" |

A phase that adds a way to reach a verb page passes its value in `VerbDestination`, the value the
`Verbs` and `Families` navigation stacks push, or in the deeplink's `source` query item. It also
adds the privacy-policy lines to [`privacy-policy-pending.md`](privacy-policy-pending.md).

