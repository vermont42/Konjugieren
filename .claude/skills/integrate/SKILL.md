---
name: integrate
allowed-tools: Bash(python3:*), Read, Grep
description: Integrate new example sentences from the working ExampleSentences.json into the app bundle
---

# Integrate Example Sentences

## Scope, and what this skill does not yet cover

This skill integrates **example sentences only**, from a single working file at the project root.
That matches the pipeline described in `docs/example-sentence-pipeline.md`.

It does **not** yet cover the etymology-and-example pipeline in
[`prompts/uses_etymologies.md`](../../../prompts/uses_etymologies.md), whose Phase 4 emits both
halves per verb across many shard files. When that pipeline reaches Phase 5, **widen this skill
rather than writing a second merge path** — two routes into the same bundle is how a bundle
drifts. Phase 5 of that document lists the three gaps to close; the one most likely to cause
silent damage is the null-sentence case:

> Phase 4 emits `"sentence": null` for a verb where no corpus candidate was a genuine verbal use.
> That is a **successful** result carrying an etymology and no sentence — not a half-finished
> record. Merging the etymology while writing no sentence entry is correct. Extending this
> skill's existing "skip verbs that have only one language" rule to also skip these would
> silently discard roughly a third of the etymologies.

## File Roles

- **Working file:** `ExampleSentences.json` (project root) — pipeline output, gitignored
- **Bundled file:** `Konjugieren/Models/ExampleSentences.json` — ships with the app, committed to git

The working file accumulates sentences from extraction subagents. The bundled file is what `ExampleSentence.swift` loads at runtime. This skill copies new entries from the working file into the bundled file.

## Steps

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

## Rules

- Never overwrite existing bundled entries — only add missing ones.
- Both `de` and `en` keys must exist for a verb to be integrated. Skip verbs that have only one language.
- Keep bundled keys alphabetically sorted within each language object.
- If the working file does not exist, inform the user and stop.
- Confirm with `git diff --stat` that the bundled file shows insertions and **no deletions**. Step 2
  rewrites the whole file, so deletions would mean existing entries were reformatted rather than
  preserved. Verified 2026-07-20: `Konjugieren/Models/ExampleSentences.json` and
  `Etymologies.json` both round-trip byte-for-byte through
  `json.dumps(obj, indent=2, ensure_ascii=False) + "\n"`, so the rewrite is safe for these two
  files. It is **not** safe for `Localizable.xcstrings`, which Xcode writes in its own format —
  see `CLAUDE.md` § "Editing Localizable.xcstrings Safely".
