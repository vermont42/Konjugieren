#!/usr/bin/env python3
"""Import tranche 3: new weak and -ieren stems, ranked by DWDS frequency.

Step 9 of docs/roadmap.md, item 7 of docs/verb-sources.md's next steps. Written 2026-11-10.
Consumes verbdata/classification.json (the classify-and-verify pipeline's verdicts),
verbdata/candidates.json (kaikki glosses and forms), the gitignored kaikki snapshot (through
verbdata/auxiliary_screen.py), and a DWDS frequency snapshot fetched for this tranche. Writes
Konjugieren/Models/Verbs.xml only on a real run with a cutoff.

Run, in this order, from the repository root:

  python3 verbdata/import_tranche3.py --write-lemmas
      Writes verbdata/dwds/tranche3-lemmas.tsv: every candidate that survives the filters that
      need no network, with two probes each (see "FREQUENCY" below). Prints the fetch command.

  python3 verbdata/fetch_dwds_frequencies.py --lemmas verbdata/dwds/tranche3-lemmas.tsv \\
      --out verbdata/dwds/tranche3-frequencies.json \\
      --quarantine verbdata/dwds/tranche3-quarantine.json --workers 2
      The fetch. BBAW asked that the volume stay modest; two workers and the default delay
      are what the corpus-wide run of 2026-08-26 used. Expect an hour or two.

  python3 verbdata/import_tranche3.py --write-repair-lemmas
  python3 verbdata/fetch_dwds_frequencies.py --lemmas verbdata/dwds/tranche3-repair-lemmas.tsv \
      --out verbdata/dwds/tranche3-frequencies-repair.json \
      --quarantine verbdata/dwds/tranche3-quarantine-repair.json --workers 2
      The repair pass, for two kinds of quarantined row that are the probe's fault and not the
      verb's (see "THE REPAIR PASS" below). A few dozen lemmas, a minute or two.

  python3 verbdata/import_tranche3.py --check [--top N | --min-hits H]
      The dry run. Writes verbdata/tranche3-ranked.tsv (every importable verb, most frequent
      first, with the corpus rank it would take) and verbdata/tranche3-deferred.txt (every
      verb held back, and why). Touches nothing else. The ranked list is what a human reads
      to choose the cutoff, which the roadmap leaves to taste.

  python3 verbdata/import_tranche3.py --top N        (or --min-hits H)
      The import. Inserts the chosen verbs into Verbs.xml and appends `proposed` rows for the
      verbs the auxiliary screen held back to verbdata/auxiliary-rulings.tsv. Refuses to run
      without a cutoff, because "all of them" is a decision nobody has made.

WHY A NEW SCRIPT, NOT import_tranche2.py
----------------------------------------
Tranche 2 imported prefixed derivatives of shipping bases, and nearly every rule in it leans on
the base: `ic` is inherited from it, `hi` is the base's count scaled by a measured ratio, and
the scope test is "has a prefix and a shipping base". A bare stem has no base, so all three
rules are wrong here. What does carry over is imported, not copied: the gloss normalizer and
the quality filters from import_tranche2.py, and the auxiliary rule from auxiliary_screen.py.
The roadmap's condition for releasing step 9 was exactly that last import.

SCOPE
-----
A verb is in scope when the pipeline verified it, it does not ship, its marked infinitive has
no prefix marker, and its family is weak (`w`) or -ieren (`i`). On 2026-11-10 that was 1,904
weak and 1,078 -ieren stems. Out of scope, and counted in the summary:

  * Bare strong and mixed stems (24). The strong inventory was tranche 1's job, done by hand
    with a decision per verb; these are what it left. They need the same care, not a rule.
  * Prefixed verbs whose base does not ship (about 2,100). They are tranche 2's shape and
    become importable when their base lands, by re-running import_tranche2.py to a fixpoint,
    exactly as step 8b did after tranche 1.

FREQUENCY: `hi` IS A REAL DWDS COUNT
------------------------------------
BBAW's permission (2026-08-26) means no estimate is needed, so `hi` is the measured count and
`hp` is never set. The counts come from fetch_dwds_frequencies.py, whose header explains why
an infinitive is not a safe query (runden -> rund). Each lemma is therefore probed with two
verbal forms from kaikki's own table, the Perfektpartizip and the Präsens 3s (gegoogelt,
googelt), which is the shape that header recommends for a bulk import. The fetcher requires
both probes to resolve to the lemma and to return the same count, and it quarantines a row
that does not. A quarantined or unfetched verb is deferred here, never estimated.

A DWDS count that merely spells the lemma differently (reißen -> reissen) is accepted, as the
fetcher accepts it.

THE REPAIR PASS
---------------
The first fetch, on 2026-11-10, verified 2,614 of 2,850 lemmas and quarantined 236. Most
quarantines are the verb's own doing and stay deferred: 46 have zero hits (abalienieren), and
129 return probes that disagree, nearly all rare words whose forms DWDS does not lemmatize. But
two kinds are the probe's fault:

  * 57 -ieren verbs "resolved to a different word". An -ieren verb's participle and Präsens 3s
    are the same string (schockiert), so it got one probe, and DWDS read that participle as the
    lexicalized ADJECTIVE: schockiert, irritiert, kompliziert, resigniert. Common verbs, lost
    to the same trap as runden -> rund, one step removed.
  * 4 network failures after three retries (naschen, narren).

--write-repair-lemmas re-probes exactly those with the Präsens 1s and the Präteritum 3s
(schockiere, schockierte), which no adjective inflects to. A second snapshot holds the answers,
and load_frequencies merges it over the first. The probe choice for the first pass is left as
it was, so the first pass stays reproducible; a future tranche can start from the safer pair.

`hi` must be unique, because the app derives a strict rank from it. A real count that collides
with a shipping one is lowered by one until it is free, which moves no verb more than a rank
or two and is noted in the summary. Tranche 2 used the same walk on its estimates.

TWO HOLES THE FIRST DRY RUN FOUND
---------------------------------
1. A same-string homograph defeats the probe gate. DWDS counts by lemma STRING across parts
   of speech. runden -> rund was caught because the probe resolved to a different string.
   But when the verb's infinitive is itself the lemma of a non-verb, both probes resolve to
   that lemma, agree, and pass: sondern (the conjunction, 26.4 million hits, which would have
   ranked 22nd in the corpus), sieben (the numeral), modern (the adjective). The endpoint has
   no part-of-speech filter (see fetch_dwds_frequencies.py), so this cannot be detected from
   the count. SAME_STRING_HOMOGRAPHS lists the ones found by reading the ranked list's first
   600 rows by eye on 2026-11-10. Below row 600 nobody has read it, so a cutoff past 600 needs
   that reading first. Treat a count that looks too high for the verb as suspect.

2. A hidden compound rides on a corrupt Wiktionary table. English Wiktionary auto-generates a
   weak table for a page with no conjugation template (docs/roadmap.md, "Wiktionary
   auto-generates weak conjugation tables"), so a separable compound of a shipping verb can
   arrive as a BARE stem whose table reads gezusammensucht, and verify against it. The check
   reads the corpus's own prefix inventory off Verbs.xml's markup and holds any bare candidate
   that splits into one of those prefixes plus a shipping verb. On 2026-11-10 it held six:
   zusammensuchen, eintrocknen, and darreichen (corrupt tables), abservieren (separable, so its
   Imperativ is "serviere ab", not "abserviere"), and two false positives that are correct
   bare (weissagen, geweissagt; gutachten, gegutachtet). Holding a false positive costs one
   look; importing a corrupt one ships a wrong participle.

TRANSLATIONS AND AUXILIARIES
----------------------------
`tn` is import_tranche2.normalize_translation_from, unchanged. `ay` comes from
auxiliary_screen.screen, which takes it from the same kaikki sense as `tn` and holds the verb
back when kaikki cannot settle it (dual auxiliary, separability homograph, family split, or a
sense that contradicts the lemma). Held verbs are deferred, and a real run proposes their
readings in the rulings file, where audit_auxiliaries.py --check fails until a session rules
them. Most weak stems take haben and pass, so expect the screen to hold a few percent.

ICONS: A KEYWORD MAP FROM THE GLOSS
-----------------------------------
`ic` names an SF Symbol figure (the app prefixes `figure.`). Josh chose a keyword map on
2026-11-10. The corpus's 40 symbols already have habits, read off the 488 unprefixed verbs
that were iconned by hand: speech is `wave` (answer, ask, thank), thought is `yoga`
(think, believe), cooking is `cooldown` (bake, roast), cutting is `fencing`, conflict is
`boxing`. ICON_KEYWORDS encodes those habits as English head words. On the 488 unprefixed
shipping verbs the map matches 252, and gives the hand-chosen icon for 188 of those, which is
partly circular, since the map was read off them. Each comma-separated part
of the translation is tried in order, and the first part whose head word is in the map wins.
A verb whose translation matches nothing gets `flexibility`, the corpus's commonest symbol and
the one its hand-iconned stems use for the widest spread of meanings. The map only points at
symbols that already ship, so no new asset is needed.

WHAT A NEW VERB LACKS
---------------------
An etymology and an example sentence. VerbView shows neither section when the verb has none,
so nothing breaks, but the step-10 pipeline (prompts/uses_etymologies.md and the `integrate`
skill) has to run over the new verbs before the corpus is whole again, and
docs/etymology-pipeline.md must not claim completeness meanwhile (check_docs.py checks it).
"""

import argparse
import collections
import datetime
import json
import pathlib
import re
import sys
import xml.etree.ElementTree as ET

import auxiliary_screen
from import_tranche2 import (
    ARCHAIC_SPELLING,
    METADATA_GLOSS,
    REFORM_CASUALTY,
    append_proposed_rulings,
    bare,
    normalize_one_gloss,
    normalize_translation_from,
    sort_key,
)

REPO = pathlib.Path(__file__).resolve().parent.parent
VERBS_XML = REPO / "Konjugieren" / "Models" / "Verbs.xml"
CLASSIFICATION = REPO / "verbdata" / "classification.json"
CANDIDATES = REPO / "verbdata" / "candidates.json"
RULINGS = REPO / "verbdata" / "auxiliary-rulings.tsv"
LEMMAS = REPO / "verbdata" / "dwds" / "tranche3-lemmas.tsv"
FREQUENCIES = REPO / "verbdata" / "dwds" / "tranche3-frequencies.json"
QUARANTINE = REPO / "verbdata" / "dwds" / "tranche3-quarantine.json"
REPAIR_LEMMAS = REPO / "verbdata" / "dwds" / "tranche3-repair-lemmas.tsv"
REPAIR_FREQUENCIES = REPO / "verbdata" / "dwds" / "tranche3-frequencies-repair.json"
RANKED = REPO / "verbdata" / "tranche3-ranked.tsv"
DEFERRED = REPO / "verbdata" / "tranche3-deferred.txt"

FAMILIES = {"w", "i"}

# Infinitives that are also the lemma of another part of speech, so DWDS's count includes it.
# See "TWO HOLES THE FIRST DRY RUN FOUND", item 1. Found by reading the first 600 ranked rows.
SAME_STRING_HOMOGRAPHS = {
    "modern": "the adjective modern",
    "sieben": "the numeral sieben",
    "sondern": "the conjunction sondern",
}
DEFAULT_ICON = "flexibility"

# English head word -> icon. Grouped by the habit each symbol already has in the corpus; see
# "ICONS" in the header. Only symbols that already ship appear on the right. When a word could
# sit in two groups, it goes where the hand-iconned stems put its nearest neighbour.
ICON_KEYWORDS = {
    # Speech and sound: answer, ask, thank, discuss all wear `wave`.
    **dict.fromkeys(
        "address announce answer ask bark beg call chat complain confess cry curse discuss "
        "explain express greet growl howl inform invite mention mumble murmur order praise "
        "pray preach promise protest quote recite reply report request say scold scream shout "
        "sing speak stammer stutter suggest swear talk tell thank translate utter warn whisper "
        "yell".split(), "wave"),
    # Thought and feeling: think, believe, feel wear `yoga`.
    **dict.fromkeys(
        "believe brood consider contemplate daydream doubt dream feel fear guess imagine "
        "interpret meditate mourn muse ponder reflect regret suspect think trust wonder "
        "worry".split(), "yoga"),
    # Knowing, perceiving, serving, suffering: `mind.and.body`.
    **dict.fromkeys("hear know learn listen perceive serve study suffer taste".split(),
                    "mind.and.body"),
    # Cooking, eating, drinking, temperature: bake, roast, eat wear `cooldown`.
    **dict.fromkeys(
        "bake boil brew chew cook cool devour digest dine drink eat feed fry grill heat "
        "nourish roast salt season simmer sip smoke steam stew swallow toast".split(),
        "cooldown"),
    # Conflict and damage: annoy, hit, threaten, dominate wear `boxing`.
    **dict.fromkeys(
        "annoy attack batter beat bother bully crush damage destroy dominate harass harm hate "
        "hit hurt insult kill kick knock mock murder oppress provoke punch punish slap "
        "smash strike tease threaten torment torture wound".split(), "boxing"),
    # Cutting and dividing: cut, separate, share wear `fencing`.
    **dict.fromkeys("carve chop cut divide duel fence fight saw separate share slice "
                    "split trim".split(), "fencing"),
    # Joining and helping: bind, help, combine wear `2.and.child.holdinghands`.
    **dict.fromkeys("assist attach bind combine connect fasten help join link secure support "
                    "tie unite".split(), "2.and.child.holdinghands"),
    # Pairs of people: marry, hire, contact wear `2`.
    **dict.fromkeys("accompany contact date engage hire kiss marry meet partner trade "
                    "visit".split(), "2"),
    # Numbers and money: finance, measure, calculate wear `barre`.
    **dict.fromkeys("balance budget calculate charge cost count estimate finance invest "
                    "measure pay price rate regulate weigh".split(), "barre"),
    # Taking and catching: accept, catch, fetch wear `handball`.
    **dict.fromkeys("accept catch fetch get grab grasp hold obtain receive seize snatch "
                    "take throw toss".split(), "handball"),
    # Shaping, founding, leading: form, establish, lead wear `walk.arrival`.
    **dict.fromkeys("create design educate establish form found govern guide lead manage "
                    "organize organise shape teach train".split(), "walk.arrival"),
    # Effort and making: work, build, change, push wear `strengthtraining.traditional`.
    **dict.fromkeys("build construct drag hammer haul labour labor lift press push repair "
                    "work".split(), "strengthtraining.traditional"),
    # Carrying and moving things: bring, carry, transport wear `hiking`.
    **dict.fromkeys("bring carry deliver harvest hike load move ship transport".split(),
                    "hiking"),
    # Water: swim, wash, flow wear `pool.swim`.
    **dict.fromkeys("bathe dip drip flood flow pour rinse soak splash spray sprinkle swim "
                    "wash water".split(), "pool.swim"),
    # Light, fire, energy: activate, shine, glow wear `highintensity.intervaltraining`.
    **dict.fromkeys("activate blaze flash flicker glow ignite light shine sparkle "
                    "switch".split(), "highintensity.intervaltraining"),
    # Falling, ending, weather: fall, end, rain wear `fall`.
    **dict.fromkeys("collapse crumble drop end fail fall hail rain sink snow stumble "
                    "topple".split(), "fall"),
    # Rising and growing: rise, increase, grow wear `stairs`.
    **dict.fromkeys("ascend climb grow improve increase promote rise".split(), "stairs"),
    # Going on foot: go, walk, approach wear `walk`.
    **dict.fromkeys("approach go march pace roam stride stroll walk wander".split(), "walk"),
    # Speed: run, flee, race wear `run`.
    **dict.fromkeys("dash escape flee hasten hurry race run rush sprint".split(), "run"),
    # Guarding and needing: follow, avoid, protect wear `walk.motion`.
    **dict.fromkeys("avoid cover follow guard need protect shield spare".split(),
                    "walk.motion"),
    # Steering and caring: drive, steer, nurse wear `seated.side.left.steeringwheel`.
    **dict.fromkeys("care drive nurse pilot steer tend".split(),
                    "seated.side.left.steeringwheel"),
    # Sitting and staying: sit, stay, position wear `seated.side.left`.
    **dict.fromkeys("lodge position remain rest settle sit stay".split(), "seated.side.left"),
    # Standing and placing: stand, place, arrange wear `stand`.
    **dict.fromkeys("arrange line place put queue set stand wait".split(), "stand"),
    # Aiming and pointing: shoot, aim, point wear `archery`.
    **dict.fromkeys("aim focus point score shoot target".split(), "archery"),
    # Sliding: glide, slide, slip wear `skating`.
    **dict.fromkeys("glide skate ski slide slip".split(), "skating"),
    # Turning and dancing: dance, turn, rotate wear `socialdance`.
    **dict.fromkeys("dance rotate spin swirl swing turn twirl twist".split(), "socialdance"),
    # Rolling and winding: roll, wind wear `roll`.
    **dict.fromkeys("roll wind wrap".split(), "roll"),
    # Jumping and hoping: jump, hope, vibrate wear `jumprope`.
    **dict.fromkeys("bounce hop hope jump leap skip vibrate".split(), "jumprope"),
    # Struggling and trying: wrestle, try, strive wear `wrestling`.
    **dict.fromkeys("attempt grapple strive struggle try wrestle".split(), "wrestling"),
    # Play and pretence: play, lie, deceive wear `play`.
    **dict.fromkeys("cheat deceive fool joke lie play pretend trick".split(), "play"),
    # Pulling and sticking: pull, stick, glue wear `indoor.rowing`.
    **dict.fromkeys("glue paste pull row stick tug".split(), "indoor.rowing"),
    # Crawling and creeping wear `climbing`, as clamber and crawl already do.
    **dict.fromkeys("clamber crawl creep".split(), "climbing"),
    # Hunting and biting.
    **dict.fromkeys("bite chase hunt prey stalk".split(), "hunting"),
    # Cold: "be cold" and "melt, thaw" wear `skiing.downhill`, as does fly.
    **dict.fromkeys("chill fly freeze frost thaw".split(), "skiing.downhill"),
    "ride": "equestrian.sports",
    # The clusters below were added after the first measurement on the incoming pool, where
    # 2,190 of 2,850 translations fell back to the default. Each extends a habit above rather
    # than starting one. The tail is 1,700 distinct head words and no map will cover it.
    # Sounds join speech, as bark and blow already have.
    **dict.fromkeys(
        "argue babble bang bawl blare bleat blow boast boom brag buzz cackle cheep chirp "
        "clatter clink crackle croak flatter gasp giggle grumble honk hum jingle laugh moan "
        "purr ramble rattle ring roar rumble rustle sigh snore snort sob squeak squeal thud "
        "thunder wail whine whistle".split(), "wave"),
    # Looking and searching: aim the eyes, as focus and point do.
    **dict.fromkeys("browse check examine inspect look observe peek peer search spy squint "
                    "stare watch".split(), "archery"),
    # Rest: sleep beside sit and stay.
    **dict.fromkeys("doze laze loll lounge nap sleep slumber".split(), "seated.side.left"),
    # Cleaning joins washing.
    **dict.fromkeys("clean mop polish rub scour scrub sweep wipe".split(), "pool.swim"),
    # Shaking and swaying join turning and swinging.
    **dict.fromkeys("dangle quiver rock shake shiver shudder sway tilt totter tremble "
                    "wobble".split(), "socialdance"),
    # Nibbling, sucking, grazing join eating.
    **dict.fromkeys("gnaw graze gulp lick munch nibble slurp suck".split(), "cooldown"),
    # Breaking, stealing, and seizing people join conflict, as "break (something)" did.
    **dict.fromkeys("abduct arrest break butcher rob scratch slaughter smash "
                    "strangle".split(), "boxing"),
    # Affection joins pairs.
    **dict.fromkeys("caress court cuddle embrace flirt hug love woo".split(), "2"),
    # Decorating and marking join shaping.
    **dict.fromkeys("decorate draw engrave frame glaze label mark paint print sketch "
                    "write".split(), "walk.arrival"),
    # Giving and handing join taking.
    **dict.fromkeys("give hand lend offer pass pick provide supply".split(), "handball"),
    # Decay joins falling.
    **dict.fromkeys("decay mould rot spoil wilt wither".split(), "fall"),
    # Mixing and stirring join moving things, as "stir, move" does.
    **dict.fromkeys("camp mix stir".split(), "hiking"),
}


def icon_for(translation):
    """The icon for a translation: the first comma-separated part whose head word is mapped.

    The head word is the part's first word after any leading "be", "get", "make", or "to",
    since kaikki glosses often start with a light verb ("be cold", "get angry") whose meaning
    is in what follows. "be" is skipped rather than mapped because it would claim half the
    stative verbs for one symbol.
    """
    for part in translation.split(","):
        words = re.findall(r"[a-z]+", part.lower())
        while words and words[0] in {"to", "be", "get", "make", "become"}:
            words = words[1:]
        if words and words[0] in ICON_KEYWORDS:
            return ICON_KEYWORDS[words[0]]
    return DEFAULT_ICON


def load_frequencies():
    """lemma -> hits, from the tranche-3 snapshot with the repair snapshot merged over it.

    {} if the main snapshot has not been fetched. A lemma is in at most one of the two, since
    the repair pass queries only lemmas the first pass quarantined, so the merge order matters
    only if someone re-runs a fetch by hand.
    """
    if not FREQUENCIES.exists():
        return {}
    hits = {row["lemma"]: row["hits"] for row in json.loads(FREQUENCIES.read_text())}
    if REPAIR_FREQUENCIES.exists():
        hits.update({row["lemma"]: row["hits"] for row in json.loads(REPAIR_FREQUENCIES.read_text())})
    return hits


def repair_probes(candidate):
    """The Präsens 1s and the Präteritum 3s: verbal forms no adjective takes. See THE REPAIR PASS."""
    forms = candidate.get("forms", {})
    probes = []
    for slot in ("präsensIndikativ.fs", "präteritumIndikativ.ts"):
        values = forms.get(slot) or []
        if values and values[0] != candidate["word"] and values[0] not in probes:
            probes.append(values[0])
    return probes


def candidates_in_scope(classifications, shipping):
    """The verified, unshipped, unprefixed weak and -ieren stems, plus out-of-scope counts."""
    scope, outside = [], collections.Counter()
    for entry in classifications:
        word = entry["word"]
        if entry["alreadyShipping"] or word in shipping or entry["status"] != "verified":
            continue
        marked = entry.get("markedInfinitiv") or ""
        if "+" in marked or "*" in marked:
            outside["prefixed (tranche 2's shape; import when the base ships)"] += 1
            continue
        if entry.get("family") not in FAMILIES:
            outside[f"bare stem of family {entry.get('family')} (tranche 1's shape)"] += 1
            continue
        scope.append(entry)
    return scope, outside


def quality_filter(entry, glosses, every_candidate):
    """(translation, source_gloss, None) or (None, None, reason). The filters tranche 2 applies.

    Swiss ss-spellings are tested against every candidate, as tranche 2 does, so a Swiss twin
    of a verb that is itself still incoming is caught too.
    """
    word = entry["word"]
    candidate_glosses = glosses.get(word, [])
    if ARCHAIC_SPELLING.match(word) or any(REFORM_CASUALTY.search(g) for g in candidate_glosses):
        return None, None, "archaic or pre-1996 orthography"
    sharp_s_twin = word.replace("ss", "ß")
    if sharp_s_twin != word and sharp_s_twin in every_candidate:
        return None, None, "Swiss ss-spelling of a verb written with ß"
    translation, source = normalize_translation_from(candidate_glosses)
    if not translation:
        if candidate_glosses and all(METADATA_GLOSS.search(g) for g in candidate_glosses):
            return None, None, "every gloss points at another entry rather than translating"
        return None, None, "no usable translation survived normalization"
    return translation, source, None


def probes_for(candidate):
    """Two verbal probes from kaikki's table: the participle and the Präsens 3s.

    A probe identical to the infinitive is dropped, since it would make the query no safer
    than the bare infinitive it is meant to replace.
    """
    forms = candidate.get("forms", {})
    probes = []
    for slot in ("perfektpartizip", "präsensIndikativ.ts"):
        values = forms.get(slot) or []
        if values and values[0] != candidate["word"] and values[0] not in probes:
            probes.append(values[0])
    return probes


def shipping_prefixes(root):
    """Every prefix the corpus's markup uses: the text before each `+` or `*` in an `in`."""
    prefixes = set()
    for verb in root:
        for match in re.finditer(r"([a-zäöüß]+)[+*]", verb.get("in").replace("^", "")):
            prefixes.add(match.group(1))
    return prefixes


def hidden_compound(word, prefixes, shipping):
    """'zusammen+suchen' if word splits into a shipping prefix and a shipping verb, else None.

    The verb part must be at least four letters, so that a short shipping verb (tun, sein)
    does not make every word ending in it look like a compound.
    """
    for i in range(2, len(word) - 3):
        if word[:i] in prefixes and word[i:] in shipping:
            return f"{word[:i]}+{word[i:]}"
    return None


def corpus_rank(hits, shipping_hits):
    """The 1-based rank a count would take among the shipping verbs' counts."""
    return 1 + sum(1 for other in shipping_hits if other > hits)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--write-lemmas", action="store_true",
                        help="write the DWDS fetch input and exit")
    parser.add_argument("--write-repair-lemmas", action="store_true",
                        help="write the repair fetch input for probe-caused quarantines and exit")
    parser.add_argument("--check", action="store_true",
                        help="dry run: write the ranked and deferred lists, nothing else")
    cutoff = parser.add_mutually_exclusive_group()
    cutoff.add_argument("--top", type=int, help="import the N most frequent importable verbs")
    cutoff.add_argument("--min-hits", type=int, help="import every importable verb with at least H hits")
    args = parser.parse_args()

    verbs_text = VERBS_XML.read_text()
    root = ET.fromstring(verbs_text)
    shipping = {bare(v.get("in")): v for v in root}
    shipping_hits = sorted((int(v.get("hi")) for v in root), reverse=True)

    classifications = json.loads(CLASSIFICATION.read_text())["classifications"]
    candidates = {c["word"]: c for c in json.loads(CANDIDATES.read_text())["candidates"]}
    glosses = {word: c.get("glosses", []) for word, c in candidates.items()}
    every_candidate = {c["word"] for c in classifications}

    scope, outside = candidates_in_scope(classifications, shipping)
    prefixes = shipping_prefixes(root)
    deferred, survivors = [], []
    for entry in scope:
        translation, source, reason = quality_filter(entry, glosses, every_candidate)
        split = hidden_compound(entry["word"], prefixes, shipping)
        if not reason and split:
            reason = (f"hidden compound: looks like {split}, a prefixed derivative of a shipping verb; check its "
                      f"table against German Wiktionary (kaikki gives "
                      f"{(candidates[entry['word']]['forms'].get('perfektpartizip') or ['?'])[0]})")
        if reason:
            deferred.append((entry["word"], reason))
        else:
            survivors.append((entry, translation, source))

    if args.write_lemmas:
        LEMMAS.parent.mkdir(parents=True, exist_ok=True)
        lines = ["\t".join([entry["word"], *probes_for(candidates[entry["word"]])])
                 for entry, _, _ in survivors]
        LEMMAS.write_text("\n".join(lines) + "\n")
        print(f"wrote {LEMMAS.relative_to(REPO)} ({len(lines)} lemmas; "
              f"{len(deferred)} filtered out before fetching)")
        print("fetch with:\n  python3 verbdata/fetch_dwds_frequencies.py "
              f"--lemmas {LEMMAS.relative_to(REPO)} --out {FREQUENCIES.relative_to(REPO)} "
              "--quarantine verbdata/dwds/tranche3-quarantine.json --workers 2")
        return 0

    if args.write_repair_lemmas:
        quarantined = json.loads(QUARANTINE.read_text()) if QUARANTINE.exists() else []
        # Only the two probe-caused kinds; zero hits and disagreeing probes stay deferred.
        repairable = [row["lemma"] for row in quarantined
                      if "a different word" in row["reason"] or "fetch failed" in row["reason"]]
        lines = ["\t".join([word, *repair_probes(candidates[word])]) for word in repairable]
        REPAIR_LEMMAS.write_text("\n".join(lines) + "\n")
        print(f"wrote {REPAIR_LEMMAS.relative_to(REPO)} ({len(lines)} of {len(quarantined)} "
              f"quarantined lemmas are the probe's fault)")
        return 0

    if not args.check and args.top is None and args.min_hits is None:
        parser.error("a real import needs --top N or --min-hits H; use --check for a dry run")

    frequencies = load_frequencies()
    if not frequencies:
        print(f"no frequency snapshot at {FREQUENCIES.relative_to(REPO)}; run --write-lemmas "
              "and the fetch first", file=sys.stderr)
        return 1

    with RULINGS.open() as handle:
        next(handle)
        ruled = {line.split("\t", 1)[0] for line in handle if line.strip()}

    lemmas = auxiliary_screen.load(entry["word"] for entry, _, _ in survivors)
    importable, proposed_lines = [], []
    for entry, translation, source in survivors:
        word = entry["word"]
        hits = frequencies.get(word)
        if hits is None:
            deferred.append((word, "no verified DWDS count (quarantined, or not fetched)"))
            continue
        if hits == 0:
            deferred.append((word, "DWDS counts no occurrences"))
            continue
        if word in SAME_STRING_HOMOGRAPHS:
            deferred.append((word, f"same-string homograph: DWDS count includes {SAME_STRING_HOMOGRAPHS[word]} "
                                   f"({hits:,} hits); no verb-only count exists"))
            continue
        if word in ruled:
            deferred.append((word, "has rows in auxiliary-rulings.tsv; add it by hand per its ruling"))
            continue
        result = auxiliary_screen.screen(lemmas.get(word), source)
        if result.flagged:
            deferred.append((word, "needs an auxiliary ruling: " + "; ".join(result.reasons)))
            proposals = auxiliary_screen.propose(lemmas[word], result, entry["markedInfinitiv"],
                                                 normalize_one_gloss)
            encoding = f"fa={entry['family']} ag=- in={entry['markedInfinitiv']} hits={hits}"
            proposed_lines.extend(auxiliary_screen.rulings_rows(
                word, result, proposals, encoding, datetime.date.today().isoformat()))
            continue
        importable.append({
            "word": word,
            "in": entry["markedInfinitiv"],
            "tn": translation,
            "fa": entry["family"],
            "ay": result.auxiliary,
            "ic": icon_for(translation),
            "hits": hits,
        })

    importable.sort(key=lambda row: (-row["hits"], row["word"]))
    if args.top is not None:
        chosen = importable[:args.top]
    elif args.min_hits is not None:
        chosen = [row for row in importable if row["hits"] >= args.min_hits]
    else:
        chosen = []

    reasons = collections.Counter(reason.split(":")[0] for _, reason in deferred)
    icons = collections.Counter(row["ic"] for row in importable)
    print(f"in scope: {len(scope)} bare weak and -ieren stems")
    for reason, count in outside.most_common():
        print(f"  outside scope {count:5}  {reason}")
    print(f"importable: {len(importable)}  (sein: {sum(r['ay'] == 's' for r in importable)})")
    for reason, count in reasons.most_common():
        print(f"  deferred {count:5}  {reason}")
    print(f"icons: {len(importable) - icons[DEFAULT_ICON]} matched by keyword, "
          f"{icons[DEFAULT_ICON]} fell back to {DEFAULT_ICON}")
    if importable:
        for label, n in (("top 100", 100), ("top 500", 500), ("top 1,000", 1000)):
            if len(importable) >= n:
                row = importable[n - 1]
                print(f"  {label:9} ends at {row['word']} ({row['hits']:,} hits, "
                      f"corpus rank {corpus_rank(row['hits'], shipping_hits):,} of "
                      f"{len(shipping_hits):,})")

    if args.check:
        RANKED.write_text(
            "# Importable tranche-3 verbs, most frequent first. Written by import_tranche3.py --check.\n"
            "# corpus_rank is where the verb would land among the verbs shipping today.\n"
            "rank\tverb\thits\tcorpus_rank\ttn\tfa\tay\tic\n"
            + "".join(f"{i}\t{r['word']}\t{r['hits']}\t{corpus_rank(r['hits'], shipping_hits)}\t"
                      f"{r['tn']}\t{r['fa']}\t{r['ay']}\t{r['ic']}\n"
                      for i, r in enumerate(importable, 1)))
        DEFERRED.write_text(
            "# Tranche-3 candidates NOT importable, and why. Recomputed on every --check.\n"
            "# verb\treason\n" + "".join(f"{w}\t{r}\n" for w, r in sorted(deferred)))
        print(f"wrote {RANKED.relative_to(REPO)} and {DEFERRED.relative_to(REPO)}")
        if proposed_lines:
            print(f"a real run would append {len(proposed_lines)} proposed rows to "
                  f"{RULINGS.relative_to(REPO)}")
        return 0

    # A real import. Same text surgery as import_tranche2.py: insert whole <verb> elements at
    # their sorted position, never round-trip the file through ElementTree.
    keys = [sort_key(v.get("in")) for v in root]
    if any(earlier > later for earlier, later in zip(keys, keys[1:])):
        print("Verbs.xml is not sorted under sort_key; refusing to insert", file=sys.stderr)
        return 1
    taken, adjusted = set(int(v.get("hi")) for v in root), 0
    lines = verbs_text.splitlines(keepends=True)
    verb_starts = [(i, sort_key(m.group(1))) for i, line in enumerate(lines)
                   if (m := re.match(r'\s*<verb in="([^"]+)"', line))]
    closing = next(i for i, line in enumerate(lines) if line.strip() == "</verbs>")
    insertions = []
    for row in chosen:
        hi = row["hits"]
        while hi in taken:
            hi -= 1
        adjusted += hi != row["hits"]
        taken.add(hi)
        tn = row["tn"].replace("&", "&amp;").replace('"', "&quot;").replace("<", "&lt;")
        ay = ' ay="s"' if row["ay"] == "s" else ""
        element = (f'  <verb in="{row["in"]}" hi="{hi}" ic="{row["ic"]}">\n'
                   f'    <reading tn="{tn}" fa="{row["fa"]}"{ay} />\n'
                   f"  </verb>\n")
        key = sort_key(row["in"])
        at = next((i for i, k in verb_starts if k > key), closing)
        insertions.append((at, key, element))
    # Back to front, keys descending, so earlier indices stay valid and verbs sharing an anchor
    # come out ascending. See import_tranche2.py for the same loop.
    for at, _, element in sorted(insertions, key=lambda t: (t[0], t[1]), reverse=True):
        lines.insert(at, element)
    VERBS_XML.write_text("".join(lines))
    append_proposed_rulings(proposed_lines)
    print(f"inserted {len(chosen)} verbs into {VERBS_XML.relative_to(REPO)} "
          f"({adjusted} counts lowered by a few hits to stay unique)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
