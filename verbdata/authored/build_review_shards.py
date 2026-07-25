#!/usr/bin/env python3
"""Build review shards for prompts/example_review.md.

Consumes:
  verbdata/authored/shards/auth_NNN.in.json    verb, gloss, separability (what the author saw)
  verbdata/authored/shards/auth_NNN.out.json   the authored de/en
  verbdata/authored/corrections.json           accepted fixes, overlaid (optional)
  verbdata/candidates.json                     the full kaikki gloss list per verb
  corpus/working/forms.json                    form -> [{verb, contiguous, particle?}]

CORRECTIONS ARE OVERLAID HERE TOO, and forgetting to would be worse than cosmetic: the reviewer
would be shown a sentence that has already been fixed, and would re-report a finding that is
already closed. The authored shards stay immutable for the reasons in check_forms.py's header;
every consumer applies corrections.json on read.

Produces:
  verbdata/review/shards/rev_NNN.in.json       one per authored shard, same verbs, same order

Run: python3 verbdata/authored/build_review_shards.py

WHY THE REVIEWER GETS MORE CONTEXT THAN THE AUTHOR DID. The author was given only verb, gloss, and
separability, deliberately: a minimal, identical input so shard size could not bias the A/B token
comparison. That constraint is gone. The quality comparison between models was ruled out of scope on
2026-07-25 (prompts/example_analysis.md, "Scope decision"), so nothing is being measured here and the
reviewer can be given everything that helps it judge:

  candidate_glosses  Lets the reviewer settle a `bad_gloss` finding against the source rather than
                     from memory. Only emitted when kaikki listed more than one sense, because a
                     single-gloss list tells the reviewer nothing and costs tokens. 83 of the 125
                     gloss disagreements the authors raised have a competing sense sitting here.
  app_forms          The conjugations the app itself generates. The reviewer needs these to judge a
                     `wrong_verb` finding (is the particle right?) WITHOUT mistaking the app's
                     one-paradigm-per-verb limitation for a sentence defect. The brief tells it
                     explicitly not to flag a correct German form merely because it is absent here.

Shards mirror the authored shards 1:1 (same NNN, same verbs, same order). There is no shuffling or
model-mixing: that machinery existed only to keep a model-vs-model comparison honest, and there is no
longer a comparison to protect. Mirroring keeps resume semantics identical to the authoring run and
makes a finding trivially traceable back to its source shard.
"""

import json
import glob
import os
import re

CAND = {c["word"]: c for c in json.load(open("verbdata/candidates.json"))["candidates"]}
FORMS = json.load(open("corpus/working/forms.json"))

# Invert forms.json once: verb -> sorted list of every token the app generates for it. Done up front
# because the file holds ~50k form keys and a per-verb scan would be quadratic over 1,097 verbs.
BY_VERB = {}
for form, entries in FORMS.items():
    for e in entries:
        BY_VERB.setdefault(e["verb"], set()).add(
            form if e["contiguous"] else f'{form} … {e.get("particle", "")}'.strip()
        )

CORRECTIONS = {}
if os.path.exists("verbdata/authored/corrections.json"):
    CORRECTIONS = json.load(open("verbdata/authored/corrections.json"))

os.makedirs("verbdata/review/shards", exist_ok=True)
built = total = 0

for inp in sorted(glob.glob("verbdata/authored/shards/auth_*.in.json")):
    n = re.search(r"auth_(\d+)\.in\.json", inp).group(1)
    outp = f"verbdata/authored/shards/auth_{n}.out.json"
    if not os.path.exists(outp):
        print(f"skip {n}: no authored output")
        continue
    authored = json.load(open(outp))
    for verb, fix in CORRECTIONS.items():
        if verb in authored:
            authored[verb] = {**authored[verb],
                              **{k: v for k, v in fix.items() if k in ("de", "en")}}
    verbs = []
    for entry in json.load(open(inp))["verbs"]:
        v = entry["verb"]
        sentence = authored.get(v)
        if not isinstance(sentence, dict):
            print(f"warn {n}: {v} missing from output")
            continue
        item = {
            "verb": v,
            "gloss": entry["gloss"],
            "separability": entry["separability"],
            "de": sentence.get("de", ""),
            "en": sentence.get("en", ""),
        }
        glosses = (CAND.get(v) or {}).get("glosses") or []
        if len(glosses) > 1:                      # a single gloss adds nothing the author lacked
            item["candidate_glosses"] = glosses
        forms = sorted(BY_VERB.get(v, ()))
        if forms:
            item["app_forms"] = forms
        verbs.append(item)
    json.dump({"shard": int(n), "verbs": verbs},
              open(f"verbdata/review/shards/rev_{n}.in.json", "w"),
              ensure_ascii=False, indent=2)
    built += 1
    total += len(verbs)

print(f"built {built} review shards covering {total} verbs -> verbdata/review/shards/"
      f"{f' ({len(CORRECTIONS)} corrections overlaid)' if CORRECTIONS else ''}")
