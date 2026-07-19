# Roadmap: growing the verb corpus

The order to execute things in, and what gates what. Written 2026-07-19.

**This file is an index, not a source.** It says *what* to do next and *why that order*; the
*how* lives in the linked prompt or doc, which is authoritative wherever the two disagree. Like
`project-structure.md`, it is a cache, and staleness has a real cost — update it when a step
completes.

## The sequence at a glance

| # | Step | Where | Status | Gated on |
|---|---|---|---|---|
| 1 | Get the Wiktionary snapshot | [`verb-sources.md`](verb-sources.md) | ✅ 2026-07-18 | — |
| 2 | Build the classify-and-verify pipeline | [`verb-classification.md`](verb-classification.md) | ✅ 2026-07-19 | — |
| 3 | Fix what it found in the shipping corpus | [`verb-classification.md`](verb-classification.md) | ✅ 2026-07-19 | — |
| 4 | Regional variety support | [`../prompts/regional_variation.md`](../prompts/regional_variation.md) | ✅ 2026-07-19 | — |
| 5 | Dual auxiliaries + double-prefix grammar | [`../prompts/dual_auxiliary.md`](../prompts/dual_auxiliary.md) | ⬜ next | step 4 ✅ |
| 6 | Refactor `fr`: store hits, derive rank | [`verb-sources.md`](verb-sources.md) § "Step 4 in detail" | ⬜ | — |
| 7 | Import tranche 1: strong bases | [`verb-sources.md`](verb-sources.md) § step 5 | ⬜ | steps 4–6 |
| 8 | Import tranche 2: prefixed derivatives | [`verb-sources.md`](verb-sources.md) § step 6 | ⬜ | step 5's grammar |
| 9 | Import tranche 3: weak stems by frequency | [`verb-sources.md`](verb-sources.md) § step 7 | 🚧 blocked | **BBAW reply** |
| 10 | Etymologies, then the docs sweep | [`verb-sources.md`](verb-sources.md) §§ 8–9 | ⬜ | step 7 |

## The one check that runs through all of it

Every step from 4 onward is verified the same way. The classify-and-verify pipeline compares the
app against Wiktionary for 985 shipping verbs, and the corpus currently stands at **14 verbs at
odds, 99.0% verified**.

```bash
python3 verbdata/build_candidates.py --include-existing

TEST_RUNNER_KONJUGIEREN_CLASSIFY_IN="$PWD/verbdata/candidates.json" \
TEST_RUNNER_KONJUGIEREN_CLASSIFY_OUT="$PWD/verbdata/classification.json" \
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren \
  -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test \
  -only-testing:KonjugierenTests/VerbClassificationTests

python3 verbdata/summarize_classification.py
```

Baseline it before starting a step, re-run it after. **It should never rise.** If it does,
something regressed — find it before continuing.

The 294 MB kaikki snapshot is gitignored; `verbdata/README.md` has the SHA-256 and the
re-download recipe if it is missing.

## What to hand a fresh session

Each of these is enough to start. The prompts are written to be self-contained.

**Step 4 — regional variety**

> Please execute `prompts/regional_variation.md`.

**Step 5 — dual auxiliaries**

> Please execute `prompts/dual_auxiliary.md`. It assumes `prompts/regional_variation.md` has
> already run; it has, on 2026-07-19. Read "Regional before dual-auxiliary" below first: it
> records the exact post-step-4 state of the `ay` attribute and the three `ay="r"` verbs you must
> not disturb.

**Step 6 — the `fr` refactor**

> Please implement the "Step 4 in detail: store hits, derive rank" section of
> `docs/verb-sources.md`.

**Steps 7 onward — the import**

> Please execute step 5 of the "Recommended next steps" in `docs/verb-sources.md`, using the
> pipeline described in `docs/verb-classification.md`.

## Why this order

Three constraints produce it, and each was learned the expensive way.

**Fix the engine before importing.** The pipeline's proposed ablaut groups worked *around*
`Conjugator`'s defects. Importing first would have baked those workarounds into hundreds of
verbs, and fixing the engine afterward would have broken every one. Confirmed by measurement:
after the fixes, the same run needed 213 new ablaut groups instead of 346, from 34 distinct
patterns instead of 52.

**Model before data.** Steps 4 and 5 both reshape `Verbs.xml`, `VerbParser`, and `Verb`.
Migrating 990 verbs is cheap; migrating 7,700 is not.

**Regional before dual-auxiliary.** Both write into the `ay` attribute with different theories
of what it means — variation by *where the speaker lives* versus variation by *what the verb
means*. Running them in the other order means migrating the same attribute twice, with the
second pass having to undo the first's assumptions.

Step 4 has now run, so the state a step-5 session inherits is concrete, and worth reading before
touching `Verbs.xml`:

- `ay` legally takes `h|s|r`; the DTD was widened. `r` means "regionally conditioned" and is
  owned by exactly three verbs: *stehen*, *sitzen*, *liegen*. `VerbParser` maps `ay="r"` to a
  `Verb.auxiliaryIsRegional` flag and leaves the stored auxiliary at `haben`, which is what keeps
  `Conjugator` region-free.
- Those three prefixed derivatives (*bestehen*, *verstehen*, *besitzen*, *entstehen*, …) were
  deliberately **not** marked regional. They have lexicalized away from the positional sense that
  takes southern *sein* (*bestehen* = to pass, not to be standing), so step 5 should treat them on
  their own merits, not by analogy to the base.
- Step 4 added `Conjugator.conjugate(…, auxiliary: Auxiliary? = nil)` and a `RegionalConjugator`
  display wrapper precisely so a per-reading auxiliary can be expressed without making `Conjugator`
  itself region- or reading-aware. Step 5's dual-auxiliary readings should **reuse** that seam, not
  reinvent it, and must leave the three `ay="r"` verbs alone — their alternation is regional, not
  by meaning.

## The blocked one

Step 9 needs frequency ranks for thousands of weak verbs, and DWDS is the only good German
frequency source. BBAW reserves § 44b UrhG, so bulk querying and shipping derived ranks needs
written permission. The request went to `dwds@bbaw.de` on 2026-07-19; see
[`dwds-permission-email.md`](dwds-permission-email.md).

**This blocks only step 9.** Steps 7 and 8 are defined by membership — the strong bases, the
prefixed derivatives — not by frequency order, so the import can start without a reply. If none
arrives, rank that tranche by a provisional source and mark it for re-derivation.

## Known gaps that are nobody's step yet

Small things the pipeline surfaced that no plan currently owns. None blocks the sequence.

- **`mahlen` and `spalten`** — weak Präteritum with strong participle (*mahlte*, but
  *gemahlen*). Neither the mixed family nor the weak family fits. Wrinkle 4 in
  `verb-sources.md`; needs a new family or a full-override ablaut group.
- **Four ablaut groups are wrong** — *hängen*, *schaffen*, *schreien*, *vergleichen* verify only
  via a group that does not ship. *hängen* is really a `dual_auxiliary.md` class-4 verb; the
  other three are unexamined.
- **Three modals resist the pipeline** — *sollen*, *bedürfen*, *vermögen* use full-override
  ablaut groups the classifier cannot derive. Probably correct as shipped; unverified.
- **Everything in `prompts/` except step 5 is already executed** and now carries a status line
  saying so. Only `dual_auxiliary.md` is outstanding.
- **Swiss infinitive display beyond `VerbView`** — the ß→ss transform now covers displayed
  infinitives (headline, nav title, browse rows, quiz prompt, results, family cards) and search
  normalizes both sides. Widget snapshots and the Tutor still emit conjugations only; neither
  displays a bare infinitive today, but a future surface that does needs the same treatment.

## Done, for the record

| What | Commit | Notes |
|---|---|---|
| Verb-source research | — | Produced `verb-sources.md` from `prompts/more_verbs.md` |
| DTD given teeth + build-phase validation | `b8bf6fb`, `bc31b22` | `xmllint --valid` before compilation |
| Classify-and-verify pipeline | `1ae08da` | 6,857 of 8,232 incoming verbs verified |
| `Conjugator` epenthetic -e and -ern/-eln | `1ae08da` | 354 → 51 verbs at odds |
| ß/ss orthography | `1ae08da` | 51 → 25; 20 test expectations corrected |
| Prefix markers | `1ae08da` | 25 → 14 |
| Regional + dual-auxiliary planning | `b725ee3` | The prompts for steps 4 and 5 |
| Regional variety support | `95206ef` | Region setting, ß/ss transform (incl. displayed infinitives + search normalization), 3 regional-auxiliary verbs, dual-flag pill, Duden Info article; at-odds count held at 14 |
