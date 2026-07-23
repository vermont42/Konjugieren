---
name: integrate
allowed-tools: Bash(python3:*), Read, Grep
description: Integrate new example sentences and etymologies from the working pipelines into the app bundle
---

# Integrate Example Sentences and Etymologies

Two pipelines feed the same two bundle files, and both route through this one skill so there is a
single merge path. Two routes into a bundle is how a bundle drifts.

- **Mode A — sentences from a single working file.** The `docs/example-sentence-pipeline.md` route:
  one working `ExampleSentences.json` at the project root, sentences only. This is the original
  skill, unchanged, in [§ Mode A](#mode-a--sentences-from-a-single-working-file).
- **Mode B — etymology-and-example shards.** The [`prompts/uses_etymologies.md`](../../../prompts/uses_etymologies.md)
  route: Phase 4 emits **both** an etymology and a (possibly null) sentence per verb, across many
  `corpus/working/shards/mine_<NNN>.out.json` files. This merges the etymology half into
  `Etymologies.json` and the sentence half into `ExampleSentences.json`, and writes the zero-hit
  verbs out for the corpus-expansion re-mine. See [§ Mode B](#mode-b--etymology-and-example-shards).

Both modes obey the same [§ Rules](#rules): never overwrite an existing bundled entry, keep keys
sorted per language, rewrite the whole file (safe for these two files — see the Rules), and verify
preservation with the byte-for-byte check in the Rules — **not** `git diff --stat`, whose deletion
count is misleading on the object-valued `ExampleSentences.json` (the Rules explain why).

## File Roles

- **Mode A working file:** `ExampleSentences.json` (project root) — pipeline output, gitignored.
- **Mode B working files:** `corpus/working/shards/mine_<NNN>.out.json` — one per shard, tracked.
  `corpus/` is otherwise gitignored, but the `.out.json` outputs are un-ignored because they carry
  authored scholarship, not a regenerable build product. They are nonetheless **ephemeral work
  product, committed only as pre-integration backup insurance** — once a shard's content is merged
  into the bundle below, the bundle is the source of truth and the shard is inert. Do **not** keep
  the shards in parity with the bundle: a later fix to the shipped etymologies (e.g. a formatting
  sweep) belongs in `Etymologies.json`, and re-sweeping the frozen shards to match is wasted effort.
- **Bundled sentences:** `Konjugieren/Models/ExampleSentences.json` — ships with the app, committed.
  Loaded by `ExampleSentence.swift`. Keyed `{de: {verb: {sentence, source}}, en: {...}}`.
- **Bundled etymologies:** `Konjugieren/Models/Etymologies.json` — ships with the app, committed.
  Keyed `{de: {verb: "markup text"}, en: {verb: "markup text"}}` (value is a string, not an object).
- **Zero-hit report (Mode B):** `verbdata/no-corpus-example.txt` — tracked. The verbs Phase 4 could
  give an etymology but no sentence, with the reason. This is the input to the corpus-expansion
  re-mine (`prompts/uses_etymologies.md` Phase 5): `no-candidates` verbs want a bigger corpus of the
  right register; `candidates-none-usable` verbs are a mix — some a corpus-quality floor (nominal /
  homograph / furniture), some genuine uses rejected only for length — and the report's note column
  says which.

## Mode A — sentences from a single working file

1. **Diff the two files** to find verbs present in the working file but missing from the bundled file:

```python
python3 -c "
import json, pathlib

root = json.loads(pathlib.Path('ExampleSentences.json').read_text())
bundled = json.loads(pathlib.Path('Konjugieren/Models/ExampleSentences.json').read_text())

new_de = set(root['de']) - set(bundled['de'])
new_en = set(root['en']) - set(bundled['en'])
new_verbs = sorted(new_de | new_en)

if not new_verbs:
    print('Nothing to integrate — bundled file is up to date.')
else:
    print(f'{len(new_verbs)} new verb(s) to integrate:')
    for v in new_verbs:
        src = root['de'].get(v, {}).get('source', '?')
        print(f'  {v} ({src})')
"
```

If nothing to integrate, stop and inform the user.

2. **Merge new entries** into the bundled file. Preserve existing entries — never overwrite a verb that already exists in the bundled file:

```python
python3 -c "
import json, pathlib

root = json.loads(pathlib.Path('ExampleSentences.json').read_text())
bundled_path = pathlib.Path('Konjugieren/Models/ExampleSentences.json')
bundled = json.loads(bundled_path.read_text())

added = []
for lang in ('de', 'en'):
    for verb, entry in root[lang].items():
        if verb not in bundled[lang]:
            bundled[lang][verb] = entry
            if lang == 'de':
                added.append(verb)
    bundled[lang] = dict(sorted(bundled[lang].items()))

bundled_path.write_text(json.dumps(bundled, indent=2, ensure_ascii=False) + '\n')
print(f'Integrated {len(added)} verb(s). Bundled file now has {len(bundled[\"de\"])} de, {len(bundled[\"en\"])} en entries.')
for v in sorted(added):
    print(f'  + {v} ({bundled[\"de\"][v][\"source\"]})')
"
```

3. **Validate** the bundled JSON:

```python
python3 -c "
import json
d = json.load(open('Konjugieren/Models/ExampleSentences.json'))
de, en = len(d['de']), len(d['en'])
assert de == en, f'Mismatch: {de} de vs {en} en'
print(f'Valid JSON. {de} entries per language.')
"
```

4. **Report** a summary table to the user: verb, source, first ~50 chars of the German sentence.

## Mode B — etymology-and-example shards

Phase 4 of `prompts/uses_etymologies.md` writes one `mine_<NNN>.out.json` per shard, each keyed by
verb, each entry shaped:

```json
{ "verb": {
    "etymology": { "de": "markup text", "en": "markup text" },
    "sentence":  { "de": {"sentence": "…", "source": "…"},
                   "en": {"sentence": "…", "source": "…"} }   // or null
} }
```

The **three gaps** over Mode A, all handled below:

- It merges an **etymology** as well as a sentence — two bundles, not one.
- It reads **many shard files**, not one working file, and tolerates missing shards (a resumed
  run leaves gaps), so an aggregation step comes first.
- The **null-sentence case is not a skip.** `"sentence": null` is a *successful* result — an
  etymology with no corpus sentence. Merge its etymology; write no sentence entry; do **not** drop
  the verb. Skipping it would silently discard about a third of the etymologies.

Markup integrity is **not** re-checked here: Mode B copies each shard's etymology text into the
bundle verbatim, so the authoritative gate is the Phase 4 validator in
[`prompts/uses_etymologies.md`](../../../prompts/uses_etymologies.md) (tilde balance, reserved
markers, ASCII-quote-in-German, stray chars). Run it green against the shards *before* integrating;
duplicating those assertions here would be a second copy that drifts — the very thing this pipeline
warns against.

1. **Aggregate the shards** and preview what will change (read-only):

```python
python3 -c "
import json, glob
mined = {}
for f in sorted(glob.glob('corpus/working/shards/mine_*.out.json')):
    mined.update(json.load(open(f)))
ety = json.load(open('Konjugieren/Models/Etymologies.json'))
ex  = json.load(open('Konjugieren/Models/ExampleSentences.json'))
new_ety  = [v for v in mined if v not in ety['en']]
new_sent = [v for v,e in mined.items() if e.get('sentence') and v not in ex['de']]
null_v   = [v for v,e in mined.items() if not e.get('sentence')]
print(f'shards aggregated: {len(mined)} verbs')
print(f'  new etymologies:      {len(new_ety)}  ({len(ety[\"en\"])} -> {len(ety[\"en\"])+len(new_ety)})')
print(f'  new sentences:        {len(new_sent)}  ({len(ex[\"de\"])} -> {len(ex[\"de\"])+len(new_sent)})')
print(f'  null-sentence (etymology only): {len(null_v)}')
"
```

2. **Merge both halves.** Etymology for every verb; sentence only where non-null. Never overwrite.
   Both `de` and `en` must be present, per the Rules — a half-language entry is skipped and
   reported, exactly as in Mode A.

```python
python3 -c "
import json, glob, pathlib

mined = {}
for f in sorted(glob.glob('corpus/working/shards/mine_*.out.json')):
    mined.update(json.load(open(f)))

ety_path = pathlib.Path('Konjugieren/Models/Etymologies.json')
ex_path  = pathlib.Path('Konjugieren/Models/ExampleSentences.json')
ety = json.loads(ety_path.read_text())
ex  = json.loads(ex_path.read_text())

ety_added, sent_added, skipped = [], [], []
for verb, entry in mined.items():
    et = entry.get('etymology') or {}
    if et.get('de') and et.get('en'):
        for lang in ('de', 'en'):
            if verb not in ety[lang]:
                ety[lang][verb] = et[lang]
        ety_added.append(verb)
    else:
        skipped.append(('etymology', verb))
    s = entry.get('sentence')
    if s:
        if s.get('de') and s.get('en'):
            for lang in ('de', 'en'):
                if verb not in ex[lang]:
                    ex[lang][verb] = s[lang]
            sent_added.append(verb)
        else:
            skipped.append(('sentence', verb))

for lang in ('de', 'en'):
    ety[lang] = dict(sorted(ety[lang].items()))
    ex[lang]  = dict(sorted(ex[lang].items()))

ety_path.write_text(json.dumps(ety, indent=2, ensure_ascii=False) + '\n')
ex_path.write_text(json.dumps(ex,  indent=2, ensure_ascii=False) + '\n')
print(f'etymologies: +{len(ety_added)} -> {len(ety[\"en\"])} per language')
print(f'sentences:   +{len(sent_added)} -> {len(ex[\"de\"])} per language')
if skipped:
    print(f'skipped (half-language): {skipped[:10]}')
"
```

3. **Write the zero-hit report.** A verb with a null sentence goes to `verbdata/no-corpus-example.txt`
   tagged by *why* — the classification depends on whether its shard input carried any candidate at
   all, so this step reads the `mine_<NNN>.in.json` shard inputs (regenerate them with
   `build_mining_shards.py` if they are absent — they are gitignored build products):

```python
python3 -c "
import json, glob, pathlib

mined = {}
for f in sorted(glob.glob('corpus/working/shards/mine_*.out.json')):
    mined.update(json.load(open(f)))
incand = {}
for f in sorted(glob.glob('corpus/working/shards/mine_*.in.json')):
    for e in json.load(open(f))['verbs']:
        incand[e['verb']] = len(e['candidates'])

# The .in.json shards are gitignored build products; without them every reason degrades to
# 'unknown' silently. Fail loudly instead so a fresh clone regenerates them first.
null_total = sum(1 for e in mined.values() if not e.get('sentence'))
if null_total and not incand:
    raise SystemExit('ERROR: no mine_*.in.json shard inputs found, so zero-hit reasons cannot be '
                     'classified. Regenerate with: python3 corpus/working/build_mining_shards.py')

rows = []
for verb, entry in sorted(mined.items()):
    if entry.get('sentence'):
        continue
    n = incand.get(verb)
    if n is None:
        reason = 'unknown-no-shard-input'
    elif n == 0:
        reason = 'no-candidates'          # corpus never attests it — wants a bigger, right-register corpus
    else:
        reason = 'candidates-none-usable'  # had candidates, none usable; the note says why (see below)
    note = (entry.get('notes') or entry.get('note') or '').strip().replace(chr(10), ' ')
    rows.append((verb, reason, note))

no_cand  = sum(1 for _,r,_ in rows if r == 'no-candidates')
rejected = sum(1 for _,r,_ in rows if r == 'candidates-none-usable')
out = pathlib.Path('verbdata/no-corpus-example.txt')
lines = [
  '# Verbs with an etymology but no corpus example sentence.',
  '# Generated by the integrate skill (Mode B) from the Phase 4 mined shards.',
  '# Input to the corpus-expansion re-mine: prompts/uses_etymologies.md Phase 5.',
  '#',
  '# reason=no-candidates           the corpus never attests this verb; wants a larger corpus of the',
  '#                                missing register (news / administrative / technical German), not',
  '#                                more of the same literary sources. Re-mine after expansion.',
  '# reason=candidates-none-usable  the corpus has the token but no candidate yielded a sentence. The',
  '#                                third column says why, and the reasons are NOT uniform: some are',
  '#                                nominal-only / homograph-drained / furniture (a corpus-quality',
  '#                                floor), but a real fraction are GENUINE verbal uses rejected only',
  "#                                for exceeding the 55-word ceiling — those are recoverable by",
  '#                                revisiting the ceiling, not by expanding the corpus. Read the note',
  '#                                before deciding the fix; the two-bucket "all nominal" framing in',
  "#                                the Phase 5 brief is coarser than what's actually here.",
  '#',
  '# format: <verb>\\t<reason>\\t<subagent note, if any>',
  '',
]
for verb, reason, note in rows:
    lines.append(f'{verb}\t{reason}' + (f'\t{note}' if note else ''))
out.write_text('\n'.join(lines) + '\n')
print(f'wrote {out}: {len(rows)} zero-hit verbs ({no_cand} no-candidates, {rejected} candidates-none-usable)')
"
```

4. **Validate both bundles** — each must have equal `de`/`en` counts, and both must still parse:

```python
python3 -c "
import json
for p in ('Konjugieren/Models/Etymologies.json', 'Konjugieren/Models/ExampleSentences.json'):
    d = json.load(open(p))
    de, en = len(d['de']), len(d['en'])
    assert de == en, f'{p}: {de} de vs {en} en'
    print(f'{p.split(\"/\")[-1]}: valid, {de} entries per language')
"
```

5. **Verify preservation, then report.** Run the byte-for-byte preservation check in the Rules — do
   **not** judge the merge by `git diff --stat` on `ExampleSentences.json`, whose deletion count is a
   line-diff artifact (the Rules explain). Then report to the user: the two before/after counts, the
   zero-hit split, and any skipped half-language verbs.

## Rules

- **Never overwrite existing bundled entries** — only add missing ones. Both modes gate every write
  on `verb not in bundle[lang]`.
- **Both `de` and `en` must exist** for a verb to be integrated into a given bundle. Skip and report
  a verb that has only one language.
  - **Mode B exception — the null sentence is not a half-language record.** A verb with a full
    `de`+`en` etymology and `"sentence": null` is complete: merge its etymology, write no sentence,
    keep the verb. Only a verb *missing a language on the half it does emit* is skipped for that
    half.
- **Keep bundled keys alphabetically sorted** within each language object.
- If a mode's working input is absent (Mode A's root file; Mode B's shard directory), inform the
  user and stop.
- **Verify preservation semantically, not by `git diff --stat` — the deletion count lies on the
  object-valued bundle.** The instinct is to confirm the diff is insertions-only, and that works for
  `Etymologies.json`, whose values are single-line strings: inserting an entry between two others is
  unambiguous to git, so a correct merge shows near-zero deletions (only the old last key gaining a
  trailing comma). It does **not** work for `ExampleSentences.json`, whose values are 4-line objects
  with repeated boilerplate lines (`"sentence":`, `"source":`, `},`). When new keys interleave among
  existing ones, git's line-alignment re-attributes those identical structural lines and reports
  thousands of delete+add pairs with **zero semantic change** — a Mode B merge adding ~1,450
  sentences showed ~4,000 phantom deletions on 2026-07-23, every original entry provably intact. So
  `git diff --stat` on that file cries wolf; do not revert a merge on its deletion count. The check
  that actually settles it (run after every merge, both files):

```python
python3 -c "
import json, subprocess, glob
mined = set()
for f in sorted(glob.glob('corpus/working/shards/mine_*.out.json')):
    mined.update(json.load(open(f)).keys())
for p in ('Konjugieren/Models/ExampleSentences.json','Konjugieren/Models/Etymologies.json'):
    orig = subprocess.run(['git','show',f'HEAD:{p}'],capture_output=True,text=True).stdout
    new  = json.load(open(p))
    stripped = {l:{k:v for k,v in new[l].items() if k not in mined} for l in ('de','en')}
    ok = json.dumps(stripped, indent=2, ensure_ascii=False)+'\n' == orig
    print(f'{p.split(chr(47))[-1]}: original content byte-for-byte preserved after merge? {ok}')
    assert ok
"
```

  It removes the merged-in verbs and asserts the remainder reproduces the committed file
  byte-for-byte — proving nothing existing was lost, altered, or reordered, regardless of what the
  line-diff shows. **Run it before committing:** it compares the working tree against `HEAD`, so once
  the merge is committed `HEAD` *is* the merged file and the check falsely fails. (For a Mode A single-file merge, substitute the working file's verb set for the
  shard-key set.) Both bundles were verified 2026-07-20 to round-trip through
  `json.dumps(obj, indent=2, ensure_ascii=False) + "\n"`; that guarantees the serialization is
  stable but **not** that the line-diff is clean, which is the distinction that tripped the earlier
  rule. This whole-file rewrite is safe for these two files. It is **not** safe for
  `Localizable.xcstrings`, which Xcode writes in its own format — see `CLAUDE.md` § "Editing
  Localizable.xcstrings Safely".
- **After a Mode B merge, shipping counts change.** `Etymologies.json` and `ExampleSentences.json`
  coverage both grow, so run `python3 scripts/check_docs.py` and update any cache file whose count it
  flags. A Mode B merge that adds kaikki-derived etymologies also makes the CC BY-SA credit invariant
  load-bearing — the checker enforces that too.
