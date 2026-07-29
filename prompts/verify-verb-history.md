# Fact-check "A History of the German Verb System"

**Status: Phase 0 and Phase 0.5 are done, 2026-07-28. Start at Phase 1.** Written 2026-07-27
from the Conjugar session that ran the same check on Conjugar's Spanish essay. Rescoped
2026-07-28 by Josh: see "Revision" at the bottom for what changed and why.

**Do not re-run Phase 0.** Its step 1 says to extract the essay from `Localizable.xcstrings`
into `docs/verb_history.txt`. That file now holds the *patched* text, and the catalog still
holds the unpatched text, so a second extraction silently discards all ten patches. What
Phase 0 produced, and what Phase 1 needs:

| File | |
|---|---|
| [`docs/verb_history.txt`](../docs/verb_history.txt) | English essay, patched. The line numbers everything else cites |
| [`docs/verb_history_de.txt`](../docs/verb_history_de.txt) | German translation, patched to match |
| [`docs/verb_history_claims.md`](../docs/verb_history_claims.md) | **The claim inventory. Phase 1 works from this, not from the section ranges below** |
| [`docs/verb_history_phase0.md`](../docs/verb_history_phase0.md) | What was patched, what diverged, the residue list, and the seams the patch created |
| [`scripts/sync_verb_history.py`](../scripts/sync_verb_history.py) | Validates an extract; `--check` writes nothing |

Nothing has been synced back to the catalog, which is Josh's call to make after he reviews
the extract diff.

**Run this with ultracode on.** It is a fan-out job: seven researchers, each followed by an
adversarial verifier, plus two agents that stand outside the fan-out. Say `ultracode` in
your opening message, or turn it on with `/effort`, then point Claude at this file.

**Phase 0 is not fan-out and it gates everything.** Do it serially, in one context, and do
not spawn a researcher until its claim inventory exists. The fan-out is what this run costs;
everything before it is what keeps that cost from being paid twice.

## Why this exists

Conjugar's `Info.verbHistoryText` ("A History of the Spanish Verb System") was fact-checked
claim by claim in July 2026. The findings are in
`/Users/josh/Desktop/workspace/Conjugar.mig/docs/history_corrections.md`, and the corrected
prose is in `/Users/josh/Desktop/workspace/Conjugar.mig/docs/verb_history.txt`. Both are
readable from this session; read them before doing anything else.

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

## Phase 3 — the app-internal agent

One agent does no web research. It verifies the essay against this app's own code, across
**both** the patched and unpatched halves, since Phase 0 hand-edits markup:

- Every `‡…‡` link is a well-formed, live URL.
- Every `$…$` span reddens the letters the app would actually redden. Uppercase inside `$…$`
  means irregular (`StringExtensions.swift:215`, `isUpper = char.isUppercase`), so each span
  should be the difference between the real form and its regular composition. This essay has
  more than fifty such spans. Check them against the app's own conjugation output, in a
  temporary Swift Testing test that you delete afterward.
- Markers balance and do not nest, since here that is a crash rather than a render bug.
- Any claim the essay makes about Konjugieren itself matches what the app does.

## Phase 4 — the deliverable

Two artifacts, and they are different in kind:

1. **`docs/verb_history.txt`, patched.** The shared sections carry Conjugar's corrections,
   applied. Josh reviews this as a diff. Nothing syncs back to `Localizable.xcstrings` until
   he says so.
2. **`docs/history_corrections.md`.** Findings from Phase 1 and 2 on the German-specific
   claims, structured per finding: the inventory row number, the quoted claim, its line, the
   verdict and severity, what is actually true, the sources, and **concrete replacement prose
   in the essay's voice**: same approximate length, markup preserved, no em-dashes and no
   parenthetical expressions, which is the house style Josh set when he commissioned these
   essays. Close with a coverage table reconciling the document against
   `docs/verb_history_claims.md`, so every row is either a finding or an explicit
   `confirmed`. Any row appearing in neither is the run's own bug, and it should be visible
   in the deliverable rather than discovered later.

Because this essay is translated, every patch and every replacement must be given **in both
English and German**, with the same hedge strength in each. Check the German separately.

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

- **Raise the web-search cap before Phase 1 starts.** Conjugar's handoff records that the cap
  is per session and does **not** reset with the five-hour usage window, so researchers run
  dry silently rather than erroring. Fourteen agents budgeting one to three searches across
  111 inventory rows will hit it. Start the fan-out session with:

  ```
  CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION=600 claude
  ```

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
