# Screenshot Automation Step 3 — Questions

Questions raised by the fresh session that's about to author `scripts/take_screenshots.sh` and run the capture sweep. Read alongside `screenshot-automation-step3-handoff.md`. Numbered for easy reply.

The handoff and the supporting docs (original handoff, Step-2 answers, calibration values, ScreenshotPlan) are unusually thorough; most of the design is pinned down. Below are the items that genuinely call for a Josh decision before the driver lands, plus a few small implementation unknowns.

## Tier 1 — small policy calls that affect the driver shape

### Q1. Build cadence: once, or per device?

The original handoff's bash skeleton has `build_app` **inside** the `for DEVICE` loop:

```bash
for DEVICE in "${DEVICES[@]}"; do
  ensure_simulator "$DEVICE"
  apply_tab_coords "$DEVICE"
  build_app
  install_app
  ...
```

But the Step-2 answers say "don't mutate `.claude/ios-build-verify.config.sh`" and the config still holds `TARGET_SIM='iPhone 17'`. Since iPhone and iPad simulator builds share architecture (arm64 simulator), one build can be installed on both sims via `simctl install <UDID> <.app path>`.

**Options:**

- **(a) Build once outside the device loop**, then `simctl install` per device. Saves ~2 min per run. Works because the simulator `.app` is sim-architecture, runtime-agnostic.
- **(b) Build per device** as the original skeleton suggests, accepting the duplicated build cost. More conservative if any per-device codepath ever diverges.

I'd default to **(a)** unless you want belt-and-braces. Either way, I'll skip running the test suite — that's a separate verification step, not part of the screenshot sweep.

### Q2. Output filename timestamp granularity

Handoff says output goes to `docs/screenshots/<timestamp>-<device>-<lang>-<view>.png`. Two ways to read `<timestamp>`:

- **(a) One timestamp per run** (`20260508-143022-iPhone-17-Pro-Max-en-verb_browse.png`) — all 36 PNGs from a single sweep share a prefix, so they sort/group together for visual review.
- **(b) Per-shot timestamp** — each PNG gets its own. `screenshot.sh` may already do this internally, in which case we just feed the base name and let the script prepend its own timestamp.

I'd default to **(a)** if I'm building the filename, or accept whatever `screenshot.sh` already prepends if it owns the timestamp. Will check `screenshot.sh`'s actual output convention before authoring the driver.

### Q3. Pre-existing `docs/screenshots/` content

The calibration session left ~10 PNGs under `docs/screenshots/` (e.g., `*-tabbar-measure.png`, `*-iphone-info-postscroll-117-slow.png`). They're gitignored, so no commit pollution, but they make visual review of the new 36 noisier.

**Options:**

- **(a) Leave as-is.** New sweep filenames are unambiguous (have all of device+lang+view); old calibration artifacts don't collide.
- **(b) Move calibration artifacts to a `docs/screenshots/_calibration/` subdir** for archival.
- **(c) Clear `docs/screenshots/` at run start** — lossy but tidy.

I'd default to **(a)**: leave alone, accept the noise during review. The calibration artifacts may be useful reference if a re-calibration is needed later.

## Tier 2 — confirming the calibration values match your intent

The Step-2 calibration session measured two screens where the resulting `SCROLL_PX = 0` differs from a strict reading of the spec. Both are deliberate choices logged in `screenshot-calibration-values.md`. Surfacing them here so you can override before I run the sweep:

### Q4. Screen 6 (InfoBrowseView) on iPad — `SCROLL_PX = 0`

**Spec says:** "show screen slightly scrolled so that 'A History of the German Verb System' is at top."

**Calibration says:** iPad = 0pt scroll. Reasoning (from calibration doc): regular size class fits all entries comfortably at natural position with verbHistory visible (iPad shows 14+ entries in the natural scroll position).

The compromise: on iPad we show the dedication row at top with verbHistory visible below, rather than scrolling verbHistory to the very top. Confirm this is acceptable, or do you want me to bump iPad's value (calibration didn't try) so verbHistory sits at the top edge?

### Q5. Screen 3 (FamilyBrowseView) on iPhone — `SCROLL_PX = 0`

**Spec says:** "show this screen with Strong on top."

**Calibration says:** iPhone = 0pt. Reasoning: max scroll on this screen is ~52pt — enough to collapse the large-title navigation but not enough to put Strong at the top. The calibration session chose to keep the large-title state for aesthetics rather than the half-collapsed mid-state.

iPad is also 0pt because the 2-column grid shows Strong without any scrolling needed.

Confirm the iPhone large-title state matches your intent, or would you rather have the half-collapsed-title state (it's the only other option short of redesigning the screen).

## Tier 3 — implementation unknowns I'll resolve by reading scripts, but flagging in case you have a preference

### Q6. Return-key submission for quiz answers

Screen 8 (Results) needs to type 30 answers, each followed by Return to submit. The TextField uses `.submitLabel(.go)` and an `onSubmit` handler. The skill's `type_text.sh` likely doesn't include a Return mechanism. Options I'll investigate:

- `axe key return` (or equivalent) — if axe exposes key events
- `axe type --text "answer\n"` — if axe interprets `\n` as Return
- Tap the on-screen keyboard's Return key via `tap_xy` (fragile — depends on keyboard layout, language, theme)

I'll prototype the cleanest available approach and report what works. No action needed from you unless you already know which mechanism this codebase has used elsewhere.

### Q7. Per-screen `verify_screen_loaded` calls

The handoff explicitly calls for `verify_screen_loaded results_score` after the 30-answer loop on screen 8 (Results), since the sheet animates in asynchronously. For the other 8 screens, the navigation is synchronous-ish (a tap → a screen) and the screenshot follows immediately.

**Options:**

- **(a) Verify only screen 8** as the handoff prescribes. Trust the other navs.
- **(b) Add `verify_screen_loaded` for each screen's anchor identifier.** More robust but requires confirming an anchor for each (we have `verb_browse_anchor`, `results_score`; would need new anchors on `VerbView`, `FamilyDetailView`, `InfoView`, `SettingsView`).

I'd default to **(a)** since (b) would require a Step-1-style additions pass. The 20s render budget on iPad's first launch already covers the slowest case (verbBrowse with 990 verbs).

---

## Suggested defaults summary

If you'd rather just sign off without a long reply, the defaults I'd ship are:

- Q1: **(a)** — one build, install per device.
- Q2: defer to `screenshot.sh`'s convention; if it owns the timestamp, accept whatever it produces.
- Q3: **(a)** — leave existing calibration PNGs alone.
- Q4: accept iPad SCROLL = 0 with verbHistory visible below dedication.
- Q5: accept iPhone SCROLL = 0 with large title intact.
- Q6: investigate, report back what works.
- Q7: **(a)** — verify only screen 8.

A "go with all defaults" is enough; otherwise flag the ones you want to revisit.
