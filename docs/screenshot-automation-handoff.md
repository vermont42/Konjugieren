# Screenshot Automation Handoff

This document hands off an in-progress effort to automate Konjugieren's App Store screenshots. A previous session (May 2026) completed the audit + code-changes phases. This prompt picks up at the **calibration phase** and runs through driver implementation, capture, and playbook documentation.

## Background

Konjugieren needs new App Store screenshots for an upcoming release. The spec is [`docs/ScreenshotPlan.md`](ScreenshotPlan.md): 9 view types × 2 languages (English, German) × 2 devices (iPhone 17 Pro Max for 6.9", iPad Pro 13-inch (M4) for iPad 13") = **36 screenshots**.

Manual capture is tedious. The plan automates via `ios-build-verify` (the build/verify skill already configured for this project) plus a custom shell driver. The previous session designed the architecture, shipped the supporting code changes, and verified the build.

The user is **Josh Adams**. He's the solo developer of Konjugieren. The previous session was a thorough multi-turn collaboration — Josh approved each step before code landed.

## What's already done (Step 1, committed before this session began)

### Source code changes (verified building, all 122 tests passing)

| File | Change |
|------|--------|
| `Konjugieren/Models/Info.swift` | Added `stableKey: String` field with locale-stable identifiers (`dedication`, `verb_history`, `praesens_indikativ`, etc.) for all 22 entries. Used by the screenshot driver to find Info rows by key regardless of language. |
| `Konjugieren/Models/Quiz.swift` | Added DEBUG-gated `generateScreenshotFixture()` (30 hand-picked verb/conjugationgroup pairs) + `exportFixtureAnswers()` (writes answer plan as JSON to `Documents/screenshot_fixture_answers.json`). Activated by launch arg `-KONJUGIEREN_QUIZ_FIXTURE screenshot`. The driver reads the JSON to know what to type. First fixture question is `(machen, Präsens Indikativ, ich)` → `"mache"`, featured in the mid-quiz screenshot. |
| `Konjugieren/Views/InfoBrowseView.swift` | Added `accessibilityIdentifier("info_row_\(info.stableKey)")` on `InfoRowView`. Also fixed a pre-existing iOS 26 deprecation warning (`Text + Text` → `Text("\($0)\($1)")` interpolation; the asset-emoji `Image` interpolation in `previewText(for:)` is preserved — important per `docs/emoji-assets.md`). |
| `Konjugieren/Views/VerbBrowseView.swift` | Added `accessibilityIdentifier("verb_row_\(verb.infinitiv)")` on `VerbRowView` (compact) and `VerbGridCell` (regular). |
| `Konjugieren/Views/FamilyBrowseView.swift` | Added `accessibilityIdentifier("family_row_\(family.rawValue)")` on both `NavigationLink`s (regular grid + compact list). |
| `Konjugieren/Views/QuizView.swift` | Added `quiz_start_button` on Start button, `quiz_answer_field` on TextField. |

### CLAUDE.md update

A new convention was added under "Swift Coding Conventions": **Single Space After Commas** — argument lists use single space after each comma, not column-aligned padding (alignment churns diffs unnecessarily when names change).

## Decisions already made (do not relitigate)

| Question | Decision |
|----------|----------|
| Quiz randomness for screens 5 (mid-quiz) and 8 (results) | Env-var fixture (`KONJUGIEREN_QUIZ_FIXTURE=screenshot`) — fully deterministic, gated to DEBUG |
| Scroll positioning for screens 3 (FamilyBrowse → Strong) and 6 (InfoBrowse → verbHistory) | Swipe gestures with per-device calibrated offsets |
| Stable info-row keys | Added `stableKey` field on `Info` |
| Doc/script split | Hybrid: `scripts/take_screenshots.sh` (executable) + `docs/screenshot-playbook.md` (orientation) |
| Scope | Narrow — App Store screenshots only, not a general-purpose screenshot tool |

## What needs to happen next

### Step 2: Calibration pass (start here)

Goal: produce a small set of calibrated values for the driver. No code changes; no screenshot captures yet.

1. **Sanity checks first.**
   - `git log -3 --oneline` — confirm Step 1 is committed.
   - `export IBV_SCRIPTS=$(dirname "$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")` — resolve skill scripts path.
   - `"$IBV_SCRIPTS/build_app.sh"` — confirm clean build.
   - `grep -rn 'accessibilityIdentifier' Konjugieren --include='*.swift'` — should see ≥7 identifiers (the existing `verb_browse_anchor` + 6 new ones for screenshots, plus `verb_row_<infinitiv>`, `family_row_<rawValue>`, `info_row_<stableKey>` patterns).

2. **Per-device tab-pill coordinates.**
   - Boot iPhone 17 Pro Max simulator (`xcrun simctl create "iPhone 17 Pro Max" "iPhone 17 Pro Max" "com.apple.CoreSimulator.SimRuntime.iOS-26-3"` if missing; check `xcrun simctl list devices` first).
   - Temporarily set `TARGET_SIM='iPhone 17 Pro Max'` in `.claude/ios-build-verify.config.sh` (it's gitignored, safe to mutate).
   - Build + install, launch the app.
   - Run `"$IBV_SCRIPTS/measure_tab_pill.sh"` — outputs per-tab pixel centers (5 tabs).
   - Repeat for iPad Pro 13-inch (M4).
   - Save **both** coordinate sets in the driver script's per-device tables (don't edit the gitignored config to hold both).

3. **Per-device scroll-up offsets** for three views:
   - **FamilyBrowseView (screen 3)**: Strong is 6th of 7 in `BrowseableFamily.allCases` (alphabetical: ablaut, ieren, inseparable, mixed, separable, strong, weak). Iterate `axe swipe …` until `family_row_strong`'s `AXFrame` y-center is near the top of the visible area. Document the swipe distance.
   - **InfoBrowseView (screen 6)**: `verbHistoryHeading` is index 1 (after the dedication row). Scroll past dedication so verbHistory is at top.
   - **SettingsView (screen 9)**: probably no scroll needed; first card with 3 pickers (conjugationgroupLang, thirdPersonPronounGender, searchScope) likely fits at default position. Verify on each device; iterate if not.

4. **Output.** Calibration values inline in the driver script (next step). One value per (device, view) pair where scroll is needed.

### Step 3: Driver implementation + capture

Goal: write `scripts/take_screenshots.sh` and run it end-to-end.

#### Driver structure (designed in audit phase)

```bash
#!/usr/bin/env bash
# Drives ios-build-verify through 36 App Store screenshots.
set -euo pipefail

DEVICES=( "iPhone 17 Pro Max" "iPad Pro 13-inch (M4)" )
LANGS=( en de )
VIEWS=( verb_browse verb_view family_browse family_detail quiz_mid \
        info_browse info_view quiz_results settings )
declare -A APPEARANCE=(
  [verb_browse]=dark   [verb_view]=light
  [family_browse]=dark [family_detail]=light
  [quiz_mid]=dark      [info_browse]=light
  [info_view]=dark     [quiz_results]=light
  [settings]=dark
)

# Filled in during Step 2 calibration.
declare -A TAB_COORDS=(
  ["iPhone 17 Pro Max"]="…"
  ["iPad Pro 13-inch (M4)"]="…"
)
declare -A SCROLL_PX_FAMILY_BROWSE=( ["iPhone 17 Pro Max"]=… ["iPad Pro 13-inch (M4)"]=… )
declare -A SCROLL_PX_INFO_BROWSE=(   ["iPhone 17 Pro Max"]=… ["iPad Pro 13-inch (M4)"]=… )

# … per-view nav functions (one each: nav_verb_browse, nav_verb_view, etc.) …

# Main loop:
for DEVICE in "${DEVICES[@]}"; do
  ensure_simulator "$DEVICE"
  apply_tab_coords "$DEVICE"
  build_app
  install_app
  for LANG in "${LANGS[@]}"; do
    for VIEW in "${VIEWS[@]}"; do
      MODE="${APPEARANCE[$VIEW]}"
      xcrun simctl ui "$(udid_of "$DEVICE")" appearance "$MODE"
      "$IBV_SCRIPTS/terminate_app.sh"
      launch_with_lang "$LANG"
      FIXTURE_ANSWERS=$(read_fixture_answers_path "$DEVICE")
      "$IBV_SCRIPTS/dismiss_onboarding.sh"
      "nav_$VIEW"
      "$IBV_SCRIPTS/screenshot.sh" "${DEVICE// /-}-${LANG}-${VIEW}"
    done
  done
done
```

#### Per-view nav recipes (audit output)

| Screen | View | Mode | Nav |
|--------|------|------|-----|
| 1 | VerbBrowseView | dark | Default landing. Just confirm `verb_browse_anchor` rendered. |
| 2 | VerbView | light | `tap_id verb_row_werden` |
| 3 | FamilyBrowseView | dark | `tap_tab families` → swipe up `${SCROLL_PX_FAMILY_BROWSE[$DEVICE]}` |
| 4 | FamilyDetailView | light | nav_family_browse → `tap_id family_row_strong` |
| 5 | QuizView (mid) | dark | `tap_tab quiz` → `tap_id quiz_start_button` → `tap_id quiz_answer_field` → `type_text $(jq -r '.[0].answer' $FIXTURE_ANSWERS)` → screenshot before submit |
| 6 | InfoBrowseView | light | `tap_tab info` → swipe up `${SCROLL_PX_INFO_BROWSE[$DEVICE]}` |
| 7 | InfoView | dark | nav_info_browse → `tap_id info_row_praesens_indikativ` |
| 8 | ResultsView | light | `tap_tab quiz` → `tap_id quiz_start_button` → loop 30× (tap field, type answer, press Return) → results sheet appears |
| 9 | SettingsView | dark | `tap_tab settings` (no scroll if first card fits) |

#### Critical mechanics

- **Appearance**: `xcrun simctl ui <UDID> appearance dark|light` — instant, no Settings.app interaction.
- **Language**: `xcrun simctl launch <UDID> biz.joshadams.Konjugieren -AppleLanguages '(de)' -AppleLocale 'de_DE' -KONJUGIEREN_QUIZ_FIXTURE screenshot`. Foundation reads `AppleLanguages` from NSArgumentDomain before any UI loads — per-launch override, doesn't persist. Same mechanism delivers the quiz fixture flag.
- **Fixture answers**: read via `xcrun simctl get_app_container <udid> biz.joshadams.Konjugieren data` then `<dataDir>/Documents/screenshot_fixture_answers.json`. Use `jq` to extract `[i].answer` for question `i`.
- **`launch_app.sh` doesn't pass through args** — bypass it for the language-override launch (use `simctl launch` directly). All other ios-build-verify scripts (`screenshot.sh`, `tap_id.sh`, `tap_tab.sh`, `describe_ui.sh`, `verify_screen_loaded.sh`, `tap_xy.sh`, `type_text.sh`) operate on whichever sim is booted and don't care about language — keep using them.
- **Per-device tab coords**: `tap_tab.sh` reads `MAIN_TABS_COORDS` from `.claude/ios-build-verify.config.sh`. The config currently has iPhone 17 (6.3") values calibrated for development. For multi-device runs, either swap the gitignored config per-iteration **or** maintain a per-device coords table in the driver and call `axe tap` directly — the latter is cleaner.
- **Onboarding**: `launch_app.sh`'s onboarding-dismiss interleave looks for "Skip" label. When bypassing it, call `dismiss_onboarding.sh` directly after each launch (idempotent).
- **Review-prompt UserDefaults accumulation**: see CLAUDE.md "App-specific friction: review-prompt UserDefaults accumulation". Tap "Not Now" once on a clean sim or `xcrun simctl uninstall <UDID> biz.joshadams.Konjugieren` between runs.

#### Output

All 36 PNGs land under `docs/screenshots/<timestamp>-<device>-<lang>-<view>.png` (the path `screenshot.sh` writes to). Inspect visually; iterate on any wrong outputs.

### Step 4: Playbook

Once captures are clean, write `docs/screenshot-playbook.md` documenting:

- Setup prerequisites (iPhone 17 Pro Max sim creation, clearing review-prompt UserDefaults if needed, ensuring Apple Silicon host or just acknowledging that no AI surfaces are screenshotted)
- The two CLI techniques (simctl appearance, launch args) with copy-paste commands
- Calibration values from Step 2 (the actual numbers)
- Per-view nav recipes (refined from this handoff)
- Recovery guidance: sim runtime drift, identifier rename in app code, locale shifts, AXTree changes from a SwiftUI version bump

The playbook is the durable artifact for future releases. After it lands, this handoff doc (`screenshot-automation-handoff.md`) can be deleted — it served its purpose.

## Project orientation

- **Read [`CLAUDE.md`](../CLAUDE.md) end-to-end.** It documents conventions, build/test commands (via `ios-build-verify`), the dependency injection pattern (`Current` / `World.swift`), the Settings system, conjugationgroup terminology, the localization system, and the iOS 26 emoji-rendering workaround. Several of these matter for screenshot work.
- **Read [`docs/ScreenshotPlan.md`](ScreenshotPlan.md).** That's the spec — light/dark mode per view, sort/scroll requirements. **Don't change it**; it's Josh's authored intent.
- **`ios-build-verify` SKILL.md**: at `~/.claude/plugins/cache/ios-build-verify/ios-build-verify/0.2.1/skills/ios-build-verify/SKILL.md` (path may differ; resolve via `find ~/.claude -path '*ios-build-verify*' -name SKILL.md`). Read sections "Verify operations", "iOS 26 controls with empty AXTree children", and "Designing for verify ops" for nuance.

## Constraints

- **Don't relitigate the four decisions** (fixture, swipes, stableKey, narrow scope) unless something concrete proves one wrong.
- **Don't change `docs/ScreenshotPlan.md`** — it's the spec.
- **Don't touch `Localizable.xcstrings`** — no locale strings change for this work.
- **Tutor surfaces are gated on Intel-Mac hosts** (CLAUDE.md "App-specific friction: Apple Intelligence Tutor host-eligibility on iOS 26.3+"). None of the 9 target screens are Tutor-gated, so it's fine here.
- **`MAIN_TABS_COORDS` in `.claude/ios-build-verify.config.sh` is gitignored.** Don't try to commit it. Per-device coords in `scripts/take_screenshots.sh` ARE checked in.
- **`docs/screenshots/` may be gitignored or kept** — check before assuming. The 36 PNGs may not need to live in the repo if they go straight to App Store Connect.

## A note on the user's working style

Josh prefers:
- Concrete plans before code lands. The previous session presented a diff plan in text form before making the edits; he reviewed and approved.
- Single space after commas in argument lists (recently codified in CLAUDE.md).
- Educational explanations alongside changes (the explanatory output style was active for the previous session — keep it active here unless he says otherwise).
- Project-stored facts over Claude Code memory (per CLAUDE.md "Memory Feature").
- Narrow scope. Don't generalize this work into a screenshot framework — it's for App Store screenshots, this release.
