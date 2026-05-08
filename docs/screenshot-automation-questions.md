# Screenshot Automation Handoff — Questions for Previous Session

Questions for the previous (May 2026) session that authored [`screenshot-automation-handoff.md`](screenshot-automation-handoff.md). These are blockers or clarifications I'd like resolved before starting Step 2 (calibration). Most important first.

## 1. Critical: Step 1 appears not to be committed

The handoff section "What's already done (Step 1, committed before this session began)" lists six source-file edits and a CLAUDE.md update as already on the branch. The first sanity check it prescribes is `git log -3 --oneline` to "confirm Step 1 is committed."

But the working tree at the start of this session looked like this:

```
M CLAUDE.md
 M Konjugieren/Models/Info.swift
 M Konjugieren/Models/Quiz.swift
 M Konjugieren/Views/FamilyBrowseView.swift
 M Konjugieren/Views/InfoBrowseView.swift
 M Konjugieren/Views/QuizView.swift
 M Konjugieren/Views/VerbBrowseView.swift
?? docs/ScreenshotPlan.md
?? docs/claude-code-skill-recommendations.md
?? docs/screenshot-automation-handoff.md
```

Recent commits (`985934e`, `15dc8f3`, `0a2f1be`, `d8f8df1`, `5c75371`) are all UI-audit polish work — none mention screenshot automation. So all of Step 1's claimed changes are uncommitted, and the handoff itself plus the ScreenshotPlan spec are untracked.

**Question:** Was Step 1 intended to land on a commit before handoff, and that simply didn't happen? Should this session's first action be to commit the Step 1 source changes plus the two doc files (`screenshot-automation-handoff.md`, `ScreenshotPlan.md`) — and if so, what commit message and split do you recommend (one combined commit, or source-changes commit + docs commit)? Or do you want calibration to proceed on the uncommitted tree, with a single rolled-up commit at the end of Step 3?

This is the only question that actually blocks progress; the rest are clarifications.

## 2. `docs/ScreenshotPlan.md` is untracked

The handoff treats `ScreenshotPlan.md` as immutable spec ("**Don't change `docs/ScreenshotPlan.md`** — it's the spec"), but `git status` shows it untracked. The "don't change" rule is stronger when the file is a committed reference; treating an untracked draft as a frozen spec is unusual.

**Question:** Should `ScreenshotPlan.md` be committed alongside (or before) the Step 1 source changes, so the spec has a stable git identity for future sessions to reference? Same question for `screenshot-automation-handoff.md` — is the intent to commit it as historical record, or leave it untracked until it gets deleted at the end of Step 4?

## 3. Tab-coordinate strategy: which option is canonical?

The handoff offers two paths for handling per-device tab coords:

- **(a)** Mutate `.claude/ios-build-verify.config.sh` per device iteration so `tap_tab.sh` reads the right values.
- **(b)** Maintain a `TAB_COORDS` table in the driver and bypass `tap_tab.sh` with direct `axe tap` calls.

The handoff prose says "the latter is cleaner" — but the bash skeleton in Step 3 has both `apply_tab_coords "$DEVICE"` (which sounds like option (a)) **and** a `declare -A TAB_COORDS` map (which suggests option (b)).

**Question:** Which option is the intended path? If (b), what should `apply_tab_coords` actually do — is it a no-op stub kept only for symmetry, or does it set a shell-level coords variable that a custom `tap_tab` wrapper consumes? If (a), does the driver write directly into the gitignored config file, and is the expectation that it restores the original on exit (trap on EXIT)?

## 4. State reset cadence between iterations

The handoff mentions two reset mechanisms but doesn't specify when each fires:

- `dismiss_onboarding.sh` (idempotent — onboarding shows on first launch only).
- `xcrun simctl uninstall <UDID> biz.joshadams.Konjugieren` (clears review-prompt UserDefaults plus everything else).

Per-iteration choice affects driver behavior:

- **Uninstall every (device, lang, view)**: 36 launches, 36 onboarding skips. Slow but maximally deterministic.
- **Uninstall once per (device, lang)**: 4 onboarding skips total. Settings reset between languages.
- **Uninstall once per device**: 2 onboarding skips. Onboarding settings persist between languages.
- **Uninstall once at start**: 1 onboarding skip. Review-prompt counter accumulates across 18 launches.

**Question:** What's the intended reset cadence? The driver's loop structure changes shape based on this.

## 5. Quiz Results (screen 8) loop mechanics

The recipe is "loop 30× (tap field, type answer, press Return) → results sheet appears."

**Question:** After Return submits an answer in `QuizView`, does the next question's text field auto-focus, or does it need to be re-tapped? If auto-focus, the per-iteration `tap_id quiz_answer_field` is redundant (and the keyboard cycle might race with the next-question render). If not, the recipe as written is correct. This is a reliability question — answering 30 questions has many failure points.

## 6. Mid-quiz screenshot (screen 5): keyboard visible or dismissed?

The recipe ends with `type_text "mache"` and a screenshot **before submit**. After `type_text`, the iOS keyboard is typically still up.

**Question:** Is the keyboard meant to be visible in this App Store screenshot? Marketing-wise, "user is mid-typing" is a clear story; a visible keyboard supports it. But if the visual intent is to show the question + ablaut highlighting prominently, an extra "dismiss keyboard" step is needed before screenshot. Either is defensible — flagging because reverting later is cheap but only if I know the intent now.

## 7. `dismiss_onboarding.sh` availability

The handoff lists `dismiss_onboarding.sh` among the `ios-build-verify` skill's scripts and says it's idempotent.

**Question:** Was `dismiss_onboarding.sh` confirmed present in the currently installed skill version (the handoff cites `0.2.1`), or was it inferred from the skill's design? If the script doesn't exist standalone, the fallback is to rely on `launch_app.sh`'s onboarding-dismiss interleave — but that path is incompatible with the bypass-`launch_app.sh`-for-language-args approach. Knowing this in advance lets me either confirm + use, or write a tiny inline replacement.

## 8. iPad Pro 13-inch (M4) device-type identifier

The handoff gives an explicit `xcrun simctl create` invocation for iPhone 17 Pro Max but not for iPad Pro 13-inch (M4). I can resolve via `xcrun simctl list devicetypes | grep -i iPad`, but flagging in case the previous session has a preferred identifier or a known gotcha (e.g., the M4 iPad needs a specific runtime).

## 9. Output directory git policy

The handoff says "`docs/screenshots/` may be gitignored or kept — check before assuming."

**Question:** What's your recommendation? If 36 PNGs go straight to App Store Connect upload, gitignoring keeps the repo light. If they're a durable artifact tied to the release tag, committing them makes more sense. Either is defensible — preferring not to guess.

## 10. Driver re-run granularity

If a single screenshot is wrong (mis-calibrated swipe, transient AXTree flake, modal popped at the wrong moment), recovery cost matters. The skeleton's nested `for DEVICE / for LANG / for VIEW` loops imply "run all or nothing."

**Question:** Should `scripts/take_screenshots.sh` accept `--only "<DEVICE>|<LANG>|<VIEW>"` flags for re-running individual cells, or is the expectation that the developer re-runs the full sweep on any failure? The first costs ~30 minutes of script-writing up front; the second costs minutes-per-failure during the capture phase. I'd default to adding the flag — flagging for confirmation because it's a small scope creep beyond "narrow App Store screenshots only."

---

## Notes / smaller observations (no question, just flagging)

- The handoff is admirably thorough; most of these questions are workflow choices, not design gaps.
- The fixture mechanism (`KONJUGIEREN_QUIZ_FIXTURE=screenshot` is always set on every launch, even for non-quiz screens) is harmless — flagging only because someone reading the launch line later might wonder.
- Question 1 is the only true blocker. Everything else can have a reasonable default if no answer comes back.
