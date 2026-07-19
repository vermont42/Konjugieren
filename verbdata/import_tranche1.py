#!/usr/bin/env python3
"""Import tranche 1: the missing strong bases from de.wikipedia's Liste starker Verben.

Step 7 of docs/roadmap.md. Consumes nothing at runtime but the two shipping XML files;
the decision table below is the artifact, hand-built from three inputs that a future
session cannot recover by reading code:

  1. de.wikipedia "Liste starker Verben (deutsche Sprache)", set-differenced against
     Konjugieren/Models/Verbs.xml. That yielded 82 missing bases, not the 87 the prose
     in docs/verb-sources.md claims -- the prose was stale, exactly as roadmap.md warned.
  2. verbdata/classification.json, the classify-and-verify pipeline's proposal for each
     one: family, ablaut group, auxiliary, and a marked infinitive whose Conjugator
     output reproduces Wiktionary's table exactly.
  3. Editorial judgment, for the four things the pipeline cannot decide -- `hi`, `ic`,
     the auxiliary, and which paradigm a dual-paradigm verb should ship with.

Run:  python3 verbdata/import_tranche1.py [--check]

--check reports what would change and writes nothing.

WHY THE ABLAUT REGIONS DIFFER FROM THE CLASSIFIER'S PROPOSAL
------------------------------------------------------------
The classifier minimizes for the *shortest* region, so it proposes `kn^ei^fen` with the
replacement `IF`, splitting the doubled f across the region boundary ("kn" + "IF" + "f").
That verifies, but it is not how this corpus is written: the shipping `greifen` is
`gr^eif^en` with `IFF`, keeping the whole consonant change inside the region. Rewriting
each proposal to the house convention collapsed thirteen proposed new groups into six,
because the reworded region matches a group that already ships:

    kneifen, pfeifen, schleifen   -> greifen    (IFF,bA,dA,pp)
    gleiten, schreiten            -> schneiden  (ITT,bA,dA,pp)
    schleichen                    -> streichen  (ICH,bA,dA,pp)
    schwoeren, gaeren, weben,     -> heben      (O,bA,pp|OE,dA)
      glimmen, klimmen, scheren,
      waegen, saugen, luegen,
      truegen, krauchen

This is the same lesson adding-verbs.md records for the sibilant: the ablaut region has
to be wide enough to spell every consonant that travels with the vowel.

WHY SOME LIST MEMBERS SHIP WEAK
-------------------------------
kaikki's forms[] carries *both* paradigms for a dual-paradigm verb, and the classifier's
`accepted` set admits any listed alternative -- so either paradigm verifies, and the
choice is editorial rather than mechanical. The rule applied here: ship strong only where
the strong paradigm is current standard German. Verbs whose strong forms Duden marks
veraltet or veraltend (bellen/gebollen, schnauben/geschnoben, triefen/getroffen,
bleichen/geblichen) ship weak, because an ablaut-teaching app that presents an obsolete
paradigm as live is teaching the wrong thing. Verbs whose strong forms are current
(melken/gemolken, flechten/geflochten, weben/gewoben, sieden/gesotten, gaeren/gegoren,
glimmen/geglommen, dingen/gedungen) ship strong.

WHAT IS DEFERRED, AND WHY
-------------------------
  mahlen, spalten -- wrinkle 4 in verb-sources.md: weak Praeteritum with strong participle.
    kaikki lists ONLY the strong participle for these two, so neither family expresses them
    and neither verifies. Unchanged by this tranche.
  salzen -- the same shape, but kaikki also lists the weak `gesalzt`, so it verifies weak
    and ships weak here.
  speien -- verifies only via `I,b1p,b3p,dA,pp|IE,b1s,b2p,b2s,b3s`, which splits the
    Praeteritum by person. That is the signature docs/verb-classification.md names as a
    Conjugator gap smuggled into an ablaut group, and its sequencing argument says
    explicitly not to import such a group. The real defect: a strong verb whose stem ends
    in a vowel takes -n, not -en, in the 1p/3p (spien, schrien), the same rule
    `hasSyllabicStamm` already implements for -ern/-eln. Shipping `schreien` carries the
    identical workaround and is one of the three known-wrong groups. Fix Conjugator, then
    both become a clean `IE,bA,dA,pp` and speien can land.
  Prefixed derivatives of these new bases -- step 8's population. Re-running
    build_candidates.py after this import brings them into scope there automatically.

PROVISIONAL HIT COUNTS
----------------------
Every verb here carries hp="y". DWDS bulk querying is blocked pending BBAW (see
docs/dwds-permission-email.md), and Josh decided on 2026-07-19 to import with editorial
estimates rather than wait. Each `hi` below was placed between the real counts of shipping
verbs judged comparable -- the anchors are named in the `near` field -- rather than at a
round number, which would land the verb wherever that happened to fall.

Deliberately NOT used as input: the real DWDS counts quoted in docs/verb-sources.md for
about twenty of these verbs. Those are in the repo under the citation allowance, and the
same reasoning the repo applies to Leipzig applies to them -- an estimate informed by a
measurement is still derived from it. When permission arrives, re-query all of these with
probes, replace `hi`, and drop `hp`.
"""

import argparse
import pathlib
import re
import sys
import xml.etree.ElementTree as ET

REPO = pathlib.Path(__file__).resolve().parent.parent
VERBS_XML = REPO / "Konjugieren" / "Models" / "Verbs.xml"
ABLAUT_XML = REPO / "Konjugieren" / "Models" / "AblautGroups.xml"

# Ablaut groups this tranche adds. Each was verified by the pipeline in the classifier's
# own region-minimal form, then rewritten to the house convention (region wide enough to
# carry the consonant change) and re-verified by re-running the pipeline after import.
NEW_ABLAUT_GROUPS = [
    # bersten really is defective in the Praesens: "du birst" and "er birst" are the same
    # word built two different ways, so 2s and 3s need separate replacements -- the stem
    # supplies "bir" plus the -st ending in one and "birs" plus the -t ending in the other.
    # This is a genuine irregularity, not an epenthetic-e workaround smuggled into a group.
    ("bersten", "IR,a2s|IRS,a3s|ARST,bA|ÄRST,dA|IRST,i2s|ORST,pp"),
    ("saufen", "ÄUF,a2s,a3s|OFF,bA,pp|ÖFF,dA"),
    # Exemplar chosen as the most recognizable member; dreschen, fechten, flechten,
    # melken, and schwellen ride the same pattern.
    ("schmelzen", "I,a2s,a3s|O,bA,pp|Ö,dA"),
    ("schinden", "U,bA,pp|Ü,dA"),
    # sieden's ablaut carries the d -> tt with it: sott, gesotten, soette.
    ("sieden", "OTT,bA,pp|ÖTT,dA"),
]

# in, tn, fa, ag, ay, ic, hi, anchor-note
# `ay` is None for haben (the default, encoded as an absent attribute).
TRANCHE = [
    # --- Ablautklasse 1: ei - i(e) - i(e) ---
    ("ge*d^ei^hen", "thrive, prosper", "s", "bleiben", "s", "yoga", 361_400, "near erbauen/filmen"),
    ("l^ei^hen", "lend, borrow", "s", "bleiben", None, "arms.open", 468_900, "near gießen/beten"),
    ("m^ei^den", "avoid, shun", "s", "bleiben", None, "walk.motion", 402_700, "near überarbeiten"),
    ("pr^ei^sen", "praise, laud", "s", "bleiben", None, "arms.open", 341_300, "below filmen"),
    ("r^ei^ben", "rub, grate", "s", "bleiben", None, "strengthtraining.traditional", 412_100, "near überarbeiten"),
    ("reihen", "line up, arrange in a row", "w", None, None, "stand", 201_600, "near hochladen"),
    ("speisen", "dine", "w", None, None, "seated.side.left", 232_800, "near hochladen/tätigen"),
    ("z^ei^hen", "accuse, impute", "s", "bleiben", None, "handball", 41_900, "far tail, archaic"),
    ("b^eiß^en", "bite", "s", "reißen", None, "hunting", 471_300, "near gießen"),
    ("bleichen", "bleach, fade", "w", None, None, "cooldown", 191_400, "near währen"),
    ("gl^eit^en", "glide, slide", "s", "schneiden", "s", "skating", 332_600, "near filmen"),
    ("keifen", "nag, scold shrilly", "w", None, None, "wave", 26_300, "far tail"),
    ("kn^eif^en", "pinch", "s", "greifen", None, "boxing", 252_400, "near tätigen"),
    ("kneipen", "pinch (dialectal)", "w", None, None, "boxing", 8_700, "far tail, dialectal"),
    ("kreißen", "be in labor", "w", None, None, "mind.and.body", 9_400, "far tail"),
    ("pf^eif^en", "whistle", "s", "greifen", None, "wave", 403_900, "near überarbeiten"),
    ("sch^eiß^en", "shit", "s", "reißen", None, "cooldown", 121_500, "near besingen"),
    ("schl^eich^en", "creep, sneak", "s", "streichen", "s", "walk.motion", 352_600, "near filmen"),
    ("schl^eif^en", "grind, sharpen", "s", "greifen", None, "strengthtraining.traditional", 291_200, "near tätigen"),
    ("schl^eiß^en", "strip, wear away", "s", "reißen", None, "cooldown", 7_300, "far tail"),
    ("schm^eiß^en", "throw, chuck", "s", "reißen", None, "handball", 381_700, "near erbauen"),
    ("schr^eit^en", "stride, proceed", "s", "schneiden", "s", "walk", 322_800, "near filmen"),
    ("spleißen", "splice, split", "w", None, None, "cooldown", 12_600, "far tail"),
    # --- Ablautklasse 2: eu/ie - o - o ---
    ("fr^ie^ren", "freeze, be cold", "s", "bieten", None, "skiing.downhill", 431_600, "near trocknen"),
    ("klieben", "cleave (regional)", "w", None, None, "strengthtraining.traditional", 5_100, "far tail"),
    ("l^ü^gen", "lie, tell an untruth", "s", "heben", None, "play", 442_500, "near rauchen"),
    ("st^ie^ben", "fly about, scatter", "s", "bieten", None, "run", 15_800, "far tail"),
    ("tr^ü^gen", "deceive, be deceptive", "s", "heben", None, "play", 96_100, "below besingen"),
    ("ver*dr^ieß^en", "vex, annoy", "s", "schließen", None, "fall", 31_700, "far tail"),
    ("kr^ie^chen", "crawl, creep", "s", "bieten", "s", "climbing", 372_400, "near erbauen"),
    ("kr^au^chen", "crawl (regional)", "s", "heben", "s", "climbing", 3_600, "far tail, dialectal"),
    ("s^auf^en", "booze, drink (of animals)", "s", "saufen", None, "cooldown", 302_100, "near tätigen"),
    ("s^au^gen", "suck", "s", "heben", None, "cooldown", 351_800, "near filmen"),
    ("schnauben", "snort", "w", None, None, "highintensity.intervaltraining", 91_300, "below besingen"),
    ("s^ied^en", "boil, seethe", "s", "sieden", None, "highintensity.intervaltraining", 21_400, "far tail"),
    ("spr^ieß^en", "sprout", "s", "schließen", "s", "yoga", 61_200, "far tail"),
    ("triefen", "drip heavily", "w", None, None, "cooldown", 71_800, "far tail"),
    # --- Ablautklasse 3: i - a/o/u - o/u ---
    ("br^i^nnen", "burn, be aflame", "s", "beginnen", None, "fall", 2_400, "far tail, archaic"),
    ("d^i^ngen", "hire, engage", "s", "finden", None, "2", 6_800, "far tail"),
    ("r^i^ngen", "wrestle, struggle", "s", "finden", None, "wrestling", 452_900, "near hassen"),
    ("sch^i^nden", "mistreat, flay", "s", "schinden", None, "wrestling", 56_400, "far tail"),
    ("schl^i^ngen", "wind, wrap; gulp", "s", "finden", None, "roll", 111_700, "near besingen"),
    ("schw^i^nden", "dwindle, fade", "s", "finden", "s", "cooldown", 281_900, "near tätigen"),
    ("schw^i^ngen", "swing, vibrate", "s", "finden", None, "jumprope", 404_600, "near überarbeiten"),
    ("st^i^nken", "stink", "s", "finden", None, "cooldown", 292_500, "near tätigen"),
    ("w^i^nden", "wind, twist", "s", "finden", None, "roll", 131_800, "near besingen"),
    ("winken", "wave, beckon", "w", None, None, "wave", 421_400, "near trocknen"),
    ("wr^i^ngen", "wring", "s", "finden", None, "strengthtraining.traditional", 6_200, "far tail"),
    ("bellen", "bark", "w", None, None, "wave", 342_900, "below filmen"),
    ("b^erst^en", "burst", "s", "bersten", "s", "fall", 101_600, "near besingen"),
    ("ver*d^e^rben", "spoil, ruin", "s", "sterben", None, "fall", 311_500, "near tätigen"),
    ("dr^e^schen", "thresh, thrash", "s", "schmelzen", None, "strengthtraining.traditional", 92_700, "below besingen"),
    ("f^e^chten", "fence, fight", "s", "schmelzen", None, "fencing", 181_300, "near währen"),
    ("fl^e^chten", "braid, plait, weave", "s", "schmelzen", None, "barre", 151_900, "near währen"),
    ("gl^i^mmen", "glow, smoulder", "s", "heben", None, "flexibility", 46_700, "far tail"),
    ("kl^i^mmen", "clamber, climb", "s", "heben", "s", "climbing", 4_300, "far tail"),
    ("m^e^lken", "milk", "s", "schmelzen", None, "2", 51_500, "far tail"),
    ("r^i^nnen", "flow, trickle", "s", "beginnen", "s", "pool.swim", 76_400, "far tail"),
    ("schallen", "resound, ring out", "w", None, None, "wave", 106_800, "near besingen"),
    ("zer*schellen", "be dashed to pieces", "w", None, "s", "fall", 36_200, "far tail"),
    ("sch^e^lten", "scold, chide", "s", "sprechen", None, "wave", 66_500, "far tail"),
    ("schm^e^lzen", "melt", "s", "schmelzen", None, "skiing.downhill", 422_600, "near trocknen"),
    ("schw^e^llen", "swell", "s", "schmelzen", "s", "highintensity.intervaltraining", 231_700, "near hochladen"),
    ("s^i^nnen", "ponder, muse", "s", "beginnen", None, "mind.and.body", 86_900, "below besingen"),
    ("sp^i^nnen", "spin; be crazy", "s", "beginnen", None, "barre", 192_800, "near währen"),
    # --- Ablautklasse 4: ie/oe - a/o - o ---
    ("be*f^e^hlen", "command, order", "s", "empfehlen", None, "stand", 405_300, "near überarbeiten"),
    ("g^ä^ren", "ferment", "s", "heben", None, "flexibility", 81_200, "below besingen"),
    ("ver*hehlen", "conceal", "w", None, None, "walk.motion", 11_400, "far tail"),
    ("sch^e^ren", "shear, clip", "s", "heben", None, "barre", 116_300, "near besingen"),
    ("schwären", "fester, suppurate", "w", None, None, "fall", 2_900, "far tail"),
    ("w^ä^gen", "weigh, ponder", "s", "heben", None, "flexibility", 26_800, "far tail"),
    ("w^e^ben", "weave", "s", "heben", None, "barre", 202_400, "near hochladen"),
    # --- Ablautklasse 5: ie - a - e ---
    ("ge*n^e^sen", "recover, convalesce", "s", "kommen", "s", "walk.arrival", 161_500, "near währen"),
    ("gr^a^ben", "dig", "s", "fahren", None, "strengthtraining.traditional", 472_800, "near gießen"),
    # --- Ablautklasse 6: ae/e/oe - u/a/o - a/o ---
    ("schw^ö^ren", "swear, vow", "s", "heben", None, "stand", 423_500, "near trocknen"),
    # --- Ablautklasse 7: former reduplicating verbs ---
    ("salzen", "salt, season", "w", None, None, "seated.side.left", 72_600, "far tail"),
    ("bl^a^sen", "blow", "s", "halten", None, "wave", 391_800, "near erbauen"),
    ("br^a^ten", "roast, pan-fry", "s", "halten", None, "cooldown", 373_200, "near erbauen"),
]


def bare(marked: str) -> str:
    """The dictionary key: the infinitive with every +, *, and ^ marker stripped."""
    return re.sub(r"[+*^]", "", marked)


def sort_key(marked: str) -> str:
    """Verbs.xml's alphabetical order: markers ignored, umlauts folded to base vowels.

    Documented in adding-verbs.md. Folding matters: `waegen` must sort between `wachsen`
    and `wagen`, not after `wynden`.

    Sharp s is deliberately NOT folded to ss, though adding-verbs.md's phrasing invites
    it. Measured against the shipping file, folding produces three order violations and
    leaving it produces none: U+00DF sorts after every ASCII letter, which is why the file
    reads `reiten` then `reissen` and `weiterlesen` then `weissen`. Match the corpus.
    """
    folded = bare(marked).lower()
    for umlaut, base in (("ä", "a"), ("ö", "o"), ("ü", "u")):
        folded = folded.replace(umlaut, base)
    return folded


def verb_element(entry) -> str:
    marked, translation, family, group, auxiliary, icon, hits, _ = entry
    reading = f'<reading tn="{translation}" fa="{family}"'
    if group:
        reading += f' ag="{group}"'
    if auxiliary:
        reading += f' ay="{auxiliary}"'
    reading += " />"
    return (
        f'  <verb in="{marked}" hi="{hits}" hp="y" ic="{icon}">\n'
        f"    {reading}\n"
        f"  </verb>\n"
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="report, write nothing")
    args = parser.parse_args()

    verbs_text = VERBS_XML.read_text()
    shipping = {bare(v.get("in")): int(v.get("hi")) for v in ET.fromstring(verbs_text)}

    # Guard the three invariants that make the insertion safe. Each one has bitten this
    # repo before: a duplicate key silently shadows a shipping verb in Verb.verbs, a
    # duplicate hit count makes the derived rank non-deterministic, and an unsorted file
    # is the kind of drift nothing in the build catches.
    problems = []
    seen_hits = set(shipping.values())
    seen_words = set()
    for entry in TRANCHE:
        word, hits = bare(entry[0]), entry[6]
        if word in shipping:
            problems.append(f"{word}: already ships")
        if word in seen_words:
            problems.append(f"{word}: duplicated within the tranche")
        if hits in seen_hits:
            problems.append(f"{word}: hit count {hits} collides, so the rank would tie")
        seen_words.add(word)
        seen_hits.add(hits)
    if problems:
        print("\n".join(problems), file=sys.stderr)
        return 1

    # Non-decreasing, not strictly sorted: folding umlauts makes `druecken`/`drucken` and
    # `zaehlen`/`zahlen` tie, and the file breaks those ties the opposite way from a naive
    # sort. Requiring a total order here would reject a correctly ordered file.
    keys = [sort_key(v.get("in")) for v in ET.fromstring(verbs_text)]
    if any(earlier > later for earlier, later in zip(keys, keys[1:])):
        print("Verbs.xml is not sorted under sort_key; refusing to insert", file=sys.stderr)
        return 1

    print(f"{len(TRANCHE)} verbs to insert; {len(NEW_ABLAUT_GROUPS)} new ablaut groups")
    families = {}
    for entry in TRANCHE:
        families[entry[2]] = families.get(entry[2], 0) + 1
    print(f"  by family: {families}")
    if args.check:
        return 0

    # Insert each verb before the first shipping verb that sorts after it. Splicing text
    # rather than re-serializing the tree is deliberate: ElementTree would rewrite
    # attribute order and entity escaping across all 990 incumbents, burying 78 real
    # additions in a whole-file diff.
    lines = verbs_text.splitlines(keepends=True)
    verb_starts = [(i, sort_key(m.group(1)))
                   for i, line in enumerate(lines)
                   if (m := re.match(r'\s*<verb in="([^"]+)"', line))]
    closing = next(i for i, line in enumerate(lines) if line.strip() == "</verbs>")

    insertions = []
    for entry in TRANCHE:
        key = sort_key(entry[0])
        at = next((i for i, k in verb_starts if k > key), closing)
        insertions.append((at, verb_element(entry)))
    for at, text in sorted(insertions, key=lambda pair: -pair[0]):
        lines.insert(at, text)
    VERBS_XML.write_text("".join(lines))

    ablaut_text = ABLAUT_XML.read_text()
    ablaut_lines = ablaut_text.splitlines(keepends=True)
    ag_starts = [(i, m.group(1))
                 for i, line in enumerate(ablaut_lines)
                 if (m := re.match(r'\s*<ag e="([^"]+)"', line))]
    ag_closing = next(i for i, line in enumerate(ablaut_lines) if line.strip() == "</ablautGroups>")
    ag_insertions = []
    for exemplar, pattern in NEW_ABLAUT_GROUPS:
        key = sort_key(exemplar)
        at = next((i for i, name in ag_starts if sort_key(name) > key), ag_closing)
        ag_insertions.append((at, f'  <ag e="{exemplar}" a="{pattern}" />\n'))
    for at, text in sorted(ag_insertions, key=lambda pair: -pair[0]):
        ablaut_lines.insert(at, text)
    ABLAUT_XML.write_text("".join(ablaut_lines))

    print(f"wrote {VERBS_XML.relative_to(REPO)} and {ABLAUT_XML.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
