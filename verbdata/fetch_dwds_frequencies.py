#!/usr/bin/env python3
"""Fetch DWDS lemma frequencies for a list of German verb infinitives.

Usage:
  python3 verbdata/fetch_dwds_frequencies.py [--lemmas FILE] [--out FILE] [--workers N]

With no --lemmas, the infinitives are read from Konjugieren/Models/Verbs.xml
(the `in` attribute, with `+` prefix separators and `^` ablaut markers stripped).

The DWDS frequency endpoint is unauthenticated but occasionally returns an empty
body; each lemma is retried up to three times with backoff before being recorded
as a failure.
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
