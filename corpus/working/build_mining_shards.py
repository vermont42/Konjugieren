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
    verbdata/sense-exemplars.json          — exemplar verbs per sense, a picking aid

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
EXEMPLARS = REPO / "verbdata/sense-exemplars.json"
OUT_DIR = REPO / "corpus/working/shards"
LANGS = ("de", "en")


# Splits that the markers in Verbs.xml license but etymology forbids: the innermost
# prefix and the remainder look like a compound and are not one. Keyed by
# (prefix, apparent root) and merged back into a single atomic root.
#
# `be*fehlen` is the case that prompted this. `befehlen` is MHG *bevelhen*, OHG
# *bifelahan*, from Proto-Germanic *felhaną "hide, entrust"; `fehlen` is an Old French
# loan from *faillir*. They are unrelated, so routing `befehlen` to `root:fehlen` tells
# a learner something false about both. This is the `be*gleiten` trap from the project
# prompt's Traps section, which survives in Verbs.xml because the markers there record
# *separability*, which is a fact about conjugation, not about descent.
#
# The reliable tell is a strong/weak mismatch: `befehlen` is `family="s"` (befiehlt,
# befahl, befohlen) while `fehlen` is weak, exactly as `begleiten` is weak while
# `gleiten` is strong. A shared root cannot inflect two ways. Check that before adding
# an entry here, and confirm against kaikki's `etymology_text`.
#
# Verified not to belong here: `ver*fehlen` (genuinely ver- + fehlen, and weak like it)
# and `emp*finden` (genuinely ent- + finden).
FALSE_SPLITS = {
    ("be", "fehlen"): "befehlen",
}


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
    root = strip_markers(segment)
    # Fold a false compound back together, innermost prefix first. Outer prefixes are
    # untouched: `an+be*fehlen` becomes an- plus the atomic root `befehlen`.
    if prefixes and (prefixes[-1][0], root) in FALSE_SPLITS:
        root = FALSE_SPLITS[(prefixes[-1][0], root)]
        prefixes = prefixes[:-1]
    return prefixes, root


# Kinds whose morpheme is a free word of modern German, and so must NOT take the
# trailing hyphen that marks a bound morpheme: hyphenating `besser` in
# `besserstellen` would claim it cannot stand alone, which is false.
FREE_WORD_KINDS = {"adjective", "noun", "verb"}


def display_form(name, kind):
    """
    The exact string a subagent should write for this morpheme, hyphen included.

    Precomputed because inferring it cost three shard-runs on 2026-07-21, each of
    which reported the same defect: the brief keyed the rule on `kind == "prefix"`,
    which is the default assigned above for the 13 inseparables and therefore says
    nothing about the 233 separable kinds. Agents inferred their way around it and
    disagreed — 36 hyphenated deictics against 11 bare, and the bare ones produced a
    bullet reading `- ~dabei~:` directly above a spliced sense reading `~dabei-~
    marks …`, contradicting itself one clause later.

    The split is bound-versus-free, derived from the 29 shards mined before it was
    precomputed and confirmed against each morpheme's own sense text:

      hyphen  particle (537 mined uses, 0 bare), deictic (42 of 45 self-hyphenate),
              fossil, adverb (8 of 9 self-hyphenate), and every inseparable
      bare    adjective (76 self-bare, 0 self-hyphenated), noun, verb

    `adverb` is the one that looks wrong and is not: the kind is defined as a free
    modern adverb, but `beiseite`, `quer`, and `weiter` all write themselves
    `~beiseite-~` in their own sense prose. A shard-run guessed bare from the
    definition and would have been the fourth agent to invent a different answer.
    """
    return f"~{name}-~" if kind not in FREE_WORD_KINDS else f"~{name}~"


def build_reading(raw, attrib, morphemes, roots, insep, sep, exemplars):
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
            kind = (entry["en"] or {}).get("kind", "prefix")
            morphemes[key] = {
                "morpheme": name,
                "separability": separability,
                # `kind` exists only on the separable side, where "prefix" spans
                # everything from a grammaticalized preposition to an incorporated noun.
                "kind": kind,
                "display": display_form(name, kind),
                "de": entry["de"],
                "en": entry["en"],
            }
            # Exemplar verbs per sense, parallel by index. A selection aid only: never
            # spliced into the prose, so it cannot change what a reader sees. Present
            # for the high-traffic prefixes; absent elsewhere, which simply means no
            # hint rather than an error.
            if key in exemplars:
                morphemes[key]["sense_exemplars"] = exemplars[key]
        refs.append(key)

    # A root entry carries both a condensed `bullet` and the long `full` article, and
    # which one belongs in the shard depends on how the verb uses it. A prefixed verb
    # cites the root as one bullet among several, so it wants `bullet` — shipping
    # `full` there is what made `abbinden` drag in the whole Sanskrit `bandana`
    # paragraph from `binden`'s article. A simplex verb *is* its root, so its
    # etymology is the article itself, and it wants `full`.
    root_key = f"root:{root}"
    field = "bullet" if prefixes else "full"
    # A root is always a free word, so it is written bare. It carries `display` anyway
    # because the brief tells subagents the field is the whole rule, and a shard-run on
    # 2026-07-21 correctly objected that roots lacked it — an exhaustive-sounding rule
    # with a hole in the data is how the hyphen ambiguity arose in the first place.
    entry = morphemes.setdefault(root_key, {"morpheme": root, "display": f"~{root}~"})
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
    # Keys prefixed with "_" are documentation, not data.
    exemplars = {k: v for k, v in json.loads(EXEMPLARS.read_text()).items()
                 if not k.startswith("_")}

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
                                      morphemes, roots, insep, sep, exemplars)
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
