#!/usr/bin/env python3
"""
Phase 3 of prompts/uses_etymologies.md: build the three reuse files by *parsing*
the etymologies the app already ships, rather than by generating them again.

Consumes
    Konjugieren/Models/Verbs.xml          — the corpus, for the `in` attribute's
                                            prefix markers (`+` separable,
                                            `*` inseparable, `^…^` ablaut region)
    Konjugieren/Models/Etymologies.json    — {"de": {...}, "en": {...}}, 990 verbs

Produces
    verbdata/roots.json                    — {"de": {...}, "en": {...}}, root → etymology
    verbdata/prefixes-inseparable.json     — {"de": {...}, "en": {...}}, prefix → {chain, senses}
    verbdata/prefixes-separable.json       — same shape
    <workdir>/reuse_gaps.json              — the authoring worklist for what parsing
                                             could not recover (path via --gaps)

Run
    python3 verbdata/build_reuse_files.py --gaps /path/to/reuse_gaps.json

Idempotent and non-destructive: entries already present in the three output files
are preserved, so re-running after subagents have filled gaps does not clobber
their work. Only missing keys are added.

Why parse rather than generate
------------------------------
The 990 existing entries are not atomic prose. A compound's etymology decomposes
into per-morpheme bullets:

    - ~meiden~: From MHG ~mīden~, from OHG ~mīdan~, … PIE *~meyth₂-~ …
    - ~ver-~:   From MHG ~ver-~, from OHG ~fir-~, … PIE *~per~ … Here the prefix
                intensifies the act of shunning.

So `meiden`'s etymology has been shipping inside `vermeiden`'s since before
`meiden` was a verb in this app. Re-deriving it pays twice for one piece of
scholarship.

Three external facts shaped this script, none of them recoverable from the code:

1. A *prefix* bullet is two things welded together: a genealogical chain that is
   identical for every compound using that prefix, and a final sentence glossing
   what the prefix contributes *to this particular compound*. Only the chain is
   reusable verbatim. Hence the {chain, senses} value shape for prefixes, against
   the flat-string shape for roots — a root bullet is reusable whole.
2. The chains drift stylistically across the 990 entries: "MHG" / "Mhd." /
   "Middle High German", "From" / "Von" / "Aus", and even the PIE accent
   (*h₂epo* vs *h₂epó*). This script therefore emits *candidates* — every
   distinct chain seen, longest first — and leaves normalization to the
   authoring step. It does not guess which spelling is house style.
3. `be*mitleiden` and `ver*anschlagen` carry only their outer prefix boundary,
   because both compounds are wholly inseparable and marking the inner `mit`/`an`
   as separable would be a lie about their syntax. The last-marker rule therefore
   reports `mitleiden` and `anschlagen` as roots. They are left as roots and
   authored compositionally; Verbs.xml is not touched.
"""

import argparse
import json
import pathlib
import re
import xml.etree.ElementTree as ET
from collections import Counter, OrderedDict

REPO = pathlib.Path(__file__).resolve().parent.parent
VERBS_XML = REPO / "Konjugieren/Models/Verbs.xml"
ETYMOLOGIES = REPO / "Konjugieren/Models/Etymologies.json"
ROOTS_OUT = REPO / "verbdata/roots.json"
INSEP_OUT = REPO / "verbdata/prefixes-inseparable.json"
SEP_OUT = REPO / "verbdata/prefixes-separable.json"

LANGS = ("de", "en")

# A bullet line: "- ~ver-~: From MHG …". The head is a morpheme, trailing hyphen
# on prefixes. Bullets are always one physical line in these entries.
BULLET = re.compile(r"^- ~([^~]+)~: (.+)$", re.M)

# The genealogical chain ends at the PIE etymon; whatever follows is the
# compound-specific gloss. Matching on the *last* PIE mention rather than the
# first is deliberate: a few chains cite an intermediate PIE root before the
# ultimate one.
PIE_CLAUSE = re.compile(r"(?:PIE|Proto-Indo-European|Urindogermanisch|urindogermanisch)\b")


def strip_markers(form: str) -> str:
    """`ver*m^ei^den` → `vermeiden`. The markers are corpus encoding, not spelling."""
    return re.sub(r"[+*^]", "", form)


def sanitize(text: str) -> str:
    """
    Repair two defects present in the shipping German etymologies, at the moment
    the text is copied into a reuse file. Copying them forward would multiply each
    one by however many compounds later reuse the root.

    * A literal backslash-n, in 49 German entries (and zero English ones), which
      renders as two visible characters instead of a paragraph break. The English
      side of the same entries carries real newlines, so the intent is unambiguous.
    * U+0137 `ķ` — a Latvian k-cedilla — standing in for U+1E31 `ḱ`, the PIE
      palatal, in 36 places. At body-text size the two are nearly identical, which
      is presumably how it survived review; in a reconstructed etymon it is simply
      a different sound.

    Both are fixed here rather than in Konjugieren/Models/Etymologies.json, which
    is shipping app content and Josh's call to change.
    """
    return text.replace("\\n", "\n").replace("ķ", "ḱ")


def split_chain_and_gloss(text: str) -> tuple[str, str]:
    """
    Cut a prefix bullet into (chain, gloss).

    The chain runs through the sentence containing the last PIE etymon; the gloss
    is everything after. A bullet with no PIE mention has no reliable cut point,
    so the whole thing is treated as chain and the gloss is empty — better an
    over-long chain a human trims than a gloss silently promoted to genealogy.

    Sentence splitting cannot use a bare period: the chains are dense in
    abbreviations ("Mhd.", "Ahd.", "vgl."). Requiring the period to be followed by
    whitespace and a capital letter (or end of string) survives all of them.
    """
    matches = list(PIE_CLAUSE.finditer(text))
    if not matches:
        return text.strip(), ""
    tail_start = matches[-1].end()
    end = re.search(r"\.(?=\s+[A-ZÄÖÜ]|\s*$)", text[tail_start:])
    if not end:
        return text.strip(), ""
    cut = tail_start + end.end()
    return text[:cut].strip(), text[cut:].strip()


def collect_bullets(entries: dict[str, str]) -> dict[str, list[tuple[str, str]]]:
    """morpheme → [(verb it was found in, bullet text)], preserving corpus order."""
    found: dict[str, list[tuple[str, str]]] = {}
    for verb, text in entries.items():
        for match in BULLET.finditer(text):
            found.setdefault(match.group(1), []).append((verb, match.group(2)))
    return found


def target_inventory() -> tuple[list[str], set[str], Counter, Counter]:
    """
    Walk Verbs.xml and report what the pipeline actually needs:
    the verbs with no etymology, their final roots, and the prefix inventory
    with occurrence counts (counts drive authoring order, not correctness).
    """
    have = set(json.loads(ETYMOLOGIES.read_text())["en"])
    missing, roots = [], set()
    separable, inseparable = Counter(), Counter()
    for verb in ET.parse(VERBS_XML).getroot():
        raw = verb.get("in")
        key = strip_markers(raw)
        if key in have:
            continue
        missing.append(key)
        boundary = max(raw.rfind("+"), raw.rfind("*"))
        roots.add(key if boundary == -1 else strip_markers(raw[boundary + 1:]))
        # Segments between markers are prefixes; the marker *after* a segment
        # says how that segment attaches, so the token list is walked pairwise.
        segment = ""
        for token in re.findall(r"[^+*]+|[+*]", raw):
            if token in "+*":
                (separable if token == "+" else inseparable)[strip_markers(segment)] += 1
                segment = ""
            else:
                segment = token
    return missing, roots, separable, inseparable


def seed_roots(entries: dict[str, str], bullets, needed: set[str]) -> tuple[dict, list, list]:
    """
    Seed root → etymology. Two sources, in order of trust:

    1. The root's own top-level entry, when it is one of the 990. Reusable whole.
    2. The longest bullet for that root inside some compound. Six roots — leihen,
       meiden, schreiten, schwinden, winden, zeihen — exist only this way: their
       etymology has been shipping inside a compound's for months.

    Longest-wins for bullets because the chains are unevenly truncated: some
    compounds cite only "From PIE *~per~" where others give the full MHG→PIE walk.
    """
    seeded, from_top, from_bullet = OrderedDict(), [], []
    for root in sorted(needed):
        if root in entries:
            seeded[root] = sanitize(entries[root])
            from_top.append(root)
        elif root in bullets:
            seeded[root] = sanitize(max((text for _, text in bullets[root]), key=len))
            from_bullet.append(root)
    return seeded, from_top, from_bullet


def harvest_prefixes(bullets, inventory: Counter) -> dict:
    """
    Harvest raw material for every prefix in the inventory: prefix → the distinct
    chains and glosses the corpus already contains, longest first.

    This deliberately returns *candidates*, not finished entries. The chains drift
    across the 990 entries in abbreviation, preposition, and PIE accent, so the
    authoring step picks and normalizes; a machine that guessed would freeze one
    arbitrary variant into every compound sharing the prefix.

    Two bullet-key shapes, and the distinction changes how the text is cut:

    * `~ver-~`, with the hyphen — a genuine prefix. Its bullet is a shared chain
      welded to a gloss of what the prefix does *in this compound*, so the two
      are split and the glosses accumulate as candidate senses.
    * `~frei~` / `~stehen~`, bare — a particle that is an ordinary adjective or
      verb (*freisprechen*, *stehenbleiben*). Its bullet is that word's own
      etymology end to end, cognates included. Splitting it would file "Cognate
      with English ~free~" as a semantic contribution, so it is left whole.
    """
    harvest = OrderedDict()
    for prefix, count in inventory.most_common():
        prefixal = bullets.get(prefix + "-")
        instances = prefixal or bullets.get(prefix) or []
        chains, senses = [], []
        for _, text in instances:
            chain, gloss = split_chain_and_gloss(text) if prefixal else (text.strip(), "")
            if chain and chain not in chains:
                chains.append(chain)
            if gloss and gloss not in senses:
                senses.append(gloss)
        harvest[prefix] = {
            "occurrences": count,
            "is_prefixal": bool(prefixal),
            "chain_candidates": sorted(chains, key=len, reverse=True)[:6],
            "sense_candidates": senses[:12],
        }
    return harvest


def merge_preserving(path: pathlib.Path, fresh: dict[str, dict]) -> dict:
    """
    Fold newly seeded entries into whatever the file already holds, never
    overwriting. Re-running after an authoring pass must not undo it, because the
    authoring pass is the expensive half and the seeding is the cheap half.
    """
    existing = json.loads(path.read_text()) if path.exists() else {lang: {} for lang in LANGS}
    for lang in LANGS:
        merged = existing.setdefault(lang, {})
        for key, value in fresh[lang].items():
            merged.setdefault(key, value)
        existing[lang] = OrderedDict(sorted(merged.items()))
    return existing


def write_json(path: pathlib.Path, payload) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--gaps", required=True, help="path for the authoring worklist")
    args = parser.parse_args()

    etymologies = json.loads(ETYMOLOGIES.read_text())
    missing, roots, separable, inseparable = target_inventory()

    bullets = {lang: collect_bullets(etymologies[lang]) for lang in LANGS}

    roots_seed, from_top, from_bullet = {}, None, None
    for lang in LANGS:
        seeded, top, bullet = seed_roots(etymologies[lang], bullets[lang], roots)
        roots_seed[lang] = seeded
        if lang == "en":
            from_top, from_bullet = top, bullet

    write_json(ROOTS_OUT, merge_preserving(ROOTS_OUT, roots_seed))
    for path in (INSEP_OUT, SEP_OUT):
        if not path.exists():
            write_json(path, {lang: {} for lang in LANGS})

    root_gaps = sorted(roots - set(roots_seed["en"]))
    write_json(pathlib.Path(args.gaps), {
        "roots": root_gaps,
        "prefixes_inseparable": {
            lang: harvest_prefixes(bullets[lang], inseparable) for lang in LANGS
        },
        "prefixes_separable": {
            lang: harvest_prefixes(bullets[lang], separable) for lang in LANGS
        },
    })

    harvested = harvest_prefixes(bullets["en"], separable)
    with_material = [p for p, v in harvested.items() if v["chain_candidates"]]
    covered = sum(separable[p] for p in with_material)
    print(f"verbs missing an etymology: {len(missing)}")
    print(f"roots needed: {len(roots)}  "
          f"seeded from own entry: {len(from_top)}  from bullets: {len(from_bullet)}  "
          f"to author: {len(root_gaps)}")
    print(f"inseparable prefixes: {len(inseparable)}  all have harvested material: "
          f"{all(harvest_prefixes(bullets['en'], inseparable)[p]['chain_candidates'] for p in inseparable)}")
    print(f"separable prefixes: {len(separable)}  with harvested material: {len(with_material)}  "
          f"from scratch: {len(separable) - len(with_material)}")
    print(f"separable occurrences with harvested material: {covered}/{sum(separable.values())} "
          f"({covered / sum(separable.values()):.0%})")


if __name__ == "__main__":
    main()
