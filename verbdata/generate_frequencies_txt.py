#!/usr/bin/env python3
"""Regenerate `docs/frequencies.txt` from `Konjugieren/Models/Verbs.xml`.

Consumes:  Konjugieren/Models/Verbs.xml (the `in` and `hi` attributes)
Produces:  docs/frequencies.txt — `<rank> <infinitive>`, one per line, rank 1 = most common

Run from the repo root:  python3 verbdata/generate_frequencies_txt.py

`frequencies.txt` is a convenience cache: an ordered lemma list so a session can hand ranges
to subagents ("etymologies for verbs 1-100") without parsing XML. Being a cache, it drifts —
it sat at 988 verbs and a stale ordering long after the corpus reached 990, which is why this
generator exists instead of a hand-maintained file. Regenerate it whenever `Verbs.xml` gains,
loses, or re-ranks a verb, and verify with --check in CI-ish contexts.

The rank here must match what the app computes, so the sort mirrors `VerbParser.ranked`
exactly: descending by `hi`, ties broken by infinitive to keep the order total. If that
Swift changes, change this too — a silent divergence would make "verb 400" mean two
different verbs depending on who was asked.
"""

import argparse
import pathlib
import re
import sys
import xml.etree.ElementTree as ET

REPO = pathlib.Path(__file__).resolve().parent.parent
XML = REPO / "Konjugieren/Models/Verbs.xml"
OUT = REPO / "docs/frequencies.txt"


def ranked_lemmas() -> tuple[list[str], list[str]]:
    """Every shipping infinitive most common first, plus those with provisional counts.

    Mirrors `VerbParser.ranked`. The provisional list is reported rather than filtered:
    an `hp` verb ranks by its estimate exactly like any other, and the caller surfaces the
    population so it stays visible instead of only being discoverable by grep.
    """
    verbs, provisional = [], []
    for verb in ET.parse(XML).getroot():
        # Strip all three markers: `+` separable, `*` inseparable, `^` ablaut region.
        # Stripping only `+` and `^` leaves 305 verbs looking like `be*achten`.
        lemma = re.sub(r"[+*^]", "", verb.get("in"))
        verbs.append((lemma, int(verb.get("hi"))))
        if verb.get("hp") is not None:
            provisional.append(lemma)
    verbs.sort(key=lambda pair: (-pair[1], pair[0]))
    return [lemma for lemma, _ in verbs], sorted(provisional)


def render(lemmas: list[str]) -> str:
    return "".join(f"{index + 1} {lemma}\n" for index, lemma in enumerate(lemmas))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true", help="exit nonzero if the file is stale; write nothing")
    args = parser.parse_args()

    lemmas, provisional = ranked_lemmas()
    expected = render(lemmas)

    if provisional:
        print(
            f"note: {len(provisional)} of {len(lemmas)} hit counts are provisional (hp): "
            + ", ".join(provisional),
            file=sys.stderr,
        )

    if args.check:
        actual = OUT.read_text() if OUT.exists() else ""
        if actual != expected:
            print(f"{OUT.relative_to(REPO)} is stale — rerun without --check", file=sys.stderr)
            return 1
        print(f"{OUT.relative_to(REPO)} is current ({len(expected.splitlines())} verbs)", file=sys.stderr)
        return 0

    OUT.write_text(expected)
    print(f"Wrote {OUT.relative_to(REPO)} ({len(expected.splitlines())} verbs)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
