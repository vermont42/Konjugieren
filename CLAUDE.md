# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

This is an Xcode project. Use the following commands:

```bash
# Build the app
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run tests
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' test

# Run a single test class
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:KonjugierenTests/Models/ConjugatorTests

# Run a single test method
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:KonjugierenTests/Models/ConjugatorTests/perfektpartizip
```

## Architecture Overview

Konjugieren is an iOS app for learning German verb conjugations. It will eventually conjugate 1,000 verbs across all German tenses.

## Project Structure

```
Konjugieren/
├── App/
│   ├── KonjugierenApp.swift    # Main app entry point
│   ├── AppLauncher.swift       # Determines test vs production app
│   └── TestApp.swift           # Test app configuration
├── Models/
│   ├── Verb.swift              # Verb model with stamm computation
│   ├── VerbParser.swift        # Parses Verbs.xml
│   ├── Verbs.xml               # Verb definitions
│   ├── Conjugator.swift        # Core conjugation logic
│   ├── ConjugationGroup.swift  # Enum of conjugation groups with endings
│   ├── Ablaut.swift            # Ablaut parsing from XML strings
│   ├── AblautGroup.swift       # Groups of ablauts for a verb pattern
│   ├── AblautGroupParser.swift # Parses AblautGroups.xml
│   ├── AblautGroups.xml        # Ablaut pattern definitions
│   ├── Family.swift            # Verb families (strong/weak/mixed/ieren)
│   ├── PersonNumber.swift      # 1s, 2s, 3s, 1p, 2p, 3p
│   ├── Prefix.swift            # Separable/inseparable prefixes
│   └── Auxiliary.swift         # haben/sein auxiliary verbs
└── Views/
    └── ContentView.swift       # SwiftUI view
```

## Terminology

### Conjugation Group

The term "conjugation group" was invented for this project because no existing term adequately described the concept. A conjugation group with more than one members, like Präsens Indikativ, combines tense and mood to identify a specific set of verb forms. The conjugation groups with one member are Perfektpartizip and Präsenspartizip.

### Tense vs. Mood

In discourse about Indo-European languages, "tense" refers only to time. German, like other Germanic languages, has only two tenses:
- **Präsens** (present)
- **Präteritum** (past)

Verbs are also encoded with **mood**. German has three moods:
- **Indikativ** - corresponds to the English indicative mood
- **Konjunktiv I** - corresponds to the English subjunctive mood
- **Konditional** (also called Konjunktiv II) - corresponds to the English conditional mood

### Conjugation Groups in This Codebase

| Conjugation Group | Tense | Mood | English Equivalent |
|-------------------|-------|------|-------------------|
| Präsens Indikativ | Präsens | Indikativ | Present indicative |
| Präteritum Indikativ | Präteritum | Indikativ | Past indicative |
| Präsens Konjunktiv I | Präsens | Konjunktiv I | Present subjunctive |
| Präteritum Konditional | Präteritum | Konditional | Past conditional |
| Imperativ | - | Imperativ | Imperative |
| Perfektpartizip | - | - | Past participle |
| Präsenspartizip | - | - | Present participle |

### Usage Notes

- Avoid using "tense" to describe conjugation groups
- Use "Konditional" rather than "Konjunktiv II" for clarity
- The participles (Perfektpartizip, Präsenspartizip) are non-finite verb forms and do not have tense or mood

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
- `d` = Präteritum Konditional (d1s, d2s, d3s, d1p, d2p, d3p, dA=all)
- `pp` = Perfektpartizip
- `i` = Imperativ (i2s, i1p, i2p, i3p, iA=all)

**Full override:** Append `*` to replacement to use it as the complete conjugated form (skips adding the normal ending). Used for highly irregular verbs like sein:

```xml
<ag e="sein" a="bin*,a1s|bist*,a2s|ist*,a3s|..." />
```

## The Ablaut System

German strong and mixed verbs undergo vowel changes (ablaut) in different conjugation groups. The system works as follows:

1. **Verb definition** marks the ablaut region with `^` characters
2. **Ablaut group** defines what replacements occur for each conjugation group
3. **Conjugator** applies the replacement at runtime

**Example: sehen (to see)**
- Infinitive: `s^e^hen` (ablaut region is "e" at indices 1..<2)
- Stamm: "seh"
- Ablaut group: `ie,a2s,a3s|a,bA|ä,dA`
- Results:
  - Präsens 2s: replace "e" with "ie" → "sieh" + "st" = "siehst"
  - Präteritum: replace "e" with "a" → "sah" + endings
  - Konditional: replace "e" with "ä" → "säh" + endings

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
   <ag e="singen" a="a,bA|ä,dA|u,pp" />
   ```

3. **Look up conjugation** on German Wiktionary: `https://de.wiktionary.org/wiki/Flexion:VERB`

### Verb with Prefix

- Separable prefix: use `+` (e.g., `an+kommen`)
- Inseparable prefix: use `*` (e.g., `ver*stehen`)

Prefixed verbs can share an ablaut group with their base verb.

## Verb Families

| Family | Description | Präteritum Endings | Perfektpartizip |
|--------|-------------|-------------------|-----------------|
| Strong | Vowel change (ablaut) | No -te suffix | ge- + stamm + -en |
| Mixed | Vowel change + weak endings | -te suffix | ge- + stamm + -t |
| Weak | Regular, no vowel change | -te suffix | ge- + stamm + -t |
| -ieren | Verbs ending in -ieren | -te suffix | stamm + -t (no ge-) |

## Common Wiktionary Reference

For verb conjugations: `https://de.wiktionary.org/wiki/Flexion:VERBNAME`

Note: Wiktionary uses "Konjunktiv II" for what this codebase calls "Konditional" (Präteritum Konditional).
