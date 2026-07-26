#!/usr/bin/env bash
# usage: run_adjudication_wave.sh 000:claude-opus-4-8 001:claude-opus-4-8 ...
#
# Launches one headless `claude -p` adjudicator per shard, in parallel, then appends one row per
# shard to verbdata/adjudication/metrics.jsonl. Skips shards whose .out.json already exists.
#
# Third instance of the driver first written for verbdata/review/. Differences from the gloss-review
# copy, all consequences of adjudicating proposals rather than auditing a corpus:
#
#   1. COVERAGE IS ASSERTED, NOT ASSUMED. This is the big one. In the review pass an empty output was
#      the success case, which meant `{}` was byte-identical to what a reviewer would leave if it had
#      never opened the shard -- the pipeline's largest silent-failure surface, and unfixable there
#      without a third mid-sweep brief revision. The adjudication brief requires a verdict for EVERY
#      verb, so coverage is checkable, and this driver checks it: a shard whose output does not name
#      exactly its input's verbs is reported and its metrics row carries the shortfall.
#   2. VALID holds three verdicts rather than one finding type.
#   3. `amended_gloss` is required if and only if the verdict is `amend`, and is validated as such.
#   4. THE MODEL MUST DIFFER FROM THE PROPOSER. The gloss review ran entirely on claude-opus-5, so
#      claude-opus-5 authored every proposal here; adjudicating them on the same model is the
#      marking-your-own-homework problem the sentence review's cross-assignment existed to prevent.
#      That reasoning did NOT apply to the review pass itself -- no model wrote the shipped glosses,
#      kaikki did -- but it does apply the moment a model's own output is the thing under review.
#      Note that `claude-opus-4-8` is not offered by the interactive /model picker; the picker
#      curates, while --model passes through to the API, which still serves it.
#
# Consumes: prompts/gloss_adjudication.md (the brief, passed verbatim),
#           verbdata/adjudication/shards/adj_<NNN>.in.json
# Produces: verbdata/adjudication/shards/adj_<NNN>.out.json, meta/, metrics.jsonl
set -u
BASELINE="$(git status --porcelain -- . ':(exclude)verbdata/adjudication' 2>/dev/null || true)"
BRIEF="$(cat prompts/gloss_adjudication.md)"
BRIEF_SHA="$(shasum -a 256 prompts/gloss_adjudication.md | cut -c1-12)"
export BRIEF_SHA
mkdir -p verbdata/adjudication/meta
pids=()
ran=()
for spec in "$@"; do
  n="${spec%%:*}"; model="${spec##*:}"
  in="verbdata/adjudication/shards/adj_${n}.in.json"
  out="verbdata/adjudication/shards/adj_${n}.out.json"
  meta="verbdata/adjudication/meta/adj_${n}.meta.json"
  [ -f "$out" ] && { echo "skip ${n} (already done)"; continue; }
  [ -f "$in" ] || { echo "WARN ${n}: no input shard; run build_adjudication_shards.py"; continue; }
  prompt="${BRIEF}

Your shard file (read this): ${in}
Write your output to (this exact path): ${out}"
  claude -p "$prompt" --model "$model" --output-format json \
    --allowedTools "Read,Write" --permission-mode acceptEdits \
    > "$meta" 2>>verbdata/adjudication/run.log &
  pids+=($!)
  ran+=("$spec")
done
[ ${#pids[@]} -gt 0 ] && wait "${pids[@]}"

strays="$(comm -13 <(echo "$BASELINE" | sort) \
                   <(git status --porcelain -- . ':(exclude)verbdata/adjudication' 2>/dev/null | sort))"
[ -n "$strays" ] && { echo "!! adjudicators touched files outside verbdata/adjudication:"; echo "$strays"; }

for spec in "${ran[@]:-}"; do
  [ -n "$spec" ] || continue
  n="${spec%%:*}"; model="${spec##*:}"
  in="verbdata/adjudication/shards/adj_${n}.in.json"
  out="verbdata/adjudication/shards/adj_${n}.out.json"
  meta="verbdata/adjudication/meta/adj_${n}.meta.json"
  [ -f "$out" ] || { echo "WARN ${n}: no output (see run.log)"; continue; }
  python3 - "$n" "$model" "$in" "$out" "$meta" <<'PY'
import json, sys, os, collections
n, model, inp, outp, metap = sys.argv[1:6]
VALID = {'accept', 'reject', 'amend'}
try:
    out = json.load(open(outp))
except Exception as e:
    print(f'{n}: bad out.json ({e}) -- rm it and re-queue the shard'); sys.exit()
if not isinstance(out, dict):
    print(f'{n}: out.json is {type(out).__name__}, expected an object -- rm it and re-queue')
    sys.exit()
expected = {r['verb'] for r in json.load(open(inp))['records']}
got = {k for k in out if not k.startswith('_')}
uncovered = sorted(expected - got)
extra = sorted(got - expected)
verdicts = collections.Counter(
    (out[v] or {}).get('verdict') for v in got if isinstance(out.get(v), dict))
bad_verdicts = sorted(set(verdicts) - VALID)
# amended_gloss is required if and only if the verdict is amend -- a bare `amend` cannot be applied,
# and an amended_gloss on an accept/reject means the adjudicator did not follow the schema.
mismatched = sorted(
    v for v in got if isinstance(out.get(v), dict)
    and (bool((out[v].get('amended_gloss') or '').strip()) != (out[v].get('verdict') == 'amend')))
no_own = sorted(v for v in got if isinstance(out.get(v), dict)
                and not (out[v].get('own_gloss') or '').strip())
r = {}
if os.path.exists(metap):
    try:
        arr = json.load(open(metap))
        r = next((e for e in arr if isinstance(e, dict) and e.get('type') == 'result'), {})
    except Exception: pass
u = r.get('usage', {}) or {}
served = [k for k in (r.get('modelUsage') or {}) if not k.startswith('claude-haiku')]
row = {'shard': n, 'adjudicator': model, 'brief_sha': os.environ.get('BRIEF_SHA'),
       'served_models': served, 'expected': len(expected), 'covered': len(expected) - len(uncovered),
       'uncovered': uncovered, 'unexpected_verbs': extra,
       'accept': verdicts.get('accept', 0), 'reject': verdicts.get('reject', 0),
       'amend': verdicts.get('amend', 0), 'invalid_verdicts': bad_verdicts,
       'amend_field_mismatch': mismatched, 'missing_own_gloss': no_own,
       'duration_ms': r.get('duration_ms'), 'duration_api_ms': r.get('duration_api_ms'),
       'output_tokens': u.get('output_tokens'), 'cost_usd': r.get('total_cost_usd')}
open('verbdata/adjudication/metrics.jsonl', 'a').write(json.dumps(row, ensure_ascii=False) + '\n')
flag = ''
if uncovered: flag += f'  !! {len(uncovered)} verb(s) with no verdict: {uncovered[:4]}'
if extra: flag += f'  !! {len(extra)} verb(s) not in the shard'
if bad_verdicts: flag += f'  !! invalid verdicts {bad_verdicts}'
if mismatched: flag += f'  !! {len(mismatched)} amended_gloss/verdict mismatch'
if no_own: flag += f'  !! {len(no_own)} missing own_gloss'
if served != [model]: flag += f'  !! served={served}'
print(f'recorded {n} {model}: {row["covered"]}/{row["expected"]} covered, '
      f'{row["accept"]}a/{row["reject"]}r/{row["amend"]}m, {r.get("duration_api_ms")} api-ms{flag}')
PY
done
