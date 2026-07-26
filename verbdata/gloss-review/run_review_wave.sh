#!/usr/bin/env bash
# usage: run_review_wave.sh 000:claude-opus-5 001:claude-opus-5 ...
#
# Launches one headless `claude -p` gloss reviewer per shard, in parallel, then appends one row per
# shard to verbdata/gloss-review/metrics.jsonl. Skips shards whose .out.json already exists, so a
# killed run costs at most one shard.
#
# Adapted from verbdata/review/run_review_wave.sh, which reviewed example sentences. Four
# differences, all consequences of auditing a gloss rather than a sentence:
#
#   1. The brief is prompts/gloss_review.md and the shards are gloss_NNN, 50 verbs each rather
#      than 25. A gloss review reads a word, a gloss, and a candidate list; it does not read a
#      sentence or write a replacement one, so the per-verb cost is lower and the shard is bigger.
#   2. VALID holds one type. `bad_gloss` is the only finding the brief defines -- `wrong_sense` is
#      meaningless with no sentence to be wrong about -- so any other type is a reviewer that
#      drifted, and the triage step would drop it silently.
#   3. Findings missing `fix_gloss` are counted and flagged. The brief requires it because
#      build_gloss_corrections.py cannot emit a correction without a replacement gloss. A reviewer
#      that omits it produces findings that cost a window and apply to nothing, which is worth
#      catching per shard while the run can still be stopped.
#   4. Cross-assignment is deliberately absent. No model authored these glosses -- kaikki did, via
#      verbdata/build_candidates.py -- so there is no conflict of interest to design around. Pass
#      one model for every shard, for consistency of threshold.
#
# EMPTY RESULTS ARE THE SUCCESS CASE, as in the sentence review: a shard with nothing wrong writes
# `{}`. The validity check below parses the JSON rather than testing file size, because a size test
# would invert the signal on every clean shard.
#
# Consumes: prompts/gloss_review.md (the brief, passed verbatim),
#           verbdata/gloss-review/shards/gloss_<NNN>.in.json (build_gloss_shards.py makes these)
# Produces: verbdata/gloss-review/shards/gloss_<NNN>.out.json, meta/, metrics.jsonl
#
# THE BRIEF HASH IS RECORDED PER SHARD, and it is not decoration. The brief was amended mid-sweep on
# 2026-07-25 after a verification pass measured the reviewer's biases (severity compressed into
# medium, comma-joined multi-sense fix_gloss values, and a recall gap on common verbs whose English
# reads well). Shards reviewed before and after that amendment are not strictly comparable, and a
# future reader deserves to know which brief produced a given finding rather than inferring it from
# timestamps. Recording a hash costs nothing and cannot drift the way a hand-maintained version
# string would.
set -u
# Baseline snapshot for the stray-file check after the wait. Without it the check reports the
# orchestrator's OWN in-flight edits -- an amended brief, a patched applier -- as reviewer strays,
# which is how it behaved on its first firing. Only paths that changed DURING the wave are strays.
BASELINE="$(git status --porcelain -- . ':(exclude)verbdata/gloss-review' 2>/dev/null || true)"
BRIEF="$(cat prompts/gloss_review.md)"
BRIEF_SHA="$(shasum -a 256 prompts/gloss_review.md | cut -c1-12)"
export BRIEF_SHA
mkdir -p verbdata/gloss-review/meta
pids=()
ran=()
for spec in "$@"; do
  n="${spec%%:*}"; model="${spec##*:}"
  in="verbdata/gloss-review/shards/gloss_${n}.in.json"
  out="verbdata/gloss-review/shards/gloss_${n}.out.json"
  meta="verbdata/gloss-review/meta/gloss_${n}.meta.json"
  [ -f "$out" ] && { echo "skip ${n} (already done)"; continue; }
  [ -f "$in" ] || { echo "WARN ${n}: no input shard; run build_gloss_shards.py"; continue; }
  prompt="${BRIEF}

Your shard file (read this): ${in}
Write your output to (this exact path): ${out}"
  claude -p "$prompt" --model "$model" --output-format json \
    --allowedTools "Read,Write" --permission-mode acceptEdits \
    > "$meta" 2>>verbdata/gloss-review/run.log &
  pids+=($!)
  ran+=("$spec")
done
[ ${#pids[@]} -gt 0 ] && wait "${pids[@]}"

# The reviewers run with unrestricted Write under acceptEdits, sixteen at a time, in a tree holding
# Konjugieren/Models/Verbs.xml. The only thing keeping them out of shipping data is prose in the
# brief. This converts that prose into an enforced check: anything touched outside the review
# directory is reported loudly rather than discovered later by `git diff`.
strays="$(comm -13 <(echo "$BASELINE" | sort) \
                   <(git status --porcelain -- . ':(exclude)verbdata/gloss-review' 2>/dev/null | sort))"
[ -n "$strays" ] && { echo "!! reviewers touched files outside verbdata/gloss-review:"; echo "$strays"; }

# Metrics are recorded only for shards this invocation actually launched. Iterating "$@" here would
# re-record shards that loop 1 skipped as already-done, appending duplicate rows that double-count
# findings, tokens, and cost the next time a killed wave is re-queued.
for spec in "${ran[@]:-}"; do
  [ -n "$spec" ] || continue
  n="${spec%%:*}"; model="${spec##*:}"
  out="verbdata/gloss-review/shards/gloss_${n}.out.json"
  meta="verbdata/gloss-review/meta/gloss_${n}.meta.json"
  [ -f "$out" ] || { echo "WARN ${n}: no output (see run.log)"; continue; }
  python3 - "$n" "$model" "$out" "$meta" <<'PY'
import json, sys, os, collections
n, model, outp, metap = sys.argv[1:5]
VALID = {'bad_gloss'}
VALID_SEV = {'high', 'medium', 'low'}
try:
    out = json.load(open(outp))
except Exception as e:
    print(f'{n}: bad out.json ({e}) -- rm it and re-queue the shard'); sys.exit()
# A non-dict output would raise OUTSIDE the try above, losing the metrics row while leaving the
# out.json in place -- and loop 1 skips any shard whose out.json exists, so that shard would be
# permanently unreviewed and permanently invisible.
if not isinstance(out, dict):
    print(f'{n}: out.json is {type(out).__name__}, expected an object -- rm it and re-queue')
    sys.exit()
findings = [f for v in out.values() if isinstance(v, dict) for f in (v.get('findings') or [])]
bad_types = sorted({f.get('type') for f in findings} - VALID)
bad_sev = sorted({str(f.get('severity')) for f in findings} - VALID_SEV)
no_fix = sum(1 for f in findings if not (f.get('fix_gloss') or '').strip())
sev = collections.Counter(f.get('severity') for f in findings)
r = {}
if os.path.exists(metap):
    try:
        arr = json.load(open(metap))
        r = next((e for e in arr if isinstance(e, dict) and e.get('type') == 'result'), {})
    except Exception: pass
u = r.get('usage', {}) or {}
served = [k for k in (r.get('modelUsage') or {}) if not k.startswith('claude-haiku')]
row = {'shard': n, 'reviewer': model, 'brief_sha': os.environ.get('BRIEF_SHA'), 'served_models': served,
       'verbs_with_findings': len(out), 'findings': len(findings),
       'high': sev.get('high', 0), 'medium': sev.get('medium', 0), 'low': sev.get('low', 0),
       'invalid_types': bad_types, 'invalid_severities': bad_sev, 'missing_fix_gloss': no_fix,
       'duration_ms': r.get('duration_ms'), 'duration_api_ms': r.get('duration_api_ms'),
       'output_tokens': u.get('output_tokens'), 'cost_usd': r.get('total_cost_usd')}
open('verbdata/gloss-review/metrics.jsonl', 'a').write(json.dumps(row, ensure_ascii=False) + '\n')
flag = ''
if bad_types: flag += f'  !! invalid types {bad_types}'
if bad_sev: flag += f'  !! invalid severities {bad_sev}'
if no_fix: flag += f'  !! {no_fix} finding(s) with no fix_gloss'
# A shard with zero findings is a legitimate success, but it is byte-identical to the artifact a
# reviewer would leave if it never read the shard. Nothing in the output attests coverage, so flag
# it for a human glance rather than letting it pass as measured cleanliness.
if not findings: flag += '  ?? zero findings -- confirm the reviewer actually read the shard'
if served != [model]: flag += f'  !! served={served}'
print(f'recorded {n} {model}: {len(findings)} findings on {len(out)} verbs '
      f'(h{row["high"]}/m{row["medium"]}/l{row["low"]}), {r.get("duration_api_ms")} api-ms{flag}')
PY
done
