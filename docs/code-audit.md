# Code Audit

A full-codebase review covering bugs, duplication, dead code, code smells, and test-coverage gaps. Conducted June 9, 2026, on `main` at commit 00ce51a. Every finding below was verified against the cited source lines; line numbers refer to that commit. Findings are ordered from most impactful to least within each section, and the sections themselves run from most impactful (bugs) to least (test coverage). A suggested implementation order, grouped into phases, appears at the bottom.

Areas inspected and found clean, for the record: `Conjugator` logic (including phonological-ending adjustment and separable-prefix handling), the `World` dependency-injection pattern, `VerbParser` caret/index math, the rich-text parser's unterminated-delimiter detection, `Modifiers.swift` structure, and the absence of `try!`, `as!`, force-unwraps, and `print` calls in production code.

## Bugs

### 1. Deeplink `konjugieren://info/-1` crashes the app

**Severity:** bug (crash). **Location:** `Konjugieren/Models/World.swift:117-123`.

`handleURL` bounds-checks the Info index only from above:

```swift
if
  let infoIndex = Int(url.pathComponents[1]),
  infoIndex < Info.infos.count
{
  info = Info.infos[infoIndex]
}
```

`hasExpectedNumberOfDeeplinkComponents` (`URLExtension.swift:10-12`) only checks `pathComponents.count == 2`, so `konjugieren://info/-1` passes every guard, `Int("-1")` parses, and `Info.infos[-1]` traps. Deeplinks arrive from outside the app (Safari, other apps, widgets), so this is an externally triggerable crash. Fix: `Info.infos.indices.contains(infoIndex)`.

### 2. Accessory widget drops its conjugation line when the pronoun setting is "sie"

**Severity:** bug. **Location:** `KonjugierenWidget/Views/AccessoryWidgetView.swift:17`.

The rectangular lock-screen widget finds the third-person row by excluding every other pronoun:

```swift
if let thirdPerson = snapshot.präsensParadigm.first(where: { $0.pronoun != "ich" && $0.pronoun != "du" && $0.pronoun != "wir" && $0.pronoun != "ihr" && $0.pronoun != "sie" }) {
```

`PersonNumber.thirdSingular.pronoun` returns the user's `thirdPersonPronounGender` setting (`PersonNumber.swift:19-20`). When that setting is `sie`, the filter excludes the very row it is looking for, and the conjugation line silently vanishes from the widget. Fix: `PersonNumber.allCases` is semantically ordered, so the writer emits the paradigm in fs/ss/ts/fp/sp/tp order; read index 2 directly, or better, add a `personNumber` (or `isThirdSingular`) field to `WidgetConjugation` so the view need not infer person from a pronoun string.

### 3. Quiz VoiceOver announcements are hardcoded English

**Severity:** bug (localization/accessibility). **Location:** `Konjugieren/Models/Quiz.swift:393-407`.

`announceAnswerResult` posts `"Correct"`, `"Incorrect. …"`, and `"Incorrect"` as literal strings, so German VoiceOver users hear English after every quiz answer. The sibling `announceQuizCompletion` (lines 409-415) correctly uses `L.*` accessors, which confirms the intent. Fix: add `L.Quiz.announceCorrect`/`announceIncorrect` keys and use them.

### 4. Robot-mode bullet loses its color, and both bullets change identity, every frame

**Severity:** bug (visual) plus inefficiency. **Location:** `Konjugieren/Models/GameState.swift:999-1020`; rendering at `Konjugieren/Views/GameView.swift:62-73`.

`updateBullets` mutates a copy of the bullet but then constructs a brand-new `Bullet` instead of assigning the copy back:

```swift
if var bullet = playerBullet {
  bullet.y -= bulletSpeed * dt
  if bullet.y < -Self.bulletSize {
    playerBullet = nil
  } else {
    playerBullet = Bullet(x: bullet.x, y: bullet.y, isPlayerBullet: true)
  }
}
```

Two consequences. First, `useRed` resets to its default `false`, so the robot mechanic's alternating red/yellow bullets (set in `playerFire()`, lines 578-587, and rendered via `bullet.useRed ? Color.customRed : Color.customYellow` in GameView) revert to yellow after a single frame; the alternation is effectively invisible. Second, `Bullet.id` is a fresh `UUID` per frame, defeating SwiftUI identity. The enemy bullet gets the same treatment. Fix: `playerBullet = bullet` and `enemyBullet = bullet`.

### 5. Widget snapshot goes stale when the conjugationgroup-language setting changes

**Severity:** bug. **Location:** `Konjugieren/App/KonjugierenApp.swift:65-68` and `Konjugieren/Utils/WidgetSnapshotWriter.swift:132-139`.

The snapshot embeds a language-dependent display name (`generateQuizQuestion` reads `Current.settings.conjugationgroupLang`), but `KonjugierenApp` rewrites the snapshot only on scene activation and on `thirdPersonPronounGender` changes. A user who switches conjugationgroup language and then goes home sees the old language in the quiz widget until the app next becomes active. The `thirdPersonPronounGender` handler shows the bug class was recognized; this dependency was simply missed. Fix: add the second `onChange`, or replace both with a single snapshot write on transition to `.background`, which covers any future setting dependencies too.

### 6. Enemy fire rate depends on display refresh rate

**Severity:** bug (gameplay fairness). **Location:** `Konjugieren/Models/GameState.swift:2026-2036`.

```swift
if Double.random(in: 0...1) < Self.enemyFireChance {
```

`attemptEnemyFire` runs once per `update`, and `update` runs once per `TimelineView(.animation)` frame. `enemyFireChance` (0.02) is therefore a per-frame probability: on a 120 Hz ProMotion display enemies shoot twice as often as on a 60 Hz display. Fix: make the probability time-based, e.g. `Double.random(in: 0...1) < Self.enemyFiresPerSecond * dt`, passing `dt` in from `update`.

### 7. Special-mechanic spawn timing reuses the initial delay after each full cycle

**Severity:** bug (minor gameplay). **Location:** `Konjugieren/Models/GameState.swift:1168-1180`.

```swift
let threshold = mechanicBag.isEmpty && mechanicSpawnTimer == 0
  ? Self.initialMechanicDelay
  : Self.mechanicSpawnInterval
```

The condition is meant to detect the first-ever spawn (15 s instead of 27 s), but it is also true whenever the shuffle bag has just been exhausted and the timer was just reset: the 1st, 5th, 9th, … mechanics all arrive after the short delay. Fix: a dedicated `hasSpawnedFirstMechanic` flag (which then also belongs in `GameStateSnapshot`).

### 8. Widget quiz can present duplicate wrong answers

**Severity:** bug (edge case). **Location:** `Konjugieren/Utils/WidgetSnapshotWriter.swift:193-200`.

```swift
while candidates.count < 3 {
  let fallback = Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: .perfektpartizip)
  if case .success(let form) = fallback, …, !candidates.contains(form.lowercased()) {
    candidates.append(form.lowercased())
  } else {
    candidates.append(correctAnswer.lowercased() + "x")
  }
}
```

When the loop needs two padding entries, the `else` branch appends the identical `…x` string twice; nothing deduplicates it. The widget then shows two identical answer buttons. Fix: vary the fallback (e.g., append `"x"`, `"xx"`) or uniquify `candidates` before returning.

### 9. Widget `questionID` ignores the deterministic date parameter

**Severity:** bug (consistency). **Location:** `Konjugieren/Utils/WidgetSnapshotWriter.swift:147`.

```swift
questionID: "\(dateString(for: Date()))-\(verb.infinitiv)"
```

Every other part of `generateSnapshot(date:)` derives from the `date` parameter so that snapshots are deterministic and testable; `questionID` alone calls `Date()`. In production the two coincide, but any caller passing a non-today date (tests, future timeline pre-generation) gets a mismatched ID. Fix: `dateString(for: date)`.

### 10. Results difficulty stat inverts the label/value convention and produces ungrammatical German

**Severity:** bug (visual/grammatical). **Location:** `Konjugieren/Views/ResultsView.swift:40-45`.

```swift
Text(label: L.Quiz.correct, value: "\(quiz.correctCount) / \(Quiz.questionCount)")
Text(label: quiz.difficultyText, value: L.Quiz.difficulty)
Text(label: L.Quiz.time, value: TimeFormatter.formatIntTime(quiz.elapsedSeconds))
```

`Text(label:value:)` styles the label yellow and the value in the foreground color. In the middle row the data ("Regular") is passed as the label, so the yellow highlight lands on the datum in one stat and on the caption in the other two. The word order ("Regular Difficulty") survives from the pre-audit layout and reads acceptably in English, but the German rendering is "Regulär Schwierigkeit", which is ungrammatical. Fix: flip to `Text(label: L.Quiz.difficulty, value: quiz.difficultyText)` and add a colon to the `Quiz.difficulty` strings ("Difficulty:"/"Schwierigkeit:") to match `Quiz.correct` and `Quiz.time`.

### 11. TutorTestView ships in Release builds behind a hidden gesture

**Severity:** bug (hygiene). **Location:** `Konjugieren/Views/TutorView.swift:120-130`.

Triple-tapping the Tutor screen's title presents `TutorTestView`, a 310-line debugging harness with unlocalized strings, in production. Fix: wrap the gesture, the `showingTests` state, and the sheet in `#if DEBUG` (and consider the same for the file itself). That also moots the view's localization gaps.

### 12. Game Center sign-in view controller is discarded

**Severity:** bug (degraded feature). **Location:** `Konjugieren/Utils/GameCenterReal.swift:16-25`.

```swift
GKLocalPlayer.local.authenticateHandler = { [weak self] _, error in
```

The first closure parameter is the view controller GameKit provides when the player is not yet signed in; ignoring it means a signed-out player never sees the sign-in UI, never authenticates, and never sees the leaderboard buttons (gated on `isAuthenticated` in `ResultsView` and `SettingsView`). If this is a deliberate "Game Center only for already-signed-in players" choice, it deserves a comment; otherwise present the controller.

### 13. `lastReviewPromptDate` cannot persist nil

**Severity:** latent bug. **Location:** `Konjugieren/Utils/Settings.swift:106-114`.

The `didSet` writes only when the new value is non-nil, so any future code that resets the date to nil would change the in-memory value but leave the old date in UserDefaults, to be resurrected on next launch. Nothing sets it to nil today, so this is latent; either handle the nil branch or note the constraint where the property is declared.

### 14. VerbParser's missing-infinitive message always reports position 1

**Severity:** bug (diagnostics only). **Location:** `Konjugieren/Models/VerbParser.swift:55`.

```swift
Current.fatalError.fatalError("No infinitive specified for verb at position \(Verb.verbs.count + 1).")
```

The interpolation reads the global `Verb.verbs`, which is still empty while the parser accumulates into its private `verbs` dictionary, so the message always says "position 1". Fix: interpolate `verbs.count + 1`. Related hardening, same file: a duplicated `in=` attribute in `Verbs.xml` silently overwrites the earlier verb at line 158 (`verbs[currentVerb] = …`); a `fatalError` on duplicate keys would catch data-entry mistakes in a 990-entry file.

### 15. Assorted robustness nits in the audio layer

**Severity:** nit. **Locations:** `Konjugieren/Utils/SoundPlayerReal.swift:41, 60-64`; `Konjugieren/Utils/UttererReal.swift:14`.

- `player.currentTime = TimeInterval.random(in: 0..<player.duration)` traps if a corrupt `beethoven.mp3` reports zero duration (empty range).
- `try? sounds[sound.rawValue] = AVAudioPlayer.init(contentsOf: audioURL)` applies `try?` to an assignment; the conventional `sounds[sound.rawValue] = try? AVAudioPlayer(contentsOf: audioURL)` is clearer. Either way the failure is silent; `setup()` logs its failure, so log here too.
- `UttererReal.setup()` swallows audio-session errors with an empty `catch {}` while `SoundPlayerReal.setup()` logs the identical failure; match the logging.

## Duplication

### 16. GameState repeats its wave-setup, reset, and game-over logic

**Severity:** smell (high value). **Location:** `Konjugieren/Models/GameState.swift:458-533, 833-889, 2078-2118`.

- The six-line enemy-grid construction loop appears verbatim in `startGame` (519-526) and `startNextWave` (878-885).
- `startGame` and `startNextWave` each reset ~30 properties with overlapping but not identical lists; drift between the two lists is exactly how bugs like finding 7 arise. Extract `resetWaveState()` and `spawnEnemyGrid()`.
- `checkGameOver` contains two byte-identical lose blocks (2092-2103 and 2105-2117): extract `loseGame()`.
- `Quiz.swift` has the same disease in miniature: `start()` and `quit()` share a seven-line state reset (`Quiz.swift:66-75, 169-176`).

### 17. The conjugationgroup display-name switch appears four times

**Severity:** smell. **Locations:** `Konjugieren/Views/VerbView.swift:10-17`, `Konjugieren/Models/Quiz.swift:468-475` (`QuizItem.displayName`), `Konjugieren/Views/FamilyBrowseView.swift:112-119` (`FamilyShowcaseCard.conjugationgroupLabel`), `Konjugieren/Utils/WidgetSnapshotWriter.swift:132-139`.

All four switch on `ConjugationgroupLang` to choose between `germanDisplayName` and `englishDisplayName`. Add one method to the enum:

```swift
extension Conjugationgroup {
  func displayName(lang: ConjugationgroupLang) -> String {
    switch lang {
    case .german:
      return germanDisplayName
    case .english:
      return englishDisplayName
    }
  }
}
```

### 18. The imperativ pronoun mapping appears three times

**Severity:** smell. **Locations:** `Konjugieren/Models/Quiz.swift:452-465` (`QuizItem.pronoun`), `Konjugieren/Utils/WidgetSnapshotWriter.swift:115-127`, `Konjugieren/Views/VerbView.swift:229-243` (`imperativConjugations`).

Each site maps `secondSingular → "du"`, `secondPlural → "ihr"`, `firstPlural → "wir"`, `thirdPlural → "Sie"`. Add `var imperativPronoun: String?` to `PersonNumber` next to `imperativPersonNumbers`. The whole of `QuizItem.pronoun` and the widget's pronoun switch could further collapse into a single `Conjugationgroup.pronoun` helper, since the widget version is a subset of the quiz version.

### 19. JSON-over-GetterSetter persistence is implemented three times

**Severity:** smell. **Locations:** `Konjugieren/Models/GameState.swift:263-289` (`SavedGame`), `Konjugieren/Models/QuizErrorHistory.swift:27-60`, `Konjugieren/Models/TutorChatHistory.swift:9-23`.

All three encode a `Codable` value with `JSONEncoder`, stringify it, and store it through `GetterSetter`, with the mirror-image decode on load. Extract once:

```swift
extension GetterSetter {
  func setCodable<T: Encodable>(key: String, value: T)
  func getCodable<T: Decodable>(key: String) -> T?
}
```

Relatedly, `Etymology.swift` and `ExampleSentence.swift` share a lazy bundle-JSON-load pattern; a shared `loadBundleJSON<T: Decodable>(resource:)` helper would remove the smaller duplication there.

### 20. Live-activity plumbing is duplicated per activity type and per call site

**Severity:** smell. **Locations:** `Konjugieren/Utils/LiveActivityManager.swift` (whole file); `Konjugieren/Models/Quiz.swift:136-145, 158-167, 326-336, 358-368`.

`startQuizActivity`/`startGameActivity`, `updateQuizActivity`/`updateGameActivity`, and `endQuizActivity`/`endGameActivity` are pairwise identical except for the attribute type; `update` and `end` can be generic over `ActivityAttributes` immediately, and `start` needs only attributes plus initial state as parameters. Separately, `Quiz` constructs `QuizActivityAttributes.ContentState` with the same seven lines in four places; extract `makeContentState(isFinished:)`.

### 21. Mixed-case ablaut rendering is duplicated across targets

**Severity:** smell. **Locations:** `Konjugieren/Utils/TextExtension.swift:20-95` and `KonjugierenWidget/Views/WidgetAblautText.swift`.

The character-by-character state machine that segments a mixed-case conjugation into regular/irregular runs, including the formal-Sie special case, exists once per target, and the widget copy re-derives `customYellow`/`customRed` numerically from comments rather than referencing shared assets. Drift here means app and widget disagree about highlighting. Fix: move the segmentation (a pure `String → [(String, isIrregular: Bool)]` function) into `Shared/`, keep per-target color application thin, and reference colors from an asset catalog available to both targets.

### 22. SettingsView repeats its action-button and heading patterns

**Severity:** smell. **Location:** `Konjugieren/Views/SettingsView.swift:145-226, 263-289`.

Five button-plus-description groups (leaderboard, onboarding, game, delete-chat-history, rate/review) repeat the same `Button { … } label: { Label(…) }.funButton().frame(maxWidth: .infinity)` followed by a `Text` with identical modifiers. One `settingsAction(title:systemImage:description:action:)` helper removes roughly forty lines and keeps accessibility uniform. In `settingSection`, the heading `Text` with four modifiers is duplicated across the `if let tip` branches; build the heading once and conditionally apply `.popoverTip`.

### 23. QuizView hand-rolls the labeled-value row four times

**Severity:** nit. **Location:** `Konjugieren/Views/QuizView.swift:103-160`.

The pronoun, conjugationgroup, last-answer, and correct-answer rows each build the same `HStack` of a yellow label plus a foreground value. The existing `Text(label:value:)` cannot serve because the value needs its own locale environment for VoiceOver, which is presumably why the pattern grew; a small private `labeledRow(label:) { value-view }` helper would capture that intent once.

### 24. GameState duplicates HapticPlayer's gating

**Severity:** nit. **Location:** `Konjugieren/Models/GameState.swift:897-900` vs `Konjugieren/Utils/HapticPlayer.swift`.

`GameState.haptic(_:)` re-implements the audio-feedback check that `HapticPlayer` exists to centralize, because `HapticPlayer` lacks light/heavy impact variants. Add `HapticPlayer.playImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)` and delete the private helper.

### 25. World clears deeplink state in two places

**Severity:** nit. **Location:** `Konjugieren/Models/World.swift:81-83, 98-100`.

`handleUserActivity` and `handleURL` both nil out `verb`/`family`/`info`; extract `clearDeeplinkTargets()`.

## Dead Code

### 26. `FlowLayout` is unused

**Location:** `Konjugieren/Views/TutorView.swift:356-401`. A complete 45-line `Layout` implementation with zero call sites (the sample-queries sheet that presumably once used it now uses a `VStack`). Delete; git remembers.

### 27. Two view modifiers are unused

**Location:** `Konjugieren/Utils/Modifiers.swift:19-21, 35-37`. `segmentedPicker()` and `buttonLabel()` have no call sites. Delete the extension methods and their `ViewModifier` structs.

### 28. `Family.pastParticiplePrefix` is unused

**Location:** `Konjugieren/Models/Family.swift:9-16`. `Conjugator.perfektpartizipWithGeAndPrefix` implements the ge-prefix logic itself and never consults this property. Delete it, or refactor `Conjugator` to use it; either resolves the trap of two sources of truth.

### 29. Four `WidgetSnapshot` fields are serialized but never read

**Location:** `Shared/WidgetSnapshot.swift` (`frequency`, `exampleEnglish`, `dateString`, `debugOffset`). No widget view or `SnapshotReader` path consumes them (`debugOffset` is read from UserDefaults directly, not from the snapshot). If they exist for debugging the JSON by hand, a comment saying so would prevent future puzzlement; otherwise prune them and the corresponding writer lines.

### 30. `RichTextView.attributedString(for:)` has an unreachable `.emoji` case

**Severity:** nit. **Location:** `Konjugieren/Views/RichTextView.swift:93-96`. `text(for:)` fully handles `.emoji` before delegating, so the second switch's `.emoji` case never executes; it exists only to satisfy exhaustiveness. Harmless, but worth restructuring during any future edit of the file so the compiler-required case does not mislead.

## Code Smells

### 31. GameState.swift is a 2,135-line god file

**Severity:** smell (largest single maintainability item). **Location:** `Konjugieren/Models/GameState.swift`.

One file holds sixteen model structs, the snapshot type, the `SavedGame` store, and a `GameState` class whose `checkCollisions()` alone runs 480 lines with 24 numbered section comments (a comment style the project's own policy discourages). The project uses folder references, so splitting is cheap:

- `Models/Game/GameModels.swift`: the entity structs and enums.
- `Models/Game/GameSnapshot.swift`: `GameStateSnapshot` + `SavedGame`.
- `Models/Game/GameState.swift`: core loop, player, enemies, bullets.
- Extensions per mechanic (`GameState+Robot.swift`, `GameState+Geisterstunde.swift`, `GameState+Bratwurstkette.swift`, `GameState+Fussball.swift`).
- `checkCollisions()` decomposed into named methods (`collidePlayerBulletWithEnemies()` and kin), which deletes the numbered comments by making them function names. The two `// MARK:` comments here and in `WidgetSnapshotWriter.swift` can disappear in the same pass.

Behavior-preserving, no test changes required, and every later game fix gets easier.

### 32. `Conjugationgroup` mixes "Indicativ" and "Indikativ" spellings

**Severity:** smell (naming). **Location:** `Konjugieren/Models/Conjugationgroup.swift` and ~285 occurrences across 17 files.

`präsensIndicativ` and `präteritumIndicativ` use a c; `perfektIndikativ`, `plusquamperfektIndikativ`, and `futurIndikativ` use the German k, as do all display strings. Anyone typing a case name must remember which half of the enum it lives in. A mechanical rename of the two c-spellings to `präsensIndikativ`/`präteritumIndikativ` (Xcode rename, or `sed` plus a build) settles it. Large diff, zero risk, best done in a commit containing nothing else.

### 33. Identity hygiene: `Verb.id` and `Info.id`

**Severity:** smell. **Locations:** `Konjugieren/Models/Verb.swift:31`, `Konjugieren/Models/Info.swift:6`.

- `Verb.id = UUID()` mints a fresh identity every parse, so identity is stable only per launch, and `Hashable` hashes all stored properties. The natural, stable key exists: `var id: String { infinitiv }`.
- `Info.id` returns the localized `heading`, so identity changes with device language, and two articles with an identical heading would collide. The struct already carries `stableKey` (currently used only for accessibility identifiers); use it as `id`.

### 34. GameView mutates the simulation inside `body`

**Severity:** smell. **Location:** `Konjugieren/Views/GameView.swift:12-13`.

```swift
TimelineView(.animation) { timeline in
  let _ = gameState.update(currentTime: timeline.date)
```

Running the physics step during view-body evaluation mutates `@Observable` state mid-update. It works today because `TimelineView(.animation)` re-evaluates every frame regardless, but it is the pattern SwiftUI's "modifying state during view update" diagnostics exist to catch, and it makes `body` non-idempotent. Driving the tick from `.onChange(of: timeline.date)` keeps the render closure pure with minimal restructuring.

### 35. Quiz builds an array of closures where values suffice

**Severity:** nit. **Location:** `Konjugieren/Models/Quiz.swift:228-248`.

`randomNonPartizipConjugationgroup` collects `[() -> Conjugationgroup]` and invokes the randomly chosen one. Since each closure just wraps a constructor around a fresh random person, an array of plain `Conjugationgroup` values built the same way has identical semantics with less machinery.

### 36. Settings restores Bool/Int/Date ad hoc, and CLAUDE.md documents the superseded pattern

**Severity:** smell (plus stale docs). **Location:** `Konjugieren/Utils/Settings.swift:127-166`; `CLAUDE.md` ("Adding a New Setting").

The generic `restore(key:default:)` handles the `RawRepresentable` settings, but `hasSeenOnboarding`, `gameHighScore`, `promptActionCount`, and `lastReviewPromptDate` each hand-roll the same load-or-seed dance. Typed `restore` overloads for `Bool`, `Int`, and `Date?` would collapse the `init`. Separately, the CLAUDE.md recipe still shows the pre-`restore` ad-hoc pattern in step 2; update it so future settings follow the current code.

### 37. VerbBrowseView's sort picker is labeled "Alphabetical"

**Severity:** nit (accessibility). **Location:** `Konjugieren/Views/VerbBrowseView.swift:86`.

```swift
Picker(L.VerbBrowse.alphabetical, selection: $sortOrder) {
```

The picker's accessibility label is one of its two options rather than a description of the control. Add an `L.VerbBrowse.sortOrder` key.

### 38. VerbView re-parses rich text on every render

**Severity:** nit (performance). **Location:** `Konjugieren/Views/VerbView.swift:123`.

`etymologyText.richTextBlocks` runs the markup parser inside `body`, so every observation-triggered re-render re-parses the etymology. `Info` solves this by parsing once at init. Either cache parsed blocks in `Etymology` (it already caches the raw strings) or hoist into a cached property.

### 39. The rich-text parser silently garbles nested markers

**Severity:** nit (robustness). **Location:** `Konjugieren/Utils/StringExtensions.swift:88-203`.

Four independent in-marker flags share a single `markupStart`, so input like `~bold %link% bold~` corrupts extraction instead of failing. Unterminated markers already `fatalError`, which is the right posture for curated content; nesting deserves the same loud failure. A single `ParsingMode` enum would make illegal states unrepresentable.

### 40. Assorted one-liners

- `GameState.computeFinalScore` (`GameState.swift:589-593`) does its arithmetic in `Float` for no evident reason; use `Double`.
- `BrowseableFamily.topVerbs` (`BrowseableFamily.swift:181`) ends with `.prefix(3).map { $0 }`; `Array(… .prefix(3))` says the same thing directly.
- `Quiz.timerInterval` (`Quiz.swift:29`) is `private var` but never reassigned after `init`; make it `let`.

## Test Coverage

The Conjugator suite is exemplary in breadth (about 1,000 lines across all conjugationgroups and ablaut patterns). The gaps are at the edges:

### 41. Conjugator error paths are untested

`ConjugatorError`'s three guard-driven cases (`verbTooShort`, `infinitivEndingInvalid`, `verbNotRecognized`; `Conjugator.swift:16-26`) have no tests. Three cheap cases ("ab", "xyzzy", "blorfen") would lock in the public failure contract.

### 42. Quiz timer pause/resume is untested

`pauseTimer()`/`resumeTimer()` (`Quiz.swift:343-352`), exercised by scene-phase changes in `QuizView`, have no coverage; a regression here silently breaks elapsed-time scoring. The existing 0.001-second-interval testing approach extends naturally.

### 43. High-value pure-logic types lack any tests

`Verb` (`stamm` derivation, `endingIsValid`), `PersonNumber` (`pronounWithSieDisambiguation`), and `Conjugationgroup.ending(family:)` are pure functions at the heart of the domain with no direct tests (they are exercised only transitively through `ConjugatorTests`). Direct tests would localize failures that today surface as mysterious conjugation mismatches.

### 44. VerbExportTests writes to a fixed /tmp path

`KonjugierenTests/Utils/VerbExportTests.swift:10` uses `/tmp/konjugieren-export.json`, which collides under parallel or concurrent test runs; use `FileManager.default.temporaryDirectory` plus a UUID.

## Suggested Implementation Order

Each phase is independently shippable and ordered so that earlier phases shrink the surface area of later ones. Within a phase, items are independent unless noted.

### Phase 1: User-facing bug fixes (small, high value, patch-release material) — ✅ DONE

1. ✅ Deeplink negative-index crash (#1): one-line guard change plus a `DeeplinkTests` case.
2. ✅ Accessory-widget "sie" filter (#2).
3. ✅ Hardcoded English VoiceOver announcements (#3): a Localizable.xcstrings addition.
4. ✅ Widget staleness on conjugationgroup-language change (#5), widget duplicate wrong answers (#8), and `questionID` date (#9): one `WidgetSnapshotWriter`/`KonjugierenApp` pass.
5. ✅ ResultsView difficulty stat (#10).
6. ✅ `#if DEBUG` around TutorTestView access (#11).

### Phase 2: Game-behavior fixes (need on-device play-testing as verification) — ✅ DONE

1. ✅ Bullet identity/`useRed` fix (#4): two-line change, visually verifiable in robot mode.
2. ✅ Frame-rate-independent enemy fire (#6): retune `enemyFireChance` as a per-second rate.
3. ✅ Mechanic-spawn first-delay flag (#7), including the snapshot field.
4. ✅ Decide on the Game Center sign-in controller (#12): present the GameKit-supplied controller.

### Phase 3: Dead-code removal (zero-risk, shrinks later refactors)

1. Delete `FlowLayout` (#26), `segmentedPicker()`/`buttonLabel()` (#27), `pastParticiplePrefix` (#28).
2. Prune or document unused `WidgetSnapshot` fields (#29).
3. Fold in the one-liners (#40) and the VerbParser message fix (#14).

### Phase 4: Consolidation refactors (DRY; behavior-preserving; run the full test suite between items)

1. `Conjugationgroup.displayName(lang:)` (#17) and `PersonNumber.imperativPronoun` (#18): these two remove the most widespread logic duplication.
2. `GetterSetter` Codable helpers (#19).
3. Generic `LiveActivityManager` plus `Quiz.makeContentState` (#20).
4. Shared mixed-case segmentation for app and widget (#21).
5. SettingsView and QuizView view-helper extractions (#22, #23), `HapticPlayer.playImpact` (#24), `World.clearDeeplinkTargets` (#25), Quiz reset dedupe (#16, Quiz portion).
6. Settings `restore` overloads plus the CLAUDE.md recipe update (#36).
7. Audio-layer robustness nits (#15).

### Phase 5: GameState restructuring (largest single change; do alone on a clean tree)

1. Split GameState.swift into the file layout sketched in #31.
2. Extract `resetWaveState()`, `spawnEnemyGrid()`, `loseGame()` (#16).
3. Decompose `checkCollisions()` into named methods; remove `MARK` and numbered comments (#31).
4. Consider the GameView `onChange`-driven tick (#34) while the game files are open.

### Phase 6: Mechanical naming and identity sweep (large diff, no logic; isolate in its own commit)

1. Rename `präsensIndicativ` → `präsensIndikativ` and `präteritumIndicativ` → `präteritumIndikativ` (#32).
2. `Verb.id`/`Info.id` stable identities (#33).
3. VerbBrowseView picker label key (#37).

### Phase 7: Test additions (any time, but most valuable before Phases 5 and 6 land)

1. Conjugator error-path tests (#41).
2. Quiz pause/resume tests (#42).
3. Direct tests for `Verb`, `PersonNumber`, `Conjugationgroup.ending` (#43).
4. VerbExportTests temp-path fix (#44).

Deliberately not proposed: changes to the protocol/Real/Dummy dependency-injection architecture, the `L.swift` accessor pattern, the XML data formats, or the mixed-case test-expectation convention. All four are working as designed, and the audit found no evidence they impede development. One apparent finding was withdrawn after review with Josh: the German sentence "Füge deine hinzu." appended to the otherwise-localized ratings description (`RatingsFetcher.swift:44`) is intentional, a touch of German seasoning in a German-learning app, and future audits should not flag it.
