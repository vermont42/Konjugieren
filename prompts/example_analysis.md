# Analyzing the authored example sentences — plan for the implementing session

**Audience: a fresh session doing analysis, not generation.** Written 2026-07-25, immediately after
the creation run finished.

**Scope in one line: the experiment measures verbosity, time, and cost. Quality is out of scope** by
Josh's decision of 2026-07-25 (§ "Scope decision"). Improving the sentences is worthwhile and separate;
attributing their quality to one model or the other is not part of this.

This is the third document in a set. Read the other two only as needed:

- [`prompts/example_prompt.md`](example_prompt.md) — the **subagent brief**, passed verbatim to every
  authoring child. Read it to know what the authors were *told* to do (sentence length, separable-verb
  word order, the `gloss_note` / `note` conventions, the output schema). It is deliberately
  measurement-blind and must stay that way; do not edit it.
- [`prompts/example_generation.md`](example_generation.md) — the **orchestrator plan** for the
  creation run: sharding, the wave driver, the model A/B design, and the now-resolved
  § "Measured run cost". Read it for run mechanics and for the two facts that live nowhere else on
  disk (§ "What is not on disk" below).

## Status: creation is COMPLETE

The generation run described in `example_generation.md` **ran to completion on 2026-07-25**. Nothing
in this document asks you to generate sentences, and you should not re-run the wave driver.

| | |
|---|---|
| Verbs authored | **1,097 / 1,097** — every verb that ships an etymology but no example sentence |
| Shards | **44 / 44** complete (25 verbs each; shard 043 is the tail, 22 verbs) |
| Models | **22 shards each** — `claude-opus-4-8` (550 sentences) and `claude-opus-5` (547) |
| Integrity | 1,097 keys present, zero missing `de` or `en`, zero invalid JSON, zero model mismatches |
| Window | one five-hour window, 23% → 75%, ~15 min wall clock over 6 waves |

Both models were interleaved *within* every wave, so throughput drift as the window filled hit them
equally and cancels out of the comparison. That is what makes the timing figures comparable at all.

## Files to use — and what each one can answer

Everything lives under `verbdata/authored/`.

| File | Contents | Answers |
|---|---|---|
| `shards/auth_NNN.out.json` | 44 files, the authored `{de, en, gloss_note?, note?}` per verb | anything sentence-level: word counts, note rates, length distributions, quality |
| `shards/auth_NNN.in.json` | 44 files, the input given each shard (`verb`, `gloss`, `separability`) | joining a sentence back to the gloss it was written against; separability breakdowns |
| `metrics.jsonl` | 44 rows, one per shard | the speed/verbosity/cost A/B — the whole headline table |
| `meta/auth_NNN.meta.json` | 44 files, each child's raw `--output-format json` | residual detail only — `stop_reason`, `ttft_ms`, `permission_denials`, per-model `modelUsage`. The two fields that mattered (`thinking_tokens`, `num_turns`) are already folded into `metrics.jsonl`. Note the `thinking` blocks are **empty** (signature only), so the reasoning text is not recoverable |
| `provenance.json` | 1,097 entries, verb → author model | provenance for `integrate`'s `source` stamp (`Opus 4.8` / `Opus 5.0`). **Not** an experimental variable, see § "Scope decision" |
| `gloss-disagreements.txt` | 125 lines, `verb<TAB>gloss_note` | the free gloss audit the authors produced as a side effect |
| `run_wave.sh` | the driver | reference only; do not re-run |

**Rule of thumb:** `metrics.jsonl` answers *how the models performed*; the `out.json` files answer
*what they wrote*. Several interesting questions need both, joined through `provenance.json`.

## Other on-disk data worth joining (coverage verified 2026-07-25)

The run's own output is not the only relevant data. These files sit elsewhere in the repo and make
several analyses possible that `verbdata/authored/` alone cannot support. **Coverage against the
1,097 gap verbs was measured, not assumed** — the numbers below are real, and one of them is a trap.

| File | Covers gap verbs | What it adds |
|---|---|---|
| `verbdata/classification.json` | **1,097 / 1,097** | per-verb `family`, `auxiliary`, `ablautGroup`, `dualAuxiliary`, `translation`, `status` |
| `verbdata/candidates.json` | **1,097 / 1,097** | the kaikki record incl. the **full multi-gloss list** per verb |
| `verbdata/no-corpus-example.txt` | **1,097 / 1,097** (exactly the gap set) | *why* each verb needed authoring at all |
| `Konjugieren/Models/Verbs.xml` | all 3,572 | the master: marked infinitive (`+` separable, `*` inseparable), `tn=` gloss |
| `Konjugieren/Models/ExampleSentences.json` | 2,475 **other** verbs | the corpus-mined sentences — a third arm for comparison |
| `verbdata/readings.json` | 1,097 / 1,097 | same shape as `candidates.json`, from the readings pass |
| `verbdata/wiktionary-defects.json` | 5 keys, small lists | verbs where Konjugieren *deliberately* disagrees with Wiktionary |
| `verbdata/dwds-frequencies.json` | **0 / 1,097 — see below** | corpus frequency, but not for these verbs |

### The three joins most worth making

**1. Verb morphology → sentence difficulty (`classification.json`, joined on `word`).** Every one of
the 1,097 gap verbs has a record. The distribution is *not* uniform, which is what makes it useful:

```
family:     w (weak) 618   s (strong) 448   m 29   i 2
auxiliary:  haben 959      sein 138
ablautGroup present: 477
```

448 strong verbs is a large enough arm to ask whether either model handles ablaut verbs better — a
sharper question than the aggregate accept rate, because strong verbs are where a wrong conjugation is
both likelier and more damaging pedagogically. Cross with `provenance.json` for the model split.

**2. The gloss audit gets a cross-check for free (`candidates.json`).** The 125 entries in
`gloss-disagreements.txt` are authors asserting the stored `tn=` gloss is wrong. `candidates.json`
holds the *full* kaikki gloss list per verb, and **83 of those 125 verbs have more than one candidate
gloss already on disk**. So for two-thirds of the disagreements you can check the author's claim
without leaving the repo: if the sense the author argues for is already sitting in the candidate list
as a secondary gloss, the import simply picked the wrong one — a mechanical, high-confidence defect.
The remaining 42 are genuine judgment calls.

**3. Why each verb needed authoring (`no-corpus-example.txt`).** This file is exactly the gap set,
TSV: `verb <TAB> reason <TAB> explanation`.

```
no-candidates            971    corpus mining found nothing at all
candidates-none-usable   126    candidates existed but every one was rejected
343 rows carry a prose explanation of the rejection
```

That prose is often specific and interesting — e.g. `abbinden`'s sole candidate was *"a 51-word Luther
passage carrying an embedded verse number and a broken hyphenation, so it is not a quotable
sentence."* Two uses: the `candidates-none-usable` verbs are ones where usable German text was scarce,
a plausible proxy for difficulty; and the whole file explains why authoring was necessary rather than
optional.

### The style baseline: authored vs mined

`Konjugieren/Models/ExampleSentences.json` holds the **2,475 corpus-mined** sentences already shipping
— a disjoint verb set, so it is not a controlled comparison, but it is a revealing one. The mined
sentences come from real corpora and read like it. `abarbeiten`'s, in full:

> *"Projekte werden zudem nur dann in den VB-E eingestuft, wenn sie keine hohe Umweltbetroffenheit
> aufweisen bzw. wenn naturschutzfachliche Probleme bereits…"*

That is bureaucratic EU-report German. Set it beside an authored sentence from this run and the
contrast in register, length, and pedagogical clarity is the point: measuring it (sentence length,
clause count, lexical frequency) quantifies what authoring actually bought over mining, which is a
question about the *pipeline*, not about the two models.

### Trap: `dwds-frequencies.json` does NOT cover these verbs

The obvious way to test the "5.0's deliberation helps on obscure verbs" hypothesis is to join corpus
frequency. **It does not work off the shelf.** `verbdata/dwds-frequencies.json` holds 990 lemmas, and
the overlap with the 1,097 gap verbs is **zero** — all 990 are verbs that were *already shipping* an
example sentence. The file was built for a different pass, and the gap set is by construction the
verbs that pass did not reach.

Options, in order of cost: use `verbdata/fetch_dwds_frequencies.py` to fetch frequencies for the gap
verbs (network, and check its rate-limiting behavior before running it over 1,097 lemmas); or use a
proxy already on disk — `readingCount` in `classification.json`, or the `no-candidates` vs
`candidates-none-usable` split above, both of which correlate with rarity without a fetch. Do not
silently substitute a proxy for frequency in a reported result; say which one you used.

### One caution on `wiktionary-defects.json`

It records **conjugation** disagreements (`abgleitete / abgegleitet` vs the correct `glitt ab /
abgeglitten`), not gloss disagreements. It is therefore relevant to the `forms.json` verification in
Open Analysis 3 — a form mismatch on a verb listed there may be *expected*, because Konjugieren
deliberately differs from Wiktionary — and is **not** a cross-check for `gloss-disagreements.txt`.
Use `candidates.json` for that.

### `metrics.jsonl` field notes

`input_tokens` is ~6 and carries **no signal** — the child's real input is Claude Code's own cached
system prompt, identical for both models. Two consequences that are easy to get wrong:

- **`output_tokens` is the effort signal.** Use it, not `input_tokens`, for the model contrast.
- **`cache_read_input_tokens` is a turn-count proxy**, not dead weight. Every turn re-sends the cached
  prefix, so it rises ~50k per extra turn: 3 turns ≈ 97k, 4 ≈ 141k, 5 ≈ 200k, 7 ≈ 297k. `meta/` has
  the exact `num_turns` if you want it precisely.
- **`cost_usd` is the weakest metric.** Each child pays a fixed ~23k cache-creation floor regardless
  of how much authoring it does, so cost is dominated by harness overhead and compressed toward a
  constant. Prefer `output_tokens` and `duration_api_ms`.
- **`thinking_tokens` and `num_turns` were folded in after the run**, extracted from `meta/` so this
  file stands alone. `thinking_tokens` is the sum of `estimated_tokens_delta` across the child's
  `thinking_tokens` events; it is a **subset of `output_tokens`**, not additive — subtract it to get
  non-thinking output. This is the single most informative pair of columns for the model contrast.

## Already computed — the baseline, do not redo

The creation session ran the A/B. Treat these as settled and build on them rather than recomputing.

```
model            shards sent  en/sent  tok/sent  med_api_ms  $/sent
claude-opus-4-8     22   550     76.6     239.9     85,454    0.02028
claude-opus-5       22   547     80.5     313.1     95,718    0.02285

model            de/sent  de_words/sent  en_words/sent  med_wall_ms
claude-opus-4-8     79.8          12.58          13.70       83,733
claude-opus-5       83.3          13.38          14.62       94,734

model            gloss_note      uncertainty note   out_tokens min/med/max
claude-opus-4-8  60 (10.9%)          42  (7.6%)     3,409 / 5,945 /  7,880
claude-opus-5    65 (11.9%)          66 (12.1%)     6,115 / 7,078 / 13,565

totals           claude-opus-4-8: 131,952 out-tokens, $11.15
                 claude-opus-5:   171,253 out-tokens, $12.50
```

```
model            think_tok/sent  % of out_tokens  turns(med)  think events/shard min/med/max
claude-opus-4-8            93.7            39.0%         3.0                    4 / 24 / 37
claude-opus-5             151.6            48.4%         3.0                   26 / 34 / 66
```

**The finding worth carrying forward, now measured rather than inferred.** Opus 5.0's English is only
**+5%** longer per sentence but costs **+30%** more output tokens, and the thinking-token columns say
where those tokens went: of the +73.2 tok/sentence gap, **+57.9 is thinking** (a +62% increase) and
only +15.3 is prose (+10%, consistent with the slightly longer English). **79% of the excess is
deliberation.** Median `num_turns` is **3.0 for both**, so this is not extra tool-use rounds or
retries — it is deeper thinking inside the same read-then-write structure. Corroborated from a third
angle by 5.0 filing uncertainty notes at **12.1% vs 7.6%**. 5.0 is also less consistent
shard-to-shard.

**This measures effort, not quality.** Whether the extra deliberation bought better sentences is
exactly what the open work below settles — and it is now a sharp question, because the cost of that
deliberation is quantified.

## Results of the `forms.json` gate — run 2026-07-25

The mechanical gate has **already been run** (`verbdata/authored/check_forms.py` →
`forms-gate.json`, misses categorised in `forms-gate-misses.md`). It is the one quality signal here
with no judge in the loop. Figures below are **after** the two corpus defects it surfaced were fixed.

```
OVERALL                 1,078 / 1,097 (98.3%)
claude-opus-4-8           542 / 550   (98.5%)
claude-opus-5             536 / 547   (98.0%)
difference  +0.6pp, 95% CI [-1.0, +2.1]  ->  NOT significant
strong verbs   4-8 98.6%  vs  5.0 97.8%      weak verbs  4-8 98.4%  vs  5.0 98.0%
```

**On mechanical conjugation correctness the two models are indistinguishable.** The gap is 0.6pp
against a ±1.6pp interval — the regime § "Hazard 3" warns not to report as a finding. 5.0's +62%
thinking bought nothing measurable *on this axis*. This null result is part of why a model-vs-model
quality comparison was taken out of scope (§ "Scope decision").

**The calibration test points the right way but does NOT reach significance.**

```
flagged with a `note`   104 / 108 hit  ->  3.7% miss
unflagged               974 / 989 hit  ->  1.5% miss
relative risk 2.44x,  Fisher one-sided p = 0.108
```

Read the history here, because it is a lesson in itself. **Before** the corpus fixes this was 2.86x at
p = 0.048 — nominally significant. One of the two fixed verbs (`überkochen`) had been *flagged* by its
author, so correcting the corpus removed a flagged miss, and with only 108 flagged verbs that single
reclassification pushed p from 0.048 to 0.108. **A p-value that fragile was never worth the weight
"significant" implies.** The direction is real and worth retesting on a larger flagged set; the
threshold claim is not.

There is a subtler reading available too. `überkochen` was flagged because the model sensed something
was wrong — and something *was* wrong, in the **corpus**, not in its sentence. So the flags may track
*"this verb is ambiguous or the gloss looks off"* rather than *"my sentence is likely wrong."* Those
are different competencies, and only the second one predicts gate failure. Recorded as an observation;
separating them would need an independent defect signal this experiment is not gathering.

**98.3% is a floor, not an estimate.** Only **4** of the 19 remaining misses are genuine sentence
defects (`wegschmeißen`, `hochstellen`, `heranhalten`, `rechtdrehen`). Nine are dual-form verbs where
the model used the other attested German form (the app conjugates *saugen* strong, *hauen* and *senden*
weak; `verglimmen` is already **deferred** in `wiktionary-defects.json`). Four are clipped colloquial
imperatives (*„Halt bitte das Essen warm"*) the app does not generate. Two are matcher limits.

**Two corpus defects the gate surfaced were fixed** (`Verbs.xml`, both verified by regenerating
`forms.json` and re-running the gate, full suite green at 211 tests):

- `zusammen+spinnen` was `fa="w"`, generating the non-word *zusammengespinnt*, while its siblings
  `sp^i^nnen` and `herum+sp^i^nnen` are `fa="s" ag="beginnen"`. Now aligned with them.
- `über*kochen` ships the inseparable homograph (*overcook*) correctly, per the pilot, but was glossed
  `tn="boil over"` — the **separable** homograph's meaning. It now carries **both** readings via the
  `über*setzen` dual-separability pattern, which is the fix the pilot itself prescribed rather than a
  flip. Corpus stays 3,572 verbs; readings 3,615 → 3,616.

## What is NOT on disk

Three things a fresh session will otherwise get wrong:

1. **`metrics.jsonl` records only successes.** The driver writes a row only when a shard's `.out.json`
   parses. A reader therefore sees 44 clean shards and would conclude a 100% first-try success rate.
   **The true rate was 42/44 first-try (2 of 46 shard-runs failed).** Shard 023 (`opus-5`) and shard
   038 (`opus-4-8`) each wrote invalid JSON — one failure per model, so this is not a model
   differentiator — by closing a German quotation opened with `„` (U+201E) using an unescaped **ASCII**
   `"` (U+0022). Both retried clean on the first re-run. Their failed `meta.json` files were
   *overwritten* by the retries and `run.log` is empty, so no trace survives except this note and
   § "Notes on the invocation" in `example_generation.md`. Row *order* is the only fingerprint: 023 and
   038 sit out of numeric sequence at lines 27 and 44.
2. **No window-cost or wave data.** `metrics.jsonl` has no `/usage` readings and no wave grouping. The
   measured cost (≈1.0 window point per shard, ≈1.0 per `/usage` read) is recorded only in
   § "Measured run cost" of `example_generation.md`.
3. **No quality verdicts.** Nothing on disk says whether any sentence is *correct*. Every sentence is
   unreviewed: no adversarial check, no `forms.json` conjugation verification, no corrections were run,
   by design — they would have muddied the performance data.

## Scope decision: quality is NOT part of this experiment (2026-07-25)

**Josh's call, made after the measurements below were in hand.** The experiment is
**verbosity, time, and cost**. Those are directly measured, judge-free, and knowable. A model-vs-model
*quality* comparison is out of scope. Sentence quality still matters, but improving it is separate
work, not an arm of this experiment. Do not build one back in.

Three findings from this run support the call, and are worth keeping because they are the reasoning:

- **The one judge-free quality comparison available came back null.** The `forms.json` gate found
  0.6pp between the models against a ±1.6pp interval (§ "Results of the `forms.json` gate").
- **The design is underpowered for anything a judge could add.** ~550 sentences per arm sitting near a
  98% ceiling puts the resolvable difference at roughly 3 points:

  ```
  SE(p_4.8 - p_5.0) = sqrt(0.95 * 0.05 * (1/550 + 1/547)) ≈ 0.013  ->  95% CI ≈ ±2.6 points
  ```

  A true 1-point difference is invisible at this n no matter how good the judge is.
- **Conclusions at this scale are fragile.** The calibration result moved from p = 0.048 to p = 0.108
  when a single observation was reclassified by a corpus fix. A quality verdict set would be at least
  as brittle.

There is also no clean judge to be had. An Opus reviewer may prefer its own family's prose
(self-preference is a documented LLM-judge failure mode), so an honest comparison would want a
third-party model, likely from another vendor. That is real infrastructure for a question this run
cannot answer anyway.

**What this changes operationally, and it is a simplification.** A quality review that is *not* an A/B
needs no blinding, no model-balanced batching, and no pre-registered hypothesis. It can run
shard-by-shard, in whatever order is convenient, with any reviewer. All of that machinery existed only
to protect a comparison that is no longer being made.

`provenance.json` is still needed, for a different reason: the `integrate` skill stamps each accepted
sentence's `source` to its author model (`Opus 4.8` / `Opus 5.0`). It is a provenance record now, not
an experimental variable.

## Open analyses — what this session can actually do

Ordered roughly by value. Pick what Josh asks for; do not assume all of them.

### 1. ~~The quality A/B~~ — RETIRED, out of scope

See § "Scope decision". Reviewing sentences for quality before shipping is still worth doing; splitting
the verdicts by author model is not part of this experiment.

The reviewer brief is [`prompts/example_review.md`](example_review.md), and
`verbdata/authored/build_review_shards.py` builds its input into `verbdata/review/shards/`
(44 shards mirroring the authored ones 1:1, ~23 KB each). Because the review is no longer an A/B, the
reviewer is given far *more* context than the author had: the full kaikki `candidate_glosses` and the
app's own generated `app_forms`. To drive it, `verbdata/authored/run_wave.sh` adapts by changing three
paths: the brief it cats, and the in/out shard paths.

### 2. Sentence-level distributions

`metrics.jsonl` is shard-aggregated, so per-sentence questions need the `out.json` files. Longest and
shortest translations, length histograms per model, outlier sentences, whether either model drifts
toward a template. Join to `provenance.json` for the model split.

### 3. Conjugation verification against `forms.json` — **DONE 2026-07-25**

Ran; see § "Results of the forms.json gate" above. Re-run with
`python3 verbdata/authored/check_forms.py` after any correction pass. Regenerating `forms.json` itself
needs `KonjugierenTests/Utils/CorpusFormsDumpTests` (see [`CLAUDE.md`](../CLAUDE.md) § "Environment-gated
harnesses"): the `TEST_RUNNER_` prefix is required, and the `--only-testing` path wants the **struct**
name `CorpusFormsDumpTests`, not the `@Suite` display name `CorpusFormsDump` — the file's own header
comment gets this wrong and would run zero tests while reporting success.

### 4. The gloss audit

`gloss-disagreements.txt` holds 125 flagged glosses — verbs whose stored `tn=` the authors believed
wrong. This is independently useful to the corpus regardless of the A/B: it is a list of probable
dictionary-import defects, found for free. Cross-reference against the `in.json` files to see the
original gloss beside the objection — and against `candidates.json`, where **83 of the 125** already
have a competing gloss on disk (§ "The three joins most worth making", join 2). Those 83 are
mechanically checkable; the other 42 need judgment.

### 5. Morphology, separability, and shard-position effects

`in.json` carries `separability`; `classification.json` adds `family` (618 weak / 448 strong),
`auxiliary` (959 *haben* / 138 *sein*), and `ablautGroup` for 477 verbs. Questions this opens: do
separable verbs draw longer sentences, since particle stranding forces a fuller clause? Do strong
verbs draw more `note` flags? Does either model's output degrade toward the end of a 25-verb shard —
visible as sentence length or note rate by position within the shard, and a genuine confound worth
ruling out before attributing any difference to the model?

### 6. Authored vs mined — what authoring bought the pipeline

A question about the pipeline rather than the models, and the only one with a ready-made control
group: compare this run's 1,097 authored sentences against the 2,475 corpus-mined ones already in
`ExampleSentences.json` (§ "The style baseline"). Sentence length, clause count, and register are all
measurable. The verb sets are disjoint, so this is suggestive rather than controlled — say so if you
report it.

## Out of scope for this plan

- **Do not regenerate sentences** or re-run `run_wave.sh`. Creation is done.
- **Do not edit** `example_prompt.md` — it is the measurement-blind brief, and changing it invalidates
  comparison with this run's data.
- **Do not integrate.** Merging into the app bundle is the `integrate` skill (Mode A), and it is Josh's
  separate pass, after review and corrections. Accepted sentences get their `source` stamped to the
  author model (`Opus 4.8` / `Opus 5.0`) — `provenance.json` is what supplies that.
- **Do not reconstruct a model-vs-model quality comparison** in any form: accept rates by author,
  defect counts by author, judge panels. It is out of scope by decision, not by oversight
  (§ "Scope decision"). Quality work on the sentences is welcome; attributing quality to a model is not.
- **Do not write `docs/blog_notes.md` during analysis.** A single wrap-up entry at the end is fine, per
  [`CLAUDE.md`](../CLAUDE.md).

## Kickoff — paste this into a fresh session

````
Analyze the authored example sentences per prompts/example_analysis.md. Working directory:
/Users/josh/Desktop/workspace/Konjugieren

Creation is already complete — do not regenerate anything. The data is under verbdata/authored/;
that plan says which file answers which question and what is deliberately absent from disk.

<state here which of the "Open analyses" you want>
````
