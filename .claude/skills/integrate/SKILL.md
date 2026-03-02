---
name: integrate
allowed-tools: Bash(python3:*), Read, Grep
description: Integrate new example sentences from the working ExampleSentences.json into the app bundle
---

# Integrate Example Sentences

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
