# Conjugationgroup Article Template

## Purpose

This document provides instructions for writing educational articles about German conjugationgroups for the Konjugieren app's Info system. Each conjugationgroup (e.g., Perfektpartizip, Präsens Indikativ) has a corresponding article that explains its formation, usage, and provides literary examples.

## Literary Sources

Use these public-domain texts from Project Gutenberg for authentic literary examples.

### Primary Texts

**Goethe: "The Sorrows of Young Werther" (1774)**
- German: https://www.gutenberg.org/cache/epub/2407/pg2407.txt
- English: https://www.gutenberg.org/cache/epub/2527/pg2527.txt

**Kafka: "The Trial" (1925)**
- German: https://www.gutenberg.org/cache/epub/69327/pg69327.txt
- English: https://www.gutenberg.org/cache/epub/7849/pg7849.txt

**Mann: "Death in Venice" (1912)**
- German: https://www.gutenberg.org/cache/epub/12108/pg12108.txt
- English: https://www.gutenberg.org/cache/epub/66073/pg66073.txt

### Old High German Sources

For historical context, these early German texts can provide examples of verb evolution:

- **Hildebrandslied** (c. 830 AD) - Earliest surviving German heroic poetry
- **Tatian translation** (c. 830 AD) - East Franconian Gospel harmony
- **Otfrid von Weißenburg's Evangelienbuch** (c. 870 AD) - First German rhymed poetry

## Markup Conventions

The app's rich text system uses these markers (parsed by `StringExtensions.swift`, rendered by `RichTextView.swift`):

| Marker | Purpose | Example |
|--------|---------|---------|
| `` ` `` | Section headings (rendered larger/styled) | `` `What Is the Perfektpartizip?` `` |
| `~` | Bold/emphasis | `~Präsens~`, `~haben~`, `~ablaut~` |
| `$...$` | Ablaut/irregularity highlighting (UPPERCASE = changed) | `$gesUngen$`, `$kÄme$`, `$gebrAcht$` |
| `%...%` | Clickable URLs (rarely needed) | `%https://example.com%` |
| 🇩🇪 | Bullet points in lists | `🇩🇪 ~Strong verbs~: vowel change (ablaut)` |
| `\n` | Newlines (within JSON string values) | Between paragraphs |

For bullet items displaying non-German example words, phrases, or sentences, use the appropriate flag, as follows:
English: 🏴󠁧󠁢󠁥󠁮󠁧󠁿
Latin: 🇻🇦
Sanskrit: 🇮🇳
Gothic: 📜
French: 🇫🇷
Spanish: 🇪🇸
Italian: 🇮🇹

### Ablaut Highlighting Rules

When using `$...$` markers:
- Lowercase letters = unchanged parts of the verb
- UPPERCASE letters = the changed ablaut region
- Examples:
  - `$gesUngen$` (sung) - the "u" is highlighted as changed from "i" in "singen"
  - `$gebrAcht$` (brought) - the "a" is highlighted as changed from "i" in "bringen"
  - `$kÄme$` (would come) - the umlaut "ä" shows the Konditional modification

## Article Structure Template

Each conjugationgroup article should follow this structure:

### Section 1: `About`

- Clear definition of what the conjugationgroup represents
- Core function: when and why this form is used
- Comparison with English equivalent (if one exists)
- Brief mention of its role in the German verb system

### Section 2: `Formation by Verb Family`

Cover each verb family with pattern and examples:

**Weak verbs:**
- Formation pattern (e.g., "ge- + stamm + -t")
- Examples: machen → gemacht, spielen → gespielt

**Strong verbs:**
- Formation pattern with ablaut note
- Examples showing vowel changes: singen → $gesUngen$, sprechen → $gesprOchen$

**Mixed verbs:**
- Formation pattern (weak endings + ablaut)
- Examples: bringen → $gebrAcht$, denken → $gedAcht$

**-ieren verbs:**
- Formation pattern (no ge- prefix)
- Examples: studieren → studiert, telefonieren → telefoniert

**Separable prefix verbs:**
- Placement of ge- (between prefix and stamm)
- Examples: ankommen → angekommen, aufstehen → aufgestanden

**Inseparable prefix verbs:**
- No ge- prefix added
- Examples: verstehen → verstanden, bekommen → bekommen

### Section 3: `Usage in Context`

- Common scenarios where this form appears
- Relationship to other conjugationgroups (e.g., Perfektpartizip used in Perfekt Indikativ)
- Any special considerations or common mistakes

### Section 4: `Literary Examples`

Format each example as:

```
"[German sentence with $highlighted$ verb form]" = "[English translation]"

[Author], ~[Work Title]~
```

Include a variety of:
- Strong verb examples (showing ablaut)
- Weak verb examples
- Different verb families represented
- Mix of literary and everyday usage

### Section 5 (optional): `Historical Note`

If relevant to this conjugationgroup:
- Old High German examples showing evolution
- How the form developed over time
- Connection to Proto-Indo-European or Proto-Germanic roots

## Guidelines

### Length
Target 1,500-2,500 words depending on conjugationgroup complexity. Participles and compound conjugationgroups may need more explanation.

### Language
Write in English only for the initial draft. German localization follows separately using the relocalization workflow in CLAUDE.md.

### Example Selection
- Choose verbs already in Verbs.xml when possible
- Include at least one example from each major verb family
- Literary examples should be authentic (from Gutenberg sources)
- Verify German text and translations are accurate

### Tone
Educational but engaging. Connect to the broader linguistic history when appropriate, similar to the verbHistoryText style.

### Technical Accuracy
- Use correct terminology from CLAUDE.md (conjugationgroup, not "tense")
- Reference the ablaut system accurately
- Ensure formation rules match what Conjugator.swift implements

## Implementation Checklist

When creating a new conjugationgroup article:

1. [ ] Add localization key to `L.swift`: `static var [conjugationgroup]Text: String`
2. [ ] Add English text to `Localizable.xcstrings` with proper markup
3. [ ] Add Info entry to `Info.swift` with heading and text reference
4. [ ] Verify article appears in Info browse list

## Verification Steps

After implementation:

1. **Build the app:**
   ```bash
   xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' build
   ```

2. **Run tests:**
   ```bash
   xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test
   ```

3. **Visual verification:**
   - Launch app in simulator
   - Navigate to Info tab
   - Select the new conjugationgroup article
   - Verify:
     - Section headings render with proper styling
     - Bold text (~...~) renders correctly
     - Ablaut highlighting ($...$) shows uppercase in different color
     - No broken markup or missing text

## Example: Perfektpartizip Article Outline

For reference, here's how the Perfektpartizip article might be structured:

```
`What Is the Perfektpartizip?`

The ~Perfektpartizip~ (past participle) is one of German's two participle forms...
[Definition and function]

`Formation by Verb Family`

🇩🇪 ~Weak verbs~: ge- + stamm + -t
Examples: machen → ~gemacht~, spielen → ~gespielt~

🇩🇪 ~Strong verbs~: ge- + ablaut-stamm + -en
Examples: singen → $gesUngen$, sprechen → $gesprOchen$
[etc.]

`Usage in Context`

The Perfektpartizip combines with auxiliary verbs ~haben~ or ~sein~ to form...
[Usage explanation]

`Literary Examples`

"Ich $habe$ den ganzen Tag $gearbeitet$." = "I have worked all day."
Goethe, ~The Sorrows of Young Werther~

[More examples]
```

This template ensures consistency across all conjugationgroup articles while allowing flexibility for each conjugationgroup's unique characteristics.
