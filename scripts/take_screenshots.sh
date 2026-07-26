#!/usr/bin/env bash
# Drive ios-build-verify (and axe/simctl directly) through the 36 App Store
# screenshots described in docs/screenshot-plan.md.
#
# Usage:
#   scripts/take_screenshots.sh  # all 36
#   scripts/take_screenshots.sh --device "iPhone 17 Pro Max"  # 18
#   scripts/take_screenshots.sh --lang de  # 18
#   scripts/take_screenshots.sh --view family_browse  # 4
#   scripts/take_screenshots.sh --device "iPhone 17 Pro Max" --lang de --view quiz_results  # 1
#
# See docs/screenshot-playbook.md for setup, recovery guidance, and a
# cross-referenced workarounds index. Calibration values and per-view nav
# functions are inline below.
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
#
# Re-verified 2026-07-18 after a large simulator prune (all iOS 18 and iOS 26.0
# devices were deleted machine-wide): BOTH of these survived and are on iOS 26.3.
# Hardcoding is why — a name-resolving driver would have had to be re-pointed.
# The trade is that a future prune CAN silently kill them, so check first:
#   xcrun simctl list devices | grep -E 'E23163FA|E73F9CB3'
# Both must print, and neither may say "unavailable". The iPad is the renamed
# "Konjugieren iPad Screenshots" (device type iPad-Pro-13-inch-M4-8GB) — the
# rename is deliberate, see the playbook.
udid_for() {
  case "$1" in
    "iPhone 17 Pro Max")     echo 'E23163FA-C903-42F3-9711-56F2FB6B2941' ;;
    "iPad Pro 13-inch (M4)") echo 'E73F9CB3-41E7-4418-AFC7-928180536EEA' ;;
  esac
}

# Tab-bar pixel centers (logical points). Order: verbs families quiz info settings.
#
# The iPad values are per-language and the iPhone values are not, because the two
# size classes lay the tab bar out differently. iPhone (compact) uses the bottom pill,
# which distributes items into equal-width slots: the label grows from "Settings" to
# "Einstellungen" but the slot center does not move, so one set of coordinates serves
# both languages. iPad (regular) uses a top segmented bar that sizes each segment to
# its content, so every label length shifts all centers downstream of it.
#
# Re-measured 2026-07-26 from AXRadioButton frames (center = x + w/2). The English
# iPad row confirmed the long-inherited values exactly; German runs up to 20.5 pt to
# the left of it. The old English-only numbers did still land inside every German tab,
# so this is hardening rather than a bug fix. But the German Info tab cleared by only
# 16.75 pt, which is the margin that would vanish first if a label were retranslated.
# Re-measure with:
#   axe describe-ui --udid <UDID> \
#     | jq '[.. | objects | select(.role? == "AXRadioButton")] | .[] | {AXLabel, AXFrame}'
# The iPhone pill exposes no AXRadioButton children at all; verify it instead by
# probing each coordinate with `axe describe-ui --point "<x>,899.3"` and reading the
# label that comes back.
tab_coords_for() {
  local device="$1" lang="$2"
  case "$device" in
    "iPhone 17 Pro Max")
      echo "67,899.3 142.7,899.3 220,899.3 296.2,899.3 372.6,899.3"
      ;;
    "iPad Pro 13-inch (M4)")
      case "$lang" in
        de) echo "334.5,54 426.75,54 508.75,54 573.5,54 673,54" ;;
        *)  echo "355,54 441.5,54 523,54 587.75,54 667.25,54" ;;
      esac
      ;;
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

# iPad's verb_browse_anchor renders slowly (3,572 verbs in regular size class).
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
}

# Tab centers depend on the language on iPad, so they are resolved per-language
# rather than once per device. See tab_coords_for.
apply_lang_state() {
  IFS=' ' read -ra CURRENT_TAB_CENTERS <<< "$(tab_coords_for "$DEVICE" "$1")"
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

# Poll until an identifier has left the AX tree, which is how we know a screen has actually
# been navigated away from.
#
# tap_id_first's fixed 0.7 s settle is enough for a row that swaps in a light screen, but
# InfoView lays out a rich-text article of roughly 16,000 characters and needs closer to 2 s.
# The 2026-07-26 sweep captured the Info list in all four info_view cells for exactly this
# reason: the tap was landing, and the screenshot fired mid-transition. Nothing reported an
# error, because nothing had gone wrong yet at the moment the shot was taken.
#
# Waiting on a condition rather than a longer duration is the point. A bigger sleep would fix
# it on this machine and silently regress on a slower one, and would cost every fast cell the
# same delay.
wait_for_id_absent() {
  local id="$1"
  local deadline=$(($(date +%s) + WAIT_FOR_RENDER_BUDGET_S))
  while [[ $(date +%s) -lt $deadline ]]; do
    if ! axe_has_id "$id"; then
      sleep 0.4  # let the incoming screen settle after the outgoing one is gone
      return 0
    fi
    sleep 0.3
  done
  log "wait_for_id_absent timed out (${WAIT_FOR_RENDER_BUDGET_S}s) waiting for $id to disappear"
  return 0
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

# Is the soft keyboard currently on screen?
#
# The keyboard belongs to a separate process, so it does NOT appear in the app's
# `axe describe-ui` tree at all — a full-tree dump of a screen with the keyboard
# plainly visible returns zero keyboard elements. `describe-ui --point` *does*
# see it, so probe a coordinate in the middle of the key field and ask what is
# under it: a single-character label ("g") means keys are there; anything longer
# is the app's own content showing through, i.e. no keyboard.
#
# The point is deliberately mid-keyboard rather than on the space bar: space
# reports a blank label, indistinguishable from "nothing found".
#
# Probe points were validated on iPhone 17 Pro Max and iPad Pro 13-inch (M4) on
# iOS 26.3 (in the sibling app Conjugar). They are a property of the *device*,
# not the app; this driver's two sims are those same device types (the iPad is
# the renamed "Konjugieren iPad Screenshots", still an iPad-Pro-13-inch-M4-8GB),
# so they carry over. Re-check if the device list changes.
keyboard_is_visible() {
  local probe labels
  case "$DEVICE" in
    "iPhone 17 Pro Max")     probe="220,760"  ;;
    "iPad Pro 13-inch (M4)") probe="516,1120" ;;
    *) return 1 ;;
  esac
  labels=$(axe describe-ui --point "$probe" --udid "$UDID" 2>/dev/null \
    | jq -r '[.. | objects | select(.AXLabel? != null and .AXLabel != "") | .AXLabel] | join("|")' 2>/dev/null)
  [[ -n "$labels" && ${#labels} -le 2 ]]
}

# Soft keyboard is suppressed by default because Simulator.app forwards host
# hardware-keyboard events. Cmd+K is the Simulator menu's "Toggle Software
# Keyboard" — sending it via AppleScript makes the keyboard appear.
#
# Cmd+K is a TOGGLE whose state persists in Simulator across app launches and
# across cells, so the visibility guard is load-bearing, not an optimization:
# without it the second quiz_mid cell of a sweep toggles the keyboard back OFF
# and the four quiz_mid shots alternate keyboard/no-keyboard. The original guard
# counted AXTree elements labelled "space", which on iOS 26 is always zero (see
# keyboard_is_visible), so it never fired — the bug this replaces.
ensure_soft_keyboard() {
  local window_match
  if keyboard_is_visible; then
    return 0
  fi
  # Raise the target sim's window, then send Cmd+K. With both sims booted,
  # whichever window is frontmost catches the toggle — must be explicit. The
  # match is by device *family* substring, so it is unambiguous only while
  # exactly one simulator per family is booted (what a normal sweep produces);
  # a stray second iPhone/iPad sim can make AXRaise pick the wrong window, which
  # the post-toggle check below is what surfaces.
  case "$DEVICE" in
    "iPhone 17 Pro Max")     window_match="iPhone" ;;
    "iPad Pro 13-inch (M4)") window_match="iPad" ;;
    *) window_match="" ;;
  esac
  # `delay 0.5`, not 0.2: with a freshly-activated Simulator the window list is
  # briefly unenumerable and AXRaise fails with -1719 "Invalid index", which
  # reads exactly like a missing-permission failure and sends you chasing the
  # wrong thing.
  #
  # Retried, and never fatal. That same unenumerable window list is a race, not a
  # steady state, and the first quiz_mid cell of a sweep runs moments after a fresh
  # install, which is exactly when it loses. Returning non-zero here used to abort
  # the entire sweep through `set -e`, throwing away every remaining cell over one
  # transient. A genuine permission failure fails all three attempts and still gets
  # a warning, and the keyboard_is_visible check below reports the real outcome
  # either way, so continuing costs at most one reviewable screenshot.
  #
  # The keystroke is gated on Simulator actually being frontmost, and that guard is
  # NOT redundant with the AXRaise above. Retrying does not help the case it catches:
  # when the raise silently fails to take focus, `keystroke` still succeeds — it just
  # lands in whichever app *is* frontmost. Observed on 2026-07-26 in the Conjugar repo,
  # where a stray Cmd+K launched the Fitness app on the host Mac while the sweep
  # reported nothing wrong. osascript returns 0 in that case, so the retry loop sees a
  # success and the post-toggle keyboard_is_visible check reports only that the keyboard
  # is missing, never that the keystroke went somewhere else. Checking frontmost first
  # turns a silent misfire into a log line that names the app that caught it.
  local attempt
  local raised=false
  local front
  for attempt in 1 2 3; do
    if osascript -e 'tell application "Simulator" to activate' \
              -e 'delay 0.5' \
              -e "tell application \"System Events\" to tell process \"Simulator\" to perform action \"AXRaise\" of (first window whose title contains \"$window_match\")" \
              -e 'delay 0.3' \
              >/dev/null 2>&1; then
      front=$(osascript -e 'tell application "System Events" to name of first process whose frontmost is true' 2>/dev/null || true)
      if [[ "$front" != "Simulator" ]]; then
        log "AppleScript Cmd+K attempt $attempt: frontmost is '${front:-unknown}', not Simulator; not sending the keystroke"
        sleep 1.0
        continue
      fi
      if osascript -e 'tell application "System Events" to keystroke "k" using {command down}' >/dev/null 2>&1; then
        raised=true
        break
      fi
    fi
    log "AppleScript Cmd+K attempt $attempt failed; retrying"
    sleep 1.0
  done
  if [[ "$raised" != true ]]; then
    log "warning: AppleScript Cmd+K failed 3x (accessibility permission for /usr/bin/osascript, or Simulator never came frontmost)"
    return 0
  fi
  sleep 0.9  # let keyboard slide-up animation complete
  # Confirm the toggle landed. Cmd+K is fire-and-forget — osascript returns 0
  # whether or not Simulator acted — so without this a keyboard-less quiz_mid
  # shot is silent.
  if ! keyboard_is_visible; then
    log "warning: soft keyboard still not visible after Cmd+K on $DEVICE"
  fi
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
# multiple AX elements, axe tap refuses to disambiguate, so we extract one match's
# AXFrame and tap its center.
#
# Pick the match with the LARGEST frame area, not the first one. The original took the
# first match and justified it with "the children share the parent NavigationLink's
# bounds", which stopped being true: an InfoBrowseView row reports its heading as a
# separate AXStaticText sitting *above* the tappable AXButton (heading y=846 h=20.5,
# button y=870.5 h=38 on iPad), and a depth-first [0] returns the heading. Tapping
# non-interactive static text does nothing, which is how the 2026-07-26 sweep captured
# the Info list in all four info_view cells with no error anywhere.
#
# Preferring an AXButton was tried first and is wrong. On iPad the verb row exposes its
# translation and family tag as AXButtons while the infinitive is AXStaticText, so that
# rule tapped "become" instead of "werden" and stopped navigating: it fixed info_view and
# broke verb_view. Largest-area is the rule that holds on every screen here, because the
# element standing for the whole row is the widest one. It reduces to the old behaviour
# wherever the old behaviour worked (both verb rows, family rows) and picks the button on
# both info rows, where its frame is 5x to 13x the heading's.
tap_id_first() {
  local id="$1" frame x y w h cx cy
  frame=$(axe describe-ui --udid "$UDID" 2>/dev/null \
    | jq -r --arg id "$id" '
        def area:
          capture("\\{\\{(?<x>[-0-9.]+), *(?<y>[-0-9.]+)\\}, *\\{(?<w>[-0-9.]+), *(?<h>[-0-9.]+)\\}\\}")
          | (.w | tonumber) * (.h | tonumber);
        [.. | objects | select(.AXUniqueId? == $id and (.AXFrame? != null))] as $matches
        | (($matches | max_by(.AXFrame | area)) // $matches[0] // {})
        | .AXFrame // ""')
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

# Largest frame-to-frame difference (ImageMagick -metric AE) still considered "settled".
#
# Measured on 2026-07-26 rather than guessed. A static screen scores 0. The quiz screen,
# whose text cursor blinks and whose elapsed-time counter ticks, scores 7.5e6 to 1.6e7 and
# never settles below that. Two genuinely different screens score 1.8e10. Benign motion and
# a real transition are three orders of magnitude apart, so 1e8 sits in open space between
# them: about 6x the noisiest legitimate screen and 180x below a screen still cross-fading.
STABLE_PIXEL_TOLERANCE=100000000

# Wait until the screen stops changing, by comparing successive screenshots.
#
# Three separate timing races produced wrong captures in this sweep, and only this check
# would have caught all three. Two were fixable by waiting on the AX tree, but the third was
# not: switching tabs on iPad cross-fades, and verb_browse_anchor leaves the AX tree within
# 0.3 s while the fade is still visibly running, so the iPad's family_browse and settings
# shots came out with the verb list ghosted through them. Accessibility state answers "has
# the view hierarchy changed"; a screenshot is graded on "has the image stopped moving", and
# those are different questions.
#
# Never fatal, and bounded: if the screen genuinely will not settle the loop gives up, logs,
# and the capture proceeds to be reviewed like any other.
wait_for_stable_screen() {
  local dir previous current differing i
  if ! command -v magick >/dev/null 2>&1; then
    sleep 1.0
    return 0
  fi
  dir=$(mktemp -d)
  previous="$dir/previous.png"
  current="$dir/current.png"
  if ! axe screenshot --udid "$UDID" --output "$previous" >/dev/null 2>&1; then
    rm -rf "$dir"
    sleep 1.0
    return 0
  fi
  for i in 1 2 3 4 5 6 7 8; do
    sleep 0.35
    axe screenshot --udid "$UDID" --output "$current" >/dev/null 2>&1 || break
    # `|| true` is load-bearing: `magick compare` exits 1 whenever the images differ, which
    # is the normal case here, and under `set -o pipefail` that makes the assignment fail and
    # `set -e` abort the sweep. The first attempt at this function died after one screenshot.
    differing=$(magick compare -metric AE "$previous" "$current" null: 2>&1 | awk '{print $1}' || true)
    # awk, not [[ -le ]]: the metric comes back in scientific notation (1.80683e+10).
    if [[ -n "$differing" ]] \
       && awk -v d="$differing" -v t="$STABLE_PIXEL_TOLERANCE" 'BEGIN { exit !(d + 0 <= t + 0) }'; then
      rm -rf "$dir"
      return 0
    fi
    mv "$current" "$previous"
  done
  log "wait_for_stable_screen: screen still changing after 8 samples on $DEVICE"
  rm -rf "$dir"
  return 0
}

take_screenshot() {
  local slug="$1"
  wait_for_stable_screen
  mkdir -p "$(pwd)/docs/screenshots"
  local ts out
  ts=$(date +%Y%m%d-%H%M%S)
  out="$(pwd)/docs/screenshots/${ts}-${slug}.png"
  axe screenshot --udid "$UDID" --output "$out" >/dev/null
  # axe writes RGBA; App Store Connect rejects any screenshot with an alpha channel
  # ("Images can't include alpha channels or transparencies"), so flatten at capture
  # rather than discovering it at upload time. Every version_2 file is RGBA.
  if command -v magick >/dev/null 2>&1; then
    magick "$out" -background white -alpha remove -alpha off "$out"
  else
    log "WARNING: magick not found; $out keeps its alpha channel and will be rejected"
  fi
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
  # iPad's segmented tab can finish its highlight animation before the underlying
  # NavigationStack swaps content — without this poll, the screenshot captures
  # VerbBrowseView with the Info tab visually highlighted (race observed on
  # iPad+de+info_browse in particular). Anchoring on the first info row gates
  # the screenshot until the list is actually rendered.
  verify_screen_loaded info_row_dedication
  swipe_up_pts "$(scroll_info_browse_for "$DEVICE")"
}

nav_info_view() {
  tap_tab info
  # Gate on the list actually being rendered before scrolling or tapping, for the same
  # reason nav_info_browse does: the iPad's segmented tab finishes its highlight animation
  # before the NavigationStack swaps content, so an immediate tap can land on the outgoing
  # screen.
  verify_screen_loaded info_row_dedication
  # Same scroll as info_browse: praesens_indikativ sits at y=873 by default on
  # iPhone, which overlaps the tab-bar hit zone (y=877+). Scrolling moves it
  # into the safe middle band. iPad has 0 scroll (regular size class fits all rows).
  swipe_up_pts "$(scroll_info_browse_for "$DEVICE")"
  tap_id_first info_row_praesens_indikativ
  wait_for_id_absent info_row_dedication
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

# Scope the search to plugins/marketplaces/, not all of ~/.claude. The marketplace
# clone is a single git checkout that `claude plugin marketplace update` pulls to the
# latest release, so it has no version segment and yields exactly one match. The
# broader ~/.claude glob also reaches plugins/cache/ios-build-verify/<version>/, which
# holds several versions at once (0.2.1 and 0.3.1 on this machine) and is shared with
# Josh's other apps; find does not guarantee directory order, so an unsorted head -1
# there could nondeterministically build the App Store screenshots with a stale
# release. See CLAUDE.md "Build and Test Commands".
resolve_ibv_scripts() {
  local path
  path=$(find ~/.claude/plugins/marketplaces -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)
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
      apply_lang_state "$lang"

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
