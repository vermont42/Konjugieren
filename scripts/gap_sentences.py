#!/usr/bin/env python3
"""Review and approve the Sentences exercise's authored sentences (Phase 18 of the pedagogy plan).

Consumes: Konjugieren/Models/GapSentences.json, a JSON array in which each sentence carries
  id, verb, table (a ConjugationTable.articleKey), person (a PersonNumber raw value, absent for a
  participle), de (the German with each word of the conjugation in braces), en, and reviewed.

Produces, by subcommand:
  review [--all] [--out PATH]
      A Markdown sheet of the drafts (or, with --all, every sentence), grouped by verb, with the
      blank filled in bold, for the reviewer to read. Prints to stdout unless --out is given.
  approve ID [ID ...] | approve --all [--except ID ...]
      Marks sentences reviewed. The app's release build asks only reviewed sentences; a debug
      build asks drafts too and marks them "Draft" on the card (GapSentences.includesDrafts).
  status
      Counts of reviewed and draft sentences, and the verbs covered.

Run from the repo root:  python3 scripts/gap_sentences.py review --out plans/gap-sentences-batch-1.md

Why it rewrites the whole file: GapSentences.json is written by json.dumps(indent=2,
ensure_ascii=False) and nothing else, so a load-and-dump round trip reproduces it byte for byte
apart from the changed flags. That is NOT true of Localizable.xcstrings, which Xcode formats with
" : " separators; never point this pattern at that file (see CLAUDE.md).

The machine check lives in KonjugierenTests/Models/GapSentenceTests.swift, which conjugates each
sentence's cell with the app's own conjugator. Run it after any edit to the file:
  xcodebuild ... -testLanguage en test -only-testing:KonjugierenTests/GapSentenceTests
"""

import argparse
import json
import pathlib
import re
import sys

PATH = pathlib.Path(__file__).resolve().parent.parent / "Konjugieren" / "Models" / "GapSentences.json"

# English names for the sheet. These mirror ConjugationTable.articleKey; a key missing here is
# printed raw, which the machine check would already have rejected as naming no cell.
TABLE_NAMES = {
    "praesens_indikativ": "Präsens Indikativ",
    "praeteritum_indikativ": "Präteritum Indikativ",
    "perfekt_indikativ": "Perfekt Indikativ",
    "plusquamperfekt_indikativ": "Plusquamperfekt Indikativ",
    "futur_indikativ": "Futur Indikativ",
    "imperativ": "Imperativ",
    "praesens_konjunktiv_i": "Präsens Konjunktiv I",
    "perfekt_konjunktiv_i": "Perfekt Konjunktiv I",
    "futur_konjunktiv_i": "Futur Konjunktiv I",
    "praeteritum_konjunktiv_ii": "Präteritum Konjunktiv II",
    "plusquamperfekt_konjunktiv_ii": "Plusquamperfekt Konjunktiv II",
    "futur_konjunktiv_ii": "Futur Konjunktiv II",
    "perfektpartizip": "Perfektpartizip",
    "praesenspartizip": "Präsenspartizip",
}
PERSONS = {"fs": "ich", "ss": "du", "ts": "er/sie/es", "fp": "wir", "sp": "ihr", "tp": "sie/Sie"}


def load():
    return json.loads(PATH.read_text())


def save(sentences):
    PATH.write_text(json.dumps(sentences, ensure_ascii=False, indent=2) + "\n")


def review(sentences, include_all, out):
    shown = [s for s in sentences if include_all or not s["reviewed"]]
    title = "Sentences" if include_all else "Sentences to review"
    lines = [f"# {title} ({len(shown)})", ""]
    lines.append("Each blank's conjugation has passed the machine check, which confirms it against the")
    lines.append("conjugator. What it cannot judge is the rest: whether the sentence is natural, whether")
    lines.append("its subject fits the person, whether the word order suits the clause, and whether the")
    lines.append("English says the same thing.")
    verb = None
    for s in shown:
        if s["verb"] != verb:
            verb = s["verb"]
            lines += ["", f"## {verb}", ""]
        cell = TABLE_NAMES.get(s["table"], s["table"])
        if "person" in s:
            cell += f", {PERSONS.get(s['person'], s['person'])}"
        german = re.sub(r"\{([^}]*)\}", r"**\1**", s["de"])
        mark = "" if s["reviewed"] else " (draft)"
        lines.append(f"- `{s['id']}`{mark}, {cell}: {german}  ")
        lines.append(f"  {s['en']}")
    text = "\n".join(lines) + "\n"
    if out:
        pathlib.Path(out).write_text(text)
        print(f"wrote {len(shown)} sentences to {out}")
    else:
        sys.stdout.write(text)


def approve(sentences, ids, approve_all, excepted):
    known = {s["id"] for s in sentences}
    unknown = [i for i in ids + excepted if i not in known]
    if unknown:
        sys.exit(f"unknown ids: {', '.join(unknown)}")
    chosen = known - set(excepted) if approve_all else set(ids)
    changed = 0
    for s in sentences:
        if s["id"] in chosen and not s["reviewed"]:
            s["reviewed"] = True
            changed += 1
    save(sentences)
    print(f"approved {changed}; {sum(not s['reviewed'] for s in sentences)} drafts remain")


def status(sentences):
    reviewed = sum(s["reviewed"] for s in sentences)
    verbs = sorted({s["verb"] for s in sentences})
    print(f"{len(sentences)} sentences: {reviewed} reviewed, {len(sentences) - reviewed} drafts")
    print(f"{len(verbs)} verbs: {', '.join(verbs)}")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    r = sub.add_parser("review")
    r.add_argument("--all", action="store_true")
    r.add_argument("--out")
    a = sub.add_parser("approve")
    a.add_argument("ids", nargs="*")
    a.add_argument("--all", action="store_true")
    a.add_argument("--except", dest="excepted", nargs="*", default=[])
    sub.add_parser("status")
    args = parser.parse_args()
    sentences = load()
    if args.command == "review":
        review(sentences, args.all, args.out)
    elif args.command == "approve":
        if not args.all and not args.ids:
            sys.exit("name ids to approve, or pass --all")
        approve(sentences, args.ids, args.all, args.excepted)
    else:
        status(sentences)


if __name__ == "__main__":
    main()
