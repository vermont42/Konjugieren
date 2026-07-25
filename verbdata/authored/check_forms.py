#!/usr/bin/env python3
"""Mechanical conjugation gate for the authored example sentences.

Consumes:
  corpus/working/forms.json                  form -> [{verb, contiguous, particle?}]
                                             built by KonjugierenTests/Utils/CorpusFormsDumpTests
  verbdata/authored/shards/auth_*.out.json   the authored {de, en} sentences
  verbdata/authored/provenance.json          verb -> author model
  verbdata/classification.json               per-verb family / auxiliary / ablautGroup

Produces:
  verbdata/authored/forms-gate.json          per-verb verdict + the matched token
  a printed report: overall hit rate, by model, by verb family, and the calibration cut

Run: python3 verbdata/authored/check_forms.py

WHY THIS IS THE UNCONFOUNDED QUALITY SIGNAL. Every other quality measure available for the
Opus 4.8 vs 5.0 comparison needs an LLM judge, which introduces self-preference bias. This
one is pure string matching against forms the app itself generates, so it has no opinion
about style. See prompts/example_analysis.md, "Run the unconfounded signals first".

Three facts about forms.json drive the matching logic, none obvious from the call site:

1. Keys are LOWERCASED. CorpusFormsDump lowercases every form because Conjugator returns
   mixed case as UI highlighting metadata ("sAng"), not orthography. So tokens must be
   lowercased before lookup.

2. Separable verbs get TWO entries. A main clause strands the particle -- "er faengt ... an"
   -- so the harness synthesizes the split form: "faengt" maps to anfangen with
   contiguous=false and particle="an". Matching a split entry therefore requires finding the
   particle as a later standalone token, not just the finite form.

3. Compound conjugationgroups are deliberately NOT enumerated, because their parts already
   appear: "hat angefangen" matches via the Perfektpartizip "angefangen", and enumerating
   compounds would map "hat" onto every verb in the corpus. So a compound-tense sentence
   still matches, just through its participle.

Known false-positive risk, accepted: a split match only checks that the particle token is
present somewhere after the finite form. "Er faengt den Ball an der Wand" would credit
anfangen when the writer meant fangen plus a preposition. This inflates the hit rate very
slightly and identically for both models, so it cannot bias the comparison -- which is what
this script is for.
"""

import json
import glob
import re
import collections

TOKEN = re.compile(r"[a-zA-ZäöüßÄÖÜẞ]+")

forms = json.load(open("corpus/working/forms.json"))
prov = json.load(open("verbdata/authored/provenance.json"))
classif = {c["word"]: c for c in json.load(open("verbdata/classification.json"))["classifications"]}

sentences = {}
for f in sorted(glob.glob("verbdata/authored/shards/auth_*.out.json")):
    sentences.update(json.load(open(f)))


def attests(verb, sentence):
    """Return (True, matched_token) if `sentence` contains a conjugation of `verb`."""
    toks = [t.lower() for t in TOKEN.findall(sentence)]
    for i, tok in enumerate(toks):
        for entry in forms.get(tok, []):
            if entry["verb"] != verb:
                continue
            if entry["contiguous"]:
                return True, tok
            # Split reading: the particle must be stranded later in the clause.
            if entry.get("particle") in toks[i + 1:]:
                return True, f'{tok} … {entry["particle"]}'
    return False, None


results = {}
for verb, e in sorted(sentences.items()):
    ok, tok = attests(verb, e.get("de", ""))
    results[verb] = {
        "hit": ok,
        "matched": tok,
        "model": prov[verb],
        "family": classif.get(verb, {}).get("family"),
        "flagged": bool(e.get("note")),
        "gloss_note": bool(e.get("gloss_note")),
        "de": e.get("de", ""),
    }

json.dump(results, open("verbdata/authored/forms-gate.json", "w"), ensure_ascii=False, indent=2)


def rate(rows):
    n = len(rows)
    h = sum(1 for r in rows if r["hit"])
    return f"{h}/{n} ({100*h/n:.1f}%)" if n else "—"


rows = list(results.values())
print(f"OVERALL  {rate(rows)}\n")

print("by author model")
for m in sorted({r["model"] for r in rows}):
    print(f"  {m:16} {rate([r for r in rows if r['model'] == m])}")

FAMILY = {"w": "weak", "s": "strong", "m": "modal/mixed", "i": "irregular"}
print("\nby verb family x model")
for fam in ["s", "w", "m", "i"]:
    sub = [r for r in rows if r["family"] == fam]
    if not sub:
        continue
    line = f"  {FAMILY[fam]:12} {rate(sub):18}"
    for m in sorted({r["model"] for r in rows}):
        line += f"  {m.replace('claude-opus-', ''):4} {rate([r for r in sub if r['model'] == m]):16}"
    print(line)

# The calibration test: do the verbs a model flagged as uncertain actually fail more often?
# This is a WITHIN-model comparison, so it is immune to judge bias and to any between-model
# difference in baseline quality.
print("\ncalibration — did self-flagged uncertainty predict failure?")
for m in sorted({r["model"] for r in rows}):
    sub = [r for r in rows if r["model"] == m]
    fl = [r for r in sub if r["flagged"]]
    un = [r for r in sub if not r["flagged"]]
    print(f"  {m:16} flagged {rate(fl):16} unflagged {rate(un)}")

misses = [(v, r) for v, r in results.items() if not r["hit"]]
print(f"\nmisses: {len(misses)}")
for v, r in misses[:25]:
    print(f'  [{r["model"].replace("claude-opus-", "")}] {v}: {r["de"][:96]}')
