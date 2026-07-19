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
ERN_ELN_FINITE = "-ern/-eln: Präsens 1p/3p and Konjunktiv I 1p/3p take -n, not -en"
ERN_ELN_PARTICIPLE = "-ern/-eln: Präsenspartizip takes -nd, not -end"
IMPERATIV_2P = "Imperativ 2p: missing epenthetic -e after a d/t stem"
SPURIOUS_E = "Spurious epenthetic -e where German has none"
MISSING_E = "Missing epenthetic -e outside the Imperativ"

VARIANT_SPELLING = re.compile(r"ey|ss(?:en|eln|ern)$")


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
    """
    if entry["mismatches"] == ["no hypothesis produced a conjugation"]:
        return "No hypothesis produced a conjugation"

    parsed = [match.groupdict() for match in
              (MISMATCH.match(mismatch) for mismatch in entry["mismatches"]) if match]

    for mismatch in parsed:
        if mismatch["slot"] != "perfektpartizip":
            continue
        expected = mismatch["expected"].split("/")
        if mismatch["got"].startswith("ge") and not any(form.startswith("ge") for form in expected):
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

    regrouped = [entry for entry in verified(shipping) if entry["ablautGroupIsNew"]]
    strong_shipping = [entry for entry in verified(shipping) if entry.get("family") in {"s", "m"}]
    out.append(f"A quieter defect: {len(regrouped)} of the {len(strong_shipping)} shipping strong "
               f"and mixed verbs verified only by proposing an ablaut group that does not ship, "
               f"which means the group they do ship with is wrong. Total shipping verbs at odds "
               f"with Wiktionary: {len(shipping) - len(verified(shipping)) + len(regrouped)}.")
    out.append("")
    out.append("Examples: " + ", ".join(entry["word"] for entry in regrouped[:8]) + ".")
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
    variants = [entry for entry in verified(incoming) if VARIANT_SPELLING.search(entry["word"])]
    disagree = [entry for entry in verified(entries) if family_disagrees(entry)]
    contrived = [entry for entry in verified(incoming) if person_split(entry.get("proposedAblautPattern"))]
    out.append(table([
        ["Dual-auxiliary (see prompts/dual_auxiliary.md)", len(dual), ", ".join(e["word"] for e in dual[:4])],
        ["Family disagrees with Wiktionary's own class tag — a dual-paradigm verb whose "
         "second paradigm this run never saw", len(disagree), ", ".join(e["word"] for e in disagree[:6])],
        ["Proposed group varies by person inside a past tense, so it is probably encoding "
         "an ending rather than ablaut", len(contrived), ", ".join(e["word"] for e in contrived[:4])],
        ["Obsolete or Swiss spelling (ey-, -ss- for -ß-)", len(variants), ", ".join(e["word"] for e in variants[:4])],
        ["Carries an etymology from kaikki", sum(1 for e in verified(incoming) if e["hasEtymology"]), ""],
    ], ["Flag", "Verbs", "Examples"]))
    out.append("")

    args.out.write_text("\n".join(out) + "\n")
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()
