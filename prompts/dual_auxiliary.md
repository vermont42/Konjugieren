# Handle haben/sein verbs in one enhancement pass

## Status

**Do this before importing verbs.** Reversed 2026-07-19, having previously been deferred.

The original reasoning was that this pass must not block the corpus expansion in
`docs/verb-sources.md`. That was right when the expansion was hypothetical. It is now
backwards: the classify-and-verify pipeline exists, 6,696 incoming verbs are classified and
externally verified, and **418 of them are dual-auxiliary**. Importing under the interim policy
would write a known-wrong auxiliary into 418 new verbs and then require a migration larger than
this feature. Land the model first and they arrive correct.

**Sequence: [`regional_variation.md`](regional_variation.md) first, then this.** That pass owns
variation by *standard variety* — the Swiss ß/ss orthography and the Austrian/Swiss auxiliary of
*stehen*, *sitzen*, and *liegen*. This pass owns variation by *meaning*. Running them in the
other order means two passes editing the same `ay` attribute with different models of what it
means.

The interim policy at the end still governs any verb added before this pass runs.

**The model is decided**: nested `<reading>` elements, locked in by Josh on 2026-07-19. See
"The model" below. Your job is to build it, not to choose it.

## Orientation for a fresh session

Read in this order. The first three are load-bearing; the rest are reference.

1. [`regional_variation.md`](regional_variation.md) — **runs before this pass** and must
   already be done. It ships the Region setting, Swiss ß/ss rendering, and the region-aware
   auxiliary that covers class 3 below.
2. `docs/verb-classification.md` — the pipeline, how to run it, and what it has already found
   and fixed. This is the tool you will use to verify every change you make here.
3. This file.
4. `docs/adding-verbs.md` — XML formats, the ablaut system, the `^` region convention, the ß/ss
   rule.
5. `docs/verb-sources.md` — where the incoming verbs come from; wrinkles 1, 4, and 7 all touch
   this pass.

**The regression oracle.** 985 of the shipping verbs have a Wiktionary conjugation table, and
the pipeline checks the app against it. As of 2026-07-19 the corpus stands at **14 verbs at odds
with Wiktionary, 99.0% verified** — down from 354 the same day. That number is your regression
test. Run the pipeline before you start, so you have a baseline, and after every substantive
change. It should never go up.

```bash
python3 verbdata/build_candidates.py --include-existing

TEST_RUNNER_KONJUGIEREN_CLASSIFY_IN="$PWD/verbdata/candidates.json" \
TEST_RUNNER_KONJUGIEREN_CLASSIFY_OUT="$PWD/verbdata/classification.json" \
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren \
  -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test \
  -only-testing:KonjugierenTests/VerbClassificationTests

python3 verbdata/summarize_classification.py
```

The 294 MB kaikki snapshot is gitignored; `verbdata/README.md` has the SHA-256 and the
re-download recipe if it is missing.

**A warning that has already earned its place.** When you change the model, shipped
`ConjugatorTests` expectations will go red. Some of them encode defects rather than German —
that has happened twice in this repo, most recently with 20 expectations documenting a ß/ss
bug. The reflex is to edit the expectation until it is green, which launders the bug into a
documented invariant, and the mixed-case convention makes it feel like a formatting tweak.
**When a shipped test and Wiktionary disagree, Wiktionary wins** unless you can say
specifically why it is wrong for that verb. Check each new value against
`verbdata/candidates.json` before you write it into a test file.

## The shortcoming

`Verbs.xml` gives each verb exactly one `ay` attribute, and `Verb` exactly one `auxiliary`.
German does not cooperate. Many verbs take **sein** in one reading and **haben** in another,
and the app forces a single choice, so one reading is silently wrong in Perfekt, Perfekt
Konjunktiv I, Plusquamperfekt, and Plusquamperfekt Konjunktiv II.

```
Das Eis ist geschmolzen.        (intransitive, change of state → sein)
Ich habe das Eis geschmolzen.   (transitive, caused change    → haben)
```

## The numbers, re-derived 2026-07-19

Two **separate** populations, which the earlier draft of this file conflated. Verify both
before you start rather than trusting these figures; the snapshot refreshes upstream.

**Dual-auxiliary lemmas** — kaikki tags the auxiliary form literally as `"haben or sein"` or
`"sein or haben"`:

| Population | Count |
|---|---|
| Dual-auxiliary single-word lemmas | 469 |
| **Already shipping, forced single-valued** | **51** |
| ...of which this pass handles | **48** |
| ...handled by `regional_variation.md` instead (class 3) | 3 |
| In the incoming pool | 418 |

**Homograph lemmas** — Wiktionary splits these across Etymology sections, so one lemma has more
than one record. This is class 5 and it is *not* a subset of the above:

| Population | Count |
|---|---|
| Lemmas with more than one Wiktionary record | 209 |
| **Already shipping** | **38** |

### The trap that will cost you an hour if you skip it

`verbdata/candidates.json` **keeps only the first record per lemma by default**, because Stage B
keys on the infinitive and cannot hold two readings of one verb. So the file silently hides
exactly the data this pass needs: *übersetzen*'s dual auxiliary lives in its **second** record,
along with its "to cross, to ferry" gloss. A scan over the default candidate file finds only 48
of the 51 shipping dual-auxiliary verbs, and the three it hides — *weichen*, *übersetzen*,
*überstehen* — are all class 5, the hardest to get right.

(Beware a coincidence: 48 is also the number this pass migrates, after class 3's three verbs go
to `regional_variation.md`. Different three verbs, same arithmetic.)

Use the flag added for this pass:

```bash
python3 verbdata/build_candidates.py --include-existing --all-records --out verbdata/readings.json
```

Records gain a `recordIndex` field. **Do not feed this file to Stage B unmodified** — the
classifier keys on `word` and will install one synthetic verb over another. Either extend Stage
B to key on `word + recordIndex`, or verify readings one at a time.

## It is not really an auxiliary problem

The auxiliary is the visible symptom, but a verb in this class differs across readings in up to
four ways at once. Any design that adds only a second `ay` will be back here shortly.

1. **Auxiliary.** sein versus haben.
2. **Gloss.** `tn` needs two values. "melt" is inadequate for *schmelzen*; the readings are
   closer to "melt (become liquid)" and "melt (make liquid)". Likewise *fahren*, "travel, go"
   against "drive (a vehicle)".
3. **Family and paradigm.** For some verbs the two readings inflect differently. *hängen* is
   intransitive strong (hing, gehangen) beside transitive weak (hängte, gehängt).
   *erschrecken* is the same shape. **Konjugieren ships hängen as `fa="w"` only,** so its
   strong intransitive paradigm is absent, not merely mis-auxiliaried.
4. **Prefix separability.** *übersetzen* is `über+setzen` "ferry across" (sein) beside
   `über*setzen` "translate" (haben). The readings differ in the `in` attribute itself.

So the unit that varies is a **reading**, bundling auxiliary, gloss, and sometimes family,
ablaut group, and prefix. Model the reading, not the auxiliary.

## The five classes, with the shipped verbs in each

All 51 are in the app today with a single `ay`; the current value is shown, an absent `ay`
meaning haben. Three of them — class 3 — belong to `regional_variation.md`, leaving 48 for this
pass. Sort verbs between classes as you go: the scan is lemma-level and cannot.

### 1. Transitivity alternation (causative pairs)

Intransitive takes sein, transitive haben. Largest and most regular class.

abbrechen (h), abziehen (h), anziehen (h), brechen (h), einziehen (h), fahren (h),
fliegen (s), heilen (h), reißen (h), rollen (h), rücken (h), schießen (h), stoßen (h),
treiben (h), trocknen (h), verbrennen (h), ziehen (h), zurückziehen (h)

Incoming: schmelzen, verderben, biegen, frieren, and others.

### 2. Motion: directional versus durative

sein when a destination is reached, haben when the activity itself is meant.
*Ich bin nach Hause geschwommen* against *Ich habe zwei Stunden geschwommen*.

fliehen (s), landen (s), reiten (h), rennen (s), schwimmen (s), starten (h), stürzen (s),
tanzen (h), tauchen (h), treten (h), wandern (s)

Incoming: rudern, joggen, segeln, klettern.

### 3. Regional variation — handled elsewhere, do not model it here

stehen, sitzen, liegen

These differ by **standard variety**, not argument structure: the German standard uses haben,
Austrian and Swiss usage takes sein. They are **out of scope for this pass** and are handled by
[`regional_variation.md`](regional_variation.md), which runs first and ships a Region setting, a
region-aware auxiliary on `Verb`, and a flag indicator in `VerbView`'s auxiliary pill.

If that pass has run, these verbs are already correct and you should leave them alone. If it has
not, **stop and do it first** — the two passes would otherwise fight over the same attribute.

The reason they are not readings: two readings differing only in an auxiliary badge would tell
every user that both forms are available to them personally, which is false for any single
speaker, and would read as a rendering bug rather than a fact about German. A reading is a
difference in *meaning*. This is a difference in *where the speaker lives*.

The scan cannot tell these apart from classes 1 and 2 — kaikki reports *stehen* as bare
`haben or sein`, exactly as it reports *schwimmen*. The separation is editorial, and
`regional_variation.md` carries the curated list.

### 4. Two readings needing two paradigms

hängen (h, shipped as weak only)

The intransitive strong paradigm is missing outright, so fixing the auxiliary alone still
leaves the verb wrong. *erschrecken* is the same shape and is not yet in the app; the pipeline
has already classified and verified it, so its paradigm is available.

Corroboration from the pipeline: *hängen* is one of four shipping verbs whose ablaut group the
classifier could only reproduce by proposing a different one (`A,bA,dA,pp`). The other three —
*schaffen*, *schreien*, *vergleichen* — are unexamined and unrelated, but *hängen*'s appearance
there is this class showing up in the data.

### 5. Separable/inseparable homographs

übersetzen (h), überstehen (h), unterliegen (h), belaufen (h), verlaufen (s), eingehen (h),
anfangen (h), antreten (s), auftauchen (s), bekommen (h), dringen (s), eintreten (s),
passieren (s), scheiden (s), weichen (s), anstreben (h), streben (h), vorliegen (h)

Several are dual-auxiliary for ordinary reasons and appear here only because the scan is
lemma-level; sort them into classes 1 and 2. The genuine homographs — *übersetzen*,
*durchbrechen*, *umfahren*, *unterstellen* — differ in the `in` attribute and overlap wrinkle 7
in `docs/verb-sources.md`.

**A confirmed instance found during the prefix pass:** *unterstellen* ships as `unter*stellen`,
correct for the "allege, subordinate" reading (*unterstellt*). Wiktionary's table shows the
separable "place underneath" reading (*untergestellt*), so it registers as a pipeline failure
that no marker change can fix. It is not a data slip. It is this class, and it is one of the 14
verbs currently at odds with Wiktionary — meaning **this pass should reduce that count, not
just hold it.**

## The model: nested reading elements

**Decided 2026-07-19 by Josh. This is settled — build it, do not re-litigate it.** The
alternatives are recorded at the end of this section so nobody reopens the question without new
information.

A `<verb>` carries one or more `<reading>` children. Shared, verb-level facts stay on `verb`;
anything that varies by reading moves to `reading`.

```xml
<!-- One reading: the shape 939 of the 990 verbs take. The wrapper is new; the
     attributes inside it are exactly what that verb already carries today. -->
<verb in="machen" fr="8" ic="...">
  <reading tn="make, do" fa="w" />
</verb>

<!-- Class 1: same paradigm, different auxiliary and gloss. -->
<verb in="schmelzen" fr="..." ic="...">
  <reading tn="melt, become liquid" fa="s" ag="..." ay="s" />
  <reading tn="melt, make liquid" fa="s" ag="..." />
</verb>

<!-- Class 4: the readings inflect differently. -->
<verb in="hängen" fr="..." ic="...">
  <reading tn="hang, be suspended" fa="s" ag="..." />
  <reading tn="hang, suspend something" fa="w" />
</verb>

<!-- Class 5: in varies per reading. -->
<verb in="übersetzen" fr="..." ic="...">
  <reading in="über*setzen" tn="translate" fa="w" />
  <reading in="über+setzen" tn="ferry across" fa="w" ay="s" />
</verb>
```

Rules that fall out of this:

- **The first reading is primary.** It drives the browse list, the quiz, widget snapshots, and
  anything else that needs one answer. `Verb.auxiliary`, `Verb.translation`, and `Verb.family`
  become computed properties returning the primary reading, so most call sites compile
  unchanged.
- **`in` on `verb` is unchanged from today** — it keeps its `+`, `*`, and `^` markers, so 939
  single-reading verbs need nothing but a `<reading>` wrapper around attributes they already
  have. `in` on `reading` is optional and overrides the verb's, which is what makes class 5
  expressible; only the handful of homographs need it.
- **The dictionary key is already marker-free.** `VerbParser` strips `[+*^]` from `in` before
  writing `verbs[currentVerb]`, so `Verb.verbs` and `Conjugator.conjugate(infinitiv:)` keep
  resolving on the plain infinitive with no change. A per-reading `in` must strip to the *same*
  key as its parent — `über*setzen` and `über+setzen` both strip to `übersetzen` — and
  `VerbParser` should reject a reading whose `in` strips to anything else, since that would
  silently create an unreachable verb.
- **`fr` and `ic` stay on `verb`.** Frequency is a property of the lemma, and the icon is one
  per verb by design.
- **DTD.** `<!ELEMENT verb EMPTY>` was tightened on 2026-07-19 precisely because nested verbs
  had never existed. This reverses that deliberately: `<!ELEMENT verb (reading+)>`. The
  **Validate Verbs.xml** build phase runs `xmllint --valid` ahead of compilation, so it will
  enforce the new shape from the first build — expect it to reject the whole file until the
  migration is complete, and migrate in one pass rather than incrementally.

### Why not the alternatives

Recorded so they stay closed.

**A. A second auxiliary attribute** (`ay2="h"` beside `ay="s"`). Smallest diff, and it solves
the symptom and nothing else: no second gloss, no way to express the family split in class 4 or
the prefix split in class 5, and no way for the UI to say which auxiliary belongs to which
meaning.

**C. Two `<verb>` entries with a disambiguator**, as Wiktionary does with Etymology 1 and
Etymology 2. More faithful to class 5, where the readings really are different verbs. Rejected
on blast radius: `Verb.verbs` is `[String: Verb]` keyed by infinitive, and
`Conjugator.conjugate(infinitiv:)`, deeplinks, widget snapshots, and `VerbEntity` all resolve by
that key. Two entries per infinitive means a compound key and every one of those call sites.

**The one trigger that would reopen C:** a reading needing to differ in something that lives on
`verb` — `fr` or `ic` — or a verb whose readings need genuinely separate Info or example-sentence
entries keyed independently. Nothing in the 48 shipping verbs or the 418 incoming ones is known
to need that. If you find one, note it rather than redesigning around a single verb.

## Work plan

1. **Baseline.** Run the pipeline. Record the "verbs at odds with Wiktionary" figure before you
   touch anything.
2. **Confirm `regional_variation.md` has run.** It owns class 3 and the Swiss ß/ss orthography,
   and it must precede this pass. Check that `Region` exists in `Settings` and that *stehen*,
   *sitzen*, and *liegen* carry a region-aware auxiliary. If not, do that pass first.
3. **Extend the DTD and `VerbParser`** for readings. All 990 verbs gain a `<reading>` wrapper —
   that part is mechanical and scriptable — but only the 48 gain a second reading, and no
   single-reading verb's attributes change. Define `reading`'s `in` grammar at the same time,
   including multiple prefix markers; see "Do the double-prefix grammar in the same migration"
   below before writing the parser, because `VerbParser` currently *rejects* a second marker and
   that guard is what needs widening.
4. **Extend `Verb`** with an ordered `readings` array. Keep `auxiliary`, `translation`, and
   `family` as computed properties returning the primary reading, so most call sites compile
   unchanged.
5. **Teach `Conjugator`** to conjugate a specified reading, defaulting to primary. The auxiliary
   is read in exactly one place: the `conjugateCompoundTense` calls for `perfektIndikativ`,
   `perfektKonjunktivI`, `plusquamperfektIndikativ`, and `plusquamperfektKonjunktivII`, which
   pass `verb.auxiliary.verb`. (Line numbers deliberately omitted — `Conjugator` was
   substantially rewritten on 2026-07-19.)
6. **UI.** `VerbView` shows one auxiliary badge and one translation. Decide how a two-reading
   verb presents: segmented control, stacked sections, or a secondary line. The quiz must pick
   one reading per question and say which. Check `docs/voiceover.md` before adding a control
   inside a row — per-child `.environment(\.locale)` does not work inside `NavigationLink` or
   `Button`, which has already forced programmatic navigation elsewhere.
7. **Migrate the 48**, class by class, sourcing the second gloss and auxiliary from
   `verbdata/readings.json`.
8. **Tests.** Add `ConjugatorTests` cases asserting both readings for a representative of each
   class: *schmelzen* or *brechen* for 1, *schwimmen* for 2, *hängen* for 4, *übersetzen* for 5.
   Take every expectation from Wiktionary, not from the engine's output. The mixed-case
   convention applies as usual.
9. **Re-run the pipeline.** The at-odds count should fall, since *unterstellen* at minimum is in
   it. If it rises, something regressed.
10. **Then the 418** incoming dual-auxiliary verbs arrive correctly modeled from the start.

## Do the double-prefix grammar in the same migration

The largest remaining gap in the corpus is unrelated to auxiliaries but touches the same code:
**a separable prefix over an already-prefixed base** cannot be expressed, because `Prefix` holds
one prefix. *angehören* (an + ge\*hören) conjugates to *angegehört*. This affects 5 shipping
verbs and **1,186 incoming** ones — by far the biggest single blocker to the import.

These are separate problems that meet in one attribute. Locking the reading model means
`reading` gains its own `in`, and that is **new parsing code whose grammar you get to define
once**. The double-prefix fix is a change to that same grammar: today `in` admits at most one
`+` or `*` marker, and *angehören* needs two (`an+ge*hören`).

So define the grammar for both at the same time, even if you land the double-prefix data
migration separately. Concretely: let `reading`'s `in` accept an ordered sequence of prefix
markers, have `VerbParser` build a `[Prefix]` rather than a single `Prefix`, and teach
`perfektpartizipWithGeAndPrefix` to insert the *ge* after the last separable prefix. That one
decision unblocks 1,186 incoming verbs and costs almost nothing on top of work you are already
doing.

The alternative — shipping a single-marker `reading.in` now and widening it later — means
parsing `in` twice, migrating `Verbs.xml` twice, and rewriting the `Prefix` call sites twice.
Do not do that.

## Building the worklist

Authoritative scan, straight from the snapshot — it does not inherit the candidate file's
first-record-only filter:

```bash
python3 - <<'PY'
import json, re
xml = open('Konjugieren/Models/Verbs.xml').read()
current = {re.sub(r'[+*^]', '', re.search(r'in="([^"]+)"', v).group(1))
           for v in re.findall(r'<verb [^/]*/>', xml)}
dual, records = set(), {}
with open('verbdata/kaikki.org-dictionary-German-by-pos-verb.jsonl') as f:
    for line in f:
        d = json.loads(line)
        w = d.get('word', '')
        if ' ' in w or any(s.get('form_of') for s in d.get('senses', [])):
            continue
        records[w] = records.get(w, 0) + 1
        aux = {fm.get('form') for fm in d.get('forms', []) if 'auxiliary' in fm.get('tags', [])}
        if any(a and ' or ' in a for a in aux):
            dual.add(w)
homographs = {w for w, n in records.items() if n > 1}
print('dual-auxiliary   shipping:', len(dual & current), ' incoming:', len(dual - current))
print('homograph        shipping:', len(homographs & current), ' total:', len(homographs))
print('shipping dual:', sorted(dual & current))
print('shipping homographs:', sorted(homographs & current))
PY
```

kaikki supplies the per-sense glosses needed for `tn`, so the second gloss needs no other
source.

## Interim policy, until this pass runs

Applies to any verb added before the model lands.

- Keep `ay` single-valued. For a new dual-auxiliary verb pick the **more common reading**,
  which for classes 1 and 2 is almost always the intransitive sein reading for motion verbs and
  the transitive haben reading for causatives.
- Record every verb so deferred, so this pass inherits a worklist rather than rediscovering one.
  The scan above regenerates it at any time.
- Do **not** widen the DTD's `ay (h|s)` enumeration to admit a combined value such as `"hs"`.
  That is option A with extra steps, and the build phase refusing it is intended behavior.
