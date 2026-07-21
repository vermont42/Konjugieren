#!/usr/bin/env python3
"""Re-anchor already-mined shards to the canonical prefix senses.

    python3 corpus/working/repair_mined_connectives.py [--apply]

WHY THIS EXISTS
---------------
Shards 000–007 were mined before `verbdata/normalize_prefix_senses.py` ran, and they diverge
from the reuse files in two different ways. Both are the same underlying failure — a subagent
adjusting a sense it was told to splice unchanged — but they need one repair, not two:

1. **Invented connectives.** About 45% of senses were verb-initial fragments that could not
   follow the chain's final period as written, so each subagent bridged the gap in its own
   words: "Here it conveys…", "It promotes…", "Here the prefix conveys…", "The prefix conveys…",
   "Here ~be-~ promotes…".
2. **Substituted subjects.** Where a sense *was* already a complete sentence, several shards
   still rewrote its opening — canonical "The prefix conveys separation or removal — taking
   something off or away." was mined as "Here it conveys separation or removal — …". Nothing
   forced this one; it is drift for its own sake, and it is invisible to a diff against the
   fragments because those senses never changed.

HOW
---
Rather than model either failure, anchor on what both preserve: the *tail* of the sense. A
subagent edited the front and spliced the rest verbatim, so the ending is intact and highly
distinctive. For each morpheme a verb actually uses, each canonical sense's tail is located in
the etymology, the span from the preceding sentence boundary to the end of that tail is taken —
that span is precisely "whatever the subagent wrote in front" plus the sense — and the whole
span is replaced by the canonical sense.

This subsumes both cases and needs no record of what the old text was, which is why it does not
consult git: the canonical senses are the only input, so re-running it after any future sense
edit does the right thing.

TWO GUARDS, BOTH LEARNED THE HARD WAY
-------------------------------------
`morphemes` restricts each verb to the senses it can legitimately contain. Without it a bare
search for the sense of `heiß` — a single word — matches inside `heißt`, and English `hot`
matches inside `shot`; a dry run corrupted eight of shard 000's etymologies exactly so.

A tail must match **exactly once**. An ambiguous tail means two senses of one morpheme end
alike, and picking either is a guess. Those are skipped and reported rather than rewritten.

Run without `--apply` to review every rewrite. The Phase 4 validator must pass before and
after: this touches etymology prose only and never a quoted sentence.
"""

import argparse
import glob
import json
import pathlib
import re

FILES = ("verbdata/prefixes-inseparable.json", "verbdata/prefixes-separable.json")
# The left edge of whatever the subagent wrote: the end of the preceding sentence, the bullet's
# own `~morpheme~: ` label, or a line break.
#
# A bare colon is deliberately NOT a boundary. Several senses contain one --- "Das Präfix ist
# inchoativ: Es bezeichnet …", "der resultative Rahmen: alt werden …" --- and treating it as an
# edge puts the span's left inside the sense, so the repair reinserts the sense after its own
# opening clause. Matching `~:` instead keys on the tilde that closes the morpheme name, which
# occurs in the label and never inside sense prose.
BOUNDARY = re.compile(r"(?:[.!?]\s+|~:\s+|\n+)")
# How much of a sense's ending to match on. Long enough to be unique in a paragraph of prose,
# short enough to survive a subagent having rewritten the opening clause.
TAIL_CHARS = 60
# German abbreviations whose period is not a sentence end. Without these the boundary scan puts
# a span's left edge inside a phrase: "Hier: der resultative bzw. wahrnehmungsbezogene Rahmen …"
# breaks after `bzw.`, and the repair then reinserts the sense after the orphaned "der resultative
# bzw.". The indexer keeps its own, larger list for sentence splitting; this one only needs the
# abbreviations that occur in authored etymology prose.
ABBREVIATIONS = frozenset(
    "bzw z B u a d h ca vgl evtl ggf insb bes eigtl urspr Jh Bd Nr St".split()
)


def sentence_edges(text, stop=None):
    """Offsets where a new sentence may begin, skipping periods that close an abbreviation."""
    edges = {0}
    for match in BOUNDARY.finditer(text, 0, stop if stop is not None else len(text)):
        head = text[: match.start() + 1]
        word = re.search(r"(\w+)\.$", head)
        if word and word.group(1) in ABBREVIATIONS:
            continue
        edges.add(match.end())
    return edges



def canonical_senses():
    """{morpheme: {lang: [sense, …]}} from the reuse files, which are the source of truth."""
    senses = {}
    for path in FILES:
        data = json.loads(pathlib.Path(path).read_text())
        for lang in ("de", "en"):
            for morpheme, entry in data[lang].items():
                if entry.get("senses"):
                    senses.setdefault(morpheme, {}).setdefault(lang, entry["senses"])
    return senses


def repair(text, lang, morphemes, senses):
    """Return the text with every bullet re-anchored to its canonical sense, plus a change log."""
    rewrites, ambiguous = [], []
    for morpheme in sorted(morphemes):
        for sense in senses.get(morpheme, {}).get(lang, []):
            # Already spliced correctly — but only if the sense *starts* a sentence. Testing
            # `sense in text` alone is not enough: "Here ~be-~ promotes …" contains the canonical
            # "~be-~ promotes …" as a substring, and skipping on that would leave the invented
            # "Here " in place, which is the very thing being repaired.
            edges = sentence_edges(text)
            if any(m.start() in edges for m in re.finditer(re.escape(sense), text)):
                continue
            tail = sense[-TAIL_CHARS:] if len(sense) > TAIL_CHARS else sense
            pattern = re.escape(tail)
            if tail == sense:
                # A short sense is a whole word and must not match inside a longer one.
                pattern = rf"(?<!\w){pattern}(?!\w)"
            found = list(re.finditer(pattern, text))
            if not found:
                continue
            if len(found) > 1:
                ambiguous.append((morpheme, sense))
                continue
            match = found[0]
            end = match.end()
            if text[end:end + 1] == ".":
                end += 1
            left = max(edge for edge in sentence_edges(text, match.start()))
            if text[left:end] != sense:
                rewrites.append((left, end, sense, text[left:end]))
    # Right to left, so earlier offsets stay valid.
    for left, end, sense, _before in sorted(rewrites, reverse=True):
        text = text[:left] + sense + text[end:]
    return text, rewrites, ambiguous


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()

    senses = canonical_senses()
    total, skipped = 0, 0
    for path in sorted(glob.glob("corpus/working/shards/mine_*.out.json")):
        shard_id = pathlib.Path(path).stem.split(".")[0]
        data = json.loads(pathlib.Path(path).read_text())
        shard = json.loads(pathlib.Path(path.replace(".out", ".in")).read_text())
        # Morpheme names per verb, from the decomposition the shard was built with. Reading keys
        # look like "insep:be" / "separ:an"; the reuse files are keyed by the bare name.
        used = {}
        for item in shard["verbs"]:
            names = set()
            for reading in item["readings"]:
                for key in reading.get("prefixes") or []:
                    names.add(key.split(":", 1)[1])
            used[item["verb"]] = names

        changed = 0
        for verb, entry in data.items():
            for lang in ("de", "en"):
                text = entry["etymology"][lang]
                fixed, rewrites, ambiguous = repair(text, lang, used.get(verb, set()), senses)
                for morpheme, _sense in ambiguous:
                    skipped += 1
                    print(f"  SKIPPED ambiguous tail [{shard_id} {verb}/{lang}] {morpheme}")
                if fixed != text:
                    changed += 1
                    total += 1
                    if not args.apply:
                        for _left, _end, sense, before in rewrites:
                            print(f"  [{shard_id} {verb}/{lang}]")
                            print(f"    - {before}")
                            print(f"    + {sense}")
                    entry["etymology"][lang] = fixed
        if args.apply and changed:
            pathlib.Path(path).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
        print(f"{shard_id}: {changed} etymology texts {'rewritten' if args.apply else 'would change'}")
    print(f"\ntotal: {total} texts, {skipped} ambiguous tails skipped")


if __name__ == "__main__":
    main()
