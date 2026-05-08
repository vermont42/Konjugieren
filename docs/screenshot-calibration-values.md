# Screenshot Calibration Values (Step 2 Output)

Output of Step 2 calibration for `scripts/take_screenshots.sh` (to be written in Step 3). Calibrated 2026-05-08 against iPhone 17 Pro Max + iPad Pro 13-inch (M4), both on iOS 26.3.1.

## Device sims

| Device | Sim Name | UDID | iOS Runtime |
|---|---|---|---|
| iPhone 17 Pro Max | `iPhone 17 Pro Max` (existing) | `E23163FA-C903-42F3-9711-56F2FB6B2941` | 26.3.1 |
| iPad Pro 13-inch (M4) | `Konjugieren iPad Screenshots` (created this session) | `E73F9CB3-41E7-4418-AFC7-928180536EEA` | 26.3.1 |

The iPad sim was created with a paren-free name to work around `_resolve_udid.sh`'s regex-pattern bug (see Findings below).

## Tab coordinates

```bash
declare -A TAB_COORDS=(
  ["iPhone 17 Pro Max"]="67,899.3 142.7,899.3 220,899.3 296.2,899.3 372.6,899.3"
  ["iPad Pro 13-inch (M4)"]="355,54 441.5,54 523,54 587.75,54 667.25,54"
)
```

Order: `Verbs Families Quiz Info Settings`.

iPhone uses the bottom pill tab bar (y=899.3 logical pts); iPad uses a top segmented-style tab bar (y=54). `measure_tab_pill.sh` worked for iPhone but doesn't apply to iPad's top bar — iPad coords were extracted from the AXTree's `AXTabButton` elements via JSON parsing.

## Scroll offsets (slow drag, duration 1.0s)

```bash
declare -A SCROLL_PX_FAMILY_BROWSE=( ["iPhone 17 Pro Max"]=0   ["iPad Pro 13-inch (M4)"]=0   )
declare -A SCROLL_PX_INFO_BROWSE=(   ["iPhone 17 Pro Max"]=117 ["iPad Pro 13-inch (M4)"]=0   )
declare -A SCROLL_PX_SETTINGS=(      ["iPhone 17 Pro Max"]=0   ["iPad Pro 13-inch (M4)"]=0   )
```

Only one non-zero scroll across both devices: **iPhone Info = 117pt**. Larger viewports (iPad regular size class) fit all calibration targets at natural position. The iPhone FamilyBrowseView entry is 0 because the 7-row list barely exceeds the viewport (max scroll is ~52pt, just enough to collapse the large title — not enough to actually feature Strong at top, so we keep the natural large-title state).

When invoking the swipe, use a slow drag (no momentum):

```bash
swipe_up_pts() {
  local pts="$1"
  [[ "$pts" -le 0 ]] && return 0
  local start_y=400
  local end_y=$((start_y - pts))
  axe swipe --start-x 200 --start-y "$start_y" --end-x 200 --end-y "$end_y" --duration 1.0 --udid "$UDID"
}
```

Slow drag (1.0s) is preferred over fast flick because momentum-driven scroll varies between devices. Slow drag has gesture ≈ scroll (1:1); fast flick produced ~2.7× the gesture distance during calibration testing.

## Findings worth carrying into the driver and playbook

1. **`_resolve_udid.sh` regex bug**: line 16 uses `grep -E "^[[:space:]]+${TARGET_SIM} \("` — when `TARGET_SIM` contains regex specials (`(`, `)`, `[`, etc.), the match fails. Workaround: rename the sim to a paren-free name. The handoff's recommended `'iPad Pro 13-inch (M4)'` value would have hit this. Worth reporting upstream to `vermont42/ios-build-verify`.

2. **iPad uses TOP tab bar**: regular size class TabView is segmented-style at the top of screen, not bottom pill bar. Different region, different y-coords, different image-detection viability.

3. **`measure_tab_pill.sh` is iPhone-only**: scans bottom y-band for pill centroids. For iPad, extract coords from AXTree `AXTabButton` elements via JSON parsing (see python snippet pattern in this session's transcript).

4. **iPad first-boot is slow**: fresh sim takes ~70s for first boot due to data-migration plugins (keychain, gestalt, MobileSafari, locationd, preferences). Subsequent boots are ~22s. Plan one-time overhead.

5. **`WAIT_FOR_RENDER_BUDGET_S=10` is too short for iPad**: `verb_browse_anchor` exists in the AXTree but doesn't appear within 10s on iPad's first launch (990 verbs render slowly). Bump to 20s for iPad in Step 3, or use a different anchor for iPad.

6. **iOS scroll-gesture momentum**: `axe swipe` velocity = distance/duration determines scroll behavior. Fast flick (short duration, 0.5s) triggers UIKit momentum (gesture × ~2.7); slow drag (long duration, 1.0s+) is direct (gesture ≈ scroll). Use slow drag for deterministic calibration.

7. **iPhone 17 Pro Max FamilyBrowse max scroll is ~52pt**: content height barely exceeds viewport. Spec's "scroll Strong to top" prescription is impossible on this device; the max scroll just collapses the large title. SCROLL_PX = 0 keeps the prettier large-title state.

8. **App did NOT need `KONJUGIEREN_QUIZ_FIXTURE` env var during calibration**: only relevant for screens 5 (mid-quiz) and 8 (results) during Step 3 capture. Calibration screens (Family/Info/Settings) work without it.

9. **App icon picker on iPad is a marketing visual**: SettingsView's App Icon section shows all 4 alternate icons (Bratwurst / Bundestag / Hat / Pretzel) horizontally — well-suited for the Settings App Store screenshot.

## Sims summary (informational; no cleanup performed)

| UDID | Name | Runtime | Action |
|---|---|---|---|
| `E23163FA-C903-42F3-9711-56F2FB6B2941` | iPhone 17 Pro Max | iOS 26.3 | Keep — Step 3 |
| `E73F9CB3-41E7-4418-AFC7-928180536EEA` | Konjugieren iPad Screenshots | iOS 26.3 | Keep — Step 3 |
| `17D474C6-860F-476C-90B5-FFDAD2AA1990` | iPhone 17 Pro Max | iOS 26.0 | Optional cleanup |
| 4× iPad Pro 13-inch (M4) variants | Older runtimes (18.0/18.1/18.4/26.0) | Optional cleanup |

## Config restore

`.claude/ios-build-verify.config.sh` restored to `TARGET_SIM='iPhone 17'` (the pre-Step-2 dev value). Tab-pill coords in the config still reflect iPhone 17 6.3" — leave them; the driver will carry its own per-device coord table per the answers' Q3 resolution.

## Saved screenshots from this calibration session

All under `docs/screenshots/` (gitignored). Useful for visual review of the calibration outcomes:

- `*-iphone-families-prescroll.png` — iPhone Families baseline
- `*-iphone-families-postscroll-600.png` — iPhone Families after 600pt swipe (only ~52pt scroll achieved)
- `*-iphone-info-postscroll-115.png` — iPhone Info after 115pt fast flick (overshoot to y=-41)
- `*-iphone-info-postscroll-117-slow.png` — iPhone Info after 117pt slow drag (target hit)
- `*-iphone-settings-default.png` — iPhone Settings natural
- `*-ipad-postlaunch-debug.png` — iPad first launch (verb grid)
- `*-ipad-families-default.png` — iPad Families natural (2-column grid + pretzel)
- `*-ipad-info-default.png` — iPad Info natural (14+ entries)
- `*-ipad-settings-default.png` — iPad Settings natural (all options)
- `*-tabbar-measure.png` — measure_tab_pill.sh artifact (iPhone)
