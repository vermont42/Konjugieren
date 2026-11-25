# Review: the Browse and Verb Implementation

**Written:** 2026-11-25, in answer to [`prompts/verb_browse_review.md`](../prompts/verb_browse_review.md).
**Subject:** the code that [`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md)
built from [`docs/browse_and_verb_ideas.md`](browse_and_verb_ideas.md): sixteen phases, about
10,000 added lines, roughly 70 source files. **Reviewed at:** `0b157b6`, so the review covers the
code as it stands, including what the pedagogy plan and the SwiftLint setup changed afterward.
Nothing was fixed. This document only reports.

## Verdict

The work is sound. The tree is green (957 tests in 100 suites, 0 SwiftLint violations, 0
`check_docs.py` problems), the architecture decisions are good ones, and the plan's "How it
differed" notes are honest about what was and was not tried. No finding is a crash or a data loss.

Five things deserve attention before the 2027 release, in this order:

1. **A folded infinitive is treated as a literal match in three places** ([C1](#c1)). Searching
   "fuhren" puts führen above fahren and hides fahren's separable verbs, and the Look Up a Verb
   shortcut cannot open the page of drucken, fallen, zahlen, or fordern.
2. **A quiz correction's group link reports which verb the learner missed** ([P1](#p1)), which the
   staged privacy text says the app does not do.
3. **The widget's My Verbs rotation repeats one verb** whenever the list grows ([C2](#c2)), the
   opposite of what the rotation was built for.
4. **A failed search stalls the main thread** while it computes its guess ([F1](#f1)): 0.15 to 0.8
   seconds per keystroke in a debug build on this Mac.
5. **Tidying My Verbs erases collection progress** ([C4](#c4)), and Clear does it without asking.

The rest is duplication, stale prose, tests that prove less than they claim, and one view that has
grown too large.

## Method

I read the search core (`VerbSearch`, `VerbSearchResults`, `ConjugationIndex`,
`ConjugationMatch`, `SearchReport`), the verb list (`VerbBrowseView` and its helpers), and the verb
page (`VerbView`) myself. Three Opus subagents each reviewed one other area independently, with
no view of my conclusions: the conjugation map and lookup from outside the app; what the verb page
is built from; and the learner's record, collections, the widget's draw, and analytics. I then
re-read the code behind every finding of theirs that I ranked above "small", and each finding below
carries one of these labels:

| Label | Meaning |
|---|---|
| **Run** | Confirmed by running code: a temporary probe test (since deleted), the simulator, or a reviewer's re-run of a script. |
| **Read** | I traced it in the code myself. |
| **Reviewer** | A subagent reported it with file and line; I did not re-trace it. |
| **Suspected** | Plausible from the code, with the unchecked step named. |

What ran: the full suite as a baseline; a probe test that searched fifteen queries, timed eleven,
and conjugated every cell of all 3,572 verbs; the app on the iPad simulator for one keyboard check;
and, by one reviewer, `scripts/count_conjugationgroups.py` with a patched rule.

**Not covered:** VoiceOver, a real device, a German-language device, Tutor surfaces (this Intel
host cannot render them), and the quiz beyond `QuizScope` and `QuizSheet`. The string catalog was
checked mechanically: every named key has a translated English and German value.

Line numbers are those of `0b157b6`.

## Correctness

<a id="c1"></a>
### C1. A folded infinitive counts as a literal match, in three places (Run)

Folding (`VerbSearch.fold`) is a guess about what a learner meant to type: konnen for können. A
query that literally spells a conjugation is not a guess. Three places rank the guess level with,
or above, the literal reading.

- **The ranking.** `MatchKind` puts `exactFoldedInfinitive` above `conjugation`
  (`VerbSearch.swift:14-25`). "fuhren" is literally wir fuhren, and it returns führen first and
  fahren second.
- **The stranded parts.** `queryIsInfinitive` is `kind <= .exactFoldedInfinitive`
  (`VerbSearch.swift:82`), so a query that merely folds to an infinitive suppresses the folded row.
  The probe: "fuhr" returns fahren plus 32 separable verbs; "fuhren" returns fahren and none of
  them. Josh's rule was "unless the query is itself an infinitive", and fuhren is not one.
- **Look Up a Verb.** `literalAnswerKinds` includes `.exactFoldedInfinitive`
  (`VerbLookup.swift:32`), although the comment at line 58 says "A folded spelling answers only
  when nothing literal does". So "drucken" has two answers, drucken and drücken, `answers.count ==
  1` fails (line 83), and the shortcut opens the search list instead of the page. A reviewer
  counted 18 pairs in `Verbs.xml` that collide after folding, among them fallen and fällen, zahlen
  and zählen, fordern and fördern, nutzen and nützen. Typing either member of a pair, umlaut
  included, has the same result.

**Fix.** Compare with `== .exactInfinitive` at line 82. In `VerbLookup`, make the literal tier
`[.exactInfinitive, .conjugation]` and fall back to the two folded kinds together. Consider moving
`conjugation` above `exactFoldedInfinitive`: zahlen would still be followed directly by zählen,
since no other verb has zahlen as a whole conjugation. Add tests for fuhren and for one twin.

**Fixed on `main` 2026-11-25**, by Phase 1 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md):
`conjugation` and `finitePart` now rank above `exactFoldedInfinitive`, only `.exactInfinitive`
suppresses stranded parts, and Look Up a Verb's folded kinds answer together after the literal
tier.

<a id="c2"></a>
### C2. The widget's My Verbs rotation repeats a verb whenever the list grows (Read)

`VerbDraw.verbOfTheDay` returns `myVerbs[turn % myVerbs.count]` (`VerbDraw.swift:31-33`), and
`myVerbs` is newest first (`LearnerVerbs.swift:69-73`). Each My Verbs day advances `turn` by one.
Each verb opened or starred in between is prepended, which moves every other verb down by one. The
two cancel, and the widget shows the same verb again three days later.

A reviewer simulated it: with 20 recents and Poisson-distributed opens averaging one per three
days, 35% of My Verbs days repeat the previous one, against 5% for a uniform pick. Phase 14 chose
rotation over chance precisely because chance "showed abberufen twice in nine days while gehen
waited". `myVerbsDaysTakeMyVerbsInTurn` (`VerbDrawTests.swift:135-144`) passes because its list
never changes between days.

**Fix.** Rotate over a stable order, such as the list sorted by infinitive, so that a new verb
shifts only the entries after it. Test with a list that grows between days.

<a id="c3"></a>
### C3. The red-letter tip's guard is true for every verb (Run)

`hasRedLetters` (`VerbView.swift:59-61`) asks whether any cell contains an uppercase letter. The
probe found that all 3,572 verbs do, for two reasons. Every compound table shows a marked
auxiliary (hAst gemacht, wIrst machen). And the polite Imperativ is "machen Sie", whose capital S
is not a red letter: `MixedCaseSegmenter` exempts it when rendering (`Shared/MixedCaseSegmenter.swift:23-39`),
but this check does not go through the segmenter. Restricting the check to the simple tables
would not help, because the Sie row is in one of them.

So the guard never hides the tip, the tip's doc comment and Phase 7's note ("machen's page would
leave it nothing to point at") are untrue, and a weak verb's page conjugates about 30 cells per
body evaluation to learn nothing.

**Fix.** Decide which is wanted. If the tip may point at a red auxiliary, delete the guard. If it
should appear only where the verb itself is irregular, test the simple tables with
`MixedCaseSegmenter.segments(for:).contains(where: \.isIrregular)`, so that one function answers
"is this letter red?" for the renderer and the guard alike.

<a id="c4"></a>
### C4. Tidying My Verbs erases collection progress (Read)

A collection's "looked up" is `lastOpened != nil` (`LearnerVerbs.swift:55-57`). A left swipe on a
recent verb calls `remove`, which deletes the whole entry (line 93), so the verb loses its check in
every collection. Open werden from the top-100 page (2 becomes 3 of 100), swipe werden out of My
Verbs, and the page says 2 of 100 again. Phase 16 records this for Clear and not for the swipe.
Clear has no confirmation, so one tap takes "37 of 100 looked up" to 0.

`firstOpened` and `openCount` are written on every open and read nowhere in the app.

**Fix.** Count progress on `firstOpened`, and have Clear and the swipe forget only `lastOpened`.
Or keep the coupling, confirm before Clear, and say so in the docs.

<a id="c5"></a>
### C5. "Alphabetical" on the prefix pages is code-point order (Read)

`[Verb].sorted(by: .alphabetical)` returns `self` (`SortOrder.swift:20-27`), on the stated
ground that "every caller already gives alphabetically". Two callers do not.
`BrowseableFamily.verbsByPrefix` sorts with `$0.infinitiv < $1.infinitiv` (`BrowseableFamily.swift:134`
and `:152`), which compares code points, so on the Separable page's ab- section abändern follows
abziehen. And the related-verb list arrives by frequency, so it carries its own copy of the German
comparator (`RelatedVerbsView.swift:155-158`, copied from `Verb.swift:16`).

**Fix.** Make `.alphabetical` sort, with one shared German comparator on `Verb`, and delete the
copy and the two `<` sorts. A function named `sorted` that does not sort will catch the next
caller too.

### C6. Swiss spelling is missing from four captions and a title (Read)

`L.VerbView.builtOn(related.root)` and `L.VerbView.sameAblaut(ablautGroup)` receive the raw
string (`RelatedVerbsView.swift:47`, `:55`, `:147`, `:149`), while the chips beside them use
`.inUserRegion`. With the region set to Switzerland, aufschließen's card reads "Built on
schließen" above chips that read schliessen and beschliessen. `VerbCollection.title`
(`VerbCollection.swift:84`) has the same omission, so the quiz sheet and the share text for the
heißen, reißen, schließen, and stoßen groups keep the ß. A reviewer counted 14 multi-verb roots
with ß.

**Fix.** `.inUserRegion` in the five places.

### C7. Smaller correctness findings

- **A strong second reading drops out of the ablaut row (Read).** `ablautRelatives` filters on
  `$0.ablautGroup`, which is the primary reading's (`RelatedVerbs.swift:78`, `Verb.swift:81`).
  bewegen and anhängen are weak first and strong second, so neither appears on its group-mates'
  pages. Match a verb if any reading is in the group.
- **Recent can show fewer than 20 (Read).** `recent()` takes 20 before starred verbs are filtered
  out (`LearnerVerbStore.swift:27`, `LearnerVerbs.swift:65-67`). With 15 of the last 20 opens
  starred, Recent lists 5 while older unstarred opens exist.
- **A bad link cancels a good pending one (Read).** `handleURL` calls `clearDeeplinkTargets()`
  before it knows that the route resolves (`World.swift:131`), so
  `konjugieren://verb/nonexistent` wipes a pending practice set, challenge, or search and replaces
  it with nothing.
- **Two entry points bypass the route (Read).** `OpenVerbIntent` and `handleUserActivity` set
  `Current.verb` by hand. The intent never clears other pending targets and switches to the Verbs
  tab even when the verb is not found (`OpenVerbIntent.swift:14-19`). Spotlight already does this
  properly through `URL.verbDeeplink`.
- **Spotlight's migration flag is set even if the delete failed (Read).** `try?` swallows the
  error and line 39 sets `leftDefaultIndexKey` regardless (`VerbSpotlight.swift:37-40`), which
  would leave duplicates for good. Nothing ever removes an entry for a verb that leaves the
  corpus, and all 3,572 entries are rebuilt at every launch.
- **A collection key may be stored as the link spelled it (Suspected).** `init?(key:)` checks the
  exemplar with canonical equality and then stores the incoming string
  (`VerbCollection.swift:39-46`). A link carrying decomposed "hängen" would work, and would send a
  second spelling of `ablaut-hängen` to analytics. Nobody confirmed that iOS delivers such a link.
  Storing the matched group's own exemplar removes the question.

## Performance

<a id="f1"></a>
### F1. A failed search computes its guess on the main thread, per keystroke (Run)

`VerbSearchResults.init` calls `VerbSearch.guess` whenever nothing matched
(`VerbSearchResults.swift:164`), and the list evaluates that inside `body`
(`VerbBrowseView.swift:50-52`). The guess measures edit distance against every folded conjugation
within a few letters of the query's length. Timed in a debug build in the simulator on this Intel
Mac:

| Query | Time |
|---|---:|
| g, ge, geh, gehört, halte, komm, eat | 0.03 to 0.07 s |
| hat gefunden, ich bin gegangen | 0.05 s |
| ginng (a guess is found) | 0.15 s |
| xyzzyq (no guess exists) | 0.81 s |

An ordinary search is cheap. The stall comes exactly when a learner has mistyped, and each further
letter pays it again, because `SearchResultsCache` holds only the last query. A release build on
a phone will be several times faster, and I did not measure one.

**Fix.** Show "No verbs found" at once and fill the guess in from a detached task, cancelling the
task when the text changes. `ConjugationIndex` is already `Sendable`. A cheaper bound would also
help: `editDistance` can stop once a row's minimum exceeds the limit.

### F2. Smaller performance findings

- **Related verbs are rebuilt in `body` (Read).** `verb.related(readingIndex:)` runs at
  `VerbView.swift:216`, and `ablautRelatives` filters and regroups all 3,572 verbs each time
  (`RelatedVerbs.swift:77-86`). `verbsByRoot` is cached; a `verbsByAblautGroup` beside it would
  finish the job.
- **Look Up a Verb may build the index on the main actor (Suspected).** The only warm-up is the
  verb list's `.task` (`VerbBrowseView.swift:352-358`). A Siri run that never draws the list
  decompresses the map and folds 50,000 keys inside `MainActor.run`
  (`LookUpVerbIntent.swift:24-28`). Not measured.
- **A search ended by clearing the field is computed again (Read).** `signalEndedSearch`
  re-runs `VerbSearch.matches` (`VerbBrowseView.swift:772`) for a query whose results the cache
  still holds.

## Privacy

<a id="p1"></a>
### P1. A correction's group link says which verb was missed (Read)

A held correction appears only after a wrong answer. Its group link pushes
`VerbCollectionRequest(collection: .ablautGroup(ablautGroup), source: .quizCorrection)`
(`QuizCorrectionView.swift:146`), and `FamilyDetailView` then sends `viewCollection` with both
`source: quizCorrection` and `collection: ablaut-<exemplar>` (`FamilyDetailView.swift:284`,
`VerbCollection.swift:142-147`). Together the two parameters name the ablaut group of the verb the
learner just got wrong. 18 of the 76 groups hold one verb, so for those the key is the verb.

Each half is fine alone. This plan's Phase 16 added the key, for collections opened from the
Families tab or a shared link, and the staged policy discloses that. The pedagogy plan added the
source, which Josh ruled on 2026-11-15 to be a surface and not a count of answers. Nobody ruled on
the pairing, and the staged text says that naming a collection "says nothing the learner typed or
chose beyond opening it".

**Fix.** For `quizCorrection`, send `viewCollection` without `collection`, or with a constant such
as `ablautGroup`. Otherwise amend the staged policy line, which is Josh's call.

**Fixed on `main` 2026-11-25**, by Phase 2 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md):
`signalView(source:)` sends `viewCollection` without `collection` when the source is
`quizCorrection`. Josh chose the omission, and the staged text stays as written.

## Gaps Between the Docs and the Code

- **G1. The widget does not read the learner's record (Read).** `Shared/LearnerVerbs.swift:5-8`,
  `Shared/PracticeRecord.swift:67-69`, `docs/feature_architecture.md` § The Review Card, and Phase
  12's note all say the widget decodes it. Nothing under `KonjugierenWidget/` names either type.
  My Verbs reaches the widget inside the snapshot bundle that the app writes. The "added fields
  must be optional" rule still matters for app upgrades. Correcting the prose is cheaper than
  moving the types out of `Shared/`.
- **G2. The frequency doc overstates Perfekt Konjunktiv I and Futur Konjunktiv I (Run, by a
  reviewer; I read the rule).** In `scripts/count_conjugationgroups.py`, "habe" or "werde" with no
  adjacent ich counts as Konjunktiv I (`auxiliary_kind`, lines 348-371). A subordinate clause
  sends the auxiliary to the end, away from its subject: "was ich dir geboten habe". The
  simple-word path already demands a third-person neighbour (lines 493-496); the auxiliary path
  does not. With the rule patched to accept an ich anywhere in the clause, Perfekt Konjunktiv I
  fell from 851 to 358 pooled and Futur Konjunktiv I from 221 to 107. **The page's section order
  does not change.** What fails is the doc's sentence that pooling reverses the three close groups
  "because literature and the Bible are full of indirect speech". The patch is itself a heuristic,
  so the new figures are estimates.
- **G3. `DeeplinkTests` pins copies of the widget's links (Read).** `docs/feature_architecture.md`
  says the tests pin every widget literal. They pin the three `pendingDeeplink` constants in
  `Shared/`. The six `"konjugieren://verb/\(…)?source=widget"` strings in five widget views are
  retyped in the test. A typo in a view would pass and silently report `deeplink`.
- **G4. A migration for data no shipped build wrote (Reviewer).** `PracticeStore.migrated` and
  `LegacyLearnerVerbs` (`PracticeStore.swift:216-246`) carry Phase 15's per-verb schedule into the
  practice record. Both exist only on `main`; version 1.4 has neither. The migration serves Josh's
  own devices. This is the only trace of "two mechanisms for one job": the schedule itself now
  lives once, in `PracticeRecord`. Delete before release unless Josh wants his history kept.
- **G5. Dwell time includes time under a sheet (Read, not measured).** `VerbVisit` ends on
  `onDisappear` or backgrounding (`VerbView.swift:239-254`). Presenting the article sheet or the
  Test Me quiz does not make the page disappear, so `leaveVerbView`'s `dwell` counts three quiz
  questions as reading.
- **G6. The Related Verbs card has no `VerbPageSection` (Reviewer)**, so `deepestSection` cannot
  say that a learner reached the newest thing on the page.
- **G7. Stale prose (Read).**
  - `VerbLookup.swift:39`: "ausgehen and 30 more". The map has 63. **Fixed on `main`
    2026-11-25**, by Phase 1 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md), as "dozens more".
  - `ConjugationMap.swift:55`: "about 160 KB". The file is 173 KB.
  - `ConjugationMapTool/main.swift:83-84`: the map is not written atomically because of the script
    sandbox, which the app target has since turned off. An atomic write would now work, and would
    avoid a truncated map whose fresh timestamp keeps the phase from rerunning.
  - `QuizView.swift:1509-1514`: `QuizSheet`'s doc comment opens with a sentence about
    `TabQuizScope`.
  - `Analytics.swift:70-71`: "once the quiz track sends it". **Fixed on `main` 2026-11-25**, by
    Phase 2 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md).

## Duplication

- **D1. "The cells of this verb that this text fills" is written three times.**
  `MatchedConjugation.init(whole:of:)`, `MatchedConjugation.marks(on:)`, and
  `MarkedConjugations.init?(text:on:)` (`VerbSearchResults.swift:24-32`, `:76-88`, `:223-234`) each
  call `conjugations(matching:)`, filter on `isFinitePart`, take the first reading, and collect its
  conjugationgroups. One helper that takes the matches and a preference for whole or part would
  serve all three.
- **D2. The zu-infinitive is built twice (Reviewer).** `ConjugationMap.swift:142-144` writes the
  key and `Reading.zuInfinitive` (`VerbSearchResults.swift:209-217`) recognizes it. If one changes
  alone, a key with no cell is named as nothing. Move `zuInfinitive` to `Reading.swift`, which the
  tool compiles, and have the builder call it.
- **D3. "Which conjugationgroups leave a finite word" is listed three times (Reviewer).**
  `ConjugationMap.swift:102-107`, `ConjugationMatch.swift:75-81` (`leavesFinitePart`), and
  `ConjugationMapTool/CellsJSON.swift:24-29`.
- **D4. The key conjugation of a stem is computed twice, with different failures (Read).**
  `KeyConjugations.swift:14-23` drops a cell the Conjugator cannot fill.
  `Mastery.swift:76-79` shows the infinitive in its place.
- **D5. The collection and family views repeat themselves (Reviewer).** The sort `Picker` appears
  in `VerbCollectionView.swift:47-56`, `FamilyDetailView.swift:40-49`, and
  `RelatedVerbsView.swift:171-179`. The "N of M" count, text, and accessibility label are computed
  in both `VerbCollectionRow` and `VerbCollectionCard`. The ablaut-group predicate exists in
  `AblautGroupInfo.verbs` and in `VerbCollection.contains`, and `VerbCollectionBar` is handed one
  list of verbs while its quiz asks the other; a test pins that the two agree, which is a sign
  that one should go.
- **D6. Widget and intent links (Read).** Six retyped verb links (see G3), and three intents in
  `Shared/` whose `perform` bodies are identical. A `WidgetDeeplink` enum in `Shared/` and a
  `PendingDeeplinkIntent` protocol with a default `perform()` would remove both, and would give
  `OpenQuizIntent`'s inline literal a constant that a test can pin.
- **D7. The main-clause split is reimplemented in the quiz's variants (Reviewer).**
  `StandardVariants.swift:226` cuts the separable run off a string that has already been through
  `inRegion`. Swiss ss is one character longer than ß, so the cut would land a letter off for a
  prefix such as groß or maß. No doublet verb has such a prefix today. This is pedagogy-plan code
  duplicating Phase 4's `withSeparablePrefix`.

## Smells

- **S1. `VerbBrowseView` does too much.** The struct runs from line 6 to line 790 with 17 `@State`
  properties, and it owns search, recents, the My Verbs list with its alert, the review card's
  lifecycle, hardware-keyboard selection, three analytics trackers, and two kinds of deeplink
  request. Each phase added a little. Natural seams: `MyVerbsList`, `FailedSearchHelp`, a
  review-card host, and an `@Observable` search model that owns `searchText`, the cache, the
  tracker, and the keyboard selection. The last would also make the search flow testable, which
  today only two static functions are.
- **S2. `searchFocusLostAt` is a `Date` used as a `Bool`, and it never resets.** It is assigned
  `.now` and compared only with `nil` (`VerbBrowseView.swift:19`, `:68-71`, `:86`). After the
  field first loses focus it stays set, so every later push from the list goes through `Task {
  await waitUntilIdle() }`. That is harmless, because the wait returns at once when nothing is
  animating, but the guard does not do what its comment describes.
- **S3. Declarations in files named for something else.** `Conjugationgroup.isParticiple` and
  `isImperativ`, `Reading.zuInfinitive`, and a `MarkedConjugations` initializer live in
  `VerbSearchResults.swift`. `VerbDestination` and `MarkedConjugations` live in `VerbVisit.swift`.
  `VerbListMode` lives in `SortOrder.swift`. `FlowLayout`, used in eight files, lives in
  `RelatedVerbsView.swift:194-243`. It also proposes `.unspecified` to every child, so a chip
  wider than its row overflows instead of wrapping.
- **S4. `VerbSearch.keysCache` is a global memo keyed by infinitive** (`VerbSearch.swift:328-342`).
  It is correct for the one corpus. A test that builds its own `Verb` named gehen with another
  gloss would be served the real one's keys. Storing the lowercased and folded infinitive on
  `Verb` at parse time needs no cache.
- **S5. App-wide statics, with multiple scenes enabled (Suspected, not tried).** `Info.plist`
  sets `UIApplicationSupportsMultipleScenes`. `VerbSearchArrowKeys` keeps one `move` closure and
  one `host` (`VerbSearchArrowKeys.swift:13-14`). With two windows on an iPad, focusing the second
  window's search and blurring the first can leave the arrow keys uninstalled or pointed at the
  wrong window. `Current` is global too, so this is one more instance of a standing limit and not
  a new kind of problem.
- **S6. An analytics value decides what the interface shows (Reviewer; I read `isRanked`).**
  `showsVerbLink` is `quiz.scope.source != .verbPage` (`QuizView.swift:449`). And `isRanked` is
  `isDefaultQuiz`, a conjunction of ten negatives (`Quiz.swift:1413-1415`), so a new mode that
  forgets to add itself is ranked and posts to Game Center. No mode is wrongly ranked today. A
  `kind` enum on `QuizScope`, with only `.default` ranked, fails safe.
- **S7. Five timed workarounds.** 700 ms of lingering focus, a 500 ms wait for a pop, a 400 ms wait
  for a sheet, a poll of up to a second for UIKit transitions, and a 4-second note
  (`VerbBrowseView.swift:80`, `:620`, `:576`; `VerbView.swift:722`;
  `ViewControllerTransitions.swift:13-18`). Each is commented as a hack with its reason, which is
  right. None of the tasks is cancelled when superseded, so a second tap on the mail link hides
  the note early. They are worth one list in a doc, to retry on each new iOS.
- **S8. The sort picker returns during a search and does nothing.** With text in the field and the
  keyboard down, the picker replaces the letter row, and choosing My Verbs has no visible effect.
  Phase 1 notes this. Disabling the picker while `isSearching` would say so on screen.
- **S9. Unused or unguarded.**
  - `URL.konjugierenURLPrefix` (`URLExtension.swift:121`) has no caller.
  - `LearnerVerbs.recent(limit:)` takes a limit that nothing passes.
  - `ConjugationMapTool` accepts any `--flag value`, so `--form-json` for `--forms-json` writes
    the map and silently skips the file (`main.swift:32-41`).
  - `ConjugationMap(compressed:)` turns invalid UTF-8 into an empty map, so every way the map can
    fail to load looks the same (`ConjugationMap.swift:93-96`).
  - `scripts/count_conjugationgroups.py` prints zeros and then divides by zero when given another
    app's `cells.json` (line 578).
  - `Analytics.swift:44-45` breaks the alphabetical order of the signal names. **Fixed on `main`
    2026-11-25**, by Phase 2 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md).
- **S10. Konjugieren and Conjuguer build the tool into one directory (Reviewer).**
  `$TMPDIR/ConjugationMapTool-build` in `scripts/write_forms_json.sh:31` and
  `scripts/count_conjugationgroups.py:184` is the path Conjuguer's script uses for a target of the
  same name. Conjugar already prefixes its own. Two sessions running at once can overwrite each
  other's binary.

## Elegance

- **E1. `VerbSearchResults.Row` and `.Entry` are one shape twice.** `Entry` is `Row` flattened
  with an `isInSeparableVerbs` flag (`VerbSearchResults.swift:104-132`). If the results stored
  entries, with the folded row's verbs behind an `isShown` filter, the `Row` type, the `flatMap`
  in `entries(separableVerbsAreShown:)`, and the one in `VerbLookup.swift:47-54` would go.
- **E2. `VerbView.rows(for:)` has a redundant case.** A participle has no `personNumber`, so the
  general branch already gives it a nil pronoun (`VerbView.swift:405-417`). The switch reduces to
  the Imperativ and everything else.
- **E3. Two static tables and an if-else chain pick the tracked sections.** `firstSimpleTable`,
  `firstCompoundTable`, and the three-way branch in `conjugationSection(for:)`
  (`VerbView.swift:389-403`) would be one optional `VerbPageSection` on `ConjugationTable`. The
  `openArticle` closure just above them is formatted so that it reads as a block inside a block.
- **E4. `sorted(by:)` should sort** (see C5), and **`QuizScope` wants a `kind`** (see S6).

## Tests

- **T1. Three tests cannot fail.**
  - `allCellsFollowsThePage` (`ConjugationTableTests.swift:43-45`) asserts the definition of
    `allCells` (`ConjugationTable.swift:224`). What can drift is `stacks`; assert against
    `stacks.flatMap { $0 }.flatMap(\.cells)`.
  - `differentQuestionsCanOrderDifferently` (`WidgetSnapshotTests.swift:189-193`) compares two
    sets, which are equal in any order.
  - `noParameterValueEchoesTheQuery` (`SearchReportTests.swift:168-185`) holds by the types, since
    every value is an enum case or a band. Harmless, and not evidence.
- **T2. Three tests check a copy of what they claim to check.**
  - `VerbLookupTests.swift:20` and `:49` compare against `MatchedConjugation(whole:of:)`, built by
    the code under test.
  - `InfoTests.swift:30-32` copies `InfoView.cleanURLString`.
  - `DeeplinkTests` retypes the widget's links (G3).
- **T3. Branches with no test.**
  - Twin infinitives and "fuhren" (C1).
  - The rotation with a list that changes (C2).
  - `writeSnapshot`'s path from disk: every stability test passes `keeping:` by hand, so a
    missing, corrupt, or stale bundle on disk is never met (`WidgetSnapshotWriter.swift:8-24`).
  - The Spotlight migration's order, the bug Phase 11 found by testing. `VerbSpotlight` calls
    `CSSearchableIndex` directly, so a test cannot reach it.
  - The begin-and-end pairing of a visit across `scenePhase`, which lives in `VerbView`.
  - `ReviewSchedule` on a daylight-saving day. The code is right; nothing pins it.
- **T4. Exact assertions against a growing corpus.** `results("eat", includeGlosses: false) ==
  ["beatmen"]` (`VerbSearchTests.swift:68`) breaks the day a verb containing "eat" is imported.
  That may be wanted as a tripwire. If it is, a comment should say so, as the roadmap expects more
  verbs.

## Costs of Settled Decisions

These are Josh's decisions, recorded in the plan. Each has a cost its note does not mention.

- **Opening a verb from the widget counts as forgetting it (Reviewer).** Any lookup but the card
  sends a verb back to the first box (`VerbView.swift:443-446`). On a My Verbs day the widget
  shows a verb the learner already knows, and a tap resets its schedule.
- **The search-scope flip overrides a deliberate choice.** A learner on 1.4 who chose Infinitive
  Only on purpose is moved to the new default once. The rule is right for everyone who only
  inherited the old one, and the two cannot be told apart.
- **The sein collection's quiz may ask a haben reading (Suspected).** Its scope passes no reading
  index, so a question on fahren may expect "hat gefahren" under a title that says sein. The
  reading draw was not traced.

## Checked and Found Fine

- **Return in an empty search field (Run, iPad simulator).** I suspected that Command-F followed
  by Return would open the first verb in the list, since `openKeyboardSelection` defaults to index
  0. It does not: the field takes focus, and Return with nothing typed leaves the list alone.
  Tried with no recent verbs.
- **The search source reaches analytics.** The control and the quick action arrive as
  `search?source=…`, whose missing `q` becomes an empty string, so `fieldOpened(from:)` runs and
  the typed search reports its surface.
- **Localization.** Every named key in `Localizable.xcstrings` has a translated value in both
  languages.
- **The map's format and the deeplink grammar (Reviewer).** No key in the bundled map contains a
  space or tab. Links with `&`, `=`, `#`, `%`, ß, umlauts, an empty `q`, and a spaced `match`
  round-trip. `info/<key>` is tried before `info/<n>`, and no key is numeric. The corpus is parsed
  before any intent or scene can ask for it.
- **The main-clause split (Reviewer).** Stacked prefixes, haben's full override, and readings that
  differ in separability all behave, and every caller that needs the joined word asks for
  `.subordinate`.
- **`Verb.root` (Reviewer).** It follows only prefixes the corpus marks, so bellen and beten are
  safe, and nesting never exceeds two steps.
- **The Leitner ladder, the store, and the draw (Reviewer).** A corrupt box is clamped, start-of-day
  arithmetic survives daylight saving, a verb that left the corpus is skipped, there is one writer
  per key, and the weighted draw's boundary is correct and tested.
- **The tool target (Reviewer).** None of the 17 borrowed files reaches `Current` beyond
  `fatalError`, and the build phase's declared inputs and output match what the script passes.

## What Is Done Well

- **One ranking rule, shared.** `VerbSearch` serves the list, the shortcut picker, and Look Up a
  Verb, and a test pins that the picker and the list agree. The plan asked that they not drift,
  and they cannot.
- **The map is built from the Conjugator's own sources**, and `matchesAFreshBuild` proves that the
  bundled map is current. The rebuild rule is documented with measurements, including the lesson
  that a build log is not a record of what ran.
- **`ConjugationTable` is the one place section order lives.** `allCells` derives from it, so the
  landing scroll cannot disagree with the page.
- **`Clause` defaults to `.subordinate` in the Conjugator and `.main` in `RegionalConjugator`.**
  That kept a thousand test expectations and the Wiktionary oracle unchanged while every
  learner-facing surface switched at once.
- **The presentation split holds.** Model files compile for macOS, and what needs `L` or
  `Settings` sits in app-only files.
- **The privacy work is careful**: bands, fixed vocabularies, staged policy lines in both
  languages. That is why P1 stands out.
- **The hacks are labelled as hacks**, each with the failure it works around and what was tried
  first.

## A Suggested Order of Work

1. **C1**, with its tests. One root cause, three symptoms, and the fix is a few lines.
2. **P1.** A one-line change, or a ruling from Josh.
3. **C2** and **C4.** Both are small changes to `Shared/` values with pure tests.
4. **F1.** Move the guess off the main actor.
5. **C5, C6, D5** together: one comparator, `.inUserRegion` in five places, one sort picker.
6. **C3** and **G2**, each of which needs a decision before code.
7. **G1, G3, G7** as a prose pass, and **G4** at release time.
8. **S1** when the verb list is next opened for a feature. The other smells and the elegance items
   can ride along with whatever touches their files.
