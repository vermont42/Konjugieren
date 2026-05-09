# Screenshot Playbook

Captures App Store screenshots for Konjugieren via `scripts/take_screenshots.sh`. The driver carries the calibration values, per-view navigation, and the twelve workarounds inline as comments; this playbook is the prose-and-procedure wrapper around it.

## Scope

App Store screenshots only — 9 views × 2 languages × 2 devices = 36 PNGs. Not a general-purpose iOS screenshot framework. The capture spec lives in [`docs/ScreenshotPlan.md`](ScreenshotPlan.md).

## Prerequisites

- macOS with Xcode 26+ and the iOS 26.3+ simulator runtime installed.
- `axe` CLI on PATH (see `ios-build-verify` SKILL.md for installation).
- `ios-build-verify` skill installed; resolve its scripts directory once per session:
  ```bash
  export IBV_SCRIPTS=$(dirname "$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")
  ```
- macOS Accessibility permission granted to `osascript`. System Settings → Privacy & Security → Accessibility → add `/usr/bin/osascript`. The driver depends on this for the soft-keyboard Cmd+K toggle (workaround #6).
- Two named simulators (see "Simulator Setup" below). Their UDIDs are hardcoded in the driver's `udid_for()`.

## Quick Start

```bash
scripts/take_screenshots.sh  # all 36 (~30-45 min)
scripts/take_screenshots.sh --device "iPhone 17 Pro Max"  # 18 (one device)
scripts/take_screenshots.sh --lang de  # 18 (German only)
scripts/take_screenshots.sh --view family_browse  # 4 (one view, both devices/langs)
scripts/take_screenshots.sh --device "iPhone 17 Pro Max" --lang de --view quiz_results  # exactly 1 cell
```

The `--device` value is the device-class label (with parens), not the simulator's display name. UDIDs are hardcoded in `udid_for()`; the driver bypasses `_resolve_udid.sh` entirely.

`VIEWS` are: `verb_browse verb_view family_browse family_detail quiz_mid info_browse info_view quiz_results settings`.

## Outputs

The driver writes timestamped PNGs to `docs/screenshots/<timestamp>-<device>-<lang>-<view>.png` (gitignored). One file per cell per run; iterating with `--view` accumulates timestamped versions.

For App Store Connect upload, copy the latest version of each cell to `docs/screenshots/latest/`:

```bash
mkdir -p docs/screenshots/latest && \
for view in verb_browse verb_view family_browse family_detail quiz_mid \
            info_browse info_view quiz_results settings; do
  for device in "iPhone-17-Pro-Max" "iPad-Pro-13-inch-(M4)"; do
    for lang in en de; do
      latest=$(ls -t docs/screenshots/*"${device}-${lang}-${view}.png" 2>/dev/null | head -1)
      [[ -n "$latest" ]] && cp "$latest" "docs/screenshots/latest/$(basename "$latest")"
    done
  done
done
```

`ls -t` orders by modification time; the timestamp embedded in the filename matches mtime to the second, so the two ordering schemes agree.

## Simulator Setup

The driver targets two specific simulators; both UDIDs are hardcoded in `udid_for()`. To recreate either after `simctl erase` or `simctl delete unavailable` removes them:

```bash
RUNTIME=$(xcrun simctl list runtimes | grep -i 'iOS 26.3' | tail -1 | awk -F'[()]' '{print $2}')

xcrun simctl create "iPhone 17 Pro Max" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max \
  "$RUNTIME"

xcrun simctl create "Konjugieren iPad Screenshots" \
  com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M4 \
  "$RUNTIME"
```

After creation, copy the new UDIDs into `udid_for()` in the driver.

**Why paren-free names?** The driver bypasses `_resolve_udid.sh`, so its regex-pattern bug (parens in `TARGET_SIM` break the match — see `Prompts/bug-resolve-udid-regex-special-chars.md` in the `ios-build-verify` repo) doesn't bite this workflow. But other `ios-build-verify` operations against these sims (`tap_tab.sh`, `dismiss_onboarding.sh`, manual `launch_app.sh`) do source it. The iPad's Apple-default name `iPad Pro 13-inch (M4)` contains regex specials; renaming to `Konjugieren iPad Screenshots` keeps everything compatible. The iPhone's default name is already paren-free.

## The Twelve Workarounds

Compact reference. The driver's inline comments hold the full WHY for each — cross-references point at the relevant function.

1. **Bash 3.2 compatibility** (`take_screenshots.sh::udid_for, tab_coords_for, scroll_*_for, wait_budget_for`)
   *Symptom:* macOS system bash lacks associative arrays. *Fix:* case-statement lookup functions instead of `declare -A`.

2. **Onboarding race during launch** (`take_screenshots.sh::wait_for_render`)
   *Symptom:* OnboardingView may render before `verb_browse_anchor` on a fresh install. *Fix:* interleave a `Skip`/`Überspringen` AXLabel-tap during the render poll.

3. **SwiftUI identifier propagation** (`take_screenshots.sh::tap_id_first`)
   *Symptom:* SwiftUI propagates `accessibilityIdentifier` to children; `axe tap --id` refuses to disambiguate. *Fix:* parse the first matching `AXFrame` from `describe-ui` and tap its center via coords.

4. **simctl subcommand naming** (`take_screenshots.sh::disable_review_prompt`)
   *Symptom:* `xcrun simctl pasteboard set` is not a real subcommand. *Fix:* `xcrun simctl pbcopy <UDID>`.

5. **Unicode typing via pasteboard** (`take_screenshots.sh::type_via_pasteboard`)
   *Symptom:* `axe type` lacks HID-keycode mappings for German umlauts and `ß`. *Fix:* paste via `simctl pbcopy` + Cmd+V (`axe key-combo --modifiers 227 --key 25`).

6. **Soft keyboard suppression** (`take_screenshots.sh::ensure_soft_keyboard`)
   *Symptom:* Simulator forwards host hardware-keyboard events; the soft keyboard is suppressed by default. *Fix:* send Cmd+K via `osascript` (Simulator's "Toggle Software Keyboard"); idempotent — checks the AXTree for a "space" key first.

7. **StoreKit modal AX gating** (`take_screenshots.sh::disable_review_prompt`)
   *Symptom:* the "Enjoying Konjugieren?" review modal opaques the AXTree mid-loop. *Fix:* pre-seed `lastReviewPromptDate` to now via `simctl spawn defaults write` so the 180-day cooldown blocks subsequent prompts.

8. **iPhone tab-bar overlap on InfoBrowseView** (`take_screenshots.sh::scroll_info_browse_for, nav_info_view`)
   *Symptom:* `info_row_praesens_indikativ` sits at y≈873 on iPhone, overlapping the tab-bar hit zone (y≈877+). *Fix:* 117pt slow-drag swipe-up before tap.

9. **`axe --id` typeMismatch on iPad** (`take_screenshots.sh::tap_id`)
   *Symptom:* `axe tap --id` and `axe tap --label` throw a Swift `typeMismatch` decoding error in some iPad screen states (e.g., QuizView pre-Start). *Fix:* route all `tap_id` calls through `tap_id_first` (describe-ui + coord-tap) — same path as workaround #3.

10. **Multi-sim window focus** (`take_screenshots.sh::ensure_soft_keyboard`)
    *Symptom:* with both sims booted, Cmd+K hits whichever Simulator window is frontmost. *Fix:* AXRaise the target sim's window by title-substring match before sending the keystroke.

11. **Localized onboarding labels** (`take_screenshots.sh::ONBOARDING_LABELS`)
    *Symptom:* the onboarding-Skip button label is localized (`Skip` / `Überspringen`). *Fix:* array of all known labels; the wait-for-render loop tries each.

12. **Lang-agnostic StoreKit dismiss** (`take_screenshots.sh::dismiss_review_prompt`)
    *Symptom:* StoreKit prompt button labels are system-localized (`Not Now` / `Nicht jetzt`); the modal also has a single-button and a post-star-tap two-button state. *Fix:* vertical sweep of `describe-ui --point` at a known x-center, tap the bottommost `AXButton` found.

## Per-View Navigation Recipes

| # | View | Mode | Driver function | Notes |
|---|---|---|---|---|
| 1 | VerbBrowseView | dark | `nav_verb_browse` | Default landing; `wait_for_render verb_browse_anchor` (20s budget on iPad). |
| 2 | VerbView | light | `nav_verb_view` | `tap_id_first verb_row_werden`. |
| 3 | FamilyBrowseView | dark | `nav_family_browse` | `tap_tab families`; no scroll either device. |
| 4 | FamilyDetailView | light | `nav_family_detail` | `tap_tab families` → `tap_id_first family_row_strong`. |
| 5 | QuizView (mid) | dark | `nav_quiz_mid` | `tap_tab quiz` → `quiz_start_button` → `quiz_answer_field` → paste fixture answer 0 → `ensure_soft_keyboard`. Captured before submit (keyboard visible per spec). |
| 6 | InfoBrowseView | light | `nav_info_browse` | `tap_tab info` → 117pt scroll on iPhone, 0 on iPad. |
| 7 | InfoView | dark | `nav_info_view` | `tap_tab info` → 117pt scroll on iPhone → `tap_id_first info_row_praesens_indikativ`. |
| 8 | ResultsView | light | `nav_quiz_results` | `tap_tab quiz` → `quiz_start_button` → 30× (paste + Return + sleep 0.3) → `dismiss_review_prompt` if needed → `verify_screen_loaded results_score`. |
| 9 | SettingsView | dark | `nav_settings` | `tap_tab settings`; no scroll either device. |

Tab-bar coordinates and per-view scroll values live in `tab_coords_for()` / `scroll_*_for()` in the driver. iPhone uses the bottom pill tab bar (y=899.3); iPad uses a top segmented tab bar (y=54).

## Recovery Guidance

### Don't Break These — Driver Anchor Dependencies

The driver depends on these app-side touchpoints. Renaming any one silently breaks the corresponding screen with no compile-time signal — the next sweep produces a wrong screenshot or `wait_for_render` times out.

| Touchpoint | Driver depends on | Source file |
|---|---|---|
| `Info.stableKey` field | `info_row_<stableKey>` identifier (specifically `info_row_praesens_indikativ`) | `Konjugieren/Models/Info.swift` |
| `Quiz.generateScreenshotFixture()` + `exportFixtureAnswers()` | DEBUG-gated 30-pair fixture; JSON written to `Documents/screenshot_fixture_answers.json` when launched with `-KONJUGIEREN_QUIZ_FIXTURE screenshot` | `Konjugieren/Models/Quiz.swift` |
| `verb_browse_anchor` identifier | `wait_for_render` polls for it after every launch | `Konjugieren/Views/VerbBrowseView.swift` |
| `verb_row_<infinitiv>` identifiers | `tap_id_first verb_row_werden` for screen 2 | same file |
| `family_row_<rawValue>` identifiers | `tap_id_first family_row_strong` for screen 4 | `Konjugieren/Views/FamilyBrowseView.swift` |
| `info_row_<stableKey>` identifiers | `tap_id_first info_row_praesens_indikativ` for screen 7 | `Konjugieren/Views/InfoBrowseView.swift` |
| `quiz_start_button`, `quiz_answer_field` identifiers | quiz nav for screens 5 and 8 | `Konjugieren/Views/QuizView.swift` |
| `results_score` identifier | `verify_screen_loaded results_score` after the 30-answer loop | `Konjugieren/Views/ResultsView.swift` |

These were added in the Step-1 prep commits (`70850b3` and `66216b3`); see `git log` if you need historical context.

### Sim Runtime Drift

If the iOS 26.3 simulator runtime is replaced by 26.4+, the AXTree shape may shift slightly — especially for system-controlled surfaces like the StoreKit review prompt. Recreate the sims on the new runtime, re-verify workarounds #7 and #12 still match, and re-run a single test cell:

```bash
scripts/take_screenshots.sh --device "iPad Pro 13-inch (M4)" --lang en --view quiz_results
```

### Identifier Renames in App Code

Use the touchpoint table above as the rename checklist. After any identifier change:

```bash
grep -n "<old_identifier>" Konjugieren/
grep -n "<old_identifier>" scripts/take_screenshots.sh
```

Update both sides; re-run a single test cell to verify.

### Locale Shifts and New Languages

If a third app language ships:

1. Append the localized "Skip" label to `ONBOARDING_LABELS` in the driver.
2. Append the language code to `LANGS=( en de )` in the driver.
3. Add a corresponding `case` arm in `launch_with_lang()` for the locale string.
4. Re-run `--view quiz_results --lang <new-lang>` to verify `dismiss_review_prompt`'s sweep still finds the system buttons in the new language.

The vertical-sweep dismiss (workaround #12) is lang-agnostic by design, so step 4 should pass without further change.

### SwiftUI Version Bumps

A SwiftUI version that changes how `accessibilityIdentifier` propagates, or where `AXFrame` is reported, can break `tap_id_first` silently. After any major SwiftUI bump:

```bash
axe describe-ui --udid <UDID> | jq '[.. | objects | select(.AXUniqueId? == "verb_row_werden")][0]'
```

If `AXFrame` is missing or the structure has changed, `tap_id_first` needs a corresponding update.

### Re-running Individual Cells

Visual review will surface bad cells. Re-run any single one via the `--device` / `--lang` / `--view` filter flags (Quick Start). Each filter is independent; combine to narrow further.

## Maintenance Triggers

- **New conjugationgroup or family.** If the change alters which 9 views ship as App Store screenshots, update [`docs/ScreenshotPlan.md`](ScreenshotPlan.md) first; the driver's `VIEWS` array follows.
- **New device size class.** Add the device-class label to `DEVICES`, add a UDID arm to `udid_for()`, calibrate `tab_coords_for()` (top vs. bottom tab bar — iPad's regular size class uses a top segmented bar at y=54; iPhone's is a bottom pill bar at y=899.3), and verify the per-view scroll values still apply.
- **`axe` upstream fix for the iPad `--id` `typeMismatch` bug.** If a future `axe` release fixes the bug, `tap_id` can be simplified back to `axe tap --id` directly. The driver's `tap_id_first` is currently always-on; after upstream fix it can become iPad-only or be removed.

## Known Gotchas

- **TipKit popovers may surface mid-sweep.** Specifically, the "Try the Quiz" tip can render on `verb_browse` depending on TipKit eligibility. The driver doesn't suppress these — visual review the captured PNG before upload.
- **Apple Intelligence Tutor surfaces are gated on Intel-Mac hosts.** Per CLAUDE.md, the Tutor row in InfoBrowseView, the `ErrorExplainerView` card in QuizView, and the Tutor page in OnboardingView don't render on Intel-Mac simulators with iOS 26.3+. None of the 9 target screenshot views are Tutor-gated, so this doesn't affect the sweep — but be aware if the spec ever adds a Tutor-adjacent screen.
- **Review-prompt cooldown is per-install.** `disable_review_prompt` pre-seeds `lastReviewPromptDate` for in-run prompts, but a manual screenshot capture of the StoreKit modal would still require uninstalling/reinstalling first.
- **iPad first-boot is ~70s on a fresh sim.** Data-migration plugins (keychain, gestalt, MobileSafari, locationd, preferences) initialize on first boot. Subsequent boots are ~22s. The driver's `WAIT_FOR_RENDER_BUDGET_S=20` accommodates the post-launch render poll, but the `xcrun simctl bootstatus -b` step itself can block for ~70s during that initial boot. Don't kill the sweep thinking it's hung — `bootstatus -b` is doing the right thing.
