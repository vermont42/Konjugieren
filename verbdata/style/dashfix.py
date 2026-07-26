#!/usr/bin/env python3
"""Apply reviewed per-dash fixes to Etymologies.json.

Consumes:  verbdata/style/sentences.json   (distinct dashed sentences, from extract_units.py)
           verbdata/style/fixes.json       (the reviewed decisions; see "Fix codes")
Produces:  a rewritten Konjugieren/Models/Etymologies.json, or with --dry-run a report.
Run:       python3 verbdata/style/dashfix.py --lang en --dry-run
           python3 verbdata/style/dashfix.py --apply

Why a code per dash rather than a rewritten sentence
----------------------------------------------------
There are ~11,000 dashes across ~5,600 distinct sentences, and every one needs a human-ish
judgment: the style rule names four replacements and which applies is a fact about the
clause. Retyping 5,600 whole sentences invites transcription errors in text dense with
markup (`~`, `„“`, `*`, IPA, reconstructed forms) that no test would catch. So the reviewer
emits an ordered list of one-character codes, one per dash in the sentence, and this script
does the mechanical surgery. The markup is never retyped, so it cannot be corrupted.

Fix codes
---------
  :   colon                     ;   semicolon
  ,   comma                     .   period, and capitalize what follows
  :^  colon, and capitalize what follows (German: a full sentence after a colon is capitalized)
  -   delete the dash, joining with a single space
  (   open a parenthetical      )   close it
  ),  close it, followed by a comma
  =X  replace the dash and its surrounding space with the literal X
  K   KEEP this dash: it is an exempt citation separator (`Goethe — Werther`) sitting inside
      a sentence whose other dashes are in scope
  !   this sentence is rewritten wholesale; the replacement text is given instead of codes

The span a code replaces is the dash *plus its surrounding whitespace*, so `a — b` and
`a —, b` both normalize cleanly instead of leaving a doubled separator.
"""

import argparse
import collections
import json
import pathlib
import re
import sys

ETYMOLOGIES = pathlib.Path("Konjugieren/Models/Etymologies.json")
FIXES = pathlib.Path("verbdata/style/fixes.json")

# The dash itself, with any whitespace on either side swept into the span. The en dash and
# double hyphen must be preceded by whitespace: an en dash with no space in front of it is a
# numeric range (1904-1944, 12.-13. Jahrhundert), correct typography this sweep leaves alone.
# Trailing whitespace is optional because a dash can abut punctuation, as in `Conjuguer -,`,
# which is punctuation and not a range.
SPAN = re.compile(r"\s*—\s*|\s+–\s*|\s+--\s*")

SIMPLE = {":": ": ", ",": ", ", ";": "; ", ".": ". ", "-": " ", "(": " (", ")": ") ",
          "),": "), ", ":^": ": ", "(,": " ("}
CAPITALIZING = {".", ":^"}


def apply_codes(sentence, codes):
    """Rewrite `sentence` by replacing its i-th dash span according to codes[i]."""
    spans = list(SPAN.finditer(sentence))
    if len(spans) != len(codes):
        raise ValueError("%d dashes but %d codes: %r" % (len(spans), len(codes), sentence))
    out = []
    cursor = 0
    for span, code in zip(spans, codes):
        out.append(sentence[cursor:span.start()])
        if code == "K":
            out.append(span.group(0))
        elif code.startswith("="):
            out.append(code[1:])
        elif code in SIMPLE:
            out.append(SIMPLE[code])
        else:
            raise ValueError("unknown code %r" % code)
        cursor = span.end()
        if code in CAPITALIZING:
            # Capitalize the first letter of what follows. Quote marks and parens can sit in
            # front of it, so walk past them. A `~` may NOT be walked past: it opens an
            # emphasis span holding a cited word form, and upcasing `~vorbei~` to `~Vorbei~`
            # silently changes which German word the entry claims to be discussing. Use `;`
            # for those instead, which needs no capitalization at all.
            rest = sentence[cursor:]
            if rest[:1] == "~":
                raise ValueError("%r would capitalize inside markup; use ';'" % code)
            for i, ch in enumerate(rest):
                if ch.isalpha():
                    out.append(rest[:i] + ch.upper())
                    cursor += i + 1
                    break
                if not (ch in "*„\"'(" or ch.isspace()):
                    break
    out.append(sentence[cursor:])
    text = "".join(out)
    # A code whose span abutted punctuation can leave " :" or ": ," behind.
    text = re.sub(r"\s+([:;,.])", r"\1", text)
    text = re.sub(r"([:;]) *,", r"\1", text)
    text = re.sub(r"  +", " ", text)
    return text


def load_fixes():
    if not FIXES.exists():
        return {"en": {}, "de": {}}
    return json.loads(FIXES.read_text())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="write Etymologies.json")
    ap.add_argument("--lang", default="both", choices=["en", "de", "both"])
    ap.add_argument("--show", type=int, default=0, help="print this many before/after pairs")
    args = ap.parse_args()

    fixes = load_fixes()
    sents = {r["id"]: r["text"]
             for rows in json.loads(pathlib.Path("verbdata/style/sentences.json").read_text()).values()
             for r in rows}
    etym = json.loads(ETYMOLOGIES.read_text())
    langs = ["en", "de"] if args.lang == "both" else [args.lang]

    shown = 0
    for lang in langs:
        table = {}
        for sid, decision in fixes.items():
            if not sid.startswith(lang[0]):
                continue
            before = sents[sid]
            after = decision if isinstance(decision, str) else apply_codes(before, decision)
            kept = 0 if isinstance(decision, str) else decision.count("K")
            if len(SPAN.findall(after)) != kept:
                raise ValueError("fix leaves a dash behind: %r" % after)
            table[before] = after

        applied = collections.Counter()
        for verb, text in etym[lang].items():
            for before, after in table.items():
                if before in text:
                    applied[before] += text.count(before)
                    text = text.replace(before, after)
            etym[lang][verb] = text

        missing = [b for b in table if not applied[b]]
        print("%s: %d fixes, %d sites rewritten, %d fixes matched nothing"
              % (lang, len(table), sum(applied.values()), len(missing)), file=sys.stderr)
        for b in missing[:5]:
            print("  UNMATCHED: %r" % b[:110], file=sys.stderr)
        while shown < args.show and shown < len(table):
            before = list(table)[shown]
            print("--- %s\n  - %s\n  + %s" % (lang, before, table[before]))
            shown += 1

        remaining = sum(len(SPAN.findall(t)) for t in etym[lang].values())
        print("  %s dashes remaining: %d" % (lang, remaining), file=sys.stderr)

    if args.apply:
        ETYMOLOGIES.write_text(json.dumps(etym, ensure_ascii=False, indent=2) + "\n")
        print("wrote %s" % ETYMOLOGIES, file=sys.stderr)


if __name__ == "__main__":
    main()
