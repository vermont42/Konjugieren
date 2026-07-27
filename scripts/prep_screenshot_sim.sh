#!/usr/bin/env bash
# Prepare one simulator for one language of an App Store screenshot sweep.
#
#   scripts/prep_screenshot_sim.sh "iPad Pro 13-inch (M4)" de
#   scripts/prep_screenshot_sim.sh "iPhone 17 Pro Max" en
#
# Does the four steps of docs/screenshot-playbook.md "Clean Status Bar" IN THE ORDER
# THAT MATTERS, then prints proof that each landed:
#
#   set system language -> reboot -> RE-APPLY status bar override -> verify
#
# Why this is a script and not four commands in the playbook: `simctl status_bar
# override` is cleared by every shutdown/reboot but survives install/launch, while
# changing the system language REQUIRES a reboot. So an override applied before the
# language change is silently wiped, and that language's shots ship with a live
# wall-clock instead of the pinned 9:41. Nothing in a visual review catches it unless
# you happen to compare clocks across languages.
#
# The system language is not cosmetic on either device:
#   - iPad: the status bar shows a DATE, rendered in the system language, independent of
#     the app's own -AppleLanguages override. A sim left on French stamps
#     "Dimanche 26 juillet" onto English/German screenshots. The app's UI localizes
#     correctly regardless, which is why it is easy to miss.
#   - BOTH: the pinned time is locale-formatted — en_US renders "9:41", de_DE renders
#     "09:41". Set it on only one device and the two disagree within the same language.
#
# Ported from Conjugar 2026-07-26 (its sweeps found both the ordering trap and the
# windowless-simulator failure below). Two Konjugieren-specific adaptations, both
# matching what take_screenshots.sh already does here:
#   1. UDIDs are hardcoded rather than resolved by name, because this repo's sweep sims
#      are RENAMED ("Konjugieren iPad Screenshots"), so the device-class label the
#      driver takes on --device is not the simulator's name. Keeping the same map in
#      both files is what makes prep and driver address the same device.
#   2. The window check matches the device FAMILY substring ("iPad"), for the same
#      reason: the renamed sim's window is titled "Konjugieren iPad Screenshots – iOS
#      26.x", which contains "iPad" but not the class label. This mirrors
#      ensure_soft_keyboard's window_match exactly — the two must agree or prep will
#      relaunch Simulator on every run while the driver is perfectly happy.
#
# Run this once per (device, language) pair, then shoot that language's 9 views with
# scripts/take_screenshots.sh --device "<name>" --lang <lang>. Keep the device booted
# for the whole language pass so the override survives.

set -euo pipefail

DEVICE_NAME="${1:-}"
LANG_CODE="${2:-}"

if [[ -z "$DEVICE_NAME" || -z "$LANG_CODE" ]]; then
  echo "usage: $(basename "$0") <device-name> <en|de>" >&2
  exit 2
fi

case "$LANG_CODE" in
  en) LOCALE=en_US ;;
  de) LOCALE=de_DE ;;
  *) echo "unknown language '$LANG_CODE' (expected en or de)" >&2; exit 2 ;;
esac

# Keep in sync with take_screenshots.sh::udid_for — see note 1 in the header.
case "$DEVICE_NAME" in
  "iPhone 17 Pro Max")     UDID='E23163FA-C903-42F3-9711-56F2FB6B2941' ;;
  "iPad Pro 13-inch (M4)") UDID='E73F9CB3-41E7-4418-AFC7-928180536EEA' ;;
  *) echo "unknown device '$DEVICE_NAME' (expected a label from DEVICES in take_screenshots.sh)" >&2; exit 2 ;;
esac

# Keep in sync with take_screenshots.sh::ensure_soft_keyboard — see note 2 in the header.
case "$DEVICE_NAME" in
  "iPhone 17 Pro Max")     WINDOW_MATCH="iPhone" ;;
  "iPad Pro 13-inch (M4)") WINDOW_MATCH="iPad" ;;
  *) WINDOW_MATCH="" ;;
esac

if ! xcrun simctl list devices | grep -q "$UDID"; then
  echo "simulator $UDID ('$DEVICE_NAME') not found — see Simulator Setup in the playbook" >&2
  exit 2
fi

log() { echo "[prep_screenshot_sim] $*"; }

log "$DEVICE_NAME ($UDID) -> system language $LANG_CODE ($LOCALE)"

xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || xcrun simctl boot "$UDID"
xcrun simctl spawn "$UDID" defaults write -g AppleLanguages -array "$LANG_CODE"
xcrun simctl spawn "$UDID" defaults write -g AppleLocale -string "$LOCALE"

# The reboot is what makes the language take effect — and what clears the override,
# which is why the override is applied AFTER this and never before.
log "rebooting (required for the language change; also clears the status bar override)"
xcrun simctl shutdown "$UDID"
xcrun simctl boot "$UDID"
xcrun simctl bootstatus "$UDID" -b >/dev/null

# A `simctl boot` does not always give the device a Simulator.app WINDOW. When the
# reboot above lands while Simulator.app is already running, the device can come back
# booted-but-windowless: simctl and axe keep working (they talk to the device, not the
# UI), so nothing looks wrong — but take_screenshots.sh's ensure_soft_keyboard raises
# `first window whose title contains "iPad"`, finds no such window, and fails all three
# attempts with -1719 "Invalid index". The only visible symptom is one keyboard-less
# quiz_mid screenshot. Hit in Conjugar on 2026-07-26 (workaround #16).
#
# `open -a Simulator --args -CurrentDeviceUDID` does NOT fix it once Simulator is
# already running (verified — the args are ignored), and neither does File > Open
# Simulator. Quitting and relaunching does: on launch Simulator attaches a window to
# every already-booted device. This runs BEFORE the override because a quit can take
# the device down with it, and a re-boot would clear the override.
ensure_simulator_window() {
  local match="$1" attempt
  windows() {
    osascript -e 'tell application "System Events" to tell process "Simulator" to get name of every window' 2>/dev/null || true
  }
  if [[ "$(windows)" == *"$match"* ]]; then
    log "Simulator window matching '$match' is present"
    return 0
  fi
  log "no Simulator window matching '$match' — relaunching Simulator.app to attach one"
  osascript -e 'tell application "Simulator" to quit' >/dev/null 2>&1 || true
  sleep 3
  # A quit may have taken the device with it; bring it back before asking for a window.
  xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || {
    xcrun simctl boot "$UDID"
    xcrun simctl bootstatus "$UDID" -b >/dev/null
  }
  open -a Simulator
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    sleep 2
    if [[ "$(windows)" == *"$match"* ]]; then
      log "Simulator window matching '$match' attached (attempt $attempt)"
      return 0
    fi
  done
  log "warning: still no Simulator window matching '$match' — the quiz_mid soft keyboard"
  log "         (Cmd+K) will fail for this device; see workaround #16 in the playbook"
}
ensure_simulator_window "$WINDOW_MATCH"

log "re-applying status bar override"
# --time takes a bare clock string: "9:41 AM" and ISO strings are both rejected as
# "Invalid, non-ISO date/time string" on this runtime. The system renders AM/PM (or
# not) and the date itself from the locale set above.
# --cellularMode notSupported hides the cellular signal, correct for a Wi-Fi iPad;
# forcing --cellularBars instead paints a bogus "Carrier" onto a Wi-Fi-only device.
xcrun simctl status_bar "$UDID" override \
  --time "9:41" \
  --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode notSupported \
  --batteryState charged --batteryLevel 100

# Print proof both halves landed. A future reader should be able to see, rather than
# assume, that the override survived the reboot and the language is what was asked for.
log "verification:"
xcrun simctl status_bar "$UDID" list | sed 's/^/    /'
log "AppleLanguages is now: $(xcrun simctl spawn "$UDID" defaults read -g AppleLanguages | tr -d '\n ')"
log "ready — now run: scripts/take_screenshots.sh --device \"$DEVICE_NAME\" --lang $LANG_CODE"
