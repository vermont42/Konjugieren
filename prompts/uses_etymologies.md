# Etymology-and-Example-Use Pipeline

**Status: designed 2026-07-20.** Phases 0 through 3 are done; phases 4 and 5 are not.

Fill the 2,582 verbs that have neither an etymology nor an example sentence, in one pass, by
moving the expensive work off the LLM and reusing what the corpus already knows.

## Why one pipeline, and why not the obvious two prompts

The obvious approach is two prompts: subagents plus `docs/example-sentence-pipeline.md` for
sentences, subagents plus `docs/etymology-pipeline.md` for etymologies. Both would work and both
would waste enormous time and tokens, for different reasons.

**Example sentences.** The existing pipeline has each subagent read corpus files directly.
`docs/example-sentence-pipeline.md` § "Sentence Pre-Filtering (Optional Optimization)" contemplates
an index and declines it: *"since the subagent can read files directly from `corpus/`, this step
may be unnecessary for small batches."* At 990 verbs that was survivable. At 2,582 it is not: the
German corpus is ~6.5 MB and every subagent pays to search all of it.

**Etymologies.** The existing entries are not atomic prose. They already decompose:

> `vermeiden`: "From MHG ~vermīden~… Compound of ~ver-~ + ~meiden~:
> - ~meiden~: From MHG ~mīden~, from OHG ~mīdan~, from Proto-West Germanic *~mīþan~… PIE *~meyth₂-~…
> - ~ver-~: From MHG ~ver-~, from OHG ~fir-~… PIE *~per~…"

So `meiden`'s etymology has been shipping inside `vermeiden`'s since before `meiden` was a verb in
this app. Re-deriving it is paying twice for one piece of scholarship.

**Combining them** avoids paying subagent startup twice for the same verb, and the two tasks share
context: a subagent already holding a verb's morphology and semantics is well placed to pick a
sentence for it.

## The measurement that sizes the work

| | |
|---|---|
| Verbs missing both etymology and example sentence | **2,582** (the two sets are identical) |
| Of those, prefixed | **97%** (76% separable, 21% inseparable, 88 multi-prefix) |
| Distinct final roots involved | **382** |
| Roots that already have an etymology | **303** |
| **Roots genuinely needing new work** | **79** |

The etymology half is not 2,582 acts of scholarship. It is **79 new roots**, a prefix inventory of
a few dozen, and 2,582 cheap compositions. Re-derive this before starting; do not trust the table.

```bash
python3 - <<'PY'
import json, re, xml.etree.ElementTree as ET
ety = set(json.load(open('Konjugieren/Models/Etymologies.json'))['en'])
missing, roots = [], set()
for v in ET.parse('Konjugieren/Models/Verbs.xml').getroot():
    raw = v.get('in'); key = re.sub(r'[+*^]', '', raw)
    if key in ety: continue
    missing.append(key)
    i = max(raw.rfind('+'), raw.rfind('*'))
    roots.add(key if i == -1 else re.sub(r'[+*^]', '', raw[i+1:]))
print(len(missing), 'missing;', len(roots), 'roots;', len(roots & ety), 'roots already done')
PY
```

## Prior art: what Conjugar actually did

`../Conjugar.mig` built this and it worked. Confirmed 2026-07-20 by reading that repo; its own
build log states the principle:

> "The Conjuguer pipeline is the one to copy because it moved the expensive work off the LLM:
> pre-conjugate every verb with the app's own engine, index the corpus deterministically by whole
> generated word-form, and let subagents do only the select/translate judgment."

The load-bearing part is **not** the index. It is the **form→lemma map**:
`ConjugarTests/Models/CorpusFormsDumpTests.swift` drives the app's own engine over every verb ×
tense × person to produce `forms.json` (52,166 forms), and the indexer does *exact whole-token*
matching against it. Its docstring says why: this "handles irregular stems and avoids substring
false positives."

Worth copying, beyond the shape:

- **Subagents write their own output files** rather than returning JSON through the transcript.
  That is what made a five-hour window interruptible: resume by relaunching only the shards with
  no output file, and re-run a single shard that died without touching the rest.
- **Candidates arrive pre-ranked and author-balanced**, so the first candidate a subagent sees is
  spread across sources rather than always coming from whichever file was scanned first.
- **A tail-rescue pass** for verbs whose candidate slots were drained by homographs.

Worth knowing before copying: no token saving was ever measured, only asserted. If you want the
number, measure one shard both ways before building the whole thing.

## The German problem Spanish did not have

**76% of the target verbs take a separable prefix, and German splits them in main clauses.**
*anfangen* surfaces as "er **fängt** neu **an**", the particle stranded at clause end, arbitrarily
far from the finite verb. Conjugar's whole-token exact match scores zero on the most common written
form of three-quarters of our targets.

Contiguous forms do exist, and are abundant in this corpus:

| Form | Contiguous? | Example |
|---|---|---|
| Infinitive | yes | anfangen |
| *zu*-infinitive | yes | anzufangen |
| Partizip II | yes | angefangen |
| Finite, verb-final subordinate clause | yes | …dass er anfängt |
| Finite, main clause (V2) | **no** | er fängt … an |

Legal and literary German, which is most of `corpus/`, is dense in perfect tense and subordination.
So: **index contiguous forms in pass 1**, then a **split-form rescue** for zero-hit verbs that
matches the finite stem and requires the particle later in the same sentence. That mirrors
Conjugar's tail rescue, which was needed anyway.

German also hands us an advantage. Conjugar's worst recurring bug was noun homographs draining
candidate slots (*cocina* for *cocinar*), which required a whole extra stage. **German capitalizes
nouns**, so *das Ringen* is mechanically distinguishable from *ringen* by orthography. Score a
capitalized mid-sentence token as probably-nominal and the same trap is nearly free to avoid. Do
not skip it: nominalized infinitives are extremely common in exactly the administrative German that
makes up the government sources.

## Phases

### Phase 0 — Fix the encoding defects ✅ done 2026-07-20

Eleven verbs shipped weak that are strong. Fixed before the pipeline runs, deliberately: a verb
whose family flips may want a different example sentence, so fixing afterward means redoing work.
See `verbdata/wiktionary-defects.json`. Two remain deferred there on known model gaps
(*verglimmen*, *verschreien*).

**Read that file before trusting any Wiktionary-derived claim in this pipeline.** English
Wiktionary auto-generates a default *weak* conjugation table for verb pages nobody supplied a
strong template for, yielding non-words (*angelest*, *aufgewascht*) while the base entries stay
correctly strong. kaikki extracts the garbage faithfully. The classifier then hypothesizes weak,
matches exactly, and reports the verb verified. **"Verified" means "agrees with Wiktionary", not
"correct".** The same caution applies to `etymology_text`.

### Phase 1 — Dump every conjugation to a form→lemma map ✅ done 2026-07-20

Add `KonjugierenTests/Utils/CorpusFormsDumpTests.swift`, modeled on the existing
`VerbExportTests.swift`, which already walks every verb across twelve conjugationgroups and writes
JSON to a path from the environment. Drive `Conjugator` over all 3,572 verbs × every
conjugationgroup × every person.

Output `corpus/working/forms.json`:

```json
{ "angefangen": [{"verb": "anfangen", "contiguous": true}],
  "fängt":      [{"verb": "anfangen", "contiguous": false, "particle": "an"},
                 {"verb": "fangen",   "contiguous": true}] }
```

The `contiguous` flag and `particle` are the German-specific addition; everything else mirrors
Conjugar. Note a form maps to *several* verbs and disambiguation is deliberately deferred to the
subagent, exactly as Conjugar did with *fue* → `ir`/`ser`.

Follow the existing convention for such harnesses: gate on an environment variable so the suite
does not write files in ordinary runs.

**As built.** `KonjugierenTests/Utils/CorpusFormsDumpTests.swift`, run in about two seconds:

```bash
TEST_RUNNER_KONJUGIEREN_FORMS_OUT="$PWD/corpus/working/forms.json" \
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren \
  -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test \
  -only-testing:KonjugierenTests/CorpusFormsDumpTests
```

`-only-testing` takes the **struct name**, not the `@Suite` display name. Getting that wrong
selects nothing and xcodebuild reports success — the same silent-skip shape as forgetting the
`TEST_RUNNER_` prefix, which is what actually forwards the variable into the simulator.

Four things about `Conjugator` shaped the harness, and Phase 2 should know them:

- **Output is mixed case by design.** `applyAblaut` splices the replacement region from
  `AblautGroups.xml` in uppercase, so `singen`'s Präteritum comes back `sAng`. Every key and
  particle is lowercased on the way in; the indexer must lowercase corpus tokens to match.
- **Only the Imperativ splits a separable prefix.** `conjugateSimpleTense` returns the prefix
  still attached (`anfängt`), because a paradigm cell has no clause to strand a particle in. The
  `contiguous: false` entries are therefore *synthesized* by dropping the separable run, guarded
  by a `hasPrefix` test so that a full-stem ablaut override (the trailing `*`) cannot be sliced.
- **Compound conjugationgroups are skipped deliberately.** They return `auxiliary + " " + part`,
  where the part is the Perfektpartizip or the bare infinitive, both already emitted. Walking them
  would map `habe` onto every verb in the corpus, which is a false attestation.
- **Every reading is walked, not just the primary.** This is not redundancy: it is what yields
  both `hing` and `hängte` for *hängen*, and it is the only thing that produces split forms for
  the four separability doublets — *übersetzen*, *überstehen*, *umgehen*, *unterstellen* — whose
  separable sense lives in a secondary reading and whose `in` attribute carries no `+`.

Measured on the 2026-07-20 corpus: ~50,000 distinct forms, ~77,000 entries, every verb reachable
by its own infinitive, and no entry where `contiguous` disagrees with the presence of `particle`.
Re-derive rather than trusting those numbers. `corpus/` is gitignored, so `forms.json` is a build
product: regenerate it rather than looking for it in a fresh clone.

### Phase 2 — Build the corpus index ✅ done 2026-07-20

`corpus/working/build_corpus_index.py`, consuming `forms.json` and `corpus/{modern,government,
technology,medieval}/`. One tokenizing pass per document. Emit `corpus/working/corpus_index.json`
keyed by infinitive:

```json
{ "anfangen": [{"doc": "corpus/modern/kafka-prozess-de.txt", "line": 412,
                "token": "angefangen", "text": "<±200 char snippet>"}] }
```

Constants worth copying from Conjugar: `MAX_OCCURRENCES = 5`, `PER_DOC_CAP = 4`,
`SNIPPET_WIDTH = 200`, tier priority literature → government → technology, and the round-robin
merge that balances the lead candidate across sources.

Add, for German: skip capitalized mid-sentence tokens unless the verb is genuinely capitalized at
sentence start, and record `contiguous` on each candidate so the subagent knows what it is looking
at. Strip Gutenberg boilerplate first (recipe in `docs/example-sentence-pipeline.md`).

**As built.** `corpus/working/build_corpus_index.py`, run in about twenty seconds:

```bash
python3 corpus/working/build_corpus_index.py
```

Each candidate carries `doc`, `line`, `token`, `text`, `contiguous`, `source` (a ready-to-use
citation string, so subagents need not infer one from a filename), and `particle` on split forms.
Conjugar's constants and its round-robin rotating-lead merge survived the port unchanged. Six
things shaped the rest, and Phase 4 should know them.

- **The English translations had to be excluded, by content not by filename.** `corpus/modern/`
  ships each work in German *and* English, and ten common English words are German verb forms in
  `forms.json` — *war*→sein, *will*→wollen, *hat*→haben, *sang*→singen, *band*→binden among them.
  A file is admitted only if at least 3% of its tokens are German function words with no English
  homograph. Measured across the corpus, the English files score 0.00–0.04% and the German ones
  9.27% (Westphalia's 17th-century spelling is the floor) to 22%, so the cut is not close. Judging
  by the `-en.txt` suffix also worked, but a naming convention is not a guarantee and nothing
  would report the mistake: the bad candidates would simply appear, in fluent English, under a
  German citation. This is a trap Conjugar never had, because its corpus was monolingual.
- **The medieval tier is not indexed.** It produced 14 candidates out of ~10,600, and inspecting
  all 14 found most unusable: lines of scholarly glossary ("rıtun (rītan) — ritten (Eng: rode) →
  NHD reiten"), and — worse — modern encyclopedia prose *about* the manuscript that would ship
  under a "(ca. 830)" citation. Fluent German attributing a 2010s Wikipedia sentence to a
  ninth-century poem passes review in a way an English false positive never would. Those files mix
  primary text, translation, and commentary, so citing them needs a policy this indexer does not
  have; Conjugar built its medieval pass as a separate program for the same reason. Dropping the
  tier cost nothing measurable — every one of those candidates was a redundant fallback for a verb
  already covered elsewhere. The `medieval` sub-key contemplated in
  `docs/example-sentence-pipeline.md` § Phase 4 remains a separate, unstarted job needing OHG
  judgment rather than token matching.
- **Matching is sentence-wise, not line-wise, and that is forced.** Conjugar scanned a line at a
  time. German cannot: the sources are hard-wrapped (Kafka ~68 chars, the government PDFs ~43), so
  a typical sentence spans two to four physical lines, and a stranded particle is routinely on a
  different line from its verb. Documents are reflowed into paragraphs, then split into sentences.
- **The split-form rule is the Satzklammer, not proximity.** The phase spec above says "requires
  the particle later in the same sentence". That was measured at roughly **70% false** — in "trat
  beiseite, ging aber nicht weg" the *weg* belongs to *ging*. Four constraints fixed it: no clause
  boundary between verb and particle, the particle closes its clause, the particle is not
  capitalized (*am Weg* is a noun), and no intervening verb claims the same particle (*gräbt eine
  Grube und deckt sie nicht zu* is *zudecken*). Precision went to roughly 11 in 12 sampled, and
  split-only coverage fell by a factor of five — the right trade, since a bad candidate costs a
  subagent more than a missing one. This subsumes the separate "split-form rescue" pass; there is
  no second pass.
- **The Bundestag Plenarprotokolle needed de-columnizing.** `pdftotext -layout` preserves two
  columns as side-by-side text, so reading a line as prose splices unrelated sentences together.
  Two thirds of the candidates from those three files were garbage. The gutter is now detected per
  page by geometry and each column read in order, which cut garbled snippets by ~88% and *raised*
  the yield from those files. They are the corpus's only natural spoken German, so recovering them
  mattered more than dropping them would have cost.
- **`doc:line` is verified, and was wrong twice.** Phase 4 tells subagents to re-open the source at
  `doc:line`, so this has to hold. It first pointed at the *paragraph* start (15 lines off inside a
  Luther paragraph) and was additionally shifted by however many lines the Gutenberg header
  occupied (24, in Kafka). Physical line numbers are now carried through the reflow and point at
  the matched verb itself; a 600-candidate audit resolves ~99%, and every sampled residual was a
  correct citation the *verifier* could not reconstruct, not a bad one.
- **Snippets became quotations, and the constant had to change with them.** Conjugar's
  `SNIPPET_WIDTH = 200` sized a *preview* — enough text to judge whether a candidate was
  relevant. Phase 4 uses the same field to *quote* the sentence into the app, and a preview may
  be lossy where a quotation may not. At 200 characters 36% of candidates arrived truncated, so
  the mining brief told every subagent to re-open the source at `doc:line` and rebuild the
  sentence by hand; that reopen measured at roughly 45% of a shard's cost, and it put subagents
  in the business of reassembling prose across the gutter of two-column PDF extractions. The
  sentence was already computed in `snippet()` and then thrown away. `MAX_QUOTE_CHARS = 600`
  stores it whole: truncation fell from 36% to 2.8% for an 8% increase in shard size. Each
  candidate now also carries an explicit `truncated` flag rather than leaving it to be inferred
  from a leading or trailing "…", because the Bundestag protocols use ellipses for
  interruptions and a consumer guessing from the glyph would quote a fragment believing it
  whole.
- **Line-break hyphens are healed, which buys recall as well as legibility.** A wrapped
  "ab-/geholt" tokenizes as `ab` + `geholt` and never matches `abgeholt`. Suspended hyphens in
  coordinations (*Ein- und Ausgang*) are left alone.

Measured on the 2026-07-20 corpus: 44 documents, ~153,000 sentences, ~10,600 candidates for ~2,650
verbs, and about **64% of the target verbs covered** — roughly 1,530 with contiguous evidence, some
130 on split forms alone, and about 920 with nothing. Re-derive rather than trusting those numbers;
the script reports all of them. The zero-candidate list is Phase 5's input, and it is large enough
that corpus expansion, not authoring, is the right response.

`corpus/` is gitignored, so `corpus_index.json` is a build product — regenerate it rather than
looking for it in a fresh clone. The **script**, however, is now tracked: `.gitignore` carries an
explicit negation for `corpus/working/*.py`, because everything in the list above is knowledge that
a fresh clone would otherwise lose.

### Phase 3 — Build the three reuse files, by parsing not generating ✅ done 2026-07-20

- `verbdata/roots.json` — root → etymology. **Seed by parsing the 990 existing entries**, whose
  bullet structure (`- ~meiden~: From MHG…`) is regular. 303 of the 382 needed roots fall out for
  free. Author the remaining 79.
- `verbdata/prefixes-inseparable.json` — *ver-*, *be-*, *er-*, *ent-*, *zer-*, *emp-*, *miss-*.
- `verbdata/prefixes-separable.json` — *an-*, *ab-*, *auf-*, *aus-*, *ein-*, *mit-*, *nach-*,
  *vor-*, *zu-*, and the open-class remainder. The separable side is open class, so expect to add
  entries rather than to enumerate it once.

Both prefix files carry the same shape as the bullets already in the corpus: MHG/OHG/PG/PIE chain,
plus the semantic contribution. Extract *ver-* once from `vermeiden` and it serves all 173
*ver-* verbs in the queue.

Format: a flat JSON object keyed by root or prefix, value being the markup-ready text. Flat and
keyed, so a subagent can look up rather than search.

**As built.** Two tracked scripts and three tracked data files:

```bash
python3 verbdata/build_reuse_files.py --gaps /tmp/reuse_gaps.json   # seed + worklist
python3 verbdata/merge_reuse_files.py --shards <dir>                # fold in authored shards
python3 verbdata/merge_reuse_files.py --validate-only               # re-check at any time
```

The seeding half confirmed the plan's arithmetic exactly. The authoring half was 73 roots and
246 prefixes across 21 subagent shards, each writing its own file — Conjugar's interruptible
pattern, and it paid off: shard reports could be read as they landed rather than at the end.

Eight things shaped the result, and Phase 4 should know them.

- **The value shapes differ between roots and prefixes, deliberately.** A root's entry is
  `{bullet, full}` — see the Phase 4 note below on why one text could not serve both jobs.
  A prefix's is `{kind, chain, senses, occurrences}`,
  because a prefix bullet in the existing corpus is two things welded together: a genealogy
  identical across every compound, and a final sentence glossing what the prefix does *in this
  compound*. Freezing one arbitrary gloss would have made all 189 *ver-* verbs read alike.
  Phase 4 composes: chain verbatim, plus the sense that fits the compound at hand.
- **Six roots existed only inside other verbs' bullets** — *leihen*, *meiden*, *schreiten*,
  *schwinden*, *winden*, *zeihen*. Their etymologies had been shipping for months as
  sub-clauses of *verleihen*, *vermeiden*, and the rest, without ever being entries. This is
  the reuse thesis in miniature.
- **Seventy-three roots needed authoring, and they are almost all strong verbs**, plus seven
  **cranberry morphemes** — bound roots that are not verbs of modern German at all and survive
  only inside one compound: *brinnen* (verbrennen), *deihen* (gedeihen), *derben* (verderben),
  *drießen* (verdrießen), *nesen* (genesen), *kreißen*, *zeihen*. Their entries say so plainly
  rather than presenting them as usable.
- **Two `in` attributes are double-prefixed but singly marked**: `be*mitleiden` and
  `ver*anschlagen`. Both compounds are wholly inseparable, so marking the inner *mit*/*an* as
  separable would misstate their syntax — the encoding is right and the last-marker rule is
  what is approximate. They are authored as composed roots. `Verbs.xml` was not touched, and
  the at-odds count did not move.
- **The separable side is not 233 prefixes**, and each entry records which of seven kinds it
  actually is, in a `kind` field, because Phase 4 composes differently for each. Measured on
  the 2026-07-20 corpus — re-derive rather than trusting these:

  | kind | entries | occurrences | |
  |---|---|---|---|
  | particle | 23 | 1,100 | old preposition grammaticalized: *ab-*, *an-*, *auf-* |
  | deictic | 74 | 459 | *her-*/*hin-*/*da(r)-* compounds and their contractions |
  | adjective | 84 | 228 | resultative frame: *totschlagen* = beat until dead |
  | adverb | 9 | 83 | free modern adverb: *weg-*, *weiter-*, *gern-* |
  | fossil | 27 | 65 | strictly bound: *abhanden* = "ab + Handen", old dative plural |
  | noun | 14 | 30 | incorporated: *teilnehmen*, *preisgeben* |
  | verb | 2 | 2 | *stehenbleiben*, *steckenbleiben* |

  **The two columns tell opposite stories, and that is the point.** By entry count the class
  is dominated by adjectives; by occurrence count 23 true particles carry 56% of all
  separable-prefix uses while 84 adjectives carry 12%. Either number alone misleads: "233
  separable prefixes" overstates how much grammar is involved, and "23 real particles"
  understates how much authoring the tail demanded. Depth therefore went on the atoms —
  *herunter* is *her-* + *unter* and gets three clauses and a pointer, while *her-* and
  *hin-* get full entries, since the toward-speaker / away-from-speaker opposition is the
  single most useful fact in the inventory.

  The kinds are **synchronic, not etymological**, and that distinction was contested during
  classification. *weg* and *beiseite* are frozen prepositional phrases historically — *weg*
  is MHG *enwec*, from OHG *in weg* — but they are free adverbs of modern German, and a
  composing subagent needs the modern reading. Their histories live in their `chain`.
- **Harvested chains had to be corrected, not merely normalized.** Beyond the expected drift
  in abbreviation and diacritic, several shipping chains were wrong on substance: *hoch*'s PIE
  gloss was misstated in both harvested variants (the root means "to elevate"), *auseinander*
  derived the *-ein-* from the preposition *in* rather than from *ein* "one", and *wahr*
  covered only the adjective — but the corpus verb is *wahrnehmen*, whose first element is the
  unrelated noun OHG *wara* "heed", the root behind English *aware*. Reused verbatim, that
  last one would have mis-derived the commoner verb.
- **Two defects in shipping data surfaced by being copied.** 49 German entries in
  `Etymologies.json` carry a literal `\n` where the English side has a real newline, and 36
  places have U+0137 `ķ` (a Latvian k-cedilla) standing for U+1E31 `ḱ`, the PIE palatal. Both
  are repaired on write into the reuse files, by `sanitize` in each script; neither is fixed
  in `Etymologies.json`, which is shipping app content. **That fix is still outstanding.**
- **The validator is the durable artifact, not the merge.** `--validate-only` re-checks tilde
  balance, asterisk placement, the four parser-significant markers, cross-language quote
  style, de/en key and sense-list parity, and both defects above. Every check exists because
  the defect it catches was actually observed. Run it after any hand-edit.

`verbdata/` is tracked, so unlike `corpus/` these three files are not build products: the seed
is re-derivable but the authored scholarship is not.

### Phase 4 — Mine, sharded, with capped concurrency

One subagent per shard. Each subagent, per verb, returns **both** an etymology and an example
sentence, and writes its own `corpus/working/mined_<NNN>.json`.

**Concurrency is the tunable knob, not shard size.** Set `MAX_CONCURRENT` low (start at 2) and
raise it toward whatever a five-hour window sustains. Keep `SHARD_SIZE` fixed at ~25 verbs so that
shard files stay comparable across runs and a resumed run has uniform units.

Each subagent is told:

1. Read your shard file. Candidates are pre-found and pre-ranked; **do not read the corpus
   wholesale**.
2. For the etymology: decompose the verb using the markers in `Verbs.xml`. Look the root up in
   `roots.json` and the prefix in the prefix files. **Reuse verbatim; do not re-derive.** Compose
   only the joining prose and the semantic gloss specific to this compound. If the root is absent,
   author it and return it separately so it can be added to `roots.json` for later shards.
3. For the sentence: walk candidates in order, take the earliest that is a genuine *verbal* use,
   re-open the source at `doc:line` for one clean complete sentence, translate it.
4. If no candidate is a genuine verbal use, return the verb with nulls and a note. **Do not invent
   a sentence.**

**As built — started 2026-07-20, and resumable.** The subagents' brief lives in
[`corpus/working/MINING_SPEC.md`](../corpus/working/MINING_SPEC.md), which is tracked for exactly
this reason. The ready-to-paste prompt for a fresh session is under
[§ Invocation](#resuming-phase-4-in-a-fresh-session).

**Progress is not recorded here, deliberately.** `build_mining_shards.py` reports it, derived from
which `.out.json` files exist:

```bash
python3 corpus/working/build_mining_shards.py     # rebuilds inputs, then reports progress
```

A count written into prose is stale the moment the next shard lands, and a stale count is worse
than none because it reads as authoritative — the same failure this repo already has a
`scripts/check_docs.py` to police in the cache files.

**Resume by relaunching only the shards with no `.out.json`.** That is the whole recovery
protocol, and it is why subagents write their own files rather than returning JSON through the
transcript: a shard that dies costs one shard. Re-running `build_mining_shards.py` regenerates
inputs only and never touches outputs, so it is safe at any point, including mid-pass.

- **Concurrency 2, shard size 25.** Size stays fixed so a resumed run has uniform units and shard
  files stay comparable across runs; concurrency is the knob.
- **Cost, measured over four shard-runs:** ~99k subagent tokens and about **2 session points**
  per shard, roughly 6 minutes. The remaining 102 are therefore ~2 full five-hour windows and
  ~29% of a weekly budget. Calibration: ~45–50k subagent tokens per session point, from two
  independent batches. Re-derive rather than trusting these.
- **Yield runs near half.** Shards 000–001 gave 26 sentences and 24 nulls over 50 verbs. Most
  nulls are verbs with no candidate at all (~36% of targets corpus-wide); the rest are honest
  refusals. Every verb still gets an etymology, so a null is a half-result, not a failure.
- **Validate before merging**, since agent self-reports are not evidence:

```bash
python3 - <<'PY'
import json, glob, re
for f in sorted(glob.glob('corpus/working/shards/mine_*.out.json')):
    n = f.split('_')[-1].split('.')[0]
    inp = {v['verb']: v['candidates'] for v in json.load(open(f.replace('.out', '.in')))['verbs']}
    out = json.load(open(f))
    assert set(out) == set(inp), f'{n}: key set differs from its shard'
    for verb, entry in out.items():
        for lang in ('de', 'en'):
            text = entry['etymology'][lang]
            assert text and text.count('~') % 2 == 0, f'{n}/{verb}/{lang}: tildes'
            assert not any(m in text for m in '`$‡^'), f'{n}/{verb}/{lang}: reserved marker'
            assert '\\n' not in text and '­' not in text, f'{n}/{verb}/{lang}: stray char'
            if lang == 'de':
                assert '"' not in text, f'{n}/{verb}: ASCII quote in German'
        if entry['sentence']:
            # The quote must be a candidate verbatim — no trimming, no reassembly.
            assert any(c['text'] == entry['sentence']['de']['sentence'] for c in inp[verb]), \
                f'{n}/{verb}: quoted sentence is not verbatim from a candidate'
print('all mined shards pass')
PY
```

Three things a later pass should know:

- **The verbatim check above is the one that matters.** It is what proves a subagent quoted rather
  than paraphrased, and it caught nothing only because the brief forbids trimming — an earlier run,
  before that rule existed, trimmed five quotes and one of them lost the clause holding its verb.
- **179 target verbs have every candidate drained by a homograph** — 11% of those with candidates.
  *abfahren*'s four candidates are all the token *abführen*, genuinely both that verb's infinitive
  and the Konjunktiv II of *abfahren* (*fahren* → *fuhr* → *führe*). `forms.json` is right to list
  both; `MAX_OCCURRENCES = 5` is what starves the rarer verb. This is Conjugar's *cocina*/*cocinar*
  problem, which the German-capitalization defense does not touch because it is verb-on-verb. A
  tail rescue belongs in Phase 5.
- **About 30 candidates still carry furniture**, the cases where stripping would have reached the
  matched verb. Subagents reject them, which is a visible loss rather than a silent edit. Do not
  "fix" this by loosening the protection.

### Phase 5 — Aggregate, and report the gaps

Merge `mined_*.json` into `Etymologies.json` and `ExampleSentences.json`. Write the zero-hit verbs
to `verbdata/no-corpus-example.txt` with the reason (no candidates at all, versus candidates that
were all nominal). Josh will expand the corpus and re-mine those; authored sentences are a later,
separate decision, and if they happen they must be flagged in Credits as the existing eleven are.

**Extend `.claude/skills/integrate`; do not write a parallel merge.** That skill already exists and
already encodes the rules this phase needs — diff working against bundled, add only missing verbs,
never overwrite an existing entry, keep keys sorted per language, validate that `de` and `en` agree
in count. Two integration routes into the same bundle is how a bundle drifts, so the work is to
widen the skill rather than to write a second path beside it. Three gaps to close:

- **It handles example sentences only.** Phase 4 emits an etymology *and* a sentence per verb, and
  nothing currently merges the etymology half into `Etymologies.json`.
- **It reads a single working file at the project root.** Phase 4 writes one file per shard, at
  `corpus/working/shards/mine_<NNN>.out.json`, so an aggregation step has to come first — and it
  should tolerate missing shards, since resuming an interrupted run means some are simply absent.
- **Its skip rule needs a third case.** The skill skips a verb that has only one language. Phase 4
  additionally emits `"sentence": null` for verbs where no candidate was a genuine verbal use,
  which is a *successful* result carrying an etymology and no sentence. Merging that verb's
  etymology while writing no sentence entry is the correct behavior; treating the null as a
  half-finished record and skipping the verb entirely would silently drop about a third of the
  etymologies.

Checked 2026-07-20, so it does not need re-deriving: both bundled files round-trip **exactly**
through `json.dumps(obj, indent=2, ensure_ascii=False) + "\n"`. The skill's rewrite-the-whole-file
approach is therefore safe here and produces a diff containing only real changes. This is *not* the
situation described in `CLAUDE.md` for `Localizable.xcstrings`, which Xcode writes in its own format
and which a round trip reflows entirely. Verify with `git diff --stat` regardless: a correct
integration shows insertions and no deletions.

## Traps

- **Do not trust a decomposition because it looks like one.** *begleiten* is not *be-* + *gleiten*;
  it descends from MHG *geleiten*, which is why it is weak while *gleiten* is strong. The reliable
  test is the `in` attribute: `ver*m^ei^den` contains the standalone `m^ei^den` character for
  character, whereas `be*gleiten` does not match `gl^eit^en`. Exact remainder matching cut a naive
  50 suffix matches to 5 true pairs. Confirm against kaikki's `etymology_text` before reuse.
- **`hp="y"` marks the imported verbs.** It is how the 2,582 are identified and how the original
  990 are excluded.
- **Do not restate counts in prose.** `scripts/check_docs.py` enforces this for the cache files;
  the same discipline applies here. Re-derive from `Verbs.xml`.
- **ExampleSentences.json is keyed `{de: {...}, en: {...}}`**, language first, then verb. Reading
  it as verb-first silently reports zero coverage.

## Invocation

> Please execute `prompts/uses_etymologies.md`, starting at phase 1. Phase 0 is done.

### Resuming Phase 4 in a fresh session

Paste the block below verbatim. It carries **no state**: which shards remain is derived from the
filesystem by `build_mining_shards.py`, so the same text is correct on the first pass, the last
pass, and every pass in between. Do not edit in a shard count — that is precisely the line that
goes stale, and a stale count is worse than none because it reads as authoritative.

It is fenced rather than block-quoted so it can be copied as-is; the outer fence uses four
backticks because the prompt contains a fenced block of its own.

````
Continue Phase 4 of `prompts/uses_etymologies.md` for Konjugieren. Read that file's Phase 4
"As built" section first — it holds the resume protocol, the cost calibration, and the
validator to run before any shard counts as done.

`corpus/` is gitignored, so regenerate the build products before anything else. The last
command prints how many shards are already mined and which remain; that output, not this
prompt, is the state:

```bash
TEST_RUNNER_KONJUGIEREN_FORMS_OUT="$PWD/corpus/working/forms.json" \
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren \
  -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test \
  -only-testing:KonjugierenTests/CorpusFormsDumpTests
python3 corpus/working/build_corpus_index.py
python3 corpus/working/build_mining_shards.py
```

Mine the remaining shards at concurrency 2, lowest number first, one subagent per shard.
Point each subagent at `corpus/working/MINING_SPEC.md` and its own shard, and stress two
things: everything it needs is joined into the shard, so it should open no other file
(`truncated` is false for ~97% of candidates, meaning `text` is the complete sentence to
quote verbatim); and root and prefix text is reused verbatim, with only the joining prose
authored.

Budget roughly 2 session points per shard. You cannot introspect usage — ask me to paste
`~/Desktop/usage.png` before starting and every few waves, and label any figure you derive
from calibration as an estimate rather than a reading. Stop with about 5 points of headroom
instead of getting caught mid-wave.

Run the Phase 4 validator before treating any shard as done; a subagent's self-report is not
evidence. Append to `docs/blog_notes.md` once at the end, not per shard. Do not merge anything
into `Konjugieren/Models/` — that is Phase 5, whose note says to widen
`.claude/skills/integrate` rather than write a parallel merge.
````

Baseline the at-odds count before starting and re-check after
(`docs/roadmap.md` § "The one check that runs through all of it"). Neither half of this pipeline
touches `Verbs.xml`, so it should not move; if it does, something unintended happened.
