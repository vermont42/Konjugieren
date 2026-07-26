# Making gloss, etymology, and example sentence agree: a plan

**Audience: a future session with a real budget.** Every verb in Konjugieren carries three
independent descriptions of what it means, written by three different passes, and **nothing has ever
compared them to each other.** On 2026-07-26 three of five spot-checked verbs turned out to disagree
internally. This document says what the check is, what it would cost, why the obvious cheap filter
does not work, and, most importantly, why the first move is a 50-verb pilot rather than the sweep.
Written 2026-07-26.

**Order, set by Josh 2026-07-26:** [`em_dash_sweep.md`](em_dash_sweep.md) first,
[`cognate_precision.md`](cognate_precision.md) second, this one **on no timeline**. Both of those
rewrite etymology prose, so this pass must not start before they land. Assume every measurement in
this document is stale when you arrive.

**Do not run the full pass without a measured defect rate from step 3.** Every cost figure below is
an extrapolation from other passes. The pilot is ~$2 and converts all of them into arithmetic.

## The three descriptions

| artifact | where | audited? |
|---|---|---|
| **gloss** | `Konjugieren/Models/Verbs.xml`, `tn=` on each `<reading>` | **twice**: the 2,432-verb sweep, then a cross-model adjudication; plus the 44 multi-reading verbs |
| **example sentence** | `ExampleSentences.json`, de + en | **once**: the 1,097-sentence adversarial review, 182 findings applied |
| **etymology** | `Etymologies.json`, de + en | **never** |

That table is the plan's most useful fact, because it gives the pass a **prior**. When two artifacts
disagree, the etymology is the one that has never been read by anything. The evidence so far is thin
but points that way: of the three disagreements found on 2026-07-26, the etymology was at fault
twice (`überkochen` claimed `über-` meant excess; `zurückziehen` claimed `Geld zurückziehen` was
German for withdrawing money) and the **gloss** was at fault once (`passieren` shipped "pass
through, strain" while its etymology had said "to pass a place, a border, an obstacle" all along).

So the prior is real but must not become a rule. Make the reviewer name which artifact it believes
and why, and let the adjudicator disagree.

## What counts as a disagreement

This is the whole brief, and getting it wrong makes the pass worthless in either direction.

The three artifacts **describe different amounts by design**. A gloss is ~15 characters and commits
to one sense. An etymology is ~1,000 characters and roams across the verb's history and its
relatives. A sentence shows one use in one context. **They differ constantly and that is correct.**

- **Not a finding:** the etymology discusses a sense the gloss does not name. The app ships one gloss
  per reading by design; `gloss_review.md` already settles this.
- **Not a finding:** the example sentence uses a sense other than the gloss's, *if* the sentence is a
  mined quotation. Those were selected for attestation, not for illustrating the gloss.
- **A finding:** an artifact asserts something another **contradicts**. `überkochen`'s etymology said
  the prefix conveys excess while its gloss said "cook again". `zurückziehen`'s etymology gave an
  example that is not German.
- **A finding, and the highest-value class:** an artifact contradicts a *different verb's* corrected
  artifact. `zurückziehen`'s etymology claimed the meaning that `abheben`'s gloss had been corrected
  **to** the same day. This is the cross-verb blindness named in the `weben`/`verweben` journal entry
  of 2026-07-26, one level up, and no per-verb pass can see it. Accept that this pass will not catch
  most of them either; it caught this one only because a human held two entries in mind at once.

## Cost, honestly

Measured inputs, 2026-07-26, English side, mean per verb:

```
gloss 15 chars + etymology 997 + sentence pair 217  =  1,228 chars  ≈  341 tokens/record
                 etymology prose only 389           =    621 chars  ≈  172 tokens/record
```

**61% of the average etymology is shared component bullets**: the PIE chain for `ab-`, for `halten`,
for `kommen`. They say nothing about *this verb's* meaning and cannot contradict a gloss. Dropping
them halves the input: **616k tokens across the corpus instead of 1,219k.** Do that. Keep a pointer
so a reviewer can ask for the full text on the rare entry where the component matters.

Anchoring on this repo's measured economics (the gloss sweep at $0.0125/verb,
60 tokens/record; the adjudication at $0.0538/record, 169 tokens/record with large output), a
prose-only record at 172 tokens with review-shaped output lands around **$0.03–0.05 per verb**:

| | estimate |
|---|---|
| review pass, 3,572 verbs, prose-only | **$110–180** |
| adjudication of findings, assuming a 10% rate | **$20–40** |
| **total** | **$130–220** |
| same with full etymologies instead of prose-only | roughly double |

Against the gloss sweep's $30.44 that is 4–7×, which is expensive but not the order of magnitude the
phrase "extremely computationally expensive" suggests. The number worth being afraid of is not the
dollars; it is that **a 10% defect rate here means ~357 findings, each requiring a human decision
about which of three artifacts to rewrite.** That triage is the real cost and it is Josh's time.

## The cheap filter does not work, and here is the measurement so nobody re-derives it

The obvious economy is to compare mechanically first and only send suspicious verbs to a model. The
natural signal is whether the gloss's head verb appears in the other two artifacts. Measured:

| signal | flags |
|---|---|
| gloss head verb absent from the English example sentence | **1,839 / 3,572 (51%)** |
| gloss head verb absent from the etymology text | **1,094 / 3,572 (31%)** |

A 51% flag rate is not a filter. The reason is ordinary and unfixable by tuning. English translations
render verbs idiomatically and inflected: a gloss of `withdraw` meets *"took the money out"*,
`abzeichnen`'s `emerge` meets *"was becoming clear"*. Lemmatization would help and would not close a
50-point gap. **Do not spend a session tuning this.** If a filter is wanted, it needs to be semantic,
which means it needs a model, which is the thing the filter was supposed to avoid.

One free check *was* worth running and is already clean: **en/de structural parity of the etymologies
is perfect**, with 0 of 3,572 entries differing in bullet count or paragraph count. That confirms the
relocalization discipline held and means there is no yield there. Keep it as a regression guard in
`check_docs.py`; do not expect findings from it.

## Design notes that will otherwise be discovered late

- **Compare per reading, not per verb.** 44 verbs carry two `<reading>` elements with a gloss each,
  and the etymology usually discusses both. A record keyed by verb will ask the reviewer to judge one
  etymology against two glosses and get an incoherent answer. Reuse the `<verb>#<index>` addressing
  from `multi_reading_glosses.md`, and pass the sibling gloss.
- **Sentence provenance must be in the record.** Mined quotations and the 1,097 Claude-authored
  sentences take different verdicts, per the "not a finding" list above. The flag is membership in
  `verbdata/authored/provenance.json`.
- **Findings need three types, not one.** `gloss_review.md`'s single-`type` design was right for
  glosses and is wrong here, because the fix differs by which artifact loses: rewriting a gloss, an
  etymology paragraph, or an example sentence are three different applications with three different
  appliers. Decide the type taxonomy before the brief, not after the first shard.
- **There is no applier for etymology prose.** `apply_gloss_corrections.py` writes `tn=` attributes
  and nothing writes `Etymologies.json`. Most findings from this pass will land on the artifact that
  has no write path. Build it, with the same `old`-assertion and occurrence-count discipline, or
  the review produces a triage nobody can apply, which is exactly the failure
  `build_gloss_shards.py` avoided by excluding multi-reading verbs in the first place.
- **This runs last, and that is now scheduled rather than advisory.** Josh set the order on
  2026-07-26: [`em_dash_sweep.md`](em_dash_sweep.md) first, [`cognate_precision.md`](cognate_precision.md)
  second, this one on no timeline. Both of those rewrite etymology prose, so running this before them
  would invalidate every `old` assertion in its corrections file. Being last is a real advantage
  here: the etymologies arrive already swept for punctuation and already audited for one factual
  claim, so a disagreement this pass finds is more likely to be a genuine contradiction than an
  artifact of text nothing had ever read.

## Steps

1. Confirm `em_dash_sweep.md` and `cognate_precision.md` have both landed. They are scheduled ahead
   of this and both rewrite etymology prose. **Re-derive every measurement in this document before
   using it.** The figures here are from 2026-07-26 and two sweeps will have moved the text since;
   the 61%-shared-bullets and 172-tokens-per-record numbers drive the cost model and the shard
   design, so a stale one is not a cosmetic problem.
2. Build the per-reading record: gloss, sibling gloss, etymology **prose only**, both sentences,
   sentence provenance flag, separability, auxiliary.
3. **Pilot one 50-verb shard.** Measure the defect rate and the disagreement mix: how often the
   etymology loses versus the gloss versus the sentence. Cost ~$2. Report to Josh and stop.
4. Only with a rate in hand, decide whether to sweep, to sample, or to stop. A rate under ~3% argues
   for stopping: at that level the pass costs more in triage attention than the defects cost users.
5. If it proceeds: shard, review on `claude-opus-5`, adjudicate on `claude-opus-4-8`.
6. Build the `Etymologies.json` applier before, not after, the triage.
7. `check_docs.py`, the suite, screenshots of changed `VerbView` entries, journal entry with the
   measured rate and the disagreement mix.

## Kickoff: paste into a fresh session

````
Execute prompts/triple_consistency.md, THROUGH STEP 3 ONLY: pilot the gloss/etymology/example-
sentence consistency check on one 50-verb shard and report the defect rate to me. Do not sweep the
corpus. Working directory: /Users/josh/Desktop/workspace/Konjugieren

Read that plan first. Key points it explains: the three artifacts describe different amounts BY
DESIGN, so the finding bar is contradiction, not incompleteness. Over-flagging is the likely
failure. The etymology has never been audited while the gloss has been audited twice, which is a
prior, not a rule. Compare per READING (44 verbs have two glosses). Pass etymology prose only: 61%
of the average entry is shared component bullets that cannot contradict anything. The obvious
mechanical prefilter was measured and does not work (51% flag rate). Do not tune it.

Full-sweep cost is estimated at $130-220 plus roughly 357 human triage decisions. The pilot is ~$2
and turns that estimate into arithmetic. Stop after it and report.
````
