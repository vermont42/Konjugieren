#!/usr/bin/env bash
# Drive ios-build-verify (and axe/simctl directly) through the 36 App Store
# screenshots described in docs/ScreenshotPlan.md.
#
# Usage:
#   scripts/take_screenshots.sh                                # all 36
#   scripts/take_screenshots.sh --device "iPhone 17 Pro Max"   # 18
#   scripts/take_screenshots.sh --lang de                      # 18
#   scripts/take_screenshots.sh --view family_browse           # 4
#   scripts/take_screenshots.sh --device "iPhone 17 Pro Max" \
#                               --lang de --view quiz_results  # 1
#
# Calibration values, decisions, and per-view nav recipes live in
# docs/screenshot-automation-step3-handoff.md and supporting docs.
#
# Compatible with macOS bash 3.2 (system default): uses case-statement lookup
# functions instead of associative arrays.

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

APP_BUNDLE_ID='biz.joshadams.Konjugieren'
ONBOARDING_LABELS=( "Skip" "Überspringen" )

DEVICES=( "iPhone 17 Pro Max" "iPad Pro 13-inch (M4)" )
LANGS=( en de )
VIEWS=( verb_browse verb_view family_browse family_detail quiz_mid \
        info_browse info_view quiz_results settings )

# ---------------------------------------------------------------------------
# Lookup tables (case statements; bash 3.2-compatible)
# ---------------------------------------------------------------------------

appearance_for() {
  case "$1" in
    verb_browse)   echo dark  ;;
    verb_view)     echo light ;;
    family_browse) echo dark  ;;
    family_detail) echo light ;;
    quiz_mid)      echo dark  ;;
    info_browse)   echo light ;;
    info_view)     echo dark  ;;
    quiz_results)  echo light ;;
    settings)      echo dark  ;;
  esac
}

# UDIDs hardcoded per docs/screenshot-calibration-values.md. Driver bypasses
# _resolve_udid.sh entirely; if sims are recreated, update these.
udid_for() {
  case "$1" in
    "iPhone 17 Pro Max")     echo 'E23163FA-C903-42F3-9711-56F2FB6B2941' ;;
    "iPad Pro 13-inch (M4)") echo 'E73F9CB3-41E7-4418-AFC7-928180536EEA' ;;
  esac
}

# Tab-bar pixel centers (logical points). Order: verbs families quiz info settings.
tab_coords_for() {
  case "$1" in
    "iPhone 17 Pro Max")     echo "67,899.3 142.7,899.3 220,899.3 296.2,899.3 372.6,899.3" ;;
    "iPad Pro 13-inch (M4)") echo "355,54 441.5,54 523,54 587.75,54 667.25,54" ;;
  esac
}

scroll_family_browse_for() {
  case "$1" in
    "iPhone 17 Pro Max")     echo 0 ;;
    "iPad Pro 13-inch (M4)") echo 0 ;;
  esac
}

scroll_info_browse_for() {
  case "$1" in
    "iPhone 17 Pro Max")     echo 117 ;;
    "iPad Pro 13-inch (M4)") echo 0   ;;
  esac
}

scroll_settings_for() {
  case "$1" in
    "iPhone 17 Pro Max")     echo 0 ;;
    "iPad Pro 13-inch (M4)") echo 0 ;;
  esac
}

# iPad's verb_browse_anchor renders slowly (990 verbs in regular size class).
wait_budget_for() {
  case "$1" in
    "iPhone 17 Pro Max")     echo 10 ;;
    "iPad Pro 13-inch (M4)") echo 20 ;;
  esac
}

# ---------------------------------------------------------------------------
# CLI parsing
# ---------------------------------------------------------------------------

DEVICE_FILTER=""
LANG_FILTER=""
VIEW_FILTER=""

usage() {
  sed -n '2,15p' "$0" | sed 's/^# \?//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) DEVICE_FILTER="$2"; shift 2 ;;
    --lang)   LANG_FILTER="$2";   shift 2 ;;
    --view)   VIEW_FILTER="$2";   shift 2 ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log() { echo "[take_screenshots] $*" >&2; }

# Per-iteration state (set inside loop):
UDID=""
DEVICE=""
DEVICE_SLUG=""
WAIT_FOR_RENDER_BUDGET_S=10
CURRENT_TAB_CENTERS=()

apply_device_state() {
  DEVICE="$1"
  UDID=$(udid_for "$DEVICE")
  DEVICE_SLUG="${DEVICE// /-}"
  WAIT_FOR_RENDER_BUDGET_S=$(wait_budget_for "$DEVICE")
  IFS=' ' read -ra CURRENT_TAB_CENTERS <<< "$(tab_coords_for "$DEVICE")"
}

ensure_booted() {
  if ! xcrun simctl list devices booted | grep -q "$UDID"; then
    log "booting $DEVICE ($UDID) — iPad first-boot can take ~70s"
    xcrun simctl boot "$UDID"
  fi
  xcrun simctl bootstatus "$UDID" -b >/dev/null
}

set_appearance() {
  xcrun simctl ui "$UDID" appearance "$1" >/dev/null
}

terminate_app() {
  xcrun simctl terminate "$UDID" "$APP_BUNDLE_ID" >/dev/null 2>&1 || true
}

uninstall_app() {
  xcrun simctl uninstall "$UDID" "$APP_BUNDLE_ID" >/dev/null 2>&1 || true
}

install_app() {
  xcrun simctl install "$UDID" "$1"
}

# Pre-seed the review-prompt cooldown so the StoreKit modal doesn't fire mid-
# loop. Settings stores lastReviewPromptDate as String(timeIntervalSince1970)
# (Settings.swift). The 180-day cooldown then blocks every subsequent prompt
# during this run.
disable_review_prompt() {
  xcrun simctl spawn "$UDID" defaults write biz.joshadams.Konjugieren \
    lastReviewPromptDate "$(date +%s)" >/dev/null 2>&1 || true
}

launch_with_lang() {
  local lang="$1" locale
  case "$lang" in
    en) locale='en_US' ;;
    de) locale='de_DE' ;;
    *) log "unknown lang: $lang"; return 1 ;;
  esac
  xcrun simctl launch "$UDID" "$APP_BUNDLE_ID" \
    -AppleLanguages "($lang)" \
    -AppleLocale "$locale" \
    -KONJUGIEREN_QUIZ_FIXTURE screenshot >/dev/null
}

wait_for_render() {
  local anchor="${1:-verb_browse_anchor}"
  local deadline=$(($(date +%s) + WAIT_FOR_RENDER_BUDGET_S))
  while [[ $(date +%s) -lt $deadline ]]; do
    local tree
    tree=$(axe describe-ui --udid "$UDID" 2>/dev/null || echo "{}")
    if echo "$tree" | jq -e --arg id "$anchor" \
        '[.. | objects | select(.AXUniqueId? == $id)] | length > 0' \
        >/dev/null 2>&1; then
      return 0
    fi
    for label in "${ONBOARDING_LABELS[@]}"; do
      if echo "$tree" | jq -e --arg l "$label" \
          '[.. | objects | select(.AXLabel? == $l)] | length > 0' \
          >/dev/null 2>&1; then
        axe tap --label "$label" --udid "$UDID" >/dev/null 2>&1 || true
        break
      fi
    done
    sleep 0.5
  done
  log "wait_for_render timed out (${WAIT_FOR_RENDER_BUDGET_S}s) on $DEVICE for $anchor"
  return 5
}

verify_screen_loaded() {
  wait_for_render "$1"
}

# tap_id routes through tap_id_first (describe-ui + coord tap). Two reasons:
# (1) SwiftUI propagates accessibilityIdentifier to child elements, so axe's
#     --id tap refuses to disambiguate when multiple matches exist.
# (2) `axe tap --id` and `axe tap --label` throw a Swift typeMismatch decoding
#     error in some iPad screen states (e.g., the QuizView pre-Start state).
#     describe-ui works in those states, so coord-tap is the safe path.
tap_id() {
  tap_id_first "$1"
}

# Soft keyboard is suppressed by default because Simulator.app forwards host
# hardware-keyboard events. Cmd+K is the Simulator menu's "Toggle Software
# Keyboard" — sending it via AppleScript makes the keyboard appear. Idempotent:
# checks for the "space" key in the AXTree first; only toggles if missing.
ensure_soft_keyboard() {
  local tree count window_match
  tree=$(axe describe-ui --udid "$UDID" 2>/dev/null || echo "{}")
  count=$(echo "$tree" | jq '[.. | objects | select((.AXLabel? // "" | ascii_downcase) == "space")] | length' 2>/dev/null || echo 0)
  if [[ "$count" -gt 0 ]]; then
    return 0
  fi
  # Raise the target sim's window, then send Cmd+K. With both sims booted,
  # whichever window is frontmost catches the toggle — must be explicit.
  case "$DEVICE" in
    "iPhone 17 Pro Max")     window_match="iPhone" ;;
    "iPad Pro 13-inch (M4)") window_match="iPad" ;;
    *) window_match="" ;;
  esac
  osascript -e 'tell application "Simulator" to activate' \
            -e 'delay 0.2' \
            -e "tell application \"System Events\" to tell process \"Simulator\" to perform action \"AXRaise\" of (first window whose title contains \"$window_match\")" \
            -e 'delay 0.3' \
            -e 'tell application "System Events" to keystroke "k" using {command down}' \
            >/dev/null 2>&1 || {
    log "warning: AppleScript Cmd+K failed (accessibility permission?)"
    return 1
  }
  sleep 0.7  # let keyboard slide-up animation complete
}

# axe type lacks HID-keycode mapping for non-ASCII characters (German umlauts,
# ß), so we route typing through the system pasteboard + Cmd+V. Works for any
# Unicode and bypasses the soft-keyboard-vs-hardware-keyboard distinction.
type_via_pasteboard() {
  local text="$1"
  printf '%s' "$text" | xcrun simctl pbcopy "$UDID"
  sleep 0.15
  axe key-combo --modifiers 227 --key 25 --udid "$UDID" >/dev/null  # Cmd+V
}

# SwiftUI propagates accessibilityIdentifier to child elements. When --id matches
# multiple AX elements, axe tap refuses to disambiguate — so we extract the first
# match's AXFrame and tap its center. Hits the parent NavigationLink because the
# children share its bounds.
tap_id_first() {
  local id="$1" frame x y w h cx cy
  frame=$(axe describe-ui --udid "$UDID" 2>/dev/null \
    | jq -r --arg id "$id" '[.. | objects | select(.AXUniqueId? == $id)][0].AXFrame // ""')
  if [[ -z "$frame" || "$frame" == "null" ]]; then
    log "tap_id_first: no element with id '$id'"
    return 1
  fi
  read -r x y w h <<< "$(echo "$frame" | sed -E 's/[{},]/ /g; s/  +/ /g' | awk '{print $1, $2, $3, $4}')"
  cx=$(awk "BEGIN{printf \"%.2f\", $x + $w/2}")
  cy=$(awk "BEGIN{printf \"%.2f\", $y + $h/2}")
  axe tap -x "$cx" -y "$cy" --udid "$UDID" >/dev/null
  sleep 0.7
}

tap_tab() {
  local tab_name="$1" index
  case "$tab_name" in
    verbs)    index=0 ;;
    families) index=1 ;;
    quiz)     index=2 ;;
    info)     index=3 ;;
    settings) index=4 ;;
    *) log "unknown tab: $tab_name"; return 1 ;;
  esac
  local center="${CURRENT_TAB_CENTERS[$index]}"
  axe tap -x "${center%,*}" -y "${center#*,}" --udid "$UDID" >/dev/null
  sleep 0.7
}

swipe_up_pts() {
  local pts="$1"
  [[ "$pts" -le 0 ]] && return 0
  local start_y=400
  local end_y=$((start_y - pts))
  axe swipe --start-x 200 --start-y "$start_y" \
            --end-x 200 --end-y "$end_y" --duration 1.0 \
            --udid "$UDID" >/dev/null
  sleep 0.5
}

read_fixture_answers_path() {
  local data_dir
  data_dir=$(xcrun simctl get_app_container "$UDID" "$APP_BUNDLE_ID" data 2>/dev/null)
  echo "$data_dir/Documents/screenshot_fixture_answers.json"
}

take_screenshot() {
  local slug="$1"
  mkdir -p "$(pwd)/docs/screenshots"
  local ts out
  ts=$(date +%Y%m%d-%H%M%S)
  out="$(pwd)/docs/screenshots/${ts}-${slug}.png"
  axe screenshot --udid "$UDID" --output "$out" >/dev/null
  log "captured: $out"
}

# ---------------------------------------------------------------------------
# Per-view nav functions
# ---------------------------------------------------------------------------

nav_verb_browse() {
  : # default landing; wait_for_render already ran in main loop
}

nav_verb_view() {
  tap_id_first verb_row_werden
}

nav_family_browse() {
  tap_tab families
  swipe_up_pts "$(scroll_family_browse_for "$DEVICE")"
}

nav_family_detail() {
  tap_tab families
  tap_id_first family_row_strong
}

nav_quiz_mid() {
  tap_tab quiz
  tap_id quiz_start_button
  sleep 1.0  # let Quiz.start() write fixture file + render question
  local fixture first_answer
  fixture=$(read_fixture_answers_path)
  first_answer=$(jq -r '.[0].answer' "$fixture")
  tap_id quiz_answer_field
  type_via_pasteboard "$first_answer"
  ensure_soft_keyboard
  sleep 0.3  # let keyboard settle before screenshot
}

nav_info_browse() {
  tap_tab info
  swipe_up_pts "$(scroll_info_browse_for "$DEVICE")"
}

nav_info_view() {
  tap_tab info
  # Same scroll as info_browse: praesens_indikativ sits at y=873 by default on
  # iPhone, which overlaps the tab-bar hit zone (y=877+). Scrolling moves it
  # into the safe middle band. iPad has 0 scroll (regular size class fits all rows).
  swipe_up_pts "$(scroll_info_browse_for "$DEVICE")"
  tap_id_first info_row_praesens_indikativ
}

nav_quiz_results() {
  tap_tab quiz
  tap_id quiz_start_button
  sleep 1.0
  local fixture
  fixture=$(read_fixture_answers_path)
  tap_id quiz_answer_field
  for i in $(seq 0 29); do
    local answer
    answer=$(jq -r ".[$i].answer" "$fixture")
    type_via_pasteboard "$answer"
    axe key 40 --udid "$UDID" >/dev/null
    sleep 0.3  # let next-question onChange fire and field re-focus
  done
  sleep 1.0  # let either results_score or review-prompt modal animate in
  if ! axe_has_id results_score; then
    log "results_score not in AX tree; dismissing review prompt"
    dismiss_review_prompt
    sleep 0.7
  fi
  verify_screen_loaded results_score
}

axe_has_id() {
  axe describe-ui --udid "$UDID" 2>/dev/null \
    | jq -e --arg id "$1" '[.. | objects | select(.AXUniqueId? == $id)] | length > 0' \
    >/dev/null 2>&1
}

# The "Enjoying Konjugieren?" review prompt is the system StoreKit dialog (per
# ReviewPrompterReal.swift), so its labels are system-localized — "Not Now" in
# English, "Nicht jetzt" in German, etc. The modal opaques the full AX tree, but
# describe-ui --point at coords inside the modal returns each element.
#
# Strategy: sweep a vertical line through the modal, tap the BOTTOMMOST button.
# State 1 (initial): only one dismiss button. State 2 (post-star-tap): Submit
# above Cancel — bottommost is Cancel, which dismisses. Lang-agnostic.
dismiss_review_prompt() {
  local x_center y last_button_y=""
  case "$DEVICE" in
    "iPhone 17 Pro Max")     x_center=220 ;;
    "iPad Pro 13-inch (M4)") x_center=512 ;;
    *) return 0 ;;
  esac
  for y in 540 575 610 645 680 715; do
    if axe describe-ui --point "${x_center},${y}" --udid "$UDID" 2>/dev/null \
       | grep -qE '"role" : "AXButton"'; then
      last_button_y=$y
    fi
  done
  if [[ -n "$last_button_y" ]]; then
    axe tap -x "$x_center" -y "$last_button_y" --udid "$UDID" >/dev/null 2>&1
    sleep 0.5
    return 0
  fi
  log "review-prompt button not found in vertical sweep"
  return 0
}

nav_settings() {
  tap_tab settings
  swipe_up_pts "$(scroll_settings_for "$DEVICE")"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

resolve_ibv_scripts() {
  local path
  path=$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)
  [[ -n "$path" ]] || { log "ios-build-verify scripts not found"; exit 2; }
  echo "$(dirname "$path")"
}

resolve_app_path() {
  local built_dir
  built_dir=$(xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren \
    -destination 'generic/platform=iOS Simulator' \
    -showBuildSettings 2>/dev/null \
    | awk -F= '/^[[:space:]]+BUILT_PRODUCTS_DIR / { gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit }')
  [[ -n "$built_dir" ]] || { log "could not resolve BUILT_PRODUCTS_DIR"; exit 2; }
  echo "$built_dir/Konjugieren.app"
}

filter_skip() {
  local value="$1" filter="$2"
  [[ -z "$filter" ]] && return 1
  [[ "$value" == "$filter" ]] && return 1
  return 0
}

main() {
  IBV_SCRIPTS=$(resolve_ibv_scripts)
  log "ibv scripts: $IBV_SCRIPTS"

  log "building once (install per device after)"
  "$IBV_SCRIPTS/build_app.sh"

  local app_path
  app_path=$(resolve_app_path)
  [[ -d "$app_path" ]] || { log "app bundle not found at $app_path"; exit 2; }
  log "app bundle: $app_path"

  for device in "${DEVICES[@]}"; do
    if filter_skip "$device" "$DEVICE_FILTER"; then continue; fi
    apply_device_state "$device"
    log "===== device: $device ($UDID) ====="
    ensure_booted
    log "uninstalling + installing fresh"
    uninstall_app
    install_app "$app_path"
    disable_review_prompt

    for lang in "${LANGS[@]}"; do
      if filter_skip "$lang" "$LANG_FILTER"; then continue; fi

      for view in "${VIEWS[@]}"; do
        if filter_skip "$view" "$VIEW_FILTER"; then continue; fi

        log "--- $device / $lang / $view ---"
        set_appearance "$(appearance_for "$view")"
        terminate_app
        launch_with_lang "$lang"
        wait_for_render
        "nav_$view"
        take_screenshot "${DEVICE_SLUG}-${lang}-${view}"
      done
    done
  done

  log "done."
}

main "$@"
