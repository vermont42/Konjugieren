"""Auxiliary screen: decides whether an incoming verb's auxiliary can be imported without a human.

Written 2026-11-10 for Part 6, "Stop the cause", of plans/fix-reference-defects.md. Imported by
verbdata/import_tranche2.py, and meant to be imported, not copied, by whatever script imports
tranche 3 (docs/roadmap.md step 9). It has no command line of its own; run the importer's
`--check --screen VERB,...` to exercise it on named verbs.

Consumes the gitignored kaikki snapshot, verbdata/kaikki.org-dictionary-German-by-pos-verb.jsonl,
read directly rather than through verbdata/candidates.json. That choice is the heart of the fix,
so the reason comes first.

WHAT WENT WRONG IN TRANCHE 2
----------------------------
The tranche-2 importer took a verb's gloss from one place and its auxiliary from another, and
nothing tied them together:

  * the gloss came from the first kaikki sense that normalized into something short;
  * the auxiliary came from the lemma-level `auxiliary` forms of the FIRST kaikki record, which
    is the only record candidates.json keeps (build_candidates.py drops later Etymology
    sections unless run with --all-records).

So aufstehen shipped "get up" with haben, and Parts 1 and 6 of the defect plan spent 252 rulings
undoing that habit. Four shipped verbs show the four ways it failed, and each is a test case for
this module (see the importer's --screen):

  zuziehen     kaikki's lemma says haben only, because most senses are transitive or reflexive
               (sich etwas zuziehen). The importer took the gloss from sense 1, intransitive "move
               here", which takes sein. No sense carries an auxiliary note; only the sense's
               `intransitive` tag and the meaning of its gloss betray it.
  durchlaufen  kaikki has two records: separable durch|laufen with sein, and inseparable
               durchlaufen with haben. candidates.json kept only the first, so the importer never
               knew a second verb existed, and the shipped verb mixed one verb's separability with
               the other's gloss.
  abschieben   kaikki marks the lemma "sein or haben". The importer shipped kaikki's first-listed
               auxiliary, sein, for "deport", which is transitive and takes haben.
  bleichen     One record whose headword template offers two paradigms: weak with haben
               ("bleach") and strong with sein ("fade", geblichen). That is two verbs under one
               spelling, the anhängen shape, and it needs a split by family, not by auxiliary.

THE RULE THIS MODULE IMPLEMENTS
-------------------------------
An auxiliary is taken from the same kaikki sense as the gloss. When that sense says nothing, the
lemma's auxiliary is used only if the lemma names exactly one and nothing in kaikki contradicts
it. Everything else is FLAGGED, and a flagged verb is not imported. It goes to
verbdata/auxiliary-rulings.tsv as rows with the outcome `proposed`, one per reading the senses
suggest, and `python3 verbdata/audit_auxiliaries.py --check` fails while any proposed row remains.
Ruling a proposed row means rewriting it with a real outcome, a source, and a note, exactly as
Part 6 did, and then adding the verb to Verbs.xml by hand with the readings the ruling chose.

Why the importer does not write the second readings into Verbs.xml itself: the readings need
glosses that tell them apart, and prompts/multi_reading_glosses.md records that a reviewer who
reads one gloss at a time misses swapped pairs. An importer that wrote readings straight into
Verbs.xml would skip the gloss review in prompts/gloss_review.md. The proposed rows are a
starting point for that review, not a substitute for it.

THE FLAGS, AND WHAT IN KAIKKI EACH ONE READS
--------------------------------------------
  dual auxiliary       The union of every record's auxiliary forms holds both haben and sein.
                       This is what tranche 2 already detected, except that it read one record.
  separability         One record's headword spec is separable (a "." splits it: `durch.laufen`)
                       and another is not (`durchlaufen<durchläuft#...>`). Catches durchlaufen,
                       umlaufen, durchdringen, übersetzen, and every stress homograph.
  family split         Two records disagree about strong and weak (schleifen, schwellen), or one
                       record's spec offers two paradigms that differ in family AND auxiliary
                       (bleichen). A dual paradigm with one auxiliary (triefen, sieden) is NOT
                       flagged: that is one meaning with two form sets, wrinkle 1 of
                       docs/verb-sources.md, and not a ruling about meaning.
  sense contradicts    The gloss's own sense contradicts the lemma's single auxiliary: an explicit
  lemma                "[auxiliary sein]" note under a haben lemma (or the reverse); a sense tagged
                       intransitive whose English gloss is a verb of motion or change of state
                       under a haben-only lemma (zuziehen); or a sense tagged transitive under a
                       sein-only lemma.

The flags overlap, and a verb carries every reason that applies. That is deliberate: the note in
the proposed row is all the reviewer starts from.

FACTS ABOUT THE KAIKKI DATA THIS RELIES ON (found by inspection on 2026-11-10)
------------------------------------------------------------------------------
* A record whose senses are all `form_of` is an inflected-form page, not a lemma. Skip it.
* A lemma can have several records, one per Wiktionary Etymology section. Read them all.
* The auxiliary forms are `forms` entries tagged "auxiliary", valued "haben", "sein",
  "haben or sein", or "sein or haben". A record may repeat them.
* A sense's own auxiliary, when stated, sits inside its gloss text as "[auxiliary sein]". It is
  in `raw_glosses` (678 senses) and almost never in `glosses` (17). Read `raw_glosses` first.
* The `de-verb` head template's first argument is the paradigm spec. A "." before the "<" marks
  the separable split (`zu.ziehen<zog,gezogen,zöge>`). Inside the angle brackets, a "," between
  past forms marks a strong or irregular paradigm, and "haben"/"sein" after a "." name the
  auxiliary; with neither named, Wiktionary's default is haben. Two paradigms on one page are
  written `((spec1,spec2))`, with commas inside the brackets, so split only at depth zero.
  Qualifiers are wrapped in the private-use characters U+10203F and U+102040.
* The record's `class` form ("7 strong") and `table-tags` form ("strong", "weak",
  "strong weak") name the family. A lemma kaikki tags "strong weak" is usually a dual paradigm.
"""

import collections
import json
import pathlib
import re
from dataclasses import dataclass, field

REPO = pathlib.Path(__file__).resolve().parent.parent
SNAPSHOT = REPO / "verbdata" / "kaikki.org-dictionary-German-by-pos-verb.jsonl"

# English head verbs that, glossing an INTRANSITIVE German sense, name a change of place or of
# state. German forms the Perfekt of exactly those with sein, which is the rule zuziehen's
# "move here" broke. The list is a screen, not a grammar: a hit sends the verb to a human, and a
# miss falls back to the lemma's auxiliary, which is what tranche 2 did for every verb. So it
# leans toward recall. Verbs whose intransitive use is usually a state or an activity in German
# (burn, float, hang, stand, sit, lie, live, work, sleep) are left out, because their German
# counterparts mostly take haben and would bury the real hits.
SEIN_HEADS = {
    "arise", "arrive", "ascend", "become", "burst", "climb", "collapse", "collide", "come",
    "crash", "decay", "depart", "descend", "die", "disappear", "dive", "drift", "drive", "drop",
    "dry", "emerge", "enter", "escape", "evaporate", "fade", "fail", "fall", "flee", "flow",
    "fly", "freeze", "get", "glide", "go", "grow", "happen", "hurry", "jump", "land", "leave",
    "march", "melt", "migrate", "move", "occur", "pass", "proceed", "race", "remain", "return",
    "ride", "rise", "roll", "rot", "run", "rush", "sail", "settle", "shrink", "sink", "slide",
    "slip", "spring", "stay", "step", "stumble", "succeed", "swim", "swell", "travel", "turn",
    "vanish", "walk", "wander", "wither",
}

AUXILIARY_NOTE = re.compile(r"\[auxiliary ([^\]]+)\]")
WORD_VALUE = re.compile(r'"word": "([^"]*)"')


def letters(text):
    """{'h'}, {'s'}, or both, from a string such as 'haben or sein'. Same as the audit's."""
    found = set()
    if "haben" in text:
        found.add("h")
    if "sein" in text:
        found.add("s")
    return found


@dataclass
class Paradigm:
    """One paradigm spec from a `de-verb` head template."""
    separable: bool
    family: str  # "strong" or "weak", as far as the spec shows it
    auxiliaries: set


@dataclass
class Sense:
    record: int
    index: int
    gloss: str  # plain glosses[0], which is what candidates.json, and so the normalizer, sees
    raw: str  # raw_glosses[0], which carries the labels and the auxiliary note
    note: set | None  # the auxiliaries an "[auxiliary ...]" note names, or None
    tags: set


@dataclass
class Record:
    auxiliaries: set
    family: str | None  # "strong", "weak", or None when the tags name both or neither
    paradigms: list
    senses: list


@dataclass
class Lemma:
    word: str
    records: list = field(default_factory=list)

    @property
    def auxiliaries(self):
        return set().union(*(r.auxiliaries for r in self.records)) if self.records else set()

    @property
    def senses(self):
        return [s for r in self.records for s in r.senses]


def split_alternatives(spec):
    """`((a<x,y>,b))` -> ['a<x,y>', 'b']; a plain spec -> [spec]. Splits only at depth zero."""
    if not spec.startswith("(("):
        return [spec]
    inner, parts, depth, current = spec[2:].removesuffix("))"), [], 0, ""
    for char in inner:
        if char == "<":
            depth += 1
        elif char == ">":
            depth -= 1
        if char == "," and depth == 0:
            parts.append(current)
            current = ""
        else:
            current += char
    parts.append(current)
    # An empty alternative (`((,liken<...>))`) means "the default paradigm", which is weak.
    return [part.strip() for part in parts]


def parse_paradigm(spec):
    """Read separability, family, and auxiliary off one paradigm spec. See the module header."""
    # Drop qualifiers first: "<rare>" is wrapped in private-use characters and would otherwise
    # look like a nested argument list.
    spec = re.sub("\U0010203f[^\U00102040]*\U00102040", "", spec)
    head, _, body = spec.partition("<")
    body = body.rsplit(">", 1)[0]
    # The body is "present#past,participle,subjunctive.aux,aux" with every part optional and
    # "."-separated. Removing a qualifier can leave an empty part behind ("geblichen.sein." from
    # "geblichen.sein.<rare>"), which first hid bleichen's sein when only the last part was read.
    # So classify every part: one made only of haben/sein names the auxiliaries, and the others
    # are forms or flags (einfix).
    parts = [part for part in body.split(".") if part]
    auxiliary_parts = [part for part in parts if set(part.split(",")) <= {"haben", "sein"}]
    auxiliaries = set().union(*(letters(part) for part in auxiliary_parts)) or {"h"}
    # Strong means a participle in -n (gezogen, getan), read from the "past,participle" part.
    # A comma alone is not enough: liken spells out weak forms too (likete,geliked).
    strong = False
    for part in parts:
        if part in auxiliary_parts or "," not in part:
            continue
        participle = part.split(",")[1].split(":")[0]
        strong = participle.endswith("n")
    return Paradigm(separable="." in head, family="strong" if strong else "weak", auxiliaries=auxiliaries)


def record_family(record):
    """'strong' or 'weak' from a record's class and table-tags forms; None if both or neither."""
    tags = set()
    for form in record.get("forms", []):
        if {"class", "table-tags"} & set(form.get("tags", [])):
            tags.update(form.get("form", "").split())
    if "strong" in tags and "weak" not in tags:
        return "strong"
    if "weak" in tags and "strong" not in tags:
        return "weak"
    return None


def load(words=None):
    """word -> Lemma, for `words` (any iterable) or for every lemma when None. Reads the snapshot once.

    Takes about half a minute over the 294 MB file. The cheap substring test before json.loads
    is only a prefilter; the parsed `word` is what decides.
    """
    wanted = set(words) if words is not None else None
    lemmas = {}
    with SNAPSHOT.open() as snapshot:
        for line in snapshot:
            if wanted is not None and not _probe(line, wanted):
                continue
            record = json.loads(line)
            word = record.get("word", "")
            if wanted is not None and word not in wanted:
                continue
            if any(sense.get("form_of") for sense in record.get("senses", [])):
                continue
            lemma = lemmas.setdefault(word, Lemma(word))
            number = len(lemma.records)
            auxiliaries = set()
            for form in record.get("forms", []):
                if "auxiliary" in form.get("tags", []):
                    auxiliaries |= letters(form.get("form", ""))
            paradigms = []
            for template in record.get("head_templates", []):
                if template.get("name") == "de-verb":
                    spec = (template.get("args") or {}).get("1", "")
                    # A bare template with no spec is the default weak, inseparable paradigm.
                    paradigms.extend(parse_paradigm(alt) if alt else Paradigm(False, "weak", {"h"})
                                     for alt in split_alternatives(spec or word))
            senses = []
            for index, sense in enumerate(record.get("senses", [])):
                raw = (sense.get("raw_glosses") or sense.get("glosses") or [""])[0]
                note = AUXILIARY_NOTE.search(raw)
                senses.append(Sense(record=number, index=index,
                                    gloss=(sense.get("glosses") or [""])[0], raw=raw,
                                    note=letters(note.group(1)) if note else None,
                                    tags=set(sense.get("tags", []))))
            lemma.records.append(Record(auxiliaries=auxiliaries, family=record_family(record),
                                        paradigms=paradigms, senses=senses))
    return lemmas


def _probe(line, wanted):
    """True if any `"word": "..."` value on this line is wanted, found without parsing the JSON.

    Every `"word"` value is tested, not only the first, because nested lists (`derived`,
    `related`) carry `"word"` keys of their own and the top-level one is not guaranteed to come
    first. A false positive costs one json.loads; the caller re-checks the parsed `word`. Testing
    set membership this way is far cheaper than a substring test per wanted word, which matters
    when the importer asks for a few thousand words.
    """
    return any(value in wanted for value in WORD_VALUE.findall(line))


def head_verb(gloss):
    """The first English word of a gloss after "to" and any leading label: 'move' for '(x) to move here'."""
    text = re.sub(r"^\s*\([^)]*\)\s*", "", gloss).lower()
    text = re.sub(r"^to\s+", "", text.strip())
    match = re.match(r"[a-z]+", text)
    return match.group(0) if match else ""


def sense_auxiliary(sense, record):
    """(auxiliary, how) for one sense: 'h', 's', or '?' when nothing settles it.

    Same order of evidence as verbdata/audit_auxiliaries.py, so the two tools agree: the sense's
    own note first, then a transitive or reflexive tag (which takes haben). Then one step the
    audit does not take: an intransitive sense of motion or change takes sein. Last, the
    record's auxiliary if it names exactly one.
    """
    if sense.note and len(sense.note) == 1:
        return next(iter(sense.note)), "note"
    if sense.note:
        return "?", "note allows both"
    if sense.tags & {"transitive", "reflexive"} and "intransitive" not in sense.tags:
        return "h", "tag"
    # The zuziehen inference, the same one screen() flags on. It outranks the record's auxiliary
    # because it is about this sense, and the record's is about the lemma as a whole.
    if ("intransitive" in sense.tags and "transitive" not in sense.tags
            and head_verb(sense.raw) in SEIN_HEADS):
        return "s", f"inference (intransitive '{head_verb(sense.raw)}')"
    if len(record.auxiliaries) == 1:
        return next(iter(record.auxiliaries)), "record"
    return "?", "unsettled"


@dataclass
class Screen:
    word: str
    auxiliary: str | None  # 'h' or 's' when importable; None when flagged
    source: Sense | None  # the sense the gloss came from, when it could be found
    reasons: list

    @property
    def flagged(self):
        return bool(self.reasons)


def find_source(lemma, gloss):
    """The sense whose plain gloss the normalizer used, preferring the first record."""
    if gloss is None:
        return None
    for sense in lemma.senses:
        if sense.gloss == gloss:
            return sense
    return None


def screen(lemma, source_gloss):
    """Decide one verb. `source_gloss` is the kaikki gloss the translation was normalized from.

    `source_gloss` is None for a hand-written translation (import_tranche2.HAND_TRANSLATIONS),
    and then only the lemma-level flags can fire.
    """
    if lemma is None or not lemma.records:
        return Screen(word="", auxiliary=None, source=None,
                      reasons=["no lemma record in the kaikki snapshot"])
    reasons = []
    known = lemma.auxiliaries

    if known == {"h", "s"}:
        reasons.append("dual auxiliary: kaikki gives both haben and sein")

    paradigms = [p for r in lemma.records for p in r.paradigms]
    if {p.separable for p in paradigms} == {True, False}:
        reasons.append("separability: kaikki has a separable and an inseparable verb under this spelling")

    # Two records that each name one family and disagree are two verbs (schaffen, schleifen,
    # schwellen), whatever their auxiliaries. Two paradigms are two verbs only if they also
    # differ in auxiliary (bleichen inside one record, erlöschen across two); otherwise they are
    # one verb with a dual paradigm (sieden, triefen), which is not this flag's business.
    families = {r.family for r in lemma.records if r.family}
    paradigm_split = any(
        a.family != b.family and a.auxiliaries != b.auxiliaries
        for i, a in enumerate(paradigms) for b in paradigms[i + 1:]
    )
    if families == {"strong", "weak"} or paradigm_split:
        reasons.append("family split: a strong and a weak verb under this spelling")

    source = find_source(lemma, source_gloss)
    if source is not None and len(known) == 1:
        lemma_auxiliary = next(iter(known))
        if source.note and len(source.note) == 1 and source.note != known:
            reasons.append(f"sense contradicts lemma: the gloss's sense notes "
                           f"{'sein' if 's' in source.note else 'haben'}, the lemma "
                           f"{'sein' if lemma_auxiliary == 's' else 'haben'}")
        elif (lemma_auxiliary == "h" and "intransitive" in source.tags
              and not source.tags & {"transitive", "reflexive"}
              and head_verb(source.raw) in SEIN_HEADS):
            reasons.append(f"sense contradicts lemma: an intransitive sense of motion or change "
                           f"('{head_verb(source.raw)}') under a haben-only lemma")
        elif (lemma_auxiliary == "s" and "transitive" in source.tags
              and "intransitive" not in source.tags):
            reasons.append("sense contradicts lemma: a transitive sense under a sein-only lemma")

    if reasons:
        return Screen(lemma.word, None, source, reasons)
    if source is not None and source.note and len(source.note) == 1:
        return Screen(lemma.word, next(iter(source.note)), source, [])
    return Screen(lemma.word, next(iter(known)) if len(known) == 1 else "h", source, [])


def swap_head_marker(marked):
    """'durch+laufen' -> 'durch*laufen' and back: the outermost prefix's separability flipped."""
    match = re.match(r"^([^+*]+)([+*])", marked)
    if not match:
        return marked
    flipped = "*" if match.group(2) == "+" else "+"
    return match.group(1) + flipped + marked[match.end():]


def propose(lemma, result, marked, normalize):
    """Readings the senses suggest for a flagged verb: [(gloss, auxiliary, in, evidence)].

    Groups every sense of every record by (auxiliary, separability, family), the three things
    the plan's "Second Readings" splits on, and proposes one reading per group, glossed from the
    group's first sense that `normalize` can shorten. The group holding the gloss the importer
    would have shipped comes first. `normalize` is the importer's normalize_one_gloss, passed in
    to keep this module free of a circular import.

    Labelled senses (archaic, regional, technical) are proposed too, with the label kept in the
    evidence, because criterion 2 of "Second Readings" is a judgment for the reviewer. Expect
    to delete proposals; the point is that nothing kaikki knows is hidden from the ruling.
    """
    groups = collections.OrderedDict()
    senses = lemma.senses
    if result.source is not None:
        senses = [result.source] + [s for s in senses if s is not result.source]
    for sense in senses:
        record = lemma.records[sense.record]
        auxiliary, how = sense_auxiliary(sense, record)
        paradigm = record.paradigms[0] if record.paradigms else Paradigm(False, record.family or "weak", record.auxiliaries)
        family = record.family or paradigm.family
        # Inside a two-paradigm record (bleichen), the sense belongs to the paradigm whose
        # auxiliary it takes: "fade" with sein is the strong one.
        for candidate in record.paradigms:
            if auxiliary in candidate.auxiliaries and len(candidate.auxiliaries) == 1:
                paradigm, family = candidate, candidate.family
                break
        key = (auxiliary, paradigm.separable, family)
        if key in groups:
            continue
        gloss = normalize(sense.gloss) if sense.gloss else None
        if not gloss:
            continue
        label = re.match(r"^\s*(\([^)]*\))", sense.raw)
        evidence = (f"record {sense.record + 1} sense {sense.index + 1}, auxiliary from {how}"
                    + (f", labelled {label.group(1)}" if label else "")
                    + f", family {family}, {'separable' if paradigm.separable else 'not separable'}")
        reading_in = ""
        marked_separable = bool(re.match(r"^[^+*]+\+", marked))
        if ("+" in marked or "*" in marked) and paradigm.separable != marked_separable:
            reading_in = swap_head_marker(marked)
        groups[key] = (gloss, auxiliary, reading_in, evidence)
    return list(groups.values())


def rulings_rows(word, result, proposals, encoding, date):
    """TSV lines for verbdata/auxiliary-rulings.tsv, outcome `proposed`, in the file's column order.

    The file is read with csv.QUOTE_NONE, so a tab or newline in any cell would corrupt it.
    """
    def clean(text):
        return re.sub(r"[\t\n\r]+", " ", text).strip()

    rows = []
    for index, (gloss, auxiliary, reading_in, evidence) in enumerate(proposals):
        note = (f"PROPOSED by the importer, unreviewed. Flagged: {'; '.join(result.reasons)}. "
                f"This reading: {evidence}. Classifier encoding: {encoding}.")
        rows.append("\t".join(clean(cell) for cell in (
            word, str(index), gloss, auxiliary, reading_in, "proposed",
            "kaikki, via verbdata/import_tranche2.py (unreviewed)", date, note)))
    return rows
