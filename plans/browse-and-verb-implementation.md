# Plan: Build the Accepted Browse and Verb Ideas

**For:** a series of fresh Claude Code sessions, one phase per session as a rule. **Kind of work:**
app code, one build-time tool, localized strings, one Info article, and tests. **Written:**
2026-11-12, from Josh's verdicts in
[`docs/browse-and-verb-ideas.md`](../docs/browse-and-verb-ideas.md) and his answers to four
questions the same day.

## Status

Each session that finishes a phase fills in its row here, then writes a **How it differed** note
under that phase's heading. Leave rows for phases not yet started as they are. A finished phase
that Josh has not yet tried is "Awaiting Josh", with the Commit cell empty until it is committed.

| Phase | Status | Date | Commit | Ideas |
|---:|---|---|---|---|
| 1 | Done | 2026-11-12 | `bcab0c3` | A1, A2, A3, A8 |
| 2 | Done | 2026-11-12 | `40acbdf` | A4, C4 |
| 3 | Done | 2026-11-12 | `1fcef34` | Signals |
| 4 | Done | 2026-11-12 | `d5ff847` | B2 |
| 5 | Done | 2026-11-12 | `6c911fb` | A5 (the map) |
| 6 | Not started | | | A5 (the search) |
| 7 | Not started | | | B3, B5's tip |
| 8 | Not started | | | B7's article |
| 9 | Not started | | | B4, A9 |
| 10 | Not started | | | B6 |
| 11 | Not started | | | C1, C2 |
| 12 | Not started | | | D1, D2 |
| 13 | Not started | | | D2's quiz scope, D3 |
| 14 | Not started | | | D5 |
| 15 | Not started | | | D4 |
| 16 | Not started | | | D6 |
| Closing | Not started | | | |

## How to Work This Plan

**Choosing a phase.** Take the lowest-numbered phase that is not done and whose dependencies are.
The numbering is a suggested order, not a requirement: phases 7 to 10 depend on nothing after
phase 3 and may be taken in any order. If a phase proves too large for one session, split it, say
so in its row, and leave the remainder marked "Partly done".

**What this plan leaves to you.** The phases say what to build and what Josh decided. They do not
say how. Read the code, choose the implementation, and record in **How it differed** anything that
departs from the phase as written: a scope change, a decision Josh made during the session, a
dependency that turned out wrong, or a piece deferred to a later phase. A later session relies on
that note more than on the phase text above it.

**Ask Josh when a verdict does not settle a question.** Several phases name such questions. Do
not guess at them.

**Every phase finishes the same way.**

1. Build and run the tests with the `ios-build-verify` skill, as `CLAUDE.md` describes. New logic
   gets tests that follow [`KonjugierenTests/CLAUDE.md`](../KonjugierenTests/CLAUDE.md). Read the
   run's test count, not only its exit status.
2. For any visible change, launch the app and look at it. This Intel host cannot render Tutor
   surfaces, which no phase here touches.
3. Localize every new string in English and German, following `CLAUDE.md`'s rules for
   `Localizable.xcstrings`.
4. Follow [`docs/voiceover.md`](../docs/voiceover.md) for anything tappable on the verb page or
   the verb list.
5. Add or extend analytics as Phase 3's convention says, once Phase 3 is done.
6. Update [`docs/project-structure.md`](../docs/project-structure.md) for new, renamed, or
   repurposed files, and run `python3 scripts/check_docs.py`.
7. Under the idea in `docs/browse-and-verb-ideas.md`, add a line saying it was built on `main`,
   with the date and this plan's phase, as the defect plan did for the ideas it touched.
8. Fill in the Status row, write **How it differed**, and append a journal entry to
   `docs/blog_notes.md`.
9. **Stop before git.** Do not run `git add`, `git commit`, or `git push` until Josh has tried the
   changes. Tell him what changed and how to try it: which screens to open, and what to type or
   tap. Once he says he has tried them, commit and push to `main`. Then, since a commit cannot
   contain its own hash, record the hash in the Status row with a one-line follow-up commit, and
   push that too. Josh made this rule on 2026-11-12, after Phase 1, and it holds for every phase
   and the Closing.

**No release before 2027.** Every phase accumulates on `main`. Nothing here reaches a learner or
produces a number until a release ships, so no phase should wait on evidence from another.

**Konjugieren only.** Each idea in the ideas document notes how it carries over to Conjuguer and
Conjugar. Porting is outside this plan; the Closing gathers the list.

## Decisions Already Made

From Josh's verdicts, and from his answers on 2026-11-12. These settle several of the ideas
document's "Decisions for Josh".

- **Rejected:** A6 (sentence mode), A7 (verbs outside the corpus), B1 (principal parts at the top),
  B5 (teasers near the top), B7 (Futur II and passive sections on the page), C3 (German shortcut
  phrases), and every entry in "Smaller and Later Ideas".
- **Search scope.** Keep the setting and flip its default so that glosses are searched. German
  matches rank above English ones: searching "es" shows essen above rest.
- **The trombone stays** on a failed search, because it is funny.
- **The map** is generated at build time by a host tool that shares the Conjugator's sources. It
  regenerates only when an input is newer than the output.
- **Separable verbs.** The verb page shows only the split conjugation (ich stehe auf), and the
  quiz accepts the split and the joined conjugation alike. This also settles decision 1 of
  [`plans/pedagogy.md`](pedagogy.md).
- **Section order.** Keep the simple conjugationgroups ahead of the compound ones and keep every
  section visible. Within each block, order by frequency of use.
- **Signals.** All three proposed signals are built, with the policy lines staged for the
  release.
- **Quiz pieces.** This plan builds minimal versions of what its ideas need from the quiz: a quiz
  over a given list of verbs, and a due date per verb. Build them so the quiz track can extend
  them rather than replace them.
- **No web domain for universal links** (the ideas document's decision 12; confirmed
  2026-11-12). Shared text carries the App Store link and, where useful, a `konjugieren://` link.
  This affects Phases 10 and 16.
- **Key conjugations appear with no label** (confirmed 2026-11-12). Josh rejected B1 partly
  because learners do not know the term "principal parts". A function that returns a verb's few
  key conjugations still serves the share text (Phase 10), Spotlight keywords (Phase 11), and the
  review card (Phase 15). Wherever they are shown, they stand alone, as in "aufstehen: steht auf ·
  stand auf · ist aufgestanden", with no heading. Avoid the term in code names too.

## Phase 1: Search Finds What People Type

**Ideas:** A1, A2, A3, A8. **Depends on:** nothing.

- **A1.** Fold ä/ae/a, ö/oe/o, ü/ue/u, and ß/ss when matching, so konnen, koennen, and können
  all find können. The existing ß and ss rule shows the way.
- **A2.** Flip the Search Scope setting's default to include glosses. Search every reading's
  gloss (already true since the defect plan's Part 3b). Rank a whole-word gloss match above a
  match inside a word, and ignore a leading "to". All German matches rank above all English
  matches.
- **A3.** Rank the exact infinitive first, then infinitives that begin with the query, then the
  rest, each by frequency whatever the list's sort order.
- **A8.** Turn off autocapitalization and autocorrection in the search field, say in the
  placeholder what can be typed, and add an ä, ö, ü, ß key row above the keyboard. Build the key
  row as a component the quiz's answer field can adopt later (pedagogy Tier 1).

Notes for the session:

- The shortcut picker already ranks exact, then prefix, then the rest (defect plan, Part 3a).
  Make the list and the picker share one matching and ranking function so the two cannot drift.
- Check whether existing installs have the old Search Scope default stored. If they do, ask Josh
  whether to migrate it.
- Folding the digraphs widens matches (bauen contains ue). The ranking should keep an unfolded
  match ahead of a folded one.

**Done when** every row of the "What Search Returns" table that this phase addresses (konnen,
koennen, go, to go, eat, essen, kommen in alphabetical order) gives the wanted verb first, and
tests pin each case.

**How it differed:**

- **The ranking is not strictly German-first.** "All German matches above all English" failed two
  of this phase's own done-criterion rows: "eat" is a substring of beatmen, and "go" matches gönnen
  after folding. Josh chose, on 2026-11-12, this order: exact infinitive, exact after folding,
  infinitive prefix, **whole-word gloss**, infinitive substring, folded prefix, folded substring,
  gloss substring. Within each kind, frequency decides, whatever the list's sort order. "es" still
  gives essen first and ruhen (rest) far below. The order is `VerbSearch.MatchKind`, whose cases
  are the match kinds Phase 3 needs for `matchKind`.
- **Folding counts ß/ss as a fold**, so a literal match outranks a ß/ss match of the same kind.
  Exact-after-folding ranks second overall, so zahlen is followed directly by zählen. The old
  `String.sharpSNormalized` and `Verb.anyTranslationContains` are gone; `VerbSearch` replaces both.
- **The Search Scope migration.** `Settings.restore` writes the default on first launch, so every
  existing install stored `infinitiveOnly` without choosing it. Josh chose a one-time migration:
  `Settings.flipSearchScopeDefaultOnce` moves a stored value to the new default, sets
  `searchScopeDefaultFlipped`, and never runs again, so a later choice of Infinitive Only sticks.
- **The letter row is not a keyboard toolbar.** `ToolbarItemGroup(placement: .keyboard)` never
  appeared for the navigation bar's search field (iOS 26.3 simulator). The row instead replaces the
  sort picker while the field is focused (`.searchFocused`), which puts it directly above the
  keyboard. Losing the picker then costs nothing, because search ignores the sort order. A
  consequence for later phases: with text in the field and the keyboard dismissed, the picker
  returns and has no visible effect. `GermanLetterKeyRow` takes an `insert` closure rather than a
  binding, so the quiz's answer field can insert at the cursor; search simply appends.
- **The placeholder depends on the scope**: "Infinitive or English meaning", or "German infinitive"
  when glosses are off. Phase 6 should extend it once a conjugation finds its verb.
- **Autocorrection was not checked on a device.** It is switched off in code, and the simulator
  showed lowercase input, but the ideas document's open question about an English keyboard on a
  real device remains.

## Phase 2: When Search Finds Nothing, and Keyboard Lookup

**Ideas:** A4, C4. **Depends on:** Phase 1.

- **A4.** Keep the sad trombone. Below "No verbs found", offer the single closest verb by fuzzy
  matching over the folded infinitives and say plainly that it is a guess. Add a line saying that
  if the learner believes the searched-for verb is real, the learner should email
  vermontcoder@gmail.com, as a `mailto:` link with the query filled in.
- **C4.** On iPad and Mac, Command-F focuses the search field, Return opens the first result, and
  the arrow keys move through results.

Phase 6 changes when the empty state appears, since a conjugation will then find its verb. Note
anything here that Phase 6 must revisit.

**How it differed:**

- **The guess.** `VerbSearch.closestVerb` measures optimal-string-alignment distance (Levenshtein
  plus a swap of two adjacent letters) between the folded query and each folded infinitive, and
  breaks ties by frequency. A guess must be within one edit per three letters, and never more than
  three, so "gehn" finds gehen and "xyzzyq" finds nothing. With no guess, the empty state shows only
  "No verbs found" and the mail line. The guess is an ordinary verb row under "A guess at the verb
  you meant:".
- **The mail line** reads "If you believe that “gehn” is a German verb, please email
  vermontcoder@gmail.com." The address is a link built by `URL.mailto`, which fills the subject and
  body with the query in the learner's language. The address lives once, as `URL.developerEmail`.
  At Josh's request, a device that cannot open the link (the simulator has no Mail app) copies
  the address to the clipboard instead and says so in a note below the line for four seconds.
- **Command-F** is a menu command, `VerbSearchCommands`, so it appears in iPadOS 26's menu bar as
  Verbs › Find a Verb. It switches to the Verbs tab, pops to the list, and focuses the field.
  `CommandGroup` placed relative to `.textEditing` never fired, because the system's own Find item
  claims ⌘F there. A top-level `CommandMenu` works.
- **The iPad search field moved.** iPadOS 26 shrinks `.automatic` search into a toolbar button
  that ignores `.searchFocused` and `.searchable(isPresented:)`, so Command-F could not open it. On
  iPad and Mac the field is now a bar under the title that stays put
  (`.navigationBarDrawer(displayMode: .always)`). iPhone keeps `.automatic` and looks as before.
  **Josh should judge this layout change.**
- **Return** opens the highlighted result, else the first, else the guess. It acts only on the iPad
  idiom (which a Mac running the iPad app also reports), so the iPhone keyboard's Search key behaves
  as before.
- **The arrow keys** needed UIKit. A focused text field consumes ↑ and ↓ as cursor movement, which
  outranks `.onKeyPress`, `.keyboardShortcut`, and a menu command alike, all three of which were
  tried. `VerbSearchArrowKeys` installs two `UIKeyCommand`s with
  `wantsPriorityOverSystemBehavior` on the window's root view controller while the field is
  focused, and removes them when it blurs, so the Quiz and Tutor fields keep their arrows. Down
  moves to the next result in reading order, also in the iPad grid. Left and right stay with the
  cursor.
- **How it was tested.** On the iPad Pro 11-inch (M5) simulator, iOS 26.3, with hardware key
  events sent by AXe (`axe key`, `axe key-combo`). Key presses sent to Simulator.app through
  computer use did not reach the device, so do not use that route. Not tried on a Mac or a real
  iPad.
- **No analytics yet.** Phase 3 should give a page opened from the guess its own `source` value
  (for instance `searchGuess`) and count a Return or arrow-key open as an ordinary search open.
- **For Phase 6 to revisit.** The empty state, and with it the guess, will appear only when the
  conjugation lookup also fails. `closestVerb` considers infinitives only; decide whether a
  misspelled conjugation (ginng) should guess too. `keyboardTargets` in `VerbBrowseView` assumes
  one row per verb, which conjugation rows and the folded row of separable verbs will change.

## Phase 3: Lookup Signals

**Ideas:** the three signals in the ideas document's "What to Measure". **Depends on:** Phase 1,
so that the match kinds exist.

- `finishSearch`, sent once per search, with banded `outcome`, `queryLength`, `resultCount`,
  `matchKind`, and `resultPosition`.
- A `source` parameter on the existing `viewVerbView`.
- `leaveVerbView`, sent once per verb view, with `deepestSection` and a banded `dwell`.

Define the full vocabulary of `source` and `matchKind` values in one place now, including values
for surfaces later phases build. Never send a verb or any typed text: the privacy policy promises
that.

**The convention for later phases.** Each phase that adds a way to reach a verb page sets its
`source` value. Phase 6 adds the `conjugation` match kind. Phases 10, 12, and 13 add
`tapShareVerb`, `tapStarVerb`, and `tapTestVerb`. Phase 13 adds `source` to `startQuiz`.

**The privacy policy.** Draft the line each new signal and parameter needs, but do not put it in
`docs/privacy_policy.txt`. Josh may deploy that file at any time, and a new signal's line belongs
in the deployed policy only on the day the release that sends it ships. Stage the lines where the
release work will find them, tell Josh where, and have later phases add to the same place.

**How it differed:**

- **Where things live.** Every name, key, and value is in `Analytics.swift`: `AnalyticsSource`,
  `SearchMatchKind`, `SearchOutcome`, `VerbPageSection`, and the bands in `AnalyticsBand`.
  `docs/feature-architecture.md` § Analytics has the signal table and says which `source` values
  are sent today and which phase sends the rest. `AnalyticsSource` is one enum for `viewVerbView`
  and `startQuiz` alike, including Phase 13's `tab` and `verbPage`, which `startQuiz` does not yet
  send.
- **`matchKind` is fine-grained.** It sends `VerbSearch.MatchKind`'s eight cases by name
  (`exactInfinitive`, `wholeWordGloss`, …) rather than the ideas document's coarse three, plus
  `guess` and `none`. The mapping is an exhaustive switch, so a new match kind cannot go unnamed.
  Phase 6 adds `conjugation`, which is already in the enum.
- **One visit, one leave.** `viewVerbView` already fired again whenever a verb page reappeared
  after a tab switch, so "once per verb view" needed a definition. A visit is one stretch of the
  page on screen with the app in the foreground (`VerbVisit`). It ends, sending `leaveVerbView`,
  when the page leaves the screen or the app goes to the background. A page that comes back
  starts a new visit whose `source` is `resume`. Every `viewVerbView` thus pairs with one
  `leaveVerbView`, background time never counts as reading, and arrivals are the views whose
  source is not `resume`. A resumed visit starts from the deepest section already on screen.
- **Reaching a section** means a third of its block's first card on screen
  (`onScrollVisibilityChange`): Perfektpartizip for `simple`, Perfekt Indikativ for `compound`.
  On an iPhone the Perfektpartizip card shows without scrolling, so `header` alone will be rare.
- **A search** (`SearchTracker`) begins with the first non-blank letter and ends once: opened,
  cleared, or the app backgrounded with text in the field. Going back to the results and opening a
  second verb without editing sends no second `finishSearch`, though the page still reports
  `search`. An abandoned search reports the top result's match kind. Opening the guess reports
  outcome `opened`, `resultCount` 0, and `matchKind` `guess`, and the page reports `searchGuess`,
  as Phase 2 asked. Return and the arrow keys count as ordinary opens.
- **How the source travels.** The list and the family pages push a `VerbDestination` (verb plus
  source) instead of a bare `Verb`; Phase 6 can add the matched section and reading to it.
  Deeplinks carry a `source` query item (`konjugieren://verb/gehen?source=widget`), because a
  widget or intent can pass the app only a URL. `World.handleURL` stores it in `verbSource`,
  falling back to `deeplink`. Spotlight, Info links, the widgets, and both random-verb intents
  name themselves this way; Handoff and the Open Verb intent set `verbSource` directly. **Phase
  11's deeplink grammar should keep this query item.**
- **The control needed its own intent.** The Random Verb control and the Random Verb shortcut ran
  the same `OpenRandomVerbIntent`, which cannot tell which of them ran it. The control now runs
  `OpenRandomVerbControlIntent` in `Shared/`, hidden from Shortcuts, reusing the existing title
  key. Phase 14 touches both.
- **Privacy lines** wait in `docs/privacy-policy-pending.md`, in English and German, with
  instructions for release day. `CLAUDE.md`'s "No Release Before 2027" section points there.
  Later phases add their lines to the same file. The staged text also rewrites the paragraph after
  the list, whose "recorded only as having happened" would otherwise become untrue.
- **Not built:** the flags `wouldMatchFolded` and `wouldMatchTranslation`, which the ideas
  document wanted only if A1 or A2 missed the release. Both are on `main`.
- **How it was tested.** 28 new tests: bands, the tracker's lifecycle, every report's parameters,
  a check that no parameter can echo the query, visits, and the source of each deeplink literal.
  In the iPhone 17 simulator, with signals logged temporarily, these fired as designed: browse,
  search (konnen → `exactFoldedInfinitive`, position 1), guess (gehn), no result (xyzzyq), a
  backgrounded search (`abandoned`, `infinitivePrefix`), family, a `?source=widget` deeplink, a
  leave at `example` after scrolling to the bottom, and `resume` after both a tab switch and a
  return from the background. Spotlight, Handoff, Info links, the shortcuts, and the control were
  tested through their URLs only, not by invoking them.

## Phase 4: Separable Verbs as a Main Clause Writes Them

**Ideas:** B2, and pedagogy decision 1. **Depends on:** nothing.

- The verb page shows the split conjugation in every finite simple conjugationgroup (ich stehe
  auf, du standest auf). It does not also show the joined conjugation.
- The quiz accepts the split conjugation and the joined one alike.
- Add a function that returns a verb's main-clause conjugation. The ideas document's coordination
  table expects it to serve the map's stranded parts and the quiz.

For the session to decide and record: whether the Conjugator's output changes or only what the
page and the quiz do with it; what the widget's quiz and the "Conjugate a Verb" shortcut show;
and whether any Info article contradicts the new display.

**How it differed:**

- **The Conjugator's output does not change; its callers' does.** `Conjugator.conjugate` gained
  `clause: Clause` (`Clause.swift`: `main`, `subordinate`), defaulting to `.subordinate`, the joined
  conjugation it has always returned. That default keeps the classify-and-verify oracle, the ~1,000
  `ConjugatorTests` expectations, and `CorpusFormsDumpTests`' `forms.json` exactly as they were,
  since Wiktionary's tables and the Python pipelines both deal in the joined word.
  `RegionalConjugator` defaults to `.main`, so every surface that shows a conjugation to a learner
  switched at once: the verb page, the quiz's shown answer, the widget's Präsens table and its
  multiple-choice quiz, the "Conjugate a Verb" shortcut, the family pages, and the Tutor's
  conjugation tool. `conjugate(…, clause: .main)` is the function this phase was to add.
- **Only the four finite simple conjugationgroups split.** The split reuses `withSeparablePrefix`,
  the Imperativ's helper, so only the leading run of separable prefixes moves (nachvollziehen gives
  vollziehe nach) and a full override such as haben's keeps working (achthaben gives hat acht). The
  compound conjugationgroups were already in main-clause order (bin aufgestanden), so the old page
  mixed two word orders and the new one has one. The Imperativ splits under either clause, as
  before. **For Phase 5:** a stranded finite part is the first word of a `.main` conjugation of a
  separable reading in those four conjugationgroups.
- **The quiz** grades against every region's conjugation in both clauses, and shows the main-clause
  one. Grading moved into `QuizItem.accepts`, which also collapses runs of spaces, now that an
  answer can have two words. It does not accept the subordinate order of a compound conjugation
  (angekommen bin), which nobody asked for. `makeQuizItem` became internal, with an optional
  `readingIndex`, so tests can build an item for a chosen verb; Phase 13 may find it useful.
- **No Info article contradicts the display.** The Präsens and Präteritum Indikativ articles
  already teach "ich komme ... an" and the subordinate "dass der Zug ... ankommt", and the Futur,
  Perfekt, and Präsenspartizip articles describe conjugations that do not split. The Families
  tab's separable-verb text says the same. The page now agrees with them where it used to
  contradict them.
- **Not changed:** `VerbExportTests`, a harness that exports every verb's page to JSON, still calls
  `Conjugator` directly and so writes joined conjugations. The App Store screenshot fixture's
  ankommen question now expects "kommt an", which `take_screenshots.sh` types from the exported
  answer, so it needs no edit, but a retaken screenshot would differ.
- **Pedagogy decision 1** is settled by this phase. The Closing updates `plans/pedagogy.md`.
- **How it was tested.** 4 new tests (the split and its exceptions in `ConjugatorTests`, the
  regional default, and two for quiz grading), 280 in all. aufstehen's page was checked in the
  iPhone 17 simulator. The widget and the shortcut were not looked at, since they read the same
  `RegionalConjugator` default.

## Phase 5: The Conjugation Map as a Build Product

**Ideas:** A5, first half. **Depends on:** Phase 4, for the stranded parts.

- A macOS command-line target that compiles the Conjugator's sources and writes a compact
  conjugation-to-infinitive map for the app bundle. The ideas document measured the July map at
  1.4 MB as a plain list and 164 KB compressed.
- A Run Script build phase that regenerates the map only when `Verbs.xml`, `AblautGroups.xml`, or
  a conjugator source is newer than the output. Declaring inputs and outputs to Xcode does this,
  as does an explicit timestamp. A build with no changed input must not run the tool.
- A loader in the app, and a function that answers "which conjugations of this verb equal this
  text?" The pedagogy report's Tier 4 diagnosis needs the same function.

Risks to settle first, before most of the code:

- The Conjugator and its model types may reach `@MainActor` state, `L`, or `Current`. Find out how
  much has to become `nonisolated` or move before a host tool can compile them.
- A new target needs `project.pbxproj` changes, unlike adding a file. If that has to happen in
  Xcode's interface, ask Josh to do it.
- If the refactor looks large (for instance a local Swift package), stop and ask Josh before
  starting it.

Also decide whether the tool replaces `CorpusFormsDumpTests` as the writer of
`corpus/working/forms.json`, which the Python pipelines read. Record the decision in
`docs/project-structure.md` and wherever the harness is documented.

**Done when** a clean build produces the map, an unchanged rebuild skips the tool, and a test
confirms that the map finds the verb of at least 99% of the app's example sentences, as the July
map did.

**How it differed:**

- **The risks were small.** The Conjugator and its model types compile for macOS with the app's
  own default MainActor isolation, so nothing became `nonisolated`. What they reached outside the
  core was presentation: `Family.displayName` (`L`), `PersonNumber.pronoun` and
  `pronounWithSieDisambiguation` (`Current.settings`), `Conjugationgroup.displayName(lang:)`, and
  `regionalAuxiliary(in:)` on `Verb` and `Reading` (`Region`). The first three moved, unchanged, to
  a new `ConjugationLabels.swift`, and the last to `Region.swift`; no call site changed. The two
  XML parsers gained `init(contentsOf:)`, with the bundle lookup as the default. The tool's
  `ToolWorld.swift` stands in for `Current` and offers only `fatalError`.
- **The target was added by editing `project.pbxproj`**, not in Xcode's interface. The tool's own
  folder is a synchronized group; the 17 app files it borrows are listed in a membership exception
  on the `Konjugieren` folder. The app target depends on the tool, so an iOS Simulator build
  builds it for the Mac first. It builds for the host architecture only (`ARCHS =
  $(NATIVE_ARCH_ACTUAL)`), with no dSYM, and `SKIP_INSTALL`. An unsigned `xcodebuild archive`
  produced an archive holding only the app, with the map inside it. **Not tried:** Xcode's own
  interface, and an Apple Silicon Mac.
- **The tool's executable stands for the Conjugator sources.** The Run Script phase ("Generate
  Conjugation Map", after Resources) declares `Verbs.xml`, `AblautGroups.xml`, and the tool as
  inputs and writes `ConjugationMap.lzfse` straight into the app bundle, so nothing generated is
  committed. Measured: an unchanged rebuild skipped the phase; touching `Verbs.xml` ran it; a
  code edit to `Conjugator.swift` relinked the tool and ran it; a comment-only edit recompiled
  but did not relink, and did not run it, which is right, since the map could not change. A
  `touch` of a Swift file is not a change to Xcode 26's driver at all.
  Josh's builds in Xcode confirmed the same: the first one regenerated the map (Xcode re-signed
  the tool, and a script phase also reruns when its exported environment differs, as it does
  between Xcode and `xcodebuild`), and an unchanged second one did not. **Judge this by file
  timestamps, not by the build log.** An Xcode `.xcactivitylog` carries forward the records of
  earlier builds whose results still stand, so the second build's log listed "Generate
  Conjugation Map", the tool's output line, and even the tool's link, while the tool and the map
  on disk kept their earlier timestamps.
- **The format** is one sorted line per conjugation (`fängt	fangen	anfangen an`), compressed with
  LZFSE: 50,056 conjugations, 1.4 MB of text, 173 KB in the bundle, about 2 seconds to build.
  `ConjugationMap.bundled` is a `nonisolated static let`, so Phase 6 can load it from a
  background task.
- **The tool replaces `CorpusFormsDumpTests`.** It writes `forms.json` with `--forms-json`, and its
  first output was byte-identical to the harness's last, so the harness is deleted.
  `scripts/write_forms_json.sh` builds the tool and writes the file. `CLAUDE.md`, the run command
  in `prompts/uses_etymologies.md`, the two Python docstrings that named the harness, and
  `docs/feature-architecture.md` § Conjugation Map say so.
- **The 99% test uses the defect plan's Scan 2**, which folds ß and ss and counts a finite part
  only beside its particle. It finds 3,547 of 3,572 sentences (99.3%), the 25 misses in the ideas
  document's appendix. The first version of the test did not fold ß, missed Kafka's läßt and
  vergißt, and came out at 98.99%, so the measure has to be stated exactly. A second test compares
  the bundled map with a fresh in-process build, which catches a Conjugator dependency the tool
  does not compile. Both run in about 2 seconds.
- **"Which conjugations of this verb equal this text?"** is `Verb.conjugations(matching:)`, in
  `ConjugationMatch.swift`. It grades as `QuizItem` builds its accepted answers (every region, both
  clauses, case and spacing ignored) and marks a match that is only the finite part of a separable
  reading. It needs no map.
- **For Phase 6.** The map's keys are not ß-folded: build a folded index at load time, as
  `ConjugationMapTests` does, for muß and läßt. Adjective endings (geklebte) are not stripped. The
  infinitive and the zu-infinitive are in the map but are not cells, so `conjugations(matching:)`
  returns nothing for them; name them in the row's own words. `conjugations(matching:)` makes six
  Conjugator calls per cell, about 270 per reading, so compute it for a folded row of 67 verbs only
  when the row opens. Within a key, whole verbs come before finite parts, ready for "base verb
  first, then one folded row".
- **Tests.** 17 new `@Test` functions, 296 in all.

## Phase 6: Reverse Lookup in Search

**Ideas:** A5, second half. **Depends on:** Phases 1, 4, and 5.

- A conjugation finds its verb. Each result row names the match, in the manner of "ging:
  Präteritum Indikativ, ich and er, of gehen". When a conjugation belongs to two verbs (gehört,
  gestanden), show both.
- A stranded finite part (halte) shows its base verb first, then one folded row for the separable
  verbs built on it, ordered by frequency when opened.
- Two words settle a separable verb: "stand auf" finds aufstehen.
- Opening a result lands on the matching section of the verb page with the conjugation marked,
  and on the matching reading for a verb with two.
- Accept older ß spellings (muß, läßt, wußte) through Phase 1's folding, and participles with
  adjective endings (geklebte) by stripping the ending before lookup. Short imperatives such as
  halt are corpus work and stay out.

The empty state from Phase 2 now appears only when this lookup also fails. Decide whether its
fuzzy guess should consider conjugations too.

**How it differed:**

## Phase 7: The Verb Page's Sections

**Ideas:** B3 as Josh amended it, and the tip from B5's verdict. **Depends on:** nothing.

- **Order by frequency within each block.** Keep simple conjugationgroups before compound ones.
  Within each block, order the conjugationgroups by how often they occur in a sample of the text
  corpus under `corpus/` (the `modern`, `government`, `government2`, and `technology` folders,
  skipping the English `-en.txt` files). Write the counting method and its results in a doc, with
  a script that reproduces them. Josh accepts that frequency varies by register. Ask him, when the
  numbers are in, where the two participles belong. Change the order on the verb page only, not
  in Info, the quiz, or the shortcuts, unless Josh says otherwise.
- **Second names.** Under or beside each heading, give the name a textbook uses, such as
  Perfektpartizip, also Partizip II. Draft the list in both languages and show it to Josh before
  committing it.
- **Article buttons.** An info-in-a-circle button at the right of every conjugationgroup heading
  opens that conjugationgroup's Info article.
- **Red-letter tip.** A TipKit tip on the verb page explains what red letters mean. Once
  dismissed, it never reappears.
- **Scroll tip.** After the red-letter tip is dismissed, a second tip encourages scrolling to the
  bottom for the etymology and the example sentence. It also never reappears.

**How it differed:**

## Phase 8: A Futur II Article

**Ideas:** B7's verdict. **Depends on:** nothing.

Write an Info article about Futur II in English and German, following
[`docs/conjugationgroupText.md`](../docs/conjugationgroupText.md). The verb page gains no Futur II
section, so the article shows by example how the construction is built. Check how `info/<index>`
deeplinks address articles before choosing where the new one goes in the list.

**How it differed:**

## Phase 9: Ways Between Verbs

**Ideas:** B4, A9. **Depends on:** nothing. Phase 3's `related` source applies if it is done.

- **B4.** The verb page leads to related verbs: the base verb and its derivatives (stehen,
  aufstehen, verstehen, bestehen), the other verbs of its ablaut group, and its family's page.
  Some bases have 60 to 80 derivatives, so the page needs a short list with a way to see all.
  Josh likes the page's current layout, so propose a placement, with a screenshot, before
  building it.
- **A9.** On a family's page in the Families tab, a segmented control between the description and
  the "Verbs" heading chooses Alphabetical, the default and today's behavior, or Frequency, most
  frequent first.

**How it differed:**

## Phase 10: Copy and Share

**Ideas:** B6. **Depends on:** nothing.

- A long press on a conjugation copies it. A tap still speaks it.
- A share button on the verb page sends a short text: the verb, its gloss, a few key
  conjugations with no label, and the App Store link (no web domain; see the decisions above).
  Build the key-conjugations function here. Phases 11 and 15 reuse it.

**How it differed:**

## Phase 11: Lookup from Outside the App

**Ideas:** C1, C2. **Depends on:** Phase 6 for the conjugation answers.

- **C1.** Before adding a route, write down one deeplink grammar that covers `search` with text
  and the list links Phase 16 will need, and record it in
  [`docs/feature-architecture.md`](../docs/feature-architecture.md). Then add the `search` route;
  a "Look Up a Verb" App Intent that takes a word, answers in the manner of "ging: Präteritum
  Indikativ of gehen", and opens the page; a Control Center control that opens search (see
  [`docs/control-center-controls.md`](../docs/control-center-controls.md)); and a Home Screen
  quick action. New shortcut phrases follow the existing English-only convention, since C3 was
  rejected.
- **C2.** Give each verb's Spotlight entry the glosses of every reading and its conjugations as
  keywords and alternate names, and move to a named index. Developers report that keywords match
  less reliably than titles, so test on a device if Josh can install a development build, and
  record whether the test ran on a device or in the simulator.

**How it differed:**

## Phase 12: Recents and My Verbs

**Ideas:** D1, D2 apart from its quiz scope. **Depends on:** nothing.

- One on-device record of the learner's verbs: each verb opened, with dates, and each verb
  starred. This is the shared piece the coordination table assigns to this track. Phases 13 to 16
  read it, and the quiz track will too. Put it where the widget extension can read it, because
  Phase 14 needs that. iCloud sync was rejected with the smaller ideas.
- **D1.** When the search field is focused and empty, show the last 20 or so verbs opened.
- **D2.** A star on the verb page, a My Verbs list that holds starred verbs and recent lookups,
  and a My Verbs filter in the verb list.

**How it differed:**

## Phase 13: A Quiz over Chosen Verbs

**Ideas:** D2's quiz scope, D3. **Depends on:** Phase 12.

- A minimal ability for the quiz to take a list of verbs and draw its questions from them.
- A My Verbs scope on the Quiz tab.
- **D3.** A "Test me on this verb" button on the verb page that asks three questions about the
  verb in view.
- `startQuiz` gains its `source` parameter.

Ask Josh whether a scoped quiz or a three-question quiz should post to the Game Center
leaderboard. Keep the change small: Tiers 2 to 6 of the pedagogy report will reshape the quiz, and
this phase should give them something to build on, not compete with.

**How it differed:**

## Phase 14: A Verb of the Day Worth Opening

**Ideas:** D5. **Depends on:** Phase 12, for the My Verbs part.

Draw the widget's daily verb, and every random verb (the Control Center control, the
`verb/random` deeplink, the Random Verb shortcut), from the 1,000 most frequent verbs, favoring
strong and base verbs, and from My Verbs once it has entries. The widget's choice must stay stable
through the day. Define the frequency bands once on `Verb`, as the coordination table asks, since
the quiz will use them too. The quiz widget's question sampling belongs to the quiz track and is
out of scope.

**How it differed:**

## Phase 15: The Review Card

**Ideas:** D4. **Depends on:** Phases 10 (the key-conjugations function) and 12.

When the app opens, one card above the verb list offers a verb looked up some days earlier, with
its key conjugations hidden until tapped. One tap reveals them; one dismisses the card. This needs
a simple due date per verb in the learner's record. Build it so the quiz track's practice record
(pedagogy Tier 3) can take it over later.

**How it differed:**

## Phase 16: Collections

**Ideas:** D6. **Depends on:** Phases 11 (the deeplink grammar), 12, and 13.

Fixed lists as places to go: the 100 most frequent verbs, the modal verbs, the verbs that take
sein, and each ablaut group. A list shows how many of its verbs have been opened, can be shared as
a link, and can start a quiz on itself. The Families tab already lists ablaut groups, so propose
to Josh where collections live and how they relate to that tab before building.

**How it differed:**

## Closing

- Run the full suite and `check_docs.py`.
- Confirm that every accepted idea in `docs/browse-and-verb-ideas.md` carries its "built" line,
  and that the staged privacy-policy lines cover every signal and parameter added.
- Update the quiz report, [`plans/pedagogy.md`](pedagogy.md), to reflect whatever it mentions
  that this plan implemented, in the manner of the "built on `main`" lines in the ideas document.
  Likely candidates, to be confirmed against what actually landed: the separable-verb convention
  and the quiz's acceptance of both conjugations (its decision 1 and Tier 1), the umlaut key row
  (Tier 1), the quiz over a list of verbs and the My Verbs scope, the due date per verb (Tier 3),
  the function that finds which conjugations of a verb equal a text (Tier 4), the frequency bands,
  and `source` on `startQuiz`.
- Write a short list of what each phase would mean for Conjuguer and Conjugar, drawn from the
  ideas document's carry-over notes, as a starting point for porting.
- Mark this plan finished in its Status section.

**How it differed:**
