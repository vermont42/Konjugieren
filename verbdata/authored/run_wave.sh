#!/usr/bin/env bash
# usage: run_wave.sh 007:claude-opus-5 008:claude-opus-4-8 009:claude-opus-5 ...
#
# Launches one headless `claude -p` child per shard spec, in parallel, then appends one row
# per shard to verbdata/authored/metrics.jsonl. Skips shards whose .out.json already exists,
# so a killed run costs at most one shard's work.
#
# Consumes: prompts/example_prompt.md (the subagent brief, passed verbatim),
#           verbdata/authored/shards/auth_<NNN>.in.json
# Produces: verbdata/authored/shards/auth_<NNN>.out.json  (written by the child)
#           verbdata/authored/meta/auth_<NNN>.meta.json   (the child's raw --output-format json)
#           verbdata/authored/metrics.jsonl               (one row per completed shard)
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
# The A/B is only valid if the child actually ran on the model we asked for. `modelUsage` is
# keyed by the model ids that served the run; a silent fallback would otherwise be invisible.
# (claude-haiku-4-5 always appears too — Claude Code's own background/summarizer traffic.)
served = [k for k in (r.get('modelUsage') or {}) if not k.startswith('claude-haiku')]
row = {'shard': n, 'model': model, 'served_models': served, 'verbs': len(out),
       'en_chars': sum(len((v or {}).get('en', '')) for v in out.values()),
       'de_chars': sum(len((v or {}).get('de', '')) for v in out.values()),
       'duration_ms': r.get('duration_ms'), 'duration_api_ms': r.get('duration_api_ms'),
       'input_tokens': u.get('input_tokens'), 'output_tokens': u.get('output_tokens'),
       'cache_read_input_tokens': u.get('cache_read_input_tokens'),
       'cost_usd': r.get('total_cost_usd')}
open('verbdata/authored/metrics.jsonl', 'a').write(json.dumps(row, ensure_ascii=False) + '\n')
flag = '' if served == [model] else f'  !! served={served}'
print(f'recorded {n} {model}: {row["verbs"]} verbs, {row["en_chars"]} en-chars, '
      f'{row["output_tokens"]} out-tokens, {r.get("duration_api_ms")} api-ms{flag}')
PY
done
