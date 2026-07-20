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
| License | CC BY-SA 4.0 (Wiktionary text, machine-extracted by the wiktextract project / kaikki.org). Derived data ships as of tranche 1 (2026-07-19), so the attribution is live: see the `Verb Data` section of `Info.creditsText` in `Konjugieren/Assets/Localizable.xcstrings`, added 2026-07-20. It names Wiktionary and the license, states that the data was modified, links kaikki.org, and gives the Ylonen LREC citation kaikki requests. |
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

## The classify-and-verify pipeline

Three scripts and one test suite turn the snapshot above into classified verbs. Full design
and findings: [`docs/verb-classification.md`](../docs/verb-classification.md).

| File | Role | Tracked |
|---|---|---|
| `build_candidates.py` | Stage A: kaikki JSONL → `candidates.json`, one normalized conjugation table per single-word lemma | yes |
| `candidates.json` | 9,217 candidates, 14.5 MB, ~6 s to rebuild | no |
| `../KonjugierenTests/Utils/VerbClassificationTests.swift` | Stage B: drives `Conjugator` over every candidate, searching for the `Verbs.xml` encoding that reproduces Wiktionary's table | yes |
| `classification.json` | Per-verb results, ~40 s to rebuild | no |
| `summarize_classification.py` | Stage C: renders the queue grouped by cause | yes |
| `classification-summary.md` | The rendered report | no |

Pass `--include-existing` to `build_candidates.py` (the default invocation does) so the 985
shipping verbs stay in the candidate set. For those the correct answer is already in
`Verbs.xml`, which turns them into a regression oracle: a shipping verb that fails to verify is
a defect, not an unknown. The first run found 354 such verbs.

## The etymology reuse files

Phase 3 of [`prompts/uses_etymologies.md`](../prompts/uses_etymologies.md). Three lookup tables
that let a Phase 4 subagent *compose* a compound verb's etymology from parts instead of
re-deriving one, keyed so it can look up rather than search.

| File | Key | Value | Tracked |
|---|---|---|---|
| `roots.json` | final root infinitive | markup-ready string | yes |
| `prefixes-inseparable.json` | bare prefix (`ver`, not `ver-`) | `{chain, senses, occurrences}` | yes |
| `prefixes-separable.json` | bare particle (`ab`, `tot`, `preis`) | `{kind, chain, senses, occurrences}` | yes |
| `build_reuse_files.py` | — | seeds the above from existing entries, emits the gap worklist | yes |
| `merge_reuse_files.py` | — | folds authored shards in; `--validate-only` re-checks | yes |

All three carry `{"de": {...}, "en": {...}}`, language first — the same shape as
`Konjugieren/Models/Etymologies.json`, and the same trap: reading them verb-first silently
reports zero coverage.

**Why prefixes get an object and roots get a string.** A root bullet in the existing corpus is
reusable whole. A prefix bullet is not: it welds a genealogy that is identical across every
compound to a final sentence glossing what the prefix contributes *to that compound*. Only the
genealogy is `chain`; `senses` holds the range of contributions, so a composed etymology can
pick the one that fits rather than repeating a single frozen gloss across 189 *ver-* verbs.

### `kind`, and why the entry count misleads

German's separable prefixes are an **open class**, so `prefixes-separable.json` is not a list
of 233 prefixes. Each entry records one of seven kinds, since a composing subagent treats them
differently. Derive the tally rather than quoting one:

```bash
python3 -c "import json,collections; d=json.load(open('verbdata/prefixes-separable.json'))['en']; \
print(collections.Counter(v['kind'] for v in d.values()))"
```

| kind | what it is |
|---|---|
| `particle` | an old preposition or adverb grammaticalized into a separable prefix |
| `deictic` | a *her-*/*hin-*/*da(r)-*/*-einander* compound, including colloquial contractions |
| `adjective` | an adjective in a resultative frame — *totschlagen* is to beat until dead |
| `adverb` | a free modern adverb, neither a deictic compound nor resultative |
| `noun` | a noun incorporated as object or adverbial — *teilnehmen*, *preisgeben* |
| `verb` | a verb used as a particle — *stehenbleiben*, *steckenbleiben* |
| `fossil` | strictly bound: not a free word of modern German at all |

**Count entries and count occurrences and you get opposite pictures.** Adjectives are the
largest class by entry and nearly the smallest by use; a couple of dozen true particles account
for over half of all separable-prefix occurrences. Quoting either number alone misrepresents
the work: the first overstates how much grammar is involved, the second understates how much
authoring the long tail demanded.

The kinds are **synchronic, not etymological**. *weg* and *beiseite* are frozen prepositional
phrases by origin — *weg* is MHG *enwec* from OHG *in weg* — but free adverbs today, and they
are filed as adverbs because that is the reading a composing subagent needs. Their histories
are in their `chain`.

**These are not build products.** The seed is re-derivable by re-running
`build_reuse_files.py`, but most of the content is authored scholarship — 73 root etymologies
and 246 prefix entries in two languages — which a regeneration would not reproduce. Merging
never overwrites an existing key for that reason.

**Validate after any hand-edit:** `python3 verbdata/merge_reuse_files.py --validate-only`. It
checks entry coverage against `Verbs.xml`, tilde balance, asterisk placement on reconstructed
forms, the four `RichTextView` markers that must not appear, cross-language quote style, and
de/en key and sense-list parity. Every check is there because the defect it catches was
actually observed during the authoring pass.

### Two defects in shipping data that this pass surfaced

Both were found by copying `Etymologies.json` content forward, and both are repaired on write
into the reuse files by the `sanitize` helper in each script. **Neither is fixed in
`Konjugieren/Models/Etymologies.json` itself**, which is shipping app content:

- **A literal `\n`** in 49 German entries, and zero English ones. The English side of the same
  entries carries real newlines, so the intent is unambiguous; the German renders two visible
  characters where a paragraph break belongs.
- **U+0137 `ķ` for U+1E31 `ḱ`**, in 36 places. At body-text size a Latvian k-cedilla and the
  PIE palatal are nearly identical, which is presumably how it survived review. In a
  reconstructed etymon it is a different sound.

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
