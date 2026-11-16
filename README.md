Konjugieren
=========

![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2026-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3.0-green.svg)
![Xcode](https://img.shields.io/badge/Xcode-26-blue.svg)

| App Icon 1 | App Icon 2 | App Icon 3 |
| --- | --- | --- |
| ![](Images/Hat.png) | ![](Images/Bundestag.png) | ![](Images/Pretzel.png) |

**Konjugieren** is an iOS app for learning German-verb conjugations. It conjugates 3,572 verbs (strong, weak, mixed, and _-ieren_) across all 14 German [conjugationgroups](https://www.linkedin.com/posts/racecondition_i-have-written-elsewhere-about-how-my-experience-activity-7404189320758280192-tiAL), from Präsens Indikativ to Plusquamperfekt Konjunktiv II. The app is fully localized in English and German.

**Konjugieren** is two apps in one. The reference finds a verb from whatever a learner types, including a conjugation like _ging_, and shows every conjugation with its ablaut highlighted, its etymology traced to Proto-Indo-European, and an example sentence from published German. The quiz is a practice hub: graded the way a teacher would grade, aware of why an answer is wrong, backed by a spaced-repetition record of what the learner knows, and offering seven kinds of exercise.

Under the hood, **Konjugieren** features a domain-specific ablaut engine that models the vowel and consonant changes of German strong verbs, a conjugation map generated at build time for reverse lookup, a rule-based diagnosis of wrong answers, a hand-written rich-text parser, protocol-oriented dependency injection, and a comprehensive [Swift Testing](https://developer.apple.com/xcode/swift-testing/) suite with 953 tests across 14,000+ lines.

**Konjugieren** is available for free download in the iOS App Store™. Tap the button below to install.

[![Install](Images/apple.png)](https://apps.apple.com/us/app/konjugieren/id6758258747)

> The screenshots and features below are those of `main`. The App Store version, 1.4, predates the quiz's practice hub and most of the reference's new lookup features, which arrive with the next release.

### Screenshots

#### Looking Up Verbs

| Verb List | Search by Conjugation | Verb | Etymology and Use |
| --- | --- | --- | --- |
| <img src="Images/verb_list.png" width="190"> | <img src="Images/search.png" width="190"> | <img src="Images/verb.png" width="190"> | <img src="Images/etymology.png" width="190"> |

| My Verbs | Families and Collections | Collection | Info |
| --- | --- | --- | --- |
| <img src="Images/my_verbs.png" width="190"> | <img src="Images/families.png" width="190"> | <img src="Images/collection.png" width="190"> | <img src="Images/info_list.png" width="190"> |

#### Practicing

| Practice Hub | Exercises | One More Try | Correction |
| --- | --- | --- | --- |
| <img src="Images/practice_hub.png" width="190"> | <img src="Images/exercises.png" width="190"> | <img src="Images/one_more_try.png" width="190"> | <img src="Images/correction.png" width="190"> |

| Verb Essentials | Sentences | Name the Conjugation | Which Fits Here? |
| --- | --- | --- | --- |
| <img src="Images/verb_essentials.png" width="190"> | <img src="Images/sentences.png" width="190"> | <img src="Images/name_the_conjugation.png" width="190"> | <img src="Images/choice_question.png" width="190"> |

| Results | Ablaut Groups | Widgets | Conjugation Tutor |
| --- | --- | --- | --- |
| <img src="Images/results.png" width="190"> | <img src="Images/ablaut_practice.png" width="190"> | <img src="Images/widgets.png" width="190"> | <img src="Images/tutor.png" width="190"> |

#### Reading and Playing

| Verb History | Dedication | Arcade Game |
| --- | --- | --- |
| <img src="Images/history.png" width="190"> | <img src="Images/dedication.png" width="190"> | <img src="Images/game.png" width="190"> |

### Why Konjugieren?

Josh Adams created **Konjugieren** as a tribute to his grandfather, [Clifford August Schmiesing](https://www.findagrave.com/memorial/56382498/clifford-august-schmiesing) (1904–1944), an Army doctor who grew up speaking German in Minster, Ohio and died serving in World War II. The app's dedication tells his story.

**Konjugieren** is also an experiment in human-AI collaboration. Josh is developing the entire app with [Claude Code](https://www.youtube.com/watch?v=AJpK3YTTKZ4), not as a crutch but as a deliberate productivity multiplier. He spent twelve months on [Conjuguer](https://apps.apple.com/us/app/conjuguer/id1588624373) (French) and nine months on [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467?mt=8) (Spanish). With Claude Code, **Konjugieren** reached feature parity in six weeks and then surpassed both predecessors with features they lack: onboarding, visually distinctive icons for each verb, variable search scope, and a 3,000-word history of the German language from the formation of the Solar System to today.

The collaboration goes beyond speed. Claude Code added TelemetryDeck analytics in a single pass, but Josh then directed two successive architectural refinements: first, wrapping the SDK behind an `Analytics` protocol with Real and Spy implementations, extending the app's existing dependency-injection pattern; and second, replacing stringly typed signal names with a compiler-checked `AnalyticsName` enum. A coding assistant executes quickly, but an experienced developer knows _what_ to ask for.

The quiz's redesign shows the same division of labor at a larger scale. Claude Code surveyed the research on second-language acquisition and wrote a report of 46 suggestions, and Josh wrote a verdict beside nearly every one. Those verdicts became a plan of 24 phases, each built, tried by Josh in the app, and committed before the next began. The browse-and-verb work before it followed the same pattern over sixteen phases. The plans live in [`plans/`](plans/) beside the code, so the reasoning behind every decision is in the repository.

### Looking Up Verbs

**Search finds what people type.** The search field takes an infinitive, an English meaning, or any conjugation. _ging_ finds _gehen_ and names the cell, "Präteritum Indikativ (ich, er)"; _hat gefunden_ finds _finden_; _stand auf_ finds _aufstehen_. Spelling is folded so that _muß_, _gehort_, and _uebernehmen_ find their verbs. A conjugation that is also part of a separable verb (_ging_ in _ausgehen_) collapses into a single "Also in 63 separable verbs" row instead of burying the base verb. When nothing matches, the app guesses: _ginng_ suggests _gehen_ by way of _ging_. Opening a result lands on the matching rows of the verb page, tinted. Siri and Shortcuts ("Look up a verb with Konjugieren") answer the same way from outside the app, and Spotlight indexes every verb.

**The conjugation map is a build product.** Reverse lookup needs every conjugation of every verb, about 50,000 spellings once compound conjugations are left to their parts. Rather than conjugating the corpus at launch, a macOS command-line target, `ConjugationMapTool`, links the app's own `Conjugator` and writes the map as a bundled resource during the build, so the map can never disagree with the engine that generates it. The same tool writes `corpus/working/forms.json` for the Python pipelines that curate example sentences.

**The verb page** orders its tables by how often German uses them and names each conjugationgroup twice ("Präteritum Indikativ, also Imperfekt"). Separable verbs appear as a main clause writes them (_kommt an_, _kam an_). The page ends with the etymology, an example sentence, and related verbs (the base verb and its derivatives, and the other verbs of its ablaut group). A long press copies a conjugation, a star adds the verb to My Verbs, and Share sends the verb, its gloss, and its key conjugations as text.

**Remembering what the learner looks up.** My Verbs lists starred and recently opened verbs. A review card on the verb list brings back a strong verb looked up days ago, with its key conjugations hidden until tapped. Collections (the 100 most frequent verbs, the modal verbs, the verbs that take _sein_, and each of the 76 ablaut groups) show how many of their verbs have been looked up, start a quiz on themselves, and share as a link.

### The Quiz

**Grading accepts what is right.** Case and spacing are ignored, as is a leading pronoun of the asked person. Any umlaut may be typed as a digraph (_uebernehme_), ß as ss, and Duden's other standard conjugations count: _komme_ beside _komm_, _sammle_ beside _sammele_, _stünde_ beside _stände_. When a right answer was spelled another way, the quiz quietly shows the learner's own region's spelling.

**The answer has a shape.** The text field sits inside the frame of the expected answer, so a separable Imperativ shows `[ ] Sie [ ] !` and the learner never has to guess where the pronoun goes. An umlaut key row rides above the keyboard.

**Naming the error, without a language model.** [`AnswerDiagnosis`](Konjugieren/Models/AnswerDiagnosis.swift) asks whether a wrong answer is exactly what a known error would produce: another reading of the same verb (_hängte_ for intransitive _hängen_'s _hing_), a separable prefix in the wrong place, a missing or wrong auxiliary, a misplaced or missing _ge-_, a strong verb conjugated as weak (_gehte_, _denkte_), or another cell of the right verb. Each check generates the wrong conjugations its error would yield, in every region's spelling, and compares, so the diagnosis is certain or absent, never a guess. A diagnosed error or a one-letter slip earns one more try at half points.

**A correction that stays.** A wrong answer stops the clock and holds the question on screen: both answers with the differing letters marked, the diagnosis, the verb page and ablaut group a tap away, and a note that the question will return three questions later.

**Levels and verb bands.** Four levels, Beginner through Advanced, each add conjugationgroups in the order learners acquire them and widen the pool from the 100 most frequent verbs to 300, 1,000, and the whole corpus. Rounds are ten questions, then ten more on request. The draw balances each round: half strong verbs, at least two of _sein_, _haben_, _werden_, and the modals, and a measured dose of rare derivatives.

**A practice record with spaced repetition.** Every answer moves an item along a ladder of 1, 3, 7, 14, and 30 days. A strong verb's items are its key conjugations (_fährt · fuhr · ist gefahren_); a weak verb's are shared patterns, so _machte_, _kaufte_, and _studierte_ all exercise the same du-Präteritum. Review asks what is due, My Mistakes asks what was last missed, and Mastery shows what is secure at the learner's level. Up to three due items mix into every ordinary round.

**Seven exercises** sit on the practice hub beside the ordinary quiz:

- **Verb Essentials** asks a strong verb's three key conjugations, one blank at a time.
- **Ablaut Groups** practices one group of strong verbs alone, then mixes it with the groups the learner already knows.
- **Name the Conjugation** reverses the direction: given _käme_, name the verb, the conjugationgroup, and the person. Every right reading is accepted.
- **Sentences** blanks the verb in one of 736 short sentences covering the 300 most frequent verbs. A test checks each blank against the conjugator in every region, so no sentence can teach a wrong conjugation.
- **Which Fits Here?** shows one sentence in two conjugationgroups and asks which a German speaker would use: the Perfekt in conversation, the Präteritum in a story, the Konjunktiv I in a news report. One appears in every round of the ordinary quiz from Elementary up.
- **Speed Round** gives sixty seconds of questions on items already mastered, for fluency.
- **Daily Session** asks ten questions, due items first, and builds a streak that survives one missed day if the learner does two sessions the next. An optional reminder says what is due.

A **Daily Challenge** of five questions, seeded by the date and level, is the same for everyone and shares as text. Custom quizzes choose conjugationgroups and verbs, and share with a class as a link or QR code. The results screen offers a literary example sentence for each verb answered right, and Game Center keeps a leaderboard per level and eight achievements.

**Privacy by construction.** The practice record lives on the device, in an App Group the widgets share. No analytics signal carries an answer, a score, a verb, or a count from which the number of wrong answers could be inferred. An audit at the end of the quiz work found one such leak (a question number that counted re-asks) and closed it.

### Architecture

![Konjugieren architecture map](Images/architecture.png)

*Five layers (App Entry, Views, Models, Data, and Infrastructure) connected by four relationship types: data flow (solid blue), navigation (dashed green), dependency injection (dotted gray), and cross-cutting concerns (dashed orange). The Conjugator engine sits at the center of the Models layer, fed by Verb and AblautGroup data from XML, and providing conjugation results upward to VerbView and the Quiz system.*

**Protocol-oriented dependency injection.** [`World.swift`](Konjugieren/Models/World.swift) is a lightweight DI container that injects a dozen dependencies, among them `Settings`, `GameCenter`, `SoundPlayer`, `Utterer`, `FatalError`, `Analytics`, the learner's verbs, the practice record, and the reminder scheduler. The services are protocols with Real, Dummy, Spy, or Fake implementations, and the settings and stores are classes over an injected `GetterSetter`, so tests swap the storage beneath them. This enables full testability with zero third-party frameworks: production code crashes early on invalid data via `FatalErrorReal`, while tests capture those errors with `FatalErrorSpy`. The quiz draws through an injectable `RandomNumberGenerator`, so a test can seed a quiz and get the same questions every time.

**Ablaut engine.** German strong verbs undergo vowel and consonant changes (_ablaut_) that differ by conjugationgroup. The engine uses region-based substring replacement: each verb's [XML definition](Konjugieren/Models/Verbs.xml) marks the mutable region with `^` delimiters, and [ablaut-group definitions](Konjugieren/Models/AblautGroups.xml) (76 groups) specify replacements per conjugationgroup. A full-override syntax (`*` suffix) handles highly irregular verbs like _sein_ and _haben_. [`Conjugator.swift`](Konjugieren/Models/Conjugator.swift) applies these rules at runtime, and the same engine conjugates the regional standards of Austria and Switzerland, including Swiss ß-free spelling.

**Rich-text parser.** A [hand-written state machine](Konjugieren/Utils/StringExtensions.swift) parses five markup syntaxes (backtick headings, tilde bold, dollar-sign ablaut highlighting, double-dagger URLs, and caret-delimited custom emoji) into a recursive `RichTextBlock`/`TextSegment` enum AST, rendered by [`RichTextView.swift`](Konjugieren/Views/RichTextView.swift). This powers the app's bilingual articles, among them a 3,000-word essay on the history of the German verb.

**@Observable reactive state.** The app uses Swift's modern [Observation](https://developer.apple.com/documentation/observation) framework throughout (`@Observable` on `World`, `Quiz`, `Settings`, and the stores), with no Combine or third-party reactive dependencies. The project builds in the Swift 6 language mode with default main-actor isolation, and marks pure computation `nonisolated`.

**Conjugation Tutor (Apple Intelligence).** An on-device conversational tutor powered by Apple's [Foundation Models](https://developer.apple.com/documentation/foundationmodels) framework. The [`LanguageModelService`](Konjugieren/Models/LanguageModelService.swift) protocol abstracts the AI layer behind the same DI pattern as the rest of the app, with [`LanguageModelServiceReal`](Konjugieren/Models/LanguageModelServiceReal.swift) running on iOS 26+ and a [`LanguageModelServiceDummy`](Konjugieren/Models/LanguageModelServiceDummy.swift) keeping the app functional on devices without Apple Intelligence. The real implementation manages a stateful `LanguageModelSession` and exposes three capabilities: interactive chat, quiz-error explanation, and personalized practice recommendations.

The centerpiece is [`ConjugationTool`](Konjugieren/Models/LanguageModelServiceReal.swift), a Foundation Models `Tool` conformance that lets the on-device model look up real conjugations from the app's 3,572-verb engine instead of hallucinating them. The tool's `@Generable` schema was iteratively refined across 10+ rounds (documented in [`on_device_tool_design.md`](docs/on_device_tool_design.md)) to minimize what the model must decide: the model specifies only a verb and conjugationgroup; the tool handles all six grammatical persons in a single call, parses both German and English conjugationgroup names with ordered-specificity fuzzy matching, and strips ablaut markup from the output. A call-count circuit breaker (max 3 retries per message, 15 per session) prevents infinite tool-call loops. The retry system detects 15+ refusal patterns and recreates the session on failure.

[`QuizErrorHistory`](Konjugieren/Models/QuizErrorHistory.swift) aggregates the user's quiz mistakes by conjugationgroup, and the tutor's practice-recommendation engine feeds this data to the model to surface the user's weakest areas. [`TutorChatHistory`](Konjugieren/Models/TutorChatHistory.swift) persists conversations to UserDefaults with a 200-message ring buffer, so context survives app restarts.

**Retro arcade game (pure SwiftUI).** A German-themed arcade shooter built entirely with SwiftUI and Core Motion: no SpriteKit, no UIKit, no game engine. [`GameState.swift`](Konjugieren/Models/Game/GameState.swift) (1,000 lines) drives a `TimelineView(.animation)` game loop with frame-rate-independent delta-time physics, while `CMMotionManager` at 60 Hz translates device tilt into player movement.

The game manages 11 entity types as value-semantic structs: enemies in a 6×6 grid with parabolic dive-bombing paths, zigzagging animal emoji that drop coins, gravity-affected eggs that hatch into player-seeking hatchlings, bouncing soccer balls with momentum transfer, five-segment bratwurst chains that split when hit and spawn destructible pretzel obstacles, and multi-phase ghosts with a five-state AI (descending → pursuing → fleeing → devoured → exiting). Three special mechanics rotate on a randomized 27-second interval: Fussball, Bratwurstkette, and Geisterstunde (ghost hunt, triggered by shooting a crystal ball).

The collision system handles 21 distinct interaction types with asymmetric behaviors: a soccer ball bounces off enemies but kills them, shields absorb hits but expire, and a portal mechanic teleports the player across the screen to escape hatchling swarms. Infinite waves scale difficulty exponentially (`enemySpeed = 21 × pow(1.02, wave − 1)`), and the final-score formula (`score × (health + 1) − elapsed seconds`) rewards aggressive, high-health play. Three power-up types (health, shield, rapid-fire) drop from defeated enemies at a 15% rate. The game includes 34 sound effects, context-sensitive haptic feedback, and particle-burst death animations, all rendered in SwiftUI with `Canvas` and standard views.

**WidgetKit.** Two widgets share data through an App Group container:

**Verb des Tages** displays the day's verb across five sizes: three home-screen sizes (small, medium, large) and two lock-screen / watchOS-complication sizes (accessoryRectangular, accessoryInline). The small widget shows the infinitive plus ich/sie Präsens conjugations; the medium adds the full six-person paradigm in two columns; the large adds a Perfektpartizip line, example sentence with source attribution, and an etymology snippet (truncated to 450 characters at a sentence boundary, main-verb bullet first). A forward button on all sizes triggers NextVerbIntent to cycle verbs without opening the app.

**Conjugation Quiz** offers small and medium home-screen sizes with a four-option multiple-choice question. Answers are submitted via AnswerQuizIntent, a WidgetKit AppIntent that validates the selection, persists the result to the shared UserDefaults container, and reloads the timeline to show a ✓/✗ result view. Answer options are deterministically shuffled using a SeededRNG (XORShift) keyed on the question ID, ensuring the same ordering survives widget reloads.

**Data pipeline.** [`WidgetSnapshotWriter`](Konjugieren/Utils/WidgetSnapshotWriter.swift) (app side) selects the day's verb through `VerbDraw`, from the 1,000 most frequent verbs weighted toward strong and unprefixed ones, and from My Verbs every third day, keeping whatever verb the widget already shows today. It generates all six Präsens conjugations via `Conjugator`, assembles wrong quiz answers deterministically, and writes a `WidgetSnapshot` JSON to the shared App Group container. [`SnapshotReader`](KonjugierenWidget/SnapshotReader.swift) (widget side) reads that file; on failure it falls back silently to a placeholder (gehen). The same mixed-case ablaut highlighting used in the main app (yellow for regular portions, red for ablaut-changed letters) is replicated in `WidgetAblautText.swift` using `AttributedString`, with `@Environment(\.colorScheme)` threaded through to switch between dark-mode gold (#FFCE00) and light-mode olive (#665300).

### Accessibility

Konjugieren is fully accessible to VoiceOver users, using four distinct accessibility strategies:

**Ablaut-aware accessibility labels.** The app's core pedagogical feature, color-coded ablaut highlighting where `sAng` renders "s" in one color and "A" in another, is invisible to screen readers. [`MixedCaseAccessibility.swift`](Konjugieren/Utils/MixedCaseAccessibility.swift) solves this with a pure function that walks the mixed-case string using the same `isFormalSieStart` algorithm as the visual renderer ([`TextExtension.swift`](Konjugieren/Utils/TextExtension.swift)), collecting uppercase characters as irregular, and producing labels like `"sang, a is irregular"` or `"bin, b i n are irregular"`. The formal pronoun "Sie" is correctly excluded from irregular-letter detection despite its initial capital.

**Speech-synthesis DI.** Quiz questions are spoken aloud using `AVSpeechSynthesizer`, following the same protocol-oriented DI pattern as `SoundPlayer`. The [`Utterer`](Konjugieren/Utils/Utterer.swift) protocol defines `setup()` and `utter(_:localeString:)`, with [`UttererReal`](Konjugieren/Utils/UttererReal.swift) tuning rate (0.5) and pitch (0.8) for clear German speech, and [`UttererDummy`](Konjugieren/Utils/UttererDummy.swift) keeping tests silent. Verb names are spoken in `de-DE`, translations in `en-US`; the locale switch happens mid-question so VoiceOver users hear correct pronunciation for both languages.

**Semantic structure.** Every section heading uses `.accessibilityAddTraits(.isHeader)`, enabling VoiceOver's rotor to jump between sections. The `SubheadingLabel` ViewModifier applies this trait globally, so all views using `.subheadingLabel()` gain heading semantics automatically. Conjugation rows use `.accessibilityElement(children: .combine)` to merge pronoun and verb conjugation into a single element: VoiceOver reads "er sang, a is irregular" instead of "er" ... "sang" as separate swipes.

**Quiz VoiceOver flow.** Announcements in [`Quiz.swift`](Konjugieren/Models/Quiz.swift), all gated on `UIAccessibility.isVoiceOverRunning`, speak the question in the right language for each part, announce a right answer and the end of a round, and read a correction's differing letters and diagnosis. An `@AccessibilityFocusState` binding in [`QuizView.swift`](Konjugieren/Views/QuizView.swift) moves VoiceOver focus to the answer field when the quiz advances, and after a wrong answer to the held correction. Each blank of an answer frame reads the whole frame ("blank, Sie, blank. Blank 1 of 2"), and the chips of Name the Conjugation and the sentences of a choice question are buttons that say whether they are chosen.

**`CFBundleSpokenName`.** The [`Info.plist`](Konjugieren/Info.plist) key `CFBundleSpokenName` provides VoiceOver with a phonetic pronunciation guide (`"cone you gear en"`) so the app name is spoken correctly in English contexts.

### Technology Stack

- **SwiftUI**: declarative UI with custom `ViewModifier`s and layouts, `TabView` navigation, `TimelineView` game loop, and `Canvas` particle effects
- **Foundation Models**: on-device Apple Intelligence integration with `SystemLanguageModel`, `LanguageModelSession`, `Tool` protocol, and `@Generable` schemas
- **Core Motion**: 60 Hz gyroscope input for arcade-game tilt controls via `CMMotionManager`
- **Swift Testing**: modern test framework (`@Test`, `#expect`) with 953 test functions
- **Game Center**: a leaderboard for each of the four quiz levels and eight achievements, via `GKLeaderboard`, `GKAchievement`, and `GKAccessPoint`
- **WidgetKit and ActivityKit**: two widgets (Verb des Tages, Conjugation Quiz) across five sizes, with AppIntents for interactive quiz answers and verb cycling, plus Live Activities for quizzes and the game
- **App Intents, Core Spotlight, and Control Center**: Siri and Shortcuts verb lookup, a Spotlight entry for every verb, and controls that start a quiz or open a random verb
- **User Notifications**: the opt-in daily reminder, written fourteen days ahead so each says what that day has due
- **Core Image**: QR codes for sharing practice sets
- **XMLParser**: streaming parser for verb and ablaut-group data (3,572 verbs, 76 ablaut groups)
- **Custom URL scheme**: `konjugieren://` deeplinks for verbs, articles, collections, practice sets, and the daily session
- **Localization**: full EN/DE support via `.xcstrings` string catalogs
- **Accessibility**: VoiceOver support with `AVSpeechSynthesizer`, `@AccessibilityFocusState`, `UIAccessibility.post`, and `CFBundleSpokenName`

### Testing

The test suite spans **14,000+ lines** across sixty-four files, with **953 test functions** covering conjugation logic, search and the conjugation map, quiz state management, answer grading and diagnosis, the practice record and its schedule, the draw of each exercise, the authored sentences, rich-text parsing, and time formatting.

The conjugation tests use a **mixed-case convention** to verify ablaut highlighting: lowercase letters represent unchanged portions, and UPPERCASE letters mark ablaut-changed regions. For example, `"sAng"` asserts that _singen_'s Präteritum changes "i" to "a" and the UI will highlight that change. This convention makes it immediately visible when a test expectation involves an ablaut transformation.

**Content is tested like code.** Every authored sentence in Sentences and Which Fits Here? names a verb and a cell, and a test requires that the words in its blanks be exactly what the conjugator produces, in every region. The quiz's draw takes a seeded generator, so tests pin each level's mix of conjugationgroups and verbs over tens of thousands of draws.

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

When working with [Claude Code](https://www.youtube.com/watch?v=AJpK3YTTKZ4), Konjugieren's `CLAUDE.md` depends on the [`ios-build-verify`](https://github.com/vermont42/ios-build-verify) Claude Code plugin, which Josh developed to address frustrations he experienced building Konjugieren. The plugin bundles `xcodebuild` + `xcbeautify` for builds and `AXe`-driven simulator operations (launch, tap, screenshot, audit) for verification, all behind named scripts driven by a per-project config. The screenshots in this README were taken with it.

Developers who prefer not to take on the `ios-build-verify` dependency can follow the instructions in [`docs/vanilla_build_and_test.md`](docs/vanilla_build_and_test.md) to replace it with raw `xcodebuild` commands.

### Related Projects

- [**Conjuguer**](https://apps.apple.com/us/app/conjuguer/id1588624373): French-verb conjugation app (iOS)
- [**Conjugar**](https://itunes.apple.com/us/app/conjugar/id1236500467?mt=8): Spanish-verb conjugation app (iOS)
- [**racecondition.software**](https://racecondition.software): Josh's development blog

### License

**Konjugieren** is licensed under the [GNU General Public License v3.0](LICENSE) in order to discourage release of low-quality clones to the App Store™.
