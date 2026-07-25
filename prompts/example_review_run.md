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

## Run cost

The authoring run measured **≈1.0 window point per 25-verb shard and ≈1.0 point per `/usage` read**
(`example_generation.md` § "Measured run cost"). A reviewer child has the same shape — read one file,
think, write one file — so **expect roughly one full window for 44 shards**, and budget ~50 points.

Two reasons it could run higher, both worth watching on wave 1: the review shards are larger than the
authoring shards (~23 KB against ~2 KB, because they carry `candidate_glosses` and `app_forms`), and a
reviewer that writes `fix_de` / `fix_en` for many verbs produces more output than one that writes
`{}`. **Measure wave 1's delta before sizing wave 2**; do not assume the authoring figure transfers.

Because there is no model interleaving to preserve here, wave size is purely an efficiency question.
Go straight to **8–9 per wave**; the authoring run's advice to start at 4 existed to catch problems
early in a first-ever run, and this pipeline is now well-trodden.

## Before the full run: one shard, by hand

Cheapest way to learn whether the brief is calibrated. **Do this first.**

```bash
bash verbdata/review/run_review_wave.sh 000:claude-opus-5
python3 -c "
import json; d=json.load(open('verbdata/review/shards/rev_000.out.json'))
n=sum(len(v['findings']) for v in d.values())
print(f'{n} findings across {len(d)} of 25 verbs'); print(json.dumps(d, ensure_ascii=False, indent=2)[:2000])"
```

Read the findings yourself and judge them before spending a window:

- **2 to 4 findings per 25 verbs** matches the pilot's rate (3 substantive findings in 25) and means
  the brief is calibrated. Proceed.
- **10 or more** means it is over-flagging. Tighten `prompts/example_review.md` § "What is NOT a
  finding" against whatever it is over-reporting, delete `rev_000.out.json`, and re-run the one shard.
  Do this before the full run, not after.
- **0** on a shard known to contain a real defect is the opposite failure. Shard 000 does not contain
  one, so a `{}` there is unremarkable. The four known genuine defects
  (`verbdata/authored/forms-gate-misses.md`) sit in four specific shards:

  | shard | verb | the defect |
  |---|---|---|
  | 020 | `heranhalten` | uses *an*, needs the particle *heran* |
  | 024 | `hochstellen` | uses *höher*, needs *hoch* |
  | 028 | `rechtdrehen` | uses *rechts*, needs *recht* (and may be a corpus defect, not a sentence one) |
  | 038 | `wegschmeißen` | uses *wirf … weg*, which is **wegwerfen**; also the corpus's one comma splice |

  **These four are the ground truth for whether the review works at all.** Each should come back as
  `wrong_verb`, and 038 should additionally come back as `comma_splice`. When those shards complete,
  check them before launching more waves. A review that misses all four is not calibrated, whatever
  its total count looks like. All four were authored by `claude-opus-4-8`, so cross-assignment sends
  every one of them to `claude-opus-5`.

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

**Sanity-check the aggregate before handing it over.** Two numbers tell you whether the run worked:
the four known defects (§ "Before the full run") should appear as `wrong_verb`, and the total should
be on the order of 100 to 150 if the pilot's rate held. A total under 20 means the reviewers were too
permissive; a total over 400 means they were too strict, and the list will be unusable.

## Handoff

Leave Josh:

- `verbdata/review/triage.md` — the finding list, severity-sorted, with proposed fixes inline.
- `verbdata/review/shards/rev_*.out.json` — the raw findings, per shard.
- `verbdata/review/metrics.jsonl` — one row per shard: findings, severity counts, duration, tokens,
  and `invalid_types` if any reviewer went off-schema.
- A short note on how many shards ran, and whether any hit the window before finishing.

Josh triages, applies the fixes he accepts, and merges via the `integrate` skill (Mode A), stamping
each sentence's `source` from `verbdata/authored/provenance.json`. **None of that is this run's job.**

## Kickoff — paste this into a fresh session

````
Execute prompts/example_review_run.md as the orchestrator. Working directory:
/Users/josh/Desktop/workspace/Konjugieren

Review all 1,097 authored example sentences via headless `claude -p` subagents, cross-assigned so
no model reviews its own shards. Do NOT apply any corrections, do NOT run the integrate merge, and
do NOT compare the two authoring models in any form.

Steps, in order:
1. Build the review shards (build_review_shards.py). Regenerate corpus/working/forms.json first if
   it is missing.
2. Run ONE shard and show me the findings before going further, so I can judge whether the brief
   is calibrated. Stop there and wait for my go-ahead.
3. After I approve: run waves of 8-9 shards, reading /usage after each, until the Current session
   exceeds 75% or all 44 shards are done.
4. Aggregate into verbdata/review/triage.md and report the severity and type tables to me.

The subagent brief is prompts/example_review.md - pass it verbatim to each child (the driver does
this) and do not add anything to it.
````
