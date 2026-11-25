# Plan: Fix What the Browse and Verb Review Found

**For:** a series of fresh Claude Code sessions, one phase per session as a rule. **Kind of work:**
app code, two scripts, one build-time tool, tests, and prose. **Written:** 2026-11-25, from
[`docs/verb_browse_review.md`](../docs/verb_browse_review.md) and Josh's answers to eight questions
the same day.

The review is the specification. Each phase below names findings by the review's own labels (C1,
P1, D5, and so on). Read the finding there before touching code: it gives the file, the line, the
evidence, and a suggested fix. This plan adds only the order, the grouping, Josh's decisions, and
what counts as done. Line numbers in the review are those of `0b157b6` and will drift as phases
land, so find code by name.

## Status

Each session that finishes a phase fills in its row, then writes a **How it differed** note under
that phase's heading. A finished phase that waits for Josh is "Awaiting Josh", with the Commit cell
empty until it is committed.

| Phase | Status | Date | Commit | Findings | Waits for Josh |
|---:|---|---|---|---|---|
| 1 | Done | 2026-11-25 | `d6640eb` | C1 | No |
| 2 | Done | 2026-11-25 | `c731457` | P1, two analytics nits | No |
| 3 | Done | 2026-11-25 | `eb8d40b` | C2, C4, C7 (recents), G1, G4, S9 (`limit`) | No; he answered its question |
| 4 | Done | 2026-11-25 | `905c500` | F1, F2 (the repeated search), S1 (the search model), S2, S8 | Yes |
| 5 | Awaiting Josh | 2026-11-25 | | S1 (the rest) | Yes |
| 6 | Not started | | | C5, C6, C7 (ablaut row), D5, F2 (related verbs), S3 (`FlowLayout`) | Yes |
| 7 | Not started | | | C3, D4, E2, E3, G5, G6 | Yes |
| 8 | Not started | | | D1, D2, D3, E1, S3 (the rest), S4 | No |
| 9 | Not started | | | C7 (links, intents, Spotlight, the key), D6, F2 (Look Up), G3, S9 (the unused prefix) | No |
| 10 | Not started | | | G2, G7 (the map's comments), S9 (the tool and the script), S10 | No |
| 11 | Not started | | | S6, D7, the sein collection's quiz | No |
| 12 | Not started | | | T1, T2, T3, T4 | No |
| Closing | Not started | | | S5, S7, the audit | No |

## How to Work This Plan

**Choosing a phase.** Take the lowest-numbered phase that is not done and whose dependencies are.
Phase 5 depends on Phase 4. Phase 8 depends on Phases 1 and 4, because all three edit the search
model's files. Every other phase stands alone and may be taken in any order. If a phase proves too
large for one session, split it, say so in its row, and leave the remainder "Partly done".

**What this plan leaves to you.** The phases say what to fix and what Josh decided. The review
suggests a fix for each finding, and a better one is welcome. Record in **How it differed** anything
that departs from the phase as written.

**A finding labelled Suspected or Reviewer in the review is not yet a fact.** Confirm it in the
code, or by running something, before fixing it. If it turns out not to be real, say so in **How
it differed** and under the finding in the review, and move on.

**Ask Josh when a decision here does not settle a question.** Phases 3 and 7 each name one.

**Every phase finishes the same way.**

1. Each fix gets a test that fails without it, following
   [`KonjugierenTests/CLAUDE.md`](../KonjugierenTests/CLAUDE.md). The review's Tests section names
   the missing ones; a test belongs to the phase that fixes its finding, and Phase 12 takes what is
   left.
2. Build and run the suite with the `ios-build-verify` skill, as `CLAUDE.md` describes. Read the
   run's test count, not only its exit status. The baseline at `0b157b6` is 957 tests in 100
   suites.
3. Run `swiftlint` from the repo root. The tree stays at zero violations.
4. Localize any new string in English and German, following `CLAUDE.md`'s rules for
   `Localizable.xcstrings`.
5. Update [`docs/project_structure.md`](../docs/project_structure.md) for new, renamed, or
   repurposed files, and run `python3 scripts/check_docs.py`.
6. Under each finding fixed, in `docs/verb_browse_review.md`, add a line saying it was fixed on
   `main`, with the date and this plan's phase. Correct any other doc the fix makes untrue;
   [`docs/feature_architecture.md`](../docs/feature_architecture.md) and
   [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) are the likely ones.
7. Fill in the Status row, write **How it differed**, and append a journal entry to
   `docs/blog_notes.md`.
8. **Git.** Josh's rule for this plan (2026-11-25): a phase whose row says "Yes" under "Waits for
   Josh" changes what he can see or tap, so it stops before `git add`. Tell him what changed and
   how to try it: which screens, what to type or tap, on which device. Commit and push to `main`
   once he says he has tried it. A phase whose row says "No" commits and pushes to `main` once
   steps 2, 3, and 5 pass, and then tells him what he could try. Either way, record the hash in the
   Status row with a one-line follow-up commit, since a commit cannot contain its own hash.

**No release before 2027.** Everything accumulates on `main`.

**Konjugieren only.** Do not port a fix to Conjuguer or Conjugar. The Closing lists what would
carry over.

## Decisions Already Made

Josh's answers on 2026-11-25.

- **P1.** For a collection opened from a quiz correction, `viewCollection` carries no `collection`
  parameter. The staged privacy text stays as written.
- **C1.** A literal conjugation ranks above a folded infinitive: fuhren gives fahren, then
  führen. The stranded parts and Look Up a Verb are fixed as the review describes.
- **C3.** The red-letter tip appears only where the verb itself is irregular. The test reads the
  simple tables through `MixedCaseSegmenter`, so the polite Imperativ's Sie does not count.
- **C4.** Collection progress is separate from My Verbs. A verb counts once it has ever been
  opened. Clear and the swipe forget only the recent history. Clear gets no confirmation.
- **G4.** The migration from `LearnerVerbs`' per-verb schedule is deleted now.
- **S1.** `VerbBrowseView` is split in full: a search model, and then `MyVerbsList`,
  `FailedSearchHelp`, and a host for the review card.
- **A lookup from the widget still sends a verb back to the first box.** That rule is the quiz
  track's, decided 2026-11-13. This plan changes nothing there.
- **Git** as step 8 above says.

Defaults this plan chose without asking, because the review left one reasonable course. Josh may
overrule any of them:

- **G2.** Fix the script's rule, regenerate the tables, and reword the doc.
- **S8.** Disable the sort picker while a search has text.
- **The search-scope flip** stays as it is.

## Phase 1: A Literal Match Outranks a Folded One

**Findings:** C1. **Depends on:** nothing.

- In `VerbSearch.MatchKind`, move `conjugation` (and `finitePart` with it) above
  `exactFoldedInfinitive`. Rewrite the ordering comment above the enum to give the new reason.
- `queryIsInfinitive` is true only for `.exactInfinitive`.
- In `VerbLookup`, the literal tier is the exact infinitive and the literal conjugation. The two
  folded kinds answer together, and only when the literal tier is empty. Correct the "30 more"
  comment there (the map has 63).
- `SearchMatchKind` in `Analytics.swift` names kinds and does not depend on their order, so the
  signals need no change. Confirm that.

**Done when** tests pin: fuhren gives fahren first, then führen, and has a folded row of
separable verbs; zahlen is still followed directly by zählen; konnen still finds können first;
Look Up a Verb gives drucken, drücken, fallen, and fällen each a page as its destination.
`VerbSearchTests` and `ConjugationSearchTests` pass, with any expectation that changes explained.

**How it differed:** Little. No existing expectation changed; four tests were added, each run
first against the old code to see it fail, and the suite went from 957 to 961.

- **The folded row sits between fahren and führen.** Because `finitePart` moved up with
  `conjugation`, as the phase says, fuhren's rows are fahren, "Also in 32 separable verbs", then
  führen. The two verbs are in Josh's order, and the stranded parts are literal spellings too, so
  they rank as literal. If Josh wants führen directly under fahren, `finitePart` moves below
  `exactFoldedInfinitive` and `literalConjugationLeadsAndItsFoldedRowPrecedesTheFoldedInfinitive`
  changes with it.
- **"30 more" became "dozens more", not 63.** The map does give ging 63 separable verbs, but the
  corpus is still growing, and a count in a comment would go stale.
- **Analytics.** `VerbSearch.MatchKind.analyticsValue` is a switch from name to name, so the order
  is irrelevant to the signals; its cases were reordered to follow the enum.
- **konnen in `infinitiveQueryHasNoStrandedParts` still passes, for another reason.** konnen is no
  longer an infinitive to that rule, but a folded spelling never strands a part
  (`conjugationMatches` refuses one), so it still has none. The test was left as it is.
- `README.md`'s three test counts went to 961, which `check_docs.py` asked for.

## Phase 2: A Correction's Link Names No Verb

**Findings:** P1, and from S9 and G7 the two nits in `Analytics.swift`. **Depends on:** nothing.

- `VerbCollection.signalView(source:)` omits `collection` when the source is `quizCorrection`. A
  test with `AnalyticsSpy` pins both cases.
- `docs/feature_architecture.md` § Analytics says so beside `viewCollection`. Read the staged
  Collections lines in `docs/privacy_policy_pending.md` and confirm that they are now true; Josh
  decided that their wording stays.
- Restore the alphabetical order of the signal names, and correct the comment that says "once the
  quiz track sends it".

**How it differed:** Hardly. Two tests were added, one for each source, and the correction's test
was run first against the old code, where it failed with `"collection": "ablaut-gehen"` in the
parameters. The suite went from 961 to 963.

- **The staged privacy text is now true and was left as written.** "A correction's links" says the
  source names "never which verb or answer", which the pairing had made false. A dated note under
  that paragraph records the fix, without changing a line that would be published. The collection
  bullet's "which collection" still describes every other source.
- **The guard has a comment.** `signalView(source:)` says why a correction's view omits the key,
  since an `if` on one source looks arbitrary from the call site.
- **The source comment now names collections too**, since `viewCollection` shares the vocabulary,
  and points to `docs/feature_architecture.md` for which values each signal sends.
- **G7's "30 more" bullet got its fixed line**, crediting Phase 1, which had fixed the comment
  but not marked the bullet.
- `README.md`'s three test counts went to 963.

## Phase 3: The Learner's Record and the Widget's Draw

**Findings:** C2, C4, C7 (recents), G1, G4, and S9's unused `limit`. **Depends on:** nothing.

- **C2.** `VerbDraw.verbOfTheDay` takes My Verbs in turn over a stable order, such as the list
  sorted by infinitive. Test with a list that gains a verb between My Verbs days: no verb repeats
  while another waits. Confirm that the widget's stable-through-the-day rule still holds
  (`WidgetSnapshotTests`).
- **C4.** `hasOpened` reads `firstOpened`. `clearRecents` and the swipe's `remove` forget
  `lastOpened` (and the star, for the swipe) and keep `firstOpened`. An entry with only
  `firstOpened` appears in neither Starred nor Recent. An entry written before this phase still
  decodes, and one with `lastOpened` but no `firstOpened` counts as opened. Tests pin each.
- **Ask Josh.** After this change, Clear no longer empties the device's record of which verbs
  were ever opened, and Phase 12 of the Browse plan added Clear so that there would be a way to
  empty it. Ask him where a full forget should live. Candidates: the practice record's existing
  reset in Settings also forgets `firstOpened`; or nothing, since the record never leaves the
  device. The staged privacy paragraph about the list kept on the device may need a clause.
- **C7.** Recent shows up to 20 unstarred verbs, by filtering before taking the limit. Remove the
  `limit` parameter that nothing passes.
- **G4.** Delete `PracticeStore.migrated`, `LegacyLearnerVerbs`, the migration tests in
  `PracticeRecordTests`, and the paragraphs that describe them in `docs/feature_architecture.md`
  and `docs/project_structure.md`.
- **G1.** Correct the comments in `Shared/LearnerVerbs.swift` and `Shared/PracticeRecord.swift`
  and the doc's § The Review Card: the widget reads the snapshot bundle, not the record. Keep the
  rule that added fields must be optional, with its true reason, an app upgrade.

**How it differed:** In C2's mechanism and in one rule of C4's, both for reasons the code gave.
The suite went from 963 to 972.

- **Josh's answer (2026-11-25): Reset Practice forgets first opens.** Settings' reset now calls
  `LearnerVerbStore.forgetFirstOpens()`, which forgets every `firstOpened` and `openCount`, so
  collection progress returns to nothing; stars and Recent stay. The reset's description and
  confirmation say so in both languages, and `docs/privacy_policy_pending.md` stages a sentence
  for the list paragraph in a new dated section.
- **C2 is fixed with state, not a sorted list.** The plan's own test fails against a sorted list
  indexed by turn: once the list's length changes, `turn % count` lands anywhere, and 3 verbs
  becoming 4 can map consecutive turns to the same index. No function of the day and today's list
  can know what earlier days showed. A My Verbs day now takes the verb whose last My Verbs day is
  longest ago (never given one first, the infinitive breaking ties), and
  `WidgetSnapshotBundle.myVerbsLastShown`, optional so old bundles decode, carries those days from
  one write to the next. A rewrite keeps the days before today and plans the rest again. The
  widget's stable-through-the-day rule holds: `WidgetSnapshotTests` pass, and a new test pins
  that a same-day rewrite produces an identical bundle. This sits well with Phase 12's T3, which
  wants the writer as a function from the old bundle to the new.
- **An entry with a last open but no first open does not count as opened.** The plan asked for
  the opposite, as a guard for old records, but Josh's answer makes that shape meaningful: it is
  what Reset Practice leaves for a recent verb, and counting it would undo the reset. No old
  entry has that shape: both dates were added in `37bb963`, and every write set both, so
  `hasOpened` reads `firstOpened` alone. The test of an earlier build's record decodes a full
  entry, with the per-verb `review` field Phase 15 of the Browse plan wrote, and counts it opened.
- **Clear and the swipe keep `openCount`** along with `firstOpened`, since both describe the
  verb's whole history; Reset Practice zeroes it. Nothing reads it yet.
- **`recent` became a property** once its `limit` went, and `recentUnstarred` joined it, so the
  filtering lives in `LearnerVerbs`, where `myVerbs` uses it too, rather than in the store.
- **G4 took two more things with it:** `PracticeRecord.adopt`, which only the migration called,
  and `PracticeStore.init`'s `now` parameter, which nothing used or passed. The reset test that
  checked "does not migrate again" now checks only that a reset survives a reload.
- **Tests.** Each test of changed behaviour was run against the old logic, put back temporarily:
  the nine in `LearnerVerbsTests` and `VerbDrawTests` all failed, the growth test with abbehalten
  repeating while three newer verbs waited. The three new writer tests pin the carried state,
  which the old code did not have. `myVerbsDaysTakeMyVerbsInTurn` now threads the last-shown days,
  as the writer does.

## Phase 4: The Guess Leaves the Main Thread, in a Search Model

**Findings:** F1, F2 (the repeated search), S1 (the search model), S2, S8. **Depends on:** nothing.
**Waits for Josh.**

- Extract an `@Observable` search model from `VerbBrowseView`. It owns the text, the results and
  their cache, the `SearchTracker`, the keyboard selection, whether the folded row is open, and
  the guess. The view keeps focus and navigation.
- A search that matches nothing shows "No verbs found" at once. The guess is computed off the main
  actor and appears when ready. A change to the text cancels a guess still in flight. The sad
  trombone still plays once per failed search, not once per guess.
- `signalEndedSearch` reads the model's results instead of searching again.
- Replace `searchFocusLostAt` with state that says what it means and resets when it should.
- The sort picker is disabled while the field has text.
- The model's flow gets tests: typing, clearing, a guess that arrives, a guess cancelled by the
  next letter, opening a result, opening the guess, and the reports each sends.

**Measure before and after**, with a temporary timing test in the manner of the review's Method
section: ginng and xyzzyq, the time until `body` can return. Record both numbers.

**Tell Josh to try:** on the iPhone, xyzzyq and ginng typed quickly, gehn, then a cleared field;
on the iPad with a hardware keyboard, Command-F, the arrow keys, Return on a result, Return on
the folded row, and Return on the guess.

**How it differed:** Mostly in how the guess leaves the main actor, which the project's
concurrency settings decided. The suite went from 972 to 994 tests, in 101 suites.

- **Measured**, three runs each, debug build, Konjugieren iPhone 17 simulator on the Intel Mac:

  | Query | Before, main thread | After, main thread | After, guess ready |
  |---|---:|---:|---:|
  | ginng | 0.18–0.23 s | 0.02–0.04 s | 0.11 s |
  | xyzzyq | 0.67–0.76 s | 0.02–0.03 s | 0.37–0.40 s |

- **The guess runs in a `@concurrent` function, not a detached task.** With
  `SWIFT_APPROACHABLE_CONCURRENCY`, a plain `nonisolated async` function runs on its caller's
  actor. A structured call also carries the task's cancellation into the work, where a detached
  task would have run on after the next letter. `VerbSearch.guess(for:among:index:)` works on
  `Sendable` `GuessCandidate`s, since `Verb`'s conformances are main-actor-isolated, and checks
  `Task.isCancelled` as it walks the conjugations. The old `guess(for:in:index:)` wraps it for
  `VerbLookup`, which still takes the guess in line.
- **`editDistance` gained a limit**, the review's second suggestion. It halved the in-line guess
  that Look Up a Verb uses (0.10 and 0.39 s). A test pins that a limited distance is exact up to
  the limit and one past it beyond.
- **`VerbSearchResults` takes `includesGuess`**, and the model asks for none. It also gained
  `topKind`, so `SearchReport.ended` reads `results:` rather than `matches:`. A test checks that
  the two agree, including a query whose top row is the folded row.
- **The sad trombone moved into the model.** It plays as a search begins to fail, and no longer
  again when the learner returns from a verb page to the same failed search, which the empty
  state's `onAppear` did.
- **S2 needed no new state.** `searchIsLingering` is `searchIsEngaged && !searchIsFocused`, which
  is true from the loss of focus until the lingering views let go, and resets by itself.
- **The model's text is observed with `didSet`**, so typing, the letter row, and a request all
  take one path, and the view's `onChange(of: searchText)` went. The search scope reaches the
  model by an `onChange` of the setting.
- **Checked in the simulator:** a `search` deeplink for ginng showed "No verbs found", then the
  guess, with the sort picker disabled. The keyboard flows were left for Josh, as the phase says.
- `README.md`'s three test counts went to 994, and its file count to sixty-five.

## Phase 5: Split the Verb List's View

**Findings:** S1 (the rest). **Depends on:** Phase 4. **Waits for Josh.**

Move out of `VerbBrowseView`, each into its own file: `MyVerbsList` with its alert,
`FailedSearchHelp` with the mail link and its copied-address note, and a host for the review
card's choice, reveal, snooze, and signal. No behavior changes. `VerbBrowseView` should end as the
navigation stack, the list or grid, the picker or letter row, and the deeplink requests.

**Tell Josh to try:** My Verbs (swipe a recent verb, swipe a starred one and cancel, Clear), a
failed search's mail link in the simulator, and the review card (reveal, open, dismiss, Suppress
Review Card on and off), on both devices.

**How it differed:** In the review card's host, which became a model and a view, because a view
alone would have changed behaviour. The suite went from 994 to 1002 tests, in 102 suites.

- **The host is `ReviewCardHost`, an `@Observable` class, beside `ReviewCardHostView`.** The card's
  place in the list sits inside the `ScrollView`, which is absent while My Verbs shows, and inside
  a condition that drops it while a search or the recents show. A view holding the card's state
  would have lost it each time, and choosing again on its next appearance would have swapped a
  revealed card for the next offer and brought back a dismissed one. So `VerbBrowseView` owns the
  host for its lifetime, as it owns `VerbSearchModel`, and forwards the three events the host
  cannot see: the list's appearance, the scene phase, and the suppression setting. The host also
  took `appWasInBackground` and `reviewCardMaxWidth` (now the host view's).
- **The host has tests, which no finding asked for.** Eight, in `ReviewCardHostTests`: one choice
  per opening, a new one only after the background (not after a mere `inactive`), one review and
  one signal per reveal, one signal per showing, a dismissal snoozing until tomorrow, the
  destination's source, and suppression hiding a card without forgetting it. A refactor has no
  test that fails without it, so these were not run against the old code; they pin what the move
  had to keep. `Current.reportAchievements()` is injected as a closure, since it writes to the
  shared Game Center spy that other suites read.
- **`FailedSearchHelp` also holds "No verbs found"**, since the two always appear together. Its
  body returns both without a container, so the `ScrollView`'s implicit stack lays them out as
  before.
- **One small difference: the copied-address note now belongs to `FailedSearchHelp`.** Before, it
  lived in `VerbBrowseView`, so a learner who copied the address, typed a letter that found a
  verb, and deleted it again within four seconds saw the note still showing. Now the note goes
  with the failed search. The four-second task still runs to its end, harmlessly.
- **`VerbRowView`, `VerbGridCell`, and `SeparableVerbsRow` stay in `VerbBrowseView.swift`.** They
  are rows of the list, not seams the review named, and S3's moves are Phase 8's.
- **Checked in the simulator:** a `search` deeplink for xyzzyq showed "No verbs found" and the mail
  link, with the sort picker disabled. The rest was left for Josh, as the phase says.
- `README.md`'s three test counts went to 1002, and its file count to sixty-six.

## Phase 6: Order, Spelling, and the Lists' Shared Pieces

**Findings:** C5, C6, C7 (the ablaut row), D5, F2 (related verbs), S3 (`FlowLayout`), E4.
**Depends on:** nothing. **Waits for Josh.**

- **C5.** One German comparator on `Verb`. `[Verb].sorted(by: .alphabetical)` sorts with it.
  Delete the copy in `RelatedVerbListView` and the two `<` sorts in `BrowseableFamily`. If sorting
  a family's thousand verbs on every body evaluation costs anything measurable, memoize. A test
  pins abändern before abziehen.
- **C6.** `.inUserRegion` in the four Related Verbs captions and in `VerbCollection.title`. A test
  pins the Swiss title of the schließen group.
- **C7.** A verb joins an ablaut row if any of its readings is in the group. Pin bewegen.
- **F2.** A cached index of verbs by ablaut group, beside `verbsByRoot`.
- **D5.** One `SortOrderPicker`. One source for a collection's "N of M" count, text, and
  accessibility label. `VerbCollectionBar` asks its collection for its verbs, and the second
  ablaut-group predicate goes if the first can serve both.
- **S3.** `FlowLayout` moves to its own file and proposes the row's width to each child, so a
  chip wider than a row wraps.

**Tell Josh to try:** the Separable page's ab- section in alphabetical order; with the region set
to Switzerland, aufschließen's Related Verbs card and the schließen group's quiz title; "All N"
from a card in both orders; and the chips on the Quiz start screen, which share `FlowLayout`.

**How it differed:**

## Phase 7: The Verb Page

**Findings:** C3, D4, E2, E3, G5, G6. **Depends on:** nothing. **Waits for Josh.**

- **C3.** The tip's guard asks `MixedCaseSegmenter` whether any simple-table cell has an irregular
  segment. Put the question on a model type so that a test can ask it: false for machen, true for
  singen and sein. Correct `RedLettersTip`'s doc comment.
- **D4.** One function for a stem's key conjugation, used by `keyConjugations` and by
  `Mastery.KeyConjugation`, with one answer for a cell the Conjugator cannot fill.
- **E2, E3.** Reduce `rows(for:)` to the Imperativ and everything else. Give `ConjugationTable` an
  optional `VerbPageSection`, and reformat the `openArticle` closure.
- **G6.** A `VerbPageSection` for the Related Verbs card. Check that the staged privacy line about
  `deepestSection` still covers it.
- **G5. Ask Josh.** A visit's dwell counts time spent under the article sheet and the Test Me
  quiz. The recommendation: end the visit when either sheet presents and begin a `resume` visit
  when it closes, which matches "one stretch of the page on screen" in
  `docs/feature_architecture.md`. It raises the count of `resume` views, so he should agree first.
  Whatever he chooses, move the begin-and-end pairing somewhere a test can drive it.

**Tell Josh to try,** on a fresh install so that TipKit has no history: machen's page (no tip),
then singen's (the tip), then close it and open another verb (the scroll tip).

**How it differed:**

## Phase 8: One Home for Each Piece of the Search Model

**Findings:** D1, D2, D3, E1, S3 (the rest), S4. **Depends on:** Phases 1 and 4.

- **D1.** One helper for "the cells of this verb that this text fills", serving
  `MatchedConjugation.init(whole:of:)`, `marks(on:)`, and `MarkedConjugations.init?(text:on:)`.
- **D2.** `Reading.zuInfinitive` moves to `Reading.swift`, and `ConjugationMap`'s builder calls
  it.
- **D3.** One list of the conjugationgroups that leave a finite word, in `Conjugationgroup.swift`,
  from which the map's builder, `leavesFinitePart`, and `CellsJSON` derive theirs.
- **E1.** `VerbSearchResults` stores one kind of row. Phase 4's model and `VerbLookup` read it.
- **S3.** Move the stray declarations to files named for them: the `Conjugationgroup` and
  `MarkedConjugations` extensions out of `VerbSearchResults.swift`, `VerbDestination` and
  `MarkedConjugations` out of `VerbVisit.swift`, `VerbListMode` out of `SortOrder.swift`.
- **S4.** The lowercased and folded infinitive and the lowercased glosses are stored on `Verb`
  when it is parsed, and `keysCache` goes. `Verb.swift` compiles into `ConjugationMapTool`, so
  `fold` may have to move with them. Build the tool.

**Done when** `ConjugationMapTests.matchesAFreshBuild` passes and `scripts/write_forms_json.sh`
leaves `corpus/working/forms.json` byte-identical (`git diff --stat` shows nothing). D2, D3, and S4
all touch files the tool compiles, and an identical map is the proof that nothing moved.

**How it differed:**

## Phase 9: Links, Intents, and Spotlight

**Findings:** C7 (the bad link, the two bypasses, Spotlight, the key), D6, F2 (Look Up), G3, S9
(the unused prefix). **Depends on:** nothing.

- `handleURL` clears pending targets only once a route has resolved. A test: a pending search
  survives `konjugieren://verb/nonexistent`.
- `OpenVerbIntent` and `handleUserActivity` go through `handleURL` with `URL.verbDeeplink`.
- `VerbSpotlight` sets its flag only when the delete succeeded. Decide, and record, whether
  removing entries for verbs that left the corpus and skipping an unchanged reindex are worth
  building now; the corpus is still growing, which argues for the first. If Spotlight's calls move
  behind a `Current` dependency, the order of delete and index gets the test it lacks.
- `VerbCollection.init?(key:)` stores the matched group's own exemplar.
- A `WidgetDeeplink` enum in `Shared/` builds the widget's links, and the five widget views and
  `DeeplinkTests` use it. A `PendingDeeplinkIntent` protocol gives the intents in `Shared/` one
  `perform()`, and `OpenQuizIntent` a constant. Strings used by `Shared/` intents live in both
  catalogs; see [`KonjugierenWidget/CLAUDE.md`](../KonjugierenWidget/CLAUDE.md).
- `LookUpVerbIntent` warms `ConjugationIndex.bundled` off the main actor before it uses it.
  Measure first: if the index loads in a few milliseconds, record that and skip the change.
- Delete `URL.konjugierenURLPrefix`.
- Correct `docs/feature_architecture.md` where it says what `DeeplinkTests` pins.

**Tell Josh he could try:** a widget's tap, the Random Verb control, Look Up a Verb for ging and
for drucken, and a verb found in Spotlight.

**How it differed:**

## Phase 10: The Map Tool and the Scripts

**Findings:** G2, G7 (the map's comments), S9 (the tool and the script), S10. **Depends on:**
nothing.

- **G2.** In `scripts/count_conjugationgroups.py`, the auxiliary path asks what the simple path
  asks before it calls "habe" or "werde" Konjunktiv I. Read `--examples perfektKonjunktivI` before
  and after, as the script's author did for its three earlier fixes. Regenerate the tables in
  [`docs/conjugationgroup_frequency.md`](../docs/conjugationgroup_frequency.md), reword the
  sentence about indirect speech to fit the new numbers, and extend Known Errors. **If the order
  of the verb page's sections would change, stop and tell Josh** before touching
  `ConjugationTable`; the review's estimate is that it will not. Make the doc and the script agree
  about "sie" as a third-person neighbour.
- The script checks the shape of the cells file it is given and fails with a message, not a
  division by zero.
- `ConjugationMapTool` rejects an unknown flag. `ConjugationMap(compressed:)` throws on invalid
  UTF-8. The map is written atomically, now that the app target's script sandbox is off; confirm
  by file timestamps that an unchanged rebuild still skips the phase, as `CLAUDE.md` § "Reading an
  Xcode build log" describes.
- The build directory in `scripts/write_forms_json.sh` and `scripts/count_conjugationgroups.py`
  is named for Konjugieren.
- Correct the "about 160 KB" comment.

**How it differed:**

## Phase 11: The Quiz's Scope

**Findings:** S6, D7, and the sein collection's quiz from "Costs of Settled Decisions". **Depends
on:** nothing.

This phase touches code the pedagogy plan wrote. Read
[`plans/pedagogy_implementation.md`](pedagogy_implementation.md) for the modes before changing how
they are told apart.

- **S6.** `QuizScope` gains a `kind`, and only the default kind is ranked, mixes due items, and
  mixes choice questions. `showsVerbLink` reads the scope, not the analytics source. A test builds
  every scope the app can start and pins which is ranked.
- **D7.** `StandardVariants` splits a separable verb with the Conjugator's own helper, before
  regional spelling is applied.
- **The sein collection.** Trace which reading its quiz asks. If a question on fahren can expect
  "hat gefahren", restrict that scope to readings that take sein in the learner's region, and pin
  it.

**How it differed:**

## Phase 12: Tests That Prove What They Claim

**Findings:** T1, T2, T3, T4, less whatever earlier phases already added. **Depends on:** nothing,
though it is shortest when taken last.

- **T1.** Repair or delete the three tests that cannot fail.
- **T2.** `VerbLookupTests` asserts the conjugationgroups it expects by name. `InfoView`'s link
  cleaning moves to a nonisolated function that the view and `InfoTests` both call.
- **T3.** Extract from `WidgetSnapshotWriter.writeSnapshot` a function that takes the old bundle
  and returns the new one, and test a missing bundle, a corrupt one, one from another day, and one
  older than ten days. Pin `ReviewSchedule` on a daylight-saving day in Europe/Berlin.
- **T4.** Where an exact assertion against the corpus is meant as a tripwire, say so in a comment.
  Where it is not, assert what the test is about.

**How it differed:**

## Closing

- Run the full suite, `swiftlint`, and `check_docs.py`.
- **S5.** On the iPad simulator, open two windows of the app, focus the search in each in turn,
  and try the arrow keys. Record what happens. Fix it only if it is broken and the fix is small;
  otherwise write it down beside the other limits of a global `Current`.
- **S7.** List the timed workarounds in one place, in `docs/feature_architecture.md` or a short
  doc of their own: what each waits for, how long, and how to tell whether a new iOS has made it
  unnecessary. Cancel a superseded task where that is one line.
- Confirm that every finding in `docs/verb_browse_review.md` carries a line: fixed, with date and
  phase; found not to be real; or left, with the reason. The three costs of settled decisions get
  the last kind.
- Write a short list of which fixes would carry over to Conjuguer and Conjugar, for whichever of
  the Browse plan's phases have been ported there. Do not read the siblings' code for it beyond
  what is needed to say whether a phase was ported.
- Mark this plan finished in its Status section.

**How it differed:**
