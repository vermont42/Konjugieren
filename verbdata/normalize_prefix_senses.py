#!/usr/bin/env python3
"""Normalize prefix/particle `senses` to complete sentences, in place.

Consumes and rewrites `verbdata/prefixes-inseparable.json` and
`verbdata/prefixes-separable.json`. Idempotent: a second run is asserted to be a no-op (see main()).

    python3 verbdata/normalize_prefix_senses.py [--dry-run]

WHY THIS EXISTS
---------------
Phase 4's brief tells a mining subagent to splice `<chain, verbatim> <sense, verbatim>`.
That instruction is only executable if every sense is a complete sentence. It was not:
about 45% of prefix-slot occurrences carried *fragment* senses, in two distinct grammars —

    predicate fragment:  "makes an intransitive verb transitive, directing the action…"
    gloss fragment:      "old, aged"

Spliced verbatim after the chain's final period, a predicate fragment yields
"…the preposition ~bei~. makes an intransitive verb transitive". Every subagent noticed
and silently invented its own connective, so eight mined shards carry four different
voices ("Here it conveys…", "It promotes…", "Here the prefix conveys…", "The prefix
conveys…"). That is precisely the drift verbatim-splicing was meant to prevent, arriving
through the one slot the design left underspecified.

Normalizing the data — rather than teaching the brief a framing rule — is what makes
"splice verbatim" literally true, which is the only version of the instruction that
cannot drift.

THE TWO FRAMES
--------------
Both put the morpheme itself in subject position, which matters for German: a bare
predicate fragment is verb-initial, and German requires the finite verb second, so
"Hier macht ~be-~ …" would demand mutating the spliced string. Subject-first does not —
"~be-~ macht …" is already verb-second. The English frame mirrors it for symmetry.

    predicate  en  "~be-~ makes an intransitive verb transitive, directing the action…"
               de  "~be-~ macht ein intransitives Verb transitiv und richtet die…"
    gloss      en  "The sense of ~alt~ here is: old, aged."
               de  "Die Bedeutung von ~alt~ ist hier: alt, betagt."

Senses that are *already* complete sentences are left untouched: they are authored
scholarship, they splice correctly as they stand, and rewriting them would churn the
file for no gain.

CLASSIFICATION
--------------
Per sense string, never per `kind` — every one of the eight `kind` values was measured
to be internally mixed, so keying the frame off `kind` would reproduce the original bug
on the minority class.

A sense is a predicate iff its first word is a finite 3sg verb, tested against a curated
whitelist rather than by shape. Shape alone fails in both languages: German adjectival
past participles end in -t exactly as 3sg verbs do (`zugemacht`, `veraltet`, `geheilt`
are glosses, not predicates), and English `as`, `across`, `is` end in -s without being
verbs. The whitelist was built by enumerating every observed opening token and sorting
it by hand.

Some predicates open with an adverbial phrase — "as an inseparable prefix, conveys
surrounding or encircling something" — so the token after a leading comma is tested too.
"""

import argparse
import json
import pathlib
import re

FILES = ("verbdata/prefixes-inseparable.json", "verbdata/prefixes-separable.json")

# Finite 3sg verbs that open a predicate sense. Curated from the full observed set;
# see the module docstring for why -s/-t shape tests are not usable here.
EN_VERBS = {
    "adds", "brings", "carries", "conveys", "crosses", "denotes", "derives", "describes",
    "expresses", "forms", "gives", "hands", "hardens", "implies", "indicates", "intensifies",
    "intrudes", "is", "keeps", "leads", "lends", "makes", "marks", "means", "moves", "offers",
    "places", "points", "positions", "presents", "preserves", "promotes", "puts", "reduces",
    "refers", "reverses", "sets", "signals", "stacks", "stands", "survives", "takes", "turns",
}
DE_VERBS = {
    "bedeutet", "behält", "beschreibt", "bewahrt", "bewegt", "bezeichnet", "bietet", "bildet",
    "bindet", "deutet", "dringt", "drückt", "erzeugt", "führt", "gibt", "hält", "hebt",
    "impliziert", "ist", "kehrt", "kennzeichnet", "kreuzt", "legt", "macht", "markiert",
    "platziert", "richtet", "stapelt", "steht", "steuert", "trägt", "verleiht", "vermittelt",
    "verortet", "verstärkt", "versammelt", "verweist", "wird", "überlässt",
}

# Morpheme kinds that are bound prefixes/particles, written with a trailing hyphen.
# Nouns, adjectives, and verbs appear as bare first elements of a compound (altmachen,
# autofahren, steckenbleiben), so they take no hyphen.
HYPHENATED_KINDS = {"INSEPARABLE", "particle", "deictic", "adverb", "fossil"}


# Terminal punctuation, optionally followed by a closing quote. A sense may legitimately
# end on a quoted gloss — `… "there, to that point."` — and testing for a bare final "."
# reports those as unfinished, which is half of the 2026-07-21 corruption described above.
TERMINAL = re.compile(r'[.!?][\"“”»]?$')


def is_sentence(sense, lang):
    """True if the sense already stands as a complete sentence.

    Three things this must get right, each of which it got wrong before 2026-07-21:

    * A sense opening with its own morpheme token (`~dahin-~ marks …`) is a sentence.
      Testing `[:1].isupper()` says otherwise, because the first character is `~`.
    * A sense closing on a quoted gloss (`… "out."`) is finished. Testing
      `endswith(".")` says otherwise.
    * A capitalized *verb-initial* fragment (`Bezeichnet die Bewegung …`, `Means "on it" …`)
      is NOT a sentence, though it opens uppercase and closes on a period. German and
      English both allow this shape, and it is exactly the fragment class this script
      exists to repair, so accepting it silently is how 28 of them survived a run.
    """
    t = sense.strip()
    if not TERMINAL.search(t):
        return False
    if t.startswith("~"):
        return True
    first = re.split(r"[\s,:;—]+", t)[0].lower().rstrip(".")
    if first in (EN_VERBS if lang == "en" else DE_VERBS):
        return False
    return t[:1].isupper()


def terminate(text):
    """Append a period unless the text already ends in terminal punctuation.

    Unconditionally appending is what turned `… "out."` into `… "out.".` across twelve
    senses: the old code stripped a trailing "." (a no-op on a string ending in a quote)
    and then added one back.
    """
    text = text.rstrip()
    return text if TERMINAL.search(text) else f"{text}."


def decapitalize(text):
    """Lowercase a sentence-initial verb that is about to become mid-sentence.

    Only ever applied to the `plain`/`fronted` branches, where `is_predicate` has already
    matched the opening token against the finite-verb whitelist — so this cannot lowercase
    a German noun, which would be the obvious way for it to go wrong.
    """
    return text[:1].lower() + text[1:] if text else text


def is_predicate(sense, lang):
    """Classify a fragment. Returns "plain", "fronted", "self", or None (a gloss).

    "fronted" marks a predicate behind a leading adverbial ("as an inseparable prefix,
    conveys …"), which needs a comma after the inserted subject. "self" marks a sense
    that already opens with its own morpheme token and so needs no subject at all.
    """
    verbs = EN_VERBS if lang == "en" else DE_VERBS
    stripped = sense.strip()
    if stripped.startswith("~"):
        return "self"
    words = re.split(r"[\s,:;—]+", stripped)
    if words and words[0].lower().rstrip(".") in verbs:
        return "plain"
    # "as an inseparable prefix, conveys …" — test the token after a leading adverbial.
    head, _, tail = stripped.partition(",")
    if tail and len(head.split()) <= 6:
        first_after = re.split(r"[\s,:;—]+", tail.strip())
        if first_after and first_after[0].lower().rstrip(".") in verbs:
            return "fronted"
    return None


def frame(sense, lang, morpheme, kind):
    """Return the sense as a complete sentence, or unchanged if it already is one."""
    if is_sentence(sense, lang):
        return sense
    token = f"~{morpheme}-~" if kind in HYPHENATED_KINDS else f"~{morpheme}~"
    body = sense.strip()
    kind_of_predicate = is_predicate(sense, lang)
    if kind_of_predicate == "self":
        # Already opens with its own morpheme; it only lacks a terminal period.
        return terminate(body)
    if kind_of_predicate == "plain":
        # The fragment's opening verb was sentence-initial and so is capitalized; behind
        # an inserted subject it is mid-sentence. Leaving it produces "~rum-~ Trägt oft
        # …", which is the `~raus-~ Marks …` defect this script itself shipped in 2026-07.
        return terminate(f"{token} {decapitalize(body)}")
    if kind_of_predicate == "fronted":
        # "as an inseparable prefix, conveys …" needs the subject set off by a comma.
        return terminate(f"{token}, {decapitalize(body)}")
    # A gloss. Bodies that already carry a colon take the frame without a second one.
    joiner = "" if ":" in body else ":"
    if lang == "en":
        return terminate(f"The sense of {token} here is{joiner} {body}")
    return terminate(f"Die Bedeutung von {token} ist hier{joiner} {body}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    changed = kept = 0
    for path in FILES:
        p = pathlib.Path(path)
        data = json.loads(p.read_text())
        # The inseparable file carries no `kind`; its entries are all bound prefixes.
        default_kind = "INSEPARABLE" if "inseparable" in path else "particle"
        for lang in ("de", "en"):
            for morpheme, entry in data[lang].items():
                senses = entry.get("senses")
                if not senses:
                    continue
                kind = entry.get("kind", default_kind)
                out = []
                for sense in senses:
                    framed = frame(sense, lang, morpheme, kind)
                    # A second pass must be a no-op. Re-framing an already-framed sense is
                    # what produced "The sense of ~her-~ here is The sense of ~her-~ here is:"
                    # on 2026-07-21, so the property is asserted rather than trusted.
                    assert frame(framed, lang, morpheme, kind) == framed, (
                        f"not idempotent on {lang}/{morpheme}: {sense!r} -> {framed!r}"
                    )
                    changed += framed != sense
                    kept += framed == sense
                    out.append(framed)
                entry["senses"] = out
        if not args.dry_run:
            p.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")

    print(f"{'would rewrite' if args.dry_run else 'rewrote'} {changed} senses; left {kept} unchanged")


if __name__ == "__main__":
    main()
