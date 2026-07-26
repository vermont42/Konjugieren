#!/usr/bin/env python3
"""Print the next batch of unreviewed dashed sentences, for the human/model reviewer.

Run: python3 verbdata/style/review.py en 60        # next 60 unfixed English sentences
     python3 verbdata/style/review.py de 60 --all  # include already-fixed ones

Each line is `id  nx  text`, where n is how many corpus sites carry that exact sentence.
Reviewing in this order (most sites first) front-loads the payoff: the top 200 sentences
per language cover 44% of all dashes in the file.
"""

import json
import pathlib
import sys

SENTS = json.loads(pathlib.Path("verbdata/style/sentences.json").read_text())
FIXES = pathlib.Path("verbdata/style/fixes.json")
done = set(json.loads(FIXES.read_text())) if FIXES.exists() else set()

lang = sys.argv[1]
limit = int(sys.argv[2]) if len(sys.argv) > 2 else 40
show_all = "--all" in sys.argv

shown = 0
for row in SENTS[lang]:
    if row["id"] in done and not show_all:
        continue
    print("%s %3dx %s" % (row["id"], row["n"], row["text"]))
    shown += 1
    if shown >= limit:
        break

pending = sum(1 for r in SENTS[lang] if r["id"] not in done)
print("\n[%s: %d of %d sentences still unreviewed]" % (lang, pending, len(SENTS[lang])),
      file=sys.stderr)
