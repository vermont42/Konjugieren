#!/usr/bin/env python3
"""Apply verbdata/authored/gloss-corrections.json to Konjugieren/Models/Verbs.xml.

Consumes: verbdata/authored/gloss-corrections.json  (verb -> {old, new, why})
Rewrites: Konjugieren/Models/Verbs.xml               (the tn= attribute of one <reading>)

Run from the repo root:  python3 verbdata/authored/apply_gloss_corrections.py
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

import json
import pathlib
import re
import sys

XML = pathlib.Path("Konjugieren/Models/Verbs.xml")
CORR = pathlib.Path("verbdata/authored/gloss-corrections.json")

dry_run = "--dry-run" in sys.argv

corrections = {k: v for k, v in json.load(CORR.open()).items() if not k.startswith("_")}
raw = XML.read_text()

# verb element spans, keyed by unmarked infinitive
spans = {}
for m in re.finditer(r'<verb in="([^"]+)"[^>]*>(.*?)</verb>', raw, re.S):
    spans[re.sub(r"[+*^]", "", m.group(1))] = m

problems, edits = [], []
for verb, fix in sorted(corrections.items()):
    m = spans.get(verb)
    if m is None:
        problems.append(f"{verb}: not in Verbs.xml")
        continue
    body = m.group(2)
    tns = re.findall(r'tn="([^"]*)"', body)
    if len(tns) != 1:
        problems.append(f"{verb}: {len(tns)} readings ({tns}) -- hand-edit, this script will not guess")
        continue
    if tns[0] != fix["old"]:
        problems.append(f'{verb}: expected old gloss {fix["old"]!r}, found {tns[0]!r} -- stale entry')
        continue
    for ch in "&<>\"":
        if ch in fix["new"]:
            problems.append(f'{verb}: new gloss contains XML-significant {ch!r}')
            break
    else:
        edits.append((verb, m.start(), m.end(), body, fix))

if problems:
    print("REFUSING TO WRITE -- {} problem(s):".format(len(problems)))
    for p in problems:
        print("  " + p)
    sys.exit(1)

# apply back-to-front so earlier spans keep their offsets
for verb, start, end, body, fix in sorted(edits, key=lambda e: -e[1]):
    new_body = body.replace(f'tn="{fix["old"]}"', f'tn="{fix["new"]}"', 1)
    raw = raw[:start] + raw[start:end].replace(body, new_body, 1) + raw[end:]
    print(f'  {verb}: {fix["old"]!r} -> {fix["new"]!r}')

if dry_run:
    print(f"\ndry run: {len(edits)} gloss(es) would change, nothing written")
else:
    XML.write_text(raw)
    print(f"\nwrote {len(edits)} gloss corrections to {XML}")
