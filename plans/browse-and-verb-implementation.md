# Plan: Build the Accepted Browse and Verb Ideas

**For:** a series of fresh Claude Code sessions, one phase per session as a rule. **Kind of work:**
app code, one build-time tool, localized strings, one Info article, and tests. **Written:**
2026-11-12, from Josh's verdicts in
[`docs/browse-and-verb-ideas.md`](../docs/browse-and-verb-ideas.md) and his answers to four
questions the same day.

## Status

Each session that finishes a phase fills in its row here, then writes a **How it differed** note
under that phase's heading. Leave rows for phases not yet started as they are.

| Phase | Status | Date | Commit | Ideas |
|---:|---|---|---|---|
| 1 | Done | 2026-11-12 | `bcab0c3` | A1, A2, A3, A8 |
| 2 | Not started | | | A4, C4 |
| 3 | Not started | | | Signals |
| 4 | Not started | | | B2 |
| 5 | Not started | | | A5 (the map) |
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
8. Fill in the Status row, write **How it differed**, append a journal entry to
   `docs/blog_notes.md`, and commit to `main`.

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
