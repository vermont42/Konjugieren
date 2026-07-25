#!/usr/bin/env python3
"""Build shards for the gloss audit — prompts/gloss_review.md, item 1 of
prompts/example_review_followups.md.

Consumes:
  Konjugieren/Models/Verbs.xml        the shipped gloss, in the tn attribute of <reading>
  verbdata/candidates.json            the full kaikki gloss list per verb
  verbdata/authored/provenance.json   the 1,097 verbs the example-sentence review already covered

Produces:
  verbdata/gloss-review/shards/gloss_NNN.in.json    50 verbs each
  verbdata/gloss-review/skipped-multi-reading.txt   verbs excluded, with their readings

Run from the repo root:  python3 verbdata/authored/build_gloss_shards.py

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

MULTI-READING VERBS ARE SKIPPED, LOUDLY. add_readings.py gave 18 dual-auxiliary verbs a second
<reading>, each with its own tn, and there are ~44 extra readings in the file overall. On such a verb
"the shipped gloss" is not a single value, and apply_gloss_corrections.py refuses to write one rather
than guess which sense to rewrite. Sending them to a reviewer would spend tokens producing findings
nothing can apply. They are written to skipped-multi-reading.txt instead of being dropped in silence,
because a silent cap reads as coverage it did not have.
"""

import collections
import json
import os
import re

SIZE = 50
OUT = "verbdata/gloss-review/shards"

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
        "separability": ("separable" if "+" in marked
                         else "inseparable" if "*" in marked else "simplex"),
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
    f.write("# Verbs excluded from the gloss audit: more than one <reading>, so 'the shipped\n"
            "# gloss' is not a single value and apply_gloss_corrections.py cannot write one.\n"
            "# Audit these by hand if the sweep's defect rate suggests it is worth it.\n"
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
