# Opus 4.8 vs Opus 5, on 1,097 German example sentences — the experiment, and what may be said about it

**Audience: a fresh session that will hash out an outline and a report with Josh.** This document
describes an A/B that already ran, says exactly which comparisons its data supports, and quantifies
the one confound that will otherwise produce a confident and wrong headline. Written 2026-07-25.

Your job is analysis and prose, not pipeline work. Everything described here is on disk and finished.
**Do not re-run the authoring or the review**; both cost multiple windows and neither would change.

## A history note, so you do not think you are violating a plan

`prompts/example_analysis.md` § "Scope decision" ruled the model-vs-model **quality** comparison out of
scope, and `prompts/example_review_run.md` instructed its orchestrator not to compare the two authoring
models "in any form". Those were live constraints for those runs, and the review run honored them.

**Josh has since decided to write this post.** He owns the call. But the reasoning behind the original
exclusion was not squeamishness — it was that the available quality signals are confounded, and § "The
confound" below shows the confound is worse than anyone assumed at the time. Read the scope decision
before you write; it is the strongest statement of the case against the post you are about to write,
and the post is better for engaging with it than for ignoring it.

## The experiment

The app had 1,097 verbs with no example sentence. Two models wrote them, in parallel, under identical
conditions:

- **Shards of 25 verbs**, 44 in total, built in alphabetical order from the gap set.
- **Models alternated strictly by shard parity** — even shards to one model, odd to the other. This was
  deliberate: shards are alphabetically clustered, so shard difficulty is not uniform (shard 038 is
  seventeen consecutive `weg-` compounds), and interleaving keeps that from loading onto one model.
- **Inputs were kept minimal and identical** — infinitive, gloss, separability, nothing else — so that
  input size could not bias the token comparison. This is why the authoring shards carry so much less
  context than the later review shards did.
- **Each shard was one headless `claude -p` child** with the same brief (`prompts/example_prompt.md`),
  writing `{de, en}` per verb plus optional self-flagged uncertainty.

Final tally: 550 verbs by `claude-opus-4-8`, 547 by `claude-opus-5`.

## Results — already computed, 2026-07-25

**Every analysis this document describes has been run.** The numbers below are the output; the sections
that follow explain what each one is and why it is or is not trustworthy. You do not need to re-derive
these, though re-running is cheap and you should if anything looks wrong.

### Effort: Opus 5 spends much more, for the same amount of text

Per-shard means over 22 shards each:

| | output tok | thinking tok | api ms | cost $ | de chars | en chars | turns |
|---|---|---|---|---|---|---|---|
| `claude-opus-4-8` | 5,998 | 2,342 | 87,429 | 0.507 | 1,995 | 1,916 | 3.1 |
| `claude-opus-5` | 7,784 | 3,769 | 106,537 | 0.568 | 2,070 | 2,002 | 3.4 |
| **ratio 5 / 4.8** | **1.30** | **1.61** | 1.22 | 1.12 | **1.04** | **1.05** | 1.09 |

The shape is the finding: **61% more thinking tokens and 30% more output tokens produce 4–5% more
text.** The extra spend is reasoning, not verbosity. Opus 5 is also more variable (output-token sd
1,860 vs 1,150; max 13,565 vs 7,880), i.e. it decides some shards are much harder than others.

### Correctness: indistinguishable

Forms gate on **pre-review text** (`corrections.json` moved aside), the one quality signal with no LLM
judge in it:

| | hit rate | misses |
|---|---|---|
| `claude-opus-4-8` | 542/550 (98.5%) | 8 |
| `claude-opus-5` | 536/547 (98.0%) | 11 |

**Fisher exact p = 0.50.** There is no difference here. Do not write one. And bear in mind that most of
those 19 misses are known non-defects — dual-paradigm forms and clipped imperatives — so the real
error rates are lower still and even closer together.

### Calibration: too thin to call, which is itself worth saying

Each model could flag sentences it was unsure of. Did the flags predict failure?

| | flagged, failed | unflagged, failed | lift | Fisher p |
|---|---|---|---|---|
| `claude-opus-4-8` | 2/42 (4.8%) | 6/508 (1.2%) | 4.0× | 0.119 |
| `claude-opus-5` | 2/66 (3.0%) | 9/481 (1.9%) | 1.6× | 0.631 |

Opus 4.8 flagged less often (7.6% vs 12.1%) and its flags look sharper, but **with two failures in each
flagged set, neither result is significant and the two cannot be separated.** An earlier draft of this
document nominated calibration as the headline; the data does not support one. Report it as a null with
the sample sizes visible — that is more honest and more useful than a 4.0× lift quoted without its p.

### Gloss disagreements: near-identical, and both models were right about a third of the time

Authors could volunteer that a shipped gloss looked wrong. Precision is measured against the later
independent review, which had no access to these notes:

| | raised | of which confirmed defective |
|---|---|---|
| `claude-opus-4-8` | 60/550 (10.9%) | 23 (38%) |
| `claude-opus-5` | 65/547 (11.9%) | 21 (32%) |

Same behavior, same hit rate, and a useful sanity check on the review itself: two independent passes
agreed on 44 glosses.

### The one large, robust difference is in judging, not writing

| | as **authors** | as **reviewers** |
|---|---|---|
| difference | 98.5% vs 98.0% | 2.0 vs 6.2 findings/shard |
| test | Fisher p = **0.50** | Mann-Whitney z = −5.26, p < **0.00001** |
| verdict | indistinguishable | 3.04×, overwhelming |

**This is the post.** The same two models, on the same corpus, differ not at all in how well they write
German and enormously in how harshly they grade it. See § "The confound" for why that also destroys the
obvious quality comparison.

## What you may compare, and with what

### 1. Effort and cost — valid, and the experiment was designed for it

`verbdata/authored/metrics.jsonl` — 44 rows, one per shard, each tagged with its author `model`:

```
{"shard": "000", "model": "claude-opus-4-8", "verbs": 25,
 "en_chars": 2133, "de_chars": 2148,
 "duration_ms": 106920, "duration_api_ms": 108025,
 "input_tokens": 6, "output_tokens": 7718, "cache_read_input_tokens": 96776,
 "thinking_tokens": 3750, "cost_usd": 0.580176, "num_turns": 3}
```

Three cautions, all from `prompts/example_generation.md`:

- **`output_tokens` is the meaningful effort signal.** `thinking_tokens` is a component of it and is
  interesting in its own right — reasoning budget spent per shard is arguably the most interesting
  number in the file.
- **`cost_usd` is secondary.** It includes a fixed harness overhead of roughly $0.02 per child, which
  is noise at this shard size but not zero.
- **`input_tokens` is meaningless** — 6, because the brief lands in `cache_read_input_tokens`. Do not
  compute a cost-per-input-token ratio from it.
- **`en_chars` / `de_chars` measure verbosity, not quality.** A model that writes longer sentences is
  not thereby better or worse; the app has no length preference beyond what the brief states.

### 2. Mechanical correctness — the one quality signal that is not confounded

`python3 verbdata/authored/check_forms.py` prints a by-author-model hit rate and writes
`verbdata/authored/forms-gate.json`. It asks one question per sentence: **does the German actually
contain a form of the verb it was written to demonstrate?** It answers by string-matching against
`corpus/working/forms.json`, which the app's own `Conjugator` generates. There is no LLM judge
anywhere in it, so there is no self-preference bias — which is precisely why `check_forms.py`'s header
calls it "the unconfounded quality signal".

It also prints a **calibration** table: each model flagged sentences it was unsure about, and the
table asks whether flagged sentences failed more often than unflagged ones — whether a model knows
when it does not know. That is a rarely-measurable property and worth reporting, but see § Results:
with two failures in each flagged set neither model's lift is significant. It is a null, not a
headline.

**One trap, and it is new.** `check_forms.py` overlays `verbdata/authored/corrections.json` on read,
and that file now holds **125 accepted corrections from the adversarial review**. A run today scores
post-review text, not what each model originally wrote. For an author-vs-author read you must exclude
it:

```bash
mv verbdata/authored/corrections.json /tmp/corrections.json.bak
python3 verbdata/authored/check_forms.py          # prints "OVERALL n/1097" with no overlay note
mv /tmp/corrections.json.bak verbdata/authored/corrections.json
```

Confirm you got the uncorrected run: the corrected one prints `[125 corrections overlaid]` beside the
overall rate, and the uncorrected one prints nothing there. **Put the file back**, and verify with
`git status` — a lost `corrections.json` costs 121 sentence fixes.

Interpret the resulting gap cautiously. Roughly fourteen of the misses are known non-defects — nine
dual-paradigm verbs where the author wrote a correct German form the app's single shipped paradigm
does not generate, four clipped colloquial imperatives, one harness limitation. Those are distributed
by which verbs a model happened to draw, not by how well it wrote. `verbdata/authored/forms-gate-misses.md`
classifies them; read it before attributing any miss to a model.

### 3. Gloss disagreements — usable, with a caveat

`verbdata/authored/gloss-disagreements.txt` collects the cases where an author judged the shipped
gloss wrong and said so in a `gloss_note`. 125 of them. Whether a model volunteers an unrequested
correction is a real behavioral difference and fair to write about. The caveat is that the brief
*invited* the note, so this measures willingness to use an offered channel, not spontaneous
initiative.

## The confound — why the review findings cannot be used, at all

This is the section that matters most, because the data that looks most like a quality comparison is
the data that is least able to be one.

An adversarial review examined all 1,097 sentences and produced 182 findings
(`verbdata/review/triage.md`, `verbdata/review/shards/rev_*.out.json`). Joining those findings to
`verbdata/authored/provenance.json` yields findings-per-authoring-model in about four lines of Python.
**Do not do it, and if you do it anyway, do not publish the result.**

The review deliberately cross-assigned every shard so that no model reviewed its own work. That was
the right call for its own purposes — marking your own homework is a conflict of interest — but it
makes **reviewer a deterministic function of author**. And the two reviewers are not remotely
comparable in strictness. Measured over 22 shards each, ~550 verbs each:

| reviewer | findings | per shard | high / medium / low |
|---|---|---|---|
| `claude-opus-4-8` | 45 | 2.0 | 2 / 31 / 12 |
| `claude-opus-5` | 137 | 6.2 | 14 / 59 / 64 |

**A 3.04× difference in finding rate, between the two models acting as reviewers.** Since Opus 4.8's
sentences were all reviewed by Opus 5 and Opus 5's sentences were all reviewed by Opus 4.8, the naive
join produces "Opus 5's sentences drew 45 findings against Opus 4.8's 137 — a 3× quality difference."
Every bit of that could be reviewer strictness, and nothing in the data can separate the two effects.
The design has no cell in which a model reviews its own author-group, so there is no anchor.

This is worth writing *about* rather than writing *around*. It is a clean, quantified example of a
failure mode that LLM-as-judge evaluations hit constantly and rarely measure: **the grader's threshold
moved more than the thing being graded.** A 3× swing from grader choice alone, on a task where both
graders had the same brief, the same rubric, and the same eight finding types, is a more useful
finding than whichever model writes marginally better German.

## Files, in the order worth reading them

| file | what it gives you |
|---|---|
| `prompts/example_generation.md` | the A/B design and why each control exists; the measured window economics |
| `prompts/example_analysis.md` | § "Scope decision" (why this post was originally ruled out) and § "Run the unconfounded signals first" |
| `verbdata/authored/metrics.jsonl` | 44 rows: tokens, thinking tokens, duration, cost, chars, by author model |
| `verbdata/authored/provenance.json` | verb → author model, the join key for everything |
| `verbdata/authored/check_forms.py` | run it; prints hit rate and calibration by author model |
| `verbdata/authored/forms-gate-misses.md` | the miss classification — read before blaming a model for a miss |
| `verbdata/authored/gloss-disagreements.txt` | 125 unrequested gloss corrections, by author |
| `docs/blog_notes.md` | dated narrative, 2026-07-19 onward; the story, including what went wrong |
| `prompts/example_prompt.md` | the brief both models actually received |
| `verbdata/review/triage.md` | **the confounded data.** Read to understand the review; do not compare authors with it |

`docs/blog_notes.md` is the richest source for narrative and the one most likely to contain a better
story than the numbers do. It records, in order, what was tried, what failed, and which conclusions
were reversed — including two of mine that were reversed by measurement rather than argument.

## Suggested spine, to argue with rather than follow

Now that the numbers are in, the honest post is not the one anyone set out to write. The comparison
readers expect — which model writes better German — has **no** answer in this data, and the interesting
result is a methodological one that fell out sideways.

1. **The setup** — 1,097 verbs, two models, controls designed in rather than bolted on. Keep it short.
2. **The expected comparison, and its null.** Correctness 98.5% vs 98.0%, p = 0.50. Calibration, both
   null. Gloss disagreements, near-identical. Lead with the null rather than burying it: three
   independent quality signals and none separates the models.
3. **The one real difference in the expected direction: cost.** 61% more thinking tokens for 4–5% more
   text. Whatever Opus 5's extra reasoning bought, it did not show up in any quality measure available
   here — which is a claim about *this task*, a constrained one-sentence generation with a mechanical
   correctness check, not about the models in general. Say so explicitly; it is the sentence most
   likely to be quoted out of context.
4. **The result nobody was looking for.** The same two models differ 3.04× as *reviewers* (p < 0.00001)
   while being indistinguishable as *authors* (p = 0.50). Judgment threshold varies far more than
   capability does.
5. **Why that also invalidates the obvious comparison** — cross-assignment made reviewer a
   deterministic function of author, so the naive join reports a 3× quality gap that is entirely
   grading. This is the LLM-as-judge failure mode, caught with a number attached.
6. **What this cannot tell you**, and why the original scope decision in `example_analysis.md` was
   right on the merits even though the post is worth writing anyway.

Sections 4 and 5 are the ones a reader has not seen before. Section 2 is the one most posts would
quietly drop for being undramatic, and dropping it is how the genre became untrustworthy.

**A caution about section 4.** It is tempting to conclude "Opus 5 is a stricter reviewer, therefore a
better one." Nothing here shows that. Strictness was measured; correctness of the findings was not, and
could only be settled by adjudicating 182 findings by hand. What *is* known is that Josh accepted all
182 unreviewed and the mechanical gate then found no regression — weak evidence the strict reviewer's
extra findings were not noise, but weak is the operative word, and 121 of those findings were never
independently checked by anything.

## Kickoff — paste this into a fresh session

````
Read prompts/model_comparison.md and help me outline and draft a blog post comparing Opus 4.8 and
Opus 5 on the German example-sentence task. Working directory: /Users/josh/Desktop/workspace/Konjugieren

Run the two valid analyses it describes (authoring metrics by model; check_forms.py with
corrections.json temporarily moved aside — put it back and verify with git status). Do NOT compare the
models using the review findings; that doc explains why in § "The confound".

The analyses are ALREADY RUN and their output is in that doc's "Results" section - read those before
deciding anything, and re-run only what you want to check. Give me a proposed outline first. We will
hash out the shape before you draft prose.
````
