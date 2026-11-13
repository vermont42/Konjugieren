# Feature Architecture

Architecture details for Konjugieren's major feature systems.

## Quiz System

The quiz tests users' knowledge of German verb conjugations with timed, scored gameplay.

### Architecture

| File | Purpose |
|------|---------|
| `Quiz.swift` | `@Observable` class managing quiz state and logic; `QuizScope`, what a quiz asks about |
| `QuizView.swift` | SwiftUI view for active quiz gameplay |
| `ResultsView.swift` | Modal sheet showing final results |
| `QuizDifficulty.swift` | Difficulty setting enum |
| `QuizErrorHistory.swift` | Persists recent wrong answers (up to 200) for AI analysis |
| `ErrorExplainerView.swift` | On-demand AI explanation of why an answer was wrong |
| `LiveActivityManager.swift` | Starts/updates/ends quiz Live Activity on lock screen |

### Quiz Flow

1. User taps "Start" → `quiz.start(scope:)` generates the scope's questions and, for a 30-question quiz, starts a Live Activity
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

### Scopes

A `QuizScope` names the verbs a quiz asks about (nil for every verb), the reading to ask about,
the question count, and the `source` its analytics signals carry. Built 2026-11-13 in Phase 13 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md) as the
minimal piece the quiz track is to extend; a collection (Phase 16) is one more constructor.

| Scope | Verbs | Questions | `source` | Ranked |
|---|---|---|---|---|
| `.allVerbs` | Every verb | 30 | `tab` | Yes |
| `.myVerbs(_:)` | My Verbs (starred, then the 20 last opened), with replacement | 30 | `myVerbs` | No |
| `.verbPage(_:readingIndex:)` | The verb on screen, in the reading on screen | 3 | `verbPage` | No |

A quiz of 30 questions keeps the mix above. A shorter one asks for distinct cells drawn from the
non-participle pool of the difficulty, since the full quiz's proportions would make three
questions all participles. Only a ranked quiz posts to Game Center and shows the leaderboard
button: Josh decided on 2026-11-13 that neither a scoped quiz nor a three-question quiz should
post. Only a 30-question quiz starts a Live Activity and counts toward `ChangeDifficultyTip`.

The Quiz tab's start screen shows a big yellow symbol for the chosen scope (books for All
Verbs, a star for My Verbs), its name and a line about what it asks, the All Verbs / My Verbs
picker, Start, three tiles (questions, difficulty, and points per right answer, which Ridiculous
doubles), and, for My Verbs, its verbs as chips, up to twelve. In the regular size class it
scales the whole composition up. Start is disabled while My Verbs is empty. "Test me on this verb" presents `QuizView(sheetScope:)` with its own `Quiz`, so a quiz in
the Quiz tab carries on beneath it. The sheet starts its quiz as it appears, closes on Quit or
when the results are dismissed, and cannot be swiped away while a question waits, so every quiz
it starts ends in `quitQuiz` or `completeQuiz`.

### Scoring

- **10 points** per correct answer
- **Ridiculous difficulty:** 2x multiplier on final score
- **Leaderboard:** only a ranked quiz (every verb, 30 questions) submits its score
- `quiz.finalScore` returns the multiplied score

### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `isInProgress` | `Bool` | Quiz currently active |
| `scope` | `QuizScope` | What the quiz asks about |
| `questionCount` | `Int` | The scope's question count: 30, or 3 on a verb page (`Quiz.questionCount` is the full quiz's 30) |
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

The verb page opens each conjugationgroup's article from the ⓘ button beside its heading
(`ConjugationTable.article`, matched by `stableKey`), in a sheet over the page. A link inside that
sheet to another article opens it in the same sheet; a link to a verb closes the sheet and goes
through `Current.handleURL`. `InfoView.openLink` is the hook that makes the difference.

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

Info articles support internal linking via the `konjugieren://info/{stableKey}` scheme. Links in article text can reference other articles or verbs, handled by `InfoView.handleInfoLink(_:)`.

Since 2026-11-12 (Phase 11 of the browse plan) an `info/` link names an article by its
`stableKey` (`info/futur_ii`), which survives the reordering of `Info.infos`. A link that names a
position (`info/20`) still opens the article at that position, as every link did before. An
article link in the text (`‡Futur II‡`) names a heading in the text's own language, so a German
text must use German headings (`‡Genus Verbi‡`, not `‡Voice‡`). `InfoTests` checks every link in
both catalogs.

## Deeplink System

The app opens `konjugieren://` links from widgets, controls, intents, quick actions, Info
articles, and Spotlight. Anything outside the app that can hand Konjugieren only a URL uses one.
There is no web domain, so there are no universal links (decided 2026-11-12; see the browse plan).

### Grammar

Written 2026-11-12 for Phase 11 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md), before the
`search` route was added, so that every route follows one shape:

```
konjugieren://<route>[/<target>][?<item>=<value>&…]
```

- **The route** is the host. It names the kind of place: a verb, the search, an article.
- **The target** is at most one path segment, percent-encoded, naming one thing of that kind: an
  infinitive, a stable key. A route that needs no target takes none.
- **Text travels in query items, never in the path**, because it can hold spaces and slashes
  ("stand auf"). Query items modify a route; unknown ones are ignored.
- **`source`** may follow any route that leads to a verb page, a search, or (Phase 13) a quiz. It
  names the surface that built the link, from `AnalyticsSource`, because a widget or an intent can
  hand the app nothing but a URL. A missing or unknown value counts as `deeplink`.
- **Builders, not literals.** App code builds links with `URL.verbDeeplink`, `URL.searchDeeplink`,
  and `URL.infoDeeplink`, which percent-encode. Only the widget extension and `Shared/`, which
  cannot see `AnalyticsSource`, write literals, and `DeeplinkTests` pins each literal's source to
  the vocabulary.

| Route | Target | Query items | Opens | Since |
|---|---|---|---|---|
| `verb` | An infinitive, or `random` | `source`; `match`, a conjugation the page marks as it marks a search's match (`verb/gehen?match=ging`) | The verb page, on the reading and section of the match | Before 2026; `match` Phase 11 |
| `search` | None | `q`, the text; `source` | The verb list with its search field. With text, the results show with the keyboard down; with none (or `q` empty), the field is cleared and focused for typing | Phase 11 |
| `info` | A `stableKey`, or a legacy position | None | The article | Before 2026; keys Phase 11 |
| `family` | A `BrowseableFamily` raw value | None | The family's page | Before 2026 |
| `quiz` | Any (today `start`) | Reserved: `list` (Phase 16) | The Quiz tab | Before 2026 |
| `list` | A collection's key | `source` | Reserved for Phase 16's collections; not handled yet | Phase 16 |

**For Phase 16.** A collection is `list/<key>`, with keys such as `top100`, `modals`, `sein`, and
`ablaut-<group>`, chosen by that phase. A quiz over a collection is `quiz/start?list=<key>`, so
that the quiz route keeps its one target. Phase 10's share text carries no `konjugieren://` link,
since Messages may not make one tappable, so whether a shared collection carries one is Phase 16's
question.

### Architecture

| File | Purpose |
|------|---------|
| `URLExtension.swift` | The grammar's constants (routes, query-item names), `isDeeplink`, `analyticsSource`, `deeplinkQueryValue(named:)`, and the three builders |
| `World.swift` | `handleURL(_:)` parses a link and sets `verb` (with `verbSource` and `verbMarks`), `searchRequest`, `family`, or `info`, and the selected tab; `openSearch(text:source:)` is the search route's effect, which Command-F also uses |
| `Info.swift` | `Info.info(deeplinkTarget:)` resolves a stable key or a legacy position |
| `VerbBrowseView.swift` | Consumes `verb` and `searchRequest` on appear and on change, since a link can arrive before the tab first appears |
| `KonjugierenApp.swift` | Receives URLs via `.onOpenURL`, and a control's pending link from the shared defaults when the scene becomes active |

### Examples

```
konjugieren://verb/singen                         → singen's page
konjugieren://verb/gehen?match=ging&source=lookup → gehen's page at the Präteritum, ich ging and er ging marked
konjugieren://search?q=stand%20auf                → the verb list searched for "stand auf"
konjugieren://search?source=control               → the verb list with an empty, focused field
konjugieren://info/futur_ii                       → the Futur II article
konjugieren://info/0                              → the Dedication article (legacy position)
```

### Internal Linking

Info articles can link to verbs or other articles using the `‡...‡` markup. When tapped, `InfoView.handleInfoLink(_:)` builds the link with `URL.infoDeeplink` or `URL.verbDeeplink` and calls `Current.handleURL(_:)`.

## Conjugation Map

A map from every one-word conjugation of every verb to the verbs it belongs to: ging → gehen,
gehört → gehören and hören, halte → halten and the 67 separable verbs built on it. Reverse lookup
in search reads it ([below](#search-by-conjugation)). Built 2026-11-12, in Phase 5 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md); search
began reading it the same day, in Phase 6.

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

### `--cells-json`

A third output, added 2026-11-12 for Phase 7 of the browse plan: every one-word conjugation with
its conjugationgroup and its verb's auxiliary (`ConjugationMapTool/CellsJSON.swift`).
`scripts/count_conjugationgroups.py` reads it to count conjugationgroups in the corpus; see
[`conjugationgroup-frequency.md`](conjugationgroup-frequency.md). Nothing in the app reads it.

### Which Conjugations Equal a Text

`Verb.conjugations(matching:)` in `ConjugationMatch.swift` returns every cell of every reading
whose conjugation equals a text, as `ConjugationMatch` values (reading, conjugationgroup, and
whether the text is only a finite part). It grades as the quiz does, against every region and both
clauses, ignoring case and spacing: "stand auf" and "aufstand" both match aufstehen's Präteritum,
and "ist gestanden" matches stehen. Search uses it to name a match, and the quiz's Tier 4
diagnosis (`plans/pedagogy.md`) can use it to say which other cell an answer belongs to. The map
says which verbs to ask; this function says which cells. The infinitive and the zu-infinitive are
not cells and never match.

### Search by Conjugation

Built 2026-11-12, in Phase 6 of the browse plan. `VerbSearch.matches` looks the query up in
`ConjugationIndex` (`ConjugationIndex.swift`), which wraps the bundled map with a folded-spelling
index and length buckets, and is built once, off the main actor, when the verb list first appears.

| Query | How it is looked up |
|---|---|
| One word (ging) | Its own spelling, then spellings equal after `VerbSearch.fold` (muß → muss, gehort → gehört). Failing both, a participle with an adjective ending loses it (geklebte → geklebt), provided the stem is a participle cell of the verb. |
| Two words, the second a particle (stand auf) | The first word's finite-part entries whose particle is the second word. The particle settles the verb, so this is a whole match. |
| A compound (hat gefunden, wird gehen) | The last word's whole-verb entries, kept only if `conjugations(matching:)` confirms the whole text is a cell: "hat gegangen" finds nothing. |
| Any of these after ich, du, er, sie, es, wir, ihr, or man | The pronoun is dropped. |

**Ranking.** `MatchKind` adds `conjugation` (after the two exact-infinitive kinds), `finitePart`
(next), and `foldedConjugation` (after every literal match, as a folded infinitive ranks). So war
finds sein ahead of warten, and zahl, zahlen's Imperativ, keeps zählen below zahlen's literal
matches. A finite part comes only from a literal spelling, or zahl would gather zählen's separable
verbs.

**Stranded parts.** A finite part (hielt, of aufhalten) matches only when the query is not itself
an infinitive. Josh chose this on 2026-11-12, so that gehen and kommen search as they did before
Phase 6. The verb list (`VerbSearchResults`) folds two or more finite-part matches into one row,
"Also in 67 separable verbs", placed after the base verb and opened in place; a lone finite part
gets an ordinary row. The shortcut picker passes `includeFiniteParts: false`, since it cannot fold
them and 62 separable verbs would fill its 25 slots for komm.

**Naming and landing.** A whole match's row names its cells, "ging: Präteritum Indikativ (ich,
er)", from `MatchedConjugation`, which calls `conjugations(matching:)` once per such verb. A
finite part's row says only "hielt … auf", and its cells are found when it is opened, because
naming 67 verbs' cells would cost about half a second. Opening a result pushes a
`VerbDestination` with `MarkedConjugations`: the page opens on that reading, scrolls to the first
marked section, and tints the marked rows, which VoiceOver reads as matching the search.

**The guess.** When nothing matches, `VerbSearch.guess` considers folded conjugations of about the
query's length as well as infinitives, and an infinitive wins a tie. ginng guesses gehen through
ging, and the guess's row names ging's cells.

## Learner's Verbs

One on-device record of the learner's own verbs: each verb opened, with its first and last dates
and a count, and each verb starred, with the date. Built 2026-11-13 in Phase 12 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md), as the
shared piece the ideas document's coordination table assigns to the browse track. Recents, My
Verbs, and the quiz's My Verbs scope read it today; the verb of the day (Phase 14), the review
card (Phase 15), collections (Phase 16), and the quiz track will.

| Piece | Role |
|---|---|
| `Shared/LearnerVerbs.swift` | The record: a Codable value keyed by infinitive, with `recent()` (the 20 last opened), `starred`, `myVerbs` (starred, then recent not starred), `remove(_:)`, which forgets a verb's star and opens alike, and `clearRecents()`, which keeps stars. Compiled into the widget too |
| `LearnerVerbStore.swift` | `Current.learnerVerbs`, an `@Observable` store that saves each change and maps infinitives to `Verb`s, skipping any that left the corpus |

**Where it lives.** JSON under the key `learnerVerbs` in the App Group's defaults
(`WidgetConstants.sharedDefaults`), written through a `GetterSetterReal` given those defaults, so
the widget extension, which has no corpus, can read the infinitives. Under unit tests it uses a
`GetterSetterFake`. iCloud sync was rejected with the ideas document's smaller ideas.

**What counts as an open.** Every `viewVerbView` whose source is not `resume`: a verb page
arriving by any route, but not the same page reappearing after another tab or the background.

**Adding a field.** It must be optional. Synthesized decoding ignores a default value and requires
the key, so a required field would fail to decode every older record, and the learner's verbs
would vanish without an error. `LearnerVerbsTests` pins the decoding of a minimal entry. Phase 15's
due date is such a field.

**Where it shows.** The verb page's star. The verb list's picker, whose third segment, My Verbs,
lists the starred verbs, then the recent ones not starred, with Clear on the recent heading.
It is a `List`, unlike the rest of the verb list, because only a `List`'s rows can be swiped: a
left swipe deletes a recent verb at once, and a starred verb after an alert asking to remove its
star. Deleting forgets the verb entirely, so an opened, starred verb leaves My Verbs rather than
dropping into Recent. On iPad it is a list rather than the grid the other modes use. Search
ignores the picker, as it ignores the sort order. And the verb list with its search field
focused and empty, which lists the recent verbs under Recent, reachable with the arrow keys and
Return on iPad and Mac. Nothing is shown when there is no history.

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

Three Control Center buttons provide quick access to app features.

| File | Purpose |
|------|---------|
| `FindVerbControl.swift` | Control Center button that opens the verb search, empty and focused (Phase 11 of the browse plan) |
| `QuickQuizControl.swift` | Control Center button that launches the quiz via deeplink |
| `RandomVerbControl.swift` | Control Center button that opens a random verb via deeplink |

The buttons run `OpenVerbSearchIntent`, `OpenQuizIntent`, and `OpenRandomVerbControlIntent` from `Shared/`, which compile into both the app and the widget extension. Each sets `openAppWhenRun = true` and writes a pending deeplink (`konjugieren://search?source=control`, `konjugieren://quiz/start`, `konjugieren://verb/random?source=control`) to the shared defaults, which the app consumes when it opens. `OpenRandomVerbControlIntent` differs from the Random Verb shortcut's `OpenRandomVerbIntent` only in that source, since one intent cannot tell which of the two ran it, and it is hidden from Shortcuts with `isDiscoverable = false`. `OpenVerbSearchIntent` is hidden too, because Shortcuts offers Look Up a Verb instead. Neither uses `OpenURLIntent`, which is a silent no-op from a widget extension for a custom URL scheme; [`control-center-controls.md`](control-center-controls.md) records why, and why the intents must live in `Shared/`.

## Home Screen Quick Actions

A long press on the app icon offers **Find a Verb**, which opens
`konjugieren://search?source=quickAction`. Added 2026-11-12, in Phase 11 of the browse plan.

`QuickActions.swift` installs the item at launch (`UIApplication.shortcutItems`) rather than
declaring it in Info.plist, so its title comes from the string catalog (`L.VerbBrowse.findVerb`,
the Command-F menu item's title). SwiftUI has no hook for quick actions, so an `AppDelegate`,
adopted with `@UIApplicationDelegateAdaptor`, names `QuickActionSceneDelegate` as the scene
delegate. A quick action that launches the app arrives in `scene(_:willConnectTo:options:)`, and
one that brings it forward in `windowScene(_:performActionFor:completionHandler:)`. SwiftUI still
manages the window, and `.onOpenURL` and Spotlight continuation work as before (checked in the
iOS 26.3 simulator, with the app running and not running).

## Siri Shortcuts / App Intents

The app registers five Siri Shortcuts via the App Intents framework.

### Architecture

| File | Purpose |
|------|---------|
| `KonjugierenShortcuts.swift` | `AppShortcutsProvider` registering all shortcuts with phrases |
| `ConjugateVerbIntent.swift` | Intent: conjugate a verb in a specific conjugationgroup |
| `LookUpVerbIntent.swift` | Intent: Look Up a Verb, which answers which verb a word belongs to and then opens it (`OpenLookupResultIntent`, hidden, is what it opens) |
| `OpenVerbIntent.swift` | Intent: open a verb's detail view |
| `VerbEntity.swift` | `AppEntity` for verb selection with entity query; its `attributeSet` carries the Spotlight fields |
| `VerbSpotlight.swift` | Builds and indexes every verb's Spotlight entry; see [Spotlight](#spotlight) |
| `VerbLookup.swift` | What Look Up a Verb says about a word and where it opens the app, read from the same search as the verb list |
| `SiriConjugationgroup.swift` | `AppEnum` mapping conjugationgroups for Siri voice commands |
| `OpenQuizIntent.swift` | Shared intent to open quiz (used by Siri and widgets) |
| `OpenRandomVerbIntent.swift` | Shared intent to open a random verb (used by Siri and widgets) |

### Registered Shortcuts

| Shortcut | Example Phrase |
|----------|---------------|
| Conjugate a Verb | "Conjugate singen with Konjugieren" |
| Look Up a Verb | "Look up a verb with Konjugieren", which then asks for the word |
| Open Verb | "Show singen with Konjugieren" |
| Start Quiz | "Start a quiz with Konjugieren" |
| Random Verb | "Show a random verb with Konjugieren" |

### Look Up a Verb

Added 2026-11-12, in Phase 11 of the browse plan. App Shortcut phrases can name only an entity or
enum parameter, not free text, so the phrase is "Look up a verb with Konjugieren" and the intent
asks for the word. The prompt turns off autocorrection and capitalization: in the simulator, an
English keyboard turned ging into Going before the intent saw it. The phrases are English only,
as the other shortcuts' are, since C3 (German phrases) was rejected.

The intent reads `VerbLookup`, which runs the verb list's own search (`VerbSearchResults`) with
the learner's Search Scope and answers in the learner's language and conjugationgroup names:

| The word | The answer | Then opens |
|---|---|---|
| A conjugation of one verb (ging) | "ging: Präteritum Indikativ (ich, er) of gehen", and, when it is also a stranded part, "ging is also a part of ausgehen (ging … aus) and of 62 more separable verbs." | That verb's page, marked (`verb/gehen?match=ging`) |
| An infinitive (aufstehen, or konnen) | "aufstehen, “get up”: steht auf · stand auf · ist aufgestanden" | That verb's page |
| An infinitive that is also another verb's conjugation (gefallen), or a conjugation of two verbs (gehört) | One line per verb, at most four | The search |
| Anything else that matches (eat) | "Konjugieren has no verb or conjugation spelled “eat”, but <n> verbs match. The first is essen, “eat”." | The search |
| Nothing (gehn) | "… Perhaps you meant gehen." or no suggestion | The search, which shows the guess and the mail link |

The stranded parts of a conjugation do not keep the learner from the base verb's page: nearly
every strong verb's Präteritum is also a part of separable verbs, and someone who says ging
almost always means gehen. An intent's result can open the app only by naming another intent, so
the answer comes back with `.result(opensIntent:dialog:)` naming `OpenLookupResultIntent`, which
calls `handleURL` with the destination. In the Shortcuts app on the simulator, the app opened
without the answer showing; Siri should speak it, which needs a device to check.

## Spotlight

Every verb has a Spotlight entry, indexed at each launch by `VerbSpotlight.indexVerbs()` into the
named index `verbs`. Until 2026-11-12 the entries went into the default index with only a title
and a subtitle. Phase 11 of the browse plan added:

| Field | Holds | Example (aufstehen) |
|---|---|---|
| Title | The infinitive | aufstehen |
| Description | The first reading's key conjugations, with no label | steht auf · stand auf · ist aufgestanden |
| Alternate names | Each reading's gloss phrases, then every reading's key conjugations in the learner's region | get up, steht auf, stand auf, ist aufgestanden |
| Keywords | Every one-word conjugation in the conjugation map, each finite part with its particle, and the gloss phrases with and without "to" | aufgestanden, aufstand, stand auf, get up, to get up, … |

Spotlight shows the description on one line and the first alternate name under it in gray, so
the gloss leads the alternate names. A gloss phrase drops parentheses and splits at commas and
semicolons ("set fire to, burn down (something)" gives "set fire to" and "burn down"). A finite
part goes in only with its particle, or steht would find dozens of separable verbs.

**What matches.** In the iOS 26.3 simulator only the title matched. aufstehen found its entry;
aufgestanden, "get up", "stand auf", and adjudge (a word only in zuerkennen's gloss) did not,
although each is in the keywords, and the first three in the alternate names or the shown
description. Indexing classic `CSSearchableItem`s with the same fields, linked with
`associateAppEntity`, matched no better, so the entities stayed. Developers report that keywords
match less reliably than titles; a device test is the open question.

**Leaving the default index.** On its first launch after the change, the app deletes the
`VerbEntity` entries from the default index once (`spotlightLeftDefaultIndex`). It does so
**before** indexing: deleting app entities by type, called on the default index, emptied the named
index too in the simulator, and run afterward it left no entries at all.

**Cost.** In a debug build on an Intel simulator, building the 3,572 entries takes about 3.3
seconds and indexing them 7 more. The map's inversion runs off the main actor; the key
conjugations need the Conjugator, which is on the main actor, so the loop yields every 100 verbs.

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
| `finishSearch` | `source` (where the search began; below), `outcome` (`opened`, `abandoned`, `noResult`), `queryLength` (`1-2`, `3-5`, `6-9`, `10+`), `resultCount` (`0`, `1`, `2-10`, `11+`), `matchKind`, `resultPosition` (`1`, `2-5`, `6+`, `none`) | Once per search: when a result or the guess is opened, the field is cleared, or the app goes to the background with text in the field |
| `tapConjugationgroupArticle` | None | When the ⓘ button beside a verb page's conjugationgroup heading opens that conjugationgroup's article. The article itself also sends `viewInfoView` |
| `tapShareVerb` | None | When the share button in a verb page's navigation bar is tapped, whether or not the learner then shares. Copying a conjugation with a long press sends nothing |
| `tapStarVerb` | `starred` (`true`, `false`: the state after the tap) | When the star in a verb page's navigation bar is tapped (Phase 12) |
| `tapTestVerb` | None | When "Test me on this verb" in a verb page's navigation bar is tapped (Phase 13). The quiz it opens sends `startQuiz` with `source` `verbPage` |
| `startQuiz`, `quitQuiz`, `completeQuiz` | `source` (`tab`, `myVerbs`, `verbPage`), added to their existing parameters | When a quiz starts, is quit, or is completed (`source` since Phase 13). Without it, three-question quizzes would inflate the completion rate of the 30-question quiz |

`VerbVisit` models one stretch of a verb page on screen, and `SearchTracker` and `SearchReport`
model one search. A section counts as reached when a third of its block's first card is on screen
(`onScrollVisibilityChange`); `simple` is the Präsens Indikativ card and `compound` the Perfekt
Indikativ card, the first of each block in `ConjugationTable`. Until Phase 7 of the browse plan
reordered the page (2026-11-12), `simple` was the Perfektpartizip card, which sat higher, so
`header` alone is likelier than before. Returning to the results and opening another verb without editing the text sends
no second `finishSearch`. An abandoned search's `matchKind` is that of the top result it passed
over.

A search's `source` is the surface that opened the field for it: `control` (Find a Verb in
Control Center), `quickAction`, `lookup` (Look Up a Verb, when it opens the search), or
`deeplink` (a `search` link from elsewhere). A search the learner began in the Verbs tab,
Command-F included, is `tab`. Only the first search after another surface opens the field takes
that surface's value; clearing the field and typing again is `tab`, and so is typing after the
field was closed untouched (`SearchTracker.fieldOpened(from:)`, `fieldClosed()`). Added
2026-11-12 in Phase 11, so that a verb page reached through a search still says which outside
surface led there.

`matchKind` values are `VerbSearch.MatchKind`'s eleven cases by name, including `conjugation`,
`finitePart`, and `foldedConjugation` from Phase 6 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md), plus
`guess` (the empty state's closest verb) and `none`. `resultCount` counts verbs, including those
inside a folded row, and `resultPosition` counts rows as shown, so the verbs of an open folded row
follow it. Opening or closing that row sends nothing.

### The `source` vocabulary

`AnalyticsSource` is one vocabulary for `viewVerbView`, `finishSearch` (since Phase 11), and the
three quiz signals (since Phase 13). A quiz's `source` is where it was begun, or for the Quiz tab's
My Verbs scope, the list it was begun on.

| Value | Sent today? | Meaning |
|---|---|---|
| `browse` | Yes | A row of the verb list with the search field empty |
| `control` | Yes | The Random Verb control in Control Center; for `finishSearch`, the Find a Verb control |
| `deeplink` | Yes | A `konjugieren://` link with no recognized `source` |
| `lookup` | Yes | Look Up a Verb: the page it opens, or the search it opens when the word is ambiguous (Phase 11) |
| `family` | Yes | A verb on a family's page |
| `handoff` | Yes | Handoff from another device |
| `infoLink` | Yes | A verb linked from an Info article |
| `related` | Yes | A verb in a verb page's Related Verbs card, or in the full list it opens |
| `quickAction` | Yes | `finishSearch` only: the Find a Verb quick action on the app icon (Phase 11) |
| `resume` | Yes | The same page appearing again (see above) |
| `search` | Yes | A search result, opened by tap, Return, or the arrow keys |
| `searchGuess` | Yes | The guess under "No verbs found" |
| `shortcut` | Yes | The Open Verb and Random Verb shortcuts |
| `spotlight` | Yes | A Spotlight result |
| `widget` | Yes | Any home-screen, lock-screen, or quiz widget |
| `sharedLink` | Not planned | A link inside shared text. Phase 10's share text carries only the App Store link, as Josh chose on 2026-11-12, so nothing sends it unless a later change adds a `konjugieren://` or universal link |
| `myVerbs` | Yes | A verb in the verb list's My Verbs (Phase 12); for the quiz signals, a quiz over My Verbs (Phase 13) |
| `recent` | Yes | A recent verb, listed while the search field is focused and empty (Phase 12) |
| `list` | Phase 16 | A collection |
| `reviewCard` | Phase 15 | The review card |
| `tab` | Yes | A search begun in the Verbs tab (Phase 11); for the quiz signals, a quiz over every verb from the Quiz tab (Phase 13) |
| `verbPage` | Yes | The quiz signals only: "Test me on this verb" (Phase 13) |

A phase that adds a way to reach a verb page passes its value in `VerbDestination`, the value the
`Verbs` and `Families` navigation stacks push, or in the deeplink's `source` query item. It also
adds the privacy-policy lines to [`privacy-policy-pending.md`](privacy-policy-pending.md).

