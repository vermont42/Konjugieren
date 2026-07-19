# Support the three standard varieties of German

## Status

**Executed 2026-07-19.** See `docs/blog_notes.md` for what changed during execution. Two
deviations from the plan below, both deliberate: `Conjugator.conjugate` gained an
`auxiliary: Auxiliary? = nil` parameter rather than the auxiliary swap happening as a string
transform (it still knows nothing of `Region`, and the default keeps the oracle byte-identical);
and the flags were dropped from the settings picker, where they truncated the labels, while
staying in the `VerbView` auxiliary pill. Scope also grew once, by Josh's decision: displayed
infinitives are transformed too, not only conjugations, with verb search normalized on both
sides so the two spellings still match.

Original plan follows.

**Planned, not started.** Decided by Josh on 2026-07-19. Do this **before**
[`dual_auxiliary.md`](dual_auxiliary.md), which assumes it has already run: that pass covers
the ~469 verbs whose auxiliary varies by *meaning*, and it explicitly hands the handful that
vary by *region* to this one.

## Why

German is **pluricentric**: it has three codified national standards — German, Austrian, and
Swiss — not one standard plus a set of dialects. Duden and the Swiss and Austrian references
treat Austrian and Swiss forms as standard, not as errors. Konjugieren currently presents only
the German (northern) standard, silently, with no indication that the others exist.

Two facts differ, and — this is the design constraint — **they partition the German-speaking
world differently**:

| | Germany | Austria | Switzerland |
|---|---|---|---|
| ß | yes | yes | **never** |
| Perfekt of *stehen*, *sitzen*, *liegen* | *hat gestanden* | *ist gestanden* | *ist gestanden* |

Swiss Standard German abolished ß outright in the 1970s: every ß is written ss, with no
exceptions and no context-dependence. It is current usage for roughly five million people, and
until 2026-07-19 this repo's own tooling filed those spellings under "obsolete."

## Scope decision, made 2026-07-19

Southern Germany — Bavaria, Baden-Württemberg — also says *ist gestanden*, but Duden marks that
as regional **within** Germany rather than standard German. Josh's call: **do not add a fourth
setting for it.** Supporting a non-standard German-German conjugation is a step too far.

The consequence is a naming one. Do not label the first option "Deutschland", which would tell
a Bavarian user their own German is Austrian. **Label it by the variety, not the country** —
"North / Standard". The flag 🇩🇪 may accompany it, but the word carries the meaning.

**Mention it, though.** Approved by Josh on 2026-07-19: affected verbs carry a short note that
southern German usage matches the Austrian and Swiss form. Describing reality costs nothing and
is not the same as offering it as a setting — a Bavarian user should be able to find their own
usage in the app without the app claiming it is the German standard.

The accurate, sourced formulation is Duden's own label, which groups all three together:

> süddeutsch, österreichisch, schweizerisch

So the note should attribute rather than adjudicate. Suggested wording, to be checked against
[`../docs/english_writing_style.md`](../docs/english_writing_style.md) before it ships:

- en: "Duden labels this form southern German, Austrian, and Swiss."
- de: „Duden kennzeichnet diese Form als süddeutsch, österreichisch und schweizerisch“

Place it near the auxiliary pill rather than inside it — the pill is a badge and this is a
sentence. A caption-styled line under the metadata row, shown only on verbs whose auxiliary is
regionally conditioned, is the natural home. Note the German quotation marks: „…“ are Unicode
curly quotes and need no JSON escaping, which sidesteps the `.xcstrings` ASCII-quote trap
described in `CLAUDE.md`.

## What ships

### 1. A `Region` setting

Three cases, following the existing pattern in `Models/ThirdPersonPronounGender.swift` exactly
— `String`-raw-value enum, a `localizedRegion` computed property switching over `L.Region.*`.
Register it in `Settings.swift` with a key, a default, and the one-line `restore(...)` call, and
add a row to `SettingsView.swift`. The full recipe is under "Adding a New Setting" in
`CLAUDE.md`; follow it rather than improvising.

| Case | Label (en) | Label (de) | Flag | ß | Auxiliary |
|---|---|---|---|---|---|
| `north` | North / Standard | Norddeutsch / Standard | 🇩🇪 | ß | haben |
| `austria` | Austria | Österreich | 🇦🇹 | ß | sein |
| `switzerland` | Switzerland | Schweiz | 🇨🇭 | ss | sein |

Default `north`. **Seed it from the device locale on first launch** — `de-AT` → `austria`,
`de-CH` → `switzerland` — so an Austrian user is not told their German is wrong before they
find Settings. Do this in `Settings.init` only when no stored value exists, so it never
overrides a choice the user made.

Per house convention the description string in `Localizable.xcstrings` begins "This setting
determines…".

### 2. Swiss orthography as a display transform

Not data. `ß` → `ss` and `ẞ` → `SS`, applied where conjugations are rendered.

The uppercase half matters: ablaut replacements use the capital sharp s `ẞ` so the
mixed-case highlighting covers the sibilant (see `docs/adding-verbs.md`). `ẞ` → `SS` keeps both
characters uppercase, so the highlight survives the transform intact. Verify that
`String.parseConjugationToSegment` still produces one `.irregular` run and not two.

**Do not put this in `Conjugator`.** It must stay region-free, because the classify-and-verify
pipeline compares its output against Wiktionary and every `ConjugatorTests` expectation is
written in the German standard. A region-sensitive `Conjugator` would make the oracle and the
test suite vary by setting, which destroys the one external check this project has.

Apply it at the display layer at all six sites that call `Conjugator`:

| Site | Note |
|---|---|
| `Views/VerbView.swift` | the conjugation table; the main case |
| `Views/FamilyBrowseView.swift` | family exemplars |
| `Models/Quiz.swift` | prompts *and* answer checking — see below |
| `Utils/WidgetSnapshotWriter.swift` | widget snapshots; regenerate when the setting changes |
| `Intents/ConjugateVerbIntent.swift` | App Intent output |
| `Models/LanguageModelServiceReal.swift` | Tutor; note it cannot be verified on an Intel Mac host, see `CLAUDE.md` |

A single `String` extension used by all six is the right shape. Josh approved applying this
wherever it makes sense rather than to `VerbView` alone: a setting that changed one screen would
read as a bug.

### 3. Region-aware auxiliary, with a visible indicator

`Verb` gains a way to say "this verb's auxiliary is regionally conditioned". The affected set is
small — see "Curating the verb list" — so an attribute on the verb is enough; this does **not**
need the `reading` model from `dual_auxiliary.md`, and should not use it. Two readings differing
only in an auxiliary badge would tell every user that both forms are available to them
personally, which is false for any single speaker, and would read as a rendering bug.

`VerbView.swift` already renders an auxiliary `metadataPill` — a `Label` showing
`verb.auxiliary.verb` with an `arrow.triangle.branch` icon, around lines 53–61. That pill is the
right home for the indicator. When a verb's auxiliary is regionally conditioned, show both forms
with their flags rather than only the one the setting selected, so the user learns that the
other exists:

```
hat 🇩🇪  ·  ist 🇦🇹🇨🇭
```

The setting decides which is **primary** — used in the conjugation table and the quiz — not
which is shown in the pill.

Flags are safe on iOS 26. The emoji bug in `docs/emoji-assets.md` affects the *tag-sequence*
flag 🏴󠁧󠁢󠁥󠁮󠁧󠁿 and, contextually, 🐎; 🇩🇪🇦🇹🇨🇭 are regional-indicator pairs, a different mechanism, and
🇩🇪 already renders in 40 localized strings. No PNG assets needed. Screenshot it anyway.

Accessibility: the pill sets `.accessibilityLabel(Text(verbatim: verb.auxiliary.verb))` and
`.germanPronunciation()`. Flags must not be read as "flag of Germany, flag of Austria" mid-verb;
supply a spoken label naming the varieties. Check `docs/voiceover.md` before adding anything
interactive to that row — per-child `.environment(\.locale)` does not work inside
`NavigationLink` or `Button`, which has already forced programmatic navigation elsewhere.

### 4. Quizzes accept all three varieties

This is the largest code change in the pass, and it is easy to underestimate.

`Quiz.swift` currently holds `let correctAnswer: String` on `QuizItem` and checks
`trimmedAnswer == correctAnswer` (around line 87), where the value came from
`Conjugator.conjugateUnsafely`. It must become a **set of acceptable answers**: the ß and ss
spellings, and both auxiliaries where the verb is regionally conditioned.

`correctAnswer` also flows into `QuizErrorHistory`, the telemetry payload (`"answer":
item.correctAnswer`), and `announceAnswerResult`'s VoiceOver readout. Each needs a single
canonical string alongside the acceptable set — **render that one in the user's own variety**,
so a Swiss user who misses *schloss* is not shown *schloß*.

The principle: the setting governs presentation and never marks a learner wrong. A user who
types a correct form from another standard variety is correct.

## Curating the verb list

**The oracle cannot help here, and this is the one place in the project where that is true.**
kaikki reports *stehen*, *sitzen*, and *liegen* as bare `haben or sein`, with no tags — exactly
the shape it gives *schwimmen*, whose alternation is about argument structure, not region. The
snapshot does carry `Austria` (2,934), `Southern-Germany` (1,933), and `Switzerland` (956) tags,
but on **senses**, marking regionally restricted meanings, never on the auxiliary.

So the list is hand-curated. *stehen*, *sitzen*, and *liegen* are the canonical three in every
reference grammar. Sources disagree about *hocken*, *knien*, *stecken*, and *lehnen*; German
Wiktionary's `Flexion:` pages carry an explicit "süddeutsch, österreichisch, schweizerisch" note
in the Hilfsverb line and are the best per-verb check. Decide each explicitly and record the
source; do not guess, and do not let the list grow by analogy.

Note that prefixed forms inherit: *aufstehen*, *entstehen*, and the rest need the same decision
as their base.

## Verification

The classify-and-verify pipeline is the regression test. Before starting, record the baseline:
as of 2026-07-19 the shipping corpus stands at **14 verbs at odds with Wiktionary, 99.0%
verified**. Run `docs/verb-classification.md`'s three stages after every substantive change.

Because `Conjugator` stays region-free, that number should be **completely unaffected** by this
pass. If it moves at all, region-sensitivity has leaked into the engine — find it before
continuing.

Two further checks the pipeline will not do for you:

- **Do not import both spellings.** 98 incoming candidates are Swiss spellings of a verb already
  present with ß — *abfliessen* beside *abfließen*. They are one verb. `verbdata/classification-summary.md`
  flags them. Dedupe by ß-normalization before any import.
- **Screenshot all three settings.** `scripts/take_screenshots.sh` and the `ios-build-verify`
  skill exist; the ß→ss transform and the flag pill are both visual, and neither is covered by a
  unit test.

## Work plan

1. Baseline the pipeline. Note the at-odds count.
2. Add the `Region` enum, `Settings` wiring, `SettingsView` row, and `L`/`Localizable.xcstrings`
   entries in both languages. Remember the `.xcstrings` ASCII-quote trap in `CLAUDE.md`: edits
   that add or change `"` must go through Python, not the Edit tool, and JSON validity must be
   checked afterward.
3. Add the locale-seeded default.
4. Add the ß/ss display transform and route all six render sites through it. Add
   `StringExtensionsTests` cases, including one asserting that `ẞ` → `SS` leaves the mixed-case
   segmentation with a single irregular run.
5. Curate the regional-auxiliary verb list. Record the source per verb.
6. Add the region-aware auxiliary to `Verb`, the flag indicator to `VerbView`'s auxiliary pill
   with its accessibility label, and the southern-German note below the metadata row. The note
   is a localized string in both languages; consult `docs/english_writing_style.md` for the
   English and use curly quotes „…“ in the German so the `.xcstrings` ASCII-quote trap does not
   apply.
7. Widen the quiz to an acceptable-answer set; keep one canonical string for history, telemetry,
   and VoiceOver, rendered in the user's variety.
8. Re-run the pipeline; confirm the at-odds count is unchanged.
9. Screenshot all three settings; verify flags render on a real device or a simulator screenshot.
10. Update `docs/project-structure.md`, `docs/adding-verbs.md` (the ß/ss section should note that
    Swiss rendering is a display concern, not a data one), and append to `docs/blog_notes.md`.

## What this pass deliberately does not do

- It does not model regional variation as a `reading`. See "Region-aware auxiliary" above.
- It does not touch the ~469 verbs whose auxiliary varies by **meaning** — *schmelzen*, *fahren*,
  *hängen*. That is [`dual_auxiliary.md`](dual_auxiliary.md), and it runs after this.
- It does not add a southern-German *setting*. It does mention southern German usage on the
  affected verbs — describing it, without offering it as a variety to conjugate in. See "Scope
  decision".
- It does not make `Conjugator` region-aware. That is the load-bearing constraint of the whole
  design.
