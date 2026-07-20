# Close the prefix-coverage gap in the Families tab

## Status

**Not executed.** Written 2026-07-19, immediately after the step-8 import that caused most of
the gap. Nothing here is urgent — no verb is missing or wrong, and no test fails. What is wrong
is that 923 verbs the app conjugates correctly cannot be reached by browsing prefixes, and the
Families tab shows a count that its own detail screen contradicts.

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

Re-derive rather than trusting these numbers, per the house rule. Read the prefix off the first
`<reading>`'s `in` (falling back to the `<verb>`'s), strip `^`, and take the run before the first
`+` or `*`.

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

After steps 1 and 2 the separable tail is still several hundred verbs across ~180 prefixes, and
no amount of further curation closes an open class. The listing must stop silently dropping
them.

Three designs, in the order I would try them:

1. **An "other prefixes" group at the end of the list.** `verbsByPrefix` gains a final bucket
   holding every verb whose prefix matched no `PrefixMeaning`, grouped and sorted by the prefix
   string, with the prefix shown as a plain heading and no etymology block. Smallest change,
   preserves the curated content as the primary experience, and the count stops lying.
2. **Derive the prefix list from the corpus and attach meanings where they exist.** `PrefixMeaning`
   becomes a lookup rather than the source of the list. More principled and it makes future
   tranches self-integrating, but it means a heading with no meaning beneath it for ~180
   prefixes, which may read as unfinished rather than as complete.
3. **Leave the listing curated but fix the count.** Show the curated total on the family card
   instead of `verbCount`. Cheapest, and it removes the contradiction — but it makes the omission
   permanent and invisible, which is how this got here.

I would take (1). It is the only one that both tells the truth and keeps the curated etymologies
feeling like the point of the screen.

Whichever is chosen, **`verbCount` and the sum of the displayed buckets must agree**, and that
belongs in a test rather than in a reviewer's memory.

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
- **Add a test that the buckets and the count agree.** Something like: for `.separable` and
  `.inseparable`, the sum of `verbsByPrefix` bucket sizes equals `verbCount`. Before step 3 that
  test fails by construction, which is the point — write it first and let it drive the design.
  A second test asserting every `PrefixMeaning` entry has a resolving `PIEMeaning.*` key (that
  `String(localized:)` does not return the key itself) would have caught the whole class of
  omission this pass is about.
- The classify-and-verify pipeline is **irrelevant here** — nothing in this pass touches
  `Verbs.xml`, `Conjugator`, or an ablaut group. Do not spend the 90 seconds; the at-odds count
  cannot move. Verify by screenshot instead: `scripts/take_screenshots.sh` and
  `docs/screenshot-playbook.md`, or the skill's verify half against the Families tab.

## What this pass is not

Not a verb import, and not a `Conjugator` change. If you find yourself editing `Verbs.xml`,
stop — a prefix that looks wrong in a browse listing is a data question for
`docs/roadmap.md`'s step 8b, not for this pass. Record it there and carry on.

Commit directly to `main`, and append a narrative entry to `docs/blog_notes.md` as you go.
