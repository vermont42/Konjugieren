#!/usr/bin/env python3
"""
Phase 4 of prompts/uses_etymologies.md: build self-contained mining shards.

Consumes
    Konjugieren/Models/Verbs.xml           — targets (hp="y") and their readings
    Konjugieren/Models/Etymologies.json    — to identify what is already done
    corpus/working/corpus_index.json       — pre-found, pre-ranked example candidates
    verbdata/roots.json                    — root → etymology
    verbdata/prefixes-inseparable.json     — prefix → {chain, senses}
    verbdata/prefixes-separable.json       — particle → {kind, chain, senses}

Produces
    corpus/working/shards/mine_<NNN>.in.json

Run
    python3 corpus/working/build_mining_shards.py [--size 25]

The whole point is that a shard is **self-contained**. A mining subagent must not
read the corpus (6.5 MB per agent, the cost Phase 2 exists to avoid), must not read
Etymologies.json, and must not go looking for a root's etymology — everything it
needs is joined into its shard here, once, deterministically. What it contributes
is judgment: which candidate is a genuine verbal use, and what the specific
compound means.

Three things this script encodes that are not obvious from the data:

* **A verb can have several readings**, and they can differ in separability —
  `über*setzen` "translate" against `über+setzen` "ferry across". The reading's own
  `in` attribute overrides the verb's when present, so the decomposition is computed
  per reading, not per verb.
* **The last-marker rule mis-splits two verbs.** `be*mitleiden` and `ver*anschlagen`
  mark only their outer boundary, correctly, since both compounds are wholly
  inseparable. Their roots therefore come out as `mitleiden` and `anschlagen`, which
  exist in roots.json as composed entries. No special-casing is needed here, but a
  reader wondering why those two look odd should know it is deliberate.
* **Roughly a third of targets have no candidates at all.** They are still shipped
  in shards, because the etymology half of the job does not depend on the corpus.
  Their `candidates` list is empty and the subagent returns a null sentence.
"""

import argparse
import json
import pathlib
import re
import xml.etree.ElementTree as ET

REPO = pathlib.Path(__file__).resolve().parent.parent.parent
VERBS_XML = REPO / "Konjugieren/Models/Verbs.xml"
ETYMOLOGIES = REPO / "Konjugieren/Models/Etymologies.json"
INDEX = REPO / "corpus/working/corpus_index.json"
ROOTS = REPO / "verbdata/roots.json"
INSEP = REPO / "verbdata/prefixes-inseparable.json"
SEP = REPO / "verbdata/prefixes-separable.json"
OUT_DIR = REPO / "corpus/working/shards"
LANGS = ("de", "en")


def strip_markers(form):
    return re.sub(r"[+*^]", "", form)


def decompose(raw):
    """
    `ab+be*stellen` → prefixes [(ab, separable), (be, inseparable)], root `stellen`.

    Segments are the runs between markers; the marker *following* a segment states
    how that segment attaches, which is why the token list is walked pairwise rather
    than simply split.
    """
    prefixes, segment = [], ""
    for token in re.findall(r"[^+*]+|[+*]", raw):
        if token in "+*":
            prefixes.append((strip_markers(segment),
                             "separable" if token == "+" else "inseparable"))
            segment = ""
        else:
            segment = token
    return prefixes, strip_markers(segment)


def build_reading(raw, attrib, morphemes, roots, insep, sep):
    """
    Join one reading against the three reuse files, interning each morpheme into
    the shard's shared `morphemes` table and referring to it by key.

    Interning is not a micro-optimization. Targets are emitted in corpus order,
    which is alphabetical, so a 25-verb shard is typically 25 verbs sharing one
    prefix — `ab+ändern` through `ab+arbeiten` and so on. Inlining the full `ab-`
    entry once per verb tripled shard size, and that cost would have been paid 104
    times over. Roots repeat across shards too (`stellen` heads eighteen compounds).
    """
    prefixes, root = decompose(raw)
    refs = []
    for name, separability in prefixes:
        table = sep if separability == "separable" else insep
        key = f"{separability[:5]}:{name}"
        if key not in morphemes:
            entry = {lang: table[lang].get(name) for lang in LANGS}
            morphemes[key] = {
                "morpheme": name,
                "separability": separability,
                # `kind` exists only on the separable side, where "prefix" spans
                # everything from a grammaticalized preposition to an incorporated noun.
                "kind": (entry["en"] or {}).get("kind", "prefix"),
                "de": entry["de"],
                "en": entry["en"],
            }
        refs.append(key)

    # A root entry carries both a condensed `bullet` and the long `full` article, and
    # which one belongs in the shard depends on how the verb uses it. A prefixed verb
    # cites the root as one bullet among several, so it wants `bullet` — shipping
    # `full` there is what made `abbinden` drag in the whole Sanskrit `bandana`
    # paragraph from `binden`'s article. A simplex verb *is* its root, so its
    # etymology is the article itself, and it wants `full`.
    root_key = f"root:{root}"
    field = "bullet" if prefixes else "full"
    entry = morphemes.setdefault(root_key, {"morpheme": root})
    for lang in LANGS:
        value = roots[lang].get(root) or {}
        # A root needed both ways inside one shard gets both fields, which is rare
        # and cheap; interning by key alone would otherwise drop the second reading.
        entry.setdefault(lang, {})[field] = value.get(field)

    return {
        "in": raw,
        "translation": attrib.get("tn"),
        "family": attrib.get("fa"),
        "auxiliary": attrib.get("ay"),
        "prefixes": refs,
        "root": root_key,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", type=int, default=25,
                        help="verbs per shard; keep fixed so resumed runs stay uniform")
    args = parser.parse_args()

    done = set(json.loads(ETYMOLOGIES.read_text())["en"])
    index = json.loads(INDEX.read_text())
    roots = json.loads(ROOTS.read_text())
    insep = json.loads(INSEP.read_text())
    sep = json.loads(SEP.read_text())

    pending = [verb for verb in ET.parse(VERBS_XML).getroot()
               if strip_markers(verb.get("in")) not in done]

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for stale in OUT_DIR.glob("mine_*.in.json"):
        stale.unlink()

    counts = {"targets": 0, "with_candidates": 0, "candidates": 0}
    unresolved = set()

    for number in range((len(pending) + args.size - 1) // args.size):
        group = pending[number * args.size:(number + 1) * args.size]
        morphemes, verbs = {}, []
        for verb in group:
            raw = verb.get("in")
            infinitive = strip_markers(raw)
            readings = [build_reading(reading.get("in", raw), reading.attrib,
                                      morphemes, roots, insep, sep)
                        for reading in verb]
            candidates = index.get(infinitive, [])
            verbs.append({"verb": infinitive, "readings": readings,
                          "candidates": candidates})
            counts["targets"] += 1
            counts["with_candidates"] += bool(candidates)
            counts["candidates"] += len(candidates)
        for key, entry in morphemes.items():
            if not entry["en"] or (isinstance(entry["en"], dict)
                                   and not any(entry["en"].values())):
                unresolved.add(key)
        path = OUT_DIR / f"mine_{number:03d}.in.json"
        path.write_text(json.dumps({"morphemes": morphemes, "verbs": verbs},
                                   ensure_ascii=False, indent=1) + "\n")

    shards = (len(pending) + args.size - 1) // args.size
    print(f"targets: {counts['targets']}")
    print(f"shards: {shards} of up to {args.size} verbs, in {OUT_DIR}")
    print(f"with at least one candidate: {counts['with_candidates']} "
          f"({counts['with_candidates'] / counts['targets']:.0%}); "
          f"without: {counts['targets'] - counts['with_candidates']}")
    print(f"unresolved morphemes: {len(unresolved)} {sorted(unresolved)[:10]}")
    print(f"candidates joined: {counts['candidates']}")

    # Progress is derived from the filesystem, never tracked in prose. A shard is done
    # when its .out.json exists, which is also the resume rule — relaunch exactly the
    # shards listed as remaining. Rebuilding inputs above never touches outputs, so this
    # is safe to run at any point, including mid-pass.
    done, todo = [], []
    for number in range(shards):
        (done if (OUT_DIR / f"mine_{number:03d}.out.json").exists() else todo).append(number)
    print()
    print(f"mined: {len(done)}/{shards} shards ({len(done) * args.size} verbs, approx)")
    print(f"remaining: {len(todo)}")
    if todo:
        preview = " ".join(f"mine_{n:03d}" for n in todo[:8])
        print(f"next: {preview}{' …' if len(todo) > 8 else ''}")
    else:
        print("Phase 4 is complete; proceed to Phase 5.")


if __name__ == "__main__":
    main()
