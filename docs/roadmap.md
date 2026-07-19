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
| 7 | Import tranche 1: strong bases | [`verb-sources.md`](verb-sources.md) § step 5 | ✅ 2026-07-19 | steps 4–6 ✅; `hi` policy decided |
| 8 | Import tranche 2: prefixed derivatives | [`verb-sources.md`](verb-sources.md) § step 6 | ⬜ next | step 5 ✅; needs a wider prefix inventory |
| 9 | Import tranche 3: weak stems by frequency | [`verb-sources.md`](verb-sources.md) § step 7 | 🚧 blocked | **BBAW reply**; fetch needs probes |
| 10 | Etymologies, then the docs sweep | [`verb-sources.md`](verb-sources.md) §§ 8–9 | ⬜ | step 7 ✅ |

## The one check that runs through all of it

Every step from 4 onward is verified the same way. The classify-and-verify pipeline compares the
app against Wiktionary for 1,063 shipping verbs, and the corpus currently stands at **8 verbs at
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

**Step 8 — import tranche 2, the prefixed derivatives**

> Please execute step 6 of the "Recommended next steps" in `docs/verb-sources.md` — the second
> import tranche, the prefixed derivatives of verbs the app already conjugates. Start at
> `docs/roadmap.md`; steps 1–7 are done and step 8 is this one.
>
> **Baseline the classify-and-verify pipeline before you touch anything.** The recipe is in
> roadmap.md § "The one check that runs through all of it". The at-odds count is **8** and must
> never rise. Re-run it after each batch, not just at the end — an import can regress a shipping
> verb through a shared ablaut group.
>
> **Do not trust the verb counts in the prose.** Step 7 re-derived the "87 missing strong bases"
> and got 82; the prose was stale. Re-derive by set difference against
> `Konjugieren/Models/Verbs.xml`, the only source of truth; the recipe is in `verb-sources.md`'s
> "Verify counts, do not trust them" section. Note the derivative population also moved: the 2,406
> figure was computed against the old 990-verb corpus, and step 7 added 78 bases whose own
> derivatives now fall to this tranche. `docs/frequencies.txt` is generated — rerun
> `python3 verbdata/generate_frequencies_txt.py` after adding verbs, `--check` for drift.
>
> Read `docs/adding-verbs.md` first, and read `verbdata/import_tranche1.py`'s header second: it is
> the worked example of this exact task, and it records four things that cost step 7 real time —
> the region-widening convention that collapses proposed ablaut groups into shipping ones, why
> `sort_key` must not fold ß to ss, why some list members ship weak, and how the provisional `hi`
> estimates were placed.
>
> Four things to budget per verb, none of which the pipeline decides for you:
>
> - **`hi`** — a raw DWDS count, and you cannot invent one. Bulk querying is blocked pending BBAW;
>   **Josh decided on 2026-07-19 to use provisional counts**, so do not query DWDS. Read
>   "Provisional hit counts: the `hp` attribute" in `verb-sources.md`, mark every estimate
>   `hp="y"`, and place each one between the real `hi` values of shipping verbs you judge
>   comparable — not at round numbers, which land the verb wherever that happens to fall. Do
>   **not** consult Leipzig, even informally: it was evaluated and rejected, and its API data is
>   CC BY-NC, so an estimate informed by it is still derived from it. `VerbTests` pins the
>   provisional count at exactly 78, so a new tranche of estimates must update that expectation
>   deliberately.
> - **`ic`** — `#REQUIRED`, 40 distinct SF Symbol suffixes in use, chosen by taste.
> - **Auxiliary** — the interim policy is in `prompts/dual_auxiliary.md` § "Interim policy". Read
>   it; do not re-derive it. The DTD takes `h|s|r` and a combined `"hs"` fails validation
>   intentionally. Note the pipeline **cannot** check auxiliaries — it never compares a compound
>   tense — so a wrong `ay` will not move the at-odds count. Guard new ones with `ConjugatorTests`
>   cases on `perfektIndikativ`, as `strongBasesTranche1Auxiliaries` does.
> - **Ablaut group** — 73 ship today. A derivative almost always inherits its base's group, so
>   this tranche should need far fewer new ones than step 7's five.
>
> Do **not** mark prefixed derivatives regional (`ay="r"`). That attribute is owned by exactly
> three verbs — *stehen*, *sitzen*, *liegen* — and their derivatives have lexicalized away from the
> positional sense (*bestehen* = to pass, not to be standing). See "Why this order" below.
>
> The live blocker for this tranche is the **prefix inventory**: 747 incoming verbs have a first
> element no shipping verb uses as a prefix (*acht*, *abhanden*), so no hypothesis proposes
> separating it. Widening the inventory is part of this step, not a prerequisite someone else owns.
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

**Decided 2026-07-19: import with provisional counts.** Josh chose this over waiting for BBAW
(unbounded) and over querying just the tranche (~174 requests, a § 44b judgment call nobody here
is qualified to make). Imported verbs get an `hi` placed by editorial judgment and marked
`hp="y"`; when permission arrives, re-query with probes, replace `hi`, drop `hp`. Step 6 stored
counts rather than ranks precisely so that cleanup is one line per verb.

The cost, stated plainly: the corpus's displayed ranks are approximate until real counts land,
because the rank is derived globally and a misplaced new verb shifts its neighbours.

Two constraints on how estimates are formed:

- **Place them against real counts, not in the abstract.** Pick shipping verbs you judge
  comparable and take a value between their `hi` values. Round numbers like `100000` land the verb
  wherever that happens to fall, which is not a judgment about anything.
- **Do not consult Leipzig's numbers, even informally.** It was evaluated and rejected on
  2026-07-19 — see `verb-sources.md` — and its API data is CC BY-NC. An estimate "informed by"
  their measurements is still derived from them; the fact that a human retypes the number in
  between does not change that. The rejection is not merely that the numbers are bad, though they
  are; it is that they are not ours to ship.

## Known gaps that are nobody's step yet

Small things the pipeline surfaced that no plan currently owns. None blocks the sequence.

- **`mahlen` and `spalten`** — weak Präteritum with strong participle (*mahlte*, but
  *gemahlen*). Neither the mixed family nor the weak family fits. Wrinkle 4 in
  `verb-sources.md`; needs a new family or a full-override ablaut group. Step 7 confirmed the
  diagnosis and left both out: kaikki lists *only* the strong participle for these two, so
  nothing verifies. *salzen* looks identical but kaikki also lists the weak *gesalzt*, so it
  verified weak and shipped weak.
- **A strong verb whose stem ends in a vowel takes `-n`, not `-en`** — *wir schrien*, *wir
  spien*. `Conjugator` has no such rule, so shipping *schreien* smuggles the repair into its
  ablaut group as a full override (`geschrIEn*,pp`) and still gets the 1p/3p Präteritum wrong.
  This is the same shape as the `-ern`/`-eln` rule `hasSyllabicStamm` already implements, and
  fixing it would let *schreien* become a clean `IE,bA,dA,pp` and unblock *speien*, which step 7
  deferred rather than import a second copy of the workaround. One verb waiting, one bug.
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
| Import tranche 1: strong bases | — | 78 verbs (61 strong, 17 weak) and 5 ablaut groups, taking the corpus from 990 to **1,068**. Re-deriving the missing-base list gave 82, not the 87 the prose claimed. Rewriting the classifier's region-minimal proposals to the house convention collapsed 13 proposed groups into 5. All 78 verify against Wiktionary with their shipped encoding; at-odds held at 8. Every `hi` is provisional (`hp="y"`) |
