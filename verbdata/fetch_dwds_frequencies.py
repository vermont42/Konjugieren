#!/usr/bin/env python3
"""Fetch DWDS lemma frequencies for a list of German verb infinitives.

Usage:
  python3 verbdata/fetch_dwds_frequencies.py [--lemmas FILE] [--out FILE] [--workers N]
  python3 verbdata/fetch_dwds_frequencies.py --check FILE     # audit a snapshot, no network

With no --lemmas, the infinitives are read from Konjugieren/Models/Verbs.xml
(the `in` attribute, with `+` prefix separators and `^` ablaut markers stripped).

The DWDS frequency endpoint is unauthenticated but occasionally returns an empty
body; each lemma is retried up to three times with backoff before being recorded
as a failure.

## The infinitive is not a safe query, and a wrong answer looks like a right one

The endpoint lemmatizes whatever it is given and returns *that* lemma's count. It takes
no part-of-speech parameter — DDC syntax such as `runden with $p=VVINF` returns nulls —
so an infinitive that is also an adjective or noun form silently resolves to the wrong
word. Measured on 2026-07-19, eight of the 990 shipping verbs did exactly that:

    runden   -> rund   (adj. "round")      23,421,973 hits, versus 516,850 for the verb
    gleichen -> gleich (adj. "same")       18,062,655           828,309
    lauten   -> laut   (adj. "loud")       12,046,082         3,183,195
    weißen   -> weiß   (adj. "white")       4,262,331           615,024

Nothing about the response says it is wrong; the hit count is real, it is just a
different word's. Deriving rank from those would have put `runden` 25th of 990.

**The fix: query an unambiguously verbal inflected form, then verify the lemma that comes
back.** The endpoint lemmatizes `rundet`, `rundete`, and `gerundet` all to `runden` and
returns the verb's own 516,850. The response's `lemma` field is the check — if it does not
equal the verb you asked about, the answer is about something else and must be discarded.
Rows repaired this way carry a `probe` field naming the form used, so the fix is reproducible.

Choose the probe with care, because inflected forms can collide too. A Präteritum or
participle is usually safer than a Präsens form, which is why `weißen` was repaired with
*geweißt*: its Präsens 2s *weißt* is also *wissen*'s. Measured 2026-07-19, that particular
collision does not actually reproduce — DWDS lemmatizes `weißt` to `weißen` and returns the
verb's own 615,024 — so treat "prefer a participle" as a sound default rather than as a rule
with a known counterexample.

Two things this is NOT, both checked before concluding. DWDS is case-sensitive, so a noun
plural does not leak in — `Fällen` is a separate entry resolving to `Fall`, and `fällte`
returns the same count as `fällen`, meaning the verb's 5.7M is genuine idiom (*eine
Entscheidung fällen*) rather than contamination. And a `dwds_lemma` that merely differs in
spelling is fine: `reißen`->`reissen`, `erschweren`->`erschwern`, `kreieren`->`kreiern` are
variant orthography, and all three shift rank by fewer than 45 places.

**Detection recipe, worth re-running after any fetch:** flag every row where `dwds_lemma`
differs from `lemma`, plus every row with zero hits, then read the survivors by eye. A match
that is a bare adjective or noun stem is the signature. That recipe found all eight; a
ninth suspect, `fällen`, was cleared by the case-sensitivity check above.

## The gate

Everything above used to be prose that a future session had to read and act on. It is now
enforced. Every fetched row is classified before anything is written, and a single suspect
row aborts the run with a nonzero exit and no output file. Three checks:

  1. `dwds_lemma` must come back equal to the lemma asked about, modulo the orthographic
     variants below. This is the check that catches `runden` -> `rund`.
  2. `hits` must be present and nonzero. A zero is how the tab-joined multi-lemma answer
     for `einigen` presented.
  3. When two probes are supplied for a lemma, both must resolve to it *and return the same
     count*. The endpoint reports the lemma's total, so two genuinely verbal forms of the
     same verb agree by construction; disagreement means at least one probe collided with
     another word. This is the only check that catches a collision nobody predicted, and so
     the only one that does not depend on the variant rules below being complete.

Verification is on by default and `--no-verify` turns it off. That default is deliberate:
an opt-in flag is precisely what a naive bulk re-fetch would omit, which is the failure this
gate exists to prevent. `--check FILE` runs the gate over an existing snapshot without
touching the network, which is how to audit a file someone else produced.

A benign variant is a spelling difference, not a different word, and is reported but not
fatal. Two alternations are known, both observed in the 990-lemma snapshot: DWDS writes ß as
ss (`reißen` -> `reissen`), and it drops the *e* before a final *-n* in some -eren verbs
(`erschweren` -> `erschwern`, `kreieren` -> `kreiern`). These are expressed as rules rather
than as a list of three lemmas so that they generalize to imported verbs of the same shape.
All three shift rank by fewer than 45 places.

Probes are supplied through `--lemmas`, one record per line, tab-separated:

    weißen<TAB>geweißt<TAB>weißte

With no probes a bare infinitive is queried, which is safe only for a lemma known not to be
a homograph. For a bulk import, generate probes from kaikki's `forms[]` — `perfektpartizip`
and `präsensIndikativ.ts` are the two shapes the 2026-07-19 repair used — rather than
trusting infinitives.
"""

import argparse
import json
import pathlib
import re
import sys
import time
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor

ENDPOINT = "https://www.dwds.de/api/frequency/"
USER_AGENT = "KonjugierenVerbResearch/1.0 (contact: vermontcoder@gmail.com)"
REPO = pathlib.Path(__file__).resolve().parent.parent


def lemmas_from_verbs_xml() -> list[str]:
    text = (REPO / "Konjugieren/Models/Verbs.xml").read_text()
    return [re.sub(r"[+*^]", "", m) for m in re.findall(r'in="([^"]+)"', text)]


# MARK: The gate


def is_benign_variant(lemma: str, dwds_lemma: str) -> bool:
    """True when `dwds_lemma` is the same word as `lemma` spelled DWDS's way.

    Rules rather than a lemma list, so that an imported ß- or -eren verb of the same shape
    is accepted without anyone having to notice and extend an allowlist. Both alternations
    were observed in the 990-lemma snapshot; see the module docstring.
    """
    if lemma == dwds_lemma:
        return True
    if lemma.replace("ß", "ss") == dwds_lemma.replace("ß", "ss"):
        return True
    # erschweren -> erschwern, kreieren -> kreiern. Anchored on -eren rather than the more
    # general -en, which would also accept machen -> machn: no such word comes back today,
    # but a rule this gate relies on should be no wider than the evidence for it.
    if re.sub(r"eren$", "ern", lemma) == dwds_lemma:
        return True
    return False


def classify(row: dict) -> tuple[str, str]:
    """Sort one fetched row into ok / benign / suspect, with a reason for the latter two.

    Only `suspect` is fatal. The caller aborts on any of them rather than dropping the row,
    because a partial file that looks complete is the shape of the original defect.
    """
    lemma, dwds_lemma, hits = row["lemma"], row["dwds_lemma"], row["hits"]

    # Checked before `hits is None`, because a disagreement also leaves hits unset and
    # would otherwise be reported as a network failure — sending the reader to debug the
    # wrong thing entirely.
    if row.get("disagreement"):
        return "suspect", f"probes disagree ({row['disagreement']})"
    if hits is None:
        return "suspect", "fetch failed after retries"
    if dwds_lemma is None:
        return "suspect", "no lemma in response"
    # A tab- or space-joined answer means DWDS matched several lemmas and committed to
    # none; `einigen` presented this way and scored zero.
    if dwds_lemma.strip() != dwds_lemma or re.search(r"\s", dwds_lemma):
        return "suspect", f"multi-lemma response {dwds_lemma!r}"
    if hits == 0:
        return "suspect", "zero hits"
    if lemma == dwds_lemma:
        return "ok", ""
    if is_benign_variant(lemma, dwds_lemma):
        return "benign", f"variant spelling {dwds_lemma}"
    # The signature of the original defect: a real count belonging to another word.
    return "suspect", f"resolved to {dwds_lemma!r}, a different word"


def verify(results: list[dict]) -> list[tuple[dict, str]]:
    """Classify every row, report benign variants, and return the suspects."""
    suspects = []
    benign = []
    for row in results:
        status, reason = classify(row)
        if status == "suspect":
            suspects.append((row, reason))
        elif status == "benign":
            benign.append((row, reason))

    if benign:
        print(f"{len(benign)} benign variant spellings (not fatal):", file=sys.stderr)
        for row, reason in benign:
            print(f"    {row['lemma']} -> {reason}", file=sys.stderr)

    if suspects:
        print(f"\n{len(suspects)} SUSPECT rows — refusing to write:", file=sys.stderr)
        for row, reason in suspects:
            print(f"    {row['lemma']:16} {reason} (hits={row['hits']})", file=sys.stderr)
        print(
            "\nA suspect count is a real number belonging to a different word, so it will\n"
            "not look wrong downstream. Re-query these with an unambiguously verbal probe;\n"
            "see this script's docstring.",
            file=sys.stderr,
        )
    return suspects


def query(term: str) -> dict:
    """One frequency lookup. `term` is whatever is sent to DWDS: a lemma or a probe form."""
    url = f"{ENDPOINT}?{urllib.parse.urlencode({'q': term})}"
    for attempt in range(3):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(request, timeout=30) as response:
                body = response.read().decode("utf-8").strip()
            if body:
                payload = json.loads(body)
                return {
                    "dwds_lemma": payload.get("lemma"),
                    "hits": payload.get("hits"),
                    "total": int(payload.get("total", 0)),
                }
        except Exception:  # noqa: BLE001 - report, retry, move on
            pass
        time.sleep(1.5 * (attempt + 1))
    return {"dwds_lemma": None, "hits": None, "total": None}


def fetch(record: tuple[str, list[str]]) -> dict:
    """Fetch one lemma, using its probes if it has any.

    With no probes the bare infinitive is queried, which is what produced the eight bad
    counts of 2026-07-19 and is safe only for a lemma known not to be a homograph.

    With probes, every probe is queried and all must agree — same resolved lemma, same
    count. Because the endpoint returns the *lemma's* total rather than the queried form's,
    two genuinely verbal forms of one verb return identical numbers, so a disagreement means
    a probe collided with another word. The row is failed here rather than silently taking
    the first answer, since either probe could be the contaminated one.
    """
    lemma, probes = record
    if not probes:
        return {"lemma": lemma, **query(lemma)}

    answers = [(probe, query(probe)) for probe in probes]

    for probe, answer in answers:
        if answer["hits"] is None:
            return {"lemma": lemma, "dwds_lemma": None, "hits": None, "total": None, "probe": probe}

    counts = {answer["hits"] for _, answer in answers}
    if len(counts) > 1:
        return {
            "lemma": lemma,
            "dwds_lemma": None,
            "hits": None,
            "total": None,
            "probe": probes[0],
            # Carried as its own field rather than smuggled into dwds_lemma, so `classify`
            # can name the actual finding. Which probe is the contaminated one is not
            # decidable here, so both are reported.
            "disagreement": ", ".join(
                f"{probe}->{answer['dwds_lemma']}={answer['hits']}" for probe, answer in answers
            ),
        }

    probe, answer = answers[0]
    return {"lemma": lemma, **answer, "probe": probe}


def read_records(path: pathlib.Path) -> list[tuple[str, list[str]]]:
    """Parse the --lemmas file: one lemma per line, optional tab-separated probes after it."""
    records = []
    for line in path.read_text().splitlines():
        if not line.strip():
            continue
        lemma, *probes = [field.strip() for field in line.split("\t") if field.strip()]
        records.append((lemma, probes))
    return records


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--lemmas", type=pathlib.Path, help="lemma per line, optional tab-separated probes")
    parser.add_argument("--out", type=pathlib.Path, default=REPO / "verbdata/dwds-frequencies.json")
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--check", type=pathlib.Path, help="verify an existing snapshot; no network, no write")
    parser.add_argument(
        "--no-verify",
        action="store_true",
        help="write without checking for contaminated counts; you almost certainly do not want this",
    )
    args = parser.parse_args()

    # --check exists so a snapshot someone else produced can be audited, and so the gate
    # itself can be exercised without spending requests against DWDS.
    if args.check:
        results = json.loads(args.check.read_text())
        suspects = verify(results)
        print(f"\nChecked {len(results)} records: {len(suspects)} suspect", file=sys.stderr)
        return 1 if suspects else 0

    records = read_records(args.lemmas) if args.lemmas else [(lemma, []) for lemma in lemmas_from_verbs_xml()]
    probed = sum(1 for _, probes in records if probes)
    print(
        f"Fetching {len(records)} lemmas with {args.workers} workers "
        f"({probed} with probes, {len(records) - probed} as bare infinitives)…",
        file=sys.stderr,
    )

    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        results = list(pool.map(fetch, records))

    if not args.no_verify:
        # Refuse to write rather than writing and warning. A contaminated count is a real
        # number for a different word, so a written file looks complete and correct, and
        # the 2026-07-19 run reported success while a third of the corpus was garbage.
        if verify(results):
            print(f"\nRefused to write {args.out}.", file=sys.stderr)
            return 1

    args.out.write_text(json.dumps(results, ensure_ascii=False, indent=2) + "\n")
    print(f"Wrote {args.out} ({len(results)} records)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
