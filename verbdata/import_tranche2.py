#!/usr/bin/env python3
"""Import tranche 2: prefixed derivatives of verbs Konjugieren already conjugates.

Step 8 of docs/roadmap.md. Consumes verbdata/classification.json (the classify-and-verify
pipeline's output) plus verbdata/candidates.json (for the untruncated kaikki glosses), and
writes into Konjugieren/Models/Verbs.xml.

Run:  python3 verbdata/import_tranche2.py [--check] [--sample N] [--screen VERB,VERB,...]

--check reports what would change and writes nothing but the deferred worklist. --sample prints
N normalized rows so the translations can be eyeballed before 2,000-odd user-visible strings
ship. --screen (with --check) runs the named verbs through every per-verb decision, auxiliary
screen included, even if they already ship or fall outside this tranche's scope, prints what the
importer would do with each, and writes nothing at all. It is how the auxiliary screen was shown
to work on verbs Part 6 had to fix; see "AUXILIARIES" below.

Needs the gitignored kaikki snapshot (verbdata/README.md has the recipe), because the auxiliary
screen reads every kaikki record of a verb and classification.json keeps only the first.

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
  `ay`  From the kaikki sense the gloss came from, or the verb is not imported; see
        "AUXILIARIES" below. (Until 2026-11-10 this was kaikki's first-listed lemma auxiliary.)

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

AUXILIARIES (rewritten 2026-11-10; the old rule is the reason Part 6 existed)
-----------------------------------------------------------------------------
Until 2026-11-10 this section said that dual-auxiliary verbs ship "with kaikki's primary
auxiliary and a single reading", and it worked worse than that sounds. `ay` came from the
lemma-level auxiliary of the FIRST kaikki record, the gloss from whichever sense normalized
first, and nothing tied the two together. aufstehen shipped "get up" with haben. Parts 1 and 6
of plans/fix-reference-defects.md then ruled 252 verbs against DWDS, and 128 of them changed.

The rule now lives in verbdata/auxiliary_screen.py, whose header gives it in full with the four
shipped verbs that motivated each part (zuziehen, durchlaufen, abschieben, bleichen). In short:

  * `ay` comes from the same kaikki sense as `tn`, falling back to the lemma's auxiliary only
    when the lemma names one and nothing in kaikki contradicts it.
  * A verb is FLAGGED, and not imported, when kaikki gives it both auxiliaries, has a separable
    and an inseparable verb under its spelling, has a strong and a weak verb under its
    spelling, or has a sense whose own evidence contradicts the lemma's auxiliary.
  * A flagged verb goes to verbdata/auxiliary-rulings.tsv as rows with the outcome `proposed`,
    one per reading its senses suggest (a real run writes them; --check only lists the verb in
    tranche2-deferred.txt). `python3 verbdata/audit_auxiliaries.py --check` fails while any
    proposed row remains, so an unreviewed verb cannot slip through the gate Part 6 built.
    Ruling it means rewriting the rows with real outcomes, sources, and notes, putting new
    glosses through prompts/gloss_review.md, and adding the verb to Verbs.xml by hand.

Measured on 2026-11-10 by screening all 3,572 shipping verbs as if they were incoming: it flags
125 of the 128 verbs whose auxiliary or readings Parts 1 and 6 changed. The three it passes
(entgehen, nachgehen, stattfinden) came from the original hand-entered corpus, not from this
importer, and the screen gives each the auxiliary the ruling chose. Among the 3,320 verbs no
ruling touched, it flags 109, 43 of them verbs the July pass had already given two readings.
That is the review cost a tranche can expect: a few percent of its verbs.

verbdata/tranche2-dual-auxiliary.txt was this section's worklist. It is history now and the
importer no longer writes it; the rulings file is the current record.
"""

import argparse
import collections
import datetime
import json
import pathlib
import re
import statistics
import sys
import xml.etree.ElementTree as ET

import auxiliary_screen

REPO = pathlib.Path(__file__).resolve().parent.parent
VERBS_XML = REPO / "Konjugieren" / "Models" / "Verbs.xml"
CLASSIFICATION = REPO / "verbdata" / "classification.json"
CANDIDATES = REPO / "verbdata" / "candidates.json"
RULINGS = REPO / "verbdata" / "auxiliary-rulings.tsv"
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
    """normalize_translation_from without the source gloss. Kept for --retranslate."""
    return normalize_translation_from(glosses)[0]


def normalize_translation_from(glosses: list[str]) -> tuple[str | None, str | None]:
    """(translation, the kaikki gloss it came from). The source is what the auxiliary screen needs.

    Turn a kaikki gloss into something that reads like the corpus's own `tn` values.

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

    Returns (None, None) only when *no* gloss yields anything, which the caller treats as an
    exclusion rather than shipping an empty string.

    The source gloss is returned because the auxiliary has to come from the same kaikki sense as
    the translation (auxiliary_screen.screen). Falling through to a later gloss is exactly the
    case where the two can part company: a verb whose first sense is a bare header and whose
    second is intransitive motion gets its translation, and must get its auxiliary, from the
    second.

    The one rule worth stating: this never truncates mid-token. The classifier's own
    `shortened` cuts at 60 characters and produced "...rumours, et", which is precisely the
    kind of thing that reaches a user and looks like corruption.
    """
    for gloss in glosses:
        if METADATA_GLOSS.search(gloss):
            continue
        translation = normalize_one_gloss(gloss)
        if translation:
            return translation, gloss
    return None, None


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


def write_worklists(deferred: list[str]) -> None:
    """Persist the deferral list as a tracked file.

    classification.json is gitignored, so anything left only in it is invisible to the next
    session -- and regenerating it needs the 294 MB kaikki snapshot, which is also gitignored.
    A deferral that exists only as a count in a document is not a worklist.

    The deferred list is a SNAPSHOT, recomputed on every run against the current corpus, which
    is what step 8b wanted. Since 2026-11-10 it also lists the verbs the auxiliary screen held
    back, with the screen's reasons, so --check shows them without touching the rulings file.

    This function used to write a second file, verbdata/tranche2-dual-auxiliary.txt, as a
    cumulative UNION of every verb shipped with one reading of two. It was a union because a
    verb that has shipped is skipped by the classifier and can never be rediscovered, and step
    8b's first re-run, when it was still a replacement, overwrote 176 rows of history with 17.
    The auxiliary screen retired it: a dual-auxiliary verb is no longer shipped with one
    reading, so there is nothing to add. The file stays as history, and
    verbdata/auxiliary-rulings.tsv is the current record.
    """
    DEFERRED_WORKLIST.write_text(
        "# Verified by the pipeline but NOT imported, and why. Recomputed on every run.\n"
        "# See docs/roadmap.md, \"The tranche-2 deferrals\". Rows reading \"needs an auxiliary\n"
        "# ruling\" were held back by verbdata/auxiliary_screen.py; a real run writes them to\n"
        "# verbdata/auxiliary-rulings.tsv as proposed rows.\n"
        "# verb\treason\n"
        + "\n".join(sorted(deferred)) + "\n"
    )
    print(f"wrote {DEFERRED_WORKLIST.relative_to(REPO)} ({len(deferred)} rows)")


def append_proposed_rulings(lines: list[str]) -> None:
    """Append `proposed` rows to verbdata/auxiliary-rulings.tsv, as text, never rewriting the file.

    The file is hand-maintained and read with csv.QUOTE_NONE (see audit_auxiliaries.py), so it
    is appended to exactly as Part 6's sessions edited it: whole lines at the end. The caller
    has already skipped any verb that has rows, so a re-run cannot duplicate a proposal, and a
    ruled row is never overwritten by a fresh proposal.
    """
    if not lines:
        return
    text = RULINGS.read_text()
    if not text.endswith("\n"):
        text += "\n"
    RULINGS.write_text(text + "\n".join(lines) + "\n")
    print(f"appended {len(lines)} proposed rows to {RULINGS.relative_to(REPO)}")


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


def print_screened(word, ships, translation, source_gloss, result, lemma, marked, encoding):
    """--screen's report for one verb: what the importer would do with it, and why."""
    print(f"{word}{'  (ships today; screened as if incoming)' if ships else ''}")
    print(f"  translation  {translation!r}, from kaikki gloss {source_gloss!r}")
    if not result.flagged:
        print(f"  IMPORT with ay={result.auxiliary}  ({encoding})")
        return
    print("  HELD: not imported. Flagged:")
    for reason in result.reasons:
        print(f"    - {reason}")
    print("  would append to verbdata/auxiliary-rulings.tsv:")
    proposals = auxiliary_screen.propose(lemma, result, marked, normalize_one_gloss)
    for line in auxiliary_screen.rulings_rows(word, result, proposals, encoding,
                                              datetime.date.today().isoformat()):
        cells = line.split("\t")
        print(f"    {cells[0]} reading {cells[1]}: {cells[2]!r} ay={cells[3]}"
              f"{' in=' + cells[4] if cells[4] else ''}  [{cells[5]}]")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true",
                        help="report; write only the deferred worklist")
    parser.add_argument("--sample", type=int, default=0, help="print N normalized rows")
    parser.add_argument(
        "--retranslate",
        action="store_true",
        help="rewrite already-shipped translations this importer generated, and exit",
    )
    parser.add_argument(
        "--screen",
        metavar="VERB,VERB,...",
        help="with --check: run these verbs through every decision, even if they ship or fall "
             "outside this tranche, print the outcome, and write nothing",
    )
    args = parser.parse_args()
    if args.screen and not args.check:
        parser.error("--screen only reports, so it needs --check")
    screened = [w.strip() for w in args.screen.split(",") if w.strip()] if args.screen else []

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

    # Verbs with rows in the rulings file are decided there, whether ruled or still proposed.
    ruled = set()
    with RULINGS.open() as handle:
        next(handle)
        ruled = {line.split("\t", 1)[0] for line in handle if line.strip()}

    rejected = collections.Counter()
    deferred = []
    already_shipping = []

    # Pass 1: every filter that needs only classification.json and candidates.json. The
    # survivors are collected rather than decided, so that the kaikki snapshot (294 MB) is read
    # once, for exactly the verbs that reach the auxiliary screen.
    pending = []
    for entry in classifications:
        word = entry["word"]
        marked = entry.get("markedInfinitiv") or ""
        base = base_of(marked)
        if screened:
            # --screen bypasses SCOPE (already shipping, unprefixed, base not shipping) so a
            # shipped verb can be put through the same decisions an incoming one would meet.
            # It does not bypass the QUALITY filters below, which would apply to any import.
            if word not in screened:
                continue
        else:
            if entry["alreadyShipping"] or entry["status"] != "verified":
                continue
            if "+" not in marked and "*" not in marked:
                continue
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
        if word in HAND_TRANSLATIONS:
            translation, source_gloss = HAND_TRANSLATIONS[word], None
        else:
            translation, source_gloss = normalize_translation_from(candidate_glosses)
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
        pending.append((entry, word, marked, base, translation, source_gloss))

    # Pass 2: the auxiliary screen. See "AUXILIARIES" in the header and the header of
    # verbdata/auxiliary_screen.py. A flagged verb is held back and proposed for a ruling.
    lemmas = auxiliary_screen.load(word for _, word, *_ in pending)
    proposed_lines = []
    flagged = []
    differs_from_classifier = []
    rows = []
    for entry, word, marked, base, translation, source_gloss in pending:
        result = auxiliary_screen.screen(lemmas.get(word), source_gloss)
        encoding = f"fa={entry.get('family')} ag={entry.get('ablautGroup') or '-'} in={marked}"
        if screened:
            print_screened(word, word in shipping, translation, source_gloss, result,
                           lemmas.get(word), marked, encoding)
            continue
        if word in ruled:
            rejected["has rows in auxiliary-rulings.tsv; add it by hand per its ruling"] += 1
            deferred.append(f"{word}\thas rows in auxiliary-rulings.tsv; add it by hand per its ruling")
            continue
        if result.flagged:
            reason = "needs an auxiliary ruling: " + "; ".join(result.reasons)
            rejected["needs an auxiliary ruling (proposed in auxiliary-rulings.tsv)"] += 1
            deferred.append(f"{word}\t{reason}")
            flagged.append(word)
            proposals = auxiliary_screen.propose(lemmas[word], result, marked, normalize_one_gloss)
            proposed_lines.extend(auxiliary_screen.rulings_rows(
                word, result, proposals, encoding, datetime.date.today().isoformat()))
            continue
        # The classifier's `auxiliary` is the first record's lemma auxiliary, the old source of
        # `ay`. Where the screen passes a verb they should agree, since an unflagged lemma names
        # one auxiliary. A disagreement means a later record named a different one, which the
        # screen would have flagged, so a nonzero count here is a bug in one of the two.
        if result.auxiliary != (entry.get("auxiliary") or "h"):
            differs_from_classifier.append(word)

        head = head_of(marked)
        ratio = ratios.get(head, global_ratio)
        estimate = max(1, round(hits[base] * ratio))

        rows.append({
            "in": marked,
            "tn": translation.replace("&", "&amp;").replace('"', "&quot;").replace("<", "&lt;"),
            "fa": entry["family"],
            "ag": entry.get("ablautGroup"),
            "ay": result.auxiliary if result.auxiliary == "s" else None,
            "ic": icons[base],
            "hi": estimate,
            "base": base,
        })

    if screened:
        missing = sorted(set(screened) - {word for _, word, *_ in pending})
        for word in missing:
            reason = next((d.split("\t", 1)[1] for d in deferred if d.startswith(word + "\t")),
                          "not in classification.json")
            print(f"{word}: stopped before the auxiliary screen ({reason})")
        print("--screen writes nothing.")
        return 0

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
    print(f"  held for an auxiliary ruling: {len(flagged)} ({', '.join(flagged) or 'none'})")
    if differs_from_classifier:
        print(f"  WARNING: screen and classifier disagree on the auxiliary of "
              f"{', '.join(differs_from_classifier)}; see the comment in main()")
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
        write_worklists(deferred)
        if proposed_lines:
            print(f"a real run would append {len(proposed_lines)} proposed rows to "
                  f"{RULINGS.relative_to(REPO)}")
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
    write_worklists(deferred)
    append_proposed_rulings(proposed_lines)
    print(f"wrote {VERBS_XML.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
