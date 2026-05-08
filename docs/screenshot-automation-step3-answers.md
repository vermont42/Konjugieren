# Screenshot Automation Step 3 — Answers

Answers to [`screenshot-automation-step3-questions.md`](screenshot-automation-step3-questions.md), authored by the Step-2 session that produced the calibration values. Same numbering as the questions doc.

The Step-3 session's reasoning on most of these is correct; this doc mostly confirms defaults and adds a couple of small clarifications.

## Tier 1 — driver-shape policy

### Q1. Build cadence: **(a) — build once outside the device loop.**

Architecturally safe. Both target sims (iPhone 17 Pro Max, iPad Pro 13-inch M4) run the same simulator architecture on this host (verified during Step-2: build output showed `x86_64-apple-ios-simulator.swiftmodule` — Intel-Mac host per CLAUDE.md's "Tutor host-eligibility" note). The same `Konjugieren.app` bundle in `Build/Products/Debug-iphonesimulator/` installs to both sims via `xcrun simctl install <UDID> "<.app path>"`.

Save the ~2 min, build once. Confirmed not running tests during the sweep — that's a separate operation; the existing test suite already passed during Step 2.

### Q2. Output filename timestamp: **defer to `screenshot.sh`.**

`screenshot.sh` prepends `YYYYMMDD-HHMMSS-` to whatever base name you pass. Verified during Step-2 — calibration screenshots like `20260508-110752-iphone-families-prescroll.png` follow this convention. Pass a clean base name (e.g., `iPhone-17-Pro-Max-en-verb_browse`) and let the script own the timestamp.

A 36-shot sweep finishes in ~10–15 minutes per device, so all PNGs from one device's pass share the same `YYYYMMDD-HH` prefix and sort/group naturally. No need to override.

### Q3. Pre-existing calibration PNGs: **(a) — leave as-is.**

The new 36 PNGs use a clear `<device>-<lang>-<view>.png` naming convention. The calibration artifacts (`*-tabbar-measure.png`, `*-iphone-info-postscroll-117-slow.png`, etc.) have unambiguous calibration-style names that won't collide with sweep filenames. Visual review will be slightly noisier with both kinds present, but readable.

Cleanup happens at Step-4 close-out, alongside the four handoff/answers/questions/calibration docs that all get deleted together.

## Tier 2 — calibration-value confirmations

### Q4. iPad InfoBrowseView `SCROLL_PX = 0`: **confirmed; ship as 0.**

Reasoning recorded in `screenshot-calibration-values.md` Finding #note: iPad's regular size class shows ~14 Info entries naturally. Pushing the dedication row off-screen via scroll would lose the Cliff Schmiesing photo + "this app is dedicated to my grandfather…" context — that personal note carries marketing weight for an App Store screenshot.

If you ever want to override: the calibration math says scrolling iPad's Info by ~87pt would put `info_row_verb_history` heading at y=150 (vs. y=237 natural). Slow drag, duration 1.0s, gesture from (200, 400) to (200, 313). But default to the documented value of 0.

### Q5. iPhone FamilyBrowseView `SCROLL_PX = 0`: **confirmed; ship as 0.**

The 52pt max-scroll only collapses the large "Families" title — it doesn't actually feature Strong at top. So the choice is between two readable states: large-title-expanded (default) or large-title-collapsed-with-rows-shifted-up-52pt. The expanded state is the more idiomatic iOS aesthetic; the half-collapsed state isn't a meaningful improvement. The 0 value preserves the more visually distinctive layout.

If you want the alternative someday, set `SCROLL_PX_FAMILY_BROWSE iPhone = 52` (slow drag, 1.0s) — but I'd advise against unless you've seen the expanded state and decided otherwise.

## Tier 3 — implementation unknowns

### Q6. Return-key submission: **try `axe key` first; fallbacks if needed.**

The Step-2 session dumped `axe --help` and saw these subcommands relevant to keyboard input:

```
key             Press a single key by keycode on the simulator.
key-sequence    Press a sequence of keys by their keycodes on the simulator.
key-combo       Press a key while holding one or more modifier keys on the simulator.
type            Type text by entering a sequence of characters.
```

So `axe key` exists. The Return key on iOS is HID keycode `0x28` (USB HID standard "Keyboard Return") or `40` decimal. Run `axe help key` to see exact syntax — likely `axe key 40 --udid <UDID>` or `axe key --keycode 0x28 --udid <UDID>`.

If `axe key` works: this is the cleanest path — independent of keyboard layout, language, or theme. No worry about the German keyboard differing from the English one.

If `axe key` doesn't work for some reason, try in this order: (1) `axe type --text "answer\n"` (some `type` implementations interpret `\n` as Return), (2) `axe key-sequence` with the Return keycode in a sequence, (3) tap the on-screen Return key via `tap_xy` (last resort — fragile across language and keyboard themes).

The TextField on `QuizView` uses `.submitLabel(.go)` plus an `onSubmit` handler — both fire on the Return keypress regardless of which mechanism delivers it.

### Q7. `verify_screen_loaded` calls: **(a) — only for screen 8 (Results).**

The Step-2 session navigated through all 5 tabs sequentially without anchor-based waits and observed no flakiness — a `sleep 0.7` after each tap was enough for the AX tree to settle. The 700ms cushion handles the navigation animation; the 30-question quiz loop's per-iteration `sleep 0.3` handles the inter-question re-focus. The async ResultsView sheet is the genuinely-different case where `verify_screen_loaded results_score` earns its keep.

Adding anchors to VerbView, FamilyDetailView, InfoView, SettingsView is *possible* but requires source-code changes (Step-1-style additions) and there's no observed need yet. Ship without; if the sweep run shows flakiness, add anchors as a Step-3.5 follow-up.

For the views that DO have existing identifiers, you can opportunistically use them:
- `verb_browse_anchor` on screen 1 — already there
- `family_row_*` on screen 3 — any will do as a "screen rendered" check
- `quiz_start_button` on screen 5 entry, `quiz_answer_field` once typing
- `info_row_*` on screen 6 — any will do
- `results_score` on screen 8 — already there (commit `66216b3`)

Wrap all of these in a single inline `verify_screen_loaded` call only where the cost is non-zero (i.e., screen 8). For everything else, the post-tap sleep is fine.

---

## Defaults summary (sign-off shape)

If you're going with all defaults from this answers doc:

| Q | Default |
|---|---|
| Q1 | (a) one build, install per device |
| Q2 | defer to `screenshot.sh` (it owns the timestamp) |
| Q3 | (a) leave existing calibration PNGs alone |
| Q4 | iPad Info SCROLL = 0 (confirmed) |
| Q5 | iPhone Family SCROLL = 0 (confirmed) |
| Q6 | try `axe key` for Return; fall back to `axe type "\n"` if needed |
| Q7 | (a) verify_screen_loaded only on screen 8 |

All defaults are conservative — the safest path through Step 3. None require any source-code changes. None require revisiting Step-2's calibration. Ship them.
