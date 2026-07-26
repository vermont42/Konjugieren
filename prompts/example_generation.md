# Authoring example sentences — orchestrator plan (with an Opus 4.8 vs 5.0 A/B)

**Audience: an orchestrator session.** This document tells one Claude Code session how to drive
subagents that author an example sentence for every remaining gap verb, and — the reason this is a
plan and not a one-liner — how to run half the subagents on **Opus 4.8** and half on **Opus 5.0** so
their performance and verbosity can be compared. Written 2026-07-25.

The companion file [`prompts/example_prompt.md`](example_prompt.md) is the **subagent brief**. It is
deliberately measurement-blind — it never mentions models, tokens, timing, or verbosity — so that the
two models behave as they naturally would. Keep it that way.

## Run cost — RESOLVED (measured by the first run, 2026-07-25)

**How much of a five-hour window a run over these verbs consumes was not knowable until a run was
measured**, so this document originally shipped with the figure blank and instructed the first
orchestration run to fill it in. That run happened on 2026-07-25; the measured figures are below and
are now permanent. Later runs read them to size the wave loop and to predict whether one window
covers all ~44 shards. The authoritative stop condition is still the **live `/usage` read**, not this
recorded figure — the figure only lets a run *anticipate* how many waves fit before it starts.

> ### Measured run cost
> **RESOLVED 2026-07-25 by the first orchestration run.** A full pass over all **44 shards (1,097
> verbs)** consumed **52 points of the five-hour window** — 23% → 75% — and **all 44 shards fit in
> one window**, finishing exactly at the 75% cap with no second window needed.
>
> The cost decomposes cleanly into two ~equal unit costs, fitted across six waves of differing
> width (4, 6, 8, 9, 9, 9 shards; each wave's delta was `shards + 1` points, an exact fit):
>
> - **≈1.0 point per 25-verb shard.**
> - **≈1.0 point per `/usage` read.** A usage probe costs as much window as a whole authoring shard.
>   The figure is right; **the attribution first recorded here was wrong**, corrected 2026-07-26 by
>   direct measurement. It blamed the headless child, on the theory that every child pays the same
>   ~23k cache-creation input regardless of how little it does. The child pays *nothing*:
>   `claude -p "/usage"` resolves the slash command inside the CLI and never sends a request, so the
>   run reports `num_turns: 0`, every `usage` field 0, and `total_cost_usd: 0` in about one second.
>   The point is spent by the **orchestrator's own turn**, which re-reads its whole cached context in
>   order to make one Bash call and read the answer back. That the fitted cost held at ~1.0 across
>   waves of 4, 6, 8, and 9 shards is itself the tell: a per-child cost would scale with wave width,
>   and a per-orchestrator-turn cost does not.
>
>   The practical advice is unchanged, and the corrected attribution sharpens it. **Measurement is
>   ~1/5 of a narrow wave**, so prefer wider waves: they do not reduce token cost, but they amortize
>   the probe. Waves of 8–9 are a good default; 4 wastes ~20% on probing. Two further consequences
>   follow from the parent being the payer. Filter the probe with `| grep -m1 'Current session'`,
>   because the full panel is ~1,110 characters that then sit in the orchestrator's context and are
>   re-read on every later turn. And expect the probe to get *more* expensive as the run proceeds,
>   since the orchestrator's context only grows.
>
> Budget arithmetic for a future run: `points ≈ shards + waves`, plus the orchestrator session's own
> overhead (this session's tokens count against the same window; the figures above include it).
> A full 44-shard pass therefore needs **~50 points of headroom**, i.e. a window no more than ~25%
> spent. Wall-clock is not the binding constraint — all six waves plus retries took ~15 minutes.

This was the one ambiguity the plan carried on purpose, and the first run discharged it. A later run
need not re-measure, but if the CLI, the shard size, or the model set changes materially, re-derive
the two unit costs the same way: read `/usage` before and after each wave and fit `delta = a·shards +
b·reads` across waves of *differing width* — same-width waves cannot separate the two terms.

## Goal and scope

- **Produce:** one authored `{de, en}` example sentence for each of the **1,097** verbs that ship an
  etymology but no example sentence (re-derive the count, § "Build the worklist"). Output is a set of
  per-shard files under `verbdata/authored/`, plus a metrics log. **Integration is not part of this
  plan** — Josh runs the adversarial review, applies corrections, and merges via the `integrate`
  skill (Mode A) in a later, separate pass.
- **Do NOT** run adversarial checks, self-verification against `forms.json`, corrections, or the
  `integrate` merge. Those would muddy the performance data and are Josh's later job. The subagents
  author; the orchestrator measures; that is the whole loop.
- **Do NOT** update `docs/blog_notes.md` or any docs during the run (the subagent brief forbids it too).
  A single wrap-up note is fine at the very end, written by the orchestrator, not the subagents.

## The experiment: Opus 4.8 vs Opus 5.0

Opus 5.0 was released 2026-07-25. Josh wants to compare it against Opus 4.8 on this authoring task.
**Model IDs (authoritative — no date suffix): `claude-opus-4-8` and `claude-opus-5`.**

Per subagent run, record **at minimum** the three metrics Josh asked for:

1. **How long it ran** — `duration_ms` (wall) and `duration_api_ms` (model-only) from the child's JSON.
2. **How many tokens it used** — `usage.input_tokens` + `usage.output_tokens` (+ cache fields) from the JSON.
3. **Verbosity** — the **total character count of the English translations** it produced, computed by
   the orchestrator from the shard's output file.

**Assignment rule — interleave, don't block.** Give each model an equal share *within every wave*
(alternate 4.8 / 5.0 across the shards in a wave), not all-4.8-then-all-5.0. As the five-hour window
fills, throughput can drift; interleaving makes that drift hit both models equally so it cancels out
of the comparison.

**Optional extra comparisons Josh invited** — cheap to add, all derivable from the same outputs:
- Per-sentence normalization: `en_chars / sentences`, `output_tokens / sentences`, `cost_usd / sentence`.
- German verbosity: `de_chars` and words per sentence (a second verbosity axis).
- Completion: sentences produced vs verbs assigned (does one model skip or refuse more?).
- Thinking effort: `thinking_tokens` per sentence, and `num_turns` (added to `metrics.jsonl` after the
  run, extracted from each child's `meta/*.meta.json`). This turned out to be the most informative
  column of all — see the run's results.

> **Scope narrowed 2026-07-25, after the run.** This section originally also proposed *"provenance for
> a later **quality** A/B"*: split Josh's adversarial-review accept/reject verdicts by author model.
> **Josh ruled that out of scope.** The experiment measures verbosity, time, and cost, which are
> directly knowable; a model-vs-model quality claim is not practical here (~550 sentences per arm at a
> ~98% ceiling resolves nothing under ~3 points, and an honest judge would have to come from another
> vendor). Sentence quality still matters and is being worked on separately. `provenance.json` is
> retained, but as the provenance record that `integrate` stamps into each sentence's `source`, not as
> an experimental variable. Full reasoning: `prompts/example_analysis.md` § "Scope decision".

## Why headless `claude -p` children, not the Task/Agent tool

The in-session Agent tool cannot pin a *specific* Opus version — its model selector is the alias
`opus`, which resolves to whatever the session's Opus is — and it does not hand per-run token or
duration figures back to the orchestrator. Headless `claude -p --model <exact-id> --output-format json`
does both: exact model control per child, and a JSON result object carrying `duration_ms`,
`duration_api_ms`, `usage`, and `total_cost_usd`. It is also how `/usage` is already read here. So
each subagent is a `claude -p` child launched from Bash; the orchestrator collects its JSON.

## Architecture at a glance

```
worklist (1,097 verbs) ──► shards of 25 ──► verbdata/authored/shards/auth_<NNN>.in.json
                                                     │
              wave = a batch of shards, models interleaved 4.8/5.0
                                                     │
        claude -p "<brief> + shard/out paths" --model <id> --output-format json
                                                     │
   ┌─────────────────────────────┼─────────────────────────────┐
   ▼                             ▼                             ▼
 writes auth_<NNN>.out.json   JSON meta → auth_<NNN>.meta.json   (repeat per shard)
                                                     │
        orchestrator appends one row per shard to metrics.jsonl (duration, tokens, en_chars)
                                                     │
        after each wave: poll `claude -p "/usage"`; stop at >75% window used
                                                     │
                    analyze metrics.jsonl by model → A/B report
```

**Resumable.** Which shards are done = which `auth_<NNN>.out.json` files exist. A killed run costs one
shard; re-launch skips completed ones. This is the mining pipeline's interruptible pattern reused.

## Preflight (run once, before anything)

Both models must actually answer via `claude -p` in this environment, and the JSON field names must be
confirmed against this CLI version (they can drift). Run one tiny probe per model and **inspect the JSON**:

```bash
for M in claude-opus-4-8 claude-opus-5; do
  echo "=== $M ==="
  claude -p "Reply with the single word OK." --model "$M" --output-format json \
    | python3 -c "import json,sys
arr=json.load(sys.stdin)                       # NOTE: json output is an ARRAY of events
r=next((e for e in arr if e.get('type')=='result'), {})  # metrics live in the 'result' element
print({k:r.get(k) for k in ('subtype','result','duration_ms','duration_api_ms','total_cost_usd')})
print('usage:', r.get('usage'))"
done
```

**Confirmed on this CLI (smoke-tested 2026-07-25):** `--output-format json` returns a **JSON array**
of events (`system/init`, `rate_limit_event`, `assistant`, `result`); the metrics live in the element
with `type == "result"`, which carries `duration_ms`, `duration_api_ms`, `total_cost_usd`, and
`usage`. The driver below extracts that element. If a future CLI version returns a bare object instead,
adjust the extraction. If `claude -p --model claude-opus-5` errors (5.0 not available to this
CLI/account), stop and tell Josh — the A/B can't run without it.

**Token signal caveat.** In `usage`, `input_tokens` is tiny (~2) while `cache_read_input_tokens` is
large (~39k) — the child's input is dominated by Claude Code's own cached system prompt, identical for
both models, so it carries no signal. **`output_tokens` is the meaningful authoring/effort signal**;
`total_cost_usd` includes a fixed harness overhead (~$0.02 floor per child), so treat cost as
secondary and compare `output_tokens` and `duration_api_ms` for the model contrast.

## Build the worklist and shards

The gap is every verb in `Verbs.xml` with no entry in `ExampleSentences.json`. Re-derive it; do not
trust the 1,097 written here. Each shard entry carries only what authoring needs — infinitive, gloss,
separability — kept minimal and identical regardless of which model gets it, so input size never
biases the token comparison.

```bash
python3 - <<'PY'
import json, re, os
ex = json.load(open('Konjugieren/Models/ExampleSentences.json'))
have = set(ex['de'])
raw = open('Konjugieren/Models/Verbs.xml').read()
gloss, sep = {}, {}
for m in re.finditer(r'<verb in="([^"]+)"[^>]*>(.*?)</verb>', raw, re.S):
    marked = m.group(1); key = re.sub(r'[+*^]', '', marked)
    tn = re.search(r'tn="([^"]*)"', m.group(2))
    gloss[key] = tn.group(1) if tn else ''
    sep[key] = 'separable' if '+' in marked else ('inseparable' if '*' in marked else 'simplex')
gap = sorted(k for k in gloss if k not in have)
SIZE = 25
os.makedirs('verbdata/authored/shards', exist_ok=True)
for i in range(0, len(gap), SIZE):
    chunk = gap[i:i+SIZE]; n = i // SIZE
    json.dump({'shard': n,
               'verbs': [{'verb': v, 'gloss': gloss[v], 'separability': sep[v]} for v in chunk]},
              open(f'verbdata/authored/shards/auth_{n:03d}.in.json', 'w'),
              ensure_ascii=False, indent=2)
print(f'{len(gap)} gap verbs -> {(len(gap)+SIZE-1)//SIZE} shards')
PY
```

## The wave driver

Save this as `verbdata/authored/run_wave.sh` and `chmod +x` it. It takes shard-assignment specs like
`007:claude-opus-5 008:claude-opus-4-8`, launches them in parallel, waits, then appends one metrics
row per shard. It **skips shards whose `.out.json` already exists** (resume safety).

```bash
#!/usr/bin/env bash
# usage: run_wave.sh 007:claude-opus-5 008:claude-opus-4-8 009:claude-opus-5 ...
set -u
BRIEF="$(cat prompts/example_prompt.md)"
mkdir -p verbdata/authored/meta
pids=()
for spec in "$@"; do
  n="${spec%%:*}"; model="${spec##*:}"
  in="verbdata/authored/shards/auth_${n}.in.json"
  out="verbdata/authored/shards/auth_${n}.out.json"
  meta="verbdata/authored/meta/auth_${n}.meta.json"
  [ -f "$out" ] && { echo "skip ${n} (already done)"; continue; }
  prompt="${BRIEF}

Your shard file (read this): ${in}
Write your output to (this exact path): ${out}"
  claude -p "$prompt" --model "$model" --output-format json \
    --allowedTools "Read,Write" --permission-mode acceptEdits \
    > "$meta" 2>>verbdata/authored/run.log &
  pids+=($!)
done
[ ${#pids[@]} -gt 0 ] && wait "${pids[@]}"
# record metrics for every shard that now has output
for spec in "$@"; do
  n="${spec%%:*}"; model="${spec##*:}"
  out="verbdata/authored/shards/auth_${n}.out.json"
  meta="verbdata/authored/meta/auth_${n}.meta.json"
  [ -f "$out" ] || { echo "WARN ${n}: no output (see run.log)"; continue; }
  python3 - "$n" "$model" "$out" "$meta" <<'PY'
import json, sys, os
n, model, outp, metap = sys.argv[1:5]
try: out = json.load(open(outp))
except Exception as e: print(f'{n}: bad out.json ({e})'); sys.exit()
# `claude -p --output-format json` returns a JSON ARRAY of events; metrics live in the
# element with type == "result".
r = {}
if os.path.exists(metap):
    try:
        arr = json.load(open(metap))
        r = next((e for e in arr if isinstance(e, dict) and e.get('type') == 'result'), {})
    except Exception: pass
u = r.get('usage', {}) or {}
row = {'shard': n, 'model': model, 'verbs': len(out),
       'en_chars': sum(len((v or {}).get('en', '')) for v in out.values()),
       'de_chars': sum(len((v or {}).get('de', '')) for v in out.values()),
       'duration_ms': r.get('duration_ms'), 'duration_api_ms': r.get('duration_api_ms'),
       'input_tokens': u.get('input_tokens'), 'output_tokens': u.get('output_tokens'),
       'cache_read_input_tokens': u.get('cache_read_input_tokens'),
       'cost_usd': r.get('total_cost_usd')}
open('verbdata/authored/metrics.jsonl', 'a').write(json.dumps(row, ensure_ascii=False) + '\n')
print(f'recorded {n} {model}: {row["verbs"]} verbs, {row["en_chars"]} en-chars, '
      f'{row["output_tokens"]} out-tokens, {r.get("duration_api_ms")} api-ms')
PY
done
```

**Smoke-tested 2026-07-25.** A two-shard test (shard 000 on `claude-opus-5`, shard 001 on
`claude-opus-4-8`, run in parallel) completed in ~90 s wall. Both children wrote valid JSON for all 25
verbs with no permission prompts; a `forms.json` conjugation spot-check (the orchestrator's, not the
subagent's) passed 25/25 on both; sentence quality was high and natural on both models. Rough
per-25-verb-shard calibration: **~80–90 s `duration_api_ms`, ~5,000–6,700 `output_tokens`**. Re-derive
rather than trusting these; they size the wave loop, nothing more.

Notes on the invocation:
- `--allowedTools "Read,Write" --permission-mode acceptEdits` lets the child read its shard and write
  its output non-interactively. If a Write still prompts in this CLI, fall back to
  `--dangerously-skip-permissions` (headless, repo-scoped — acceptable for a controlled author-and-write
  task, but prefer the allowlist).
- **Concurrency is the wave size.** Start at **4 per wave** (2 on each model), then widen to **8–9**
  once a wave has come back clean. Widening does not reduce token cost, but it amortizes the ~1-point
  `/usage` probe (§ "Measured run cost"); the countervailing risk is only that more shards are in
  flight before you can react to a problem.
- **Malformed-JSON shards happen, and the driver's skip logic does not catch them.** In the 2026-07-25
  run, 2 of 46 shard-runs (one per model — 023 on 5.0, 038 on 4.8) wrote invalid JSON, both times by
  closing a German quotation opened with `„` (U+201E) using an **ASCII** `"` (U+0022), unescaped inside
  a JSON string. The driver prints `NNN: bad out.json (…)` and records no metrics row, but the corrupt
  `.out.json` still **exists**, so `[ -f "$out" ]` would skip it forever on resume. Recovery is to
  `rm` the bad file and re-queue the shard; both retries succeeded first try. Do **not** hand-repair the
  escape — that is a correction, and corrections are Josh's later pass, not this run's.

## The wave loop and the 75% window stop

Josh's stop condition is **">75% of the five-hour window used"**, and the per-wave cost is unknown
until measured. So: read `/usage` before wave 1, run wave 1, read `/usage` again, record the delta as
the measured per-wave cost, then keep launching waves — checking `/usage` after each — until the
**Current session** line exceeds 75% (or all shards are done, whichever comes first).

Read the window with the headless-usage trick (same as the mining pipeline):

```bash
claude -p "/usage" 2>/dev/null | grep -iA3 "current session"   # read the Current session %, not the weekly lines
```

Loop shape (the orchestrator runs this itself, one wave at a time, assigning models interleaved):

1. `USED0=$(read /usage Current-session %)`. If already >75%, stop.
2. Pick the next up-to-`WAVE_SIZE` shards **without** an `.out.json`, alternating models:
   `bash verbdata/authored/run_wave.sh 012:claude-opus-4-8 013:claude-opus-5 014:claude-opus-4-8 015:claude-opus-5`
3. `USED1=$(read /usage)`. Record `USED1-USED0` as this wave's window cost, and sanity-check it
   against § "Measured run cost" (expect `shards + 1` points). A wave that costs materially more than
   that is a signal something changed — investigate before launching the next one.
4. If `USED1 > 75` or no shards remain → stop. Else go to 2.

The authoritative stop condition is always the live `/usage` read, not the recorded figure; the
recorded figure only lets a run *anticipate* how many waves fit before it starts. Note that step 3's
read is itself billed at ~1 point, so `WAVE_SIZE` of 4 spends ~20% of the window on measurement —
8–9 is the better default (see § "Measured run cost").

Stopping at >75% leaves headroom for the analysis step and Josh's later passes. If the window is
exhausted before all 44-ish shards are done, that is fine — the run is resumable; a fresh window
continues where this one stopped (the driver skips completed shards).

## Analyze — the A/B report

After the run (or at any checkpoint), aggregate `metrics.jsonl` by model and build the provenance map.

```bash
python3 - <<'PY'
import json, glob, statistics as st
rows = [json.loads(l) for l in open('verbdata/authored/metrics.jsonl')]
by = {}
for r in rows: by.setdefault(r['model'], []).append(r)
def agg(rs):
    sent = sum(r['verbs'] for r in rs)
    en   = sum(r['en_chars'] for r in rs)
    out  = sum((r['output_tokens'] or 0) for r in rs)
    inp  = sum((r['input_tokens'] or 0) for r in rs)
    dapi = [r['duration_api_ms'] for r in rs if r.get('duration_api_ms')]
    cost = sum((r['cost_usd'] or 0) for r in rs)
    return dict(shards=len(rs), sentences=sent,
                en_chars_per_sentence=round(en/sent,1) if sent else 0,
                output_tokens_per_sentence=round(out/sent,1) if sent else 0,
                median_duration_api_ms=round(st.median(dapi)) if dapi else None,
                total_input_tokens=inp, total_output_tokens=out,
                cost_per_sentence_usd=round(cost/sent,5) if sent else 0)
print(f"{'model':16} shards sent  en/sent  tok/sent  med_api_ms  $/sent")
for m in sorted(by):
    a = agg(by[m])
    print(f"{m:16} {a['shards']:5}  {a['sentences']:4}  {a['en_chars_per_sentence']:7}  "
          f"{a['output_tokens_per_sentence']:8}  {str(a['median_duration_api_ms']):10}  {a['cost_per_sentence_usd']}")
# provenance: verb -> model, for a later quality A/B
prov = {}
for r in rows:
    out = json.load(open(f"verbdata/authored/shards/auth_{r['shard']}.out.json"))
    for v in out: prov[v] = r['model']
json.dump(prov, open('verbdata/authored/provenance.json','w'), ensure_ascii=False, indent=2)
print(f"\nprovenance.json: {len(prov)} verbs tagged by author model")
PY
```

The printed table is the headline A/B result: for each model, how verbose its English is
(`en/sent`), how many output tokens it spends per sentence (`tok/sent`), how fast it is
(`med_api_ms`), and its cost per sentence. `provenance.json` is the bridge to a *quality* comparison
later — split Josh's accept/reject verdicts by author model.

## Gloss disagreements

The subagent brief tells authors to write for a verb's *actual* meaning when its stored gloss looks
wrong, and to record a `gloss_note`. Collect those into one report for Josh (they are also a free
gloss audit, as the pilot found):

```bash
python3 - <<'PY'
import json, glob
rows = []
for f in sorted(glob.glob('verbdata/authored/shards/auth_*.out.json')):
    for verb, e in json.load(open(f)).items():
        if isinstance(e, dict) and e.get('gloss_note'):
            rows.append((verb, e['gloss_note']))
open('verbdata/authored/gloss-disagreements.txt','w').write(
    '\n'.join(f'{v}\t{n}' for v, n in sorted(rows)) + '\n')
print(f'{len(rows)} gloss disagreements -> verbdata/authored/gloss-disagreements.txt')
PY
```

## Handoff

When the window is spent (or all shards done), leave Josh:
- `verbdata/authored/shards/auth_*.out.json` — the authored `{de, en}` sentences, per shard.
- `verbdata/authored/metrics.jsonl` and the printed A/B table — the performance/verbosity comparison.
- `verbdata/authored/provenance.json` — verb → author model, for a later quality split.
- `verbdata/authored/gloss-disagreements.txt` — flagged glosses to review.

Josh then runs the adversarial review, applies corrections, stamps each accepted sentence's `source`
to its author model (`Opus 4.8` / `Opus 5.0`), and merges via the `integrate` skill (Mode A). **None
of that is this run's job.**

## Kickoff — paste this into a fresh session to orchestrate

````
Execute prompts/example_generation.md as the orchestrator. Working directory:
/Users/josh/Desktop/workspace/Konjugieren

Do only what that plan says: generate one example sentence per gap verb via headless
`claude -p` subagents, half on claude-opus-4-8 and half on claude-opus-5, and measure each
run. Do NOT run adversarial checks, self-verification, corrections, or the integrate merge —
those are a later, separate pass of mine. Do NOT touch docs/blog_notes.md during the run.

Steps, in order:
1. Preflight: probe both models with `claude -p ... --output-format json` and confirm the JSON
   field names the driver reads (duration_ms, duration_api_ms, usage.input_tokens,
   usage.output_tokens, total_cost_usd). If claude-opus-5 is unavailable, stop and tell me.
2. Build the worklist and shards (the plan's Python snippet). Re-derive the gap count.
3. Save the wave driver from the plan as verbdata/authored/run_wave.sh and chmod +x it.
4. Read `claude -p "/usage"` (Current session line). Then run waves of ~4 shards, models
   interleaved 4.8/5.0 within each wave, skipping shards that already have output. This is the
   FIRST run, so the "Measured run cost" is UNRESOLVED — measure the window cost per wave and,
   once you have a representative figure, edit prompts/example_generation.md to resolve that
   placeholder permanently. Keep launching waves, re-reading /usage after each, until the Current
   session exceeds 75% or all shards are done.
5. Run the analysis snippet to print the A/B table and write provenance.json, and the
   gloss-disagreements collector. Report the table to me.

The subagent brief is prompts/example_prompt.md — pass it verbatim to each child (the driver
does this) and never add anything about models, tokens, timing, or measurement to it.
````
