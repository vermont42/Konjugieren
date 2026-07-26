#!/usr/bin/env python3
"""Extract distinct reviewable units from Etymologies.json.

Consumes:  Konjugieren/Models/Etymologies.json, a {"de": {...}, "en": {...}} map of
           verb -> etymology text.
Produces:  a JSON file of *distinct* text units matching a pattern, each with its
           occurrence count and the verbs carrying it.
Run:       python3 verbdata/style/extract_units.py --pattern dashes --out verbdata/style/units.json

Why this exists
---------------
Roughly 70% of etymology bullet lines are repeats: every `ab-` verb carries the same
`ab-` bullet, 94 of them. A per-verb review pass would show the reviewer that identical
bullet 94 times and collect 94 slightly different rewordings, so the shipped corpus would
end up saying several things about one etymology. Users compare entries; the pipeline
never has. So: deduplicate first, fix each distinct string once, then fan the fix back
out by exact-string replacement.

Two sweeps consume this (prompts/em_dash_sweep.md and prompts/cognate_precision.md), which
is why the pattern is a flag rather than a constant.

Unit boundaries
---------------
An etymology is paragraphs separated by "\\n\\n", and the bullet block is consecutive
lines each beginning with "\N{BULLET} ". Splitting on "\\n" therefore yields exactly the
units we want: one line per bullet, one line per prose paragraph. Bullets are the
shared population; prose is per-verb and dedupes to almost nothing, but it is counted
the same way so that a surprise repeat is visible rather than silently fixed twice.
"""

import argparse
import collections
import json
import pathlib
import re
import sys

ETYMOLOGIES = pathlib.Path("Konjugieren/Models/Etymologies.json")

# Named patterns. `dashes` is the em dash sweep's population: U+2014 anywhere, plus the
# two lookalikes that travel with it. The en dash must be *preceded* by whitespace, because
# one with no space in front of it is a numeric range (1904-1944 in the dedication, or
# 12.-13. Jahrhundert) and correct typography that must survive. Nothing is required after
# it: a dash can abut punctuation, as in `Conjuguer -,`, and that is still punctuation.
PATTERNS = {
    "dashes": r"—|\s–|\s--",
    "em": r"—",
    "cognate": r"[Cc]ognate|[Vv]erwandt",
}

BULLET = "• "


def units(text):
    """Yield (kind, line) for each non-empty line of an etymology."""
    for line in text.split("\n"):
        if not line.strip():
            continue
        yield ("bullet" if line.startswith(BULLET) else "prose"), line


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pattern", default="dashes",
                    help="named pattern (%s) or a raw regex" % ", ".join(PATTERNS))
    ap.add_argument("--lang", default="both", choices=["en", "de", "both"])
    ap.add_argument("--kind", default="both", choices=["bullet", "prose", "both"])
    ap.add_argument("--out", default="verbdata/style/units.json")
    args = ap.parse_args()

    pat = re.compile(PATTERNS.get(args.pattern, args.pattern))
    etym = json.loads(ETYMOLOGIES.read_text())
    langs = ["en", "de"] if args.lang == "both" else [args.lang]

    out = {}
    for lang in langs:
        # counts[(kind, line)] -> occurrences; carriers[(kind, line)] -> verbs
        counts = collections.Counter()
        carriers = collections.defaultdict(list)
        for verb, text in etym[lang].items():
            for kind, line in units(text):
                counts[(kind, line)] += 1
                carriers[(kind, line)].append(verb)

        rows = []
        for (kind, line), count in counts.items():
            if args.kind != "both" and kind != args.kind:
                continue
            if not pat.search(line):
                continue
            rows.append({
                "kind": kind,
                "text": line,
                "occurrences": count,
                "hits": len(pat.findall(line)),
                "verbs": sorted(carriers[(kind, line)]),
            })
        # Highest-leverage strings first: a bullet on 94 verbs is worth more care than
        # one on a single verb, and reviewing in this order front-loads the payoff.
        rows.sort(key=lambda r: (-r["occurrences"], r["text"]))
        out[lang] = rows

        sites = sum(r["occurrences"] for r in rows)
        marks = sum(r["hits"] * r["occurrences"] for r in rows)
        print("%s: %d distinct units, %d sites, %d matches" % (lang, len(rows), sites, marks),
              file=sys.stderr)
        for kind in ("bullet", "prose"):
            sub = [r for r in rows if r["kind"] == kind]
            print("  %-7s %4d distinct, %5d sites, %5d matches" % (
                kind, len(sub), sum(r["occurrences"] for r in sub),
                sum(r["hits"] * r["occurrences"] for r in sub)), file=sys.stderr)

    pathlib.Path(args.out).write_text(json.dumps(out, ensure_ascii=False, indent=2))
    print("wrote %s" % args.out, file=sys.stderr)


if __name__ == "__main__":
    main()
