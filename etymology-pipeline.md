# Etymology Translation Pipeline

## Progress

**Next verb: bestehen**

**BATCH SIZE: 50**

## Task

Read `Konjugieren/Models/Etymologies.json`, take the next BATCH SIZE verbs (alphabetically by key in the `"en"` object) starting at the verb above. Launch parallel subagents to translate each English etymology into German. Merge results back into the same file under a new `"de"` key.

## Architecture

Launch up to 10 `general-purpose` subagents **in parallel** (in a single message with multiple Agent tool calls). Each subagent receives ONE verb's English etymology and returns a German translation as a JSON fragment. After all return, verify and merge the fragments into `Etymologies.json`.

### Subagent prompt template

Give each subagent the following prompt, substituting the VERB SECTION. The subagent prompt must be **self-contained** — include all translation rules inline, since the subagent cannot see this file.

---

**Begin subagent prompt (copy fully for each verb, substituting VERB SECTION):**

> You are translating a German-verb etymology from English into German. Do NOT write any files. Return ONLY the JSON result at the end.
>
> ## Your Verb
>
> VERB SECTION (see below)
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
> {"INFINITIVE": "GERMAN ETYMOLOGY TEXT"}
>
> **JSON and special characters:** German typographic quotes (`„` U+201E, `"` U+201C) and special letters (`ä`, `ö`, `ü`, `ß`) are safe to include directly in JSON string values — they are distinct from the ASCII `"` (U+0022) used as JSON delimiters. Do NOT escape them as `\uXXXX` in your output; write them as literal characters.

**End subagent prompt.**

---

### Verb-specific sections

For each verb, construct the VERB SECTION like this:

```
**Verb:** abbauen
**English etymology to translate:**

[Paste the full English etymology text here, verbatim]
```

## After Subagents Return

1. **Parse** the JSON fragment from each subagent's response. The subagent may include extra text around the JSON — extract the JSON object.
2. **Verify markup preservation**: For each translation, count the number of `~` characters in the English original and the German translation. They MUST match. Also spot-check that reconstructed forms (anything starting with `*~`) appear unchanged.
3. **Merge into Etymologies.json**: Use Python via Bash to read the existing file, add a `"de"` key (or merge into existing `"de"`), and write back. Use the merge script pattern below.
4. **Validate JSON** after every write.
5. Print a summary table: verb | first 60 chars of German translation | tilde count match (Y/N)
6. **Update this file**: Change "Next verb" to the next unprocessed verb alphabetically. If all 989 verbs are done, note that translation is complete.

### Merge script pattern

Write a Python script to `/tmp/merge_etymologies.py`, then run it:

```python
import json
import pathlib

p = pathlib.Path('Konjugieren/Models/Etymologies.json')
data = json.loads(p.read_text())

# Initialize "de" key if it doesn't exist
if 'de' not in data:
    data['de'] = {}

# New translations from this batch
new_translations = {
    # "abbauen": "German translation text here...",
}

# Merge new translations
data['de'].update(new_translations)

# Sort keys within each language object
for lang in data:
    data[lang] = dict(sorted(data[lang].items()))

# Sort top-level keys so "de" comes before "en"
data = dict(sorted(data.items()))

p.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n')
print("Merged successfully.")
```

Then validate:

```bash
python3 -c "import json; json.load(open('Konjugieren/Models/Etymologies.json')); print('Valid JSON')"
```

## JSON Munging Advice

These lessons are carried over from the example-sentence pipeline:

1. **Never use `cat > file << 'EOF'` heredocs** to write JSON containing German text. Typographic quotes (`„"`) are visually similar to ASCII `"` and cause parse errors.
2. **Never embed German text in Python heredocs (`<< 'PYEOF'`)**. The closing `"` (U+201C) next to an ASCII `"` confuses the parser.
3. **Use `\uXXXX` escapes** in Python string literals when constructing sentences with typographic quotes: `\u201e` for `„`, `\u201c` for `"`, `\u00bb` for `»`, `\u00ab` for `«`.
4. **Preferred pattern:** Write a Python script to a file with the Write tool, then run it with Bash. This avoids all heredoc quoting issues.
5. **Validate JSON** after every write: `python3 -c "import json; json.load(open('Konjugieren/Models/Etymologies.json'))"`

## Important

- Launch all subagents in a **single message** (parallel Agent tool calls). If the runtime processes them sequentially despite parallel invocation, batch into groups of 3–4 per message as a practical compromise to reduce round trips.
- Each subagent prompt must be fully self-contained — paste all translation rules and the English etymology into each one.
- Do not translate etymologies yourself — delegate all translation to the subagents.
- After merging, verify tilde counts match between English and German for every verb before writing.
- Always update the "Next verb" in this file after successfully updating `Etymologies.json`.

## Lessons Learned

### Run 1 (abnehmen → anstreben, 50 verbs)

1. **Tilde-wrapped phrases get dropped during restructuring.** The most common error (3/50 verbs) was subagents restructuring sentences and losing or adding tilde markup. Examples:
   - `anstellen`: EN had `~jemanden anstellen~`, `~das Wasser anstellen~`, `~sich anstellen~` (×2). The DE replaced these with `„jemanden anstellen"` (German quotes) instead of keeping tilde markup — losing 8 tildes.
   - `anpassen`: DE added extra `~an~` markers around separable-prefix particles that the EN didn't mark — gaining 4 tildes.
   - `ansagen`: EN had `~to~` as a tilde-wrapped directional word. DE absorbed it into natural prose — losing 2 tildes.
   - **Fix applied to prompt:** Added explicit instruction that tilde count must match, with examples of common failure patterns.

2. **Subagent output files are JSONL transcripts, not raw JSON.** The `.output` files contain one JSON object per line (agent transcript format). The translation lives in the `message.content[0].text` field of the `type: "assistant"` line. A brace-matching JSON extractor will pick up transcript metadata objects instead.

3. **German typographic quotes in JSON.** Subagents sometimes produce ASCII `"` (U+0022) where `"` (U+201C) was intended as a German closing quote. This breaks JSON parsing. Fix: regex-replace `„...ASCII"` → `„...\u201c` before `json.loads()`.

4. **Batching 5 verbs per subagent works well.** 10 parallel agents × 5 verbs each completed in ~30–45 seconds. All 50 translations returned successfully on the first attempt.
