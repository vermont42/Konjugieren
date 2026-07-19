# Sweep low-value comments (declutter to CLAUDE.md's comment policy)

**Status:** ✅ executed in `3f7b8fd`. Kept for the rationale; not outstanding work.
Note that `CLAUDE.md`'s comment policy has since been relaxed for scripts, harnesses,
and test tooling — see its "Comments" section before applying this to `verbdata/` or
`KonjugierenTests/Utils/`.

## Why this exists

Konjugieren's sibling app Conjugar recently ran a comment-only sweep
(`Conjugar.mig/prompts/sweep-comments.md`, commits `ee61032` / `c2e9632`) that
stripped a dense **provenance paper trail** — Fable-audit `item N` citations,
build-plan `Phase N` pointers, cross-app `audit §N` / `K#` / `C#` codes, the
external verb-reference book/taxonomy oracle, and "ported from Konjugieren"
sibling-app notes — across 89 files.

**Konjugieren does not have that paper trail.** A full comment sweep (July 2026,
332 real comment lines across 148 files) found:

- **Zero** provenance citations (`item N`, `Phase N`, `audit §N`, book/taxonomy).
- **Zero** sibling-app mentions in comments (no "Conjugar", "Conjuguer",
  "mirrors", "ported from").
- **Zero** change-narration comments ("previously", "used to", "per the audit").

Konjugieren's conjugation engine is **original and will not change** — it never
accumulated the migration scar tissue Conjugar's rewritten engine did. So this
sweep is not a provenance strip. It is a **decluttering pass** that brings the
codebase into line with the comment policy already written in `CLAUDE.md`:

> Code should be well-written and therefore self-explanatory. Explanatory and
> MARK comments result in clutter and increased maintenance burden. Only use
> comments for: file headers, TODOs, hacks or workarounds.

This is a **comment-only** sweep. Do not change any executable code, string
literals, or user-facing copy. `git diff` should show only comment lines
(`//`, `///`, or inside `/* */`).

## The governing rule

For every comment that is **not** a file header, a `// TODO:`, or a
`// HACK:` / workaround note, apply this test:

1. **Delete it** if its content is already encoded in the code it sits above —
   a label restating the identifier, or a worked example whose facts are already
   in the test's expected value. This is the **aggressive lean Josh chose**: if
   reading the next line or two tells you the same thing the comment does, the
   comment is clutter.
2. **Keep it (trimmed if needed)** only when it carries **durable, non-obvious
   rationale** a future reader can't recover from the code itself — a
   phonological rule that explains why an expected value looks wrong, a
   concurrency/isolation constraint, an ordering guarantee, a deliberate
   silent-failure, an SE-number workaround. These answer "why is the code like
   this?", not "what does this line do?".

When a comment is borderline after applying the rule, **lean toward deletion** —
Josh is comment-averse and believes well-written code is self-documenting. This
is judgment work, not a regex replace: read each comment in the context of the
code beneath it.

**If you hit a class of comments you're genuinely unsure about** after applying
the rule, collect the cases (file, comment, your recommendation) and ask Josh
together rather than guessing or interrupting per file. Reserve this for real
uncertainty; the inventory below already resolves the known cases.

## MARK comments — delete all of them, unconditionally

Josh does not use `// MARK:` markers for navigation, and `CLAUDE.md` names them
as clutter. Delete **every** `// MARK:` line in the swept files, regardless of
what follows the marker. Known hits (re-scan before starting — line numbers
drift):

- `Konjugieren/Utils/WidgetSnapshotWriter.swift` — 4 (`Verb Selection`,
  `Conjugation Paradigm`, `Quiz Question Generation`, `Utilities`)
- `KonjugierenTests/Models/ConjugatorTests.swift` — 4 (`du form`, `ihr form`,
  `wir form`, `Sie form`)
- `KonjugierenTests/Utils/VerbExportTests.swift` — 1 (`Encodable Structs`)

Search: `// MARK:` across all four source roots.

## The main body of work: `ConjugatorTests.swift`

This one file holds the bulk of the sweep. It has ~150 descriptive comments in
three sub-classes. Apply the governing rule:

**DELETE — pure labels** (content is the identifier restated):
`// Weak verb`, `// Strong verb`, `// Mixed verb(s)`, `// -ieren verb`,
`// Separable prefix verb`, `// Inseparable prefix verb`, `// Weak verb - all
persons`, `// Präsens Indikativ`, `// Präteritum Indikativ`, `// Perfektpartizip`,
the section sub-labels (`// arbeiten: Präsens Indikativ 2p`, `// kosten: Präsens
Indikativ 3s`), and the `// X - uses Y pattern` cross-references
(`// sterben - uses sprechen pattern`, `// trinken - uses singen pattern`, etc.).

**DELETE — ablaut worked-examples whose facts are in the expected value.** The
test's mixed-case expected string (`"sAng"`, `"gesUngen"`, `"kÄme"`) already
encodes the ablaut per the project's mixed-case convention, so the parallel
prose comment is redundant:
`// singen - i→a (Präteritum)`, `// treffen - eff→iff (Präsens 2s,3s), eff→af…`,
`// fahren - a→ä (Präsens 2s,3s), a→u (Präteritum)…`, and every sibling of that
shape. Also delete the `// Pattern: mAG*,a1s,a3s|…` lines (they transcribe the
verb-data encoding, which lives in the verb definitions) and their
`// mögen - Präsens singular has full overrides…` header lines.

**KEEP — genuine linguistic / test-intent rationale** (NOT recoverable from the
expected value). Do not let the aggressive pass sweep these away:

- The `// Note:` engine-behavior notes — e.g. `// Note: German spelling would
  convert ß→ss after short vowel, but conjugator preserves consonant` (schließen,
  genießen, essen, vergessen), and `// Note: 3s ending -t merges with stamm
  ending -tt (German phonology)` (treten). These explain a *surprising* engine
  choice, which is exactly the "why is it like this?" class.
- `// arbeiten: Präsens Indikativ 3s should get epenthetic "e" → "arbeitet" not
  "arbeitt"` — explains the epenthesis rule the expected value tests.
- `// schreien … contracted Perfektpartizip` / `contracted from *geschrieen` —
  the "contracted from" note is non-obvious; keep that fact (drop the `Pattern:`
  transcription).
- `// The three guards run in order: length, then ending validity, then
  recognition.` and `// The conjugationgroup is irrelevant: all three guards run
  before the group switch.` — test-intent rationale for the error-path tests.

## Inventory for the rest of the tree

Beyond `ConjugatorTests.swift` and the MARKs, the corpus is mostly durable
rationale that **stays**. The sweep still visits these files to catch any thin
label, but expect few edits.

**KEEP (durable rationale — do not touch):**
- `Konjugieren/Intents/SiriConjugationgroup.swift` — the rawValue legacy-spelling
  note (persisted Shortcuts identifiers).
- `Konjugieren/Models/AblautGroupInfo.swift` — `// Alphabetical per German locale
  (umlauts sort as base vowel, ß as ss)`.
- `Konjugieren/Models/LanguageModelServiceReal.swift` — the on-demand-availability
  note (25–27), the refusal-detection `null`/`nullify` note (267–270), the
  actor-isolation note (313–315), the specificity-ordering note (393–395). These
  are the substantive rationale. The pure step-labels in the JSON-parsing routine
  (`// German redirects`, `// Bare-name fallbacks…`, `// Fallback: extract from
  first { to last }`) are borderline — trim them only if they merely restate the
  next line; keep if they aid a non-obvious parse.
- `Konjugieren/Utils/SoundPlayerReal.swift` — the `forums.developer.apple.com`
  URL documents the workaround it sits on (a permitted hack/workaround note).
- `Konjugieren/Views/TutorView.swift:385` — `// Silently fail — recommendations
  are supplementary` (explains a deliberate empty catch).
- `Konjugieren/Utils/WidgetSnapshotWriter.swift` — the distractor-strategy notes
  (`// Wrong 1: same conjugationgroup, different person`, etc.) explain
  non-obvious quiz-generation logic; keep (but delete the MARKs above them).
- `KonjugierenWidget/SnapshotReader.swift` — the `///` timeline-entry doc block.
- `KonjugierenWidget/Views/WidgetAblautText.swift` — the color-hex notes document
  magic numbers; keep.
- `Shared/WidgetQuizShuffle.swift`, `Shared/WidgetSnapshot.swift` — SE-0206
  seeding rationale and index-order notes.
- Test rationale: `PersonNumberTests` (er/es vs sie collision), `QuizTests`
  (timer/run-loop mechanics, guard no-ops), `RefusalDetectionTests`
  (`null`/`nullify` edge cases), `VerbTests` (`"ändern"` ends in "rn"),
  `WidgetSnapshotTests` (FNV golden-value), `VerbExportTests:10` (per-instance
  unique path). All keep.

**DELETE (thin labels, same rule as ConjugatorTests):**
- `KonjugierenTests/Utils/VerbExportTests.swift` — the one-word structural labels
  (`// Partizipien`, `// Prefix`, `// Family`, `// Etymology (English)`,
  `// Example sentences`). Keep `:10` (unique-path rationale); the
  `// Conjugationgroup factories in VerbView display order (excluding
  partizipien)` line carries ordering rationale — keep it.

## Do NOT touch (out of scope / false positives)

- **The disabled-surface TODO blocks** in `Konjugieren/Views/QuizView.swift`
  (149–157) and `Konjugieren/Views/TutorView.swift` (76–90). These are
  `// TODO:`-tagged, carry the restore condition, and point to the live
  `docs/cloud-llm-tier.md`. `CLAUDE.md` permits TODOs; Josh chose to keep them
  as-is, including the commented-out code beneath each TODO.
- **File headers** (`//  Foo.swift`, `//  Created by…`, `//  Copyright…`).
- **`//` inside string literals**, which look like comments to a naive scan but
  are code. Every `//verb/…`, `//quiz/start`, `//example.com`, `//apple.com`,
  `//"` hit in the sweep is a fragment of a `konjugieren://` deeplink URL or an
  `https://` test string — NOT a comment. Files affected: `KonjugierenApp.swift`,
  `URLExtension.swift`, all `KonjugierenWidget/Views/*`, `Shared/OpenQuizIntent`,
  `Shared/OpenRandomVerbIntent`, `DeeplinkTests`, `StringExtensionsTests`. Skip
  every one.
- `Konjugieren/Assets/Localizable.xcstrings` and the widget's
  `KonjugierenWidget/Localizable.xcstrings` — no code comments live there.
- `docs/**`, `prompts/**`, `CLAUDE.md`.

## Execution mechanics

- Work file-by-file. For each hit, read the code beneath the comment before
  deciding — the same phrasing can be delete-worthy in one spot and rationale in
  another.
- Editing engine/view files may spam SourceKit "Cannot find type X in scope" /
  "has no member" diagnostics for same-module symbols. These are **false
  positives** — comment edits cannot change symbol resolution. Ignore them.
- `git diff` sanity check when done: every changed line must be a comment. If a
  non-comment line changed, revert it.

## Validation

The change is comment-only and must compile identically. Use the
`ios-build-verify` skill (see `CLAUDE.md` for the `IBV_SCRIPTS` resolution):

- `"$IBV_SCRIPTS/build_app.sh"` — app + widget build green.
- `swiftlint` — clean.
- `"$IBV_SCRIPTS/run_tests.sh"` — the test files are in scope, so a test-target
  build is worthwhile even though comment edits shouldn't affect behavior.

## Commit

One commit on `main`, e.g.:
`Declutter comments to CLAUDE.md's comment policy`

Body: note that this deletes every `// MARK:`, the redundant label and ablaut
worked-example comments in `ConjugatorTests.swift` (the mixed-case expected value
already encodes the ablaut), and other thin restate-the-code labels — keeping
only file headers, TODOs/workarounds, and durable non-obvious rationale. Unlike
Conjugar's sweep, there was no provenance paper trail to strip; Konjugieren's
engine is original.
