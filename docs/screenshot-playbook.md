# Screenshot Playbook

> **⚠️ Updated 2026-07-18 — NOT RE-TESTED.** This playbook and
> `scripts/take_screenshots.sh` were refreshed from findings made while porting the same
> harness to the sibling app **Conjugar**, and from a large machine-wide simulator prune the
> same day. The changes are believed correct but **no cell of this sweep has been run since**,
> and no simulator was booted to confirm. Treat the first run as a verification run: shoot a
> single cell (`--lang de --view quiz_results`) and inspect it before trusting a full sweep.
> Specifically unverified here: the iPad tab coordinates (see *Per-View Navigation Recipes*)
> and the keyboard probe points (workaround #6).

Captures App Store screenshots for Konjugieren via `scripts/take_screenshots.sh`. The driver carries the calibration values, per-view navigation, and the workarounds inline as comments; this playbook is the prose-and-procedure wrapper around it.

## Scope

App Store screenshots only — 9 views × 2 languages × 2 devices = 36 PNGs. Not a general-purpose iOS screenshot framework. The capture spec lives in [`docs/screenshot-plan.md`](screenshot-plan.md).

## Prerequisites

- macOS with Xcode 26+ and the iOS 26.3+ simulator runtime installed.
- `axe` CLI on PATH (see `ios-build-verify` SKILL.md for installation).
- `ios-build-verify` skill installed; resolve its scripts directory once per session:
  ```bash
  export IBV_SCRIPTS=$(dirname "$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")
  ```
- macOS Accessibility permission granted to `osascript`. System Settings → Privacy & Security → Accessibility → add `/usr/bin/osascript`. The driver depends on this for the soft-keyboard Cmd+K toggle (workaround #6).
- Two named simulators (see "Simulator Setup" below). Their UDIDs are hardcoded in the driver's `udid_for()`.
- All three kill switches set to `false` (see the next section). Restore them to `true` when the sweep finishes.

## Flip the kill switches first (then restore)

`Konjugieren/Models/KonjugierenTips.swift` holds three compile-time kill switches, all ordinarily `true`. **Set all three to `false` before running the driver and restore them afterward.** They are compile-time constants and the driver builds once at start, so they must be flipped *before* launch — flipping one mid-sweep does nothing. (Contrast the `KONJUGIEREN_QUIZ_FIXTURE` flag, which is deliberately runtime because the driver toggles it per-cell.)

| Switch | Effect when `false` | What you get if you forget |
|---|---|---|
| `TipDisplay.tipsEnabled` | `KonjugierenApp` skips `Tips.configure()`. TipKit shows nothing until configured, so every `TipView` and `.popoverTip(_:)` stays hidden with no per-call-site changes. | A tip card can land on any shot. "Try the Quiz" reliably occupies `verb_browse` on a fresh install — that is sweep view #1. |
| `OnboardingDisplay.onboardingEnabled` | The first-launch `fullScreenCover` in `KonjugierenApp` never presents. Only that automatic path consults the switch; Settings → **Show Onboarding** ignores it, so the flow stays manually reachable for review. | The welcome tour covers whichever screen was being captured. The driver's Skip interleave (workarounds #2/#11) usually saves you, but it is a race, not a guarantee. |
| `TutorDisplay.tutorUnavailableRowEnabled` | `InfoBrowseView` drops the tutor **unavailability reason row**. Only that row: when the model *is* available the section still renders `TutorRowView`, so the switch cannot hide a working feature. | Both `info_browse` shots carry an "Apple Intelligence…" status row where a feature should be. |

```bash
# before the sweep
sed -i '' -E 's/(tipsEnabled|onboardingEnabled|tutorUnavailableRowEnabled) = true/\1 = false/' \
  Konjugieren/Models/KonjugierenTips.swift

# after the sweep — restore
sed -i '' -E 's/(tipsEnabled|onboardingEnabled|tutorUnavailableRowEnabled) = false/\1 = true/' \
  Konjugieren/Models/KonjugierenTips.swift

git diff --stat Konjugieren/Models/KonjugierenTips.swift   # must be empty when you are done
```

Only `tutorUnavailableRowEnabled` changes a screen the driver navigates *to*; the other two suppress things that appear *over* screens. That is why forgetting the tutor switch produces a consistently wrong `info_browse`, while forgetting the other two produces intermittent damage that is easy to miss in review.

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

> **Alpha channels — flattened at capture since 2026-07-25.** `axe screenshot` writes
> **RGBA**, and App Store Connect rejects any screenshot with an alpha channel ("Images
> can't include alpha channels or transparencies"). `take_screenshot()` now pipes each
> capture through `magick … -alpha remove -alpha off`. Two consequences: **`magick` is now
> effectively required** (the driver warns and continues without it, producing rejectable
> PNGs), and **`version_2` is non-compliant** — its 36 driver-produced files are RGBA,
> while only the four hand-made `10.png` slots are RGB. Flatten before reusing it.

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

### Per-Release Upload Bundles

App Store Connect's upload dialog takes one (device × locale) at a time and orders screenshots alphabetically by filename. The descriptive `latest/` names — useful as an archive — get in the way at upload time. For each release, project `latest/` into a numbered bundle:

```
docs/screenshots/version_<N>/
├── iPhone_English/{1..9}.png
├── iPhone_German/{1..9}.png
├── iPad_English/{1..9}.png
└── iPad_German/{1..9}.png
```

`<N>` increments per release (`version_2`, `version_3`, …). The row number is the `#` column in the "Per-View Navigation Recipes" table below (1 = VerbBrowseView … 9 = SettingsView). To regenerate after a re-shoot:

```bash
cd docs/screenshots && \
mkdir -p version_<N>/iPhone_English version_<N>/iPhone_German \
         version_<N>/iPad_English  version_<N>/iPad_German && \
for src in latest/*.png; do
  rest="${src##*/}"; base="${rest#????????-??????-}"; base="${base%.png}"
  [[ "$base" =~ ^(iPhone-17-Pro-Max|iPad-Pro-13-inch-\(M4\))-(en|de)-(.+)$ ]] || continue
  case "${BASH_REMATCH[3]}" in
    verb_browse) n=1 ;; verb_view) n=2 ;; family_browse) n=3 ;; family_detail) n=4 ;;
    quiz_mid) n=5 ;; info_browse) n=6 ;; info_view) n=7 ;; quiz_results) n=8 ;; settings) n=9 ;;
  esac
  case "${BASH_REMATCH[1]}" in iPhone-17-Pro-Max) d=iPhone ;; *) d=iPad ;; esac
  case "${BASH_REMATCH[2]}" in en) l=English ;; de) l=German ;; esac
  cp "$src" "version_<N>/${d}_${l}/${n}.png"
done
```

`latest/` stays untouched as the timestamped archive; `version_<N>/` is a regenerable projection — re-running the snippet after a re-shoot produces the same 36 files. If the playbook table ever reorders, edit only the inner `case` block.

## Simulator Setup

The driver targets two specific simulators; both UDIDs are hardcoded in `udid_for()`.

> **Prune check (do this first).** On 2026-07-18 this machine was pruned hard: every iOS 18
> device, every iOS 26.0 device, and all 305 devices on uninstalled runtimes were deleted.
> **Both of this driver's hardcoded UDIDs survived** and sit on iOS 26.3 — hardcoding is what
> saved them, since a name-resolving driver would have had to be re-pointed. But the next prune
> can kill them silently, so confirm before a sweep:
>
> ```bash
> xcrun simctl list devices | grep -E 'E23163FA|E73F9CB3'
> ```
>
> Both must print and neither may be listed under an `Unavailable:` runtime heading. If either
> is missing, recreate it below and copy the new UDID into `udid_for()`.
>
> Note `xcrun simctl delete unavailable` only removes devices whose *runtime is uninstalled*.
> A device on an old-but-installed runtime is "available" and survives that command — which is
> exactly how a stale duplicate can shadow a name lookup in a name-resolving driver. Not an
> issue here (UDIDs are hardcoded), but it is why the sibling Conjugar driver hit trouble.

To recreate either after `simctl erase` or `simctl delete unavailable` removes them:

```bash
RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-26-3

xcrun simctl create "iPhone 17 Pro Max" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max \
  "$RUNTIME"

xcrun simctl create "Konjugieren iPad Screenshots" \
  com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M4-8GB \
  "$RUNTIME"
```

**The device-type id changed.** Xcode 26 splits the M4 into 8 GB and 16 GB variants, so the
bare `…iPad-Pro-13-inch-M4` no longer resolves — use `…iPad-Pro-13-inch-M4-8GB` (which is what
the existing sim is). The M4 type is still offered on the 26.3 runtime even though a fresh
Xcode install seeds only an M5, so creating it by hand is the way to get an M4.

After creation, copy the new UDIDs into `udid_for()` in the driver.

**Why paren-free names?** The driver bypasses `_resolve_udid.sh`, so its regex-pattern bug (parens in `TARGET_SIM` break the match — see `Prompts/bug-resolve-udid-regex-special-chars.md` in the `ios-build-verify` repo) doesn't bite this workflow. But other `ios-build-verify` operations against these sims (`tap_tab.sh`, `dismiss_onboarding.sh`, manual `launch_app.sh`) do source it. The iPad's Apple-default name `iPad Pro 13-inch (M4)` contains regex specials; renaming to `Konjugieren iPad Screenshots` keeps everything compatible. The iPhone's default name is already paren-free.

## The Workarounds

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

6. **Soft keyboard suppression** (`take_screenshots.sh::ensure_soft_keyboard, keyboard_is_visible`)
   *Symptom:* Simulator forwards host hardware-keyboard events; the soft keyboard is suppressed by default. *Fix:* send Cmd+K via `osascript` (Simulator's "Toggle Software Keyboard").

   **Corrected 2026-07-18 — the idempotency guard was broken.** It counted AXTree elements
   labelled `space`, which is *always zero*: the keyboard runs in its own process and does not
   appear in a full `axe describe-ui` dump at all. Since Cmd+K is a **toggle** whose state
   persists in Simulator across app launches, the guard never firing means the second
   `quiz_mid` cell of a sweep switches the keyboard back **off** — the four `quiz_mid` shots
   alternate keyboard/no-keyboard, silently, in a run that reports success. `describe-ui
   --point` *can* see the keyboard (same trick as workaround #12 on the StoreKit modal), so
   `keyboard_is_visible` now probes a mid-keyboard coordinate and treats a ≤2-character label
   (`g`) as keys-present. Not the space bar — it reports a blank label, indistinguishable from
   "nothing found". `ensure_soft_keyboard` also re-checks after toggling and warns if it did
   not land.

   The probe points (`220,760` iPhone / `516,1120` iPad) were validated on iOS 26.3 in
   Conjugar. They are a property of the **device**, not the app, and this driver's two sims are
   the same device types — but they have not been run against *this* app. Verify on first use.

7. **StoreKit modal AX gating** (`take_screenshots.sh::disable_review_prompt`)
   *Symptom:* the "Enjoying Konjugieren?" review modal opaques the AXTree mid-loop. *Fix:* pre-seed `lastReviewPromptDate` to now via `simctl spawn defaults write` so the 180-day cooldown blocks subsequent prompts.

8. **iPhone tab-bar overlap on InfoBrowseView** (`take_screenshots.sh::scroll_info_browse_for, nav_info_view`)
   *Symptom:* `info_row_praesens_indikativ` sits at y≈873 on iPhone, overlapping the tab-bar hit zone (y≈877+). *Fix:* 117pt slow-drag swipe-up before tap.

9. **`axe --id` typeMismatch on iPad** (`take_screenshots.sh::tap_id`)
   *Symptom:* `axe tap --id` and `axe tap --label` throw a Swift `typeMismatch` decoding error in some iPad screen states (e.g., QuizView pre-Start). *Fix:* route all `tap_id` calls through `tap_id_first` (describe-ui + coord-tap) — same path as workaround #3.

10. **Multi-sim window focus** (`take_screenshots.sh::ensure_soft_keyboard`)
    *Symptom:* with both sims booted, Cmd+K hits whichever Simulator window is frontmost. *Fix:* AXRaise the target sim's window by title-substring match before sending the keystroke.

    **The match is by device *family* substring (`iPhone` / `iPad`), so it disambiguates only
    while exactly one simulator per family is booted** — which is what a normal sweep produces.
    Boot a second iPhone or iPad (easy while testing) and AXRaise can raise the wrong window;
    the keystroke lands on a sim that isn't being screenshotted and `quiz_mid` comes out
    keyboard-less. Observed in Conjugar with four windows open. Workaround #6's post-toggle
    check catches it and logs `soft keyboard still not visible after Cmd+K`; if you see that,
    run `osascript -e 'tell application "System Events" to tell process "Simulator" to get name
    of every window'` and shut down extra sims of that family.

    Also note the AppleScript's `delay` after `activate` is now **0.5 s** (was 0.2 s): a
    freshly-activated Simulator briefly reports no windows, and the resulting `-1719 "Invalid
    index"` error reads exactly like a missing Accessibility permission. It is not one.

11. **Localized onboarding labels** (`take_screenshots.sh::ONBOARDING_LABELS`)
    *Symptom:* the onboarding-Skip button label is localized (`Skip` / `Überspringen`). *Fix:* array of all known labels; the wait-for-render loop tries each.

12. **Lang-agnostic StoreKit dismiss** (`take_screenshots.sh::dismiss_review_prompt`)
    *Symptom:* StoreKit prompt button labels are system-localized (`Not Now` / `Nicht jetzt`); the modal also has a single-button and a post-star-tap two-button state. *Fix:* vertical sweep of `describe-ui --point` at a known x-center, tap the bottommost `AXButton` found.

13. **Tutor unavailability row in `info_browse`** (`Konjugieren/Models/KonjugierenTips.swift::TutorDisplay`)
    *Symptom:* the screenshot host can't resolve Apple Intelligence as available (CLAUDE.md's iOS 26.3+ host-eligibility gate), so `InfoBrowseView` substitutes `TutorUnavailableRowView` for `TutorRowView` and both `info_browse` shots ship a status row reading "Apple Intelligence is being configured…" or "…isn't available on this device." Honest on a device, reads as a defect in a store listing. *Fix:* set the compile-time `TutorDisplay.tutorUnavailableRowEnabled` to `false` before the sweep, restore after (see *Disable the tutor row first*). The guard is on the `else if` branch only, so it can never suppress a working tutor. Observed reason on this host is `.modelNotReady`, not the `.deviceNotEligible` one might expect — both take the same branch, so the switch covers either.

14. **Tips and onboarding intruding on captures** (`Konjugieren/Models/KonjugierenTips.swift::TipDisplay, OnboardingDisplay`)
    *Symptom:* TipKit renders "Try the Quiz" over `verb_browse` on a fresh install, and the first-launch onboarding cover auto-presents over whatever is being captured. *Fix:* set both compile-time switches `false` before the sweep, restore after (see *Flip the kill switches first*).

    These make workarounds #2 and #11 — the Skip-label interleave during `wait_for_render` — a **belt-and-braces safety net rather than the primary defense.** Keep them: they cost nothing when the cover never appears (the poll just doesn't find a Skip button), and they still cover the case where an operator forgets the switch. But the switch is the reliable mechanism, because the interleave is a race against presentation timing and the switch is not.

## Per-View Navigation Recipes

> **Tab coordinates are unverified since 2026-07-18.** The sibling app Conjugar re-measured its
> iPad tab centers from the AXTree and found the long-inherited values (`355 / 441.5 / 523 /
> 587.75 / 667.25`) landed inside the right tab but 3–6 pt off-center. **Those corrected numbers
> do not transfer to this app** — iPad tab widths follow the localized label text, and German
> labels differ from Spanish. Re-measure here rather than copying; unlike the iPhone pill (whose
> children are not exposed), the iPad's top bar reports each tab as an `AXRadioButton`:
>
> ```bash
> axe describe-ui --udid <IPAD_UDID> \
>   | jq '[.. | objects | select(.role? == "AXRadioButton")] | .[] | {AXLabel, AXFrame}'
> ```
>
> Center = `x + w/2`. An off-center-but-working tap is the early warning that geometry drifted.

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
| `info_row_<stableKey>` identifiers | `verify_screen_loaded info_row_dedication` (screen 6 settle); `tap_id_first info_row_praesens_indikativ` (screen 7) | `Konjugieren/Views/InfoBrowseView.swift` |
| `quiz_start_button`, `quiz_answer_field` identifiers | quiz nav for screens 5 and 8 | `Konjugieren/Views/QuizView.swift` |
| `results_score` identifier | `verify_screen_loaded results_score` after the 30-answer loop | `Konjugieren/Views/ResultsView.swift` |
| `TipDisplay.tipsEnabled`, `OnboardingDisplay.onboardingEnabled`, `TutorDisplay.tutorUnavailableRowEnabled` | Operator flips all three `false` pre-sweep; the `sed` recipes match the declaration text verbatim, so renaming a constant breaks the recipe silently | `Konjugieren/Models/KonjugierenTips.swift` |
| `Tips.configure()` call site | `tipsEnabled` suppresses tips by *not configuring TipKit*; moving `Tips.configure()` out from behind that guard re-enables every tip app-wide | `Konjugieren/App/KonjugierenApp.swift` |

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

- **New conjugationgroup or family.** If the change alters which 9 views ship as App Store screenshots, update [`docs/screenshot-plan.md`](screenshot-plan.md) first; the driver's `VIEWS` array follows.
- **New device size class.** Add the device-class label to `DEVICES`, add a UDID arm to `udid_for()`, calibrate `tab_coords_for()` (top vs. bottom tab bar — iPad's regular size class uses a top segmented bar at y=54; iPhone's is a bottom pill bar at y=899.3), and verify the per-view scroll values still apply.
- **`axe` upstream fix for the iPad `--id` `typeMismatch` bug.** If a future `axe` release fixes the bug, `tap_id` can be simplified back to `axe tap --id` directly. The driver's `tap_id_first` is currently always-on; after upstream fix it can become iPad-only or be removed.

## Known Gotchas

- **Run `scripts/verify_store_media.sh` before every upload.** It walks a bundle (or the
  `~/Desktop/Final/Konjugieren` video folder) and asserts accepted dimensions, absence of
  alpha, and — for previews — duration bounds, H.264 level, stream count, frame rate, and
  audio bit rate. It grades in two tiers: **blocking** for things known to stop an upload
  (wrong dimensions, alpha, duration outside 15–30 s) and **advisory** for spec deviations
  this app has shipped anyway (Level 5.0/5.1, 125 kbps audio, a stray timecode track). None
  of it is visible in a screenshot review.
- **A valid screenshot size can still be the wrong size.** App Store Connect exposes one
  tile per device family, and which size it wants follows what the app shipped last time.
  Konjugieren's 6.9"/13" captures have matched its tiles so far; Conjuguer's 2.0 page
  offered only a 6.5" tile and rejected the same 1320 × 2868 size. Read the drop zone
  before building a bundle — see [`docs/screenshot-plan.md`](screenshot-plan.md).
- **TipKit popovers surface mid-sweep — now suppressible.** The "Try the Quiz" tip renders on `verb_browse` (sweep view #1) on any fresh install, and other tips can appear elsewhere depending on TipKit eligibility. An earlier revision of this playbook said the driver couldn't suppress these and told you to visually review instead; `TipDisplay.tipsEnabled` now handles it (see *Flip the kill switches first*). Visual review is still worth doing, but it is no longer the only defense.
- **Apple Intelligence Tutor surfaces are gated on Intel-Mac hosts, and this *does* affect the sweep.** Per CLAUDE.md, the Tutor row in InfoBrowseView, the `ErrorExplainerView` card in QuizView, and the Tutor page in OnboardingView don't render as live features on Intel-Mac simulators with iOS 26.3+. `info_browse` is one of the 9 target views, and `InfoBrowseView` doesn't simply omit the tutor when the model is unavailable — it substitutes `TutorUnavailableRowView`, which states the reason ("Apple Intelligence is being configured…" / "…isn't available on this device."). So both `info_browse` shots carry that row unless `TutorDisplay.tutorUnavailableRowEnabled` is set `false` (see *Disable the tutor row first* above). An earlier revision of this playbook claimed no target view was Tutor-gated; that was wrong.
- **Review-prompt cooldown is per-install.** `disable_review_prompt` pre-seeds `lastReviewPromptDate` for in-run prompts, but a manual screenshot capture of the StoreKit modal would still require uninstalling/reinstalling first.
- **iPad first-boot is ~70s on a fresh sim.** Data-migration plugins (keychain, gestalt, MobileSafari, locationd, preferences) initialize on first boot. Subsequent boots are ~22s. The driver's `WAIT_FOR_RENDER_BUDGET_S=20` accommodates the post-launch render poll, but the `xcrun simctl bootstatus -b` step itself can block for ~70s during that initial boot. Don't kill the sweep thinking it's hung — `bootstatus -b` is doing the right thing.
