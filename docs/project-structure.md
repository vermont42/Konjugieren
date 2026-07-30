# Project Structure

```
Konjugieren/
├── Info.plist                  # App configuration (deeplinks, export compliance)
├── Konjugieren.entitlements    # App entitlements (App Groups for widget sharing)
├── PrivacyInfo.xcprivacy       # Privacy manifest for App Store submission
├── Secrets.example.xcconfig    # Template for secrets configuration
├── Secrets.xcconfig            # TelemetryDeck app ID (gitignored)
├── App/
│   ├── AppLauncher.swift       # Chooses TestApp vs KonjugierenApp based on environment
│   ├── KonjugierenApp.swift    # Main app entry point with Game Center auth
│   └── TestApp.swift           # Minimal app for unit test environment
├── Assets/
│   ├── Localizable.xcstrings   # Localization strings (JSON format, EN/DE)
│   ├── Assets.xcassets/        # Colors, app icons, images (CliffSchmiesing, JoshAdams, etc.)
│   └── Sounds/                 # MP3 sound effects (applause, buzz, chime, guns, etc.)
├── Intents/
│   ├── ConjugateVerbIntent.swift   # Siri shortcut intent for conjugating a verb
│   ├── KonjugierenShortcuts.swift  # AppShortcutsProvider registering all Siri shortcuts
│   ├── OpenVerbIntent.swift        # Siri shortcut intent to open a verb detail view
│   ├── SiriConjugationgroup.swift  # AppEnum mapping conjugationgroups for Siri
│   └── VerbEntity.swift            # AppEntity for verb selection in Siri intents
├── Models/
│   ├── Ablaut.swift            # Single ablaut: replacement + target conjugationgroups
│   ├── AblautGroup.swift       # Named collection of ablauts for a verb pattern
│   ├── AblautGroupInfo.swift   # Identifiable struct with localized ablaut-group descriptions
│   ├── AblautGroupParser.swift # XMLParser delegate that parses AblautGroups.xml
│   ├── AblautGroups.xml        # 73 ablaut pattern definitions
│   ├── AppIcon.swift           # Alternate app-icon enum (bratwurst/hat/pretzel/bundestag)
│   ├── AudioFeedback.swift     # Setting enum: enable/disable sound effects
│   ├── Auxiliary.swift         # haben/sein auxiliary verb enum
│   ├── BrowseableFamily.swift  # Enum of browseable family categories for FamilyBrowseView
│   ├── Conjugationgroup.swift  # Enum of all conjugationgroups with endings
│   ├── ConjugationgroupLang.swift  # Setting enum: german/english display
│   ├── Conjugator.swift        # Core conjugation logic for all conjugationgroups
│   ├── ConjugatorError.swift   # Error enum for conjugation failures
│   ├── Etymologies.json        # Bundled verb etymologies keyed by language and infinitive
│   ├── Etymology.swift         # Lazy-loading etymology lookup by infinitive
│   ├── ExampleSentence.swift   # Lazy-loading literary example sentence lookup by infinitive
│   ├── ExampleSentences.json   # Bundled literary example sentences keyed by language and infinitive
│   ├── Family.swift            # Verb families (strong/weak/mixed/ieren)
│   ├── Game/
│   │   ├── GameModels.swift            # Entity structs/enums (Enemy, Bullet, Ghost, RobotBrain, etc.)
│   │   ├── GameSnapshot.swift          # GameStateSnapshot + SavedGame persistence
│   │   ├── GameState.swift             # @Observable core loop: player, enemies, bullets, waves, life cycle
│   │   ├── GameState+Bratwurstkette.swift  # Wurst-chain mechanic (spawn/update + pretzel obstacles)
│   │   ├── GameState+Collisions.swift  # checkCollisions decomposed into per-pair named methods
│   │   ├── GameState+Fussball.swift    # Bouncing-football mechanic (spawn/update)
│   │   ├── GameState+Geisterstunde.swift  # Ghost-hunt mechanic (spawn/update)
│   │   └── GameState+Robot.swift       # Robot brain/minion mechanic (spawn/update)
│   ├── Info.swift              # Info article model with rich text and images
│   ├── InfoMedia.swift         # Enum: .photo or .sfSymbol media for Info rows
│   ├── KonjugierenTips.swift   # TipKit tips (e.g., change-difficulty hint)
│   ├── LanguageModelService.swift      # Protocol for on-device AI error explanation and tutoring
│   ├── LanguageModelServiceDummy.swift # No-op stub for tests/unsupported devices
│   ├── LanguageModelServiceReal.swift  # FoundationModels implementation for AI tutoring
│   ├── PersonNumber.swift      # 1s, 2s, 3s, 1p, 2p, 3p with localized pronouns
│   ├── Prefix.swift            # Separable/inseparable prefix enum ([Prefix] helpers live in Reading.swift)
│   ├── PrefixMeaning.swift     # Prefix meanings with PIE etymologies
│   ├── PrefixSection.swift     # Curated-vs-other heading for the prefix-grouped verb list
│   ├── Quiz.swift              # @Observable quiz state: questions, timer, scoring
│   ├── QuizDifficulty.swift    # Setting enum: regular vs ridiculous
│   ├── Region.swift            # Setting enum: the three standard varieties (north/austria/switzerland)
│   ├── QuizErrorHistory.swift  # Persistence for recent quiz errors (up to 200)
│   ├── SearchScope.swift       # Setting enum: infinitive-only vs. infinitive-and-translation search
│   ├── SortOrder.swift         # Enum for verb list sorting (alphabetical/frequency)
│   ├── Sound.swift             # Sound effect definitions (guns, chimes, applause)
│   ├── TabSelection.swift      # TabView selection enum for programmatic tab switching
│   ├── ThirdPersonPronounGender.swift  # Setting enum: er/sie/es preference
│   ├── TutorChatHistory.swift  # Persistence for chat messages with the AI tutor
│   ├── Reading.swift           # One sense of a verb: gloss, family, auxiliary, prefixes
│   ├── Verb.swift              # Lemma: frequency, icon, and an ordered list of readings
│   ├── VerbParser.swift        # XMLParser delegate for Verbs.xml, incl. the `in` marker grammar
│   ├── Verbs.xml               # 3,572 verb definitions with markers and metadata
│   └── World.swift             # @Observable DI container with environment selection
├── Utils/
│   ├── Analytics.swift         # Analytics protocol, event names, and parameter keys
│   ├── AnalyticsReal.swift     # TelemetryDeck implementation of Analytics
│   ├── AnalyticsSpy.swift      # Test spy that captures analytics signals
│   ├── FatalError.swift        # Protocol for testable fatal error handling
│   ├── FatalErrorReal.swift    # Production implementation (calls Swift.fatalError)
│   ├── FatalErrorSpy.swift     # Test implementation (captures error messages)
│   ├── GameCenter.swift        # Protocol for Game Center operations
│   ├── GameCenterDummy.swift   # No-op implementation for tests/simulator
│   ├── GameCenterReal.swift    # Real GKLocalPlayer authentication and scores
│   ├── GetterSetter.swift      # Protocol for key-value storage abstraction
│   ├── GetterSetterFake.swift  # In-memory dictionary implementation for tests
│   ├── GetterSetterReal.swift  # UserDefaults implementation of GetterSetter
│   ├── GradientDivider.swift   # Shared gradient divider used by SettingsView and ResultsView
│   ├── HapticPlayer.swift      # Haptic feedback methods respecting audio-feedback setting
│   ├── KonjugierenLogger.swift # os.Logger factory with app subsystem
│   ├── L.swift                 # Type-safe localization string accessors
│   ├── Layout.swift            # Spacing constants (8pt, 16pt, 24pt)
│   ├── LiveActivityManager.swift   # Creates and updates Live Activities for quiz and game
│   ├── MixedCaseAccessibility.swift  # VoiceOver labels for mixed-case ablaut strings
│   ├── Modifiers.swift         # Custom ViewModifiers (headingLabel, funButton, etc.)
│   ├── RatingsFetcher.swift    # Fetches app ratings from iTunes API
│   ├── RegionalRendering.swift # ß→ss display transform + RegionalConjugator (region-aware wrapper over the region-free Conjugator)
│   ├── ReviewPrompter.swift    # Protocol for review-prompting behavior
│   ├── ReviewPrompterDummy.swift   # No-op stub for tests
│   ├── ReviewPrompterReal.swift    # Real implementation prompting reviews at intervals
│   ├── Settings.swift          # @Observable settings with UserDefaults persistence
│   ├── SoundPlayer.swift       # Protocol for audio playback
│   ├── SoundPlayerDummy.swift  # No-op implementation for tests
│   ├── SoundPlayerReal.swift   # AVAudioPlayer implementation with debouncing
│   ├── StringExtensions.swift  # Rich text markup parsing to RichTextBlock/TextSegment
│   ├── TextExtension.swift     # Text(mixedCaseString:) for ablaut-highlighted display
│   ├── TimeFormatter.swift     # Formats elapsed seconds as h:mm:ss
│   ├── URLExtension.swift      # Deeplink URL helpers (konjugieren:// scheme)
│   ├── URLProtocolStub.swift   # URLProtocol subclass for stubbing HTTP responses in tests
│   ├── URLSessionExtension.swift   # Extension providing a stubbed URLSession for testing
│   ├── UserLocale.swift        # Locale detection helpers (isGerman, isEnglish)
│   ├── Utterer.swift           # Protocol for text-to-speech with UttererLocale constants
│   ├── UttererDummy.swift      # No-op TTS implementation for tests
│   ├── UttererReal.swift       # AVSpeechSynthesizer implementation
│   └── WidgetSnapshotWriter.swift  # Generates and persists widget snapshots with daily verb data
└── Views/
    ├── ErrorExplainerView.swift # AI-generated explanations for conjugation errors
    ├── FamilyBrowseView.swift  # Browseable list of verb families, prefixes, and ablaut groups
    ├── FamilyDetailView.swift  # Detail view for a single family/prefix/ablaut category
    ├── GameView.swift          # Space-invaders-like verb conjugation game
    ├── InfoBrowseView.swift    # List of Info articles (dedication, history, etc.)
    ├── InfoView.swift          # Detail view for a single Info article
    ├── MainTabView.swift       # Root TabView with five tabs
    ├── OnboardingView.swift    # Multi-page onboarding shown on first launch
    ├── QuizView.swift          # Quiz gameplay: questions, timer, answer input
    ├── ResultsView.swift       # Modal showing quiz results and leaderboard button
    ├── RichTextView.swift      # Renders RichTextBlock content with styling
    ├── SettingsView.swift      # Settings UI with segmented pickers
    ├── TutorTestView.swift     # Debug view for testing the AI tutor
    ├── TutorView.swift         # Chat interface for the AI tutor with sample queries
    ├── VerbBrowseView.swift    # Searchable, sortable list of all verbs
    └── VerbView.swift          # Verb detail showing all conjugations

KonjugierenWidget/
├── AnswerQuizIntent.swift      # AppIntent for answering a quiz question from the widget
├── Assets.xcassets/            # Widget-specific asset catalog
├── Info.plist                  # Widget extension configuration
├── KonjugierenWidget.entitlements  # Widget entitlements (App Groups)
├── KonjugierenWidgetBundle.swift   # Widget bundle combining all widgets and live activities
├── Localizable.xcstrings       # Widget-target string catalog (en/de); resolved against the widget bundle
├── NextVerbIntent.swift        # AppIntent for advancing to the next verb in the widget
├── QuickQuizControl.swift      # Control Center button launching the quiz
├── QuizWidget.swift            # Timeline-based widget for daily quiz questions
├── RandomVerbControl.swift     # Control Center button opening a random verb
├── SnapshotReader.swift        # Reads the multi-day WidgetSnapshotBundle from shared container; emits per-day timeline entries with page offset
├── VerbDesTagesWidget.swift    # Timeline-based widget displaying the daily verb
├── WidgetL.swift               # Type-safe localization accessors for the widget target (mirrors L)
└── Views/
    ├── AccessoryWidgetView.swift   # Lock screen accessory widget views
    ├── GameLiveActivityView.swift  # Live activity showing game state (waves, score, health)
    ├── LargeWidgetView.swift       # Full-size widget with conjugation paradigm
    ├── MediumWidgetView.swift      # Mid-size widget with selected conjugations
    ├── QuizLiveActivityView.swift  # Live activity showing quiz progress and score
    ├── QuizWidgetView.swift        # Widget view for displaying a quiz question
    ├── SmallWidgetView.swift       # Compact widget showing verb name and translation
    └── WidgetAblautText.swift      # Text rendering for ablaut changes in widgets

Shared/
├── GameActivityAttributes.swift    # ActivityKit model for game live activity
├── MixedCaseSegmenter.swift        # Pure ablaut segmentation shared by app and widget highlighting
├── OpenQuizIntent.swift            # Shared intent to open quiz via deeplink
├── OpenRandomVerbIntent.swift      # Shared intent to open random verb via deeplink
├── QuizActivityAttributes.swift    # ActivityKit model for quiz live activity
├── WidgetConstants.swift           # Constants for widget app-group container, storage keys, day count, and pinned Gregorian calendar
├── WidgetQuizShuffle.swift         # Process-stable (FNV-1a seeded) answer shuffle + SeededRNG, shared by widget and tests
└── WidgetSnapshot.swift            # Data models for serialized widget state, incl. WidgetSnapshotBundle (N-day array)

KonjugierenTests/
├── Models/
│   ├── ConjugationgroupTests.swift # Conjugationgroup.ending(family:) ending-table tests
│   ├── ConjugatorTests.swift   # Comprehensive conjugation tests (~50 test functions), incl. error paths
│   ├── GameStateTests.swift    # Game-logic tests: damage invulnerability, robot-mechanic clearing, game-over/wave transitions, snapshot round-trip
│   ├── PersonNumberTests.swift # Pronoun and sie-disambiguation tests
│   ├── QuizErrorHistoryTests.swift # Quiz error persistence tests
│   ├── QuizTests.swift         # Quiz logic, scoring, and timer pause/resume tests
│   ├── RefusalDetectionTests.swift # Tutor refusal-phrase detection, incl. the "null" exact-match false-positive guard
│   └── VerbTests.swift         # Verb.stamm and endingIsValid tests
└── Utils/
    ├── CorpusFormsDumpTests.swift  # Harness: drives Conjugator over every verb to emit corpus/working/forms.json (form → lemma, with separable-prefix split forms). Gated on TEST_RUNNER_KONJUGIEREN_FORMS_OUT
    ├── DeeplinkTests.swift     # Deeplink URL parsing and handling tests
    ├── MixedCaseAccessibilityTests.swift  # VoiceOver label generation tests
    ├── MixedCaseSegmenterTests.swift  # Ablaut segmentation tests (empty/all-regular/all-irregular/formal Sie)
    ├── SettingsTests.swift     # Settings persistence and default-value tests
    ├── StringExtensionsTests.swift  # Rich text parsing and error handling tests
    ├── TimeFormatterTests.swift     # Time formatting utility tests
    ├── VerbClassificationTests.swift  # Harness: stage B of classify-and-verify, searching for the Verbs.xml encoding that reproduces Wiktionary. Gated on TEST_RUNNER_KONJUGIEREN_CLASSIFY_IN
    ├── VerbExportTests.swift        # Verb data JSON export tests
    └── WidgetSnapshotTests.swift    # Widget snapshot/bundle generation, per-day paging math, and process-stable answer-shuffle tests

docs/
├── adding-verbs.md            # Verb-addition guide: XML formats, ablaut system, lessons learned
├── blog_notes.md              # Work journal: dated narrative notes for future blog posts and session memory
├── bratwurst-icon-prompts.md  # Prompts used to generate bratwurst-themed app icons
├── bug-report-gitcommitsha.md  # Bug report draft: Claude Code `plugin update` doesn't refresh `gitCommitSha` in `installed_plugins.json`
├── bug-report-grep-silent-truncation.md  # Bug report draft (filed as anthropics/claude-code #56751): long-line `grep` matches silently disappear from Bash tool output
├── claude-code-skill-recommendations.md  # Curated third-party Claude Code skills worth installing for Konjugieren work
├── code-audit.md              # Full-codebase audit (June 2026): bugs, duplication, dead code, smells, test gaps, phased implementation order
├── code-review-recommendations.md  # Second full-codebase review (July 2026): ranked recommendations across game, widget, deeplink, and concurrency findings, with a phased implementation sequence
├── conjugationgroupText.md    # Template and guidelines for conjugationgroup articles
├── control-center-controls.md  # iOS 18+ ControlWidget constraints on `openAppWhenRun`/`OpenURLIntent` and the Shared/ dual-target pattern
├── dwds-permission-email.md   # Draft permission request to dwds@bbaw.de for frequency-API use (§ 44b UrhG reservation)
├── emoji-assets.md            # Why some emoji ship as PNG assets (iOS 26 emoji-rendering workaround)
├── english_writing_style.md   # English writing conventions consulted by Claude when editing localization strings, docs, and comments
├── etymologies.md             # Etymology pipeline documentation
├── etymology-pipeline.md      # Etymology *translation* pipeline: EN→DE batch workflow and coverage check. Lived at the repo root until 2026-07-20, where two sessions searching `docs/` failed to find it and one concluded it had never existed
├── example-sentence-pipeline.md   # Pipeline for generating literary example sentences
├── example-sentence-prompt.md     # Prompt template for example sentence generation
├── example-sentence-sources.md    # Source texts for example sentences
├── feature-architecture.md    # Architecture details: Quiz, Game Center, Info, Deeplink systems
├── frequencies.txt            # Verb frequency data
├── grep-gotchas.md            # Silent-truncation failure mode that bites `grep` on long-line files (xcstrings, Markdown); detection via `grep -c`
├── history_corrections.md     # **The verb-history fact-check's deliverable.** 27 findings with replacement prose in both languages, 9 span corrections, agent H's 16 internal-consistency items, 4 thin confirmations, and the coverage reconciliation. Applied to both extracts on 2026-07-29; its "What was applied and what was not" section records the nine declines. Synced to the catalog on 2026-07-29
├── line-counts-howto.md       # How to generate line count reports
├── line-counts.md             # Line count report for the project
├── linkedin-launch-post.txt   # LinkedIn post for app launch
├── Localization.md            # Localization workflow documentation
├── luther_section.md          # **The Luther section's deliverable.** Why the verb-history essay's nineteenth heading says what it says: verdicts on the four briefed candidates (two shipped, one refuted by the Zurich Bible's tense statistics, one unsupported because the Satzklammer was already formed), the four things cut from the draft including `ketzerisches e`, and two traps worth carrying forward
├── nomination.md              # App Store featuring nomination — Description, Helpful Details, and Supplemental Materials slots
├── on-device-tool-design.md   # Lessons from implementing Foundation Models Tool conformances
├── pdf.md                     # PDF export documentation
├── peterborough-chronicle-reading-list.md  # Reading list for the Peterborough Chronicle and the Old-to-Middle English transition
├── platform-features-plan.md  # Plan for platform-specific features
├── post-release-features.md   # Post-release feature backlog
├── project-structure.md       # This file — annotated directory tree
├── query-rewriting-exploration.md  # Query rewriting research for tutor feature
├── regenerate-verbs-pdf-prompt.md  # Self-contained session prompt for regenerating konjugieren-verbs.pdf
├── screenshot-plan.md            # App Store screenshot capture spec: 9 view categories × light/dark × English/German across iPhone 6.9" and iPad 13"
├── screenshot-playbook.md        # App Store screenshot workflow: prerequisites, driver flags, the 12 workarounds, recovery guidance
├── screenshots/                  # Captured App Store screenshots produced by `scripts/take_screenshots.sh` (gitignored)
├── sound-replacement-prompts.md    # Prompts used to generate replacement sound effects
├── terminology.md             # Conjugationgroup definitions, tense/mood/voice distinctions
├── tutor-test-queries.txt     # Test queries for the AI tutor
├── ui-audit.md                # UI audit notes and findings (Round One; implemented in commit 657bb4f)
├── ui-audit-2.md              # UI audit Round Two — post-657bb4f suggestions; self-contained for future implementation sessions
├── ui-audit-2-next-session.md # Next-session brief for OnboardingView page-1 layout work from UI audit Round Two #16
├── usage.md                   # Reading the five-hour window from inside a session: the zero-token `/usage` probe, why the calling session pays, and what a headless child costs
├── vanilla_build_and_test.md  # Raw xcodebuild commands for opting out of the ios-build-verify dependency
├── roadmap.md                 # START HERE for verb-corpus expansion: the sequence of plans, what gates what
├── verb-classification.md     # The classify-and-verify pipeline: design, invocation, and what it found
├── verb-sources.md            # Verb-corpus expansion research (2026-07): Wiktionary/kaikki/Wikidata/DWDS measurements, licenses, extraction pipeline
├── verb_history.txt           # Editable English source of Info.verbHistoryText, header plus body; sync with `scripts/sync_verb_history.py`
├── verb_history_de.txt        # The German translation of the same, synced with `--lang de`
├── verb_history_claims.md     # Claim inventory for the verb-history fact-check: 111 numbered claims, one owning cluster each
├── verb_history_phase0.md     # Phase 0 of the fact-check: what was patched from Conjugar's corrections, what diverged, and what the patch could not reach
├── verb_history_phase1.md     # Phase 1 of the fact-check: a verdict for all 111 inventory rows, 31 findings with replacement prose, and agent H's internal-consistency report
├── verb_history_phase2.md     # Phase 2 of the fact-check: adversarial disposition of all 31 findings, replacement prose for the 27 survivors, and the coverage audit. Phase 4's input
├── verb_history_phase2_reports/  # The 31 skeptic reports, the 19 second opinions, the coverage audit, and final.json
├── verb_history_phase3.md     # Phase 3 of the fact-check: the essay's 27 `$…$` spans against the app's own conjugation output, markup integrity, and four findings against the app rather than the essay, one of them a shipped `sollen` bug since fixed. Phase 4's other input; the deliverable is `history_corrections.md`
├── video_script.md            # App Store preview script with bilingual captions and 30-second timing math
├── voiceover.md               # VoiceOver pronunciation patterns and per-screen strategy
├── wwdc2026-platforms-sotu.md  # WWDC2026 Platforms State of the Union announcements relevant to Konjugieren; reshapes the cloud-llm-tier decision
├── wwdc2026-platforms-sotu-transcript.txt  # Verbatim WWDC2026 session-102 transcript (Apple copyrighted; gitignored)
├── wwdc2026-whats-new-in-swift.md  # WWDC2026 "What's New in Swift" (session 262) announcements relevant to Konjugieren; gated by the Apple-silicon/Xcode-27 toolchain move
├── wwdc2026-whats-new-in-swift-transcript.txt  # Verbatim WWDC2026 session-262 transcript (Apple copyrighted; gitignored)
├── wwdc2026-whats-new-swiftui.md  # WWDC2026 "What's new in SwiftUI" announcements relevant to Konjugieren; SwiftUI companion to the Platforms SOTU report
└── wwdc2026-whats-new-swiftui-transcript.txt  # Verbatim WWDC2026 session-269 transcript (Apple copyrighted; gitignored)

scripts/
├── check_docs.py              # Asserts the checkable claims the docs make about themselves: corpus/ablaut/test counts in the four cache files, relative-link targets, roadmap commit hashes, the kaikki attribution invariant, and etymology completeness
├── generate_verb_pdf.py       # Generates PDF verb conjugation tables
├── render_emoji.swift         # Renders emoji glyphs to PNG assets in Assets.xcassets (workaround for iOS 26 emoji-rendering bug; see docs/emoji-assets.md)
├── sync_verb_history.py       # Validates docs/verb_history{,_de}.txt against StringExtensions' markup rules and writes the body back into Localizable.xcstrings
├── test_sync_verb_history.py  # Negative-tests every validator in sync_verb_history.py by corrupting a copy of the essay one way at a time; also asserts both shipping extracts validate clean
└── take_screenshots.sh        # Drives ios-build-verify + axe/simctl through 36 App Store screenshots (9 views × 2 langs × 2 devices); see docs/screenshot-playbook.md

corpus/                        # German text corpus for example sentence sourcing (gitignored,
│                              # except corpus/working/*.py — see .gitignore for why)
├── README.md
├── government/                # Federal government reports and policy documents
├── government2/               # Additional government publications
├── medieval/                  # Old High German texts (Hildebrandslied, Tatian, etc.). NOT indexed by build_corpus_index.py: these files mix primary text, translation, and modern commentary, so citing them needs a policy the indexer lacks
├── modern/                    # Modern German literature and legal texts
├── technology/                # BSI security guides and technical Wikipedia articles
└── working/                   # Pipeline scripts and their build products
    └── build_corpus_index.py  # Phase 2 of prompts/uses_etymologies.md: indexes the corpus into per-verb candidate sentences using forms.json. Sentence-wise (not line-wise) matching, Satzklammer split-particle rule, two-column PDF recovery, English translations excluded

verbdata/                      # Verb-corpus-expansion data (see docs/verb-sources.md)
│   generate_frequencies_txt.py  # Regenerates docs/frequencies.txt from Verbs.xml (--check for drift)
├── README.md                  # Provenance, integrity stats, and re-download recipes for the data files
├── fetch_dwds_frequencies.py  # Fetches DWDS lemma frequencies; --lemmas FILE overrides the Verbs.xml corpus
├── wiktionary-defects.json    # Verbs where Konjugieren deliberately disagrees with English Wiktionary because Wiktionary is wrong (auto-generated weak tables); subtracted from the at-odds count by summarize_classification.py
├── build_candidates.py        # Classify-and-verify stage A: kaikki JSONL → candidates.json (see docs/verb-classification.md)
├── summarize_classification.py # Classify-and-verify stage C: classification.json → a Markdown summary grouped by cause
├── add_readings.py            # One-shot migration that gave every verb a <reading> child (roadmap step 5)
├── import_tranche1.py         # One-shot import of the 78 missing strong bases (roadmap step 7); the decision table is the artifact
├── import_tranche2.py         # Rule-driven import of 2,303 prefixed derivatives (roadmap step 8); hi derived from each base
├── tranche2-dual-auxiliary.txt # 176 imported verbs shipping one reading of two; worklist for the dual-auxiliary pass
├── dwds-frequencies.json      # 990-lemma DWDS frequency snapshot (gitignored pending BBAW permission)
├── candidates.json            # 9,217 normalized candidate conjugation tables (gitignored, regenerable)
├── classification.json        # Per-verb classification results (gitignored, regenerable)
├── classification-summary.md  # Rendered summary of the above (gitignored, regenerable)
└── kaikki.org-dictionary-German-by-pos-verb.jsonl  # 294 MB kaikki.org German-verb extraction (gitignored)

GameCenterResources.gamekit/   # Game Center leaderboard configuration and images

Images/                        # README and App Store screenshot images
```
