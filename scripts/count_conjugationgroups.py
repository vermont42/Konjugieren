#!/usr/bin/env python3
# Copyright © 2026 Josh Adams. All rights reserved.
"""Count how often each conjugationgroup occurs in a sample of the text corpus.

The verb page orders its simple conjugationgroups, and then its compound ones, by these counts
(Phase 7 of plans/browse-and-verb-implementation.md). docs/conjugationgroup-frequency.md gives
the method and the results, and should be updated if this script changes.

Consumes
  * The German texts in corpus/modern, corpus/government, corpus/government2, and
    corpus/technology. The English translations (*-en.txt) are skipped. The texts are
    gitignored; corpus/README.md says where they came from.
  * A cells table: every one-word conjugation of every verb in the app, with the
    conjugationgroup it belongs to and its verb's Perfekt auxiliary. ConjugationMapTool writes
    it with --cells-json (ConjugationMapTool/CellsJSON.swift), so the counter and the app agree
    on what a conjugation is. Without --cells, this script builds the tool and runs it.

Produces
  A table on stdout, and with --json a machine-readable copy of every count.

Run
  python3 scripts/count_conjugationgroups.py [--cells cells.json] [--json out.json]
                                             [--examples GROUP]

  --examples prints a sample of the words counted under one group (for instance
  plusquamperfektKonjunktivII), which is how the stoplist below was found.

The method, in brief (the doc has the reasoning):
  1. Clean each text: drop Project Gutenberg boilerplate, split the Bundestag protocols' two
     columns, and rejoin words hyphenated across a line break.
  2. Split into sentences and clauses at punctuation. Keep only words a reader would take for a
     verb: lowercase, or capitalized at the start of a sentence. German capitalizes nouns, so a
     capitalized word mid-sentence (die Weise, das Leben) is never a verb.
  3. Within a clause, pair each form of haben, sein, or werden with a participle or infinitive
     to find the compound conjugationgroups. A pairing counts only if the participle's verb
     takes that auxiliary, which separates "ist gegangen" (Perfekt) from "ist gemacht"
     (Zustandspassiv). Passives and Futur II are counted apart, since the page shows neither.
  4. Count every remaining verb word under its simple conjugationgroup. Where a spelling
     belongs to two (meine is Präsens Indikativ and Konjunktiv I), rules below decide, and the
     default is the indicative.

Every number this produces is an estimate. The rules err in known directions, which the doc
lists, and none of those errors is large enough to change the order of the top of each block.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter, defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
FOLDERS = ["modern", "government", "government2", "technology"]

SIMPLE = [
    "perfektpartizip",
    "praesenspartizip",
    "praesensIndikativ",
    "praeteritumIndikativ",
    "praesensKonjunktivI",
    "praeteritumKonjunktivII",
    "imperativ",
]
COMPOUND = [
    "perfektIndikativ",
    "perfektKonjunktivI",
    "plusquamperfektIndikativ",
    "plusquamperfektKonjunktivII",
    "futurIndikativ",
    "futurKonjunktivI",
    "futurKonjunktivII",
]
# Counted so the doc can say how large they are, but the verb page shows neither.
OFF_PAGE = ["passiv", "futurII"]

# Auxiliary forms, by what they make with a participle or an infinitive. The ambiguous ones
# (habe, werde: ich habe is indicative, er habe is Konjunktiv I) are resolved by
# `first_person_singular`, below.
HABEN_PRESENT = {"habe", "hast", "hat", "haben", "habt"}
HABEN_K1_ONLY = {"habest", "habet"}
HABEN_PAST = {"hatte", "hattest", "hatten", "hattet"}
HABEN_K2 = {"hätte", "hättest", "hätten", "hättet"}
SEIN_PRESENT = {"bin", "bist", "ist", "sind", "seid"}
SEIN_K1 = {"sei", "seiest", "seist", "seien", "seiet"}
SEIN_PAST = {"war", "warst", "waren", "wart"}
SEIN_K2 = {"wäre", "wärest", "wärst", "wären", "wäret", "wärt"}
WERDEN_PRESENT = {"werde", "wirst", "wird", "werden", "werdet"}
WERDEN_K1_ONLY = {"werdest"}
WERDEN_PAST = {"wurde", "wurdest", "wurden", "wurdet", "ward"}
WERDEN_K2 = {"würde", "würdest", "würden", "würdet"}
AUXILIARIES = (
    HABEN_PRESENT | HABEN_K1_ONLY | HABEN_PAST | HABEN_K2
    | SEIN_PRESENT | SEIN_K1 | SEIN_PAST | SEIN_K2
    | WERDEN_PRESENT | WERDEN_K1_ONLY | WERDEN_PAST | WERDEN_K2
)

# Every finite and infinitive spelling of the six modals. A modal's infinitive is never a Futur
# partner ("werden … müssen" is rare and "müssen … werden" common), and a modal in the clause
# means a bare "werden" is an infinitive.
MODALS = {
    "können", "kann", "kannst", "könnt", "konnte", "konnten", "konntest", "konntet", "könnte", "könnten", "könntest", "könntet",
    "müssen", "muss", "muß", "musst", "müsst", "musste", "mussten", "müsste", "müssten", "mußte", "mußten", "müßte", "müßten",
    "sollen", "soll", "sollst", "sollt", "sollte", "sollten", "solltest", "solltet",
    "dürfen", "darf", "darfst", "dürft", "durfte", "durften", "dürfte", "dürften",
    "wollen", "will", "willst", "wollt", "wollte", "wollten", "wolltest", "wolltet",
    "mögen", "mag", "magst", "mögt", "mochte", "mochten", "möchte", "möchten", "möchtest", "möchtet",
}

PRONOUNS = {"ich", "du", "er", "sie", "es", "wir", "ihr", "man"}
THIRD_SINGULAR = {"er", "es", "man"}

# Words that are spelled like a conjugation of some verb in the app but are, nearly always,
# something else. Found by reading the most frequent words of each group (--examples). Without
# this list, während (währen's Präsenspartizip) would outnumber every real one.
STOPLIST = {
    "während",       # währen: conjunction and preposition
    "entsprechend",  # entsprechen: used as a preposition
    "betreffend",
    "bitte",         # bitten: interjection
    "danke",
    "halt",          # halten: particle
    "mal",           # malen: particle
    "gleich",        # gleichen: adverb
    "trotz",         # trotzen: preposition
    "dank",          # danken: preposition
    "laut",          # lauten: preposition, adjective
    "statt",         # preposition
    "weit",
    "bereit",
    "frei",
    "fest",
    "los",
    "wohl",
    "lieber",
    "voll",
    "leid",
    "bald",
    "kaum",
    "gar",
    "weg",
    "zurück",
    "hin",
    "her",
    "vor",
    "nach",
    "aus",
    "an",
    "ab",
    "auf",
    "ein",
    "eine",          # einen (unite): article
    "einen",
    "einem",
    "einer",
    "eines",
    "seine",
    "seinen",
    "meine",         # meinen: possessive far more often than "ich meine"
    "meinen",
    "deine",
    "unsere",
    "ihre",
    "mein",          # meinen: possessive
    "schon",         # schonen: adverb
    "offenbar",      # offenbaren: adverb
    "verschieden",   # verscheiden (die): the adjective "different"
    "sein",          # infinitive, but also the possessive; infinitives are not counted anyway
}

GUTENBERG_START = re.compile(r"\*\*\* ?START OF (THE|THIS) PROJECT GUTENBERG.*?\*\*\*", re.S)
GUTENBERG_END = re.compile(r"\*\*\* ?END OF (THE|THIS) PROJECT GUTENBERG", re.S)
WORD = re.compile(r"[A-Za-zÄÖÜäöüß]+")
SENTENCE_END = set(".!?")
CLAUSE_BREAK = set(",;:()[]„“”\"«»‹›–—")
ADJECTIVE_ENDINGS = ("em", "en", "er", "es", "e")


def build_cells():
    """Builds ConjugationMapTool, as scripts/write_forms_json.sh does, and writes the cells."""
    build_root = Path(os.environ.get("TMPDIR", "/tmp")) / "ConjugationMapTool-build"
    subprocess.run(
        ["xcodebuild", "-project", str(REPO / "Konjugieren.xcodeproj"), "-target", "ConjugationMapTool",
         "-configuration", "Release", f"SYMROOT={build_root}/Products", f"OBJROOT={build_root}/Intermediates",
         "-quiet", "build"],
        check=True,
    )
    out = Path(tempfile.mkdtemp()) / "cells.json"
    subprocess.run(
        [str(build_root / "Products/Release/ConjugationMapTool"),
         "--verbs", str(REPO / "Konjugieren/Models/Verbs.xml"),
         "--ablaut-groups", str(REPO / "Konjugieren/Models/AblautGroups.xml"),
         "--cells-json", str(out)],
        check=True,
    )
    return out


def load_cells(path):
    """form → {group → set of auxiliaries}. The verb itself is never needed: a conjugationgroup
    is the same whichever verb a word belongs to, and the auxiliary is all that pairing asks."""
    raw = json.loads(Path(path).read_text())
    cells = {}
    for form, rows in raw.items():
        groups = defaultdict(set)
        for group, _infinitive, auxiliary in rows:
            groups[group].update(auxiliary)
        cells[form] = dict(groups)
    return cells


def split_columns(text):
    """The Bundestag protocols are pdftotext -layout output: two columns side by side on every
    line, with margin markers such as (B) and (D). Reading a line straight across would join the
    end of a left-column sentence to the middle of a right-column one. This splits each line at
    its first long run of spaces after the left margin and returns the left column's lines
    followed by the right column's, which keeps each column's sentences in order within a page.
    Pages are not detected, so a sentence that crosses a page break is cut; that costs a few
    compounds and invents none."""
    left, right = [], []
    for line in text.split("\n"):
        line = re.sub(r"^\s*\([A-D]\)", "", line)
        line = re.sub(r"\([A-D]\)\s*$", "", line)
        match = re.search(r"\S(\s{4,})\S", line[8:])
        if match:
            cut = 8 + match.start(1)
            left.append(line[:cut])
            right.append(line[cut:])
        else:
            left.append(line)
    return "\n".join(left) + "\n" + "\n".join(right)


def clean(path):
    text = path.read_text(encoding="utf-8", errors="replace")
    start = GUTENBERG_START.search(text)
    if start:
        text = text[start.end():]
    end = GUTENBERG_END.search(text)
    if end:
        text = text[:end.start()]
    if "plenarprotokoll" in path.name:
        text = split_columns(text)
    # widerspre-\nchen → widersprechen. A capital after the break means a real hyphenated
    # compound (Corona-\nPandemie), which is a noun either way.
    text = re.sub(r"([a-zäöüß])-\s*\n\s*([a-zäöüß])", r"\1\2", text)
    # Luther verse numbers start sentences in effect: "16 Da standen …"
    text = re.sub(r"(?m)^\s*\d+\s+", ". ", text)
    return text


TOKEN = re.compile(r"[A-Za-zÄÖÜäöüß]+|[^\sA-Za-zÄÖÜäöüß]")


def noun_spellings(texts):
    """Words that are capitalized mid-sentence more often than not: nouns. German capitalizes
    every noun, so a word like Ziel, Reich, or Werte is a noun wherever it starts a sentence,
    even though ziel, reich, and werte are Imperativ spellings of zielen, reichen, and werten.
    Only the sentence-initial position is ambiguous, and this settles it by the word's
    behavior everywhere else in the corpus."""
    capitalized, lowercase = Counter(), Counter()
    for text in texts:
        sentence_start = True
        for match in TOKEN.finditer(text):
            token = match.group(0)
            if not token[0].isalpha():
                sentence_start = sentence_start or token in SENTENCE_END
                continue
            if not sentence_start:
                if token[0].isupper():
                    capitalized[token.lower()] += 1
                else:
                    lowercase[token] += 1
            sentence_start = False
    return {w for w, n in capitalized.items() if n > lowercase[w]}


def sentences(text, nouns):
    """Yields (clauses, terminator) per sentence. A clause is a list of (word, starts_sentence).
    Words that cannot be verbs (capitalized mid-sentence, all capitals, a noun at the start of a
    sentence) are kept as None placeholders, so adjacency rules do not see across a noun as if
    it were not there. The terminator is ".", "!", or "?", which the Imperativ rule reads."""
    sentence, clause = [], []
    sentence_start = True
    for match in TOKEN.finditer(text):
        token = match.group(0)
        if not token[0].isalpha():
            if token in SENTENCE_END or token in CLAUSE_BREAK:
                if clause:
                    sentence.append(clause)
                clause = []
            if token in SENTENCE_END:
                if sentence:
                    yield sentence, token
                sentence = []
                sentence_start = True
            continue
        word = token
        if word[0].isupper():
            if sentence_start and not word.isupper() and word.lower() not in nouns:
                word = word.lower()
            else:
                word = None
        clause.append((word, sentence_start))
        sentence_start = False
    if clause:
        sentence.append(clause)
    if sentence:
        yield sentence, "."


def lookup(word, cells):
    """The groups a word belongs to, folding the old ß spellings (muß, daß) as a fallback."""
    if word is None or word in STOPLIST:
        return None
    hit = cells.get(word)
    if hit is None and "ß" in word:
        hit = cells.get(word.replace("ß", "ss"))
    return hit


def participle_lookup(word, cells):
    """A participle with an adjective ending (gemachte, laufenden) → its groups, or None."""
    if word is None or word in STOPLIST:
        return None
    for ending in ADJECTIVE_ENDINGS:
        if word.endswith(ending) and len(word) > len(ending) + 3:
            base = lookup(word[: -len(ending)], cells)
            if base and ({"perfektpartizip", "praesenspartizip"} & base.keys()):
                return {g: a for g, a in base.items() if g in ("perfektpartizip", "praesenspartizip")}
    return None


def first_person_singular(words, index):
    """Whether ich stands next to the word: ich habe, habe ich. Settles habe, werde, and every
    other spelling that is both ich's indicative and er's Konjunktiv I."""
    neighbors = words[max(0, index - 1): index] + words[index + 1: index + 2]
    return "ich" in neighbors


def third_singular_neighbor(words, index):
    neighbors = words[max(0, index - 1): index] + words[index + 1: index + 2]
    return bool(THIRD_SINGULAR & set(neighbors)) or "sie" in neighbors


def auxiliary_kind(word, words, index):
    """(auxiliary verb, what it makes) for a form of haben, sein, or werden."""
    if word in HABEN_PRESENT:
        if word == "habe" and not first_person_singular(words, index):
            return ("h", "k1")
        return ("h", "present")
    if word in HABEN_K1_ONLY:
        return ("h", "k1")
    if word in HABEN_PAST:
        return ("h", "past")
    if word in HABEN_K2:
        return ("h", "k2")
    if word in SEIN_PRESENT:
        return ("s", "present")
    if word in SEIN_K1:
        return ("s", "k1")
    if word in SEIN_PAST:
        return ("s", "past")
    if word in SEIN_K2:
        return ("s", "k2")
    if word in WERDEN_PRESENT:
        if word == "werde" and not first_person_singular(words, index):
            return ("w", "k1")
        return ("w", "present")
    if word in WERDEN_K1_ONLY:
        return ("w", "k1")
    if word in WERDEN_PAST:
        return ("w", "past")
    if word in WERDEN_K2:
        return ("w", "k2")
    return None


PERFECT_GROUP = {
    "present": "perfektIndikativ",
    "k1": "perfektKonjunktivI",
    "past": "plusquamperfektIndikativ",
    "k2": "plusquamperfektKonjunktivII",
}
FUTURE_GROUP = {
    "present": "futurIndikativ",
    "k1": "futurKonjunktivI",
    "k2": "futurKonjunktivII",
}


def count_clause(clause, terminator, cells, counts, examples):
    words = [w for w, _ in clause]
    groups = [lookup(w, cells) for w in words]
    adjective_participles = [None if g else participle_lookup(w, cells) for w, g in zip(words, groups)]
    used = [False] * len(words)

    def note(group, index_list):
        counts[group] += 1
        if examples is not None:
            examples[group][" ".join(words[i] or "_" for i in sorted(index_list))] += 1

    participles = [i for i, g in enumerate(groups) if g and "perfektpartizip" in g]
    infinitives = [
        i for i, g in enumerate(groups)
        if g and "infinitiv" in g and not (i > 0 and words[i - 1] == "zu")
    ]

    for index, word in enumerate(words):
        kind = auxiliary_kind(word, words, index) if word else None
        if kind is None or used[index]:
            continue
        auxiliary, tense = kind
        others = [i for i in participles if i != index and not used[i]]
        if auxiliary in ("h", "s"):
            partner = next((i for i in others if auxiliary in groups[i]["perfektpartizip"]), None)
            # "ist gemacht worden": the participle of werden marks a passive Perfekt.
            if partner is not None and "worden" in words:
                passive = next(i for i, w in enumerate(words) if w == "worden")
                used[index] = used[partner] = used[passive] = True
                note("passiv", [index, partner, passive])
                counts["perfektpartizip_compound_off_page"] += 1
                continue
            if partner is not None:
                used[index] = used[partner] = True
                note(PERFECT_GROUP[tense], [index, partner])
                continue
            # A participle whose verb takes the other auxiliary: ist gemacht, the Zustandspassiv.
            # The auxiliary is then an ordinary finite verb, and the participle a participle.
            continue
        # werden
        # werden + participle + haben/sein is Futur II: "wird gegangen sein".
        futur_ii = next(
            (i for i in range(1, len(words)) if i != index and words[i] in ("haben", "sein")
             and not used[i] and not used[i - 1] and groups[i - 1] and "perfektpartizip" in groups[i - 1]),
            None,
        )
        if futur_ii is not None and tense in FUTURE_GROUP:
            used[index] = used[futur_ii] = used[futur_ii - 1] = True
            note("futurII", [index, futur_ii - 1, futur_ii])
            counts["perfektpartizip_compound_off_page"] += 1
            continue
        # "werden" beside a modal is werden's infinitive, not an auxiliary: "müssen gesichert
        # werden" is a passive, "soll werden" a full verb.
        if word == "werden" and any(w in MODALS for w in words if w):
            continue
        infinitive_partner = next(
            (i for i in infinitives if i != index and not used[i] and words[i] not in AUXILIARIES and words[i] not in MODALS),
            None,
        )
        if infinitive_partner is not None and tense in FUTURE_GROUP:
            used[index] = used[infinitive_partner] = True
            note(FUTURE_GROUP[tense], [index, infinitive_partner])
            continue
        partner = next(iter(others), None)
        if partner is not None:
            used[index] = used[partner] = True
            note("passiv", [index, partner])
            counts["perfektpartizip_compound_off_page"] += 1
            continue

    for index, word in enumerate(words):
        if used[index] or word is None:
            continue
        found = groups[index]
        if not found:
            found = adjective_participles[index]
            if found:
                group = "perfektpartizip" if "perfektpartizip" in found else "praesenspartizip"
                note(group, [index])
                counts[group + "_attributive"] += 1
            continue
        finite = [g for g in found if g not in ("infinitiv", "perfektpartizip", "praesenspartizip")]
        # An Imperativ starts its sentence, and no pronoun follows it (Kommt er? is a question).
        # Only the start of a sentence counts: a main clause after a fronted subordinate one
        # also starts with its verb ("Wenn …, gilt das"). A spelling that is also another
        # conjugation (geht, mache) counts only in a sentence that ends with "!".
        _, starts_sentence = clause[index]
        next_word = words[index + 1] if index + 1 < len(words) else None
        others = [g for g in finite if g != "imperativ"]
        if "imperativ" in found and starts_sentence and next_word not in PRONOUNS:
            if not others or terminator == "!":
                note("imperativ", [index])
                continue
            # An upper bound for the doc: sentences such as "Sage mir …" that this rule
            # counts as Präsens, though some are surely Imperativ.
            counts["imperativ_possible"] += 1
        finite = others
        if finite:
            if "praesensIndikativ" in finite and "praesensKonjunktivI" in finite:
                group = "praesensKonjunktivI" if (
                    not first_person_singular(words, index) and third_singular_neighbor(words, index) and word.endswith("e")
                ) else "praesensIndikativ"
            elif "praesensIndikativ" in finite:
                group = "praesensIndikativ"
            elif "praeteritumIndikativ" in finite:
                group = "praeteritumIndikativ"
            else:
                group = finite[0]
            # The du and ihr Konjunktiv I (sehest, sehet) is all but extinct, and nearly every
            # such spelling in the corpus is Luther's archaic indicative or Imperativ: "Sehet die
            # Vögel unter dem Himmel an." Counting them would credit the Konjunktiv I with the
            # Bible's imperatives.
            if group == "praesensKonjunktivI" and (word.endswith("et") or word.endswith("est")):
                counts["archaic"] += 1
                continue
            note(group, [index])
            continue
        if "perfektpartizip" in found:
            note("perfektpartizip", [index])
            counts["perfektpartizip_standalone"] += 1
        elif "praesenspartizip" in found:
            note("praesenspartizip", [index])


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--cells", help="cells.json from ConjugationMapTool --cells-json; built if omitted")
    parser.add_argument("--json", help="write every count here")
    parser.add_argument("--examples", help="print the commonest words counted under this group")
    args = parser.parse_args()

    cells = load_cells(args.cells or build_cells())
    texts = {
        folder: [clean(path) for path in sorted((REPO / "corpus" / folder).glob("*.txt")) if not path.name.endswith("-en.txt")]
        for folder in FOLDERS
    }
    nouns = noun_spellings(text for folder in FOLDERS for text in texts[folder])
    by_folder = {}
    examples = defaultdict(Counter) if args.examples else None
    for folder in FOLDERS:
        counts = Counter()
        for text in texts[folder]:
            for sentence, terminator in sentences(text, nouns):
                for clause in sentence:
                    count_clause(clause, terminator, cells, counts, examples)
        by_folder[folder] = counts

    pooled = sum(by_folder.values(), Counter())

    def shares(counts, groups):
        total = sum(counts[g] for g in groups) or 1
        return {g: counts[g] / total for g in groups}

    def report(title, groups):
        print(f"\n{title}")
        print(f"{'':30}" + "".join(f"{f:>13}" for f in FOLDERS) + f"{'pooled':>13}{'balanced':>11}")
        folder_shares = {f: shares(by_folder[f], groups) for f in FOLDERS}
        balanced = {g: sum(folder_shares[f][g] for f in FOLDERS) / len(FOLDERS) for g in groups}
        for g in sorted(groups, key=lambda g: -balanced[g]):
            cells_text = "".join(f"{by_folder[f][g]:>8} {folder_shares[f][g]:4.0%}" for f in FOLDERS)
            print(f"{g:30}{cells_text}{pooled[g]:>8} {shares(pooled, groups)[g]:4.0%}{balanced[g]:>10.1%}")
        return balanced

    simple_balanced = report("Simple conjugationgroups", SIMPLE)
    compound_balanced = report("Compound conjugationgroups", COMPOUND)
    print("\nOff the page, and participle detail (pooled):")
    for key in OFF_PAGE + ["archaic", "imperativ_possible", "perfektpartizip_compound_off_page", "perfektpartizip_attributive",
                           "perfektpartizip_standalone", "praesenspartizip_attributive"]:
        print(f"  {key:40}{pooled[key]:>8}")
    page_compounds = sum(pooled[g] for g in ("perfektIndikativ", "perfektKonjunktivI", "plusquamperfektIndikativ", "plusquamperfektKonjunktivII"))
    print(f"  {'perfektpartizip inside page compounds':40}{page_compounds:>8}")

    # The Perfektpartizip as a word, wherever it stands: alone or attributive (counted above),
    # inside the Perfekt and Plusquamperfekt, and inside a passive or Futur II.
    def participle_everywhere(counts):
        inside = sum(counts[g] for g in ("perfektIndikativ", "perfektKonjunktivI", "plusquamperfektIndikativ", "plusquamperfektKonjunktivII"))
        return counts["perfektpartizip"] + inside + counts["perfektpartizip_compound_off_page"]

    print("\nIf the Perfektpartizip counted every participle, including those inside compounds:")
    for folder in FOLDERS + ["pooled"]:
        counts = pooled if folder == "pooled" else by_folder[folder]
        adjusted = Counter({g: counts[g] for g in SIMPLE})
        adjusted["perfektpartizip"] = participle_everywhere(counts)
        total = sum(adjusted.values())
        ranking = ", ".join(f"{g} {adjusted[g] / total:.0%}" for g in sorted(SIMPLE, key=lambda g: -adjusted[g])[:4])
        print(f"  {folder:12} {ranking}")

    if args.examples:
        print(f"\nCommonest under {args.examples}:")
        for text, n in examples[args.examples].most_common(60):
            print(f"  {n:>7}  {text}")

    if args.json:
        Path(args.json).write_text(json.dumps({
            "byFolder": {f: dict(c) for f, c in by_folder.items()},
            "pooled": dict(pooled),
            "balancedShares": {"simple": simple_balanced, "compound": compound_balanced},
        }, ensure_ascii=False, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
