#!/usr/bin/env bash
# usage: run_review_wave.sh 007:claude-opus-5 008:claude-opus-4-8 ...
#
# Launches one headless `claude -p` reviewer per shard, in parallel, then appends one row per
# shard to verbdata/review/metrics.jsonl. Skips shards whose .out.json already exists, so a
# killed run costs at most one shard.
#
# Adapted from verbdata/authored/run_wave.sh. Three differences, all consequences of reviewing
# rather than authoring:
#
#   1. An EMPTY result is the success case. A shard with nothing wrong writes `{}`. The driver
#      must not treat that as a failure, which is why the validity check below parses the JSON
#      rather than testing file size.
#   2. Findings are counted, not characters. There is no verbosity metric here; nothing about
#      the reviewer is being measured for its own sake.
#   3. Finding `type` values are validated against the brief's eight names. A reviewer that
#      invents a type produces findings the triage step will silently drop, so catch it per
#      shard while the run can still be stopped.
#
# Consumes: prompts/example_review.md (the brief, passed verbatim),
#           verbdata/review/shards/rev_<NNN>.in.json  (build_review_shards.py makes these)
# Produces: verbdata/review/shards/rev_<NNN>.out.json, verbdata/review/meta/, metrics.jsonl
set -u
BRIEF="$(cat prompts/example_review.md)"
mkdir -p verbdata/review/meta
pids=()
for spec in "$@"; do
  n="${spec%%:*}"; model="${spec##*:}"
  in="verbdata/review/shards/rev_${n}.in.json"
  out="verbdata/review/shards/rev_${n}.out.json"
  meta="verbdata/review/meta/rev_${n}.meta.json"
  [ -f "$out" ] && { echo "skip ${n} (already done)"; continue; }
  [ -f "$in" ] || { echo "WARN ${n}: no input shard; run build_review_shards.py"; continue; }
  prompt="${BRIEF}

Your shard file (read this): ${in}
Write your output to (this exact path): ${out}"
  claude -p "$prompt" --model "$model" --output-format json \
    --allowedTools "Read,Write" --permission-mode acceptEdits \
    > "$meta" 2>>verbdata/review/run.log &
  pids+=($!)
done
[ ${#pids[@]} -gt 0 ] && wait "${pids[@]}"

for spec in "$@"; do
  n="${spec%%:*}"; model="${spec##*:}"
  out="verbdata/review/shards/rev_${n}.out.json"
  meta="verbdata/review/meta/rev_${n}.meta.json"
  [ -f "$out" ] || { echo "WARN ${n}: no output (see run.log)"; continue; }
  python3 - "$n" "$model" "$out" "$meta" <<'PY'
import json, sys, os, collections
n, model, outp, metap = sys.argv[1:5]
VALID = {'wrong_verb', 'wrong_sense', 'bad_gloss', 'logic',
         'connotation', 'grammar', 'translation', 'comma_splice'}
try:
    out = json.load(open(outp))
except Exception as e:
    print(f'{n}: bad out.json ({e}) -- rm it and re-queue the shard'); sys.exit()
findings = [f for v in out.values() for f in (v or {}).get('findings', [])]
bad_types = sorted({f.get('type') for f in findings} - VALID)
sev = collections.Counter(f.get('severity') for f in findings)
r = {}
if os.path.exists(metap):
    try:
        arr = json.load(open(metap))
        r = next((e for e in arr if isinstance(e, dict) and e.get('type') == 'result'), {})
    except Exception: pass
u = r.get('usage', {}) or {}
served = [k for k in (r.get('modelUsage') or {}) if not k.startswith('claude-haiku')]
row = {'shard': n, 'reviewer': model, 'served_models': served,
       'verbs_with_findings': len(out), 'findings': len(findings),
       'high': sev.get('high', 0), 'medium': sev.get('medium', 0), 'low': sev.get('low', 0),
       'invalid_types': bad_types,
       'duration_ms': r.get('duration_ms'), 'duration_api_ms': r.get('duration_api_ms'),
       'output_tokens': u.get('output_tokens'), 'cost_usd': r.get('total_cost_usd')}
open('verbdata/review/metrics.jsonl', 'a').write(json.dumps(row, ensure_ascii=False) + '\n')
flag = ''
if bad_types: flag += f'  !! invalid types {bad_types}'
if served != [model]: flag += f'  !! served={served}'
print(f'recorded {n} {model}: {len(findings)} findings on {len(out)} verbs '
      f'(h{row["high"]}/m{row["medium"]}/l{row["low"]}), {r.get("duration_api_ms")} api-ms{flag}')
PY
done
