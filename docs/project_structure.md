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
│   └── VerbSpotlight.swift         # Each verb's Spotlight entry (key conjugations as description, glosses and conjugations as alternate names and keywords), indexed at launch into the named index "verbs", deleting first the verbs that have left the corpus
├── Models/
│   ├── Ablaut.swift            # Single ablaut: replacement + target conjugationgroups
│   ├── AblautGroup.swift       # Named collection of ablauts for a verb pattern
│   ├── AblautPractice.swift    # Ablaut-group practice: AblautPracticeGroup (a group's ten most frequent verbs with their readings of the group, its key conjugations, isKnown: half past the first box of the practice record, mixPartners, practicedAloneByUse), AblautPracticeSession (alone or mixed), QuizScope.ablautPractice, and QuizDraw.ablautPracticeSteps and ablautMixSteps (three verbs of the group, two of the known groups)
│   ├── Achievement.swift       # The eight Game Center achievements for mastery milestones: permanent IDs, points, each one's progress computed from the practice record (a level's weak patterns, or all three key conjugations of the pillars or of 10, 25, or 50 core strong verbs), and World.reportAchievements()
│   ├── AblautGroupInfo.swift   # Identifiable struct with localized ablaut-group descriptions
│   ├── AblautGroupParser.swift # XMLParser delegate that parses AblautGroups.xml
│   ├── AblautGroups.xml        # 76 ablaut pattern definitions
│   ├── AnswerDiagnosis.swift   # Why a wrong quiz answer is wrong, when the conjugator can say so exactly (another cell or reading, an auxiliary, ge-, prefix order, a strong verb made weak), and the one line that says it; QuizItem.diagnosis(of:)
│   ├── AnswerDifference.swift  # Where a wrong quiz answer differs from the right one, letter by letter (an alignment like VerbSearch.editDistance's), and QuizItem.difference(from:), which picks the nearest spelling of the cell to show
│   ├── AnswerFrame.swift       # The shape of a quiz answer: blanks and the words around them (ihr [ ], [ ] Sie [ ] !), or a sentence's words (.context) and its sentenceTokens for wrapping; the answer a set of filled blanks gives, and where Return goes
│   ├── AnswerSlip.swift        # Whether a wrong quiz answer is a slip that earns one more attempt: one edit or only missing umlauts and ß, four letters or more, and never another cell of the verb
│   ├── AnswerSpelling.swift    # Quiz answer normalization: case and spacing, the leading pronouns a cell allows (ihr habt …), digraph spellings of umlauts (ue for ü, never ü for ue), and the orthographic key for showing a learner the umlaut spelling
│   ├── AppIcon.swift           # Alternate app-icon enum (bratwurst/hat/pretzel/bundestag)
│   ├── AudioFeedback.swift     # Setting enum: enable/disable sound effects
│   ├── Auxiliary.swift         # haben/sein auxiliary verb enum
│   ├── BrowseableFamily.swift  # Enum of browseable family categories for FamilyBrowseView
│   ├── ChoiceQuestion.swift    # Choice questions: ChoiceQuestion (a setting, the same sentence in two conjugationgroups read as GapSentences, the reason line, the levels that ask it), ChoiceSetting, ChoiceReason (nine localized reasons), ChoicePrompt (an item with the right sentence first or second), ChoiceQuestions (the bundle, drafts in debug builds only), QuizDraw.choice and choicePosition
│   ├── ChoiceQuestions.json    # The authored choice items, each with its verb, person, level, setting, reason, right and other sentences with {braced} conjugations, English, and whether Josh has reviewed it; checked by ChoiceQuestionTests, reviewed and approved with scripts/choice_questions.py
│   ├── Clause.swift            # main/subordinate: whether a separable prefix splits off (ich stehe auf) or joins (aufstehe)
│   ├── ConjugationLabels.swift # Display members of core types that need L or Settings (Family.displayName, PersonNumber.pronoun, Conjugationgroup.displayName(lang:)), kept out of the files ConjugationMapTool compiles
│   ├── ConjugationMap.swift    # Conjugation → infinitive map (ging → gehen; halte → aufhalten with particle auf): builder, text/LZFSE format, and the bundled loader. Compiled into the app AND ConjugationMapTool
│   ├── ConjugationIndex.swift  # The bundled conjugation map indexed for search: folded spellings (muß → muss) and length buckets for the guess
│   ├── ConjugationMatch.swift  # Verb.conjugations(matching:): which cells of a verb equal a text, in any region and either clause; Verb.cells(filledBy:preferring:), the first reading's whole conjugations or finite parts, which MatchedConjugation and MarkedConjugations share
│   ├── ConjugationTable.swift  # The verb page's tables in page order (frequency within simple, then compound; docs/conjugationgroup_frequency.md), each table's cells, second names, Info article, and the page section it marks; hasRedLetters, whether the simple tables show a red letter of the verb's own, which RedLettersTip waits for; Conjugationgroup.allCells and .table
│   ├── Conjugationgroup.swift  # Enum of all conjugationgroups with endings; personNumber, isParticiple, isImperativ, and oneWordFinites(for:), the one list of cells that leave a finite word, from which leavesFinitePart, the conjugation map's builder, and CellsJSON derive theirs
│   ├── ConjugationgroupLang.swift  # Setting enum: german/english display
│   ├── Conjugator.swift        # Core conjugation logic for all conjugationgroups; joined (subordinate-clause) conjugations by default, the Wiktionary oracle
│   ├── ConjugatorError.swift   # Error enum for conjugation failures
│   ├── CustomQuiz.swift        # The Quiz tab's custom quiz: chosen tables and a QuizVerbSet (a band, every verb, My Verbs, or a collection), either falling back to the level's; its permanent stored form (groups=…&verbs=…, or infinitives=… for a practice set's list of verbs); QuizScope.custom
│   ├── DailyChallenge.swift    # The daily challenge: DailyChallenge.Key (a day and a level, seeded by FNV-1a), the five-question draw seeded by the key alone and memoized, DailyChallengeResult (the outcomes, the dots, the agreed share text, the share signal), QuizScope.challenge, and DailyChallengeRequest
│   ├── DailyReminder.swift     # The daily reminder: the DailyReminder setting (off, on), DailyReminderPlan (one notification a day for 14 days at the chosen time, worded with what will be due or the streak's repair, none on a done day), the ReminderScheduler protocol, DailySessionRequest, and World.rescheduleReminders
│   ├── DailySession.swift      # The daily session: QuizScope.daily, QuizDraw.dailyQuestions (due items the level asks first, then the default draw), the streak's bands, and what the hub and the results say about the streak
│   ├── DailyStreak.swift       # The daily streak: finished daily sessions by day, and the status a day has (none, active, or repairable by two sessions the day after one missed day); only the last two runs are kept
│   ├── Etymologies.json        # Bundled verb etymologies keyed by language and infinitive
│   ├── Etymology.swift         # Lazy-loading etymology lookup by infinitive
│   ├── ExampleSentence.swift   # Lazy-loading literary example sentence lookup by infinitive
│   ├── ExampleSentences.json   # Bundled literary example sentences keyed by language and infinitive; also the results screen's reward for a right answer
│   ├── GapSentence.swift       # Sentences: GapSentence (a sentence with braced blanks, its cell, frame, answer, clause, and the levels that ask it), GapSentences (the bundle, drafts in debug builds only), QuizDraw.sentences, QuizScope.sentences
│   ├── GapSentences.json       # The authored sentences for Sentences, each with its verb, cell, German with {blanks}, English, and whether it has been reviewed; 736 of them, for the top 300 by frequency; checked by GapSentenceTests, reviewed and approved with scripts/gap_sentences.py
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
│   ├── KeyConjugations.swift   # Verb.keyConjugations (steht auf · stand auf · ist aufgestanden, always shown with no label), Verb.shareText, what the verb page's share button sends, and Stem.keyConjugation, one stem's, which the Mastery page shares
│   ├── KonjugierenTips.swift   # TipKit tips (e.g., ChangeLevelTip, shown in Settings after a quiz; the verb page's RedLettersTip and ScrollToBottomTip)
│   ├── LastQuizResult.swift    # The last quiz's results for the Quiz tab's hub: a kind (LastQuizResult.Kind(scope:)), a verb or collection key (an ablaut group's for its practice, alone or mixed), the level, counts, score, and date; kept by PracticeStore on the device and never sent
│   ├── LearnerVerbStore.swift  # Current.learnerVerbs: @Observable view of Shared/LearnerVerbs.swift that records opens and stars, saves each change to the App Group's defaults, and answers in verbs (starred, recent, My Verbs)
│   ├── LanguageModelService.swift      # Protocol for on-device AI error explanation and tutoring
│   ├── LanguageModelServiceDummy.swift # No-op stub for tests/unsupported devices
│   ├── LanguageModelServiceReal.swift  # FoundationModels implementation for AI tutoring
│   ├── MarkedConjugations.swift # The cells of a verb page that a search matched, which the page opens on, scrolls to, and marks; init?(text:on:) for a deeplink's match
│   ├── MatchedConjugation.swift # The conjugation a search result matched: its text, a finite part's particle, its cells' names for the row, and the marks it gives the verb page
│   ├── Mastery.swift           # The Mastery page's model: MasteryState (not practiced, learning, or mastered at the third box of the ladder, which the Speed Round shares), the level's weak patterns by conjugationgroup and person (the Futurs serving every verb), and the key conjugations each level asks of the 50 most frequent strong and mixed verbs, a row per strong reading; the counts the hub's row shows
│   ├── PracticeItemMapping.swift # Which PracticeItem a question exercises (a strong reading's key conjugation by the stem its cell is built on, otherwise its cell's pattern; the Futurs are patterns for every verb), the items a lookup schedules, the cell an item asks, and PracticeItem.Stem's tables and key cell
│   ├── PracticeSet.swift       # A custom quiz shared as a link or QR code: reads and writes konjugieren://quiz/set, carries the sharer's level while a part is left to it, turns My Verbs into a list of infinitives, its scope, share text, and summary; PracticeSetRequest, which World.handleURL sets
│   ├── PracticeStore.swift     # Current.practice: @Observable view of Shared/PracticeRecord.swift that records answers and lookups, offers the review card's verb, reviews and snoozes it, resets, keeps the last quiz's result (lastResult, recordResult), the Speed Round's best, the daily streak, and each level's best ranked score (levelBests, recordRankedScore), and saves to the App Group's defaults
│   ├── PersonNumber.swift      # 1s, 2s, 3s, 1p, 2p, 3p (pronouns live in ConjugationLabels.swift)
│   ├── Prefix.swift            # Separable/inseparable prefix enum ([Prefix] helpers live in Reading.swift)
│   ├── PrefixMeaning.swift     # Prefix meanings with PIE etymologies
│   ├── PrefixSection.swift     # Curated-vs-other heading for the prefix-grouped verb list
│   ├── Quiz.swift              # @Observable quiz state: rounds of ten and Ten More (continueSession), re-asks of missed questions, timer, scoring summed from the items; QuizItem grading (accepts, preferredSpelling), points, reasked(); submitRecognition for Name the Conjugation, which writes neither the record nor the error history; makeSentenceItem, graded in the sentence's clause; submitChoice and isHoldingChoice for a choice question, held after either answer for its reason, writing neither the record nor the error history; DEBUG fixtures (screenshot, grading, frames, corrections, slips, diagnoses, essentials, recognition, sentences, choices); QuizItem.answerFrame; QuizScope (its Kind, one case per mode carrying the mode's state, which alone decides ranking, mixing, and the correction's verb link; the verbs asked about, the readings its collection admits, a round's question count, the analytics source, whether it continues, whether its verbs are mixed, its pool): every verb, My Verbs, a collection, a custom quiz, a practice set, Review or My Mistakes, the modes, or three questions on a verb's page
│   ├── QuizAbandonment.swift   # The quizzes in progress, one entry per Quiz, so that the next launch can send abandonQuiz for one the app was left during
│   ├── QuizClock.swift         # Setting enum: hide (the default) or show the quiz's time
│   ├── QuizDueItems.swift      # QuizDraw.dueQuestions and mixing: up to three due practice items a default round asks, within its level and band, placed at random among the drawn questions; QuizDraw.recordQuestions, the item-to-question draw it shares with Review
│   ├── QuizRecordSession.swift # Review and Practice My Mistakes: QuizRecordSession (which record items each asks, its title and source), PracticeItem.isAskable, QuizDraw.sessionQuestions (up to ten items beyond the level's pool, a verb's key conjugations kept together, earlier rounds' items skipped), QuizScope.recordSession
│   ├── QuizDraw.swift          # Draws a quiz's questions from a pool (a level's, or a custom quiz's, whose restricted kinds fall back to every verb rather than vanish): a kind by weight, then a verb it admits, in a reading the scope admits, then a cell; for the default quiz, mixes the verbs (half strong, two core, one to three rare derivatives); AnyRandomNumberGenerator
│   ├── QuizLevel.swift         # Setting enum: Beginner, Elementary, Intermediate, Advanced (replaced QuizDifficulty's regular and ridiculous); each level's pool of QuizPoolEntry (a table's cells, the QuizVerbs it may ask, a weight) and the frequency band its default quiz draws from
│   ├── Recognition.swift       # Name the Conjugation: QuizScope.recognition, RecognitionQuestion (a prompt, every cell of every verb that writes it through the conjugation map and Verb.conjugations(matching:), the level's tables, grade, answerLines), RecognitionAnswer, RecognitionGrade (the parts to check, and the repair line), RecognitionPart, and RecognitionCell
│   ├── SpeedRound.swift        # The Speed Round: SpeedRound (60 seconds, opens at 5 mastered items, batches of 10, the mastered items the record holds), QuizScope.speedRound, and QuizDraw.speedRoundQuestions (each mastered item in turn, never twice running; a key conjugation asks any cell of its stem the level asks, or its own er cell; a pattern a fresh weak verb of the band) with speedRoundCells
│   ├── RelatedVerbs.swift      # Verb.root (the innermost base: anerkennen → kennen) and Verb.related(readingIndex:): verbs built on the same root, one verb per other root of the ablaut group (a verb counts if any reading is in it, so bewegen is on bieten's page), and the Families pages of a reading; the cached verbsByRoot and verbsByAblautGroup
│   ├── Region.swift            # Setting enum: the three standard varieties (north/austria/switzerland)
│   ├── ReviewCardHost.swift    # The verb list's review card, owned for the list's lifetime: chosen once per opening and again on each return from the background, hidden by suppression without being forgotten; revealing records a review and reports achievements, dismissing before a reveal snoozes, and each sends its signal
│   ├── ReviewCardSuppression.swift # Setting enum: off (the default) shows the review card, on hides it
│   ├── QuizErrorHistory.swift  # Persistence for recent quiz errors (up to 200), read by the Tutor's recommendations; cleared by Reset Practice
│   ├── SearchReport.swift      # SearchTracker (one search, first letter to its end, and the surface that opened the field for it) and SearchReport (the banded finishSearch parameters)
│   ├── SearchScope.swift       # Setting enum: infinitive-only vs. infinitive-and-translation search
│   ├── SortOrder.swift         # Enum for verb list sorting (alphabetical/frequency); [Verb].sorted(by:), whose alphabetical order is Verb.precedesAlphabetically's German one, used by the family pages, the collections, and the related-verb list
│   ├── StandardVariants.swift  # Duden's other standard conjugations of a cell (komme, sammle, kämst, stünde, sandte, erkennt an), accepted by the quiz but not shown on the verb page; rows of plans/pedagogy_phase1_variant_audit.md
│   ├── Sound.swift             # Sound effect definitions (guns, chimes, applause)
│   ├── TabSelection.swift      # TabView selection enum for programmatic tab switching
│   ├── ThirdPersonPronounGender.swift  # Setting enum: er/sie/es preference
│   ├── TutorChatHistory.swift  # Persistence for chat messages with the AI tutor
│   ├── Reading.swift           # One sense of a verb: gloss, family, auxiliary, prefixes; zuInfinitive (anzufangen), which the conjugation map's builder and search both read
│   ├── Verb.swift              # Lemma: frequency, icon, and an ordered list of readings; precedesAlphabetically, the one German comparator (abändern before abziehen); SearchKeys, the lowercased and folded infinitive and glosses made with the verb, and fold, the umlaut/digraph/ß folding
│   ├── VerbDestination.swift   # A verb page to push, with its analytics source and the cells a search marked
│   ├── VerbListMode.swift      # The verb list's picker (Alphabetical, Frequency, My Verbs)
│   ├── VerbCollection.swift    # Collections: the 100 most frequent verbs, the modal verbs, the verbs that take sein (by region), and each ablaut group (by the primary reading, as the Ablaut page lists them); admits(_:region:), the readings a collection's quiz may ask (the sein readings, a group's own); keys for `list/<key>` links, the share text, viewCollection, QuizScope.collection, and VerbCollectionProgress, the "3 of 6 looked up" that the bar, row, and card show
│   ├── VerbEssentials.swift    # Verb Essentials: QuizScope.verbEssentials (five strong or mixed verbs, three key conjugations each), QuizDraw.verbEssentialsStep and verbEssentialsSteps (over verbs, or over members whose readings are already chosen, as ablaut practice passes), Quiz.currentStepRange and essentialsRows (a step's rows: answered, current, pending, given), and Quiz.reaskPlacement (a missed blank returns after the next verb's step)
│   ├── VerbDraw.swift          # The widget's verb of the day and every random verb: the top 1,000 weighted toward strong and unprefixed verbs, and My Verbs every third day (random: one draw in three)
│   ├── VerbParser.swift        # XMLParser delegate for Verbs.xml, incl. the `in` marker grammar
│   ├── VerbVisit.swift         # VerbVisit (one viewVerbView/leaveVerbView pair)
│   ├── VerbVisitTracker.swift  # When a verb page's visits begin and end (on screen, in the foreground, no sheet over it), and the open its first visit records
│   ├── VerbSearch.swift        # The one search rule (list and shortcut picker): ranked match kinds including conjugations and stranded parts, and the edit-distance guess (infinitives and conjugations) for a failed search, whose core takes Sendable candidates so it can run off the main actor and stops when its task is cancelled
│   ├── VerbSearchModel.swift   # The verb list's search (@Observable): the text, its results, the guess found off the main actor and cancelled by the next edit, the keyboard selection, the folded row's state, the sad trombone once per failed search, and the finishSearch reports
│   ├── VerbLookup.swift        # What Look Up a Verb says about a word (an infinitive, a conjugation of one or more verbs, other matches, the guess) and where it then opens the app
│   ├── VerbSearchResults.swift # What a query shows: one list of entries, the folded row of separable verbs followed by its verbs, which show only while it is open; the top row's kind; and the guess (which the verb list asks for separately)
│   ├── Verbs.xml               # 3,572 verb definitions with markers and metadata
│   └── World.swift             # @Observable DI container with environment selection; handleURL parses the deeplink grammar (docs/feature_architecture.md § Deeplink System); SearchRequest
├── Utils/
│   ├── Analytics.swift         # Analytics protocol, event names, parameter keys, value vocabularies (AnalyticsSource, SearchMatchKind, …), and bands
│   ├── AnalyticsReal.swift     # TelemetryDeck implementation of Analytics
│   ├── AnalyticsSpy.swift      # Test spy that captures analytics signals
│   ├── FatalError.swift        # Protocol for testable fatal error handling
│   ├── FatalErrorReal.swift    # Production implementation (calls Swift.fatalError)
│   ├── FatalErrorSpy.swift     # Test implementation (captures error messages)
│   ├── GameCenter.swift        # Protocol for Game Center operations; QuizLevel.leaderboardID, the per-level leaderboard IDs (docs/game_center_setup.md)
│   ├── GameCenterReal.swift    # Real GKLocalPlayer authentication, per-level score submission, achievement progress (held until sign-in, only what has risen), and the leaderboard and achievement views
│   ├── GameCenterSpy.swift     # Records submissions, achievement reports, and what was shown, for tests
│   ├── GetterSetter.swift      # Protocol for key-value storage abstraction
│   ├── GetterSetterFake.swift  # In-memory dictionary implementation for tests
│   ├── GetterSetterReal.swift  # UserDefaults implementation of GetterSetter; standard defaults unless given others (the learner's verbs use the App Group's)
│   ├── GradientDivider.swift   # Shared gradient divider used by SettingsView and ResultsView
│   ├── HapticPlayer.swift      # Haptic feedback methods respecting audio-feedback setting
│   ├── KillSwitches.swift      # Compile-time screenshot kill switches: TipDisplay, OnboardingDisplay, TutorDisplay
│   ├── KonjugierenLogger.swift # os.Logger factory with app subsystem
│   ├── L.swift                 # Type-safe localization string accessors
│   ├── Layout.swift            # Spacing constants (8pt, 16pt, 24pt)
│   ├── LiveActivities.swift    # The LiveActivities protocol (Current.liveActivities) and LiveActivity, the handle a quiz or the game holds
│   ├── LiveActivitiesReal.swift  # Starts, updates, and ends quiz and game Live Activities through ActivityKit (was LiveActivityManager)
│   ├── LiveActivitiesSpy.swift   # Records started and ended activities under unit tests, which start no real ones
│   ├── MixedCaseAccessibility.swift  # VoiceOver labels for mixed-case ablaut strings
│   ├── Modifiers.swift         # Custom ViewModifiers (headingLabel, funButton, speakOnTap, copyOnLongPress, etc.)
│   ├── QRCode.swift            # A QR code made on the device with Core Image, for a practice set
│   ├── RatingsFetcher.swift    # Fetches app ratings from iTunes API
│   ├── ReminderSchedulerReal.swift # Schedules the daily reminders as local notifications, each carrying the daily session's deeplink, and ReminderNotificationDelegate, which opens a tapped one and shows none while the app is open
│   ├── ReminderSchedulerSpy.swift  # Records scheduled reminders and authorization requests under unit tests
│   ├── RegionalRendering.swift # ß→ss display transform + RegionalConjugator (region-aware wrapper over the region-free Conjugator, defaulting to main-clause conjugations: steht auf); search folding lives in VerbSearch
│   ├── ReviewPrompter.swift    # Protocol for review-prompting behavior
│   ├── ReviewPrompterDummy.swift   # No-op stub for tests
│   ├── ReviewPrompterReal.swift    # Real implementation prompting reviews at intervals
│   ├── Settings.swift          # @Observable settings with UserDefaults persistence
│   ├── ShareSheet.swift        # UIKit workaround: presents UIActivityViewController for the verb page's share button, anchored to the visible bar button on iPad, with an LPLinkMetadata header (ShareLink sends no tap from a toolbar and loses Copy with a SharePreview)
│   ├── SoundPlayer.swift       # Protocol for audio playback
│   ├── SpotlightIndex.swift    # Current.spotlightIndex: protocol for VerbSpotlight's three Spotlight calls (empty every index, delete verbs, index verbs)
│   ├── SpotlightIndexReal.swift    # The three calls through Core Spotlight's named index "verbs" and the default index
│   ├── SpotlightIndexSpy.swift     # Records the calls in order under unit tests, and can fail them
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
│   └── WidgetSnapshotWriter.swift  # Generates and persists the 10-day widget bundle from VerbDraw, keeping the verb the widget shows today; each day's quiz question is the first of that day's challenge at the learner's level
└── Views/
    ├── AblautPracticeCard.swift # An ablaut group's practice: Alone and Mixed, each a Verb Essentials sheet, a line naming the known groups Mixed adds or saying why it is closed, a Known seal, and for a single-verb group why it has no practice
    ├── AblautPracticeListView.swift # Pushed by the Quiz tab's Ablaut Groups row: the 58 groups with a pattern, the most used first, each expanding onto its AblautPracticeCard; defines AblautPracticeDestination
    ├── AnswerFrameView.swift   # Draws an AnswerFrame on one line with a text field per blank, or a sentence word by word in a FlowLayout; Return fills the next empty blank, then submits; the letter keys follow the cursor; each field's VoiceOver label reads the whole frame, after an optional spokenPrefix
    ├── ChoiceQuestionView.swift # A choice question's card body: "Which fits here?", the two sentences as buttons with their conjugations in bold and their conjugationgroups named, the English, and once chosen, the right one green, a wrong one red, the reason, and Continue
    ├── CustomQuizView.swift    # Pushed from the Quiz tab's Custom segment: CustomQuizEditor (conjugationgroup and verb-set rows, each with "Set by Your Level"), CustomQuizAblautGroupList, CustomQuizDestination, and CustomQuizSummaryCard (shared with a practice set's sheet)
    ├── ErrorExplainerView.swift # AI-generated explanations for conjugation errors
    ├── FailedSearchHelp.swift  # What a failed search shows below the verb list's field: "No verbs found", the guess once VerbSearchModel finds one, and the mail link asking for the verb, which copies the address and says so when no mail app opens it
    ├── FamilyBrowseView.swift  # The Families tab: a Collections section (rows; three cards on iPad) above the verb families, prefixes, and ablaut groups; opens a `list/<key>` link's collection
    ├── FlowLayout.swift        # Lays children out in rows that wrap, optionally centered; offers each child the row's width, so a chip wider than a row wraps its text; used by the Related Verbs card, the Quiz tab's chips, the dot row, corrections, results, Mastery, and the sentence frame
    ├── FamilyDetailView.swift  # Detail view for a single family/prefix/ablaut category; an Alphabetical/Frequency control orders the verbs within each section; an expanded ablaut group starts with its VerbCollectionBar and its AblautPracticeCard and checks the verbs looked up, and a link opens the page with its group expanded
    ├── GameView.swift          # Space-invaders-like verb conjugation game
    ├── GermanLetterKeyRow.swift # ä ö ü ß keys shown above the keyboard, for the search field and the quiz's answer frame (a keyboard toolbar there, inserting at the cursor of the focused blank)
    ├── InfoBrowseView.swift    # List of Info articles (dedication, history, etc.)
    ├── InfoView.swift          # Detail view for a single Info article
    ├── MainTabView.swift       # Root TabView with five tabs
    ├── MasteryView.swift       # Pushed by the Quiz tab's Mastery row: a legend, the patterns as cards with a mark under each person, then the strong and mixed verbs with a mark beside each key conjugation; shows only, since a verb page opened from it would count as a lookup and send the verb back to the first box; defines MasteryDestination
    ├── MyVerbsList.swift       # The verb list's My Verbs: a List of starred, then recent unstarred, verbs, each deletable by a left swipe (a starred one after a confirmation alert), and Clear for the recent ones; neither costs a collection's progress
    ├── OnboardingView.swift    # Multi-page onboarding shown on first launch
    ├── PracticeSetView.swift   # A shared practice set's sheet (what it asks, Start, Keep as My Custom Quiz, or "Practice Set Not Found") and PracticeSetQRView, the full-screen code a teacher projects
    ├── QuizCorrectionView.swift # The held correction of a wrong quiz answer: both answers with the differing letters marked (for Name the Conjugation, the answer part by part with the wrong parts in red, and every right answer), the completed sentence for a Sentences question, links to the verb's page and its ablaut group or family, and Continue; defines the isBeneathQuiz environment value
    ├── QuizView.swift          # Quiz gameplay: questions, timer, answer input; the Quiz tab's practice hub (a yellow symbol for the scope, its name and description, the All Verbs/My Verbs/Custom picker, tiles for questions, minutes, and the level as a menu, My Verbs' verbs as chips, the custom quiz's summary with Choose or Change and the Share menu of link or QR code, Start, then From Your Practice with Review, My Mistakes, Mastery (pushing MasteryView), and LastQuizResultRow, then Exercises with Verb Essentials, Ablaut Groups, and Name the Conjugation, each row a QuizHubRow, and a small View Leaderboard button while signed in to Game Center, scaled up on iPad); with a sheetScope, a quiz in a sheet (QuizSheet: "Test me on this verb" or a collection's quiz), which starts as it appears and closes when the quiz ends; its own navigation stack pushes the pages a held correction links to, over the waiting quiz, and the hub's Ablaut Groups row pushes AblautPracticeListView; isBeneathQuiz is set only while a quiz is in progress
    ├── RecognitionChoicesView.swift # Name the Conjugation's card parts: RecognitionPromptView (the conjugation, ablaut in red) and RecognitionChoicesView (the level's conjugationgroups, then the chosen table's persons, as chips)
    ├── RelatedVerbsView.swift  # The verb page's Related Verbs card (chips in a FlowLayout), RelatedVerbListView (every verb of one relation), RelatedVerbListDestination, whose relation gives the caption in the user's region's spelling, and VerbPagePush, the environment action by which a verb page pushes onto whichever tab's stack shows it
    ├── ResultsView.swift       # Modal showing quiz results, each verb's first right row offering its literary example sentence, and Ten More, or for Verb Essentials Five More Verbs, or for an ablaut group's practice Another Round (and no level line); the leaderboard button is on the Quiz tab's hub, not here
    ├── ReviewCardHostView.swift # Places the card ReviewCardHost chose above the verb list, narrower on iPad, and signals its first showing
    ├── ReviewCardView.swift    # The review card above the verb list: a strong verb looked up or practiced days ago, one reading's key conjugations hidden until a tap reveals them; a second tap opens the page, and ✕ dismisses
    ├── RichTextView.swift      # Renders RichTextBlock content with styling
    ├── SettingsView.swift      # Settings UI with segmented pickers
    ├── SortOrderPicker.swift   # The Frequency/Alphabetical segmented picker of the family pages, the collection page, and the related-verb list
    ├── TutorTestView.swift     # Debug view for testing the AI tutor
    ├── TutorView.swift         # Chat interface for the AI tutor with sample queries
    ├── VerbBrowseView.swift    # Searchable, sortable list of all verbs; the letter row replaces the sort picker while search is focused; a result found by a conjugation says which cells matched, and separable verbs in which the query is a stranded part fold into one row (a grid section on iPad); a failed search shows FailedSearchHelp; the sort picker is disabled while the field has text; Return and the arrow keys open and move through results on iPad and Mac; the focused, empty field shows the recent verbs, and the picker's My Verbs shows MyVerbsList; ReviewCardHostView shows ReviewCardHost's card above the list. Also holds VerbRowView, VerbGridCell, and SeparableVerbsRow
    ├── VerbCollectionView.swift # A featured collection's page; VerbCollectionBar ("3 of 100 looked up", a progress bar, Quiz, and Share), which the expanded ablaut groups share and which asks its collection for its verbs; the Families tab's VerbCollectionRow and VerbCollectionCard, all three reading VerbCollectionProgress
    ├── VerbEssentialsRowView.swift # Verb Essentials' rows other than the answer field's (answered with its state's icon, given, pending), VerbEssentialsRowLabel (the row's conjugationgroup), and VerbEssentialsFrameLead (er, or sie (3s))
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
├── QuizWidget.swift            # Timeline-based widget for daily quiz questions, the first of each day's challenge, unpaged by Next
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
├── OpenQuizIntent.swift            # Shared intent to open quiz via deeplink (a PendingDeeplinkIntent)
├── OpenRandomVerbControlIntent.swift  # The Random Verb control's action: OpenRandomVerbIntent with source=control, hidden from Shortcuts
├── OpenRandomVerbIntent.swift      # Shared intent to open random verb via deeplink (the Random Verb shortcut)
├── OpenVerbSearchIntent.swift      # The Find a Verb control's action: konjugieren://search?source=control, hidden from Shortcuts
├── PendingDeeplinkIntent.swift     # The four Open… intents' one perform(): leaves a WidgetDeeplink in the App Group's defaults, which the app follows when it becomes active
├── LearnerVerbs.swift              # The learner's verbs (each verb opened, with dates and a count, and each verb starred), keyed by infinitive and stored as JSON in the App Group's defaults, which the widget does not read; a first open is collection progress and a last open is Recent; new fields must be optional
├── PracticeRecord.swift            # The practice record: PracticeItem (a strong verb's key conjugation or a weak pattern, with a permanent string key) and a ReviewSchedule, last answer, and last lookup per item, stored as JSON in the App Group's defaults; never sent
├── QuizActivityAttributes.swift    # ActivityKit model for quiz live activity
├── ReviewSchedule.swift            # The practice record's Leitner ladder (1, 3, 7, 14, 30 days): a box and a due date per item, started by a lookup or a wrong answer, raised by a review or a right answer when due, postponed a day by a snooze
├── WidgetDeeplink.swift            # The links the widgets and the Shared/ intents hand the app, with their `source` spelled once, since neither can see AnalyticsSource
├── WidgetConstants.swift           # Constants for widget app-group container, storage keys, day count, and pinned Gregorian calendar
├── WidgetQuizShuffle.swift         # Process-stable (FNV-1a seeded) answer shuffle + SeededRNG, shared by widget and tests
└── WidgetSnapshot.swift            # Data models for serialized widget state, incl. WidgetSnapshotBundle (N-day array, paging, the snapshot displayed at a moment, and the last day each verb of My Verbs was given, which only the app reads)

KonjugierenTests/
├── CLAUDE.md                   # Lazily loaded Claude Code guidance: Swift Testing conventions for this target
├── .swiftlint.yml              # Nested SwiftLint config merged over the root one: allows force_cast and force_try in tests
├── Models/
│   ├── AnswerDiagnosisTests.swift  # Each diagnosis for real verbs, undiagnosable answers getting none, the lines, and the repair sharing the slip's one more attempt
│   ├── AnswerDifferenceTests.swift # The held correction's marking: a missing umlaut, a missing or extra letter, a swap, case as no difference, the nearer word order, a dropped pronoun
│   ├── AnswerFrameTests.swift      # The quiz's answer frame: every cell of six verbs takes its right answer through its frame, the frame per kind of cell, readings, Return
│   ├── AnswerSlipTests.swift       # One more try: what is a slip and what is another cell (kommt for kommst, musstest, fahrt), half points, one attempt at most, the separate count
│   ├── AnswerSpellingTests.swift   # Quiz grading: the report's three simulator cases, leading pronouns by person, digraphs both ways, the spelling shown beside the checkmark by region and clause
│   ├── BrowseableFamilyTests.swift # The Families pages: every prefixed verb in exactly one section, each section in German order, the ablaut groups listed and described
│   ├── ConjugationMapTests.swift   # Bundled map equals a fresh build (staleness), finds the verb of ≥99% of example sentences (Scan 2 of the defect plan), anchors, format round-trip
│   ├── ConjugationMatchTests.swift # Verb.conjugations(matching:): clauses, regions, finite parts, readings
│   ├── ConjugationTableTests.swift # The verb page's table order, cells, articles, and second names
│   ├── ConjugationSearchTests.swift # Search by conjugation: the ideas doc's conjugation queries, stranded parts and the folded row, particles, compounds, folding, adjective endings, cell names, marks
│   ├── ConjugationgroupTests.swift # Conjugationgroup.ending(family:) ending-table tests
│   ├── ChoiceQuestionTests.swift # Choice questions: the machine check over every bundled item (well formed, both sentences the conjugator's conjugations in every region, the item's level asks its answer, every reason names its conjugationgroups, every contrast and level covered), the two sentences and the prompt's order, levels and drafts, the draw and its position; nested in QuizTests, one choice a default round from Elementary up and none elsewhere, a right choice held with its reason and nothing recorded, a wrong one held and not re-asked, Ten More's unasked choice, and a ranked round still out of 100
│   ├── CustomQuizTests.swift   # The custom quiz's stored form and keys, its pool at each level, the restricted-table fallback, its scope (never ranked, mixed only for bands), the setting's persistence; nested in QuizTests, sessions that ask only the choice, post no score, and send source custom
│   ├── DailyChallengeTests.swift # The seed pinned, days round-tripped, the same key drawing the same challenge, days and levels differing, each level's five balanced questions, the result and the agreed share text, and the quiz widget's question agreeing; nested in QuizTests, the same five whatever the device, a result kept once and unranked, no re-ask, a quit keeping nothing, the store's limit and persistence, and the share signal
│   ├── DailySessionTests.swift # The daily streak across days (repair by two sessions, a failed repair, two missed days, a 25-hour day, pruning, the bands, the store across a launch and a reset), the draw (due items first, ten due, one beyond the level), the scope, and the reminder plan (each day at the time, today's past or done, the repair line, what will be due); nested in QuizTests, a session at the level, the streak extended and sent, a quit not counting, a repair across days, the reminder rescheduled, and the reminder as source
│   ├── ConjugatorTests.swift   # Comprehensive conjugation tests (~50 test functions), incl. error paths
│   ├── LearnerVerbsTests.swift # The learner's verbs: opens, stars, recents (unstarred ones filling to the limit), My Verbs, removal and clearing that keep first opens, Reset Practice's forgetting of them, JSON round trip and old records' decoding, and the store's reload and collection progress
│   ├── MasteryTests.swift      # The Mastery page's model: the state by box, each level's pattern count and which conjugationgroups have patterns, the Futurs serving every verb, the 50 core verbs, the stems each level asks, a verb mastered when every asked stem in every strong reading is, and answers landing where the item mapping sends them
│   ├── KeyConjugationsTests.swift # Key conjugations per reading and region, the share text, and what a long press copies
│   ├── InfoTests.swift         # Info articles: a heading and text per article in each language, every ‡link‡ opens an article or a verb (both catalogs), stable keys
│   ├── GameStateTests.swift    # Game-logic tests: damage invulnerability, robot-mechanic clearing, game-over/wave transitions, snapshot round-trip
│   ├── PracticeSetTests.swift  # Practice sets: the pinned link, every table, verb set, list, and level round-tripped, links that name nothing, My Verbs shared as a capped list, the QR code read back as the link; extends DeeplinkTests (the quiz/set route) and nests sessions in QuizTests (the set's level, no score)
│   ├── PersonNumberTests.swift # Pronoun and sie-disambiguation tests
│   ├── PracticeItemTests.swift # Which item each question exercises: a strong verb's stems by table, the Futurs as patterns, every weak, separable, inseparable, and -ieren verb sharing one pattern per cell, prefixed strong verbs' own items, hängen's two readings, pinned keys, and items asking their own cell back
│   ├── PracticeRecordTests.swift # The record and store: climbing when due, starting over on a miss, due order, lookups and the card's review and snooze, the card's choice and caption, weak patterns never on the card, a relaunch, and a reset that stays
│   ├── QuizErrorHistoryTests.swift # Quiz error persistence tests, including Reset Practice's clear
│   ├── QuizPracticeTests.swift # Nested in QuizTests: answers recorded as given and kept on quit, every scope writing, due items limited to the level and band, a default round mixing in at most three, scoped quizzes mixing in none
│   ├── QuizRecordSessionTests.swift # Review and My Mistakes: missed items most recent first, days to the next due item, sessions beyond the level's pool and band, a verb's key conjugations together, excluded and unaskable items, never ranked; nested in QuizTests, sessions of ten then the rest, a short Review, an empty record, a mistake leaving once right and not re-asked in Ten More, and signals without counts
│   ├── QuizRoundTests.swift    # Nested in QuizTests: re-ask placement and limits, half points for a re-ask, Ten More continuing the session, completeQuiz's questionCount, quitQuiz's duration bands, the hidden clock; QuizAbandonment's records and its launch report
│   ├── QuizHubTests.swift      # The hub's last result: its pinned stored form, a round trip, each scope's kind, titles, the store keeping it across a launch, and Reset forgetting it; nested in QuizTests, a finished quiz keeping its result, Ten More replacing it, a quit keeping nothing, a record session with no level, and a verb page's quiz naming its verb
│   ├── QuizScopeTests.swift    # Nested in QuizTests: every scope the app starts, only the default ranked or mixing anything in, only Test Me hiding the verb link, each remembered as its kind, a link's source deciding nothing, the readings each collection admits, and the sein collection's quiz never asking a haben reading
│   ├── QuizLeaderboardTests.swift # Nested in QuizTests: each level's leaderboard ID, a ranked session posting its first round to its level's board (second attempts counted, re-asks not), Ten More and scoped quizzes posting nothing
│   ├── QuizLevelTests.swift    # Each level's tables and cells, the restricted cells' verbs, weighted shares under a fixed seed, and short quizzes' distinct cells
│   ├── QuizVerbMixTests.swift  # The default quiz's verbs over 40 seeds per level: each level's band, half strong, two core verbs, a prefixed verb, one to three rare derivatives, and no provisional count in a band
│   ├── QuizTests.swift         # Quiz logic, scoring, and timer pause/resume tests; scopes (My Verbs, three questions on a verb page, ranking, the source on start, quit, and completion)
│   ├── StandardVariantsTests.swift # Every row Josh accepted in the Phase 1 variant audit, and the ones he rejected
│   ├── AchievementTests.swift  # The achievements: each permanent ID, the points within Apple's limits, the pillars, each level's patterns earning its own and the lower levels', one short, learning counting for nothing, all three key conjugations needed, each core-verb step, both of fahren's readings; nested in QuizTests, the answer that reaches a milestone reported at the results, a quit reporting, and the per-level bests (new, not beaten, replaced, per level, none after Ten More or for an unranked quiz, across a launch and a reset, none for 0)
│   ├── AblautPracticeTests.swift # Ablaut-group practice: a group's ten most frequent verbs and their readings of the group, the 18 single-verb groups, known at half of the key conjugations (either reading, lookups and wrong answers not counting), mix partners, the draws (alone; mixed three and two, partners one group at a time, a short side, unasked verbs first), the scopes, and the last result; nested in QuizTests, a group practiced alone becoming known and joining another's mix, another round, and the signals
│   ├── ReviewCardHostTests.swift # The review card's host: one choice per opening, a new one only after the background, a reveal recording one review and one signal, a dismissal snoozing until tomorrow, the destination, and suppression hiding the card without forgetting it
│   ├── SearchReportTests.swift # SearchTracker lifecycle, finishSearch parameters (an ended search's from the results shown, folded row included), and the no-typed-text guarantee
│   ├── ReviewScheduleTests.swift # The ladder alone: due the next morning, the boxes, snoozes, a quiz answer moving up only when due, a miss starting over, a new item's first answer
│   ├── RelatedVerbsTests.swift # Verb.root through nested prefixes, verbs built on a root, ablaut relatives (one per root), family pages, per-reading relations, a second reading's ablaut group, the cached ablaut index, captions in Swiss spelling, [Verb].sorted(by:) in German order
│   ├── GapSentenceTests.swift  # Sentences: the machine check over every bundled sentence (well formed, each blank the conjugator's conjugation in every region, asked at some level, the Imperativ's pronoun given, at least three sentences for each of the top 100 verbs and two for each of the next 200), frames and tokens, the clause and grading in it, each level's sentences, drafts in release builds, the draw, and the scope; nested in QuizTests, a round of the level's sentences, an answer recorded, a re-ask keeping its sentence, and the signals, last result, and Ten More
│   ├── RecognitionTests.swift  # Name the Conjugation: the cells a prompt accepts (käme, fuhr's two readings, kam an alone, weiß of wissen and weißen, kommen's four, offered tables only, compounds, participles), grading in any spelling, the parts a grade names, the repair lines, the correction's lines, the chips' persons, and the scope; nested in QuizTests, a round of the level's band and tables, no record written, a repair for half points, a held correction and re-ask, and the signals, last result, and Ten More
│   ├── SpeedRoundTests.swift   # The Speed Round: mastered means the third box, unaskable items left out, only mastered items asked, each in turn and never twice running across batches, one item repeated, none asked from nothing, a pattern's weak verbs, a key conjugation's stem cells by level, the scope, and the best across a launch and a reset; nested in QuizTests, nothing mastered starting nothing, a miss moving on at once with its answer shown, a slip as a miss, the record and error history untouched, batches drawn as answered, sixty seconds ending the round with the best kept, no score or counts sent, and a pause stopping the clock
│   ├── RefusalDetectionTests.swift # Tutor refusal-phrase detection, incl. the "null" exact-match false-positive guard
│   ├── VerbCollectionTests.swift # Collections: keys, members (modals, the top 100, sein by region), the ablaut group's title in Swiss spelling, share text, the quiz scope, the store's count of verbs looked up, VerbCollectionProgress
│   ├── VerbEssentialsTests.swift # Verb Essentials: a step's cells and items, each blank's answers for separable, inseparable, sein-taking, and mixed verbs, the draw (distinct strong verbs, weak verbs never, a mixed-reading verb's strong reading, asked verbs last), the scope, and re-ask placement; nested in QuizTests, a round's steps and rows, each blank recorded alone, a re-ask step with its other rows given, a diagnosed blank's second try, Five More's new verbs, and signals, the last result, and no score
│   ├── VerbDrawTests.swift     # Frequency bands, and VerbDraw: weights, My Verbs every third day and in turn, even as the list grows, stability through a day, the favored share
│   ├── VerbLookupTests.swift   # Look Up a Verb: what it says about infinitives, conjugations, ambiguous and unknown words, and where it opens the app
│   ├── VerbSearchModelTests.swift # The verb list's search flow: typing, clearing, a guess that arrives, one cancelled by the next letter, opening a result or the guess, requests, the scope, the trombone, and the report each sends
│   ├── VerbSearchTests.swift   # VerbSearch: folding, match-kind ranking, the ideas doc's failed queries, list/picker agreement, the failed-search guess, its cancellation, and the limited edit distance
│   ├── VerbSpotlightTests.swift # Spotlight fields: gloss phrases, conjugations with particles, key conjugations per reading and region; and indexing's calls, in order, through SpotlightIndexSpy
│   ├── VerbTests.swift         # Verb.stamm and endingIsValid tests
│   ├── VerbVisitTests.swift    # VerbVisit: deepest section and banded dwell
│   └── VerbVisitTrackerTests.swift # VerbVisitTracker: sheets, scene phases, and reappearance pair each view with one leave
├── Utils/
│   ├── AnalyticsTests.swift    # Analytics bands, section order, and the match-kind mapping
│   ├── DeeplinkTests.swift     # The deeplink grammar: every route, the `source` and `match` query items, the search route, stable-key articles, every WidgetDeeplink, the control and quick-action links, a link to nothing leaving a pending search, and Handoff and the Open Verb shortcut going through the route
│   ├── MixedCaseAccessibilityTests.swift  # VoiceOver label generation tests
│   ├── MixedCaseSegmenterTests.swift  # Ablaut segmentation tests (empty/all-regular/all-irregular/formal Sie)
│   ├── SettingsTests.swift     # Settings persistence and default-value tests
│   ├── StringExtensionsTests.swift  # Rich text parsing and error handling tests
│   ├── TimeFormatterTests.swift     # Time formatting utility tests
│   ├── URLExtensionTests.swift      # mailto: percent-encoding and the App Store link
│   ├── VerbClassificationTests.swift  # Harness: stage B of classify-and-verify, searching for the Verbs.xml encoding that reproduces Wiktionary. Gated on TEST_RUNNER_KONJUGIEREN_CLASSIFY_IN
│   ├── VerbExportTests.swift        # Harness: every verb's page as JSON, for scripts/generate_verb_pdf.py. Gated on TEST_RUNNER_KONJUGIEREN_EXPORT_OUT (optional TEST_RUNNER_KONJUGIEREN_EXPORT_ONLY)
│   └── WidgetSnapshotTests.swift    # Widget snapshot/bundle generation, per-day paging math, My Verbs turns carried from bundle to bundle, a same-day rewrite, an older bundle's decoding, and process-stable answer-shuffle tests
└── Views/
    ├── FlowLayoutTests.swift   # FlowLayout, measured in a UIHostingController: a child wider than a row wraps, and children that fit share a row
    └── VerbBrowseViewTests.swift    # Arrow-key selection arithmetic (VerbSearchModel's) and grid sections for the verb list

docs/
├── adding_verbs.md                            # Verb-addition guide: XML formats, ablaut system, lessons learned
├── blog_notes.md                              # Work journal: dated narrative notes for future blog posts and session memory
├── browse_and_verb_ideas.md                   # Findings and ranked ideas for the verb list and verb page (2026-11-10): where a lookup fails today, what other tools do, ideas with basis, effort, signal, and carry-over to Conjuguer and Conjugar, the pieces shared with the quiz track, signals to add, and defects found while checking
├── bug_report_gitcommitsha.md                 # Bug report draft: Claude Code `plugin update` doesn't refresh `gitCommitSha` in `installed_plugins.json`
├── bug_report_grep_silent_truncation.md       # Bug report draft (filed as anthropics/claude-code #56751): long-line `grep` matches silently disappear from Bash tool output
├── claude_code_skill_recommendations.md       # Curated third-party Claude Code skills worth installing for Konjugieren work
├── cloud_llm_tier.md                          # Memo on a paid cloud tier for the Tutor through the Anthropic API; flagged for re-evaluation after WWDC2026 (see wwdc2026_platforms_sotu.md)
├── code_audit.md                              # Full-codebase audit (June 2026): bugs, duplication, dead code, smells, test gaps, phased implementation order
├── code_review_recommendations.md             # Second full-codebase review (July 2026): ranked recommendations across game, widget, deeplink, and concurrency findings, with a phased implementation sequence
├── conjugationgroup_frequency.md              # How often each conjugationgroup occurs in the corpus: method, results, and the verb page's resulting order
├── conjugationgroup_text.md                   # Template and guidelines for conjugationgroup articles
├── control_center_controls.md                 # iOS 18+ ControlWidget constraints on `openAppWhenRun`/`OpenURLIntent` and the Shared/ dual-target pattern
├── description.md                             # App Store description, English and German. One of the four cache files whose counts scripts/check_docs.py asserts
├── dwds_permission_email.md                   # Draft permission request to dwds@bbaw.de for frequency-API use (§ 44b UrhG reservation)
├── dwds_reply_email.md                        # Josh's reply to BBAW answering the permission grant for the DWDS frequency data, sent 2026-08-30; companion to dwds_permission_email.md
├── emoji_assets.md                            # Why some emoji ship as PNG assets (iOS 26 emoji-rendering workaround)
├── english_writing_style.md                   # English writing conventions consulted by Claude when editing localization strings, docs, and comments
├── etymologies.md                             # Etymology pipeline documentation
├── etymology_pipeline.md                      # Etymology *translation* pipeline: EN→DE batch workflow and coverage check. Lived at the repo root until 2026-07-20, where two sessions searching `docs/` failed to find it and one concluded it had never existed
├── example_sentence_pipeline.md               # Pipeline for generating literary example sentences
├── example_sentence_sources.md                # Source texts for example sentences
├── feature_architecture.md                    # Architecture details: Quiz, Game Center, Info, Deeplink systems, and Analytics (signals and the `source` vocabulary)
├── frequencies.txt                            # Verb frequency data
├── game_center_setup.md                       # The Game Center configuration: leaderboard IDs, names, and settings, how to create one in App Store Connect, and what to do on release day
├── grep_gotchas.md                            # Silent-truncation failure mode that bites `grep` on long-line files (xcstrings, Markdown); detection via `grep -c`
├── history_corrections.md                     # **The verb-history fact-check's deliverable.** 27 findings with replacement prose in both languages, 9 span corrections, agent H's 16 internal-consistency items, 4 thin confirmations, and the coverage reconciliation. Applied to both extracts on 2026-07-29; its "What was applied and what was not" section records the nine declines. Synced to the catalog on 2026-07-29
├── line_counts.md                             # Line count report for the project
├── line_counts_howto.md                       # How to generate line count reports
├── linkedin_launch_post.txt                   # LinkedIn post for app launch
├── localization.md                            # Word counts of the app's localized text, English and German, by file, set beside the lengths of well-known books
├── luther_section.md                          # **The Luther section's deliverable.** Why the verb-history essay's nineteenth heading says what it says: verdicts on the four briefed candidates (two shipped, one refuted by the Zurich Bible's tense statistics, one unsupported because the Satzklammer was already formed), the four things cut from the draft including `ketzerisches e`, and two traps worth carrying forward
├── nomination.md                              # App Store featuring nomination — Description, Helpful Details, and Supplemental Materials slots
├── on_device_tool_design.md                   # Lessons from implementing Foundation Models Tool conformances
├── pdf.md                                     # PDF export documentation
├── pedagogy_research.md                       # Research findings on the quiz's pedagogy (2026-11-10): what the quiz does, what a played session and the telemetry show, what the literature supports, and tiered suggestions; every claim labeled by how it was verified. The report that plans/pedagogy_implementation.md builds. Was plans/pedagogy.md until 2026-11-16
├── peterborough_chronicle_reading_list.md     # Reading list for the Peterborough Chronicle and the Old-to-Middle English transition
├── platform_features.md                       # Plan for platform-specific features
├── post_release_features.md                   # Post-release feature backlog
├── privacy_policy.txt                         # The deployed privacy policy, English and German, describing what the shipped app sends; lines for unreleased work wait in privacy_policy_pending.md
├── privacy_policy_pending.md                  # Privacy-policy lines (English and German) for analytics built on main, to splice into privacy_policy.txt on release day
├── project_structure.md                       # This file — annotated directory tree
├── query_rewriting_exploration.md             # Query rewriting research for tutor feature
├── release.md                                 # What the 2027 release must do: before submitting, on release day, and afterward (CLAUDE.md § No Release Before 2027 points here)
├── release_notes.txt                          # App Store release notes by version, English and German
├── reply_about_wiktionary_defects.txt         # Josh's reply to a reader who asked how the app records its deliberate disagreements with Wiktionary (verbdata/wiktionary_defects.json); the recipient's name is redacted
├── roadmap.md                                 # START HERE for verb-corpus expansion: the sequence of plans, what gates what
├── screenshot_playbook.md                     # App Store screenshot workflow: prerequisites, driver flags, the 12 workarounds, recovery guidance
├── screenshots/                               # Captured App Store screenshots produced by `scripts/take_screenshots.sh` (gitignored)
├── telemetry_usage.md                         # Usage snapshot (2026-11-10) for Konjugieren, Conjuguer, Conjugar from TelemetryDeck and App Store Connect, the China-device reconciliation, and the recipes and gotchas for refreshing both
├── terminology.md                             # Conjugationgroup definitions, tense/mood/voice distinctions
├── tutor_recording.md                         # Playbook for recording the short Tutor walkthrough that the App Store nomination lists as supplemental material
├── tutor_test_queries.txt                     # Test queries for the AI tutor
├── ui_audit.md                                # UI audit notes and findings (Round One; implemented in commit 657bb4f)
├── ui_audit_2.md                              # UI audit Round Two — post-657bb4f suggestions; self-contained for future implementation sessions
├── usage.md                                   # Reading the five-hour window from inside a session: the zero-token `/usage` probe, why the calling session pays, and what a headless child costs
├── vanilla_build_and_test.md                  # Raw xcodebuild commands for opting out of the ios-build-verify dependency
├── verb_browse_review.md                      # Code review (2026-11-25) of what plans/browse_and_verb_implementation.md built: correctness, performance, privacy, doc gaps, duplication, smells, elegance, and tests, each finding labelled by how it was verified, with a suggested order of work; nothing fixed there. plans/verb_browse_fixes.md is the plan to fix them
├── verb_classification.md                     # The classify-and-verify pipeline: design, invocation, and what it found
├── verb_history.txt                           # Editable English source of Info.verbHistoryText, header plus body; sync with `scripts/sync_verb_history.py`
├── verb_history_claims.md                     # Claim inventory for the verb-history fact-check: 111 numbered claims, one owning cluster each
├── verb_history_de.txt                        # The German translation of the same, synced with `--lang de`
├── verb_history_phase0.md                     # Phase 0 of the fact-check: what was patched from Conjugar's corrections, what diverged, and what the patch could not reach
├── verb_history_phase1.md                     # Phase 1 of the fact-check: a verdict for all 111 inventory rows, 31 findings with replacement prose, and agent H's internal-consistency report
├── verb_history_phase2.md                     # Phase 2 of the fact-check: adversarial disposition of all 31 findings, replacement prose for the 27 survivors, and the coverage audit. Phase 4's input
├── verb_history_phase2_reports/               # The 31 skeptic reports, the 19 second opinions, the coverage audit, and final.json
├── verb_history_phase3.md                     # Phase 3 of the fact-check: the essay's 27 `$…$` spans against the app's own conjugation output, markup integrity, and four findings against the app rather than the essay, one of them a shipped `sollen` bug since fixed. Phase 4's other input; the deliverable is `history_corrections.md`
├── verb_sources.md                            # Verb-corpus expansion research (2026-07): Wiktionary/kaikki/Wikidata/DWDS measurements, licenses, extraction pipeline
├── video_script.md                            # App Store preview script with bilingual captions and 30-second timing math
├── voiceover.md                               # VoiceOver pronunciation patterns and per-screen strategy
├── whats_new.md                               # App Store "What's New" copy by version, English and German
├── wwdc2026_platforms_sotu.md                 # WWDC2026 Platforms State of the Union announcements relevant to Konjugieren; reshapes the cloud-llm-tier decision
├── wwdc2026_platforms_sotu_transcript.txt     # Verbatim WWDC2026 session-102 transcript (Apple copyrighted; gitignored)
├── wwdc2026_whats_new_in_swift.md             # WWDC2026 "What's New in Swift" (session 262) announcements relevant to Konjugieren; gated by the Apple-silicon/Xcode-27 toolchain move
├── wwdc2026_whats_new_in_swift_transcript.txt # Verbatim WWDC2026 session-262 transcript (Apple copyrighted; gitignored)
├── wwdc2026_whats_new_swiftui.md              # WWDC2026 "What's new in SwiftUI" announcements relevant to Konjugieren; SwiftUI companion to the Platforms SOTU report
└── wwdc2026_whats_new_swiftui_transcript.txt  # Verbatim WWDC2026 session-269 transcript (Apple copyrighted; gitignored)

plans/                         # What Claude wrote to get another session to do something: plans, orchestrator plans, subagent briefs, and resume prompts. Josh's own prompts are in prompts/, and Claude's research and other informational output is in docs/
├── bratwurst_icon.md                       # Three prompts for an image generator, for a bratwurst icon that matches the game's illustrated icons, with a verification checklist and asset-integration steps. Was docs/bratwurst-icon-prompts.md until 2026-11-16
├── browse_and_verb_ideation.md             # Brief for the research-and-ideation session on the Browse and Verb screens, written in parallel with the quiz research in docs/pedagogy_research.md; carried out 2026-11-10, with the findings in docs/browse_and_verb_ideas.md
├── browse_and_verb_implementation.md       # Multi-session plan, in 16 phases plus a closing, for building the ideas Josh accepted in docs/browse_and_verb_ideas.md; each session marks its phase done and notes how it differed
├── choice_questions_batch_1.md             # Review sheet for the first 40 choice items (Elementary 12, Intermediate 18, Advanced 10), reviewed and approved by Josh on 2026-11-15, generated by scripts/choice_questions.py review
├── cognate_precision.md                    # Plan (2026-07-26) for auditing "cognate with" across the etymologies: cognates versus co-borrowings, how small the real population is, and why find-and-replace would damage entries that are correct. Second of the three style plans
├── dual_auxiliary.md                       # Plan for the haben/sein enhancement pass: readings that take different auxiliaries, and the double-prefix grammar. Executed 2026-07-19, with its three deviations recorded at the top
├── em_dash_sweep.md                        # Plan (2026-07-26) for sweeping em dashes from the shipped corpus to honor docs/english_writing_style.md: the counts, what must not be touched, and why sed is the wrong tool. First of the three style plans; executed in e07935a
├── example_analysis.md                     # Plan for analyzing the authored example sentences: the Opus 4.8 versus 5.0 comparison of verbosity, time, and cost, with quality out of scope by Josh's decision
├── example_authoring.md                    # Subagent brief for the authoring run, passed verbatim to every child by verbdata/authored/run_wave.sh; deliberately silent about measurement
├── example_generation.md                   # Orchestrator plan for authoring an example sentence for every gap verb with subagents, half on Opus 4.8 and half on Opus 5.0
├── example_review.md                       # Subagent brief for the adversarial review of the authored sentences, passed verbatim by verbdata/review/run_review_wave.sh with a shard path appended
├── example_review_followups.md             # Plan for the four open items the example-sentence review of 2026-07-25 left, each scoped with its evidence and the decision it needs
├── example_review_run.md                   # Orchestrator plan for the adversarial review of every authored example sentence, and for collapsing the findings into one triage list for Josh
├── example_sentence_extraction.md          # Batch prompt, with its own progress counter, for extracting literary example sentences for the first corpus with parallel subagents; extraction complete. The pipeline it drives is docs/example_sentence_pipeline.md
├── fix_cold_launch_widget_deeplink_race.md # Plan for checking Konjugieren for the cold-launch widget-deeplink race that Conjuguer had, and fixing it if present (2026-07-09)
├── fix_languagemodel_availability_poll.md  # Fix plan for LanguageModelServiceReal polling availability every five seconds; implemented 2026-07-08
├── fix_reference_defects.md                # Plan for fixing the defects that ideation found, to be carried out before any idea is built: wrong auxiliaries (37 contradicted by kaikki, 141 needing a ruling) with a second reading wherever both senses are current, prefixes lost under full-override ablaut entries, two small code bugs, five example sentences, three documents, and the backen/hauen participles. Its audit prototype was promoted to verbdata/audit_auxiliaries.py
├── frame_parity_repair.md                  # Resume prompt for the de/en frame-parity repair found while mining shards 051–052; carries no state and defers to the journal entry of 2026-07-21
├── gap_sentences_batch_1.md                # Review sheet for the first 117 gap sentences, reviewed and approved by Josh on 2026-11-15 (the 25 most frequent verbs, and anfangen, ankommen, einladen), generated by scripts/gap_sentences.py review
├── gap_sentences_batch_2.md                # Prompt for a fresh session to draft, machine-check, reread, and approve the remaining ~625 gap sentences (verbs 26 to 300) with Sonnet subagents; carries Josh's 2026-11-15 decision not to review them himself
├── gloss_adjudication.md                   # Subagent brief for the second reader, a different model from the proposer, that decides which proposed gloss corrections reach the app; passed by verbdata/adjudication/run_adjudication_wave.sh
├── gloss_review.md                         # Subagent brief for the adversarial audit of the shipping English glosses; passed by verbdata/gloss_review/run_review_wave.sh
├── irregularity_marking_consistency.md     # Plan (2026-07-29) for making the red-letter marking consistent across full-override conjugations; not started when written, and ordered after the verb-history rewrite
├── localize_tutor_suggestions.md           # Plan for localizing the tutor's suggestion chips into German (drafted 2026-07-08)
├── luther_bible_section.md                 # Brief for adding a Luther Bible section to the verb-history essay; shipped 2026-07-29, with what happened in docs/luther_section.md
├── model_comparison.md                     # Brief for a session in the Blog repo writing the Opus 4.8 versus Opus 5 post, with every analysis already run and its results included
├── multi_reading_glosses.md                # Plan for auditing the glosses of the verbs with more than one reading; executed 2026-07-26
├── pedagogy_implementation.md              # Multi-session plan, in 24 phases plus a closing, for building the quiz suggestions Josh accepted in docs/pedagogy_research.md; indexes the report's suggestions as T1.1 to T6.9 and M1 to M5, and each session marks its phase done and notes how it differed
├── pedagogy_phase1_variant_audit.md        # Audit from Phase 1 of pedagogy_implementation.md (2026-11-13): the optional standard conjugations, checked against Duden, with rows for Josh to rule on before any becomes an accepted quiz answer. StandardVariants.swift holds the accepted rows
├── prefix_coverage.md                      # Plan for closing the prefix-coverage gap in the Families tab, which opened when the import tranches outgrew a hand-curated prefix list; executed 2026-07-19 in 08a5e93
├── regenerate_verbs_pdf.md                 # Self-contained prompt for a fresh session regenerating konjugieren-verbs.pdf; the generator playbook is docs/pdf.md
├── region_national_framing.md              # Plan (2026-07-26) for reframing the Region setting around national standards and giving the north a bare flag
├── regional_variation.md                   # Plan for supporting the three standard varieties of German; executed 2026-07-19, with its deviations recorded at the top
├── screenshot.md                           # App Store screenshot capture spec: 9 view categories × light/dark × English/German across iPhone 6.9" and iPad 13". Begun by Josh and mostly written by Claude since; docs/screenshot_playbook.md says to update it first when the shipped views change
├── separability_audit.md                   # Plan (queued 2026-07-22) for auditing the separability markers and root splits of imported verbs that mining subagents flagged; a conjugation-correctness task
├── ship_verb_history.md                    # Procedure for shipping the corrected verb-history essay into the string catalog; complete 2026-07-29, and kept as the procedure for any later edit to the essay
├── sound_replacement.md                    # Two prompts for Claude in Chrome on Pixabay, to find non-violent replacements for the game's shot and rapid-fire sounds. Was docs/sound-replacement-prompts.md until 2026-11-16
├── sweep_comments.md                       # Plan for sweeping low-value comments to CLAUDE.md's comment policy; executed in 3f7b8fd. Answers prompts/comments.md
├── swift_testing_doc_improvements.md       # Prompt for a session tightening the Swift Testing code and the docs on test conventions (2026-06-22)
├── triple_consistency.md                   # Plan (2026-07-26) for making each verb's gloss, etymology, and example sentence agree, beginning with a pilot rather than the sweep. Third of the three style plans, on no timeline
├── tutor_row_killswitch.md                 # Plan for the Tutor-row kill switch used when taking screenshots, ported from Conjugar; shipped in 7dd7b88
├── ui_audit_2_next_session.md              # Next-session brief for the OnboardingView page-1 layout work, item 16 of docs/ui_audit_2.md
├── uses_etymologies.md                     # The combined etymology-and-example-sentence pipeline, in phases 0 to 5; complete 2026-07-23, and kept live because the corpus-expansion re-mine reuses Phase 4. Mode B of the integrate skill reads its output
├── verb_browse_fixes.md                    # Multi-session plan, in 12 phases plus a closing, for fixing what docs/verb_browse_review.md found, with Josh's eight decisions of 2026-11-25; phases that change what he can see wait for him before git, and each session marks its phase done and notes how it differed
└── verify_verb_history.md                  # Plan for fact-checking "A History of the German Verb System" in phases 0 to 4; every phase done, with docs/history_corrections.md as the deliverable

prompts/                       # What Josh wrote to get Claude to do something. A plan Claude writes in answer goes in plans/, and research or other informational output goes in docs/
├── bersten.md                 # Asks whether the carets in bersten's entry mark more letters irregular than the vowel that changes
├── code_review.md             # Asks for a full-codebase review ranked by impact; answered by docs/code_review_recommendations.md
├── comments.md                # Asks for a comment-sweep plan like Conjugar's; answered by plans/sweep_comments.md
├── creation_test.md           # Asks for the authored-example pipeline, an orchestrator plan and a subagent brief, split between Opus 4.8 and 5.0; answered by plans/example_generation.md and plans/example_authoring.md
├── etymology_fixes.md         # Asks for two etymology-formatting sweeps: capitals at the start of sentences, and a bullet in place of the hyphen that introduces a verb's parts
├── frequency.md               # Quotes BBAW's permission for the DWDS frequency data and asks to adopt it, credit it, and note DWDS's term Flexionsparadigma
├── game_orientation.md        # Asks to remove the game's UIKit orientation hack and fix its iPad layout; executed in bbdb8ec
├── location_cleanup.md        # Asks for the sorting of 2026-11-16 that put prompts, plans, and documents in the folders this file describes
├── more_verbs.md              # Asks for new sources of verbs; executed 2026-07-18, producing docs/verb_sources.md
├── pedagogy.md                # Asks whether the quiz is pedagogically sound and how to improve it; answered by docs/pedagogy_research.md
├── telemetry.md               # Asks for the usage data of all three apps from TelemetryDeck; answered by docs/telemetry_usage.md
└── verb_browse_review.md      # Asks for a review of the code that plans/browse_and_verb_implementation.md built; answered by docs/verb_browse_review.md

scripts/
├── check_docs.py              # Asserts the checkable claims the docs make about themselves: corpus/ablaut/test counts in the four cache files, relative-link targets, roadmap commit hashes, the kaikki attribution invariant, and etymology completeness
├── choice_questions.py        # Choice questions' content: `review` writes a Markdown sheet of the drafts with each reason as the app words it, `approve` marks items reviewed, `status` counts them by level
├── count_conjugationgroups.py # Counts each conjugationgroup in the corpus, from ConjugationMapTool --cells-json; see docs/conjugationgroup_frequency.md
├── gap_sentences.py           # Sentences' content: `review` writes a Markdown sheet of the drafts, `approve` marks sentences reviewed, `status` counts them
├── generate_verb_pdf.py       # Generates PDF verb conjugation tables from VerbExportTests' JSON (default /tmp/konjugieren-export.json)
├── render_emoji.swift         # Renders emoji glyphs to PNG assets in Assets.xcassets (workaround for iOS 26 emoji-rendering bug; see docs/emoji_assets.md)
├── rename_files.py            # Renames or moves files and directories from a JSON map and repairs the references: Markdown link targets, written-out paths, and bare names. Skips and reports any path whose prefix names a different file, which is how an inbound GitHub link gets noticed. Run from the root of the repo being changed, so Conjugar and Conjuguer use it too
├── sync_verb_history.py       # Validates docs/verb_history{,_de}.txt against StringExtensions' markup rules and writes the body back into Localizable.xcstrings
├── test_sync_verb_history.py  # Negative-tests every validator in sync_verb_history.py by corrupting a copy of the essay one way at a time; also asserts both shipping extracts validate clean
├── take_screenshots.sh        # Drives ios-build-verify + axe/simctl through 36 App Store screenshots (9 views × 2 langs × 2 devices); see docs/screenshot_playbook.md
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
    └── build_corpus_index.py  # Phase 2 of plans/uses_etymologies.md: indexes the corpus into per-verb candidate sentences using forms.json. Sentence-wise (not line-wise) matching, Satzklammer split-particle rule, two-column PDF recovery, English translations excluded

verbdata/                      # Verb-corpus-expansion data (see docs/verb_sources.md)
│   generate_frequencies_txt.py  # Regenerates docs/frequencies.txt from Verbs.xml (--check for drift)
├── README.md                  # Provenance, integrity stats, and re-download recipes for the data files
├── fetch_dwds_frequencies.py  # Fetches DWDS lemma frequencies; --lemmas FILE overrides the Verbs.xml corpus, --quarantine keeps the clean rows when some are suspect
├── apply_dwds_frequencies.py  # Writes a fetched snapshot back into Verbs.xml: sets hi, drops hp. Text surgery, not an ElementTree round trip
├── replace_inflated_estimates.py # One-shot, 2026-11-13: moved 61 provisional (hp) estimates that tranche 2 had ranked near #940 to beside a named measured verb each; the anchor table is the artifact
├── wiktionary_defects.json    # Verbs where Konjugieren deliberately disagrees with English Wiktionary because Wiktionary is wrong (auto-generated weak tables); subtracted from the at-odds count by summarize_classification.py
├── build_candidates.py        # Classify-and-verify stage A: kaikki JSONL → candidates.json (see docs/verb_classification.md)
├── summarize_classification.py # Classify-and-verify stage C: classification.json → a Markdown summary grouped by cause
├── add_readings.py            # One-shot migration that gave every verb a <reading> child (roadmap step 5)
├── import_tranche1.py         # One-shot import of the 78 missing strong bases (roadmap step 7); the decision table is the artifact
├── import_tranche2.py         # Rule-driven import of 2,303 prefixed derivatives (roadmap step 8); hi derived from each base. --check --screen V,V runs named verbs through every decision and writes nothing
├── import_tranche3.py         # Tranche 3 (roadmap step 9): bare weak and -ieren stems, hi from a two-probe DWDS fetch, icons by gloss keyword; --write-lemmas, --write-repair-lemmas, --check, then --top N / --min-hits H
├── tranche3_ranked.tsv        # import_tranche3.py --check output: every importable verb, most frequent first, with the corpus rank it would take. The list a cutoff is chosen from
├── tranche3_deferred.txt      # import_tranche3.py --check output: every tranche-3 candidate held back, and why. Recomputed each run
├── auxiliary_screen.py        # Shared by importers: ay from the same kaikki sense as tn; holds back dual-auxiliary, separability-homograph, family-split, and sense-contradicted verbs as `proposed` rows in auxiliary_rulings.tsv
├── tranche2_dual_auxiliary.txt # Frozen 2026-11-10: the verbs tranche 2 shipped with one reading of two. History; auxiliary_rulings.tsv is the current record
├── audit_auxiliaries.py       # Compares every shipped reading's auxiliary with kaikki, sense by sense, and with auxiliary_rulings.tsv. --unruled prints the worklist; --check fails on any reading that disagrees with its ruling, on any listed verb still unruled, and on any `proposed` row an importer wrote
├── auxiliary_rulings.tsv      # One row per reading ruled against DWDS / German Wiktionary by plans/fix_reference_defects.md (Parts 1 and 6): gloss, auxiliary, outcome, source, reasoning. Pinned by ConjugatorTests.ruledAuxiliary
├── dwds_frequencies.json      # Corpus-wide DWDS frequency snapshot, re-fetched 2026-08-26 under BBAW permission (gitignored, regenerable)
├── dwds/                      # Inputs and logs for the corpus-wide fetch: lemma list with probes, quarantine files, run logs (gitignored)
├── candidates.json            # 9,217 normalized candidate conjugation tables (gitignored, regenerable)
├── classification.json        # Per-verb classification results (gitignored, regenerable)
├── classification_summary.md  # Rendered summary of the above (gitignored, regenerable)
└── kaikki.org-dictionary-German-by-pos-verb.jsonl  # 294 MB kaikki.org German-verb extraction (gitignored)

GameCenterResources.gamekit/   # Xcode's local Game Center configuration: the retired Leaderboard (with its images) and the four per-level leaderboards; see docs/game_center_setup.md

Images/                        # README and App Store screenshot images

.swiftlint.yml                 # SwiftLint rules, shared with Conjugar and Conjuguer; the app target's Run SwiftLint phase lints the whole repo
```
