# Project Structure

```
Konjugieren/
├── Info.plist                  # App configuration (deeplinks, export compliance)
├── PrivacyInfo.xcprivacy       # Privacy manifest for App Store submission
├── Secrets.example.xcconfig    # Template for secrets configuration
├── Secrets.xcconfig            # TelemetryDeck app ID (gitignored)
├── App/
│   ├── AppLauncher.swift       # Chooses TestApp vs KonjugierenApp based on environment
│   ├── KonjugierenApp.swift    # Main app entry point with Game Center auth
│   └── TestApp.swift           # Minimal app for unit test environment
├── Assets/
│   ├── Localizable.xcstrings   # Localization strings (JSON format, EN/DE)
│   ├── Assets.xcassets/        # Colors, app icons, images (CliffSchmiesing, JoshAdams)
│   └── Sounds/                 # MP3 sound effects (applause, buzz, chime, guns, etc.)
├── Models/
│   ├── Ablaut.swift            # Single ablaut: replacement + target conjugationgroups
│   ├── AblautGroup.swift       # Named collection of ablauts for a verb pattern
│   ├── AblautGroupInfo.swift   # Identifiable struct with localized ablaut-group descriptions
│   ├── AblautGroupParser.swift # XMLParser delegate that parses AblautGroups.xml
│   ├── AblautGroups.xml        # ~40 ablaut pattern definitions
│   ├── AppIcon.swift           # Alternate app-icon enum (hat/pretzel/bundestag)
│   ├── AudioFeedback.swift     # Setting enum: enable/disable sound effects
│   ├── Auxiliary.swift         # haben/sein auxiliary verb enum
│   ├── BrowseableFamily.swift  # Enum of browseable family categories for FamilyBrowseView
│   ├── Conjugationgroup.swift  # Enum of all conjugationgroups with endings
│   ├── ConjugationgroupLang.swift  # Setting enum: german/english display
│   ├── Conjugator.swift        # Core conjugation logic for all conjugationgroups
│   ├── ConjugatorError.swift   # Error enum for conjugation failures
│   ├── Family.swift            # Verb families (strong/weak/mixed/ieren)
│   ├── InfoMedia.swift         # Enum: .photo or .sfSymbol media for Info rows
│   ├── Info.swift              # Info article model with rich text and images
│   ├── PersonNumber.swift      # 1s, 2s, 3s, 1p, 2p, 3p with localized pronouns
│   ├── Prefix.swift            # Separable/inseparable prefix enum
│   ├── PrefixMeaning.swift     # Prefix meanings with PIE etymologies
│   ├── Quiz.swift              # @Observable quiz state: questions, timer, scoring
│   ├── QuizDifficulty.swift    # Setting enum: regular vs ridiculous
│   ├── SearchScope.swift       # Setting enum: infinitive-only vs. infinitive-and-translation search
│   ├── SortOrder.swift         # Enum for verb list sorting (alphabetical/frequency)
│   ├── Sound.swift             # Sound effect definitions (guns, chimes, applause)
│   ├── TabSelection.swift      # TabView selection enum for programmatic tab switching
│   ├── ThirdPersonPronounGender.swift  # Setting enum: er/sie/es preference
│   ├── Verb.swift              # Verb model with stamm/ablaut-region computation
│   ├── VerbParser.swift        # XMLParser delegate that parses Verbs.xml
│   ├── Verbs.xml               # ~200 verb definitions with markers and metadata
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
│   ├── KonjugierenLogger.swift # os.Logger factory with app subsystem
│   ├── L.swift                 # Type-safe localization string accessors
│   ├── Layout.swift            # Spacing constants (8pt, 16pt, 24pt)
│   ├── MixedCaseAccessibility.swift  # VoiceOver labels for mixed-case ablaut strings
│   ├── Modifiers.swift         # Custom ViewModifiers (headingLabel, funButton, etc.)
│   ├── Settings.swift          # @Observable settings with UserDefaults persistence
│   ├── SoundPlayer.swift       # Protocol for audio playback
│   ├── SoundPlayerDummy.swift  # No-op implementation for tests
│   ├── SoundPlayerReal.swift   # AVAudioPlayer implementation with debouncing
│   ├── StringExtensions.swift  # Rich text markup parsing to RichTextBlock/TextSegment
│   ├── TextExtension.swift     # Text(mixedCaseString:) for ablaut-highlighted display
│   ├── TimeFormatter.swift     # Formats elapsed seconds as h:mm:ss
│   ├── URLExtension.swift      # Deeplink URL helpers (konjugieren:// scheme)
│   ├── UserLocale.swift        # Locale detection helpers (isGerman, isEnglish)
│   ├── Utterer.swift           # Protocol for text-to-speech with UttererLocale constants
│   ├── UttererDummy.swift      # No-op TTS implementation for tests
│   └── UttererReal.swift       # AVSpeechSynthesizer implementation
└── Views/
    ├── FamilyBrowseView.swift  # Browseable list of verb families, prefixes, and ablaut groups
    ├── FamilyDetailView.swift  # Detail view for a single family/prefix/ablaut category
    ├── InfoBrowseView.swift    # List of Info articles (dedication, history, etc.)
    ├── InfoView.swift          # Detail view for a single Info article
    ├── MainTabView.swift       # Root TabView with five tabs
    ├── OnboardingView.swift    # Multi-page onboarding shown on first launch
    ├── QuizView.swift          # Quiz gameplay: questions, timer, answer input
    ├── ResultsView.swift       # Modal showing quiz results and leaderboard button
    ├── RichTextView.swift      # Renders RichTextBlock content with styling
    ├── SettingsView.swift      # Settings UI with segmented pickers
    ├── VerbBrowseView.swift    # Searchable, sortable list of all verbs
    └── VerbView.swift          # Verb detail showing all conjugations

KonjugierenTests/
├── Models/
│   ├── ConjugatorTests.swift   # Comprehensive conjugation tests (~50 test functions)
│   └── QuizTests.swift         # Quiz logic and scoring tests
└── Utils/
    ├── DeeplinkTests.swift     # Deeplink URL parsing and handling tests
    ├── MixedCaseAccessibilityTests.swift  # VoiceOver label generation tests
    ├── SettingsTests.swift     # Settings persistence and default-value tests
    ├── StringExtensionsTests.swift  # Rich text parsing and error handling tests
    └── TimeFormatterTests.swift     # Time formatting utility tests

docs/
├── adding-verbs.md            # Verb-addition guide: XML formats, ablaut system, lessons learned
├── conjugationgroupText.md    # Template and guidelines for conjugationgroup articles
├── feature-architecture.md    # Architecture details: Quiz, Game Center, Info, Deeplink systems
├── project-structure.md       # This file — annotated directory tree
├── terminology.md             # Conjugationgroup definitions, tense/mood/voice distinctions
└── voiceover.md               # VoiceOver pronunciation patterns and per-screen strategy
```
