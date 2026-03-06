# Example-Sentence Extraction

## Progress

**Next verb number: 697** ← matches the number in column 1 of `docs/frequencies.txt` (988 verbs total). For example, 597 means the line that starts with `597`.

**BATCH SIZE: 50**

## Task

Read `docs/frequencies.txt` and take the next [BATCH SIZE] verbs starting at the verb number above (or fewer if near the end of the file). Find one excellent example sentence for each verb from the literary corpus in `corpus/modern/`. Use parallel subagents — one per verb — then merge their results into the master `ExampleSentences.json`.

## Architecture

Launch up to 10 `general-purpose` subagents **in parallel** (in a single message with multiple Agent tool calls). Each subagent searches the corpus for ONE verb and returns a JSON fragment. After all return, verify and merge the fragments into `ExampleSentences.json`.

### Source rotation

To ensure source diversity, assign each subagent a **preferred source** using the verb's number (from column 1 of `frequencies.txt`) modulo 10:

| Number mod 10 | Preferred source file |
|--------------|----------------------|
| 0 | `goethe-werther-de.txt` |
| 1 | `kafka-prozess-de.txt` |
| 2 | `mann-venedig-de.txt` |
| 3 | `grimm-maerchen-de.txt` |
| 4 | `nietzsche-zarathustra-de.txt` |
| 5 | `nietzsche-jenseits-de.txt` |
| 6 | `luther-bible-de.txt` |
| 7 | `grundgesetz-de.txt` |
| 8 | `westphalia-de.txt` |
| 9 | `weimar-verfassung-de.txt` |

Include the preferred source in the subagent prompt's VERB SECTION. If the verb isn't found in the preferred source, the subagent should try other sources in random order until it finds a good sentence.

### Subagent prompt template

Give each subagent the following prompt, substituting the verb-specific section. The subagent prompt must be **self-contained** — include all corpus info, search instructions, and quality criteria inline, since the subagent cannot see this file.

---

**Begin subagent prompt (copy fully for each verb, substituting VERB SECTION):**

> You are searching a German literary corpus to find one excellent example sentence for a specific verb. Do NOT write any files. Just return the JSON result at the end.
>
> ## Your Verb
>
> VERB SECTION (see below)
>
> ## Corpus
>
> German source texts are in `corpus/modern/`. Each file is plain text. **Skip Gutenberg boilerplate**: ignore everything before `*** START OF THE PROJECT GUTENBERG EBOOK` and after `*** END OF THE PROJECT GUTENBERG EBOOK` in Gutenberg files (goethe-*, kafka-*, mann-*, grimm-*, nietzsche-*). The other files (luther-bible-de.txt, grundgesetz-de.txt, westphalia-de.txt, weimar-verfassung-de.txt) have no such boilerplate.
>
> **Spelling note:** Pre-reform texts (Goethe, Kafka, Mann, Grimm, Nietzsche) use `ß` after short vowels (e.g., `muß`, `daß`, `läßt`). Post-reform texts (Grundgesetz) use `ss`. Always search for both variants.
>
> The files and their source display names:
>
> | File | Source display name |
> |------|-------------------|
> | `goethe-werther-de.txt` | Goethe — Die Leiden des jungen Werthers |
> | `kafka-prozess-de.txt` | Kafka — Der Proceß |
> | `mann-venedig-de.txt` | Mann — Der Tod in Venedig |
> | `grimm-maerchen-de.txt` | Grimm — Märchen |
> | `nietzsche-zarathustra-de.txt` | Nietzsche — Also sprach Zarathustra |
> | `nietzsche-jenseits-de.txt` | Nietzsche — Jenseits von Gut und Böse |
> | `luther-bible-de.txt` | Luther — Bibel |
> | `grundgesetz-de.txt` | Grundgesetz (1949) |
> | `westphalia-de.txt` | Westfälischer Friede (1648) |
> | `weimar-verfassung-de.txt` | Weimarer Verfassung (1919) |
>
> **Fallback: Government reports** are in `corpus/government/`. Search these only if the verb isn't found in any literary source above. They use modern administrative German and cover verbs like *funktionieren*, *erstellen*, *planen*, *informieren*, *präsentieren*, and *umsetzen*.
>
> | File | Source display name |
> |------|-------------------|
> | `berufsbildungsbericht-2024-de.txt` | Berufsbildungsbericht (2024) |
> | `bundesverkehrswegeplan-2030-de.txt` | Bundesverkehrswegeplan (2030) |
> | `raumfahrtstrategie-2023-de.txt` | Raumfahrtstrategie (2023) |
> | `raumordnungsbericht-2021-de.txt` | Raumordnungsbericht (2021) |
> | `bufi-kurzfassung-2024-de.txt` | BuFI Kurzfassung (2024) |
> | `digitale-strategie-2025-de.txt` | Digitale Strategie (2025) |
> | `ki-strategie-2020-de.txt` | KI-Strategie (2020) |
>
> **Technology fallback:** If the verb isn't found in any `corpus/modern/` or `corpus/government/` file, search `corpus/technology/` files next. These BSI guides and Wikipedia articles contain technology verbs like *installieren*, *speichern*, *klicken*, *aktualisieren*, *verschlüsseln*, *testen*, *deaktivieren*, etc.
>
> | File | Source display name |
> |------|-------------------|
> | `bsi-passwoerter-2024-de.txt` | BSI — Sichere Passwörter erstellen |
> | `bsi-accountschutz-de.txt` | BSI — Accountschutz |
> | `bsi-benutzerkonten-de.txt` | BSI — Benutzerkonten einrichten |
> | `bsi-basisschutz-computer-de.txt` | BSI — Basisschutz für Computer |
> | `bsi-router-wlan-vpn-de.txt` | BSI — Router, WLAN und VPN |
> | `bsi-grundschutz-software-tests-2023-de.txt` | BSI — Software-Tests und -Freigaben (2023) |
> | `bsi-grundschutz-patch-management-2023-de.txt` | BSI — Patch- und Änderungsmanagement (2023) |
> | `bsi-grundschutz-datensicherung-2023-de.txt` | BSI — Datensicherungskonzept (2023) |
> | `wiki-hilfe-bearbeiten-de.txt` | Wikipedia — Hilfe:Bearbeiten |
> | `wiki-hilfe-dateien-de.txt` | Wikipedia — Hilfe:Dateien |
> | `wiki-datensicherung-de.txt` | Wikipedia — Datensicherung |
> | `wiki-softwaretest-de.txt` | Wikipedia — Softwaretest |
> | `wiki-installation-de.txt` | Wikipedia — Installation (Software) |
> | `wiki-verschluesselung-de.txt` | Wikipedia — Verschlüsselung |
> | `wiki-firewall-de.txt` | Wikipedia — Firewall |
>
> ## How to Search
>
> 1. **Start with your preferred source** (specified in the verb section above). Use Grep to search that file first for likely conjugated forms. Cast a wide net — include stem variations, prefixes, and participles. For separable-prefix verbs, also search for the separated particle pattern (e.g., grep for both "absichern" and "sichert.*ab" and "abgesichert").
> 2. If you find a good sentence in the preferred source, use it. If not (the verb doesn't appear, or only appears in bland/fragmentary contexts), try other `corpus/modern/` files in any order until you find a good sentence.
> 3. **Government fallback:** If the verb isn't found in any `corpus/modern/` file, search `corpus/government/` files next. Government reports use modern administrative German and cover verbs like *funktionieren*, *erstellen*, *planen*, *informieren*, *präsentieren*, and *umsetzen* that rarely appear in the literary corpus.
> 4. **Technology fallback:** If the verb isn't found in any `corpus/modern/` or `corpus/government/` file, search `corpus/technology/` files next. BSI guides and Wikipedia articles cover technology verbs like *installieren*, *speichern*, *klicken*, *aktualisieren*, *verschlüsseln*, *testen*, *deaktivieren*, etc.
> 5. **Line wraps:** Corpus files wrap at ~70 characters. A sentence often spans 2–3 lines. After finding a match with Grep, always use Read with offset/limit (or Grep with `-C 3`) to see surrounding lines and reconstruct the full sentence.
> 6. Select the best sentence according to the quality criteria below.
>
> ## Sentence Quality Criteria
>
> Prefer sentences that are:
>
> 1. **Complete and self-contained** — understandable without surrounding context. Not a fragment or clause.
> 2. **Interesting or memorable** — a vivid image, a famous line, a striking thought. Avoid bland filler sentences.
> 3. **Reasonably short** — ideally under 40 words. If a great sentence is long, it's OK, but don't pick a 100-word run-on.
> 4. **Clearly using the target verb** — the verb should be prominent, not buried in a subordinate clause where it's barely noticeable.
> 5. **Dialogue is fine** — if the best sentence is character speech embedded in narration (e.g., `»Das können wir...«`), extract the spoken words as a standalone sentence. Replace the trailing comma-plus-closing-quote with a period. Note: the sentence must still appear verbatim in the corpus — only the punctuation at the boundary changes.
>
> ## Output
>
> Return ONLY a JSON object in this exact format (no markdown fencing, no extra text):
>
> {"de":{"INFINITIVE":{"sentence":"GERMAN SENTENCE","source":"SOURCE DISPLAY NAME"}},"en":{"INFINITIVE":{"sentence":"ENGLISH TRANSLATION","source":"SOURCE DISPLAY NAME"}}}
>
> Rules:
> - The German sentence must actually appear in the corpus file. Do not fabricate sentences.
> - Preserve original spelling exactly (daß not dass, mußte not musste).
> - The English sentence is your own faithful translation — do NOT search the English corpus files. Aim for natural, literary-quality English.
> - If the verb genuinely cannot be found in any corpus file, return: {"notFound":"INFINITIVE","reason":"explanation"}
> - **JSON and smart quotes:** German texts use typographic quotes (»«, „") that are DIFFERENT characters from the ASCII double quote (`"`, U+0022) used as JSON delimiters. NEVER replace typographic quotes with ASCII quotes in your JSON output — leave them as-is. If your sentence contains dialogue with typographic quotes, they will coexist safely with the JSON structure. Example: `{"de":{"rufen":{"sentence":"„Wo bist du?" rief er.","source":"Luther — Bibel"}}}` — here `„` (U+201E) and `"` (U+201C) are string content, while `"` (U+0022) is JSON syntax. Mixing them up breaks the JSON parser.

**End subagent prompt.**

---

### Verb-specific sections

For each verb, construct the VERB SECTION by describing the verb and its key conjugated forms. Include:
- The infinitive
- Whether it's regular, strong (with ablaut pattern), irregular, modal, separable-prefix, etc.
- Key forms to search for (Präsens, Präteritum, Konjunktiv II, Partizip II)
- For separable-prefix verbs: both joined and separated search patterns
- Any special notes (e.g., "prefer independent meaning over auxiliary use" for sein/haben/werden)
- **Source priority**: "Search `FILENAME` first (your preferred source). If the verb isn't there or only appears in bland contexts, try other sources." — using the source rotation table above

## After Subagents Return

1. Parse the JSON fragment from each subagent's response. The subagent may include extra text around the JSON — extract the JSON object.
2. Merge the fragments into a combined object with `"de"` and `"en"` keys, each containing the new verb entries.
3. If any subagent returned `notFound`, note the gap in the summary, do not add an entry to the JSON, and **append the verb to `docs/missing_verbs.md`** (preserving the existing table format).
4. **Verify** each German sentence actually exists in the corpus: use Grep to confirm a unique multi-word substring (not the full sentence) appears in the claimed source file. Full-sentence matching is unreliable because corpus lines wrap at ~70 characters, and `goethe-werther-de.txt` uses double spaces between sentences (e.g., `leidet.  Ich`), which won't match a single-space version.
5. **Update the master file**: Read the existing `ExampleSentences.json` at the project root (create it if it doesn't exist). Merge the new verb entries into the existing `"de"` and `"en"` objects — do not overwrite existing entries. Write the updated file back with pretty-printed JSON (2-space indent, keys sorted alphabetically within each language object). Use Python for the merge to ensure correctness:
   ```
   python3 -c "
   import json, pathlib
   p = pathlib.Path('ExampleSentences.json')
   master = json.loads(p.read_text()) if p.exists() else {'de': {}, 'en': {}}
   new = NEW_ENTRIES_HERE
   for lang in ('de', 'en'):
       master[lang].update(new.get(lang, {}))
       master[lang] = dict(sorted(master[lang].items()))
   p.write_text(json.dumps(master, indent=2, ensure_ascii=False) + '\n')
   "
   ```
6. Print a summary table: verb | source | first 60 chars of German sentence | verified/not-found/failed-verification.
7. **Update this file**: Change the "Next verb number" at the top of this file to current + (number of verbs processed). Also update the verb list under "## Task" to show the next batch of verbs from `docs/frequencies.txt`. If the new number > 988, note that extraction is complete.
8. **Integrate into the app bundle**: Invoke the `/integrate` skill to merge the updated `ExampleSentences.json` into the app's bundled data.

## Medieval Examples (deferred)

The top 30 verbs (indices 0–29) also need a `"medieval"` sub-key with an Old High German example from `corpus/medieval/`. This is handled in a separate pass — see `docs/example-sentence-pipeline.md` Phase 4. Do NOT search `corpus/medieval/` in this prompt.

## Important

- Launch all subagents in a **single message** (parallel Agent tool calls).
- Each subagent prompt must be fully self-contained — paste all corpus info and criteria into each one.
- Do not search the corpus yourself — delegate all searching to the subagents.
- After merging, verify every German sentence against the corpus before updating the master file.
- Always update the "Next verb number" in this file after successfully updating `ExampleSentences.json`.
- If a verification fails (sentence not found in corpus), exclude that verb from the master file and note it in the summary. It can be retried in a future run.

## Lessons Learned

### Heredoc and PYEOF quoting hazards

German typographic quotation marks (`„` U+201E, `"` U+201C, `"` U+201D, `»` U+00BB, `«` U+00AB) visually resemble ASCII `"` (U+0022) but are distinct Unicode characters. When constructing JSON data containing German sentences:

1. **Never use `cat > file << 'EOF'` heredocs to write JSON** that contains German dialogue. The typographic quotes `"` and `"` are indistinguishable from JSON delimiters in many contexts, causing `JSONDecodeError`.
2. **Never embed German sentences in Python `<< 'PYEOF'` heredocs as string literals.** The closing `"` (U+201C) at the end of a German quotation immediately followed by `"` (ASCII, JSON) confuses the parser.
3. **Use Python `\uXXXX` escapes** when constructing sentences with typographic quotes: `\u201e` for `„`, `\u201c` for `"`, `\u00bb` for `»`, `\u00ab` for `«`, `\u00df` for `ß`, `\u00e4` for `ä`, etc.
4. **Preferred pattern:** Write a Python script to a file with `Write`, then run it with `Bash`. This avoids all heredoc quoting issues. Example:
   ```python
   # Write to /tmp/merge.py, then run: python3 /tmp/merge.py
   def add(verb, de_sent, de_src, en_sent, en_src):
       new["de"][verb] = {"sentence": de_sent, "source": de_src}
       new["en"][verb] = {"sentence": en_sent, "source": en_src}
   add("st\u00e4rken", "\u201eBring ihm die Suppe,\u201c sagte er.", "Kafka \u2014 Der Proce\u00df", ...)
   ```
5. **Source name normalization** is essential. Subagents return variant source names (e.g., "Grimm, Aschenputtel" vs. "Grimm — Märchen", "Nietzsche, Also sprach Zarathustra (1883)" vs. "Nietzsche — Also sprach Zarathustra"). Build a comprehensive normalization map covering both German and English name variants.

### Sentence text reconstruction after verification

A grep match confirms the verb exists in the claimed source file, but does NOT guarantee the subagent's surrounding sentence text is correct. Subagents frequently introduce subtle word-level errors — wrong nouns, different prepositional phrases, or an entirely different sentence for the same verb (e.g., a subagent returned "Gartenpforte" but the corpus has "Gartenterrasse"; "steinralte" instead of "steinalte"; a wholly different `einreichen` sentence than what's in Kafka). After a grep verification succeeds:

1. Use `Read` with the matched line number (± 3 lines of context) to get the exact corpus text.
2. Reconstruct the full sentence from the corpus, not from the subagent's output.
3. Use the corpus text verbatim in the merge script.

This is especially important when writing the Python merge script — always go back to the corpus for the definitive wording.

### Context window management

Processing 50 verbs in a single session risks hitting the context limit before writing results to disk. Mitigation strategies:
- **Write intermediate results** to a temp JSON file after each batch of 10 agents returns, not just at the end.
- **If the session is continued** after compaction, extract prior results from the old transcript at `~/.claude/projects/.../SESSION_ID.jsonl` using regex. Agent results appear in `<result>...</result>` tags. Sentences with escaped quotes (`\"`) inside the JSON require special handling — search for each verb individually rather than using a single regex.
- The transcript is JSONL with nested JSON escaping. Typographic quotes survive fine, but sentences containing `\"` (escaped ASCII quotes within JSON strings) break simple extraction regexes. Use per-verb block extraction (find the block, print its tail) instead.
