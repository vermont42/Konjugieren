# Blog Notes

Work journal for Konjugieren. Newest entries at the bottom. Narrative over changelog: what was tried, what failed, why decisions changed.

## Verb-corpus expansion research: measuring the Wiktionary option (2026-07-18)

Josh asked (via `prompts/more_verbs.md`) where thousands of additional verbs could come from, given that the sibling apps got their 6,200 and 4,800 verbs from the "Made Simple(r)" books and no German equivalent is in hand. The session turned out to need no browser automation at all: both Wiktionaries, Wikipedia, Wikidata, and DWDS all answered to plain `curl` against their APIs from the Bash tool.

The first move that paid off was a containment check before any diffing: German Wiktionary contains all 990 current verbs and English Wiktionary contains 989 (all but weiterlesen), so set differences against them are real candidate lists rather than coverage noise. The headline numbers: English Wiktionary has 10,407 German verb lemmas (8,346 not in Konjugieren), German Wiktionary has 14,530 (13,457 missing), and 6,980 verbs appear in both Wiktionaries while missing from the app. Of those, 2,406 are prefixed or compound derivatives of verbs the app already conjugates.

One false start worth remembering: the de.wikipedia "Liste starker Verben (deutsche Sprache)" looked like wikitables, and a first extraction pass over `|`-prefixed rows found zero verbs. The page actually builds its rows with `{{Verb Zelle|'''verb'''|...}}` templates, so the extraction had to target bolded tokens inside those templates. Once fixed, the list yielded 186 base strong verbs, of which Konjugieren is missing 87, including everyday ones: beißen, frieren, graben, befehlen, lügen, blasen, braten. A telling inversion emerged: the original frequency list admitted vermeiden and verleihen while excluding meiden and leihen. DWDS frequency checks (their no-auth API worked beautifully) showed the missing bases are common: beißen has 438k corpus hits. The comedy prize goes to küren, which out-polls beißen thanks to sports journalism's "zum Sieger gekürt".

The recommended extraction path is kaikki.org's wiktextract JSONL rather than any crawling: a 293.9 MB verbs-only file carries glosses, expanded conjugation tables, and `etymology_text` in one download, which satisfies the requirement that glosses and etymologies travel with the verbs. Classification can be automated by inverting the manual checklist: hypothesize each family and existing ablaut group, conjugate with `Conjugator`, and accept whatever exactly matches the Wiktionary table; mismatches are precisely the verbs needing new ablaut groups. Modeling wrinkles the data surfaced: dual strong/weak paradigms (sieden: sott/gesotten beside siedete/gesiedet), dual auxiliaries (schmelzen), and the weak-Präteritum-strong-participle class (mahlen, salzen, spalten) that fits no current family.

Findings, licensing analysis (everything usable is CC BY-SA 4.0 except Wikidata's CC0), and a phased plan landed in `docs/verb-sources.md`. No app code changed.

Later the same day, step 1 went from plan to done: the 294 MB kaikki verb file now lives in `verbdata/` at the repo root, deliberately outside `Konjugieren/` because that directory's Xcode folder references would have swept a data file into the app target. The JSONL is gitignored while a tracked README pins provenance and a SHA-256. A full-parse validation counted 87,343 records: 76,503 conjugation entries, 10,840 lemmas, 9,759 single-word lemmas, and 8,736 verbs not yet in the app.

## A kill switch that structurally cannot hide a working feature (2026-07-18)

Ported from Conjugar, where the same switch shipped earlier the same day. The problem: every `info_browse` App Store screenshot was carrying a row announcing that Apple Intelligence wasn't working. `InfoBrowseView` renders a tutor entry point above the first info row, and when the on-device model is unavailable it doesn't omit that entry point — it substitutes `TutorUnavailableRowView`, which explains why. On a real device that's honest UI. On the screenshot host it's the only outcome, because iOS 26.3.1 tightened the `os-eligibility-domain.change.greymatter` gate and Intel-Mac hosts no longer resolve as eligible. So two of the 36 store screenshots were advertising a broken feature.

The design constraint that mattered most was where to put the guard. The tutor block is an `if isAvailable { … } else if let reason = … { … }`. Gating the outer block would have been the same number of characters and would have created a flag capable of hiding a *working* tutor — the classic screenshot-flag footgun, where someone flips it for a sweep, forgets, and ships a build missing a feature. Gating only the `else if` means the switch's worst possible failure is that a status row someone wanted to see is invisible. It cannot suppress `TutorRowView`. That's a structural property, not a discipline one, which is the kind worth paying a comment to explain.

Compile-time rather than `UserDefaults`, deliberately, and the reasoning is worth contrasting with the flag right next to it: `KONJUGIEREN_QUIZ_FIXTURE` is runtime precisely because the screenshot driver must toggle it per-cell. The tutor switch is the opposite case — the driver builds once at start, so a runtime flag would invite a stale-build mismatch where the flag says one thing and the installed binary does another.

Konjugieren had no kill-switch convention to extend. Conjugar has `TipDisplay.tipsEnabled` and `OnboardingDisplay.onboardingEnabled` sitting in `ConjugarTips.swift`, and the tutor switch simply joined them there; grepping Konjugieren for any of those names came back empty. So this introduces the convention. The temptation was to port all three at once for symmetry, but unused switches rot and Konjugieren's sweep hasn't been shown to need tips or onboarding suppression. Only the tutor switch landed, in `KonjugierenTips.swift`, so that a future `TipDisplay` has an obvious home.

Verifying in both directions turned out to matter. With the switch `false` the concern was an orphan `Divider()` — a stray hairline above the first info row is exactly the artifact that survives review — but the divider lives inside the suppressed branch, so it went with the row; the built UI confirmed one clean separator under Dedication. The `true` direction produced a surprise: the reason the host reports is `.modelNotReady` ("Apple Intelligence is being configured. This may take a few minutes."), not the `.deviceNotEligible` that CLAUDE.md's host-eligibility note would predict. Both reasons take the same `else if`, so the switch covers either, but it's a reminder that the eligibility gate's *observable* symptom isn't the one documented.

Also corrected a stale claim in `docs/screenshot-playbook.md`, which asserted that none of the nine target views were Tutor-gated and the host-eligibility problem therefore didn't affect the sweep. That was false in a load-bearing way: `info_browse` is view #6 and it captures the row every time. A doc that tells the next session a problem doesn't exist is worse than no doc, so the gotcha now says the opposite and points at the switch.

## Finishing the kill-switch set, and finding the stale doc's twin (2026-07-19)

Yesterday's tutor kill switch deliberately shipped alone; the plan scoped tips and onboarding out on the grounds that Konjugieren's sweep hadn't been shown to need them. Josh asked for them anyway, and the sweep promptly proved it needed them: on a fresh install the "Try the Quiz" TipKit card renders directly over `verb_browse`, which is sweep view #1, and the onboarding cover auto-presents over whatever screen is being captured. So the caution was wrong in the useful direction — the switches were needed, and the evidence took one screenshot to obtain.

Finding Conjugar's implementation to port from took a detour. `~/Desktop/workspace/Conjugar` looked like the obvious source, but its HEAD is `Xcode 26 and Conjugar 2.8` from December and it contains none of the switches. The live checkout is `Conjugar.mig`, whose recent commits include the very `Tutor: add a screenshot kill switch` this work descends from. Worth remembering: this machine keeps many `.bak`/`.mig`/numbered sibling checkouts, and the plausibly-named one is not reliably the current one. Check `git log` before concluding a feature doesn't exist.

`tipsEnabled` turned out to be the cheapest switch of the three, and for a reason specific to TipKit: it displays nothing at all until `Tips.configure()` runs. So one guard around that single call in `KonjugierenApp.init` suppresses all five call sites — two `TipView`s and three `.popoverTip(_:)`s — with no per-site edits. Framework initialization order did the work.

Onboarding needed a different insertion point than Conjugar's. Conjugar presents imperatively (`router.showOnboarding = true` behind a guard); Konjugieren computes a `fullScreenCover` binding from `!Current.settings.hasSeenOnboarding`, so the gate goes in the binding's `get`. A pleasant consequence of that shape: because the cover never presents, its setter never fires, so `hasSeenOnboarding` is left untouched rather than falsely marked seen. The switch doesn't corrupt the state it reads.

Verification turned up a false negative worth recording. Tapping "Show Onboarding" via `tap_label.sh` reported success at (201, 1238) and nothing happened — which looked exactly like the Settings reshow path being broken by the switch. It wasn't: the screen is 874 points tall, so y=1238 is below the fold. `describe-ui` happily reports `AXFrame`s for elements scrolled out of view, and the tap script doesn't sanity-check them against screen bounds. Scrolling first and re-reading the frame (y=384) made the tap work and the onboarding appear, labelled "Dismiss" rather than "Skip" — the `isReshow: true` variant, which is a nice independent confirmation that the manual path and the automatic path are genuinely different code. **A tap that "succeeds" at an off-screen coordinate is indistinguishable from a feature that doesn't work.** Check the coordinate against the display size before believing a negative result.

The documentation half repeated yesterday's lesson almost exactly. Yesterday's fix was a playbook gotcha falsely claiming no sweep view was Tutor-gated. Today's is its twin, three bullets away: "TipKit popovers may surface mid-sweep… The driver doesn't suppress these — visual review the captured PNG before upload." True when written, false the moment `tipsEnabled` landed, and it would have told the next operator that manual review was their only option. Two stale claims of the same shape in one document suggests the failure mode isn't carelessness but structure: this playbook describes capabilities the code has, so every capability added ages a sentence somewhere in it. The Don't-Break-These table now lists all three switches plus the `Tips.configure()` call site, which at least makes the coupling greppable.

One deliberate non-removal: the driver's Skip-label interleave during `wait_for_render` (workarounds #2 and #11) stays, demoted to a safety net. It costs nothing when the cover never appears — the poll simply finds no Skip button — and it covers the operator who forgets the switch. But the playbook now says plainly which is the reliable mechanism: the interleave races presentation timing, the switch does not.

## Deleting the Orientation Hack: Portrait-Only iPhone, Proportional Fleet, Rotating iPad (2026-07-19)

Konjugieren used to support Landscape Left and Right on iPhone, which the game could never
tolerate — the pretzel-vs-Oktoberfest shooter is portrait by construction. The workaround
was a UIKit escape hatch: an `AppDelegate` whose sole job was to host a mutable
`orientationLock` static, which `GameView` flipped to `.portrait` in `onAppear`, restored to
`.allButUpsideDown` in `onDisappear`, and enforced with a `requestGeometryUpdate` call to
force the live rotation. Josh disliked it, correctly. It was a global mutable made necessary
by a plist that promised more than the app could deliver.

Josh changed the iPhone plist to Portrait only, which retires the need for the lock
entirely. iPad keeps all four orientations, because on iPad an app that refuses to rotate
reads as broken. That reframes the problem: the game no longer needs to *prevent* rotation,
it needs to *survive* it.

Deleting the hack was the easy part — the whole `AppDelegate` and its
`@UIApplicationDelegateAdaptor` went with it, since orientation was all it did. The
interesting work was the two bugs the screenshot Josh supplied was demonstrating at once.
The fleet was bunched into a narrow column *and* centered at ~72% of the screen width. The
bunching is the obvious one: `enemySpacingX` was a hardcoded 45 points, tuned on a 393-point
iPhone, so on an 820-point iPad the six columns huddled in the middle third. The off-center
placement was the subtler one, and it was the rotation bug wearing a disguise —
`screenWidth` is captured once in `onAppear` and never revisited, so a board laid out at
landscape width and then displayed in portrait puts its center where the old center was.

**Proportional beats conditional.** The literal request was 3× spacing on iPad. Modeling it
showed that on an 820-point iPad portrait screen, 135-point spacing puts the fleet's outer
edge within ~57 points of each wall, which would shrink Space Invaders' side-to-side march
to a twitch and fire the descend-on-wall-contact rule almost immediately. The alternative:
express spacing as a fraction of screen width, calibrated so the iPhone is unchanged *by
construction*. The fleet already spanned 57.3% of an iPhone's width, so
`enemyGridWidthFraction = 0.573` reproduces 45 points on a phone, yields ~94 on iPad
portrait, and ~135 in landscape — the requested 3×, arrived at without an idiom check.
Measured on the simulator, landscape spacing came out at exactly 135.2. The rule also covers
Stage Manager and Split View widths, which a hardcoded `UIDevice.current.userInterfaceIdiom`
branch never would.

**The rotation handler already existed, in pieces.** Conjugar solves this with
`.onChange(of: geo.size) { gameState.reconfigure(...) }`, re-dealing the level geometry. That
is right for a platformer whose level is static scenery, and wrong here: re-dealing mid-wave
would resurrect enemies the player already shot. But `GameState` already contained the right
algorithm under a different name. `restoreGame(from:screenWidth:...)` — the pause/resume
path — scales every entity's coordinates by width and height ratios, because resuming on a
different screen size is the same problem as rotating. It just did the scaling inline, in
sixteen near-identical `.map` closures over the snapshot.

Extracting those into a `scaleGeometry(scaleX:scaleY:)` that mutates the live entities let
`restoreGame` become plain assignment plus one call, and gave `reflow` — the new
`onChange(of: geometry.size)` handler — the whole behavior for free. Net effect: about sixty
lines of duplication removed while adding a feature. A satisfying shape, and one worth
looking for: when a new requirement feels like it needs an algorithm you already wrote for a
different-sounding reason, the two reasons are probably the same reason.

A near-miss worth recording. The first instinct was to implement `reflow` as literally
`restoreGame(from: makeSnapshot(), ...)`, which reads beautifully and is wrong. `restoreGame`
also clears `gameOverTime`, restarts the music, and resets the mechanic-shuffle bags — so
rotating the iPad on the Game Over screen would have set `gameOverTime` to nil while `phase`
stayed `.lost`, making `canRestart` permanently false and the "tap to play again" prompt a
lie. Reusing a function because its *main* effect is what you want smuggles in its *other*
effects. Extracting the pure part was the only safe reuse.

**CoreMotion does not rotate with your interface.** Supporting iPad landscape exposed a
control bug that had been latent: `updatePlayerPosition` read `data.gravity.x` raw, and
`CMDeviceMotion.gravity` is expressed in the *device* reference frame, which is fixed to the
hardware. In portrait, device-X runs across the screen and steering works. In landscape,
device-X runs vertically down the screen, so tilting left and right does nothing and pitching
the iPad forward and back slides the pretzel sideways. Shipping landscape support without
fixing this would have shipped an unplayable orientation — silently, since nothing errors.
The fix projects gravity onto the screen's horizontal axis per `interfaceOrientation`
(`+x` portrait, `−x` upside down, `+y`/`−y` in the two landscapes). Note
`UIWindowScene.interfaceOrientation` is deprecated in iOS 26; `effectiveGeometry.interfaceOrientation`
is the replacement, and with a 26.0 deployment target no availability check is needed.

The landscape *signs* are the one thing simulator verification cannot settle — an Intel Mac
host has no accelerometer to feed the simulator, and the classic
`UIInterfaceOrientationLandscapeLeft == UIDeviceOrientationLandscapeRight` inversion makes
this exactly the kind of thing that is easy to reason confidently and wrongly about. The
mapping was derived from the device axes rather than recalled, and flagged for on-device
confirmation. If steering is inverted in one landscape orientation, both landscape cases are
wrong together and swapping the two lines fixes it.

Everything else was verified on an iPad Air 11-inch simulator: portrait lays out centered
with the wider spacing, a rotation to landscape reflows to 135-point spacing with no entity
lost, and a pause/resume round trip through the refactored `restoreGame` came back with
score 1,650, health 75%, the fleet's holes where enemies had died, two mid-dive attackers,
and a Bratwurstkette intact. Two incidental notes for future simulator work: `xcrun simctl
io screenshot` returns the *unrotated* framebuffer, so a landscape iPad screenshot arrives
portrait-shaped and must be transposed before it can be read — check `describe-ui`'s root
frame, not the PNG dimensions, to learn whether rotation actually happened. And `xcrun
simctl ui` has no `orientation` verb; rotation has to be driven through the Simulator's
Device menu via AppleScript.

One vertical compromise remains, deliberately. Because `reflow` scales Y by the height ratio,
a portrait-to-landscape rotation compresses the six enemy rows from 40-point spacing to about
28, so the fleet reads tighter in landscape than a fresh landscape start would. Keeping Y
absolute instead would risk pushing bottom-anchored entities off a shorter screen, which is
the worse failure. Left proportional pending Josh's eyeball on real hardware.
