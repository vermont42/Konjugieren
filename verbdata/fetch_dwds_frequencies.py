#!/usr/bin/env python3
"""Fetch DWDS lemma frequencies for a list of German verb infinitives.

Usage:
  python3 verbdata/fetch_dwds_frequencies.py [--lemmas FILE] [--out FILE] [--workers N]

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

Choose the probe with care, because inflected forms collide too: `weißen`'s Präsens 2s
*weißt* is also *wissen*'s, so its participle *geweißt* was used instead. A Präteritum or
participle is usually safer than a Präsens form.

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

This script does not yet generate probe forms automatically. A bulk re-fetch should do so —
`Conjugator` can produce them — rather than trusting infinitives.
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


def fetch(lemma: str) -> dict:
    url = f"{ENDPOINT}?{urllib.parse.urlencode({'q': lemma})}"
    for attempt in range(3):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(request, timeout=30) as response:
                body = response.read().decode("utf-8").strip()
            if body:
                payload = json.loads(body)
                return {
                    "lemma": lemma,
                    "dwds_lemma": payload.get("lemma"),
                    "hits": payload.get("hits"),
                    "total": int(payload.get("total", 0)),
                }
        except Exception as error:  # noqa: BLE001 - report, retry, move on
            last = error
        time.sleep(1.5 * (attempt + 1))
    return {"lemma": lemma, "dwds_lemma": None, "hits": None, "total": None}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--lemmas", type=pathlib.Path)
    parser.add_argument("--out", type=pathlib.Path, default=REPO / "verbdata/dwds-frequencies.json")
    parser.add_argument("--workers", type=int, default=4)
    args = parser.parse_args()

    lemmas = (
        [line.strip() for line in args.lemmas.read_text().splitlines() if line.strip()]
        if args.lemmas
        else lemmas_from_verbs_xml()
    )
    print(f"Fetching {len(lemmas)} lemmas with {args.workers} workers…", file=sys.stderr)

    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        results = list(pool.map(fetch, lemmas))

    failures = [r["lemma"] for r in results if r["hits"] is None]
    args.out.write_text(json.dumps(results, ensure_ascii=False, indent=2) + "\n")
    print(f"Wrote {args.out} ({len(results)} records, {len(failures)} failures)", file=sys.stderr)
    if failures:
        print("Failures: " + ", ".join(failures), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
