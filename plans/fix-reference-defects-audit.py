"""Prototype of the auxiliary audit described in plans/fix-reference-defects.md, Parts 1 and 6.

Consumes: Konjugieren/Models/Verbs.xml and the gitignored kaikki snapshot in verbdata/.
Produces: a tab-separated table on stdout, one row per verb whose shipped auxiliary kaikki does
not plainly confirm, and a summary on stderr.
Run from the repository root: python3 plans/fix-reference-defects-audit.py > audit.tsv

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
"""
import collections
import json
import re
import sys
import xml.etree.ElementTree as ET

SNAPSHOT = "verbdata/kaikki.org-dictionary-German-by-pos-verb.jsonl"


def letters(text):
    """{'h'}, {'s'}, or both, from a string such as 'haben or sein'."""
    found = set()
    if "haben" in text:
        found.add("h")
    if "sein" in text:
        found.add("s")
    return found


def load_shipping():
    """infinitive -> (hits, [(ay, gloss), ...]). An absent `ay` means haben; 'r' is regional."""
    shipping = {}
    for verb in ET.parse("Konjugieren/Models/Verbs.xml").getroot().findall("verb"):
        infinitive = re.sub(r"[+*^]", "", verb.get("in"))
        readings = [(r.get("ay") or "h", r.get("tn")) for r in verb.findall("reading")]
        shipping[infinitive] = (int(verb.get("hi")), readings)
    return shipping


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


def main():
    shipping = load_shipping()
    lemma_aux, senses = load_kaikki(shipping)
    rank = {v: i + 1 for i, (v, _) in enumerate(sorted(shipping.items(), key=lambda kv: -kv[1][0]))}
    verdicts = collections.Counter()
    rows = []
    for verb, (_, readings) in shipping.items():
        known = lemma_aux.get(verb)
        if not known:
            continue
        shipped = {ay for ay, _ in readings}
        ay, gloss = readings[0]
        if "r" in shipped:
            verdict, evidence = "regional", ""
        elif len(known) == 1:
            if known & shipped:
                continue  # kaikki names one auxiliary and the app ships it
            verdict, evidence = "CONTRADICTS (lemma)", "kaikki lists only " + "".join(known)
        elif len(readings) > 1:
            # Already modelled as readings, and audited by hand in July. The plan's Part 6
            # adds readings of its own, so the promoted script must stop skipping here and
            # check each reading against verbdata/auxiliary-rulings.tsv instead.
            continue
        else:
            sense = matching_sense(gloss, senses[verb])
            if sense is None:
                verdict, evidence = "needs ruling: no sense matched", ""
            else:
                note, how = sense["note"], "note"
                if note is None and sense["tags"] & {"transitive", "reflexive"}:
                    note, how = {"h"}, "tag"
                evidence = sense["gloss"][:140]
                if note is None:
                    verdict = "needs ruling: sense has no note"
                elif len(note) == 2:
                    verdict = "sense allows both"
                elif ay in note:
                    verdict = "agrees (" + how + ")"
                else:
                    verdict = "CONTRADICTS (" + how + ")"
        verdicts[verdict] += 1
        rows.append((rank[verb], verb, ay, gloss, verdict, evidence))
    print("rank\tverb\tshipped\tgloss\tverdict\tkaikki evidence")
    for row in sorted(rows):
        print("\t".join(str(cell) for cell in row))
    for verdict, count in sorted(verdicts.items()):
        print(f"{count:4d}  {verdict}", file=sys.stderr)


if __name__ == "__main__":
    main()
