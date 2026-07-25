# Reviewing the authored example sentences — orchestrator plan

**Audience: an orchestrator session.** This document tells one Claude Code session how to drive
subagents that adversarially review all 1,097 authored example sentences, and how to collapse their
output into a single triage list for Josh. Written 2026-07-25.

Companion files:

- [`prompts/example_review.md`](example_review.md) — the **subagent brief**, passed verbatim to every
  child. It is written in second person to a reviewer handling exactly *one* shard, and it expects the
  shard path and output path to be appended at the end. The driver does that. **Do not paste this file
  at a session and expect a run**; on its own it has no shard to read.
- [`prompts/example_prompt.md`](example_prompt.md) and
  [`prompts/example_generation.md`](example_generation.md) — the authoring brief and its orchestrator
  plan, which produced the sentences being reviewed. Read the latter for the measured window
  economics this plan reuses.
- [`prompts/example_analysis.md`](example_analysis.md) — what is on disk from the authoring run, and
  § "Scope decision", which governs what this review is *not* for.

## Goal and scope

- **Produce:** `verbdata/review/shards/rev_NNN.out.json` for all 44 shards, then one aggregated triage
  list, `verbdata/review/triage.md`, sorted by severity.
- **Do NOT apply corrections.** The reviewer proposes `fix_de` / `fix_en`; deciding which to accept is
  Josh's pass. An orchestrator that edits sentences has destroyed the record of what was flagged.
- **Do NOT run the `integrate` merge.** That is Mode A, and it happens after Josh triages.
- **Do NOT compare the two authoring models**, in any form: findings-per-author, severity-by-author,
  accept rates. Out of scope by decision (`example_analysis.md` § "Scope decision"). This matters here
  because § "Reviewer assignment" below deliberately splits work by authoring model, which makes the
  comparison trivially computable and still forbidden.
- **Do NOT update `docs/blog_notes.md`** during the run. A single wrap-up note at the end is fine.

## Reviewer assignment: cross-assign, do not self-review

Each authored shard was written entirely by one model, so a reviewer looking at its own shard is
marking its own homework. Nothing about that is a *comparison* problem; it is a plain
conflict-of-interest problem, and it would persist even if only one model existed.

**Assign each shard to the model that did not author it.** `verbdata/authored/provenance.json` gives
verb → author model, and shards are model-homogeneous, so one lookup per shard settles it:

```bash
python3 - <<'PY'
import json, glob, re
prov = json.load(open('verbdata/authored/provenance.json'))
OTHER = {'claude-opus-4-8': 'claude-opus-5', 'claude-opus-5': 'claude-opus-4-8'}
specs = []
for f in sorted(glob.glob('verbdata/authored/shards/auth_*.out.json')):
    n = re.search(r'auth_(\d+)', f).group(1)
    author = prov[next(iter(json.load(open(f))))]     # shards are model-homogeneous
    specs.append(f'{n}:{OTHER[author]}')
print(' '.join(specs))
PY
```

That prints all 44 specs. Feed the next 8 or 9 of them to each wave.

If Josh would rather have a single reviewer for consistency, that is a defensible alternative; say so
in the wrap-up, because a self-reviewed shard's findings deserve less weight than a cross-reviewed
one's.

## Run cost — reviewing is ~2.5x more expensive than authoring

**This section originally reused the authoring figure and was wrong.** A trial shard on 2026-07-25
(shard 038, `claude-opus-5`) measured:

| | authoring shard (5.0) | review shard | ratio |
|---|---|---|---|
| `output_tokens` | ~6,300 | **15,995** | 2.5x |
| `duration_api_ms` | ~95,000 | **212,965** | 2.2x |
| `cost_usd` | ~0.54 | **1.00** | 1.8x |

Reading 25 sentences against their gloss, `candidate_glosses`, and `app_forms` and then justifying
each finding is simply more work than writing the sentences was. So against the authoring run's
measured **≈1.0 window point per shard**, budget **≈2 to 2.5 points per review shard**, i.e. roughly
**100 points for all 44 — two windows, not one.**

Treat that as derived from token ratios, not measured from `/usage`: the trial was a single shard and
no window delta was read for it. **Measure wave 1's `/usage` delta and re-plan from it**, exactly as
the authoring run did. If a wave of 8 costs materially more than ~20 points, stop and re-scope before
launching another.

Because there is no model interleaving to preserve here, wave size is purely an efficiency question.
Go straight to **8–9 per wave**; the authoring run's advice to start at 4 existed to catch problems
early in a first-ever run, and this pipeline is now well-trodden.

## The trial shard — ALREADY DONE, do not repeat it

**Shard 038 was trialled on 2026-07-25 and approved. Go straight to the waves.** A fresh session that
re-trials burns a shard and ~3.5 minutes re-proving a settled point.

Shard 038 itself **will** be reviewed again in the normal waves, deliberately. Its trial output was
produced against the *uncorrected* `wegschmeißen` sentence, and the two findings it raised have since
been fixed in `corrections.json` — so keeping it would have made the triage list report two closed
items as open. The trial output is preserved as `verbdata/review/trial-038.out.json`, out of the
driver's path, and 038 gets a clean review against the corrected text like every other shard.

What the trial established, so you do not have to re-establish it:

- **Detection works.** Shard 038 holds `wegschmeißen`, the one sentence with known ground truth. Both
  expected findings came back correctly diagnosed and correctly fixed: `wrong_verb` (high) and
  `comma_splice` (low). Its `fix_de` / `fix_en` are now shipped in
  `verbdata/authored/corrections.json`.
- **The rate is 8 findings per 25 verbs**, split high 1 / medium 2 / low 5, with every finding
  defensible on inspection and `invalid_types` empty.
- **Judge by severity, not by total.** High-plus-medium was 3 per 25, matching the pilot. That is the
  number that sizes triage.

**Rebuild the shards before running.** All four known defects — `wegschmeißen` (038), `heranhalten`
(020), `hochstellen` (024), `rechtdrehen` (028) — have been **fixed** in `corrections.json`, and
`build_review_shards.py` overlays it. Skip the rebuild and the reviewer sees the old sentences and
re-reports four closed findings. After a correct rebuild, those four verbs should come back **clean**,
which is itself a useful check: a `wrong_verb` finding on any of them means the overlay did not apply.

### If you edit the brief, re-trial

Only then. Delete the shard's `.out.json`, re-run the single shard, and judge the findings
individually:

- **Over-flagging looks like bad findings, not many findings.** If you read the list and disagree with
  several, tighten `prompts/example_review.md` § "What is NOT a finding" against whatever it is
  over-reporting.
- **Do not extrapolate a total from one shard.** Shards are built in alphabetical order, so each is a
  *clustered* sample. Shard 038 is `weghören, wegjagen, wegmachen, wegrauchen, wegrennen, …` —
  seventeen consecutive `weg-` compounds, a run of near-synonymous separable verbs where particle
  scope and sense boundaries are unusually dense, and plausibly harder than average. Sample two shards
  from different parts of the alphabet before believing any projection.

## Build the shards

```bash
python3 verbdata/authored/build_review_shards.py
```

44 shards into `verbdata/review/shards/`, mirroring the authored shards 1:1 (same NNN, same verbs,
same order). They are gitignored as derived bulk; rebuild rather than expecting them in a fresh clone.
Note this needs `corpus/working/forms.json`, which is itself gitignored and regenerated by
`KonjugierenTests/Utils/CorpusFormsDumpTests` — see `example_analysis.md` § "Results of the
`forms.json` gate" for the invocation, including the struct-name-not-display-name trap.

## The wave driver

`verbdata/review/run_review_wave.sh`, already committed and executable. Unlike the authoring plan,
which asked the orchestrator to transcribe its driver from the document, this one is a real file:
transcription is a needless failure mode.

```bash
bash verbdata/review/run_review_wave.sh 008:claude-opus-5 009:claude-opus-4-8 010:claude-opus-5 …
```

It skips shards whose `.out.json` exists, so re-launching after a kill is safe. It parses each output
rather than testing file size, because **`{}` is the success case** for a clean shard. It also
validates every finding's `type` against the brief's eight names and prints `!! invalid types` if the
reviewer invented one, which is worth stopping for: unknown types survive into `metrics.jsonl` but the
triage step will not know how to rank them.

## The wave loop and the 75% stop

Same shape as the authoring run:

1. Read the window: `claude -p "/usage" 2>/dev/null | grep -i "current session"`. If already past 75%,
   stop and hand off; the run is resumable.
2. Launch the next 8–9 unstarted shards, cross-assigned per § "Reviewer assignment".
3. Read `/usage` again. Record the delta. Compare against `shards + 1` points; a materially larger
   wave cost means the review is more expensive than authoring was, so re-plan how many shards fit.
4. If past 75% or no shards remain, stop. Otherwise go to 2.

The live `/usage` read is the authoritative stop condition, never a projection.

## Aggregate into a triage list

Once the shards are done (or the window is spent), collapse them.

```bash
python3 - <<'PY'
import json, glob, re, collections
SEV = {'high': 0, 'medium': 1, 'low': 2}
TYPE_ORDER = ['wrong_verb', 'wrong_sense', 'bad_gloss', 'logic',
              'grammar', 'translation', 'connotation', 'comma_splice']
sent = {}
for f in sorted(glob.glob('verbdata/authored/shards/auth_*.out.json')):
    sent.update(json.load(open(f)))
# Overlay corrections, exactly as build_review_shards.py does. Without this the "current de/en"
# lines print pre-fix text, so a re-run after any fixes are accepted shows Josh sentences that no
# longer exist and re-proposes fixes already applied.
for verb, fix in json.load(open('verbdata/authored/corrections.json')).items():
    if verb in sent:
        sent[verb] = {**sent[verb], **{k: v for k, v in fix.items() if k in ('de', 'en')}}
rows, shards = [], 0
for f in sorted(glob.glob('verbdata/review/shards/rev_*.out.json')):
    shards += 1
    for verb, entry in json.load(open(f)).items():
        for fi in (entry or {}).get('findings', []):
            rows.append((SEV.get(fi.get('severity'), 3),
                         TYPE_ORDER.index(fi['type']) if fi.get('type') in TYPE_ORDER else 9,
                         verb, fi))
rows.sort(key=lambda r: (r[0], r[1], r[2]))
by_sev = collections.Counter(r[3].get('severity') for r in rows)
by_type = collections.Counter(r[3].get('type') for r in rows)
out = ['# Review triage', '',
       f'{len(rows)} findings across {len({r[2] for r in rows})} verbs, from {shards} of 44 shards.', '',
       '| severity | n |', '|---|---|']
out += [f'| {s} | {by_sev[s]} |' for s in ('high', 'medium', 'low') if by_sev[s]]
out += ['', '| type | n |', '|---|---|']
out += [f'| {t} | {by_type[t]} |' for t in TYPE_ORDER if by_type[t]]
cur = None
for sev, _, verb, fi in rows:
    label = ('high', 'medium', 'low', 'unknown')[min(sev, 3)]
    if label != cur:
        cur = label; out += ['', f'## {label}', '']
    out.append(f'### {verb} — `{fi.get("type")}`')
    out.append(f'{fi.get("detail", "")}')
    out.append(f'- current de: {sent.get(verb, {}).get("de", "")}')
    out.append(f'- current en: {sent.get(verb, {}).get("en", "")}')
    if fi.get('fix_gloss'): out.append(f'- **fix gloss:** {fi["fix_gloss"]}')
    if fi.get('fix_de'): out.append(f'- **fix de:** {fi["fix_de"]}')
    if fi.get('fix_en'): out.append(f'- **fix en:** {fi["fix_en"]}')
    out.append('')
open('verbdata/review/triage.md', 'w').write('\n'.join(out))
print(f'{len(rows)} findings -> verbdata/review/triage.md')
PY
```

The triage list puts each finding beside the sentence it is about and the proposed replacement, so
Josh can accept or reject without opening anything else. Sorted severity-first, then by finding type
in the brief's own order, so `wrong_verb` leads.

**Sanity-check the aggregate before handing it over.** Three checks, in order of how much they tell
you:

1. **The four corrected verbs should come back with no findings at all** — `wegschmeißen`,
   `hochstellen`, `heranhalten`, `rechtdrehen`. This is the only hard ground truth available, and note
   that it reads *backwards* from the obvious: they are the four verbs with known defects, so the
   instinct is to expect `wrong_verb` on each. Their defects are fixed in `corrections.json`, which
   § "Rebuild the shards" overlays, so a `wrong_verb` finding on any of them means the overlay did not
   apply and the reviewers read stale sentences.
2. **High plus medium should land near 110.** Measured on 2026-07-25: 106, across all 44 shards. This
   is the number that sizes Josh's triage.
3. **The overall total will be larger, and that is expected** — 182 on the 2026-07-25 run, most of it
   `low`. Do not read a large total as over-flagging; read the severity split. The trial shard's
   8-findings-per-25 rate projected ~350 and was nearly double the truth, because seventeen
   consecutive `weg-` compounds made it a harder-than-average sample.

A high-plus-medium count under 30 means the reviewers were too permissive to be useful. Over ~250
means they were too strict, and the list will be unusable regardless of how good individual findings
look.

## Handoff

Leave Josh:

- `verbdata/review/triage.md` — the finding list, severity-sorted, with proposed fixes inline.
- `verbdata/review/shards/rev_*.out.json` — the raw findings, per shard.
- `verbdata/review/metrics.jsonl` — one row per shard: findings, severity counts, duration, tokens,
  and `invalid_types` if any reviewer went off-schema.
- A short note on how many shards ran, and whether any hit the window before finishing.

Josh triages, applies the fixes he accepts, and merges via the `integrate` skill (Mode A), stamping
each sentence's `source` from `verbdata/authored/provenance.json`. **None of that is this run's job.**

### Where accepted fixes land — two files, because glosses are not pipeline data

Whoever applies the fixes needs to know that the review's three fix fields do not go to one place:

- `fix_de` / `fix_en` → `verbdata/authored/corrections.json`, keyed by verb, carrying a `reason` and a
  `source`. The authored shards stay immutable and every consumer overlays this file on read; see
  `check_forms.py`'s header for why.
- `fix_gloss` → `verbdata/authored/gloss-corrections.json`, applied by
  `verbdata/authored/apply_gloss_corrections.py`. Glosses are **not** in the pipeline at all: they live
  in the `tn` attribute of `<reading>` in `Konjugieren/Models/Verbs.xml`, which is shipping app data.
  That script asserts each `old` gloss still matches before writing anything, refuses the whole file if
  one is stale, and refuses any verb carrying two `<reading>` elements rather than guessing which sense
  to rewrite.

After applying either, **run `python3 verbdata/authored/check_forms.py`**. It is the acceptance test
for accepted fixes: a `fix_de` that quietly drops the target verb shows up as a new miss, which is the
one failure mode a proposed sentence can have that reading it does not reveal. Compare the miss list
against the run before, not against zero — roughly fourteen misses are known non-defects
(dual-paradigm verbs, clipped colloquial imperatives, matcher limits).

## Kickoff — paste this into a fresh session

````
Execute prompts/example_review_run.md as the orchestrator. Working directory:
/Users/josh/Desktop/workspace/Konjugieren

Review all 1,097 authored example sentences via headless `claude -p` subagents, cross-assigned so
no model reviews its own shards. Do NOT apply any corrections, do NOT run the integrate merge, and
do NOT compare the two authoring models in any form.

Steps, in order:
1. Rebuild the review shards (build_review_shards.py) so they pick up
   verbdata/authored/corrections.json. Regenerate corpus/working/forms.json first if it is missing.
2. Do NOT run a trial shard. Shard 038 was already trialled and approved; the plan records what it
   established. Go straight to waves of 8-9 shards, reading /usage after each, until the Current
   session exceeds 75% or all 44 shards are done. Budget two windows; the driver skips completed
   shards, so resuming in a fresh window is just running it again.
3. Aggregate into verbdata/review/triage.md and report the severity and type tables to me.

The subagent brief is prompts/example_review.md - pass it verbatim to each child (the driver does
this) and do not add anything to it.
````
