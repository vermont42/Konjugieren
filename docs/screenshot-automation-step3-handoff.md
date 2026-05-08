# Screenshot Automation Step 3 Handoff

Picks up at the **driver implementation + capture sweep**. Steps 1 and 2 are complete; this prompt hands Step 3 off to a fresh Claude Code session because the previous session's context grew past 250k tokens by Step 2's close.

## Mandatory reading, in this order

1. **[`docs/screenshot-automation-handoff.md`](screenshot-automation-handoff.md)** — original handoff with the full design from Step 1's audit phase. Skim sections "Decisions already made", "Driver structure", "Per-view nav recipes", "Critical mechanics".
2. **[`docs/screenshot-automation-answers.md`](screenshot-automation-answers.md)** — previous session's answers to Step-2 questions (10 resolutions). The Q5 `results_score` caveat is already implemented (commit `66216b3`).
3. **[`docs/screenshot-calibration-values.md`](screenshot-calibration-values.md)** — Step 2's output: per-device tab coords, scroll offsets, and 9 findings. **Read in full.**
4. [`docs/ScreenshotPlan.md`](ScreenshotPlan.md) — the spec (don't modify).

Skim, don't memorize. Refer back during driver authoring.

## State at handoff

- Branch `main`, pushed to `origin/main`.
- Relevant commits: `70850b3` (Step 1) → `66216b3` (`results_score`) → `8a2103d` (audit Q&A) → calibration commit (Step 2 outputs).
- Sims kept available for Step 3:
  - **iPhone**: UDID `E23163FA-C903-42F3-9711-56F2FB6B2941` — name `iPhone 17 Pro Max`, iOS 26.3.1.
  - **iPad**: UDID `E73F9CB3-41E7-4418-AFC7-928180536EEA` — name `Konjugieren iPad Screenshots`, iOS 26.3.1. (Renamed away from `iPad Pro 13-inch (M4)` to avoid the `_resolve_udid.sh` regex bug — see calibration Finding #1.)
- `.claude/ios-build-verify.config.sh` restored to `TARGET_SIM='iPhone 17'` (Josh's pre-Step-2 dev value). Driver carries its own per-device UDID resolution; **don't mutate the config**.

## Deliverables

### 1. `scripts/take_screenshots.sh` (new file)

Use the bash skeleton in the original handoff's "Driver structure" section as the starting point. Adaptations from that skeleton, with the source of each:

| From original handoff | Adaptation | Source |
|---|---|---|
| `apply_tab_coords` semantics ambiguous | Driver-local `TAB_COORDS` table + thin `tap_tab` wrapper that calls `axe tap` directly; bypass `tap_tab.sh` entirely | answers Q3 |
| `TARGET_SIM`-based sim resolution | Hardcode the two UDIDs in the driver; never invoke `_resolve_udid.sh` | calib Finding #1 (regex bug) |
| Reset cadence unclear | Per-device uninstall once before that device's loop; relaunch per (lang, view) within | answers Q4 |
| Quiz answer loop unclear | `tap_id quiz_answer_field` once at start; then 30× (`type_text` + Return + `sleep 0.3` for re-focus) | answers Q5 |
| Mid-quiz screenshot keyboard? | Visible — capture after `type_text` before submit | answers Q6 + ScreenshotPlan |
| iPad WAIT_FOR_RENDER_BUDGET | Bump to 20s (vs. iPhone's 10s); `verb_browse_anchor` exists but renders slowly with 990 verbs | calib Finding #5 |
| Scroll helper | `axe swipe --duration 1.0` (slow drag, gesture ≈ scroll, no momentum) | calib Finding #6 |
| Tab-coord region | iPhone bottom (y=899.3) / iPad top (y=54) | calib Finding #2 |
| `--only DEVICE/LANG/VIEW` flags | Add for re-running individual cells | answers Q10 |
| `results_score` anchor for screen 8 | Already exists (commit `66216b3`); use `verify_screen_loaded results_score` | answers Q5 caveat |

The exact numerical values for `TAB_COORDS` and `SCROLL_PX_*` are in `screenshot-calibration-values.md`. Copy them into the driver verbatim; don't re-derive.

### 2. End-to-end run

36 PNGs total: `9 views × 2 langs × 2 devices`. Output under `docs/screenshots/<timestamp>-<device>-<lang>-<view>.png` (gitignored — `screenshot.sh` writes here automatically). Visual review; iterate via `--only` flags on bad cells.

Estimated wall clock: ~30–45 min for both devices, dominated by build + sim cycles. The `--only` flag exists precisely to keep iteration cycles short.

### 3. Don't do these

- **Don't write `docs/screenshot-playbook.md`** — that's Step 4.
- **Don't delete** the original handoff, the questions/answers docs, the calibration values, or this Step-3 handoff. They get cleaned up at Step 4 close, all together.
- **Don't touch** `Localizable.xcstrings` or `docs/ScreenshotPlan.md` (the spec).
- **Don't relitigate** the 4 original decisions or the 10 Step-2 resolutions in the answers doc.

## Refined per-view nav recipes (Step-2-aware)

| # | View | Mode | Nav |
|---|---|---|---|
| 1 | VerbBrowseView | dark | Default landing. ≥20s render budget on iPad. |
| 2 | VerbView | light | `tap_id verb_row_werden` |
| 3 | FamilyBrowseView | dark | `tap_tab families` (no scroll either device) |
| 4 | FamilyDetailView | light | `tap_tab families` → `tap_id family_row_strong` |
| 5 | QuizView (mid) | dark | `tap_tab quiz` → `tap_id quiz_start_button` → `tap_id quiz_answer_field` → `type_text` first fixture answer → screenshot before submit |
| 6 | InfoBrowseView | light | `tap_tab info` → swipe `${SCROLL_PX_INFO_BROWSE[$DEVICE]}` (iPhone=117, iPad=0) |
| 7 | InfoView | dark | `tap_tab info` → `tap_id info_row_praesens_indikativ` (no scroll for navigation) |
| 8 | ResultsView | light | `tap_tab quiz` → `tap_id quiz_start_button` → loop 30× (`type_text` + Return + `sleep 0.3`) → `verify_screen_loaded results_score` |
| 9 | SettingsView | dark | `tap_tab settings` (no scroll either device) |

## Constraints

- `docs/screenshots/` is gitignored. Captured PNGs don't get committed.
- `MAIN_TABS_COORDS` in `.claude/ios-build-verify.config.sh` is gitignored. Don't mutate during Step 3.
- Tutor surfaces are gated on Intel-Mac hosts (CLAUDE.md). None of the 9 target screens are Tutor-gated; safe.

## Working-style notes (carry forward)

- **Concrete diff-style plans before code lands** — Josh reviews and approves each material change.
- **Single space after commas** in argument lists (CLAUDE.md "Swift Coding Conventions").
- **Educational explanations alongside changes** — explanatory output style stays active.
- **Project-stored facts over Claude Code memory** (CLAUDE.md "Memory Feature").
- **Narrow scope** — App Store screenshots only, not a general-purpose screenshot framework.

## Session-economy note

The Step 2 session's context grew to ~250k tokens, dominated by calibration screenshots and AXTree dumps accumulating across the conversation. If Step 3's driver authoring + capture sweep approaches similar growth (likely — the capture sweep alone produces 36 PNGs, plus iteration on misfires), plan a Step-4 handoff at that point too. Don't try to do all of Steps 3 and 4 in one fresh session.
