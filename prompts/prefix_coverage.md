# Close the prefix-coverage gap in the Families tab

## Where this sits

Self-contained: you need nothing from `docs/roadmap.md` to do this work, and this pass is not
gated on any step in it. But two references below will otherwise be opaque.

**Steps 7 and 8** are the two verb-import tranches of that roadmap, both executed 2026-07-19.
Step 7 added 78 missing strong base verbs; step 8 added 2,315 prefixed derivatives of verbs the
app already conjugated. Together they took the corpus from 990 verbs to 3,383 — a 3.4× growth
that is why a hand-curated list of 25 prefixes stopped being adequate. A **tranche** is one such
import. **Step 8b** is the not-yet-done cleanup of what step 8 deferred, and it owns verb-data
questions; this pass does not.

The narrative of both imports, including why the prefix problem was noticed by eye rather than by
a test, is in `docs/blog_notes.md` under the 2026-07-19 entries. You do not need to read it.

## Status

**Executed 2026-07-19**, in commit "Close the Families-tab prefix-coverage gap". All three steps
landed as written: 8 inseparable prefixes (that screen is now 100% covered, 0 remainder), 22
separable prefixes, and the flat "Other Prefixes" tail section carrying 424 verbs across 184
prefixes. The measured numbers below all reproduced exactly. Four tests in
`KonjugierenTests/Models/BrowseableFamilyTests.swift` now pin the invariant. See the 2026-07-19
entry in `docs/blog_notes.md` for what the execution surfaced, notably an `.xcstrings` round-trip
trap that neither the Edit tool nor `json.dump` avoids.

The rest of this document is kept as the record of why the design is what it is.

**Step 3's design is decided**, not open: one flat "other prefixes" section at the end. Josh
locked it in on 2026-07-19 and the rejected alternatives are recorded with reasons, so that
choice should be inherited rather than re-opened. Steps 1 and 2 are content work and the
judgment there is still yours.

## The defect, measured

`BrowseableFamily.verbsByPrefix` buckets verbs into the hand-curated list in
`PrefixMeaning.swift` — 18 separable prefixes and 7 inseparable ones. A verb whose prefix is not
in that list is **silently dropped from the listing** while still counting in `verbCount`. So
`FamilyBrowseView` prints 2,035 on the Separable card and `FamilyDetailView` then lists 1,245.

Measured against `Verbs.xml` on 2026-07-19, at 3,383 verbs:

| Class | Verbs with a prefix | Covered | Uncovered | Uncovered prefixes |
|---|---|---|---|---|
| Separable | 2,035 | 1,245 | **790** (39%) | 206 |
| Inseparable | 860 | 727 | **133** (15%) | 8 |

**Most of this is new, and the imports caused it.** Before roadmap steps 7 and 8, the uncovered
population was 30 separable verbs across 20 prefixes and 42 inseparable across 8 — a blemish
nobody would notice. The tranches added 760 uncovered separable verbs and 186 new uncovered
prefixes. The inseparable side gained 91 verbs but **zero** new prefixes, which is the single
most useful fact in this document; see below.

Re-derive rather than trusting these numbers. Prose counts in this repo go stale — three
documents claimed 989 verbs well after the corpus reached 990, and one of them shipped that
number to the App Store — so `Konjugieren/Models/Verbs.xml` is the only source of truth. The
convention is `docs/verb-sources.md` § "Verify counts, do not trust them".

To re-derive: read the prefix off the first `<reading>`'s `in` (falling back to the `<verb>`'s),
strip `^`, and take the run before the first `+` or `*`.

## Why the two classes get different treatment

**German's inseparable prefixes are a closed class.** There are about a dozen and no new ones
have entered the language in centuries. The 8 uncovered ones — *über-*, *unter-*, *um-*,
*wider-*, *hinter-*, *voll-*, *an-*, *wieder-* — cover **all 133** uncovered inseparable verbs,
and all 8 were already in use before the imports. Curating them makes that half of the feature
**100% covered and permanently so**: any future tranche of inseparable verbs lands in a bucket
that already exists. Highest value per unit of work in this plan by a wide margin.

**German's separable slot is open class**, and that is not a quirk of this corpus. The slot takes
particles (*weg-*, *nieder-*), but also adjectives (*tot-*, *frei-*, *kaputt-*) and nouns
(*heim-*, *eis-*, *bauch-*) — *teilnehmen* has shipped since the beginning as a noun sitting in a
prefix slot, and nobody noticed because it was curated by hand. 206 uncovered prefixes cover 790
verbs, and 85 of them are singletons. Coverage by curation hits diminishing returns fast:

| Curate the top… | …and you reach |
|---|---|
| 10 | 30% of the missing verbs |
| 20 | 44% |
| 40 | 61% |
| 100 | 84% |

So curation alone cannot close this half, which is why step 3 exists. This is the same lesson
the classifier learned in step 8: a finite list is the wrong shape for an open class. There the
fix was to stop keeping a list at all and read the evidence from the data; here the content
(an etymology per prefix) genuinely has to be written by a human, so the fix is instead to make
the UI stop *hiding* what the list does not cover.

## Step 1 — the 8 inseparable prefixes

Add to `PrefixMeaning.inseparableData`, keeping the array alphabetical as it already is.

| Prefix | Verbs | Examples |
|---|---|---|
| `über-` | 65 | überantworten, überarbeiten, überbewerten |
| `unter-` | 35 | unterbewerten, unterbinden, unterbezahlen |
| `um-` | 13 | umfahren, umfangen, umfassen |
| `wider-` | 8 | widerlegen, widerrufen, widerspiegeln |
| `hinter-` | 6 | hinterfragen, hintergehen, hinterlassen |
| `voll-` | 4 | vollbringen, vollenden, vollführen |
| `an-` | 1 | anerkennen |
| `wieder-` | 1 | wiederholen |

Two of these are worth a moment's thought rather than a rote entry, and both are good material
for the tab:

- **`über-`, `unter-`, `um-`, `wider-` and `wieder-` appear in *both* lists.** They are the
  famous separable/inseparable homograph prefixes, and the meaning genuinely differs with the
  stress: *ÜBERsetzen* (ferry across, separable) beside *überSETZen* (translate, inseparable);
  *UMfahren* (run over) beside *umFAHRen* (drive around). The corpus already encodes both — 12
  verbs take separable `über+` and 65 take inseparable `über*`. The English meaning written for
  the inseparable entry should describe the inseparable sense, and it is worth saying in the
  copy that the same syllable does both jobs, because that is exactly the kind of connection
  this tab exists to surface. `docs/english_writing_style.md` governs the wording, as for any
  English text in this repo.
- **`an-` (1 verb) and `wieder-` (1 verb)** are *anerkennen* and *wiederholen*, each the lone
  inseparable use of a prefix that is otherwise separable. Check both against a dictionary
  before writing a meaning; a single-verb bucket that is actually a data error would be worth
  finding now rather than enshrining.

## Step 2 — the top separable prefixes

Add to `PrefixMeaning.separableData`, alphabetically. Twenty-two candidates, ordered by how many
verbs each unlocks; take as many as the copy holds up for, and stop where the etymology stops
being interesting rather than at a round number.

| Prefix | Verbs | | Prefix | Verbs |
|---|---|---|---|---|
| `durch-` | 48 | | `hinein-` | 12 |
| `weg-` | 48 | | `tot-` | 12 |
| `heraus-` | 27 | | `über-` | 12 |
| `nieder-` | 23 | | `voraus-` | 12 |
| `weiter-` | 21 | | `wieder-` | 11 |
| `herum-` | 17 | | `empor-` | 10 |
| `los-` | 15 | | `heran-` | 10 |
| `heim-` | 14 | | `davon-` | 9 |
| `herunter-` | 13 | | `frei-` | 9 |
| `unter-` | 13 | | `hervor-` | 9 |
| `entgegen-` | 12 | | `hinaus-` | 9 |

Notes on the content, since these are less uniform than the existing eighteen:

- **Several are transparent compounds of prefixes already in the list**: *heraus-* is *her-* +
  *aus-*, *herunter-* is *her-* + *unter-*, *hinein-* is *hin-* + *ein-*, *voraus-* is *vor-* +
  *aus-*. The existing entries for `zurück-` and `zusammen-` already model how to write a PIE
  field for a compound: `"*doh₁ + *(s)krewk"`. Follow that.
- **`tot-` and `frei-` are adjectives, not particles**, and *heim-* is a noun. Saying so in the
  English meaning is more honest than pretending they are directional, and it is the fact that
  makes the separable slot interesting.
- **`weg-` has a genuinely good story**: the noun *Weg* and English *way* are the same word, from
  PIE *\*wegʰ-* "to move, to carry" — which also gives Latin *vehere* and therefore English
  *vehicle*. A verb meaning "away" is literally "by the road".
- **`durch-`** is cognate with English *through* and *thorough*, which are the same word split in
  two by Middle English metathesis.

## Step 3 — stop hiding the remainder

**Decided 2026-07-19: one "other prefixes" section at the end of the list.** Josh chose this over
the two alternatives below; do not re-open it.

After steps 1 and 2 the tail is **424 separable verbs across 184 prefixes**, of which 85 are
singletons and only 24 have five or more verbs. Those numbers decide the section's shape.

**Render it as a single flat section, not 184 sub-headings.** One "Other prefixes" heading, then
every verb in the tail listed alphabetically, using the same `VerbRow` as everywhere else. Giving
each uncurated prefix its own heading — which is what the first draft of this plan proposed —
would put 184 headings above a median of two verbs each, and turn the Separable screen into a
wall of nearly-empty sections. The prefix is already legible in each row, because it is the first
syllable of the infinitive: a reader scanning *wegkommen*, *wegbleiben*, *weglaufen* sees the
grouping without being told.

### The type problem, which is the actual work

`verbsByPrefix` returns `[(prefix: PrefixMeaning, verbs: [Verb])]`, `FamilyDetailView` keys its
`ForEach` on `\.prefix.id`, and `PrefixHeaderView` renders `englishMeaning`, `pie`, and
`pieMeaning`. An uncurated prefix has none of those. So something has to give, and the choice
matters:

- **Do not** make `PrefixMeaning`'s fields optional. It is a content type; every curated entry
  genuinely has all three, and optionality would spread `if let` through a view that is currently
  clean.
- **Do not** synthesize a `PrefixMeaning` with empty strings. That renders an England-flag row
  with nothing after it.

Introduce a heading type instead, and let the view switch on it:

```swift
enum PrefixSection: Identifiable {
  case curated(PrefixMeaning)
  case other                    // the tail, one section, no etymology

  var id: String {
    switch self {
    case .curated(let meaning):
      return meaning.id
    case .other:
      return "__other__"
    }
  }
}
```

`verbsByPrefix` then returns `[(section: PrefixSection, verbs: [Verb])]`, with the curated
sections first in their existing alphabetical order and `.other` appended last — and omitted
entirely when empty, so the inseparable screen (which after step 1 has no tail) does not grow a
stray heading. `PrefixHeaderView` switches: `.curated` renders exactly what it renders today,
`.other` renders a localized "Other prefixes" title with the same `.title2.bold()`,
`.customYellow`, and `.isHeader` treatment and no flag or horse rows.

That title needs a new `L` accessor and a `Localizable.xcstrings` key in both languages, per the
conventions in `CLAUDE.md`. It is the only new user-facing string in this step.

### What this must satisfy

`verbCount` and the sum of the displayed sections have to agree, for both `.separable` and
`.inseparable`. That is the whole point of the step, and it belongs in a test — see Verification.

### The alternatives, recorded so they are not re-litigated

- **Derive the prefix list from the corpus and attach meanings where they exist.** More
  principled, and future tranches would integrate themselves. Rejected because it yields ~180
  headings with nothing beneath them, which reads as unfinished rather than as complete — the
  same wall of empty sections that decided the flat-list question above.
- **Leave the listing curated and just fix the count** by showing the curated total on the family
  card. Cheapest, and it does remove the contradiction. Rejected because it makes the omission
  permanent and invisible, which is precisely how this defect survived unnoticed until Josh
  spotted it by eye.

## Facts you need that are not obvious from the code

- **`PrefixMeaning` has three fields and only one of them is localized.** `prefix` (`"ab-"`,
  with the trailing hyphen) and `englishMeaning` are inline Swift strings; `pie` is the root
  itself (`"*h₂epó"`). The localized part is `pieMeaning`, which builds the key by dropping the
  final character: `"über-"` → `String(localized: "PIEMeaning.über")`. Umlauts in keys are fine —
  `PIEMeaning.zurück` already ships. There are 25 such keys today, one per entry, each with a
  `de` and an `en` value. **Adding an entry without adding its key yields a row rendering the
  raw key**, since `String(localized:)` falls back to the key.
- **`Localizable.xcstrings` edits have a trap.** Read the "Editing Localizable.xcstrings Safely"
  section of `CLAUDE.md` before touching it: the Edit tool operates on rendered text, so any
  edit that adds or changes an ASCII double quote silently breaks the JSON. Use Python for those,
  and validate with `python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"`
  afterward regardless of how the edit was made.
- **A verb buckets by its *outermost* prefix only.** `Reading.prefix` returns `prefixes.first`,
  so `auf+be*wahren` has prefixes `[.separable("auf"), .inseparable("be")]` and appears under
  separable `auf-`, never under inseparable `be-`. That is the right call for browsing and it is
  why the two class totals do not double-count, but it means a double-prefix verb's inner prefix
  is unreachable from this screen. Do not "fix" that as part of this pass.
- **The array order is the display order.** Both `separableData` and `inseparableData` are
  alphabetical today and `verbsByPrefix` preserves that order; insert accordingly.
- **`PrefixHeaderView` renders three lines**: the prefix in title2 bold, an England-flag row with
  `englishMeaning`, and a horse row with `pie` in italics followed by `• pieMeaning`. The flag and
  horse are custom image assets, per the emoji convention in `CLAUDE.md`. Nothing needs changing
  there for steps 1 and 2.

## Verification

- `python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"` after
  every catalog edit.
- Build and run the suite via the `ios-build-verify` skill; see `CLAUDE.md`.
- **Write the coverage test first, before any of the three steps.** For `.separable` and
  `.inseparable`, the sum of the displayed sections' verb counts must equal `verbCount`. It fails
  by construction today — by 790 and 133 — and it is the only check that actually pins the defect
  this pass exists to fix. Steps 1 and 2 will move it without closing it; step 3 closes it. Do not
  write it last as a formality.
- **Add a test that every `PrefixMeaning` entry resolves its `PIEMeaning.*` key**, i.e. that
  `String(localized:)` does not hand back the key itself. Steps 1 and 2 add up to thirty entries
  each needing a catalog key in two languages, and a missed one is invisible until someone opens
  that exact section and reads `PIEMeaning.durch` in the UI.
- **A verb may appear in exactly one section.** Worth asserting alongside the count test, since
  the `.other` bucket is defined by exclusion and an off-by-one in the predicate would either
  duplicate or drop verbs without changing the total in an obvious way.
- **Skip the classify-and-verify pipeline.** That is the three-stage check every verb-data change
  in this repo has to run (`docs/roadmap.md` § "The one check that runs through all of it"), and
  it guards a count of shipping verbs that disagree with Wiktionary — currently 8. Nothing in this
  pass touches `Verbs.xml`, `Conjugator`, or an ablaut group, so that count cannot move. Running
  it anyway costs 90 seconds and teaches the habit of performing rituals that do not apply.
  Verify by screenshot instead: `scripts/take_screenshots.sh` and `docs/screenshot-playbook.md`,
  or the `ios-build-verify` skill's verify half against the Families tab.

## What this pass is not

Not a verb import, and not a `Conjugator` change. If you find yourself editing `Verbs.xml`,
stop — a prefix that looks wrong in a browse listing is a data question for
`docs/roadmap.md`'s step 8b, not for this pass. Record it there and carry on.

Commit directly to `main`, and append a narrative entry to `docs/blog_notes.md` as you go.
