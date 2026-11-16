The time has come to create Konjugieren's App Store screenshots. Many are required. What follows is Josh's plan for creating those.

There are nine categories of screenshot:

1: VerbBrowseView: show verbs sorted by frequency of use, with sein on top; DARK
2: VerbView: show conjugation of werden; LIGHT
3: FamilyBrowseView: show this screen with Strong on top; DARK
4: FamilyDetailView: show Strong; LIGHT
5: QuizView: show quiz in progress with correct, proposed answer typed; randomness is fine; ensure that virtual keyboard is visible; DARK
6: InfoBrowseView: show screen slightly scrolled so that "A History of the German Verb System" is at top; LIGHT
7: InfoView: show Präsens Indikativ screen; DARK
8: ResultsView: show quiz results with a score, elapsed time, and per-question review visible; LIGHT
9: SettingsView: show settings screen with as many pickers visible as possible; DARK

Create iPhone 6.9" screenshots using iPhone 17 Pro Max simulator. Create iPad 13" screenshots using iPad Pro 13-inch (M4) simulator.

> **On the iPad sim name (2026-08-01).** Xcode 26 splits each iPad Pro into RAM variants, so
> the device-type id carries a suffix — `…iPad-Pro-13-inch-M4-8GB`, not `…iPad-Pro-13-inch-M4`
> — and only that variant gets the plain `iPad Pro 13-inch (M4)` name the driver matches (the
> 16 GB one is named `… (16GB)`). A fresh Xcode install seeds an **M5** instead. An M5 is an
> equivalent substitute if the M4 is ever unavailable: same 13-inch geometry, same
> **2064 × 2752** capture, same App Store slot — the sibling app Conjugar moved to
> `iPad Pro 13-inch (M5)` that day. It is not a drop-in for the *driver*, though: the device
> name appears in six `case` arms (`DEVICES`, `tab_coords_for`, `wait_budget_for`,
> `keyboard_is_visible`, `set_keyboard_state`, `dismiss_review_prompt`), and an arm that
> misses just falls through to its `*)` default and fails somewhere far away.


Create all screenshots with the iPhone and iPad running in both English and German modes.

The end product is thirty-six screenshots.

## Alpha channels

`axe screenshot` writes **RGBA**, and App Store Connect rejects any screenshot carrying an
alpha channel: "Images can't include alpha channels or transparencies."
`scripts/take_screenshots.sh` now flattens each capture immediately, so a fresh sweep is
compliant.

**The rejection is about the channel, not about transparency.** Sibling app Conjuguer's
rejected captures were fully opaque — max alpha at every pixel — and were refused anyway.
Apple isn't inspecting content; it refuses any file whose *format* admits transparency,
which is why this stays invisible until upload. Check with
`magick 1.png -alpha extract -format '%[min],%[max]' info:`.

**Everything shot before 2026-07-25 is not compliant.** Of `version_2`'s 40 files, the **36
driver-produced ones are RGBA**; only the four hand-made `10.png` slots are RGB — which
neatly identifies the driver as the source. Flatten any old bundle before reuse:

```bash
magick in.png -background white -alpha remove -alpha off out.png
```

Then check the whole bundle at once:

```bash
scripts/verify_store_media.sh docs/screenshots/version_<N>
```

## Before shooting: confirm which slot App Store Connect is offering

App Store Connect's version page shows **one tile per device family**, and which display
size that tile accepts depends on what the app shipped previously — not on what's current.
Konjugieren has been lucky here: `version_2`'s 1320 × 2868 (6.9") and 2064 × 2752 (13")
captures matched the tiles it was offered.

The sibling app Conjuguer was not. Its 2.0 page offered only an **iPhone 6.5" Display**
tile, because 1.5 had shipped 6.5", and rejected 1320 × 2868 uploads that are a perfectly
valid App Store size.

**The fix, and the recommended path here too: use Media Manager and keep native sizes.**
**View All Sizes in Media Manager** exposes every display size regardless of which single
tile the version page shows. Conjuguer 2.0 shipped that way, its native 6.9" and 13"
captures accepted unchanged — no downscaling, no regenerated bundle. Try that before
reaching for either recipe below.

Fallbacks, if a tile has to be filled directly:

- To fill a **6.5"** tile:

  ```bash
  # 1320 × 2868 → 1284 × 2778, alpha stripped
  magick in.png -background white -alpha remove -alpha off \
    -resize 1284x -gravity center -crop 1284x2778+0+0 +repage out.png
  ```

- To fill a **12.9"** iPad tile rather than 13":

  ```bash
  # 2064 × 2752 → 2048 × 2732, alpha stripped
  magick in.png -background white -alpha remove -alpha off \
    -resize x2732 -gravity center -crop 2048x2732+0+0 +repage out.png
  ```

Both recipes scale on the axis that leaves the target size *inside* the scaled image and
center-crop the remainder — 12 px for the iPhone, 1 px for the iPad — rather than
stretching to fit.