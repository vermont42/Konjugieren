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
| 8 | Import tranche 2: prefixed derivatives | [`verb-sources.md`](verb-sources.md) § step 6 | ✅ 2026-07-19 | step 5 ✅; prefix inventory widened |
| 8b | Clear the tranche-2 deferrals | this file, § "The tranche-2 deferrals" | ⬜ next | step 8 ✅ |
| 9 | Import tranche 3: weak stems by frequency | [`verb-sources.md`](verb-sources.md) § step 7 | 🚧 blocked | **BBAW reply**; fetch needs probes |
| 10 | Etymologies, then the docs sweep | [`verb-sources.md`](verb-sources.md) §§ 8–9 | ⬜ | step 7 ✅ |

## The one check that runs through all of it

Every step from 4 onward is verified the same way. The classify-and-verify pipeline compares the
app against Wiktionary for 3,378 shipping verbs, and the corpus currently stands at **8 verbs at
odds, 99.9% verified**.

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

**Step 8b — clear the tranche-2 deferrals**

Step 8 imported 2,303 verbs by rule and deliberately left four groups behind, each needing
judgment a bulk pass could not supply. They are listed in "The tranche-2 deferrals" below.

> Please clear the tranche-2 deferrals recorded in `docs/roadmap.md` § "The tranche-2
> deferrals". Steps 1–8 are done; this is the cleanup pass that step 8 could not do by rule.
>
> **Baseline the classify-and-verify pipeline before you touch anything.** The recipe is in
> roadmap.md § "The one check that runs through all of it". The at-odds count is **8** and must
> never rise.
>
> Read `verbdata/import_tranche2.py`'s header first. It states every rule step 8 applied and
> why, including the two that are the most arguable — that `hi` is derived from the base rather
> than measured, and that `tn` is normalized from kaikki rather than written. Both are worth
> re-examining while clearing the deferrals, because both are visible to users.
>
> The largest item is the **182 derivatives needing an ablaut group that does not ship**. Step 7
> added five groups by hand and step 8 added none, on the reasoning that adding 182 mechanically
> is how a `Conjugator` workaround becomes permanent data. Many of the 182 will collapse onto a
> shipping group once the ablaut region is rewritten to the house convention — that is what
> turned 13 proposed groups into 5 in step 7, and `docs/adding-verbs.md` § "Widen the region
> before you propose a new group" records the technique. Expect the residue to be small.
>
> Commit directly to `main`, and append a narrative entry to `docs/blog_notes.md` as you go.

## The tranche-2 deferrals

Four groups step 8 left behind, in rough order of size. None blocks step 9.

- **182 derivatives need an ablaut group that does not ship.** Deferred on the sequencing
  argument in `verb-classification.md`: a mechanically added group can encode a `Conjugator`
  gap rather than an ablaut, and 182 of them would be 182 pieces of permanent data. Rewriting
  each proposal to the house region convention first should collapse most of them onto groups
  that already ship.
- **176 imported verbs are dual-auxiliary and ship one reading.** `verbdata/tranche2-dual-auxiliary.txt`
  is the worklist, written by the import. It is a **historical** record and cannot be
  regenerated: once those verbs ship, the classifier skips them and a re-run produces nothing.
  The importer refuses to overwrite it with an empty result, which it learned by doing exactly
  that once. The `<reading>` model can express both; what the bulk
  pass could not do is decide which sense pairs with which auxiliary, 176 times. The interim
  policy in `prompts/dual_auxiliary.md` governs until then, and the pipeline cannot see the
  error, since it never compares a compound tense.
- **36 verbs lost their translation to normalization**, and 34 more had a gloss that pointed at
  another entry ("clipping of herumfahren") rather than translating. Both sets are recoverable
  by hand from kaikki's later glosses.
- **28 verbs still fail the prefix check.** The residue after the inventory fix: mostly noun and
  adjective compounds whose participle gives no usable evidence (*arschkriechen*, *bauchreden*).

`verbdata/tranche2-deferred.txt` lists the first, third and fourth groups verb by verb, with the
reason on each line. Unlike the dual-auxiliary list it is **recomputed on every run**, so it
always describes the current corpus rather than the state at import time — which is what step 8b
wants. Regenerate it with `python3 verbdata/import_tranche2.py --check`, which writes nothing
else.

Note that the importer must be run to a **fixpoint**, not once. Tranche 2's first pass made 12
further derivatives classifiable, because a double-prefix verb such as *hineinversetzen* needs
its inner base (*versetzen*) to ship before any hypothesis proposes separating the outer element.
Those 12 were imported in a second pass and a third returned nothing, which is where it stands.

Worth a separate look, because it is user-visible rather than merely absent: **2,303 translations
were normalized from kaikki glosses, not written.** Spot-reading them is the highest-value review
left. Most read well ("approach", "checkmate", "reprint"), but the source is lexicographic prose
and some come through thin — *untergehen* glossed as bare "set", *verkochen* as "vaporize,
forwall". `normalize_translation` in `verbdata/import_tranche2.py` is where the rules live.

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
- ~~**747 incoming verbs are blocked on the prefix inventory.**~~ **Fixed 2026-07-19**, in the
  classifier, during step 8. The inventory was derived from the prefixes 1,068 shipping verbs
  happened to use, so nothing proposed separating *weg*, *nieder*, *tot* or *acht*. But the
  evidence was already in the data: German infixes the participle's *ge-* **after** a separable
  first element, so wherever Wiktionary writes *ge-* somewhere other than the front, the text
  before it names the element. Reading the head off each participle needs no inventory and no
  maintenance, and it generalizes past particles to the adjective and noun compounds that behave
  identically — *kaputtgemacht*, *achtgegeben*, *eisgelaufen*. The queue fell 747 → 28 and
  incoming verification rose 84.4% → 94.6%. `Prefix` already carried an arbitrary string, so no
  shipping code changed.
- **Three modals resist the pipeline** — *sollen*, *bedürfen*, *vermögen* use full-override
  ablaut groups the classifier cannot derive. Probably correct as shipped; unverified.
- **`prompts/prefix_coverage.md` is written and not executed.** The Families tab buckets verbs
  into a hand-curated prefix list, so 923 verbs the app conjugates correctly cannot be reached
  by browsing, and the family card shows a count its own detail screen contradicts. Mostly
  caused by steps 7 and 8: the uncovered population was 72 verbs before them and is 923 now.
  Its step-3 design is decided (one flat "other prefixes" section); steps 1 and 2 are content
  work. Everything else in `prompts/` is executed and carries a status line saying so.
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
| Prefix inventory widened | — | The classifier now reads the separable head off Wiktionary's own participle instead of off a shipping-verb inventory, since German infixes the participle's *ge-* after a separable first element. Incoming verification 84.4% → **94.6%**; the prefix-gap queue collapsed 747 → 28, and adjective and noun compounds (*kaputtmachen*, *achtgeben*) became expressible |
| Import tranche 2: prefixed derivatives | — | 2,315 verbs, corpus 1,068 → **3,383**, no new ablaut groups. `hi` derived from each base by a ratio measured off the corpus's own 446 real derivative/base pairs, clamped to the rank-900 count; `ic` inherited from the base; `tn` normalized from kaikki. All 2,315 verify with their shipped encoding; at-odds held at 8 |
