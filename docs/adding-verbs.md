# Adding Verbs

This guide covers the complete workflow for adding verbs to Konjugieren, including XML file formats, the ablaut system, verb families, and lessons learned from adding the first 400 verbs.

## XML File Formats

### Verbs.xml

Defines verbs with their properties. Each `<verb>` holds one or more `<reading>` children:

```xml
<verb in="an+k^om^men" hi="2941218" ic="walk.arrival">
  <reading tn="arrive" fa="s" ag="kommen" ay="s" />
</verb>
```

Attributes on `verb` describe the lemma. Attributes on `reading` describe one sense, and are
the ones that can vary between senses of the same verb.

| Element | Attribute | Meaning | Required |
|---|---|---|---|
| `verb` | `in` | Infinitive with markers (see below) | Yes |
| `verb` | `hi` | Raw DWDS corpus hit count (higher = more common) | Yes |
| `verb` | `ic` | Frequency-icon suffix | Yes |
| `reading` | `tn` | Translation | Yes |
| `reading` | `fa` | Family: `s`=strong, `m`=mixed, `w`=weak, `i`=ieren | Yes |
| `reading` | `ag` | Ablaut group name (required for strong/mixed) | Conditional |
| `reading` | `ay` | Auxiliary: `s`=sein, `h`=haben (default), `r`=regionally conditioned | No |
| `reading` | `in` | Overrides the verb's `in` for this sense only | No |

**`hi` holds a hit count, not a rank.** The `#255` a verb screen displays is a dense rank over
the whole corpus, but it is *derived* — `VerbParser.ranked` sorts every verb by `hi` descending
after parsing and assigns 1..n. Storing the rank instead, which is what the retired `fr`
attribute did, made the rank a property of the file rather than of the corpus: inserting one
verb renumbered every verb below it, so a one-verb change arrived as a 990-line diff. Get the
count from `verbdata/dwds-frequencies.json`, and if the verb is not in there, read the header of
`verbdata/fetch_dwds_frequencies.py` before querying DWDS — a bare infinitive that is also an
adjective or noun silently returns the *other* word's count, and nothing in the response says so.

`Verb` exposes both: `hits` is the raw count, `frequency` the derived rank. Sort and display on
`frequency`. Ordering by `hits` ascending is least-common-first, the reverse of what every call
site means.

**Infinitive markers:**
- `+` separates a separable prefix (e.g., `an+kommen` → ankommen)
- `*` separates an inseparable prefix (e.g., `ver*stehen` → verstehen)
- `^` marks ablaut region boundaries (e.g., `k^om^men` → ablaut region is "om")

Markers may repeat, so a separable prefix can sit on an already-prefixed base:
`an+ge*hören`, `nach+voll*ziehen`, `auf+be*wahren`. This matters because the *ge-* of the
Perfektpartizip goes immediately before the base stem and only when the prefix touching that
stem is separable or absent — so `ab+bauen` gives *abgebaut* but `an+ge*hören` gives
*angehört*, not *angegehört*. Writing such a verb with a single marker is the defect that
made seven shipping verbs disagree with Wiktionary until 2026-07-19.

### Readings: when a verb needs more than one

A German verb often differs across senses in more than the auxiliary, so the unit that varies
is the reading. Add a second `<reading>` when a verb splits in any of these ways:

| What differs | Example | How |
|---|---|---|
| Auxiliary and gloss only | *brechen*: break something (haben) / break apart (sein) | second `reading` with `ay="s"` |
| The whole paradigm | *hängen*: strong *hing/gehangen* / weak *hängte/gehängt* | second `reading` with its own `fa`, `ag`, and `in` for the carets |
| Prefix separability | *übersetzen*: `über*setzen` translate / `über+setzen` ferry across | second `reading` with its own `in` |

Two rules govern reading-level `in`:

- **It must strip to the same key as its parent.** `über*setzen` and `über+setzen` both strip
  to `übersetzen`, which is what `Verb.verbs` and `Conjugator` resolve on. `VerbParser` calls
  `fatalError` on a reading that strips to anything else, because that would create a verb
  nothing could reach.
- **The first reading is primary.** It drives the browse list, the widget, deeplinks, and
  anything else with room for one answer, and `Verb.translation`, `.family`, `.auxiliary`, and
  `.prefix` all return it.

**Do not use a second reading for regional variation.** *stehen*, *sitzen*, and *liegen* take
haben in the northern standard and sein in Austria and Switzerland, which is a difference in
where the speaker lives, not in what the verb means. Two readings would tell every user both
forms are available to them personally. Those verbs use `ay="r"`; see `prompts/regional_variation.md`.

**The pipeline cannot check the auxiliary.** `VerbClassificationTests` compares only the
simple tenses, the two participles, and the Imperativ against Wiktionary — never a compound
tense — so `ay` is invisible to it. A wrong auxiliary will not move the at-odds count. Guard
new auxiliaries with `ConjugatorTests` cases on `perfektIndikativ`.

### AblautGroups.xml

Defines vowel/consonant changes for strong and mixed verbs:

```xml
<ag e="sehen" a="ie,a2s,a3s|a,bA|ä,dA" />
```

| Attribute | Meaning |
|-----------|---------|
| `e` | Exemplar (name of the ablaut group) |
| `a` | Ablaut patterns separated by `\|` |

**Ablaut pattern format:** `replacement,group1,group2,...`

**Conjugation group codes:**
- `a` = Präsens Indikativ (a1s, a2s, a3s, a1p, a2p, a3p, aA=all)
- `b` = Präteritum Indikativ (b1s, b2s, b3s, b1p, b2p, b3p, bA=all)
- `c` = Präsens Konjunktiv I (c1s, c2s, c3s, c1p, c2p, c3p, cA=all)
- `d` = Präteritum Konjunktiv II (d1s, d2s, d3s, d1p, d2p, d3p, dA=all)
- `pp` = Perfektpartizip
- `i` = Imperativ (i2s, i1p, i2p, i3p, iA=all)

**Full override:** Append `*` to replacement to use it as the complete conjugated form, not adding the usual ending. This is used for highly irregular verbs like sein:

```xml
<ag e="sein" a="bin*,a1s|bist*,a2s|ist*,a3s|..." />
```

### XML Validation with FatalError Protocol

The XML parsers (`VerbParser.swift` and `AblautGroupParser.swift`) use an injectable `FatalError` protocol for validation failures. This enables testing while maintaining crash-early behavior in production.

**The Pattern:**
```swift
protocol FatalError {
  func fatalError(_ message: String)
}

struct FatalErrorReal: FatalError {
  func fatalError(_ message: String) {
    Swift.fatalError(message)  // Crashes in production
  }
}

class FatalErrorSpy: FatalError {
  private(set) var messages: [String] = []

  func fatalError(_ message: String) {
    messages.append(message)  // Captures for testing
  }
}
```

**Usage in Parsers:**
- Injected via `World.fatalError` dependency
- Production uses `FatalErrorReal` (crashes on invalid XML)
- Tests use `FatalErrorSpy` (captures error messages for verification)

**Rationale:**
- XML files are **developer-controlled data**, not user input
- Validation errors indicate bugs that must be fixed before shipping
- Crash-early behavior prevents silent data corruption
- Protocol injection enables comprehensive unit testing of error conditions

**Common Validation Checks:**
- Required attributes (infinitiv, translation, family, hit count, exemplar)
- Valid enum codes (family: s/m/w/i, auxiliary: s/h)
- Ablaut marker rules (^^ count, placement, and consistency with family)
- Pattern format correctness in AblautGroups.xml

**Important:** Do not change the production implementation to use throwing errors or optional returns. The crash-early behavior is intentional and ensures data integrity.

## The Ablaut System

German strong and mixed verbs undergo vowel and other changes (ablaut) in different conjugation groups. The system works as follows:

1. **Verb definition** marks the ablaut region with `^` characters
2. **Ablaut group** defines what replacements occur for each conjugation group
3. **Conjugator** applies the replacement at runtime

**Example: sehen (to see)**
- Infinitive: `s^e^hen` (ablaut region is "e" at indices 1..<2)
- Stamm: "seh"
- Ablaut group: `IE,a2s,a3s|A,bA|Ä,dA`
- Results:
  - Präsens 2s: replace "e" with "ie" → "sieh" + "st" = "siehst"
  - Präteritum: replace "e" with "a" → "sah" + endings
  - Konjunktiv II: replace "e" with "ä" → "säh" + endings

### The ß/ss Alternation Belongs Inside the Ablaut Region

German writes **ß after a long vowel or diphthong** and **ss after a short one**. Ablaut changes
vowel length, so the sibilant changes with it:

| Verb | Präsens | Präteritum | Perfektpartizip |
|------|---------|-----------|-----------------|
| essen | i**ss**t (short) | a**ß** (long) | gege**ss**en |
| schließen | schlie**ß**t (long) | schlo**ss** (short) | geschlo**ss**en |

The sibilant must therefore sit **inside** the ablaut region so each replacement can spell it.
Mark `^ess^en`, not `^e^ssen`; `schl^ieß^en`, not `schl^ie^ßen`. A region that stops at the
vowel cannot express the alternation, and the result is a plausible-looking wrong spelling —
`schloß` or `ass` — that no test will catch unless someone checks it against a dictionary.

Write a replacement's ß as the **capital sharp s, `ẞ` (U+1E9E)**, not `ß`:

```xml
<ag e="messen" a="ISS,a2s,a3s|Aẞ,bA|Äẞ,dA" />
```

`RichTextView` lowercases every character for display and uses uppercase only to select the
ablaut highlight, so `Aẞ` renders as "aß" with both letters marked as changed. A lowercase `ß`
would render identically but leave the sibilant unhighlighted, splitting one ablaut into two
visual runs.

**Swiss spelling is a display concern, not a data one.** Swiss Standard German abolished ß in
the 1970s and writes ss everywhere, without exception. Do **not** store a second Swiss spelling
of a verb, and do not import one: `abfliessen` and `abfließen` are the same verb, and
`verbdata/classification-summary.md` flags roughly 98 such incoming duplicates. `Verbs.xml`
always holds the ß spelling; `String.inRegion(_:)` in `Konjugieren/Utils/RegionalRendering.swift`
rewrites ß→ss and ẞ→SS at render time when the region setting is `.switzerland`. Mapping the
capital sharp s to `SS` rather than `ss` is what keeps the ablaut highlight a single run, which
is the same reason the replacement spells it `ẞ` in the first place.

For the same reason, `Conjugator` takes no region and must stay that way: it is the oracle the
classify-and-verify pipeline compares against Wiktionary. Where a regional reading is wanted,
call `RegionalConjugator` instead, which passes an explicit auxiliary down and applies the
orthography transform on the way out. See `prompts/regional_variation.md`.

This was wrong across 20 verbs until 2026-07-19, in both directions at once. Pre-1996
orthography used ß at the end of any syllable regardless of vowel length, so `schloß` and `daß`
were correct when much of this app's reference material was written; the 1996 reform tied ß to
vowel length. If a verb's spelling looks odd, check which side of the reform it comes from.

## Adding a New Verb

### Weak or -ieren Verb (Regular)

Simply add to Verbs.xml without ablaut markers:

```xml
<verb in="machen" hi="67161366" ic="strengthtraining.traditional">
  <reading tn="make, do" fa="w" />
</verb>
<verb in="studieren" hi="2173332" ic="flexibility">
  <reading tn="study" fa="i" />
</verb>
```

### Strong or Mixed Verb

1. **Add to Verbs.xml** with ablaut markers and group reference:
   ```xml
   <verb in="s^i^ngen" hi="2904260" ic="wave">
     <reading tn="sing" fa="s" ag="singen" />
   </verb>
   ```

2. **Add ablaut group to AblautGroups.xml** (if new pattern):
   ```xml
   <ag e="singen" a="A,bA|Ä,dA|U,pp" />
   ```

3. **Look up conjugation** on German Wiktionary: `https://de.wiktionary.org/wiki/Flexion:VERB`

### Verb with Prefix

- Separable prefix: use `+` (e.g., `an+kommen`)
- Inseparable prefix: use `*` (e.g., `ver*stehen`)

Prefixed verbs can share an ablaut group with their base verb.

### Alphabetical Ordering

Both XML files must maintain alphabetical order:

- **Verbs.xml**: Sort by the German verb name, ignoring prefix markers (`+`, `*`) and ablaut markers (`^`). For example, `an+k^om^men` sorts as "ankommen" and `g^e^lten` sorts as "gelten". Umlauts sort as their base vowels (ä≈a, ö≈o, ü≈u).

  **ß is not folded to ss.** It sorts where its code point puts it, after every ASCII letter, which is why the file reads *reiten* then *reißen* and *weiterlesen* then *weißen*. Measured against the shipping file on 2026-07-19, folding ß to ss produces three order violations and leaving it alone produces none. Folding umlauts does create ties — *drücken* and *drucken*, *zählen* and *zahlen* — and the file breaks them the opposite way from a naive sort, so the invariant to check is that the folded keys are *non-decreasing*, not that the file equals its own sort.

- **AblautGroups.xml**: Sort by the exemplar verb name (`e` attribute).

## Verb Families

| Family | Description | Präteritum Endings | Perfektpartizip |
|--------|-------------|-------------------|-----------------|
| Strong | Vowel change (ablaut) | No -te suffix | ge- + stamm + -en |
| Mixed | Vowel change + weak endings | -te suffix | ge- + stamm + -t |
| Weak | Regular, no vowel change | -te suffix | ge- + stamm + -t |
| -ieren | Verbs ending in -ieren | -te suffix | stamm + -t (no ge-) |

## Common Wiktionary Reference

For verb conjugations: `https://de.wiktionary.org/wiki/Flexion:VERBNAME`

## Lessons Learned from Adding Verbs

These patterns emerged while adding verbs 51-400 and will help with the remaining 600 verbs.

### Ablaut Region Must Include Consonant Changes

When a verb's consonants change between tenses (not just vowels), the ablaut region must include those consonants:

| Verb | Wrong | Correct | Reason |
|------|-------|---------|--------|
| schneiden | `schn^ei^den` | `schn^eid^en` | Präteritum is "schnitt" (d→tt) |
| leiden | `l^ei^den` | `l^eid^en` | Präteritum is "litt" (d→tt) |
| greifen | `gr^ei^fen` | `gr^eif^en` | Präteritum is "griff" (f→ff) |
| treffen | `tr^e^ffen` | `tr^eff^en` | All forms change ff→different consonants |
| ziehen | `z^ie^hen` | `z^ieh^en` | Präteritum is "zog" (h→g) |

### Verbs Starting with "ge-" Need Inseparable Prefix Marker

Verbs that naturally begin with "ge-" must use the inseparable prefix marker (`ge*`) to prevent double "ge-" in the Perfektpartizip:

```xml
<!-- Wrong: produces "gegewonnen" -->
<verb in="gew^i^nnen" ... />

<!-- Correct: produces "gewonnen" -->
<verb in="ge*w^i^nnen" ... />
```

Affected verbs include: gewinnen, gelingen, genießen, gebären, geschehen, gefallen, gelangen, geraten.

The same reasoning extends one level out. When a separable prefix sits on top of such a verb,
both markers are needed, because the inseparable one is what suppresses the *ge-*:

```xml
<!-- Wrong: produces "angegehört" -->
<verb in="an+gehören" ...>

<!-- Correct: produces "angehört" -->
<verb in="an+ge*hören" ...>
```

This is not special to a `ge-` base — any inseparable prefix behaves the same way, which is
why `auf+be*wahren` gives *aufbewahrt* and `weiter+ent*wickeln` gives *weiterentwickelt*.

### Common Ablaut Patterns for Reuse

Many verbs share ablaut patterns. When adding a new strong verb, first check if an existing pattern applies:

| Pattern | Verbs Using It | Changes |
|---------|---------------|---------|
| singen | klingen, trinken, singen, beginnen, gewinnen, gelingen | i→a (Prät), i→ä (Konj II), i→u (PP) |
| finden | binden, verschwinden, verbinden, empfinden | i→a (Prät), i→ä (Konj II), i→u (PP) |
| bleiben | schreiben, treiben, entscheiden, vermeiden, verleihen | ei→ie (Prät, Konj II, PP) |
| sprechen | brechen, helfen, sterben, treffen, werfen | e→i (Präs 2s/3s), e→a (Prät), e→o (PP) |
| geben | lesen, sehen, vergessen, messen, essen | e→i/ie (Präs 2s/3s), e→a (Prät), e→ä (Konj II) |
| fahren | tragen, schlagen, laden, wachsen | a→ä (Präs 2s/3s), a→u (Prät), a→ü (Konj II) |
| schließen | fliegen, bieten, verlieren, heben, genießen | ie/e→o (Prät, PP), ie/e→ö (Konj II) |
| halten | lassen, fallen, schlafen, laufen, rufen, heißen | Various, often a→ä (Präs) + ie (Prät) |
| schneiden | leiden, reiten, streiten, gleiten, schreiten | eid/eit→itt (all past forms) |
| greifen | kneifen, pfeifen, schleifen | eif→iff (all past forms) |
| streichen | weichen, gleichen, schleichen | eich→ich (all past forms) |
| heben | verlieren, schwören, weben, gären, glimmen, klimmen, scheren, wägen, saugen, lügen, trügen | vowel→o (Prät, PP), →ö (Konj II) |
| schmelzen | dreschen, fechten, flechten, melken, schwellen | e→i (Präs 2s/3s), e→o (Prät, PP), e→ö (Konj II) |

**Widen the region before you propose a new group.** A pattern that looks new is often a shipping pattern seen through too narrow an ablaut region. *kneifen* can be written `kn^ei^fen` with the replacement `IF`, splitting the doubled f across the region boundary — that conjugates correctly, but it needs a group of its own. Written the way this corpus writes *greifen*, `kn^eif^en` with `IFF`, it reuses `greifen` and adds nothing. The rule is the same one the ß/ss section states: the region has to be wide enough to spell every consonant that changes with the vowel. Applying it to the step-7 tranche turned thirteen proposed groups into five.

### Verbs That Use "sein" as Auxiliary

Verbs of motion or change of state use `ay="s"`:
- **Motion verbs**: fahren, fliegen, gehen, kommen, laufen, reisen, steigen, fallen
- **Change of state**: sterben, wachsen, werden, entstehen, verschwinden, geschehen
- **Location-related intransitives**: bleiben, sein, ankommen, auftreten, landen

### Compound Verb Prefix Patterns

| Prefix Type | Marker | Examples | Perfektpartizip |
|-------------|--------|----------|-----------------|
| Separable | `+` | an+kommen, auf+treten, ein+laden | Prefix + ge + stamm + en (angekommen) |
| Inseparable | `*` | ver*stehen, be*kommen, er*fahren | No ge- (verstanden) |
| Naturally ge- | `ge*` | ge*winnen, ge*schehen | No double ge- (gewonnen) |

### Quick Verb Classification Checklist

When adding a new verb:

1. **Is it an -ieren verb?** → `fa="i"`, no ablaut markers needed
2. **Is it a regular weak verb?** → `fa="w"`, no ablaut markers needed
3. **Does it have a prefix?** → Use `+` (separable) or `*` (inseparable)
4. **Does it start with ge-?** → Use `ge*` prefix marker
5. **Is it strong/mixed?** → Find matching ablaut pattern, mark region with `^`
6. **Does it use sein?** → Add `ay="s"`
7. **Verify on Wiktionary** → Check 2s/3s Präsens, Präteritum, Perfektpartizip
