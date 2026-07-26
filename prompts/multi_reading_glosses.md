# Auditing the glosses of the multi-`<reading>` verbs — a plan

## Status

**Executed 2026-07-26.** 88 glosses reviewed, **6 defects, 6.8%**; all six accepted by the
`claude-opus-4-8` adjudication and confirmed against attested use. See the `docs/blog_notes.md` entry
of that date for what the plan did not anticipate. Three things, briefly:

1. **The pair defect was a *swap*, not a collision.** The plan predicted two glosses collapsing into
   the same English. `umgehen` instead had each reading carrying the *other's* meaning. Same
   invisibility to a one-gloss-at-a-time reviewer, and it made the reading-scoped splice load-bearing
   immediately rather than eventually: the corrections file asks to write a string onto reading 1 that
   is still sitting on reading 0.
2. **Two fields the plan did not list turned out to be load-bearing.** Separability is per *reading*
   and differs from the parent's on six of the 88 (`übersetzen` is inseparable "translate" against
   separable "ferry across" — two verbs distinguished by a stress German does not write). And
   `candidate_glosses` is per *lemma*, so "no listed sense supports this" means nothing on this
   population; `sense_match: "none"` covers 66 of 88. Both briefs had to say so, or the adjudicator
   would have rejected the lot on a signal that does not apply.
3. **Reverso is the wrong tool for half of these questions.** It pools all readings under one lemma,
   so it cannot settle a claim about which *paradigm* carries a sense — `zurückziehen`'s free examples
   are all reflexive. DWDS publishes per-sense paradigms and settled both `zurückziehen` and
   `überkochen`. The `verweben` lesson (prefer use to dictionary listings) still holds; the refinement
   is that a corpus dictionary answers a question a bilingual concordance cannot.

Original plan follows.

**Audience: a future session picking up the one population the gloss sweep never looked at.** The
sweep of 2026-07-25/26 audited 2,432 shipping verbs and corrected 225 glosses. It excluded every verb
carrying two `<reading>` elements. This document says what they are, why they were excluded, why the
reason is smaller than it first appeared, and what to do. Written 2026-07-26.

Companion files: [`gloss_review.md`](gloss_review.md) (the reviewer brief, amended mid-sweep),
[`gloss_adjudication.md`](gloss_adjudication.md) (the cross-model second opinion),
[`example_review_followups.md`](example_review_followups.md) (the plan the sweep executed), and
[`docs/blog_notes.md`](../docs/blog_notes.md) entries of 2026-07-25 and 2026-07-26, which are the
current truth where older docs conflict.

## What these verbs are, and what they are not

**44 verbs carry exactly two `<reading>` elements — 88 glosses.** This is the **dual-auxiliary**
case, and it is already modelled. On *abbrechen*:

```xml
<reading tn="break off, cancel"            fa="s" ag="sprechen"        />   transitive, haben
<reading tn="break off, snap (come apart)" fa="s" ag="sprechen" ay="s" />   intransitive, sein
```

Same ablaut group, same conjugation, same paradigm. Only the perfect auxiliary and the meaning
differ. `add_readings.py` built this and [`dual_auxiliary.md`](dual_auxiliary.md) owns it.

**It is NOT the dual-paradigm work** in [`docs/roadmap.md`](../docs/roadmap.md), and an earlier draft
of the journal wrongly said these verbs were blocked on it. Readings distinguish *meanings*; a dual
paradigm is one *meaning* with two form sets — *absaugen* wanting `saugte` where the app generates
`sog`, 111 verbs, not modelled. The two are unrelated, and neither gates the other. The journal entry
of 2026-07-24 already stated this correctly; the correction of 2026-07-26 restores it.

## Why they were skipped, and why that reason is small

Nothing about the linguistics. `apply_gloss_corrections.py` refuses any verb whose element holds more
than one `tn=`, because "replace the tn in this element" does not say *which* one and the script will
not guess. `build_gloss_shards.py` therefore excluded them rather than spend tokens producing findings
nothing could apply — a good call at the time, and it wrote them to
`verbdata/gloss-review/skipped-multi-reading.txt` rather than dropping them in silence.

The fix is **addressing, not modelling**: key each correction to a specific reading, by
`(verb, reading index)` or by its `old` value, which the applier already asserts. `build_gloss_shards.py`
emits one record per **reading** instead of per verb, carrying that reading's `tn`, its `ay`/`ag`
attributes, and the verb's kaikki `candidate_glosses`.

## The 44th verb

`skipped-multi-reading.txt` lists **43**. There are **44**. `überkochen` has two readings and never
reached the multi-reading check, because it sits in the already-reviewed 1,097 of
`verbdata/authored/provenance.json` and was filtered out of the pool one step earlier.

This is worth understanding rather than just patching: two filters ran in sequence and only the
second one wrote a record. The skipped file is honest about what *it* dropped and structurally blind
to what was dropped upstream of it. `überkochen`'s glosses have never been audited either — the
sentence review saw them only incidentally. **Include it, and say so in the journal.**

## Scale: do not build a pipeline for this

88 glosses is one shard's worth. The sweep measured **~1.2 window points per 50-verb shard**, so this
is a rounding error against a 49-shard run. Review them in session, or with a single headless
`claude -p` call. Copying the wave driver a fourth time would cost more than the work.

## The one genuinely new instruction

Every constraint in `gloss_review.md` carries over unchanged. Add one, because these verbs have a
failure mode the sweep never faced:

**Each reading is judged on its own meaning, and the two glosses on a verb must stay distinguishable
from each other.** A pair that collapses to the same English defeats the point of having two
readings. This is the `weben`/`verweben` collision the sweep found — both shipped as "weave" — except
*inside a single entry*, and it is invisible to a reviewer judging one gloss at a time, which is
exactly how the pipeline works.

## Verify against attested use, not dictionary listings

The lesson of `verweben`, recorded in the journal of 2026-07-26. Langenscheidt lists `interlace`; no
translator in any bilingual corpus uses it. Reverso Context gives **frequency-ranked** renderings that
no dictionary provides, and it **403s WebFetch** — reach it with the Chrome MCP.

Watch for the same register question these verbs invite: a reading that is attested only figuratively
should not be glossed as though it were literal, but do **not** solve that with a usage label.
Appending "(figurative)" reproduces the leaked-dictionary-apparatus defect the sweep spent 49 shards
removing, which `gloss_review.md` rates high-severity. A parenthetical that *narrows a stated meaning*
— "read off (a meter)", "withdraw (money)" — is fine; one that *stands in for* a meaning is not.

## Adjudicate on a different model

The sweep ran entirely on `claude-opus-5`, so `claude-opus-5` authored every proposal. Judging them
on the same model is the self-review problem `example_review_run.md`'s cross-assignment exists to
prevent — a problem that did *not* apply to the review pass, since kaikki wrote the shipped glosses,
and that the review pass then created.

`claude-opus-4-8` is **not offered by the interactive `/model` picker** but **is served headless**:
`claude -p "..." --model claude-opus-4-8`, verified 2026-07-26. The picker curates; `--model` passes
through to the API.

## Steps

1. Extend `build_gloss_shards.py` to emit one record per reading for multi-reading verbs, including
   `überkochen`. Verify the record count is 88.
2. Add the pair-distinguishability paragraph to `gloss_review.md`.
3. Review, on `claude-opus-5`. One shard.
4. Adjudicate the findings on `claude-opus-4-8`, per `gloss_adjudication.md`.
5. Extend `apply_gloss_corrections.py` to accept a reading-scoped key, so it can write one `tn` on a
   two-reading verb without guessing. Keep the `old` assertion and the XML-parse check.
6. **Do not apply until Josh has read the triage.** Report the defect count and rate.
7. `python3 scripts/check_docs.py`, the test suite via the `ios-build-verify` skill, and a journal
   entry in `docs/blog_notes.md`.

## Kickoff — paste into a fresh session

````
Execute prompts/multi_reading_glosses.md: audit the glosses of the 44 multi-<reading> verbs the
gloss sweep excluded — 88 glosses. Working directory: /Users/josh/Desktop/workspace/Konjugieren

Read that plan first, then the docs/blog_notes.md entries of 2026-07-25 and 2026-07-26, which are
the current truth where older docs conflict.

Key points the plan explains: these are dual-AUXILIARY verbs, already modelled, and NOT the
dual-paradigm work in roadmap.md. They were excluded for an addressing limitation in
apply_gloss_corrections.py, not a linguistic one. skipped-multi-reading.txt lists 43; there are 44
(überkochen was filtered out upstream). 88 glosses is one shard — do NOT build a wave pipeline.
Adjudicate on claude-opus-4-8, which is absent from /model but served headless. Verify against
attested use via Reverso through the Chrome MCP, not dictionary listings.

Do not apply to Verbs.xml until I have read the triage. Report the defect count and rate to me.
````
