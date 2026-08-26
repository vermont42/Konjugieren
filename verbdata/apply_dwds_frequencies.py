#!/usr/bin/env python3
"""Write measured DWDS hit counts back into `Konjugieren/Models/Verbs.xml`.

Consumes:  verbdata/dwds-frequencies.json (gitignored), the output of
           `fetch_dwds_frequencies.py`, plus the XML itself.
Produces:  an in-place edit of Verbs.xml: every lemma present in the snapshot gets its
           measured `hi`, and loses `hp="y"` if it carried one.
Run:       python3 verbdata/apply_dwds_frequencies.py [--dry-run]

## Why this edits text rather than an ElementTree

`Verbs.xml` opens with a DOCTYPE that `xmllint --valid` enforces, carries attributes in a
fixed order, and is indented by hand. `ElementTree.write` preserves none of the three, so a
parse-and-serialize round trip would churn all 3,572 verbs and every reading beneath them
while changing one attribute each. The same reasoning that keeps `Localizable.xcstrings`
away from `json.dump` applies here, and `git diff --stat` is likewise the check: only lines
whose `hi` actually moved should appear.

## What it deliberately does not do

A lemma absent from the snapshot is left exactly as it is, `hp="y"` included. Absence means
the fetch quarantined it, and a quarantined lemma has no measured count to write. Silently
substituting anything for it would recreate the defect the fetcher's gate exists to prevent:
a number that looks measured and is not. The run reports the survivors so the population
stays visible.
"""

import argparse
import json
import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
XML = REPO / "Konjugieren/Models/Verbs.xml"
SNAPSHOT = REPO / "verbdata/dwds-frequencies.json"

# One `<verb …>` opening tag. Non-greedy up to the first `>`, which is safe because no
# attribute value in this file contains one.
VERB_TAG = re.compile(r"<verb\b[^>]*>")


def lemma_of(tag: str) -> str:
    """The plain infinitive behind an `in` attribute, with all three markers stripped.

    `+` separates a separable prefix, `*` an inseparable one, and `^` brackets the ablaut
    region, so `ab+w^ei^chen` is the lemma `abweichen`. Dropping only `+` and `^` leaves
    305 verbs looking like `be*achten`; cf. generate_frequencies_txt.py, which was fixed
    for exactly that.
    """
    return re.sub(r"[+*^]", "", re.search(r'in="([^"]+)"', tag).group(1))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--snapshot", type=pathlib.Path, default=SNAPSHOT)
    parser.add_argument("--dry-run", action="store_true", help="report, do not write")
    args = parser.parse_args()

    measured = {row["lemma"]: row["hits"] for row in json.loads(args.snapshot.read_text())}
    text = XML.read_text()

    changed, cleared, unmeasured, moved = 0, 0, [], []

    def rewrite(match: re.Match) -> str:
        nonlocal changed, cleared
        tag = match.group(0)
        lemma = lemma_of(tag)
        hits = measured.get(lemma)
        if hits is None:
            unmeasured.append(lemma)
            return tag

        old = int(re.search(r'hi="(\d+)"', tag).group(1))
        if old != hits:
            moved.append((lemma, old, hits))
            changed += 1
        tag = re.sub(r'hi="\d+"', f'hi="{hits}"', tag)
        # `hp` marks the count as an editorial estimate. A measured count retires it, and
        # the DTD declares it #IMPLIED, so removal is simply dropping the attribute.
        if 'hp="y"' in tag:
            tag = tag.replace(' hp="y"', "")
            cleared += 1
        return tag

    updated = VERB_TAG.sub(rewrite, text)

    print(f"{changed} counts changed, {cleared} provisional flags cleared")
    print(f"{len(unmeasured)} lemmas left untouched (absent from the snapshot)")
    for lemma in unmeasured[:20]:
        print(f"    {lemma}")
    if len(unmeasured) > 20:
        print(f"    … and {len(unmeasured) - 20} more")

    if args.dry_run:
        print("\n--dry-run: nothing written", file=sys.stderr)
        return 0

    XML.write_text(updated)
    print(f"\nWrote {XML}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
