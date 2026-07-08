# Code Review: Recommendations

A second full-codebase review, conducted July 7, 2026, on `main` at commit c679481. It follows the June 2026 audit ([`code-audit.md`](code-audit.md)), whose seven remediation phases have all landed, so this review concentrates on code added or changed since that audit, on dimensions the audit did not sweep (deprecated APIs, concurrency, the widget's process boundary), and on the game and tutor subsystems, which have grown the most.

**Method.** Every Swift file in the app, widget, `Shared/`, and `Intents/` groups was read in full; the test suite was skimmed for quality rather than reread line by line. A fresh `run_tests.sh` baseline was taken first: all 145 tests in 20 suites pass, and the build emits exactly one compiler warning (finding 7). Findings below were verified against source; line numbers refer to commit c679481. Game findings are from static analysis; the simulator cannot exercise tilt controls, so their in-game severity should be confirmed by on-device play-testing.

**Deliberately not flagged**, per standing dispositions: the `FamilyBrowseView`/`VerbBrowseView` duplication (intentional), the German sentence in `RatingsFetcher.swift`, the protocol/Real/Dummy dependency-injection architecture, the `L.swift` accessor pattern, the XML data formats, and the mixed-case test-expectation convention.

Findings are ranked highest impact to lowest. An implementation sequence appears at the bottom.

**Status: Phases 1–3 complete.** Phase 1 (zero-risk hygiene: findings 7, 11, 12, and the finding-17 batch), Phase 2 (game correctness: findings 1, 4, 16), and Phase 3 (deeplink completion: finding 3) have landed on `main`. Phases 4–6 remain. The full test suite stands at 157 tests across 24 suites, all passing, with a zero-warning build.

---

## 1. Game: player damage applies every frame during sustained contact

**Severity:** bug (gameplay-breaking when triggered). **Locations:** `Konjugieren/Models/Game/GameState+Collisions.swift:281-297` (`collideWurstWithPlayer`), `322-337` (`collideFussballWithPlayer`), `520-534` (`collideRobotMinionWithPlayer`).

Every collision handler that damages the player follows the same block:

```swift
if !shieldActive {
  playerHealth -= Self.healthLossPerHit
  portalSide = nil
}
Current.soundPlayer.play(.playerHit, shouldDebounce: false)
HapticPlayer.playImpact(.heavy)
```

The safe handlers make this a one-shot by removing or state-transitioning the colliding entity: the enemy bullet is nilled, a diving enemy dies, the zigzagger is removed, hatchlings are removed, a pursuing ghost flips to `.exiting`. Three handlers break that invariant. Wurst segments are never removed on player contact; the fussball bounces (`velocityY = -abs(...)`) but remains overlapping the player for many frames while it departs; the diving robot minion persists through its whole parabola. Because `checkCollisions()` runs once per `TimelineView(.animation)` frame, each of these deals `healthLossPerHit` (0.25) **per frame** during overlap, with the `.playerHit` sound and heavy haptic firing per frame as well.

The arithmetic makes contact effectively lethal. A wurst chain sweeping the player's row at `wurstBaseSpeed × wurstPlayerRowSpeedMultiplier` (432 pt/s) keeps a segment overlapping the 40-pt player for roughly 0.16 s: 10 to 19 frames, far past the four hits that empty full health. The fussball and the diving minion produce the same order of magnitude. The health system is clearly designed around four discrete hits (compare the enemy-bullet path and `healthRestoreAmount`), so this reads as unintended.

**Fix:** extract one `damagePlayer()` method containing the shared block, and give it a brief invulnerability window (for example a `damageCooldown: CGFloat` counted down in `update(dt:)`; 0.5 to 1.0 s is genre-typical). Persist the cooldown in `GameStateSnapshot` alongside the other timers. This one change fixes all three per-frame sites, prevents the sound and haptic spam, and deletes eight copies of the damage block (the audit's finding-16 treatment, applied to damage).

## 2. Widget content cannot advance without an app launch

**Severity:** bug (defeats the widget's premise). **Locations:** `KonjugierenWidget/VerbDesTagesWidget.swift:25-26`, `KonjugierenWidget/QuizWidget.swift:29-30`, `KonjugierenWidget/NextVerbIntent.swift:14-15`, `Konjugieren/Utils/WidgetSnapshotWriter.swift`.

The widget extension compiles only `Shared/` and `KonjugierenWidget/` (confirmed in `project.pbxproj`'s `fileSystemSynchronizedGroups`). It contains no `Conjugator`, no `Verbs.xml`, and no `WidgetSnapshotWriter`; it can only read the single `widget-snapshot.json` that the app last wrote. Two consequences:

- **Midnight rollover is a no-op.** Both timelines end with `.after(nextMidnight)`, but when WidgetKit re-requests the timeline at midnight, `SnapshotReader.read()` returns the same file, so the "Verb des Tages" and the daily quiz question repeat yesterday's content until the user next opens the app. The feature currently behaves as "verb of the last app launch".
- **The Next Verb button does nothing visible.** `NextVerbIntent` increments `widgetDebugOffset` in shared defaults and reloads timelines, but the offset is only consumed by `WidgetSnapshotWriter.generateSnapshot`, which runs in the app. From the user's side, tapping the forward button on any widget size resets the quiz-answered state and otherwise changes nothing until the app next reaches the foreground.

**Fix (recommended):** have the app write an array of snapshots for the next N days (say 10). `generateSnapshot(date:)` is already parameterized, deterministic, and covered by `WidgetSnapshotTests`, so this is a loop plus a container type. The providers then emit one timeline entry per day, and `NextVerbIntent` can page through the cached days (`index = (todayIndex + offset) % cachedCount`). The per-day `questionID` values already make the quiz-answered state self-invalidating across days. **Alternative:** add the conjugation core (`Conjugator`, `VerbParser`, `Verbs.xml`, `ExampleSentences.json`, and their dependencies) to the widget target and generate snapshots in-process; this is more capable but grows the extension's memory footprint, which WidgetKit polices tightly. The multi-day array is the smaller, safer change.

## 3. The family deeplink does nothing, and the info deeplink neither switches tabs nor works before the Info tab has been visited

**Severity:** bug (dead and half-dead features). **Locations:** `Konjugieren/Models/World.swift:117-125` (`handleURL`), `Konjugieren/Views/InfoBrowseView.swift` (sheet), `Konjugieren/Views/FamilyBrowseView.swift` (no consumer).

`handleURL` sets `family` for `konjugieren://family/<name>`, but no production code reads `World.family`; a pickaxe search (`git log -S 'world.family'` over `Konjugieren/Views/`) shows a consumer never existed. Only `DeeplinkTests` observes the property, so the tests pass while the deeplink does nothing a user can see.

The info deeplink is consumed (`InfoBrowseView`'s `.sheet(item: $world.info)`), but `handleURL` switches `selectedTab` only for the verb and quiz hosts. Two gaps follow. First, `konjugieren://info/3` opened from Safari leaves the user on whatever tab was frontmost, with a sheet appearing over it rather than landing in the Info context. Second, and worse: `TabView` instantiates tab content lazily, so if the Info tab has never been selected this session, the sheet modifier is not yet installed, the deeplink does nothing at all, and the sheet then appears, surprisingly, whenever the user later visits the Info tab. In-app article cross-links are unaffected (the user is already inside the Info tab when tapping them), which is why this has been easy to miss.

**Fix:** in `handleURL`, set `selectedTab = .info` in the info branch and `selectedTab = .families` in the family branch; add an `.onChange(of: world.family)` in `FamilyBrowseView` that maps the string through `BrowseableFamily(rawValue:)`, pushes it onto `navigationPath`, and clears `world.family` (mirroring `VerbBrowseView`'s verb handling). Extend `DeeplinkTests` to assert the `selectedTab` transitions. If family deeplinks are instead judged not worth keeping, delete the host, the property, and the tests; the current state, where state is set and nothing observes it, is the worst of both.

## 4. Game: the robot mechanic can wedge `activeMechanic` for the rest of the wave

**Severity:** bug. **Locations:** `Konjugieren/Models/Game/GameState+Robot.swift:72-89` (`.converting`), `Konjugieren/Models/Game/GameState.swift:859` (spawn guard).

`updateSpecialMechanic` spawns nothing while `activeMechanic != nil`. Every robot-mechanic exit path clears `activeMechanic` except one: when the brain reaches `.converting` but its locked-on target has already died, the code skips minion creation and nils `robotBrain`, leaving `activeMechanic == .robot` with no brain and no minion. The player can force this path by shooting the locked-on enemy during the roughly three-second lock-on and bolt phase (the target sits in the top row; once its column is clear, it is the first enemy a bullet reaches). After that, no special mechanic spawns again until the next wave resets the state.

**Fix:** in the dead-target branch of `.converting`, clear the mechanic the same way the collision handlers do (`if activeMechanic == .robot && robotMinion == nil { activeMechanic = nil }`). A regression test belongs in the new game-logic suite proposed in finding 16.

## 5. InfoView's reading-width cap is inverted and never applies

**Severity:** bug (visual, iPad readability). **Location:** `Konjugieren/Views/InfoView.swift:59`.

```swift
.frame(minWidth: 0, maxWidth: horizontalSizeClass == .regular ? .infinity : 680, alignment: .leading)
```

The regular size class (iPad, the only environment wide enough to need a measure cap) gets `.infinity`, while compact devices get a 680-pt cap that is a no-op on every iPhone. [`ui-audit-2.md`](ui-audit-2.md) records the intended design as a "reading-width constraint of 680pt via `.frame(maxWidth: 680)`", so the ternary contradicts the documented intent; article body text on iPad runs the full window width. **Fix:** swap the arms (or simply use `maxWidth: 680` unconditionally, since the cap is inert on compact widths) and verify on an iPad simulator in both orientations.

## 6. Widget quiz answer order is not actually deterministic

**Severity:** bug (visual inconsistency); incorrect comment. **Location:** `KonjugierenWidget/Views/QuizWidgetView.swift:85-96`.

`shuffledAnswers` seeds `SeededRNG` from `Hasher`, under the comment "Deterministic shuffle based on questionID". Swift's `Hasher` has been randomly seeded per process since SE-0206, deliberately, so the same `questionID` produces a different seed whenever the widget process is relaunched (memory pressure, timeline re-render after `AnswerQuizIntent`, system reboots). The four answer buttons can silently reorder between renders of the same question. Grading is unaffected (`AnswerQuizIntent` compares answer strings, not positions), but a quiz whose options shuffle mid-day reads as broken, and the comment claims a guarantee the standard library specifically revokes. **Fix:** derive the seed from the `questionID` bytes with a stable function (an FNV-1a fold over `utf8` is four lines) and keep `SeededRNG` as is. A unit test asserting stable order across two `Hasher`-independent computations would have caught this.

## 7. `Text + Text` concatenation is deprecated as of iOS 26

**Severity:** deprecated API (the build's only compiler warning). **Location:** `Konjugieren/Views/RichTextView.swift:38`.

```swift
segments.reduce(Text(verbatim: "")) { $0 + text(for: $1) }
```

iOS 26 deprecates `Text`'s `+` operator in favor of interpolation. The codebase already contains the modern form: `InfoBrowseView.formattedPreviewText()` reduces with `Text("\($0)\(previewText(for: $1))")`. Applying the same shape here restores a zero-warning build:

```swift
segments.reduce(Text(verbatim: "")) { Text("\($0)\(text(for: $1))") }
```

## 8. `ConjugationTool.callCount` is an unprotected cross-actor mutable static

**Severity:** concurrency (data race, explicitly opted out of checking). **Location:** `Konjugieren/Models/LanguageModelServiceReal.swift:286-291, 307-311`.

```swift
nonisolated(unsafe) private static var callCount = 0
```

`Tool.call` is nonisolated and runs wherever FoundationModels schedules it; `resetCallCount()` runs on the main actor at the top of every `sendTutorMessage` attempt. `nonisolated(unsafe)` silences the compiler's objection to exactly this: unsynchronized reads and writes from two isolation domains. Contention is low in practice (the UI serializes tutor requests behind `isGenerating`), but the annotation is a standing invitation for the next call site to race. **Fix:** the increment can live inside the already-`@MainActor` `performLookup` path (make `call` await a single main-actor helper that counts, checks the limit, and performs the lookup), which deletes the `nonisolated(unsafe)` and the separate reset hop. `URLProtocolStub.testURLs` (`Konjugieren/Utils/URLProtocolStub.swift:6`) carries the same annotation; it is test-support code written once before reads, so it is tolerable, but a `Mutex` or immutable configuration would let both annotations disappear from the codebase.

## 9. LanguageModelServiceReal polls availability every five seconds for the app's lifetime

**Severity:** smell (energy, idiom). **Location:** `Konjugieren/Models/LanguageModelServiceReal.swift:27-34`.

`init` starts a `while !Task.isCancelled` loop that sleeps five seconds and re-snapshots `model.availability`, forever; nothing ever cancels it, since `World` retains the service for the process lifetime. The check exists so the Tutor row appears promptly after the user enables Apple Intelligence or the model finishes downloading, but a five-second heartbeat is the costliest way to get that: it wakes the process roughly 17,000 times a day to observe a value that changes at most once or twice ever. **Fix:** refresh on meaningful edges instead: on `scenePhase == .active` (the user returning from Settings is the main real-world transition) and on appearance of the surfaces that read `isAvailable` (`InfoBrowseView`, `OnboardingView`, `SettingsView`). If event-driven refresh ever proves insufficient, `SystemLanguageModel` is `Observable`, and observation tracking is the platform-native replacement for polling.

## 10. The refusal heuristic matches the substring "null", which is a German word

**Severity:** bug risk (false positives in the shipping tutor surface). **Location:** `Konjugieren/Models/LanguageModelServiceReal.swift:243` (within `isLikelyRefusal`, lines 235-274).

`sendTutorMessage` treats any response containing `"null"` (lowercased) as a refusal, discards it, resets the session, and retries. *Null* is the German word for zero, and the German-locale tutor answers in German: a legitimate response such as "Die Stunde Null" or any sentence counting from null would be thrown away up to four times and then replaced with `L.Tutor.unableToAnswer`. English responses containing "nullify" would meet the same fate. The other three dozen phrases are multi-word and safe; this one is a single common morpheme. **Fix:** replace the substring test with an exact-match test on the trimmed response (`trimmed.lowercased() == "null"` catches the model literally emitting JSON null, which is presumably what this guard was for). More broadly, consider logging which phrase tripped the refusal detector via `lmsLogger`, so future false positives are diagnosable from the console rather than by bisecting the phrase list.

## 11. The two test-environment probes disagree

**Severity:** smell (latent misconfiguration). **Locations:** `Konjugieren/Models/World.swift:40-51`, `Konjugieren/App/AppLauncher.swift:10`.

`AppLauncher` chooses `TestApp` via `NSClassFromString("XCTestCase")`, unconditionally. `World.chooseWorld()` chooses the fake world via `NSClassFromString("XCTest")`, and only inside `#if targetEnvironment(simulator)`. The class names differ (both currently resolve under the XCTest runner, so nothing misfires today), and the simulator gate means a unit-test run on a physical device would get `World.real`: real UserDefaults, real Game Center authentication, real analytics, under test. **Fix:** one shared probe, for example `static let isRunningUnitTests = NSClassFromString("XCTestCase") != nil` on `World`, consulted by both call sites, with the `targetEnvironment` condition removed.

## 12. Vestigial iOS 26 availability scaffolding

**Severity:** smell (dead code). **Locations:** `Konjugieren/Models/World.swift:56-62`, `Konjugieren/Models/LanguageModelServiceReal.swift:6-8, 12, 281`, `Konjugieren/App/AppLauncher.swift:7`.

Both targets set `IPHONEOS_DEPLOYMENT_TARGET = 26.0`, so `if #available(iOS 26, *)` in `World.real` is always true and its `LanguageModelServiceDummy` fallback is unreachable on device; the `#if canImport(FoundationModels)` guard and the `@available(iOS 26, *)` annotations on `LanguageModelServiceReal` and `ConjugationTool` are likewise inert. Separately, `AppLauncher.main()` is declared `throws` and throws nothing. If the minimum target is meant to stay at 26, delete the scaffolding (the dummy class itself stays; the unit-test world uses it). If a future drop below 26 is contemplated, keep it and say so in a comment, because as written it reads as load-bearing when it is not.

## 13. Hand-rolled JSON extraction where the framework offers structured generation

**Severity:** smell (robustness of a dormant surface). **Location:** `Konjugieren/Models/LanguageModelServiceReal.swift:131-189`.

`explainError` and `recommendPractice` embed a JSON schema in prose instructions, then run the response through `extractJSON` (code-fence stripping, first-brace-to-last-brace slicing) and `JSONDecoder`, throwing `jsonDecodingFailed` when the model freelances. FoundationModels' `@Generable` macro plus `session.respond(to:generating:)` produces the typed struct directly, with the framework constraining decoding; the codebase already uses `@Generable` for `ConjugationTool.Arguments`, and [`cloud-llm-tier.md`](cloud-llm-tier.md) names forced tool-use as "the cloud analog of the on-device `@Generable` macro pattern". Both surfaces are disabled in 1.0 (hallucination concerns documented in that file), so this is not urgent; but whichever session revives them, on-device or hybrid, should migrate to structured generation first and delete `extractJSON` and the schema-in-prose instructions.

## 14. `MixedCaseSegmenter` emits a phantom empty segment, and its Sie logic is duplicated

**Severity:** smell (shared pure function; zero direct tests). **Locations:** `Shared/MixedCaseSegmenter.swift:71-72`, `Konjugieren/Utils/MixedCaseAccessibility.swift`.

The segmenter's epilogue appends **both** accumulators unconditionally:

```swift
result.append(Segment(text: currentRegularPart, isIrregular: false))
result.append(Segment(text: currentIrregularPart, isIrregular: true))
```

At most one is non-empty, so every conjugation rendered by `Text(mixedCaseString:)` and the widget's `Text(widgetMixedCase:)` carries an empty trailing segment (two for the empty string). Downstream `AttributedString` appends make it invisible today, but any future consumer that counts or inspects segments inherits the surprise. Guard both appends with `isEmpty` checks.

Relatedly, `MixedCaseAccessibility.accessibilityLabel(for:)` duplicates the segmenter's subtle formal-Sie detection (`isFormalSieStart` plus the three-index membership test) rather than consuming `MixedCaseSegmenter.segments(for:)` and deriving irregular letters from the irregular runs. The audit unified the app and widget display paths; this is the remaining third copy of the Sie rule. Rebuilding the label on segmenter output single-sources it. Either change is a natural moment to give the segmenter its first direct unit tests (empty string, all-regular, all-irregular, formal Sie at start, middle, and end).

## 15. Widget-snapshot plumbing: double write on launch, and unpinned calendar arithmetic

**Severity:** smell. **Locations:** `Konjugieren/App/KonjugierenApp.swift:52-90`, `Konjugieren/Utils/WidgetSnapshotWriter.swift:6-8, 58-62, 222-226`.

Two small items in the same subsystem as finding 2, worth folding into that work:

- Cold launch writes the snapshot twice and reloads all timelines twice: once in `KonjugierenApp.init()` and again when `scenePhase` first becomes `.active`. The `.active` write alone covers launch; drop the `init` write (the other `init` work stays).
- `dateString(for:)` builds a `DateFormatter` with a fixed format but default locale and calendar, and `verbOfTheDay`/`generateQuizQuestion` count days via `Calendar.current` from a `referenceDate` also built with `Calendar.current`. On a device set to a non-Gregorian calendar (Buddhist is a regional default), the day arithmetic and the `questionID` strings diverge from Gregorian devices. Everything stays internally consistent per device, so nothing breaks today, but determinism claims and cross-device reasoning get simpler if the writer pins `Calendar(identifier: .gregorian)` and `Locale(identifier: "en_US_POSIX")`. `WidgetSnapshotTests.date(_:)` should pin the same way. While in the file, `LargeWidgetView.swift:45-46` indexes `präsensParadigm[row]`/`[row + 3]` unguarded; a snapshot decoded from an old or hand-edited file with fewer than six entries would crash the widget process. A `count >= 6` guard (or reuse of the safe-access idiom already on `thirdSingularConjugation`) closes it.

## 16. GameState logic has no unit tests

**Severity:** test gap (the largest untested subsystem). **Location:** `KonjugierenTests/` (absence); `Konjugieren/Models/Game/` (roughly 2,100 lines).

The conjugation engine, quiz, settings, deeplinks, string parsing, and widget snapshots all have suites; the game has none. Most game logic was hard to test as one god file, but the Phase-5 split changed that: `update(currentTime:)` advances pure value-type state that a test can construct, step with synthetic timestamps, and assert on, with no rendering involved. The highest-value first tests are exactly the regressions from this review: `damagePlayer()` honoring the invulnerability window (finding 1), the `.converting` dead-target path clearing `activeMechanic` (finding 4), and `checkGameOver`/wave-transition bookkeeping. A `GameStateTests` suite that calls `startGame(screenWidth:screenHeight:topInset:)` with fixed dimensions and drives `update` with hand-built dates needs no new seams beyond what exists.

## 17. Small smells and nits (batched)

**Severity:** nit. Each is independent and mechanical.

- **`QuizView.swift:18`**: `lastSubmittedIndex` is written nowhere and read nowhere; delete the dead `@State`.
- **`InfoBrowseView.swift:13`**: the `ForEach` keys rows by `\.element.heading`, the localized string whose instability motivated audit finding 33; `Info` now has a stable `id`. Key by `\.element.id`.
- **`RatingsFetcher.swift:9, 13`**: `URL(string:)!` twice in production code, contrary to the project's no-force-unwrap convention (and `stubData` force-unwraps `data(using:)`). Constant inputs make these safe in fact; either bless them with the documented-exception treatment or switch to a non-optional construction (`URL(string:)` fed by `#require` is test-only; production can use a `static let` built via `URLComponents`).
- **`Settings.swift:150-157`**: the `Bool` restore treats any stored garbage as `false` even when the default is `true`, unlike the `Int` and `RawRepresentable` overloads, which fall back to the default; and the `RawRepresentable` seed path writes `"\(defaultValue)"` (the case name) rather than `defaultValue.rawValue`, which happens to coincide today but breaks silently for any future enum whose raw values differ from case names.
- **`GetterSetter.swift`**: `SavedGame.clear` and `TutorChatHistory.clear` store `""` as a tombstone because the protocol lacks removal. Add `remove(key:)` (UserDefaults `removeObject`, dictionary removal in the fake) and delete the sentinel convention.
- **`SettingsView.swift:286-297`**: `settingsActionDecoration` applies the accessibility hint **or** the tip; a future call site passing both silently loses the tip. Apply both when both are present.
- **`GameView.swift:397`**: the game-over overlay shows "New High Score" when `finalScore >= highScore`, but `persistHighScore` updates only on strictly greater, so an exact tie displays the banner without a new high score. Use `>` or compare against the pre-game value.
- **`SoundPlayerReal.swift:60-70`**: each sound is loaded and decoded synchronously on first play, on the main actor, mid-gameplay for game sounds. Preloading (or at least `prepareToPlay()`) during `setup()` moves the hitch to launch.
- **`Quiz.swift:45-49`**: `elapsedTimeLiveActivity` hand-rolls minutes-and-seconds formatting beside `TimeFormatter`; a `TimeFormatter.formatMinutesSeconds(_:)` would keep the two clock styles in one place.
- **`AblautGroupInfo.swift`, `PrefixMeaning.swift`**: the two dynamic-key lookups use `NSLocalizedString`; `String(localized:)` is the codebase's idiom everywhere else and behaves identically here.
- **`LanguageModelService.swift`**: `lastRetryCount` exists only for `TutorTestView` (a DEBUG surface) yet is a requirement every conformer must implement. Moving it out of the protocol (a cast to `LanguageModelServiceReal` inside the DEBUG view, or a separate debug protocol) keeps the production contract clean.

---

## Carried over from the June audit, still open by disposition

Audit findings 13, 30, 35, 38, and 39 were acknowledged in June but appear in no remediation phase, and all five remain in the code: `lastReviewPromptDate` cannot persist nil (`Settings.swift:106-114`, still uncommented), the unreachable `.emoji` case in `RichTextView.attributedString(for:)`, the closure array in `Quiz.randomNonPartizipConjugationgroup`, `VerbView`'s per-render re-parse of etymology markup (`VerbView.swift:118`), and the rich-text parser's silent garbling of nested markers. None rises above nit; they are recorded here so the next audit does not rediscover them as new. If the disposition is "won't fix", a line saying so in `code-audit.md` would close the loop.

## Areas inspected and found clean

For the record, this review examined and found no issues in: the `Conjugator` engine and phonological-ending logic (still exemplary, as in June); `VerbParser` and `AblautGroupParser` validation posture; the `Quiz` engine, including timer pause/resume and the VoiceOver announcement paths; the verb and quiz deeplink paths, Spotlight indexing, and Handoff; the Siri intents, including the pinned legacy raw values in `SiriConjugationgroup`; the Control Center controls and the pending-deeplink handoff; live-activity plumbing post-audit; `Settings` persistence overall; `ReviewPrompterReal`; `GameCenterReal` (including observability of `isAuthenticated` through the protocol existential); the TipKit integration; onboarding; and the localization catalogs (both validate as JSON; `WidgetL` discipline holds). The test suite is healthy: 145 tests, well-factored helpers, correct `sourceLocation` forwarding, and the `.serialized` annotations where `Current` is mutated.

---

## Suggested Implementation Sequence

Each phase is independently shippable. Earlier phases are ordered by impact per unit of risk; the widget phase is last among the feature phases because it is the largest single change.

### Phase 1: Zero-risk hygiene (one sitting) — ✅ DONE

1. ✅ `Text` interpolation in `RichTextView` (finding 7): `reduce` now folds with `Text("\($0)\(text(for: $1))")`; build is back to zero warnings.
2. ✅ The finding-17 batch:
   - ✅ Deleted the dead `lastSubmittedIndex` `@State` (`QuizView`).
   - ✅ `InfoBrowseView` `ForEach` now keys by `\.element.id` (stable `Info.id`), not `\.element.heading`.
   - ✅ `RatingsFetcher.iTunesURL`/`reviewURL` rebuilt via `URLComponents` (nil-coalesced, no force-unwrap), per Josh's choice; byte-identical to the old literals. `stubData`'s `data(using:)!` left as test-support (convention exempts test code).
   - ✅ `Settings` `Bool` restore now falls back to the default on non-`"true"/"false"` storage; the `RawRepresentable` seed writes `defaultValue.rawValue` rather than `"\(defaultValue)"`.
   - ✅ Added `GetterSetter.remove(key:)` (UserDefaults `removeObject`; dictionary removal in the fake) and switched `SavedGame.clear`/`TutorChatHistory.clear` off the `""` tombstone.
   - ✅ `settingsActionDecoration` now applies hint **and** tip when both are present.
   - ✅ Game-over "New High Score" banner gates on a new `GameState.achievedNewHighScore` flag (set in the strict-`>` persist branch, reset in `startGame`), so an exact tie no longer shows it.
   - ✅ `SoundPlayerReal.setup()` preloads and `prepareToPlay()`s all sounds (made `Sound` `CaseIterable`), moving the first-play decode hitch to launch.
   - ✅ Added `TimeFormatter.formatMinutesSeconds(_:)`; `Quiz.elapsedTimeLiveActivity` consumes it.
   - ✅ `AblautGroupInfo`/`PrefixMeaning` dynamic-key lookups now use `String(localized: String.LocalizationValue(stringLiteral:))` instead of `NSLocalizedString`.
   - ✅ Moved `lastRetryCount` out of the `LanguageModelService` protocol (and the dummy); `TutorTestView` reads it via an `as? LanguageModelServiceReal` cast.
3. ✅ Vestigial availability scaffolding and the `throws` on `AppLauncher.main()` (finding 12): dropped `#if canImport(FoundationModels)`, the `@available(iOS 26, *)` on `LanguageModelServiceReal`/`ConjugationTool`, the always-true `if #available` in `World.real`, and `main()`'s unused `throws`.
4. ✅ Unify the test-environment probe (finding 11): one `nonisolated static let World.isRunningUnitTests = NSClassFromString("XCTestCase") != nil`, consulted by both `chooseWorld()` and `AppLauncher`, with the `targetEnvironment(simulator)` gate removed.

### Phase 2: Game correctness (verify by on-device play-testing) — ✅ DONE

1. ✅ `damagePlayer()` with an invulnerability window (finding 1): one helper on `GameState+Collisions` now holds the shared damage block (health, portal reset, `.playerHit` sound, heavy haptic), gated on a new `damageCooldown` counted down in `update(currentTime:)` and reset in `resetWaveState()`. All eight per-collision copies were deleted, so the wurst/fussball/robot-minion per-frame damage-and-spam bug is fixed at every site. Window is `GameState.damageInvulnerability = 0.75`; tune by feel on device. The cooldown persists in `GameStateSnapshot`.
2. ✅ Clear `activeMechanic` in the dead-target conversion path (finding 4): the `.converting` branch in `updateRobotBrain` now runs `if activeMechanic == .robot && robotMinion == nil { activeMechanic = nil }` after nilling the brain, mirroring the collision handlers, so a player who shoots the locked-on target no longer wedges the mechanic for the rest of the wave.
3. ✅ Stood up `GameStateTests` (finding 16): 11 tests across four suites — `DamageInvulnerability` (first-hit damage arms the cooldown, second hit during the window is ignored, damage resumes once cleared, `update` counts the cooldown down, shielded hits still arm it but lose no health), `RobotMechanic` (dead-target conversion clears `activeMechanic`; live-target conversion keeps it and spawns a minion), `GameOverAndWaves` (health depletion → `.lost`, clearing enemies → `.waveComplete`, and advance to wave 2 after the wave-complete duration), plus a snapshot round-trip for `damageCooldown`.

**Note for on-device play-testing:** the simulator cannot exercise tilt controls, so confirm the invulnerability window feels right during real contact (wurst sweep, fussball bounce, diving robot minion) and that 0.75 s is neither too forgiving nor too punishing.

### Phase 3: Deeplink completion (small, user-facing) — ✅ DONE

1. ✅ Tab switching for info and family, and a wired (not deleted) decision for family (finding 3), with `DeeplinkTests` extended to cover `selectedTab`.
   - ✅ `handleURL` now sets `selectedTab = .info` when a valid info index resolves, and `selectedTab = .families` when the family name resolves to a `BrowseableFamily`. Both switches are gated on valid input, mirroring the verb branch, so a bogus `info/99999` or `family/xyz` link leaves the frontmost tab alone.
   - ✅ The family deeplink is now consumed: `FamilyBrowseView` gained a `@Bindable var world = Current` and a `navigateToDeeplinkedFamily()` helper — mapping `world.family` through `BrowseableFamily(rawValue:)`, resetting `navigationPath`, appending the family, and clearing `world.family` — called from **both** `.onChange(of: world.family)` and `.onAppear`. The `.onAppear` is load-bearing: because Families is not the default tab, a cold-launch deeplink mounts the view with `world.family` already set, and `.onChange` alone would miss that initial value (the same lazy-`TabView`-instantiation trap finding 3 describes for the info sheet).
   - ✅ `DeeplinkTests` now resets `selectedTab = .settings` in `init` (a neutral baseline no deeplink targets, so each assertion proves a real transition), asserts `.info`/`.families` on the valid info/family cases, and adds `handleURLFamilyDeeplinkUnknownFamily` (unknown family leaves `family` nil and the tab unchanged). 157 tests across 24 suites pass.

### Phase 4: Widget freshness (the largest change; do alone on a clean tree)

1. Multi-day snapshot array, per-day timeline entries, and a paging `NextVerbIntent` (finding 2).
2. Stable answer-shuffle seed plus its unit test (finding 6).
3. The finding-15 folds: single launch write, pinned calendar and locale, guarded paradigm indexing.
4. Verify with a simulated date rollover and a Next Verb tap with the app killed.

### Phase 5: Tutor and concurrency cleanups

1. Remove `nonisolated(unsafe)` from `ConjugationTool` by counting on the main actor (finding 8).
2. Replace availability polling with edge-driven refresh (finding 9).
3. Fix the "null" refusal match and add refusal-phrase logging (finding 10).
4. When the disabled surfaces return: structured generation via `@Generable` (finding 13).

### Phase 6: Rendering and layout polish

1. InfoView reading-width cap, verified on iPad in both orientations (finding 5).
2. Segmenter empty-segment guard, accessibility-label unification, and first segmenter tests (finding 14).
