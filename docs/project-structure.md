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
│   ├── AblautGroups.xml        # ~40 ablaut pattern definitions
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
│   ├── GameState.swift         # Enemy and Bullet structures for game mechanics
│   ├── Info.swift              # Info article model with rich text and images
│   ├── InfoMedia.swift         # Enum: .photo or .sfSymbol media for Info rows
│   ├── KonjugierenTips.swift   # TipKit tips (e.g., change-difficulty hint)
│   ├── LanguageModelService.swift      # Protocol for on-device AI error explanation and tutoring
│   ├── LanguageModelServiceDummy.swift # No-op stub for tests/unsupported devices
│   ├── LanguageModelServiceReal.swift  # FoundationModels implementation for AI tutoring
│   ├── PersonNumber.swift      # 1s, 2s, 3s, 1p, 2p, 3p with localized pronouns
│   ├── Prefix.swift            # Separable/inseparable prefix enum
│   ├── PrefixMeaning.swift     # Prefix meanings with PIE etymologies
│   ├── Quiz.swift              # @Observable quiz state: questions, timer, scoring
│   ├── QuizDifficulty.swift    # Setting enum: regular vs ridiculous
│   ├── QuizErrorHistory.swift  # Persistence for recent quiz errors (up to 200)
│   ├── SearchScope.swift       # Setting enum: infinitive-only vs. infinitive-and-translation search
│   ├── SortOrder.swift         # Enum for verb list sorting (alphabetical/frequency)
│   ├── Sound.swift             # Sound effect definitions (guns, chimes, applause)
│   ├── TabSelection.swift      # TabView selection enum for programmatic tab switching
│   ├── ThirdPersonPronounGender.swift  # Setting enum: er/sie/es preference
│   ├── TutorChatHistory.swift  # Persistence for chat messages with the AI tutor
│   ├── Verb.swift              # Verb model with stamm/ablaut-region computation
│   ├── VerbParser.swift        # XMLParser delegate that parses Verbs.xml
│   ├── Verbs.xml               # 990 verb definitions with markers and metadata
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
│   ├── HapticPlayer.swift      # Haptic feedback methods respecting audio-feedback setting
│   ├── KonjugierenLogger.swift # os.Logger factory with app subsystem
│   ├── L.swift                 # Type-safe localization string accessors
│   ├── Layout.swift            # Spacing constants (8pt, 16pt, 24pt)
│   ├── LiveActivityManager.swift   # Creates and updates Live Activities for quiz and game
│   ├── MixedCaseAccessibility.swift  # VoiceOver labels for mixed-case ablaut strings
│   ├── Modifiers.swift         # Custom ViewModifiers (headingLabel, funButton, etc.)
│   ├── RatingsFetcher.swift    # Fetches app ratings from iTunes API
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
├── NextVerbIntent.swift        # AppIntent for advancing to the next verb in the widget
├── QuickQuizControl.swift      # Control Center button launching the quiz
├── QuizWidget.swift            # Timeline-based widget for daily quiz questions
├── RandomVerbControl.swift     # Control Center button opening a random verb
├── SnapshotReader.swift        # Reads WidgetSnapshot from shared container with fallback
├── VerbDesTagesWidget.swift    # Timeline-based widget displaying the daily verb
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
├── OpenQuizIntent.swift            # Shared intent to open quiz via deeplink
├── OpenRandomVerbIntent.swift      # Shared intent to open random verb via deeplink
├── QuizActivityAttributes.swift    # ActivityKit model for quiz live activity
├── WidgetConstants.swift           # Constants for widget app-group container and storage keys
└── WidgetSnapshot.swift            # Data models for serialized widget state

KonjugierenTests/
├── Models/
│   ├── ConjugatorTests.swift   # Comprehensive conjugation tests (~50 test functions)
│   ├── QuizErrorHistoryTests.swift # Quiz error persistence tests
│   └── QuizTests.swift         # Quiz logic and scoring tests
└── Utils/
    ├── DeeplinkTests.swift     # Deeplink URL parsing and handling tests
    ├── MixedCaseAccessibilityTests.swift  # VoiceOver label generation tests
    ├── SettingsTests.swift     # Settings persistence and default-value tests
    ├── StringExtensionsTests.swift  # Rich text parsing and error handling tests
    ├── TimeFormatterTests.swift     # Time formatting utility tests
    ├── VerbExportTests.swift        # Verb data JSON export tests
    └── WidgetSnapshotTests.swift    # Widget snapshot generation and determinism tests

docs/
├── adding-verbs.md            # Verb-addition guide: XML formats, ablaut system, lessons learned
├── bratwurst-icon-prompts.md  # Prompts used to generate bratwurst-themed app icons
├── conjugationgroupText.md    # Template and guidelines for conjugationgroup articles
├── etymologies.md             # Etymology pipeline documentation
├── example-sentence-pipeline.md   # Pipeline for generating literary example sentences
├── example-sentence-prompt.md     # Prompt template for example sentence generation
├── example-sentence-sources.md    # Source texts for example sentences
├── feature-architecture.md    # Architecture details: Quiz, Game Center, Info, Deeplink systems
├── frequencies.txt            # Verb frequency data
├── line-counts-howto.md       # How to generate line count reports
├── line-counts.md             # Line count report for the project
├── linkedin-launch-post.txt   # LinkedIn post for app launch
├── Localization.md            # Localization workflow documentation
├── on-device-tool-design.md   # Lessons from implementing Foundation Models Tool conformances
├── pdf.md                     # PDF export documentation
├── platform-features-plan.md  # Plan for platform-specific features
├── post-release-features.md   # Post-release feature backlog
├── project-structure.md       # This file — annotated directory tree
├── query-rewriting-exploration.md  # Query rewriting research for tutor feature
├── sound-replacement-prompts.md    # Prompts used to generate replacement sound effects
├── terminology.md             # Conjugationgroup definitions, tense/mood/voice distinctions
├── tutor-test-queries.txt     # Test queries for the AI tutor
├── ui-audit.md                # UI audit notes and findings
└── voiceover.md               # VoiceOver pronunciation patterns and per-screen strategy

scripts/
└── generate_verb_pdf.py       # Generates PDF verb conjugation tables

corpus/                        # German text corpus for example sentence sourcing
├── README.md
├── government/                # Federal government reports and policy documents
├── government2/               # Additional government publications
├── medieval/                  # Old High German texts (Hildebrandslied, Tatian, etc.)
├── modern/                    # Modern German literature and legal texts
└── technology/                # BSI security guides and technical Wikipedia articles

GameCenterResources.gamekit/   # Game Center leaderboard configuration and images

Images/                        # README and App Store screenshot images
```
