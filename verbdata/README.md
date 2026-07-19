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

## dwds-frequencies.json

| Fact | Value |
|---|---|
| Source | `https://www.dwds.de/api/frequency/`, one request per lemma |
| Fetched | 2026-07-19 |
| Records | 990 — every infinitive in `Konjugieren/Models/Verbs.xml`, 0 failures |
| Corpus | DWDS aggregate ("Gesamt"), 53,203,990,582 tokens |
| Fields | `lemma` (as asked), `dwds_lemma` (as resolved), `hits`, `total` |
| License | **Not open.** BBAW reserves § 44b UrhG; automated querying and reuse need explicit permission. Gitignored pending a reply from `dwds@bbaw.de`. |

Regenerate with `python3 verbdata/fetch_dwds_frequencies.py` (~4 minutes at 4 workers).
Pass `--lemmas FILE` to fetch an arbitrary list instead of the shipped corpus.

### Two traps this snapshot documents

**Strip every `Verbs.xml` marker, not just the obvious ones.** The `in` attribute uses
three: `+` (separable prefix), `*` (inseparable prefix), and `^` (ablaut region). A first
pass stripped `+` and `^` only, so all 305 inseparable-prefix verbs were queried as
`be*achten` and silently returned 0 hits — silently because the API answers such junk with
a well-formed zero rather than an error. Any future extraction keyed on `in` must strip
`[+*^]`.

**Compare `dwds_lemma` against `lemma`.** DWDS lemmatizes the query, and for a verb whose
infinitive is a homograph of some other lemma's inflected form, it resolves to the wrong
one. Ten of 990 mismatch, and the errors are large:

| Asked | DWDS resolved to | Hits |
|---|---|---|
| runden | rund (adjective) | 23,421,973 |
| gleichen | gleich (adjective) | 18,062,655 |
| lauten | laut (adjective) | 12,046,082 |
| achten | acht (numeral) | 7,240,939 |
| weißen | weiß (adjective) | 4,262,331 |
| tätigen | tätig (adjective) | 3,517,501 |
| regen | rege (adjective) | 803,503 |
| erschweren | erschwern | 690,834 |
| kreieren | kreiern | 539,870 |
| einigen | einig / einige / einigen | 0 |

The last three are lemmatizer quirks rather than homograph collisions; `reißen` → `reissen`
is mere ß-normalization and is not a mismatch. The mismatch check is a cheap, complete
filter for the real errors: every case above needs a hand-set value or exclusion.

One contamination case the check **cannot** catch: `sein` reports 833,809,998 hits, more
than twice `haben`, because the possessive pronoun *sein* shares both the lemma and the
lowercase spelling. It resolves to `sein`, so nothing looks wrong. It happens not to matter
— `sein` is rank 1 either way — but it is the shape of error to watch for.

Capitalization, by contrast, works *for* us: German orthography capitalizes nouns, so a
lowercase query is already a partial part-of-speech filter (`küren` → the verb, 439,640;
`Küren` → the noun *Kür*, 158,517).
