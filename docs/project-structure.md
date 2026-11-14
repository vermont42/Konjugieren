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
│   ├── QuickActions.swift      # Home Screen quick action (Find a Verb), installed at launch; AppDelegate and the scene delegate that receive it, since SwiftUI has no hook
│   ├── TestApp.swift           # Minimal app for unit test environment
│   └── VerbSearchCommands.swift  # Menu command: Command-F switches to the Verbs tab and focuses search (iPad, Mac)
├── Assets/
│   ├── Localizable.xcstrings   # Localization strings (JSON format, EN/DE)
│   ├── Assets.xcassets/        # Colors, app icons, images (CliffSchmiesing, JoshAdams, etc.)
│   └── Sounds/                 # MP3 sound effects (applause, buzz, chime, guns, etc.)
├── Intents/
│   ├── ConjugateVerbIntent.swift   # Siri shortcut intent for conjugating a verb
│   ├── KonjugierenShortcuts.swift  # AppShortcutsProvider registering all Siri shortcuts
│   ├── LookUpVerbIntent.swift      # Look Up a Verb: answers which verb a word belongs to ("ging: Präteritum Indikativ (ich, er) of gehen"), then opens the page or the search through the hidden OpenLookupResultIntent
│   ├── OpenVerbIntent.swift        # Siri shortcut intent to open a verb detail view
│   ├── SiriConjugationgroup.swift  # AppEnum mapping conjugationgroups for Siri
│   ├── VerbEntity.swift            # AppEntity for verb selection in Siri intents; its attributeSet carries the Spotlight fields
│   └── VerbSpotlight.swift         # Each verb's Spotlight entry (key conjugations as description, glosses and conjugations as alternate names and keywords), indexed at launch into the named index "verbs"
├── Models/
│   ├── Ablaut.swift            # Single ablaut: replacement + target conjugationgroups
│   ├── AblautGroup.swift       # Named collection of ablauts for a verb pattern
│   ├── AblautGroupInfo.swift   # Identifiable struct with localized ablaut-group descriptions
│   ├── AblautGroupParser.swift # XMLParser delegate that parses AblautGroups.xml
│   ├── AblautGroups.xml        # 76 ablaut pattern definitions
│   ├── AnswerDifference.swift  # Where a wrong quiz answer differs from the right one, letter by letter (an alignment like VerbSearch.editDistance's), and QuizItem.difference(from:), which picks the nearest spelling of the cell to show
│   ├── AnswerFrame.swift       # The shape of a quiz answer: blanks and the words around them (ihr [ ], [ ] Sie [ ] !); the answer a set of filled blanks gives, and where Return goes
│   ├── AnswerSlip.swift        # Whether a wrong quiz answer is a slip that earns one more attempt: one edit or only missing umlauts and ß, four letters or more, and never another cell of the verb
│   ├── AnswerSpelling.swift    # Quiz answer normalization: case and spacing, the leading pronouns a cell allows (ihr habt …), digraph spellings of umlauts (ue for ü, never ü for ue), and the orthographic key for showing a learner the umlaut spelling
│   ├── AppIcon.swift           # Alternate app-icon enum (bratwurst/hat/pretzel/bundestag)
│   ├── AudioFeedback.swift     # Setting enum: enable/disable sound effects
│   ├── Auxiliary.swift         # haben/sein auxiliary verb enum
│   ├── BrowseableFamily.swift  # Enum of browseable family categories for FamilyBrowseView
│   ├── Clause.swift            # main/subordinate: whether a separable prefix splits off (ich stehe auf) or joins (aufstehe)
│   ├── ConjugationLabels.swift # Display members of core types that need L or Settings (Family.displayName, PersonNumber.pronoun, Conjugationgroup.displayName(lang:)), kept out of the files ConjugationMapTool compiles
│   ├── ConjugationMap.swift    # Conjugation → infinitive map (ging → gehen; halte → aufhalten with particle auf): builder, text/LZFSE format, and the bundled loader. Compiled into the app AND ConjugationMapTool
│   ├── ConjugationIndex.swift  # The bundled conjugation map indexed for search: folded spellings (muß → muss) and length buckets for the guess
│   ├── ConjugationMatch.swift  # Verb.conjugations(matching:): which cells of a verb equal a text, in any region and either clause; Conjugationgroup.personNumber
│   ├── ConjugationTable.swift  # The verb page's tables in page order (frequency within simple, then compound; docs/conjugationgroup-frequency.md), each table's cells, second names, and Info article; Conjugationgroup.allCells and .table
│   ├── Conjugationgroup.swift  # Enum of all conjugationgroups with endings
│   ├── ConjugationgroupLang.swift  # Setting enum: german/english display
│   ├── Conjugator.swift        # Core conjugation logic for all conjugationgroups; joined (subordinate-clause) conjugations by default, the Wiktionary oracle
│   ├── ConjugatorError.swift   # Error enum for conjugation failures
│   ├── Etymologies.json        # Bundled verb etymologies keyed by language and infinitive
│   ├── Etymology.swift         # Lazy-loading etymology lookup by infinitive
│   ├── ExampleSentence.swift   # Lazy-loading literary example sentence lookup by infinitive
│   ├── ExampleSentences.json   # Bundled literary example sentences keyed by language and infinitive
│   ├── Family.swift            # Verb families (strong/weak/mixed/ieren)
│   ├── FrequencyBand.swift     # The 100, 300, and 1,000 most frequent verbs, defined once: Verb.isIn(_:) and Verb.verbs(in:)
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
│   ├── KeyConjugations.swift   # Verb.keyConjugations (steht auf · stand auf · ist aufgestanden, always shown with no label) and Verb.shareText, what the verb page's share button sends
│   ├── KonjugierenTips.swift   # TipKit tips (e.g., ChangeLevelTip, shown in Settings after a quiz; the verb page's RedLettersTip and ScrollToBottomTip)
│   ├── LearnerVerbStore.swift  # Current.learnerVerbs: @Observable view of Shared/LearnerVerbs.swift that records opens, stars, and reviews, saves each change to the App Group's defaults, and answers in verbs (starred, recent, My Verbs, the verb due for review)
│   ├── LanguageModelService.swift      # Protocol for on-device AI error explanation and tutoring
│   ├── LanguageModelServiceDummy.swift # No-op stub for tests/unsupported devices
│   ├── LanguageModelServiceReal.swift  # FoundationModels implementation for AI tutoring
│   ├── PersonNumber.swift      # 1s, 2s, 3s, 1p, 2p, 3p (pronouns live in ConjugationLabels.swift)
│   ├── Prefix.swift            # Separable/inseparable prefix enum ([Prefix] helpers live in Reading.swift)
│   ├── PrefixMeaning.swift     # Prefix meanings with PIE etymologies
│   ├── PrefixSection.swift     # Curated-vs-other heading for the prefix-grouped verb list
│   ├── Quiz.swift              # @Observable quiz state: rounds of ten and Ten More (continueSession), re-asks of missed questions, timer, scoring summed from the items; QuizItem grading (accepts, preferredSpelling), points, reasked(); DEBUG fixtures (screenshot, grading, frames, corrections, slips); QuizItem.answerFrame; QuizScope (the verbs asked about, a round's question count, the analytics source, whether it continues, and whether the score is ranked): every verb, My Verbs, a collection, or three questions on a verb's page
│   ├── QuizAbandonment.swift   # The quizzes in progress, one entry per Quiz, so that the next launch can send abandonQuiz for one the app was left during (M2)
│   ├── QuizClock.swift         # Setting enum: hide (the default) or show the quiz's time
│   ├── QuizDraw.swift          # Draws a quiz's questions from a level's pool: a kind by weight, then a verb it admits, then a cell; for the default quiz, mixes the verbs (half strong, two core, one to three rare derivatives); AnyRandomNumberGenerator
│   ├── QuizLevel.swift         # Setting enum: Beginner, Elementary, Intermediate, Advanced (replaced QuizDifficulty's regular and ridiculous); each level's pool of QuizPoolEntry (a table's cells, the QuizVerbs it may ask, a weight) and the frequency band its default quiz draws from
│   ├── RelatedVerbs.swift      # Verb.root (the innermost base: anerkennen → kennen) and Verb.related(readingIndex:): verbs built on the same root, one verb per other root of the ablaut group, and the Families pages of a reading
│   ├── Region.swift            # Setting enum: the three standard varieties (north/austria/switzerland)
│   ├── ReviewCardSuppression.swift # Setting enum: off (the default) shows the review card, on hides it
│   ├── QuizErrorHistory.swift  # Persistence for recent quiz errors (up to 200)
│   ├── SearchReport.swift      # SearchTracker (one search, first letter to its end, and the surface that opened the field for it) and SearchReport (the banded finishSearch parameters)
│   ├── SearchScope.swift       # Setting enum: infinitive-only vs. infinitive-and-translation search
│   ├── SortOrder.swift         # Enum for verb list sorting (alphabetical/frequency); [Verb].sorted(by:), used by the family pages and the related-verb list; VerbListMode, the verb list's picker (Alphabetical, Frequency, My Verbs)
│   ├── StandardVariants.swift  # Duden's other standard conjugations of a cell (komme, sammle, kämst, stünde, sandte, erkennt an), accepted by the quiz but not shown on the verb page; rows of plans/pedagogy-phase1-variant-audit.md
│   ├── Sound.swift             # Sound effect definitions (guns, chimes, applause)
│   ├── TabSelection.swift      # TabView selection enum for programmatic tab switching
│   ├── ThirdPersonPronounGender.swift  # Setting enum: er/sie/es preference
│   ├── TutorChatHistory.swift  # Persistence for chat messages with the AI tutor
│   ├── Reading.swift           # One sense of a verb: gloss, family, auxiliary, prefixes
│   ├── Verb.swift              # Lemma: frequency, icon, and an ordered list of readings
│   ├── VerbCollection.swift    # Collections (Phase 16 of the browse plan): the 100 most frequent verbs, the modal verbs, the verbs that take sein (by region), and each ablaut group; keys for `list/<key>` links, the share text, viewCollection, and QuizScope.collection
│   ├── VerbDraw.swift          # The widget's verb of the day and every random verb: the top 1,000 weighted toward strong and unprefixed verbs, and My Verbs every third day (random: one draw in three)
│   ├── VerbParser.swift        # XMLParser delegate for Verbs.xml, incl. the `in` marker grammar
│   ├── VerbVisit.swift         # VerbDestination (a verb page to push, with its analytics source and the cells a search marked) and VerbVisit (one viewVerbView/leaveVerbView pair)
│   ├── VerbSearch.swift        # The one search rule (list and shortcut picker): umlaut/digraph/ß folding, ranked match kinds including conjugations and stranded parts, and the edit-distance guess (infinitives and conjugations) for a failed search
│   ├── VerbLookup.swift        # What Look Up a Verb says about a word (an infinitive, a conjugation of one or more verbs, other matches, the guess) and where it then opens the app
│   ├── VerbSearchResults.swift # What the verb list shows for a query: rows, the folded row of separable verbs, the guess; MatchedConjugation names a match's cells and the marks for the verb page; MarkedConjugations(text:on:) for a deeplink's match
│   ├── Verbs.xml               # 3,572 verb definitions with markers and metadata
│   └── World.swift             # @Observable DI container with environment selection; handleURL parses the deeplink grammar (docs/feature-architecture.md § Deeplink System); SearchRequest
├── Utils/
│   ├── Analytics.swift         # Analytics protocol, event names, parameter keys, value vocabularies (AnalyticsSource, SearchMatchKind, …), and bands
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
│   ├── GetterSetterReal.swift  # UserDefaults implementation of GetterSetter; standard defaults unless given others (the learner's verbs use the App Group's)
│   ├── GradientDivider.swift   # Shared gradient divider used by SettingsView and ResultsView
│   ├── HapticPlayer.swift      # Haptic feedback methods respecting audio-feedback setting
│   ├── KillSwitches.swift      # Compile-time screenshot kill switches: TipDisplay, OnboardingDisplay, TutorDisplay
│   ├── KonjugierenLogger.swift # os.Logger factory with app subsystem
│   ├── L.swift                 # Type-safe localization string accessors
│   ├── Layout.swift            # Spacing constants (8pt, 16pt, 24pt)
│   ├── LiveActivityManager.swift   # Creates and updates Live Activities for quiz and game
│   ├── MixedCaseAccessibility.swift  # VoiceOver labels for mixed-case ablaut strings
│   ├── Modifiers.swift         # Custom ViewModifiers (headingLabel, funButton, speakOnTap, copyOnLongPress, etc.)
│   ├── RatingsFetcher.swift    # Fetches app ratings from iTunes API
│   ├── RegionalRendering.swift # ß→ss display transform + RegionalConjugator (region-aware wrapper over the region-free Conjugator, defaulting to main-clause conjugations: steht auf); search folding lives in VerbSearch
│   ├── ReviewPrompter.swift    # Protocol for review-prompting behavior
│   ├── ReviewPrompterDummy.swift   # No-op stub for tests
│   ├── ReviewPrompterReal.swift    # Real implementation prompting reviews at intervals
│   ├── Settings.swift          # @Observable settings with UserDefaults persistence
│   ├── ShareSheet.swift        # UIKit workaround: presents UIActivityViewController for the verb page's share button, anchored to the visible bar button on iPad, with an LPLinkMetadata header (ShareLink sends no tap from a toolbar and loses Copy with a SharePreview)
│   ├── SoundPlayer.swift       # Protocol for audio playback
│   ├── SoundPlayerDummy.swift  # No-op implementation for tests
│   ├── SoundPlayerReal.swift   # AVAudioPlayer implementation with debouncing
│   ├── StringExtensions.swift  # Rich text markup parsing to RichTextBlock/TextSegment
│   ├── TextExtension.swift     # Text(mixedCaseString:) for ablaut-highlighted display
│   ├── TimeFormatter.swift     # Formats elapsed seconds as h:mm:ss
│   ├── URLExtension.swift      # The deeplink grammar's constants and builders (verbDeeplink with match, searchDeeplink, infoDeeplink by stable key), the `source` query item, developerEmail, the mailto: builder, and URL.appStore
│   ├── URLProtocolStub.swift   # URLProtocol subclass for stubbing HTTP responses in tests
│   ├── URLSessionExtension.swift   # Extension providing a stubbed URLSession for testing
│   ├── ViewControllerTransitions.swift  # UIKit workaround: waits until no view controller is presenting or dismissing, since UIKit drops a push made mid-transition (an iPad tap that ends an empty search)
│   ├── VerbSearchArrowKeys.swift   # UIKit workaround: priority UIKeyCommands so ↑/↓ move through search results while the field is focused
│   ├── UserLocale.swift        # Locale detection helpers (isGerman, isEnglish)
│   ├── Utterer.swift           # Protocol for text-to-speech with UttererLocale constants
│   ├── UttererDummy.swift      # No-op TTS implementation for tests
│   ├── UttererReal.swift       # AVSpeechSynthesizer implementation
│   └── WidgetSnapshotWriter.swift  # Generates and persists the 10-day widget bundle from VerbDraw, keeping the verb the widget shows today
└── Views/
    ├── AnswerFrameView.swift   # Draws an AnswerFrame on one line with a text field per blank; Return fills the next empty blank, then submits; the letter keys follow the cursor; each field's VoiceOver label reads the whole frame
    ├── ErrorExplainerView.swift # AI-generated explanations for conjugation errors
    ├── FamilyBrowseView.swift  # The Families tab: a Collections section (rows; three cards on iPad) above the verb families, prefixes, and ablaut groups; opens a `list/<key>` link's collection
    ├── FamilyDetailView.swift  # Detail view for a single family/prefix/ablaut category; an Alphabetical/Frequency control orders the verbs within each section; an expanded ablaut group starts with its VerbCollectionBar and checks the verbs looked up, and a link opens the page with its group expanded
    ├── GameView.swift          # Space-invaders-like verb conjugation game
    ├── GermanLetterKeyRow.swift # ä ö ü ß keys shown above the keyboard, for the search field and the quiz's answer frame (a keyboard toolbar there, inserting at the cursor of the focused blank)
    ├── InfoBrowseView.swift    # List of Info articles (dedication, history, etc.)
    ├── InfoView.swift          # Detail view for a single Info article
    ├── MainTabView.swift       # Root TabView with five tabs
    ├── OnboardingView.swift    # Multi-page onboarding shown on first launch
    ├── QuizCorrectionView.swift # The held correction of a wrong quiz answer: both answers with the differing letters marked, links to the verb's page and its ablaut group or family, and Continue; defines the isBeneathQuiz environment value
    ├── QuizView.swift          # Quiz gameplay: questions, timer, answer input; the Quiz tab's start screen (a big yellow symbol for the scope, its name and description, the All Verbs/My Verbs picker, Start, three fact tiles, and My Verbs' verbs as chips, scaled up on iPad); with a sheetScope, a quiz in a sheet (QuizSheet: "Test me on this verb" or a collection's quiz), which starts as it appears and closes when the quiz ends; its own navigation stack pushes the pages a held correction links to, over the waiting quiz
    ├── RelatedVerbsView.swift  # The verb page's Related Verbs card (chips in a FlowLayout, which can also center its rows, as the Quiz tab's My Verbs chips do), RelatedVerbListView (every verb of one relation), and VerbPagePush, the environment action by which a verb page pushes onto whichever tab's stack shows it
    ├── ResultsView.swift       # Modal showing quiz results, and the leaderboard button after a ranked quiz
    ├── ReviewCardView.swift    # The review card above the verb list: a verb looked up days ago, its key conjugations hidden until a tap reveals them; a second tap opens the page, and ✕ dismisses
    ├── RichTextView.swift      # Renders RichTextBlock content with styling
    ├── SettingsView.swift      # Settings UI with segmented pickers
    ├── TutorTestView.swift     # Debug view for testing the AI tutor
    ├── TutorView.swift         # Chat interface for the AI tutor with sample queries
    ├── VerbBrowseView.swift    # Searchable, sortable list of all verbs; the letter row replaces the sort picker while search is focused; a result found by a conjugation says which cells matched, and separable verbs in which the query is a stranded part fold into one row (a grid section on iPad); a failed search shows a guess and a mail link; Return and the arrow keys open and move through results on iPad and Mac; the focused, empty field shows the recent verbs, and the picker's My Verbs is a List of starred, then recent, verbs, each deletable by a left swipe (a starred one after a confirmation); each launch and each return from the background shows the review card above the list when a verb is due
    ├── VerbCollectionView.swift # A featured collection's page; VerbCollectionBar ("3 of 100 looked up", a progress bar, Quiz, and Share), which the expanded ablaut groups share; the Families tab's VerbCollectionRow and VerbCollectionCard
    └── VerbView.swift          # Verb detail showing all conjugations; a search result opens it on the matched reading, scrolled to the matched section, with the matched rows tinted; ends with the Related Verbs card; the bar holds Test Me (a three-question quiz in a sheet), the star, and Share; each arrival records an open in the learner's verbs

KonjugierenWidget/
├── AnswerQuizIntent.swift      # AppIntent for answering a quiz question from the widget
├── Assets.xcassets/            # Widget-specific asset catalog
├── CLAUDE.md                   # Lazily loaded Claude Code guidance: WidgetL and the widget string catalog
├── FindVerbControl.swift       # Control Center button opening the verb search, empty and focused
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

ConjugationMapTool/             # macOS command-line target; borrows the conjugation core from Konjugieren/ via membership exceptions in project.pbxproj
├── CellsJSON.swift             # --cells-json: every one-word conjugation with its conjugationgroup and auxiliary, for scripts/count_conjugationgroups.py
├── main.swift                  # Reads Verbs.xml + AblautGroups.xml, writes ConjugationMap.lzfse (app build phase) and/or forms.json (scripts/write_forms_json.sh)
└── ToolWorld.swift             # Stand-in for the app's Current, offering only fatalError

Shared/
├── GameActivityAttributes.swift    # ActivityKit model for game live activity
├── MixedCaseSegmenter.swift        # Pure ablaut segmentation shared by app and widget highlighting
├── OpenQuizIntent.swift            # Shared intent to open quiz via deeplink
├── OpenRandomVerbControlIntent.swift  # The Random Verb control's action: OpenRandomVerbIntent with source=control, hidden from Shortcuts
├── OpenRandomVerbIntent.swift      # Shared intent to open random verb via deeplink (the Random Verb shortcut)
├── OpenVerbSearchIntent.swift      # The Find a Verb control's action: konjugieren://search?source=control, hidden from Shortcuts
├── LearnerVerbs.swift              # The learner's verbs (each verb opened, with dates and a count, each verb starred, and each verb's review schedule), keyed by infinitive and stored as JSON in the App Group's defaults so the widget can read it; new fields must be optional
├── QuizActivityAttributes.swift    # ActivityKit model for quiz live activity
├── ReviewSchedule.swift            # The review card's Leitner ladder (1, 3, 7, 14, 30 days): a box and a due date per verb, set by a lookup, raised by a review, postponed a day by a snooze
├── WidgetConstants.swift           # Constants for widget app-group container, storage keys, day count, and pinned Gregorian calendar
├── WidgetQuizShuffle.swift         # Process-stable (FNV-1a seeded) answer shuffle + SeededRNG, shared by widget and tests
└── WidgetSnapshot.swift            # Data models for serialized widget state, incl. WidgetSnapshotBundle (N-day array, paging, and the snapshot displayed at a moment)

KonjugierenTests/
├── CLAUDE.md                   # Lazily loaded Claude Code guidance: Swift Testing conventions for this target
├── Models/
│   ├── AnswerDifferenceTests.swift # The held correction's marking: a missing umlaut, a missing or extra letter, a swap, case as no difference, the nearer word order, a dropped pronoun
│   ├── AnswerFrameTests.swift      # The quiz's answer frame: every cell of six verbs takes its right answer through its frame, the frame per kind of cell, readings, Return
│   ├── AnswerSlipTests.swift       # One more try: what is a slip and what is another cell (kommt for kommst, musstest, fahrt), half points, one attempt at most, the separate count
│   ├── AnswerSpellingTests.swift   # Quiz grading: the report's three simulator cases, leading pronouns by person, digraphs both ways, the spelling shown beside the checkmark by region and clause
│   ├── ConjugationMapTests.swift   # Bundled map equals a fresh build (staleness), finds the verb of ≥99% of example sentences (Scan 2 of the defect plan), anchors, format round-trip
│   ├── ConjugationMatchTests.swift # Verb.conjugations(matching:): clauses, regions, finite parts, readings
│   ├── ConjugationTableTests.swift # The verb page's table order, cells, articles, and second names
│   ├── ConjugationSearchTests.swift # Search by conjugation: the ideas doc's conjugation queries, stranded parts and the folded row, particles, compounds, folding, adjective endings, cell names, marks
│   ├── ConjugationgroupTests.swift # Conjugationgroup.ending(family:) ending-table tests
│   ├── ConjugatorTests.swift   # Comprehensive conjugation tests (~50 test functions), incl. error paths
│   ├── LearnerVerbsTests.swift # The learner's verbs: opens, stars, recents, My Verbs, removal, clearing, JSON round trip and an old record's decoding, and the store's reload
│   ├── KeyConjugationsTests.swift # Key conjugations per reading and region, the share text, and what a long press copies
│   ├── InfoTests.swift         # Info articles: a heading and text per article in each language, every ‡link‡ opens an article or a verb (both catalogs), stable keys
│   ├── GameStateTests.swift    # Game-logic tests: damage invulnerability, robot-mechanic clearing, game-over/wave transitions, snapshot round-trip
│   ├── PersonNumberTests.swift # Pronoun and sie-disambiguation tests
│   ├── QuizErrorHistoryTests.swift # Quiz error persistence tests
│   ├── QuizRoundTests.swift    # Nested in QuizTests: re-ask placement and limits, half points for a re-ask, Ten More continuing the session, completeQuiz's questionCount, quitQuiz's duration bands, the hidden clock; QuizAbandonment's records and its launch report
│   ├── QuizLevelTests.swift    # Each level's tables and cells, the restricted cells' verbs, weighted shares under a fixed seed, and short quizzes' distinct cells
│   ├── QuizVerbMixTests.swift  # The default quiz's verbs over 40 seeds per level: each level's band, half strong, two core verbs, a prefixed verb, one to three rare derivatives, and no provisional count in a band
│   ├── QuizTests.swift         # Quiz logic, scoring, and timer pause/resume tests; scopes (My Verbs, three questions on a verb page, ranking, the source on start, quit, and completion)
│   ├── StandardVariantsTests.swift # Every row Josh accepted in the Phase 1 variant audit, and the ones he rejected
│   ├── SearchReportTests.swift # SearchTracker lifecycle, finishSearch parameters, and the no-typed-text guarantee
│   ├── ReviewScheduleTests.swift # The review ladder: due the next morning, the boxes, snoozes, a re-lookup back to the first box, an open from the card, an entry from before the schedule, the store's choice of verb
│   ├── RelatedVerbsTests.swift # Verb.root through nested prefixes, verbs built on a root, ablaut relatives (one per root), family pages, per-reading relations, [Verb].sorted(by:)
│   ├── RefusalDetectionTests.swift # Tutor refusal-phrase detection, incl. the "null" exact-match false-positive guard
│   ├── VerbCollectionTests.swift # Collections: keys, members (modals, the top 100, sein by region, ablaut groups as on the Ablaut page), share text, the quiz scope, the store's count of verbs looked up
│   ├── VerbDrawTests.swift     # Frequency bands, and VerbDraw: weights, My Verbs every third day and in turn, stability through a day, the favored share
│   ├── VerbLookupTests.swift   # Look Up a Verb: what it says about infinitives, conjugations, ambiguous and unknown words, and where it opens the app
│   ├── VerbSearchTests.swift   # VerbSearch: folding, match-kind ranking, the ideas doc's failed queries, list/picker agreement, the failed-search guess
│   ├── VerbSpotlightTests.swift # Spotlight fields: gloss phrases, conjugations with particles, key conjugations per reading and region
│   ├── VerbTests.swift         # Verb.stamm and endingIsValid tests
│   └── VerbVisitTests.swift    # VerbVisit: deepest section and banded dwell
├── Utils/
│   ├── AnalyticsTests.swift    # Analytics bands, section order, and the match-kind mapping
│   ├── DeeplinkTests.swift     # The deeplink grammar: every route, the `source` and `match` query items, the search route, stable-key articles, the control and quick-action links
│   ├── MixedCaseAccessibilityTests.swift  # VoiceOver label generation tests
│   ├── MixedCaseSegmenterTests.swift  # Ablaut segmentation tests (empty/all-regular/all-irregular/formal Sie)
│   ├── SettingsTests.swift     # Settings persistence and default-value tests
│   ├── StringExtensionsTests.swift  # Rich text parsing and error handling tests
│   ├── TimeFormatterTests.swift     # Time formatting utility tests
│   ├── URLExtensionTests.swift      # mailto: percent-encoding and the App Store link
│   ├── VerbClassificationTests.swift  # Harness: stage B of classify-and-verify, searching for the Verbs.xml encoding that reproduces Wiktionary. Gated on TEST_RUNNER_KONJUGIEREN_CLASSIFY_IN
│   ├── VerbExportTests.swift        # Harness: every verb's page as JSON, for scripts/generate_verb_pdf.py. Gated on TEST_RUNNER_KONJUGIEREN_EXPORT_OUT (optional TEST_RUNNER_KONJUGIEREN_EXPORT_ONLY)
│   └── WidgetSnapshotTests.swift    # Widget snapshot/bundle generation, per-day paging math, and process-stable answer-shuffle tests
└── Views/
    └── VerbBrowseViewTests.swift    # Arrow-key selection arithmetic and grid sections for the verb list

docs/
├── adding-verbs.md            # Verb-addition guide: XML formats, ablaut system, lessons learned
├── blog_notes.md              # Work journal: dated narrative notes for future blog posts and session memory
├── bratwurst-icon-prompts.md  # Prompts used to generate bratwurst-themed app icons
├── browse-and-verb-ideas.md   # Findings and ranked ideas for the verb list and verb page (2026-11-10): where a lookup fails today, what other tools do, ideas with basis, effort, signal, and carry-over to Conjuguer and Conjugar, the pieces shared with the quiz track, signals to add, and defects found while checking
├── bug-report-gitcommitsha.md  # Bug report draft: Claude Code `plugin update` doesn't refresh `gitCommitSha` in `installed_plugins.json`
├── bug-report-grep-silent-truncation.md  # Bug report draft (filed as anthropics/claude-code #56751): long-line `grep` matches silently disappear from Bash tool output
├── claude-code-skill-recommendations.md  # Curated third-party Claude Code skills worth installing for Konjugieren work
├── code-audit.md              # Full-codebase audit (June 2026): bugs, duplication, dead code, smells, test gaps, phased implementation order
├── code-review-recommendations.md  # Second full-codebase review (July 2026): ranked recommendations across game, widget, deeplink, and concurrency findings, with a phased implementation sequence
├── conjugationgroup-frequency.md # How often each conjugationgroup occurs in the corpus: method, results, and the verb page's resulting order
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
├── feature-architecture.md    # Architecture details: Quiz, Game Center, Info, Deeplink systems, and Analytics (signals and the `source` vocabulary)
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
├── privacy-policy-pending.md  # Privacy-policy lines (English and German) for analytics built on main, to splice into privacy_policy.txt on release day
├── project-structure.md       # This file — annotated directory tree
├── query-rewriting-exploration.md  # Query rewriting research for tutor feature
├── regenerate-verbs-pdf-prompt.md  # Self-contained session prompt for regenerating konjugieren-verbs.pdf
├── reply-about-wiktionary-defects.txt  # Josh's reply to a reader who asked how the app records its deliberate disagreements with Wiktionary (verbdata/wiktionary-defects.json); the recipient's name is redacted
├── screenshot-plan.md            # App Store screenshot capture spec: 9 view categories × light/dark × English/German across iPhone 6.9" and iPad 13"
├── screenshot-playbook.md        # App Store screenshot workflow: prerequisites, driver flags, the 12 workarounds, recovery guidance
├── screenshots/                  # Captured App Store screenshots produced by `scripts/take_screenshots.sh` (gitignored)
├── sound-replacement-prompts.md    # Prompts used to generate replacement sound effects
├── telemetry-usage.md         # Usage snapshot (2026-11-10) for Konjugieren, Conjuguer, Conjugar from TelemetryDeck and App Store Connect, the China-device reconciliation, and the recipes and gotchas for refreshing both
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

plans/                         # Plans written for future sessions to carry out
├── browse-and-verb-ideation.md # Brief for ideating Browse and Verb screen improvements, in parallel with the quiz work in plans/pedagogy.md
├── browse-and-verb-implementation.md # Multi-session plan, in 16 phases plus a closing, for building the ideas Josh accepted in docs/browse-and-verb-ideas.md; each session marks its phase done and notes how it differed
├── fix-reference-defects.md   # Plan for fixing the defects that ideation found, to be carried out before any idea is built: wrong auxiliaries (37 contradicted by kaikki, 141 needing a ruling) with a second reading wherever both senses are current, prefixes lost under full-override ablaut entries, two small code bugs, five example sentences, three documents, and the backen/hauen participles. Its audit prototype was promoted to verbdata/audit_auxiliaries.py
├── pedagogy-implementation.md # Multi-session plan, in 24 phases plus a closing, for building the quiz suggestions Josh accepted in plans/pedagogy.md; indexes the report's suggestions as T1.1 to T6.9 and M1 to M5, and each session marks its phase done and notes how it differed
└── pedagogy.md                # Research findings on the quiz's pedagogy (2026-11-10): what the quiz does, what a played session and the telemetry show, what the literature supports, and tiered suggestions; every claim labeled by how it was verified

scripts/
├── check_docs.py              # Asserts the checkable claims the docs make about themselves: corpus/ablaut/test counts in the four cache files, relative-link targets, roadmap commit hashes, the kaikki attribution invariant, and etymology completeness
├── count_conjugationgroups.py # Counts each conjugationgroup in the corpus, from ConjugationMapTool --cells-json; see docs/conjugationgroup-frequency.md
├── generate_verb_pdf.py       # Generates PDF verb conjugation tables from VerbExportTests' JSON (default /tmp/konjugieren-export.json)
├── render_emoji.swift         # Renders emoji glyphs to PNG assets in Assets.xcassets (workaround for iOS 26 emoji-rendering bug; see docs/emoji-assets.md)
├── sync_verb_history.py       # Validates docs/verb_history{,_de}.txt against StringExtensions' markup rules and writes the body back into Localizable.xcstrings
├── test_sync_verb_history.py  # Negative-tests every validator in sync_verb_history.py by corrupting a copy of the essay one way at a time; also asserts both shipping extracts validate clean
├── take_screenshots.sh        # Drives ios-build-verify + axe/simctl through 36 App Store screenshots (9 views × 2 langs × 2 devices); see docs/screenshot-playbook.md
└── write_forms_json.sh        # Builds ConjugationMapTool and writes corpus/working/forms.json for the Python pipelines (replaced the CorpusFormsDumpTests harness, 2026-11-12)

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
├── fetch_dwds_frequencies.py  # Fetches DWDS lemma frequencies; --lemmas FILE overrides the Verbs.xml corpus, --quarantine keeps the clean rows when some are suspect
├── apply_dwds_frequencies.py  # Writes a fetched snapshot back into Verbs.xml: sets hi, drops hp. Text surgery, not an ElementTree round trip
├── replace_inflated_estimates.py # One-shot, 2026-11-13: moved 61 provisional (hp) estimates that tranche 2 had ranked near #940 to beside a named measured verb each; the anchor table is the artifact
├── wiktionary-defects.json    # Verbs where Konjugieren deliberately disagrees with English Wiktionary because Wiktionary is wrong (auto-generated weak tables); subtracted from the at-odds count by summarize_classification.py
├── build_candidates.py        # Classify-and-verify stage A: kaikki JSONL → candidates.json (see docs/verb-classification.md)
├── summarize_classification.py # Classify-and-verify stage C: classification.json → a Markdown summary grouped by cause
├── add_readings.py            # One-shot migration that gave every verb a <reading> child (roadmap step 5)
├── import_tranche1.py         # One-shot import of the 78 missing strong bases (roadmap step 7); the decision table is the artifact
├── import_tranche2.py         # Rule-driven import of 2,303 prefixed derivatives (roadmap step 8); hi derived from each base. --check --screen V,V runs named verbs through every decision and writes nothing
├── import_tranche3.py         # Tranche 3 (roadmap step 9): bare weak and -ieren stems, hi from a two-probe DWDS fetch, icons by gloss keyword; --write-lemmas, --write-repair-lemmas, --check, then --top N / --min-hits H
├── tranche3-ranked.tsv        # import_tranche3.py --check output: every importable verb, most frequent first, with the corpus rank it would take. The list a cutoff is chosen from
├── tranche3-deferred.txt      # import_tranche3.py --check output: every tranche-3 candidate held back, and why. Recomputed each run
├── auxiliary_screen.py        # Shared by importers: ay from the same kaikki sense as tn; holds back dual-auxiliary, separability-homograph, family-split, and sense-contradicted verbs as `proposed` rows in auxiliary-rulings.tsv
├── tranche2-dual-auxiliary.txt # Frozen 2026-11-10: the verbs tranche 2 shipped with one reading of two. History; auxiliary-rulings.tsv is the current record
├── audit_auxiliaries.py       # Compares every shipped reading's auxiliary with kaikki, sense by sense, and with auxiliary-rulings.tsv. --unruled prints the worklist; --check fails on any reading that disagrees with its ruling, on any listed verb still unruled, and on any `proposed` row an importer wrote
├── auxiliary-rulings.tsv      # One row per reading ruled against DWDS / German Wiktionary by plans/fix-reference-defects.md (Parts 1 and 6): gloss, auxiliary, outcome, source, reasoning. Pinned by ConjugatorTests.ruledAuxiliary
├── dwds-frequencies.json      # Corpus-wide DWDS frequency snapshot, re-fetched 2026-08-26 under BBAW permission (gitignored, regenerable)
├── dwds/                      # Inputs and logs for the corpus-wide fetch: lemma list with probes, quarantine files, run logs (gitignored)
├── candidates.json            # 9,217 normalized candidate conjugation tables (gitignored, regenerable)
├── classification.json        # Per-verb classification results (gitignored, regenerable)
├── classification-summary.md  # Rendered summary of the above (gitignored, regenerable)
└── kaikki.org-dictionary-German-by-pos-verb.jsonl  # 294 MB kaikki.org German-verb extraction (gitignored)

GameCenterResources.gamekit/   # Game Center leaderboard configuration and images

Images/                        # README and App Store screenshot images
```
