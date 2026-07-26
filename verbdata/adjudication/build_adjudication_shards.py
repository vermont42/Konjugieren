#!/usr/bin/env python3
"""Build shards for the gloss adjudication — prompts/gloss_adjudication.md.

Consumes: verbdata/gloss-review/gloss-corrections-sweep.json  the 220 proposed corrections
          verbdata/gloss-review/shards/gloss_NNN.in.json      kaikki senses + separability
Produces: verbdata/adjudication/shards/adj_NNN.in.json        25 records each

Run from the repo root:  python3 verbdata/adjudication/build_adjudication_shards.py
  --corrections PATH   override the input corrections file
  --size N             records per shard (default 25)

WHY 25 AND NOT 50. The review shards held 50 verbs because a reviewer reads a word, a gloss, and a
candidate list. An adjudicator does more per record: it derives its own gloss first, then weighs a
proposal and an argument against it. Measured input is ~169 tokens per record against the review
shard's ~60 per verb, and the reasoning is deeper. Half the shard size keeps the per-shard cost in
the same band the wave driver's metrics were calibrated on.

WHY THIS IS CHEAP, WHICH IS THE POINT OF ADJUDICATING FINDINGS RATHER THAN RE-REVIEWING. The review
pass read 2,432 verbs to find 220 defects. This pass reads only the 220. At the review's measured
$0.68 per 50-verb shard, a second opinion on 100% of the writes costs roughly 10% of the sweep --
verification is cheap exactly when the defect rate is low, and that ratio would invert on data that
was mostly wrong.

WHAT IS DELIBERATELY NOT IN THE RECORD. The `traceability` field computed by
build_gloss_corrections.py -- whether a proposed gloss re-picks a listed kaikki sense or is the
reviewer's own invention -- is NOT passed to the adjudicator. Telling it "no dictionary backs this"
would anchor it toward rejection and destroy the independence that makes the second opinion worth
anything. It is far more useful as an orthogonal axis at merge time: if rejections cluster in the
authored bucket, that is evidence about the reviewer, and it is only evidence if the adjudicator
could not see the bucket.

The `severity` field IS passed, because it is the proposer's own claim about how bad the defect is
and the adjudicator should be able to hold it to that claim -- a `high` severity attached to a
cosmetic quibble is itself informative.

--PATTERN multi ADJUDICATES THE PER-READING SHARD, and adds two fields the per-verb records do not
have. Corrections on the 44 dual-auxiliary verbs are keyed `<verb>#<index>`, one per <reading>, so the
adjudicator is judging one of a verb's two glosses. It needs `auxiliary`, because on this population
the haben/sein split is generally the whole reason the second reading exists and is therefore the
strongest evidence about which sense a reading is supposed to name; and it needs `sibling_gloss`,
because two glosses on one lemma can each be defensible alone and still collapse into the same
English -- a defect visible only as a relationship between them, which a record showing one gloss at
a time hides by construction.
"""

import argparse
import glob
import json
import os

parser = argparse.ArgumentParser()
parser.add_argument("--corrections", default="verbdata/gloss-review/gloss-corrections-sweep.json")
parser.add_argument("--size", type=int, default=25)
parser.add_argument("--out", default="verbdata/adjudication/shards")
parser.add_argument("--pattern", choices=["gloss", "multi"], default="gloss",
                    help="which review shards hold the kaikki senses: 'gloss' (per verb) or "
                         "'multi' (per reading, keyed <verb>#<index>)")
args = parser.parse_args()
LIST_FIELD, KEY_FIELD = ("verbs", "verb") if args.pattern == "gloss" else ("readings", "key")

corrections = {k: v for k, v in json.load(open(args.corrections)).items() if not k.startswith("_")}
if not corrections:
    raise SystemExit(f"{args.corrections}: no corrections (header only) -- nothing to adjudicate")

# kaikki senses and separability come from the review shards, which read them from Verbs.xml.
meta = {}
for f in glob.glob(f"verbdata/gloss-review/shards/{args.pattern}_*.in.json"):
    for entry in json.load(open(f))[LIST_FIELD]:
        meta[entry[KEY_FIELD]] = entry

missing = sorted(v for v in corrections if v not in meta)
if missing:
    raise SystemExit(
        f"{len(missing)} corrected verb(s) absent from the review shards: {', '.join(missing[:8])}.\n"
        "Refusing: without candidate_glosses the adjudicator has no dictionary to judge against, and "
        "a record silently missing that field would be judged on the proposal alone."
    )

records = []
for key in sorted(corrections):
    fix = corrections[key]
    entry = meta[key]
    record = {
        "verb": entry["verb"] if args.pattern == "multi" else key,
        "separability": entry.get("separability"),
        "shipped_gloss": fix["old"],
        "proposed_gloss": fix["new"],
        "severity": fix.get("severity"),
        "reviewer_detail": fix.get("why", ""),
        "candidate_glosses": entry.get("candidate_glosses") or [],
    }
    if args.pattern == "multi":
        # `key` is what the verdict must come back under; `verb` alone names two glosses.
        record = {"key": key, **record, "auxiliary": entry.get("auxiliary"),
                  "sibling_gloss": entry.get("sibling_gloss")}
    records.append(record)

os.makedirs(args.out, exist_ok=True)
shards = [records[i:i + args.size] for i in range(0, len(records), args.size)]
for n, chunk in enumerate(shards):
    path = f"{args.out}/adj_{n:03d}.in.json"
    with open(path, "w") as fh:
        json.dump({"shard": n, "records": chunk}, fh, ensure_ascii=False, indent=1)
        fh.write("\n")

print(f"{len(records)} correction(s) -> {len(shards)} shard(s) of {args.size} in {args.out}")
print("specs for the wave driver:")
print("  " + " ".join(f"{n:03d}:claude-opus-4-8" for n in range(len(shards))))
