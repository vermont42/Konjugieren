# Frame-parity repair — resume prompt

Paste the block below into a fresh session at a fresh budget. It carries **no state**: the
mismatch list is re-derived from the file, and the repair policy lives in `docs/blog_notes.md`
(the `## Mine shards 051–052 …` entry, 2026-07-21) rather than being restated here — the same
anti-drift discipline the Phase 4 resume block in `prompts/uses_etymologies.md` uses, and for the
same reason: a summarized copy goes stale and then outranks the file it contradicts.

Do this repair (and settle the still-open shard-049 precedence decision) **before** resuming
Phase 4 mining from shard 053.

````
Do the frame-parity repair in Konjugieren before resuming Phase 4 mining. Working directory:
/Users/josh/Desktop/workspace/Konjugieren

Read the `## Mine shards 051–052 …` entry in `docs/blog_notes.md` (2026-07-21) first — it holds
the full analysis and Josh's decision, "per-entry dominant style," with the per-prefix
instructions and the `schön` mixed case. That entry is authoritative; do not re-derive the
policy, and do not restate it back to me.

The target is `verbdata/prefixes-separable.json` (language-first: {de:{prefix:…}, en:{prefix:…}};
each prefix entry has `kind`, `chain`, `senses`, `occurrences`). Re-derive the mismatch list
rather than trusting any count — a sense is a defect when exactly one language carries the
normalizer frame (`The sense of ~X~ here is:` / `Die Bedeutung von ~X~ ist hier:`) and its twin
does not:

```bash
python3 - <<'PY'
import json, re
d = json.load(open('verbdata/prefixes-separable.json'))
fen = re.compile(r'^The sense of ~[^~]+~ here is:?\s*')
fde = re.compile(r'^Die Bedeutung von ~[^~]+~ ist hier:?\s*')
for p in sorted(set(d['de']) & set(d['en'])):
    se, sd = d['en'][p].get('senses',[]), d['de'][p].get('senses',[])
    for i in range(min(len(se), len(sd))):
        he, hd = bool(fen.match(se[i])), bool(fde.match(sd[i]))
        if he != hd:
            print(f"{p}[{i}] {'EN-only' if he else 'DE-only'}")
            print(f"   en: {se[i]}")
            print(f"   de: {sd[i]}")
PY
```

This is real bilingual authoring, not a mechanical strip: frame-free senses are full clauses
beginning with the prefix name, framed senses are colon-fragments, so converting either way means
re-writing the clause in the twin's register. Read all of a prefix's senses together before
editing any one of them (`schön` sense 0 stays framed; only 1–2 change). After editing, validate
with `python3 verbdata/merge_reuse_files.py --validate-only` — it catches tilde/quote/de-en parity
regressions — and confirm `git diff --stat` shows only the touched entries.

A second, separate data decision is still open from an earlier window: the shard-049
exemplar-vs-reading precedence rule (see its blog_notes entry). Raise it with me before acting;
it is not part of this repair.

Once both data questions are settled, resume mining from shard 053 using the standard Phase 4
resume prompt in `prompts/uses_etymologies.md` § "Resuming Phase 4 in a fresh session."
````
