# verbdata

Data files supporting the verb-corpus expansion described in [`docs/verb-sources.md`](../docs/verb-sources.md). The JSONL below is gitignored (`verbdata/*.jsonl`); this README is tracked so that provenance and the re-download recipe live in git.

This folder sits at the repo root deliberately: the `Konjugieren/` app directory uses Xcode folder references, so any file placed there joins the app target. A 294 MB data file must stay outside it.

## kaikki.org-dictionary-German-by-pos-verb.jsonl

| Fact | Value |
|---|---|
| Source | `https://kaikki.org/dictionary/German/pos-verb/kaikki.org-dictionary-German-by-pos-verb.jsonl` |
| Downloaded | 2026-07-18 |
| Size | 308,208,774 bytes (293.9 MB) |
| SHA-256 | `76d5222ae6baa2a68e20536c9bfdbc538a10e0c6b7c7802bd3933aa3d61062cb` |
| License | CC BY-SA 4.0 (Wiktionary text, machine-extracted by the wiktextract project / kaikki.org; attribution belongs in the Credits article if derived data ships) |
| Records | 87,343, one JSON object per line; every line validated as parseable JSON on download day |
| Form-of records | 76,503 (conjugations with their own Wiktionary pages; useful as a conjugation-to-lemma map) |
| Lemma records | 10,840, of which 9,759 are single-word lemmas |
| Single-word lemmas with `etymology_text` | 8,395 |
| Single-word lemmas with `forms[]` tables | 9,505 |
| Single-word lemmas absent from Konjugieren's current 990 | 8,736 |

These counts differ slightly from the category-membership numbers in `docs/verb-sources.md` (10,407 category lemmas; 8,346 missing) because the category crawl filtered titles by infinitive-shaped endings and reflects live category membership, while these counts come from the snapshot's own records.

**Record structure:** `word`, `pos`, `senses[].glosses` (English, labeled), `etymology_text` (plain prose, wiki templates resolved), and `forms[]` tagged by person, number, mood, and auxiliary, plus `table-tags` entries carrying Wiktionary's own weak/strong classification. Lemma filtering: keep records in which no sense contains `form_of`.

**Re-download** (upstream refreshes regularly; the SHA-256 above pins this snapshot):

```bash
curl -C - -A "Konjugieren verb research (contact: <email>)" \
  -o verbdata/kaikki.org-dictionary-German-by-pos-verb.jsonl \
  "https://kaikki.org/dictionary/German/pos-verb/kaikki.org-dictionary-German-by-pos-verb.jsonl"
```
