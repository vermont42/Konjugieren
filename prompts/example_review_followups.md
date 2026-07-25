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

### The trap: do not filter by "the app shipped glosses[0]"

The obvious cheap sweep is to flag every verb where kaikki listed multiple senses and the app shipped
the first one, on the theory that the importer took entry order for frequency. **Measured against the
review's findings, that filter is too weak to run on its own:**

| | |
|---|---|
| Reviewed verbs that were first-sense picks | 209 |
| ... found defective | **24 (11% precision)** |
| Gloss defects that were *not* first-sense picks | **31 of 55 (56% missed)** |

Eleven percent precision would send nine clean verbs to a reviewer for every real defect, and it would
still miss over half of them. The 31 it misses are the ones no mechanical rule can catch: raw import
artifacts (`abschmecken` truncated mid-clause at a comma; `entmieten` shipping only the parenthetical
usage label "of a landlord"; `durchspielen` with an unbalanced `)`; `hinwegschauen` shipping the
cross-reference "synonym of hinwegsehen"; `kaltmachen` glossed with Jamaican-English "duppy"), and
glosses that are simply wrong about the language regardless of what kaikki listed.

For reference, the pool sizes: 1,877 shipping verbs have more than one kaikki sense, 605 of those
shipped `glosses[0]`, and 420 of *those* were never reviewed.

**So sweep all 2,475, not a filtered subset.** Use the first-sense flag as a *hint in the shard*, not
as the selection criterion — tell the reviewer "the importer took sense 1 of N here", which is exactly
the signal that let the sentence review call 48 of its 55 findings mechanical rather than judgment.

### Why this is cheaper than the sentence review was

A gloss review reads a word, a gloss, and a candidate list. It does not read a sentence, judge whether
the sentence demonstrates the gloss, or write a replacement sentence. The sentence review measured
**1.8 window points per 25-verb shard**; budget well under that per verb, and use **50-verb shards** —
2,475 verbs is then ~50 shards. Measure wave 1 and re-plan from it, as every run in this pipeline has.

### Steps

1. **Extend the reviewer brief, or write a gloss-only sibling.** `prompts/example_review.md` now has a
   `fix_gloss` field and documents the app's gloss house style (bare lowercase verb phrase, no leading
   `to `, comma-separated synonyms, ~14 characters typical). A gloss-only brief should keep that
   section verbatim and drop everything about sentences. Keep `bad_gloss` as the only finding type;
   `wrong_sense` is meaningless without a sentence to be wrong about.
2. **Build shards** of `{verb, gloss, candidate_glosses, sense_index}` for the 2,475 verbs not in
   `verbdata/authored/provenance.json`, 50 per shard. Emit `candidate_glosses` always here, not only
   when there are several — for a gloss audit, "kaikki listed exactly one sense and we shipped it" is
   itself the finding-relevant fact.
3. **Run waves** with `verbdata/review/run_review_wave.sh` as the model; it is generic except for the
   paths and the eight valid finding types.
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
Execute item 1 of prompts/example_review_followups.md: audit the glosses of the 2,475 shipping verbs
the example-sentence review never examined. Working directory: /Users/josh/Desktop/workspace/Konjugieren

Sweep all 2,475 — do NOT filter to first-sense picks; the plan documents why that filter is too weak.
Build 50-verb shards, run waves reading /usage after each, stop past 75%, and apply via
apply_gloss_corrections.py into a NEW corrections file. Report the defect count and rate to me.
````

````
Execute items 2 and 3 of prompts/example_review_followups.md. Working directory:
/Users/josh/Desktop/workspace/Konjugieren

First measure how many verbs carry two separable particles, then tell me whether the check_forms.py
multi-token particle fix is worth making before you make it. Item 3 is a decision for me, not a task —
present the three options with what each costs and wait.
````
