# Etymology-and-Example-Use Pipeline

**Status: designed 2026-07-20; Phase 4 mining completed 2026-07-23.** Phases 0 through 4 are done;
phase 5 is not.

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

### Phase 4 — Mine, sharded, with capped concurrency ✅ first pass done 2026-07-23

**"First pass" is deliberate: the whole section below stays live.** Every shard of the current
corpus is mined (`build_mining_shards.py` reports it and prints "Phase 4 is complete"), but the
resume protocol, cost calibration, validator, and per-shard launch prompt are *reused verbatim* by
the corpus-expansion re-mine that Phase 5 plans — the zero-candidate verbs get new candidates once
the corpus grows, and mining them is another Phase 4 pass, not new machinery. Do not retire this
section; it is done for *this* corpus, not done forever.

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

**The per-shard launch prompt, so it is not re-derived every session.** MINING_SPEC now carries
the friction ask and the write-no-other-file rule itself, so the launch prompt only has to point
at the brief and name the shard. Substitute `<NNN>` twice:

```
You are mining one shard for Phase 4 of the Konjugieren etymology-and-example-sentence
pipeline. Working directory: /Users/josh/Desktop/workspace/Konjugieren

1. Read `corpus/working/MINING_SPEC.md` in full. It is your complete brief — follow it exactly.
2. Your shard is `corpus/working/shards/mine_<NNN>.in.json`.
3. Write `corpus/working/shards/mine_<NNN>.out.json`.

Two points the brief makes that past runs still got wrong. Everything you need is joined into
your shard, so open no other file — the corpus, `Verbs.xml`, and the kaikki JSONL are all off
limits, and a candidate whose `truncated` is false carries the stored quotation in full. And
root, chain, and sense text is spliced verbatim by script; only the lead sentence and the
closer are yours to write. A validator checks your quoted German against the candidate strings
by exact equality, so paraphrase, trimming, and retyping all fail it.
```

- **Concurrency 2, shard size 25.** Size stays fixed so a resumed run has uniform units and shard
  files stay comparable across runs; concurrency is the knob.

  **Keep it at 2, and disregard the design section's invitation above to raise it.** Josh's call,
  2026-07-20, on the evidence of that day: three systemic problems surfaced during the first four
  shard-runs — root entries sized as articles rather than bullets, subagents re-opening source
  files the index could have supplied, and extraction furniture causing good candidates to be
  rejected. Each was caught within a wave or two and cost seconds of CPU to fix.

  Raising concurrency does not reduce total cost — it is ~2 session points per shard either way —
  it only spends the window faster, which means more shards are already contaminated before a
  systemic fault becomes visible. Wall-clock is not the binding constraint here; the window's
  token budget is. So the throughput gained is nearly nothing and the price is a wider blast
  radius. Raise it only once a full window has run without any pipeline change, which has not
  yet happened.
- **Cost, measured over ten shard-runs:** ~85–110k subagent tokens and about **2 session points**
  per shard, roughly 5–6 minutes. Calibration: ~45–50k subagent tokens per session point, from
  two independent batches. Re-derive rather than trusting these, and multiply by the shard count
  `build_mining_shards.py` reports rather than by one written here — an earlier version of this
  line said "the remaining 102", which was stale within a wave and is precisely the failure the
  progress-is-not-recorded-here rule above exists to prevent.

  **Pipeline work is the other half of the budget, and it is worth it.** The 2026-07-20 window
  spent ~13 of 17 points on fixes rather than shards, against the ~200 it would have cost to
  re-mine 100 shards contaminated by the defects those fixes removed.
- **Checking the window, discovered 2026-07-22.** A session *can* read its own usage, contrary to
  the assumption these notes were first written under: `claude -p "/usage"` runs the slash command
  in a headless child and prints its panel to stdout, so the figures come straight back. Read the
  **`Current session`** line — the five-hour window this pacing is about; the two weekly lines are a
  separate, slower pool. They are the panel's own numbers, "approximate, based on local sessions on
  this machine," so treat them as a gauge, keep headroom, and remember they miss other devices and
  claude.ai. The call costs about one request — negligible against a shard's ~100k subagent tokens —
  so poll every few shards, never in a loop. And it reports what is *consumed*, not whether the next
  batch *fits*: combine the reading with the ~2-points-per-shard estimate above and stop with
  headroom rather than mid-shard. Pasting `~/Desktop/usage.png` remains a fallback that costs no
  request at all.
- **Three artifacts landed on 2026-07-20 that a resuming session should know exist**, all
  tracked, all with their reasoning in their own docstrings:
  - `verbdata/normalize_prefix_senses.py` — made every prefix sense a complete sentence, so the
    brief's "splice verbatim" is literally executable. It was not: 45% were verb-initial
    fragments, and every subagent had been inventing its own connective. **Do not run it.** This
    line used to read "Idempotent; re-run it after editing any sense," and that was tested on
    2026-07-21 and is false in both halves. A second run re-adds a doubled terminal `.".` to
    every sense ending in a quoted gloss, and double-prepends its own frame — *"The sense of
    ~her-~ here is The sense of ~her-~ here is: …"*. It is the source of the 14 malformed senses
    repaired that day, and it left 28 verb-initial fragments standing, which is the defect it
    exists to remove. Repair senses by hand until the script is fixed, and validate with
    `merge_reuse_files.py --validate-only`, which does catch these.
  - `verbdata/sense-exemplars.json` — exemplar verbs per sense, index-parallel, for the
    highest-traffic prefixes. Sense selection was the last underdetermined step. Extend it when a
    run reports a gap; **check index parity against `senses` after editing**, since a short list
    fails silently as "no hint configured".
  - `corpus/working/repair_mined_connectives.py` — retrofits already-mined shards to the
    canonical senses. Needed once; kept because a future sense edit would need it again.
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
- **Separability doublets cannot be filtered in the indexer, and this was measured rather than
  assumed.** A shard-run on 2026-07-21 observed that the inseparable twin of `durchbrechen` cost it
  a third of its candidate reading and proposed dropping the class mechanically — `zu durchX`
  against `durchzuXen`, or an attached finite form in V2. It was implemented and measured, and the
  precision is not there. A separable verb is *legitimately* contiguous in its infinitive,
  zu-infinitive, participle, and any verb-final subordinate clause, and the last of those is not
  mechanically separable from V2 without parsing: `das zulief`, `der teilhat`, and `die
  hervorbricht` are all one constituent plus a contiguous verb, exactly like `Da durchstach ihn
  sein Diener`. A first attempt at "attached, finite, not clause-final" dropped 78 candidates and
  emptied 16 verbs' pools, about half of them real attestations in clauses that happened to be
  followed by `und` or an em-dash. Narrowing to V2 cut that to 18 drops at **5 true twins** — 28%
  precision — and the residue included genuine uses plus six `-nd` participles. Patching both
  classes reaches roughly 60% precision for a net gain of about three correct drops corpus-wide,
  while still deleting real attestations silently.

  So the doublet stays a **subagent rejection**, with the tells written into MINING_SPEC's
  rejection list instead. This is the same trade as the furniture rule directly above, and it is
  worth stating twice: the indexer's job is to be cheap and deterministic, and where a
  distinction needs syntax it belongs to the reader, not the filter. Do not re-attempt this
  without a parser.
- **An indexer change can orphan an already-mined quote, so make indexer changes early.**
  `merge_balanced` pops from per-work queues *after* they are sorted, so a new sort key changes
  which candidates survive `MAX_OCCURRENCES` — not merely their order. When the word-count key
  landed on 2026-07-20 it pushed shard 001's *abgehen* quote out of its own candidate pool, and
  the validator flagged it as no longer verbatim although it had been verbatim when mined. The
  repair is to re-pick from the current pool and say so in `notes`; do not carve an exception
  into the validator, which is the one check proving a subagent quoted rather than paraphrased.
  The general lesson is that the pipeline is cheap to change before mining and expensive after,
  which is the argument for spending a window on reported friction rather than on more shards.

### Phase 5 — Aggregate, and report the gaps

Merge `mined_*.json` into `Etymologies.json` and `ExampleSentences.json`. Write the zero-hit verbs
to `verbdata/no-corpus-example.txt` with the reason (no candidates at all, versus candidates that
were all nominal). Josh will expand the corpus and re-mine those; authored sentences are a later,
separate decision, and if they happen they must be flagged in Credits as the existing eleven are.

**The expansion has a shape, not just a size, and the shape tells you what to add.** Measured over
the full 104-shard run (2026-07-23): of the imported verbs that got no sentence, the large majority
had *zero candidates* — the corpus never attests them at all — and only a small remainder had
candidates that were all non-verbal and got honestly rejected. So the miss is a **register gap, not
a thin corpus**: the mined texts are literary and historical (Nietzsche, Kafka, Luther, the Weimar
constitution), and the un-attested verbs are overwhelmingly the register those authors never wrote
in — administrative, commercial, and technical vocabulary (*abbestellen* "cancel a subscription",
*abbuchen* "debit an account", *abrechnen* "settle accounts", *zwischenspeichern* "cache/buffer",
which post-dates the whole corpus). This is confirmable from the zero-candidate list
`build_corpus_index.py` prints: it opens with a wall of `ab-`/`an-`/`aus-` compounds of exactly this
kind. So the re-mine is not blind fishing — add **contemporary German of the missing registers**
(news and non-fiction prose, administrative/commercial text, technical writing) and a large fraction
of the zero-candidate list should resolve on the next pass. Adding *more* of the same literary
sources will not: those verbs are absent by register, not by volume. The all-rejected remainder is a
different, permanent floor — verbs the corpus mentions only as nouns, or drained by a homograph —
and it stays a subagent rejection, not a target for expansion.

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

**It references the brief; it must never restate it.** An earlier version summarized the brief's
rules for convenience — including that `truncated: false` "means `text` is the complete sentence"
— and when the brief was corrected on 2026-07-20 the summary stayed behind as a divergent copy.
A stale claim here is worse than one in the brief, because it arrives first in a fresh session
and outranks the file it contradicts. Any sentence in this block that could instead be a pointer
to `MINING_SPEC.md` should be one.

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
Launch each with the per-shard prompt recorded in Phase 4's "As built" section, substituting
the shard number — do not compose your own, and do not restate the brief's rules in it. The
brief is `corpus/working/MINING_SPEC.md` and it is authoritative; anything a launch prompt
says about `truncated`, about what is reused versus authored, or about candidate selection is
a second copy that will drift out of date and then contradict it.

Budget roughly 2 session points per shard. Check the five-hour window before starting and every
few waves — the technique is in Phase 4's "As built" section — and label any figure you derive
from calibration as an estimate rather
than a reading. Stop with about 5 points of headroom instead of getting caught mid-wave.

Run the Phase 4 validator before treating any shard as done; a subagent's self-report is not
evidence. Append to `docs/blog_notes.md` once at the end, not per shard. Do not merge anything
into `Konjugieren/Models/` — that is Phase 5, whose note says to widen
`.claude/skills/integrate` rather than write a parallel merge.

Read the subagent reports as evidence about the pipeline, not just as status about a shard,
and propose improvements freely. Every significant fix so far came from a report mentioning
friction rather than from anyone inspecting the code: root entries turned out to be articles
where a bullet was wanted, subagents were re-opening source files to rebuild sentences the
index already held, and extraction furniture was causing good candidates to be rejected. Each
was a few seconds of CPU to fix and each was worth more than the shards it would otherwise
have degraded.

So watch for a subagent working around the brief, rejecting candidates for a reason that
recurs, doing expensive work that could be precomputed, or asking for something the shard
should already contain. When you see it, stop and propose a fix before spending another
window — a change to the indexer or the brief is cheap, and re-mining is not. Pushback on the
brief itself is welcome too: several agents have corrected it with sources and been right, so
tell me when one does rather than quietly accepting or quietly overruling it.
````

Baseline the at-odds count before starting and re-check after
(`docs/roadmap.md` § "The one check that runs through all of it"). Neither half of this pipeline
touches `Verbs.xml`, so it should not move; if it does, something unintended happened.
