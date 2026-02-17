# Adding Verbs

This guide covers the complete workflow for adding verbs to Konjugieren, including XML file formats, the ablaut system, verb families, and lessons learned from adding the first 400 verbs.

## XML File Formats

### Verbs.xml

Defines verbs with their properties:

```xml
<verb in="an+k^om^men" tn="arrive" ay="s" fr="255" ag="kommen" fa="s" />
```

| Attribute | Meaning | Required |
|-----------|---------|----------|
| `in` | Infinitive with markers (see below) | Yes |
| `tn` | Translation | Yes |
| `fa` | Family: `s`=strong, `m`=mixed, `w`=weak, `i`=ieren | Yes |
| `fr` | Frequency rank (lower = more common) | Yes |
| `ag` | Ablaut group name (required for strong/mixed) | Conditional |
| `ay` | Auxiliary: `s`=sein, `h`=haben (default: haben) | No |

**Infinitive markers:**
- `+` separates a separable prefix (e.g., `an+kommen` → ankommen)
- `*` separates an inseparable prefix (e.g., `ver*stehen` → verstehen)
- `^` marks ablaut region boundaries (e.g., `k^om^men` → ablaut region is "om")

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
- Required attributes (infinitiv, translation, family, frequency, exemplar)
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

## Adding a New Verb

### Weak or -ieren Verb (Regular)

Simply add to Verbs.xml without ablaut markers:

```xml
<verb in="machen" tn="make, do" fr="8" fa="w" />
<verb in="studieren" tn="study" fr="353" fa="i" />
```

### Strong or Mixed Verb

1. **Add to Verbs.xml** with ablaut markers and group reference:
   ```xml
   <verb in="s^i^ngen" tn="sing" fr="354" ag="singen" fa="s" />
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
| schneiden | leiden | eid→itt (all past forms) |

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
