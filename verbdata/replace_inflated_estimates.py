#!/usr/bin/env python3
"""Lower the provisional hit counts that tranche 2's ratio placed in the top 1,200.

Consumes:  Konjugieren/Models/Verbs.xml.
Produces:  an in-place edit of Verbs.xml: each verb in `ANCHORS` gets a new `hi`, and keeps
           `hp="y"`, since the new value is still an estimate.
Run:       python3 verbdata/replace_inflated_estimates.py [--dry-run]

## Why

83 verbs carry `hp="y"` because DWDS cannot measure them: it has no lemma for compounds such as
*madigmachen* and echoes the query string's own count instead (see `docs/verb-sources.md`,
"The 83 that DWDS cannot measure" in `docs/blog_notes.md`). Their estimates came from
`import_tranche2.py`, which scaled the base verb's count by a ratio. For a base as common as
*machen*, *halten*, or *gehen*, the ratio put the compound near 574,000 hits, rank ~940. So 56
of them sat inside the top 1,000, and *madigmachen* ranked above every measured derivative of
*machen* but *aufmachen* and its peers. Measured compounds of the same shape say otherwise:
*kaputtmachen* is #2321 and *schlechtmachen* #3062.

Pedagogy Phase 6 (2026-11-13) found this because the default quiz now draws from frequency
bands, and the widget's verb of the day already drew from the top 1,000. Josh chose to move
the estimates rather than have the quiz skip provisional verbs.

## How a value is chosen

`docs/verb-sources.md` § "Provisional hit counts" gives the rule: pick a neighbourhood by
judgment ("about as common as *gedeihen*") and take a value between its neighbours' real
counts. So each verb below names a measured, shipping anchor, and the script places it just
under the anchor, at the midpoint between the anchor's count and the next measured count below
it. Verbs that share an anchor take successive gaps going down, in the order listed, one verb
to a gap, so each sits between two real counts and no two tie. The tail is dense (measured
counts there often differ by one or two), so a gap too narrow for a midpoint is skipped.

The anchors are judgment, made on 2026-11-13 from register and semantics, the inputs the rule
allows. Spatial compounds of *halten* (*drüberhalten*, *davorhalten*) and adjective compounds
of *machen* (*armmachen*) are placed with the rarest measured derivatives; phrases common in
news (*vonstattengehen*, *sich starkmachen*, *publikmachen*) with mid-frequency ones. An anchor
is a neighbourhood, not a semantic claim: *neustarten* sits beside *zurückverfolgen* because
the two are about equally common, not because they are related.

Only the 61 provisional verbs ranked above #1,200 are moved, since moving the 56 in the top
1,000 alone would have lifted *verklicken* (#1020) and *verräumen* (#1054) into the band in
their place. The other 22 were left. After the run the highest of them is *verstehlen* at
#1151, outside every band, though several (*schöntrinken*, *scheckiglachen*) look as inflated
as the 61 did and could take the same treatment.

This edits text, not an ElementTree, for the reason `apply_dwds_frequencies.py` gives.
"""

import argparse
import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
XML = REPO / "Konjugieren/Models/Verbs.xml"
VERB_TAG = re.compile(r"<verb\b[^>]*>")

# Provisional verb -> the measured verb it is about as common as.
ANCHORS = {
    "vonstattengehen": "mitgehen",
    "starkmachen": "festmachen",
    "publikmachen": "vormachen",
    "kleinhalten": "freihalten",
    "geringhalten": "freihalten",
    "querdenken": "umdenken",
    "falschliegen": "anliegen",
    "gleichbehandeln": "abhandeln",
    "neustarten": "zurückverfolgen",
    "satthaben": "dabeihaben",
    "zupasskommen": "herumführen",
    "querlesen": "aufsagen",
    "bankrottgehen": "lossagen",
    "kurzmachen": "zuwarten",
    "rückwärtsfahren": "fertigmachen",
    "beiseitehalten": "ummelden",
    "fernschauen": "zurechtweisen",
    "kleinrechnen": "zerfließen",
    "verräumen": "nachverhandeln",
    "wichtigmachen": "vorbehandeln",
    "rausdrehen": "wegweisen",
    "madigmachen": "heiligsprechen",
    "seligmachen": "heiligsprechen",
    "gesundmelden": "krankmelden",
    "aufsprechen": "aufhelfen",
    "beihelfen": "aufhelfen",
    "ähnlichschauen": "abprüfen",
    "zuvorsagen": "abprüfen",
    "niederführen": "schlechtmachen",
    "armmachen": "schlechtmachen",
    "altmachen": "schlechtmachen",
    "heißmachen": "schlechtmachen",
    "allemachen": "schlechtmachen",
    "rücküberweisen": "durchfragen",
    "feilhaben": "durchfragen",
    "entfolgen": "aufeinanderfolgen",
    "dahinterhalten": "herumfragen",
    "darunterhalten": "herumfragen",
    "davorhalten": "herumfragen",
    "drunterhalten": "herumfragen",
    "drüberhalten": "herumfragen",
    "raufhalten": "herumfragen",
    "heraufhalten": "herumfragen",
    "hinaufhalten": "herumfragen",
    "nebeneinanderhalten": "herumfragen",
    "übereinanderhalten": "herumfragen",
    "umeinanderstehen": "zusammenräumen",
    "erfließen": "zusammenräumen",
    "einmelden": "zusammenräumen",
    "rechtdrehen": "zusammenräumen",
    "rückdrehen": "zusammenräumen",
    "niederreden": "zusammenräumen",
    "zerleben": "ausfolgen",
    "anwarten": "ausfolgen",
    "anprüfen": "ausfolgen",
    "einschauen": "ausfolgen",
    "festfragen": "ausfolgen",
    "verklicken": "ausfolgen",
    "zertreiben": "ausfolgen",
    "hintanlegen": "ausfolgen",
    "sonderkündigen": "ausfolgen",
}


def lemma_of(tag: str) -> str:
    """The plain infinitive behind an `in` attribute, with `+`, `*`, and `^` stripped."""
    return re.sub(r"[+*^]", "", re.search(r'in="([^"]+)"', tag).group(1))


def hits_of(tag: str) -> int:
    return int(re.search(r'hi="(\d+)"', tag).group(1))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true", help="report, do not write")
    args = parser.parse_args()

    text = XML.read_text()
    tags = {lemma_of(m.group(0)): m.group(0) for m in VERB_TAG.finditer(text)}

    for lemma, anchor in ANCHORS.items():
        if lemma not in tags or 'hp="y"' not in tags[lemma]:
            sys.exit(f"{lemma} is not a provisional verb")
        if anchor not in tags or 'hp="y"' in tags[anchor]:
            sys.exit(f"anchor {anchor} is not a measured verb")

    # The measured counts, highest first. Anchors and their lower neighbours come only from
    # here, so a moved verb never lands beside another estimate.
    measured = sorted((hits_of(tag) for tag in tags.values() if 'hp="y"' not in tag), reverse=True)

    by_anchor: dict[str, list[str]] = {}
    for lemma, anchor in ANCHORS.items():
        by_anchor.setdefault(anchor, []).append(lemma)

    new_hits: dict[str, int] = {}
    for anchor, lemmas in by_anchor.items():
        position = measured.index(hits_of(tags[anchor]))
        for lemma in lemmas:
            while measured[position] - measured[position + 1] < 2:
                position += 1
            high, low = measured[position], measured[position + 1]
            new_hits[lemma] = (high + low) // 2
            position += 1

    taken = set(measured) | {hits_of(tag) for lemma, tag in tags.items() if lemma not in ANCHORS}
    clashes = [lemma for lemma, hits in new_hits.items() if hits in taken]
    if clashes or len(set(new_hits.values())) != len(new_hits):
        sys.exit(f"a new count ties an existing one: {clashes}")

    for lemma, hits in new_hits.items():
        old_tag = tags[lemma]
        new_tag = re.sub(r'hi="\d+"', f'hi="{hits}"', old_tag)
        assert text.count(old_tag) == 1, lemma
        text = text.replace(old_tag, new_tag)
        print(f"{lemma}: {hits_of(old_tag)} -> {hits} (under {ANCHORS[lemma]})")

    if not args.dry_run:
        XML.write_text(text)
    print(f"{len(new_hits)} estimates {'would move' if args.dry_run else 'moved'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
