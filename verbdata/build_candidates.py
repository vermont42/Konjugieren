#!/usr/bin/env python3
"""Reduce the kaikki German-verb snapshot to a compact candidate file.

Stage A of the classify-and-verify pipeline described in docs/verb-sources.md.
Reads verbdata/kaikki.org-dictionary-German-by-pos-verb.jsonl (294 MB) plus
Konjugieren/Models/Verbs.xml, and writes verbdata/candidates.json holding one
record per single-word lemma absent from Konjugieren, with its conjugation table
normalized into the app's own conjugationgroup vocabulary.

Stage B (KonjugierenTests/Utils/VerbClassificationTests.swift) consumes that file.
"""

import argparse
import json
import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
KAIKKI = REPO / "verbdata" / "kaikki.org-dictionary-German-by-pos-verb.jsonl"
VERBS_XML = REPO / "Konjugieren" / "Models" / "Verbs.xml"
DEFAULT_OUT = REPO / "verbdata" / "candidates.json"

PERSON_TAGS = {"first-person": "f", "second-person": "s", "third-person": "t"}
NUMBER_TAGS = {"singular": "s", "plural": "p"}

# Tags that qualify a form without changing which slot it fills.
VARIANT_TAGS = {"formal", "informal", "rare", "archaic", "colloquial", "dated", "obsolete", "error-unrecognized-form"}


def current_infinitives():
    """Every infinitive in Verbs.xml, markers stripped.

    Strips [+*^], not [+^]: see the trap documented in verbdata/README.md.
    """
    xml = VERBS_XML.read_text()
    return {re.sub(r"[+*^]", "", m) for m in re.findall(r'<verb\s[^>]*\bin="([^"]+)"', xml)}


def slot_for(tags):
    """Map a kaikki form's tags onto '<conjugationgroup>.<personNumber>', or None."""
    tags = set(tags)

    if "multiword-construction" in tags:
        return None
    if tags & {"table-tags", "inflection-template", "class", "auxiliary"}:
        return None

    if "participle" in tags:
        if "past" in tags:
            return "perfektpartizip"
        if "present" in tags:
            return "präsenspartizip"
        return None

    person = next((v for k, v in PERSON_TAGS.items() if k in tags), None)
    number = next((v for k, v in NUMBER_TAGS.items() if k in tags), None)
    if person is None or number is None:
        return None
    person_number = person + number

    if "imperative" in tags:
        return f"imperativ.{person_number}" if person_number in {"ss", "sp"} else None
    if "subjunctive-i" in tags:
        return f"präsensKonjunktivI.{person_number}"
    if "subjunctive-ii" in tags:
        return f"präteritumKonjunktivII.{person_number}"
    if "indicative" in tags:
        if "present" in tags:
            return f"präsensIndikativ.{person_number}"
        if "preterite" in tags:
            return f"präteritumIndikativ.{person_number}"
    return None


def extract(record):
    """Build a candidate dict from one kaikki lemma record."""
    forms = {}
    auxiliaries = set()
    table_tags = set()
    verb_class = None

    for form in record.get("forms", []):
        value = (form.get("form") or "").strip()
        tags = form.get("tags", [])
        if not value or value == "-":
            continue
        if "auxiliary" in tags:
            auxiliaries.add(value)
            continue
        if "table-tags" in tags:
            table_tags.update(value.split())
            continue
        if "class" in tags:
            verb_class = value
            continue
        # The conjugation table is authoritative; headword forms duplicate it.
        if form.get("source") != "conjugation":
            continue
        slot = slot_for(tags)
        if slot is None:
            continue
        primary = not (set(tags) & VARIANT_TAGS)
        bucket = forms.setdefault(slot, [])
        if value not in bucket:
            # Unqualified forms sort ahead of rare/archaic/formal variants.
            if primary:
                bucket.insert(0, value)
            else:
                bucket.append(value)

    glosses = []
    for sense in record.get("senses", []):
        for gloss in sense.get("glosses", []):
            if gloss not in glosses:
                glosses.append(gloss)

    return {
        "word": record["word"],
        "glosses": glosses[:6],
        "auxiliary": sorted(auxiliaries),
        "tableTags": sorted(table_tags),
        "verbClass": verb_class,
        "hasEtymology": bool(record.get("etymology_text")),
        "forms": forms,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=pathlib.Path, default=DEFAULT_OUT)
    parser.add_argument("--include-existing", action="store_true",
                        help="Also emit the 990 verbs already in Verbs.xml, as a regression oracle.")
    parser.add_argument("--limit", type=int, default=0, help="Emit at most N candidates (smoke tests).")
    args = parser.parse_args()

    if not KAIKKI.exists():
        sys.exit(f"missing {KAIKKI}; see the re-download recipe in verbdata/README.md")

    existing = current_infinitives()
    candidates = []
    seen = set()
    stats = {"records": 0, "lemmas": 0, "multiword": 0, "already_shipping": 0, "duplicate": 0, "no_table": 0}

    with KAIKKI.open() as handle:
        for line in handle:
            stats["records"] += 1
            record = json.loads(line)
            if any(sense.get("form_of") for sense in record.get("senses", [])):
                continue
            stats["lemmas"] += 1
            word = record.get("word", "")
            if " " in word or "-" in word:
                stats["multiword"] += 1
                continue
            if word in existing and not args.include_existing:
                stats["already_shipping"] += 1
                continue
            if word in seen:
                # Wiktionary splits homographs across Etymology sections; the first
                # record wins and the collision is reported in the report's notes.
                stats["duplicate"] += 1
                continue
            candidate = extract(record)
            if "perfektpartizip" not in candidate["forms"] or len(candidate["forms"]) < 8:
                stats["no_table"] += 1
                continue
            candidate["alreadyShipping"] = word in existing
            seen.add(word)
            candidates.append(candidate)
            if args.limit and len(candidates) >= args.limit:
                break

    candidates.sort(key=lambda candidate: candidate["word"])
    args.out.write_text(json.dumps({"stats": stats, "candidates": candidates}, ensure_ascii=False))
    print(json.dumps(stats, indent=2))
    print(f"wrote {len(candidates)} candidates to {args.out} ({args.out.stat().st_size / 1e6:.1f} MB)")


if __name__ == "__main__":
    main()
