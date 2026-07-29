# Fact-check "A History of the German Verb System"

**Status: every phase is done, including Phase 4, which ran 2026-07-29.** The deliverable is
[`docs/history_corrections.md`](../docs/history_corrections.md). Written 2026-07-27
from the Conjugar session that ran the same check on Conjugar's Spanish essay. Rescoped
2026-07-28 by Josh: see "Revision" at the bottom for what changed and why. Phases 2, 3 and 4 ran
2026-07-28 and 2026-07-29; see the revisions at the bottom.

**What is left is Josh's, not a session's.** Nothing has been applied to
`docs/verb_history.txt`, `docs/verb_history_de.txt` or `Konjugieren/Assets/Localizable.xcstrings`
beyond Phase 0's ten patches, which are also unsynced. The corrections document is a set of
proposals; Josh decides which land, and `scripts/sync_verb_history.py` pushes the result to the
catalog afterward.

**Phase 4 was not a fan-out.** It was synthesis in one context: merge four finished inputs into
one document and write the German counterpart prose. Do not turn on ultracode for it and do not
spawn a fleet. The "run this with ultracode" instruction below applies to Phases 1 and 2, which
are done. Everything Phase 4 needs is on disk; it needs no web research and no search budget.

**Do not re-run Phase 2.** It cost 2.38 million subagent tokens across 51 agents and
returned a disposition for all 31 findings, with replacement prose for the 27 survivors.

**Do not re-run Phase 3.** It ran the app's own conjugator over the essay's spans in a temporary
Swift Testing suite and then deleted it. Re-running recreates that file and re-derives nine
corrections that are already written down.

**Do not re-run Phase 0.** Its step 1 says to extract the essay from `Localizable.xcstrings`
into `docs/verb_history.txt`. That file now holds the *patched* text, and the catalog still
holds the unpatched text, so a second extraction silently discards all ten patches.

**Do not re-run Phase 1 either.** It cost 1.12 million subagent tokens across eight agents and
returned a verdict for all 111 inventory rows. Re-running it buys nothing and pays for it twice.
What the run has produced so far:

| File | |
|---|---|
| [`docs/verb_history.txt`](../docs/verb_history.txt) | English essay, patched. The line numbers everything else cites |
| [`docs/verb_history_de.txt`](../docs/verb_history_de.txt) | German translation, patched to match |
| [`docs/verb_history_claims.md`](../docs/verb_history_claims.md) | **The claim inventory. Every fan-out phase works from this, not from the section ranges below** |
| [`docs/verb_history_phase0.md`](../docs/verb_history_phase0.md) | What was patched, what diverged, the residue list, and the seams the patch created |
| [`docs/verb_history_phase1.md`](../docs/verb_history_phase1.md) | All 111 verdicts with reasoning and sources, 31 findings with replacement prose, agent H's report, and the inventory gaps |
| [`docs/verb_history_phase2.md`](../docs/verb_history_phase2.md) | **Phase 4 input 1.** Disposition of all 31 findings, replacement prose for the 27 survivors, agent H's routing, and the coverage audit |
| [`docs/verb_history_phase2_reports/`](../docs/verb_history_phase2_reports/) | The 31 skeptic reports, the 19 second opinions, the coverage audit, and `final.json` |
| [`docs/verb_history_phase3.md`](../docs/verb_history_phase3.md) | **Phase 4 input 2.** Nine span corrections, the H11 and H13 adjudications, markup and link results, and four findings against the app rather than the essay |
| [`docs/history_corrections.md`](../docs/history_corrections.md) | **The deliverable.** Phase 4's merge of the four inputs, with German prose written for every survivor |
| [`scripts/sync_verb_history.py`](../scripts/sync_verb_history.py) | Validates an extract; `--check` writes nothing |

Nothing has been synced back to the catalog, which is Josh's call to make after he reviews
the extract diff.

**Phase 1 corrected the inventory's line numbers.** Nine shared-half rows cited a line one to
nine short of their claim, by varying amounts, so no constant offset would have fixed them. All
111 have since been audited mechanically, by matching each row's quoted fragment against its
cited line. Phase 0's patch table had the same defect in five rows and is also corrected. If a
line number ever looks wrong again, that audit is four lines of Python and is worth re-running
before trusting a number.

**Historical, and superseded by the status block at the top of this file.** Phases 1 and 2 were
the fan-out and were run with ultracode on: seven researchers in Phase 1, then 31 skeptics and 19
second opinions in Phase 2. Phases 0 and 3 were serial, single-context work, and Phase 4 is too.
Kept because a reader of the corrections document should be able to tell what produced it.

## Why this exists

Conjugar's `Info.verbHistoryText` ("A History of the Spanish Verb System") was fact-checked
claim by claim in July 2026. The findings are in
`/Users/josh/Desktop/workspace/Conjugar.mig/docs/history_corrections.md`, and the corrected
prose is in `/Users/josh/Desktop/workspace/Conjugar.mig/docs/verb_history.txt`.

**Phase 0 read both in full, and no later phase should.** The corrections file is 358 KB and
about 90,000 tokens, and its whole contribution to this run was the ten patches already applied
to `docs/verb_history.txt`. A session doing Phase 4 that reads it "before doing anything else",
as an earlier draft of this line instructed, spends most of a context window on an input whose
output is already on disk.

**The three essays share their opening sections as near-verbatim variants.** Konjugieren's
first five sections cover the same ground as Conjugar's:

| Konjugieren section | Status | Treatment |
|---|---|---|
| `From Stardust to Speech` | shared with Conjugar | patch |
| `The Long Road to Language` | shared | patch |
| `The Yamnaya and Proto-Indo-European` | shared | patch |
| `The Verb System of Proto-Indo-European` | shared | patch |
| `Ablaut: The Heart of Indo-European Morphology` | shared, retitled (Conjugar's is "Ablaut, and Why Spanish Nearly Lost It") | patch the shared claims; its German material goes to the fan-out |
| `The Migration to Europe` onward | German-specific, never checked | fan out |

**The shared sections are not fact-checked in this run. They are patched.** Conjugar's
`history_corrections.md` is a diff, not a replacement text, and Konjugieren's prose is
already the right length and voice. Applying the corrections is a local edit at each
correction site, not a rewrite and not a research task. Two reasons this is the right call
and not merely the cheap one:

1. Those corrections already survived an adversarial skeptic pass that dismissed 104 of 188
   proposals. Fresh researchers over that text can only tie or regress.
2. The earlier draft of this file dedicated an agent to diffing the shared sections for
   claims that mutated during the port. Patching dissolves that problem instead of
   detecting it: a mutated claim gets corrected without anyone having to notice it mutated.

Note that this essay is the shortest of the three at 2,753 English words, against Conjugar's
5,683. The German-specific half is dense with dates and sound laws, and that half is the
whole job here.

## What is different here, and will bite

1. **There is no editable extract.** The essay lives on a single JSON line in
   `Konjugieren/Assets/Localizable.xcstrings` under `Info.verbHistoryText`. Editing it there
   is the foot-gun `CLAUDE.md` warns about: the Edit tool renders `\"` as `"` and writes it
   back unescaped, corrupting the catalog.
2. **It is already translated.** `sourceLanguage` is `en`; there are `en` (2,753 words) and
   `de` (2,695 words) localizations, both marked `translated`. English is the source, German
   the translation. Every patch and every correction lands in two places, and a hedge that
   reads correctly in English can be flattened into a flat assertion in German.
3. **Bad markup crashes this app.** Unlike Conjugar and Conjuguer, whose parsers fail
   silently, `StringExtensions.swift` calls `Current.fatalError.fatalError("Unterminated
   delimiter: …")` for each of `` ` ``, `~`, `‡`, `$`, `^`. The validator in Phase 0 is not a
   nicety, and it matters more in this scope than the last, because Phase 0 now hand-edits
   prose that is full of these markers.
4. **`^…^` is an emoji span, not a heading.** Conjugar uses `^…^` for headings; this app uses
   it for emoji, and the essay already contains three such spans. Anyone porting Conjugar's
   sync script must rewrite the marker table rather than copying it.
5. **Asterisks are linguistics, not markup.** This essay carries about twenty of them
   (`*bʰer-`, and so on) as reconstructed-form notation. Do not "balance" them.

## Phase 0 — extract, validate, patch

Nothing fans out until this phase is done and its diff is reviewed.

1. **Extract the essay to `docs/verb_history.txt`**, following the shape Conjugar uses: a
   header block documenting *this app's* markup and its rules, a dashed separator line, then
   the English body verbatim.
2. **Port `scripts/sync_verb_history.py`** from Conjugar, adapting the marker table (five
   markers here, and `^` means emoji) and the link check. Conjugar's version validates four
   things: markers balance, markers do not nest, link targets resolve, and no irregularity
   span starts with a lone capital. Here the link check becomes "every `‡…‡` payload is a
   well-formed URL." Negative-test each validator by corrupting a copy, and confirm `--check`
   passes and the round-trip is **byte-identical** before editing anything. This repo already
   has a `scripts/check_docs.py`; follow its conventions.
3. **Read Conjugar's `docs/history_corrections.md` in full**, then **apply its corrections to
   Konjugieren's five shared sections** in the extract.

   **Use Conjugar's corrected phrasing verbatim wherever it applies.** Not paraphrased, not
   trimmed to fit Konjugieren's tighter word budget, not improved. That prose was written to
   fix a specific error and then survived a skeptic pass; its clause structure is carrying the
   hedge, and rewording is how a hedge quietly becomes an assertion. Copy the sentence.

   Judgement calls, in rough order of how often they will come up:
   - A correction whose claim Konjugieren already words correctly: skip it, and say so.
   - A correction that lands on a claim Konjugieren does make: paste Conjugar's corrected
     sentence in place of Konjugieren's.
   - A correction whose sentence carries Spanish-specific material that has no German
     counterpart (the *poder* / *puedo* thread runs through Conjugar's opening): keep every
     clause that is language-neutral verbatim, and change only the example. Re-point at German
     or drop, whichever the sentence supports.
   - Anything else that seems to require rewording: **do not reword silently.** Apply the
     verbatim text if it is at all usable, and list the sentence as a divergence with the
     reason. Josh reviews the divergence list alongside the diff. A short list of flagged
     rewordings is a better outcome than a clean diff full of unflagged ones.

   The one rule that survives every judgement call: hedge strength is preserved exactly. A
   correction that added a hedge in Conjugar adds the same hedge here, in the same words.
4. **Emit a residue list.** Any claim in Konjugieren's five shared sections with **no
   counterpart** in Conjugar's essay is unchecked, and patching does not touch it. This is
   most likely in `Ablaut`, whose retitle from "Ablaut, and Why Spanish Nearly Lost It"
   reflects an opposite rhetorical job: German strong verbs descend from ablaut directly, and
   the app's `$…$` spans light up exactly those vowels.
5. **Build the claim inventory.** This is the step that keeps the fan-out from paying for the
   same research twice, and it is described in its own section below.
6. **Land the patches in `docs/verb_history.txt` only.** Do not sync back to
   `Localizable.xcstrings` in this phase. Josh reviews the extract diff first, and the German
   counterparts for every touched sentence come with it.

### Phase 0.5 — the claim inventory

**The fan-out is the expensive part of this run.** Conjugar's cost most of three five-hour
windows. Duplicated research is the main avoidable waste, and section ranges are what cause
it: ranges overlap at the edges, so the same fact gets researched by two agents who each
believe it is theirs. In this essay the collisions are predictable. Grimm's law sits in the
Germanic-verb range while the High German consonant shift sits in the Old High German range,
and no researcher can check the second without reading up on the first. Strong-verb classes
appear in both. Preterite-present modals appear in the tense-building range and again in the
Konjunktiv discussion.

So do not hand out ranges. Hand out claims.

Phase 0 already has the whole essay open. Before the fan-out starts, emit
`docs/verb_history_claims.md`: every checkable assertion in the German-specific half, one per
row, numbered, with

- the quoted claim and its line in `docs/verb_history.txt`,
- the **single** cluster that owns it,
- a `kind` tag: date, number, name, etymology, sound law, consensus attribution, or quoted
  verb form,
- a `depends-on` field naming any other inventory row a researcher must know the verdict of
  before judging this one.

Rules for the inventory:

- **Exhaustive and disjoint.** Every claim appears exactly once. A claim two clusters both
  want goes to the one whose section states it most fully; the other cluster gets a
  `depends-on` pointer, not a second copy.
- **Residue-list items are assigned here**, not routed by default. The `Ablaut` residue
  mostly belongs with the strong classes in cluster E, but decide row by row.
- **Shared background is named once.** The two consonant shifts, the seven strong classes,
  Verner's law and PIE accent, and the dental preterite are each owned by exactly one cluster.
  Every other cluster that leans on one of them cites the owner's verdict and does not
  re-search it. If the owner's verdict has not landed yet, flag the dependency and move on;
  agent H resolves anything still open.

The inventory costs one agent that is already reading the text, and it converts seven
overlapping ranges into a partition. It also makes coverage checkable at the end, which the
range-based version was not: a claim nobody reported was previously indistinguishable from a
claim everybody thought belonged to someone else.

## Phase 1 — fan out over the German-specific claims

**Done, 2026-07-28. Results in [`docs/verb_history_phase1.md`](../docs/verb_history_phase1.md).**
Kept below because Phase 2 needs to know what each cluster was told, and because a skeptic
judging whether a researcher overreached should be able to read the brief it was working from.

Seven clusters, one researcher each. Everything before `The Migration to Europe` is out of
scope except residue-list items the inventory assigns here.

**The section lists below orient a researcher; the inventory is what it works from.** Where
the two disagree, the inventory wins, because it is the only artifact that guarantees no
claim is checked twice and none is checked zero times.

- **A. Into Europe** — `The Migration to Europe`. Corded Ware, the Germanic homeland, the
  Jastorf culture, and any appeal to a pre-Germanic substrate, which is a contested
  hypothesis and must not be stated flatly.
- **B. Teutoburg** — `The Battle of the Teutoburg Forest`. The 9 AD date, Varus, Arminius,
  the three legion numbers, the Kalkriese identification, and the Suetonius "Quintili Vare,
  legiones redde" line. Check whether the essay overstates the battle's linguistic
  consequences: the claim that it kept Latin out of Germania is a popular simplification.
- **C. Tacitus country** — `Lifeways of the Germanic Tribes`. Nearly everything here traces
  to Tacitus's *Germania*, a moralizing text written by someone who never went. Flag any
  claim that presents it as straight ethnography.
- **D. The Germanic verb** — `The Germanic Verb System: Simplification and Innovation`,
  `Losses from Proto-Indo-European`, `The Germanic Innovation: Weak Verbs`. Grimm's law,
  Verner's law and its relation to PIE accent, the collapse to a two-tense system, and the
  origin of the dental preterite, where the "*did* fused onto the stem" account is one
  hypothesis among several and is often repeated as settled fact.
- **E. Old High German** — `Old High German and the Continuing Evolution`,
  `Strong-Verb-Class Restructuring`. The High German consonant shift and its dating, the
  OHG period boundaries, the seven strong classes, Notker, and any claim about which
  dialects shifted what. Most `Ablaut` residue lands here, since the strong classes and the
  German alternations are its natural home, but the inventory assigns it row by row.
- **F. Tense-building** — `Development of the Perfect Tense`, `The Future Tense and Modal
  Verbs`, `Preterite-Present Verbs`. The *haben*/*sein* auxiliary split, the *werden*
  future's late arrival, the *oberdeutscher Präteritumschwund*, and the modals as
  preterite-presents.
- **G. Modern German** — `The Subjunctive and Modern German`, `The Verb System Today`.
  Konjunktiv I and II, the *würde* periphrasis, the decline of Konjunktiv I in speech, and
  Luther's role, which popular accounts routinely overstate.

Rules for every researcher:

- Read the whole essay for context, including the patched sections, then check **exactly the
  inventory rows you own**. Not the section, the rows. If you believe a claim in your
  sections is checkable and missing from the inventory, report it as an inventory gap rather
  than researching it: a gap is cheap to fill once and expensive to fill seven times.
- Do not research a claim owned by another cluster, even when your own claim leans on it.
  Cite the `depends-on` row and state what your verdict assumes. Two agents independently
  establishing the date of the High German consonant shift is the exact waste this structure
  exists to prevent.
- Budget searches by claim, not by agent: roughly one to three distinct searches per
  inventory row, more for a contested one, none at all for a row another cluster owns.
  Prefer peer-reviewed work and standard handbooks (Braune-Reiffenstein, Paul, Ringe's
  *From Proto-Indo-European to Proto-Germanic*, Fortson, Kluge/Seebold, the DWDS and Grimm
  dictionaries) over Wikipedia, and say what each source actually states.
- **Judge each claim as written, including its hedges.** A properly hedged claim about a
  contested question is not an error. An unhedged claim about a contested question is, and so
  is a hedge that misrepresents where the consensus sits. This rule matters more than raw
  coverage: a fact-checker with a search engine and no self-skepticism will cheerfully
  "correct" a careful hedge into a confident mistake.
- **The patched sections are settled.** Do not re-litigate them. If something there looks
  wrong, report it as a note rather than a finding, and let Phase 1's agent H judge it.
- Record blocked URLs (403, paywall, robots) and route around them. If a blocked page is
  decisive, use the Chrome MCP.
- **Return a verdict for every row you own**, `confirmed` ones included, keyed by row number.
  A row with no verdict is an unfinished job, not a passed one, and under the inventory that
  is now visible instead of silent.

### H. Internal consistency

An agent with **no web access and no cluster**, holding the whole essay at once, patched
sections included, and asking only one question: does anything here contradict anything else
here? Every other agent in this run reads a range, and a contradiction that lives *between*
two ranges is invisible to both of them.

In the Conjugar run this was the single category of error the fan-out structurally could not
find, and the one Josh caught himself: the opening promised the steppe was "the reason a
student has to memorize what *poder* does in the first person singular," while the
stem-changes section a hundred and twenty-six lines later opened by declaring that exact
alternation "not an irregularity at all" and used *puedo* as its headline example of the
thing you do *not* memorize. Two agents each read their own line closely enough to find real
errors there and neither could see it.

**This scope makes agent H more necessary, not less.** That contradiction lived exactly at the
seam between a shared section's promise and a language-specific section's delivery, and
Phase 0 manufactures a fresh seam of the same kind: five patched sections butted against
seven unpatched ones. If the patched opening promises something about what a German learner
has to memorize, the Germanic half has to deliver it. H is the only agent spanning both
halves, and it is the last thing to cut.

Have it check, at minimum: promises made in the opening against what the body delivers; the
same form, date, or sound law cited in two places with different values; a claim hedged in one
section and stated flatly in another; and the closing summary against the sections it
summarizes. Two extra jobs here that Conjugar did not have. This essay is the shortest of the
three and the most compressed, so a claim carried over from a longer original may have lost the
qualification that made it true. And the German localization is a second surface: check the
`de` text against the `en` for the same contradictions, since a translator resolving an
ambiguity one way can create a conflict that exists in only one language.

One consequence of the verbatim rule lands squarely in H's lap. A pasted sentence arrives in
Conjugar's voice and at Conjugar's length, sitting between sentences written for this essay,
so the patched sections can now hold a restatement: the pasted sentence makes a point the next
Konjugieren sentence already made, more briefly. That is not a factual error and no researcher
is looking for it. H should flag redundancy and register breaks at the patch sites as notes for
Josh, without proposing to reword the pasted text, since rewording it is the thing the verbatim
rule exists to prevent.

## Phase 2 — adversarial verification

Pipeline each cluster's findings into an independent skeptic instructed to **refute** them:
research each proposed correction independently rather than re-reading the first agent's
sources, and decide upheld / partly / refuted. Default to skepticism.

**Skeptics research findings, not ranges.** A skeptic's independent research on a proposed
correction is duplication of the valuable kind, and it is what killed 104 of 188 proposals in
the Conjugar run. A skeptic re-reading its cluster's whole range hunting for missed claims is
duplication of the wasteful kind, and it doubles the fan-out's cost. The inventory replaces
that hunt with a cheap check: confirm every row the cluster owns came back with a verdict,
and challenge any row marked `confirmed` on reasoning that looks thin. Do not open new
research on rows the researcher already settled.

Grade every survivor:

- **factual-error** — a reader would be actively misinformed
- **needs-hedging** — the question is contested and the essay states it flatly
- **nitpick** — a specialist's quibble that misleads nobody

### What Phase 1 handed you

31 findings out of 111 rows: 7 factual errors, 7 needing a hedge, 17 nitpicks, 80 confirmed. No
row came back unresolved and no agent reported on a row it did not own, so the partition held
and coverage needs verifying rather than reconstructing.

Findings per cluster, which is what sizes the skeptic fleet: A 3, B 2, C 6, D 4, E 8, F 3, G 3.
The distribution is uneven enough that a per-cluster fan-out has a straggler in E.

**Attack these four first.** They are the ones most likely to fall, and Phase 1's own authors
flagged three of them:

1. **B12** rests on Wikipedia. Its author says so and volunteers the downgrade to nitpick
   unprompted. The underlying fact is elementary, so the exposure is the grading, not the fact.
2. **R6** argues that `*n̥-péh₂-tōr` is not a reconstruction the handbooks give of anything.
   That is an argument from absence, resting on Wiktionary, at medium confidence, and it is
   exactly the shape of finding the Conjugar skeptic pass killed most often.
3. **F8** concedes the essay is right about the onset and faults it for stopping there. A
   finding about an omission has to show the omission misleads, not merely that more could be
   said.
4. **C9 and C13** each narrow an absolute, "no stone monuments" and "groves rather than
   temples". Each can be defended by reading the essay's word more charitably than its author
   did, and a skeptic should try.

### Do not hand a skeptic the whole Phase 1 document

`docs/verb_history_phase1.md` is 368 KB, roughly 92,000 tokens. Seven agents each reading it is
about 644,000 input tokens spent before a single search runs, which is more than half of what
the entire Phase 1 fan-out cost. Slice it and splice the slice inline into the prompt. All seven
findings blocks together come to 117 KB, about 29,000 tokens, so slicing is a 22-fold saving on
that axis alone.

Each cluster's findings are the contiguous block under its `### Cluster X` heading in the
`## Findings` section. The same heading recurs later under `## Confirmed rows`, so stop at the
next `###` rather than at the next occurrence of the cluster name:

```bash
awk -v h="### Cluster E: Old High German" \
    '$0==h{f=1;print;next} f&&/^### /{exit} f' docs/verb_history_phase1.md
```

A skeptic needs the essay, its own findings block, and the sources under attack. It does not
need `verb_history_phase0.md`, the style doc, or this file's Phase 0 material: those were for
agents writing replacement prose, and a skeptic writes none.

### Two decompositions, and what each costs

Phase 1's measured cost was 1,122,761 subagent tokens, 239 tool calls, 107 web searches, about
21 minutes wall clock across 8 agents.

- **Per cluster, 7 skeptics.** What the paragraph above describes. Roughly 600 to 750 thousand
  tokens, 55 to 65 percent of Phase 1. Work volume falls because 31 findings is 28 percent of
  111 rows; per-item cost rises because refuting takes more searching than confirming.
- **Per finding, 31 skeptics**, or 31 times three under the perspective-diverse verify pattern.
  Plausibly 1.2 to 2 million tokens, so *more* than Phase 1. This is the more thorough
  structure and it is what the Conjugar run's kill rate came from.

Neither is wrong. Pick deliberately and say which was picked, because a reader of the finished
corrections document cannot tell from the output which fleet produced it.

### Agent H's 19 items are not skeptic-bound

They are internal-consistency observations, they needed no research to produce, and research
will not settle them. Most are a choice about which of two sentences gives way, which is Josh's
call and not a fact question. Routing them to a refutation fleet wastes the fleet and misframes
the items. Carry them into the deliverable as their own section.

Three of them do belong somewhere else. H11 and H13 turn on `$…$` span values, which **Phase 3**
owns because it checks spans against the app's own conjugation output. H14 is the same kind of
question in prose rather than markup, so it is Josh's.

## Phase 3 — the app-internal agent

One agent does no web research. It verifies the essay against this app's own code, across
**both** the patched and unpatched halves, since Phase 0 hand-edits markup:

- Every `‡…‡` link is a well-formed, live URL.
- Every `$…$` span reddens the letters the app would actually redden. Uppercase inside `$…$`
  means irregular (`StringExtensions.swift:215`, `isUpper = char.isUppercase`), so each span
  should be the difference between the real form and its regular composition. This essay has
  **27** such spans, 17 distinct, byte-identical between the two language files. An earlier draft
  of this file said "more than fifty", which was wrong and was believed until someone counted.
  Sixteen are German and the app can arbitrate them; eleven are English and must be judged by
  hand against the same rule. Check the German ones against the app's own conjugation output, in a
  temporary Swift Testing test that you delete afterward.
- Markers balance and do not nest, since here that is a crash rather than a render bug.
- Any claim the essay makes about Konjugieren itself matches what the app does.

## Phase 4 — the deliverable

Two artifacts, and they are different in kind:

1. **`docs/verb_history.txt`, patched.** The shared sections carry Conjugar's corrections,
   applied. Josh reviews this as a diff. Nothing syncs back to `Localizable.xcstrings` until
   he says so.
2. **`docs/history_corrections.md`.** It has **four** inputs, not two, and a fresh session that
   merges only the first will ship an incomplete document:

   1. **`docs/verb_history_phase2.md`**, the 27 surviving findings with English replacement prose.
      Note that 15 of the 27 carry prose written by the second opinion rather than by Phase 1, so
      take the prose from the disposition sections rather than from `verb_history_phase1.md`.
   2. **`docs/verb_history_phase2.md` again, for agent H's 16 non-routed items.** They are not
      findings and must not be presented as though they were. Most are a choice about which of two
      sentences gives way, which is Josh's call. H14 is his too. H11 and H13 went to Phase 3 and
      come back answered.
   3. **`docs/verb_history_phase3.md`**, nine span corrections plus the H11 and H13 adjudications.
      Each lands in **both** language files, since the spans are byte-identical.
   4. **The four thin confirmed rows** from the coverage audit, G16, D1, C8 and C7. These are
      reasoning defects in rows that passed, not proposed corrections, and they belong in their
      own section so nobody reads them as findings.

   Phase 3 also produced **findings against the app rather than the essay**. The chief one, that
   `sollen` was `fa="w"` with no ablaut group and conjugated as an ordinary weak verb, was **fixed
   on 2026-07-29** and needs no entry: sollen now has its own ablaut group, `modalVerbs()` covers
   all six preterite-presents rather than three, and the suite passes at 211 tests. The remaining
   three are B, `auslesen` glossed in a sense the corpus does not ship, C, the passive being the
   one item in the essay's closing list the app does not model, and D, a terminology note. None is
   an essay error. Give them a short section pointing at `verb_history_phase3.md` rather than
   filing them among the findings.

   Structure each finding: the inventory row number, the quoted claim, its line, the verdict and
   severity, what is actually true, the sources, and **concrete replacement prose in the essay's
   voice**: same approximate length, markup preserved, and no em dashes, per
   [`docs/english_writing_style.md`](../docs/english_writing_style.md).

   **On parentheses, correcting an earlier draft of this file.** It said "no parenthetical
   expressions", and agent H flagged the consequence: this essay is heavily parenthetical by
   design, since its glosses are parentheses, as in `~haben~ (to have)` and
   `singen, $sAng$, $gesUngen$ (sing, $sAng$, $sUng$)`. A corrections author obeying that rule
   literally would produce prose that does not match the voice around it and would strip glosses
   the essay needs. The rule that was meant: **do not add new parenthetical asides**, and keep the
   glosses that are already there. Phase 1 and Phase 2 both wrote to the corrected rule.

   Close with a coverage table reconciling the document against `docs/verb_history_claims.md`, so
   every row is either a finding or an explicit `confirmed`. The numbers are already computed and
   audited in `verb_history_phase2_reports/coverage_audit.md`; use them rather than recounting.
   The inventory's own reconciliation table at `docs/verb_history_claims.md` lines 339 to 348 is
   still blank and those numbers belong in it.

Because this essay is translated, every patch and every replacement must be given **in both
English and German**, with the same hedge strength in each. Check the German separately.

**The German prose does not exist yet, and that is deliberate rather than an oversight.** Phase 1
deferred it because roughly half the findings were expected to fall, and four did. Writing it is
the single largest remaining task in this run. Every survivor cites its German counterpart line, so
Phase 4 knows what it is translating against. Agent H's German-surface section in
`verb_history_phase1.md` lists seven places where the existing translation already changes hedge
strength or reads circularly; two of them are in patched text, where the hedge survived the port
from Conjugar and then did not survive the translation. Read that section before writing any
German, because it is a list of the exact mistakes this step is prone to.

**Do not edit the German-specific half of the essay.** For that half the deliverable is the
corrections document, and Josh decides what changes.

## This app's markup

From `Konjugieren/Utils/StringExtensions.swift`:

| Marker | Meaning |
|---|---|
| `` `…` `` | subheading |
| `~…~` | bold / emphasis |
| `$…$` | conjugation; uppercase letters inside are irregular, shown red |
| `‡…‡` | link |
| `^…^` | emoji |

## Lessons from the Conjugar run

- **Raise the web-search cap before any fan-out phase starts, including Phase 2.** The cap is
  per session and does **not** reset with the five-hour usage window, so researchers run dry
  silently rather than erroring. It is **not** in `settings.json` or any shell profile on this
  machine, so a session that was not launched with it does not have it, and there is no way to
  add it partway through. Start the session with:

  ```
  CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION=600 claude
  ```

  Phase 1 spent 107 of the 600 across eight agents and 111 rows, so 600 is generous rather than
  tight. The number is not the point; a silent failure mode with no error message is.

- Give each subagent absolute paths **inline in its prompt**. Passing them through workflow
  `args` failed there: the values arrived as the literal string `undefined`, and the agents
  only recovered because they were told to report broken instructions rather than guess.
- Phase 0 depends on Conjugar's corrections file. Do not start before you can read it.
- Expect the skeptic pass to knock down a meaningful share of first-pass findings. That is
  the pass working, not a waste. In Conjugar's run it dismissed **104 of 188 proposals**, and
  one of the kills was a finding already written into the document as a factual error.
- Decomposition is the highest-leverage decision and it has a cost. Cutting by claim-domain is
  what let a specialist overturn the standard account of Spanish's velar verbs, and it is also
  why nobody saw the essay contradict itself across two sections. Agent **H** above exists to
  pay that cost back; do not drop it as redundant.
- **The fan-out is where the money goes.** Conjugar's took most of three five-hour windows.
  Phase 0.5 exists because of that, and Phase 1's rules are written to hold the line: one
  owner per claim, no cross-cluster re-research, searches budgeted per row. Check `/status`
  before starting Phase 1, and treat any agent reporting on a row it does not own as a signal
  the inventory has a boundary problem worth fixing before the rest of the fleet hits it.

## Revision, 2026-07-28

The first draft of this file fact-checked all twelve claim-domains, shared sections included,
and carried a dedicated agent to diff the shared prose against Conjugar's for claims that
mutated during the port. Josh rescoped it: the shared sections get Conjugar's corrections
applied rather than re-researched.

Dropped: researchers **A** (cosmos and dispersal), **B** (the steppe), **C** (PIE morphology
and ablaut), and **K** (port fidelity), along with their skeptics. K's job disappears rather
than goes unfilled, because patching corrects a mutated claim without requiring anyone to
detect the mutation. The remaining clusters were relettered **A** through **G**; internal
consistency, formerly **L**, is now **H**.

An intermediate proposal to replace the shared sections wholesale with Conjugar's corrected
prose was rejected, though not for the reason first recorded here. The original argument was
that Konjugieren's version is roughly half the length, so replacement would have forced a
re-compression, and re-compression is what drops the qualification making a claim true. The
verbatim rule below retires that argument, since under it nothing is re-compressed anywhere.

What still rules wholesale replacement out is **scope**. It would import Conjugar's entire
opening: sentences Konjugieren already words correctly, Spanish framing with no German
counterpart, and forward references pointing at sections this essay does not have. Patching
touches only the sentences Conjugar's corrections actually name. The unit of reuse is the
corrected sentence, not the corrected section, and that is the whole distinction between the
two proposals.

Tightened: the patch step originally said to adapt Conjugar's corrections to Konjugieren's
shorter phrasing. Josh cut that, and the cut is what resolved the tension above. Adapting is a
per-sentence re-compression that drops hedges exactly the way a wholesale one would, so the
length objection could not survive as a reason to reject replacement while the patch step was
quietly performing the same operation one sentence at a time. Verbatim is now the default, any
reworded sentence is flagged for review rather than absorbed into the diff, and the shared
sections may grow slightly as a result. That is the intended trade.

Added: **Phase 0.5, the claim inventory**, after Josh reported the Conjugar fan-out cost most
of three five-hour windows. Section ranges overlap at their edges, so the same fact gets
researched by two agents who each believe it is theirs. Assigning numbered claims instead of
ranges makes the partition exhaustive and disjoint, lets skeptics verify coverage by checking
for a missing row number rather than re-reading a range, and costs one agent that is already
holding the text open for the patch work.

## Revision, 2026-07-28, after Phase 1

Phase 1 ran as written and the structure held: 111 rows, 111 verdicts, no row unresolved, no
agent reporting on a row it did not own. The three traps the inventory named in advance, D6's
optative, F8's *werden* dating and G8's inverted aspect claim, all fired, which is an argument
for writing traps down rather than hoping a researcher rediscovers them.

What this revision adds to Phase 2 is what Phase 1 learned that the earlier draft could not have
known. Three things.

**The Phase 1 document is 368 KB and must be sliced.** The earlier draft said skeptics research
findings rather than ranges, which is right, but said nothing about how the findings reach them.
Handing seven agents the whole document would spend more on reading than the entire Phase 1
fan-out cost. The `awk` recipe in Phase 2 above is tested against the file's actual headings,
including the trap that each `### Cluster X` heading appears twice, once under Findings and once
under Confirmed rows.

**The decomposition fork is now explicit and costed.** The earlier draft said "pipeline each
cluster's findings into an independent skeptic", which reads as seven agents, while the quality
patterns argue for one skeptic per finding. Both are defensible and they differ by roughly
threefold in cost, so the choice deserved to be a decision rather than an accident of phrasing.

**Agent H's output does not fit the Phase 2 pipeline.** The earlier draft placed H inside Phase 1
and then described Phase 2 purely in terms of cluster findings, leaving H's items with nowhere to
go. They need no research, research cannot settle them, and most are a choice about which of two
sentences gives way. They travel to the deliverable directly, with two routed to Phase 3 because
they turn on `$…$` span values.

One correction of fact, recorded because a future session will otherwise trust the number. The
inventory's line numbers were wrong for nine shared-half rows, non-uniformly, and Phase 0's patch
table was wrong for five. Agent H caught it, and the audit that settles it is to match each row's
quoted fragment against its cited line. The inventory's own How-to-read section had already asked,
in writing, to locate a row by its quoted text if the number looked wrong. Nobody did until an
agent with no cluster went looking, which is the same lesson `scripts/check_docs.py` exists to
teach: prose asking to be re-read does not get re-read.

## Revision, 2026-07-29, after Phase 2

Phase 2 ran per finding rather than per cluster, which was the more expensive of the two options
this file costed. 51 agents, 2,376,954 subagent tokens, 592 tool calls, 303 of the 600 web searches,
about 22 minutes of wall clock. That is roughly twice Phase 1 and inside the 1.2 to 2 million the
per-finding estimate predicted. Results in [`docs/verb_history_phase2.md`](../docs/verb_history_phase2.md).

Four things a future run should take from it.

**A refutation pass is not self-validating, and neither is a pass that audits it.** The skeptics
killed 15 of 31. A second opinion, firing on every kill, overturned 11 of the 15. Nineteen second
opinions ran, fourteen changed the disposition, and **all fourteen moved toward a stronger finding
with not one moving toward a weaker one**. The direction was designed in: "attack the skeptic"
applied to a kill means "restore it". So the pass measured robustness, not truth, and how many
findings survive depends substantially on which agent goes last. This retroactively weakens the
104-of-188 figure that this file cites as evidence the skeptic pass works: those kills were never
audited, and when Phase 2 audited its own, most did not survive. Do not drop the second pass, since
without it the 11 restorations would have shipped as kills. Do consider making the third agent a
**neutral adjudicator** told to decide rather than to attack, and either way **measure the direction
of movement**, because a pass that only ever pushes one way is visible in one line of arithmetic.

**Ask the skeptic whether the proposed fix is right, not only whether the claim is wrong.** These
are different questions and they had different answers often enough to matter: **15 of the 27
surviving findings ship replacement prose that neither Phase 1 nor its own skeptic wrote.** C13 is
the cautionary case. Phase 1's replacement would have introduced an anachronism into a paragraph
whose governing sentence dates it to 9 AD, and the finding was killed anyway, so the bad prose died
with it by luck rather than by anyone checking.

**Name a structured-output field for the thing it decides, not for the agent's own conclusion.** The
second opinion's `finalVerdict` enum reads two ways: "the finding is upheld" and "the skeptic's kill
is upheld". One agent meant the second, which put a wrong number in the workflow's own progress log,
11 overturned kills reported as 12. A companion boolean caught it. Prefer an unambiguous name.

**Slice the prior phase's document; the arithmetic is decisive.** Each skeptic got a 3.7 KB finding
file rather than the 368 KB Phase 1 document. Handing 31 agents the whole thing would have spent
about 2.9 million input tokens before a single search ran, which is more than the entire Phase 2
fan-out cost including all the research.

## Revision, 2026-07-29, after Phase 3

Phase 3 ran as one agent with no web access: 187,212 subagent tokens, 48 tool calls, about 15
minutes. It is by far the cheapest phase and the only one that found a bug in the app.
Results in [`docs/verb_history_phase3.md`](../docs/verb_history_phase3.md).

**Nine of the 27 spans were wrong**, seven caught by the app and two by hand. `$nahm$` to `$nAhm$`,
`$genOMmen$` to `$genOmmen$`, `$kAnN$` to `$kAnn$` three times, `$lIest$` to `$lIEst$` twice, and
the `$mAde$` / `$saId$` pair removed with the example list rewritten.

**Tell the agent that the app is the arbiter for German forms, and then tell it that finding the
app wrong is the more interesting result rather than the less.** That one sentence is what produced
the run's best finding. `sollen` is `fa="w"` with no ablaut group in `Verbs.xml`, unlike the other
five modals, so the app emits *ich solle* and *er sollt* rather than the preterite-present *ich
soll*. The essay's claim at line 171 is correct and the corpus contradicts it. Without that
instruction the agent would have "corrected" the essay to match a buggy corpus and the bug would
still be shipping. It survived because `modalVerbs()` covers only mögen, wissen and wollen, so
sollen, können, müssen and dürfen have no test anywhere.

**"More than fifty spans" was wrong for as long as this file has existed.** There are 27. The
figure was written into the prompt, repeated back in a summary, and only then counted. Cached
numbers rot in prompts exactly as they rot in documentation, and the prompt is the one place
nobody thinks to run `scripts/check_docs.py` over.

**Have the agent prove its own validators fire.** It confirmed the per-block markup rule by
injecting two stray tildes that balance across the whole essay but not within their blocks, and
watched the script report both. A validator that has never failed is a validator nobody has tested,
and here bad markup is a `fatalError` on the Info screen rather than a render bug.

**Read the test count, not the exit status.** `CLAUDE.md` documents three ways a filtered run
reports success having executed nothing. Phase 3 reported its counts unprompted because the brief
asked for them: 8 tests in the temporary suite with 5 assertion failures across 4 of them, 18 in
`test_sync_verb_history.py`, 2 `--check` runs, and 1 more after deletion to confirm the target
still compiled.

## Revision, 2026-07-29, after Phase 4

Phase 4 ran as written: one context, no fan-out, no web research, about 25 minutes. It read the two
extracts, `verb_history_phase2.md`, `verb_history_phase3.md`, the coverage audit, and agent H's
section sliced out of the 368 KB Phase 1 document with `sed -n '1840,2131p'`. Deliverable:
[`docs/history_corrections.md`](../docs/history_corrections.md). The inventory's reconciliation table
at `docs/verb_history_claims.md` is filled.

Five things a future run should take from it.

**The four inputs are not four sections. They collide, and reconciling them is the work.** The
runbook framed Phase 4 as a merge, which undersells it. Six corrections land on a line another
correction also touches, and two inputs disagree outright. **D12's second opinion proposed
`$maDe$`** while **Phase 3 recommended deleting the span**, and Phase 3 owns span values, so the
second opinion's fix is superseded. **Agent H's H2 says the closing line contradicts the opening**
while **G14, the researched finding on the identical sentence, was killed twice**, so H2 should not
be actioned. A session that merged the inputs section by section would have shipped both conflicts
unnoticed, since neither is visible from inside one document.

**Five of agent H's sixteen items were already discharged by a surviving finding, and that is only
visible from Phase 4's position.** H1 by D7, H4 by R1, H5 by G8, H15 by R2c. Each was written by an
agent that could not see the replacement prose, because Phase 1's H ran before the findings were
adjudicated and Phase 2 never routed them anywhere. Presenting all sixteen as open decisions would
have handed Josh five choices that no longer exist. Check this explicitly in any future run: the
internal-consistency agent and the corrections are looking at the same sentences from different
sides.

**Write the German against the German line, not against the English replacement.** Every survivor
cites its German counterpart line for exactly this reason, and it matters most where the two
languages are not parallel. C10 survives **in the German only**: the English concessive asserts no
date, and the German pluperfect "entwickelt hatten" places the runic alphabet before Teutoburg. H3
is the mirror image, an English-only contradiction that the translator had already resolved
correctly. A Phase 4 that translated the English replacements would have missed the first and
"fixed" the second in the wrong direction.

**Check the marker arithmetic mechanically, because the file headers assert it.** Applying
everything takes the essay from 59 `~…~` spans to 68, from 27 `$…$` spans to 25, and from 20
asterisks to 25, all of which the two headers state as facts and nothing automated verifies:
`check_docs.py` does not read these files. Counting by hand is the failure mode this run has already
demonstrated twice, with the stale 58 tilde spans and the "more than fifty" spans that were 27. Both
figures in the corrections document's bookkeeping table were computed by diffing the replacement
strings against the originals in Python, and the parity of all 29 English/German pairs was checked
the same way: equal `~…~` counts, byte-identical `$…$` values.

**A blank table in a cache file stays blank until someone is told to fill it.** The inventory's
reconciliation table asked to be filled "at the end of Phase 2", Phase 2 recorded that it was still
blank, and it was still blank when Phase 4 started. It is the same lesson `scripts/check_docs.py`
exists to teach, in the one form the script cannot catch: prose asking to be re-read does not get
re-read, and neither does an empty table asking to be filled.
