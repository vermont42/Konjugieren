# Feature Architecture

Architecture details for Konjugieren's major feature systems.

## Quiz System

The quiz tests users' knowledge of German verb conjugations with timed, scored gameplay.

### Architecture

| File | Purpose |
|------|---------|
| `Quiz.swift` | `@Observable` class managing quiz state and logic; `QuizScope`, what a quiz asks about; `QuizItem`, one question and its grading |
| `AnswerDifference.swift` | Where a wrong answer differs from the right one, letter by letter, for the held correction |
| `AnswerSlip.swift` | Whether a wrong answer is a slip that earns one more attempt |
| `AnswerDiagnosis.swift` | Why a wrong answer is wrong, when the conjugator can say so for certain, and the one line that says it |
| `AnswerSpelling.swift` | Answer normalization, the leading pronouns a cell allows, and digraph spellings of umlauts |
| `StandardVariants.swift` | Duden's other standard conjugations of a cell, accepted as right answers |
| `QuizView.swift` | SwiftUI view for active quiz gameplay |
| `QuizCorrectionView.swift` | The held correction of a wrong answer |
| `ResultsView.swift` | Modal sheet showing final results |
| `QuizLevel.swift` | The level setting, each level's pool, `QuizPoolEntry` (a table's cells, their verbs, a weight), `QuizVerbs` (which verbs a restricted cell may ask), and each level's frequency band |
| `QuizDraw.swift` | Draws a quiz's questions from a pool with an injectable random source, mixing the default quiz's verbs |
| `CustomQuiz.swift` | The Quiz tab's custom quiz: chosen tables, a `QuizVerbSet`, its stored form, and `QuizScope.custom` |
| `CustomQuizView.swift` | The editor the Custom segment pushes, and its list of ablaut groups |
| `QuizErrorHistory.swift` | Persists recent wrong answers (up to 200) for AI analysis |
| `QuizAbandonment.swift` | The quizzes in progress, so that the next launch can report one the app was left during (`abandonQuiz`) |
| `QuizClock.swift` | The setting that shows or hides the quiz's time, hidden by default |
| `ErrorExplainerView.swift` | On-demand AI explanation of why an answer was wrong |
| `LiveActivityManager.swift` | Starts/updates/ends quiz Live Activity on lock screen |

### Quiz Flow

1. User taps "Start" → `quiz.start(scope:)` generates the scope's ten questions (three on a verb page) and, except on a verb page, starts a Live Activity
2. Timer begins, questions presented one at a time; Live Activity updates on each answer
3. User types conjugation, presses return → `quiz.submitAnswer()`
4. A right answer advances at once, except a choice question's, which holds its reason (see Choice Questions). A slip waits for one more attempt (see One More Try). A wrong one is recorded to `QuizErrorHistory`, queued to be asked again, and held on its question, with the clock stopped, until Continue (see The Held Correction, and Rounds and Re-asks)
5. After the round's questions and re-asks → `quiz.finishQuiz()` shows ResultsView and ends the Live Activity
6. Ten More (`quiz.continueSession()`) draws ten more questions into the same session, and the flow resumes at step 2

### Question Generation

Built 2026-11-13 in Phase 5 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md),
replacing Regular and Ridiculous (which asked four and twelve conjugationgroups, with a fixed quota
of one Präsenspartizip and two Perfektpartizip questions per quiz). The learner chooses one of four
levels in Settings (`Settings.quizLevel`), and each adds conjugationgroups to the one before, in
the order of the report's ladder:

| Level | Roughly | Adds |
|---|---|---|
| Beginner (Einstieg) | A1 | Präsens Indikativ; Imperativ for du, ihr, and Sie |
| Elementary (Grundstufe) | A1 to A2 | Perfekt Indikativ; Perfektpartizip; the wir Imperativ; Präteritum Indikativ of sein, haben, and the modals |
| Intermediate (Mittelstufe) | B1 | Präteritum Indikativ of every verb; Plusquamperfekt Indikativ; Futur Konjunktiv II; Präteritum Konjunktiv II of sein, haben, werden, and the modals; Plusquamperfekt Konjunktiv II; Futur Indikativ |
| Advanced (Oberstufe) | B2 and above | Präsens Konjunktiv I; Perfekt Konjunktiv I; Futur Konjunktiv I; Präteritum Konjunktiv II of every strong or mixed reading; Präsenspartizip |

`QuizLevel.pool` lists each level's kinds of question as `QuizPoolEntry` values, and `QuizDraw`
draws every question the same way: a kind by its weight, then a verb (and a reading) that the
kind's `QuizVerbs` admits, then one of the kind's cells. Drawing the verb after the cell is what
keeps a restricted cell, such as the Elementary Präteritum, off other verbs; a kind that no verb of
the scope admits is left out, so a My Verbs quiz of weak verbs at Elementary asks no Präteritum.
The weights, which Josh chose on 2026-11-13, are fixed and never adapt to the learner:

| Weight | Kinds |
|---:|---|
| 3 | Präsens Indikativ, Perfekt Indikativ |
| 2 | Every other finite conjugationgroup |
| 1 | Futur Indikativ, Futur Konjunktiv I, Futur Konjunktiv II (only their auxiliary varies), and both participles (one cell each) |

A weight belongs to a kind as a whole, whatever its number of cells. At Beginner, a quiz is
therefore about 60% Präsens and 40% Imperativ. Every level scores 10 points a right answer.

`Quiz(randomSource:)` takes any `RandomNumberGenerator`, so a test can pass `SeededRNG` and draw the
same quiz every time. `Quiz` sorts the verbs by infinitive before drawing, since a dictionary's
order changes between launches. `QuizLevelTests` pins each level's tables, the restricted cells'
verbs, and each kind's share of 40,000 seeded draws.

### Which Verbs the Default Quiz Asks

Built 2026-11-13 in Phase 6 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md).
A quiz whose scope names no verbs (`QuizScope.allVerbs`, the Quiz tab's default) draws from its
level's `QuizLevel.band`: the 100 most frequent verbs at Beginner, 300 at Elementary, 1,000 at
Intermediate, and the whole corpus at Advanced. `Quiz.defaultVerbs(for:)` supplies them, and
`Quiz` passes `mixesVerbs: true` to `QuizDraw`, which then balances the session:

- **Half the questions, rounded down, ask a strong or mixed reading.** ieren counts as weak, and
  so the reading, not the verb, decides: hängen counts by the reading asked.
- **At least two ask sein, haben, werden, or a modal** (`QuizDraw.isCore`). Since haben is mixed in
  the data, every core question is also a strong one.
- **Derivatives.** A prefixed verb in the top 300 (`QuizDraw.frequentDerivativeBand`) draws as
  freely as a base verb, as Josh chose on 2026-11-13: bekommen is as basic as kommen. Beyond the
  top 300, a prefixed verb is a *rare derivative*, and where the band reaches that far
  (Intermediate and Advanced) exactly one to three questions ask one, and no other question may.
  At Beginner and Elementary, where no rare derivative exists, at least one question asks a
  prefixed verb.

The counts are exact because `QuizDraw.mixedQuestions` decides them before it draws a verb. It
draws every slot's kind by weight, as above. It then gives slots their roles (core, rare
derivative, derivative, or free) and gives each slot a strong-or-weak value, the restricted kinds
first since they have no choice: Elementary's Präteritum is core and strong by its verbs alone.
Only then does it draw, for each slot, a verb whose reading fits all three. A scoped quiz (My
Verbs, a collection, a verb's page) is never mixed, because its verbs were chosen.
`QuizVerbMixTests` pins each rule over 40 seeds per level.

The bands exposed a data defect, fixed the same day. 56 of the 83 verbs whose `hi` is an estimate
(`hp="y"`, compounds DWDS cannot measure) sat at ranks 937 to 994, put there by tranche 2's ratio
from a common base (*madigmachen* beside *machen*). `verbdata/replace_inflated_estimates.py` moved
61 of them beside measured verbs of similar use, and `QuizVerbMixTests` checks that no provisional
count reaches the top 1,000.

### Scopes

A `QuizScope` names the verbs a quiz asks about (nil for every verb), the reading to ask about,
the question count, and the `source` its analytics signals carry. Built 2026-11-13 in Phase 13 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md) as the
minimal piece the quiz track is to extend. Phase 16 added `.collection(_:)`, and `title` (what a
quiz in a sheet shows) and `collectionKey` (which `startQuiz` names).

| Scope | Verbs | Questions | `source` | Ranked |
|---|---|---|---|---|
| `.allVerbs` | Every verb; from Elementary up, one question of each round is a choice question (pedagogy Phase 19) | 10, then Ten More | `tab` | First round |
| `.myVerbs(_:)` | My Verbs (starred, then the 20 last opened), with replacement | 10, then Ten More | `myVerbs` | No |
| `.verbPage(_:readingIndex:)` | The verb on screen, in the reading on screen | 3 | `verbPage` | No |
| `.collection(_:)` | A collection's verbs (Phase 16), with replacement, in a sheet | 10, then Ten More | `list` | No |
| `.custom(_:myVerbs:)` | The custom quiz's verb set, or the level's band (pedagogy Phase 9) | 10, then Ten More | `custom` | No |
| `PracticeSet.scope(source:)` | A shared practice set's verb set, or its level's band, in a sheet (pedagogy Phase 10) | 10, then Ten More | `sharedLink` or `qrCode` | No |
| `.recordSession(.review)` | Due items of the practice record; a pattern asks a weak verb of the level's band (pedagogy Phase 12) | Up to 10, then Ten More while any are due | `review` | No |
| `.recordSession(.mistakes)` | Items whose last answer was wrong, likewise | Up to 10, then Ten More while any remain | `mistakes` | No |
| `.verbEssentials(_:)` | Five strong or mixed verbs of the level's band, or of the verbs passed, each asked its three key conjugations (pedagogy Phase 15) | 15, then five more verbs | `verbEssentials` | No |
| `.ablautPractice(_:)` | Verb Essentials over an ablaut group's ten most frequent verbs, alone, or mixed: three of the group's verbs and two of the known groups' (pedagogy Phase 16), in a sheet | Up to 15, then another round | `ablautAlone` or `ablautMixed` | No |
| `.recognition()` | Name the Conjugation: the level's pool and band, each question a conjugation to name by infinitive, conjugationgroup, and person (pedagogy Phase 17) | 10, then Ten More | `recognition` | No |
| `.sentences()` | Sentences: the authored sentences whose verb is in the level's band and whose cell is in its pool, one a verb where they allow (pedagogy Phase 18) | Up to 10, then Ten More | `sentences` | No |
| `.speedRound()` | Speed Round: the practice record's mastered items, in turn, for 60 seconds (pedagogy Phase 21) | As many as answered in a minute, drawn 10 at a time; then another round | `speedRound` | No |
| `.daily(source:)` | The daily session: due items the level asks and the band holds, then the default quiz's draw, no choice question (pedagogy Phase 22) | 10; no Ten More, but Another Session while a repair needs a second | `daily`, or `reminder` from the reminder | No |

A quiz whose rounds are ten (`QuizScope.continues`) draws as above. The verb page's three
questions ask distinct cells and no participle, from the learner's level, since every Perfekt
among three questions tests the participle anyway. Only a ranked quiz posts to Game Center, to its
level's leaderboard: Josh decided on 2026-11-13 that neither a scoped quiz nor a
three-question quiz should post. Only a quiz of ten-question rounds starts a Live Activity and
counts toward `ChangeLevelTip`, the latter on its first results only. Every scope uses the
learner's level, except a practice set's, which carries the sharer's level in `QuizScope.level`
when it leaves a part to the level. Before Phase 7 of the pedagogy plan (2026-11-13), every quiz but the verb page's
was 30 questions.

The Quiz tab's start screen is a practice hub (pedagogy Phase 13, T6.1). It shows a yellow
symbol for the chosen scope (books for All Verbs, a star for My Verbs, sliders for Custom), its name
and a line about what it asks, the All Verbs / My Verbs / Custom picker, three tiles (ten
questions, "2–3 Minutes", and the level, whose tile is a menu that sets `Settings.quizLevel`, the
same setting as Settings' level picker), for My Verbs its verbs as chips (up to twelve), and Start.
Below Start, "From Your Practice" holds the Daily Session (pedagogy Phase 22), Review, My Mistakes, and the last quiz's results
(`LastQuizResultRow`), then "Exercises" holds Verb Essentials (pedagogy Phase 15) and Ablaut Groups (pedagogy Phase 16), a row with a chevron that pushes `AblautPracticeListView`, and last of all, while signed in to Game Center, a small "View Leaderboard"
button that opens the current level's board. The results screen no longer has one (T6.6). In the
regular size class the whole composition scales up. Start is disabled while My Verbs is empty.
Custom shows its summary and Choose or Change in place of the tiles (see The Custom Quiz).

**The last result** (`LastQuizResult`) is kept by `PracticeStore` under `lastQuizResult` in the App
Group's defaults, written by `Quiz.finishQuiz` at each round's results, so after Ten More it
describes the session so far. A quit quiz writes nothing. It stores a kind (all verbs, My Verbs,
custom, practice set, collection, verb page, Review, My Mistakes) and a verb or collection key
rather than a title, so the hub names it in the current language (Verb Essentials too, since
pedagogy Phase 15, and an ablaut group's practice, alone or mixed, since Phase 16); the level (none for Review, My Mistakes, and an ablaut group's practice); the counts right, right on a second try, and asked; the score; and the date. It is never
sent, and Reset Practice forgets it.

"Test me on this verb" presents `QuizView(sheetScope:)` with its own `Quiz`, so a quiz in
the Quiz tab carries on beneath it. The sheet starts its quiz as it appears, closes on Quit or
when the results are dismissed, and cannot be swiped away while a question waits, so every quiz
it starts ends in `quitQuiz` or `completeQuiz`.

### The Custom Quiz

Built 2026-11-14 in Phase 9 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T2.8). The Quiz tab's picker gained a third segment, Custom (Eigene Auswahl), beside All Verbs and
My Verbs. The tab opens on All Verbs at every launch, so the default stays the default. The segment
shows what the custom quiz will ask and a Choose or Change button that pushes `CustomQuizEditor`,
where the learner picks any of the fourteen tables and one verb set: the 100, 300, or 1,000 most
frequent verbs, every verb, My Verbs (listed only while it has verbs), the modal verbs, the verbs
with sein, or one ablaut group. Either part may stay "Set by Your Level", so a choice of verbs alone
asks the level's conjugationgroups, and a choice of conjugationgroups alone asks the level's band.
Start is disabled until something is chosen, or while the choice names an empty My Verbs.

- **Kept between launches** in `Settings.customQuiz`, stored as
  `groups=praesens_indikativ,imperativ&verbs=ablaut-singen`. Table keys are
  `ConjugationTable.articleKey`, and verb-set keys are `all`, `top100`, `top300`, `top1000`,
  `myVerbs`, or a collection's key. The form is permanent, since Phase 10 shares it as a link, and a
  key that names nothing is dropped. `CustomQuizTests` pins it.
- **Any table at any level** (Josh, 2026-11-13). A chosen table's kind is Advanced's, the fullest:
  the Präteritum of every verb, the wir Imperativ, and the Präteritum Konjunktiv II of strong and
  mixed readings and the core verbs. When no verb of the set fits that restriction, as with a My
  Verbs of weak verbs, `QuizDraw`'s `relaxesRestrictions` asks it of every verb instead of leaving
  it out, so the learner's choice is never silently empty. The weights are the usual ones.
- **Bands are mixed, lists are not.** A band or every verb is balanced as the default quiz is (half
  strong, two core, the derivative rules), since it was chosen for its size, not its verbs. A
  collection or My Verbs asks its own verbs as they come. `QuizScope.mixesVerbs` decides.
- **Never ranked.** `QuizScope.isRanked` requires `custom == nil`, so a custom quiz posts nowhere,
  even one whose choice matches the level's. It continues with Ten More, starts a Live Activity, and
  counts toward `ChangeLevelTip` as any ten-question quiz does.

### Practice Sets

Built 2026-11-14 in Phase 10 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T2.9, Decision 8), so that a teacher can hand a class one practice set without accounts or a
server. A practice set is a custom quiz shared as a link.

- **Sharing.** Beside Change on the Custom segment, Share is a menu: Share Link sends text with the
  set's summary, its `quiz/set` link with `source` `sharedLink`, and the App Store link, as a
  collection's share does; Show QR Code covers the screen with the link as a QR code (`source`
  `qrCode`), drawn dark on white in either appearance, with the summary beneath and the screen kept
  awake. `QRCode.image(for:)` makes it with Core Image's generator at medium error correction.
  `PracticeSet(sharing:level:myVerbs:)` builds the shared set.
- **What travels.** The custom quiz's stored form (The Custom Quiz above) and, while either part is
  left to the level, the sharer's level, so every student is asked the same set (decided in the
  session, not by Josh). My Verbs are the sharer's
  own, so they travel as `infinitives=gehen,kommen`, at most 100 (Josh, 2026-11-14); in the stored
  form a list is `QuizVerbSet.list`, kept apart from `verbs=` because an infinitive can equal a
  set's key (`sein`). The length does not travel: every set is ten questions, then Ten More (Josh,
  2026-11-14).
- **Opening.** `World.handleURL` turns `quiz/set` into `Current.practiceSet`, which `MainTabView`
  shows as a page-sized sheet over whatever tab is open: what the set asks, Start (a `QuizSheet`
  over it, at the set's level, never ranked), and Keep as My Custom Quiz, which replaces the
  learner's own custom quiz (Josh, 2026-11-14, rather than replacing it on opening). A kept set asks
  the learner's level for a part left to the level, as any custom quiz does. A link naming nothing
  this version knows shows "Practice Set Not Found" rather than doing nothing; unknown keys, unknown
  infinitives, and `verbs=myVerbs` are dropped and the rest kept.
- **Tests.** `PracticeSetTests` pins the link's form, round-trips every table, verb set, list, and
  level, decodes the generated QR code back to the link, and nests sessions in `QuizTests` and link
  handling in `DeeplinkTests`.

### Grading

Built 2026-11-13 in Phase 1 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md).
`Quiz.makeQuizItem` fills `QuizItem.acceptableAnswers` with the cell's conjugation in every region
and both clauses, plus the variants `StandardVariants` gives for each. `QuizItem.accepts` then
grades an answer:

- Case and runs of spacing are ignored.
- A leading pronoun of the asked person is ignored (`ihr habt ferngeguckt`), never another
  person's. The Imperativ takes none in front, since its wir and Sie conjugations carry theirs.
  Any of er, sie, and es matches the third-person singular.
- Any umlaut may be written as a digraph (`uebernehme`, `uebernaehme`, `übernaehme`). The
  expansion runs only from umlaut to digraph, so a missing umlaut stays wrong (`fahrt`) and a real
  ue cannot become ü (`baü`). The ss for ß comes from the Swiss spelling.
- Duden's other standard conjugations are right: komme beside komm, sammle beside sammele,
  kämst beside kämest, stünde beside stände, sandte beside sendete, and the rest of the rows Josh
  accepted in [`plans/pedagogy-phase1-variant-audit.md`](../plans/pedagogy-phase1-variant-audit.md).
  The verb page still shows only the conjugator's conjugation.

When a right answer was spelled another way, `QuizItem.preferredSpelling(of:)` gives the user's
region's spelling (übernehme for uebernehme, stoßen Sie um for stossen Sie um), and the quiz shows
it quietly under the score, with a green checkmark, until the next answer. VoiceOver announces
"Correct. Spelled: …". Another region's legitimately different conjugation, such as Austria's ist
gestanden, gets no such line.

The answer field shows `GermanLetterKeyRow` as a keyboard toolbar. It inserts at the cursor or
replaces the selection, through the field's `TextSelection`. With a hardware keyboard attached,
iOS draws the toolbar as a floating bar at the bottom of the screen.

The DEBUG launch default `KONJUGIEREN_QUIZ_FIXTURE grading` asks ten questions whose answers
exercise all of this. See the comment on `Quiz.generateGradingFixture()`.

### The Answer Frame

Built 2026-11-13 in Phase 2 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md).
The answer field sits inside the shape of the expected answer, which replaced the Pronoun row.
`QuizItem.answerFrame` builds an `AnswerFrame`, a list of segments, and `AnswerFrameView` draws it
on one line with a rounded text field per blank:

| Question | Frame |
|---|---|
| A participle | `[ ]` |
| A finite cell | `ihr [ ]`, `er [ ]` (the pronoun the settings choose), `sie (3s) [ ]`, `sie (3p) [ ]` |
| The du or ihr Imperativ | `(du) [ ] !` |
| The wir or Sie Imperativ | `[ ] Sie!` |
| The same, separable | `[ ] Sie [ ] !` |

Only the wir and Sie imperatives put a pronoun inside the answer, so only they can take two
blanks. Every other cell is one blank. A separable Präsens in particular stays one, because the
quiz accepts both kommt an and ankommt. Whether an Imperativ is separable comes from the asked
reading's `separableRun`, so übersetzen asks `[ ] wir!` for translating and `[ ] wir [ ] !` for
ferrying across. The second blank reveals separability for a prefix like um-; Josh accepted that.

`AnswerFrame.answer(filling:)` joins the blanks and the frame's own words of the answer (the Sie,
never the pronoun in front), and the quiz grades that string as before. A pronoun typed into the
blank anyway is still stripped by grading. Return moves to the next empty blank and submits once
none is empty (`blankAfterReturn`); the letter keys insert into whichever blank has the cursor.
The blanks keep their identity from question to question, keyed by blank index rather than by
position, so the keyboard keeps its focus when a pronoun appears in front of the field. Each field's
accessibility label reads the whole frame ("blank, Sie, blank. Blank 1 of 2"), and the frame's
other text is hidden from VoiceOver. The first field keeps the identifier `quiz_answer_field`; a
second is `quiz_answer_field_2`.

The frame is meant for reuse: Phase 15's three blanks and Phase 18's sentence frames are more
segments of the same kind. `KONJUGIEREN_QUIZ_FIXTURE frames` asks one question per frame above.
A fixture is cut or repeated to a round's ten questions, and Ten More asks it again.

### The Held Correction

Built 2026-11-13 in Phase 3 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md),
replacing the Last Answer and Correct Answer rows that showed on the *next* question's card while
its clock ran. A wrong answer sets `Quiz.correction` and stops the timer, and the quiz stays on the
missed question. `submitAnswer` ignores answers while a correction is held, `resumeTimer` (on
return to the foreground) leaves the clock stopped, and `continueAfterCorrection()` clears it,
advances, and restarts the clock, or after the last question shows the results. A right answer
still advances at once.

`QuizCorrectionView`, under the answer frame, shows:

- **Your Answer and Correct Answer, with the differing letters marked.** `QuizItem.difference(from:)`
  drops a leading pronoun of the asked person, as grading does, and chooses the nearest of the
  region's spellings, so ankomt is shown ankommt rather than kommt an (the canonical answer wins a
  tie). `AnswerDifference.between` aligns the two letter by letter, ignoring case, with the costs
  of `VerbSearch.editDistance` (a swap marks both letters). The learner's wrong or extra letters
  are struck through on a red tint; the right answer's changed or missing letters are underlined
  on a green tint. The red letters of irregularity stay red, so the two marks never compete.
- **Links.** The verb's page, opened on the asked reading and scrolled to the missed cell, which
  is marked as a search's match is, and the verb's ablaut group (the Ablaut page with the group
  expanded) or, for a weak or -ieren verb, its family page. They push onto `QuizView`'s own
  navigation stack, so Back returns to the held question with the clock still stopped. The
  `isBeneathQuiz` environment value hides "Test me on this verb" and a collection's Quiz button
  on those pages, so no second quiz starts over the first. A quiz begun from a verb's own page
  shows no verb link.
- **Continue**, at most 400 points wide and centered, so that it does not span an iPad's card.
  Return in the answer field also continues, from any blank. Return resigns the
  field, so the view refocuses it on holding and again after Back from a linked page.

VoiceOver: a wrong answer is no longer announced by `Quiz`. Instead focus moves to the correction,
which reads "Incorrect. Your answer: … Correct answer: … Letters that differ: …" (the letters only
when three or fewer), with a hint that Continue follows. A Magic Tap continues too.

`KONJUGIEREN_QUIZ_FIXTURE corrections` asks eight questions with a wrong answer for each in the
comment on `Quiz.generateCorrectionsFixture()`.

### One More Try

Built 2026-11-13 in Phase 4 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md).
A wrong answer that is only a slip gets one more attempt before any correction. `QuizItem.isSlip`
decides, on the answer with a leading pronoun of the asked person dropped, as grading drops it:

- **Near.** The answer is one edit (`VerbSearch.editDistance`) from an accepted spelling, digraph
  spellings included, or differs from one only in missing umlauts and ß, however many
  (`ubernahme` for übernähme). `AnswerSlip.isSlip(_:of:)` is this test.
- **Four letters or more** in the right answer, so geb for gib is a wrong vowel, not a slip.
- **Not another cell.** If `Verb.conjugations(matching:)` finds the answer anywhere in the verb's
  tables, any reading, it is a grammatical error and goes to the correction: kommt for du kommst
  (er's cell), musstest for müsstest (the Indikativ). This rule also makes fahrt for er fährt a
  real error, since fahrt is ihr's cell. Phase 14 named such errors; see
  [Naming the Error](#naming-the-error).

A slip sets `QuizItem.firstAttempt` and leaves `isCorrect` nil, so `Quiz.isAwaitingSecondAttempt`
is true. The clock keeps running. The field keeps the first attempt for editing and is refocused,
since Return resigned it, and an orange "Almost! Try once more." line appears under it, which
VoiceOver announces. The cue is a pop and a light tap, not the buzz and shake of a wrong answer. A
question gets one more attempt at most: the second answer is graded and, if wrong, goes to the held
correction whether or not it too is a slip. A diagnosed error shares this mechanism (below). A slip
is not recorded in `QuizErrorHistory`; a wrong second attempt is.

A right second attempt earns `Quiz.pointsPerSecondAttempt` (5) and counts in
`Quiz.secondAttemptCount`, apart from `correctCount`. Its `QuizItem.State` is
`.correctOnSecondAttempt`, an orange dot. The results show "Second Try: n" beside Correct and a
"First Try:" line on each such row, and VoiceOver's dot-row and completion summaries count them.
The results' score color gives a second attempt half credit.

`KONJUGIEREN_QUIZ_FIXTURE slips` asks ten questions with a slip or a near miss for each in the
comment on `Quiz.generateSlipsFixture()`.

### Naming the Error

Built 2026-11-14 in Phase 14 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T4.2 and T4.3). `QuizItem.diagnosis(of:)` returns an `AnswerDiagnosis` for a wrong answer when
the answer is exactly what a known error would produce, and nil otherwise. No language model is
involved: each check builds the wrong conjugations an error would yield, in every region's spelling
and clause order and with digraphs, and asks whether the answer (pronoun dropped) is one of them.
The checks run in this order and stop at the first that fits, since one answer can fit several:

1. **Another reading, same cell** (`otherReading`): hängte for intransitive hängen's hing.
2. **Separable prefix order**: aufsteh for steh auf in the du or ihr Imperativ (`prefixAtEnd`; the
   wir and Sie frames already place the prefix), and gestanden auf or auf gestanden for a
   participle, alone or after its auxiliary (`participleIsOneWord`).
3. **Missing auxiliary**: the participle alone for a Perfekt or Plusquamperfekt, the infinitive
   alone for a Futur.
4. **Wrong auxiliary**: only an auxiliary no region allows, so stehen's ist gestanden stays right.
5. **ge-**: missing (macht, aufstanden), on an -ieren verb (gestudiert), on an inseparable verb
   (geverstanden), or before a separable prefix (geaufstanden).
6. **Strong or mixed conjugated as weak** (`weakConjugation`): the cell of the same reading with
   its family set to `.weak`, through `Conjugator.conjugate(reading:…)`, which conjugates a reading
   that need not be in the corpus. Catches gehte, gesingt, denkte, and fahrst/fahrt for fährst/fährt.
7. **Another cell of the asked reading** (`otherCell`): another person of the asked
   conjugationgroup first (kommt for du: "for er and ihr"), then another conjugationgroup, naming
   its persons only when the asked person is not among them. A finite part alone (steht for
   aufstehen) is not named.

The rules come before the cell match because both can be true and the rule says more: macht is
also er's Präsens, and fahrt also ihr's. **Every class prompts a repair** (Josh, 2026-11-14):
`Quiz.submitAnswer` checks for a diagnosis before a slip, sets `firstAttempt` and
`firstAttemptDiagnosis`, and the field shows `QuizItem.secondAttemptPrompt`, the line followed by
"Try once more." in the orange of "almost". The one-attempt limit holds whatever earned the
attempt. The held correction (`QuizCorrection.diagnosis`) shows the diagnosis of the *final*
answer, under the two answers with a lightbulb, and VoiceOver reads it after the differing
letters. The same line serves both places. Conjugationgroups are named in the language the
settings choose.

`KONJUGIEREN_QUIZ_FIXTURE diagnoses` asks one question per class, with the wrong answer for each in
the comment on `Quiz.generateDiagnosesFixture()`.

### Rounds and Re-asks

Built 2026-11-13 in Phase 7 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md).
A session is rounds of `Quiz.questionCount` (10) questions. The results of each round offer **Ten
More**, which calls `Quiz.continueSession()`: ten more questions, drawn afresh so that each round
has the default quiz's mix (half strong, two core, one to three rare derivatives), are appended to
`questions`, and the score, the clock, and the earlier questions carry on. There is no limit; two
rounds of Ten More reach the thirty the quiz used to ask. `roundCount` counts the rounds begun,
and `questionCount` is the rounds' questions so far (10, 20, 30), re-asks excluded. A verb page's
three questions do not continue (`canContinue`, from `QuizScope.continues`).

A question answered wrongly, after any second attempt, is **re-asked once**: a copy of it
(`QuizItem.reasked()`, `isReask`) is inserted `Quiz.reaskGap` (3) questions later, or at the
round's end when fewer remain, so a question missed near the end returns before the results. A
re-ask is never re-asked, whatever its answer (Josh, T3.1). The correction says "This question
will come up again." for a question that will return, and VoiceOver reads it with the correction.
A re-ask's card carries an "Asked Again" line, which VoiceOver announces before the verb; its dot
is a diamond; and its results row carries the same line. A re-ask may still earn a slip's second
attempt. The round ends when `currentIndex` passes the last item, re-asks included.

The dot row wraps (`FlowLayout`), since rounds and re-asks can take it past thirty dots.

Verb Essentials (below) places its re-asks differently, by step: `Quiz.reaskPlacement` returns
the position and the step for every re-ask, and for a question shown alone it is the rule above.

### The Practice Record

Built 2026-11-14 in Phase 11 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T3.3's record, T3.4, T3.5, T6.4). Every final answer in every scope goes into an on-device record
as it is given, so a quiz quit after six questions has still practiced six; the trombone still
plays. A slip's first attempt records nothing, and a right second attempt counts as right.

| Piece | Role |
|---|---|
| `Shared/PracticeRecord.swift` | `PracticeItem` (an item and its permanent `key`) and `PracticeRecord` (an `Entry` per key: a `ReviewSchedule`, the last answer's date and rightness, the last lookup). Compiled into the widget, which has no corpus |
| `Shared/ReviewSchedule.swift` | The ladder: 1, 3, 7, 14, and 30 days, the last repeating; due dates fall at the start of a day. `answered(correctly:)` is the quiz's move |
| `PracticeItemMapping.swift` | Which item a question exercises, the items a lookup schedules, and the cell an item asks |
| `PracticeStore.swift` | `Current.practice`: saves each change to the App Group's defaults under `practiceRecord`, offers the review card, resets, and migrates browse Phase 15's schedules once |
| `QuizDueItems.swift` | `QuizDraw.dueQuestions` and `mixing`: the due items a default round takes |

**Two kinds of item (T3.5).** A strong or mixed reading's question exercises one of the verb's key
conjugations, `key:<infinitiv>:<reading>:<stem>`, chosen by the stem its cell is built on:
`praesens` for the Präsens Indikativ, the Präsens Konjunktiv I, the Imperativ, and the
Präsenspartizip; `praeteritum` for the Präteritum Indikativ and Konjunktiv II; `perfekt` for the
Perfektpartizip and the four Perfekt and Plusquamperfekt tables. A weak or -ieren reading's question
exercises a pattern, `pattern:<table>:<person>`, shared by every weak verb, so aufmachen, verkaufen,
and studieren in the Präteritum du share one item with machen. The three Futurs are patterns for
every verb, since werden and the infinitive show nothing of a strong verb. Strength is judged per
reading, as the quiz judges it, so hängen's two readings map differently. The table key is
`ConjugationTable.articleKey` and the person `PersonNumber`'s raw value; changing either orphans
learners' schedules.

**The ladder.** A new item answered right goes to the second box, due in three days; answered
wrong, to the first, due tomorrow. A wrong answer always starts an item over. A right answer
moves it up only when it is due, so a pattern asked three times in one session does not climb
three boxes in an afternoon. A lookup and the review card move strong verbs' items as § The
Review Card says.

**Due items in the default quiz.** A round of the default quiz (`QuizScope.mixesDueItems`: every
verb, no custom choice, ten questions) asks up to `QuizDraw.dueItemLimit` (3) due items, the most
overdue first, placed at random among a draw of the rest. A key conjugation asks its own cell (the
er form of the Präsens, Präteritum, or Perfekt) of its verb; a pattern asks its cell of a weak verb
from the level's band. An item the level does not ask, or a verb beyond the band, waits for Review,
so the default quiz stays within its level. Every Ten More round does the same. Due questions sit
outside Phase 6's mix, which balances the other seven. Scoped quizzes mix in nothing.

**Reset Practice**, in Settings' last card while there is a record, a last result, or a kept wrong
answer, asks for confirmation, then empties the record (saving it empty, so the migration does not
run again), forgets the last result (since Phase 13), and empties `QuizErrorHistory`, which Josh kept on 2026-11-14 for the Tutor's recommendations and Phase
14. Starred and recent verbs stay.

### Review and My Mistakes

Built 2026-11-14 in Phase 12 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T3.2, and T3.3's session). Two sessions drawn from the practice record rather than from a level's
pool, each a `QuizScope.recordSession` (`QuizRecordSession.review`, `.mistakes`) started from a
"From Your Practice" section below the Quiz tab's Start. Each row shows its count and starts the
session, or, with nothing to ask, says why: Review gives the days to the next due item, or says
what puts items there; My Mistakes says a missed question waits there until answered right. While a
session runs, the tab's bar is titled with its name (an iPad's tab bar shows no title).

- **What each asks.** Review asks `PracticeRecord.dueItems`, the most overdue first; My Mistakes
  asks `missedItems()`, items whose last answer was wrong, the most recently missed first, each
  leaving once answered right (Josh, 2026-11-13). A key conjugation asks its own cell of its verb;
  a pattern asks its cell of a weak verb from the level's band. Neither session is held to the
  level's pool or band, so it asks what the default quiz's due items left out (a Präteritum looked
  up at Elementary, a rare verb). `QuizDraw.sessionQuestions` keeps a verb's key conjugations
  together in the verb page's order (fährt, fuhr, ist gefahren).
- **Rounds.** Up to ten items, re-asks and second attempts as in any quiz, and Ten More while
  `canContinue` finds an askable item the session has not asked. Review needs no exclusion, since
  an answered item is no longer due; My Mistakes does, since a mistake missed again stays a mistake.
  `Quiz.questionCount` counts the questions asked, so a Review of four says "Correct: 3 / 4".
- **Never ranked**, mixing in no due items, and donating no level tip.
- **No counts in signals** (`QuizScope.sendsQuestionCounts`). A session shorter than ten is as
  long as the learner's due or missed items, so `completeQuiz` omits `questionCount` and `quitQuiz`
  and `abandonQuiz` omit `questionNumber` (Decision 5). `QuizAbandonment.Entry.questionNumber` is
  optional for this.

### Mastery

Built 2026-11-15 in Phase 20 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T6.2). A Mastery row ("Lernstand") in From Your Practice, below My Mistakes, says "Mastered: 7 of 17
patterns · 2 of 50 verbs" and pushes `MasteryView`, which shows what the practice record has made
secure at the learner's level. `Mastery` (in `Models/Mastery.swift`) builds it from the record and
the level; it reads the record and writes nothing.

- **Split, not a grid** (Josh, 2026-11-15, from mockups). A weak verb's cells are patterns shared
  by every weak verb, so they appear once: a card per conjugationgroup that a weak verb may be asked
  at the level (`Mastery.patternTables`, the pool entries whose `QuizVerbs` is `.all`), a mark under
  each person. The Futurs carry an "Every verb" tag, since a strong verb's Futur answer is a pattern
  too. Then the strong and mixed verbs: the 50 most frequent (`Mastery.coreVerbs`, the same at every
  level, all within Beginner's band), a row per strong reading (fahren and ziehen have two), each with
  the key conjugations the level asks (`Mastery.stems(askedAt:of:readingIndex:)`: the Präsens at
  Beginner; at Elementary the Präteritum only for sein, haben, and the modals). A grid would have
  shown a strong verb's Präsens and Imperativ, or Perfekt and Perfektpartizip, as two cells always
  alike, since each pair is one item.
- **States.** `MasteryState`: not practiced (no entry), learning (box 0 or 1), mastered (box 2 or
  higher, `MasteryState.masteredBox`, the seven-day interval). Phase 21's speed round uses the same
  threshold. A lookup puts an item in learning; a wrong answer drops a mastered item back to it.
- **Counts.** A pattern counts once its own item is mastered; a pattern beyond the level is kept in
  the record but not counted there. A verb counts once every stem the level asks, in every strong
  reading, is mastered, so kommen's mastered Präsens masters it at Beginner but not at Elementary.
- **It only shows.** A verb row opens nothing, since opening a verb page records a lookup, which
  would send that verb's key conjugations back to the first box. Conjugations are computed when
  drawn (`Mastery.KeyConjugation.conjugation(region:)`), so the hub's row, which needs only counts,
  does not conjugate.
- **VoiceOver.** Every mark is its own element, read as its state; every German word (a pronoun, a
  conjugation, an infinitive) is its own element with German pronunciation, and the gloss English.
- Analytics: `viewMastery`, with no parameters, when the page appears.

### Verb Essentials

Built 2026-11-14 in Phase 15 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T5.1). "Verb Essentials" ("Verb-Grundlagen", Josh's choice of name) asks a strong or mixed verb's
three key conjugations, er's Präsens, Präteritum, and Perfekt (fährt, fuhr, ist gefahren), as the
Goethe-Institut's B1 list prints them. No "principal parts" label appears anywhere, in the interface
or in code (Decisions Already Made). It starts from a row in the hub's "Exercises" section.

- **Each blank is its own question.** A verb is three `QuizItem`s sharing a `stepID`, in the verb
  page's order (`QuizDraw.verbEssentialsStep`). Each is graded alone, on Return, and records its
  own key conjugation through `PracticeItem.exercised`, so every quiz mechanism applies per blank
  unchanged: a slip's or a diagnosis's one more try at half points, the held correction, the
  re-ask, and the preferred spelling. Josh chose this on 2026-11-14 over filling all three and
  checking them together.
- **One step on screen.** `Quiz.essentialsRows` gives the current verb's three rows: answered
  (the right conjugation with its state's icon), current (the answer field), pending (an empty
  outline), or given (a re-ask's hint). `QuizView` draws the rows before the field and the rows
  after it as separate children around the one `AnswerFrameView`, so the field keeps its place in
  the hierarchy, and the keyboard its focus, as it moves down a row; the "almost" line and a held
  correction sit under the field, above the pending rows. Each row is labeled with its
  conjugationgroup in the chosen language, which replaces the card's Conjugationgroup line, and the
  field's VoiceOver label begins with it (`AnswerFrameView.spokenPrefix`). VoiceOver hears the verb
  only at a step's first question.
- **Rounds.** Five verbs, fifteen blanks (Josh, 2026-11-14), then "Five More Verbs" ("Fünf weitere
  Verben") in place of Ten More. `QuizDraw.verbEssentialsSteps` draws distinct verbs with a strong
  or mixed reading from the level's band (the level's pool does not apply), asking one such reading
  at random; verbs the session has asked come last, so later rounds are new while the band lasts.
- **Re-asks by step.** A missed blank returns after the next verb, as a step of its own whose other
  rows are given, so a re-ask never lands among another verb's blanks. A second miss in the same
  verb joins the first's re-ask step (`Quiz.reaskPlacement`).
- Never ranked, mixing in no due items, and donating no level tip. Its signals carry the source
  `verbEssentials`, and `completeQuiz` sends its `questionCount` (15 a round), which depends on no
  answer. The fixture `KONJUGIEREN_QUIZ_FIXTURE essentials` asks fahren as travel, aufstehen,
  verstehen, denken, and gehen, when Verb Essentials is started.
- **Ablaut groups.** An ablaut group's practice is Verb Essentials through
  `QuizScope.ablautPractice(_:)`, which chooses the readings as well as the verbs (below).

### Ablaut-Group Practice

Built 2026-11-15 in Phase 16 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T5.2): work through one ablaut group, then mix it with the groups already known. The support is
Pan et al. (2019), where practicing a pattern alone before mixing it did better; for ablaut groups
as such there is no study, so it is a bet. The practice is Verb Essentials, since the vowel changes
a group shares are what it asks.

- **A group is its ten most frequent verbs** (`AblautPracticeGroup.verbLimit`, Josh, 2026-11-15),
  at every level, or all of them when it has fewer. Counted over every verb, bleiben's 125 would
  need 188 right answers to be known. Membership is the Ablaut page's (the primary reading's
  group), and a member is asked only its readings that inflect by the group's pattern: both of
  fahren's, and hängen's strong one, never hängte. `AblautPracticeGroup.all` is built once, in the
  Ablaut page's order.
- **Known.** A group is known once at least half of its key conjugations have moved past the first
  box of the practice record (`isKnown(in:)`, Josh, 2026-11-13). A key conjugation counts once per
  verb, in whichever asked reading it climbed, so a group of ten verbs is 30 and one round of five
  answered right makes it known. Nothing is stored: it is computed from the record, so a wrong
  answer, which sends an item back to the first box, can make a group unknown again. A right
  answer moves an item up only when it is due (the ladder's rule), so a verb looked up today and
  answered right today stays in the first box until tomorrow.
- **Two sessions** (`AblautPracticeSession`), each in a `QuizSheet`. **Alone** draws five of the
  group's verbs, the session's unasked ones first. **Mixed** draws three of the group's verbs and
  two of the known groups' (`QuizDraw.ablautMixGroupVerbCount`, Josh, 2026-11-15), shuffled, taking
  one verb from each known group in turn so that a group of ten does not crowd out a group of one;
  whichever side is short leaves the rest to the other. Mixed opens for a group as soon as another
  group is known, whether or not the group itself is (Josh, 2026-11-15: nothing is earned).
- **Single-verb groups.** The 18 groups of one verb offer no practice alone, since one verb is not
  a pattern (Josh, 2026-11-13). They join other groups' mixes once known, which takes two of their
  verb's three key conjugations, climbed in any quiz.
- **Where it starts.** `AblautPracticeCard` sits in each expanded group of the Families tab's Ablaut
  page, below the `VerbCollectionBar`: Alone, Mixed, and a line naming the known groups Mixed adds
  or saying why it is closed. The hub's Ablaut Groups row pushes `AblautPracticeListView`, the 58
  groups with a pattern ordered by use (each group's most frequent verb: haben, geben, kommen),
  with a seal on the known ones, each expanding onto the same card. The Ablaut page was not pushed
  from the hub, since its article is more than a screen long. `isBeneathQuiz` is now true only
  while a quiz is in progress, so the cards work on pages the hub pushes.
- The results offer "Another Round" ("Noch eine Runde"), since a round may be fewer than five
  verbs, and show no level, which changes nothing here. Never ranked, no due items mixed in, no
  level tip. `startQuiz` carries the group's collection key. A mixed session sends neither
  `questionCount` nor `questionNumber`: its round can be short when the known groups hold few
  verbs, and which groups are known comes from the learner's answers (Decision 5).

### Name the Conjugation

Built 2026-11-15 in Phase 17 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T5.4): recognition, the direction a reader needs. "Name the Conjugation" ("Konjugationen
bestimmen", Josh's choice; *bestimmen* is the German classroom's word for naming a verb's cell)
shows a conjugation, such as käme, and asks for its infinitive, typed, and its conjugationgroup and
person, chosen from chips, since typing their names would test the metalanguage. It is a mode of its
own, a row in the hub's Exercises (Josh, 2026-11-13); the default quiz stays production practice.

- **The draw** is the default quiz's: the level's pool and band, mixed as in Phase 6
  (`QuizScope.recognition()`, ten a round, Ten More). The prompt is the asked cell's conjugation in
  the user's region and the main clause's word order (kam an, ist gekommen, seien Sie), ablaut in
  red. The verb and its gloss are not shown, since they are what is asked.
- **Every right reading is accepted.** `RecognitionQuestion.cells` holds every cell of every verb
  that writes the prompt: kommen is the Präsens and the Konjunktiv I of wir and sie, fuhr belongs
  to both readings of fahren, and weiß to wissen (ich, er) and weißen (the du Imperativ). Ambiguous
  prompts are not avoided, since deciding which cells a text can be is the skill. The verbs to try
  come from the conjugation map, by each word of the prompt; each is then matched cell by cell with
  `Verb.conjugations(matching:)`. A finite part alone is not its verb: the prompt kam does not
  accept ankommen. Only cells of the offered tables count, so at Elementary machte is the Präteritum
  Indikativ alone.
- **The chips** (`RecognitionChoicesView`) are the level's tables, in the verb page's order, and
  then the chosen table's persons (four for the Imperativ, none for a participle). One person is
  chosen; any right one is accepted. The chips sit above the field, so that they stay in sight
  above the keyboard and Return checks the answer; a Check button does too, enabled once the answer
  is complete. The infinitive is graded as the quiz grades: case and spacing aside, umlauts as
  digraphs, ß as ss.
- **The grade** (`RecognitionQuestion.grade`) is judged against the typed verb's cells when it is
  one of them, and against every cell otherwise, and names a part wrong only when changing it can
  make the answer right. An answer with any part right earns one more try at half points, with a
  line naming what to check ("Check the person. Try once more."), through Phase 4's mechanism
  (`QuizItem.firstAttemptRecognition`, Josh, 2026-11-15). Nothing right goes to the correction at
  once. The correction shows the answer part by part, the wrong parts in red, and lists every right
  answer, one line per verb and table ("kommen · Präteritum Konjunktiv II · ich, er"); the re-ask
  and links work as for any question.
- **Nothing is recorded** (Josh, 2026-11-15). Recognizing fuhr is not evidence of producing it, so a
  recognition answer moves neither the practice record nor `QuizErrorHistory`, whose misses the
  Tutor reads as production errors. The last result is kept, as `LastQuizResult.Kind.recognition`.
- Never ranked, no due items, the level tip donated as for the default quiz. Its signals carry the
  source `recognition`, and `completeQuiz` its `questionCount`. The fixture
  `KONJUGIEREN_QUIZ_FIXTURE recognition` asks ten prompts over every table, several ambiguous, when
  Name the Conjugation is started.

### Sentences

Built 2026-11-15 in Phase 18 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T5.5), so far with a first batch of content: a short authored sentence with its verb blanked, so
that a conjugation is tied to a meaning. "Sentences" ("Lückensätze", Josh's choice) is a mode of its
own, a row in the hub's Exercises (Josh, 2026-11-15).

- **The content** is `Konjugieren/Models/GapSentences.json`: for each sentence an id, the verb, a
  table (`ConjugationTable.articleKey`) and person (`PersonNumber` raw value), the German with each
  word of the conjugation in braces ("Gestern {sind} wir ins Kino {gegangen}."), the English, and
  `reviewed`. Claude drafts, `GapSentenceTests` checks, and Josh reviews every sentence (Josh,
  2026-11-13). `scripts/gap_sentences.py` writes a review sheet and marks approvals.
- **The machine check** (`GapSentenceTests.everyBlankIsTheConjugatorsConjugation`) reads each
  sentence's braces in order and requires the conjugator's conjugation of its cell, in the main or
  the subordinate clause's word order, and the same words in every region (Swiss ss aside), so that
  no sentence teaches a wrong conjugation or shows an Austrian learner a German auxiliary. It cannot
  judge whether the word order suits the sentence: "{fängt} {an}" after *wann* passes it, so that is
  Josh's review. Other checks: one or two one-word blanks, a verb in the top 300, a cell some level
  asks, and the wir or Sie of an Imperativ after the first blank.
- **Drafts.** A release build asks only reviewed sentences; a debug build asks drafts too and marks
  each card "Draft" ("Entwurf"), so that a draft can be tried in the app (`GapSentences.includesDrafts`).
- **The frame** is Phase 2's `AnswerFrame`, with the sentence's words as `.context` segments, laid
  out word by word in a `FlowLayout` so that a long sentence wraps; every blank is one width, so it
  does not hint at the answer's length, and a full stop written against a blank stays with it. The
  wir and Sie of an Imperativ are a `.word` the frame supplies ("{Nehmen} Sie bitte Platz!"), as in
  the one-line frame. The English is shown beneath; the conjugationgroup line stays, and the
  sentence's subject gives the person.
- **Grading in the sentence's clause.** A separable verb after a conjunction is graded in the
  subordinate clause's order alone (`GapSentence.clause`, `Quiz.makeQuizItem(clauses:)`): "anfängt"
  fills "wann der Film {anfängt}", and "fängt an" does not, though the one-line quiz takes both. The
  correction shows that clause's conjugation, and the whole sentence read back with it in place.
- **The draw** (`QuizDraw.sentences`): the sentences the level asks (`GapSentence.isAskable(at:)`,
  its band and pool), the session's unasked first, one a verb where they allow; a smaller pool makes
  a shorter round, and once every sentence is asked, Ten More asks them again. The hub's row says
  when a level has none.
- **Recorded as production.** A sentence answer goes through `submitAnswer`, so it moves the practice
  record and, when wrong, `QuizErrorHistory`, and earns Phase 4's and Phase 14's second attempt.
  Never ranked, no due items, the level tip donated as for the default quiz.
  `LastQuizResult.Kind.sentences`. The fixture `KONJUGIEREN_QUIZ_FIXTURE sentences` asks ten
  sentences, one per kind of frame, when Sentences is started.
- **The literary reward** (Josh, 2026-11-13 and 2026-11-15): on every quiz's results screen, the
  first row of each verb answered right offers its bundled literary example (`ExampleSentences`),
  revealed by a tap. The quiz never pauses after a right answer to show it, though a choice question
  holds after any answer for its reason. The reveal sends no signal.

### Choice Questions

Built 2026-11-15 in Phase 19 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T5.6): a setting and the same sentence in two conjugationgroups, of which the learner taps the one
a German speaker or writer would use. The quiz otherwise never asks a learner to choose a
conjugationgroup, and choosing is where much real difficulty lies. Not a mode: one question of every
default round, Ten More's included, from Elementary up (Josh, 2026-11-13 and 2026-11-15).

- **The content** is `Konjugieren/Models/ChoiceQuestions.json`: for each item an id, the verb (and
  reading), one person for both sentences, the `QuizLevel` from which it is asked, a setting
  (`ChoiceSetting`: conversation, news, story), a reason (`ChoiceReason`), the `right` and `other`
  sentences (each a table and the German with the conjugation in braces, as in Sentences), the
  English, and `reviewed`. Four contrasts across nine reasons: the Perfekt in conversation, with sein
  and haben's Präteritum as the exception, and the Präteritum in a written story; würde for most
  verbs, and the one-word Konjunktiv II of sein, haben, and the modals; the Präsens with a word for
  when, and the Futur without one; the Konjunktiv I in a news report, and the Indikativ in
  conversation. `scripts/choice_questions.py` writes a review sheet and marks approvals.
- **The machine check** (`ChoiceQuestionTests`) reads each sentence as a `GapSentence`
  (`ChoiceQuestion.rightSentence`, `.otherSentence`) and requires Phase 18's check of both: the
  braces are the conjugator's conjugation of the cell in every region. Also: the two tables differ,
  the item's level asks its verb, in its band, the right sentence's cell (`isAskable(at:)`), every
  reason names its conjugationgroups in both name languages, and every contrast and level is
  covered. The other sentence's cell may be one no level asks (kaufte as kaufen's Konjunktiv II).
  Whether the choice is right in German is Josh's review, with Claude's reread.
- **The reasons** are nine strings in `Localizable.xcstrings` (`Choice.reason…`), each naming the
  right conjugationgroup, and two of them the other too, in the learner's chosen language for names
  (`ChoiceQuestion.reasonLine(lang:)`), so that one string serves every item of its kind. The
  setting is shown in German with its English gloss, as a verb is; it takes the verb's place on the
  card.
- **The draw** (`QuizDraw.choice`, `QuizDraw.choicePosition`): `QuizScope.mixesChoiceQuestions`,
  true only for the default quiz, asks one item of those the level asks (from its level up, drafts
  in debug builds), the session's unasked first, with the right sentence first or second at random.
  It takes one of the round's ten places, anywhere but first, so that a round opens on the
  keyboard, and the draw of the other nine shrinks by one. Beginner has no items and asks none. A
  ranked first round still scores out of 100.
- **The answer** (`Quiz.submitChoice`): 10 points if right, none if wrong, with no second attempt
  and no re-ask, since a choice of two would then be known. Right or wrong, the card holds, with the
  clock stopped, showing the right sentence in green, a wrong choice in red, the reason, and
  Continue (`Quiz.isHoldingChoice`, `Quiz.isHeld`; Josh, 2026-11-15), because a right choice of two
  can be a guess and the reason is the lesson. Choosing a sentence is not producing its
  conjugation, so the practice record and `QuizErrorHistory` are untouched, as for Name the
  Conjugation. The results row shows the right sentence's conjugation, and the chosen one in red
  when wrong. `ChoiceQuestionView` draws the card.
- **Signals.** None new: the question is part of a default round, whose signals are unchanged, and
  which item was asked or how it was answered may not be sent (Decision 5).
- **VoiceOver.** Each sentence is a button read as its sentence and conjugationgroup, under the
  header "Which fits here?"; once chosen, its value says "Your choice" and "The right choice". The
  answer is announced ("Correct. In conversation, most verbs take the Perfekt Indikativ." or
  "Incorrect. The right choice: … ") and focus moves to the reason. Magic Tap continues.
- **The fixture** `KONJUGIEREN_QUIZ_FIXTURE choices` asks ten choice questions, one per reason, when
  the default quiz is started.

### Speed Round

Built 2026-11-15 in Phase 21 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T5.7): sixty seconds of questions on items already mastered, counting right answers. It is Paul
Nation's fluency strand, speed for material already accurate, and the one place the clock counts.
"Speed Round" / "Blitzrunde", a row in the hub's Exercises.

- **What it asks** (`Models/SpeedRound.swift`). `SpeedRound.masteredItems(in:)`: the record's items
  in box 2 or higher (`MasteryState.masteredBox`, the seven-day interval, as on the Mastery page),
  that can still be asked, in key order. `QuizDraw.speedRoundQuestions` asks each item once before
  any again, never the same item twice running, the last of the batch before included. A mastered
  key conjugation asks any cell built on its stem that the level asks of the verb, or its own er
  cell (`QuizDraw.speedRoundCells`: mastered fuhr can ask du fuhrst at Intermediate, and asks er fuhr
  at Elementary, whose Präteritum is sein's, haben's, and the modals'). A pattern asks its cell of a
  weak verb of the level's band, a fresh one each time. Otherwise not held to the level, since a
  mastered item stays mastered when the level changes (Josh, 2026-11-15, all four).
- **When it opens.** At `SpeedRound.minimumMasteredCount`, 5 mastered items; a round repeats them as
  it needs. Below that the row is not a button and says how many are mastered so far.
- **The round.** `QuizScope.speedRound()`; `Quiz.generateQuestions` draws `SpeedRound.batchSize`, 10,
  and `advance()` draws another batch as the round reaches the last question of this one. An answer
  (`Quiz.submitSpeedRoundAnswer`) never holds: no second attempt (a slip is a miss), no diagnosis, no
  correction, no re-ask. A miss's right answer shows above the next question
  (`Quiz.speedRoundMiss`, `SpeedRoundMissLine`), "fahren · er fährt". The card shows "Correct" and
  "Time Left" (0:59 …) whatever the clock setting, the last ten seconds in red; there is no row of
  dots, since the questions are drawn as it goes.
- **The clock.** `Quiz.clockTicked()`, which the timer calls each second and tests call directly.
  At 0 (`speedRoundSecondsLeft`) the round ends: the question on screen, unanswered, and the rest of
  the batch are dropped, so the results list what was answered. Leaving the app pauses it, as for
  every quiz.
- **Nothing recorded.** The round leaves the practice record and `QuizErrorHistory` untouched: a miss
  does not send an item down the ladder, since speed errors are often haste (Josh, 2026-11-13), and
  counting only hits would make the record one-sided (Josh, 2026-11-15).
- **The personal best** (`PracticeStore.speedRoundBest`, under `speedRoundBest` in the App Group) is
  the most right answers in one round, kept on the device. `recordSpeedRound(_:)` keeps a count that
  beats it (a round with none right sets none). Reset Practice forgets it. The results show "Right
  Answers in 60 Seconds", the count, "New personal best!" or "Your best: n", the questions, and
  Another Round, which starts a fresh round; the hub's row shows "Best: n". The last result's kind is
  `.speedRound`, and its row shows no points.
- **Never ranked, never continued** (`continues` false: no Ten More, no Live Activity, no level tip).
- **Signals.** `source` `speedRound` on the quiz signals. **No counts**
  (`QuizScope.sendsQuestionCounts`): a round's length is how many questions were answered in a
  minute, a measure of the answers. The best is never sent.
- **VoiceOver.** A miss is announced ("Incorrect. The answer was er fährt."), so is "Ten seconds
  left.", and the end ("Time is up. Right answers: 12. New personal best!"). The miss line reads the
  same. The row has a hint, and so does Another Round.

### The Daily Session and the Streak

Built 2026-11-15 in Phase 22 of [`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)
(T6.3): a short daily session, a streak that one missed day does not break if repaired, and an
optional reminder. "Daily Session" / "Tägliche Übung", the first row of the hub's From Your
Practice, with a flame once there is a streak.

- **What it asks** (`Models/DailySession.swift`, `QuizDraw.dailyQuestions`). Ten questions at the
  learner's level (Josh, 2026-11-13): first the record's due items that the level asks and the band
  holds, most overdue first (`QuizDraw.dueQuestions` with a limit of ten), then the default quiz's
  balanced draw for the rest, the due questions placed among them at random. An item the level does
  not ask waits for Review, as in the default quiz. No choice question, since a choice moves nothing
  in the record. Every answer moves the record as in any quiz.
- **The scope.** `QuizScope.daily(source:)`, `isDaily`. Never ranked; `continues` false, so no Ten
  More and no level tip, though it starts a Live Activity, since ten questions are a real session.
  `LastQuizResult.Kind.daily`.
- **The streak** (`Models/DailyStreak.swift`). `DailyStreak` keeps finished daily sessions per day
  (`2026-11-15`, the learner's calendar) under `dailyStreak` in the App Group, through
  `PracticeStore.dailyStreak`, `recordDailySession(at:)`, and `streakStatus(at:)`. A session counts
  when its results appear (`Quiz.finishQuiz`); a quit one does not. `status(at:)` is `.none`,
  `.active(length:isDoneToday:)`, or `.repairable(length:sessionsToday:)`. Days join a run when
  consecutive, or across one missed day when the day after has **two** sessions (Josh, 2026-11-13);
  the missed day does not count toward the length. One session on that day starts a run of its own,
  reported as `.repairable(…, sessionsToday: 1)` until the second, and if the day ends there the old
  streak is gone. Only the last two runs are kept. Day arithmetic is in calendar days, so a 25-hour
  day is one. Reset Practice forgets the streak.
- **The hub and the results.** The row says, by status: what the session is and that one a day
  builds a streak; "Streak: 5 days. Today's session keeps it going." or "… Done for today."; "You
  missed yesterday. Two sessions today keep your 5-day streak."; "One more session today keeps your
  5-day streak." It always starts a session; a second on an ordinary day changes nothing. The
  results show the streak with a flame, and while a repair awaits its second session, Another
  Session in place of Ten More (`DailyStreak.Status.awaitsRepairSession`).
- **The reminder** (`Models/DailyReminder.swift`, `Utils/ReminderSchedulerReal.swift`). Settings'
  Daily Reminder, Off or On (`Settings.dailyReminder`, off by default), and a time
  (`Settings.dailyReminderMinutes`, 18:00). **Permission is asked only when it is turned on**
  (`ReminderScheduler.requestAuthorization`); refused, the setting stays Off with a line and Open
  Settings, which also show while On if notifications were later turned off in the Settings app.
  `DailyReminderPlan.reminders` writes one notification per day for 14 days, not a repeating one,
  so that each says what that day will have due ("Your daily session is ready, with 8 conjugations
  due for review.") or that its streak needs repair, and a day whose session is done gets none.
  `World.rescheduleReminders()` replaces them when the setting or time changes, a daily session
  finishes, practice is reset, and the app becomes active or goes to the background. A learner who
  does not open the app for two weeks stops being reminded. Tapping a reminder opens
  `konjugieren://quiz/daily?source=reminder` (`ReminderNotificationDelegate`, set in `AppDelegate`),
  which starts a session unless a quiz is under way. A reminder due while the app is open is not
  shown. The widgets do not show the streak (Josh, 2026-11-13).
- **Signals.** `source` `daily` or `reminder` on the quiz signals; `completeQuiz` of a daily session
  carries `streak` in bands (`AnalyticsBand.streak`: `1`, `2-6`, `7-29`, `30+`), the streak at stake
  while a repair awaits its second session; `tapDailyReminder` with `enabled`. Question counts are
  sent, since a daily session is always ten.
- **VoiceOver.** The row reads its title and its line, with a hint ("Starts ten questions, beginning
  with what is due for review."); the results' announcement ends with the streak line; Another
  Session has a hint. Every quiz state inside the session is an ordinary one.

### The Quiz Clock

`Settings.quizClock` (`QuizClock`: `.hide`, `.show`), default `.hide` (T6.5). While it is hidden,
the quiz card, the results, and the Live Activity show no time; `elapsedTimeLiveActivity` is nil
and the timer's Live Activity updates are skipped. The clock still counts, still stops while a
correction is held, and still runs across Ten More. A Speed Round shows its time left whatever the
setting.

### Scoring

- **10 points** per correct answer, **5** for one right on the second attempt, and **5** for a
  right re-ask, on whichever attempt
- Each `QuizItem` knows its `points` and `maximumPoints`; `score`, `correctCount`,
  `secondAttemptCount`, `reaskCount`, and `reaskCorrectCount` are computed from `questions`.
  `correctCount` and `secondAttemptCount` exclude re-asks. The results' score color is
  `score / maximumScore`
- **The same at every level.** Ridiculous's doubling went with the levels (Phase 5); each level
  has its own leaderboard (Phase 8), so no score compares across levels
- **Leaderboard:** only a ranked quiz (every verb, the default scope) submits a score, and only
  when its first round's results appear: `firstRoundScore`, the first ten questions' points
  without their re-asks, so every ranked score has a ceiling of 100 (Josh, 2026-11-13, for Phase
  8; adopted early in Phase 7). Ten More's points are never posted. The score goes to the
  leaderboard of the level the quiz started at (`QuizLevel.leaderboardID`)
- `quiz.finalScore` equals `score`

### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `isInProgress` | `Bool` | Quiz currently active |
| `scope` | `QuizScope` | What the quiz asks about |
| `questionCount` | `Int` | The session's questions so far, re-asks excluded: 10, 20, 30, …, or 3 on a verb page (`Quiz.questionCount` is a round's 10) |
| `roundCount` | `Int` | Rounds begun: 1, then one more for each Ten More |
| `currentIndex` | `Int` | Index of the current item in `questions`, re-asks included |
| `level` | `QuizLevel` | The level the quiz was started at |
| `score` | `Int` | Points so far, summed from the items |
| `firstRoundScore` | `Int` | The first round's points without re-asks: what a ranked session posts |
| `finalScore` | `Int` | The score submitted and shown in the results; equal to `score` since Phase 5 |
| `elapsedSeconds` | `Int` | Time elapsed |
| `correctCount` | `Int` | Number right on the first attempt |
| `secondAttemptCount` | `Int` | Number right on the second attempt |
| `reaskCount`, `reaskCorrectCount` | `Int` | Re-asks so far, and those answered right |
| `isAwaitingSecondAttempt` | `Bool` | A slip or a diagnosed error waits for its one more attempt |
| `questions` | `[QuizItem]` | Every round's questions and re-asks, in the order asked |
| `correction` | `QuizCorrection?` | The held correction of a wrong answer: its `AnswerDifference`, its `AnswerDiagnosis` if any, and the `ErrorExplainerContext` the disabled explainer would take |
| `lastPreferredSpelling` | `String?` | The conjugation's own spelling of the last answer, when it was right but spelled another way |

### Sound Effects

Quiz uses `SoundPlayer` for audio feedback:
- **Start:** Random gun sound
- **Correct answer:** Chime
- **Slip (one more try):** Pop
- **Incorrect answer:** Buzz
- **Quit:** Random sad trombone
- **Finish:** Random applause

## Game Center Integration

The app posts quiz scores to Game Center, one leaderboard per quiz level (Phase 8 of the pedagogy
plan, 2026-11-14). The configuration in App Store Connect and in `GameCenterResources.gamekit`,
with every leaderboard's ID, names, and settings, is in
[`game-center-setup.md`](game-center-setup.md).

### Architecture

| File | Purpose |
|------|---------|
| `GameCenter.swift` | Protocol for authentication, score submission, and showing leaderboards; `QuizLevel.leaderboardID` |
| `GameCenterReal.swift` | Real `GKLocalPlayer` and `GKLeaderboard` implementation |
| `GameCenterSpy.swift` | Records submissions and shown leaderboards, for tests (`World.unitTest`) |
| `QuizView.swift` | "View Leaderboard", the current level's board, at the foot of the Quiz tab's hub (pedagogy Phase 13; until then on a ranked quiz's results) |
| `SettingsView.swift` | "View Leaderboards", Game Center's list of the app's boards |

Both buttons appear only while the player is signed in to Game Center.

### Leaderboards

- **IDs:** `konjugieren.level.beginner`, `.elementary`, `.intermediate`, `.advanced`, from
  `QuizLevel.leaderboardID`. They are permanent in App Store Connect; a test pins them
- **Score:** `Quiz.firstRoundScore`, 0 to 100, Best Score, High to Low
- **Which quizzes post:** see Scoring above. `QuizScope.isRanked` decides, and `Quiz.finishQuiz`
  posts on the first round's results only
- The original leaderboard, `Leaderboard`, is retired on `main` and still live for the shipped app

### API Notes

`GameCenter.submitScore(_:level:)` is synchronous: `GameCenterReal` starts its own `Task` for
`GKLeaderboard.submitScore`, so that `Quiz` can call it inline and a spy records the call at once.
`showLeaderboard(level:)` uses `GKAccessPoint.shared.trigger(leaderboardID:playerScope:timeScope:)`,
and `showLeaderboards()` uses `GKAccessPoint.shared.trigger(state: .leaderboards)`. These replace
the deprecated `GKGameCenterViewController` and `GKGameCenterControllerDelegate` APIs.

### Authentication Flow

1. `KonjugierenApp.init()` calls `Current.gameCenter.authenticate()`
2. iOS presents Game Center login UI if needed
3. `gameCenter.isAuthenticated` becomes `true` when successful

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
| `quiz` | `set`, `daily`, or any other (today `start`) | For `set`: `groups`, `verbs` or `infinitives`, `level`, `source`; for `daily`, `source` | `set` shows a practice set in a sheet over the open tab; `daily` opens the Quiz tab and starts a daily session unless a quiz is under way or showing results (`World.dailySessionRequest`), which the reminder taps (`quiz/daily?source=reminder`); any other target, the Quiz tab | Before 2026; `set` pedagogy Phase 10; `daily` pedagogy Phase 22 |
| `list` | A collection's key: `top100`, `modals`, `sein`, or `ablaut-<exemplar>` (`ablaut-hängen`, percent-encoded) | `source` | The Families tab, on the collection's page, or for an ablaut group, the Ablaut page with that group expanded | Phase 16 |

**Collections (Phase 16, 2026-11-13).** A collection is `list/<key>`. The `quiz/start?list=<key>`
link that Phase 11 reserved was not built: a shared collection opens its page, where Quiz is one
tap, so the quiz route took no query items until pedagogy Phase 10 gave its `set` target the
practice set's (below). A shared collection's text carries its `list` link
with `source` `sharedLink` beside the App Store link, as Josh chose on 2026-11-13, knowing that
Messages may not make a `konjugieren://` link tappable and that it does nothing without the app.

### Architecture

| File | Purpose |
|------|---------|
| `URLExtension.swift` | The grammar's constants (routes, query-item names), `isDeeplink`, `analyticsSource`, `deeplinkQueryValue(named:)`, and the builders, `practiceSetDeeplink` among them |
| `PracticeSet.swift` | Reads a `quiz/set` link (`PracticeSet(url:)`) and writes one |
| `World.swift` | `handleURL(_:)` parses a link and sets `verb` (with `verbSource` and `verbMarks`), `searchRequest`, `family`, `collection` (Phase 16), `practiceSet` (pedagogy Phase 10), or `info`, and the selected tab; `openSearch(text:source:)` is the search route's effect, which Command-F also uses |
| `Info.swift` | `Info.info(deeplinkTarget:)` resolves a stable key or a legacy position |
| `VerbBrowseView.swift` | Consumes `verb` and `searchRequest` on appear and on change, since a link can arrive before the tab first appears |
| `FamilyBrowseView.swift` | Consumes `family` and `collection` the same way |
| `KonjugierenApp.swift` | Receives URLs via `.onOpenURL`, and a control's pending link from the shared defaults when the scene becomes active |

### Examples

```
konjugieren://verb/singen                         → singen's page
konjugieren://verb/gehen?match=ging&source=lookup → gehen's page at the Präteritum, ich ging and er ging marked
konjugieren://search?q=stand%20auf                → the verb list searched for "stand auf"
konjugieren://search?source=control               → the verb list with an empty, focused field
konjugieren://info/futur_ii                       → the Futur II article
konjugieren://info/0                              → the Dedication article (legacy position)
konjugieren://list/modals?source=sharedLink       → the Modal Verbs collection
konjugieren://list/ablaut-h%C3%A4ngen             → the Ablaut page, the hängen group expanded
konjugieren://quiz/set?groups=imperativ&verbs=modals&source=sharedLink → a practice set: the Imperativ of the modal verbs
konjugieren://quiz/set?infinitives=gehen,h%C3%A4ngen&level=beginner    → a practice set: Beginner's conjugationgroups of gehen and hängen
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
whether the text is only a finite part). It matches against every region and both clauses,
ignoring case and spacing, as the quiz grades, but without the quiz's pronoun stripping, digraphs,
or standard variants (Phase 1 of the pedagogy plan), which a cell lookup does not need: "stand auf" and "aufstand" both match aufstehen's Präteritum,
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
Verbs, the quiz's My Verbs scope, the verb of the day and random verb (Phase 14), and the review
card (Phase 15), and collections (Phase 16) read it today; the quiz track will.

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
would vanish without an error. `LearnerVerbsTests` pins the decoding of a minimal entry. Browse
Phase 15's `review` was such a field; pedagogy Phase 11 moved it into the practice record, and
decoding ignores it in records written before.

**Where it shows.** The verb page's star. The verb list's picker, whose third segment, My Verbs,
lists the starred verbs, then the recent ones not starred, with Clear on the recent heading.
It is a `List`, unlike the rest of the verb list, because only a `List`'s rows can be swiped: a
left swipe deletes a recent verb at once, and a starred verb after an alert asking to remove its
star. Deleting forgets the verb entirely, so an opened, starred verb leaves My Verbs rather than
dropping into Recent. On iPad it is a list rather than the grid the other modes use. Search
ignores the picker, as it ignores the sort order. And the verb list with its search field
focused and empty, which lists the recent verbs under Recent, reachable with the arrow keys and
Return on iPad and Mac. Nothing is shown when there is no history.

### The Review Card

Built 2026-11-13 in Phase 15 of the browse plan, for idea D4, and moved onto the practice record
(§ The Practice Record, under Quiz System) on 2026-11-14 in Phase 11 of the pedagogy plan. Each
launch, and each return from the background, the verb list shows one card above its rows when a
strong or mixed verb has a key conjugation due: the verb whose item is longest overdue, a caption
saying when it was last touched ("Looked up 3 days ago", or "Practiced 3 days ago" when a quiz
answer came after the lookup), the asked reading's gloss, and its key conjugations hidden under a
placeholder. A tap reveals them, red letters and all; a second tap opens the page, with `source`
`reviewCard`; ✕ dismisses the card. Nothing replaces a dismissed card until the next opening, and
the card hides while a search, the recents, or My Verbs shows. The Suppress Review Card setting
(`ReviewCardSuppression`, off by default) hides it altogether; the schedule keeps running
underneath.

| Piece | Role |
|---|---|
| `PracticeStore.cardOffer(at:)` | The verb and reading of the longest-overdue key conjugation, with every due key conjugation of that reading, the days since the last activity, and whether that was a lookup |
| `PracticeStore.recordLookup(_:source:)` | Called by the verb page on every open; puts a strong verb's key conjugations in the first box |
| `ReviewCardView.swift` | The card. `VerbBrowseView` chooses the offer and applies each tap to the record |

**What moves a verb (Josh, 2026-11-13, kept in Phase 11).** An open puts each strong or mixed
reading's three key conjugations in the first box, due the next day, and so does any later open,
since looking a verb up again suggests it was forgotten. An open from the card itself is the
exception. Revealing moves each due key conjugation of the offered reading up a box; one not yet due
keeps its place. Dismissing before revealing is no review: each due one keeps its box and returns
the next day. Quiz answers move the same items.

**Weak verbs are no longer offered** (Josh, 2026-11-14). Their conjugations are patterns shared by
every weak verb, so a lookup of a weak verb schedules nothing, and Review (pedagogy Phase 12) drills
the patterns. On the first launch with a practice record, each strong verb's Phase 15 schedule
(`LearnerVerbs.Entry.review`, or for an older entry its last open) became its key conjugations'
schedule, and weak verbs' schedules were dropped.

## Collections

Fixed lists as places to go, from idea D6 of
[`browse-and-verb-ideas.md`](browse-and-verb-ideas.md): the 100 most frequent verbs, the modal
verbs, the verbs that take sein, and each of the 76 ablaut groups. Built 2026-11-13 in Phase 16 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md). Each shows
how many of its verbs have been looked up, starts an unranked ten-question quiz on itself in a
sheet, and is shared as text with a `list/<key>` link and the App Store link.

| Piece | Role |
|---|---|
| `VerbCollection.swift` | The collections, their keys, their verbs (alphabetical, as every list's arrive), the share text, `viewCollection`, and `QuizScope.collection(_:)` |
| `VerbCollectionView.swift` | A featured collection's page, and `VerbCollectionBar` (progress, Quiz, Share), which the Ablaut page's expanded groups also show |
| `FamilyBrowseView.swift` | The Collections section at the top of the Families tab, and the `list` route's landing |
| `LearnerVerbs.hasOpened(_:)` | What counts toward progress: a verb with a last open. Clear in My Verbs forgets opens, so it resets every collection's progress; a star alone does not count |

**Where they live (Josh, 2026-11-13).** At the top of the Families tab, which keeps its name. The
ablaut groups stay on the Ablaut page, where an expanded group now begins with the bar, rather
than each getting a page of its own. The seven family pages did not become collections.

**Membership.** The modal verbs are the six by name. The verbs that take sein are those with any
reading that takes sein in the learner's region, so fahren is in for "ist gefahren", and liegen,
sitzen, and stehen are in only for Austria and Switzerland (607 northern, 610 southern on
2026-11-13). An ablaut group's verbs are those whose primary reading is in the group, as on the
Ablaut page; 18 of the 76 groups hold a single verb (sein, tun, können, …), and those have the
bar too.

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

### Choosing the Verb

`VerbDraw` chooses the widget's verb for each day and every random verb (the `verb/random`
deeplink, which the Random Verb control and shortcut send). Built 2026-11-13 in Phase 14 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md).

- **The frequent verbs** are `FrequencyBand.top1000`, the bands being defined once on `Verb`
  (`isIn(_:)`, `verbs(in:)`) for the quiz track as well. A draw weights each verb by 2 if it is
  strong or mixed and by 2 if it has no prefix, so gehen counts 4 and abarbeiten 1. About 80% of
  draws land on a strong or unprefixed verb, against 64% of the band.
- **My Verbs** (starred, then recent, as `LearnerVerbs.myVerbs`) gets one draw in three once it
  has entries, as Josh chose. For the widget that is every third day, by day number, taking the
  verbs in turn; independent draws left gaps of two weeks and repeated one verb while another
  waited. A random verb goes to My Verbs by a one-in-three chance. A My Verbs day changes no other
  day's verb.
- **Determinism.** A day's frequent verb comes from `SeededRNG` seeded with the day's number since
  2025-01-01, read with plain modulo rather than `Int.random(in:using:)`, whose use of the generator
  is not documented.
- **Stable through the day.** The app rewrites the bundle at every activation, and My Verbs may
  have changed since the last write. `WidgetSnapshotWriter.writeSnapshot` reads the old bundle,
  asks it which snapshot the widget shows now (`WidgetSnapshotBundle.displayedSnapshot(at:pageOffset:)`,
  the page offset included), and puts that verb where the new bundle shows today. This also keeps
  the quiz widget's answered state, which is keyed by date and infinitive.
- **Eligibility.** The widget still draws only verbs with an example sentence, which today is all
  of them.

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
| `QuizActivityAttributes.swift` | ActivityKit model: level (its localized name), current state |
| `GameActivityAttributes.swift` | ActivityKit model: wave, score, health fraction, phase |
| `QuizLiveActivityView.swift` | Widget-side view rendering quiz progress |
| `GameLiveActivityView.swift` | Widget-side view rendering game state |

### Quiz Live Activity State

| Field | Description |
|-------|-------------|
| `currentQuestion` | Position in the session, re-asks included |
| `totalQuestions` | The session's items so far, which grows with each re-ask and Ten More |
| `score` | Running score |
| `correctCount` | Running correct count |
| `elapsedTime` | Formatted elapsed time string, nil while the quiz clock is hidden |
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
| `viewReviewCard` | None | Once per card shown: when the review card first appears after a launch or a return from the background (Phase 15) |
| `viewCollection` | `collection` (its key, such as `modals` or `ablaut-gehen`), `source` (`family`, `sharedLink`, `deeplink`, `quizCorrection`) | When a collection's page appears, once per arrival, or an ablaut group is expanded on the Ablaut page (Phase 16). The ideas document's "lists opened". The key names a fixed list, not anything the learner chose |
| `tapShareCollection` | `collection` | When a collection's share button is tapped, whether or not the learner then shares (Phase 16) |
| `tapResetPractice` | None | When Reset Practice in Settings is confirmed (pedagogy Phase 11). Nothing about the record is sent |
| `tapDailyReminder` | `enabled` (`true`, `false`, `denied`) | When Settings' Daily Reminder is set On or Off (pedagogy Phase 22). `denied`: turned on, and notification permission refused, now or before, so the reminder stays off. Changing the time sends nothing |
| `viewMastery` | None | When the Mastery page, pushed from the Quiz tab's hub, appears (pedagogy Phase 20). Nothing about the record or the level is sent |
| `tapRevealReviewCard` | None | When a tap reveals the review card's key conjugations, once per card (Phase 15). A page opened from the card then sends `viewVerbView` with `source` `reviewCard` |
| `tapViewLeaderboard` | `source` (`tab`) from the Quiz tab's hub; none from Settings | When View Leaderboard on the Quiz tab's hub (pedagogy Phase 13) or View Leaderboards in Settings is tapped. The results screen's button, which sent nothing, is gone |
| `startQuiz`, `quitQuiz`, `completeQuiz` | `source` (`tab`, `myVerbs`, `verbPage`, `list`, `custom`); `level` (`beginner`, `elementary`, `intermediate`, `advanced`); `quitQuiz` also `questionNumber` and `duration` (`0-3s`, `3-15s`, `15-40s`, `40s-2m`, `2m+`); `completeQuiz` also `questionCount` (`10`, `20`, `30`, …, or `3`); `startQuiz` alone also carries `collection` for a collection's quiz (Phase 16), or for a custom quiz over a collection, and `customChoice` (`conjugationgroups`, `verbs`, `both`) for a custom quiz (pedagogy Phase 9). A Review or My Mistakes session (`review`, `mistakes`, pedagogy Phase 12) sends neither `questionCount` nor `questionNumber`, since either would tell how many items were due or missed, and neither does a mixed ablaut session (`ablautMixed`, pedagogy Phase 16); an ablaut group's practice carries `collection` | When a quiz starts, is quit, or reaches its results (`source` since Phase 13). Without it, three-question quizzes would inflate the completion rate of the default quiz. `level` replaced `difficulty` (`regular`, `ridiculous`), which only `quitQuiz` and `completeQuiz` sent, in Phase 5 of the pedagogy plan, and `startQuiz` gained it then (M1). Since Phase 7, `completeQuiz` is sent at each round's results, and its `questionCount` says how many rounds' questions the session has asked, so Ten More shows as `20` and `30`. `duration` (M3) is wall-clock time from the start to the quit, background included. `questionNumber` counts re-asks |
| `abandonQuiz` | `source`, `level`, `questionNumber` (not for `review` or `mistakes`) | At launch, once for each quiz the last run left in progress (M2, Phase 7 of the pedagogy plan): the app was closed or killed during a question. `QuizAbandonment` keeps an entry per running quiz in `GetterSetter`, written at the start and at each question and removed at a quit or the results. A quiz left at its results is not abandoned |

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
| `ablautAlone` | Yes | The quiz signals only: an ablaut group practiced alone (pedagogy Phase 16) |
| `ablautMixed` | Yes | The quiz signals only: an ablaut group practiced mixed with the known groups (pedagogy Phase 16) |
| `browse` | Yes | A row of the verb list with the search field empty |
| `control` | Yes | The Random Verb control in Control Center; for `finishSearch`, the Find a Verb control |
| `custom` | Yes | The quiz signals only: a custom quiz from the Quiz tab (pedagogy Phase 9) |
| `deeplink` | Yes | A `konjugieren://` link with no recognized `source` |
| `lookup` | Yes | Look Up a Verb: the page it opens, or the search it opens when the word is ambiguous (Phase 11) |
| `family` | Yes | A verb on a family's page, including an expanded ablaut group; for `viewCollection`, a collection opened from the Families tab |
| `handoff` | Yes | Handoff from another device |
| `infoLink` | Yes | A verb linked from an Info article |
| `related` | Yes | A verb in a verb page's Related Verbs card, or in the full list it opens |
| `quizCorrection` | Yes | A verb page opened from a quiz's held correction; for `viewCollection`, an ablaut group opened from it (pedagogy Phase 3) |
| `quickAction` | Yes | `finishSearch` only: the Find a Verb quick action on the app icon (Phase 11) |
| `resume` | Yes | The same page appearing again (see above) |
| `search` | Yes | A search result, opened by tap, Return, or the arrow keys |
| `searchGuess` | Yes | The guess under "No verbs found" |
| `shortcut` | Yes | The Open Verb and Random Verb shortcuts |
| `spotlight` | Yes | A Spotlight result |
| `widget` | Yes | Any home-screen, lock-screen, or quiz widget |
| `sharedLink` | Yes | `viewCollection` only: a collection's `list` link inside the text its share button sends (Phase 16). A verb's share text carries only the App Store link, as Josh chose on 2026-11-12 |
| `myVerbs` | Yes | A verb in the verb list's My Verbs (Phase 12); for the quiz signals, a quiz over My Verbs (Phase 13) |
| `recent` | Yes | A recent verb, listed while the search field is focused and empty (Phase 12) |
| `list` | Yes | A verb on a featured collection's page; for the quiz signals, a collection's quiz (Phase 16) |
| `reviewCard` | Yes | The review card, tapped after its conjugations are revealed (Phase 15) |
| `review` | Yes | The quiz signals only: a Review session from the Quiz tab (pedagogy Phase 12) |
| `mistakes` | Yes | The quiz signals only: a Practice My Mistakes session from the Quiz tab (pedagogy Phase 12) |
| `verbEssentials` | Yes | The quiz signals only: Verb Essentials from the Quiz tab (pedagogy Phase 15) |
| `ablautAlone`, `ablautMixed` | Yes | The quiz signals only: an ablaut group's practice, alone or mixed (pedagogy Phase 16) |
| `recognition` | Yes | The quiz signals only: Name the Conjugation from the Quiz tab (pedagogy Phase 17) |
| `sentences` | Yes | The quiz signals only: Sentences from the Quiz tab (pedagogy Phase 18) |
| `speedRound` | Yes | The quiz signals only: the Speed Round from the Quiz tab (pedagogy Phase 21) |
| `daily` | Yes | The quiz signals only: a daily session from the Quiz tab, or from Another Session on its results (pedagogy Phase 22) |
| `reminder` | Yes | The quiz signals only: a daily session started by tapping the daily reminder (pedagogy Phase 22) |
| `tab` | Yes | A search begun in the Verbs tab (Phase 11); for the quiz signals, a quiz over every verb from the Quiz tab (Phase 13) |
| `verbPage` | Yes | The quiz signals only: "Test me on this verb" (Phase 13) |

A phase that adds a way to reach a verb page passes its value in `VerbDestination`, the value the
`Verbs` and `Families` navigation stacks push, or in the deeplink's `source` query item. It also
adds the privacy-policy lines to [`privacy-policy-pending.md`](privacy-policy-pending.md).

