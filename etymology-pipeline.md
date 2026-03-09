# Etymology Translation Pipeline

## Progress

**Next verb: lächeln**

**BATCH SIZE: 60**

## Task

Read `Konjugieren/Models/Etymologies.json`, take the next BATCH SIZE verbs (alphabetically by key in the `"en"` object) starting at the verb above. Launch parallel subagents to translate each English etymology into German. Merge results back into the same file under a new `"de"` key.

## Architecture

Launch 5 `general-purpose` subagents **in parallel** (in a single message with multiple Agent tool calls). Each subagent receives 20 verbs' English etymologies and returns German translations as a JSON fragment. After all return, verify and merge the fragments into `Etymologies.json`. This 5×20 split reduces context consumption compared to 10×10, lowering the risk of context compaction mid-batch.

### Subagent prompt template

Give each subagent the following prompt, substituting the VERB SECTIONS. Each subagent receives ~20 verbs. The prompt must be **self-contained** — include all translation rules inline, since the subagent cannot see this file.

---

**Begin subagent prompt (copy fully for each verb, substituting VERB SECTION):**

> You are translating German-verb etymologies from English into German. Do NOT write any files. Return ONLY the JSON result at the end.
>
> ## Your Verbs
>
> VERB SECTIONS (see below — multiple verbs separated by `---`)
>
> ## What to Translate
>
> Translate the connecting prose, explanations, and commentary into natural, idiomatic German. Specifically:
>
> **Language labels — use these standard German equivalents:**
>
> | English | German |
> |---------|--------|
> | Middle High German / MHG | Mittelhochdeutsch / Mhd. |
> | Old High German / OHG | Althochdeutsch / Ahd. |
> | Proto-Germanic | Urgermanisch |
> | Proto-West Germanic | Proto-Westgermanisch |
> | Proto-Indo-European / PIE | Protoindoeuropäisch / PIE |
> | Old English | Altenglisch |
> | Old Norse | Altnordisch |
> | Old French | Altfranzösisch |
> | Middle French | Mittelfranzösisch |
> | Latin | Lateinisch |
> | Ancient Greek / Greek | Altgriechisch / Griechisch |
> | Sanskrit | Sanskrit |
> | Gothic | Gotisch |
> | Old Saxon | Altsächsisch |
> | Old Frisian | Altfriesisch |
> | Low German | Niederdeutsch |
> | Dutch | Niederländisch |
>
> **English semantic glosses in parentheses** (e.g., "to dwell", "off, away") → translate to German glosses (e.g., "wohnen", "weg, fort"). These are the meanings in parentheses after reconstructed forms or historical words.
>
> **Structural phrases** like "From X, from Y" → "Aus X, aus Y" or "Von X, von Y" — use whichever reads more naturally. "Cognate with..." → "Verwandt mit...". "Related to..." → "Verwandt mit...". "Compound of..." → "Zusammensetzung aus...". "The semantic development..." → "Die Bedeutungsentwicklung...". And so on — translate naturally.
>
> **Cultural/historical commentary** → translate into engaging, idiomatic German at the same level of detail.
>
> ## What NOT to Translate
>
> - **Reconstructed forms**: `*~bʰuH-~`, `*~h₂epo~`, etc. — keep verbatim, including the asterisk and tildes
> - **All `~tilde~` markup** — preserve exactly as-is. Every `~` must appear in the output exactly where it appears in the input. The number of `~` characters in your German output MUST exactly equal the number in the English input. Do NOT add tildes to words that weren't tilde-wrapped in the English, and do NOT drop tildes by restructuring sentences. If the English wraps a phrase like `~sich anstellen~`, the German must keep that exact phrase wrapped: `~sich anstellen~`. If the English wraps a small word like `~to~`, find an equivalent tilde-wrapped word in your translation (e.g., `~zu~`) rather than absorbing it into the surrounding prose.
> - **German words/phrases already in German** — obviously keep them as-is
> - **Latin scholarly terms** used as technical labels: ~frequentative~, ~causative~, ~iterative~, ~inchoative~, ~desiderative~, etc. — keep in Latin
> - **Cognate citations in other languages** (English ~break~, Dutch ~breken~, Swedish ~bryta~, etc.) — keep in the original language. BUT translate any English gloss that accompanies them.
> - **Verb infinitives and word forms** cited from other languages — keep in the original language
>
> ## Style Guidance
>
> - Mirror the English structure but allow natural German phrasing where it reads better
> - Maintain the same paragraph breaks and bullet-point structure
> - Preserve the educational, engaging tone
> - Keep the same level of detail — don't add or omit information
> - Use German typographic conventions: for quotation marks, use double low-nine/left double (,,X``) if quoting, but generally the etymologies use parenthetical glosses, not quotation marks
>
> ## Output Format
>
> Return ONLY a JSON object in this exact format (no markdown fencing, no extra text):
>
> {"verb1": "GERMAN ETYMOLOGY TEXT", "verb2": "GERMAN ETYMOLOGY TEXT", ...}
>
> **JSON and special characters:** German typographic quotes (`„` U+201E, `"` U+201C) and special letters (`ä`, `ö`, `ü`, `ß`) are safe to include directly in JSON string values — they are distinct from the ASCII `"` (U+0022) used as JSON delimiters. Do NOT escape them as `\uXXXX` in your output; write them as literal characters.

**End subagent prompt.**

---

### Verb-specific sections

For each subagent, construct the VERB SECTIONS by concatenating ~20 verb blocks separated by `---`:

```
**Verb:** abbauen
**English etymology to translate:**

[Paste the full English etymology text here, verbatim]

---

**Verb:** abbilden
**English etymology to translate:**

[Paste the full English etymology text here, verbatim]

---

[...repeat for all ~20 verbs in this group...]
```

## After Subagents Return

### Step 1: Extract translations from subagent JSONL transcripts

Do NOT try to parse the subagent response text directly — it may contain German typographic closing quotes (`"` U+201C) rendered as ASCII `"` (U+0022), which breaks `json.loads()`. Instead, use this extraction script that fixes the quotes before parsing:

```python
python3 << 'ENDPY'
import json, pathlib, re

OPEN_Q  = "\u201e"  # „
CLOSE_Q = "\u201c"  # "

def fix_german_quotes(text):
    """Replace ASCII " used as German closing quote after „ with proper U+201C."""
    return re.sub(
        OPEN_Q + r'([^' + CLOSE_Q + OPEN_Q + r'"]{1,80})"',
        lambda m: OPEN_Q + m.group(1) + CLOSE_Q,
        text
    )

base = pathlib.Path(
    "/Users/josh/.claude/projects/-Users-josh-Desktop-workspace-Konjugieren"
)
# Find the current session directory (most recent conversation JSONL)
# Subagent IDs come from the Agent tool results — substitute them below.
session = "SESSION_ID"  # e.g. "ebf85cc7-704a-4fb5-bf16-c88458f0b180"
agents = [
    ("agent-AGENT_ID_1.jsonl", "/tmp/de_group_1.json"),
    ("agent-AGENT_ID_2.jsonl", "/tmp/de_group_2.json"),
    ("agent-AGENT_ID_3.jsonl", "/tmp/de_group_3.json"),
]

for agent_file, out_file in agents:
    p = base / session / "subagents" / agent_file
    for line in p.read_text().splitlines():
        try:
            obj = json.loads(line)
        except:
            continue
        if obj.get("type") != "assistant":
            continue
        for block in obj.get("message", {}).get("content", []):
            if block.get("type") != "text":
                continue
            text = block["text"].strip()
            # Skip past any preamble before the JSON object
            json_start = text.find('{')
            if json_start == -1:
                continue
            text = text[json_start:]
            fixed = fix_german_quotes(text)
            try:
                data = json.loads(fixed)
                pathlib.Path(out_file).write_text(json.dumps(data, ensure_ascii=False))
                print(f"{agent_file}: {len(data)} verbs -> {out_file}")
            except json.JSONDecodeError as e:
                print(f"{agent_file}: FAILED: {e}")
                pos = e.pos if hasattr(e, 'pos') else 0
                print(f"  Context: ...{fixed[max(0,pos-60):pos+60]}...")
ENDPY
```

This script reads the JSONL transcript files that persist on disk even after context compaction. Substitute the session ID and agent IDs from the current run.

### Step 2: Verify tilde counts

For each verb, count `~` in the EN original and DE translation. They MUST match. Also spot-check that reconstructed forms (`*~...~`) appear unchanged.

### Step 3: Fix tilde mismatches

Common mismatch pattern: subagents tilde-wrap English cognates that appear in untilded prose. For example, EN says `to "drive" progress` (no tildes) but DE produces `den Fortschritt ~drive~ forward` (tildes added). Fix by removing the spurious tildes.

### Step 4: Merge into Etymologies.json

Load the temp group JSON files and merge:

```python
python3 << 'ENDPY'
import json, pathlib

p = pathlib.Path('Konjugieren/Models/Etymologies.json')
data = json.loads(p.read_text())

g1 = json.load(open('/tmp/de_group_1.json'))
g2 = json.load(open('/tmp/de_group_2.json'))
g3 = json.load(open('/tmp/de_group_3.json'))
new_translations = {**g1, **g2, **g3}

if 'de' not in data:
    data['de'] = {}

data['de'].update(new_translations)

for lang in data:
    data[lang] = dict(sorted(data[lang].items()))
data = dict(sorted(data.items()))

p.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n')
print(f"Merged {len(new_translations)} translations. Total DE: {len(data['de'])}")
ENDPY
```

### Step 5: Validate JSON

```bash
python3 -c "import json; json.load(open('Konjugieren/Models/Etymologies.json')); print('Valid JSON')"
```

### Step 6: Print summary and update pipeline

Print a summary table: verb | first 60 chars of German translation | tilde count match (Y/N).

### Step 7: Update "Next verb"

Compute the next verb by finding the **first remaining untranslated verb alphabetically** — do NOT simply take the verb after the last one in this batch, since earlier gaps may exist from skipped or failed verbs:

```python
python3 -c "
import json, pathlib
d = json.loads(pathlib.Path('Konjugieren/Models/Etymologies.json').read_text())
remaining = sorted(set(d['en']) - set(d['de']))
print(f'Remaining: {len(remaining)}, next: {remaining[0] if remaining else \"DONE\"}')"
```

If all 989 verbs are done, note that translation is complete.

## JSON Munging Advice

1. **Never put German translation text in shell heredocs or inline Python dicts.** Typographic quotes (`„"`) are visually similar to ASCII `"` and cause parse errors in both shell and Python contexts. The `\uXXXX` escape workaround is fragile and error-prone.
2. **Preferred pattern:** Extract translations from subagent JSONL transcripts on disk (see Step 1 above). The `json.loads()` call happens in Python, where the German-quote fixer handles the only known failure mode. This keeps German text out of shell entirely.
3. **Validate JSON** after every write: `python3 -c "import json; json.load(open('Konjugieren/Models/Etymologies.json'))"`

## Important

- Launch all 5 subagents in a **single message** (parallel Agent tool calls). If the runtime limits tool calls per message, batch into 2–3 messages.
- Each subagent prompt must be fully self-contained — paste all translation rules and all ~20 English etymologies into each one.
- Do not translate etymologies yourself — delegate all translation to the subagents.
- After merging, verify tilde counts match between English and German for every verb before writing.
- Always update the "Next verb" in this file after successfully updating `Etymologies.json`.

## Lessons Learned

- **Tilde-wrapped phrases get dropped during restructuring.** Subagents sometimes restructure sentences and lose or add tilde markup. Common patterns: replacing `~phrase~` with `„phrase"` (German quotes), adding extra `~an~` markers around separable-prefix particles, or absorbing small tilde-wrapped words like `~to~` into natural prose. The subagent prompt now includes explicit instructions that tilde count must match.

- **Translators sometimes add tildes to words not marked in the English.** Examples: `~-urg~` (a suffix fragment), `~fine arts~` (an English phrase). The tilde-count verification in the merge script catches these before they enter `Etymologies.json`.

- **Subagent output files are JSONL transcripts, not raw JSON.** The `.output` files contain one JSON object per line (agent transcript format). The translation lives in the `message.content[0].text` field of the `type: "assistant"` line. A brace-matching JSON extractor will pick up transcript metadata objects instead.

- **German typographic quotes in JSON.** Subagents sometimes produce ASCII `"` (U+0022) where `"` (U+201C) was intended as a German closing quote. This breaks JSON parsing. Fix: regex-replace `„...ASCII"` → `„...\u201c` before `json.loads()`. The extraction script in "After Subagents Return → Step 1" handles this automatically — always use it rather than trying to parse subagent output directly.

- **Never use the Write tool for intermediate JSON files.** The Write tool writes content literally — it doesn't JSON-escape internal `"` characters. Always use Python's `json.dumps()` to write intermediate JSON:
   ```python
   import json, pathlib
   data = {"verb": "translation text..."}
   pathlib.Path('/tmp/de_group_N.json').write_text(json.dumps(data, ensure_ascii=False))
   ```
   If group files are already broken, they can be repaired by using the known verb names as delimiters to split the raw text and rebuild valid JSON via `json.dumps()`.

- **Never embed German translation text in Python heredocs or inline dicts.** Even with `python3 << 'ENDPY'`, constructing Python dicts with German text as inline string literals fails because typographic quotes and `\u` sequences interact badly with the heredoc parser. Instead, always extract translations from the subagent JSONL transcripts on disk using the Step 1 script — this avoids touching the text in any shell context.

- **3–5 subagents × 20 verbs works well.** 3×20 (batch of 60) uses less context than 5×20 (batch of 100) and still completes in reasonable time. Either split is fine depending on how many verbs remain. The earlier 10×10 split consumed too much context (10 prompt reads + 10 agent launches + 10 results), risking compaction mid-batch. If compaction does happen, agent task output files at `/private/tmp/claude-501/.../tasks/*.output` persist on disk and can be mined to recover results — the extraction script in Step 1 does exactly this.

- **Tilde mismatches on English cognates in prose.** The most common mismatch pattern is subagents tilde-wrapping English cognate words that appear in un-tilded prose. Example: EN says `to "drive" progress forward` (no tildes — the word is in regular quotes or unquoted) but DE produces `den Fortschritt ~drive~ forward` (spurious tildes added). Fix: remove the `~` delimiters from the affected word, leaving the word itself intact. Check the EN original to confirm the word is indeed untilded there.

- **"Next verb" means first remaining, not next after batch.** Verbs are not necessarily translated in strict alphabetical order — earlier batches may have gaps. After each batch, always compute the next verb by diffing EN and DE keys, not by assuming the verb after the last one in the batch.
