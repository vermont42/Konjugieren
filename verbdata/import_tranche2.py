#!/usr/bin/env python3
"""Import tranche 2: prefixed derivatives of verbs Konjugieren already conjugates.

Step 8 of docs/roadmap.md. Consumes verbdata/classification.json (the classify-and-verify
pipeline's output) plus verbdata/candidates.json (for the untruncated kaikki glosses), and
writes into Konjugieren/Models/Verbs.xml.

Run:  python3 verbdata/import_tranche2.py [--check] [--sample N]

--check reports what would change and writes nothing. --sample prints N normalized rows so
the translations can be eyeballed before 2,000-odd user-visible strings ship.

WHY THIS TRANCHE IS DIFFERENT FROM TRANCHE 1
--------------------------------------------
Step 7 imported 78 verbs and made four editorial decisions per verb by hand. This tranche is
thirty times larger, which breaks two of those doctrines outright -- nobody can place 2,500
hit counts "between the real counts of comparable shipping verbs" and mean it, and nobody
can choose 2,500 SF Symbol icons by taste. Both are therefore decided by rule here, and the
rules are stated so a reader can disagree with them:

  `hi`  Derived from the base verb's count, scaled by a ratio MEASURED from the corpus's own
        real DWDS counts (see RATIOS below). Still marked hp="y".
  `ic`  Inherited from the base verb. A derivative of `beissen` gets `beissen`'s icon.
  `tn`  Normalized from kaikki's gloss (see `normalize_translation`), not hand-written.
  `ay`  kaikki's primary reading, per the interim policy in prompts/dual_auxiliary.md.

Everything else -- family, ablaut group, ablaut region, prefix marking -- comes from the
pipeline, which verified each one against Wiktionary's full conjugation table.

THE `hi` RATIOS ARE MEASURED, NOT CHOSEN
----------------------------------------
The corpus ships 990 verbs with real DWDS counts, and 448 of them are prefixed derivatives
whose base also ships with a real count. That is a calibration set: it says what fraction of
its base's frequency a real German derivative actually has. The median is 0.174 overall, but
it varies by prefix in a way that is linguistically legible -- the inseparable prefixes that
form lexicalized everyday verbs run high (be- 0.372, er- 0.406, ver- 0.307) and the
directional particles that form specific ones run low (weiter- 0.042, ueber- 0.047,
vor- 0.061). So the ratio is per-prefix wherever the calibration set has at least five pairs,
and the global median otherwise.

This is still an estimate and still wrong in individual cases -- 52 of the 448 real
derivatives are MORE common than their base (*bekommen* beats *kommen*), which no ratio
captures. What it is not is invented: it is the corpus's own measured behaviour applied to
verbs whose counts we are not allowed to query yet.

Bases that are themselves provisional (tranche 1's 78) are excluded from the calibration,
though a derivative may still be built on one -- an estimate on an estimate, which is worth
knowing when the real counts land.

THE RATIO SETS THE ORDER; A SECOND FACT SETS THE RANGE
------------------------------------------------------
Used raw, the ratio puts 796 of these 2,300 verbs inside the top 500 of the measured corpus,
and puts the archaic *gehaben* fourth overall -- above *gehen*. That is not a tuning problem.
The ratio is a median over derivatives that are attested and lexicalized enough to have made
a top-990 frequency list, so applying it to obscure derivatives inflates every one of them.
A derivative's frequency is simply not a function of its base's.

But there is a second measured fact available, and it points the other way: **every verb in
this tranche was absent from the frequency-ordered list that produced the original 990.**
That list was built from real frequency data, so absence from it is evidence -- not proof,
since it demonstrably had holes (it took *vermeiden* and left *meiden*), but evidence that
these verbs sit below the measured corpus rather than scattered through its top half.

So the two facts are used for the two different things each actually supports:

  the ratio  ->  the ORDER of the tranche within itself. *zurueckgeben* above *nachdrucken*
                 is real information, and it comes from measured German.
  the absence ->  the RANGE the whole tranche occupies: below the 900th real verb.

So each estimate is the ratio applied to the base, then clamped to the ceiling. Clamping and
not rescaling: mapping the whole tranche evenly across the band was tried and throws away the
magnitude the ratio actually measured, which sent *vermieten* to the rare tail. Clamping
leaves every plausible estimate untouched and compresses only the third that the ratio
inflated past the ceiling, which then sit just under it in ratio order.

What the resulting number claims is exactly this much: "no more common than the 900th measured
verb, and roughly this common relative to the rest of the tranche." It does not claim to be a
hit count, which is what `hp="y"` says out loud.

WHAT IS EXCLUDED, AND WHY
-------------------------
A verb can verify perfectly and still not belong in the app. Four filters run before import:

  * kaikki's gloss is metadata, not a translation -- "clipping of herumfahren", "alternative
    form of ausbauen", "obsolete spelling of ...". These are pointers to another entry; the
    entry they point at is usually already in the tranche.
  * pre-1996 or archaic orthography -- the `bey-` spellings (beybringen), the `auss-` ones
    (aussbauen). docs/adding-verbs.md's note about which side of the 1996 reform a spelling
    comes from applies here.
  * Swiss ss-spellings whose sharp-s twin exists. Same verb, not a second one; Swiss
    rendering is a display transform, never stored. See adding-verbs.md.
  * A verb needing an ablaut group that does not ship. Tranche 1 added groups deliberately,
    five of them, each checked by hand. Adding 182 mechanically is how workarounds become
    permanent data -- the exact failure docs/verb-classification.md's sequencing argument
    warns about. These are deferred to a pass that can look at them.

DUAL AUXILIARIES
----------------
197 of these verbs take sein in one reading and haben in another. The <reading> model landed
in step 5 and could express both, but choosing which sense pairs with which auxiliary is a
per-verb judgment and this tranche does not make 197 of them. Each ships with kaikki's
primary auxiliary and a single reading, per the interim policy in prompts/dual_auxiliary.md,
and --check writes the worklist to verbdata/tranche2-dual-auxiliary.txt so the pass that
handles them inherits it rather than rediscovering it.
"""

import argparse
import collections
import json
import pathlib
import re
import statistics
import sys
import xml.etree.ElementTree as ET

REPO = pathlib.Path(__file__).resolve().parent.parent
VERBS_XML = REPO / "Konjugieren" / "Models" / "Verbs.xml"
CLASSIFICATION = REPO / "verbdata" / "classification.json"
CANDIDATES = REPO / "verbdata" / "candidates.json"
DUAL_WORKLIST = REPO / "verbdata" / "tranche2-dual-auxiliary.txt"
DEFERRED_WORKLIST = REPO / "verbdata" / "tranche2-deferred.txt"

GLOBAL_RATIO = 0.174
MIN_PAIRS_FOR_PER_PREFIX_RATIO = 5

# The ceiling the estimates are clamped to: the count of the 900th real verb, so no guessed
# derivative claims to outrank all but a hundred measured ones.
CEILING_REAL_RANK = 900

# A gloss of this shape points at another entry instead of translating the verb.
# Matching `form of` and `spelling of` outright, rather than enumerating the qualifiers that
# precede them, because the enumeration kept losing: "archaic or dialectal form of kneifen"
# names two qualifiers where the list anticipated one, and shipped as a translation reading
# "archaic or dialectal form of kneifen". Whatever adjective kaikki reaches for, a gloss saying
# the entry is a *form of* something else is pointing, not translating.
METADATA_GLOSS = re.compile(
    r"\b(form|spelling|clipping|misspelling|abbreviation|synonym|eye dialect) of\b",
    re.IGNORECASE,
)

# Pre-1996 and archaic orthography. `bey-` for `bei-`, `auss-`/`aussen-` for `aus-`.
ARCHAIC_SPELLING = re.compile(r"^(bey|auß|thu|thei)", re.IGNORECASE)

# The other kind of 1996 casualty, which no spelling of the word betrays: a compound the reform
# split into two words. radfahren became Rad fahren, spazierengehen became spazieren gehen. The
# app conjugates single words, so the post-reform spelling is not a verb it can hold, and the
# pre-reform one should no more ship than beybringen. kaikki says so in the gloss outright,
# which is the only place the evidence lives -- ARCHAIC_SPELLING reads the lemma and sees
# nothing wrong with radfahren.
REFORM_CASUALTY = re.compile(
    r"formerly standard spelling of|deprecated in the spelling reform", re.IGNORECASE
)

TRANSLATION_MAX = 42

# Verbs kaikki defines only by describing them. "to break something by saving too much money on
# maintenance" is a correct account of kaputtsparen and useless as a `tn`: there is no short
# English equivalent to extract, because English has no such verb. No normalizing rule can
# invent one, so these fifteen are written by hand -- the one place in this importer where a
# translation is authored rather than derived, which is why they are listed here in the open
# rather than buried in a data file. Step 8 deferred all fifteen; each was checked against the
# full kaikki entry, and several are idioms whose English is nothing like the German
# (hochschlafen is exactly "sleep one's way up").
HAND_TRANSLATIONS = {
    "abtippen": "type up, transcribe",
    "abtrinken": "drink down a little",
    "anfüttern": "bait, win over with gifts",
    "anheimgeben": "leave to someone's discretion",
    "durchfragen": "ask one's way through",
    "festfragen": "corner with questions",
    "freitesten": "test out of restrictions",
    "hochschlafen": "sleep one's way up",
    "kaputtsparen": "ruin by cost-cutting",
    "krankfeiern": "skip work feigning illness",
    "leerrauchen": "smoke the whole supply",
    "nachleisten": "perform belatedly",
    "reinfeiern": "celebrate into the day",
    "vorleisten": "perform in advance",
    "übereignen": "transfer ownership",
}


def bare(marked: str) -> str:
    return re.sub(r"[+*^]", "", marked)


def sort_key(marked: str) -> str:
    """Verbs.xml's order: markers ignored, umlauts folded, sharp s left alone.

    Identical to import_tranche1.py's; see its docstring for why ss is not folded and why
    the invariant is non-decreasing rather than strictly sorted.
    """
    folded = bare(marked).lower()
    for umlaut, base in (("ä", "a"), ("ö", "o"), ("ü", "u")):
        folded = folded.replace(umlaut, base)
    return folded


def head_of(marked: str) -> str:
    """The outermost prefix of a marked infinitive: `an` for `an+ge*hoeren`."""
    match = re.match(r"^([a-zäöüß]+)[+*]", marked.replace("^", ""))
    return match.group(1) if match else ""


def base_of(marked: str) -> str:
    """The innermost stem, past every prefix marker: `hoeren` for `an+ge*hoeren`."""
    return re.sub(r"\^", "", marked).split("+")[-1].split("*")[-1]


def normalize_translation(glosses: list[str]) -> str | None:
    """Turn a kaikki gloss into something that reads like the corpus's own `tn` values.

    Tries each gloss in order and returns the first that yields something usable, skipping
    the ones that point at another entry instead of translating.

    Step 8 read only `glosses[0]` and deferred the verb when that one gloss produced nothing.
    That discarded 71 verbs whose *later* glosses translate them perfectly well, because
    kaikki's first gloss is often not a definition at all. Three shapes account for nearly
    all of them: a bare grammatical header ("[auxiliary haben]", "[with gegen (+ accusative)
    ...]:"), which reduces to the empty string; a long descriptive definition that overruns
    TRANSLATION_MAX ("to transcribe from one source by the help of keys into another medium")
    while a later sense is short and idiomatic; and a pointer ("clipping of heranhalten")
    followed by the actual translation. Falling through costs nothing -- a gloss that
    normalizes to a good short translation is a good short translation whatever its index --
    and it is what the roadmap meant by "recoverable by hand from kaikki's later glosses".

    Returns None only when *no* gloss yields anything, which the caller treats as an
    exclusion rather than shipping an empty string.

    The one rule worth stating: this never truncates mid-token. The classifier's own
    `shortened` cuts at 60 characters and produced "...rumours, et", which is precisely the
    kind of thing that reaches a user and looks like corruption.
    """
    for gloss in glosses:
        if METADATA_GLOSS.search(gloss):
            continue
        translation = normalize_one_gloss(gloss)
        if translation:
            return translation
    return None


def step8_normalize_translation(glosses: list[str]) -> str | None:
    """Reproduce step 8's translation rule exactly. Used as a fingerprint, never to write.

    `--retranslate` has to rewrite the translations this importer generated without touching the
    ones step 7 wrote by hand, and nothing in Verbs.xml distinguishes them: both tranches carry
    hp="y", which marks a provisional *count*, not a generated translation. Filtering on that
    alone proposed replacing tranche 1's careful "lend, borrow" for leihen with a bare "borrow",
    and "spoil, ruin" for verderben with the flatly wrong "deprive of, rob of".

    So the test is not which tranche a verb came from but whether the old rule reproduces what it
    ships: if it does, the value is machine-generated and this importer owns it; if it does not,
    a human wrote it and it stays. That needs no marker in the data and cannot drift out of date,
    because it asks the question directly.
    """
    if not glosses:
        return None
    text = glosses[0]
    text = re.sub(r"^\s*\([^)]*\)\s*", "", text)
    text = re.sub(r"\([^)]*\)", " ", text)
    text = re.sub(r"\[[^\]]*\]", " ", text)
    text = text.split(";")[0]
    text = re.sub(r"\s+", " ", text).strip(" ,.;:")

    senses = []
    for sense in text.split(","):
        sense = re.sub(r"^to\s+", "", sense.strip()).strip(" ,.;:")
        if sense and sense not in senses:
            senses.append(sense)
    if not senses or len(senses[0]) > TRANSLATION_MAX:
        return None
    result = senses[0]
    for sense in senses[1:]:
        if len(result) + 2 + len(sense) > TRANSLATION_MAX:
            break
        result += ", " + sense
    return result.lower()


def normalize_one_gloss(text: str) -> str | None:
    """Reduce a single kaikki gloss to a `tn` value, or None if nothing usable survives."""
    # Leading label groups: "(semelfactive, intransitive) to breathe again".
    text = re.sub(r"^\s*\([^)]*\)\s*", "", text)
    # Any remaining parenthetical or bracketed aside.
    text = re.sub(r"\([^)]*\)", " ", text)
    text = re.sub(r"\[[^\]]*\]", " ", text)
    # A semicolon inside one kaikki gloss separates near-synonyms, not distinct senses -- those
    # get their own gloss in the list. Step 8 assumed the opposite and kept only the text before
    # the first semicolon, which threw away the better half of the definition and, worse, kept
    # whichever synonym kaikki happened to list first: aufbleiben ("to wake; to stay awake; to
    # stay up") shipped as "wake", which is not what aufbleiben means. Treating the semicolon
    # like the comma feeds every synonym to the fits-in-TRANSLATION_MAX loop below, so the
    # translation reads "wake, stay awake, stay up" and the sense survives even when the first
    # word alone would have misled.
    text = re.sub(r"\s+", " ", text).strip(" ,.;:")

    senses = []
    for sense in re.split(r"[;,]", text):
        sense = sense.strip()
        sense = re.sub(r"^to\s+", "", sense)
        sense = sense.strip(" ,.;:")
        if sense and sense not in senses:
            senses.append(sense)
    if not senses:
        return None

    # Add senses while they fit. Never cut a sense in half.
    result = senses[0]
    if len(result) > TRANSLATION_MAX:
        return None
    for sense in senses[1:]:
        if len(result) + 2 + len(sense) > TRANSLATION_MAX:
            break
        result += ", " + sense
    return result.lower()


def measure_ratios(verbs_root) -> dict[str, float]:
    """Measure the derivative-to-base hit ratio from the corpus's own real counts.

    Provisional counts are excluded from both sides: calibrating on estimates would make the
    rule a function of earlier guesses rather than of measured German.
    """
    hits, provisional, marked = {}, set(), {}
    for verb in verbs_root:
        word = bare(verb.get("in"))
        hits[word] = int(verb.get("hi"))
        marked[word] = verb.get("in")
        if verb.get("hp"):
            provisional.add(word)

    by_prefix = collections.defaultdict(list)
    everything = []
    for verb in verbs_root:
        word = bare(verb.get("in"))
        if word in provisional:
            continue
        head, base = head_of(verb.get("in")), base_of(verb.get("in"))
        if not head or base == word or base not in hits or base in provisional:
            continue
        ratio = hits[word] / hits[base]
        by_prefix[head].append(ratio)
        everything.append(ratio)

    ratios = {head: statistics.median(values)
              for head, values in by_prefix.items()
              if len(values) >= MIN_PAIRS_FOR_PER_PREFIX_RATIO}
    ratios["__global__"] = statistics.median(everything) if everything else GLOBAL_RATIO
    ratios["__pairs__"] = len(everything)
    return ratios


def write_worklists(dual_auxiliary: list[str], deferred: list[str]) -> None:
    """Persist both deferral lists as tracked files.

    classification.json is gitignored, so anything left only in it is invisible to the next
    session -- and regenerating it needs the 294 MB kaikki snapshot, which is also gitignored.
    A deferral that exists only as a count in a document is not a worklist.

    These are SNAPSHOTS, and the two age differently. Re-running after the import recomputes
    the deferred list against the new corpus, which is what step 8b wants -- it is the current
    state. But the dual-auxiliary list cannot be recomputed at all once its verbs ship, because
    the classifier then skips them: it is a cumulative record of every verb any tranche shipped
    with one reading of two.

    So it is written as a UNION, never a replacement. It used to be replaced, guarded only
    against an empty result -- which held exactly as long as re-runs produced nothing. Step 8b's
    first re-run produced 17 rows, all of them verbs this pass newly unblocked, and overwrote
    176 rows of history with them. Non-empty is not the same as complete, and only the union
    keeps a partial re-run from being indistinguishable from a fresh one.
    """
    existing = []
    if DUAL_WORKLIST.exists():
        existing = [line for line in DUAL_WORKLIST.read_text().splitlines()
                    if line and not line.startswith("#")]
    merged = sorted(set(existing) | set(dual_auxiliary))
    DUAL_WORKLIST.write_text(
        "# Imported with one reading of two; see prompts/dual_auxiliary.md.\n"
        "# Historical and cumulative: rows are only ever added, because a verb that has shipped\n"
        "# is skipped by the classifier and can never be rediscovered.\n"
        "# verb\tkaikki primary auxiliary\ttranslation as shipped\n"
        + "\n".join(merged) + "\n"
    )
    print(f"wrote {DUAL_WORKLIST.relative_to(REPO)} "
          f"({len(merged)} rows, {len(merged) - len(existing)} new)")

    DEFERRED_WORKLIST.write_text(
        "# Verified by the pipeline but NOT imported, and why. Recomputed on every run.\n"
        "# See docs/roadmap.md, \"The tranche-2 deferrals\".\n"
        "# verb\treason\n"
        + "\n".join(sorted(deferred)) + "\n"
    )
    print(f"wrote {DEFERRED_WORKLIST.relative_to(REPO)} ({len(deferred)} rows)")


def retranslate(verbs_text: str, glosses: dict[str, list[str]], check: bool) -> int:
    """Re-run the current translation rules over the translations this importer already shipped.

    Only over those. `step8_normalize_translation` decides ownership; see its docstring for why
    that is a fingerprint rather than a tranche membership test.

    Rewrites the `tn` attribute in place by line, never by parsing and re-serializing. Verbs.xml
    is 8,000-odd hand-maintained lines and ElementTree does not preserve their formatting, so a
    round-trip would rewrite every one of them to change 139 -- the same trap CLAUDE.md documents
    for Localizable.xcstrings, and `git diff --stat` is the same check: insertions and deletions
    should be equal and small.
    """
    lines = verbs_text.splitlines(keepends=True)
    changes, word = [], None
    for i, line in enumerate(lines):
        if match := re.match(r'\s*<verb in="([^"]+)"', line):
            # hp="y" is the necessary condition and the fingerprint is the sufficient one, and
            # both are needed. hp alone sweeps in tranche 1's hand-written translations; the
            # fingerprint alone sweeps in the original 990, where a translation short enough to
            # be obvious is one the rule reproduces by coincidence. wollen ships a hand-written
            # "want" that the rule also derives, and the rewrite would have made it
            # "want, wish, desire, demand" -- longer, and worse for a modal.
            word = bare(match.group(1)) if 'hp="y"' in line else None
            continue
        current = re.search(r'tn="([^"]*)"', line)
        if not (word and current):
            continue
        candidate_glosses = glosses.get(word, [])
        # A verb with several readings has a translation per reading, and the importer only ever
        # generated single-reading verbs, so the fingerprint fails on all of them anyway.
        if step8_normalize_translation(candidate_glosses) != current.group(1):
            continue
        replacement = HAND_TRANSLATIONS.get(word) or normalize_translation(candidate_glosses)
        if not replacement or replacement == current.group(1):
            continue
        changes.append((i, word, current.group(1), replacement))
        lines[i] = line.replace(f'tn="{current.group(1)}"', f'tn="{replacement}"', 1)

    for _, word, before, after in changes:
        print(f"  {word:24} {before!r} -> {after!r}")
    print(f"{len(changes)} translations {'would change' if check else 'rewritten'}")
    if not check:
        VERBS_XML.write_text("".join(lines))
        print(f"wrote {VERBS_XML.relative_to(REPO)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="report, write nothing")
    parser.add_argument("--sample", type=int, default=0, help="print N normalized rows")
    parser.add_argument(
        "--retranslate",
        action="store_true",
        help="rewrite already-shipped translations this importer generated, and exit",
    )
    args = parser.parse_args()

    verbs_text = VERBS_XML.read_text()
    root = ET.fromstring(verbs_text)
    shipping = {bare(v.get("in")): v for v in root}
    hits = {word: int(v.get("hi")) for word, v in shipping.items()}
    icons = {word: v.get("ic") for word, v in shipping.items()}

    ratios = measure_ratios(root)
    pairs = ratios.pop("__pairs__")
    global_ratio = ratios.pop("__global__")

    classifications = json.loads(CLASSIFICATION.read_text())["classifications"]
    glosses = {c["word"]: c.get("glosses", []) for c in json.loads(CANDIDATES.read_text())["candidates"]}
    every_candidate = {c["word"] for c in classifications}

    if args.retranslate:
        return retranslate(verbs_text, glosses, check=args.check)

    rejected = collections.Counter()
    deferred = []
    dual_auxiliary = []
    already_shipping = []
    rows = []
    for entry in classifications:
        if entry["alreadyShipping"] or entry["status"] != "verified":
            continue
        marked = entry.get("markedInfinitiv") or ""
        if "+" not in marked and "*" not in marked:
            continue
        word, base = entry["word"], base_of(marked)
        if base not in shipping or base == word:
            continue
        # Do not trust `alreadyShipping` alone to prevent a double import. It is a field in
        # classification.json, which is gitignored and regenerable, so running this script
        # against a copy generated BEFORE the tranche landed would re-insert all of it.
        # Verbs.xml is the only source of truth for what ships.
        if word in shipping:
            already_shipping.append(word)
            continue

        if entry.get("ablautGroupIsNew"):
            rejected["needs an ablaut group that does not ship"] += 1
            deferred.append(f"{word}\tneeds an ablaut group that does not ship")
            continue
        if ARCHAIC_SPELLING.match(word) or any(
            REFORM_CASUALTY.search(g) for g in glosses.get(word, [])
        ):
            rejected["archaic or pre-1996 orthography"] += 1
            deferred.append(f"{word}\tarchaic or pre-1996 orthography")
            continue
        sharp_s_twin = word.replace("ss", "ß")
        if sharp_s_twin != word and sharp_s_twin in every_candidate:
            rejected["Swiss ss-spelling of a verb written with ß"] += 1
            deferred.append(f"{word}\tSwiss ss-spelling of a verb written with ß")
            continue
        candidate_glosses = glosses.get(word, [])
        translation = HAND_TRANSLATIONS.get(word) or normalize_translation(candidate_glosses)
        if not translation:
            # Both reasons are still worth telling apart in the worklist. A verb every one of
            # whose glosses points elsewhere ("alternative form of benutzen") is a duplicate of
            # an entry already in the corpus and should stay out; one whose glosses merely
            # defeated the normalizer is a gap that better rules could close.
            if candidate_glosses and all(METADATA_GLOSS.search(g) for g in candidate_glosses):
                reason = "every gloss points at another entry rather than translating"
            else:
                reason = "no usable translation survived normalization"
            rejected[reason] += 1
            deferred.append(f"{word}\t{reason}")
            continue

        head = head_of(marked)
        ratio = ratios.get(head, global_ratio)
        estimate = max(1, round(hits[base] * ratio))
        if entry.get("dualAuxiliary"):
            dual_auxiliary.append(f"{word}\t{entry.get('auxiliary')}\t{translation}")

        rows.append({
            "in": marked,
            "tn": translation.replace("&", "&amp;").replace('"', "&quot;").replace("<", "&lt;"),
            "fa": entry["family"],
            "ag": entry.get("ablautGroup"),
            "ay": entry.get("auxiliary") if entry.get("auxiliary") == "s" else None,
            "ic": icons[base],
            "hi": estimate,
            "base": base,
        })

    # Clamp rather than rescale; see "THE RATIO SETS THE ORDER" above. Rescaling the whole
    # tranche onto the band was tried first and is worse: spreading 2,300 verbs evenly across
    # it discards the magnitude the ratio actually measured, and sent *vermieten* — an
    # everyday verb — to the rare tail. Clamping keeps every plausible estimate exactly as
    # measured and compresses only the ones already known to be inflated, which then sit just
    # under the ceiling in ratio order.
    real_counts = sorted((int(v.get("hi")) for v in root if not v.get("hp")), reverse=True)
    ceiling = real_counts[min(CEILING_REAL_RANK, len(real_counts)) - 1]
    rows.sort(key=lambda row: (-row["hi"], row["in"]))
    clamped = sum(1 for row in rows if row["hi"] > ceiling)
    for row in rows:
        row["hi"] = min(row["hi"], ceiling)

    # The derived rank must be a strict total order, and clamping guarantees ties. Walking
    # down to the next free integer preserves the descending order the rows are already in.
    taken = set(hits.values())
    for row in rows:
        while row["hi"] in taken:
            row["hi"] -= 1
        if row["hi"] < 1:
            raise SystemExit(f"{row['in']}: could not find a free hit count")
        taken.add(row["hi"])

    print(f"calibration: {pairs} real derivative/base pairs, global median {global_ratio:.3f}, "
          f"{len(ratios)} per-prefix ratios")
    print(f"clamped to the rank-{CEILING_REAL_RANK} ceiling ({ceiling:,}): {clamped} of {len(rows)}")
    print(f"{len(rows)} verbs to insert")
    print(f"  by family: {dict(collections.Counter(row['fa'] for row in rows))}")
    print(f"  taking sein: {sum(1 for row in rows if row['ay'] == 's')}")
    print(f"  dual-auxiliary, shipping one reading: {len(dual_auxiliary)}")
    for reason, count in rejected.most_common():
        print(f"  rejected {count:5}  {reason}")
    if already_shipping:
        print(f"\n{len(already_shipping)} candidates already ship and were skipped "
              f"(e.g. {', '.join(already_shipping[:5])}).")
        print("classification.json is probably stale; regenerate it before trusting this run.")

    if args.sample:
        print(f"\n--- {args.sample} sample rows ---")
        step = max(1, len(rows) // args.sample)
        for row in rows[::step][:args.sample]:
            print(f'  <verb in="{row["in"]}" hi="{row["hi"]}" hp="y" ic="{row["ic"]}">  '
                  f'tn="{row["tn"]}" fa={row["fa"]} ag={row["ag"]} ay={row["ay"]}  (base {row["base"]})')

    if args.check:
        write_worklists(dual_auxiliary, deferred)
        return 0

    keys = [sort_key(v.get("in")) for v in root]
    if any(earlier > later for earlier, later in zip(keys, keys[1:])):
        print("Verbs.xml is not sorted under sort_key; refusing to insert", file=sys.stderr)
        return 1

    lines = verbs_text.splitlines(keepends=True)
    verb_starts = [(i, sort_key(m.group(1)))
                   for i, line in enumerate(lines)
                   if (m := re.match(r'\s*<verb in="([^"]+)"', line))]
    closing = next(i for i, line in enumerate(lines) if line.strip() == "</verbs>")

    insertions = []
    for row in rows:
        reading = f'<reading tn="{row["tn"]}" fa="{row["fa"]}"'
        if row["ag"]:
            reading += f' ag="{row["ag"]}"'
        if row["ay"]:
            reading += f' ay="{row["ay"]}"'
        reading += " />"
        element = (f'  <verb in="{row["in"]}" hi="{row["hi"]}" hp="y" ic="{row["ic"]}">\n'
                   f"    {reading}\n"
                   f"  </verb>\n")
        key = sort_key(row["in"])
        at = next((i for i, k in verb_starts if k > key), closing)
        insertions.append((at, key, element))

    # Insert back-to-front so earlier indices stay valid. Both keys descend: repeated
    # insert() at one index reverses the insertion order, so verbs sharing an anchor have to
    # go in descending key order to come out ascending.
    for at, _, element in sorted(insertions, key=lambda triple: (triple[0], triple[1]), reverse=True):
        lines.insert(at, element)
    VERBS_XML.write_text("".join(lines))
    write_worklists(dual_auxiliary, deferred)
    print(f"wrote {VERBS_XML.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
