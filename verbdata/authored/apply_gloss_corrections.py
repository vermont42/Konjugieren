#!/usr/bin/env python3
"""Apply a gloss-corrections file to Konjugieren/Models/Verbs.xml.

Consumes: a corrections JSON  (verb -> {old, new, why}), default
          verbdata/authored/gloss-corrections.json
Rewrites: Konjugieren/Models/Verbs.xml  (the tn= attribute of one <reading>)

Run from the repo root:  python3 verbdata/authored/apply_gloss_corrections.py [CORRECTIONS_JSON]
Add --dry-run to report what would change without writing.

WHY THIS IS A SCRIPT AND NOT 55 Edit CALLS. The tn values being replaced are short English
phrases, and several are substrings of other verbs' glosses ("follow", "hit", "charge",
"boot", "outsource"). A textual find-and-replace on the value alone would silently hit the
wrong verb. Every replacement here is scoped to the matched <verb> element first, so the
gloss can only change on the lemma it was authored for.

THE MULTI-READING GUARD IS THE POINT OF THE per-verb CHECK. add_readings.py gave 18 shipping
dual-auxiliary verbs a SECOND <reading>, each carrying its own tn. On such a verb, "replace
the tn in this element" is ambiguous and would silently pick the first. This script therefore
refuses any verb whose element holds more than one tn= and reports it for hand-editing rather
than guessing. None of the 55 review corrections hit such a verb, but the guard has to exist
before that stops being true.

The `old` value in the corrections file is an ASSERTION, not a hint. If Verbs.xml no longer
holds it, the entry is stale — the gloss was edited by something else since the review ran —
and this script refuses the whole file rather than half-applying it. Verbs.xml is shipping app
data, so a partial write is worse than no write.

The lookup key is the UNMARKED infinitive. Verbs.xml stores marked forms in the `in`
attribute ("ab+be*zahlen"), where + precedes a separable particle, * an inseparable prefix,
and ^ a Dehnungs-h boundary; stripping those three characters yields the plain lemma the
review pipeline keys on.
"""

import argparse
import collections
import json
import pathlib
import re
import sys
import xml.etree.ElementTree as ET
from xml.sax.saxutils import escape, unescape

XML = pathlib.Path("Konjugieren/Models/Verbs.xml")
DEFAULT_CORR = "verbdata/authored/gloss-corrections.json"

# argparse rather than `"--dry-run" in sys.argv`. The hand-rolled version accepted --dryrun, -n, and
# every other near-miss silently: the flag simply did not match, dry_run stayed False, and the script
# wrote to shipping data while the operator believed it was rehearsing. argparse errors on an unknown
# option instead, which is the only acceptable behavior for a script whose non-dry mode edits
# Verbs.xml.
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("corrections", nargs="?", default=DEFAULT_CORR,
                    help="corrections JSON; each review run should write its own")
parser.add_argument("--dry-run", action="store_true")
parser.add_argument("--skip-stale", action="store_true",
                    help="drop and report entries whose `old` no longer matches, instead of "
                         "refusing the whole file")
args = parser.parse_args()
dry_run = args.dry_run
CORR = pathlib.Path(args.corrections)

corrections = {k: v for k, v in json.load(CORR.open()).items() if not k.startswith("_")}
if not corrections:
    sys.exit(f"{CORR}: no corrections (header only) -- refusing rather than rewriting Verbs.xml "
             "byte-identically and reporting success")
raw = XML.read_text()

# Verb element spans, keyed by unmarked infinitive. The key is many-to-one -- `ab+laufen` and a bare
# `ablaufen` would both reduce to `ablaufen` -- so collisions are collected rather than overwritten.
# There are none in the corpus today, but the corpus is growing (docs/roadmap.md), and silently
# keeping the last match would write a gloss into the wrong <verb> element: exactly the failure this
# script's docstring says it exists to prevent.
spans = collections.defaultdict(list)
for m in re.finditer(r'<verb in="([^"]+)"[^>]*>(.*?)</verb>', raw, re.S):
    spans[re.sub(r"[+*^]", "", m.group(1))].append(m)

problems, stale, edits = [], [], []
for verb, fix in sorted(corrections.items()):
    ms = spans.get(verb) or []
    if not ms:
        problems.append(f"{verb}: not in Verbs.xml")
        continue
    if len(ms) > 1:
        problems.append(f"{verb}: {len(ms)} <verb> elements share this unmarked lemma -- hand-edit")
        continue
    m = ms[0]
    body = m.group(2)
    tns = re.findall(r'tn="([^"]*)"', body)
    if len(tns) != 1:
        problems.append(f"{verb}: {len(tns)} readings ({tns}) -- hand-edit, this script will not guess")
        continue
    new = (fix.get("new") or "").strip()
    if not new:
        problems.append(f"{verb}: empty replacement gloss")
        continue
    # `old` is compared DECODED. Values arrive from Verbs.xml as encoded text and from the reviewer
    # as plain text; no tn currently contains an XML-significant character, which made the raw
    # comparison accidentally correct rather than correct.
    if unescape(tns[0]) != fix["old"]:
        stale.append(f'{verb}: expected old gloss {fix["old"]!r}, found {unescape(tns[0])!r}')
        continue
    if new == fix["old"]:
        problems.append(f"{verb}: replacement is identical to the shipped gloss")
        continue
    edits.append((verb, m.start(), m.end(), body, tns[0], new))

# Stale entries are the drift signal this script exists to catch, so they abort by default. But
# holding 200 good corrections hostage to one drifted entry is not a safety property, hence
# --skip-stale for the case where the operator has looked and wants the rest.
if stale and not args.skip_stale:
    problems += [s + " -- stale entry (re-run with --skip-stale to drop it and apply the rest)"
                 for s in stale]
elif stale:
    print(f"skipping {len(stale)} stale entr(ies):")
    for s in stale:
        print("  " + s)

if problems:
    print("REFUSING TO WRITE -- {} problem(s):".format(len(problems)))
    for p in problems:
        print("  " + p)
    sys.exit(1)

if not edits:
    sys.exit("no edits survived validation -- refusing to rewrite shipping data with no change")

# apply back-to-front so earlier spans keep their offsets
for verb, start, end, body, old_encoded, new in sorted(edits, key=lambda e: -e[1]):
    # Escape rather than refuse. A legitimate gloss containing & ("cash & carry") is encodable; the
    # earlier behavior rejected it AND, because any problem aborts the file, took every other
    # correction down with it.
    new_body = body.replace(f'tn="{old_encoded}"', f'tn="{escape(new, {chr(34): "&quot;"})}"', 1)
    raw = raw[:start] + raw[start:end].replace(body, new_body, 1) + raw[end:]
    print(f"  {verb}: {unescape(old_encoded)!r} -> {new!r}")

# Validate the artifact produced, not merely the inputs consumed. Verbs.xml is shipping app data and
# this script splices raw text into it; one parse before writing is a complete guarantee that a
# malformed replacement cannot corrupt the corpus. ET handles the file's DOCTYPE internal subset.
try:
    ET.fromstring(raw)
except ET.ParseError as exc:
    sys.exit(f"REFUSING TO WRITE -- the spliced XML no longer parses: {exc}")

if dry_run:
    print(f"\ndry run: {len(edits)} gloss(es) would change, nothing written")
else:
    XML.write_text(raw)
    print(f"\nwrote {len(edits)} gloss corrections to {XML}")
