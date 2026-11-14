# Plan: Build the Accepted Pedagogy Suggestions

**For:** a series of fresh Claude Code sessions, one phase per session as a rule. **Kind of work:**
quiz logic, new practice modes, a persistent practice record, localized strings, Game Center
configuration, a little authored German content, and tests. **Written:** 2026-11-13, from Josh's
verdicts in [`plans/pedagogy.md`](pedagogy.md) (the report) and his answers to its "Decisions for
Josh", the day the browse plan,
[`plans/browse-and-verb-implementation.md`](browse-and-verb-implementation.md), finished.

## Status

Each session that finishes a phase fills in its row here, changes the **Status** line under the
phase's heading to match, and writes the phase's **How it differed** note. A finished phase that
Josh has not yet tried is "Awaiting Josh", with the Commit cell empty until it is committed.

| Phase | Status | Date | Commit | Suggestions |
|---:|---|---|---|---|
| 1 | Done | 2026-11-13 | `250cca9` | T1.3, T1.4, T1.5 |
| 2 | Done | 2026-11-13 | `11f2d81` | T1.2 |
| 3 | Done | 2026-11-13 | `f7f3fbc` | T4.1, T4.4, T4.5 |
| 4 | Done | 2026-11-13 | `ae1b4a4` | T1.6 |
| 5 | Done | 2026-11-13 | `71e0bc9` | T2.3, T2.6, T6.7, M1 |
| 6 | Done | 2026-11-13 | `4ee097d` | T2.1, T2.2, T2.5 |
| 7 | Done | 2026-11-13 | `80b5f85` | T2.7, T3.1, T6.5, M2, M3 |
| 8 | Done | 2026-11-14 | `cba6f9e` | Decision 4 |
| 9 | Done | 2026-11-14 | `b4f00b0` | T2.8 |
| 10 | Done | 2026-11-14 | `dee17b1` | T2.9, Decision 8 |
| 11 | Done | 2026-11-14 | `e8fcc07` | T3.3 (the record), T3.4, T3.5, T6.4 |
| 12 | Awaiting Josh | 2026-11-14 | | T3.2, T3.3 (the session) |
| 13 | Not started | | | T6.1, T6.6 (the leaderboard's place) |
| 14 | Not started | | | T4.2, T4.3 |
| 15 | Not started | | | T5.1 |
| 16 | Not started | | | T5.2 |
| 17 | Not started | | | T5.4 |
| 18 | Not started | | | T5.5 |
| 19 | Not started | | | T5.6 |
| 20 | Not started | | | T6.2 |
| 21 | Not started | | | T5.7 |
| 22 | Not started | | | T6.3 |
| 23 | Not started | | | T6.6 (personal bests and achievements) |
| 24 | Not started | | | T6.8 |
| Closing | Not started | | | Audit, report notes, porting list, Decision 10 |

## How to Work This Plan

**Choosing a phase.** Take the lowest-numbered phase that is not done and whose dependencies are.
The numbering follows the report's order of leverage (correct grading, then what the quiz asks,
then memory, then feedback, then new directions, then motivation), adjusted where one phase needs
another's pieces. It is a suggested order. If a phase proves too large for one session, split it,
say so in its row, and leave the remainder marked "Partly done". Phases 18 and 19 need authored
German content and are the likeliest to split.

**What this plan leaves to you.** The phases say what to build and what Josh decided. They do not
say how. Read the code, choose the implementation, and record in **How it differed** anything that
departs from the phase as written: a scope change, a decision Josh made during the session, a
dependency that turned out wrong, or a piece deferred to a later phase. A later session relies on
that note more than on the phase text above it. Read the notes of every phase this one depends on
before starting.

**Ask Josh when a verdict does not settle a question.** Most phases list such questions under
**Ask Josh**. Do not guess at them. Ask before building the part that depends on the answer, and
record the answer and its date in **How it differed**.

**Every phase finishes the same way.**

1. Build and run the tests with the `ios-build-verify` skill, as `CLAUDE.md` describes. New logic
   gets tests that follow [`KonjugierenTests/CLAUDE.md`](../KonjugierenTests/CLAUDE.md). Read the
   run's test count, not only its exit status. Question generation is random, so make its random
   source injectable (`SeededRNG` in `Shared/WidgetQuizShuffle.swift` exists) and test
   proportions with a fixed seed rather than with luck.
2. For any visible change, launch the app and look at it on both the iPhone 17 and the iPad Pro
   11-inch (M5) simulators, not only for layout work. Josh tries changes on an iPhone and leaves
   the iPad to the session (2026-11-13), so the session's check is the only one the iPad gets.
   Exercise the phase's new states there too, not just its first screen, and say in **How it
   differed** what was tried on each device. Split the languages and appearances across the two:
   on the iPhone, look in German and again in English, and on the iPad in English, so that between
   them the check covers both languages, light and dark, and both size classes (Josh, 2026-11-13).
   Since 2026-11-14 the iPhone simulator's system language is German (Josh), so a plain
   `launch_app.sh` shows German there, and the English look needs a relaunch with
   `-AppleLanguages "(en)"`; the iPad's stays English. Check with `xcrun simctl spawn <udid>
   defaults read -g AppleLanguages`. The iPhone simulator has been in dark mode and the iPad in
   light; if either has changed, set it with `xcrun simctl ui <udid> appearance dark` (or
   `light`). The quiz has a `KONJUGIEREN_QUIZ_FIXTURE` launch
   default for a fixed set of questions; extend it rather than tapping through random quizzes.
3. Localize every new string in English and German, following `CLAUDE.md`'s rules for
   `Localizable.xcstrings`. A new setting's description begins "This setting determines...".
   Strings used by `Shared/` code belong in the widget's catalog too.
4. Follow [`docs/voiceover.md`](../docs/voiceover.md). The quiz already announces each question
   and each result; every new state (a hold on a wrong answer, a second attempt, a diagnosis)
   needs an announcement that a learner who cannot see the screen can act on.
5. Add analytics by the browse plan's convention
   ([`docs/feature-architecture.md`](../docs/feature-architecture.md) § Analytics), and stage
   every new signal, parameter, or value in
   [`docs/privacy-policy-pending.md`](../docs/privacy-policy-pending.md) in both languages. **No
   signal may carry an answer, a score, a count of right or wrong answers, or which verb or item
   was asked** (Decision 5). That a mode was started, quit, or finished, and from where, is fine.
6. Update [`docs/project-structure.md`](../docs/project-structure.md) for new, renamed, or
   repurposed files, keep `docs/feature-architecture.md` § Quiz true, and run
   `python3 scripts/check_docs.py`.
7. In the report, [`plans/pedagogy.md`](pedagogy.md), add a **Built on `main`** or **Partly
   built** line under the tier whose suggestion this phase built, with the date and a link to the
   phase, as the browse plan's Closing did.
8. Fill in the Status row and the phase's Status line, write **How it differed**, and append a
   journal entry to `docs/blog_notes.md`.
9. **Stop before git.** Do not run `git add`, `git commit`, or `git push` until Josh has tried the
   changes. Tell him what changed and how to try it: which screens to open, and what to type or
   tap. Once he says he has tried them, commit and push to `main`. Then, since a commit cannot
   contain its own hash, record the hash in the Status row with a one-line follow-up commit, and
   push that too. This is the browse plan's rule, made by Josh on 2026-11-12, and it holds for
   every phase here and the Closing.

**No release before 2027.** Every phase accumulates on `main`. Nothing here reaches a learner or
produces a number until a release ships, so no phase should wait on evidence from another, and
App Store Connect work (Phases 8 and 23, and the Closing's category change) prepares for that
release rather than for an earlier one.

**Konjugieren only.** The report advises building shared changes into all three apps, and Josh
answered that Konjugieren goes first (Decision 6). Porting is outside this plan; the Closing
gathers the list.

## Suggestion Index

The report's suggestions carry no numbers, so this plan gives them IDs. "Verdict" is Josh's, from
the report's tables, shortened.

| ID | Suggestion | Verdict | Phase |
|---|---|---|---:|
| T1.1 | Decide the separable-verb convention | Accept both | Built (browse Phase 4) |
| T1.2 | Show the shape of the expected answer | Yes | 2 |
| T1.3 | Strip a leading pronoun before grading | Yes | 1 |
| T1.4 | Accept ae, oe, ue, and ss; ä, ö, ü, and ß keys on the answer field | Yes | 1 |
| T1.5 | Audit optional variants and accept every standard one | Yes | 1 |
| T1.6 | A one-letter slip is "almost", with one more attempt | Yes, half points if right on the second attempt | 4 |
| T2.1 | Draw from frequency bands | Yes, top 300 | 6 |
| T2.2 | Prefer base verbs | Yes, one to three derivative verbs per quiz | 6 |
| T2.3 | Levels ordered by use, replacing the two difficulties | Yes | 5 |
| T2.4 | Weight a newly opened conjugationgroup | **No** | Not built |
| T2.5 | Guarantee a mix of strong and weak verbs; sein, haben, werden, and the modals recur | Yes | 6 |
| T2.6 | Thin the Futur and other auxiliary-only conjugationgroups | Yes | 5 |
| T2.7 | Ten questions, with an offer to continue | Reluctantly, yes | 7 |
| T2.8 | Learner-chosen scope | Yes; the default stays the classic-style quiz | 9 |
| T2.9 | A scope shareable as a link or a QR code | Yes | 10 |
| T3.1 | Re-ask a missed question | Partial: re-ask once | 7 |
| T3.2 | Practice my mistakes | Yes | 12 |
| T3.3 | A box and a due date per item, and a Review session | Yes | 11, 12 |
| T3.4 | A ladder of 1, 3, 7, 14, and 30 days | Yes | 11 |
| T3.5 | Two kinds of item: a strong verb's key conjugations, and a weak pattern | Yes | 11 |
| T4.1 | Stay on a missed question until Continue | Yes | 3 |
| T4.2 | Diagnose the error in one templated line | Yes | 14 |
| T4.3 | Prompt a repair before revealing a diagnosable error | Yes | 14 |
| T4.4 | Mark where the learner's answer differs | Yes | 3 |
| T4.5 | Link the correction to the verb's page and family | Yes | 3 |
| T4.6 | A language model that words a deterministic diagnosis | **Not applicable at this time** | Not built |
| T5.1 | A key-conjugations exercise for strong verbs | Yes | 15 |
| T5.2 | Ablaut-group practice, one group, then mixed | Yes | 16 |
| T5.3 | Test yourself on this verb | Yes | Built (browse Phase 13) |
| T5.4 | Recognition questions | Yes | 17 |
| T5.5 | Sentence frames for the core verbs | Yes | 18 |
| T5.6 | Choice questions between two conjugationgroups | Yes | 19 |
| T5.7 | A speed round over mastered items | Yes | 21 |
| T6.1 | The Quiz tab as a practice hub | Yes | 13 |
| T6.2 | Show mastery | Yes | 20 |
| T6.3 | A daily session, a repairable streak, an optional reminder | Yes | 22 |
| T6.4 | Keep partial work | Partial: the sad trombone stays | 11 |
| T6.5 | Hide the clock by default | Yes, as a setting | 7 |
| T6.6 | Leaderboard out of the main path; personal bests and achievements | Yes, with help in App Store Connect | 13, 23 |
| T6.7 | Rename the levels | Yes | 5 |
| T6.8 | A daily shared challenge | Yes | 24 |
| T6.9 | Make the arcade game conjugate | Outside this project | Not built |
| M1 | Send the difficulty with `startQuiz` | No verdict; within the policy | 5 |
| M2 | Report the question reached by a quiz abandoned by leaving the app | No verdict; within the policy | 7 |
| M3 | Report the time from start to quit in bands | No verdict; within the policy | 7 |
| M4, M5 | Questions answered and correct; accuracy by interval | **No** (Decision 5) | Not built |

M1 to M3 are the report's "within the present policy" signals, for which the report recorded no
verdict. Confirm each with Josh in its phase before building it.

## Decisions Already Made

From the report's verdicts and Josh's answers to its "Decisions for Josh".

- **Practice, not examination** (Decision 2). Where a choice between the two arises, choose
  practice.
- **Serve both audiences** (Decision 3): residents of German-speaking countries, many with phones
  in another language, and English-speaking learners abroad. The English glosses stay, and the
  setting for the language of conjugationgroup names stays.
- **The leaderboard is re-scoped by level** (Decision 4), in Phase 8.
- **No accuracy signals** (Decision 5). The privacy policy is not revised to send accuracy. The
  practice record is kept on the device and sent nowhere; the policy's sentence that the app "does
  not record your quiz answers, your scores" becomes "does not send", as the browse plan's Phase
  12 did for looked-up verbs.
- **Konjugieren first** (Decision 6). The siblings follow from the Closing's list.
- **The arcade game is left as play** (Decision 7, and T6.9).
- **Schools are a channel** (Decision 8). Shareable practice sets are the step toward it.
- **Conjuguer's minimum OS stays at 26** (Decision 9). Nothing here touches it.
- **Konjugieren's store category becomes Reference** (Decision 10), though Josh expects little
  from it. See [Tasks for Josh Outside the Code](#tasks-for-josh-outside-the-code).
- **The sad trombone stays** on quitting, because it is fun and silly (T6.4).
- **Levels are chosen, not earned.** Josh rejected weighting by which conjugationgroups have been
  opened, saying that what has been opened "should not impact quizzes" (T2.4). The learner picks a
  level, and nothing unlocks; Josh confirmed this reading on 2026-11-13.
- **Most open questions are answered.** On 2026-11-13, before any phase began, Josh answered
  every question that needed only his preference, and each phase records them under **Decided**.
  The **Ask Josh** items that remain need something to look at first: a mockup, an audited list,
  a draft, or a built screen.
- **The default quiz is the classic quiz, modified** by this plan (T2.8): levels, frequency bands,
  ten questions. Scopes are choices beside it, not replacements.
- **Re-ask a missed question once, not until correct** (T3.1), because in a ten-question session
  one stubborn question could dominate.
- **A right second attempt earns half points** (T1.6).
- **No "principal parts" label** anywhere, in the interface or in code names. Josh rejected the
  browse plan's B1 partly because learners do not know the term, and that plan settled that a
  verb's key conjugations stand alone, as in "aufstehen: steht auf · stand auf · ist
  aufgestanden". This governs Phases 11 and 15.
- **Only a full quiz over every verb ranks**, as Josh decided on 2026-11-13 in the browse plan's
  Phase 13. Phase 8 replaces this rule with per-level ranking; until then it stands.

## What the Browse Plan Left for This One

Read [`plans/pedagogy.md`](pedagogy.md)'s **Built on `main`** and **Partly built** lines for the
full account. In brief, by code name:

- **Grading.** `QuizItem.accepts` grades case- and spacing-insensitively against
  `acceptableAnswers`, which `Quiz.makeQuizItem` fills with every region's and both clauses'
  conjugation. So the quiz accepts split and joined separable verbs, and ss for ß through the Swiss
  spelling. It does not accept ae, oe, or ue.
- **Folding.** `VerbSearch.fold` folds ä, ae, and a together. That is right for search and wrong
  for grading, since it would accept fahrt for fährt. Grading needs a narrower fold.
- **Edit distance.** `VerbSearch.editDistance` (optimal string alignment) exists for Phase 4.
- **Which cell is this text?** `Verb.conjugations(matching:)` in `ConjugationMatch.swift` returns
  every cell of a verb that equals a text, graded as the quiz grades. It is Phase 14's first check.
- **The conjugation map** ships in the app (`ConjugationMap`, `ConjugationIndex`), built by
  `ConjugationMapTool`. Phase 17 reads it.
- **Key conjugations.** `Verb.keyConjugations(readingIndex:region:)` in `KeyConjugations.swift`.
- **Scopes.** `QuizScope` carries verbs, a reading, a question count, a source, a title, and a
  collection key, with constructors `.allVerbs`, `.myVerbs`, `.verbPage`, and `.collection`.
  `QuizScope.isRanked` decides the leaderboard. `QuizSheet` presents a scoped quiz in a sheet.
- **Bands and collections.** `FrequencyBand` (`.top100`, `.top300`, `.top1000`) with
  `Verb.isIn(_:)` and `Verb.verbs(in:)`; `VerbCollection`, including all 76 ablaut groups, shared
  as `konjugieren://list/<key>`.
- **A due date per verb.** `ReviewSchedule` in `Shared/`, on each `LearnerVerbs.Entry`, on the
  ladder of 1, 3, 7, 14, and 30 days, which drives the review card above the verb list.
  `docs/feature-architecture.md` § The Review Card says how the quiz can take it over.
- **The letter keys.** `GermanLetterKeyRow`, with an `insert` closure so that the quiz's answer
  field can insert at the cursor. Only the search field shows it.
- **Errors kept, never read.** `QuizErrorHistory` stores the last 200 wrong answers. Each
  `QuizErrorRecord` names the conjugationgroup by its English display name without the person, and
  carries no reading, so a record cannot rebuild its question.
- **Thirty is wired in.** `Quiz.questionCount` (30) also gates the Live Activity, the
  `ChangeDifficultyTip` donation, the participle quota, and `isRanked`. Phases 5, 7, and 8 must
  revisit each.
- **The start screen.** Browse Phase 13 filled the Quiz tab with a scope picker (All Verbs, My
  Verbs), a hero symbol, and tiles for questions, difficulty, and points. Phase 13 here grows it
  into a hub.
- **The disabled explainer.** `ErrorExplainerView` is commented out in `QuizView` because the
  on-device model invented grammar. Leave it so (T4.6).

## Phase 1: Accept What Is Right

**Suggestions:** T1.3, T1.4, T1.5. **Depends on:** nothing. **Status:** Done.

- **T1.3.** Strip a leading pronoun from the answer before grading, so "ihr habt ferngeguckt"
  passes. Strip only a pronoun that matches the question's person, and keep the pronoun that the
  wir and Sie Imperativ answers already contain (`steigen wir nach`, `stoßen Sie um`).
- **T1.4.** Accept ae, oe, and ue for ä, ö, and ü, alongside the ss for ß that the Swiss spelling
  already allows. Use a fold that maps only digraph to umlaut, never umlaut to bare vowel, so a
  missing umlaut stays wrong (Phase 4 makes it a near miss). Show `GermanLetterKeyRow` above the
  keyboard while the answer field is focused, inserting at the cursor. The browse plan's Phase 1
  found that a keyboard toolbar never appeared for the navigation bar's search field; the answer
  field is an ordinary `TextField`, so try the toolbar placement first.
- **T1.5.** Audit optional standard conjugations and accept each. Candidates to check against DWDS
  or Duden: the du-Imperativ with and without -e (zieh hin, ziehe hin), and the cases where the -e
  is required or impossible; the ich-Präsens of verbs in -eln and -ern (ich sammle, ich sammele;
  ich wandere, ich wandre); Präteritum Konjunktiv II doublets (stünde, stände; hülfe, hälfe); and
  doublet participles and Präteritum conjugations not already modeled as readings.

**Decided (Josh, 2026-11-13):** a digraph answer is accepted, and the umlaut spelling
("übernehme") shows quietly beside the checkmark, without counting against the learner.

**Ask Josh:** before accepting any variant, show Josh the audited list with its sources and let
him rule on each. Variants become accepted answers only, not new conjugations on the verb page,
unless he says otherwise.

**Done when** the report's simulator cases pass (`ihr habt ferngeguckt`, `uebernehme`, and the
already-passing `stossen Sie um`), a missing umlaut still fails, the key row inserts into the
answer field, the ruled variants pass, and tests pin each.

**How it differed:**

- **The digraph rule expands rather than folds.** Instead of folding the learner's answer, each
  accepted conjugation gains every spelling with any of its umlauts written as a digraph
  (`AnswerSpelling.digraphSpellings`). A fold on both sides would also have accepted baü for
  baue. The ss for ß still comes from the Swiss spelling, and the spelling beside the checkmark
  covers it too: a learner in Germany who types stossen Sie um is shown stoßen Sie um. A
  different regional conjugation, such as Austria's ist gestanden, gets no such line.
- **The pronoun rule takes er, sie, or es for the third-person singular**, whichever the settings
  show, and nothing in front of any Imperativ.
- **The audit is its own file**, [`pedagogy-phase1-variant-audit.md`](pedagogy-phase1-variant-audit.md),
  with its method, Duden links per row, and Josh's rulings of 2026-11-13. It mined the kaikki
  Wiktionary snapshot for every form the conjugator lacks (13,023 across 3,571 verbs) and checked
  each pattern against Duden's conjugation tables. Wiktionary alone was wrong twice: it lists ich
  wandre, which Duden does not, and tags nearly every Konjunktiv II "formal, rare". Josh accepted
  every row recommended, for quiz acceptance only. The variants are in `StandardVariants.swift`.
- **Two data fixes Josh approved during the session:** scheiden (`sch^eid^en` gave schie and
  geschien) and vergleichen (bleiben's group gave vergliech), in `Verbs.xml`. This closes the
  roadmap's last wrong ablaut group. The audit's defects table lists three more verb-page changes
  Josh chose to defer: the Konjunktiv I of -eln and -ern verbs (du sammelest, which Duden lacks),
  anerkennen split, and sandte and gesandt as a reading of senden.
- **`Verb.conjugations(matching:)` no longer grades "as the quiz grades".** It still matches
  cells exactly, without pronouns, digraphs, or variants, and its comment and
  `docs/feature-architecture.md` now say so. Phases 4 and 14 call it on a wrong answer, where
  exact cells are what they want.
- **A new fixture**, `KONJUGIEREN_QUIZ_FIXTURE grading`: ten questions whose right answers
  exercise this phase, repeated to 30.
- **Analytics:** none added, so nothing is staged in `docs/privacy-policy-pending.md`.
- **Verified on the iPhone 17 simulator**, with a hardware keyboard, where iOS draws the keyboard
  toolbar as a floating bar at the bottom. The letter keys inserted at the cursor, mid-word too.
  The software keyboard's placement and the iPad were not tried, and neither was VoiceOver's
  "Correct. Spelled: …" announcement.

## Phase 2: The Shape of the Answer

**Suggestions:** T1.2. **Depends on:** Phase 1. **Status:** Done.

Show the shape of the expected answer around the field: `ihr ______` with the pronoun fixed
outside the field, and `______ Sie ______!` for a Sie-Imperativ of a separable verb. The frame
settles the pronoun question and the word-order question together. It must cover the six persons
(including the Sie disambiguation that `PersonNumber.pronounWithSieDisambiguation` provides), the
participles (no pronoun), the Imperativ for du and ihr (no pronoun) and for wir and Sie (pronoun
inside), and separable verbs in each. Where the quiz accepts both split and joined conjugations, a
frame must not make either impossible to type.

Build the frame as a component the later question types can reuse: Phase 15's three blanks and
Phase 18's sentence frames are the same idea at a larger scale.

**Ask Josh** to choose between two or three mockups before building, with a two-blank imperative
among them, and to judge how a two-field frame should handle Return and the letter-key row.

**Done when** every conjugationgroup and person shows a frame, the separable Sie-Imperativ shows
two blanks, VoiceOver reads the frame as one prompt, and tests pin the frame chosen for each kind
of question.

**How it differed:**

- **Josh chose on 2026-11-13**, from three mockups: inline rounded fields with the fixed words on
  the same line (over underlined blanks, and over a frame drawn as a caption above one field);
  Return moves to the next empty blank and submits once none is empty, with the letter keys
  following the cursor (over Return always advancing, and over a space that jumps blanks); and
  the second blank may reveal that a verb is separable, since the quiz is practice.
- **Two blanks only where the pronoun is inside the answer.** The separable wir and Sie Imperativ
  get `[ ] Sie [ ] !`; every other cell is one blank, compound conjugations included (`ich [ ]`
  takes bin angekommen). A separable Präsens stays one blank so that ankommt is as easy as kommt
  an. Separability comes from the asked reading, so übersetzen frames differently by reading.
- **The person still shows where no pronoun is typed.** The du and ihr Imperativ show `(du) [ ] !`
  and `(ihr) [ ] !`, since the two take different answers, and sie keeps its `(3s)` or `(3p)`.
- **The Pronoun row is gone**, and `L.Quiz.pronoun` with it. `QuizItem.pronoun` stays for
  `ResultsView`.
- **The frame's pronoun is not part of the graded answer**, so a learner who types `ihr kommt an`
  into the blank is still right. Nothing new tolerates a Sie typed into the second blank, or the
  whole `stoßen Sie um` in the first; the Return rule makes the learner fill the second.
- **A focus bug, found by looking.** The first build keyed the frame's segments by position, so
  when a pronoun appeared in front of the field on the next question, the field was rebuilt and
  the keyboard lost focus. The blanks are now keyed by blank index. Giving the frame a new
  identity per question had the same flaw and would have bounced a software keyboard.
- **VoiceOver.** Each field's label reads the whole frame in the app's language ("ihr, blank";
  "blank, Sie, blank. Blank 1 of 2"), with new strings for blank, its position, singular, and
  plural; the frame's other text is hidden. The German pronouns inside an English label are read
  by the English voice. Nobody has listened to it yet.
- **A new fixture**, `KONJUGIEREN_QUIZ_FIXTURE frames`: one question per frame, repeated to 30.
- **Analytics:** none added, so nothing is staged in `docs/privacy-policy-pending.md`.
- **Verified on the iPhone 17 simulator** with a hardware keyboard, typing every fixture answer
  with keystrokes alone after one tap: Return advanced between the Imperativ's blanks, the ß and
  ü keys inserted into the focused blank, and focus survived every change of frame. The iPad, the
  software keyboard, and VoiceOver by ear were not tried. The App Store's quiz screenshots will
  show the frame when next captured; the driver still types into `quiz_answer_field`, and the
  screenshot fixture asks no wir or Sie Imperativ.

## Phase 3: A Correction That Stays

**Suggestions:** T4.1, T4.4, T4.5. **Depends on:** nothing; Phase 2 preferably. **Status:**
Done.

Today `Quiz.submitAnswer` advances before the view redraws, so the correction for question n
appears on the card for question n + 1 while the clock runs.

- **T4.1.** After a wrong answer, stay on the missed question: its prompt, the learner's answer,
  the correct answer, and a Continue button, which Return also triggers. Pause the clock while the
  correction shows. After a right answer, advance at once, as now; the report's chief study
  recommends exactly that split.
- **T4.4.** Mark where the learner's answer differs from the correct one. The red letters already
  mark what is irregular about the verb, so the difference needs a visibly different treatment,
  and it must still read sensibly to VoiceOver.
- **T4.5.** Link the correction to the verb's page and to its family or ablaut group. Opening one
  must not end the quiz; it pauses the clock and returns to the held question. In `QuizSheet`
  opened from a verb's own page, a link back to that page is circular, so leave it out there.

The rows "Last Answer" and "Correct Answer" on the next card, and the `lastIncorrectAnswer`
machinery that feeds them, are replaced, not supplemented. Keep the commented-out
`ErrorExplainerView` where it can return beside the held correction.

**Ask Josh** to judge the layout of the held correction and the difference marking on a
device-sized screen before polishing it.

**Done when** a wrong answer holds on its own question with the clock stopped, Continue advances,
the difference is marked, both links work from the tab and the verb link is absent in the sheet,
VoiceOver announces the correction and the Continue button, and tests pin the state machine.

**How it differed:**

- **The layout is built, not yet judged.** The correction sits in the question's card, under the
  answer frame: Your Answer, Correct Answer, a row of links, and a full-width Continue. The field
  keeps the learner's answer and the keyboard, so Return continues. It stays editable, since a
  binding that ignores edits can leave a `TextField` showing text its state does not hold, and
  nothing typed there is graded. Josh has still to judge it on a device-sized screen (the Ask Josh
  above).
- **Which right answer is shown.** `QuizItem.difference(from:)` shows the nearest of the user's
  region's spellings, so ankomt is corrected to ankommt and komt an to kommt an. A leading
  pronoun of the asked person is dropped, as grading drops it, and the learner's capitals are
  kept. `QuizErrorHistory` and the error context still record the canonical answer.
- **The marking.** `AnswerDifference` aligns the two answers with `VerbSearch.editDistance`'s
  costs and marks whatever the cheapest alignment leaves unmatched. A missing letter has nothing
  to mark in the learner's answer, so it shows only as an underlined letter of the right answer;
  a caret in the learner's answer was considered and left out. Case is not a difference, so a red
  letter is never marked for being a capital. The tints were strengthened after the first
  screenshots, where they barely showed on the dark card.
- **One group link.** A strong or mixed reading links to its ablaut group (the Ablaut page,
  expanded and scrolled to it), and a weak or -ieren reading to its family page. A separable
  verb's prefix family is not linked. The verb link opens the page on the asked reading,
  scrolled to the missed cell and marked, through the `MarkedConjugations` that search uses.
- **No quiz inside a quiz.** Not in the phase: the pages pushed over a held question hide "Test
  me on this verb" and a collection's Quiz button, through a new `isBeneathQuiz` environment
  value. The verb link is left out of a quiz begun from a verb's page, as the phase said.
- **Two focus bugs, found by looking.** Return resigns a `TextField`, and the next question's
  focus reset had hidden that. A held question therefore lost the keyboard and Return did
  nothing, so the view now refocuses the field on holding. After Back from a linked page, setting
  the focus state to the 0 it still held changed nothing, so it is cleared and set again once the
  pop has finished.
- **A wrong last answer now shows its correction** before the results. Before, the 30th
  question's correction never appeared.
- **VoiceOver.** `Quiz` no longer announces a wrong answer. Focus moves to the correction instead,
  which reads "Incorrect. Your answer: fahrt. Correct answer: fährt. Letters that differ: ä." (the
  letters only when three or fewer), with the hint "Swipe right for links to the verb, then
  Continue." Continue has its own hint, and a Magic Tap also continues. Nobody has listened to it.
- **Analytics:** one new value, `quizCorrection`, for `viewVerbView` and `viewCollection`. The
  privacy policy's existing wording covers it, which [`docs/privacy-policy-pending.md`](../docs/privacy-policy-pending.md)
  records without changing a line.
- **Removed:** `Quiz.lastIncorrectAnswer`, `lastCorrectAnswer`, `lastErrorContext` (now
  `correction.errorContext`), and the string `Quiz.lastAnswer`. The commented-out
  `ErrorExplainerView` sits in the correction's branch of `QuizView`, taking
  `correction.errorContext`.
- **A new fixture**, `KONJUGIEREN_QUIZ_FIXTURE corrections`: eight questions, each with a wrong
  answer in the generator's comment that shows a kind of marking or link.
- **Verified on the iPhone 17 simulator** with a hardware keyboard: all eight fixture answers
  held and continued with keystrokes alone, the clock stood still through a hold and through a
  visit to a linked page, both links opened and returned to the held question with the keyboard
  back, and the sheet from a verb's page showed no verb link. On the iPad Pro 11-inch (M5), in
  light mode, the hold, the verb link, Back, and Return behaved the same, and the tints read
  well. There the card spans the screen's width, as it did before, so at Josh's request
  (2026-11-13) Continue is capped at 400 points and centered. Not
  tried: the software keyboard (which may cover Continue on a small phone; the view scrolls
  Continue into sight) and VoiceOver by ear. Tests: 16 new, 560 in all. Josh added the fixture to
  the shared scheme as a launch argument, unchecked.

## Phase 4: One More Try

**Suggestions:** T1.6. **Depends on:** Phase 3. **Status:** Done.

Treat a slip as "almost" and allow one more attempt. A right second attempt earns half the points
(5 where a first attempt earns 10). A wrong second attempt goes to Phase 3's correction.

- A slip is one edit by `VerbSearch.editDistance` after normalizing, or a missing umlaut or ß.
- **An answer that is itself another conjugation of the verb is not a slip.** "kommt" for
  "kommst" is one letter off and a grammatical error, the wrong person. Check
  `Verb.conjugations(matching:)` first and treat a match as a real error, which Phase 14 will name.
- A question gets at most one second attempt, whatever triggered it. Phase 14 adds diagnosable
  errors as a second trigger and must share this mechanism.
- The results list and the progress dots show which answers were right on the second attempt.

**Decided (Josh, 2026-11-13):**

- A slip earns a second attempt only in an answer of four or more letters.
- A right second attempt is counted apart from the correct answers ("8 correct, 1 on the second
  try") and has its own dot color.
- After the "almost" prompt, the first attempt stays in the field for the learner to edit.

**Ask Josh** to approve the wording of the "almost" prompt in both languages.

**Done when** a one-letter slip and a missing umlaut each prompt one more try, another cell of
the verb does not, half points are scored and shown, and tests pin each case.

**How it differed:**

- **Josh chose the wording on 2026-11-13**, from three drafts: "Almost! Try once more." /
  "Fast! Versuch es noch einmal." (over one pointing at the spelling and one naming half points),
  and "Second Try:" / "Zweiter Versuch:" for the separate count (over "Almost:"). A row right on
  the second attempt shows "First Try:" / "Erster Versuch:" with the slip.
- **fahrt for er fährt is not a slip.** The rule that an answer matching another cell is a real
  error catches it, since fahrt is ihr's Präsens and Imperativ. The "Done when" took a missing
  umlaut as the plainest slip, and it usually is (fahrst for fährst, ubernehme), but the
  textbook case is also a person error. The rule was kept as written; Phase 14, which names the
  error, can decide whether "wrong person or missing umlaut" deserves its own line.
- **Where the four letters are counted.** In the accepted spelling the answer is near, spaces
  excluded, so geb for gib is not a slip, and nothing compound ever falls under the limit.
- **"Missing umlauts and ß" means any number of them**, compared on bare spellings (ä to a, ß to
  ss) against every accepted spelling, digraph spellings included. So ubernahme for übernähme and
  uebernahme (one digraph, one missing) are slips although each is two edits away.
- **The mechanism.** `QuizItem.firstAttempt` holds the slip, and a question awaits its second
  attempt while that is set and `isCorrect` is nil. No separate state on `Quiz`. Phase 14 should
  set `firstAttempt` for a diagnosable error too, so that the one-attempt limit holds whatever
  triggered it, and may add a field saying why.
- **The clock keeps running** through the second attempt, since the learner is still answering.
  A slip is not written to `QuizErrorHistory`; a wrong second attempt is, as before.
- **Feedback.** A pop and a light tap, not the buzz, flash, and shake of a wrong answer. The
  orange of the "almost" line is also the dot color. The results' score color gives a second
  attempt half credit.
- **VoiceOver.** The "almost" line is announced, and focus stays in the field. The dot row's label
  now counts second tries ("3 correct, 1 on the second try, 2 incorrect, …"), as does the summary
  at the end. Nobody has listened to it.
- **Analytics:** none added, so nothing is staged in `docs/privacy-policy-pending.md`.
- **A new fixture**, `KONJUGIEREN_QUIZ_FIXTURE slips`: ten questions, each with a slip or a near
  miss in the comment on `Quiz.generateSlipsFixture()`.
- **Verified on the iPhone 17 simulator** with a hardware keyboard: fahrst prompted one more try,
  with the first attempt still in the field and the keyboard back, and faehrst then scored 5 and
  an orange dot; kommt for du went straight to the correction; weis and then weix went to the
  correction after one prompt. A three-question quiz from a verb's page showed the results: 20
  points, "Correct: 1 / 3", "Second Try: 2", and two "First Try:" lines. With four items in the
  results header, "Difficulty: Regular" wraps onto two lines on the iPhone; Phase 5 replaces the
  difficulty with levels, so it was left. Not tried: the iPad, the software keyboard, and
  VoiceOver by ear. Tests: 9 new, 569 in all.

## Phase 5: Levels

**Suggestions:** T2.3, T2.6, T6.7, M1. **Depends on:** nothing, though Phases 1 to 4 come first by
leverage. **Status:** Done.

Replace Regular and Ridiculous with levels ordered by use, following the report's ladder, each
level adding to the one before:

| Level | Roughly | Conjugationgroups added |
|---|---|---|
| 1 | A1 | Präsens Indikativ; Imperativ for du, ihr, and Sie |
| 2 | A1 to A2 | Perfekt Indikativ and the Perfektpartizip; Präteritum Indikativ of sein, haben, and the modals |
| 3 | B1 | Präteritum Indikativ of all verbs; Plusquamperfekt Indikativ; Futur Konjunktiv II; Präteritum Konjunktiv II of sein, haben, werden, and the modals; Plusquamperfekt Konjunktiv II; Futur Indikativ |
| 4 | B2 and above | Präsens Konjunktiv I, Perfekt Konjunktiv I, Futur Konjunktiv I; Präteritum Konjunktiv II of strong verbs; Präsenspartizip |

The verbs column of the report's ladder belongs to Phase 6.

- Some cells are restricted to certain verbs (the Präteritum of sein, haben, and the modals at
  Level 2). The generator must draw a verb that fits the cell, not a cell that fits a random verb.
- **T2.6.** Give fixed lower weights to conjugationgroups whose only variable part is an
  auxiliary: Futur Indikativ, Futur Konjunktiv I, and Futur Konjunktiv II. The weights are fixed
  per level, never adjusted by what the learner has done (T2.4's "No").
- **T6.7.** The new names must not tell a learner that part of the app is a joke.
- Replace the participle quota (one Präsenspartizip and two Perfektpartizip per 30 questions),
  which assumed both participles at every difficulty.
- Migrate the stored `quizDifficulty` setting. Revisit `ChangeDifficultyTip`, the difficulty tile
  on the start screen, the results row, `QuizActivityAttributes.difficulty`, and the `difficulty`
  parameter on `quitQuiz` and `completeQuiz`.
- **M1.** Send the level with `startQuiz`. Stage privacy lines in both languages: the policy now
  says "Quiz difficulty level (regular or ridiculous)".
- Correct `docs/feature-architecture.md` § Quiz, which the report found listing three and four
  conjugationgroups where the code had four and eight, and which said the arcade game's players
  shoot "by conjugating verbs". Rewrite both for the levels.

**Decided (Josh, 2026-11-13):**

- Levels are chosen by the learner, and nothing unlocks.
- The levels are named with words, not numbers or CEFR labels, along the lines of Beginner,
  Elementary, Intermediate, and Advanced. Propose the exact English and German names to Josh.
- A new install starts at Level 1.
- A stored Regular becomes Level 2, and a stored Ridiculous becomes Level 4.
- A right answer earns 10 points at every level. Ridiculous's doubling goes away, and each level
  has its own leaderboard (Phase 8), so scores never compare across levels.
- The wir Imperativ joins at Level 2.
- Präteritum Konjunktiv II at Level 4 is asked of strong and mixed verbs only, since a weak verb's
  (machte) repeats its Präteritum Indikativ.
- Scoped quizzes (My Verbs, a collection, a verb's page) use the learner's level.

**Done when** each level draws only its own cells, the restricted cells draw only their verbs,
the auxiliary-only groups appear at their reduced weight under a fixed seed, existing settings
migrate, `startQuiz` carries the level, and tests pin each level's pool.

**How it differed:**

- **Josh chose the names on 2026-11-13**: Beginner, Elementary, Intermediate, and Advanced, and in
  German Einstieg, Grundstufe, Mittelstufe, and Oberstufe (over Anfänger, Grundlagen, Mittelstufe,
  Fortgeschritten, and over Einsteiger, Grundkenntnisse, Aufbau, Experte). The German set is all
  nouns of course stages and avoids the masculine Anfänger.
- **Josh chose the weights the same day**, from three sets: Präsens and Perfekt Indikativ 3, every
  other finite conjugationgroup 2, and the three Futurs and both participles 1, the same at every
  level. A weight belongs to a conjugationgroup as a whole, so a participle's one cell is not as
  likely as a six-cell table. This replaces the participle quota. A restricted cell keeps its
  conjugationgroup's weight, so about one Elementary question in five is a Präteritum of sein,
  haben, or a modal, which Phase 6's two core questions per session may make redundant.
- **How the draw works.** `QuizLevel.pool` lists each level's conjugationgroups as
  `QuizPoolEntry` values (a `ConjugationTable`, its cells, a `QuizVerbs` restriction), written out
  per level rather than built by accumulation, so that each level reads like the table above.
  `QuizDraw` draws a conjugationgroup by weight, then a verb and a reading that the restriction
  admits, then a cell. Strong and mixed are judged per reading, so hängen is asked the Präteritum
  Konjunktiv II only in its strong reading. A conjugationgroup that no verb of the scope admits is
  left out, which keeps the Präteritum out of an Elementary quiz on a weak verb's page. Phase 6's
  bands belong in `QuizDraw` too.
- **The random source is injectable**: `Quiz(randomSource:)`, with `SeededRNG`. `Quiz` sorts the
  corpus before drawing, since `Verb.verbs` is a dictionary whose order changes between launches,
  so a seed draws the same quiz in every process.
- **A short quiz** (three questions on a verb's page) still asks distinct cells and no participle.
- **The setting moved to a new key**, `quizLevel`. On the first launch without it, a stored
  `quizDifficulty` migrates (anything but `ridiculous` becomes Elementary) and is removed. Both
  paths were tried on real simulator installs: the iPhone's stored Regular became Elementary, and
  the iPad's, set to Ridiculous for the test, became Advanced. A fresh install started at Beginner.
- **Not a segmented control.** A four-segment picker truncated "Intermedia..." on the iPhone, and
  the German names are as long. The levels are tiles like the App Icon picker's, each with a gauge
  (`gauge.with.dots.needle.0percent` to `100percent`) whose needle rises with the level; the Quiz
  tab's tile uses the same gauge. Josh has not judged this; it was not in the phase.
- **The tip.** `ChangeDifficultyTip` became `ChangeLevelTip`, "Choose Your Level" / "Wähle deine
  Stufe". TipKit treats a renamed tip as new while the `quizCompleted` event keeps its donations,
  so every learner who has finished a quiz will see it once more, which suits a new setting.
  Looking at it found an older bug: Settings attaches its popover tips to views that stay alive
  after the tab's first visit, and on the iPad the tip appeared over the Quiz tab's results the
  moment a quiz finished, pointing at nothing. Settings now attaches its tips, `PlayGameTip`
  included, only while it is on screen, and the tip waits for the next visit, where it points at
  Quiz Level. Tried on the iPad after a reinstall.
- **Text that named Ridiculous.** The onboarding quiz page's two sentences about difficulty now
  name the levels (Phase 13 rewrites the page), and `docs/description.md`, the App Store text,
  lists the levels in place of the two difficulties and the 2× multiplier.
- **Scoring.** Every level scores 10 a right answer. Until Phase 8, every level posts to the one
  leaderboard, so a Beginner score and an Advanced score now compete there. Nothing ships before
  Phase 8, so this was left.
- **Analytics.** The parameter `difficulty` became `level`, with the level's raw value, on
  `startQuiz` (new, M1), `quitQuiz`, and `completeQuiz`. Staged in
  [`docs/privacy-policy-pending.md`](../docs/privacy-policy-pending.md) as a changed line in both
  languages.
- **`docs/feature-architecture.md`** now gives the levels, the weights, and the draw. The arcade
  sentence the phase mentions had already been corrected on 2026-11-10.
- **The Live Activity** shows the level's name, through `QuizActivityAttributes.level`. It was not
  looked at.
- **No new fixture.** What needed seeing was the random draw, so the check typed a wrong answer
  into thirty real questions per level and logged each one's conjugationgroup and verb.
- **Verified on the iPhone 17**, in dark mode: the Quiz tab's tile, Settings' tiles, and the
  results row ("Level: Intermediate" fits on one line), in English and German. An Intermediate
  quiz asked only Intermediate's conjugationgroups, its seven Präteritum Konjunktiv II questions
  all of sein, haben, werden, or a modal; a Beginner quiz asked only the Präsens and the
  Imperativ. **On the iPad Pro 11-inch (M5)**, in light mode: the tiles, the onboarding page, an
  Advanced quiz (every conjugationgroup appeared, its Präteritum Konjunktiv II asked of abwerfen
  and vordenken), a Beginner quiz's results, and the tip. Not tried: VoiceOver by ear (each level
  tile reads its name, with the selected trait), the software keyboard, and the Live Activity.
  Tests: 18 new, 587 in all.

## Phase 6: Which Verbs Are Asked

**Suggestions:** T2.1, T2.2, T2.5. **Depends on:** Phase 5. **Status:** Done.

For the default quiz (not My Verbs, a collection, or a verb's page, whose verbs are chosen):

- **T2.1.** Draw from the level's frequency band, as decided below. The report notes that 83
  verbs carry placeholder frequency counts; check that none sits in the top 1,000 by accident of
  its placeholder. Level 4's band, the whole corpus, needs no `FrequencyBand` case.
- **T2.2.** Prefer base verbs. Every quiz includes one to three derivative (prefixed) verbs to
  practice prefix behavior, and otherwise draws unprefixed verbs and frequent derivatives.
- **T2.5.** Fix the share of strong and weak verbs per session, as Conjugar's Easy quiz fixes
  regular and irregular, and make sure that sein, haben, werden, and the modals recur.

**Decided (Josh, 2026-11-13):**

- **The band follows the level**: the 100 most frequent verbs at Level 1, 300 at Level 2, 1,000 at
  Level 3, and the whole corpus at Level 4. This supersedes the verdict's "top 300", which now
  describes Level 2.
- Half of a default quiz's verbs are strong or mixed.
- Every session includes at least two questions on sein, haben, werden, or the modals.

**Done when** a default quiz under a fixed seed draws only from the band, contains one to three
derivative verbs, meets the strong-and-weak share, includes the core verbs as decided, and scoped
quizzes are unaffected, with tests for each.

**How it differed:**

- **Josh chose the reading of T2.2 on 2026-11-13.** The phase text was at odds with itself: "one
  to three derivative verbs" against "otherwise draws unprefixed verbs and frequent derivatives".
  Read strictly, bekommen and verstehen could appear at most three times in all. Josh chose the
  looser reading. A prefixed verb in the top 300 (`QuizDraw.frequentDerivativeBand`) draws as
  freely as a base verb. Beyond it, a prefixed verb is a *rare derivative*, and where the band
  reaches that far (Intermediate and Advanced) exactly one to three questions ask one, chosen at
  random per quiz, and no other question may. At Beginner and Elementary no rare derivative
  exists, so the rule there is a floor: at least one question asks a prefixed verb. The top 100
  holds 24 prefixed verbs, all inseparable, so separable prefixes first appear at Elementary.
- **The placeholder check found 56, and Josh chose to fix the data.** Of the 83 verbs with
  `hp="y"`, 56 sat at ranks 937 to 994, put there by tranche 2's ratio from a common base:
  madigmachen, armmachen, drüberhalten, umeinanderstehen. Measured compounds of the same shape
  rank far lower (kaputtmachen #2321, schlechtmachen #3062). Offered a choice between moving the
  estimates and having the quiz skip provisional verbs, Josh chose to move them, which also fixes
  the widget's verb of the day, which already drew from the top 1,000. The new
  `verbdata/replace_inflated_estimates.py` places each of the 61 provisional verbs ranked above
  #1,200 beside a named measured verb, between two real counts, keeping `hp`. Moving only the 56
  would have lifted verklicken and verräumen into the band. The highest provisional verb is now
  verstehlen at #1151. A few left alone (schöntrinken, scheckiglachen, near #1160) look as inflated
  as the 61 did; they are outside every band, and moving them is a choice for another day. Ranks
  from #937 down shifted, so `docs/frequencies.txt` was regenerated. The pinned count of 83
  provisional verbs is unchanged.
- **How the mix works.** `QuizDraw.questions(mixesVerbs:)`, which `Quiz` sets only when the scope
  names no verbs, draws every slot's conjugationgroup by weight as in Phase 5. Then it gives
  slots roles (core, rare derivative, derivative, free) and splits strong and weak exactly in
  half, and only then draws each slot's verb from those that fit. So the counts are exact, not
  likely. A restricted kind counts on its own: Elementary's Präteritum and Intermediate's
  Präteritum Konjunktiv II are core questions by their verbs alone. Since haben is mixed in the
  data, every core question is also strong. Strength is judged by the asked reading, as in Phase 5.
  "Half of a default quiz's verbs" is read as half its questions, rounded down.
- **A bug the 30-question tests hid.** The first version could give the core role to a slot that
  was already core-only, so a quiz with one restricted Konjunktiv II question and no other core
  verb counted it twice. Thirty questions draw enough core verbs by chance to hide this; the
  ten-question test, written with Phase 7 in mind, caught it at two seeds of 40.
- **A slowdown the tests did not fail on.** Refactoring the draw made the unmixed path filter the
  whole corpus for every question, and `QuizLevelTests`, which draws 40,000 questions at a time,
  went from about 3 seconds to 688 while passing. Read the per-suite times, not only the verdict.
  The full suite now runs in 47 seconds, 11 of them `QuizVerbMixTests`, which draws each level's
  40 quizzes once and shares them. A mixed quiz costs about 50 ms in a debug build.
- **The level's description** in Settings now names verbs too: "This setting determines which
  conjugationgroups and verbs quizzes ask about…", in both languages. The App Store description's
  levels bullet gained "and verbs". The onboarding page was left; it is still true, and Phase 13
  rewrites it.
- **Phase 7** will make the default quiz ten questions. The rules are per draw, so a ten-question
  quiz gets five strong questions, two core, and one to three rare derivatives, which is a larger
  share of rare derivatives than at thirty. Phase 7 should decide whether Ten More draws a fresh
  mix of ten each time (the simple path) or one mix for the session.
- **No analytics and no privacy lines.** Nothing new is sent; `startQuiz` already carries the level.
- **Verified on the iPhone 17**, in dark mode, by answering every question of a real quiz wrongly
  and logging each verb. In English at Beginner, all thirty verbs were in the top 100, with three
  core questions and eight frequent derivatives (verstehen, erklären). In German at Mittelstufe,
  exactly one rare derivative (unterscheiden, #329) appeared, and the four Präteritum Konjunktiv II
  questions were dürfen, müssen, wollen, and sollen. The results screens were fine in both
  languages. **On the iPad Pro 11-inch (M5)**, in light mode and English: the new description
  under the level tiles, and an Advanced quiz with one rare derivative (hineinrufen, #3053),
  rarer bases such as gären, melken, and dingen, and three core questions. Not tried: a scoped
  quiz on a device (a unit test covers it), and VoiceOver, which this phase gave nothing new to
  say. Tests: 14 new, 601 in all.

## Phase 7: Ten Questions, Then Ten More

**Suggestions:** T2.7, T3.1, T6.5, M2, M3. **Depends on:** Phases 3 and 5. **Status:** Done.

- **T2.7.** The default session is ten questions, with an offer to continue. Josh agreed
  reluctantly, since ten questions are far from comprehensive, in the hope that a shorter quiz
  will be started and finished more often. Continuing should feel like the same session growing,
  not a new quiz.
- **T3.1.** Re-ask a missed question once, a few questions later, and not again whatever the
  second answer. A question missed near the end is re-asked before the results.
- **T6.5.** A setting, default off, that shows the clock. While it is off, the quiz screen shows
  no time.
- Revisit what `Quiz.questionCount` gated: the Live Activity, the tip donation, and `isRanked`
  (Phase 8 settles ranking; until then, decide with Josh what a ten-question quiz does).
- **M2 and M3.** Josh confirmed both on 2026-11-13: on the next launch after a quiz was abandoned by leaving
  the app, report the question reached; and report the time from start to quit in bands (the
  report suggests that under three seconds is exploration and over forty a struggle). Stage the
  privacy lines.

**Decided (Josh, 2026-11-13):**

- The results of the first ten appear with a "Ten More" button, which continues the same session
  and adds to its score.
- A re-ask is added beyond the ten, and a right re-ask earns half points (5), like a second
  attempt.
- No 30-question choice remains. Ten More, twice, reaches thirty.
- With the clock hidden, the results show no time either.
- Build both M2 and M3.

**Done when** the default quiz is ten questions and can continue, a missed question returns once,
the clock hides by default, the Live Activity and tip follow the new length as decided, and tests
pin the re-ask placement and the continuation.

**How it differed:**

- **Josh decided four things on 2026-11-13**, each the recommended option. (1) Until Phase 8, a
  default session posts its first round's score, re-asks not counted, to the existing leaderboard
  when the first results appear, and Ten More's points are never posted. That is Phase 8's rule
  applied early, so Phase 8 has only to change where the score goes (`Quiz.firstRoundScore`).
  (2) My Verbs and collection quizzes become ten with Ten More too, and a verb page keeps its
  three questions with no Ten More (`QuizScope.continues`). (3) The Live Activity starts for every
  ten-question round, with a total that counts the session so far, and shows no time while the
  clock is hidden. (4) M3's bands are 0-3s, 3-15s, 15-40s, 40s-2m, and 2m+.
- **Decided in the session, not asked.** Ten More has no limit; "Ten More, twice, reaches thirty"
  was read as how to reach thirty, not as a cap. Each round of Ten More draws a fresh mix of ten
  (Phase 6's open question), so every round, the ranked first included, is balanced, at the cost
  of up to nine rare derivatives in thirty questions. A verb page's quiz re-asks too. A re-ask may
  still earn a slip's second attempt, and a right re-ask earns 5 on either attempt.
- **How it works.** `Quiz.questionCount` (the static) is now a round's 10; the instance's
  `questionCount` is the rounds' questions so far, re-asks excluded, and a round ends when
  `currentIndex` passes the last item, re-asks included. A wrong final answer inserts
  `QuizItem.reasked()` `Quiz.reaskGap` (3) questions on, or at the round's end. `score`,
  `correctCount`, and the other counts are computed from the items' `points` rather than kept
  alongside, which made re-asks and Ten More bookkeeping-free. `continueSession()` appends a
  fresh draw and restarts the clock and the Live Activity. `QuizActivityAttributes.totalQuestions`
  moved into the content state, since re-asks grow it mid-activity, and `elapsedTime` became
  optional.
- **What a learner sees.** The correction says "This question will come up again." / "Diese
  Frage kommt noch einmal."; a re-ask's card and results row say "Asked Again" / "Noch einmal
  gefragt"; its dot is a diamond; the results add "Asked Again: 2 / 3" and "Ten More" / "Zehn
  weitere". The results' header became a wrapping flow (five items no longer fit an iPhone's
  line), and so did the dot row, which passes thirty dots after two rounds of Ten More. Josh has
  not judged any of the wording.
- **The clock** is a new setting, Quiz Clock / Quiz-Uhr, Hide / Show (Ausblenden / Anzeigen),
  under Quiz Level. The clock still counts while hidden.
- **Strings that said 30 or "timed"** changed: the All Verbs line on the start screen, Start's
  VoiceOver hint, the onboarding quiz page ("Take ten-question quizzes"), and `TryQuizTip`. The
  App Store description was not touched; it names no count.
- **Analytics.** `completeQuiz` is now sent at each round's results with `questionCount` (10, 20,
  …), so Ten More shows without a signal of its own. `quitQuiz` gained `duration` (M3), wall-clock
  from the start, background included. The new `abandonQuiz` (M2) is sent at launch for each quiz
  the last run left mid-question; `QuizAbandonment` keeps one entry per `Quiz` instance, since a
  sheet's quiz can run beside the tab's. All staged in
  [`docs/privacy-policy-pending.md`](../docs/privacy-policy-pending.md), with the section 6
  sentence about which quizzes post.
- **Fixtures** are cut or repeated to a round's ten; the screenshot fixture now asks its first ten,
  and `scripts/take_screenshots.sh` answers as many questions as the fixture holds.
- **One test changed its claim.** `QuizVerbMixTests.frequentDerivativesDrawFreely` asserted that
  40 thirty-question quizzes held more derivatives than three per quiz. At ten questions that
  average fell to 2.7, so it now asserts that some quiz holds more than three.
- **Verified on the iPhone 17**, in dark mode, with the `corrections` fixture: in English, a miss
  showed the come-up-again line and a diamond four places on, the re-ask came with its badge,
  answers after it scored 5 each (85 for seven right and three re-asks), the results showed Asked
  Again and Ten More and no time, and Ten More resumed with the score and the keyboard. In German,
  the clock set to Anzeigen in Settings, a round of misses showed Zeit in the quiz and the results,
  the time carried across Zehn weitere (25 s, then 39 s), and 40 dots wrapped to two lines. **On
  the iPad Pro 11-inch (M5)**, in light mode and English: the start screen, the correction line,
  the badge, the results (two re-asks, 10 points), Ten More with typing at once, and the clock
  setting. Found by looking: the results row's "Asked Again" was first a `Label`, whose icon a
  `List` set apart in a column of its own. Not tried: VoiceOver by ear, the software keyboard, the
  Live Activity, a real abandonment across a relaunch (unit-tested), and Game Center.
- **Seen, not changed.** The quiz card's red border stays lit after a wrong answer until the next
  one, since it follows a toggled flag; this predates the phase. In English, the Rate or Review
  line in Settings ends in German ("Füge deine hinzu."). Tests: 19 new, 620 in all.

## Phase 8: Leaderboards by Level

**Suggestions:** Decision 4. **Depends on:** Phases 5 and 7. **Status:** Done.

Re-scope the Game Center leaderboard by level: one leaderboard per level, with a ranked session
defined so that scores within a level compare. This replaces the rule that only a full quiz over
every verb ranks; `QuizScope.isRanked` changes accordingly, and scoped quizzes stay unranked.

- `GameCenter.submitScore` needs the leaderboard to post to. Update `GameCenterReal`, the dummy,
  and the results screen's leaderboard button, which should open the level's leaderboard.
- **Josh asked for help with App Store Connect.** Write `docs/game-center-setup.md`, a
  step-by-step walkthrough for creating the per-level leaderboards: where in App Store Connect,
  each leaderboard's ID exactly as the code uses it, score format, sort order, and the English and
  German display names. Read Apple's current documentation for the steps rather than writing them
  from memory, and note that new leaderboards ship with an app version. Phase 23 adds achievements
  to the same document.
- Once Josh has created them, try posting a score from a development build signed in to Game
  Center, if the sandbox allows it, and record the result.

**Decided (Josh, 2026-11-13):**

- A ranked score is the score of the first ten questions of a default session at a level,
  counting second-attempt half points and not counting re-asks. Every ranked score therefore has
  the same ceiling, 100. Expect many ties at 100, and raise with Josh whether anything should
  break them, given that the clock is hidden by default.
- The existing leaderboard, `Leaderboard`, is retired: nothing posts to it, and its button goes.

**Done when** a ranked session posts to its level's leaderboard, an unranked one posts nowhere,
the walkthrough exists, and tests pin which sessions rank.

**How it differed:**

- **Josh decided four things on 2026-11-14**, each but one the recommended option. Nothing breaks
  ties at 100 (over packing the time into the score, or weekly recurring boards). Each
  leaderboard is named for its level alone, Beginner to Advanced and Einstieg to Oberstufe.
  Settings' button opens Game Center's list of all the boards (not the recommended current
  level's), and the results' button opens the quiz's level's board. The old `Leaderboard` is
  archived on release day, not now, since the shipped app still posts to it and opens it.
- **Claude created the four leaderboards in App Store Connect**, driving Josh's Chrome, rather
  than leaving the walkthrough for Josh to follow. Each is Classic, Integer, 0 to 100, Best Score,
  High to Low, with English and German names and a description, no suffix, and no image, and each
  is in "Prepare for Submission". None was added for review; that happens with the 2027 version.
  The form defaults to Low to High, which the walkthrough warns about. Afterward the four
  leaderboards' range and sort order were read back from their pages.
- **The IDs are `konjugieren.level.<level>`**, from `QuizLevel.leaderboardID` in `GameCenter.swift`.
  App Store Connect makes an ID permanent, so a test pins each literally, and the prefix leaves
  room for the siblings' own.
- **`GameCenterResources.gamekit` was found mid-phase.** The repo already held Xcode's local
  Game Center configuration, copied into the app by the build. The four leaderboards were added to
  its JSON by hand, in the shape of its existing entry (App Store Connect's API attributes). The
  build only copies the file, so **Josh should open it in Xcode once** to confirm the editor reads
  them. Apple's docs now describe configuring leaderboards in Xcode and pushing to App Store
  Connect, which this phase did not use.
- **The walkthrough, [`docs/game-center-setup.md`](../docs/game-center-setup.md)**, records what
  exists rather than only how to make it: the five leaderboards, their settings and descriptions,
  the steps as App Store Connect showed them, what to do on release day (add each for review with
  the version, archive `Leaderboard`, perhaps change the default), and how to test. Apple's
  help pages were read for it; the GameKit article was read through its JSON, since its page
  renders by script.
- **`GameCenterDummy` became `GameCenterSpy`**, which records submissions and shown leaderboards,
  in the way `AnalyticsSpy` records signals. The unit-test world uses it, and nothing else used the
  dummy. `submitScore(_:level:)` is no longer `async`: `GameCenterReal` starts its own `Task`, so
  `Quiz` calls it inline and a test sees the call at once without waiting on a detached task.
- **The protocol** has `submitScore(_:level:)`, `showLeaderboard(level:)`, and `showLeaderboards()`
  (`GKAccessPoint.trigger(state: .leaderboards)`). `QuizScope.isRanked` did not change, since
  Phase 7 had already ranked a default session's first round; only where the score goes did.
- **Strings.** Settings' row became "View Leaderboards" / "Bestenlisten anzeigen", with a new
  description naming one board per level and other learners at the same level (the old one said
  "game scores", though the game never posted) and a new hint. The results' hint now says it opens
  the board for this quiz's level. `GameCenter.viewLeaderboardDescription` was replaced by
  `GameCenter.viewLeaderboardsDescription`. No analytics changed; Settings' tap still sends
  `tapViewLeaderboard`. Section 6 of the privacy policy gets two revised sentences, staged.
- **Tests:** `QuizLeaderboardTests` (7 functions): each ID, distinct IDs, each level's ranked
  session posting 100 to its own board, the level fixed at the quiz's start, a re-ask excluded
  and a second attempt's half points included, Ten More posting nothing, and three scoped quizzes
  posting nothing. 627 in all, every one passing.
- **Not verified on a device.** Both leaderboard controls appear only when signed in to Game
  Center, and neither simulator was; signing in needs Josh's Apple ID. On the iPhone 17 the
  Settings screen was read through its accessibility tree and showed no leaderboard row, as
  expected, and on the iPad Pro 11-inch (M5) the app launched and rendered. The German strings,
  the Game Center sheets, and posting a score were not seen there.
- **Josh tried it on his iPhone the same day**, and the post could not be confirmed. With the
  scheme's GameKit debug mode on, Game Center offered no leaderboards at all, the live one
  included; with it off (now off in the shared scheme), the build saw only the live
  `Leaderboard`, and an Elementary quiz's View Leaderboard showed "Cannot Connect". The four level
  boards are probably invisible until they are added to an app version, and none exists before
  2027. Josh chose to test then, after the version is created and before it is submitted;
  [`docs/release.md`](../docs/release.md) carries the reminder, and
  `docs/game-center-setup.md` the details. The results screen and both buttons were seen working on the device.
- **A layout fix from the same try.** At Josh's text size, "Conjugationgroup:" on the quiz card
  left "Präsens Indikativ" a one-word column. `QuizView.labeledRow` now puts the value beside the
  label when the line fits and below it when it does not (`ViewThatFits`). Checked on the iPhone 17
  simulator at the default and the largest standard text sizes.

## Phase 9: Choosing What to Practice

**Suggestions:** T2.8. **Depends on:** Phases 5 and 6. **Status:** Done.

Let the learner choose the scope: conjugationgroups, a verb set (a frequency band, a collection
or ablaut group, My Verbs when it has entries), or both. The default remains the classic-style
quiz with this plan's modifications. Browse Phase 13's All Verbs and My Verbs picker is the place
to start; scopes by verb already exist as `QuizScope` constructors, and scopes by conjugationgroup
do not.

- A chosen scope is unranked.
- A beginner opening the tab should not meet a wall of options. Keep the custom choice one step
  away from Start.

**Decided (Josh, 2026-11-13):**

- A custom scope is remembered between launches and offered beside the default quiz, which stays
  the default.
- A custom scope may include any conjugationgroup, above the learner's level or not. It is the
  learner's explicit choice, and a teacher's shared set (Phase 10) needs any combination.

**Ask Josh** to judge the layout on a phone and an iPad before polishing.

**Done when** a learner can start a quiz over chosen conjugationgroups, a chosen verb set, or
both; the default is unchanged; and tests pin scope construction.

**How it differed:**

- **The layout.** The Quiz tab's picker gained a third segment, Custom (Eigene Auswahl). Its start
  screen shows a sliders symbol, "Custom Quiz", a card summarizing the choice (Conjugationgroups,
  Verbs), and Choose or Change, which pushes `CustomQuizEditor` onto the tab's stack: one row per
  table with its second name (Imperfekt, Befehlsform), and one row per verb set, each section
  opening with "Set by Your Level". Ablaut groups are a further push, a list of the groups with
  their verb counts. Empty, the segment says what to do and Start is disabled. The tab opens on All
  Verbs at every launch, so the default stays the default and Custom is one tap from Start. **Josh
  has not judged the layout**, which the phase asks for before polishing.
- **Decided in the session, not asked.** Each is a guess Josh can overrule. (1) A part left
  unchosen is the level's, so tables alone ask the level's band and a verb set alone asks the
  level's conjugationgroups. (2) A chosen table's kind is Advanced's, so the Präteritum is asked of
  every verb and the Imperativ of wir too, at any level. (3) The Präteritum Konjunktiv II keeps
  Advanced's restriction to strong and mixed readings and the core verbs, but when no verb of the
  set fits it (My Verbs of weak verbs), it is asked of every verb rather than dropped, since the
  learner chose it (`QuizDraw`'s `relaxesRestrictions`). (4) A band or every verb is mixed as the
  default quiz is; a collection or My Verbs is not. (5) The top-100 collection is offered only as
  the band, which holds the same verbs. (6) My Verbs is listed only while it has verbs, or while it
  is the stored choice. (7) Only one verb set at a time, not a union of several.
- **Kept between launches** in `Settings.customQuiz`, as `groups=…&verbs=…` with permanent keys
  (`ConjugationTable.articleKey` and the collection keys), so Phase 10 can put the same string in a
  link. The setting is not shown in Settings.
- **Never ranked**: `QuizScope.isRanked` now also requires `custom == nil`. A custom quiz has Ten
  More, a Live Activity, and the tip donation, like any ten-question quiz.
- **Analytics.** A new `source` value, `custom`, and a new `startQuiz` parameter, `customChoice`
  (`conjugationgroups`, `verbs`, or `both`), which says what kind of choice without saying which. A
  custom quiz over a collection sends `collection` as a collection's quiz does. Staged in
  [`docs/privacy-policy-pending.md`](../docs/privacy-policy-pending.md) in both languages, with the
  section 6 sentence naming custom quizzes among those that post nothing.
- **Strings.** The picker's VoiceOver label, "Verbs to Quiz", no longer fit a picker that also
  chooses conjugationgroups and became "What to Quiz" / "Was abgefragt wird". `L.VerbCollection`
  gained a `verbCount` accessor for its existing plural string, after the ablaut list first said
  "1 Verbs".
- **Found by looking.** The rows' second names first rendered in a dim red: inside a `Button`,
  `.secondary` derives from the button's tint, the app's red. `Color.secondary` is fixed.
- **Tests:** `CustomQuizTests`, 21 functions (some looped, since Swift Testing builds `arguments:`
  off the main actor, where these types' conformances are not available): the stored form pinned
  and round-tripped, every table and verb-set key, unknown keys dropped, each level's pool, chosen
  tables at Beginner, the restriction and its fallback, never ranked, which sets are mixed, the
  setting's persistence, and, nested in `QuizTests`, sessions that ask only the choice, post no
  score, and send `custom`. 648 in all, every one passing.
- **Verified on the iPhone 17**, in dark mode: the empty Custom segment, the editor, a choice of
  Präteritum Indikativ and Präsens Konjunktiv I kept across a relaunch, Modal Verbs chosen, a quiz
  that asked sollen in the Präteritum, and the summary and editor in German, where "Eigene Auswahl"
  fits its segment. **On the iPad Pro 11-inch (M5)**, in light mode and English: the three
  segments, the empty state, the editor (a full-width plain list, with no My Verbs row since the
  iPad has none), the ablaut list, choosing singen, the summary, and a quiz that asked singen in the
  Perfekt. Not tried: VoiceOver by ear, the Live Activity, and Ten More on a custom quiz
  (unit-tested).

## Phase 10: Practice Sets to Share

**Suggestions:** T2.9, Decision 8. **Depends on:** Phase 9. **Status:** Done.

Make a chosen scope shareable as a link and as a QR code, so a teacher can hand a class one
practice set without accounts or a server. One Swiss institution brought Conjuguer more downloads
than every other source combined, and this is the smallest step toward that channel.

- Encode the scope (level, conjugationgroups, verb set, length) in a `konjugieren://` link under
  the deeplink grammar of the browse plan's Phase 11. Opening it shows the practice set with Start,
  rather than starting a quiz unasked. Browse Phase 16 decided against `quiz/start?list=<key>`
  for collections; reconsider the route's shape for scopes generally, and keep existing links
  working.
- There is no web domain (the browse plan's decision), so shared text carries the
  `konjugieren://` link and the App Store link.
- Generate the QR code on the device, with a full-screen view a teacher can project.
- The simulator cannot show whether the Camera app offers to open a `konjugieren://` QR code.
  Ask Josh to try it on his phone, and record the result.
- Analytics: the `sharedLink` source exists; add a signal for sharing a practice set and stage
  its lines.

**Done when** a shared link and a scanned code both open the same practice set, an invalid link
fails gracefully, and tests pin encoding and decoding of every scope.

**How it differed:**

- **Decided by Josh (2026-11-14), asked before building.** (1) Opening a set shows a sheet with
  Start, which runs the quiz in a sheet over it, and Keep as My Custom Quiz, which replaces the
  learner's own custom quiz only when tapped. (2) A shared My Verbs carries its verbs, by infinitive,
  so a teacher can star this week's verbs and share them; the session capped the list at 100 so that
  a projected code stays coarse enough to scan. (3) The length does not travel: every set is ten
  questions, then Ten More, and a length can be added later without breaking links.
- **The route.** `konjugieren://quiz/set?groups=…&verbs=…&level=…&source=…`, the quiz route with a
  `set` target and the custom quiz's stored form as its query. `quiz/start` and every other target
  still open the Quiz tab, so existing links keep working. Browse Phase 16's reason for not building
  `quiz/start?list=<key>` still holds for collections, whose `list/<key>` page has Quiz one tap away;
  a set has no page of its own, so its link opens the sheet.
- **Decided in the session, not asked.** Each is a guess Josh can overrule. (1) The level travels
  only while a part is left to the level, so every student is asked the same set whatever their own
  level; a quiz over the set asks at that level through a new `QuizScope.level`, without touching
  the learner's setting. A kept set, like any custom quiz, uses the learner's level. (2) A list of
  verbs is a new `QuizVerbSet.list`, stored as `infinitives=gehen,kommen` rather than in `verbs=`,
  because the infinitive `sein` equals the sein collection's key. The editor lists a kept list only
  while it is the choice, since nothing in the editor can build one. (3) A link naming
  `verbs=myVerbs` drops that part, since it would ask the opener's own verbs. (4) The sheet shows over
  whatever tab is open rather than switching to the Quiz tab, and a later link replaces it. (5) The
  QR code's link says `source=qrCode` and the shared text's `sharedLink`, a new source value, so
  `startQuiz` can tell a projected code from a forwarded message. (6) Share lives only on the Custom
  segment, as a menu of Share Link and Show QR Code beside Change; the practice-set sheet does not
  share onward. (7) The QR view draws dark modules on white in both appearances, keeps the screen
  awake, and shows the set's summary beneath the code.
- **Invalid links.** A `quiz/set` link that names nothing this version knows opens a sheet saying
  "Practice Set Not Found", with a line that the link may be cut short or need a newer app, rather
  than doing nothing. Unknown keys, unknown infinitives, and an unknown level are dropped and the
  rest kept.
- **Analytics.** `tapSharePracticeSet` (`method` `link` or `qrCode`, and `customChoice`),
  `viewPracticeSet` (`source`, and `outcome` `opened` or `invalid`), `tapKeepPracticeSet`, and the
  `qrCode` source on the quiz signals. None names a conjugationgroup or a verb. Staged in
  [`docs/privacy-policy-pending.md`](../docs/privacy-policy-pending.md) in both languages.
- **Found by looking.** The QR caption first joined tables and verbs with a `·`, which read
  ambiguously beside a list's own "Verb List · 14 verbs", so the summary now takes two lines. Share
  sat a point taller than Change, a Menu's label being taller than a NavigationLink's. On the iPad
  the sheet's form-sheet height clipped the Keep footer, so it is presented page-sized.
- **Tests:** `PracticeSetTests`, 27 functions: the link's pinned form, every set, table, verb set,
  list, and level round-tripped, the list's stored form and the `sein` collision, nine links that
  name nothing, a link that keeps what it can read, My Verbs shared as a capped list, the level
  travelling only when needed, the scope, the share text, the generated QR code read back by Core
  Image's detector, a hundred long infinitives still fitting a code, and the kept list's
  persistence; in `DeeplinkTests`, the `quiz/set` route, its failure, `quiz/start` unchanged, and a
  later link replacing a set; nested in `QuizTests`, a session at the set's level, `startQuiz`
  naming `qrCode` and the set's level, and no score posted. 675 in all, every one passing.
- **Verified on the iPhone 17**, in dark mode: a 14-verb set opened by `simctl openurl`, its quiz
  (lesen in the Perfekt), Quit back to the set, Keep, the kept set on the Custom segment after a
  relaunch, Share's menu, the share sheet (Copy gave the expected text and link), the QR view, and
  the invalid link; in German, a set at Grundstufe ("Nach Stufe: Grundstufe · Die 300 häufigsten
  Verben") and the QR view. **On the iPad Pro 11-inch (M5)**, in light mode and English: the set's
  sheet, Keep, the share sheet as a popover anchored to Share, and the QR view. The QR codes in the
  iPhone's and the iPad's screenshots decode to the exact link. Not tried: VoiceOver by ear, the
  Live Activity of a set's quiz, and Ten More on one (unit-tested).
- **Waiting on Josh's phone:** whether the Camera app offers to open a `konjugieren://` QR code. The
  simulator has no camera. Record the result here.

## Phase 11: The Practice Record

**Suggestions:** T3.3 (the record), T3.4, T3.5, T6.4. **Depends on:** Phase 7. **Status:** Done.

Give the quiz a memory: a small record per item, a box and a due date, moved up the ladder of 1,
3, 7, 14, and 30 days by a right answer and back to the start by a wrong one. Josh's verdict on
the intervals: do not agonize over the numbers.

- **T3.5. Two kinds of item.** For a strong or mixed verb, an item is one of its key conjugations
  (`Verb.keyConjugations` gives them). For a weak verb, an item is a pattern, a conjugationgroup
  and person, shared by every weak verb. Decide and document how each question maps to the item
  it exercises, and test the mapping across conjugationgroups and the separable, inseparable, and
  -ieren verbs.
- **Reuse `ReviewSchedule`**, generalizing it rather than writing a second ladder, and store the
  record in the App Group, since Phases 22 and 24 need it outside the app.
- **T6.4.** Record each answer as it is given, so a learner who quits after six questions has
  still practiced six. The trombone stays.
- Every scope writes to the record, unless Josh decides otherwise.
- Stage the privacy change: the policy's "does not record your quiz answers, your scores" becomes
  "does not send", with a sentence that the practice record stays on the device.
- `QuizErrorHistory` has no reader but the disabled explainer. Decide with Josh whether the record
  supersedes it.

**Decided (Josh, 2026-11-13):**

- **One schedule.** The review card above the verb list reads the practice record: a looked-up
  verb enters the record, and the card offers whatever is due there. Browse Phase 15's per-verb
  `ReviewSchedule` on `LearnerVerbs.Entry` is folded in, with a migration for existing entries.
  Keep the card's rules that Josh set in that phase (a dismissal before revealing is no review; a
  later lookup sends a verb back to the first box) unless the merge makes one meaningless, and if
  so, ask.
- A default session mixes in up to about three due items of its ten, so a learner who never opens
  Review still relearns.
- Settings gains a Reset Practice control, behind a confirmation, as Clear sits in My Verbs.

**Done when** every answer updates its item, the ladder advances and resets as specified, quitting
keeps what was answered, the record survives a relaunch, and tests pin the item mapping and the
schedule.

**How it differed:**

- **Decided by Josh (2026-11-14), asked before building.** (1) The merge made one of the card's
  rules meaningless: a weak verb has no items of its own, since its answers move patterns shared
  by every weak verb, so a lookup of one had nothing to schedule. Josh chose to offer **strong and
  mixed verbs only** on the card, from a lookup or a quiz answer alike, and to drop weak verbs'
  schedules in the migration (over a card-only item for weak verbs, and over keeping the card's
  per-verb schedule as a third kind of item). (2) `QuizErrorHistory` stays, and Reset Practice
  clears it too. It has a second reader the phase text missed: the Tutor's Recommendations sheet
  counts its misses by conjugationgroup. It also keeps the typed answers, which the record does not.
- **The mapping (T3.5), decided in the session.** A strong or mixed reading's question maps to
  the key conjugation of the **stem its cell is built on**: the Präsens Indikativ, Präsens
  Konjunktiv I, Imperativ, and Präsenspartizip to the Präsens (fährt); the Präteritum Indikativ and
  Konjunktiv II to the Präteritum (fuhr); the Perfektpartizip and the four Perfekt and
  Plusquamperfekt tables to the Perfekt (ist gefahren). The three Futurs are patterns for every
  verb, since werden and the infinitive show nothing of a strong verb. Strength is per reading, as
  the quiz judges it. Prefixed strong verbs (aufstehen, verstehen) have their own items. Separable,
  inseparable, and -ieren weak verbs share machen's patterns. The cost of this choice: a slip in
  wir fahren counts against fährt, though the plural keeps the infinitive's vowel.
- **Keys** are strings, `key:fahren:0:praeteritum` and `pattern:praeteritum_indikativ:ss`, built
  from `ConjugationTable.articleKey` and `PersonNumber` raw values, so that the widget, which has no
  corpus, can read the record. Tests pin them.
- **The ladder, decided in the session.** `ReviewSchedule` was generalized, not duplicated:
  `lookedUp` became `start`, and `answered(correctly:)` and `new` were added. A wrong answer always
  starts an item over. A right one moves it up **only when it is due**, so that a pattern asked
  three times in one session cannot climb three boxes in an afternoon; Leitner's spacing would
  mean nothing otherwise. A new item answered right enters the second box (three days), and one
  answered wrong the first (tomorrow). A slip's right second attempt counts as right. A re-ask is
  just another answer: after a miss the item is not due, so a right re-ask leaves it in the first
  box.
- **Where it lives.** `Shared/PracticeRecord.swift` (the items and the record, `nonisolated`, in
  the widget too) and `PracticeStore` (`Current.practice`), saving JSON under `practiceRecord` in
  the App Group's defaults through the same `GetterSetterReal` as `LearnerVerbs`. The review card's
  fields left `LearnerVerbs`; `recordOpen` lost its `source` and the store its review methods, and
  the verb page now records the open and the lookup separately.
- **The migration** runs once, when no record is stored. It reads `LearnerVerbs`' old `review`
  field, or for an entry from before browse Phase 15 its last open, and gives each strong reading's
  three key conjugations that schedule. Reset saves an empty record rather than removing the key,
  so a reset is not undone by a second migration. On the iPhone simulator's real install,
  aufstehen came across in box 2 and overdue, and was the first card offered; ahnen, weak, was
  dropped.
- **Due items in the default quiz, decided in the session.** Up to three per round of ten, the
  most overdue first, placed at random among a draw of seven, in Ten More rounds too. Only the
  default quiz mixes them in; a scoped quiz asks what was chosen. An item is skipped when the
  level does not ask its cell (a Präteritum key conjugation at Elementary, where the Präteritum is
  sein's, haben's, and the modals') or its verb is beyond the level's band. Josh rejected letting
  what was opened shape quizzes (T2.4), and the band keeps a looked-up rare verb out of a
  Beginner's quiz; Phase 12's Review will ask those. Due questions sit outside Phase 6's mix, which
  balances the other seven, so a round with three due items may have fewer than five strong
  questions or a fourth rare derivative.
- **The card's caption** now says how the verb got there: "Looked up 3 days ago" ("Vor 3 Tagen
  nachgeschlagen"), or "Practiced 3 days ago" ("Vor 3 Tagen geübt") when a quiz answer came after
  the lookup. The card shows the due reading's key conjugations and gloss, so fahren's two readings
  are offered one at a time. Revealing raises only the due key conjugations; one not due keeps its
  place. The Suppress Review Card description now says "a strong verb you looked up or practiced".
- **Reset Practice** ("Übungsstand zurücksetzen") sits in Settings' last card, beside Show
  Onboarding and Play Game, while there is a record or a kept wrong answer. An alert confirms it,
  as Clear does in My Verbs. Its description began "This setting erases", after Delete Chat
  History, until looking showed its neighbours saying "This button …", and it now says the same.
  It plays no sound.
- **Analytics.** `tapResetPractice`, with no parameters, on confirmation. Staged in
  [`docs/privacy-policy-pending.md`](../docs/privacy-policy-pending.md) in both languages, with a
  paragraph saying the practice record stays on the device and is never sent. The "does not
  record" to "does not send" change was already staged by the browse plan's Phase 12.
- **VoiceOver.** No new quiz state needs an announcement: recording is silent, and a due item is
  an ordinary question. The card's caption is read as before, and the alert is the system's.
- **Tests:** 699 in all, 24 more than Phase 10's: 32 new, and `ReviewScheduleTests` cut from 15 to
  7, its card tests having moved. `PracticeItemTests` (11 functions: pinned and
  round-tripped keys, unreadable keys, every table of a strong verb, weak, separable,
  inseparable, and -ieren verbs sharing patterns, prefixed strong verbs, hängen's two readings,
  lookups, items asking their own cell back, and the stems agreeing with the verb page's key
  conjugations), `PracticeRecordTests` (14: the ladder through answers, due order, lookups, the
  card's review and snooze, the card's choice and caption, weak patterns never on the card, a
  relaunch, the migration, and a reset that stays), `QuizPracticeTests` nested in `QuizTests` (6:
  answers kept on quit, every scope writing, due items within level and band, at most three, none
  in a scoped quiz), `QuizErrorHistoryTests`' clear, and `ReviewScheduleTests` rewritten for the
  ladder alone. Run in English with
  `xcodebuild -testLanguage en`, all pass (697, and the 2 environment-gated harnesses skipped).
  **Run through `run_tests.sh`, 10 fail before and after this phase:** `MixedCaseAccessibilityTests`
  and a `VerbCollectionTests` share-text test expect English, and the iPhone simulator's system
  language became German today. Confirmed on a clean tree. Pinning those tests' language, or
  passing `-testLanguage en` in the skill's script, is left for Josh to choose.
- **Verified on the iPhone 17**, in dark mode: in German, the migrated aufstehen card ("Vor 11
  Tagen nachgeschlagen"); a seeded record's singen card ("Vor 3 Tagen geübt"), whose reveal raised
  only its two due key conjugations; a Mittelstufe quiz answered wrongly throughout, whose last two
  first-round questions were einschätzen in the Perfekt er and bereiten in the Präsens ich, the two
  seeded due weak patterns, and every answer in the record as it was given; Reset Practice, its
  alert, and the record read back empty. In English: the singen card ("Looked up 9 days ago"), a
  dismissal that snoozed the due items to the next morning in their box, and the Reset alert. **On
  the iPad Pro 11-inch (M5)**, in light mode and English: a first launch's migration of an empty
  record, the singen card ("Practiced 3 days ago"), and Reset Practice's row and alert. Not tried:
  VoiceOver by ear, the widget (which reads nothing of the record yet), and a real day passing.
- **Seen, not changed.** The English "Rate or Review" description still ends in German ("Füge
  deine hinzu."), as Phase 7 noted.

## Phase 12: Review and My Mistakes

**Suggestions:** T3.2, T3.3 (the session). **Depends on:** Phase 11. **Status:** Awaiting Josh.

- **Review.** A short session of whatever items are due, built from the record: a strong verb's
  item asks its key conjugation, and a weak pattern asks that conjugationgroup and person of a
  weak verb from the learner's band.
- **Practice my mistakes.** A session of the items most recently missed.
- Entry points on the Quiz tab, each with an empty state that says why it is empty. Phase 13 moves
  them into the hub.
- New `source` values for the quiz signals; stage their lines.

**Decided (Josh, 2026-11-13):**

- A Review session is ten due items, the most overdue first, with Ten More, like the default
  session.
- "Practice my mistakes" draws items whose most recent answer was wrong. An item leaves the list
  once answered right.

**Done when** both sessions draw the right items under test, update the record, and show sensible
empty states.

**How it differed:**

- **Nothing was asked of Josh.** The phase lists no Ask Josh items, and every question below was
  decided in the session. Each is a guess he can overrule.
- **Where the entry points live.** A "From Your Practice" ("Aus deinem Übungsstand") section below
  the Quiz tab's tiles, on every segment, with one row each for Review ("Wiederholen") and Practice
  My Mistakes ("Meine Fehler üben"). A row with questions shows their count and a play symbol, and
  a tap starts the session at once. An empty row is not a button. It says why it is empty: Review
  gives the days to the next due item ("Nothing is due today. The next review is tomorrow."), or,
  with nothing scheduled, says that quiz answers and strong verbs looked up come due a day or more
  later. My Mistakes says that a question missed in a quiz waits there until answered right. The
  segmented picker was not used: a fourth and fifth segment would not fit an iPhone in German, where
  "Eigene Auswahl" already fills its own. **On an iPhone the section is below the fold**, under the
  hero and the tiles. Phase 13's hub is the place to fix that.
- **What each session asks.** Review: the record's due items, most overdue first. My Mistakes: items
  whose last answer was wrong, most recently missed first (`PracticeRecord.missedItems()`). It reads
  the record, not `QuizErrorHistory`, which has typed answers but no items. A key conjugation asks its
  er form, as the review card shows it; a pattern asks its cell of a weak verb from the learner's
  band. **Neither is held to the level's pool or band**, so Review asks what Phase 11's due items left
  out (a Präteritum looked up at Elementary, a rare looked-up verb). A verb's due key conjugations sit
  together in the verb page's order (fährt · fuhr · ist gefahren), at the place of the first drawn.
- **Rounds.** Ten items, then Ten More while an askable item remains that the session has not asked.
  Fewer than ten makes a shorter round, so a Review of two due items asks two. Ten More keeps its
  label when fewer than ten remain. Review needs no exclusion, since an answered item is no longer
  due. My Mistakes does, since a mistake missed again stays a mistake and would come straight back.
  Re-asks and second attempts work as in any quiz, and every answer moves the record as before.
- **`Quiz.questionCount` now counts the questions asked**, re-asks excluded, rather than multiplying
  rounds by ten. That is the same number for every earlier scope and the true one for a short
  Review, whose results say "Richtig: 1 / 2". `canContinue` now checks the record for a record
  session. The Live Activity is keyed on `scope.continues`, since `canContinue` changes meaning
  mid-session. The level tip is not donated after a record session, which does not ask by level.
- **The bar's title.** While a session runs or shows its results, the Quiz tab's bar reads
  "Wiederholen" or "Practice My Mistakes", since its questions look like any quiz's. On the iPad, the
  top tab bar shows no navigation title at all, "Quiz" included. That predates this phase, so the
  session name is not visible there.
- **Analytics.** New `source` values `review` and `mistakes`. **A record session sends no counts.**
  `completeQuiz` omits `questionCount`, and `quitQuiz` and `abandonQuiz` omit `questionNumber`
  (`QuizScope.sendsQuestionCounts`). A session shorter than ten is exactly as long as the learner's
  due or missed items, so its length would be a count of wrong answers (Decision 5).
  `QuizAbandonment.Entry.questionNumber` became optional, which still decodes stored entries. Staged
  in [`docs/privacy-policy-pending.md`](../docs/privacy-policy-pending.md) in both languages, with a
  sentence saying why, and the section 6 sentence naming these sessions among those that post
  nothing.
- **VoiceOver.** No new quiz state. Each row reads as one element, its title and its count or
  reason, and a startable row has a hint ("Starts a quiz of the questions due for review.").
- **Tests:** `QuizRecordSessionTests`, 12 functions. Six on the parts: missed items most recent
  first, days to the next due item, a session beyond the pool and band, a verb's key conjugations
  together, excluded and unaskable items with the limit, and never ranked. Six nested in `QuizTests`:
  twelve due items asked as ten then two and nothing more, a short Review that does not continue, an
  empty record starting nothing, a mistake leaving once answered right, a mistake missed again not
  returning in Ten More, and signals without counts and no score posted. Run in English with
  `xcodebuild -testLanguage en`: 709 passed and 2 skipped (the environment-gated harnesses), 711
  in all. `run_tests.sh` was not used, for Phase 11's reason: the iPhone simulator is German.
- **Verified on the iPhone 17**, in dark mode. In German: both rows with the earlier sessions'
  record (2 due, 2 missed), a Review of a weak pattern asked of ehren and then of unterschätzen
  after a relaunch, a slip's "Fast!", a correction with "Diese Frage kommt noch einmal." and the
  re-ask's diamond, results of "Richtig: 1 / 2" with no Ten More, and both rows' empty states after.
  In English: a default quiz quit after two misses, both missed questions waiting in My Mistakes,
  the session titled "Practice My Mistakes" (aufkommen's key conjugation kommt auf, then dürfen's
  durfte), results of 2 / 2, and both rows empty, read through the accessibility tree. **On the iPad
  Pro 11-inch (M5)**, in light mode and English: the section above the fold with 4 due and 4
  missed, a Review opening with singen's two due key conjugations in order, then a weak pattern of
  mitfühlen, and its correction. Not tried: VoiceOver by ear, the Live Activity of a record session,
  Ten More from a real record of more than ten, and a real day passing (each unit-tested where it
  can be).

## Phase 13: The Practice Hub

**Suggestions:** T6.1, T6.6 (the leaderboard's place). **Depends on:** Phases 7, 8, 11, and 12.
**Status:** Not started.

Turn the Quiz tab into a practice hub: what a session is, how long it takes, the current level,
what is due for review, and the last result. The usage data show most quizzes ending before the
first answer, and the blank tab gave no reason to begin. Browse Phase 13's start screen (hero
symbol, scope picker, tiles) is the base.

- Move the leaderboard out of the main path: a modest control on the hub, not a button on every
  results screen.
- Rewrite the quiz's onboarding page, now titled "Test Your Knowledge" and describing timed
  quizzes, points, and the leaderboard, to describe practice. Revisit `TryQuizTip`'s text too.
- The last result is kept on the device; it falls under the privacy change staged in Phase 11.

**Ask Josh** to judge the hub on a phone and an iPad, in light and dark, before polishing.

**Done when** the hub shows each item above with real data, the onboarding page and tip are
rewritten in both languages, and the leaderboard is one tap away but not in the way.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 14: Naming the Error

**Suggestions:** T4.2, T4.3. **Depends on:** Phases 3 and 4; Phase 2 for the separable class.
**Status:** Not started.

Diagnose a wrong answer from the conjugator's own knowledge and say it in one templated line,
shown with Phase 3's correction. No language model. The one careful study the report found
(Song et al. 2023) shows explanations become reliable when a deterministic step establishes the
facts first, and a template needs no model at all. Candidate classes, from the report:

- **Another cell of the same verb**, by `Verb.conjugations(matching:)`: "That is the Präteritum.
  The Perfekt was asked." Probably the commonest, and always right.
- **A strong verb conjugated as weak** (gehte for ging).
- **The wrong auxiliary** (hat gegangen). Every region's auxiliary is already accepted, so this
  fires only when no region allows it.
- **A participle prefix error**: ge- missing, ge- added to an inseparable or -ieren verb, or ge-
  misplaced in a separable verb (geaufstanden).
- **A separable prefix attached or detached contrary to the frame.** Since both orders are
  accepted for finite conjugations, this mostly concerns the Imperativ and the participle.
- **A wrong ending on a right stem**, or the reverse.
- **A spelling slip**, which Phase 4 already catches.

**T4.3.** For a diagnosable error, prompt a repair before revealing the answer ("Check the
auxiliary. Try once more."), through Phase 4's single second attempt with half points. The report
treats this as an experiment, since its evidence is oral and from classrooms.

A wrong diagnosis is worse than none. Say only what is certain, order the checks from most to
least certain, and stop at the first that applies. The templates use the conjugationgroup names
in the learner's chosen language.

**Ask Josh** which classes prompt a repair and which reveal at once, and to review the templates
in both languages.

**Done when** each class is diagnosed for real verbs under test, an undiagnosable answer gets no
line, and the prompted second attempt shares Phase 4's mechanism.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 15: Key Conjugations

**Suggestions:** T5.1. **Depends on:** Phases 2 and 11. **Status:** Not started.

An exercise for strong and mixed verbs: given the infinitive, supply the third-person Präsens, the
Präteritum, and the Perfekt with its auxiliary, as the Goethe-Institut's B1 list prints them
("abfahren, fährt ab, fuhr ab, ist abgefahren"). `Verb.keyConjugations` supplies the answers, and
Phase 2's frame supplies the three blanks. Each blank is graded alone and updates its own item in
the record.

- **No "principal parts" label** (see Decisions Already Made), in the interface or in code.
- Offer it on the Quiz tab over the strong verbs of the learner's band, and wherever Phase 16
  needs it.

**Decided (Josh, 2026-11-13):**

- The exercise is called **Verb Essentials**. Propose the German name to Josh ("Verb-Grundlagen"
  was the suggestion he chose from).
- Each blank scores on its own and updates its own item.

**Done when** the exercise asks, grades each blank, and records each item, with tests for
separable, inseparable, and sein-taking strong verbs.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 16: Ablaut Groups, One Then Mixed

**Suggestions:** T5.2. **Depends on:** Phases 11 and 15. **Status:** Not started.

Work through one ablaut group, then mix it with groups already practiced. Browse Phase 16 gave
each expanded ablaut group a bar with a 30-question Quiz; this phase adds the blocked-then-mixed
practice. The support is Pan et al. (2019), where practicing a pattern alone before mixing it did
better over two weekly sessions; for ablaut families as such the report found no study, so treat
it as a bet.

**Decided (Josh, 2026-11-13):**

- The practice uses Phase 15's Verb Essentials, since the vowel changes a group shares are exactly
  what it asks.
- A group is "already known" once at least half of its items have moved past the first box of the
  practice record.
- The 18 single-verb groups offer no solo practice, since one verb is not a pattern. They join
  mixes once their verb's items have climbed.

**Ask Josh** about the mix's composition (how much of it is the new group) once the solo practice
works.

**Done when** a learner can practice one group, then a mix of it with known groups, and tests pin
which groups count as known and how the mix is drawn.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 17: Recognition

**Suggestions:** T5.4. **Depends on:** Phase 3. **Status:** Not started.

Show a conjugation, such as käme, and ask for the infinitive and the conjugationgroup. This is the
direction a reader needs, and the report's principle 11 says practice develops in the direction
practiced. The bundled conjugation map gives every conjugation's verbs and cells.

- The infinitive is typed. The conjugationgroup and person are chosen, since typing their names
  would test the metalanguage.
- Many conjugations belong to several cells or verbs (kommen; fuhr, of fahren and its family).
  Accept any cell that matches, or avoid ambiguous prompts; decide and test.
- Draw from the learner's level and band.

**Decided (Josh, 2026-11-13):** recognition is a mode of its own, a separate session on the hub.
The default quiz stays production practice.

**Done when** recognition questions ask, accept every right reading, and record to the practice
record if Phase 11 maps them, with tests on ambiguous conjugations.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 18: Sentences with a Blank

**Suggestions:** T5.5. **Depends on:** Phases 2 and 3. **Status:** Not started.

Short authored sentences for the core verbs, with the verb blanked, so the conjugation is tied to
a meaning. Both sides of the drill debate agree that practice linked to meaning is the strong
kind. The bundled literary examples exist for every verb and are mostly too hard for a beginner's
blank; the report suggests them as a reward after a correct answer instead.

- **The content.** A JSON resource, like `ExampleSentences.json`: for each sentence, the German
  with a marked blank, the verb, its cell, and an English translation. A machine check confirms
  that each blank's answer is the conjugator's conjugation of that cell, so no sentence can teach
  a wrong conjugation.
- **The app.** A sentence prompt built on Phase 2's frame, where the sentence replaces the
  pronoun row.
- **The literary reward**, if Josh wants it. The report's chief feedback study says to move on at
  once after a right answer, so a reward that delays the next question works against it; the
  results screen may be the better place.

**Decided (Josh, 2026-11-13):**

- Claude drafts the sentences, a machine check confirms each blank against the conjugator, and
  Josh reviews every sentence before it ships.
- Sentences cover the 300 most frequent verbs from the start, at the levels' conjugationgroups.
- The literary reward appears on the results screen, where each question's row can show its verb's
  literary sentence. The quiz itself never pauses after a right answer.

**Ask Josh** how many sentences per verb, once a first batch shows how long review takes.

Split this phase into content and app if either is large.

**Done when** the sentences exist for the agreed verbs and pass the machine check, sentence
questions appear where decided, and tests pin the check.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 19: Which Conjugationgroup Would a Speaker Use?

**Suggestions:** T5.6. **Depends on:** Phase 18 for its content pipeline. **Status:** Not started.

A context and two conjugationgroups, with the learner choosing the one a speaker would use. The
report notes that choosing is where much real difficulty lies and that the quiz never asks for it.
Candidate contrasts: Perfekt or Präteritum in speech and in writing (with sein, haben, and the
modals as the exception); a one-word Konjunktiv II or the würde construction; Konjunktiv I in
reported speech or the Indikativ; the Präsens or the Futur for future time. Each item carries a
one-line reason shown after the choice, and items are leveled with Phase 5.

**Decided (Josh, 2026-11-13):** Claude drafts the items and Josh reviews each, as in Phase 18.
Choice questions appear occasionally in default sessions from the second level up, where the
Perfekt and Präteritum and the würde construction first matter, rather than as a mode.

**Done when** the items exist and are reviewed, the choice and its reason appear as decided, and
tests pin the item data's integrity.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 20: Mastery

**Suggestions:** T6.2. **Depends on:** Phases 5, 11, and 13. **Status:** Not started.

Show mastery: the core verbs against the conjugationgroups of the current level, filling in as
items move up the ladder. The report warns that progress displays are unproven for persistence,
so keep it modest. The two kinds of item complicate a verb-by-conjugationgroup grid: a weak
verb's cells come from patterns shared by every weak verb, so they fill together. That is honest,
since the pattern is one thing to learn, but it should look intended.

**Ask Josh** to choose between a grid and a display that separates patterns from strong verbs,
from mockups, and where it lives in the hub.

**Done when** the display reflects the record under test and Josh has judged it on a device-sized
screen.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 21: Speed Round

**Suggestions:** T5.7. **Depends on:** Phases 11 and 20. **Status:** Not started.

A speed round over items already mastered, the one place where the clock counts. It belongs to
what Paul Nation calls the fluency strand: speed for material already accurate.

**Decided (Josh, 2026-11-13):**

- The round lasts 60 seconds and counts right answers. A personal best is kept on the device, and
  nothing ranks.
- An item is mastered once its interval is 7 days or longer: the third box of the ladder, index 2
  in `ReviewSchedule`'s zero-based boxes.
- A miss in the round does not send an item back down the ladder, since speed errors are often
  haste.

**Ask Josh** what the round offers when too few items qualify, once Phase 20 shows how quickly
items reach the third box.

**Done when** the round draws only mastered items, times as decided, and tests pin the drawing and
scoring.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 22: A Daily Session and a Streak

**Suggestions:** T6.3. **Depends on:** Phases 11, 12, and 13. **Status:** Not started.

A short daily session, a streak that can be repaired, and an optional reminder at a time the
learner picks. About 37% of iOS education-app users allow notifications (**secondhand**, in the
report), so the reminder cannot be the plan; the session and the streak must work without it.

- The daily session draws from what is due, topped up with new items.
- Ask for notification permission only when the learner turns the reminder on. The reminder can
  say how many items are due, which is the spaced-repetition reminder of
  [`docs/post-release-features.md`](../docs/post-release-features.md).
- A broken streak lowers later engagement unless it can be repaired (Silverman and Barasch 2023,
  **secondhand**).

**Decided (Josh, 2026-11-13):**

- The daily session is ten questions at the learner's level, filled first from due items and then
  with new draws. Finishing it extends the streak.
- A streak broken by one missed day is repaired by finishing two daily sessions the following day.
- The widgets do not show the streak; it lives on the hub.
- Three signals, with staged privacy lines: the reminder turned on or off; a `source` value for
  the app opened from the reminder; and the streak's length in bands (1, 2 to 6, 7 to 29, 30 or
  more) at each daily session.

**Done when** the session, the streak with its repair, and the reminder work across days under a
controllable clock in tests, and the reminder fires on the simulator at the chosen time.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 23: Personal Bests and Achievements

**Suggestions:** T6.6 (personal bests and achievements). **Depends on:** Phases 8, 20, and 22.
**Status:** Not started.

Personal bests per level, kept on the device, and Game Center achievements for mastery
milestones. The report's evidence says comparisons with one's own past motivate weaker performers
better than rankings do.

- Propose a short list of achievements to Josh, tied to mastery (for example, every Level 1
  pattern in a high box, or the key conjugations of the 50 most frequent strong verbs), not to
  volume of play.
- Extend `docs/game-center-setup.md` (Phase 8) with the achievements: IDs as the code uses them,
  English and German titles and descriptions, point values, and the artwork App Store Connect
  requires. Read Apple's current documentation for the requirements.
- `GameCenter` gains a way to report an achievement; update the real and dummy implementations.

**Decided (Josh, 2026-11-13):** the achievements' artwork is generated with the `gpt-image`
skill, and every prompt specifies colors from Konjugieren's palette: the color sets in
`Konjugieren/Assets/Assets.xcassets` (`customBackground`, `customCardBackground`,
`customCardBorder`, `customForeground`, `customRed`, `customYellow`, and `AccentColor`). Read
their light and dark values from each `Contents.json` and give the hex values in the prompt. Josh
picks among the drafts.

**Ask Josh** to approve the list of achievements before any artwork is made.

**Done when** each achievement reports when its milestone is reached, under test with the dummy,
and the walkthrough covers achievements.

**How it differed:**

(To be written by the session that finishes this phase.)

## Phase 24: The Daily Challenge

**Suggestions:** T6.8. **Depends on:** Phases 5 and 22. **Status:** Not started.

A daily shared challenge built on the quiz widget's daily question: the same short set for
everyone that day, seeded by the date as the widget already seeds its question
(`WidgetQuizShuffle.stableSeed`), with a result the learner can share as text with the App Store
link. The report rates the basis as speculative: a designer's testimony and one survey.

- The browse plan left the quiz widget's question sampling to this track. Make it follow the
  challenge, and the levels if the challenge has them.
- A shared result names the date and how the learner did, in a short text of the app's own design.
- Analytics: a `source` for the challenge on the quiz signals, and a signal for sharing a result,
  never the result itself.

**Decided (Josh, 2026-11-13):** one challenge per level per day, five questions each, so learners
at every level get a fair challenge. A shared result names the level.

**Ask Josh** to approve the shared text, from a drafted example in both languages.

**Done when** two devices on the same date get the same challenge, the widget's question agrees
with it, sharing produces the agreed text, and tests pin the seeding.

**How it differed:**

(To be written by the session that finishes this phase.)

## Tasks for Josh Outside the Code

- **The store category** (Decision 10). In App Store Connect, change Konjugieren's primary
  category from Education to Reference, the siblings' category. Josh expects little from it. If
  App Store Connect applies the change only with a new version, it waits for the 2027 release;
  the Closing checks which.
- **Leaderboards and achievements**, by the walkthrough Phases 8 and 23 write. Phase 8's four
  leaderboards exist in App Store Connect (2026-11-14). What remains for Josh: open
  `GameCenterResources.gamekit` in Xcode once, post a score from a development build, and on
  release day add the four for review and archive the old `Leaderboard`.
- **Two checks on his phone**, which the simulator cannot make: the Camera app opening a
  `konjugieren://` QR code (Phase 10), and anything a phase marks "not tried on a device".

## Not Built

- **T2.4**, weighting a newly opened conjugationgroup: Josh said no.
- **T4.6**, a language model wording a diagnosis: not applicable at this time. The explainer stays
  disabled.
- **T6.9**, the arcade game: a possible future project, outside this one.
- **M4 and M5**, accuracy signals: Decision 5.
- **Retiring the sad trombone**: Josh keeps it.

## Closing

**Status:** Not started.

- Run the full suite and `check_docs.py`.
- Confirm that every suggestion in the Suggestion Index marked for a phase carries its **Built on
  `main`** line in [`plans/pedagogy.md`](pedagogy.md), and that the report's "Decisions for Josh"
  say what was done about each.
- Audit the privacy staging: diff `Analytics.swift` against the commit before Phase 1, read every
  call site, and confirm that each new signal, parameter, and value has its lines in
  `docs/privacy-policy-pending.md` in both languages, and that none carries an answer, a score, an
  accuracy, or a verb (Decision 5).
- Check, in App Store Connect's documentation or with Josh, whether the category change can take
  effect without a release, and record the answer.
- Write a short list of what each phase would mean for Conjuguer and Conjugar, as the browse
  plan's Closing did. The report's section on the siblings notes what they already do better
  (curated lists, fixed per-tense quotas) and their own grading defects, and its advice to build
  shared changes into all three applies.
- Mark this plan finished in its Status section.

**How it differed:**

(To be written by the session that finishes the Closing.)
