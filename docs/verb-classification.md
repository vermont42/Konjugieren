# The classify-and-verify pipeline

Step 2 of the plan in [`verb-sources.md`](verb-sources.md), built and first run on 2026-07-19.
It takes the kaikki.org Wiktionary extraction and, for every candidate verb, searches for the
`Verbs.xml` encoding whose `Conjugator` output reproduces Wiktionary's conjugation table
exactly. A hit confirms family, ablaut group, ablaut region, and prefix simultaneously.

The headline result was not the incoming verbs. It was that **354 of the 985 verbs Konjugieren
already shipped disagreed with Wiktionary**, collapsing into a handful of causes. The pipeline
was built to import verbs and its first useful act was to audit the ones already here.

Those defects were fixed the same day — in `Conjugator`, and then in the data — and the count
is now **14**. The sections below record the audit as it stood before each fix, then what
changed. Re-running all three stages is the regression test.

## Running it

Three stages, about 50 seconds end to end once the 294 MB snapshot is in place.

```bash
# A. 294 MB kaikki JSONL → a compact candidate file (~6 s)
python3 verbdata/build_candidates.py --include-existing

# B. Drive Conjugator over every candidate (~40 s)
TEST_RUNNER_KONJUGIEREN_CLASSIFY_IN="$PWD/verbdata/candidates.json" \
TEST_RUNNER_KONJUGIEREN_CLASSIFY_OUT="$PWD/verbdata/classification.json" \
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren \
  -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test \
  -only-testing:KonjugierenTests/VerbClassificationTests

# C. Render the queue, grouped by cause
python3 verbdata/summarize_classification.py
```

Stage B lives in the test target because `Conjugator` resolves verbs through
`Verb.verbs`, so a candidate must be inserted into that dictionary before it can be
conjugated at all, and only `@testable import Konjugieren` reaches it. `VerbExportTests` set
the precedent for driving app code over the whole corpus from a test.

Two mechanics worth knowing. `xcodebuild` forwards a host environment variable to the test
process only if it is named `TEST_RUNNER_<NAME>`, which is why the invocation looks like that;
and the suite is gated on `KONJUGIEREN_CLASSIFY_IN` being set, because it mutates
`Verb.verbs` and `AblautGroup.ablautGroups`, which every other suite reads. An ordinary
`run_tests.sh` never sees it.

`--include-existing` keeps the 985 shipping verbs in the candidate set. They cost nothing and
they are the calibration: for those, the right answer is already in `Verbs.xml`, so a
disagreement is a defect rather than an unknown.

## How a hypothesis is tested

The obvious design — try every shipped ablaut group against all contiguous stem regions for all
9,217 verbs — is tens of millions of conjugation batches. The pipeline does something cheaper
and more exact: it **derives** the ablaut rather than searching for it.

1. Try `weak`, then `-ieren`. Most verbs stop here.
2. Otherwise, for each candidate region (shortest first, always opening on a vowel, since a
   German ablaut region is a vowel nucleus plus any consonants that travel with it), probe
   `Conjugator` with a sentinel replacement to learn where the region lands in the output.
3. For each conjugationgroup, search the suffixes of Wiktionary's form for the replacement
   that makes `Conjugator` produce exactly that form.
4. Minimize: drop every entry the `Conjugator` can already infer, chiefly the e→i Imperativ
   stem change it derives from the Präsens 2s ablaut. Without this step no derived group would
   ever equal a shipped one.
5. Compare the minimized group against every shipped group. Equal means reuse the exemplar's
   name; otherwise propose a new group.

Step 3 is the subtle one. The first draft read the replacement straight off the probe by
aligning head and tail, which is wrong: `Conjugator`'s ending depends on the stem's final
letter, so *beißen*'s Präsens 2s is `beißt`, not `beißst`, and a sentinel ending in Ω does not
model that. Only the probe's **head** is trustworthy. Searching the suffixes and then
re-conjugating to confirm is both simpler and immune to every phonological rule `Conjugator`
has or ever will have — the oracle is `Conjugator` itself, so nothing about endings is
duplicated here.

Comparison is case-insensitive because `Conjugator` uppercases ablaut regions for the
highlighting convention (`sAng`) while Wiktionary does not, and it accepts Wiktionary's joined
and split spellings of separable verbs (`abbeiße` beside `beiße ab`) plus the optional
Imperativ 2s `-e`.

## What it found in the shipping corpus (before the fix)

| Verbs | Cause |
|---|---|
| 110 | Imperativ 2p drops the epenthetic -e after a d/t stem: `arbeitt` for *arbeitet* |
| 67 | -ern/-eln verbs take -en where German takes -n: `änderen` for *ändern* |
| 26 | Other, individually |
| 20 | Epenthetic -e appears where German has none: `stimmete` for *stimmte*, `ahnete` for *ahnte* |
| 13 | Perfektpartizip of a double prefix: `angegehört` for *angehört* |

Four of these five are one phenomenon seen from different angles: the **epenthetic -e**, the
vowel German slips between a stem and its ending when the two would otherwise collide. English
speakers apply the identical repair without noticing it — *wanted* and *needed* get a full
syllable that *walked* and *jumped* do not, and for exactly the same reason German says
*arbeitet* rather than *arbeitt*. It is a dental-cluster problem, and both languages solved it
the same way.

`Conjugator` implements the rule in `adjustEndingForPhonology`, but only for the Präsens and
Präteritum of weak and -ieren verbs. Three gaps follow directly:

- **`conjugateImperativ` never calls it.** The 2s branch has its own ad-hoc `hasSuffix("d") ||
  hasSuffix("t")` test; the 2p branch has nothing, so `newStamm + "t"` yields `arbeitt`.
- **`.mixed` and `.strong` fall through to `break`.** The shipped `finden` group is
  `A,bA|Ä,dA|U,pp` with no `e` anywhere, so the app produces *du findst* for *du findest*.
  *finden* nonetheless shows as verified, which is the subtlest result in the run: the pipeline
  reproduced Wiktionary's table only by proposing
  `INDE,a2p,a2s,a3s,i2p|AND,…|ANDE,b2p|ÄND,dA|UND,pp`, a group that does not ship. **118 of the
  304 shipping strong and mixed verbs verified this way** — *abnehmen*, *anbieten*, *anhalten*,
  *aufhalten*, *abschneiden* among them. Read `ablautGroupIsNew` on an already-shipping verb as
  "the shipped group is wrong"; those 118 are why the real defect count is 354, not 236.
- **The exemption list is too narrow.** `needsEpentheticE` exempts an `m`/`n` stem only when
  the preceding letter is `l`, `r`, or a vowel. That misses doubled consonants (*stimmen* →
  `stimmete`) and the Dehnungs-h (*ahnen* → `ahnete`, *lehnen*, *gewöhnen*).

The -ern/-eln cluster is separate and simpler: for a stem already ending in `er`/`el`, the
1p/3p ending is `-n` and the Präsenspartizip is `-nd`, but `Conjugationgroup.ending` returns
`en`/`end` unconditionally. 67 shipping verbs are affected, including *ändern*, *wandern*, and
*auffordern*.

The double-prefix cluster is a model limitation rather than a bug in the code. `Prefix` holds
one prefix, so *angehören* (separable *an* over inseparable *ge*) cannot be written; it ships
as `an+gehören` and produces `angegehört`.

## What it found in the incoming pool (before the fix)

| Population | Candidates | Verified |
|---|---|---|
| Already shipping | 985 | 749 (76.0%), of which 118 only via a group that does not ship |
| Incoming | 8,232 | 4,812 (58.5%) |

Of the 4,812: 2,715 weak, 1,134 -ieren, 898 strong, 65 mixed. Among the strong and mixed, 617
reuse an ablaut group that already ships and 346 need a new one, drawn from 52 distinct
proposed patterns. 4,128 arrive carrying an etymology.

The strong-verb milestone is close to done on the classification side. Of the 44 missing
strong verbs named in `verb-sources.md`, **42 verified automatically**, including every one of
the thirteen finds — *gedeihen*, *schwören*, *spinnen*, *genesen*, *dreschen*, *melken*,
*bersten*, *sieden*, *verdrießen*, *kiesen*, *wringen*, *küren* — plus *beißen*, *braten*,
*graben*, *frieren*, *lügen*, and *kriechen*. *graben* needs no new group at all: it reuses
*fahren*.

The two that failed are *mahlen* and *spalten*, which is a pleasing result, because those are
precisely wrinkle 4 in `verb-sources.md`: weak Präteritum with strong participle. The pipeline
rediscovered the documented gap without being told about it.

## The fix, and what it moved

Done 2026-07-19, in `Conjugator.swift` only. No `Verbs.xml`, no `AblautGroups.xml`, and no
existing `ConjugatorTests` expectation was touched.

- `needsEpentheticE` became a named function used by all four call sites that need it — the
  simple tenses, the Perfektpartizip, and both Imperativ branches. The Imperativ 2p had never
  consulted any phonological rule at all.
- Its exemption list gained `m` and `n` (so *stimmte*, *gewinnt*) and a Dehnungs-h test: an `h`
  preceded by a vowel is a length mark and exempts, an `h` preceded by anything else is half of
  `ch` and does not. That one test separates *ahnte* and *wohnte* from *rechnete* and *zeichnete*.
- `.strong` and `.mixed` now take the -e where German does. The condition is `stammIsAblauted`:
  a strong verb that changes its stem in the Präsens keeps the old endingless 3s (*er hält*),
  and an unchanged stem takes the ordinary ending (*er findet*, *ihr haltet*). The same flag
  now gates the t-dropping rule, which previously fired for *ihr haltet* too.
- `.mixed` is excluded from the Präteritum and the Partizip, because a mixed verb attaches its
  -te and -t to the ablauted stem directly: *sandte*, *gewandt*, *gebrannt*.
- `hasSyllabicStamm` gives -ern and -eln verbs `-n` and `-nd` instead of `-en` and `-end`. The
  test is on the infinitive, not the stem: *verheeren*'s stem also ends in `er`, and *tun* and
  *sein* end in `-n` without the syllable (*wir taten*, *seien wir*).

Figures below span the whole day — the epenthetic-e and -ern/-eln fixes in this section,
plus the ß/ss and prefix-marker passes recorded further down.

| Measure | Before | After |
|---|---|---|
| Shipping verbs at odds with Wiktionary | 354 | 14 |
| Shipping verification rate | 76.0% | 99.0% |
| Incoming verification rate | 58.5% | 83.3% |
| Incoming verbs classified | 4,812 | 6,857 |
| Incoming needing a new ablaut group | 346 | 213 |
| Distinct new patterns proposed | 52 | 34 |

The last three rows are the point of the sequencing argument below: the same run now proposes
fewer and simpler groups, because it no longer has to smuggle a missing `-e` into them.

Five test functions were added to `ConjugatorTests` covering the fixed behavior. Every
expectation in them came from Wiktionary via this pipeline rather than from the engine's own
output, and all five passed on the first run without adjustment.

## Sequencing: fix `Conjugator` before importing

This is the recommendation the run exists to produce.

The 52 proposed ablaut groups are correct — each was verified against Wiktionary — but many
are correct *by working around the epenthetic-e gaps*. The group proposed for *binden* is

```
INDE,a2p,a2s,a3s,i2p|AND,b1p,b1s,b2s,b3p,b3s|ANDE,b2p|ÄND,dA|UND,pp
```

where the shipped `finden` group is just `A,bA|Ä,dA|U,pp`. The `INDE`, the `ANDE`, and the
split between `b2p` and the other five persons are all the missing `-e` smuggled into the
ablaut region, because that is the only lever the pipeline has. 145 of the proposed groups
show this shape, flagged in the summary as varying by person inside a past tense.

Import first and those workarounds become permanent data, in hundreds of verbs, and the
epenthetic-e fix then breaks every one of them. Fix `Conjugator` first and the same run
proposes the small, idiomatic groups instead — and the shipping-corpus failure count is the
regression test, since it should fall from 236 toward zero.

Recommended order:

1. ~~Fix the epenthetic -e.~~ **Done 2026-07-19.**
2. ~~Fix -ern/-eln endings.~~ **Done 2026-07-19.**
3. ~~The ß/ss orthography.~~ **Done 2026-07-19**, in data only — see below.
4. Decide the double-prefix question. 1,186 incoming verbs and 13 shipping ones need it, and it
   overlaps wrinkle 7 and the separable/inseparable class in
   [`../prompts/dual_auxiliary.md`](../prompts/dual_auxiliary.md).
5. Re-run all three stages after each; the shipping-corpus count is the regression test.
6. Then import, starting with the strong bases.

## The ß/ss fix, and a test suite that had documented the bug

Done 2026-07-19, in `Verbs.xml` and `AblautGroups.xml` only. `Conjugator` needed no change:
the alternation depends on the ablauted vowel's length, which is exactly what an ablaut group
is for. 20 shipping verbs were wrong, **in both directions at once** — *schließen* yielded
`schloß` where German writes *schloss*, and *essen* yielded `ass` where German writes *aß*.

The mechanical part was widening each region to carry the sibilant (`^ess^en` for `^e^ssen`,
`schl^ieß^en` for `schl^ie^ßen`) so each replacement could spell it, and writing the ß as the
capital sharp s `ẞ` so the highlight covers it. Three groups had to be split, because a group
had been shared by verbs on opposite sides of the alternation: *riechen* rode with *schließen*
but has no sibilant and moved to the identical `bieten`; *messen* and *vergessen* rode with
*geben*; and *fressen* rode with *essen*, inheriting its `gegEssen*` participle override and
conjugating to *gegessen*. Two full overrides in the *lassen* group disappeared outright, since
a correctly placed region produces *lässt* and *ließ* without them.

The instructive part is that **`ConjugatorTests` had documented the defect as intended
behavior**: `expected: "Ass"` for *essen*, `"schlOß"` for *schließen*, `"wEIsS"` for *wissen*.
Twenty expectations went red on the fix. Each new value was checked against Wiktionary before
being written, not copied from the engine's output — the distinction that separates fixing a
test from laundering a bug through it. Six of the twenty were casing-only (`Isst` → `ISSt`),
where the rendered form was already right and only the highlighted span widened.

| Measure | Before | After |
|---|---|---|
| Shipping verbs at odds with Wiktionary | 51 | **25** |
| Shipping verification rate | 96.4% | 97.9% |
| Shipping groups that were wrong | 16 | 4 |

## The prefix-marker pass

Done 2026-07-19, in `Verbs.xml`. Eleven entries carried the wrong prefix marking, and sorting
them out took the shipping corpus to **14 verbs at odds, 99.0% verified**.

Five were simply unmarked — `zerstören` for `zer*stören`, `herstellen` for `her+stellen`, and
likewise `sicherstellen`, `kennenlernen`, `ausprobieren` — so the Perfektpartizip grew a ge-
where none belongs (`gezerstört`) or lost one it needs (`geherstellt`).

Four were a class nobody had named: **an `in` value carrying more than one prefix marker**.
`VerbParser` splits on the first separator and honours only `components[0]`, so
`vor+aus+setzen` parsed as prefix *vor* and produced `vorgeaussetzt`. The correct marking names
the whole prefix: `voraus+setzen`, `auseinander+setzen`, `voran+tr^ei^ben`. The parser now
rejects a second marker outright rather than silently truncating, which is the same crash-early
posture the rest of the XML validation takes.

Two were wrong about separability or family: `unterbringen` shipped as inseparable
(`unter*br^ing^en` → *unterbracht*) when it is separable (*untergebracht*), and `besitzen`
shipped as a weak verb, producing *besitzte* and *besitzt* for *besaß* and *besessen*. The
second is worth noting as a category: a strong verb mis-shipped as weak is invisible to every
check the project had before this pipeline, because nothing about it is malformed.

Where it stops. The 10 remaining failures are 5 verbs needing a separable prefix over an
already-prefixed base (*angehören*, *aufbewahren*, *vorbereiten*, *zubereiten*,
*weiterentwickeln*, plus *einbeziehen* whose ablaut region is also misplaced), 3 modal full
overrides the pipeline cannot derive (*sollen*, *bedürfen*, *vermögen*), and *nachvollziehen*,
a genuine double-prefix verb now marked `nachvoll*z^ieh^en`. That last one is a deliberate
trade rather than a fix: the marking gets all 25 compound-tense forms right and the 2 Imperativ
forms wrong, where the previous marking had it the other way around.

One verb was **misdiagnosed as a data slip and is not one**. `unterstellen` ships as
inseparable, which is correct for the *allege, subordinate* reading (*unterstellt*); Wiktionary's
table shows the separable *place underneath* reading (*untergestellt*). It is wrinkle 7, a
separable/inseparable homograph, and belongs with the dual-auxiliary work rather than here.

The 4 remaining group disagreements — *hängen*, *schaffen*, *schreien*, *vergleichen* — are
unrelated to sibilants or prefixes and unexamined.

## What "verified" does not mean

Three flags in the summary, each a real limit:

- **Verified is not idiomatic.** *sieden* verified as strong with a contrived group because
  Wiktionary's table happened to show its weak paradigm.
- **Verified is not complete.** 17 verbs verified into a family that contradicts Wiktionary's
  own strong/weak class tag — *melken*, *gären*, *bleichen*, *pflegen*, *triefen*, *spinnen*,
  *erwägen*. These are wrinkle 1's dual-paradigm verbs; this run saw whichever paradigm the
  table held and confirmed only that one.
- **Verified is not desirable.** 129 verified candidates are obsolete or Swiss spellings
  (*beyssen*, *abfliessen*, *laßen*). They conjugate fine and should not ship.

Also unresolved, and deliberately so: 249 verified incoming verbs are dual-auxiliary. The
interim policy in `prompts/dual_auxiliary.md` governs; the pipeline records `ay` from kaikki's
primary reading and sets a flag rather than deciding.

`fr` and `ic` are untouched. `fr` is blocked pending BBAW's reply about DWDS, and `ic` has no
external source at all — it is 40-odd SF Symbol suffixes chosen by taste, and it is
`#REQUIRED` in the DTD. Budget a decision per imported verb.
