#!/usr/bin/env python3
"""Extract and repair dashed sentences in a .xcstrings catalog.

Consumes:  Konjugieren/Assets/Localizable.xcstrings (or the widget catalog)
Produces:  verbdata/style/xc-sentences.json  (extract mode)
           a rewritten catalog                (apply mode, using verbdata/style/xc-fixes.json)
Run:       python3 verbdata/style/xcstrings_units.py extract
           python3 verbdata/style/xcstrings_units.py apply

Why not edit the catalog directly
---------------------------------
Two constraints from CLAUDE.md make the obvious approaches wrong.

1. **Never round-trip through json.load + json.dump.** Xcode writes `"key" : value` with a
   space before the colon; `json.dump` writes `"key": value`. A round trip rewrites all
   ~5,400 lines without changing a single value, and the result is still valid JSON, so
   validation cannot catch it. Only `git diff --stat` can: a correct edit shows insertions
   and **zero deletions**. So this script parses to *read* and emits raw text to *write*.
2. **The Edit tool operates on rendered text**, so any edit touching an ASCII double quote
   inside a JSON string value silently produces an unescaped quote. Doing the replacement
   in Python on the escaped form sidesteps that entirely.

The long-form Info articles run to 21,000 characters each, so the unit of review is the
*sentence*, not the string. That also matches how the etymology sweep works, and it keeps
the surrounding rich-text markup (`~`, `$`, backtick headings, `‡` links) untouched,
because the markup is never retyped.
"""

import json
import pathlib
import re
import sys

CATALOG = pathlib.Path("Konjugieren/Assets/Localizable.xcstrings")
SENTENCES = pathlib.Path("verbdata/style/xc-sentences.json")
FIXES = pathlib.Path("verbdata/style/xc-fixes.json")

SPAN = re.compile(r"\s*—\s*|\s+–\s*|\s+--\s*")
# Sentence boundary: terminal punctuation (optionally inside a closing quote) then
# whitespace. Newlines also end a unit, because the articles use them between paragraphs
# and before bullet lines.
SPLIT = re.compile(r'(?<=[.!?])["“”„]?\s+|\n+')
ABBR = {"Ahd", "Mhd", "ahd", "mhd", "Nhd", "Urgerm", "Got", "Altn", "vs", "z", "B", "d",
        "h", "bzw", "usw", "vgl", "ca", "Jh", "Jhd", "Lat", "Engl", "Gr", "Chr", "u", "a",
        "St", "Nr", "S", "Bd", "ff", "f"}


def sentences(text):
    parts = SPLIT.split(text)
    out = []
    for part in parts:
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


def string_units(catalog):
    for key, entry in catalog["strings"].items():
        for lang, loc in entry.get("localizations", {}).items():
            unit = loc.get("stringUnit")
            if unit:
                yield key, lang, unit["value"]


def extract():
    catalog = json.loads(CATALOG.read_text())
    rows, seen = [], set()
    for key, lang, value in string_units(catalog):
        for sentence in sentences(value):
            if not SPAN.search(sentence) or sentence in seen:
                continue
            seen.add(sentence)
            rows.append({"id": "x%04d" % len(rows), "lang": lang, "key": key,
                         "text": sentence, "d": len(SPAN.findall(sentence))})
    SENTENCES.write_text(json.dumps(rows, ensure_ascii=False, indent=1))
    print("%d distinct dashed sentences, %d dashes" % (rows and len(rows) or 0,
                                                       sum(r["d"] for r in rows)))


def apply():
    sys.path.insert(0, str(pathlib.Path("verbdata/style").resolve()))
    from dashfix import apply_codes

    rows = {r["id"]: r for r in json.loads(SENTENCES.read_text())}
    fixes = json.loads(FIXES.read_text())
    raw = CATALOG.read_text()

    applied = missing = 0
    for sid, decision in fixes.items():
        before = rows[sid]["text"]
        after = decision if isinstance(decision, str) else apply_codes(before, decision)
        kept = 0 if isinstance(decision, str) else decision.count("K")
        if len(SPAN.findall(after)) != kept:
            raise ValueError("fix leaves a dash behind: %r" % after)
        # Replace the *JSON-escaped* form, so a value containing an ASCII double quote is
        # matched and rewritten in its escaped state and never unescaped by accident.
        # ensure_ascii=False is required, not cosmetic: Xcode writes the catalog as literal
        # UTF-8, so the default ASCII escaping would turn every „ and emoji into \uXXXX and
        # match nothing at all. Escaping stays limited to what JSON demands: " \ and \n.
        esc_before = json.dumps(before, ensure_ascii=False)[1:-1]
        esc_after = json.dumps(after, ensure_ascii=False)[1:-1]
        if esc_before not in raw:
            print("UNMATCHED %s: %r" % (sid, before[:90]))
            missing += 1
            continue
        applied += raw.count(esc_before)
        raw = raw.replace(esc_before, esc_after)

    CATALOG.write_text(raw)
    print("%d fixes, %d sites rewritten, %d unmatched" % (len(fixes), applied, missing))
    catalog = json.loads(CATALOG.read_text())     # validates JSON integrity
    left = sum(len(SPAN.findall(v)) for _, _, v in string_units(catalog))
    print("dashes remaining in catalog: %d (exempt citations and bibliography)" % left)


if __name__ == "__main__":
    {"extract": extract, "apply": apply}[sys.argv[1]]()
