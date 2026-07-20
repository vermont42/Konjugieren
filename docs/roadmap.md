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
| 8b | Clear the tranche-2 deferrals | this file, § "The tranche-2 deferrals" | ✅ 2026-07-19 | step 8 ✅ |
| 9 | Import tranche 3: weak stems by frequency | [`verb-sources.md`](verb-sources.md) § step 7 | 🚧 blocked | **BBAW reply**; fetch needs probes |
| 10 | Etymologies, then the docs sweep | [`verb-sources.md`](verb-sources.md) §§ 8–9 | ⬜ | step 7 ✅ |

## The one check that runs through all of it

Every step from 4 onward is verified the same way. The classify-and-verify pipeline compares the
app against Wiktionary for 3,567 shipping verbs, and the corpus currently stands at **8 verbs at
odds, 99.9% verified**.

**Rebuild `candidates.json` first, every time.** The recipe below starts with `build_candidates.py`
for a reason that is invisible until it bites: `alreadyShipping` is computed there and baked into
the file, not read from `Verbs.xml` by the classifier. Re-running only the classifier after an
import therefore re-derives the newly shipped verbs as though they were incoming, and the
already-shipping population — the regression oracle the at-odds count is measured over — silently
stays at its old size. Step 8b hit this and read a stale 3,378 twice before noticing.

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

**Prefix coverage in the Families tab** — executed 2026-07-19, commit `08a5e93`.

**Step 8b — clear the tranche-2 deferrals** — done 2026-07-19. See "The tranche-2 deferrals" below
for what it cleared, what it deliberately left excluded, and the 26 verbs still waiting on an
ablaut group.

## The tranche-2 deferrals

**Cleared on 2026-07-19.** Step 8 left four groups behind; step 8b imported 189 of them, taking
the corpus from 3,383 to **3,572**, and reduced `verbdata/tranche2-deferred.txt` from 270 rows to
78. The at-odds count held at 8 through every pass.

What remains in that file is 78 verbs in four groups, and **52 of them are deliberate exclusions
that should stay excluded**, not gaps:

- **31 verbs whose every gloss points at another entry** — *benützen* is "alternative form of
  benutzen", *heraufgehen* is "alternative form of raufgehen". The entry they point at is already
  in the corpus, so importing these would ship the same verb twice under two spellings.
- **18 archaic or pre-1996 spellings** — the `bey-` and `auß-` ones, plus four the lemma does not
  betray at all: *radfahren*, *probefahren*, *spazierengehen* and *maschineschreiben* are
  compounds the 1996 reform split into two words, and only kaikki's gloss says so.
- **3 Swiss ss-spellings** whose sharp-s twin already ships. Swiss rendering is a display
  transform, never stored.
- **26 verbs needing an ablaut group that does not ship** — down from 182, and this is the only
  one of the four that is a real gap. The residue is now mostly singletons; see below.

The other two deferral groups are gone entirely. **The 36 verbs that "lost their translation to
normalization" no longer exist as a category**: the normalizer now falls through to later glosses,
which rescued 24; fifteen more are written by hand in `HAND_TRANSLATIONS`; the rest turned out to
be the reform casualties above. **The dual-auxiliary worklist is unchanged in kind but has grown**
to 193 rows, 17 of them added by 8b's import — see below.

### What collapsed the 182, and why it was worth doing in the classifier

Nearly all of them were a shipping group seen through an ablaut region one consonant too narrow —
*abbeissen* proposed as `b^ei^ssen`/`I` where the corpus writes *reißen* as `r^eiss^en`/`ISS`. The
technique for spotting that is `adding-verbs.md` § "Widen the region before you propose a new
group", but the fix belongs in `VerbClassificationTests.swift`, not in 182 hand edits: the
classifier enumerated regions shortest-first and **returned on the first one that verified**, so
the narrow encoding won before the wide one was ever tried. Preferring a region whose group
matches something already shipping, and keeping shortest-first only as the tiebreak, took the
count from 233 to 89 in one run. Two smaller classifier fixes took it to 37, and the import to 26.

Full-table verification is what makes preferring reuse safe: a region only reaches the comparison
once it is known to conjugate the whole verb correctly, so both encodings are already right and
the choice between them is about which data the corpus has to carry.

### Two things in the shipping data that were blocking reuse

- **`haben`'s ablaut group was nine full-word overrides** (`hATte*`, `hÄTte*`, …) spelling out by
  hand what the mixed family already derives from `A,a2s,a3s|AT,bA|ÄT,dA`. An override bakes in
  the literal word, so no prefixed derivative could reuse it, and *anhaben*, *aufhaben* and 21
  others each wanted a private group describing exactly that pattern. Rewritten; all 210 tests
  pass, which matters more here than usual because `haben` is the auxiliary in every compound
  conjugation in the app.
- **`treten`'s group carries `ET,pp`, a replacement identical to the region it replaces.** It
  spells no new letters and exists only to mark the region for the mixed-case highlighting
  convention — `ConjugatorTests` pins `getrETen` deliberately. `minimize` correctly drops such an
  entry from a *proposal*, and that asymmetry alone kept 20 derivatives from matching a group they
  conjugate identically to. Fixed by ignoring identity replacements when comparing, so the
  derivatives inherit the family's highlighting instead. The shipping group and its pinned test
  are untouched.

### Still open

- **26 verbs need a genuinely new ablaut group.** Mostly singletons now. The largest cluster is 8
  verbs on `I,b1p,b3p,dA,pp|IE,b1s,b2p,b2s,b3s` — *anschreien*, *anspeien*, *aufschreien* — which
  is the *schreien* problem already recorded under "Known gaps": a strong verb whose stem ends in
  a vowel takes `-n`, not `-en`, and `Conjugator` has no such rule. Fix that rule and these 8 and
  their base collapse together. The rest need judgment one verb at a time.
- **193 verbs are dual-auxiliary and ship one reading.** `verbdata/tranche2-dual-auxiliary.txt` is
  the worklist. It is **historical and cumulative** — once a verb ships the classifier skips it,
  so a row that leaves the file can never be rediscovered. It is now written as a union and rows
  are only ever added. It used to be replaced, guarded only against an empty result, and step 8b's
  first re-run produced 17 rows and overwrote 176 rows of history with them. Non-empty is not the
  same as complete; the guard was wrong, not merely incomplete.
- **~28 verbs still fail the prefix check** — mostly noun and adjective compounds whose participle
  gives no usable evidence (*arschkriechen*, *bauchreden*).

Unlike the dual-auxiliary list, `verbdata/tranche2-deferred.txt` is **recomputed on every run**,
so it always describes the current corpus. Regenerate it with
`python3 verbdata/import_tranche2.py --check`.

The importer must still be run to a **fixpoint**, not once, because a double-prefix verb such as
*hineinversetzen* needs its inner base (*versetzen*) to ship before any hypothesis proposes
separating the outer element. Step 8b's second pass returned nothing new.

### The translations, spot-read

The roadmap called reading the ~2,300 machine-normalized translations the highest-value review
left, and it was right, though not for the reason it gave. The thin ones (*untergehen* as bare
"set") are mostly honest: kaikki offers nothing better. The real defect was a wrong assumption
stated as a comment — that a semicolon inside a kaikki gloss separates distinct senses. It
separates near-*synonyms*; distinct senses get their own gloss. So the rule kept only the text
before the first semicolon and, worse, kept whichever synonym kaikki happened to list first.
*aufbleiben*, glossed "to wake; to stay awake; to stay up", shipped as **"wake"** — which is not
what *aufbleiben* means. 106 shipped translations were rewritten; all but one are strictly
additive, and the exception replaced a leaked pointer with a real translation.

`--retranslate` re-runs the current rules over the translations the importer generated, and only
those. Ownership is decided by two conditions that both have to hold: `hp="y"`, and the old rule
reproducing what ships. Neither works alone — `hp` sweeps in tranche 1's hand-written translations
(it would have replaced *leihen*'s "lend, borrow" with a bare "borrow"), and the fingerprint alone
sweeps in the original 990, where a translation short enough to be obvious is one the rule
reproduces by coincidence (*wollen*'s "want" would have become "want, wish, desire, demand").

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
  deferred rather than import a second copy of the workaround. **This is now the highest-value
  `Conjugator` fix outstanding**: step 8b left 26 verbs needing a new ablaut group, and 8 of them
  are this same pattern (*anschreien*, *anspeien*, *aufschreien*, …). One missing rule, nine verbs.
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
- ~~**`prompts/prefix_coverage.md` is written and not executed.**~~ **Executed 2026-07-19**,
  commit `08a5e93`. The Families tab bucketed verbs into a hand-curated prefix list, so 923 verbs
  the app conjugates correctly could not be reached by browsing. Everything in `prompts/` is now
  executed and carries a status line saying so. Note that the separable side is open class, so
  every future tranche adds to the "other prefixes" section rather than to the curated list —
  8b's 189 verbs included.
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
| Clear the tranche-2 deferrals | — | 189 verbs, corpus 3,383 → **3,572**, no new ablaut groups. The 182 derivatives blocked on a missing group fell to 26, almost entirely by one classifier fix: prefer a region whose group already ships over the shortest region that verifies. Two shipping-data blockers cleared with it — `haben`'s nine full-word overrides became the mixed pattern they were spelling out, and identity replacements like `treten`'s `ET,pp` are now ignored when matching. 106 shipped translations rewritten after finding that a semicolon inside a kaikki gloss separates synonyms, not senses (*aufbleiben* shipped as "wake"). At-odds held at 8 |
| Import tranche 2: prefixed derivatives | — | 2,315 verbs, corpus 1,068 → **3,383**, no new ablaut groups. `hi` derived from each base by a ratio measured off the corpus's own 446 real derivative/base pairs, clamped to the rank-900 count; `ic` inherited from the base; `tn` normalized from kaikki. All 2,315 verify with their shipped encoding; at-odds held at 8 |
