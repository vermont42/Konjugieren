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
| 5 | Dual auxiliaries + double-prefix grammar | [`../prompts/dual_auxiliary.md`](../prompts/dual_auxiliary.md) | ✅ 2026-07-19 | step 4 ✅ |
| 6 | Refactor `fr`: store hits, derive rank | [`verb-sources.md`](verb-sources.md) § "Step 4 in detail" | ✅ 2026-07-19 | — |
| 7 | Import tranche 1: strong bases | [`verb-sources.md`](verb-sources.md) § step 5 | ⬜ next | steps 4–6 ✅; needs an `hi` policy |
| 8 | Import tranche 2: prefixed derivatives | [`verb-sources.md`](verb-sources.md) § step 6 | ⬜ | step 5 ✅; needs a wider prefix inventory |
| 9 | Import tranche 3: weak stems by frequency | [`verb-sources.md`](verb-sources.md) § step 7 | 🚧 blocked | **BBAW reply**; fetch needs probes |
| 10 | Etymologies, then the docs sweep | [`verb-sources.md`](verb-sources.md) §§ 8–9 | ⬜ | step 7 |

## The one check that runs through all of it

Every step from 4 onward is verified the same way. The classify-and-verify pipeline compares the
app against Wiktionary for 985 shipping verbs, and the corpus currently stands at **8 verbs at
odds, 99.7% verified**.

**The metric changed on 2026-07-19 and is now stricter, so do not compare it to older figures.**
It used to count only verbs the classifier could not verify at all, plus verbs whose repair needed
an ablaut group that does not ship. It missed a third and larger category: a verb whose shipped
encoding failed but which the classifier rescued using a group that *already* ships was reported
verified while the app conjugated it wrongly. That hid 67 broken verbs, all now fixed. The
`shippedEncodingFailed` flag on each classification is what closed the gap.

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

**Step 7 — import tranche 1, the strong bases**

Decide the `hi` policy before handing this over; see "The blocked one" below.

> Please execute step 5 of the "Recommended next steps" in `docs/verb-sources.md` — the first
> import tranche, the missing strong bases plus their common derivatives. Start at
> `docs/roadmap.md`; steps 1–6 are done and step 7 is this one.
>
> **Baseline the classify-and-verify pipeline before you touch anything.** The recipe is in
> roadmap.md § "The one check that runs through all of it". The at-odds count is **8** and must
> never rise. Re-run it after each batch, not just at the end — a tranche import can regress a
> shipping verb through a shared ablaut group.
>
> **Do not trust the verb counts in the prose.** `verb-sources.md` says 87 missing strong bases
> in one place and "44 named" in another; those are different populations and at least one is
> stale. Re-derive by set difference against `Konjugieren/Models/Verbs.xml`, the only source of
> truth; the recipe is in that file's "Verify counts, do not trust them" section.
> `docs/frequencies.txt` is a generated lemma list in rank order and is current as of 2026-07-19;
> rerun `python3 verbdata/generate_frequencies_txt.py` after adding verbs, and `--check` to see
> whether it has drifted.
>
> Read `docs/adding-verbs.md` first: the XML format changed twice on 2026-07-19 and any example
> you remember is wrong. Each `<verb>` now holds one or more `<reading>` children; `fr` is retired
> and `hi` holds a raw DWDS hit count, with the displayed rank derived at parse time. A **Validate
> Verbs.xml** build phase runs `xmllint --valid`, so a malformed verb fails the build with a
> file-and-line diagnostic rather than shipping silently.
>
> Four things to budget per verb, none of which the pipeline decides for you:
>
> - **`hi`** — a raw DWDS count, and you cannot invent one. Bulk querying is blocked pending BBAW;
>   follow whatever policy Josh set when handing you this task, and if none was set, ask before
>   fetching. If the answer is provisional counts, read "Provisional hit counts: the `hp`
>   attribute" in `verb-sources.md` and mark every estimate with `hp="y"` — place each estimate
>   between the real counts of verbs you judge it comparable to, rather than picking round
>   numbers. Do **not** reach for Leipzig; it was evaluated and rejected on 2026-07-19, and the
>   section above that one says why. If real counts are authorised,
>   `verbdata/fetch_dwds_frequencies.py` refuses contaminated rows but needs probes: supply two
>   per lemma from kaikki's `forms[]` (`perfektpartizip`, `präsensIndikativ.ts`).
> - **`ic`** — `#REQUIRED`, 40 distinct SF Symbol suffixes in use, chosen by taste.
> - **Auxiliary** — the interim policy is in `prompts/dual_auxiliary.md` § "Interim policy". Read
>   it; do not re-derive it. The DTD takes `h|s|r` and a combined `"hs"` fails validation
>   intentionally. Note the pipeline **cannot** check auxiliaries — it never compares a compound
>   tense — so a wrong `ay` will not move the at-odds count. Guard new ones with `ConjugatorTests`
>   cases on `perfektIndikativ`.
> - **Ablaut group** — 68 ship today. The classifier proposes new ones, and strong bases are
>   exactly the population most likely to need them. New groups go in `AblautGroups.xml`.
>
> Do **not** mark prefixed derivatives regional (`ay="r"`). That attribute is owned by exactly
> three verbs — *stehen*, *sitzen*, *liegen* — and their derivatives have lexicalized away from the
> positional sense (*bestehen* = to pass, not to be standing). See "Why this order" below.
>
> Two known gaps that bite in this tranche specifically. *mahlen* and *spalten* are weak Präteritum
> with strong participle, which neither family expresses — they need a new family or a full-override
> ablaut group, and are wrinkle 4 in `verb-sources.md`. And the de.wikipedia list is deliberately
> exhaustive, reaching into the attic (*kiesen*, *brinnen*, *eischen*): an editorial pass should
> decide how deep to go, and the pedagogical core is perhaps 60 of the 87.
>
> Commit directly to `main`, and append a narrative entry to `docs/blog_notes.md` as you go.

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

**It blocks step 9 outright, and now touches steps 7 and 8 too.** Those two are defined by
membership — the strong bases, the prefixed derivatives — not by frequency order, so their
*selection* needs no reply. But step 6 changed what an import must supply: `hi` is `#REQUIRED`
and holds a raw DWDS count, which cannot be assigned by judgment the way the old `fr` rank could.
Every imported verb therefore needs either a real count or an explicitly provisional one.

Decide this before starting step 7. Three options, and the choice is Josh's:

- **Wait for BBAW.** Cleanest, and unbounded in time.
- **Query just the tranche.** ~87 lemmas, ~174 requests with two probes each. Whether that is
  citation-scale or the § 44b commercial use BBAW reserved is a judgment call, not a technical one.
- **Import with provisional counts**, placed by editorial judgment and marked `hp="y"` in the
  XML. The refactor makes this cheap — a provisional `hi` is one number per verb, and replacing
  it later is a one-line change rather than a renumber — though the corpus's displayed ranks stay
  approximate until real counts land, since the rank is derived globally. **Leipzig Corpora was
  evaluated as a source for this on 2026-07-19 and rejected**: its API data is CC BY-NC, it is
  1,000× smaller than DWDS, 17 of the 87 strong bases are absent from it entirely, and it measures
  word forms rather than lemmas. See "Leipzig Corpora Collection was evaluated as a substitute and
  rejected" in `verb-sources.md`.

## Known gaps that are nobody's step yet

Small things the pipeline surfaced that no plan currently owns. None blocks the sequence.

- **`mahlen` and `spalten`** — weak Präteritum with strong participle (*mahlte*, but
  *gemahlen*). Neither the mixed family nor the weak family fits. Wrinkle 4 in
  `verb-sources.md`; needs a new family or a full-override ablaut group.
- **Three ablaut groups are wrong** — *schaffen*, *schreien*, *vergleichen* verify only via a
  group that does not ship, and remain unexamined. *hängen* was the fourth and is fixed: it was a
  `dual_auxiliary.md` class-4 verb and now ships two readings.
- **Two verbs are editorially ambiguous** — *helfen* (Wiktionary's *hülfe* against the shipped
  *hälfe*) and *verstoßen* (the shipped Präsens umlaut *du verstößt* against a table without it).
  Both need a human to pick, not more code.
- **A bulk DWDS fetch still needs probe generation.** Querying a bare infinitive silently
  resolves a verb that is also an adjective or noun to the wrong word — *runden* scored as
  *rund*. Eight such verbs were found and repaired on 2026-07-19, and the script now **refuses to
  write** a contaminated row rather than warning about it (verified live against all eight). What
  remains is generating the probes themselves for an import, which belongs to the import step:
  kaikki's `forms[]` carries `perfektpartizip` and `präsensIndikativ.ts` for every candidate, so
  no `Conjugator` round-trip is needed. Supply two probes per lemma and the gate cross-checks
  them against each other.
- **747 incoming verbs are blocked on the prefix inventory**, not on grammar. Their first element
  — *acht*, *abhanden* — is not a prefix any shipping verb uses, so no hypothesis proposes
  separating it. Widening the inventory belongs to the import step. The summary used to file these
  under "double prefix", which is no longer true after step 5 and would send a session to rewrite
  correct code.
- **Three modals resist the pipeline** — *sollen*, *bedürfen*, *vermögen* use full-override
  ablaut groups the classifier cannot derive. Probably correct as shipped; unverified.
- **Everything in `prompts/` is now executed** and carries a status line saying so.
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
| Dual auxiliaries + double-prefix grammar | — | Nested `<reading>` model across all 990 verbs, repeated prefix markers, 38 verbs given a second reading, reading picker in `VerbView`, reading-aware quiz. Fixed 7 double-prefix verbs, *hängen*, and 67 verbs whose broken encoding the old metric hid; 14 → 8 at odds |
| `fr` → `hi`: store hits, derive rank | — | `Verbs.xml` stores raw DWDS counts; `VerbParser` derives the 1..n rank at parse time. `fr` retired from the DTD so a stale writer fails the build. Ranks moved a median of 43 places; at-odds held at 8 |
