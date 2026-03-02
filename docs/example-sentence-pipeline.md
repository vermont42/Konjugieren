# Example-Sentence Extraction Pipeline

This document describes how to extract example sentences from the literary corpus in `corpus/` for all 988 verbs. The output is `ExampleSentences.json`, following the same structure as `Etymologies.json`.

## Corpus Overview

The corpus lives in the gitignored `corpus/` directory. See `corpus/README.md` for full source details.

### German Sources (for sentence extraction)

| File | Chars | Era | Notes |
|------|-------|-----|-------|
| `luther-bible-de.txt` | 4.2M | 1534/1912 | Largest source; archaic spelling (daß, ward) |
| `nietzsche-zarathustra-de.txt` | 565K | 1885 | Rich philosophical vocabulary |
| `grimm-maerchen-de.txt` | 562K | 1921 ed. | Narrative prose; good for common verbs |
| `kafka-prozess-de.txt` | 506K | 1925 | Modern literary German |
| `nietzsche-jenseits-de.txt` | 426K | 1886 | Dense abstract language |
| `westphalia-de.txt` | 346K | 1648 | 17th-century German; archaic spelling (vnd, Käyserlich) |
| `mann-venedig-de.txt` | 196K | 1912 | Elegant prose |
| `grundgesetz-de.txt` | 194K | 1949 | Legal German |
| `goethe-werther-de.txt` | 133K | 1774 | Epistolary style |
| `weimar-verfassung-de.txt` | 77K | 1919 | Legal/constitutional German |

### English Sources (for parallel translations)

Each German source has an English counterpart (except Luther Bible and Westphalia-de). These can provide translation context but the subagent should produce its own faithful translations.

### Medieval Sources (top 30 verbs only)

`corpus/medieval/` contains the Hildebrandslied, Tatian excerpts, and Oaths of Strasbourg. These are for the `medieval` sub-key in the JSON output for the top 30 verbs.

## Preprocessing

### Gutenberg Header/Footer Stripping

Gutenberg texts have boilerplate before `*** START OF THE PROJECT GUTENBERG EBOOK ... ***` and after `*** END OF THE PROJECT GUTENBERG EBOOK ... ***`. Strip these before feeding to the subagent:

```python
import re

def strip_gutenberg(text: str) -> str:
    start = re.search(r'\*\*\* START OF.*?\*\*\*', text)
    end = re.search(r'\*\*\* END OF.*?\*\*\*', text)
    if start and end:
        return text[start.end():end.start()].strip()
    return text
```

Affected files: all `goethe-*`, `kafka-*`, `mann-*`, `grimm-*`, `nietzsche-*` files.

### Sentence Pre-Filtering (Optional Optimization)

The combined German corpus is ~6.5MB. If context-window limits become an issue, a Python pre-filter can reduce input size by grepping for likely verb forms. However, since the subagent can read files directly from `corpus/`, this step may be unnecessary for small batches.

## Output JSON Schema

Follows `Etymologies.json` structure — keyed by language, then by verb infinitive:

```json
{
  "en": {
    "singen": {
      "sentence": "She sang until the whole forest seemed to listen.",
      "source": "Grimm — Märchen"
    },
    "sein": {
      "sentence": "Someone must have been telling lies about Josef K.",
      "source": "Kafka — The Trial",
      "medieval": {
        "sentence": "dat sih urhettun ænon muotin",
        "source": "Hildebrandslied (c. 830)",
        "note": "OHG 'sih' (reflexive of 'sein'): 'that they challenged each other'"
      }
    }
  },
  "de": {
    "singen": {
      "sentence": "Sie sang, bis der ganze Wald zu lauschen schien.",
      "source": "Grimm — Märchen"
    },
    "sein": {
      "sentence": "Jemand mußte Josef K. verleumdet haben, denn ohne daß er etwas Böses getan hätte, wurde er eines Morgens verhaftet.",
      "source": "Kafka — Der Proceß",
      "medieval": {
        "sentence": "dat sih urhettun ænon muotin",
        "source": "Hildebrandslied (ca. 830)",
        "note": "Ahd. ‚sih' (Reflexivform von ‚sein'): ‚dass sie sich einzeln zum Kampf stellten'"
      }
    }
  }
}
```

### Schema Rules

- Every verb in `docs/frequencies.txt` must have an entry under both `"de"` and `"en"`.
- `"sentence"` is a complete, self-contained sentence (not a fragment).
- `"source"` uses the display format from the table below.
- `"medieval"` key is present only for the top 30 verbs (see list below).
- The `"en"` sentence is a faithful translation of the German, not a separate English-source sentence.

### Source Display Names

| Corpus file prefix | `source` value |
|--------------------|----------------|
| `goethe-werther` | Goethe — Die Leiden des jungen Werthers |
| `kafka-prozess` | Kafka — Der Proceß |
| `mann-venedig` | Mann — Der Tod in Venedig |
| `grimm-maerchen` | Grimm — Märchen |
| `nietzsche-zarathustra` | Nietzsche — Also sprach Zarathustra |
| `nietzsche-jenseits` | Nietzsche — Jenseits von Gut und Böse |
| `luther-bible` | Luther — Bibel |
| `grundgesetz` | Grundgesetz (1949) |
| `westphalia` | Westfälischer Friede (1648) |
| `weimar-verfassung` | Weimarer Verfassung (1919) |

## Extraction Workflow

### Phase 1: Dry Run (3 Verbs)

Start with a manual prompt for 3 test verbs to validate the approach. Suggested test verbs spanning different difficulty levels:

- **sein** — extremely common, highly irregular, should be easy to find
- **singen** — strong verb with clear ablaut, moderate frequency
- **absichern** — separable-prefix verb, less common, may need deeper search

The dry-run prompt should instruct the subagent to:
1. Read the German corpus files from `corpus/modern/`
2. Search for any conjugated form of each verb
3. Select a complete, interesting sentence
4. Provide a faithful English translation
5. Output JSON in the schema above

### Phase 2: Prompt Refinement

Based on dry-run results, refine the prompt for:
- Sentence quality (complete vs. fragment, interesting vs. mundane)
- Source diversity (not always picking the same book)
- Separable-prefix handling (recognizing "er sicherte das Gebäude ab" as absichern)
- Translation quality
- Edge cases (reflexive verbs, modal verbs in auxiliary position)

### Phase 3: Batch Extraction

Run batches of ~30–40 verbs, drawing from `docs/frequencies.txt` in order. Group prefixed compounds with their base verbs (e.g., stehen/bestehen/verstehen/entstehen in one batch) so the subagent sees related passages together.

Suggested batching: ~25–33 subagents for 988 verbs. Run 3 in parallel per round.

### Phase 4: Medieval Pass (Top 30 Only)

A separate subagent searches `corpus/medieval/` for OHG forms of these verbs:

sein, werden, haben, können, geben, müssen, sollen, machen, kommen, gehen, finden, lassen, wollen, stehen, sehen, sagen, stellen, mögen, liegen, nehmen, zeigen, bieten, bleiben, dürfen, wissen, führen, bringen, halten, erhalten, bekommen

The medieval texts are short and OHG forms differ substantially from modern German, so this subagent needs linguistic knowledge rather than brute-force search.

### Phase 5: Merge and Gap-Fill

1. Collect JSON output from all subagents
2. Validate: all 988 verbs present under both `"de"` and `"en"`
3. Validate: top 30 verbs have `"medieval"` keys
4. For missing verbs: run a second-pass subagent focused on gaps, searching more creatively
5. JSON validation: `python3 -c "import json; json.load(open('ExampleSentences.json'))"`

## Why Subagents Work

Claude understands German grammar natively. It can:
- Recognize "sang" as Präteritum of "singen"
- Identify separable-prefix verbs ("er rief sie an" → anrufen)
- Distinguish homographs ("sie stellen" vs. "die Stellen")
- Parse 17th-century spelling ("vnd" = "und", "auffgericht" = "aufgerichtet")
- Extract clean sentence boundaries from running prose
- Produce faithful English translations

This is far more reliable than regex-based conjugation matching, which would require generating all ~50 conjugated forms per verb and still miss irregular patterns.

## File Locations

| File | Purpose |
|------|---------|
| `corpus/` | Downloaded source texts (gitignored) |
| `corpus/README.md` | Source documentation |
| `docs/frequencies.txt` | 988 verbs in frequency order |
| `docs/example-sentence-pipeline.md` | This file |
| `Konjugieren/Models/Etymologies.json` | Pattern for output structure |
| `ExampleSentences.json` (future) | Pipeline output |
