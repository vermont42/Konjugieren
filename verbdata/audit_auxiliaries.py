"""Auxiliary audit: compares each shipped reading's auxiliary with kaikki and with the rulings file.

Promoted from plans/fix-reference-defects-audit.py in Part 6 of plans/fix-reference-defects.md.

Consumes:
  * Konjugieren/Models/Verbs.xml
  * verbdata/auxiliary-rulings.tsv, one row per ruled reading (columns below)
  * the gitignored kaikki snapshot, verbdata/kaikki.org-dictionary-German-by-pos-verb.jsonl

Two modes, both run from the repository root:

  python3 verbdata/audit_auxiliaries.py [--unruled] > audit.tsv
      Report. A tab-separated table on stdout, one row per verb whose shipped auxiliary kaikki
      does not plainly confirm, with the verb's ruling outcome when it has one. --unruled prints
      only the verbs still awaiting a ruling, which is the Part 6 worklist. Summary on stderr.

  python3 verbdata/audit_auxiliaries.py --check
      Exits 1, listing every problem, when
        * a ruled verb's readings in Verbs.xml differ from its rows (count, auxiliary, gloss, or
          the reading's infinitive where the row states one),
        * a row is malformed (unknown outcome, no source, readings not numbered 0..n-1),
        * a verb the report lists has no ruling at all, or
        * a verb has `proposed` rows, which nobody has reviewed yet (see below).
      The third condition is what made --check the "done" test for Part 6: it fails until every
      listed verb is ruled, and the count it prints is how much remains. The fourth extends the
      same gate to imports.

Rulings-file columns: verb, reading, gloss, auxiliary (h or s), in, outcome, source, date, note.

The outcome `proposed` (added 2026-11-10, Part 6 "Stop the cause") marks rows that an importer
wrote and nobody has ruled on. verbdata/import_tranche2.py writes them through
verbdata/auxiliary_screen.py for every incoming verb the screen holds back, and does not put the
verb in Verbs.xml. So a proposed row is checked only for its shape: its verb is expected to be
absent from Verbs.xml, its auxiliary may be "?" when kaikki did not settle it, and the whole
verb is listed under "awaiting review" and fails --check, as an unruled listed verb does.
Ruling it means rewriting every row of the verb with a real outcome, a source, and a note, then
adding the verb to Verbs.xml by hand. A verb with any proposed row is treated as proposed whole,
because its readings are ruled together or not at all.
`in` is the reading's effective infinitive with its markup (the reading's own `in`, else the
verb's), and it may be left empty when it adds nothing. An absent `ay` in Verbs.xml means haben.

Facts about the kaikki data that this relies on, found by inspection on 2026-11-10:

* A record's auxiliary is a `forms` entry tagged "auxiliary" whose `form` is "haben", "sein",
  "haben or sein", or "sein or haben". Several such entries can sit on one record.
* A lemma can have several records (Wiktionary's Etymology 1, Etymology 2). The second record is
  where a homograph such as übersetzen keeps its other auxiliary, so every record must be read.
  verbdata/candidates.json keeps only the first and must not be used for this.
* Records whose senses are all `form_of` are inflected-form pages, not lemmas. Skip them.
* A sense's auxiliary, when Wiktionary states it, is written inside the gloss text itself, as
  "[auxiliary sein]" or "[auxiliary haben or sein]", in `raw_glosses` (falling back to `glosses`).
  Only about 130 shipping verbs have any such note, so it settles a minority of rows.
* A sense tagged "transitive" or "reflexive" takes haben. That inference is used only when the
  sense carries no note, and the row says so.

What the audit cannot see. It compares auxiliaries, so a verb whose two senses differ only in
family (anhängen, schaffen) or whose kaikki record is wrong for one homograph (übergehen) never
appears in the report. Such verbs are ruled by hand, and --check still verifies their rows.

Verbs that shipped two readings before Part 1 were audited by hand in July and are skipped unless
the rulings file has rows for them; once ruled, every reading is checked.
"""
import collections
import csv
import json
import re
import sys
import xml.etree.ElementTree as ET

SNAPSHOT = "verbdata/kaikki.org-dictionary-German-by-pos-verb.jsonl"
VERBS = "Konjugieren/Models/Verbs.xml"
RULINGS = "verbdata/auxiliary-rulings.tsv"
OUTCOMES = {"two readings", "flip", "flip and re-gloss", "re-gloss", "keep"}
PROPOSED = "proposed"


def letters(text):
    """{'h'}, {'s'}, or both, from a string such as 'haben or sein'."""
    found = set()
    if "haben" in text:
        found.add("h")
    if "sein" in text:
        found.add("s")
    return found


def bare(marked):
    """An infinitive without the separability and ablaut markup of Verbs.xml."""
    return re.sub(r"[+*^]", "", marked)


def load_shipping():
    """infinitive -> (hits, [{'ay', 'tn', 'in'}, ...]). An absent `ay` means haben; 'r' is regional."""
    shipping = {}
    for verb in ET.parse(VERBS).getroot().findall("verb"):
        readings = [{"ay": r.get("ay") or "h", "tn": r.get("tn"), "in": r.get("in") or verb.get("in")}
                    for r in verb.findall("reading")]
        shipping[bare(verb.get("in"))] = (int(verb.get("hi")), readings)
    return shipping


def load_rulings():
    """verb -> list of rows in file order. Each row is a dict keyed by the header's column names."""
    rulings = collections.defaultdict(list)
    with open(RULINGS, newline="") as handle:
        for row in csv.DictReader(handle, delimiter="\t", quoting=csv.QUOTE_NONE):
            rulings[row["verb"]].append(row)
    return rulings


def load_kaikki(shipping):
    lemma_aux = collections.defaultdict(set)
    senses = collections.defaultdict(list)
    with open(SNAPSHOT) as snapshot:
        for line in snapshot:
            record = json.loads(line)
            word = record.get("word", "")
            if word not in shipping or any(s.get("form_of") for s in record.get("senses", [])):
                continue
            for form in record.get("forms", []):
                if "auxiliary" in form.get("tags", []):
                    lemma_aux[word] |= letters(form.get("form", ""))
            for sense in record.get("senses", []):
                gloss = (sense.get("raw_glosses") or sense.get("glosses") or [""])[0]
                note = re.search(r"\[auxiliary ([^\]]+)\]", gloss)
                senses[word].append({
                    "gloss": gloss,
                    "note": letters(note.group(1)) if note else None,
                    "tags": set(sense.get("tags", [])),
                })
    return lemma_aux, senses


def plain(gloss):
    """A kaikki gloss without its auxiliary note and its leading label, lowercased."""
    gloss = re.sub(r"\[auxiliary[^\]]*\]", "", gloss).strip()
    return re.sub(r"^\([^)]*\)\s*", "", gloss).lower()


def matching_sense(shipped_gloss, verb_senses):
    """The first kaikki sense that one of the shipped gloss's alternatives appears in.

    Whole-phrase matches are tried before substring matches, because "move" must not be claimed
    by "remove" when a later sense says "to move".
    """
    alternatives = [a.strip().lower() for a in re.split(r"[,;]", re.sub(r"\([^)]*\)", "", shipped_gloss)) if a.strip()]
    for sense in verb_senses:
        parts = [re.sub(r"^to ", "", p.strip()) for p in re.split(r"[,;]", plain(sense["gloss"]))]
        if any(a == p or p.startswith(a + " ") for a in alternatives for p in parts):
            return sense
    for sense in verb_senses:
        if any(a in plain(sense["gloss"]) for a in alternatives):
            return sense
    return None


def verdict_for(reading, known, verb_senses):
    """(verdict, evidence) for one reading, against the lemma's auxiliaries and its senses."""
    if len(known) == 1:
        if reading["ay"] in known:
            return "agrees (lemma)", ""
        return "CONTRADICTS (lemma)", "kaikki lists only " + "".join(sorted(known))
    sense = matching_sense(reading["tn"], verb_senses)
    if sense is None:
        return "needs ruling: no sense matched", ""
    note, how = sense["note"], "note"
    if note is None and sense["tags"] & {"transitive", "reflexive"}:
        note, how = {"h"}, "tag"
    evidence = sense["gloss"][:140]
    if note is None:
        return "needs ruling: sense has no note", evidence
    if len(note) == 2:
        return "sense allows both", evidence
    if reading["ay"] in note:
        return "agrees (" + how + ")", evidence
    return "CONTRADICTS (" + how + ")", evidence


def audit(shipping, rulings):
    """Rows for the report, one per listed reading: (rank, verb, index, ay, gloss, verdict, evidence, outcome)."""
    lemma_aux, senses = load_kaikki(shipping)
    rank = {v: i + 1 for i, (v, _) in enumerate(sorted(shipping.items(), key=lambda kv: -kv[1][0]))}
    rows = []
    for verb, (_, readings) in shipping.items():
        known = lemma_aux.get(verb)
        if not known:
            continue
        ruled = verb in rulings
        outcome = "; ".join(sorted({row["outcome"] for row in rulings.get(verb, [])}))
        if any(r["ay"] == "r" for r in readings):
            rows.append((rank[verb], verb, 0, "r", readings[0]["tn"], "regional", "", outcome))
            continue
        if len(readings) > 1 and not ruled:
            continue  # pre-Part-1 multi-reading verb, audited by hand in July
        listed = []
        for index, reading in enumerate(readings):
            verdict, evidence = verdict_for(reading, known, senses[verb])
            listed.append((rank[verb], verb, index, reading["ay"], reading["tn"], verdict, evidence, outcome))
        # A single-auxiliary lemma that agrees with every reading needs nothing, as in the prototype.
        if all(row[5] == "agrees (lemma)" for row in listed):
            continue
        rows.extend(listed)
    return sorted(rows)


def check(shipping, rulings, rows):
    """(problems, unruled, proposed). Every entry of unruled and proposed is also a problem."""
    problems = []
    proposed = []
    for verb, verb_rows in rulings.items():
        if any(row["outcome"] == PROPOSED for row in verb_rows):
            proposed.append(verb)
            indices = [int(row["reading"]) for row in verb_rows]
            if indices != list(range(len(verb_rows))):
                problems.append(f"{verb}: rows number their readings {indices}, not 0..{len(verb_rows) - 1}")
            for row in verb_rows:
                if row["outcome"] != PROPOSED:
                    problems.append(f"{verb} reading {row['reading']}: ruled beside proposed rows; "
                                    f"rule the verb's readings together")
                if row["auxiliary"] not in {"h", "s", "?"}:
                    problems.append(f"{verb} reading {row['reading']}: auxiliary {row['auxiliary']!r} "
                                    f"is not h, s, or ?")
            problems.append(f"{verb}: proposed by an importer, awaiting review")
            continue
        if verb not in shipping:
            problems.append(f"{verb}: ruled but not in Verbs.xml")
            continue
        readings = shipping[verb][1]
        indices = [int(row["reading"]) for row in verb_rows]
        if indices != list(range(len(verb_rows))):
            problems.append(f"{verb}: rows number their readings {indices}, not 0..{len(verb_rows) - 1}")
        if len(verb_rows) != len(readings):
            problems.append(f"{verb}: {len(verb_rows)} ruled readings, {len(readings)} in Verbs.xml")
        for row in verb_rows:
            where = f"{verb} reading {row['reading']}"
            if row["outcome"] not in OUTCOMES:
                problems.append(f"{where}: unknown outcome {row['outcome']!r}")
            if not row["source"].strip():
                problems.append(f"{where}: no source")
            if row["auxiliary"] not in {"h", "s"}:
                problems.append(f"{where}: auxiliary {row['auxiliary']!r} is not h or s")
            index = int(row["reading"])
            if index >= len(readings):
                continue
            shipped = readings[index]
            if shipped["ay"] != row["auxiliary"]:
                problems.append(f"{where}: ships {shipped['ay']}, ruled {row['auxiliary']}")
            if shipped["tn"] != row["gloss"]:
                problems.append(f"{where}: ships gloss {shipped['tn']!r}, ruled {row['gloss']!r}")
            if row["in"] and shipped["in"] != row["in"]:
                problems.append(f"{where}: ships in {shipped['in']!r}, ruled {row['in']!r}")
    unruled = sorted({row[1] for row in rows if row[1] not in rulings and row[5] != "regional"})
    for verb in unruled:
        problems.append(f"{verb}: listed by the audit, no ruling")
    return problems, unruled, proposed


def main():
    args = set(sys.argv[1:])
    unknown = args - {"--check", "--unruled"}
    if unknown:
        sys.exit(f"unknown arguments: {' '.join(sorted(unknown))}")
    shipping = load_shipping()
    rulings = load_rulings()
    rows = audit(shipping, rulings)
    if "--check" in args:
        problems, unruled, proposed = check(shipping, rulings, rows)
        for problem in problems:
            print(problem)
        ruled_listed = len({row[1] for row in rows if row[1] in rulings})
        print(f"{len(rulings) - len(proposed)} verbs ruled ({ruled_listed} of them listed by the audit), "
              f"{len(unruled)} listed verbs await a ruling, "
              f"{len(proposed)} proposed verbs await review, "
              f"{len(problems) - len(unruled) - len(proposed)} other problems", file=sys.stderr)
        sys.exit(1 if problems else 0)
    if "--unruled" in args:
        rows = [row for row in rows if row[1] not in rulings and row[5] != "regional"]
    print("rank\tverb\treading\tshipped\tgloss\tverdict\tkaikki evidence\truling")
    for row in rows:
        print("\t".join(str(cell) for cell in row))
    verdicts = collections.Counter(row[5] for row in rows if row[2] == 0 and not row[7])
    for verdict, count in sorted(verdicts.items()):
        print(f"{count:4d}  {verdict}  (unruled, by first reading)", file=sys.stderr)
    print(f"{len({row[1] for row in rows if row[7]}):4d}  ruled", file=sys.stderr)


if __name__ == "__main__":
    main()
