# Screenshot Automation Handoff — Answers

Answers to [`screenshot-automation-questions.md`](screenshot-automation-questions.md), authored by the previous session that wrote [`screenshot-automation-handoff.md`](screenshot-automation-handoff.md). Same numbering as the questions doc.

## 1. Critical: Step 1 appears not to be committed

**Step 1 was committed** in the previous session as commit `70850b3` ("prep screenshot automation — identifiers, quiz fixture, handoff prompt"), then pushed to `origin/main`. The push output confirmed `985934e..70850b3 main -> main`.

## 2. `docs/ScreenshotPlan.md` is untracked

`ScreenshotPlan.md` is **already committed** as part of `70850b3` — `git show 70850b3 --stat` lists it under "create mode 100644 docs/ScreenshotPlan.md". After `git pull` it will be in your tracked tree.

`screenshot-automation-handoff.md` is **also committed** in the same commit. Keep it tracked through Step 4. Once `screenshot-playbook.md` lands at the end of Step 4, the handoff doc can be deleted (it's a transitional artifact). Until then, it lives in the repo as the canonical record of why decisions were made the way they were.

`screenshot-automation-questions.md` (this fresh session's questions) and `screenshot-automation-answers.md` (this file) are also worth committing — they're the audit trail of session-to-session handoff and may be informative for the playbook later.

## 3. Tab-coordinate strategy: which option is canonical?

**Option (b) — driver-local `TAB_COORDS` table, bypass `tap_tab.sh`.** The handoff's bash skeleton showing `apply_tab_coords` plus a `TAB_COORDS` map was an unresolved inconsistency; the prose ("the latter is cleaner") is the authoritative answer.

`apply_tab_coords` is **not** for option (a). It's a small helper that selects the right `TAB_COORDS[$DEVICE]` entry into a shell variable for use by a custom `tap_tab` wrapper:

```bash
apply_tab_coords() {
  local device="$1"
  IFS=',' read -ra CURRENT_TAB_CENTERS <<< "${TAB_COORDS[$device]}"
}

tap_tab() {
  local tab_name="$1"
  local index
  case "$tab_name" in
    verbs)    index=0 ;;
    families) index=1 ;;
    quiz)     index=2 ;;
    info)     index=3 ;;
    settings) index=4 ;;
    *) echo "unknown tab: $tab_name" >&2; return 1 ;;
  esac
  local center="${CURRENT_TAB_CENTERS[$index]}"
  axe tap -x "${center%,*}" -y "${center#*,}"
}
```

This avoids: (i) mutating the gitignored `.claude/ios-build-verify.config.sh`, (ii) needing a trap-on-EXIT restore, (iii) fighting with `tap_tab.sh`'s preflight (which would refuse iPad coords against a 5-tab geometry mismatch).

Option (a) is rejected because rewriting `.claude/ios-build-verify.config.sh` from a script crosses tool boundaries and creates a recovery mess if interrupted. Driver-local state is cleaner.

## 4. State reset cadence between iterations

**Uninstall once per device.** Two onboarding skips total. Reasoning:

- **Per (device, lang, view)** is overkill — 36 fresh installs cost ~5 minutes total and add no value because we control all UserDefaults via launch args anyway.
- **Per (device, lang)** would reset Settings between languages, defeating any persisted state (though we don't rely on persisted state today, this rules out future-proofing).
- **Per device** is the right balance: clean install per device, then for each (lang, view) tuple, terminate + relaunch with launch args. The launch args (`-AppleLanguages`, `-KONJUGIEREN_QUIZ_FIXTURE`) override any persisted state per-launch. Onboarding's `hasSeenOnboarding` persists across language switches within the device, so only one skip per device.
- **Once at start** is risky: the review-prompt counter (`promptActionCount`) increments on `Current.reviewPrompter.promptableActionHappened()` calls (which fire on `viewVerbBrowseView` and `completeQuiz`). After 36 launches we'd risk the prompt firing mid-loop on `quiz_results`. Per-device uninstall resets the counter to 0 between devices, which is enough headroom.

Loop structure:

```bash
for DEVICE in "${DEVICES[@]}"; do
  ensure_simulator "$DEVICE"
  apply_tab_coords "$DEVICE"
  uninstall_app "$DEVICE"           # clean state per device
  build_app
  install_app "$DEVICE"
  for LANG in "${LANGS[@]}"; do
    for VIEW in "${VIEWS[@]}"; do
      xcrun simctl ui "$(udid_of "$DEVICE")" appearance "${APPEARANCE[$VIEW]}"
      "$IBV_SCRIPTS/terminate_app.sh"
      launch_with_lang "$LANG"
      "$IBV_SCRIPTS/dismiss_onboarding.sh"   # idempotent; fires once per device, no-op after
      "nav_$VIEW"
      "$IBV_SCRIPTS/screenshot.sh" "${DEVICE// /-}-${LANG}-${VIEW}"
    done
  done
done
```

## 5. Quiz Results (screen 8) loop mechanics

**The field auto-focuses after each submit** — the per-iteration `tap_id quiz_answer_field` is redundant after the first one. From `QuizView.swift`:

```swift
.onChange(of: quiz.currentIndex) {
  userInput = ""
  isTextFieldFocused = true
  isTextFieldA11yFocused = true
}
```

After successful submit, `quiz.currentIndex` increments → onChange fires → `userInput` clears + field re-focuses. The keyboard stays up; you can immediately type the next answer.

But: there's an animation/reflow window where the field re-focuses. If the driver `type_text` fires before the field is actually ready, characters may be lost. Recommend either a small `sleep 0.3` between submit and next type, or polling `describe_ui` until `quiz_answer_field`'s AXValue is empty again before typing.

Updated recipe:

```bash
nav_quiz_results() {
  tap_tab quiz
  tap_id quiz_start_button
  tap_id quiz_answer_field           # initial focus (subsequent iterations auto-focus)
  for i in $(seq 0 29); do
    type_text "$(jq -r ".[$i].answer" "$FIXTURE_ANSWERS")"
    submit_via_return                 # press Return — TextField has .submitLabel(.go)
    sleep 0.3                         # let next-question onChange fire and field re-focus
  done
  # Q30's submit triggers quiz.shouldShowResults = true → ResultsView sheet
  verify_screen_loaded results_score
}
```

**Important caveat:** ResultsView currently has **no accessibility identifier**. `verify_screen_loaded` would fail. Recommend adding `.accessibilityIdentifier("results_score")` to the score `Text` at line 32 of `ResultsView.swift` (the big `Text("\(displayedScore)")` element). Small one-line addition, follows the `verb_browse_anchor` pattern. This is a Step-1-style addition that the previous session missed; do it before running the screen 8 capture.

## 6. Mid-quiz screenshot (screen 5): keyboard visible or dismissed?

**Keyboard visible.** Confirmed by `docs/ScreenshotPlan.md` line 9:

> 5: QuizView: show quiz in progress with correct, proposed answer typed; randomness is fine; **ensure that virtual keyboard is visible**; DARK

The "user is mid-typing" framing is the marketing intent. After `type_text "mache"`, the keyboard is up — exactly the desired state. Screenshot before submit.

## 7. `dismiss_onboarding.sh` availability

**Confirmed present** in skill version 0.2.1. Read directly from SKILL.md:

> `scripts/dismiss_onboarding.sh` — Tap the first-launch onboarding dismiss button (Skip / Continue / Get Started) by AXLabel. With no argument, uses `ONBOARDING_DISMISS_LABEL` from the per-project config. Idempotent: when the labeled element isn't in the current AXTree (already-dismissed onboarding, no onboarding view), exits 0 without tapping.

It's callable independently of `launch_app.sh`. The bypass-launch-args + dismiss-onboarding workflow is fully supported. Use the script directly after each `simctl launch`.

## 8. iPad Pro 13-inch (M4) device-type identifier

Resolve dynamically — I don't have a confirmed identifier from this project's history. Standard pattern:

```bash
# List installed device types and runtimes
xcrun simctl list devicetypes | grep -i 'iPad Pro 13'
xcrun simctl list runtimes | grep -i 'iOS-26'

# Expected device type identifier (Apple's naming convention):
# com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M4

# Create:
xcrun simctl create "iPad Pro 13-inch (M4)" \
  "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M4" \
  "$(xcrun simctl list runtimes | grep -i 'iOS 26' | tail -1 | awk -F'[()]' '{print $2}')"
```

If the device-type identifier doesn't match, `simctl create` will exit with an error listing valid identifiers; copy the right one from the error output.

No known M4-iPad-specific gotcha at this project's scope. The Tutor host-eligibility note in CLAUDE.md doesn't apply — none of the 9 target screens are Tutor-gated.

## 9. Output directory git policy

**Gitignore `docs/screenshots/`.** Reasoning:

- Screenshots go straight to App Store Connect; they don't need to be in the repo.
- 36 PNGs per release × ~4–6 releases per year = significant binary churn over time.
- The repo's `.gitignore` already excludes `build.log` and `.claude/ios-build-verify.config.sh` — adding `docs/screenshots/` continues the pattern of keeping ephemeral run artifacts out of version control.

Add this line to `.gitignore`:

```
docs/screenshots/
```

If a specific screenshot ever needs to be checked in (README marketing, bug-report attachment), commit it to `Images/` (already in the project structure for that purpose) as an explicit one-off, not from this directory.

## 10. Driver re-run granularity

**Yes, add the `--only` flag.** It pays for itself within the first capture run.

Surface:

```bash
scripts/take_screenshots.sh                                        # all 36
scripts/take_screenshots.sh --device "iPhone 17 Pro Max"           # 18 (one device, both langs, all views)
scripts/take_screenshots.sh --lang de                              # 18 (both devices, German, all views)
scripts/take_screenshots.sh --view family_browse                   # 4 (both devices, both langs, one view)
scripts/take_screenshots.sh --device "iPhone 17 Pro Max" \
                            --lang de --view family_browse         # exactly 1 shot
```

Implementation: ~15 lines of arg parsing + a filter predicate before each `(DEVICE, LANG, VIEW)` tuple. Cost of failure during capture is high (full sweep is ~30 minutes); cost of adding the flag is low.

This is squarely within "narrow scope" — it's a recovery affordance for the same workflow, not a new use case. No scope creep concern.

## Notes / observations

- **Fixture flag always set on every launch**: correct and harmless. The fixture only kicks in when `Quiz.start()` is called, which only happens on the Quiz tab. For non-quiz screens the flag is inert. No need to gate the launch arg by view.
- **Q1 was the only true blocker**: agreed. Once you've pulled `70850b3`, none of the other questions block calibration — they're workflow choices with reasonable defaults that you'd converge on independently.
- **One Step-1-style addition discovered**: `ResultsView` needs `.accessibilityIdentifier("results_score")` (Q5). Add this before running the screen-8 capture. It's a one-line edit; commit it as a follow-up to `70850b3` rather than rolling it into the screenshot driver commit, so the source-code changes stay separate from the script + playbook work.

## Suggested order of operations from here

1. `git pull --ff-only` (Q1 — confirms tree is clean and 70850b3 is HEAD)
2. Add the `results_score` identifier to `ResultsView.swift`, build + test, commit as a small follow-up (Q5 caveat)
3. Begin Step 2 calibration as the handoff describes (sanity checks, tab-pill measurements, scroll offsets)
4. Begin Step 3 driver implementation, applying the resolutions from this answers doc (option-b tab coords, per-device uninstall, results_score anchor, --only flag)
5. Capture, iterate
6. Step 4 playbook (`docs/screenshot-playbook.md`); after it lands, `screenshot-automation-handoff.md`, `screenshot-automation-questions.md`, and `screenshot-automation-answers.md` can be deleted as superseded
