#!/usr/bin/env python3
"""Apply adjudication verdicts to the proposed corrections, producing the file that ships.

Consumes: verbdata/gloss-review/gloss-corrections-sweep.json   220 proposals (claude-opus-5)
          verbdata/adjudication/shards/adj_NNN.out.json        verdicts (claude-opus-4-8)
Produces: verbdata/gloss-review/gloss-corrections-final.json   accepted + amended, for the applier
          verbdata/adjudication/triage.md                      the full record, including rejections

Run from the repo root:  python3 verbdata/adjudication/merge_verdicts.py
  --partial   proceed although some proposals have no verdict

Feed the output to:
  python3 verbdata/authored/apply_gloss_corrections.py verbdata/gloss-review/gloss-corrections-final.json --dry-run

WHAT EACH VERDICT DOES:
  accept  the proposal is written as-is.
  amend   the adjudicator's amended_gloss replaces the proposal. `source` records both models,
          because the resulting gloss is neither one's unaided work.
  reject  the correction is DROPPED and the shipped gloss survives. Recorded in triage.md, never
          silently discarded -- a rejection is a finding about the reviewer, and the whole reason
          this pass is worth its cost is that those are visible afterward.

THE CROSS-TABULATION AT THE BOTTOM IS THE POINT, NOT DECORATION. build_gloss_shards' traceability
class -- whether a proposed gloss re-picks a listed kaikki sense or is the reviewer's own invention
-- was deliberately withheld from the adjudicator (see build_adjudication_shards.py). That makes
verdict-by-traceability a genuine measurement rather than a tautology. If rejections concentrate in
`authored`, the reviewer's failure mode is invention and the traceability class is a usable filter
for future runs. If they spread evenly, traceability predicts nothing and should stop being
presented as a confidence signal. Either answer is worth having; the wrong design was the one that
told the adjudicator the answer first.

A NOTE ON `own_gloss`. The brief requires the adjudicator to write its own gloss before reading the
proposal. It is carried into the record but NOT used as a gate: agreement between two models on
wording is weak evidence about a language and strong evidence only about the models. It is here so a
human triager can see, at a glance, when both models independently landed on the same phrase --
which is the closest thing this pipeline has to corroboration.
"""

import argparse
import collections
import glob
import json
import os

parser = argparse.ArgumentParser()
parser.add_argument("--corrections", default="verbdata/gloss-review/gloss-corrections-sweep.json")
parser.add_argument("--out", default="verbdata/gloss-review/gloss-corrections-final.json")
parser.add_argument("--triage", default="verbdata/adjudication/triage.md")
parser.add_argument("--verdicts", default="verbdata/adjudication/shards/adj_*.out.json",
                    help="glob of adjudicator output; the per-reading run writes to shards-multi/")
parser.add_argument("--partial", action="store_true")
args = parser.parse_args()

proposals = {k: v for k, v in json.load(open(args.corrections)).items() if not k.startswith("_")}

verdicts, malformed = {}, []
for f in sorted(glob.glob(args.verdicts)):
    try:
        data = json.load(open(f))
    except Exception as exc:
        malformed.append((f, f"unparseable: {exc}"))
        continue
    if not isinstance(data, dict):
        malformed.append((f, f"top level is {type(data).__name__}"))
        continue
    for verb, payload in data.items():
        if not verb.startswith("_") and isinstance(payload, dict):
            verdicts[verb] = payload

unjudged = sorted(v for v in proposals if v not in verdicts)
if unjudged and not args.partial:
    raise SystemExit(
        f"{len(unjudged)} of {len(proposals)} proposals have no verdict "
        f"({', '.join(unjudged[:6])}{' ...' if len(unjudged) > 6 else ''}).\n"
        "Refusing: a corrections file merged from a partial adjudication looks exactly like a fully "
        "adjudicated one once written. Re-run with --partial if that is what you intend."
    )

final, rejected, amended, bad = {}, [], [], []
for verb in sorted(proposals):
    prop = proposals[verb]
    v = verdicts.get(verb)
    if v is None:
        continue
    verdict = v.get("verdict")
    if verdict == "reject":
        rejected.append((verb, prop, v))
        continue
    if verdict == "amend":
        new = (v.get("amended_gloss") or "").strip()
        if not new:
            bad.append((verb, prop, v, "amend with no amended_gloss"))
            continue
        if new == prop["old"]:
            # An amendment back to the shipped gloss is a rejection wearing a different hat.
            rejected.append((verb, prop, v))
            continue
        amended.append((verb, prop, v))
        source = "claude-opus-5, amended by claude-opus-4-8"
    elif verdict == "accept":
        new = prop["new"]
        source = "claude-opus-5, confirmed by claude-opus-4-8"
    else:
        bad.append((verb, prop, v, f"unrecognized verdict {verdict!r}"))
        continue
    final[verb] = {
        "old": prop["old"],
        "new": new,
        "why": v.get("reason") or prop.get("why", ""),
        "severity": prop.get("severity"),
        "traceability": prop.get("traceability"),
        "verdict": verdict,
        "adjudicator_own_gloss": v.get("own_gloss"),
        "shard": prop.get("shard"),
        "source": source,
    }

for path in (args.out, args.triage):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)

header = {
    "_source": args.corrections,
    "_adjudicated_by": "claude-opus-4-8",
    "_brief": "prompts/gloss_adjudication.md",
    "_proposed": len(proposals),
    "_accepted": sum(1 for c in final.values() if c["verdict"] == "accept"),
    "_amended": len(amended),
    "_rejected": len(rejected),
    "_unjudged": unjudged,
}
with open(args.out, "w") as fh:
    json.dump({**header, **final}, fh, ensure_ascii=False, indent=2)
    fh.write("\n")

# verdict x traceability -- see the docstring on why this is a real measurement
cross = collections.Counter()
for verb, prop in proposals.items():
    v = verdicts.get(verb)
    if v:
        cross[(prop.get("traceability"), v.get("verdict"))] += 1

lines = [
    f"# Adjudication triage — {len(verdicts)} of {len(proposals)} proposals judged",
    "",
    f"**{header['_accepted']} accepted · {len(amended)} amended · {len(rejected)} rejected.** "
    f"{len(final)} correction(s) written to `{args.out}`.",
    "",
    "## Verdict by traceability",
    "",
    "Traceability was withheld from the adjudicator, so this table measures something.",
    "",
    "| | accept | amend | reject |",
    "|---|---|---|---|",
]
for tkey in ("repick", "partial", "authored"):
    row = [cross[(tkey, w)] for w in ("accept", "amend", "reject")]
    lines.append(f"| {tkey} | {row[0]} | {row[1]} | {row[2]} |")
lines.append("")
if unjudged:
    lines += [f"> **PARTIAL.** {len(unjudged)} proposal(s) never judged: {', '.join(unjudged)}.", ""]

if rejected:
    lines += [f"## Rejected — shipped gloss survives ({len(rejected)})", ""]
    for verb, prop, v in rejected:
        lines.append(
            f"- **{verb}** keeps `{prop['old']}`, proposal `{prop['new']}` rejected "
            f"({prop.get('traceability')}) — {v.get('reason', '')}"
        )
    lines.append("")
if amended:
    lines += [f"## Amended — neither model's original wording ({len(amended)})", ""]
    for verb, prop, v in amended:
        lines.append(
            f"- **{verb}** `{prop['old']}` → `{v['amended_gloss']}` "
            f"(proposal was `{prop['new']}`) — {v.get('reason', '')}"
        )
    lines.append("")
accepted = [(k, c) for k, c in final.items() if c["verdict"] == "accept"]
if accepted:
    lines += [f"## Accepted ({len(accepted)})", ""]
    for verb, c in accepted:
        agree = " ✓ both models wrote the same gloss independently" \
            if (c.get("adjudicator_own_gloss") or "").strip().lower() == c["new"].strip().lower() else ""
        lines.append(f"- **{verb}** `{c['old']}` → `{c['new']}` ({c['traceability']}){agree}")
    lines.append("")
if bad:
    lines += [f"## Malformed verdicts — not applied ({len(bad)})", ""]
    lines += [f"- **{verb}**: {why}" for verb, _, _, why in bad] + [""]
if malformed:
    lines += ["## Malformed adjudicator output", ""]
    lines += [f"- {f}: {why}" for f, why in malformed] + [""]
open(args.triage, "w").write("\n".join(lines))

print(f"{len(verdicts)}/{len(proposals)} judged: {header['_accepted']} accept, "
      f"{len(amended)} amend, {len(rejected)} reject")
print(f"  {len(final)} correction(s) -> {args.out}")
print(f"  triage -> {args.triage}")
for tkey in ("repick", "partial", "authored"):
    tot = sum(cross[(tkey, w)] for w in ("accept", "amend", "reject"))
    if tot:
        print(f"  {tkey}: {cross[(tkey, 'reject')]}/{tot} rejected")
if bad:
    print(f"  !! {len(bad)} malformed verdict(s)")
if unjudged:
    print(f"  !! PARTIAL: {len(unjudged)} unjudged")
