#!/usr/bin/env python3
"""Collapse gloss-review findings into a corrections file apply_gloss_corrections.py can write.

Consumes: verbdata/gloss-review/shards/gloss_NNN.out.json   reviewer findings
          verbdata/gloss-review/shards/gloss_NNN.in.json    shipped gloss + kaikki candidates
Produces: verbdata/gloss-review/gloss-corrections-sweep.json  (verb -> {old, new, why, ...})
          verbdata/gloss-review/triage.md                     human-readable, traceability-sorted

Run from the repo root:  python3 verbdata/authored/build_gloss_corrections.py
  --min-severity high|medium|low   default low (everything)
  --partial                        REQUIRED if some input shards have no output yet
  --out PATH / --triage PATH       override destinations

WHY THIS STEP EXISTS AT ALL. The reviewer and the applier speak different shapes on purpose. A
finding is a review artifact: typed, severity-ranked, and free to hedge in prose. A correction is a
write artifact: it asserts that Verbs.xml currently holds `old`, and apply_gloss_corrections.py
refuses the whole file if that assertion fails anywhere. Keeping them separate is what lets the
apply step detect drift -- if Verbs.xml changed between review and application, `old` no longer
matches and nothing is written. Fusing the two would lose that.

WHERE `old` COMES FROM, AND WHY NOT FROM THE FINDING. The reviewer is never asked to echo the gloss
it is criticizing, and asking would invite a paraphrase. The shipped gloss is read back out of the
INPUT shard instead, which is the same value build_gloss_shards.py read from Verbs.xml. That makes
`old` a fact about the corpus rather than a reviewer assertion.

COVERAGE IS ASSERTED, NOT INFERRED. An earlier version counted output shards and reported that
number as if it were the sweep. Run against a third of the shards it emitted a corrections file
whose header said `_shards_reviewed: 16` and said nothing at all about the 33 shards that had never
been reviewed -- a partial sweep wearing the costume of a complete one. This version reconciles the
output set against the INPUT set, names the missing shards in both the header and triage.md, and
refuses to run at all without --partial when they differ. The repo has been bitten by exactly this
shape before; see CLAUDE.md on test filters that report success while running nothing.

TRACEABILITY IS COMPUTED, AND IT IS THE MOST IMPORTANT COLUMN HERE. The brief asks the reviewer to
name the kaikki sense index when the correct meaning was already in candidate_glosses, "because that
makes it a mechanical import defect rather than a judgment call, and those are applied with more
confidence." That distinction was being thrown away into free prose. It is recoverable for free:
compare fix_gloss against the candidate list. The split matters because the two classes carry
different risk. A re-pick restores a sense a dictionary already attests. An authored gloss replaces
an attested phrase with one no source backs -- and the error costs are asymmetric, since a missed
defect merely leaves kaikki's wording in place while a false positive ships a model's invention.
Measured over the first 16 shards, only about a quarter of proposed replacements were re-picks.

--PATTERN multi SERVES THE PER-READING SHARD, AND THE UNIT OF WORK BECOMES A READING. The 44
dual-auxiliary verbs carry two <reading> elements with a gloss each, so `abbrechen` names two glosses
and cannot be a correction key. build_gloss_shards.py --multi-reading emits `readings`, keyed
`<verb>#<index>`, and apply_gloss_corrections.py accepts that key. Everything below is unchanged by
it: a key is an opaque string here, and "one gloss per key" holds either way. Only the shard glob,
the record list's field name, and which field is the key differ, which is why this is a pattern flag
rather than a second script.

MULTIPLE FINDINGS ON ONE VERB collapse to one correction, because a verb has one gloss. The pick is
the highest-severity finding THAT CARRIES A fix_gloss -- not simply the highest-severity one. An
earlier version took the top-severity finding unconditionally and, when that finding happened to
lack a replacement, filed the verb's remaining actionable finding under "second opinions, not
applied (verb already corrected above)". The verb had not been corrected above. A triager reading
that heading would skip the only usable finding on the verb.
"""

import argparse
import collections
import glob
import json
import os
import re

RANK = {"high": 0, "medium": 1, "low": 2}
VALID_SEV = set(RANK)

parser = argparse.ArgumentParser()
parser.add_argument("--min-severity", choices=["high", "medium", "low"], default="low")
parser.add_argument("--partial", action="store_true",
                    help="proceed even though some input shards have no reviewer output")
parser.add_argument("--out", default="verbdata/gloss-review/gloss-corrections-sweep.json")
parser.add_argument("--triage", default="verbdata/gloss-review/triage.md")
parser.add_argument("--pattern", choices=["gloss", "multi"], default="gloss",
                    help="'gloss' reads the 49 per-verb shards; 'multi' reads the per-reading "
                         "shard, whose records are keyed <verb>#<index>")
args = parser.parse_args()
cutoff = RANK[args.min_severity]

SHARDS = "verbdata/gloss-review/shards"
PREFIX = args.pattern
# The two shard shapes differ in one field name each: the record list, and the record's key.
LIST_FIELD, KEY_FIELD = ("verbs", "verb") if PREFIX == "gloss" else ("readings", "key")


def shard_id(path):
    return re.search(rf"{PREFIX}_(\d+)", path).group(1)


in_ids = {shard_id(f) for f in glob.glob(f"{SHARDS}/{PREFIX}_*.in.json")}
out_ids = {shard_id(f) for f in glob.glob(f"{SHARDS}/{PREFIX}_*.out.json")}
missing = sorted(in_ids - out_ids)
if missing and not args.partial:
    raise SystemExit(
        f"{len(missing)} of {len(in_ids)} shards have no reviewer output "
        f"({', '.join(missing[:6])}{' ...' if len(missing) > 6 else ''}).\n"
        "Refusing: a corrections file built from a partial sweep is indistinguishable from a "
        "complete one once written. Re-run with --partial if that is what you intend."
    )


def normalize(text):
    """Lowercase, drop a leading 'to ', collapse whitespace. Used only for substring comparison."""
    return re.sub(r"\s+", " ", re.sub(r"^to\s+", "", (text or "").strip().lower()))


def trace(fix, candidates):
    """Classify a proposed gloss against the kaikki senses the importer had available.

    `repick`   the whole replacement appears inside some listed sense -- a mechanical import defect,
               the highest-confidence class to apply.
    `partial`  at least one comma-separated synonym appears in some listed sense.
    `authored` nothing in the replacement appears in any listed sense. This is the reviewer's own
               lexicography, and it is the class that most deserves a human eye before it ships.
    """
    fixn = normalize(fix)
    cands = [normalize(c) for c in (candidates or [])]
    if not fixn or not cands:
        return "authored"
    if any(fixn in c for c in cands):
        return "repick"
    parts = [p.strip() for p in fixn.split(",") if p.strip()]
    if any(any(p in c for c in cands) for p in parts):
        return "partial"
    return "authored"


# shipped gloss and candidate senses per key, from the INPUT shards -- see the docstring
shipped, cands_of, shard_of = {}, {}, {}
for f in sorted(glob.glob(f"{SHARDS}/{PREFIX}_*.in.json")):
    n = shard_id(f)
    for entry in json.load(open(f))[LIST_FIELD]:
        key = entry[KEY_FIELD]
        shipped[key] = entry["gloss"]
        cands_of[key] = entry.get("candidate_glosses") or []
        shard_of[key] = n

findings, malformed = [], []
for f in sorted(glob.glob(f"{SHARDS}/{PREFIX}_*.out.json")):
    n = shard_id(f)
    try:
        data = json.load(open(f))
    except Exception as exc:
        malformed.append((n, f"unparseable: {exc}"))
        continue
    if not isinstance(data, dict):
        malformed.append((n, f"top level is {type(data).__name__}, expected object"))
        continue
    for verb, payload in data.items():
        if verb.startswith("_"):
            continue
        for finding in (payload or {}).get("findings", []):
            findings.append((verb, n, finding))

by_verb = collections.defaultdict(list)
for verb, n, finding in findings:
    by_verb[verb].append((n, finding))

corrections = {}
dropped, below_cutoff, bad_severity, unknown, alternates = [], [], [], [], []
for verb in sorted(by_verb):
    entries = by_verb[verb]
    for n, finding in entries:
        sev = finding.get("severity")
        if sev not in VALID_SEV:
            bad_severity.append((verb, finding))
    usable = [(n, f) for n, f in entries
              if (f.get("fix_gloss") or "").strip() and f.get("severity") in VALID_SEV]
    if not usable:
        for n, finding in entries:
            if finding.get("severity") in VALID_SEV:
                dropped.append((verb, finding))
        continue
    usable.sort(key=lambda e: RANK[e[1]["severity"]])
    n, best = usable[0]
    if verb not in shipped:
        unknown.append((verb, best))
        continue
    if RANK[best["severity"]] > cutoff:
        below_cutoff.append((verb, best))
        continue
    fix = best["fix_gloss"].strip()
    corrections[verb] = {
        "old": shipped[verb],
        "new": fix,
        "why": best.get("detail", ""),
        "severity": best["severity"],
        "traceability": trace(fix, cands_of[verb]),
        "candidate_index": best.get("candidate_index"),
        "shard": n,
        "reviewer": "claude-opus-5",
    }
    # Only now is the verb actually corrected, so only now is a second finding a "second opinion".
    for other_n, other in usable[1:]:
        alternates.append((verb, other))

for path in (args.out, args.triage):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)

header = {
    "_source": f"{SHARDS}/{PREFIX}_*.out.json",
    "_brief": "prompts/gloss_review.md",
    "_min_severity": args.min_severity,
    "_shards_total": len(in_ids),
    "_shards_reviewed": len(out_ids),
    "_shards_missing": missing,
    "_partial": bool(missing),
}
with open(args.out, "w") as fh:
    json.dump({**header, **corrections}, fh, ensure_ascii=False, indent=2)
    fh.write("\n")

sev_counts = collections.Counter(c["severity"] for c in corrections.values())
trace_counts = collections.Counter(c["traceability"] for c in corrections.values())
lines = [
    f"# Gloss sweep triage — {len(out_ids)} of {len(in_ids)} shards reviewed",
    "",
    f"{len(findings)} finding(s) on {len(by_verb)} verb(s). "
    f"{len(corrections)} correction(s) written to `{args.out}` "
    f"(high {sev_counts['high']}, medium {sev_counts['medium']}, low {sev_counts['low']}).",
    "",
    f"**Traceability:** {trace_counts['repick']} re-pick a sense kaikki already listed, "
    f"{trace_counts['partial']} partially, "
    f"**{trace_counts['authored']} are the reviewer's own wording with no source behind them.** "
    "The last group replaces an attested gloss with an unattested one and deserves the closest read.",
    "",
]
if missing:
    lines += [
        f"> **PARTIAL SWEEP.** {len(missing)} shard(s) have no reviewer output and are not "
        f"represented here: {', '.join(missing)}.",
        "",
    ]

# Sorted so the judgment calls come first: authored replacements need a human, re-picks mostly don't.
ORDER = {"authored": 0, "partial": 1, "repick": 2}
for tkey, title in (("authored", "Reviewer's own wording — no kaikki sense behind it"),
                    ("partial", "Partially traceable to a kaikki sense"),
                    ("repick", "Re-pick of a sense kaikki already listed")):
    picks = [(v, c) for v, c in corrections.items() if c["traceability"] == tkey]
    picks.sort(key=lambda vc: (RANK[vc[1]["severity"]], vc[0]))
    if not picks:
        continue
    lines += [f"## {title} ({len(picks)})", ""]
    for verb, c in picks:
        lines.append(f"- **{verb}** ({c['severity']}) `{c['old']}` → `{c['new']}` — {c['why']}")
        for _, alt in [(v, a) for v, a in alternates if v == verb]:
            lines.append(
                f"  - *also proposed* ({alt.get('severity')}): "
                f"`{alt.get('fix_gloss')}` — {alt.get('detail', '')}"
            )
    lines.append("")

for title, items in (
    ("Dropped: no finding on this verb carried a fix_gloss", dropped),
    ("Below the severity cutoff", below_cutoff),
    ("Unrecognized severity value — not applied", bad_severity),
    ("Verb not present in any input shard", unknown),
):
    if not items:
        continue
    lines += [f"## {title} ({len(items)})", ""]
    for verb, finding in items:
        lines.append(
            f"- **{verb}** ({finding.get('severity')}) → "
            f"`{finding.get('fix_gloss') or '—'}` — {finding.get('detail', '')}"
        )
    lines.append("")
if malformed:
    lines += ["## Malformed reviewer output — these shards contributed nothing", ""]
    lines += [f"- shard {n}: {why}" for n, why in malformed] + [""]
open(args.triage, "w").write("\n".join(lines))

print(f"{len(out_ids)}/{len(in_ids)} shards, {len(findings)} finding(s) on {len(by_verb)} verb(s)")
print(f"  {len(corrections)} correction(s) -> {args.out}")
print(f"  traceability: {trace_counts['repick']} re-pick / {trace_counts['partial']} partial / "
      f"{trace_counts['authored']} authored")
for label, items in (("no fix_gloss", dropped), ("below cutoff", below_cutoff),
                     ("bad severity", bad_severity), ("unknown verb", unknown),
                     ("second opinions", alternates), ("malformed shards", malformed)):
    if items:
        print(f"  {len(items)} {label} (see {args.triage})")
if missing:
    print(f"  !! PARTIAL: {len(missing)} shard(s) unreviewed: {', '.join(missing)}")
