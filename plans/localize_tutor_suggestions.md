# Plan: Localize the tutor suggestion chips (German)

_Drafted 2026-07-08._

## Problem

`Konjugieren/Views/TutorView.swift` defines a `private static let suggestions` array of **16
hardcoded English strings** (e.g. `"Conjugate singen in the Präteritum."`). These are the
sample-query chips shown in the tutor's "sample query" sheet. In an otherwise-bilingual
(en/de) app they never switch to German — the German-locale user sees English prompts.

This mirrors code-review finding **#20** in the sibling app **Conjuguer** (French), where the
same array is English-only.

## Chosen approach — Conjugar's locale-switched parallel arrays

The sibling app **Conjugar** (Spanish, `../Conjugar/Conjugar/Views/TutorView.swift`) already
solved this. Rather than routing the strings through the `L` / `Localizable.xcstrings` system,
it keeps **two hand-written arrays selected by locale**:

```swift
private static var isSpanish: Bool {
  Locale.current.language.languageCode?.identifier == "es"
}
private static let englishSuggestions = [ … ]
private static let spanishSuggestions = [ … ]
private static var suggestions: [String] {
  isSpanish ? spanishSuggestions : englishSuggestions
}
```

**Conjuguer (French) has now been updated to this exact pattern** (`isFrench` /
`frenchSuggestions`). Konjugieren should follow suit with `isGerman` / `germanSuggestions`.

### Why this over `L` / `.xcstrings`

- These are model **prompts** (full sentences), not UI labels. They belong in code, near the
  tutor logic, the same way the English array already is.
- 16 sentence-length keys in the String Catalog is heavy boilerplate for content that only
  ever has two variants and is never reused elsewhere.
- Consistency across the three-app family (Conjugar, Conjuguer, Konjugieren) is worth more
  here than consistency with the app's own `L` convention.

Trade-off accepted: this is inconsistent with how the rest of Konjugieren localizes (via `L`).
That's a deliberate, documented call — same one the other two apps made.

## Keep the count at 16

Konjugieren currently ships **16** suggestions (Conjugar ships 12). **Do not change the
count** — write 16 German strings, one per existing English entry, preserving order so the
two arrays stay index-aligned.

## Implementation

### Edit `Konjugieren/Views/TutorView.swift`

Replace the single `private static let suggestions = [ … ]` block with:

```swift
  private static var isGerman: Bool {
    Locale.current.language.languageCode?.identifier == "de"
  }

  private static let englishSuggestions = [
    "Conjugate singen in the Präteritum.",
    "What is the Konjunktiv II of sein?",
    "What is the past participle of trinken?",
    "Conjugate laufen in the future tense.",
    "What is the imperative of helfen?",
    "How do you say \u{2018}I would have sung\u{2019} in German?",
    "What is the Perfekt of gehen?",
    "Conjugate sprechen in the Präsens.",
    "How do you say \u{2018}we had written\u{2019} in German?",
    "What is the Konjunktiv I of geben?",
    "Conjugate anfangen in the Perfekt.",
    "What are all the Präsens conjugations of wissen?",
    "How do you conjugate können in the Präteritum?",
    "What is the Futur of nehmen?",
    "Conjugate essen in the Plusquamperfekt.",
    "How do you say \u{2018}they would carry\u{2019} in German?"
  ]

  private static let germanSuggestions = [
    "Konjugiere singen im Präteritum.",
    "Was ist der Konjunktiv II von sein?",
    "Was ist das Partizip II von trinken?",
    "Konjugiere laufen im Futur.",
    "Was ist der Imperativ von helfen?",
    "Wie sagt man \u{201E}ich hätte gesungen\u{201C} auf Deutsch?",
    "Was ist das Perfekt von gehen?",
    "Konjugiere sprechen im Präsens.",
    "Wie sagt man \u{201E}wir hatten geschrieben\u{201C} auf Deutsch?",
    "Was ist der Konjunktiv I von geben?",
    "Konjugiere anfangen im Perfekt.",
    "Wie lauten alle Präsens-Formen von wissen?",
    "Wie konjugiert man können im Präteritum?",
    "Was ist das Futur von nehmen?",
    "Konjugiere essen im Plusquamperfekt.",
    "Wie sagt man \u{201E}sie würden tragen\u{201C} auf Deutsch?"
  ]

  private static var suggestions: [String] {
    isGerman ? germanSuggestions : englishSuggestions
  }
```

The call site already reads `Self.suggestions` (in the sample-queries sheet), so **no
call-site change is needed** — it now resolves to the computed property.

### German translation notes

- **Register:** informal imperative `Konjugiere …` (du-form), matching Conjugar's informal
  `Conjuga …`.
- **Quotes:** German low-high quotation marks `„ … "` — written as `\u{201E}` (opening `„`)
  and `\u{201C}` (closing `"`). This mirrors the existing English array's use of `\u{2018}` /
  `\u{2019}` escapes for its curly quotes rather than pasting raw glyphs.
- **The "how do you say X" prompts** give the **German** target phrase (`ich hätte
  gesungen`, `wir hatten geschrieben`, `sie würden tragen`) — following Conjugar, which
  translates the English gloss into the target-language answer.
- **Grammatical terms stay German** (`Präteritum`, `Konjunktiv II`, `Perfekt`, `Präsens`,
  `Plusquamperfekt`, `Futur`) in both arrays — they're already German.
- `past participle` → `Partizip II`; `future tense` → `Futur` (the app's own tense label).
- Contractions: `im` (= in dem) is correct for all the masc/neut tense nouns used here.
- Double-check `Wie lauten alle Präsens-Formen von wissen?` reads naturally to a native ear;
  an alternative is `Was sind alle Präsens-Konjugationen von wissen?`.

## Verification

1. `build_app.sh` — expect a clean build (SourceKit may show same-module "cannot find in
   scope" noise for `L` / `Current`; the build is authoritative, ignore it).
2. Launch with the **German** app language and open the tutor's sample-query sheet; confirm
   all 16 chips render in German and tapping one populates the input field.
3. Launch with **English** and confirm the chips are unchanged (regression check on the
   `else` branch).

To force locale at launch, set the scheme's Run → Options → App Language to German (or pass
`-AppleLanguages "(de)"`), the same way the app is exercised in German elsewhere.

## Reference

- Conjugar (done): `../Conjugar/Conjugar/Views/TutorView.swift` — `isSpanish` /
  `spanishSuggestions`.
- Conjuguer (done): `../Conjuguer/Conjuguer/Views/TutorView.swift` — `isFrench` /
  `frenchSuggestions`.
