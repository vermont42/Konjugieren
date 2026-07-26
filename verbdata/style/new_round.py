#!/usr/bin/env python3
"""Start a new sweep round over Etymologies.json.

Run: python3 verbdata/style/new_round.py 3

Archives the previous round's decisions, re-extracts distinct dashed units from the corpus
*as it now stands*, splits them into sentences, and writes a fresh `sentences.json` plus an
empty `fixes.json`.

Why each round must re-extract
------------------------------
`dashfix.py --apply` rewrites the corpus, so the previous round's "before" strings no longer
occur in it. Re-extracting is not merely tidy: it is the only way the remaining population is
counted correctly, and it makes the archived `fixes-roundN.json` an immutable record of what
was decided rather than a live input that would silently stop matching.

Sentence splitting
------------------
The unit of review is the sentence, not the paragraph, because a paragraph can carry several
independent dashes. Splitting on terminal punctuation would break inside the corpus's many
abbreviations (`Mhd.`, `Ahd.`, `v. Chr.`, `im 16. Jahrhundert`), so a fragment whose previous
piece ends in a known abbreviation or a digit is rejoined. A mis-split is harmless anyway:
the fix is applied by exact-string replacement, and a fragment is still an exact substring of
the paragraph that contains it.
"""

import collections
import json
import pathlib
import re
import subprocess
import sys

STYLE = pathlib.Path("verbdata/style")
SPAN = re.compile(r"\s*—\s*|\s+–\s*|\s+--\s*")
SPLIT = re.compile(r'(?<=[.!?])["“”„]?\s+')
ABBR = {"Ahd", "Mhd", "ahd", "mhd", "Nhd", "nhd", "Urgerm", "Got", "got", "Altn", "vs", "z",
        "B", "d", "h", "bzw", "usw", "vgl", "ca", "Jh", "Jhd", "Lat", "lat", "Engl", "engl",
        "Gr", "ndl", "Ndl", "Nl", "ags", "Ags", "Chr", "K", "u", "a", "St", "Nr", "ff", "f"}


def sentences(text):
    out = []
    for part in SPLIT.split(text):
        if not part:
            continue
        if out:
            tail = re.search(r"(\S+)\.$", out[-1])
            tok = tail.group(1).rstrip(".").split("(")[-1].split("~")[-1] if tail else None
            if tok and (tok in ABBR or tok.isdigit()):
                out[-1] += " " + part
                continue
        out.append(part)
    return out


def main():
    n = int(sys.argv[1])
    for name in ("fixes", "sentences"):
        live = STYLE / ("%s.json" % name)
        if live.exists():
            live.rename(STYLE / ("%s-round%d.json" % (name, n - 1)))

    subprocess.run([sys.executable, str(STYLE / "extract_units.py"),
                    "--out", str(STYLE / "units.json")], check=True)
    units = json.loads((STYLE / "units.json").read_text())

    out = {}
    for lang in ("en", "de"):
        counts = collections.Counter()
        for row in units[lang]:
            for sentence in sentences(row["text"]):
                if SPAN.search(sentence):
                    counts[sentence] += row["occurrences"]
        out[lang] = [{"id": "%s%04d" % (lang[0], i), "text": s, "n": c,
                      "d": len(SPAN.findall(s))}
                     for i, (s, c) in enumerate(counts.most_common())]
        print("%s: %d sentences, %d dashes"
              % (lang, len(out[lang]), sum(r["d"] * r["n"] for r in out[lang])))

    (STYLE / "sentences.json").write_text(json.dumps(out, ensure_ascii=False, indent=1))
    (STYLE / "fixes.json").write_text("{}")
    print("round %d ready" % n)


if __name__ == "__main__":
    main()
