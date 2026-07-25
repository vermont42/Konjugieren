# Blog post brief: Opus 4.8 vs Opus 5, on 1,097 German example sentences

**You are running in `~/Desktop/workspace/Blog` and writing a post for racecondition.software.** The
experiment described here happened in a different repo, `~/Desktop/workspace/Konjugieren`, and is
finished. Every path below is absolute, so you never need to change directory.

**All analyses are already run and their results are in this document.** You should not need to open
the Konjugieren repo at all. Read it only to verify a number you doubt or to pull a quote. Do **not**
re-run the authoring or the review; both cost multiple windows and neither would change.

Follow the Blog repo's own `CLAUDE.md` for how posts are created, named, and verified — this document
says nothing about Jekyll conventions and does not override them. Josh wants to agree an outline
before you draft prose.

## Prior art in this blog, worth reading for voice and for overlap

Under `/Users/josh/Desktop/workspace/Blog/_posts/`:

- `2026-06-09-fable-and-opus.md` — a previous model comparison. Check what it already claims so this
  post does not repeat it.
- `2026-06-07-effort.md` — on reasoning effort. Directly adjacent to this post's cost finding.
- `2026-07-24-the-aside-that-built-a-test-suite.md` — recent, same project, same working style.
- `2026-05-14-when-refusals-dont-translate.md` — for the register Josh uses on LLM-behavior posts.

## The short version

Two frontier models wrote 1,097 German example sentences each half, under controlled conditions, for
an iOS app that teaches German verb conjugation. Then an adversarial review read all 1,097.

**The comparison everyone expects has no answer.** Three independent quality signals separate the two
models not at all. The only difference in the expected direction is cost, and it is large.

**The result worth publishing was not the one being looked for.** The same two models are
statistically indistinguishable as *authors* and differ 3× as *reviewers* — and because of how the
review was assigned, that difference silently masquerades as a quality gap in the most obvious
analysis anyone would run.

## The experiment

Konjugieren is a German verb conjugation app with 3,572 verbs. 1,097 of them had no example sentence.
Two models wrote them in parallel:

- **44 shards of 25 verbs**, built in alphabetical order from the gap set.
- **Models alternated strictly by shard parity.** Deliberate: shards are alphabetically clustered, so
  difficulty is uneven (one shard is seventeen consecutive `weg-` compounds), and interleaving keeps
  that from landing on one model.
- **Inputs minimal and identical** — infinitive, gloss, separability, nothing else — so input size
  could not bias the token comparison.
- **One headless `claude -p` child per shard**, same brief
  (`/Users/josh/Desktop/workspace/Konjugieren/prompts/example_prompt.md`), producing `{de, en}` per
  verb plus optional self-flagged uncertainty.

Final tally: **550 verbs by `claude-opus-4-8`, 547 by `claude-opus-5`.**

Later, a separate adversarial review read all 1,097 sentences, cross-assigned so **no model reviewed
its own work** — a conflict-of-interest control that turns out to matter enormously. It produced 182
findings.

## Results

### 1. Effort — Opus 5 spends much more, for the same amount of text

Per-shard means, 22 shards each:

| | output tok | thinking tok | api ms | cost $ | de chars | en chars | turns |
|---|---|---|---|---|---|---|---|
| `claude-opus-4-8` | 5,998 | 2,342 | 87,429 | 0.507 | 1,995 | 1,916 | 3.1 |
| `claude-opus-5` | 7,784 | 3,769 | 106,537 | 0.568 | 2,070 | 2,002 | 3.4 |
| **ratio 5 / 4.8** | **1.30** | **1.61** | 1.22 | 1.12 | **1.04** | **1.05** | 1.09 |

The shape is the finding: **61% more thinking tokens and 30% more output tokens produce 4–5% more
text.** The extra spend is reasoning, not verbosity. Opus 5 is also more variable — output-token
sd 1,860 vs 1,150, max 13,565 vs 7,880 — i.e. it treats some shards as much harder than others.

Caveats if you quote these: `cost_usd` includes ~$0.02/child of fixed harness overhead. `input_tokens`
reads 6 because the brief lands in `cache_read_input_tokens`; it is not a real number. Character
counts measure verbosity, not quality.

### 2. Correctness — indistinguishable

The gate asks one question per sentence: **does the German actually contain a form of the verb it was
written to demonstrate?** It answers by string-matching against forms the app's own conjugator
generates. No LLM judge anywhere in it, therefore no self-preference bias — the only clean quality
signal in the whole experiment. Measured on **pre-review text**, before any corrections:

| | hit rate | misses |
|---|---|---|
| `claude-opus-4-8` | 542/550 (98.5%) | 8 |
| `claude-opus-5` | 536/547 (98.0%) | 11 |

**Fisher exact p = 0.50.** There is no difference. Do not write one.

Further: most of those 19 misses are known non-defects — nine are dual-paradigm verbs where the author
wrote a correct German form the app's single shipped paradigm does not generate (*saugte* where the app
has *sog*), four are clipped colloquial imperatives (*halt* beside *halte*), one is a limitation of the
matcher itself. So the true error rates are lower still, and closer together still.

### 3. Calibration — a null, and worth reporting as one

Each model could flag sentences it was unsure of. Did the flags predict failure?

| | flagged, failed | unflagged, failed | lift | Fisher p |
|---|---|---|---|---|
| `claude-opus-4-8` | 2/42 (4.8%) | 6/508 (1.2%) | 4.0× | 0.119 |
| `claude-opus-5` | 2/66 (3.0%) | 9/481 (1.9%) | 1.6× | 0.631 |

Opus 4.8 flagged less often (7.6% vs 12.1%) and its flags look sharper. **But with two failures in each
flagged set, neither result is significant and the models cannot be separated.** An earlier draft of
this brief nominated calibration as the headline; the data does not support one. If you report the 4.0×
lift, report the p and the n in the same breath or you have written something false.

### 4. Unrequested gloss corrections — near-identical

Authors could volunteer that a verb's shipped English gloss looked wrong. Precision below is measured
against the later independent review, which never saw these notes:

| | raised | confirmed defective |
|---|---|---|
| `claude-opus-4-8` | 60/550 (10.9%) | 23 (38%) |
| `claude-opus-5` | 65/547 (11.9%) | 21 (32%) |

Same rate, same precision. Note this measures willingness to use a channel the brief explicitly
offered, not spontaneous initiative.

### 5. The one large, robust difference — and it is not about writing

| | as **authors** | as **reviewers** |
|---|---|---|
| difference | 98.5% vs 98.0% | 2.0 vs 6.2 findings per shard |
| test | Fisher **p = 0.50** | Mann-Whitney z = −5.26, **p < 0.00001** |
| verdict | indistinguishable | **3.04×**, overwhelming |

Reviewer detail, 22 shards and ~550 verbs each:

| reviewer | findings | per shard | high / medium / low |
|---|---|---|---|
| `claude-opus-4-8` | 45 | 2.0 (median 2, range 0–4) | 2 / 31 / 12 |
| `claude-opus-5` | 137 | 6.2 (median 7, range 2–8) | 14 / 59 / 64 |

The same two models, the same corpus, the same brief, the same eight finding types. They differ not at
all in how well they write German and enormously in how harshly they grade it.

## The confound — and why it is the post rather than a footnote

The review cross-assigned every shard so no model marked its own homework. Correct for its own
purposes, and it has a consequence nobody priced in: **reviewer is a deterministic function of
author.** Opus 4.8's sentences were all reviewed by Opus 5; Opus 5's were all reviewed by Opus 4.8.

So the obvious analysis — join the 182 findings to the authorship map, four lines of Python — returns
**"Opus 5's sentences drew 45 findings against Opus 4.8's 137, a 3× quality difference."** Every bit of
that could be reviewer strictness. Nothing in the data can separate the two effects, because the design
has no cell in which a model reviews its own author-group. There is no anchor.

**Do not run that join, and if you run it anyway, do not publish the result.**

This is worth writing *about* rather than writing *around*. It is a clean, quantified instance of the
failure mode LLM-as-judge evaluations hit constantly and almost never measure: the grader's threshold
moved more than the thing being graded. A 3× swing from grader identity alone, on a task where both
graders received identical instructions, is a more useful result than which model writes marginally
better German — and it is the kind of thing that quietly inflates model-comparison benchmarks
everywhere.

**One caution.** It is tempting to conclude "Opus 5 is the stricter reviewer, therefore the better
one." Nothing here shows that. Strictness was measured; correctness of the findings was not. What is
known: Josh accepted all 182 findings without individual triage, and the mechanical gate then showed no
regression — weak evidence the extra findings were not noise. Weak is the operative word.

## Suggested spine, to argue with rather than follow

1. **The setup** — 1,097 verbs, two models, controls designed in rather than bolted on. Keep it short.
2. **The expected comparison, and its null.** Correctness p = 0.50; calibration null both ways; gloss
   disagreements identical. Lead with this rather than burying it: three independent signals, no
   separation.
3. **The one real difference: cost.** 61% more thinking for 4–5% more text. Whatever that reasoning
   bought did not appear in any quality measure available here — a claim about *this task*, a
   constrained one-sentence generation with a mechanical correctness check, not about the models in
   general. Say so explicitly; it is the sentence most likely to be quoted out of context.
4. **The result nobody was looking for.** Indistinguishable as authors, 3.04× apart as reviewers.
   Judgment threshold varies far more than capability.
5. **Why that also invalidates the obvious comparison.** Cross-assignment, the deterministic mapping,
   the 3× that is entirely grading.
6. **What this cannot tell you** — and why ruling the comparison out of scope was right on the merits
   even though the post is worth writing.

Sections 4 and 5 are what a reader has not seen before. Section 2 is the one most posts quietly drop
for being undramatic, and dropping it is how the genre became untrustworthy.

## Source files, if you want to verify or quote

All under `/Users/josh/Desktop/workspace/Konjugieren/`:

| path | what it holds |
|---|---|
| `verbdata/authored/metrics.jsonl` | 44 rows: tokens, thinking tokens, duration, cost, chars, per shard, tagged by author model |
| `verbdata/authored/provenance.json` | verb → author model |
| `verbdata/authored/check_forms.py` | the correctness gate; its header explains why it is the unconfounded signal |
| `verbdata/authored/forms-gate-misses.md` | classification of the misses — read before attributing one to a model |
| `verbdata/authored/gloss-disagreements.txt` | the 125 unrequested gloss corrections |
| `verbdata/review/metrics.jsonl` | per-shard review metrics, tagged by **reviewer** model |
| `verbdata/review/triage.md` | the 182 findings. **Confounded for author comparison** — see above |
| `prompts/example_generation.md` | the A/B design and why each control exists |
| `prompts/example_analysis.md` | § "Scope decision" — the case against writing this post at all |
| `prompts/example_prompt.md` | the brief both models received |
| `docs/blog_notes.md` | dated narrative from 2026-07-19; the story, including reversals |

`docs/blog_notes.md` is the richest source for narrative and likely holds a better story than the
numbers do. It records what was tried, what failed, and which conclusions were reversed by measurement.

**One number to re-verify if you quote it.** The correctness table is measured on pre-review text.
Running `check_forms.py` today scores *post*-review text, because it overlays 125 accepted corrections
and prints `[125 corrections overlaid]` beside the rate. The pre-review figures above were obtained by
moving `verbdata/authored/corrections.json` aside for one run and restoring it. If you re-run it, you
will get 1083/1097 rather than 1078/1097 — that is expected and is not a contradiction.

## A note on provenance, for honesty in the post

`prompts/example_analysis.md` ruled this model-vs-model quality comparison out of scope, and the review
orchestrator was instructed not to compare the two authoring models in any form. Those constraints were
honored during the runs; Josh decided afterward that the post was worth writing. The original reasoning
was not squeamishness — it was that the available quality signals are confounded, and § "The confound"
shows the confound was worse than anyone assumed at the time. The post is stronger for saying this than
for omitting it: the experiment's designers called the shot before the data did.
