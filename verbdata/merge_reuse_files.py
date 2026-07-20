#!/usr/bin/env python3
"""
Fold authored shards into the Phase 3 reuse files, then validate the result.

Consumes
    <shards>/roots_*.out.json    {"de": {root: text}, "en": {root: text}}
    <shards>/insep_*.out.json    {"de": {prefix: {chain, senses, occurrences}}, "en": {...}}
    <shards>/sep_*.out.json      same shape

Produces / updates
    verbdata/roots.json
    verbdata/prefixes-inseparable.json
    verbdata/prefixes-separable.json

Run
    python3 verbdata/merge_reuse_files.py --shards <dir>
    python3 verbdata/merge_reuse_files.py --validate-only

Merging never overwrites an existing key, matching build_reuse_files.py: the seed
is cheap and re-derivable, the authored text is not, and a re-run must not undo it.

The validator is the load-bearing half. These files feed Phase 4, where each entry
is reused verbatim across every compound sharing the morpheme — so a defect here is
multiplied by the morpheme's frequency before anyone sees it. Every check below
exists because the defect it catches was actually observed:

* Unbalanced `~` — RichTextView's parser (StringExtensions.swift) treats an odd
  tilde count as an unterminated delimiter and the emphasis run swallows the rest
  of the paragraph.
* `~*form~` instead of `*~form~` — the asterisk marking a reconstruction must sit
  outside the emphasis delimiters, or the rendered text shows a stray asterisk
  inside italics.
* Forbidden markers — `` ` `` opens a section heading, `$…$` an ablaut highlight,
  `‡…‡` a URL, `^…^` a custom emoji asset. All four are meaningful to the parser
  and none belongs in an etymology bullet.
* Cross-language quote leakage — German prose uses „…“ and English "…". A German
  entry containing an ASCII double quote is a translation that was not finished.
* Literal `\\n` — 49 shipping German entries in Etymologies.json carry a backslash-n
  that renders as visible characters instead of a paragraph break. Do not add more.
* U+0137 `ķ` for U+1E31 `ḱ` — the PIE palatal. 36 instances reached shipping data,
  presumably from a keyboard or font substitution that looks right at small sizes.
  A wrong PIE etymon is exactly the kind of error this pipeline is built to avoid
  paying for twice.
"""

import argparse
import glob
import json
import pathlib
import re
import sys
import xml.etree.ElementTree as ET
from collections import OrderedDict

REPO = pathlib.Path(__file__).resolve().parent.parent
VERBS_XML = REPO / "Konjugieren/Models/Verbs.xml"
ETYMOLOGIES = REPO / "Konjugieren/Models/Etymologies.json"
ROOTS = REPO / "verbdata/roots.json"
INSEP = REPO / "verbdata/prefixes-inseparable.json"
SEP = REPO / "verbdata/prefixes-separable.json"
LANGS = ("de", "en")

FORBIDDEN = {"`": "section-heading marker", "$": "ablaut-highlight marker",
             "‡": "URL marker", "^": "custom-emoji marker"}
K_CEDILLA = "ķ"  # U+0137, not the PIE palatal ḱ (U+1E31)

# What a separable "prefix" actually is. German's separable prefixes are an open
# class, so the 233 entries are not 233 prefixes — the label spans grammaticalized
# prepositions, transparent deictic compounds, adjectives in resultative frames,
# incorporated nouns, and frozen phrases. Phase 4 composes differently for each,
# so the kind is recorded rather than inferred from the chain's wording.
#
# The distinction that matters most is synchronic, not etymological: `weg` and
# `beiseite` are frozen phrases historically (MHG `enwec` < OHG `in weg`) but free
# adverbs today, and the composing subagent needs the modern reading. Their
# histories live in their `chain`.
PARTICLE_KINDS = {
    "particle",   # old preposition/adverb grammaticalized into a separable prefix
    "deictic",    # her-/hin-/da(r)-/-einander compound, incl. colloquial contractions
    "adjective",  # adjective in a resultative frame: totschlagen = beat until dead
    "adverb",     # free modern adverb, neither deictic compound nor resultative
    "noun",       # noun incorporated as object or adverbial: teilnehmen, preisgeben
    "verb",       # a verb used as a particle: stehenbleiben, steckenbleiben
    "fossil",     # strictly bound — not a free word of modern German at all
}


def load(path):
    return json.loads(path.read_text()) if path.exists() else {lang: {} for lang in LANGS}


def sanitize(value):
    """
    Repair the two defects inherited from the shipping German etymologies wherever
    they appear, at write time rather than at seed time. Applied on every write so
    that a seed produced before the repair existed is fixed by the next merge —
    the alternative, a one-off cleanup, leaves the defect latent for the next
    person who re-seeds. Idempotent, and a no-op on authored text.

    See build_reuse_files.py's `sanitize` for what the two defects are and why they
    are fixed here rather than in Konjugieren/Models/Etymologies.json.
    """
    if isinstance(value, str):
        return value.replace("\\n", "\n").replace("ķ", "ḱ")
    if isinstance(value, list):
        return [sanitize(item) for item in value]
    if isinstance(value, dict):
        return {key: sanitize(item) for key, item in value.items()}
    return value


def write(path, payload):
    for lang in LANGS:
        payload[lang] = OrderedDict(
            (key, sanitize(value)) for key, value in sorted(payload[lang].items())
        )
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n")


def merge(target, pattern, shard_dir):
    """Fold every matching shard into `target`, never overwriting an existing key."""
    added = 0
    for shard in sorted(glob.glob(str(pathlib.Path(shard_dir) / pattern))):
        payload = json.loads(pathlib.Path(shard).read_text())
        for lang in LANGS:
            for key, value in payload.get(lang, {}).items():
                if key not in target[lang]:
                    target[lang][key] = value
                    added += 1
    return added


def texts_of(entry):
    """Every human-readable string in an entry, whatever its shape."""
    if isinstance(entry, str):
        return [entry]
    return [entry.get("chain", "")] + list(entry.get("senses", []))


def check_markup(where, lang, text, problems):
    if text.count("~") % 2:
        problems.append(f"{where} [{lang}]: odd number of ~ delimiters")
    if "~*" in text:
        problems.append(f"{where} [{lang}]: '~*' — asterisk belongs outside the tildes")
    for marker, meaning in FORBIDDEN.items():
        if marker in text:
            problems.append(f"{where} [{lang}]: contains {marker!r} ({meaning})")
    if "\\n" in text:
        problems.append(f"{where} [{lang}]: literal backslash-n")
    if K_CEDILLA in text:
        problems.append(f"{where} [{lang}]: U+0137 ķ — the PIE palatal is ḱ (U+1E31)")
    if lang == "de" and '"' in text:
        problems.append(f"{where} [de]: ASCII double quote — German prose uses „…“")
    if lang == "en" and ("„" in text or "“" in text):
        problems.append(f"{where} [en]: German quotation marks in English prose")


def needed_inventory():
    """The roots and prefixes Phase 4 will actually look up. Re-derived, not trusted."""
    have = set(json.loads(ETYMOLOGIES.read_text())["en"])
    roots, separable, inseparable = set(), set(), set()
    for verb in ET.parse(VERBS_XML).getroot():
        raw = verb.get("in")
        if re.sub(r"[+*^]", "", raw) in have:
            continue
        boundary = max(raw.rfind("+"), raw.rfind("*"))
        roots.add(re.sub(r"[+*^]", "", raw if boundary == -1 else raw[boundary + 1:]))
        segment = ""
        for token in re.findall(r"[^+*]+|[+*]", raw):
            if token in "+*":
                (separable if token == "+" else inseparable).add(re.sub(r"[+*^]", "", segment))
                segment = ""
            else:
                segment = token
    return roots, separable, inseparable


def validate():
    problems = []
    roots, insep, sep = load(ROOTS), load(INSEP), load(SEP)
    need_roots, need_sep, need_insep = needed_inventory()

    for label, data, needed in (("roots", roots, need_roots),
                                ("prefixes-inseparable", insep, need_insep),
                                ("prefixes-separable", sep, need_sep)):
        if set(data["de"]) != set(data["en"]):
            only_de = sorted(set(data["de"]) - set(data["en"]))
            only_en = sorted(set(data["en"]) - set(data["de"]))
            problems.append(f"{label}: de/en key mismatch — de-only {only_de}, en-only {only_en}")
        for key in sorted(needed - set(data["en"])):
            problems.append(f"{label}: missing required entry {key!r}")
        for lang in LANGS:
            for key, entry in data[lang].items():
                for text in texts_of(entry):
                    check_markup(f"{label}/{key}", lang, text, problems)
                if isinstance(entry, str):
                    continue
                # A chain may legitimately end on a quoted gloss — `… means "past, by."`
                # — so the sentence-final period is allowed to sit inside a closing
                # quotation mark or parenthesis rather than at the very end.
                if not re.search(r'\.["“”„»)\]]*$', entry.get("chain", "").rstrip()):
                    problems.append(f"{label}/{key} [{lang}]: chain does not end in a period")
                if not entry.get("senses"):
                    problems.append(f"{label}/{key} [{lang}]: no senses")
                if label == "prefixes-separable" and entry.get("kind") not in PARTICLE_KINDS:
                    problems.append(f"{label}/{key} [{lang}]: kind {entry.get('kind')!r} "
                                    f"is not one of {sorted(PARTICLE_KINDS)}")
        for key in set(data["de"]) & set(data["en"]):
            de, en = data["de"][key], data["en"][key]
            if isinstance(de, dict) and de.get("kind") != en.get("kind"):
                problems.append(f"{label}/{key}: de kind {de.get('kind')!r} != "
                                f"en kind {en.get('kind')!r}")
        for key in set(data["de"]) & set(data["en"]):
            de, en = data["de"][key], data["en"][key]
            if isinstance(de, dict) and len(de.get("senses", [])) != len(en.get("senses", [])):
                problems.append(f"{label}/{key}: de has {len(de['senses'])} senses, "
                                f"en has {len(en['senses'])} — they must correspond item for item")

    print(f"roots: {len(roots['en'])} entries, {len(need_roots)} required")
    print(f"prefixes-inseparable: {len(insep['en'])} entries, {len(need_insep)} required")
    print(f"prefixes-separable: {len(sep['en'])} entries, {len(need_sep)} required")
    if problems:
        print(f"\n{len(problems)} problem(s):")
        for problem in problems:
            print(f"  - {problem}")
        return 1
    print("\nAll checks passed.")
    return 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--shards", help="directory holding *_NN.out.json shard files")
    parser.add_argument("--validate-only", action="store_true")
    args = parser.parse_args()

    if not args.validate_only:
        if not args.shards:
            parser.error("--shards is required unless --validate-only is given")
        for path, pattern in ((ROOTS, "roots_*.out.json"),
                              (INSEP, "insep_*.out.json"),
                              (SEP, "sep_*.out.json")):
            data = load(path)
            added = merge(data, pattern, args.shards)
            write(path, data)
            print(f"{path.name}: +{added} entries (both languages counted)")
        print()

    sys.exit(validate())


if __name__ == "__main__":
    main()
