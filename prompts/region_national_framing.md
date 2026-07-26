# Reframe the Region setting around national standards, and give the north a bare flag

## Status

**Planned, not started.** Decided by Josh on 2026-07-26, during the 1.3 release-copy pass.
**Implement only. Do not run the screenshot driver.** Josh is routing the redo to the session
that already has the simulator warm and the sweep workflow loaded. Hand off when the code is
verified; the "Screenshots" section at the end is a briefing for that session, not a step for
you.

**Blocked by the emoji-asset work in flight as of 2026-07-26.** A second session is adding
German, Austrian, and Swiss flag imagesets, the `EmojiAsset` mappings for them, and a
`regionSegment(for:)` helper in `SettingsView` that renders a mapped emoji as an image. None of
that exists in `main` as of this writing. **Do not start until it has landed**, and read the
current values out of the catalog rather than trusting the "from" column below.

## Why

The Region picker currently reads **North** / 🇦🇹 / 🇨🇭. That is asymmetric in a way that
encodes a claim the app elsewhere contradicts.

Two strings render on the same `VerbView` screen, one directly beneath the other:

| String | Says |
|---|---|
| `auxiliaryPillText` (`VerbView.swift:286`) | `hat 🇩🇪  ·  ist 🇦🇹🇨🇭` |
| `Region.southernNote` | "Duden labels the Perfekt with sein (ist gestanden) southern German, Austrian, and Swiss." |

Read as claims about **speakers**, those contradict each other: the pill puts all of Germany
on *hat*, and the note puts southern Germany on *ist*. `Region.auxiliaryVariesLabel` sides with
the pill ("sein in Austria and Switzerland"), dropping the "southern German" that
`southernNote` includes, and `Region.regionalAuxiliary`'s doc comment repeats the elision.
`Region.seeded(from:)` completes the problem by mapping every non-AT, non-CH locale, `DE`
included, to `.north`, so a Munich user is seeded into a variety the app itself tells them is
wrong for their speech.

Read as claims about **codified national standards**, they are both true and complementary:
the German standard prescribes *hat gestanden*, the Austrian and Swiss standards admit *ist
gestanden*, and intra-German variation is a separate fact that the setting description
explains. Nothing in the modeling changes. Only what the labels are understood to denote.

Josh's decision: adopt the national-standard reading explicitly, in the setting description,
and then make the picker symmetric. Once 🇩🇪 denotes a national standard the way 🇦🇹 and 🇨🇭
already do, **North** is the odd element, because it names a direction where the other two name
nations. Three bare flags is the consistent result.

There is a second, purely practical payoff, and `docs/emoji-assets.md` is the authority on it:
`SegmentedPickerStyle` renders one plain `Text` or one plain `Image` per segment and silently
drops image attachments inside a `Text`, so a segment **cannot** pair a word with a flag at all.
Austria and Switzerland went flag-only for that reason, and the north kept `North 🇩🇪` only until
the same constraint took its flag away too. Label length has now caused trouble twice, most
recently when simulator tofu doubled each flag's width and truncated `North 🇩🇪` to `North…`.
Three bare flags is the one arrangement every segment can actually represent, and it retires the
truncation risk and the label translation along with it.

## The naming problem this sidesteps

Recorded because a future session will otherwise re-litigate it. Every available name for the
German national standard is compromised somewhere:

- **North** is not a cognizable region, and it names a direction rather than a nation.
- **German** collides with the language name, which is why the current English description
  reads "German, Austrian, and Swiss are all codified standards" and lands oddly.
- **Standard German** is the *superordinate* term (`Standarddeutsch` / `Hochdeutsch`) covering
  all three national standards. Using it for one of them demotes the other two, which inverts
  the exact point the sentence exists to make.
- **German Standard German** is the established English term in the pluricentricity literature,
  alongside Austrian Standard German and Swiss Standard German. It is precise and it reads as a
  typo on a Settings screen.
- **Bundesdeutsch** is the German-language term already used in this catalog, and it is not
  neutral either: it is built on *Bundesrepublik*, so it cannot predate 1949, and it carried an
  unspoken contrast with the DDR for its first forty years.

The fix is structural rather than lexical. Factor the noun out so all three become parallel
adjectives ("the German, Austrian, and Swiss standards"), and let the flag carry the naming.

## What changes

Four strings and two comments. **No Swift logic changes at all**, for the reason in step 1.

### 1. `Region.north` becomes a bare flag

`Konjugieren/Assets/Localizable.xcstrings`:

| Key | Locale | To |
|---|---|---|
| `Region.north` | `en` | `🇩🇪` |
| `Region.north` | `de` | `🇩🇪` |

**Read the current value before editing.** It has been two different things this week, and which
one you find tells you whether the blocking work has landed:

| If `Region.north` reads | Then |
|---|---|
| `North 🇩🇪` / `Nord 🇩🇪` | The emoji-asset work has **not** landed. Stop and wait. Without `regionSegment(for:)` the segment is a plain `Text`, and a bare 🇩🇪 there renders as two tofu boxes **in the simulator**. It would look correct on a physical device, so the damage would show up only in the App Store screenshots, which is precisely where it matters. See `docs/emoji-assets.md`. |
| `North` / `Nord` | The emoji-asset work **has** landed. Proceed. |

Once it has landed, this is the entire change and it requires no Swift, because the machinery is
then in place:

- `SettingsView.regionSegment(for:)` branches on `EmojiAsset.assetName(for: region.localizedRegion)`,
  rendering an `Image` when the localized value is a mapped emoji and a `Text` otherwise.
- `EmojiAsset.assetNames` in `Konjugieren/Views/RichTextView.swift` maps `\u{1F1E9}\u{1F1EA}`
  to `"EmojiGermanFlag"`.
- `Konjugieren/Assets/Assets.xcassets/EmojiGermanFlag.imageset` exists.

Confirm all three before editing the string; if any is missing, the blocking work is incomplete.
`.north` will then take the image branch automatically, exactly as `.austria` and `.switzerland`
do. The flags are images rather than emoji because iOS 26 renders regional-indicator pairs as
tofu; see `docs/emoji-assets.md`. Do not "simplify" the segment back to a `Text`.

VoiceOver is unaffected by construction: the image branch sets
`.accessibilityLabel(Text(verbatim: region.localizedRegion))`, so the label becomes the 🇩🇪
character and VoiceOver says "flag of Germany", matching what it already says for the other two.

### 2. `Settings.regionDescription` gains a sentence and loses its odd apposition

**English, from:**

> This setting determines which standard variety of German the app shows. German, Austrian, and Swiss are all codified standards, not dialects.

**English, to:**

> This setting determines which standard variety of German the app shows. The German, Austrian, and Swiss standards are all codified, not dialects. Southern German usage often follows the Austrian and Swiss standards rather than the German one.

**German, from:**

> Diese Einstellung bestimmt, welche Standardvariante des Deutschen die App anzeigt. Bundesdeutsch, österreichisch und schweizerisch sind allesamt kodifizierte Standards, keine Dialekte.

**German, to:**

> Diese Einstellung bestimmt, welche Standardvariante des Deutschen die App anzeigt. Der bundesdeutsche, der österreichische und der schweizerische Standard sind allesamt kodifiziert, keine Dialekte. Der süddeutsche Sprachgebrauch folgt oft dem österreichischen und schweizerischen Standard statt dem bundesdeutschen.

Three things this wording is doing deliberately, all of which a later editor might undo:

- **"The German, Austrian, and Swiss standards"** factors the noun out so "German" sits in the
  same grammatical slot as "Austrian" and "Swiss" instead of competing with the language name.
- **The third sentence guides rather than merely discloses.** An earlier draft read "Usage in
  southern Germany differs from the national standard." That version tells a Munich user the
  app does not quite cover them and offers no remedy, and "the national standard" re-demotes
  the other two standards. The shipped version tells them which of the three options actually
  matches their speech.
- **`süddeutsch` stays lowercase**, matching `Region.southernNote`'s existing „süddeutsch,
  österreichisch und schweizerisch" and Duden's own label.

The opening clause must stay, per CLAUDE.md: setting descriptions begin with "This setting
determines...".

### 3. `Region.auxiliaryVariesLabel` adopts the same framing

| Locale | From | To |
|---|---|---|
| `en` | `haben in the northern standard; sein in Austria and Switzerland` | `haben in the German standard; sein in the Austrian and Swiss standards` |
| `de` | `haben im norddeutschen Standard; sein in Österreich und der Schweiz` | `haben im bundesdeutschen Standard; sein im österreichischen und schweizerischen Standard` |

This is the string that currently elides southern Germany. Under national framing the elision
disappears without needing a caveat, because the sentence is no longer making a claim about
speakers at all. This is the VoiceOver label for the `VerbView` auxiliary pill, so it is spoken
rather than seen; length is not a layout constraint here.

### 4. Two comments

- **`Konjugieren/Views/SettingsView.swift:275-278`** currently ends "...which is why North shows
  its word alone while Austria and Switzerland show their flag alone." That asymmetry is what
  this plan removes, so the clause is now false. Keep the iOS 26 tofu fact, which stays
  load-bearing, and drop the asymmetry explanation.
- **`Konjugieren/Models/Region.swift`, `regionalAuxiliary`** reads "Austria and Switzerland say
  *ist gestanden* where the northern standard says *hat gestanden*." Reframe to standards, and
  state the modeling boundary outright, because it is the thing the next reader will get wrong:
  the enum models three codified national standards, not three speech communities, and southern
  Germany patterns with Austria and Switzerland on this feature without being a fourth case.

## What must not change

- **Do not rename the `north` case.** `Region` is `String`-raw-valued, and `Settings.swift:38`
  persists it as `getterSetter.set(key: Settings.regionKey, value: "\(region)")`, so the stored
  UserDefaults value is the literal string `"north"`. Renaming the case to `germany` orphans
  every existing user's stored choice; `restore` would fall through to
  `Region.seeded(from: Locale.current)` and silently re-seed them. The case name is internal and
  invisible; the label is what this plan is about. If a rename is ever wanted, it needs a
  migration, and it is not in scope here.
- **Do not merge `Region.flag` and `Region.localizedRegion`.** After this change they return the
  same string for all three cases, which will look like duplication. They cannot merge:
  `flag` is `nonisolated` and `localizedRegion` is not, because it routes through `L.*`, which
  is `@MainActor` via `String(localized:)`. `VerbView`'s `auxiliaryPillText` needs the
  nonisolated one. See CLAUDE.md § "Swift 6 and Default Main-Actor Isolation".
- **Do not touch `docs/description.md`.** The App Store copy says "North Germany, Austria, and
  Switzerland" and "Norddeutschland, Österreich und Schweiz" by Josh's decision on 2026-07-26.
  The App Store line has no `regionDescription` sitting beneath it to do the disambiguating
  work, so it carries the geographic qualifier that the in-app picker no longer needs. Both
  language sections are within about 25 characters of Apple's 4,000-character cap; any edit
  there must be measured, not eyeballed.
- **Do not add a fourth region for southern Germany.** Linguistically it is the most correct
  model and it is a real roadmap candidate, but it changes `Region`, `regionalAuxiliary`, the
  seeding logic, `RegionalRendering`, every call site, and the picker's segment count. Out of
  scope for a pre-release change.

## Editing `Localizable.xcstrings` safely

All four values above are free of ASCII double quotes (`"`, U+0022), so per CLAUDE.md § "Editing
Localizable.xcstrings Safely" the Edit tool is safe here and Python is not required. The German
`süddeutsch` sentence uses no quotation marks either. Validate anyway:

```bash
python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"
git diff --stat Konjugieren/Assets/Localizable.xcstrings   # small, balanced; no mass reformat
```

A large balanced insertion/deletion count means the file was round-tripped through
`json.load` + `json.dump`, which reformats all ~5,400 lines. Revert and redo with targeted edits.

## Verification

1. **Build and full suite.** `"$IBV_SCRIPTS/build_app.sh"` then `"$IBV_SCRIPTS/run_tests.sh"`.
   Nothing should break: the only `Region` assertions live in `StringExtensionsTests`'
   `Regional Orthography` sub-suite, and they cover the ß transform and
   `Region.seeded(from:)`, never the display labels.
2. **Look at the picker.** Launch and go to Settings; Region is the third section, so it is
   visible without scrolling. Confirm three flag images, evenly weighted, none showing tofu
   (`􀀁`-style boxes or a pair of letters). Tofu means the `EmojiAsset` lookup missed and the
   `Text` fallback ran, which would mean the catalog value is not exactly `\u{1F1E9}\u{1F1EA}`.
3. **Read the description underneath it** in both languages, since it is now three sentences
   and the card may reflow.
4. **VoiceOver spot-check** on the picker: "flag of Germany", "flag of Austria", "flag of
   Switzerland". Then on a regional verb (*stehen*, *sitzen*, *liegen*, or a prefixed
   derivative such as *aufstehen*), confirm the auxiliary pill speaks the new
   `auxiliaryVariesLabel` rather than reading the flags out mid-verb.

## Screenshots

**For the screenshot session, not the implementing one.** Only the `settings` cells change, so
this is four of the thirty-six, which is 2 devices by 2 languages. Not two: 36 shots over 9
views is 4 per view, and redoing only the iPhone pair leaves the iPad pair stale in a way that
survives review because nobody opens them side by side.

```bash
scripts/take_screenshots.sh --view settings   # 4 cells: 2 devices x 2 languages
```

Two things to get right first, both from [`docs/screenshot-playbook.md`](../docs/screenshot-playbook.md):

- **Flip the three kill switches in `Konjugieren/Models/KonjugierenTips.swift` to `false`
  before running, and restore them after.** They are compile-time constants and the driver
  builds once at start. As of 2026-07-26 that file was already modified in another session's
  working tree, so check its actual state rather than assuming `true`, and finish with
  `git diff --stat Konjugieren/Models/KonjugierenTips.swift` empty.
- The `settings` cell is view #9, dark appearance, `tap_tab settings`, **no scroll on either
  device**. That is why the Region picker lands in frame at all, and why this change requires a
  redo.

Then refresh `docs/screenshots/latest/` and the numbered upload bundle per the playbook's
"Outputs" section, where `settings` is `n=9`.

## Journal

Append to `docs/blog_notes.md` per CLAUDE.md. The entry worth writing is not the diff, which is
four strings, but the reframing: the same pixels went from contradicting an adjacent string to
complementing it, purely by changing what the flags were understood to denote, and the change
that made it defensible was a sentence in a setting description rather than anything in the
picker.
