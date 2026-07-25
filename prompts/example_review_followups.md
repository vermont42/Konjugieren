# Open items left by the example-sentence review — a plan

**Audience: a future session picking up loose ends.** The adversarial review of 2026-07-25
(`prompts/example_review_run.md`) closed the example-sentence gap and, as a byproduct, audited 1,097
shipping glosses. It left four things undone. This document scopes each one, gives the evidence, and
says what has to be *decided* before any code is written. Written 2026-07-25.

They are independent. Take them in any order, or take only item 1 — it is the only one that is
plausibly worth a whole session on its own.

Companion files: [`example_review_run.md`](example_review_run.md) (the review orchestrator),
[`example_review.md`](example_review.md) (the reviewer brief), [`docs/blog_notes.md`](../docs/blog_notes.md)
entries of 2026-07-25 (what actually happened, in order).

## What this plan does NOT cover

**Dual paradigms.** Nine of the fourteen remaining `check_forms.py` misses are verbs where the author
wrote a correct German form the app's single shipped paradigm does not generate — *absaugen* wanting
`saugte` where the app has `sog`. That work is already owned: `docs/roadmap.md` § "Known gaps that are
nobody's step yet" records the decision (2026-07-25, in favor of extending the model to carry two
parallel paradigms), sizes it at 111 of 3,572 shipping verbs, and says it wants its own prompt doc on
the `prompts/dual_auxiliary.md` model. Do not re-plan it here.

One note that belongs with that work rather than in it: **`krauchen` is not a defect and should not be
"fixed" on inspection.** The app gives it *krauche/krauchst* in the Präsens but *kroch/gekrochen* in
the Präteritum and participle, which reads as a chimera. It is faithful: kaikki attests krauchen as
strong, class 2, with exactly those forms. The sentence's *krauchte* is the weak regional variant. It
resolves with the other eight when a second paradigm exists, and needs nothing before then.

---

## Item 1 — Audit the glosses of the 2,475 verbs the review never saw

**This is the highest-value item on the list, and the only one with a real defect population behind
it.** Everything else here is a handful of verbs.

### The evidence

The review examined 1,097 verbs and found **55 defective glosses — 5.0%**. Those defects are now
fixed (`verbdata/authored/gloss-corrections.json`). But the review only looked at the 1,097 verbs that
happened to *lack example sentences*. Nothing about that selection correlates with gloss quality: they
were selected by which verbs the corpus-mining pipeline could not serve, not by anything about their
dictionary entries. **The other 2,475 shipping verbs have never had their glosses read by anything.**

At the observed 5.0% rate, expect **roughly 124 wrong glosses currently shipping**. That is a user-
visible defect: the gloss is the English meaning shown beside the verb, and a wrong one teaches a
wrong word. `fernschauen` shipped as "look into the distance" when it means *watch TV*; `niederführen`
shipped as "run someone over" when it means *lead down*.

### The "shipped glosses[0]" filter: real, and still not worth using

The obvious cheap sweep is to audit only verbs where kaikki listed multiple senses and the app shipped
the first, on the theory that the importer took entry order for frequency. Measured against the
review's findings, using `build_gloss_shards.py`'s own `match_sense`:

| | |
|---|---|
| Reviewed verbs that were first-sense picks | 377 |
| ... found defective | **40 (11% precision)** |
| Gloss defects that were *not* first-sense picks | **15 of 55 (27% missed)** |

**That is a real filter and this plan says so plainly**, because an earlier draft of this section
overstated the case against it by measuring with strict string equality, which put the miss rate at
56%. It is not 56%. Applied to the audit pool the filter cuts 2,432 verbs to 993 and would still find
roughly seven of every eight defects.

Sweep everything anyway, for two reasons that are about cost and calibration rather than recall. The
saving is 59% of a **cheap, one-time** pass over data that already ships, and the price is ~13 wrong
glosses left in the app with nothing remaining that would ever look at them again. And 11% precision
means nine clean verbs per real defect, which is a poor diet for a reviewer that calibrates its
threshold on what it is shown.

**If a future run is under real window pressure, order rather than filter:** shard the first-sense
picks first and the rest after. That banks the same 88% early and leaves a resumable tail, which is
strictly better than dropping the tail. `build_gloss_shards.py` emits `sense_index` and `sense_match`
on every entry, so the ordering is a sort, not a rebuild.

The defects the filter misses are the ones no mechanical rule can catch: raw import artifacts
(`abschmecken` truncated mid-clause at a comma; `entmieten` shipping only the parenthetical usage label
"of a landlord"; `durchspielen` with an unbalanced `)`; `hinwegschauen` shipping the cross-reference
"synonym of hinwegsehen"; `kaltmachen` glossed with Jamaican-English "duppy"), and glosses simply wrong
about the language regardless of what kaikki listed.

### Why this is cheaper than the sentence review was

A gloss review reads a word, a gloss, and a candidate list. It does not read a sentence, judge whether
the sentence demonstrates the gloss, or write a replacement sentence. The sentence review measured
**1.8 window points per 25-verb shard**; budget well under that per verb. The shards are already
built: 49 shards of 50 verbs. Measure wave 1 and re-plan from it, as every run in this pipeline has.

### Steps

**Both artifacts already exist — written 2026-07-25, unrun.** Steps 1 and 2 are done; start at 3.

1. ~~Write the brief.~~ [`prompts/gloss_review.md`](gloss_review.md). Gloss-only, `bad_gloss` as the
   sole finding type (`wrong_sense` is meaningless without a sentence to be wrong about), severity
   carrying the weight, `fix_gloss` **required** because a finding without a replacement cannot be
   applied. It keeps `example_review.md`'s house-style section, and adds a "what is NOT a finding"
   list aimed at the specific over-flagging risk here: a gloss terser than the dictionary is the house
   style, not a defect.
2. ~~Build the shards.~~ `python3 verbdata/authored/build_gloss_shards.py` — **49 shards of 50 verbs,
   2,432 verbs**, in `verbdata/gloss-review/shards/`. Not 2,475: 43 verbs carry two `<reading>`
   elements, where "the shipped gloss" is not a single value and `apply_gloss_corrections.py` refuses
   to write one, so they are excluded to `verbdata/gloss-review/skipped-multi-reading.txt` rather than
   dropped in silence. Audit those by hand if the sweep's defect rate warrants it.
3. **Run waves.** Copy `verbdata/review/run_review_wave.sh` to `verbdata/gloss-review/`, changing the
   three paths (`prompts/gloss_review.md`, `gloss_NNN.in.json`, `gloss_NNN.out.json`) and narrowing
   `VALID` to `{'bad_gloss'}`. Nothing else in it is specific to sentences. Read `/usage` after each
   wave and stop past 75%, as every run in this pipeline has.
4. **Apply** via `verbdata/authored/apply_gloss_corrections.py`, which already asserts each `old`
   gloss still matches before writing and refuses any verb carrying two `<reading>` elements rather
   than guessing which sense to rewrite. Add entries to a new corrections file rather than reusing
   `gloss-corrections.json`, so the two runs stay separable in the record.
5. **Verify** with `python3 scripts/check_docs.py` and the test suite. Glosses are shipping data in
   `Konjugieren/Models/Verbs.xml`; no test asserts a specific gloss string today, which is worth
   re-checking rather than assuming.

### The cross-assignment question

The sentence review cross-assigned shards so no model reviewed its own work. **That reasoning does not
transfer**: no model authored these glosses — kaikki did, via `verbdata/build_candidates.py`. There is
no conflict of interest, so use whichever model you like, and use one for consistency.

---

## Item 2 — Teach `check_forms.py` to match a multi-token particle

**The smallest item here, and the only one where every party is already correct.**

`wiederaufleben` is doubly separable — *wieder* + *auf* + *leben*. The app handles it correctly,
synthesizing the split form as stem `lebte` with particle `wiederauf`. German strands those as two
separate tokens: *„lebte das alte Handwerk langsam **wieder auf**"*. `check_forms.py` matches a split
form by scanning for a later standalone token equal to the particle string, and no single token equals
`wiederauf`, so the gate reports a miss on a sentence that is right, for a verb the app conjugates
correctly.

**Fix:** where the matcher currently tests one token against the particle, also accept the particle
being satisfied by consecutive tokens whose concatenation equals it. Guard it — only span tokens that
are themselves particles, or the rule will start matching accidental adjacency.

**Verify:** the gate should go from 14 misses to 13, with `wiederaufleben` the only one that moves.
Any other change in the miss list means the relaxation is too loose. This is the whole test.

**How many verbs are affected** is worth measuring before writing code: count lemmas in `Verbs.xml`
whose marked `in` attribute carries two `+` particles. If `wiederaufleben` is the only one, consider
whether a one-verb fix to a harness is worth it at all — the honest answer may be to leave the miss and
annotate it, and this plan does not presume otherwise.

---

## Item 3 — Decide what the app owes clipped colloquial imperatives

**A decision, not a task.** Four of the fourteen misses are the same phenomenon:

- `daherreden` — *„**Red** nicht so dummes Zeug daher"*
- `danebenhalten` — *„**Halt** das Muster mal daneben"*
- `runterhalten` — *„**Halt** den Ast kurz runter"*
- `warmhalten` — *„**Halt** bitte das Essen warm"*

The app generates `rede` and `halte`; standard spoken German also clips them to `red` and `halt`. The
reviewer brief explicitly lists these as **not** findings, so the sentences were deliberately left
alone — this is a question about the *app*, not about the sentences.

Three defensible answers, and this plan does not pick one:

1. **Conjugator generates both**, and `Quiz.acceptableAnswers` (already a `Set`) accepts either. Most
   correct, most work, and it interacts with the dual-paradigm decision — both are "one meaning, two
   surface forms", so doing them together may be cheaper than doing either alone.
2. **The gate exempts them.** Cheapest. `check_forms.py` accepts a clipped imperative as a match for
   the `-e` form. Nothing user-visible changes; the app still teaches only `halte`.
3. **Leave it.** The app teaches the standard written form, which for a conjugation teaching app is a
   defensible editorial line, and the four sentences are natural German that a learner benefits from
   seeing.

**Josh decides.** If the answer is 1, fold it into the dual-paradigm prompt doc rather than writing a
second one. Note that the imperative is one of the conjugationgroups the classify-and-verify pipeline
covers, so option 1 is checkable by the oracle in a way the dual-auxiliary work was not.

---

## Item 4 — Decide whether `source` should name the reviser

**Smallest, and purely editorial.** The 1,097 merged sentences carry `source: "Opus 4.8"` or
`"Opus 5"`, stamped from `verbdata/authored/provenance.json` — the model that *authored* the sentence,
following the bundle's existing convention (it already held 25 `Opus 4.8` and 11 `Opus 4.6` entries).

But **121 of those sentences were revised during review by the other model**, and 75 have wholly
replaced German. The current attribution names the author of a sentence that, in those 75 cases, no
longer exists. The bundle has no compound-source format, and inventing one mid-merge would have been
worse than the imprecision, so the correction record lives in `verbdata/authored/corrections.json`
instead.

If the attribution should read differently, it is a one-line change to the label map plus a re-merge:
the reviser is derivable per verb, because shards were model-homogeneous and cross-assigned, so a
shard's reviewer is the opposite of its author. Note that a compound label such as
`"Opus 4.8, rev. Opus 5"` would be the first of its kind in a field otherwise holding real citations
(*Kafka — Der Proceß*, *Grundgesetz (1949)*), which is an argument for leaving it alone.

---

## Kickoff — paste one of these into a fresh session

````
Execute item 1 of prompts/example_review_followups.md: audit the glosses of the 2,432 shipping verbs
the example-sentence review never examined. Working directory: /Users/josh/Desktop/workspace/Konjugieren

The brief (prompts/gloss_review.md) and the shard builder (verbdata/authored/build_gloss_shards.py)
already exist and are unrun. Rebuild the shards, copy run_review_wave.sh per step 3, then run waves
reading /usage after each and stopping past 75%. Sweep all 49 shards - do NOT filter to first-sense
picks; the plan says why. Apply via apply_gloss_corrections.py into a NEW corrections file. Report
the defect count and rate to me.
````

````
Execute items 2 and 3 of prompts/example_review_followups.md. Working directory:
/Users/josh/Desktop/workspace/Konjugieren

First measure how many verbs carry two separable particles, then tell me whether the check_forms.py
multi-token particle fix is worth making before you make it. Item 3 is a decision for me, not a task —
present the three options with what each costs and wait.
````
