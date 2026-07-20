#!/usr/bin/env python3
"""Render verbdata/classification.json as a readable Markdown summary.

Stage C of the classify-and-verify pipeline described in docs/verb-sources.md.
Groups the queue by failure cause so a reader sees a handful of systematic causes
rather than thousands of individual misses.
"""

import argparse
import collections
import json
import pathlib
import re

REPO = pathlib.Path(__file__).resolve().parent.parent
DEFAULT_IN = REPO / "verbdata" / "classification.json"
DEFAULT_OUT = REPO / "verbdata" / "classification-summary.md"

MISMATCH = re.compile(r"^(?P<slot>[^:]+): expected (?P<expected>.*), got (?P<got>.+)$")

DOUBLE_PREFIX = "Perfektpartizip: double prefix (separable over inseparable) is unrepresentable"
UNKNOWN_PARTICLE = "First element is not in the shipped prefix inventory, so no hypothesis separates it"
ERN_ELN_FINITE = "-ern/-eln: Präsens 1p/3p and Konjunktiv I 1p/3p take -n, not -en"
ERN_ELN_PARTICIPLE = "-ern/-eln: Präsenspartizip takes -nd, not -end"
IMPERATIV_2P = "Imperativ 2p: missing epenthetic -e after a d/t stem"
SPURIOUS_E = "Spurious epenthetic -e where German has none"
MISSING_E = "Missing epenthetic -e outside the Imperativ"

ARCHAIC_SPELLING = re.compile(r"ey")


def swiss_spelling(word, verified_words):
    """Whether word is the Swiss spelling of a verb also present with ß.

    Swiss Standard German does not use ß at all — it is a current national standard,
    not an obsolete spelling, and the two forms are the same verb. Shipping both would
    duplicate the lemma; the alternation belongs in rendering, not in the corpus.
    """
    return "ss" in word and word.replace("ß", "ss") == word and any(
        other != word and other.replace("ß", "ss") == word for other in verified_words)


def epenthetic(expected_forms, got):
    """Whether got differs from some expected form by exactly one 'e'.

    Returns 'missing' when Conjugator dropped an e German keeps (geatmt for geatmet),
    'spurious' when it added one German does not (stimmete for stimmte), else None.
    """
    for expected in expected_forms:
        for index, character in enumerate(expected):
            if character == "e" and expected[:index] + expected[index + 1:] == got:
                return "missing"
        for index, character in enumerate(got):
            if character == "e" and got[:index] + got[index + 1:] == expected:
                return "spurious"
    return None


def cause(entry):
    """Name the systematic cause behind a verb's mismatches.

    Order matters: an unrepresentable double prefix also perturbs later slots, so it
    is tested first. It is identified by shape rather than by regex over the whole
    line — Conjugator prepending a ge- that Wiktionary does not have is the signature,
    and matching "got ge…" alone would sweep in every ordinary Perfektpartizip miss.

    That signature alone is ambiguous, though, and was silently conflating two causes
    until the double-prefix grammar landed on 2026-07-19. Both end with Conjugator
    emitting a leading ge-, but for opposite reasons, and where Wiktionary puts its own
    ge- tells them apart:

      no ge at all in the expected form   angehört      the prefix against the stem is
                                                        inseparable — a real double prefix
      ge infixed in the expected form     achtgegeben   the first element separates but is
                                                        not in the inventory, so every
                                                        hypothesis was rejected and the
                                                        no-prefix fallback prepended ge-

    The second is a gap in the prefix inventory, not in the grammar, and calling it a
    double prefix would send the next session to rewrite code that is already correct.
    """
    if entry["mismatches"] == ["no hypothesis produced a conjugation"]:
        return "No hypothesis produced a conjugation"

    parsed = [match.groupdict() for match in
              (MISMATCH.match(mismatch) for mismatch in entry["mismatches"]) if match]

    for mismatch in parsed:
        if mismatch["slot"] != "perfektpartizip":
            continue
        expected = mismatch["expected"].split("/")
        if not mismatch["got"].startswith("ge") or any(form.startswith("ge") for form in expected):
            continue
        if any("ge" in form[1:] for form in expected):
            return UNKNOWN_PARTICLE
        return DOUBLE_PREFIX

    for mismatch in parsed:
        if re.search(r"(er|el)en$", mismatch["got"]) and mismatch["slot"].endswith(("fp", "tp")):
            return ERN_ELN_FINITE
        if mismatch["slot"] == "präsenspartizip" and re.search(r"(er|el)end$", mismatch["got"]):
            return ERN_ELN_PARTICIPLE

    for label in (IMPERATIV_2P, SPURIOUS_E, MISSING_E):
        for mismatch in parsed:
            delta = epenthetic(mismatch["expected"].split("/"), mismatch["got"])
            if delta is None:
                continue
            if mismatch["slot"] == "imperativ.sp" and delta == "missing":
                found = IMPERATIV_2P
            else:
                found = SPURIOUS_E if delta == "spurious" else MISSING_E
            if found == label:
                return label

    return "Other"


def family_disagrees(entry):
    """Whether the verified family contradicts Wiktionary's own strong/weak tag.

    The usual reason is a verb with parallel strong and weak paradigms — melken,
    gären, sieden. Wiktionary's table shows one, its class tag names the other, and
    this run confirmed only the paradigm the table happened to hold.
    """
    tag = entry.get("kaikkiClass") or ""
    if entry.get("family") in {"w", "i"}:
        return "strong" in tag
    if entry.get("family") == "s":
        return "weak" in tag
    return False


def person_split(pattern):
    """Whether a proposed group gives one past tense different replacements per person.

    Genuine ablaut is person-uniform outside the Präsens 2s/3s. A group that assigns
    AND to five persons and ANDE to the sixth is encoding a conjugation ending inside
    the ablaut region, which works but is not what the ablaut mechanism is for.
    """
    if not pattern:
        return False
    replacements = collections.defaultdict(set)
    for entry in pattern.split("|"):
        parts = entry.split(",")
        for code in parts[1:]:
            if code[:1] in {"b", "d"}:
                replacements[code[:1]].add(parts[0])
    return any(len(values) > 1 for values in replacements.values())


def table(rows, headers):
    lines = ["| " + " | ".join(headers) + " |", "|" + "|".join(["---"] * len(headers)) + "|"]
    lines += ["| " + " | ".join(str(cell) for cell in row) + " |" for row in rows]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=pathlib.Path, default=DEFAULT_IN)
    parser.add_argument("--out", type=pathlib.Path, default=DEFAULT_OUT)
    args = parser.parse_args()

    entries = json.loads(args.input.read_text())["classifications"]
    shipping = [entry for entry in entries if entry["alreadyShipping"]]
    incoming = [entry for entry in entries if not entry["alreadyShipping"]]

    def verified(group):
        return [entry for entry in group if entry["status"] == "verified"]

    out = ["# Classification summary", ""]
    out.append(f"{len(entries)} candidates classified: {len(shipping)} already shipping "
               f"(the regression oracle) and {len(incoming)} incoming.")
    out.append("")

    out.append("## Verification rate")
    out.append("")
    out.append(table([
        ["Already shipping", len(shipping), len(verified(shipping)),
         f"{100 * len(verified(shipping)) / max(1, len(shipping)):.1f}%"],
        ["Incoming", len(incoming), len(verified(incoming)),
         f"{100 * len(verified(incoming)) / max(1, len(incoming)):.1f}%"],
    ], ["Population", "Candidates", "Verified", "Rate"]))
    out.append("")
    out.append("A shipping verb that fails is a verb the app conjugates differently from "
               "Wiktionary today. That number is a bug count, not a pipeline score.")
    out.append("")

    # A shipping verb can be at odds with Wiktionary in three ways, and only the first is
    # obvious. Counting just the first two undercounted for months: see the note below.
    # A verb with more than one reading is excluded: the classifier tests only the primary
    # reading, against a Wiktionary table that aggregates every sense, so a verb whose table
    # describes the second reading fails for a reason that is not a defect.
    multi_reading = [entry for entry in verified(shipping)
                     if entry.get("shippedEncodingFailed") and entry.get("readingCount", 1) > 1]
    miscounted = [entry for entry in verified(shipping)
                  if entry.get("shippedEncodingFailed") and entry.get("readingCount", 1) == 1]
    # Verbs where the app deliberately disagrees with Wiktionary because Wiktionary is wrong.
    # Without this subtraction the gate punishes correctness: fixing such a verb raises the
    # count, and the roadmap says the count must never rise. See wiktionary-defects.json for
    # the failure mode (auto-generated weak tables on under-edited pages) and the evidence.
    defects_path = pathlib.Path(__file__).with_name("wiktionary-defects.json")
    known_wrong = set()
    if defects_path.exists():
        known_wrong = {d["verb"] for d in json.loads(defects_path.read_text())["defects"]}

    regrouped = [entry for entry in miscounted if entry["ablautGroupIsNew"]]
    rescued = [entry for entry in miscounted if not entry["ablautGroupIsNew"]]
    strong_shipping = [entry for entry in verified(shipping) if entry.get("family") in {"s", "m"}]
    at_odds_raw = len(shipping) - len(verified(shipping)) + len(miscounted)
    deliberate = sum(1 for entry in miscounted if entry.get("word") in known_wrong)
    deliberate += sum(1 for entry in shipping
                      if entry not in verified(shipping) and entry.get("word") in known_wrong)
    at_odds = at_odds_raw - deliberate

    out.append(f"A quieter defect: {len(miscounted)} shipping verbs verified only after the "
               f"classifier abandoned the encoding in Verbs.xml and found a different one, "
               f"which means the encoding they ship with is wrong. Of those, {len(regrouped)} "
               f"of the {len(strong_shipping)} shipping strong and mixed verbs need an ablaut "
               f"group that does not ship, and {len(rescued)} are repairable with a group that "
               f"already does. Total shipping verbs at odds with Wiktionary: {at_odds}.")
    out.append("")
    if deliberate:
        out.append(f"That total excludes {deliberate} verbs listed in `wiktionary-defects.json`, "
                   f"where the app is right and Wiktionary is wrong. English Wiktionary "
                   f"auto-generates a default *weak* table for verb pages nobody has supplied a "
                   f"strong template for, producing non-words like *angelest* and *aufgewascht* "
                   f"while the base entries stay correctly strong. Each exclusion was arbitrated "
                   f"against German Wiktionary, which is independently edited. Fixing such a "
                   f"verb raises the raw count ({at_odds_raw}), so without this subtraction the "
                   f"gate would punish the repair.")
        out.append("")
    out.append("The second kind used to be invisible. Until 2026-07-19 this count added only "
               "the verbs needing a *new* ablaut group, so a verb the classifier could rescue "
               "with an existing one — beschreiben shipped weak, scheinen without its "
               "participle ablaut, schwimmen with its region spanning a whole consonant "
               "cluster — was reported verified while the app went on conjugating it wrongly. "
               "The `shippedEncodingFailed` flag now catches both.")
    out.append("")
    if miscounted:
        out.append("Examples: " + ", ".join(entry["word"] for entry in miscounted[:8]) + ".")
        out.append("")
    if multi_reading:
        out.append(f"Excluded from that count: {len(multi_reading)} verbs with more than one "
                   f"reading ({', '.join(entry['word'] for entry in multi_reading)}). The "
                   f"classifier tests only the primary reading against a table that aggregates "
                   f"every sense, so these fail for a reason that is not a defect. Judge them "
                   f"by hand, or by the ConjugatorTests cases that pin each reading.")
        out.append("")

    out.append("## Incoming verbs by family")
    out.append("")
    families = collections.Counter(entry["family"] for entry in verified(incoming))
    names = {"w": "weak", "s": "strong", "m": "mixed", "i": "-ieren"}
    out.append(table([[names.get(code, code), count] for code, count in families.most_common()],
                     ["Family", "Verified"]))
    out.append("")

    reused = [entry for entry in verified(incoming) if entry.get("ablautGroup") and not entry["ablautGroupIsNew"]]
    fresh = [entry for entry in verified(incoming) if entry["ablautGroupIsNew"]]
    out.append(f"Of the strong and mixed verbs, {len(reused)} reuse an ablaut group that already "
               f"ships and {len(fresh)} need a new one, drawn from "
               f"{len({entry['proposedAblautPattern'] for entry in fresh})} distinct proposed patterns.")
    out.append("")

    out.append("## Proposed ablaut groups, most-used first")
    out.append("")
    patterns = collections.Counter(entry["proposedAblautPattern"] for entry in fresh)
    rows = []
    for pattern, count in patterns.most_common(25):
        examples = [entry["word"] for entry in fresh if entry["proposedAblautPattern"] == pattern][:3]
        rows.append([count, f"`{pattern}`", ", ".join(examples)])
    out.append(table(rows, ["Verbs", "Pattern", "Examples"]))
    out.append("")

    out.append("## The queue, grouped by cause")
    out.append("")
    for label, population in (("Already shipping", shipping), ("Incoming", incoming)):
        failures = [entry for entry in population if entry["status"] != "verified"]
        counts = collections.Counter(cause(entry) for entry in failures)
        out.append(f"### {label} ({len(failures)} unverified)")
        out.append("")
        rows = []
        for name, count in counts.most_common():
            examples = [entry["word"] for entry in failures if cause(entry) == name][:3]
            rows.append([count, name, ", ".join(examples)])
        out.append(table(rows, ["Verbs", "Cause", "Examples"]))
        out.append("")

    out.append("## Flags for the editorial pass")
    out.append("")
    out.append("Verified means Conjugator reproduced Wiktionary's table exactly. It does not "
               "mean the encoding is idiomatic, nor that Wiktionary's table was the only one.")
    out.append("")
    dual = [entry for entry in verified(incoming) if entry["dualAuxiliary"]]
    verified_words = {entry["word"] for entry in verified(entries)}
    archaic = [entry for entry in verified(incoming) if ARCHAIC_SPELLING.search(entry["word"])]
    swiss = [entry for entry in verified(incoming) if swiss_spelling(entry["word"], verified_words)]
    disagree = [entry for entry in verified(entries) if family_disagrees(entry)]
    contrived = [entry for entry in verified(incoming) if person_split(entry.get("proposedAblautPattern"))]
    out.append(table([
        ["Dual-auxiliary (see prompts/dual_auxiliary.md)", len(dual), ", ".join(e["word"] for e in dual[:4])],
        ["Family disagrees with Wiktionary's own class tag — a dual-paradigm verb whose "
         "second paradigm this run never saw", len(disagree), ", ".join(e["word"] for e in disagree[:6])],
        ["Proposed group varies by person inside a past tense, so it is probably encoding "
         "an ending rather than ablaut", len(contrived), ", ".join(e["word"] for e in contrived[:4])],
        ["Swiss Standard German spelling of a verb already present with ß — the same "
         "verb, not a second one. Do not import both.", len(swiss), ", ".join(e["word"] for e in swiss[:4])],
        ["Archaic spelling (ey-)", len(archaic), ", ".join(e["word"] for e in archaic[:4])],
        ["Carries an etymology from kaikki", sum(1 for e in verified(incoming) if e["hasEtymology"]), ""],
    ], ["Flag", "Verbs", "Examples"]))
    out.append("")

    args.out.write_text("\n".join(out) + "\n")
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()
