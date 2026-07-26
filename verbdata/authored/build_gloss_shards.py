#!/usr/bin/env python3
"""Build shards for the gloss audit — prompts/gloss_review.md, item 1 of
prompts/example_review_followups.md.

Consumes:
  Konjugieren/Models/Verbs.xml        the shipped gloss, in the tn attribute of <reading>
  verbdata/candidates.json            the full kaikki gloss list per verb
  verbdata/authored/provenance.json   the 1,097 verbs the example-sentence review already covered

Produces, in the default single-reading mode:
  verbdata/gloss-review/shards/gloss_NNN.in.json    50 verbs each
  verbdata/gloss-review/skipped-multi-reading.txt   verbs excluded, with their readings

Produces, with --multi-reading:
  verbdata/gloss-review/shards/multi_000.in.json    one record per READING, 88 of them

Run from the repo root:  python3 verbdata/authored/build_gloss_shards.py [--multi-reading]

WHAT IS BEING AUDITED, AND WHY IT IS NOT THE SENTENCES. The adversarial review of 2026-07-25 read
1,097 verbs and found 55 defective glosses, 5.0%. It found them incidentally: it was reading example
sentences, and a gloss that disagreed with its sentence was visible as a side effect. Those 1,097
verbs were selected by which verbs the corpus-mining pipeline could not serve — nothing about that
correlates with gloss quality — so the remaining 2,475 shipping verbs have never had their glosses
read by anything. At the observed rate, expect roughly 124 wrong glosses currently shipping.

WHY EVERY VERB IS SHARDED, NOT JUST THE SUSPICIOUS ONES. The obvious economy is to audit only verbs
where kaikki listed several senses and the importer shipped the first, on the theory that it took
entry order for frequency. Measured against the review's own findings, using the same match_sense
below: of 377 reviewed first-sense picks, 40 were defective — 11% precision — and 15 of the 55
defects were not first-sense picks at all, 27% missed.

That is a real filter, and honesty requires saying so: applied here it would cut 2,432 verbs to 993
and still find something like seven of every eight defects. The reason to sweep everything anyway is
that the saving is 59% of a cheap one-time pass over data that already ships, and the price is ~13
wrong glosses left in the app with nothing left that would ever look at them again. Nine clean verbs
per real defect is also a poor experience for the reviewer, who calibrates on what it is shown.

If a future run is under real window pressure, shard the first-sense picks FIRST and the rest after;
that gets the same 88% early and leaves a resumable tail, which is strictly better than filtering.
The flag is emitted INSIDE the shard as `sense_index` either way, as a hint to the reviewer.

WHY candidate_glosses IS ALWAYS EMITTED HERE. build_review_shards.py emits it only when kaikki found
more than one sense, because for a sentence reviewer a single-gloss list adds nothing. For a gloss
reviewer it is the opposite: "kaikki listed exactly one sense and we shipped it" is itself a
finding-relevant fact, because it tells the reviewer that a disagreement is a judgment call against
the dictionary rather than a wrong pick among options. Nine of the review's 55 findings were of that
kind, and they were the ones its `detail` prose hedged on.

MULTI-READING VERBS ARE SKIPPED BY THE DEFAULT MODE, LOUDLY — AND SERVED BY --multi-reading.
add_readings.py gave 44 dual-auxiliary verbs a second <reading>, each with its own tn. On such a verb
"the shipped gloss" is not a single value, and apply_gloss_corrections.py originally refused to write
one rather than guess which sense to rewrite, so the default mode excludes them and lists them in
skipped-multi-reading.txt rather than dropping them in silence. That exclusion was mechanical, never
linguistic: each reading has its own gloss and each is independently auditable.

--multi-reading audits them, emitting one record per READING keyed `<verb>#<index>`. The applier now
accepts that key (see apply_gloss_corrections.py), which is what unblocked the population. Three
things the per-reading record must carry, each learned by looking at the data rather than assumed:

  * SEPARABILITY IS PER READING, NOT PER VERB. Nine of the 44 readings carry their own `in=`
    overriding the parent <verb>: `übersetzen` is inseparable `über*setzen` (übersétzen, translate)
    in reading 0 and separable `über+setzen` (ÜBERsetzen, ferry across) in reading 1. German
    orthography does not mark the stress that distinguishes them. Inheriting the parent's
    separability would show a reviewer "ferry across (inseparable)" and invite a finding against a
    verb that does not exist.
  * THE SIBLING GLOSS. The one failure mode this population has and the 2,432-verb sweep never faced
    is a pair that collapses into the same English — the weben/verweben collision found in that
    sweep, except inside one entry. A reviewer judging records one at a time cannot see it, so the
    sibling is named in the record instead of being left to be inferred from file adjacency.
  * THE AUXILIARY. `ay="s"` means the perfect takes sein. On this population it is usually the whole
    reason the second reading exists (transitive haben vs intransitive sein), so it is the strongest
    available evidence about which sense a reading is supposed to name.

WHY --multi-reading WRITES A SEPARATE FILE AND THE DEFAULT MODE NOW REFUSES TO CLOBBER. The 49
gloss_NNN.in.json shards are the audit trail of what the sweep actually reviewed, and 220 of the
glosses they quote have since been corrected in Verbs.xml. Re-running the default mode today would
rewrite them with post-correction values, silently making the record of the sweep disagree with the
sweep. It therefore refuses when the shards already exist unless --force is passed.
"""

import argparse
import collections
import glob
import json
import os
import re

SIZE = 50
OUT = "verbdata/gloss-review/shards"

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--multi-reading", action="store_true",
                    help="audit the 44 two-<reading> verbs instead: one record per reading, "
                         "keyed <verb>#<index>, into multi_000.in.json")
parser.add_argument("--force", action="store_true",
                    help="overwrite existing shard files (see the docstring: the gloss_NNN shards "
                         "are the sweep's audit trail and Verbs.xml has moved since)")
args = parser.parse_args()

raw = open("Konjugieren/Models/Verbs.xml").read()
CAND = {c["word"]: (c.get("glosses") or [])
        for c in json.load(open("verbdata/candidates.json"))["candidates"]}
REVIEWED = set(json.load(open("verbdata/authored/provenance.json")))


def norm(s):
    """kaikki writes 'to hand over, to deliver'; the app writes 'hand over, deliver'. Strip the
    leading 'to ' and a trailing period, which are the only systematic differences."""
    return re.sub(r"^to ", "", s.strip().lower()).rstrip(".")


def match_sense(gloss, glosses):
    """Which kaikki sense did the shipped gloss come from, and how faithfully?

    Returns (index_or_None, kind) where kind is 'exact', 'shortened', or 'none'.

    THE 'shortened' CASE IS THE NORMAL ONE AND THIS FUNCTION EXISTS FOR IT. An earlier version
    tested only for equality and reported that 1,520 of 2,432 shipped glosses matched no kaikki
    sense, which reads as a mass import failure and is nothing of the kind: the app's house style
    is a terse phrase (~14 characters), and kaikki's is a full dictionary definition with
    parentheticals and usage notes. 'work off' against 'to work off (a debt, the items on a
    to-do list, etc); to resolve or take care of something by working' is a faithful shortening,
    not a mismatch. Reporting it as 'none' would have told every reviewer that the ordinary case
    was suspicious.

    So a candidate counts as 'shortened' when every comma-separated part of the shipped gloss
    appears somewhere in it. That is deliberately generous: the field is a hint for a human
    reader, not a gate, and a false 'shortened' costs nothing while a false 'none' misleads.
    """
    n = norm(gloss)
    for i, g in enumerate(glosses):
        if norm(g) == n:
            return i, "exact"
    parts = [p.strip() for p in n.split(",") if p.strip()]
    for i, g in enumerate(glosses):
        ng = norm(g)
        if parts and all(p in ng for p in parts):
            return i, "shortened"
    return None, "none"


def separability(marked):
    return ("separable" if "+" in marked
            else "inseparable" if "*" in marked else "simplex")


def build_multi_reading():
    """One record per reading of every two-<reading> verb, keyed <verb>#<index>.

    THE REVIEWED FILTER IS DELIBERATELY NOT APPLIED HERE, and that is not a shortcut. In the
    default mode the two filters run in sequence — already-reviewed first, multi-reading second —
    and only the second writes a record, so `überkochen` was removed from the pool before the
    multi-reading check ever saw it and is absent from skipped-multi-reading.txt. That file says
    43; the corpus holds 44. Its glosses have never been audited: provenance.json records that its
    example SENTENCE was reviewed, which is a different pass with a different subject. Any
    exclusion file inherits the blindness of every filter that ran before it.
    """
    records, overrides = [], []
    for m in re.finditer(r'<verb in="([^"]+)"[^>]*>(.*?)</verb>', raw, re.S):
        marked, body = m.group(1), m.group(2)
        verb = re.sub(r"[+*^]", "", marked)
        readings = [dict(re.findall(r'(\w+)="([^"]*)"', r.group(1)))
                    for r in re.finditer(r'<reading\b([^>]*)/>', body)]
        if len(readings) < 2:
            continue
        glosses = CAND.get(verb) or []
        for i, rd in enumerate(readings):
            idx, kind = match_sense(rd["tn"], glosses)
            if separability(rd.get("in", marked)) != separability(marked):
                overrides.append(f"{verb}#{i}")
            records.append({
                "key": f"{verb}#{i}",
                "verb": verb,
                "reading_index": i,
                "gloss": rd["tn"],
                # A reading may override the parent's `in`, which changes the separability and thus
                # WHICH GERMAN VERB this gloss belongs to: übersetzen is übersétzen (translate) in
                # reading 0 and ÜBERsetzen (ferry across) in reading 1.
                "separability": separability(rd.get("in", marked)),
                "auxiliary": "sein" if rd.get("ay") == "s" else "haben",
                "ablaut_group": rd.get("ag"),
                "sibling_gloss": readings[1 - i]["tn"] if len(readings) == 2 else None,
                "candidate_glosses": glosses,
                "sense_index": idx,
                "sense_match": kind,
            })
    records.sort(key=lambda r: (r["verb"], r["reading_index"]))
    os.makedirs(OUT, exist_ok=True)
    path = f"{OUT}/multi_000.in.json"
    if os.path.exists(path) and not args.force:
        raise SystemExit(f"{path} exists -- pass --force to overwrite")
    json.dump({"shard": "multi_000", "readings": records},
              open(path, "w"), ensure_ascii=False, indent=2)
    verbs = {r["verb"] for r in records}
    kinds = collections.Counter(r["sense_match"] for r in records)
    print(f"{len(records)} readings on {len(verbs)} verbs -> {path}")
    print(f"  gloss tracks a kaikki sense: exact {kinds['exact']}, "
          f"shortened {kinds['shortened']}, none {kinds['none']}")
    print(f"  readings overriding the parent's separability: {len(overrides)} {overrides}")
    print(f"  readings taking sein: {sum(1 for r in records if r['auxiliary'] == 'sein')}")
    print(f"  in provenance.json (invisible to skipped-multi-reading.txt): "
          f"{sorted(verbs & REVIEWED)}")


if args.multi_reading:
    build_multi_reading()
    raise SystemExit

if glob.glob(f"{OUT}/gloss_*.in.json") and not args.force:
    raise SystemExit(
        f"{OUT}/ already holds gloss_NNN.in.json shards -- refusing to rewrite them.\n"
        "They quote the glosses the sweep of 2026-07-25 reviewed, 220 of which have since been\n"
        "corrected in Verbs.xml, so a rebuild would make the audit trail disagree with the audit.\n"
        "Pass --force if you really mean to rebuild from current Verbs.xml.")

entries, skipped = [], []
for m in re.finditer(r'<verb in="([^"]+)"[^>]*>(.*?)</verb>', raw, re.S):
    marked = m.group(1)
    verb = re.sub(r"[+*^]", "", marked)
    if verb in REVIEWED:
        continue
    tns = re.findall(r'tn="([^"]*)"', m.group(2))
    if len(tns) != 1:
        skipped.append((verb, tns))
        continue
    glosses = CAND.get(verb) or []
    idx, kind = match_sense(tns[0], glosses)
    entries.append({
        "verb": verb,
        "gloss": tns[0],
        "separability": separability(marked),
        "candidate_glosses": glosses,
        # 0-based index of the kaikki sense the shipped gloss came from, and how faithfully.
        # sense_index 0 with several candidates is the first-sense pick the review found
        # defective 11% of the time; sense_match "none" means the gloss tracks no listed sense
        # and is the reviewer's own judgment call.
        "sense_index": idx,
        "sense_match": kind,
    })

entries.sort(key=lambda e: e["verb"])
os.makedirs(OUT, exist_ok=True)
for i in range(0, len(entries), SIZE):
    n = i // SIZE
    json.dump({"shard": n, "verbs": entries[i:i + SIZE]},
              open(f"{OUT}/gloss_{n:03d}.in.json", "w"), ensure_ascii=False, indent=2)

with open("verbdata/gloss-review/skipped-multi-reading.txt", "w") as f:
    # Kept in sync with the checked-in file by hand. A regeneration must not read as a fresh
    # to-do list: these verbs were audited on 2026-07-26 via --multi-reading.
    f.write("# Verbs excluded from the DEFAULT-mode gloss audit: more than one <reading>, so 'the\n"
            "# shipped gloss' is not a single value.\n"
            "#\n"
            "# AUDITED 2026-07-26 -- this file is now a historical record, not a to-do. The "
            "exclusion was\n"
            "# an addressing limitation, not a linguistic one; apply_gloss_corrections.py now "
            "accepts a\n"
            "# reading-scoped `<verb>#<index>` key and build_gloss_shards.py --multi-reading emits "
            "one\n"
            "# record per reading. 88 glosses reviewed, 6 defects. See docs/blog_notes.md "
            "(2026-07-26).\n"
            "#\n"
            "# THIS FILE LISTS 43. THERE ARE 44. `überkochen` was removed by the already-reviewed "
            "filter\n"
            "# one step before the multi-reading check ran, so no record was ever written for it "
            "-- and it\n"
            "# turned out to be one of the six defects. Any exclusion file inherits the blindness "
            "of every\n"
            "# filter that ran before it.\n"
            "# format: <verb>\\t<gloss> | <gloss> ...\n\n")
    for verb, tns in sorted(skipped):
        f.write(f"{verb}\t" + " | ".join(tns) + "\n")

first = sum(1 for e in entries if e["sense_index"] == 0 and len(e["candidate_glosses"]) > 1)
single = sum(1 for e in entries if len(e["candidate_glosses"]) <= 1)
kinds = collections.Counter(e["sense_match"] for e in entries)
print(f"{len(entries)} verbs -> {(len(entries) + SIZE - 1) // SIZE} shards of {SIZE} in {OUT}/")
print(f"  gloss tracks a kaikki sense: exact {kinds['exact']}, shortened {kinds['shortened']}, "
      f"none {kinds['none']}")
print(f"  first-sense picks among multi-sense verbs : {first}")
print(f"  kaikki listed one sense or none           : {single}")
print(f"  skipped, multi-reading                    : {len(skipped)}"
      f"  -> verbdata/gloss-review/skipped-multi-reading.txt")
