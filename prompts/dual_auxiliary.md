# Handle haben/sein verbs in one enhancement pass

## Status

**Deferred by design.** This is a real shortcoming in the app, acknowledged 2026-07-19, but
it must not block the verb-corpus expansion described in `docs/verb-sources.md`. See "Interim
policy" at the end for what to do until this pass runs.

## The shortcoming

`Verbs.xml` gives each verb exactly one `ay` attribute, and `Verb` exactly one `auxiliary`.
German does not cooperate. Many verbs take **sein** in one reading and **haben** in another,
and the app currently forces a single choice, so one of the two readings is silently wrong in
Perfekt, Perfekt Konjunktiv I, Plusquamperfekt, and Plusquamperfekt Konjunktiv II.

```
Das Eis ist geschmolzen.        (intransitive, change of state → sein)
Ich habe das Eis geschmolzen.   (transitive, caused change    → haben)
```

Measured against the kaikki snapshot, which tags such verbs with the literal auxiliary form
`"haben or sein"`:

| Population | Count |
|---|---|
| Dual-auxiliary lemmas in kaikki (single-word) | 469 |
| **Already shipping in Konjugieren, forced single-valued** | **51** |
| In the incoming expansion pool, not yet added | 418 |

Reproduce with the scan in "Building the worklist" below.

## It is not really an auxiliary problem

The auxiliary is the most visible symptom, but a verb in this class differs across readings in
up to four ways at once. Any design that adds only a second `ay` will be back here shortly.

1. **Auxiliary.** sein versus haben.
2. **Gloss.** `tn` needs two values. "melt" is inadequate for schmelzen; the readings are
   closer to "melt (become liquid)" and "melt (make liquid)". Likewise fahren, "travel, go"
   against "drive (a vehicle)".
3. **Family and paradigm.** For some verbs the two readings inflect differently.
   hängen is intransitive strong (hing, gehangen) beside transitive weak (hängte, gehängt).
   erschrecken is intransitive strong (erschrak, erschrocken) beside transitive weak
   (erschreckte, erschreckt). **Konjugieren currently ships hängen as `fa="w"` only,** so its
   strong intransitive paradigm is entirely absent, not merely mis-auxiliaried.
4. **Prefix separability.** übersetzen is `über+setzen` "ferry across" (sein) beside
   `über*setzen` "translate" (haben). The two readings differ in the `in` attribute itself.

So the unit that varies is a **reading**, and a reading bundles auxiliary, gloss, and
sometimes family, ablaut group, and prefix. Model the reading, not the auxiliary.

## The five classes, with the shipped verbs in each

All 51 below are in the app today with a single `ay`. The current value is shown so the pass
can see which reading was privileged.

### 1. Transitivity alternation (causative pairs)

The intransitive takes sein, the transitive haben. The largest and most regular class.

abbrechen (h), abziehen (h), anziehen (h), brechen (h), einziehen (h), fahren (h),
fliegen (s), heilen (h), reißen (h), rollen (h), rücken (h), schießen (h), stoßen (h),
treiben (h), trocknen (h), verbrennen (h), ziehen (h), zurückziehen (h)

Incoming, not yet added: schmelzen, verderben, biegen, frieren, and others.

### 2. Motion: directional versus durative

sein when a destination is reached, haben when the activity itself is meant.
*Ich bin nach Hause geschwommen* against *Ich habe zwei Stunden geschwommen*.

fliehen (s), landen (s), reiten (h), rennen (s), schwimmen (s), starten (h), stürzen (s),
tanzen (h), tauchen (h), treten (h), wandern (s)

Incoming: rudern, joggen, segeln, klettern.

### 3. Regional variation, not transitivity

stehen (h), sitzen (h), liegen (h)

These differ by **dialect region**, not by argument structure: northern German uses haben,
southern German, Austrian, and Swiss usage takes sein. The app already privileges the
northern form. This class probably wants a different treatment from classes 1 and 2, since
presenting both as equally available would misdescribe the situation for any single speaker.
Consider documenting the regional split in the verb's Info text rather than modeling it as
two readings. **Decide this explicitly; do not let it default.**

### 4. Two readings needing two paradigms

hängen (h, and shipped as weak only)

The intransitive strong paradigm is missing outright. Fixing the auxiliary without adding the
paradigm would still leave the verb wrong. erschrecken is the same shape and is not yet in
the app.

### 5. Separable/inseparable homographs

übersetzen (h), überstehen (h), unterliegen (h), belaufen (h), verlaufen (s), eingehen (h),
anfangen (h), antreten (s), auftauchen (s), bekommen (h), dringen (s), eintreten (s),
passieren (s), scheiden (s), weichen (s), anstreben (h), streben (h), vorliegen (h)

Several of these are dual-auxiliary for ordinary reasons and appear here only because the
scan is lemma-level; sort them into classes 1 and 2 during the pass. The genuine
separable/inseparable homographs, übersetzen above all, differ in the `in` attribute and
overlap with wrinkle 7 in `docs/verb-sources.md`.

## Design options

### A. Add a second auxiliary attribute

`ay2="h"` beside `ay="s"`. Smallest diff. Rejected: carries no gloss, cannot express the
family split in class 4, cannot express the prefix split in class 5, and gives the UI no way
to say which auxiliary belongs to which meaning. It solves the symptom and nothing else.

### B. Nested reading elements

```xml
<verb in="schmelzen" fr="..." ic="...">
  <reading tn="melt, become liquid" fa="s" ag="..." ay="s" />
  <reading tn="melt, make liquid" fa="s" ag="..." />
</verb>
```

One `Verb` per infinitive, carrying an ordered array of readings; the first is primary and
drives the browse list and the quiz. Handles classes 1, 2, and 4. Handles class 5 only if
`in` is allowed to vary per reading.

Note the DTD consequence: `<!ELEMENT verb EMPTY>` was tightened on 2026-07-19 precisely
because nested verbs had never existed. This option deliberately reintroduces child elements,
so the declaration becomes `<!ELEMENT verb (reading+)>` with the shared attributes staying on
`verb`. That is a considered reversal, not an accident, and the build-phase validation will
enforce whichever shape is chosen.

### C. Two verb entries with a disambiguator

Model each reading as its own `<verb>`, as Wiktionary does with Etymology 1 and Etymology 2.
Most faithful, especially for class 5, where the two readings really are different verbs.

The obstacle is that `Verb.verbs` is `[String: Verb]` keyed by infinitive, and
`Conjugator.conjugate(infinitiv:)` resolves by that key, as do deeplinks, widget snapshots,
and `VerbEntity`. Two entries per infinitive requires a compound key and touches every one of
those call sites.

### Recommendation

**Option B**, with `in` permitted on `reading` so class 5 is covered. It keeps the primary
key intact, which is what makes the change tractable, while modeling the reading as the unit
that actually varies. Revisit option C only if the separable/inseparable homographs prove
unworkable under B.

## Work plan

1. **Decide the model.** B unless a better argument appears. Settle class 3 separately.
2. **Extend the DTD and `VerbParser`** for readings, keeping single-reading verbs expressible
   without ceremony so 939 of the 990 are untouched. The `Validate Verbs.xml` build phase
   will enforce the new shape immediately.
3. **Extend `Verb`** with an ordered `readings` array. Keep `auxiliary`, `translation`, and
   `family` as computed properties returning the primary reading, so most call sites compile
   unchanged.
4. **Teach `Conjugator`** to conjugate a specified reading, defaulting to primary. The
   compound-tense path at `Conjugator.swift:53-62` is the only place the auxiliary is read.
5. **UI.** `VerbView` currently shows one auxiliary badge and one translation. Decide how a
   two-reading verb presents: segmented control, stacked sections, or a secondary line. The
   quiz must pick one reading per question and say which.
6. **Migrate the 51**, class by class, sourcing the second gloss and auxiliary from kaikki.
7. **Tests.** Add `ConjugatorTests` cases asserting both readings for a representative of each
   class: schmelzen or brechen for 1, schwimmen for 2, hängen for 4, übersetzen for 5. The
   mixed-case convention applies as usual.
8. **Then the 418** incoming dual-auxiliary verbs arrive correctly modeled from the start,
   rather than needing a second migration.

## Building the worklist

```bash
python3 - <<'PY'
import json, re
xml = open('Konjugieren/Models/Verbs.xml').read()
current = {re.sub(r'[+*^]','',re.search(r'in="([^"]+)"', v).group(1)):
           ('s' if ' ay=' in v else 'h')
           for v in re.findall(r'<verb [^/]*/>', xml)}
dual = set()
with open('verbdata/kaikki.org-dictionary-German-by-pos-verb.jsonl') as f:
    for line in f:
        if '"auxiliary"' not in line:
            continue
        d = json.loads(line)
        w = d.get('word', '')
        if ' ' in w or any(s.get('form_of') for s in d.get('senses', [])):
            continue
        if any(a and 'or' in a for a in
               {fm.get('form') for fm in d.get('forms', []) if 'auxiliary' in fm.get('tags', [])}):
            dual.add(w)
print('in app:', sorted(dual & current.keys()))
print('incoming:', len(dual - current.keys()))
PY
```

kaikki also supplies the per-sense glosses needed for `tn`, so the second gloss does not
require a separate source.

## Interim policy, until this pass runs

Do not block on any of the above.

- Keep `ay` single-valued. For a new dual-auxiliary verb, pick the **more common reading**,
  which for classes 1 and 2 is almost always the intransitive sein reading for motion verbs
  and the transitive haben reading for causatives.
- Record every verb so deferred, so this pass inherits a worklist rather than rediscovering
  one. The scan above regenerates it from kaikki at any time.
- Do **not** widen the DTD's `ay (h|s)` enumeration to admit a combined value such as `"hs"`.
  Encoding two auxiliaries in one attribute is option A with extra steps, and the build phase
  refusing it is the intended behavior.
