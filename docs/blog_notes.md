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

## Asking whether DWDS should own the frequency column (2026-07-19)

Picking up `docs/verb-sources.md` after step 1 (the kaikki snapshot), the question that had
to be answered before steps 2 and 3 was deceptively small: where do new verbs get their `fr`
rank? Today `fr` is a dense, unique 1–990 integer, rendered as a "#N" badge on `VerbView`
and driving the default browse sort. Adding even the 87 missing strong bases forces the
issue, because appending beißen at #991 — behind tätigen — would be visibly absurd to anyone
who speaks German.

So: re-derive everything from DWDS? I fetched all 990 lemmas from the frequency API to find
out, and the answer split cleanly into a data question and a licensing question, which
turned out to have opposite signs.

The data question came out well. Spearman between the existing ranks and DWDS-derived ranks
is 0.932 — the original list, whose provenance the repo never recorded (the commit message
is just "add complete verb etymologies and frequency list"), is not wrong. But the median
verb still shifts 45 places and 215 shift more than 100, so the two orderings are genuinely
different documents, and only one of them is reproducible.

Two traps surfaced, both now written up in `verbdata/README.md`. The first was mine: the
`in` attribute in `Verbs.xml` carries three markers, `+` and `*` and `^`, and my extractor
stripped only `+` and `^`. All 305 inseparable-prefix verbs went out as `be*achten` — and
the API answered with a well-formed zero rather than an error, so the first full run looked
like a success while a third of the corpus was silently garbage. Only the biggest-movers
table, in which the bottom of the ranking was suspiciously full of ordinary verbs, gave it
away. The second trap is DWDS's own: it lemmatizes the query, so a verb whose infinitive is
a homograph of another lemma's inflected form resolves to the wrong lemma. runden lands on
the adjective *rund* and reports 23.4 million hits, which would have installed it at rank
25. Ten of 990 do this, and comparing the returned `dwds_lemma` against the asked lemma
catches all ten for free. The one it cannot catch is sein, which outpolls haben two to one
because the possessive pronoun shares its spelling and its lemma; harmless here only because
sein is rank 1 regardless.

The licensing question is where the day turned. `verb-sources.md` had asserted that
DWDS-derived ranks "with a Credits mention are cleaner" than Leipzig or SUBTLEX-DE or
DeReWo. Reading the actual Nutzungsbedingungen reverses that: BBAW explicitly reserves its
§ 44b UrhG rights — that is the German TDM exception, which rights holders may opt out of
for non-research use — and requires written permission for automated querying not covered by
§ 60d, the exception reserved to non-commercial *research organizations*. A shipping App
Store app is not one. Quoting a dozen frequencies in a design doc is fine under the citation
allowance; deriving the app's whole frequency column and shipping it is not. I had already
run the fetch twice by the time I read this, which is the wrong order to do things in, and
the snapshot is now gitignored pending an email to dwds@bbaw.de. The correction is recorded
in `verb-sources.md` rather than quietly patched, since future sessions read that file as
settled fact.

The engineering recommendation that falls out is independent of who wins the license: store
raw hits in the XML and derive the rank at parse time, rather than storing the rank. A stored
dense rank means every tranche of new verbs rewrites the `fr` of all 990 incumbents — a
useless diff and an invitation to error — whereas a derived rank makes adding a verb a
one-line change. That refactor touches `VerbParser`, `Verb`, and `VerbExportTests`, and it
should land before the corpus grows, not after.

## Drafting the DWDS permission request (2026-07-19)

Wrote `docs/dwds-permission-email.md`, an English request to `dwds@bbaw.de` for permission to
derive the app's frequency ranking from their API.

Two judgment calls are baked into the draft, both worth revisiting before it goes out. The
first is disclosure: the email admits that the 990-lemma snapshot has already been fetched.
The alternative was to ask in the abstract, which would have been technically honest and
practically evasive, since the requests are in BBAW's logs either way. The second is the
public-repository problem. Shipping the ranks inside a compiled app is one thing; publishing
them in a GitHub repo is redistribution, and burying that in a footnote would be the kind of
omission that turns a yes into a retracted yes. The draft raises it in its own paragraph and
offers to drop the hit counts, or to walk away, if that is what it takes.

The email also asks BBAW to specify the attribution wording rather than proposing one and
hoping. That was not originally a courtesy: `dwds.de/d/zitieren` renders its citation
templates in JavaScript, so the house style was simply unreadable from a curl. Turning the
gap into a question improved the email.

Everything is still gated on the reply. Step 2 of `verb-sources.md`, the classify-and-verify
pipeline against `Conjugator`, needs only the CC-BY-SA kaikki data and can proceed meanwhile.

## Giving the Verbs.xml DOCTYPE teeth (2026-07-19)

The DOCTYPE in `Verbs.xml` had been quietly wrong for a long time. It declared `in`, `tn`,
`fa`, `fr`, and `ay`, but not `ag` (324 verbs) or `ic` (all 990), typed `fa` as free-form
CDATA, and declared `<!ELEMENT verb (verb*)>`, permitting nested verbs that have never
existed. `XMLParser` does not validate against internal subsets, so nothing ever complained.

That is the same failure that produced the three stale 989s earlier in the day, with one
aggravating difference: a DTD *looks* machine-checked. Prose that nothing executes is at least
honestly prose. A schema that nothing validates is a comment wearing a costume.

Repairing the declaration was easy. The interesting part was deciding what the corrected DTD
should say, because the data answered questions the old one had ducked. `ag` turned out to sit
on exactly the 294 strong plus 30 mixed verbs and on zero weak or -ieren verbs, so `#IMPLIED`
is right and the correlation is perfect. `fa` has a closed set of four values, so it became an
enumeration rather than CDATA, which means a typo'd family code now fails validation instead
of reaching `VerbParser`'s `default:` branch and its `fatalError`. `ay` appears only as `s` in
the data, but `Auxiliary` declares `haben = "h"` alongside `sein = "s"`, so the enumeration
had to permit both; writing `(s)` would have described the current data while forbidding a
legitimate value. Schema-from-data is a trap when the model is wider than the sample.

Then the follow-through, which is the whole point: a **Validate Verbs.xml** run-script phase
placed ahead of Sources in the Konjugieren target, so a bad verb fails the build. Josh asked
what it costs, which is the right question to ask before agreeing to a check that runs
forever. Measured directly, `xmllint --valid` on the 80 KB file takes 10.1 ms mean over 50
runs, and a bare `/bin/sh -c true` takes 8.2 ms of that, so the validation proper is about
2 ms and the rest is process spawn. With `inputPaths` and `outputPaths` declared, Xcode skips
the phase entirely when `Verbs.xml` has not changed, which is nearly every build. Against a
6.2 s no-op build, the worst case is roughly 0.2 percent.

Verifying it was worth the extra step. The first check only proved the build still succeeded,
which proves nothing about a validator. Injecting a verb missing `ic` produced
`Verbs.xml:1005: error: Element verb does not carry attribute ic`, rendered by xcbeautify with
a caret under the offending element, and `build_app.sh` exited 65. A first attempt to confirm
this read the exit status of a `tail` at the end of a pipeline rather than of the build, and
reported 0. Worth remembering: `$?` after a pipeline is the last command's, and the shape of
that mistake is exactly the one that lets a decorative check pass for a real one.

## The importer that audited the corpus it was meant to grow (2026-07-19)

Step 2 of `verb-sources.md` was "build the classify-and-verify pipeline against `Conjugator`."
The premise from step 1 was that classification need not be manual at 6,000-verb scale:
hypothesize an encoding, generate all conjugations, compare against Wiktionary's table, and an
exact match confirms family, ablaut group, region, and prefix at once. That premise held. What
it produced first, though, was not new verbs. It was a bug report about the 990 already here.

The first design decision was where the thing lives. `Conjugator.conjugate` resolves verbs
through `Verb.verbs`, so a candidate cannot be conjugated until it has been inserted into that
dictionary, and only `@testable import Konjugieren` reaches it. So the harness is a test suite,
gated on an environment variable because it mutates `Verb.verbs` and `AblautGroup.ablautGroups`
while every other suite reads them. `xcodebuild` forwards host environment variables to the
test process only under a `TEST_RUNNER_` prefix, which took a minute to remember.

The interesting engineering was in how a hypothesis gets tested. Brute force over 66 ablaut
groups × every stem region × 9,217 verbs is tens of millions of batches, so the pipeline
derives the ablaut instead of searching for it: probe `Conjugator` with a sentinel replacement
to see where the region lands, then read the required replacement off Wiktionary's form. That
first draft was wrong, and wrong in an instructive way. I aligned both the head and the tail of
the probe output, which assumes the ending is independent of the replacement. It is not:
*beißen*'s Präsens 2s is `beißt`, not `beißst`, because `adjustEndingForPhonology` collapses
`st` after a sibilant. Every strong verb with an s-final stem died silently. The fix was to
trust only the head and *search* the suffixes of the expected form, confirming each candidate
by re-conjugating. Slower per slot, immune to every phonological rule `Conjugator` has or will
have, and it keeps the oracle and the implementation the same object — no ending logic is
duplicated in the pipeline at all.

Two more corrections came from reading the shipped data rather than reasoning about it.
Replacements in `AblautGroups.xml` are uppercase, because uppercase is the app's ablaut
highlighting convention — so comparison had to go case-insensitive, and every derived group had
been failing to match its shipped twin for that reason alone. And Wiktionary lists a separable
verb's finite forms both joined and split, `abbeiße` beside `beiße ab`, which made the
normalization I had written mostly unnecessary.

Then the calibration idea, which is the part I would keep. The candidate file includes the 985
shipping verbs alongside the 8,232 incoming ones. They cost nothing to classify, and for them
the right answer is already in `Verbs.xml` — so a shipping verb that fails to verify is a
defect rather than an unknown. 236 failed. Grouped by cause they collapse into five clusters,
and four of the five are one phenomenon: the epenthetic -e, which `Conjugator` implements only
for the Präsens and Präteritum of weak verbs. The Imperativ never calls the adjustment at all,
so the app says `arbeitt` for *arbeitet*; strong and mixed fall through a `break`; and the
exemption list misses doubled consonants (`stimmete`) and the Dehnungs-h (`ahnete`). Pleasing
that this is the same repair English makes in *wanted* and *needed* but not *walked* — a dental
cluster both languages refuse to pronounce, fixed the same way on both sides of the North Sea.

The quietest finding took another hour to see. *finden* showed as verified, which seemed fine
until I noticed `ablautGroupIsNew: true` on a verb that ships with a group. The pipeline had
reproduced Wiktionary's table by *proposing a different group* than the one in the file —
because the shipped `A,bA|Ä,dA|U,pp` produces *du findst*. 118 of the 304 shipping strong and
mixed verbs verified that way. So the real disagreement count is 354 of 985, not 236, and the
flag that reveals it is one boolean nobody would think to look at.

That reframed the recommendation entirely. The 52 proposed ablaut groups are all verified, but
145 of them are verified *by working around* the epenthetic-e gaps — smuggling the missing `-e`
into the ablaut region, which is why the proposed group for *binden* is five clauses long where
the shipped `finden` group is three. Import first and those workarounds become permanent data
in hundreds of verbs, and fixing `Conjugator` later breaks every one. Fix `Conjugator` first
and the same run proposes the small idiomatic groups instead. The shipping-corpus failure count
is the regression test: it should fall from 354 toward zero.

Two smaller pleasures. 42 of the 44 missing strong verbs named in `verb-sources.md` classified
automatically, *graben* reusing *fahren* with no new group needed. And the two that failed were
*mahlen* and *spalten* — precisely wrinkle 4 of that document, weak Präteritum with strong
participle. The pipeline rediscovered the documented gap without being told it existed, which
is about the best evidence available that the verification is real and not a tautology.

Where it stops short: verified means `Conjugator` reproduced Wiktionary's table, not that the
encoding is idiomatic, not that Wiktionary's table was the only one. 17 verbs verified into a
family contradicting Wiktionary's own class tag — *melken*, *gären*, *sieden*, *pflegen* — which
is wrinkle 1's dual-paradigm problem showing up as a cheap cross-check nobody designed. The
summary flags them rather than guessing.

## Fixing the epenthetic -e, and not laundering it into the tests (2026-07-19)

The classification run had left a bug report: 354 of 985 shipping verbs conjugated differently
from Wiktionary, in five clusters. Josh asked for the fix. It came to about sixty lines in
`Conjugator.swift`, and the interesting part was not writing them but deciding what the rule
actually is.

Four of the five clusters were one phenomenon, the epenthetic -e, implemented only for the
Präsens and Präteritum of weak verbs. Extending it meant answering three questions the original
code had finessed.

**Which m/n stems take it?** The old exemption was "preceded by l, r, or a vowel", which misses
*stimmen* → `stimmete` and *ahnen* → `ahnete`. Adding m and n handles the doubled consonants.
The h is the subtle one, because it cuts both ways: *rechnen* and *zeichnen* take the -e while
*ahnen*, *wohnen*, and *lehnen* do not. The difference is that the first pair's h is half of
`ch`, a real consonant, and the second group's is a Dehnungs-h, a silent length mark on the
vowel before it. So the test is on the letter before the h: vowel means exempt. Three lines,
and it separates *gewöhnte* from *trocknete* correctly across the whole corpus.

**When does a strong verb take it?** German says *er findet* but *er hält*, and both stems end
in t. The generalization is that strong verbs which change their stem in the Präsens kept the
older endingless 3s, and the ones that do not change take the ordinary ending. That maps onto
something `conjugateSimpleTense` already knows — whether `applyAblaut` returned a different
stem — so the fix was to thread a `stammIsAblauted` flag through. It turned out to fix a second
bug for free: the existing t-dropping rule was firing for *ihr haltet* as well as *er hält*,
because it tested only the letter and the family. Gating both on the same flag made the pair
fall out correctly.

**Where does it stop?** Mixed verbs. *senden* takes the -e in the Präsens (*du sendest*) but
not in the Präteritum or the Partizip (*sandte*, *gesandt*), because the mixed -te attaches to
the ablauted stem directly. Excluding `.mixed` from those two is a no-op on today's corpus,
since *senden* and *wenden* actually ship as weak, but it is the right rule for the imports.

The -ern/-eln cluster was simpler and still had a trap. My first rule was "if the infinitive
does not end in -en, the plural ending is -n", reasoning that the stem already carries the e.
Eighteen tests went red immediately: *sein* and *tun* end in -n too, and their stems are `sei`
and `tu`, with no e to carry. The predicate had to be `-ern`/`-eln` specifically. Keying on the
stem instead would have been wrong in the other direction, since *verheeren*'s stem also ends
in `er`. Two failure modes, one on each side, and the tests caught both in one run.

Then Josh relayed a warning from a prior session that is worth writing down: when fixing an
engine turns a shipped test red, the reflex is to edit the expectation until it is green, which
launders the bug into a documented invariant. The mixed-case convention makes this especially
easy, because changing a capital letter in an expected string feels like formatting rather than
a claim about German.

Worth checking rather than promising. `git diff` on `ConjugatorTests.swift` was empty — the
eighteen failures had been fixed in the engine, which is where the bug was. But the warning
prompted a better question: are there expectations that encode a defect and are green *now*?
Intersecting the 96 verbs the tests assert against the 51 that still disagree with Wiktionary
gave nine, and they turned out to be one systematic issue. `ConjugatorTests` asserts `"Ass"` for
*essen*'s Präteritum, `"schlOß"` for *schließen*, and `"wEIsS"` for *wissen*. German writes
*aß*, *schloss*, and *weiß*. The suite has been documenting a ß/ss defect as intended behavior,
in both directions at once — ß where ss belongs and ss where ß belongs — because the rule
depends on whether the ablauted vowel is long, and nothing in the model knows vowel length.

That one is data rather than code: the sibilant has to move inside the ablaut region so each
group can spell it per vowel, which is exactly what the pipeline already proposes
(`schl^ieß^en` with `OSS`). I left it for Josh, flagged in `verb-classification.md` with the
explicit note that fixing it *will* turn those tests red and that Wiktionary should win.

The five new test functions I did add were written from the oracle rather than from the engine.
All five passed on the first run without a single adjustment, which is the only real evidence
that a regression test is testing German and not testing the code that produced it.

Numbers, since the whole point was that the pipeline measures itself: shipping verbs at odds
with Wiktionary 354 → 51, shipping verification 76.0% → 96.4%, incoming 58.5% → 81.3%. The
prediction that mattered also held — the same run now needs 234 new ablaut groups instead of
346, drawn from 35 distinct patterns instead of 52, because it no longer has to smuggle a
missing -e into them. That is the argument for fixing the engine before importing, and it is
now a measurement rather than an argument.

## The ß that was right in 1991 (2026-07-19)

The last cluster from the classification audit was the ß/ss alternation, and it was the only
one where the app was wrong in two opposite directions simultaneously. *schließen* conjugated to
`schloß`; *essen* conjugated to `ass`. German writes ß after a long vowel or diphthong and ss
after a short one, so *schloss* (short o) and *aß* (long a) are both correct and the app had
each backwards.

Josh mentioned, while I was working, that he studied German casually as a teenager about
thirty-five years ago and has had little contact with it since. That detail explains half the
bug and is the more interesting half. Pre-1996 orthography used ß at the end of any syllable
regardless of vowel length — *daß*, *muß*, *schloß*, *Fluß* were all correct — and the 1996
reform retied it to vowel length. So `schloß` is not an error so much as a fossil: it was the
right spelling when Josh learned it. The `ass` cases are simply wrong under either system,
which is what makes the mixture diagnostic rather than embarrassing. (French, which Josh knows
far better, had its own *rectifications orthographiques* in 1990; they were so weakly adopted
that a French app would have no equivalent stratum to find.)

`Conjugator` needed no change. Vowel length is a property of the ablauted vowel, which is
precisely what an ablaut group encodes, so the sibilant had to move inside the ablaut region:
`^ess^en` rather than `^e^ssen`, `schl^ieß^en` rather than `schl^ie^ßen`. A region that stops
at the vowel simply cannot express the alternation.

One small decision took a detour. Replacements are uppercase by the app's highlighting
convention, and ß has no everyday capital. Writing `Aß` would work, but `RichTextView` decides
what to highlight with `char.isUppercase` and then lowercases everything for display, so the ß
would render correctly and highlight incorrectly, splitting one ablaut into two visual runs.
The capital sharp s `ẞ` (U+1E9E) solves it exactly: `isUppercase` is true, `lowercased()` is
`ß`, so `Aẞ` displays as "aß" with both letters marked. Verified in a one-line `swift -e`
before committing to it across six groups.

Widening the regions exposed three groups that had been quietly serving verbs on opposite sides
of the alternation. *riechen* sat in the *schließen* group despite having no sibilant at all,
and moved to *bieten*, whose pattern is character-for-character identical. *messen* and
*vergessen* sat in *geben*. And *fressen* sat in *essen*, which carries `gegEssen*` as a full
override for the participle — so the app had been conjugating *fressen* to *gegessen*. That one
was invisible to the ß work and would have stayed invisible; it fell out of having to look at
the group membership at all. The *lassen* group, meanwhile, lost two full overrides outright:
with the region correctly placed at `l^ass^en`, *lässt* and *ließ* come out of the ordinary
machinery and the special cases become unnecessary.

Then the part Josh had specifically warned about. Twenty `ConjugatorTests` expectations went
red, because they had been documenting the defect: `expected: "Ass"`, `"schlOß"`, `"wEIsS"`. The
temptation is to treat these as formatting and update them until green. What made it safe was
having the oracle: each new value was checked against Wiktionary's table *before* being written
into the test file, and the edit was applied by line number so nothing else could drift. Six of
the twenty turned out to be casing-only — `Isst` → `ISSt` — where the rendered word was already
right and only the highlighted span widened. Those six are exactly the ones that would have
been rubber-stamped without checking.

Shipping verbs at odds with Wiktionary: 51 → 25. Across the day, 354 → 25. What is left is
mostly one modeling gap rather than a pile of bugs: fifteen of the twenty-one remaining
failures are verbs like *angehören* and *kennenlernen* that need a separable prefix over an
already-prefixed base, which the single-`Prefix` model cannot express. Three are modal full
overrides the pipeline cannot derive and probably never should. Three are ordinary data slips
that the audit surfaced for free — *zerstören* and *unterstellen* are missing their inseparable
marker, *ausprobieren* its separable one.

## The three data slips that were ten, and one that wasn't a slip (2026-07-19)

I had ended the previous pass by offering Josh "a five-minute fix" on three stray data errors:
*zerstören* and *unterstellen* missing an inseparable-prefix marker, *ausprobieren* missing a
separable one. He said yes. Both halves of my characterization turned out to be wrong, which is
worth recording because the error was avoidable and the check that caught it was cheap.

I had derived the three by eyeballing the classification queue and sorting failures by their
mismatch text. Before editing anything I actually looked at the entries, and the picture
changed. *unterstellen* is not a slip at all: it ships as inseparable, which is right for the
*allege, subordinate* reading (*unterstellt*), and Wiktionary's table simply showed the other
reading, *place underneath* (*untergestellt*). That is wrinkle 7, the separable/inseparable
homograph, and no marker changes it — it needs two readings, which the model cannot hold.
Meanwhile seven more verbs I had filed under "double prefix, unfixable" turned out to be
ordinary marking errors.

The interesting group was four verbs whose `in` value carried **two** prefix markers:
`vor+aus+setzen`, `aus+einander+setzen`, `vor+an+treiben`, `nach+voll+ziehen`. `VerbParser`
splits on the first separator and uses `components[0]`, then strips the rest, so
`vor+aus+setzen` had been parsed as prefix *vor* over stem *aussetz* and produced
`vorgeaussetzt`. The correct marking names the whole prefix as one unit — `voraus+setzen` — and
the fix is a character deletion. What makes this a class rather than four typos is that nothing
could have caught it: the XML is well-formed, the DTD is satisfied, the family is right, and
the output is a plausible German-looking word. It needed an external oracle. I added a guard so
the parser now refuses a second marker instead of silently honoring the first.

Two more were wrong about something other than the marker. *unterbringen* shipped as
inseparable and produced *unterbracht* where German has *untergebracht*. And *besitzen* shipped
as a **weak** verb, conjugating to *besitzte* and *besitzt* instead of *besaß* and *besessen* —
a strong verb hiding in the weak family, which is the most invisible defect class this corpus
has, since nothing about such an entry is malformed. It was sitting one line away from
*s^itz^en*, correctly marked strong with the *sitzen* group, for who knows how long.

*nachvollziehen* was the one that would not resolve cleanly. It is genuinely double-prefixed:
separable *nach* over inseparable *voll*. Marking it `nachvoll*z^ieh^en` gets the participle
right (*nachvollzogen*) and therefore all twenty-five compound-tense forms, at the cost of the
two Imperativ forms, which now read *nachvollzieht* instead of *vollzieht nach*. The previous
marking had the trade exactly inverted. I took the twenty-five and wrote down that it is a
trade rather than a fix, because the temptation with a verb like this is to keep fiddling until
the queue is empty and quietly land somewhere worse.

Shipping corpus: 25 verbs at odds → 14, or 99.0% verified. Across the day, 354 → 14. The ten
that remain are five true double-prefix verbs, three modal full overrides the pipeline cannot
derive and probably never should, *nachvollziehen*'s two Imperativ forms, and *einbeziehen*,
which needs both a prefix decision and a relocated ablaut region.

The lesson I want to keep is not about prefixes. It is that "three quick data slips" was a
guess dressed as an inventory, and the thing that corrected it was spending two minutes reading
the actual rows before touching them. The oracle had the right answer the whole time; I had
just summarized it carelessly on the way out the door.

## Three Standard Germans, and the One Place the Oracle Cannot Help (2026-07-19)

German is pluricentric: German, Austrian, and Swiss are three codified standards, not one
standard plus two accents. Konjugieren had been quietly shipping only the northern one. This
pass added a `Region` setting and made two facts follow it, which turned out to be two very
different engineering problems wearing the same hat.

The easy one is orthography. Swiss Standard German abolished ß in the 1970s: every ß is written
ss, no exceptions, no dependence on vowel length. That is a pure display transform, and the only
subtlety is the uppercase half. Ablaut replacements spell the sibilant with the capital sharp s
`ẞ` so the mixed-case highlighting covers it, so the transform maps `ẞ` to `SS` rather than
`ss`. Keeping both output characters uppercase is what stops `MixedCaseSegmenter` from splitting
one highlighted run into two. There is now a test asserting exactly that, because the failure
mode is invisible in a diff and obvious only in a screenshot.

The hard one is the auxiliary, and it collided head-on with the constraint the plan called
load-bearing: `Conjugator` must stay region-free, because it is the oracle the classify-and-verify
pipeline compares against Wiktionary for 985 verbs, and every `ConjugatorTests` expectation is
written in the German standard. But `Conjugator` reads `verb.auxiliary` internally to build the
compound tenses, so a region-sensitive `Verb.auxiliary` would have made the oracle vary by user
setting without anyone noticing until the numbers moved.

The plan's suggestion was to handle it at the display layer alongside the ß transform. I did not
take that route. Rewriting "habe gestanden" into "bin gestanden" as a string operation means
pattern-matching eleven inflected forms of *haben* across six persons and four moods, and getting
it wrong produces plausible German that no test catches. Instead `Conjugator.conjugate` gained
`auxiliary: Auxiliary? = nil`. It still has no idea what a `Region` is; the parameter is purely
linguistic, the default preserves byte-identical behavior for the oracle and the whole test
suite, and a new `RegionalConjugator` wrapper is the only thing that knows about the setting.
I think this honors the constraint rather than bending it, but it is a deviation from the letter
of the plan and worth naming as one.

Curating the verb list is where the pass earned its keep, and it went exactly as the plan warned.
kaikki reports *stehen*, *sitzen*, and *liegen* as a bare "haben or sein" with no tags. It reports
*unterliegen*, *überstehen*, and *vorliegen* identically. Three of those six are regional and
three are not, and the snapshot cannot tell you which. German Wiktionary's lemma pages can:
*stehen* carries "Das Hilfsverb sein wird vor allem in Süddeutschland, der Schweiz und Österreich
verwendet", *sitzen* says "im oberdeutschen Sprachraum", *liegen* says "nur im oberdeutschen
Bereich". The other three each fail for a different reason. *unterliegen* alternates by meaning
(*sein* for "be defeated", *haben* for "be subject to"), which is `dual_auxiliary.md`'s territory.
*überstehen* alternates only in its separable "protrude" sense, while the app ships the
inseparable "survive". *vorliegen* alternates with no regional note at all. *hocken* looked
promising until the regional label turned out to sit on a sense rather than on the auxiliary,
which is the same trap one level down. Final list: the canonical three, exactly as every reference
grammar says, and not one verb added by analogy.

Two things the screenshots caught that no test would have. First, the flags in the settings picker
rendered as tofu, which sent me to `docs/emoji-assets.md` and the standing 2026-05-09 decision:
🇩🇪 is broken in the simulator and fine on Josh's physical iPhone, and the workaround was
deliberately deferred until an Apple Silicon machine. Josh confirmed this again mid-session. So
the tofu was a red herring, but the *truncation* it caused was not: "🇩🇪 North / Standard" does
not fit a third of a segmented control. The flags came out of the picker and stayed in the
`VerbView` auxiliary pill, where they do real work distinguishing "hat 🇩🇪" from "ist 🇦🇹🇨🇭".

Second, and this is the one I would have shipped wrong: in Swiss mode the conjugation table read
*schliesse, schliesst, schliessen* while the headline above it still said **schließen**. The plan
scoped the transform to the six `Conjugator` call sites, and an infinitive is not a conjugation,
so it fell straight through the gap. It looked like a rendering bug. Josh's call was to transform
displayed infinitives too, which meant the headline, nav title, browse rows, quiz prompt, results
rows, and family cards, plus normalizing both sides of verb search so a Swiss user typing
"schliessen" still finds the verb stored as "schließen". Lookup keys, `Verb.verbs`, and deeplinks
all stay on ß; only what a human reads changes.

The regression check that mattered: 14 verbs at odds, 99.0% verified, before and after. That
number was supposed to be completely unmoved by this pass, and any movement would have meant
region-sensitivity had leaked into the engine. It did not move.

Still open: the auxiliary pill's layout is unverified on real hardware. In the simulator each flag
renders as two tofu boxes instead of one glyph, which roughly doubles the pill's width and wraps
it to three lines. That is probably a simulator artifact, but "probably" is not "verified", and
Josh is building to his iPhone to settle it. If it wraps there too, the pill wants its own row.

### On-device review, same day

Josh built to his iPhone and two of the three open questions closed immediately. The flags render
correctly on device (the simulator tofu is the known 2026-05-09 bug), and the auxiliary pill fits
on one row: `haben 🇩🇪 · sein 🇦🇹🇨🇭`. No separate row needed.

Two refinements came out of it. The settings picker's `North / Standard` truncated to
`North / Stan…`; since flags render on device, it became `North 🇩🇪` (`Nord 🇩🇪` in German), which
keeps the word carrying the meaning with the flag alongside, exactly as the plan wanted. For consistency the other two segments then went flag-only, 🇦🇹 and 🇨🇭; North keeps its word because 🇩🇪 alone would read as Deutschland, which the design deliberately avoids. And the
southern-German note said "Duden labels this form southern German, Austrian, and Swiss", where
"this form" had no antecedent on screen. Josh asked, reasonably, what "the form" was. It is the
use of sein, so the note now names it and shows an example: "Duden labels the Perfekt with sein
(ist gestanden) southern German, Austrian, and Swiss." The example is conjugated per-verb, so
sitzen shows ist gesessen and liegen ist gelegen, and it is forced to a sein-writing region so the
northern user, who is exactly the one reading the note, sees the form the note is describing. 

And because new code is cheap, Josh asked for a full Info article on the Duden, slotted just above the Game entry: Konrad Duden the Gymnasium headmaster, the 1880 dictionary, the 1901 Berlin conference, the 1955–1996 official-arbiter era and the Rat für deutsche Rechtschreibung that superseded it, the Webster eponym parallel, and a three-references coda noting that the Österreichisches Wörterbuch controls in Austria while Switzerland keeps no dictionary of its own and follows the Duden, ß-lessly. It closes by pointing back at the very regional note that prompted it.

## Readings, double prefixes, and the metric that was lying (2026-07-19)

Step 5 of the roadmap: `prompts/dual_auxiliary.md`, the pass that lets one verb carry more than
one meaning. The model was already decided — nested `<reading>` elements, Josh's call the same
day — so this was a build, not a design. It did not stay that way, because the thing the pass
needed most turned out to be a bug in how we were measuring ourselves.

### The cheap half

The mechanical part went exactly as the prompt predicted. `Verbs.xml` grew a `<reading>` wrapper
around every one of its 990 verbs, with `in`, `fr`, and `ic` staying on `verb` and `tn`, `fa`,
`ag`, `ay` moving inside. The migration script changed no attribute *value*, and the proof is
that the whole test suite stayed green across it: every `ConjugatorTests` expectation, all of
them written before readings existed, still held. `Verb` kept `translation`, `family`,
`auxiliary`, and `prefix` as computed properties returning the primary reading, so of the dozens
of call sites across views, widgets, intents, and the game, exactly two needed touching — the
two that build a `Verb` literally.

The one Swift trap worth recording: `Prefix` has a case named `none`, so `switch prefixes.last`
binds `.none` to `Optional.none` and the compiler cheerfully accepts a switch that means
something else entirely. Unwrap first, then switch.

### The half that actually paid

The prompt said to do the double-prefix grammar in the same migration, on the reasoning that
`reading` gains its own `in` and you only get to define that grammar once. That was right, and
it undersold it. Before the pipeline ran a single new verb, widening `in` to admit repeated
markers — `an+ge*hören`, `nach+voll*ziehen`, `auf+be*wahren` — fixed **7 of the 10 shipping verbs
that disagreed with Wiktionary**. The app had been producing *angegehört*, *aufgebewahrt*,
*zugebereitet*. The fix is one predicate: *ge-* sits immediately before the base stem and appears
only when the prefix touching that stem is separable or absent. That replaces a three-case switch
with a test on the last element of a list, and it is why `ab+bauen` keeps its *ge-* while
`an+ge*hören` does not, even though both open with a separable prefix.

Then `hängen`, the class-4 verb the prompt names, went to two readings — strong *hing/gehangen*
intransitive, weak *hängte/gehängt* transitive — and the count went to 6. Down from 14.

### The metric was lying, and it took writing a test to notice

Here is the part worth remembering. Writing `ConjugatorTests` cases for the new readings, I
asserted `schwimmen`'s participle and got `geschwUen`. Not a mixed-case mistake — a genuinely
broken conjugation, in a verb the pipeline had been calling **verified** all along.

The cause is in how `classify()` works. It tries the shipped encoding first, and if that fails it
keeps going through other hypotheses. If one of *those* succeeds, the verb is reported verified.
The at-odds count then added only the verbs whose repair needed an ablaut group that does not
ship — which caught `hängen`, `schaffen`, `schreien`, `vergleichen`, and nothing else. A verb the
classifier could rescue using a group that *already ships* looked perfect from the outside while
the app conjugated it wrongly.

Adding a `shippedEncodingFailed` flag turned the light on. **67 shipping verbs.** Most were
missing a prefix marker outright, and the app was really, verifiably emitting *geanlegt*,
*gebeantwortet*, *gebegrüßt*, *geanzeigt*. I probed six of them through `Conjugator` directly
before believing it. Others were subtler: `beschreiben` shipped as a weak verb, so *hat
beschreibt*; `scheinen` carried the `heißen` group, which has no participle ablaut, so
*gescheint*; `schweigen`'s ablaut region spanned `eig` instead of the diphthong, so *schwIEen*;
`einigen` shipped as `ein+igen` and `ernten` as `er*nten`, neither of which has a prefix at all.

All 67 are fixed. Three genuine separable/inseparable homographs fell out of the same list and
became two-reading verbs — `umgehen`, `umstellen`, and `unterstellen`, the last of which
`dual_auxiliary.md` had predicted by name.

The lesson generalizes past this repo: a verification harness that retries on failure will report
success unless you separately record *which* hypothesis won. The retry is what makes it useful for
classifying new verbs and exactly what made it useless as a regression test.

### What the pipeline still cannot tell you

Worth stating plainly, because it is counterintuitive for a pass whose headline is auxiliaries:
`VerbClassificationTests` compares only the simple tenses, the two participles, and the Imperativ.
It never checks a compound tense. **The auxiliary is invisible to it.** Every `ay` value in the
corpus could be wrong and the at-odds count would not move.

So the 38 verbs that gained a second reading here — the `haben`/`sein` alternations of `brechen`,
`fahren`, `schwimmen`, `treten`, `übersetzen` and the rest — are editorial work, sourced from
kaikki's per-sense glosses but assigned by the ordinary rules (intransitive change of state and
directional motion take sein; transitive and atelic activity take haben). kaikki cannot do it
mechanically: it tags nearly every one of these `haben`, `sein`, **and** `haben or sein` at once,
because a Wiktionary table aggregates every sense of the lemma. These are guarded by
`ConjugatorTests` cases on `perfektIndikativ`, and by nothing else.

That aggregation also bites the metric from the other side. A two-reading verb whose Wiktionary
table happens to describe the *second* reading now registers as an encoding failure that is not
one, so the summarizer records `readingCount` and excludes them, naming them instead.

### The UI

Josh chose a picker over stacked sections: one conjugation table at a time, switched by gloss.
Showing both at once would have invited reading a row from the wrong paradigm, which is the failure
mode the whole feature exists to prevent. The control carries the glosses, so the separate
translation line is suppressed when a verb has more than one — otherwise the selected gloss prints
twice. Every piece of metadata below it follows the selection, which matters more than it sounds:
switching `hängen`'s reading flips the family pill from Strong to Weak and makes the ablaut-group
pill disappear, because the weak reading genuinely has no group.

The quiz picks one reading per question and shows that reading's gloss, so `hängen` in the
Präteritum has one right answer rather than two. Accepting both was tempting and wrong: it would
never mark a learner wrong and would teach neither paradigm.

It shipped first as a segmented `Picker`, and Josh caught the problem on device within minutes:
*antreten*'s second gloss, "take up (office), begin (a journey)", truncated to "take up (office),
begin (…". `UISegmentedControl` renders every segment on one line and offers no multiline option,
which makes it simply the wrong container for text of arbitrary length. It is now capsule `Button`s
inside a `ViewThatFits` — side by side while each fits on one line, stacked full-width when not, so
a long gloss wraps instead of truncating.

That change fixed the accessibility problem for free, which is the tidiest thing that happened all
day. The segmented picker had exposed itself as an `AXTabGroup` with a null label and no children,
so its segments could not be reached by label at all and verification had to tap coordinates. Real
buttons appear in the tree under their own glosses, and `tap_label.sh "hang, suspend something"`
now works.

Worth recording what *not* to do, because I got it wrong twice in two different shapes. Putting
`.accessibilityLabel` on the `Picker` made things strictly worse — a label on a container replaces
its children's labels. Replacing the picker and then reaching for
`.accessibilityElement(children: .contain)` plus `.accessibilityLabel` flattened it again, and the
tree showed exactly one element named "Meaning". The buttons name themselves by their glosses;
naming the group costs the ability to tell the readings apart, which is the whole point.

### Numbers

Shipping corpus: **14 verbs at odds with Wiktionary → 8**, but the two numbers are not measuring
the same thing, and that is the point. Under the old, permissive metric the corpus would now read
**6**, and it would have read 6 before this pass too while 67 verbs were quietly broken. Under the
new metric the starting position was not 14 but 81.

What is left is three modals that resist the pipeline (`sollen`, `bedürfen`, `vermögen`), three
verbs needing ablaut groups that do not ship (`schaffen`, `schreien`, `vergleichen`), and two
genuinely ambiguous ones: `helfen`, where Wiktionary wants the `sterben` group's *hülfe* over the
shipped `sprechen` group's *hälfe*, and `verstoßen`, where the shipped encoding has the Präsens
umlaut (*du verstößt*) and Wiktionary's table does not. Both want a human. Separately, four
two-reading verbs (`bewegen`, `scheiden`, `umstellen`, `unterstellen`) are excluded and named by
the summarizer as the artifact described above.

Incoming: 6,857 → 6,958 verified. Smaller than hoped, and worth being precise about why. The
double-prefix bucket in the summary fell from 1,036 to 145, but most of that mass moved rather than
resolved: those verbs' first element (`acht`, `abhanden`) simply is not in the shipped prefix
inventory, so no hypothesis ever proposed separating it. The old label called all of them double
prefixes, which after this pass would have sent the next session to rewrite code that is already
correct. The summarizer now distinguishes the two by where Wiktionary puts its own *ge-*: absent
entirely means a real double prefix, infixed means an unrecognized particle. **747 verbs are
waiting on a wider prefix inventory**, which belongs to the import step, not here.

## Retire the rank, store the count (2026-07-19)

The `fr` attribute in `Verbs.xml` held a dense rank, 1 through 990, hand-maintained. It reads
naturally — `fr="8"` for *machen* says "eighth most common verb" — and it is exactly the wrong
thing to store, because a rank is a property of the corpus rather than of the verb. Inserting one
verb at position 400 renumbers the 590 below it. The corpus is about to grow by thousands, so the
choice was between a stream of 990-line diffs that no reviewer can read and a one-line addition.

The refactor itself was small: `Verbs.xml` now carries `hi`, the raw DWDS hit count, and
`VerbParser.ranked` sorts by it descending after parsing and assigns 1..n. What made the session
short was that the prior session had left three notes attached to the plan, and all three paid off.

The first was a list of preconditions "verified by measurement, not by reading" — `fr` really is
dense over 1..990, the DWDS snapshot really does cover all 990 with no ties. Re-checking those took
one Python invocation instead of an afternoon, and they all still held.

The second was a warning about eight bad hit counts. The DWDS frequency endpoint lemmatizes
whatever you hand it and takes no part-of-speech parameter, so `runden` resolves to the adjective
*rund* and comes back with 23.4M hits instead of the verb's 517K. Nothing marks the answer as
wrong; the count is real, it just belongs to a different word. Deriving rank from it would have put
*runden* 25th of 990 and nobody would have noticed. Those eight had already been repaired by
re-querying an unambiguously verbal form, so the migration inherited clean data — but the note also
says the fetch script is *unchanged*, so a bulk re-fetch reintroduces the defect across thousands
of verbs. That is now the loudest item in the roadmap's known-gaps list.

The third note was the useful one, because it corrected the plan it was attached to. The plan named
three call sites; the note said the list was incomplete in two ways. `fr` is *rendered*, not only
sorted by — `VerbBrowseView` and `VerbView` both print `#\(verb.frequency)`, which would have
become `#516850`. And every sort site sorts ascending, which means most-common-first for a rank and
*least*-common-first for a hit count, and one of those sites — `BrowseableFamily.topVerbs`, the
three-exemplar picker on the family screens — was not in the plan's list at all. Left alone, each
family screen would have quietly showcased its three rarest verbs, and no test would have failed.

The note's own recommendation resolved both at once: keep `Verb.frequency` as the derived rank and
give the raw count a different name. `Verb.hits` is new; `frequency` means what it always meant. No
call site changed. That is the whole argument for the shape of this refactor — the four sorts and
two renders are correct because the name they read still denotes a rank.

Two things were added beyond the plan. The DTD retires `fr` rather than repurposing it, so a stale
tool writing a rank into the file fails the `xmllint --valid` build phase instead of passing as a
plausible small number — the failure mode the eight bad counts taught, applied to the schema. And
`VerbTests` gained three assertions, one of which is that more hits means a lower rank. The plan's
own note observed that no test asserted the ordering; leaving that true after making the ordering
derived seemed like the wrong kind of thrift.

Validation: the migration's report matched the prior session's measurements exactly — median shift
43 places, `fällen` the largest at 575, `weiterlesen` 447 → 975. Getting the same three numbers
from an independent rerun is what confirmed the migration read the same data the same way. 201
tests pass, and the classify-and-verify at-odds count held at 8.

## Turning a detection recipe into a gate (2026-07-19)

The `fr` → `hi` refactor left an uncomfortable asymmetry. The shipped rank is now derived from
DWDS hit counts, and the note explaining how those counts get silently corrupted was excellent
prose sitting in a docstring — which is to say, a thing a future session has to read, believe, and
act on. The eight bad counts of the morning were found because someone happened to run the
detection recipe. Nothing made them run it.

So the recipe is now enforced. Three observations made this much cheaper than expected.

The first is that the signal was already there. Every row in `dwds-frequencies.json` carries
`dwds_lemma`, the lemma DWDS decided the query was about. The script has been recording it since
the beginning and has never once looked at it. The fix is not to gather new evidence but to act on
evidence already in hand.

The second is that the check can be *strict*. Post-repair, exactly three of 990 rows have
`dwds_lemma != lemma`, and all three are orthographic variants: `reißen`→`reissen`,
`erschweren`→`erschwern`, `kreieren`→`kreiern`. Zero false positives means the gate can refuse to
write rather than print a warning, and that distinction is the whole point — a warning in a
7,700-lemma run is a line nobody reads. The two variants are encoded as rules (ß↔ss, and the
dropped *e* before final *-n*) rather than as a list of three lemmas, so an imported verb of the
same shape passes without anyone extending an allowlist.

The third is the check I did not expect to be able to build. DWDS returns the *lemma's* total, not
the queried form's, so two genuinely verbal forms of one verb return byte-identical counts. That
makes probe agreement a real invariant, and disagreement catches collisions no allowlist could
anticipate. Supply `regen` the probes `regt` and `rege` and the gate reports
`regt->regen=527307, rege->rege=803503` and refuses the row.

Verification went further than planned, and twice it was worth it.

Re-querying the eight bare infinitives live: all eight refused, and the first four counts came back
matching the values recorded in the docstring to the digit — 23,421,973 for `rund`, 18,062,655 for
`gleich`. The defect is still live upstream. Then the same eight with probes: all eight passed and
reproduced the shipped repaired counts exactly, via second probes I chose independently of whatever
the morning's repair used. Two different routes to the same eight numbers is about as good as
end-to-end evidence gets here.

The two surprises both came from tests that did not do what I predicted.

I tried to demonstrate the collision check using the case the docstring names — `weißen`'s Präsens
2s *weißt* is also *wissen*'s — and the gate passed it. Not a bug: DWDS lemmatizes the string
`weißt` to `weißen`, hits 615,024, the same as `geweißt`. The probes genuinely agreed. So the
a-priori concern that sent the morning's repair to a participle does not actually reproduce at this
endpoint, which is worth knowing before anyone treats "avoid Präsens forms" as a hard rule. The
underlying advice still stands — a participle is a safer default — but for `weißen` specifically
the collision is hypothetical. I had to construct a real one (`rege`) to exercise the path.

And when I did, the gate caught it and reported the wrong reason: "fetch failed after retries." A
disagreement leaves `hits` unset, and `classify` tested `hits is None` before it looked at anything
else, so a probe collision was indistinguishable from a network timeout. The row was correctly
refused and the diagnostic would have sent the next session to debug DNS. Fixed by carrying the
disagreement in its own field and testing it first. A gate that fails for the right reason but says
the wrong thing is only half-built, and the only way to find that is to watch it fail on purpose.

`--check FILE` audits an existing snapshot without touching the network, which is how the 990 and
the reconstructed pre-repair eight are regression-tested: 0 suspect and 8 suspect respectively.
Verification is on by default; `--no-verify` opts out. That default is the load-bearing decision.
An opt-in flag is exactly what a naive bulk re-fetch omits, and a naive bulk re-fetch is the entire
threat model.

Still open, and now the sharp edge: generating probes for an import. Kaikki's `forms[]` already
carries `perfektpartizip` and `präsensIndikativ.ts` for every candidate, so this needs no
`Conjugator` round-trip — a correction to the docstring's own suggestion. That belongs to the
import step, where the candidate data is in hand.

## A doc-consistency pass, and the stale number that mattered (2026-07-19)

Checking whether roadmap step 8 was still correct turned up one wrong gate and, more usefully,
a stale figure in a position where staleness does real damage.

Step 8 imports the 2,406 prefixed derivatives, and both files said it was gated on the
double-prefix grammar. That grammar shipped with step 5, so the gate is satisfied — but the
interesting part is that the blocker did not disappear, it *moved*, and got bigger. Only 145
incoming verbs still need the double-prefix grammar. **747** are blocked on something else
entirely: their first element (*acht*, *abhanden*) is not a prefix any shipping verb uses, so no
hypothesis ever proposes separating it. The roadmap's known-gaps section already recorded this;
the step-8 row and `verb-sources.md`'s step 6 had not caught up. Both now say the live blocker is
the prefix inventory, and that widening it belongs to the tranche rather than being a prerequisite
somebody else owns.

The worse find was in `verb-sources.md`: "The corpus now stands at **14 verbs at odds, 99.0%
verified**, and that number is the regression test for every step below." Two problems. The count
is 8 now, not 14 — but more dangerously, 14 was measured under the *old, looser* metric. A session
told to baseline against that sentence would take 14 as its floor and conclude a regression to 13
was progress, when the real floor is 8 under a stricter definition that counts 67 verbs the old
metric hid. Both numbers are now correct, and the paragraph carries the same do-not-compare warning
the roadmap does, because that sentence is the one a fresh session actually acts on.

Two more were my own misses from the `fr` → `hi` sweep earlier the same day: the Context paragraph
still listed "frequency rank (`fr`)" among what a new verb needs, and the DTD table — the one this
document calls "the authoritative list of what a verb carries" — still had an `fr` row. I had
updated the DTD in `Verbs.xml` itself and the build enforces it, so neither would have caused a
broken build; they would just have told the next reader to write an attribute that fails
validation. Worth noting that the thing which caught them was grepping for the *old* name rather
than re-reading what I had changed. Checking your own diff finds what you touched; grepping for
the retired name finds what you missed.

Also marked steps 3 and 4 of "Recommended next steps" as done, since both had run and were still
written in the future tense, and renamed the "`fr` is blocked" section to "`hi` is blocked". The
remaining `fr` mentions are all inside the section that documents the refactor's own reasoning,
where the old name is the subject rather than a live instruction.

## Writing the step-7 prompt, and what writing it exposed (2026-07-19)

Josh asked what to hand a fresh session for the first import tranche. Writing that prompt turned
out to be a better audit of the docs than reading them, because a prompt has to be *actionable* —
every pointer in it gets followed, every number gets used — and three of them did not survive
the attempt.

The first is the one that matters. Both `roadmap.md` and `verb-sources.md` said steps 7 and 8
could proceed without a reply from BBAW, because those tranches are defined by membership rather
than by frequency order. That was true this morning and is not true this afternoon, and the thing
that changed it was my own refactor. `fr` was a rank, and a human could assign one by judgment —
slot the new verb in around 400 and move on. `hi` is a raw DWDS hit count, it is `#REQUIRED`, and
it cannot be invented. So an import of 87 strong bases now needs 87 real counts, and bulk querying
is exactly what the § 44b reservation covers.

This is worth dwelling on, because the refactor was right and still moved a blocker. The old design
let the corpus grow on made-up numbers; the honesty of the new one is that a number you cannot
source is a number you have to decide about. The decision is Josh's — wait, query just the tranche,
or import provisional counts marked for re-derivation — so the roadmap now states it as an open
choice with the tradeoffs, rather than continuing to claim the step is unblocked.

The second: `verb-sources.md` ends with a section titled "Verify counts, do not trust them," whose
closing line is "See the recipe at the top of `etymology-pipeline.md`." There is no
`etymology-pipeline.md` in this repo and, as far as I can tell, never has been. A warning about
stale documentation, pointing at a file that does not exist. I inlined the three-line recipe
instead, which is short enough that it should have been inline from the start — a pointer to
something that small is all risk and no benefit.

The third: `docs/frequencies.txt` lists "all 988 verbs sorted by frequency rank," and
`docs/etymologies.md` recommends handing it to subagents as a lemma list so they need not parse
`Verbs.xml`. It is wrong about the count (990) and now wrong in kind, since ranks are derived
rather than stored. That is precisely the "convenient cached copy that drifts" pattern this repo
has paid for repeatedly, so it is filed as a known gap: regenerate or delete, but do not hand it
to a session as truth.

The prompt itself leans on a technique worth naming. Two of its lines are "do not trust the verb
counts in the prose" and "any example you remember is wrong." Both target the same failure mode: a
fresh session arrives with confident priors drawn from documents that were accurate when written.
Generic advice to be careful does not help, because the session does not know which of its beliefs
are the stale ones. Naming the specific memories to distrust — the 87-versus-44 discrepancy, the
pre-reading-model XML examples — is what makes the warning usable.

## Regenerating frequencies.txt, and the phase that never landed (2026-07-19)

`docs/frequencies.txt` was filed as a known gap earlier today: 988 verbs against a corpus of 990,
and numbers it called frequency ranks after ranks stopped being stored. Josh asked for it to be
regenerated. The interesting part was what checking its consumers turned up before overwriting it.

The two missing verbs were *besingen* and *konjugieren* — the app's namesake absent from its own
frequency list, and now, by derived rank, the single rarest verb in the corpus at 990 of 990. Both
already had full `Etymologies.json` and `ExampleSentences.json` entries, so adding them does not
break the pipeline's "every verb in frequencies.txt must have an entry" invariant. It repairs it:
that check has been silently under-verifying by two.

It is a generator now rather than a hand-maintained file, with `--check` to report drift. A file
that drifted this way twice should not depend on anyone remembering to update it. The generator
mirrors `VerbParser.ranked` deliberately, and the docstring says so, because a silent divergence
would make "verb 400" mean different things depending on whether you asked Swift or Python.

That claim is worth verifying rather than asserting, so I ran the export harness, pulled the
990-verb JSON out of the simulator's tmp directory, and compared its Swift-computed `frequency`
against the file's column 1. Zero mismatches across 990, and zero ties in the hit counts — which
matters, because with no ties the ordering is determined by `hi` alone and the two implementations
cannot diverge on tiebreak even in principle.

Reordering did move things, and one looked alarming. The top 30 changed membership: *erhalten* and
*bekommen* dropped out, *setzen* and *spielen* came in. The example-sentence pipeline keys its
`medieval` sub-key off "the top 30 verbs" and hardcodes the old list, so this looked like a real
break — until I checked the data. **No verb in `ExampleSentences.json` has a `medieval` key at
all.** The string does not appear in the file. Phase 4 of that pipeline was designed, documented
with a schema rule and a validation step, and never run, or run and never merged.

So the reshuffle broke nothing, because nothing consumed the ordering. But the pipeline doc has
been describing an output shape its own data does not have, and a future session running Phase 4
would have used a verb list frozen against ranks that no longer exist. Both are now noted in place
rather than left as a trap.

The pattern across today is consistent enough to name. Every one of these — the dead
`etymology-pipeline.md` pointer, the 14-at-odds baseline, this file, the medieval phase — was a
document making a claim that no code checked. The ones that got caught were caught by executing
the claim: following the link, running the recipe, grepping for the key. Reading them found
nothing, because they all read fine.

## Leipzig, and marking a guess as a guess (2026-07-19)

The `hi` refactor left the import needing hit counts it cannot get, so the obvious move was to
find another German frequency source. Leipzig Corpora Collection is the obvious candidate, and I
suggested it — describing it as CC BY, from memory, which turned out to be wrong in the direction
that matters.

Their terms split the licence in two. "The data and applications provided by the project" are
CC BY-**NC**, with commercial use prohibited without written consent, and that covers the web
service API. Separately, "the text corpora offered for download are made available under the
Creative Commons licence CC BY." So the numbers I had actually been querying are the
non-commercial half. Konjugieren is a paid app, so shipping ranks derived from them is barred for
the same reason DWDS is. My queries themselves were fine — the terms permit automated access
"except via our web services", and the web service is the sanctioned channel — but the derived
values cannot ship.

Reading that page needed Josh's browser. The site sits behind Anubis, a proof-of-work gate aimed
at mass scrapers, and my plain HTTP fetches got the challenge page instead of the terms. Claude in
Chrome renders in a real browser, which satisfies the challenge as designed rather than evading
it, and the point of the visit was to read a licence in order to obey it. That felt like the
distinction worth drawing: one page view, user-directed, in service of compliance.

Three technical findings killed Leipzig independently of the licence, so it would have lost
anyway. It holds 50.7M tokens against DWDS's 53.2 **billion**. Seventeen of the 87 missing strong
bases return 404 outright, *sieden* among them, and many that resolve sit at counts of one to six.
And it reports word forms rather than lemmas — `machen` is 24,992 there against 67,161,366 in
DWDS — which on an 83-verb spread sample gives ρ = 0.876 against the DWDS ranking, with a worst
displacement of 57 places inside the sample, roughly 680 at full-corpus scale.

The worst outlier was `gleichen`, one of the eight homographs repaired that morning, because the
string also inflects the adjective *gleich*. Leipzig reproduces the contamination — and the gate
built earlier that day cannot catch it, because that check compares the returned lemma against the
one asked for, and Leipzig returns only the word you queried. The comparison is a tautology. Not
merely unprotected: structurally unprotectable.

The general shape is worth keeping. Any corpus good enough to replace DWDS is likely restricted
for the same reason DWDS is, because the counts *are* the asset. So the useful question was never
which free source to find; it was whether a membership-defined tranche needs measured frequency at
all. It does not. An honest editorial estimate beats a precise-looking number that is wrong for
reasons nothing can detect.

Which leaves the real risk, which is not the guess but the guess quietly becoming permanent. Hence
`hp="y"` on `<verb>`: present means the count is an estimate, absent means it is measured, and the
DTD admits only `y` so a typo fails the build rather than reading as "real". It changes no
behaviour — the rank derives from `hi` either way — and exists purely so the provisional
population stays findable.

I implemented it rather than leaving it specified, and the reason is this same day's evidence.
Twice today I found a document describing something no code checked: the `etymology-pipeline.md`
pointer to a file that never existed, and Phase 4 of the example-sentence pipeline, complete with
a schema rule and a validation step, whose `medieval` key appears nowhere in the data. A spec for
`hp` sitting in `verb-sources.md` until step 7 is that pattern with the ink still wet.

And having written a test for it, the test passed immediately — which proves nothing, since no
verb carries `hp`. So I marked *singen* provisional, confirmed the test failed with `["singen"]`
and the generator reported `1 of 990`, set the value to `hp="maybe"` and confirmed xmllint
rejected it as "not among the enumerated set", then reverted. A test that has never been seen to
fail is not yet a test; it is a claim no code checks, which is exactly the thing being guarded
against.

## Provisional counts, decided (2026-07-19)

Josh chose provisional counts over waiting for BBAW or querying the 87-verb tranche. Recorded in
the roadmap as a decision rather than an option, so step 7 inherits it instead of re-opening it —
the point of writing a handoff is that the next session does not redo the deliberation.

One note went in that is less obvious than it looks. Having rejected Leipzig on licensing, there
is an inviting next thought: we cannot *ship* their numbers, but we could glance at them to place
our own estimates. That does not work. An estimate informed by their measurements is derived from
them, and a human retyping the figure in between does not launder it. The rejection was never only
that the numbers are bad — they are, badly enough to lose on the merits alone — but that they are
not ours to use commercially. So the note names what the legitimate inputs are instead: register
and semantics, Wiktionary labels like *archaic* and *regional*, the licensed texts already in
`corpus/`, and the real DWDS values of shipping verbs to place estimates between.

Worth being honest about what this costs. Displayed ranks across the whole corpus become
approximate, because the rank is derived globally and a misplaced new verb shifts its neighbours.
That is a real regression in data quality, accepted deliberately and marked in the data so it can
be found and undone. Which is the difference between this and the old `fr`: that was also
guesswork, but nothing recorded which numbers were guesses, so there was nothing to come back to.

## The strong bases land: 990 verbs become 1,068 (2026-07-19)

Step 7, the first import tranche. The plan said 87 missing strong bases. Re-deriving the list
gave 82, which is the third time this repo has caught a verb count that no code consumed and
nobody had rechecked. The roadmap's own instruction — do not trust the prose, do the set
difference — paid for itself in the first ten minutes.

The extraction is worth describing because the failure mode was quiet. de.wikipedia's *Liste
starker Verben* encodes each verb family as a `{{Verb Zelle}}` row whose first bolded argument is
the base and whose later bolded arguments are derivatives. 187 rows, but only 180 yield a plain
bolded base: seven wrap the head in square brackets, the list's own marking for a verb that has
left the standard language (*schneen*, *kiesen*, *quillen*, *schallen*, *schröcken*, *stecken*)
plus *sein*, which the app has had since the beginning. A regex that ignored the brackets would
have imported the attic without noticing it was the attic.

### The classifier was right and its answer was still wrong

The pipeline had already verified 78 of the 82 against Wiktionary, so the encodings arrived for
free. Except they did not, quite. For *kneifen* the classifier proposed `kn^ei^fen` with the
replacement `IF`, which conjugates to *kniff* by putting the second f outside the ablaut region
and letting the stem supply it. That is correct. It is also not how this corpus is written: the
shipping *greifen* is `gr^eif^en` with `IFF`, the whole consonant change inside the region.

The classifier minimizes for the shortest region that works, and the shortest region that works
is frequently not the one that matches an existing group. Rewriting all thirteen proposals to the
house convention collapsed them to five, because eight of them turned out to *be* groups that
already ship — `greifen` for the -eif- verbs, `schneiden` for *gleiten* and *schreiten*,
`streichen` for *schleichen*, and `heben`, which quietly fits eleven of the new bases across four
different vowels. `heben` is o in the Präteritum and participle and ö in Konjunktiv II, and that
is exactly *schwören*, *weben*, *gären*, *glimmen*, *scheren*, *wägen*, *saugen*, *lügen*,
*trügen*, *klimmen*, and the dialectal *krauchen*.

This is the same lesson the ß/ss pass learned in March-of-the-same-day form: the ablaut region
has to be wide enough to spell everything that changes. A region that stops at the vowel can
always be made to work by pushing the consonant into the stem, and the result is a group nobody
else can share.

### Where the pipeline stops being an oracle

kaikki lists *both* paradigms of a dual-paradigm verb — *melken* carries `melkte` beside `molk`,
`gemolken` beside `gemelkt` — and the classifier accepts any listed alternative as a match. Two
consequences, one convenient and one not.

The convenient one: shipping the strong paradigm for such a verb does not raise the at-odds
count, because the strong form is right there in the table. The inconvenient one: neither does
shipping the weak paradigm. The pipeline verifies both and therefore decides nothing. It reported
*flechten*, *melken*, *weben*, *sieden*, *gären*, and *glimmen* as weak purely because weak is the
first hypothesis it tries and it succeeded.

So the choice was editorial, and the rule adopted was: ship strong only where the strong paradigm
is current standard German. *melken/gemolken*, *flechten/geflochten*, *weben/gewoben*,
*sieden/gesotten*, *gären/gegoren*, *glimmen/geglommen*, *dingen/gedungen* ship strong.
*bellen/gebollen*, *schnauben/geschnoben*, *triefen/getroffen*, *bleichen/geblichen* ship weak,
because Duden marks those strong forms veraltet and an app that teaches ablaut has no business
presenting a dead paradigm as live. Seventeen of the 78 ship weak for this reason or because they
were never strong in the first place.

*bellen* is the one that took longest to let go of. Its strong forms are real — *boll*,
*gebollen*, *bölle*, and kaikki even offers *ball* — and there is something appealing about a
barking dog conjugating like *helfen*. But nobody has said *der Hund boll* since roughly Goethe.

### What was left out, and the bug hiding behind one of them

*mahlen* and *spalten* stayed out, as expected: wrinkle 4, weak Präteritum with strong
participle, which no family expresses. The pipeline confirmed the diagnosis by failing on exactly
one slot each. Interestingly *salzen* looks identical — *salzte* but *gesalzen* — and shipped
anyway, because kaikki also lists the weak *gesalzt*, so the weak encoding verifies. Wrinkle 4 is
therefore narrower than the doc implies: it bites only when the strong participle is the *only*
participle.

*speien* was the deliberate one. It verifies, but only via
`I,b1p,b3p,dA,pp|IE,b1s,b2p,b2s,b3s` — a group that splits the Präteritum by person, which
`verb-classification.md` names as the signature of a `Conjugator` gap smuggled into an ablaut
group, and whose sequencing argument says in as many words not to import such a thing.

Chasing it down: a strong verb whose stem ends in a vowel takes -n, not -en, in the 1p and 3p.
*wir spien*, not *wir spieen*. `Conjugator` has no such rule, so the only lever the pipeline has
is to vary the ablaut by person. And this is not hypothetical — shipping *schreien* carries the
identical workaround as a full override (`geschrIEn*,pp`) and is one of the three ablaut groups
already known to be wrong. It is the same shape as the `-ern`/`-eln` rule `hasSyllabicStamm`
already implements, which suggests the fix is small. Fixing it would repair *schreien*, drop the
at-odds count from 8 to 7, and let *speien* in on a clean `IE,bA,dA,pp`. Recorded as its own gap
rather than done here, because an import tranche is the wrong place to change the engine — which
is, after all, the entire argument for doing steps 2 and 3 before this one.

### Housekeeping that turned into a finding

The insertion script guards three invariants before writing: no duplicate key, no duplicate hit
count, and the file already sorted. The sortedness guard failed immediately, and the reason was
mine: `adding-verbs.md` says umlauts fold to their base vowels, and I folded ß to ss by analogy.
Measured against the actual file, folding produces three violations and not folding produces
none — U+00DF sorts after every ASCII letter, which is why the corpus reads *reiten* then
*reißen*. Then the corrected version failed too, on *drücken*/*drucken* and *zählen*/*zahlen*:
folding umlauts creates genuine ties, and the file breaks them the opposite way from a naive
sort. The invariant is that the folded keys are non-decreasing, not that the file equals its own
sorted self. Both facts are now in `adding-verbs.md`, since neither is recoverable by reading the
code that depends on them.

### The numbers

78 verbs in, 61 strong and 17 weak, 5 new ablaut groups (`bersten`, `saufen`, `schmelzen`,
`schinden`, `sieden`), corpus 990 → **1,068**. Every one of the 78 verifies against Wiktionary
with the encoding it ships with — not with a rescued alternative, which is the distinction the
`shippedEncodingFailed` flag exists to draw. **The at-odds count held at 8.** All 205 tests pass,
including three new `ConjugatorTests` functions: the new groups, the reuses, and the auxiliaries.

That last one matters more than its size suggests. The pipeline never compares a compound tense,
so `ay` is invisible to it and a wrong auxiliary cannot move the at-odds count. Fourteen of these
verbs take *sein* and nothing but a hand-written `perfektIndikativ` expectation would ever catch
it if they did not.

Every `hi` is provisional, marked `hp="y"`, placed between the real counts of shipping verbs
judged comparable. One temptation declined: `verb-sources.md` quotes real measured DWDS counts for
about twenty of these verbs, and it would have been easy to use them. But the argument the repo
already made against glancing at Leipzig applies unchanged — an estimate informed by a
measurement is derived from it — and those figures sit in that document under a citation
allowance, which is a narrower permission than shipping them in the app's data. So they went
unused, and the tranche stays uniformly provisional and uniformly re-queryable.

`VerbTests` had a tripwire waiting: `everyShippingHitCountIsMeasuredNotProvisional`, which
asserted no verb carried `hp` and whose comment said, in advance, that a tranche imported while
DWDS was blocked would break it and that updating it should be a deliberate act. It broke exactly
as designed. It now pins the provisional population at 78 and the measured one at 990, so the
next tranche of estimates has to come here and say so rather than sliding in under a `> 0`.

## Tranche 2, and the bug that was hiding in the fix for tranche 1 (2026-07-19)

Step 8: the prefixed derivatives. 2,303 verbs in, corpus 1,068 → **3,371**, at-odds held at 8.
Three things are worth writing down, and only one of them is the import.

### The prefix inventory was never the problem

The plan said 747 incoming verbs were blocked because their first element — *weg*, *nieder*,
*tot*, *acht* — is not a prefix any shipping verb uses, and that widening the inventory was part
of this step. Which invited the obvious implementation: curate a list of German separable
particles and paste it in.

Two things argued against that. First, the tail is long and heterogeneous — 203 distinct heads,
and past the first thirty they stop being particles at all. *blaumachen*, *eislaufen*,
*bauchreden*, *kaputtmachen*: German's separable slot takes adjectives and nouns as happily as
adverbs, and *teilnehmen* has been in the app since the beginning without anyone noticing it is
a noun sitting in a prefix. "Prefix inventory" is the wrong name for the thing; it is a
separable-first-constituent inventory, and it is open class.

Second, and decisively: the evidence was already in the data. German puts the participle's *ge-*
**after** a separable first element. *angekommen*, *weggelaufen*, *achtgegeben*. So wherever
Wiktionary writes a *ge-* somewhere other than the front, the text before it *names* the
element. The classifier does not need an inventory; it needs to read.

That turned out to be about fifteen lines. Every occurrence of "ge" is tried rather than just
the first, so a head that itself starts with *ge-* is still found (*gegengehalten* yields
*gegen* only at the second). Over-generation costs nothing, because every hypothesis still has
to reproduce the entire conjugation table before it is accepted — the same property that makes
the whole pipeline safe to be sloppy inside.

Queue: 747 → 28. Incoming verification: 84.4% → **94.6%**. Shipping code: unchanged, because
`Prefix` has always held an arbitrary string; the constraint was never in the model, only in
what the classifier thought to propose.

### Writing the guard found the bug it was guarding against

The tranche-2 importer inserts verbs into the middle of a sorted file, so I gave it the same
three preconditions tranche 1 had — no duplicate key, no duplicate hit count, file already
sorted — and then thought about the insertion order more carefully than I had the first time.
Inserting back-to-front keeps earlier indices valid, but repeated `insert()` at *one* index
reverses that batch, so verbs sharing an anchor have to go in descending key order to come out
ascending.

Tranche 1 did not do that. Checking it: 14 violations. *glimmen* before *gleiten*, *kneipen*
before *kneifen*, *saugen* before *saufen* — every one a pair of new verbs that had landed at
the same anchor. Committed and shipped six commits earlier.

Nothing caught it because nothing was looking. `Verb.verbs` is a dictionary, so file order
survives nowhere in the parsed model, and every test reads the model. The new test reads the raw
XML out of the bundle instead. It asserts non-decreasing rather than sorted, because folding
umlauts makes *drücken*/*drucken* and *zählen*/*zahlen* tie and the file breaks those ties the
opposite way from a naive sort — which is itself a fact I only know because tranche 1's guard
rejected the file and made me go find out why.

There is a pattern here worth naming. Both of tranche 1's real defects — the ß-folding and this
— were found by writing a *check*, not by writing the code. The check is where you have to state
what you believe, and stating it is what makes it falsifiable.

### Scale broke the doctrine, and the fix was to say so

Tranche 1 made four editorial decisions per verb, by hand, 78 times. At 2,303 the same doctrine
is a lie: nobody places 2,300 hit counts "between the real counts of comparable shipping verbs"
and means it. What would actually happen is a formula wearing the costume of judgment.

So both became rules, stated in the importer's header so a reader can disagree with them. `ic`
is inherited from the base verb. `hi` is the base's count times a ratio — and the ratio is
*measured*, not chosen: the corpus already ships 446 derivative/base pairs where both counts are
real DWDS, which is a calibration set that says what fraction of its base's frequency a real
German derivative actually has. Median 0.167, and the per-prefix spread is legible enough to be
reassuring: the inseparable prefixes that build lexicalized everyday verbs run high (*be-* 0.37,
*er-* 0.41, *ver-* 0.31) and the directional particles that build specific ones run low
(*weiter-* 0.04, *über-* 0.05, *vor-* 0.06). That is a real linguistic fact falling out of a
sanity check.

Then it produced nonsense, and the nonsense was instructive. Used raw, the rule put 796 of the
2,303 inside the corpus's top 500, and put *gehaben* — archaic, reflexive, thoroughly dead —
fourth overall, above *gehen*. Not a tuning problem. The ratio is a median over derivatives
lexicalized enough to have reached a top-990 frequency list, so applying it to obscure ones
inflates every single one. A derivative's frequency is not a function of its base's; it is a
fact about the world that the base does not contain.

The repair came from noticing a second measured fact pointing the other way: **every verb in
this tranche was absent from the frequency-ordered list that produced the original 990.** That
is evidence — not proof, since the list demonstrably had holes, which is the entire reason
tranche 1 existed — that these verbs sit below the measured corpus rather than scattered through
its top half. So estimates are clamped to the count of the 900th real verb.

I tried rescaling the whole tranche onto that band first, geometrically, and it was worse in a
way I would not have predicted: spreading 2,300 verbs evenly across the range discards the
magnitude the ratio actually measured, and sent *vermieten* — which every German renter says
weekly — to the rare tail. Clamping leaves every plausible estimate exactly where the
measurement put it and compresses only the half already known to be inflated. Half the tranche
is clamped, which is a blunt thing to have to report, and it is reported: the importer prints
the count.

What the number claims is now sayable in one sentence: no more common than the 900th measured
verb, and roughly this common relative to the rest of the tranche. `hp="y"` says the rest.

### What was left out

182 derivatives need an ablaut group that does not ship, and step 8 added **none**. Tranche 1
added five, each looked at individually; adding 182 by machine is precisely how a `Conjugator`
gap becomes permanent data, which is the argument `verb-classification.md` makes and which this
project has already paid for once. Most will collapse onto shipping groups once their regions
are rewritten to the house convention — that is what turned 13 into 5 in tranche 1 — so the
residue should be small, and it is now step 8b rather than a silent omission.

Four filters ran before import, and they matter more than their size: 34 verbs whose kaikki
"gloss" is a pointer to another entry ("clipping of herumfahren") rather than a translation, 11
pre-1996 or archaic spellings (*beybringen*), 2 Swiss ss-forms of a verb already present with ß,
and 36 whose gloss left nothing usable after normalization.

That normalizer deserves a note, because it is the part that ships straight to users. kaikki's
glosses are lexicographic prose — "(semelfactive, intransitive) to breathe again" — and the
corpus's own style is "reduce, dismantle". Stripping labels and parentheticals, taking the first
sense group, dropping the infinitival *to*, and capping at 42 characters gets most of the way.
The one rule I would not bend: never truncate mid-token. The classifier's own shortener cuts at
60 characters and had been producing "travel, to get around, to get out (news, gossip, rumours,
et" — which, had it shipped, would have looked to a user exactly like corruption, because that
is what it is.

Most come through well: *approach*, *checkmate*, *reprint*, *predominate*, *crawl through*. Some
come through thin — *untergehen* as a bare "set", *verkochen* as "vaporize, forwall". Spot-reading
2,303 of them is the highest-value review left, and it is recorded as such rather than declared
done.

## Auditing the handoff, and three things it was missing (2026-07-19)

Josh asked whether step 8b was safe to hand to a fresh session. The useful way to answer that
is not to reassure but to go look, because the question is really "is what you know written
down, or is it only in your context?" Three things were only in my context.

**The importer had no independent duplicate guard.** Tranche 1's script refused to run if any
verb it was about to insert already shipped. Tranche 2's relied instead on the `alreadyShipping`
flag inside `classification.json` — which is gitignored and regenerable. A fresh session that
ran the importer against a classification generated *before* the tranche landed would have
silently re-inserted all 2,303 verbs. `Verbs.xml` is the only source of truth for what ships,
and the check now reads it.

**The 182 deferrals existed nowhere on disk.** I had written the dual-auxiliary worklist to a
tracked file and left the ablaut-group deferrals as a number in a document, while describing
both as "recorded". A count is not a worklist. Both are now files, and writing the second one
surfaced the more interesting half of the problem: the two lists age differently. The deferred
list is recomputed on every run and therefore always describes the current corpus, which is what
8b wants. The dual-auxiliary list *cannot* be recomputed, because once those verbs ship the
classifier skips them — it is a historical record of what tranche 2 chose. I found that out by
running `--check` and watching the 176-verb file truncate itself to zero. There is now a guard
against writing an empty worklist over a full one, which exists for exactly one reason.

**The import needed a fixpoint, not a pass.** The same `--check` that ate the worklist reported
12 verbs still to insert. Not duplicates — genuinely new: a double-prefix verb like
*hineinversetzen* needs its inner base *versetzen* to ship before anything can propose splitting
the outer element, and *versetzen* had only just arrived. So the tranche was cascading, and
stopping after one pass would have left work on the floor that nothing would have gone looking
for. Second pass took the 12, third returned nothing. 3,371 → **3,383**, at-odds still 8.

The general shape is worth keeping. Everything I found came from asking what a reader with no
memory of this session would have on disk, and the answer differed from what I had written down
in three places — one a latent data-corruption bug, one a missing artifact, one an unfinished
job. None would have been found by re-reading my own summary, because the summary was written by
the same context that was wrong.

## Closing the Families-tab prefix-coverage gap (2026-07-19)

The plan in `prompts/prefix_coverage.md` opened by telling me not to trust its own numbers, and
that turned out to be the right instinct to inherit even though the numbers were fine. Re-deriving
from `Verbs.xml` reproduced 790 uncovered separable verbs across 206 prefixes and 133 inseparable
across 8, exactly. Cheap to check, and it meant every later decision rested on the corpus rather
than on prose that had already been stale three times in this repo.

**The test first, and it earned its place.** Written before any fix, the coverage assertion failed
with `(listed → 1245) == (family.verbCount → 2035)` and `727 == 860`. That is the defect stated in
one line: the card counts what the screen doesn't list. What I did not anticipate was the failure
message. `#expect(Set(listed) == Set(family.verbs...))` interpolates *both* sets, so the first red
run dumped 68KB of infinitives into the transcript. Rewrote it to report `missing.count` plus ten
examples. A test whose failure output is unreadable is only half a test.

**The inseparable half is the one that stays fixed.** Eight prefixes covered all 133 uncovered
verbs, and after adding them that screen is at 100% with zero remainder. That is not a coincidence
of this corpus: German's inseparable prefixes are a closed class, so any future tranche lands in a
bucket that already exists. The separable slot is open class and always will be, which is why the
other half needed a structural answer rather than a longer list.

**Two things I got to write down that I enjoyed.** Five prefixes appear in *both* lists, and the
stress is what distinguishes them: *ÜBERsetzen* (ferry across) beside *überSETZen* (translate).
The English glosses now say so. And *wieder* and *wider* are the same word, split apart by
orthographic convention in the 18th century, so they share a PIE root string in the data. `weg-`
turned out to be the best story: *Weg* and English *way* are the same word from *\*wegʰ-* "to move,
carry", which also gives Latin *vehere* and therefore *vehicle*. A prefix meaning "away" is
literally "by the road".

**The `.xcstrings` trap is worse than documented.** CLAUDE.md warns that the Edit tool breaks JSON
escaping, so I went to Python. Python broke it differently: `json.dump` writes `"key": value` and
Xcode writes `"key" : value`, so a load-modify-dump round trip rewrote all 5,400 lines
(3,789 insertions, 3,440 deletions) without changing a single value. Reverted and rewrote only the
contiguous `PIEMeaning.*` block as raw text, which landed as 425 insertions and 0 deletions. Worth
adding to the file's lore: for `.xcstrings`, neither Edit nor `json.dump` is safe, and the diff
stat is the check that tells you which mistake you just made.

**Verification hit a wall and I stopped rather than fight it.** The Separable detail screen renders
correctly and the curated `ab-` header survived the refactor, but the "Other Prefixes" section sits
below 2,035 rows and the simulator's AXTree collapsed to a bare application node on a list that
long. Taps and swipes stopped registering. Rather than keep retrying, I converted the risk the
screenshot would have caught into an assertion that the heading resolves its catalog key, which is
a better guard anyway: it runs every time instead of once. Two of the four tests in the new suite
exist because a rendering bug there is invisible until someone scrolls to exactly the wrong place.

Corpus untouched, so the classify-and-verify pipeline was deliberately skipped: nothing in this
pass can move the at-odds count of 8. 210 tests pass.

## Clearing the tranche-2 deferrals, and four bugs that were hiding as data (2026-07-19)

Step 8 imported 2,315 prefixed derivatives and deliberately left four groups behind, the largest
being **182 verbs needing an ablaut group that does not ship**. The roadmap's guess was that most
would collapse onto shipping groups once each proposal was rewritten to the house region
convention, the way thirteen proposed groups became five in step 7. That guess was right about the
outcome and wrong about the work: it reads like 182 hand edits, and it was one preference in the
classifier.

**The narrowest region wins, and it is the one least likely to match anything.** `solve` enumerates
candidate ablaut regions shortest-first and returned on the first that reproduced Wiktionary's
table. Nothing about that is wrong — the encoding it picks conjugates correctly. But a verb usually
admits several regions that all verify, and the narrow one is precisely the one no shipping group
uses: *abbeissen* verifies as `b^ei^ssen` with the replacement `I`, while the corpus writes
*reißen* as `r^eiss^en` with `ISS`, splitting no consonant off its vowel. The comment above the
loop said "shortest regions first, so `k^om^men` beats `k^omm^en` when both verify", which is a
statement about canonical form, and the early `return` quietly turned it into a statement about
group reuse. Keeping the search going and preferring a region whose group already ships took the
count from 233 to 89 in a single run. The verification is what makes that safe: a region only
reaches the comparison once it conjugates the whole verb, so choosing between two encodings is
never a choice about correctness, only about how much permanent data the corpus carries.

Then the residue got interesting, because three of the four remaining clusters were not ablaut
problems at all.

**`GEI,pp`, five verbs.** *geigen*, *geifern*, *geisseln* were being classified as `ge*`-prefixed
verbs with an ablaut that fires only in the participle. That is a fabricated ablaut doing a
prefix's job: with `ge-` treated as inseparable, `Conjugator` suppresses the participle's own
`ge-` and emits *geigt*, so the classifier invented a replacement to put the swallowed syllable
back. The guard was `!participle.hasPrefix("ge") || word.hasPrefix("ge")`, whose second clause is
true of every `ge`-initial word. The discriminator that actually works compares against `ge` *plus
the prefix*: *gegeigt* starts with `gege`, so *geigen*'s `ge-` is stem; *gehört* does not, so
*gehören*'s `ge-` is prefix. My first attempt tested the participle against the word's stem
instead, which is right for *gehören* and breaks *gewinnen* — ablaut means *gewonnen* shares only
its `ge-` with the infinitive. Worth remembering that any test on a strong verb's participle has
to survive the stem changing underneath it.

**`A,a2s,a3s|AT,bA|ÄT,dA`, twenty-three verbs, all derivatives of *haben*.** *haben*'s shipping
ablaut group was nine full-word overrides — `hATte*`, `hATtest*`, `hÄTte*` and so on — spelling
out by hand exactly what the mixed family derives from three replacements. An override bakes in
the literal word, so *anhaben* and *aufhaben* could not reuse a single one of them, and each
wanted a private group describing the pattern *haben* was already using the long way. Rewrote it
to `A,a2s,a3s|AT,bA|ÄT,dA`. This is the change I was most nervous about, since *haben* is the
auxiliary in every compound conjugation the app produces, so the evidence had to be more than my
reasoning: the pipeline verifies *haben* against all 28 of Wiktionary's slots, and the full suite
of 210 tests exercises the compound forms.

**`IT,a2s,a3s|A,bA|Ä,dA`, twenty verbs, all derivatives of *treten*.** These were blocked by
something subtler and, I think, more interesting. *treten*'s group carries `ET,pp` — a replacement
identical to the region it replaces. It spells no new letters; it exists only so the highlighting
convention marks the participle, and `ConjugatorTests` pins `getrETen` on purpose. `minimize`
drops such an entry from a *proposal*, correctly, because removing it still reproduces Wiktionary.
So the proposal and the shipping group differed in nothing a reader would ever see, and compared
unequal. The first fix I reached for was deleting `ET,pp`, which would have been me changing a
deliberate editorial convention because it was inconvenient for my matcher. Ignoring identity
replacements during comparison instead leaves the shipping group and its test alone, and the
derivatives inherit the family's highlighting — which is what you want anyway, since
*abgetrETen* beside *getrETen* is the consistent outcome.

189 verbs imported. Corpus 3,383 → **3,572**. At-odds held at 8 through every pass.

**The translations were worse than "thin", and the comment said why.** The roadmap flagged
spot-reading the ~2,300 machine-normalized translations as the highest-value review left. Sampling
twenty at random reads fine. Sorting by length does not: 131 were a single bare word, and
*aufbleiben* was shipping as **"wake"**. Its gloss is "to wake; to stay awake; to stay up", and
`normalize_translation` did `text.split(";")[0]` under a comment asserting that "a semicolon in
kaikki separates genuinely distinct senses." It does not — it separates near-synonyms, and
genuinely distinct senses get their own gloss in the list. So the rule discarded the better half of
every such definition and kept whichever synonym happened to be listed first, which for
*aufbleiben* was the one wrong one. Treating `;` like `,` fixed 106 shipped translations, all but
one strictly additive.

Rewriting shipped data needed a way to touch only what the importer generated, and nothing in
`Verbs.xml` marks that: `hp="y"` marks a provisional *count*, and both tranches carry it. Filtering
on it alone proposed replacing tranche 1's hand-written "lend, borrow" for *leihen* with a bare
"borrow", and "spoil, ruin" for *verderben* with the flatly wrong "deprive of, rob of". So I added
a fingerprint — keep step 8's exact rule around and ask whether it reproduces what ships — which
needs no marker and cannot drift. That alone was not enough either: it sweeps in the original 990,
because a translation short enough to be obvious is one any rule reproduces by coincidence, and
*wollen*'s hand-written "want" would have become "want, wish, desire, demand". Both conditions
together are exactly right. Two filters, each individually wrong in opposite directions, is a shape
worth recognizing.

**I destroyed a file and got it back.** `--check` is documented as writing nothing but the
worklists, and running it rewrote `tranche2-dual-auxiliary.txt` — the historical record of 176
verbs shipped with one reading of two — down to the 17 rows this pass happened to produce. The
guard existed and was the wrong guard: it refused to write an *empty* result, having learned that
lesson once, and 17 is not empty. Non-empty is not the same as complete. It is tracked in git, so
`git checkout` restored it; the file is now written as a union, rows only ever added, which is what
"historical and cumulative" should have meant in code and not just in a comment.

**A stale cache read the same number twice.** After importing, I re-ran the classifier and got
3,378 already-shipping verbs — the pre-import figure — and did it again before looking properly.
`alreadyShipping` is computed by `build_candidates.py` and baked into `candidates.json`; the
classifier does not read it from `Verbs.xml`. So skipping the rebuild step silently measures the
at-odds count over the old population, which is the one number this whole sequence is not allowed
to get wrong. The importer caught it before I did, with "classification.json is probably stale" —
a warning someone wrote for exactly this and which I am glad was there. The roadmap now says why
the recipe starts where it starts.

What is left of the deferrals is 78 rows, and 52 of them are exclusions that should stay: 31
duplicate spellings pointing at entries already in the corpus, 18 pre-1996 spellings (four of them
compounds the reform split into two words, which only the gloss reveals — *radfahren* looks
perfectly modern), and 3 Swiss ss-forms. The real remainder is 26 verbs needing a new ablaut group,
and the largest cluster of those is 8 verbs waiting on the *schreien* rule already in "Known gaps":
a strong verb whose stem ends in a vowel takes `-n`, not `-en`. One missing rule, nine verbs.

One test failed at the end, and it failed on purpose. `onlyImportedTranchesHaveProvisionalHitCounts`
pins the exact number of verbs carrying an estimated frequency — `78 + 2315` — rather than an upper
bound, under a comment saying the point is that "a later tranche that ships estimates has to come
here and say so." So it did, with `(provisional → 2582) == (78 + 2315 → 2393)`, and the fix was to
go and say so. Pinning an exact count is usually a brittle-test smell; here the brittleness *is*
the mechanism, because the thing being guarded is that nobody quietly grows the estimated
population while the DWDS permission request is still outstanding.

## bersten's red was too wide: caret span vs. capitalization (2026-07-20)

Josh looked at bersten's VerbView and saw *barst*, *bärste*, and *geborsten* rendering with
almost the entire word in red — `b` yellow, `arst` red. His hypothesis was that the carets in
`b^erst^en` were misplaced and should be `b^e^rsten`, since only the vowel actually departs
from expectation.

The hypothesis was right about the symptom and wrong about the cause, and the distinction is
worth writing down because it will recur.

The carets and the capitalization are two independent knobs that this group happened to have
set to the same width:

- The carets mark the **span of the stem that gets textually replaced**. `VerbParser`
  records start/end indices; `Conjugator.applyAblaut` does a literal `replaceSubrange`.
- The capitalization of the replacement string marks **which characters render red**.
  `StringExtensions.swift` tests `char.isUppercase` per character; `TextExtension.swift`
  paints uppercase `.customRed` and lowercase `.customYellow`.

bersten genuinely needs the wide span. Its Präsens is defective — *du birst* and *er birst*
are the same word assembled two different ways — and both 2s and 3s swallow the stem's `-st`:
the region `erst` becomes `ir` (plus the `-st` ending) or `irs` (plus the `-t` ending).
Narrowing to `b^e^rsten` would make 2s produce **birstst**.

The `*` full-override escape hatch that `werden` uses (`wIrst*,a2s`) is closed here:
`zer*b^erst^en` shares the group, and `applyAblaut` returns an override as the *entire*
stamm, prefix included, so *zerbirst* would come out as *birst*.

So the fix was capitalization only — lowercase the unchanged tail of each replacement while
leaving the replacement widths alone:

    IR,a2s|IRS,a3s|ARST,bA|ÄRST,dA|IRST,i2s|ORST,pp
    Ir,a2s|Irs,a3s|Arst,bA|Ärst,dA|Irst,i2s|Orst,pp

`applyEToIStemChange` is unaffected: it already compares `ablaut.lowercased()`. Updated the
six expectations in `ConjugatorTests` plus the `import_tranche1.py` source-of-truth entry
(with a comment explaining why the span stays wide). All 45 ConjugatorTests pass.

Open follow-up: bersten is not the only group whose replacement is uppercased across
characters that did not change. `nehmen`'s `AHM` (region `ehm` → `ahm`; only the vowel moved)
and `fallen`'s `ÄLL` are the same shape. Meanwhile bersten's own Ablautklasse-3 neighbors —
sterben, werfen, schmelzen, dreschen — all use single-vowel regions and mark only the vowel,
so the majority convention already matches Josh's instinct. Worth a sweep someday.

## Auditing all 73 ablaut groups for over-marking (2026-07-20)

Having fixed bersten, Josh asked whether the same over-marking was hiding elsewhere. It was —
in 20 groups covering roughly 260 verbs.

The audit needed a script, because the caret region lives on each *verb*, not on the group, so
the same replacement is applied against whatever region each member happens to mark. A group
can therefore be correctly cased for some members and wrong for others, and no amount of
reading AblautGroups.xml alone reveals it.

First attempt used `difflib.SequenceMatcher` to align region against replacement. It produced
false positives that would have been actively destructive if applied: it claimed `streichen`'s
`eich` → `ICH` was a no-op (because "ich" is a substring of "eich") and wanted it fully
lowercased, which would have rendered *strich* as though nothing had changed. Same trap for
`liegen`'s `ie` → `E`. The lesson is that opportunistic interior matching is the wrong model
for ablaut: German puts the vowel nucleus at the head of the region and lets the consonant coda
ride along, so the only alignment worth trusting is a **common suffix**, anchored at the right.

The second pass used that, and tiered the results by confidence. Two policy questions fell out
that the script could not settle, so they went to Josh:

1. **Consonant doubling.** Is `eif` → `iff` (griff) a change worth marking, or is the doubling
   predictable? Josh chose predictable — German doubling signals a short vowel, so once the
   vowel is red the doubling carries no extra information. `IFF` → `Iff`.
2. **No-op marks.** `treten`'s Perfektpartizip replaces `et` with `et` and `gebären`'s
   Konjunktiv II replaces `är` with `är` — identical strings, rendered red. Josh chose to
   lowercase them: *getreten* and *gebäre* genuinely match their stems, and saying so is honest.

One refinement emerged while applying: a shared trailing **vowel** must stay uppercase, because
it belongs to the nucleus rather than the coda. Without that carve-out the script wanted
`laufen`'s `ÄU` → `Äu` and `sehen`'s `IE` → `Ie`, which is wrong — *läuft* and *sieht* change
the whole diphthong.

Two entries had to be reverted by hand after the bulk apply. `bieten` (94 verbs) and `heben`
(16) each serve members with seven different region widths, and their Konjunktiv II `Ö` matched
the region exactly for the handful whose stem vowel is already ö (*schwören* → *schwöre*). The
script dutifully lowercased it — which would have un-marked *böte*, *flöge*, *zöge* and eighty
others, where ie→ö is a real change. There is no way to express both in one group; majority
wins, and the limitation is now written into adding-verbs.md.

38 entries rewritten, minus those 2 reverts. 67 ConjugatorTests expectations followed.
Those were regenerated from the test run's own output, which is normally how you launder a bug
into a green suite — so the regeneration script hard-refuses any failure where the produced
conjugation differs from its expectation by more than case. All 67 were case-only; all 210
tests in 31 suites pass.

The durable artifact is the new "Region Width and Capitalization Are Independent Knobs" section
in docs/adding-verbs.md, stating the policy and the bersten counterexample. Without it the next
tranche re-imports all-caps groups and the audit has to happen again. Also fixed two examples in
that file that had drifted to all-lowercase (`sehen` as `ie,a2s...`, `sein` as `bin*`), which
would have contradicted the policy paragraph sitting a few lines below them.

Deliberately left marked: real consonant substitutions, where the coda genuinely changes
identity rather than count — `bringen` `ACH` (ing→ach), `gehen` `ING`, `stehen` `AND`, `ziehen`
`OG`, `sieden` `OTT`, `mögen` `OCH`, `essen`/`sitzen` `Aẞ`. And `haben`'s `A`/`AT`: the region
`ab` loses its b entirely, so the deletion is invisible in the output and the uppercase head is
the only signal left that *hast* is irregular.

Visually confirmed on the simulator afterward via `konjugieren://verb/<infinitiv>` deeplinks —
much cheaper than driving the browse list and search field. *bersten* renders geb**o**rsten /
b**i**rst / b**a**rst; *nehmen* gives gen**o**mmen / n**i**mmt / n**a**hm; *treten* shows
**getreten** entirely in yellow, which is the Tier-2 no-op case doing exactly what it should.
*bieten* still marks geb**o**ten and b**o**t, confirming the hand-revert held and the audit
script's false positive on that group didn't ship.

## Crediting kaikki.org, and the difference between influence and derivation (2026-07-20)

Josh asked whether kaikki.org belonged in `creditsText`, given how much of the corpus expansion
now rests on it. It did, and the reason is sharper than "we should be polite about our sources".

The Credits article already named Wiktionary. But it named it in the `Etymologies and
Translations` paragraph, where the claim is that the etymologies "draw on linguistic knowledge
from Claude's training data, principally Wiktionary". That sentence describes *influence*: a
model that read Wiktionary during training and later wrote prose informed by it. Nothing about
that requires a license, and the paragraph correctly makes no license claim beyond naming
CC BY-SA in passing.

What changed on 2026-07-18 is categorically different. A 294 MB kaikki JSONL was downloaded,
parsed, and turned into `candidates.json`; `VerbClassificationTests` then searched for the
`Verbs.xml` encoding reproducing each Wiktionary conjugation table; tranches 1 and 2 shipped
2,582 verbs whose `tn` glosses were normalized straight out of kaikki's `senses[].glosses`.
That is a derivative work in the plain CC BY-SA sense, and it is in the app binary today. The
credits had no sentence covering it.

Interestingly, this was foreseen. `verbdata/README.md`'s License row has said since download day
that "attribution belongs in the Credits article if derived data ships". The conditional simply
went true two tranches ago and nobody re-read the row. That is the same failure mode this repo
keeps paying for: a correct note whose trigger condition nobody re-evaluates. The row now states
the obligation in the past tense and points at the string, so it can no longer sit there as a
pending condition.

The new `Verb Data` section discharges four CC BY-SA obligations explicitly, because attribution
is not one thing: name the source (Wiktionary), name the license (CC BY-SA 4.0), indicate that
the material was modified ("modified in the course of import"), and make the derivative
available under the same license (the GitHub repo, already linked earlier in the article). It
then adds the two things kaikki.org itself asks for, neither of which is legally compelled: a
link to the site, and the citation to Tatu Ylonen's LREC 2022 paper, *Wiktextract: Wiktionary as
Machine-Readable Structured Data*. Paying an academic citation in an iOS app's credits screen is
mildly funny, but wiktextract is the reason the import was a weekend's work instead of a crawl,
and Ylonen asked in one sentence.

Mechanics worth remembering: the section was spliced with Python against the raw file rather
than the Edit tool, per the `.xcstrings` rule, though in the end the text contains no ASCII
double quote at all. Avoiding them was deliberate: the paper title is set in `~...~` emphasis
rather than quotation marks, which sidesteps JSON escaping entirely and matches how the article
already sets `Etymologisches Wörterbuch der deutschen Sprache`. `git diff --stat` shows 2
insertions and 2 deletions, which is right here and would be wrong for an *added* entry: two
existing long value lines were edited in place, not reformatted.

A companion question came up and was settled the other way. The app displays a frequency rank for
all 990 original verbs, derived from DWDS hit counts, and `creditsText` mentions DWDS only inside
that same training-data paragraph. DWDS's terms do allow citation with a Quellenangabe, so a
credit line could be written today. **Josh's call: leave it TBD pending a reply from BBAW, if one
comes.** The asymmetry with kaikki is the point. Wiktionary's CC BY-SA obligation is unilateral
and unambiguous, so there is nothing to wait for and the credit went in immediately. DWDS is an
open request whose answer may change both what the app is permitted to ship and what the right
wording is, and writing the credit first would quietly presume an outcome. The permission email
went out 2026-07-19; see `docs/dwds-permission-email.md`.

## Markdown files get unit tests, and the first run found nine problems (2026-07-20)

Josh, on being told that the "if derived data ships" note in `verbdata/README.md` had been an
untested assertion for two tranches: "If only Markdown files had unit tests. :)"

Some of them can be. The joke has a real answer, and running it embarrassed the repo.

### The signal-to-noise problem, and the rule that solves it

A naive `grep` for "N verbs" across the repo returns 60 hits, of which 55 are correct. That is the
whole difficulty. `blog_notes.md` is *supposed* to say 990 in an entry written when the corpus held
990; `roadmap.md` records "corpus 3,383 → 3,572" as history; `verb-sources.md` quotes Conjuguer's
6,200 and a 9,217-candidate pool, neither of which is Konjugieren's corpus. A smarter regex does
not fix this, because the sentences are grammatically identical.

The discriminator is not in the text, it is in the file's *job*, and this repo already names that
job in prose without ever making it mechanical. CLAUDE.md calls `project-structure.md` a cache.
`roadmap.md` opens by calling itself one. `blog_notes.md` is dated project memory whose entire
value is preserving what was true then. So: **caches assert, journals narrate**, and only caches
get checked. `CACHE_FILES` in `scripts/check_docs.py` is four entries long, and adding a fifth is
a promise that the file makes no historical claim about corpus size.

### What the first run found

Four stale counts, all in cache files, all wrong in the same direction:

- `docs/description.md`, the **App Store copy**, said 3,383 against 3,572. That file is named in
  `verb-sources.md` § "Verify counts, do not trust them" as the file that shipped a wrong count to
  the App Store once already. It has now done so twice.
- `CLAUDE.md` and `docs/project-structure.md`: 3,383.
- `README.md`: 990 verbs and 988 verbs, the latter 2,582 behind. Also 66 ablaut patterns against
  73, and 113 test functions against 210, in two places.
- One broken link: README pointed at `Models/GameState.swift` after the file moved to
  `Models/Game/`.

The counts had been stale for two commits. The README figures had been stale for months.

### The checker's own two bugs, which are the same bug

The first run also produced five false positives, and both classes taught the same lesson: **a
count is checkable only when its subject is unambiguous.**

CLAUDE.md says `ConjugatorTests.swift` contains "~25 test functions" and `project-structure.md`
says "~50". Both true, both about one file, both flagged against the suite-wide 210. "3,572 verbs"
is safe because the app has exactly one corpus; "N tests" is not, because prose routinely scopes it.
The fix is one rule: skip lines that name a `.swift` file, because naming the file *is* the scoping.

The commit-hash check flagged five hashes, and every one was correct prose. `52e4d6f` is an
ios-build-verify marketplace commit; `1f359d4` is Conjuguer's; `ee61032` and `c2e9632` are
Conjugar's. Konjugieren's docs cite sibling-app commits routinely and nothing in the text marks
them as foreign. So that check is scoped to `roadmap.md`, whose "Done, for the record" table is
this repo's own provenance by construction.

Both scopings are the same move as `CACHE_FILES`: decide *what a claim is about* before asserting it.

### A checker that has never failed is an expensive `true`

Every check was then negative-tested: perturb one file, confirm the exit code flips and the right
check names the right problem, restore from an in-memory copy in a `finally`. Two of the five
attempts were themselves instructive.

The attribution test "passed" when it should have failed, because renaming one mention of kaikki
left `https://kaikki.org/` and "Kaikki.org lives here" in place. The credit really was still
there; my test was wrong, not the checker. Removing all six mentions produced the failure message
that would have been showing throughout the day the credit was actually missing:
`2582 verbs carry hp="y" (kaikki-derived), but Info.creditsText never names kaikki.org`.

The etymology check fired on correct text, because I had written "**INCOMPLETE**" and a substring
test for "COMPLETE" matches it, as does the paragraph quoting the old headline verbatim. The
predicate has to match the *claim*, not the word: `^\*\*COMPLETE\b`, anchored to the bolded status
line.

### The find that justifies the whole exercise

Josh then asked why `etymology-pipeline.md` sat at the repo root when
`docs/example-sentence-pipeline.md` and friends live in `docs/`. Moving it turned up something
much worse than a misplaced file.

That document's headline read **"COMPLETE — every verb in `Verbs.xml` is translated"**, verified
2026-07-19. `Etymologies.json` holds 990 keys. The corpus holds 3,572. **2,582 verbs have no
etymology at all, in either language**, so the app's etymology surface covers 28% of the corpus
and the doc claimed 100%. Tranche 1 landed the same day the claim was verified, and falsified it
within hours.

The detail that makes this the best possible argument for the script: two lines below that
headline, the same file says *"Do not restate the verb count here. `Verbs.xml` is the single source
of truth, and this file previously claimed 989 long after the corpus reached 990"*, and supplies a
one-second coverage command. The warning was right, the recipe was right, the recipe disproves the
headline directly above it, and nobody ran it. Writing the check down is not running the check.
That gap is the entire thesis of `check_docs.py`, stated by accident, by a file that fell into it.

The file also resolves a small mystery. `blog_notes.md` records a session concluding there is no
`etymology-pipeline.md` in the repo "and, as far as I can tell, never has been". It has been in git
since commit `23076d0`. It was at the root, and the sessions looking for it searched `docs/`. Two
independent sessions failed to find a file that was one `ls` away, which is a better argument for
Josh's consistency instinct than tidiness ever was.

### What this does not do

Nothing here checks whether prose is *right*, only whether it is *consistent with the data*.
`check_docs.py` cannot tell that a decision has been superseded, that an explanation is confused,
or that a recommendation stopped being good advice. It settles the mechanical subset. That subset
turned out to contain nine live defects, one of which had reached the App Store.

## Wiktionary invents conjugations, and "verified" stopped meaning "correct" (2026-07-20)

Josh asked for one example of a verb whose prefixed form shipped in the original 990 while its bare
base arrived later. Answering it properly turned up a hole in the foundation of the entire
verb-import project.

### The example, and the technique that found it

Five verbs qualify: *vermeiden*/*meiden*, *verschwinden*/*schwinden*, *verleihen*/*leihen*,
*überwinden*/*winden*, *überschreiten*/*schreiten*. All strong, all inseparable, all tranche 1.

The technique matters more than the answer. Naive suffix matching returns 50 pairs, mostly
nonsense: *bringen* as *b-* + *ringen*, *schreiben* as *sch-* + *reiben*. But `Verbs.xml` writes
`ver*m^ei^den`, where `*` marks the inseparable prefix and **the base keeps its ablaut region
verbatim**, so the remainder after the marker is character-for-character the standalone `m^ei^den`.
Requiring exact remainder match cuts 50 to 5.

It also answers, for free, the quirk Josh's prompt asked the pipeline to handle: it rejects
`be*gleiten` against `gl^eit^en`, because *begleiten* descends from MHG *geleiten* rather than from
*gleiten*, which is why it is weak while *gleiten* is strong. The encoding already knew. Nobody had
asked it.

### The near-miss scan, and what it exposed

Scanning instead for *near* misses — base ships, but the two disagree on encoding — returned 66,
of which 38 were verbs encoded weak whose base is strong. Spot-checking four against kaikki
produced this:

| Verb | Wiktionary says | Actual German |
|---|---|---|
| abgleiten | abgleitete / abgegleitet | glitt ab / abgeglitten |
| anlesen | anleste / **angelest** | las an / angelesen |
| aufwaschen | aufwaschte / **aufgewascht** | wusch auf / aufgewaschen |
| auspfeifen | auspfeifte / ausgepfeift | pfiff aus / ausgepfiffen |

*angelest* and *aufgewascht* are not German words. English Wiktionary **auto-generates a default
weak conjugation table** for any verb page nobody supplied a strong template for. The base entries
(*lesen*, *waschen*, *pfeifen*) are correctly strong; only the under-edited derivative pages are
corrupt.

Which means the importer did nothing wrong. It hypothesized weak, compared against Wiktionary's
table, matched exactly, and shipped. The at-odds count held at 8 the entire time, because the app
faithfully reproduces a corrupt source.

**"Verified" means "agrees with Wiktionary", not "correct", and nothing inside the pipeline can
tell the two apart.** That is the load-bearing assumption of steps 2 through 9, stated for the
first time only now, in its negative form.

### Arbitration, and a heuristic that broke on German word order

kaikki could not adjudicate, being the corrupted source. German Wiktionary could: it is
independently edited and its `{{Deutsch Verb Übersicht}}` box carries principal parts directly. 38
API calls settled 34 of them.

The first classification pass reported 12 defects and 14 "unclear". The unclear ones were an
artifact: my weak-detector tested whether the Präteritum ended in *-te*, and German Wiktionary
writes the *split* form. "hängte auf" ends in *auf*. Stripping the trailing particle before
testing the stem resolved all ten cleanly, every one of them weak and correctly shipped.

Final triage: **12 defects, 22 vindicated, 4 unknowable** (no German entry at all). The
discriminator that explains the 22 is worth keeping: a weak derivative of a strong base is normally
**denominal or deadjectival** — *umringen* from *Ring*, *bemitleiden* from *Mitleid*, *aufweichen*
from *weich*, *veranschlagen* from *Anschlag*. A transparent prefix + strong verb compound encoded
weak is the defect signature.

Eleven were fixed by inheriting the base's encoding, which is just the tranche-2 rule. Two were
deferred, and both land on gaps already in the roadmap: *verglimmen* is weak Präteritum with strong
participle, the *mahlen*/*spalten* class the model cannot express; *verschreien* needs the
vowel-stem *-n* rule, making it the ninth verb waiting on the single highest-value `Conjugator` fix
outstanding.

### The metric started punishing the repair

Then the interesting part. Re-running the pipeline took the at-odds count from **8 to 17**, and the
summary named my eleven fixes as the offenders. The roadmap says of that number, in bold, "it
should never rise."

But eleven of those seventeen are correct German disagreeing with a corrupt table. Left as prose,
this is a trap with a fuse: a future session sees 17, reads the injunction, and reverts today's
work to restore the number. That is precisely this morning's lesson wearing a different hat, so it
got the same treatment. `verbdata/wiktionary-defects.json` records each verb, what Wiktionary
claims, what is correct, and which authority settled it; `summarize_classification.py` subtracts
them and reports the raw count alongside. Back to 8, with the divergence visible as data rather
than as a paragraph asking to be believed.

Adding a verb to that file is a claim that an outside source contradicts Wiktionary, and the schema
demands you name it. It is not a mute button.

**The 5,650 incoming verbs have never been screened for this**, and the same generated tables are
what tranche 3 will verify against.

### The pipeline Josh actually asked for

The task underneath all this was designing a combined etymology-and-example-sentence pipeline for
the 2,582 verbs that have neither. Two of his premises checked out exactly.

Conjugar's index really exists and works as he remembered, though the load-bearing piece is not the
index but the **form→lemma map** produced by driving the app's own conjugation engine over every
verb (`CorpusFormsDumpTests.swift`, 52,166 forms), enabling exact whole-token matching that
"handles irregular stems and avoids substring false positives". And the current Konjugieren
pipeline documents its own inefficiency in writing: `example-sentence-pipeline.md` contemplates a
pre-filter and declines it, because "the subagent can read files directly from `corpus/`".

The measurement that justifies the whole redesign: of 2,582 missing verbs, 97% are prefixed, they
reduce to **382 distinct roots**, and **303 of those roots already have an etymology** — shipping
inside their prefixed relatives, since the existing entries decompose into bullets. So the
etymology half is 79 new roots plus 2,582 cheap compositions, not 2,582 acts of scholarship. Josh's
instinct was right by an order of magnitude more than he argued for.

The one genuinely hard part has no Spanish analogue. **76% of the targets take a separable prefix,
and German splits them in main clauses**: *anfangen* surfaces as "er fängt neu an", particle
stranded at clause end. Whole-token matching scores zero on the commonest written form of
three-quarters of the queue. The answer is to index only contiguous forms first (infinitive,
*zu*-infinitive, participle, and every verb-final subordinate clause, all abundant in legal and
literary German), then a split-form rescue pass for zero-hit verbs.

German also gives something back. Conjugar's worst recurring bug was noun homographs draining
candidate slots, needing an entire extra stage. German capitalizes nouns, so *das Ringen* is
mechanically distinguishable from *ringen*. The same trap is nearly free to dodge here.

Design is in `prompts/uses_etymologies.md`. Concurrency is the tunable knob rather than shard size,
per Josh: shards stay ~25 verbs so a resumed run has uniform units, and `MAX_CONCURRENT` starts at
2 and rises toward whatever a five-hour window sustains.

## The vowel-stem -n rule, and a fix that did not unblock what it was supposed to (2026-07-20)

The roadmap called this "the highest-value `Conjugator` fix outstanding": a strong verb whose stem
ends in a vowel takes `-n`, not `-en`. *wir schrien*, not *schrieen*. Nine verbs were said to be
waiting on it. It took about fifteen lines, it works, and it unblocked none of them.

### The rule

A stem already ending in `-e` absorbs the `e` of an `-en` ending. Both doubled spellings were
correct until the 1996 reform, which is why sources disagree: *geschrieen* became *geschrien*.

Two details decided the implementation. First, the test is on the **stem**, not the infinitive.
`hasSyllabicStamm`, the existing analogue for `-ern`/`-eln`, keys off the infinitive, and copying
that would have been wrong here: *schreien*'s Präsens stem is *schrei*, which takes the full ending
(*wir schreien*), while only its Präteritum stem *schrie* contracts. The negative case is now
pinned in `ConjugatorTests` precisely because it is the one a future session would break.

Second, the comparison has to be case-insensitive. This corpus marks ablaut regions in uppercase,
so the ablauted stem reads `schrIE`, and `hasSuffix("e")` returns false on it. That would have been
a silent no-op: every test still passing, the bug untouched.

The payoff beyond the plural: *schreien*'s ablaut group could drop its full-override participle,
`IE,bA,dA|geschrIEn*,pp` becoming `IE,bA,dA,pp`. An override spells out a literal word, so no
derivative can reuse it — the same pathology that `haben`'s nine overrides had, cleared in step 8b.
*verschreien*, deferred that morning for exactly this reason, was fixed onto the repaired group.

### The part that did not work

The eight blocked derivatives — *anschreien*, *anspeien*, *aufschreien* — still want a group that
does not ship, and the run after the fix proposed the identical pattern as before:
`I,b1p,b3p,dA,pp|IE,b1s,b2p,b2s,b3s`.

Reading kaikki's actual table for *schreien* explains why, and the diagnosis in the roadmap was
simply wrong. Wiktionary's Konjunktiv II is *schrie / schriest / schrie / schrien / schriet /
schrien* — identical to the indicative, tagged *rare*. The app ships *schriee / schrieest / …*, the
mechanical Präteritum-stem-plus-`-e` formation the grammars give.

So that exotic pattern was never about the `-n` rule. Decode it: `I` applies to `dA`, all of
Konjunktiv II, producing *schrI* + *e* = *schrie*. The whole contraption exists to remove one `-e-`
from the Konjunktiv II. It is a workaround for an **editorial disagreement**, not for a missing
engine rule, and no amount of `Conjugator` work will dissolve it. Somebody has to decide whether
*ich schriee* or *ich schrie* is the Konjunktiv II of *schreien*, and then all nine verbs follow
from that one answer.

The roadmap now says so, and the tranche-2 deferral note that carried the wrong diagnosis was
corrected rather than left to send the next session after the same phantom.

### What the fix is worth anyway

The 1p/3p Präteritum really was wrong and now is right, for *schreien* and every future derivative
of it. One full override left the data. And the residual disagreement went from "three ablaut groups
are wrong and remain unexamined" to a single named question with a yes/no answer. That last part is
most of the value: the gap did not close, but it stopped being mysterious.

At-odds held at 8 across the whole change; 210 tests pass.

## Generalizing the rule dissolved the editorial question (2026-07-20)

Continuing from the entry above, which ended by declaring the *schreien* residue an editorial call
for Josh: is the Konjunktiv II *ich schriee* or *ich schrie*? He asked the right question back,
which was whether one is more common, and answering it properly showed the question should never
have been asked.

### Measuring it, and the confound that nearly reversed the answer

Only one of the two candidates is measurable. *Schrie* is also the indicative Präteritum, so
counting the string says nothing about the subjunctive. *Schriee* is unambiguous. It occurs **zero
times** in the 17 MB corpus; so do *schrieest* and *spiee*.

The trap: *schrieen* occurs **59** times, which reads as support for the uncontracted forms. It is
not. This corpus is overwhelmingly pre-1996 — Luther 1912, Goethe 1774, Grimm 1921, Nietzsche,
Westphalia 1648 — and *schrieen* is the **old indicative plural spelling** of *schrien*. A corpus
that predates the reform cannot adjudicate a post-reform orthography question, and the raw count
points the wrong way if you forget that.

The documentary evidence was one-sided: de.wiktionary's `Flexion:schreien` gives the contracted
paradigm with no alternatives and no *selten* marking, English Wiktionary agrees, and kaikki shows
*speien* running parallel with *spie*.

### The question was a scoping bug wearing a costume

The real finding is that *schrie* versus *schriee* is not a paradigm choice at all. It is the same
orthographic rule from the previous entry, scoped one notch too narrowly. I had written it as "a
stem ending in `-e` absorbs the `e` of an `-en` ending". The actual rule is "a stem ending in `-e`
absorbs an **ending-initial** `e`":

    schrie + e   -> schrie      (Konjunktiv II 1s/3s)
    schrie + est -> schriest    (Konjunktiv II 2s)
    schrie + et  -> schriet     (Konjunktiv II 2p)
    schrie + en  -> schrien     (already handled)

Independent confirmation that it is general and not a *schreien* special case: *ich knie*, not *ich
kniee* — weak verb, present tense, same absorption. German does not write that `ee` across the
boundary, in any tense or family.

Generalizing turned one narrow conditional into a small helper returning the shortened ending, used
at both call sites. Results: *schreien* now verifies against Wiktionary **with the encoding it
ships**, `shippedEncodingFailed` false and `ablautGroupIsNew` false, where both had been true. The
at-odds count went **8 → 7**. And the category "shipping strong or mixed verbs needing an ablaut
group that does not ship" went from 1 to **0**, which had never been empty before.

The general lesson is one this repo keeps relearning from the other direction: when a rule you just
wrote leaves a residue that looks like a judgment call, suspect the rule's scope before accepting
the judgment call. An editorial decision is a bad thing to spend when a missing case is what you
actually have. I had already written the roadmap entry declaring it Josh's call, and it was wrong.

### The eight are still blocked, for a third reason

*anschreien*, *anspeien*, *aufschreien* and friends still propose the exotic
`I,b1p,b3p,dA,pp|IE,b1s,b2p,b2s,b3s`, even though `IE,bA,dA,pp` — shipping as `ag="schreien"` —
must now verify for them, their base having just verified with it.

This is now a **classifier preference**, not an engine gap, and the diagnosis is precise. Step 8b
taught the classifier to prefer a *region* whose group already ships, keeping shortest-region as
the tiebreak. Both candidates here use the same region, `ei`, so the preference cannot discriminate
and the tiebreak picks the exotic one. Extending 8b's preference from regions to whole *patterns*
should finish it: when several verify, prefer one that already ships.

That is three different diagnoses for the same eight verbs in one day — missing `-n` rule, then
editorial disagreement, then classifier tiebreak — of which the first two were wrong. Each was
written down confidently. Worth remembering next time a stated cause feels settled.

## The third fix, and why the classifier could not see the answer (2026-07-20)

The generalized absorption rule made *schreien* verify with the encoding it ships, but its eight
derivatives went on proposing the same exotic group. Josh asked for the classifier fix too.

The cause was not a tiebreak, which is what the previous entry predicted. It is in `derive`, which
computes each slot's replacement by string arithmetic against Wiktionary's form and takes the
shortest that lands. For *anschreien* it reads `I` from *schrien*, because *schr* + `I` + *en*
spells it exactly, and `IE` from *schrie*, where no ending follows to absorb anything. The result
is a pattern split by person that verifies perfectly and matches no shipping group. Meanwhile `IE`
everywhere — the group *schreien* itself ships — verifies just as well now that the Conjugator
absorbs the ending-initial e. The classifier never tried it, because it only ever compared its own
derived pattern against the shipping list.

So the fix generalizes step 8b's principle one notch: before fabricating a group, **try the
shipping groups themselves against the full table**. That sounds expensive, a 73-group scan per
verb, and it is not: it runs only in the branch where the classifier was about to invent a group,
which is a few dozen verbs out of 9,217. Runtime went 34s to 38s.

Results, none of which required touching data:

- incoming verbs needing a new ablaut group: **37 → 18**
- distinct proposed patterns: **23 → 14**
- `tranche2-deferred.txt`'s ablaut-group category: **26 → 11**

Four clusters collapsed and only one was the target. Besides the *schreien* eight, *gutgehen* and
*schiefgehen*, *unterbleiben* and *zubleiben*, and *festwachsen* and *widerfahren* all turned out
to be verbs whose correct group was already in the corpus and simply never attempted. The pattern
of the whole day repeats: the blocker was not missing knowledge, it was a search that stopped early.

### An artifact worth flagging rather than fixing

The classifier now assigns the *schreien* family to `ag="bleiben"`, not `ag="schreien"`. With its
full override gone, *schreien*'s group is byte-identical to *bleiben*'s, `IE,bA,dA,pp`, and the
scan takes the alphabetically first among equals. *bleiben* carries 126 verbs; *schreien* carries 2.

Merging them is the obvious tidy-up and was deliberately not done. Ablaut groups are **user-facing**:
each has an `AblautGroupInfo.<name>` description with localized strings and a browsable entry, so
retiring *schreien* deletes something a reader can see. That is Josh's call, not a data cleanup.

### Three diagnoses, two wrong

Worth recording plainly, since all three were written down with confidence on the same day. The
eight verbs were blocked by, in order: a missing vowel-stem `-n` rule (real, but not the blocker),
an editorial disagreement over Konjunktiv II (not real — a scoping bug in the rule I had just
written), and a classifier that never tried the answer it already had (the actual cause). The first
two are in the git history as corrected roadmap entries rather than quietly rewritten, because the
sequence is the lesson: a confident diagnosis in this repo has been wrong twice in one afternoon.

## Screening the incoming pool, and three dead ends worth recording (2026-07-20)

The morning's finding — English Wiktionary auto-generates weak conjugation tables for verb pages
nobody supplied a strong template for — left an obvious worry: 11 of 38 shipping candidates were
defects, and 5,218 verified incoming verbs had never been checked. Tranche 3 will verify against
those same tables.

The pool turns out to be nearly clean. **One genuine instance: *rauswaschen*.** kaikki gives it
*rauswaschte / rausgewascht*, neither of which is German, while its base *waschen* is correctly
strong — the identical shape to *reinwaschen*, repaired that morning. It is not yet shipping, so
this is a note to the importer rather than a bug.

### The dead ends, which are the useful part

**kaikki's own class tag cannot flag this.** Of all incoming weak-classified verbs, exactly zero
carry a `N strong` tag. That looked at first like evidence of cleanliness and is nothing of the
kind: the tag is emitted by the strong template, which is precisely what a corrupt page lacks. The
metadata that would identify the defect is missing for the same reason the defect exists. A signal
absent from the corrupt population is not a signal.

**de.wiktionary does not categorize verbs as strong or weak.** I expected a category to intersect,
which would have made this a two-request screen. Checking the categories on *schreien* shows
`Verb (Deutsch)` and `Verb untrennbar (Deutsch)` but nothing about ablaut. The route does not exist.

**The prefix-and-base screen is narrow but decisive where it applies.** Of 1,998 prefixed incoming
weak verbs, the base is a known strong verb for exactly one. 493 further bases were unknown to the
corpus; resolving each against kaikki surfaced only *spalten*, which is wrinkle 4 rather than
corruption.

**de.wikipedia's "Liste starker Verben" is the broad net that worked.** 566 bolded verb tokens
intersected against 5,035 incoming weak verbs gave 21 hits, most of them expected once you notice
what the list is: it bolds weak *causatives* beside their strong relatives — *tränken* beside
*trinken*, *säugen* beside *saugen*, *henken* beside *hängen*. Those are correctly weak. Arbitrating
the genuine maybes against de.wiktionary cleared *schrecken*, *abschrecken*, *aufschrecken*,
*kreischen*, *heischen* and *zerspalten*.

### Two things that look like the defect and are not

*abspalten* and *aufspalten*: de.wiktionary gives *spaltete ab / abgespalten*, weak Präteritum with
strong participle. That is wrinkle 4, the *mahlen*/*spalten* class the model cannot express, and it
now has company — *verglimmen* landed there this morning.

*lobpreisen*: kaikki lists **both** paradigms, *lobpreiste/gelobpreist* and *lobpries/lobgepriesen*,
so the weak classification verified legitimately. Dual-paradigm verbs are an editorial choice at
import, exactly as tranche 1 recorded for *melken*, *weben* and *sieden*.

### What remains uncovered, stated plainly

A **bare** strong verb whose page is corrupt has no prefix and no base to compare against, and is
caught only if the Wikipedia list happens to name it. That list is thorough for standard strong
verbs, so coverage is good — but it is not provable, and saying "the pool is clean" would overclaim.
The honest statement is that every avenue available without bulk-fetching de.wiktionary has been
tried, and one verb came out.

## Merging a duplicate ablaut group, and why it was not a deletion (2026-07-20)

Once *schreien*'s full-override participle was retired, its ablaut group became byte-identical to
*bleiben*'s: `IE,bA,dA,pp`. *bleiben* carried 126 verbs, *schreien* two, and the classifier had
already begun assigning the whole *schreien* family to *bleiben*, alphabetically first among
equals. Josh asked for the merge.

The mechanical part was four coordinated edits: repoint *schreien* and *verschreien* to
`ag="bleiben"`, delete the `<ag>` element, drop `"schreien"` from `AblautGroupInfo.exemplars`, and
remove the orphaned `AblautGroupInfo.schreien` strings. The inventory went **73 → 72**.

### The part that mattered

Ablaut groups are not internal identifiers. Each has a localized description and a browsable entry
in the Families tab, so retiring one deletes something a reader can see. And *schreien*'s
description taught something *bleiben*'s did not:

> Contracted participle: $schrEIen$ → $schrIE$ → $geschrIEn$. The -en contracts to -n.

That is a lesson about exactly the rule `absorbsLeadingE` implements, and dropping it would have
traded a small data tidy-up for a real loss of teaching in an app whose whole purpose is teaching.
It was folded into *bleiben*'s description in both languages instead. The general rule, worth
keeping: **retiring a group is only safe when its teaching survives the move.** A merge that is
correct in the data can still be a regression in the product.

### Two small confirmations

Deleting an `.xcstrings` entry is the mirror of adding one, and the same discipline applies:
brace-count from the key rather than round-tripping through `json.dump`, then read
`git diff --stat`. It showed 2 insertions and 19 deletions — the two edited *bleiben* values, plus
the 17-line removed entry — with no reformatting churn. For a deletion, deletions are expected; what
would signal trouble is the count exceeding the entry's own size.

And `scripts/check_docs.py`, written this morning, immediately caught what I would otherwise have
missed: `README.md` claimed 73 ablaut patterns against the new 72, in two places. That is precisely
the failure it exists for — a number in prose that no code consumed, stale within minutes of a data
change. It was green again within a minute. Writing the checker took an hour; it has now paid for
itself twice in one day.

At-odds held at 7; 210 tests pass.

## Phase 1 of the etymology-and-example pipeline: a form→lemma map, and the particle problem (2026-07-20)

Phase 1 of `prompts/uses_etymologies.md` is one file:
`KonjugierenTests/Utils/CorpusFormsDumpTests.swift`. It drives `Conjugator` over every verb and
every reading and writes `corpus/working/forms.json`, so that Phase 2's indexer can match corpus
tokens deterministically instead of making 2,582 subagents each search 6.5 MB of German prose.
That is the Conjugar trick, copied on purpose: move the expensive part off the LLM, and leave the
model only the select-and-translate judgment it is actually good at.

Writing it took twenty minutes. Reading `Conjugator.swift` first took longer, and was the whole
job, because three things about its output are invisible from the call site and each one would
have produced a plausible-looking, silently wrong index.

**Conjugations come back mixed case.** `applyAblaut` splices the replacement region in from
`AblautGroups.xml` in uppercase, so `singen`'s Präteritum is literally `sAng`. That casing is
highlighting metadata for the UI, not orthography. An indexer that took it at face value would
match nothing, and would do so quietly — a zero-hit verb looks exactly like a verb the corpus
doesn't attest.

**Only the Imperativ splits a separable prefix.** This is the interesting one. The design doc
already flagged that German strands the particle at clause end — *er fängt neu an* — and that
Conjugar's whole-token exact match therefore scores zero on the most common written form of
three-quarters of the target verbs. What the doc could not know without reading the code is that
*the app has never needed the split form either*. `conjugateSimpleTense` returns `stamm + ending`
with the prefix still attached, giving `anfängt`, because a paradigm cell is not a clause and has
nowhere to strand anything. `withSeparablePrefix` — the one function that does the splitting — is
reached only from `conjugateImperativ`. So the split forms are not harvestable from the engine;
they are synthesized here, by dropping the separable run off each contiguous finite form.

That synthesis needed a guard I did not anticipate. An ablaut group may fully override the stem
via the trailing-`*` convention, and a full override replaces the stem outright, prefix and all.
Dropping a fixed character count from such a form would emit a mangled token that would then
match nothing while looking like a real entry. The fix is a `hasPrefix` test before slicing —
cheap, and the kind of thing that is obvious once stated and invisible until it bites.

**Compound conjugationgroups had to be skipped.** The phase text says "every conjugationgroup ×
every person," and following it literally is wrong. `conjugateCompoundTense` returns
`auxiliary + " " + secondPart`, where the second part is either the Perfektpartizip or the bare
infinitive — both of which the harness already emits directly. Walking the compound groups adds
no form for the verb itself, and maps `habe` and `werde` onto all 3,572 verbs. `habe` attests
*haben*, and *haben* emits it from its own Präsens. A false attestation in a form→lemma map is
worse than a missing one, because the subagent downstream has no way to tell.

**The reading walk paid off in a way I expected only half of.** Iterating every reading rather
than the primary is obviously right for *hängen*, which is `hing` intransitive and `hängte`
transitive; both attest the lemma. What I did not predict is that it is the *only* thing that
produces split forms for the four separability doublets — *übersetzen*, *überstehen*, *umgehen*,
*unterstellen*. Their `in` attribute carries `*`, not `+`, because the primary sense is
inseparable; the separable sense ("ferry across", "protrude", "make a detour", "take shelter")
lives in a secondary `<reading>` with its own respelled `in`. The count caught it: 2,193 verbs in
`Verbs.xml` have a `+`, but 2,197 lemmas ended up with split forms. Chasing that discrepancy of
four was how I confirmed the walk was doing real work rather than duplicating it. A cross-check
that comes out *almost* right is worth more than one that comes out exactly right, because only
the first one tells you something.

### Two pieces of harness friction, both silent

The first run reported `Test Succeeded` and executed zero tests. `-only-testing` takes the
**struct name**, `CorpusFormsDumpTests`, not the `@Suite` display name `CorpusFormsDump`. A
non-matching filter is not an error. The neighboring failure mode is the same shape: xcodebuild
forwards a host variable into the simulator only under the name `TEST_RUNNER_<NAME>`, so setting
the bare `KONJUGIEREN_FORMS_OUT` leaves `.enabled(if:)` false and the gated suite skips —
green, silent, nothing written. `docs/verb-classification.md` records the prefix rule; the
struct-name rule is now in the pipeline doc next to it.

Both are worth stating plainly because they share a property: the harness reports success. A
gated, filtered, file-writing test can fail in three different ways that all look identical from
the terminal, and the only reliable check is whether the output file exists and has plausible
contents.

### Result

~50,000 distinct forms, ~77,000 entries, about two seconds. Every one of the 3,572 verbs is
reachable by its own infinitive, no entry disagrees with itself about `contiguous` versus
`particle`, and no key is capitalized or contains a space. `corpus/` is gitignored, so
`forms.json` is a build product rather than a checked-in artifact.

`Verbs.xml` was not touched, which the pipeline doc asks to be confirmed rather than assumed:
`git status` shows it unmodified, so the at-odds count cannot have moved and there was nothing to
re-measure. `scripts/check_docs.py` earned its keep again — the new `@Test` took the suite from
210 to 211 and it flagged all three stale claims in `README.md` within seconds of the change,
including the file count that went from eighteen to nineteen. That is twice now that a number no
code consumed went stale within minutes of a change, and twice that the checker caught it before
a commit did not.

Next: Phase 2, the corpus index.

## The corpus index, and four things German does that Spanish does not (2026-07-20)

Phase 2 of `prompts/uses_etymologies.md`: turn ~6.5 MB of German text into a per-verb list of
pre-found candidate sentences, so that the Phase 4 subagents never read the corpus wholesale.
Conjugar had already built this shape for Spanish, and the port started as a genuine port — same
constants, same tier priority, same round-robin merge with a rotating lead work so the first
candidate a subagent sees is not always Luther. All of that survived unchanged.

Everything else was German.

### The English translations are a minefield

`corpus/modern/` ships each work twice, German and English. Ten common English words are also
German verb forms in `forms.json`: *war* → sein, *will* → wollen, *hat* → haben, *sang* → singen,
*band* → binden, *sank*, *fall*, *rang*, *fang*, *sing*. Indexing `kafka-prozess-en.txt` would
have attested German verbs from English prose, and the snippets would have looked plausible right
up until they shipped. Conjugar never had to think about this because its corpus was monolingual.
Skipping `*-en.txt` was the first line of German-specific code.

### The line is the wrong unit

Conjugar scanned one physical line at a time, which is fine when every candidate is a single
token. German splits separable prefixes in main clauses — *anfangen* surfaces as "er **fängt** neu
**an**" — so the particle has to be sought somewhere else in the sentence. And these sources are
hard-wrapped: Kafka at ~68 characters, the government PDFs at ~43. A German sentence runs well
past 100 characters, so it spans two to four physical lines and the particle is routinely not on
the verb's line at all.

So the reader had to be rebuilt: reflow each blank-line paragraph into running prose, split it
into sentences (with a German abbreviation guard, because the legal texts are wall-to-wall "Art. 5
Abs. 2"), and match sentence-wise. The grammar problem propagated all the way down into the I/O
layer, which was not obvious from the phase spec.

### "Particle later in the same sentence" is 70% wrong

The spec said to match a split form when the finite stem appears and the particle occurs later in
the same sentence. Implemented literally, it worked — and sampling ten of its results found three
correct. *fortwerfen* got "warf ich alles Andere fort" and *armmachen* got "ich mache dich arm",
both perfect. But *wegtreten* got "trat beiseite, ging aber nicht weg", where the *weg* plainly
belongs to *ging*, and *volllaufen* got "liefen sie voll Zorn und Wut hinaus", where *voll* is an
adjective governing the noun after it.

The failures had one shape. German brackets a separable verb around its clause — the *Satzklammer*
— with the finite verb opening the bracket and the particle closing it, and a bracket never spans
a comma. "Same sentence" was simply the wrong scope; "same clause, and closing it" is the
grammatically correct one. Two constraints followed directly, and sampling the result surfaced two
more: the particle must not be capitalized (*setzte den Kleinen auf einen Acker am Weg* matched
*wegsetzen*, because tokens are lowercased before lookup and `Weg` is a noun), and no intervening
verb may claim the same particle (*gräbt eine Grube und deckt sie nicht zu* is *zudecken*, not
*zugraben* — when two verbs can claim one particle, the nearer one wins).

Precision went from roughly 3-in-10 to roughly 11-in-12. Split-only coverage fell by a factor of
five, which is the right trade: a wrong candidate costs a subagent more than a missing one, since
it invites a confidently wrong sentence into the app. A pleasant side effect — verbs with
*contiguous* evidence went **up**, because the bogus split hits had been consuming the per-document
cap and crowding out real matches later in the same file.

This also collapsed a planned second pass. The spec contemplated a separate "split-form rescue"
for zero-hit verbs; ranking split candidates below contiguous ones in a single pass does the same
job, since a verb with good contiguous hits never sees one.

### The Plenarprotokolle were two columns pretending to be prose

Two thirds of the candidates from the three Bundestag transcripts were garbage, in a way that only
showed up by reading them: "Doch ich würde Ich sage Danke an alle, die mich konstruktiv begleitet
noch weiter gehen". `pdftotext -layout` had preserved the two-column page faithfully — one
physical line holds a fragment of the left column, padding, then a fragment of the right — and
reflowing that as prose splices unrelated sentences together.

These files are the corpus's only source of natural spoken German, which is exactly what the
modern colloquial verbs in the queue need, so recovering them beat dropping them. The gutter is
found per page as the column offset that is blank on most lines, and the page is read down the
left column and then down the right. Garbled snippets fell by ~88% and the yield from those files
went *up*. Detection is geometric rather than by filename, so a future two-column source works
without a code change.

### `doc:line` was wrong twice, in ways nothing would have caught

Phase 4 tells each subagent to re-open the source at `doc:line` to get a clean sentence, so the
citation has to actually land. Auditing 400 candidates, 273 failed.

Two independent bugs. The reported line was the *paragraph's* first line, not the sentence's — 15
lines off inside one Luther paragraph. And line numbers were counted after the Gutenberg header
was stripped, shifting every citation in Kafka by the 24 lines that header occupies. Both are
invisible unless you check, because a candidate with a wrong line number still has a perfectly
good snippet sitting right next to it; the subagent would simply have re-opened the wrong passage
and either used the snippet anyway or quietly rejected a real verb.

Carrying physical line numbers through the reflow and pointing at the matched verb itself fixed
both: ~99% of 600 resolve. Every sampled residual turned out to be a *correct* citation my
verifier could not reproduce — a word healed across a line break ("hingu-/cken"), or a soft hyphen
sitting inside the word in the raw file (`ent\xadgegenwirken`). The verifier was wrong, not the
index. Worth remembering that a check can fail for the same reason the thing it checks succeeds.

### One packaging problem

`corpus/` is gitignored, and the phase spec puts the script at `corpus/working/`. So the finished
indexer was invisible to git — `git status` was clean with the whole thing sitting untracked. A
fresh clone would have gotten no indexer and none of the knowledge above, which may be exactly how
Conjugar's pipeline ended up needing to be recovered by reading that repo rather than by reading
its docs.

`.gitignore` now carries a negation for `corpus/working/*.py`. Git does not descend into an
excluded directory, so each path component has to be re-included before the final rule can match —
`corpus/*`, then `!corpus/working/`, then `corpus/working/*`, then `!corpus/working/*.py`. The
texts stay ignored because they are licensed sources; the JSON stays ignored because it is a
build product; the code is neither.

### Result

47 documents, ~153,000 sentences, ~10,600 candidates for ~2,650 verbs, in about twenty seconds.
About 64% of the target verbs have at least one candidate. The ~920 with none go to Phase 5, and
that number is large enough that corpus expansion, not authoring, is the right response — the tail
is dominated by everyday separable verbs (*abbuchen*, *abtrocknen*, *abrechnen*) that Goethe and
the Grundgesetz had no occasion to use.

`Verbs.xml` was not touched, which the pipeline doc asks to be confirmed rather than assumed:
`git status` shows it unmodified, so the at-odds count cannot have moved.

Next: Phase 3, the three reuse files — and the good news there is that 303 of the 382 roots can be
parsed out of etymologies the app already ships, leaving 79 to author.

## Two guards, one of which I had built backwards (2026-07-20)

Josh asked, reasonably, whether the corpus should be pruned of English — he was worried about
exactly the *will* / *hat* collisions that motivated the exclusion rule in the first place. The
short answer was no: the indexer already skipped `*-en.txt`, and auditing all ~10,600 candidates
for English-looking text turned up two suspects, both false alarms.

The better of the two false alarms is worth recording. My detector flagged Nietzsche's "Was in uns
will eigentlich ‚zur Wahrheit'?" as English, because *was*, *in*, and *will* are all English words.
The check I wrote to catch German/English homograph confusion was itself defeated by German/English
homograph confusion. The fix was to build the language test only from German function words that
have **no** English homograph — *und*, *nicht*, *ist*, *sich*, *durch* — rather than from whatever
came to mind first.

That test then replaced the filename rule outright. Measured across every file: the English
translations score 0.00–0.04% German markers, the German sources 9.27% (Westphalia, whose
17th-century spelling is the floor) to 22%. Nothing lands between, so a 3% threshold is two orders
of magnitude clear of English with room to spare below German. The decisive check was copying
`kafka-prozess-en.txt` to a file named `kafka-prozess-de.txt` and confirming it is still rejected —
otherwise the "content check" is just the filename rule wearing a costume. `-en.txt` was a fine
convention; it just wasn't an enforceable one, and a violation would have produced fluent English
sentences under German citations with nothing to report the error.

### The thing I found while answering a different question

Chasing the English question turned up a worse problem next door. The medieval tier contributed 14
candidates, and reading all 14 — a small enough number that there was no excuse not to — showed
most were not usable text. Some were scholarly glossary lines: "rıtun (rītan) — ritten (Eng: rode)
→ NHD reiten". Others were modern encyclopedia prose *about* the manuscript: "Die Übersetzung wurde
um das Jahr 830 im Kloster Fulda unter der Leitung von Hrabanus Maurus angefertigt."

That second kind is the dangerous one, and it is dangerous in the opposite way from the English
risk. It is fluent, correct, idiomatic German. It would sail through Phase 4 review. And its
`source` field said **"Althochdeutscher Tatian (ca. 830)"** — so the app would have attributed a
sentence written by a Wikipedia editor in the 2010s to a ninth-century manuscript. An English false
positive announces itself; a false citation does not.

The root cause is that `corpus/medieval/` files are not texts but *editions*: primary text,
modern translation, and scholarly apparatus interleaved in one file. Deciding which spans are
citable is a policy the indexer does not have and should not acquire — which is presumably why
Conjugar built its medieval pass as a separate program with its own attachment policy, a detail
that read as incidental until now. The tier is dropped, at zero measurable cost: coverage stayed at
exactly 1,663 verbs, because all 14 were redundant fallbacks for verbs already covered.

Worth generalizing: the guard against a *wrong language* and the guard against a *wrong citation*
are different guards. `tatian.txt` passes the language test at 8.7% German and should — it really
is mostly German. It fails on provenance instead. Conflating the two would have let it through.

## Phase 3: paying once for scholarship that was already in the file (2026-07-20)

The premise of this phase was that `Etymologies.json` already contains most of what the 2,582
etymology-less verbs need, decomposed and waiting. It does, and the arithmetic came out exactly
as designed: of 382 distinct final roots, 303 have their own top-level entry and 6 more exist
only as bullets inside other verbs' compounds. That left 73 to author instead of 382.

Those six are the nicest confirmation of the thesis. *meiden*, *leihen*, *schreiten*,
*schwinden*, *winden*, *zeihen* — each has been shipping in the app for months as a sub-clause
of *vermeiden*, *verleihen*, and so on, fully researched, without ever existing as an entry.
Parsing them out cost a regex.

**Where the design changed.** The phase spec said the value should be "the markup-ready text,"
flat, for both roots and prefixes. That is right for roots and wrong for prefixes, and the
reason only becomes visible once you read fifty prefix bullets side by side: a prefix bullet is
two things welded together. There is a genealogy — MHG *ver-*, OHG *fir-*, PGmc \**fra-*, PIE
\**per* — that is identical in all 95 places *ver-* appears, and then a final sentence saying
what the prefix does *in this compound*. Freezing one of those 95 glosses into the file would
make every *ver-* verb in the app read the same. So prefixes carry `{chain, senses}`, and Phase
4 composes: chain verbatim, plus whichever sense fits. Roots stayed flat strings.

**The separable side is not a prefix inventory.** It is 233 entries, and the count is
misleading. Perhaps forty are true particles. Ninety are transparent deictic compounds where
the only fact worth stating is the composition and the *her-*/*hin-* orientation — inventing a
separate PIE chain for *herunter* would be fabrication dressed as scholarship. Sixty-odd are
ordinary adjectives in resultative frames (*totschlagen* = beat until dead). A dozen are
incorporated nouns. The residue is fossils: *abhanden* is "ab + Handen", the old dative plural
of *Hand*, and saying so *is* the entry. Getting the depth allocation right — atoms deep,
compounds shallow — mattered more than any individual etymology.

**Harvested chains needed correcting, not just normalizing.** I expected drift in abbreviation
and diacritic and got it. I did not expect the shipping chains to be wrong on substance, and
several were. *hoch*'s PIE gloss was misstated in both harvested variants. *auseinander*
derived its *-ein-* from the preposition *in* rather than from *ein* "one". Worst, the *wahr*
material covered only the adjective — but the corpus verb is *wahrnehmen*, whose first element
is a different word entirely: the old feminine noun OHG *wara* "heed, attention", the root
behind English *aware* and *beware*. Reused verbatim across every *wahr-* compound, that would
have confidently mis-derived the commoner verb. The lesson is that "already in the corpus" and
"correct" are independent properties, and the reuse thesis only saves work on the first.

Several subagents corrected my own briefing the same way, with sources: *anheim* is a
directional accusative, not a dative; *entzwei* is *in zwei* respelled under the influence of
*ent-* rather than a real *ent-* prefix; *hintan* is *hin* + *dan* reanalyzed as *hint* + *an*;
and the *preis* of *preisgeben* is Old French *prise* "capture, booty" — the source of *Prise*
and of English naval *prize* — not *pretium* "price", which is the homophone it was later
conflated with. I had asserted the *pretium* line in the shard prompt. Being wrong in a
briefing that twenty agents read is a good argument for asking them to check rather than comply.

**Two defects in shipping data surfaced by being copied forward.** 49 German entries carry a
literal `\n` where the English side has a real newline — it renders as two visible characters.
And 36 places have U+0137 `ķ`, a Latvian k-cedilla, where U+1E31 `ḱ`, the PIE palatal, belongs;
at body-text size they are nearly identical, which is presumably how it survived review. Both
are repaired on write into the reuse files. **Neither is fixed in `Etymologies.json`**, which
is shipping app content and Josh's call. That fix is outstanding.

The interesting structural point about those two: I only found them because the validator I
wrote for *new* content was pointed at *copied* content as well. A validator scoped to "things
the subagents wrote" would have passed cleanly and shipped both defects onward, multiplied by
however many compounds reuse each root.

**Two encoding facts worth carrying forward.** `be*mitleiden` and `ver*anschlagen` are
double-prefixed but mark only their outer boundary — correctly, since both compounds are wholly
inseparable and marking the inner *mit*/*an* separable would misstate their syntax. So the
last-marker rule reports *mitleiden* and *anschlagen* as roots. They are authored as composed
roots rather than "fixed" in `Verbs.xml`, and the at-odds count did not move.

And the 73 authored roots turned out to be almost entirely strong verbs, including seven
cranberry morphemes — bound roots that are not verbs of modern German at all: *brinnen*
(verbrennen), *deihen* (gedeihen), *derben* (verderben), *drießen* (verdrießen), *nesen*
(genesen), *kreißen*, *zeihen*. The corpus's own `in` attributes exhumed them. *nesen* is the
one to remember: it survives only in *genesen*, from PIE \**nes-* "to return home safely" — the
root that also gives Greek *nóstos*, so *Genesung* and *nostalgia* rest on the same idea.

## Correcting a count I had estimated rather than derived (2026-07-20)

The Phase 3 entry above says the separable side is "perhaps forty true particles, ninety
transparent deictic compounds, sixty-odd adjectives, a dozen incorporated nouns." Josh asked
for the real number. Every one of those figures was eyeballed from having read the shards, and
the two largest were wrong in opposite directions: there are 23 true particles, not forty, and
84 adjectives, not sixty.

Rather than swap in better guesses, the taxonomy is now a `kind` field on every entry and the
counts are derived from the file. That also serves Phase 4, which composes differently for a
grammaticalized preposition than for an adjective in a resultative frame.

Classifying it surfaced a flaw in the taxonomy I had written. My six kinds had no bucket for
free adverbs, so *gern*, *wohl*, *weiter*, *recht*, *quer*, *weg* and *irre* were being forced
into "adjective" or "fossil" against my own boundary rule ("prefer fossil when the word no
longer exists free"). All of them are perfectly free words. The classifying subagent flagged
*irre* as "the single sharpest conflict in the set" and was right to. Adding a seventh kind
fixed it, and forced a useful decision: **the kinds are synchronic, not etymological.** *weg*
and *beiseite* are frozen prepositional phrases by origin — *weg* is MHG *enwec* from OHG
*in weg* — but they are ordinary adverbs today, and a subagent composing a compound needs the
modern reading. The etymology is already in the `chain`; the `kind` should describe the word as
it now is. Filing them as fossils would have been a fact about the tenth century masquerading
as a fact about the grammar.

The genuinely interesting result was not the corrected numbers but that **entry count and
occurrence count tell opposite stories**. By entry, adjectives dominate: 84 of 233. By
occurrence, they are nearly the smallest class — 228 of 1,967 — while 23 true particles carry
1,100, over half. Each framing is misleading alone. "233 separable prefixes" makes the German
sound far more grammaticalized than it is; "really only 23 particles" hides that the tail is
where almost all the authoring went, because each of those 84 adjectives appears once or twice
and still needed its own etymology.

That is a general lesson about this pipeline, not a fact about prefixes. The whole design rests
on paying once for what recurs, so the frequency distribution *is* the design input — and a
count of distinct things is the wrong statistic for deciding where effort goes. It was the
right statistic for the roots, where 382 distinct roots really did mean 382 lookups. It was the
wrong one here.

## A sizing error found by using the thing (2026-07-20)

Phase 4 began, two shards ran, and the output was correct and wrong at the same time.
*abbinden*'s etymology contained the entire Sanskrit-*bandana* paragraph from *binden*'s
article, because Phase 3 had told the mining subagents to reuse root text **verbatim** and the
root text they were handed was an article.

The numbers say it plainly. The 544 root bullets already shipping in the app run a median of
239 characters. `roots.json` was running 969. A compound verb was inheriting a bullet four
times house length, and paying for it twice — once when a subagent read it, once when it wrote
it back out.

The mistake was seeding `roots.json` entirely from the roots' **top-level article** form. For
the 303 roots that are also app verbs, that form was sitting right there in `Etymologies.json`
and copying it was free, which is exactly why it looked like the obvious move. It was free and
it was the wrong shape. A root is cited two ways — as one bullet inside a compound, and as the
whole article when the root is itself a simplex verb (71 of the targets are) — and one text
cannot serve both.

So every root now carries `{bullet, full}`, and the shard builder picks by use. Shards fell 31%,
from a 74 KB median to 51 KB, which is 31% off the input side of all 102 remaining mining
shards.

Two things about the condensation pass are worth keeping.

**The `full` field was a contract, and it held.** Eight subagents were told to pass `full`
through byte-for-byte and condense only into `bullet`. The merge refused to write unless all 764
`full` values compared equal to their inputs. They did, across all eight, with no exceptions —
which is the check that makes "condense, do not rewrite" verifiable rather than aspirational.
Without it the pass would have been a rewrite wearing a compression's clothes, and nobody would
have known.

**The bullets that stayed long are the ones that should have.** Median landed at 341 (en) rather
than the house 239, and the overruns are almost all two-reading roots — *schleifen*, *scheren*,
*kehren*, *laden*, *wiegen* — where a single spelling covers two verbs with separate origins and
separate principal parts. Those cannot compress without losing a conjugation fact, which is the
one thing this app exists to teach. The cranberry morphemes also cluster high, because each
spends ninety-odd characters saying it is not a verb of modern German before its chain begins.
One agent noticed that and pointed out that if the median ever has to come down further, that
status sentence is the compressible part, not the etymology. That is the right instinct: know
which of your bytes are load-bearing.

Only one entry tripped the runaway check at 700 characters — *wiegen*, at 793 — and the fix was
not to compress the etymology but to delete a clause duplicated in *wägen*'s entry, which
already cross-references back. Redundancy across two entries reads as thoroughness inside
either one.

**The general shape, again.** This is the third time in two days that the bug has been a value
that was correct for one purpose and reused for another: the root articles, right as articles
and wrong as bullets; `MAX_OCCURRENCES = 5`, right for a verb whose forms are its own and wrong
for one sharing forms with a commoner verb; the count of distinct separable prefixes, right for
sizing the authoring and wrong for describing the grammar. The reuse thesis this whole pipeline
rests on is that scholarship already paid for should not be paid for twice. The corollary is
that reuse is only free when the *shape* transfers too, and shape is the thing nobody checks.

Also logged, not yet acted on: 179 target verbs (11% of those with candidates) have every
candidate drained by a homograph of a commoner verb. *abfahren*'s four candidates are all the
token *abführen* — genuinely both the infinitive of *abführen* and the Konjunktiv II of
*abfahren*, since *fahren* → *fuhr* → *führe*. `forms.json` is right to list both; the five-slot
cap is what starves the rarer verb. This is Conjugar's *cocina*/*cocinar* problem, which Phase 2
believed German capitalization had solved — it solves noun homographs and is silent about
verb-on-verb ones. Phase 5's tail rescue is where it belongs.

## The constant that was sized for a different job (2026-07-20)

Before spending the ~9M tokens the remaining mining shards were projected to cost, one more
look at where a shard's budget actually goes. The answer was not the etymologies or the
candidates. It was that `MINING_SPEC.md` told every subagent to re-open the source file at
`doc:line` and recover a clean sentence by hand — roughly twenty file reads per shard, plausibly
45% of the measured 124.5k.

And the sentence was already there. `build_corpus_index.py`'s `snippet()` computes the complete
sentence and *then* truncates it to `SNIPPET_WIDTH = 200`. Only 36% were actually being cut, so
for the other 64% a subagent was opening a file to reconstruct text it was already holding.

`SNIPPET_WIDTH = 200` came over from Conjugar, where it was correct. A snippet there sized a
**preview**: enough context for a reader to judge whether a candidate was relevant. Phase 4
reuses the field to **quote** the sentence into the app. A preview may be lossy. A quotation may
not. Nothing about the constant was wrong; it was answering a question nobody was asking
anymore, and the reopen instruction in the spec was me papering over the mismatch instead of
noticing it.

`MAX_QUOTE_CHARS = 600` now stores the sentence whole. Truncation fell from 36% to 2.8% and
shards grew 8%, from a 51 KB median to 55 KB. Twenty seconds of CPU, no model tokens.

Two details worth keeping.

**The flag is explicit, not inferred.** Each candidate carries `truncated: bool` rather than
leaving a consumer to look for a leading or trailing "…". The Bundestag protocols use ellipses
for interruptions, so the glyph is not evidence of truncation and its absence is not evidence of
completeness. Inferring a data property from a formatting character is the kind of shortcut that
works for months and then quotes a fragment as though it were a sentence.

**The spec now says never to trim a quote to hit the length target** — quote whole or reject.
That rule exists because a Phase 4 subagent already reported catching itself: it had shortened
five quotes toward the 8–30-word target and in one case the trim removed the very clause holding
the target verb. German puts the finite verb second and strands its particle at the clause end,
so the illustrated verb frequently sits in exactly the subordinate clause a naive trim discards.
The agent caught it and restored all five. The spec should not have depended on it catching it.

**Fourth time, same shape.** Root articles: right as articles, wrong as bullets. `MAX_OCCURRENCES
= 5`: right for a verb owning its forms, wrong for one sharing them with a commoner verb. The
count of distinct separable prefixes: right for sizing the authoring, wrong for describing the
grammar. `SNIPPET_WIDTH`: right for previewing, wrong for quoting. Every one was a value that
was correct where it came from and silently wrong where it was reused — which is exactly the
failure mode a reuse-everything pipeline should expect to have, and exactly the one none of its
validators check for, because each value is individually valid. Reuse is only free when the
shape transfers, and shape is invisible until something downstream is built on it.

## Furniture, and the cost of a candidate you never see (2026-07-20)

Two Phase 4 shards ran, and their reports kept mentioning debris: a speaker label at the head
of a Bundestag quote, a Grundgesetz paragraph number, a heckle whose party name was split by a
PDF line-hyphen into "GRÜ- NEN". The agents had quoted verbatim as instructed rather than
silently editing German, and flagged it. Josh asked whether to strip it now.

The answer is yes, and the reason is sharper than tidiness. **A rejected candidate is
unrecoverable.** Nothing in the pipeline records which sentence a subagent passed over. So a
later cleanup can only tidy the quotes that were *selected* — it can never resurrect the ones
furniture caused to be rejected. Cleaning at index time raises yield; cleaning afterwards
cannot. About a quarter of candidates carried something.

Two mistakes on the way, both caught by measuring instead of assuming.

**The regex I would have shipped decapitates German sentences.** A "speaker label" rule keyed on
`^Name:` reported 428 hits. Sampling them showed most were ordinary sentences with a colon —
"Deshalb: Nach der Ampel links abbiegen.", "Nur: Seit über zwei Jahren fließen jede Woche 2
Milliarden Euro ab." Stripping on that pattern would have removed the first clause of hundreds
of perfectly good quotes, and the results would have read fluently afterward, which is precisely
what makes it the dangerous kind of bug. The genuine artifact turned out to be a speaker name
followed by a two-column marker — `Michael Schrodi (A)` — so that is what the rule matches now.

**The first implementation stripped blindly and then went looking for the verb.** It failed two
ways at once: thirteen sentences were stripped past their own matched token, three of them to
the empty string, and on long sentences `find()` located a *different* occurrence of the token,
so the stored window jumped to an unrelated clause of the same sentence. Both failures produce
text that looks fine. The fix is that the matched verb is now inviolable — no rule may cut into
its position, and the offset is carried through the edits rather than rediscovered afterwards.
The ~30 candidates that still carry furniture are exactly the ones where stripping would have
reached the verb, and leaving them is correct: the subagent rejects them, which is a visible
loss rather than a silent corruption.

Scoping matters as much as the patterns. A leading integer is a verse number in the Luther bible
and a plain numeral in a ministry report, so 1,689 of 1,711 are stripped and the remaining 22
are left alone. Every rule names the documents it applies to.

**The re-run measured the payoff.** Shard 001 went from 14 sentences to 16; shard 000 stayed at
10 but replaced three contaminated quotes with clean ones. So roughly +4% yield and six quotes
that would otherwise have shipped with a page number or a heckle attached. Both agents opened
zero source files, and both independently verified their German against the candidate strings
before finishing — one of them caught a stray soft hyphen (U+00AD) it had introduced into its own
authored prose, which nothing else in the pipeline would have noticed.

One judgment worth recording. *abfahren* has four candidates and all four are the token
*abführen*, which is genuinely both the infinitive of *abführen* and the Konjunktiv II of
*abfahren* (fahren → fuhr → führe). Both runs correctly returned a null sentence rather than
quote a use of the wrong verb. The second run then did something better than refusing: it put
the collision in the etymology, since *führen* is the causative of *fahren* and the homograph is
genealogical rather than accidental. That is the shape of answer this pipeline is supposed to
produce — the constraint became the content.

## The subagents keep finding the indexer's bugs (2026-07-20)

Two more mining shards, and then a stop — not because the window ran out, but because both
subagents independently reported the same three problems, and the protocol says a recurring
rejection reason is a reason to fix the pipeline rather than to mine another shard against it.

The most interesting finding is that the brief was making a promise the code does not keep.
MINING_SPEC told every subagent that `truncated: false` means `text` **is** the complete sentence
as it appears in the source. What `snippet()` actually does is set the flag false whenever
`len(sentence) <= MAX_QUOTE_CHARS` — that is, "I did not clip this to fit." Whether the thing was
a sentence at all was settled upstream by the splitter, and when the splitter mis-splits, the
fragment arrives wearing a completeness badge. One shard's `abliefern` candidate ended mid-clause
on a comma; another's `abrücken` began lowercase with no Vorfeld. Both agents trusted the flag as
instructed, then rejected the candidates on their own judgment, and both wrote up the gap. The
flag was not lying so much as being read as a stronger claim than it makes, which is a failure of
the brief rather than of the code.

The second finding was that length was the dominant rejection reason and nobody had thought to
rank on it. `_rank` encodes contiguous-versus-split and nothing else, so the round-robin merge
hoists whatever each work offered first — and Kafka, Mann, and Nietzsche offer periods. Measuring
it turned two anecdotes into a number: the median candidate is 25 words, the 90th percentile is
59, and for a sixth of the verbs with candidates the lead ran past 45 words while a clean short
one sat below it. A word-count term as a tiebreaker within the rank tier was a few lines.

The third was mechanical damage reaching subagents: text severed mid-word across a two-column PDF
gutter, bare `(A)`/`(B)` column markers landed in the prose, unclosed parens from Bundestag
heckles whose speaker attribution had been cut away. Roughly one candidate in nine carried
something detectable for free, and each one cost a subagent a read and a rejection.

The near-miss worth recording is what happened when I filtered all four defect classes alike.
Coverage dropped by about sixty verbs, and the reason was quotation marks: German quoted speech
spans sentences freely, so `„Erstens dies. Zweitens das.“` splits into two complete sentences each
holding one half of the marks. Luther and Grimm are saturated with quoted speech and are two of
the three largest lead sources. Hard-dropping every imbalance was throwing away good sentences to
catch severed heckles. Splitting the filter by severity — drop what is corrupt or fragmentary,
merely demote what is unideal — recovered most of it, and the surviving losses are verbs whose
only candidates were genuinely damaged, which a subagent would have nulled anyway.

Re-ranking then orphaned an already-mined quote, which is a lesson about ordering rather than
about ranking. `merge_balanced` pops from per-work queues after they are sorted, so a new sort key
changes *which* candidates survive `MAX_OCCURRENCES`, not just their order. Shard 001's *abgehen*
had quoted a 39-word Luther passage that the length key pushed out of the pool, and the validator
correctly flagged it as no longer verbatim even though it had been verbatim when mined. I re-picked
from the current pool — Ruth 4:14 attests the same "be lacking" sense in 27 words — and noted why
in the entry. The general point is that indexer changes are not safe once mining is underway, which
is an argument for spending a window on the pipeline before spending several on the corpus.

Two smaller things. The `senses` field shipped five polished, drop-in sentences per prefix while
the brief asked subagents to author a sense sentence themselves; both agents dutifully wrote their
own. The redundancy was the bug — the brief already had a closer slot for compound-specific
meaning — so the sense is now spliced verbatim and the closer carries the interesting observation.
And one agent had spliced its root bullets by script rather than retyping them, precisely so the
verbatim check could not fail on a typo; that technique is now in the brief, along with the same
advice for copying the quoted sentence by candidate index.

Four shards mined, all passing the validator. The remaining hundred will run against an indexer
that ranks by length, drops corrupt text, and demotes rather than discards a sentence caught
inside a larger quotation.

## The heckle that survived two filters (2026-07-20)

A follow-up pass on the same day, tightening what the first one left. Re-reading the two shard
reports against the filter I had just written turned up something worth recording: the specific
candidate shard 002 had rejected — a Bundestag heckle, `– Kay Gottschalk [AfD]: Wie wär's denn,
wenn ihr euren Schleuserskandal in NRW abklärt?` — was *still sitting at index 0* for *abklären*
after the filter shipped. It starts with an en dash rather than a lowercase letter, and its
square brackets are balanced, so none of the four tells touched it. Forty-one such candidates led
their verb's list.

That is a useful reminder that a filter built from a list of symptoms catches the symptoms and
not the disease. The disease here is that parliamentary heckles are printed with their
attribution inline, which makes them unquotable whole and untrimmable by rule — no amount of
careful reading rescues one. Matching the party bracket directly drops 634 of them, and it is a
deterministic kill rather than a judgment call, which is the test for whether something belongs
in the indexer at all.

The severity split earned itself a second time. A leading dash looked like the same kind of
defect but is not: Nietzsche heads complete sentences with continuation dashes, so those demote
rather than drop. Two independent cases now — quotation marks spanning sentences, and dashes
heading them — suggest drop-versus-demote is the filter's organizing principle rather than a
concession, and future tells should be classified that way from the start.

Three brief changes came out of report findings I had not yet acted on. Roots that cover two
homographs (*kehren* turn/sweep, *laden* load/invite, *löschen* extinguish/unload) ship both
branches without saying which the compound descends from; the brief now tells subagents to pick
using `family` and `translation` and to state the choice in the closer, since a strong/weak split
usually separates the twins. Subagents are now told explicitly not to append to this file — one
of them had noticed that `CLAUDE.md` asks contributors to journal their work and correctly
flagged that concurrent shard agents doing so would corrupt it. And the friction ask itself moved
out of the launch prompt and into the brief, which meant the launch prompt got short enough to
write down; it now lives in the phase doc so no future session has to reconstruct it.

That last change is the one I would defend hardest. The reports have produced every substantive
improvement to this pipeline so far, and the ask that elicits them was living in a prompt that
each session composed from scratch — which is precisely the kind of thing that quietly drops out
on the session where someone is in a hurry.

## Phase 4 mining, shards 004–005: the furniture problem recurs, and a budget that only bought one wave (2026-07-20)

A short session by design. The window opened at 88% consumed, and the protocol's own rule — stop
with about five session points of headroom — made the arithmetic unambiguous: at roughly two
points per shard, twelve points buys one wave of two, not three. So this entry records one wave,
shards 004 and 005, and the reasoning for stopping rather than pressing.

Regenerating the build products was uneventful, which is itself worth noting, because `corpus/`
is gitignored and every fresh session pays this cost. The forms dump wrote 50,011 forms in about
two seconds, the index rebuilt with zero unresolved morphemes, and the shard builder reported
4/104 mined from nothing but which `.out.json` files existed on disk. That derived-progress design
kept paying: no state had to survive the session boundary, and none did.

Both shards validated on the first pass, and so did the four before them — 75 sentences and 75
nulls across six shards, which lands exactly on the half-yield the earlier calibration predicted.
Worth remembering that the validator re-checks *old* shards against *freshly rebuilt* candidate
pools, so a green run here is also evidence that nothing in the regeneration shifted a pool out
from under an already-mined quote. That failure has happened once, when the word-count sort key
landed, and it is silent until the validator catches it.

The substance of the session is in the two reports, which converged from opposite directions on
the same finding: **extraction furniture is still surviving the corrupt-candidate filter, and it
is now the most-reported friction in the pipeline.** Shard 005 hit orphan quotation marks glued to
the front of otherwise-whole sentences (`« Der Teufel…`, `“ K. dachte…`, the splitter attaching
the *previous* sentence's closing mark) and a Wikipedia list item with its `*` bullet intact.
Shard 004 hit a Luther verse number sitting mid-sentence between two lowercase words
(`…wäre; 24 aber es ist…`), a PDF space-split compound („Prognose zeitraum" for
„Prognosezeitraum"), a two-column protocol whose committee names interleaved into the text, and a
Bundestag fragment that began mid-sentence but escaped the lowercase-start rule by starting on a
capitalized noun and ended on a comma.

Two independent agents, no shared context, both spending real deliberation on the same class of
defect. That is the third time this class has surfaced and the second time it has cost good
candidates outright: the rule is quote-whole-or-reject, so a sentence that is perfect apart from
an interpolated verse number leaves a subagent no good move. Every one of these is mechanically
detectable, and each detector is a few lines in a place the indexer already does this work.

The timing argument matters more than the fix. The phase doc already records that an indexer
change can orphan an already-mined quote, because `merge_balanced` pops from per-work queues
*after* sorting, so a new key changes which candidates survive `MAX_OCCURRENCES` rather than
merely reordering them. The conclusion drawn then was that the pipeline is cheap to change before
mining and expensive after. Six of 104 shards are mined. If that argument is ever going to be
acted on, this is the cheapest moment it will ever have — and the alternative is 98 shards each
paying the same tax and each recording the same hedge.

Two smaller findings, both zero-risk because neither touches candidate ranking. First, a genuine
rule collision the brief does not resolve: the markup convention says German prose uses „…“ and
never ASCII quotes, but several corpus sentences quote speech with ASCII quotes, and
exact-equality validation forbids normalizing them. Verbatim quotation already wins in fact — the
validator only bans ASCII quotes in *etymology* text, not in a quoted sentence — but the brief
never says so, which is an invitation for some future shard-runner to helpfully "fix" a quote and
fail validation. Second, shard 005 argues the `ab-` sense inventory is missing two senses that a
recurring family needs: a support/bracing sense (*abstützen*, *abstellen*, *abfangen*,
*absichern*) and a reciprocal/relief sense (*abwechseln*, *ablösen*, *abtreten*). It reached for
the escape hatch three times in 25 verbs, which is the hatch working but working too often. Shard
004, notably, reported the same inventory as *well*-shaped for its verbs — the derivation sense
fitting *abstammen* and the copying sense fitting *abschreiben* exactly. Both can be true; the
inventory covers the core and frays at a specific edge.

One report also raised a heuristic worth thinking about rather than acting on: `abtöten`'s only
candidate was *töten* followed later in the clause by an `ab` stranded from a different separable
verb (`tötete ihn und hieb ihm den Kopf damit ab`). The separable-particle window produces this
systematically for any `ab+X` verb, independently of homography. `contiguous: false` already
demotes these; whether an intervening finite verb should demote them further is a real question
and a riskier change than the furniture filters, since it touches matching rather than cleanup.

**Same day, later: the furniture fix landed.** Josh authorized spending the window's tail on it
rather than banking it, which was the right call for the reason the entry above argues — six
shards mined is as cheap as this change will ever be.

Four detectors, each traceable to a specific report. Three drop and one strips. `no-terminal-punct`
rejects text that ends without `.`, `!`, `?`, `…` or `:`, which is the complement of the existing
lowercase-start rule: a fragment beginning on a capitalized noun sails past that rule, and German
supplies capitalized nouns constantly. `verse-number` drops a Luther verse number sitting between
clauses, which `LEADING_FURNITURE` catches only at the head and which cannot be stripped
mid-sentence. `wiki-markup` drops MediaWiki list items and namespace links. And the orphan
quotation mark became a *strip* rather than a drop, in `LEADING_FURNITURE`, since a mark followed
by whitespace opened nothing — a real German opening mark hugs its word, `„Wort` — so removing it
recovers a whole sentence instead of discarding one.

The verse-number rule is the one I checked hardest before believing, because 896 drops out of
2,075 Luther candidates looked like over-firing. It is safe for the same reason the lowercase rule
is: German capitalizes every noun, so a bare integer followed by a *lowercase* word cannot head a
quantity phrase. „24 Jahre“ and „12 Männer“ both survive; „24 aber“ and „3 und“ do not. That is
now the third rule in the indexer leaning on German orthography for a defense that would be
unavailable in English, which feels less like a coincidence than like the shape of the problem.

Cost accounting, since this is the trade the decision rested on: 1,995 unusable candidates
dropped, against 25 target verbs falling from one candidate to zero (1,627 → 1,602 with evidence).
That loss is nominal rather than real — those verbs' only candidates were mechanically defective,
so a subagent would have read them, rejected them, and returned null anyway. What actually changed
is that nobody pays to deliberate about them.

**And the predicted hazard fired, exactly once, exactly where predicted.** Re-validating the six
mined shards against the rebuilt pools flagged `abscheiden`: its quoted Luther sentence was the
one carrying the stray verse number, which the new rule now correctly drops. The subagent had
flagged that very sentence as a hedge when it mined it. The repair followed the rule already
written down — re-pick from the current pool and say so in `notes`, never carve an exception into
the validator — and the re-pick came out `null`, because the sole surviving candidate is the
Nietzsche attestation in precisely the right sense at 49 words, past the brief's 45-word ceiling
for a last candidate. Losing a good sentence over four words stings, but the ceiling exists so
that an unreadable quotation cannot ship, and overriding it quietly in the one case where it binds
is how a ceiling stops meaning anything. Final state: 74 sentences, 76 nulls, validator green.

Two brief edits came out of the reports as well. The markup section said German prose uses „…“ and
never ASCII quotes, without saying that the rule governs *authored prose only* — while several
corpus sentences punctuate speech with ASCII quotes and exact-equality validation forbids
normalizing them. A future shard-runner following the letter of that rule would have "fixed" a
quote and failed validation, so the brief now says verbatim always wins inside a quotation. And
the brief's list of what the indexer catches was left accurate rather than allowed to understate
the new filter — the same staleness failure this project keeps having to design against.

## The slot the brief could not describe (2026-07-20)

Two mining subagents came back from shards 006 and 007 with the same complaint, worded
differently enough that neither had copied the other. MINING_SPEC tells them to build each
morpheme bullet as `<chain, verbatim> <sense, verbatim>`. Both said, politely, that this
instruction cannot be executed — and both had quietly worked around it rather than stopping.

They were right. Measured across the reuse files, 45% of prefix-slot occurrences carried senses
that were not sentences at all but verb-initial fragments: `makes an intransitive verb
transitive`, `hebt das, was das Grundverb mit einer Präposition regiert`. Spliced after the
chain's final period exactly as instructed, that yields "…the preposition ~bei~. makes an
intransitive verb transitive". So every subagent had invented a connective to bridge the gap, and
eight shards had accumulated four different ones: "Here it conveys…", "It promotes…", "Here the
prefix conveys…", "The prefix conveys…". Precisely the voice drift that verbatim-splicing exists
to prevent, arriving through the one slot the design left underspecified.

What makes this the most instructive bug of the project so far is that **every one of those
shards passed the validator**. The validator checks tilde balance, reserved markers, and — the
one that matters — that each quoted German sentence is byte-equal to a candidate. All mechanical
properties. Whether a spliced sentence is grammatical is not mechanically checkable, so eight
shards reported clean while drifting apart. The only detector was two independent agents
noticing the same thing, which is an argument for reading subagent reports as instrument output
rather than as status.

**The fix was to change the data, not the brief.** The tempting move is to teach MINING_SPEC a
framing rule: "splice verbatim, except prepend a subject when the sense is a fragment." That
instruction is exactly as ambiguous as the situation that produced four connectives — it just
moves the ambiguity somewhere it looks authoritative. Normalizing all 1,051 fragments into
complete sentences makes "splice verbatim" *literally true*, and an instruction that says only
that has nothing left to drift on.

Framing had to be decided per *sense*, never per `kind`. That was the first thing I got wrong and
caught only by measuring: I assumed the eight `kind` values would each be internally homogeneous,
so a per-kind frame would do. Every single one is mixed — `fossil` holds both `marks something as
passing into another's possession` (a predicate) and `gone from one's hands, mislaid, lost` (a
gloss). Keying the frame off `kind` would have rebuilt the identical bug on each kind's minority
class, and it would have looked like a principled design while doing it.

The German frame is the part I'd have gotten wrong without the subagent's report. It puts the
morpheme in subject position — `~be-~ macht ein intransitives Verb transitiv` — because German
requires the finite verb second. "Hier macht ~be-~ …" would have meant reordering words *inside*
the string being spliced, which is the one thing the design forbids. Shard 007's agent had worked
this out on its own and said so, and its solution is the one now in the file.

### Retrofitting eight shards, and four bugs found by refusing to skip the dry run

The already-mined shards needed reconciling. `repair_mined_connectives.py` anchors on the *tail*
of each canonical sense, since a subagent edited the front and spliced the rest verbatim, then
replaces everything from the preceding sentence boundary through that tail. That span is exactly
"whatever the agent invented" plus the sense.

The dry run earned its keep four times over, and every failure was a case where the code looked
obviously correct:

- The sense of `heiß` is the single word `heiß`, and a substring search matched it inside
  `heißt`; English `hot` matched inside `shot`. Eight of shard 000's etymologies would have been
  mangled. Fixed by restricting each verb to the morphemes it actually decomposes into, plus
  word-boundary anchoring — either guard alone is insufficient.
- Treating `:` as a sentence boundary split senses that *contain* a colon (`Das Präfix ist
  inchoativ: Es bezeichnet…`), so the repair would have reinserted a sense after its own opening
  clause. Only the bullet's own `~morpheme~:` label is a boundary now.
- Guarding with `if sense in text` was too coarse: "Here ~be-~ promotes…" *contains* the
  canonical "~be-~ promotes…", so the guard skipped the very case being repaired. The occurrence
  has to start at a sentence edge.
- German abbreviations end in a period. `bzw.` read as a sentence end and put a span's left edge
  mid-phrase.

Eleven texts were rewritten, the script is idempotent, and the validator passed before and after.

### The stratum underneath

Measuring splice compliance to confirm the repair turned up something the repair could not touch.
Shards 000–003 had **zero** spliced bullets and 214 authored ones; shards 004–007 were almost
entirely spliced. Not drift — a regime change, sitting exactly where MINING_SPEC gained its "do
not author a per-bullet sentence of your own on top of the spliced sense" rule. The first four
shards were mined under the older brief and are a dated stratum, visible in the data to the shard.

No mechanical repair applies, because there is no canonical sense in the text to re-anchor to;
shard 000's `ab-` bullet is a genuinely different, genuinely good sentence. Josh chose to re-mine.
All four came back with 0 authored bullets and **identical sentence yield** — 10/15, 16/9, 9/16,
10/15, the same as the originals. 214 authored bullets became reused scholarship at no cost in
coverage, for about 8 session points.

### Two philological finds, pointing opposite ways

Shard 006 caught `anbefehlen` routed to `root:fehlen`. It is the `begleiten` trap: `befehlen` is
MHG *bevelhen*, OHG *bifelahan*, from Proto-Germanic \*`felhaną` "hide, entrust", while `fehlen`
is an Old French loan from *faillir*. Unrelated. The tell is the same one that exposes
`begleiten` — a strong/weak mismatch, since a shared root cannot inflect two ways — and that
diagnostic, not the exception itself, is what went into the `FALSE_SPLITS` comment. The semantic
path is lovely on its own: "hide, bury" → "place in another's keeping" → "command". To order
something was first to put it into someone else's hands, which is why `empfehlen` and *seine
Seele Gott befehlen* preserve the older layer.

Shard 001 found the mirror image and got it wrong in a well-reasoned way. Every `abfahren`
candidate came back as *abführen*, and it inferred a stemmer had collapsed `führen` into
`fahren`. The pipeline does not stem — the form map is generated by running the app's own
`Conjugator` — and *abführen* is the genuine Konjunktiv II plural of *abfahren*. But the instinct
was sound: `führen` **is** Proto-Germanic \*`fōrijaną`, the causative of \*`faraną` "to travel",
so it once meant "to make go". The two verbs are one root, which is exactly why the false
inference was so persuasive. Two separate runs have now reached it, so it is documented in the
brief with the history included — a bare prohibition invites re-derivation from agents good
enough to reconstruct a plausible counter-argument and then trust it.

So the day produced a matched pair: `befehlen`/`fehlen` look related and are not;
`fahren`/`führen` look unrelated and are one root. The surface tells you nothing in either
direction, which is the whole reason the `in` attribute and the `family` field have to do the work.

### A rule tried and removed, which is worth more written down than deleted

Reports named two PDF de-hyphenation defects: the *split* word (`Hauptschul abschluss`,
`Leistungsfähig keit`) and the *severed* word, where the head is lost and only a tail survives
(`… soll wieder tionäre abwerfen`, from `… Dividenden an Ak|tionäre`). Both seemed detectable by
using the corpus as its own dictionary, which needs no word list and stays current for free.

Split-word works: 512 caught, and the samples are unambiguous. Severed-word does not. The test —
"a near-absent token that is the ending of a common word" — dropped 250 candidates at visibly bad
precision, taking clean sentences like "Haben Förderprogramme die erwünschten Wirkungen gebracht?"
with it. The reason is structural: **German compounding makes "is the ending of some frequent
word" very nearly vacuous**, since almost every German word is the tail of some longer compound.
The rarity threshold cannot separate the cases. Detecting a severed head needs a lexicon with
morpheme boundaries, not a frequency table. That is now a do-not-retry note in the docstring,
because the idea is attractive enough that someone will have it again — this is the fourth time
the indexer has leaned on German orthography for a defense unavailable in English, and the first
time German morphology has taken one away.

### Everything else the reports bought

Content filtering moved into the indexer. A run refused `androhen`'s sole candidate — genuine
German, but it names a living official and recommends beating critics — and argued the judgment
should be made once, centrally, rather than by taste in each of 104 shards. That is obviously
right: a per-shard decision is neither reproducible nor reviewable. It is scoped to the government
tier, since violence in Luther and Kafka is context rather than advocacy, and filtering the
literary tier would gut the best source of clean sentences while protecting nobody.

Five more extraction defects became regexes, each having cost a verb its only attestation: bare
Luther verse numbers with no punctuation announcing them, inline editorial apparatus (`(+++
Nichtamtlicher Hinweis:`), candidates ending on a colon, `Zedern-und` suspended compounds that
lost their space, and gutter splices visible as long runs of interior spaces. Identical text
across two works is no longer two attestations — the Grundgesetz incorporates Weimar articles
verbatim, so `abhängen` was spending two of five slots on byte-identical text, which is also a
nice accidental record of a constitutional transplant. Coverage cost: ten verbs, all of which had
only corrupt candidates and would have become nulls after a subagent paid to read them.

The last underdetermined step got closed too. Two runs independently reported that sense selection
was a coin-flip at the margin — `abmelken` between completion and drawing-out, `abladen` between
separation and downward motion — and one wrote that it had invented a tiebreak rule and that
"another shard will resolve it differently". Same signature as the connective bug, caught earlier
this time. `verbdata/sense-exemplars.json` now gives each sense two or three exemplar verbs,
index-parallel, for the twelve highest-traffic prefixes; the brief says they outrank an agent's
own reading of the sense text. They are language-neutral, so they live in one file rather than
duplicated across `de` and `en` where they would drift, and they are never spliced into the prose,
so a bad exemplar can only cause a mis-picked sense and never corrupt shipped text. Both runs also
named senses that were simply missing, and four were added: durative `an-`, and `ab-` for
deviation-from-prior-state and for naming the source an action proceeds from.

### The economics, which are the actual argument

This window absorbed two mined shards plus all of the above for 17 session points. The shards
account for about four of those, so the pipeline work cost roughly thirteen — against the ~200 it
would take to re-mine 100 contaminated shards, or the permanent seam of leaving them contaminated.

That is the concrete case for the policy the phase spec already states and that I keep being
tempted to hurry past: concurrency stays at 2, and reported friction gets spent on before more
shards do. Every significant fix today came from a subagent mentioning something awkward, not from
anyone inspecting the code. None of it was visible to the validator. Raising concurrency would not
have produced a single additional insight; it would only have widened the blast radius of a
defect that took two waves to become visible.

One thing deliberately left alone: the 55-word ceiling. Shard 003 wants it raised to ~65, having
lost `abordnen` at 61 words; shard 002 says it "never bound against anything usable" and caught
Kafka periods of 67 to 84 cleanly. Genuinely conflicting evidence, and the ceiling had already
moved once today. Moving it twice in one session to rescue one verb is how a ceiling stops meaning
anything, so it stays, and Phase 5's null list can say whether Bundestag-length verbs are a real
pattern. `abhandenkommen` is the case that will argue loudest: its sole candidate is 58 words, and
since `abhanden-` survives in that one verb, it is the only attestation the corpus will ever hold.

## The window that spent half itself on the pipeline, and measured every time (2026-07-20)

Sixteen shards mined this window, 010 through 026, taking Phase 4 from 10 of 104 to 27. The other
half of the window went on the pipeline, which is the same trade the previous entry defended. What
changed is not the ratio but the method: every proposal this time was settled by measuring the
candidate pool rather than by weighing anecdotes, and that turned out to reverse the answer about
as often as it confirmed it.

### The cost model that decided everything

One distinction did more work than any other, and it is worth stating plainly because it is not
obvious from inside a shard report: **a rule in `MINING_SPEC.md` is cheap to change and a filter in
`build_corpus_index.py` is expensive.** Changing the brief leaves every candidate pool byte-identical,
so nothing already mined can be orphaned. Changing the indexer re-ranks pools, and `merge_balanced`
pops from per-work queues *after* sorting, so a new filter can push a quotation out of its own
verb's pool — the failure that hit shard 001's `abgehen` in an earlier window.

Three indexer changes were diagnosed correctly by subagents and **declined**:

- **Stranded particles.** `ansuchen`'s candidate is Kafka's *fing sofort wieder zu suchen an*, where
  the `an` belongs to *anfangen*. There is even an airtight fix — a separable verb infixes *zu*
  (*anzusuchen*), so "zu suchen … an" can never be *ansuchen*. It matched 4 candidates in 5,250,
  all in shards already mined. A correct diagnosis and a worthwhile remedy are different questions.
- **Hyphen-severed extractions.** 15 of 5,250, and agents reject them reliably by hand, which the
  brief prefers as a visible loss over a silent edit.
- **Verse numbers, at first.** Declined on the reasoning that filtering rescues nothing, since the
  starved verbs are null either way. That was true and it was answering the wrong question — see
  below.

Two were **taken**, and the test that licensed both was the same: apply the pattern to all 347
mined quotations and confirm zero would be orphaned.

- **Wiki markup.** `WIKI_MARKUP` anchored list markers at `^` and knew nothing of `=` headings, so
  `==== Artikel 112 ==== :Jeder Deutsche…` sailed through. 51 matches, *every one* in
  `weimar-verfassung-de.txt` — a pattern that fires in exactly one document is describing that
  document's extraction damage, not German. `auswandern` had lost its only candidate to it, so the
  cost had stopped being wasted effort and started being verbs.
- **Verse numbers, on the second look.** Shard 018 noted the corrupt candidate was ranked *first*,
  which reframes the exposure: not a missed rescue but a corrupt sentence silently shipping, since
  verbatim-quoting a corrupt candidate passes every check the validator makes. Shard 024 then
  located the actual gap: `VERSE_NUMBER` wanted lowercase after the numeral and `BARE_VERSE_NUMBER`
  wanted lowercase before it, so `sprach: 24 Du Menschenkind` — punctuation before, capital after —
  fell between them. Luther's `sprach:` introducing direct speech makes that shape common, which is
  why four separate runs tripped over it.

Both landed with all mined quotations intact. Zero-candidate verbs went 990 → 997: seven verbs
converted from a silent hand-rejection to a visible zero, which is what the Phase 5 gap list wants.

### The ceiling the last window declined to move

That entry left the 55-word ceiling alone on the grounds that shard 003 wanted 65 and shard 002 said
it never bound — genuinely conflicting anecdotes, and it had already moved once that day. The
argument was sound and the evidence was the wrong kind. Measured across the pool, **22 verbs have
every candidate above 55 and at least one at 65 or below**, and were shipping nothing at all. So it
moved to 65. The distribution has no cliff, so the number is a judgment about phone screens rather
than a natural boundary; 65 still nulls the genuine runaways, which in the shard that prompted it
ran 86 words. Notably the previous entry predicted `abhandenkommen` would argue loudest at 58 words,
and it was right — that class is exactly what the raise rescued.

### Report-then-widen is structurally too late

The session's most useful finding is about the feedback loop rather than any one defect. Shards are
ordered alphabetically, so a prefix's shards run consecutively — which means by the time three
agents have independently reported a missing sense, that prefix is nearly exhausted. `auf-` was
widened from 5 senses to 10 after five shards reported gaps, and only 6 `auf-` verbs remained to
benefit. `aus-`'s privative gap was reported at shard 020, with zero pending verbs left. The
feedback arrives, by construction, just after it stops paying.

So the loop was inverted: the pending verb list for a prefix is known in advance, so its sense
coverage can be audited *before* its first shard runs. Three audits followed, covering 429 pending
verbs for about five points:

- **`be-`**, 5 → 6 senses. One gap survived: reflexiva tantum (*sich benehmen*, *sich besinnen*,
  *sich behelfen*, *sich betrinken*), where sense 0 would have had an agent write "directs the
  action at an object" for a verb that can never take one.
- **`ver-`**, 6 → 8. Gradual cessation (*verklingen*, *versiegen*, *verkommen* — 19 pending) and
  closing/covering (*verdecken*, *versperren* — 7).
- **`ein-`**, 4 → 6. Habituation through practice (*einüben*, *einarbeiten*, *einleben* — 11) and
  destructive collapse inward (*einstürzen*, *einreißen* — 7).

**Auditing beat reporting on accuracy, not merely on timing.** Three `be-` groups looked like gaps
and dissolved under one test. *beleben* and *bestürzen*: *leben* and *stürzen* are intransitive, so
transitivizing them *is* sense 0. *bekochen* and *beliefern*: *für jemanden kochen* → *jemanden
bekochen* *is* sense 1. *bekümmern* and *bezaubern*: denominal from *Kummer* and *Zauber*, which is
sense 3. A shard meeting any one of these alone would plausibly have reported a gap, because the
population is invisible from inside a single shard.

The reverse also happened, and it is the more useful half. **Shard 022 caught what the audit
missed**: German *be-* promotes **dative** objects too — *einem Rat folgen* → *einen Rat befolgen*,
*jemandem gleichen* → *etwas begleichen*. The audit tested the prepositional pattern, found it
covered, and never thought to check dative-governing bases; three verbs in one shard turned on it.
Auditing sees the whole population but only along the axes you think to test. Shards hit cases
instead of reasoning about them, which is a different and complementary kind of coverage.

### Two things that would have gone wrong quietly

**`repair_mined_connectives.py` can no-op without erroring.** The `be-` fix was a sense *amendment*
rather than an addition, which is a different cost class: adding senses is free for mined work,
editing one strands every entry that spliced it. Three had. The repair script reported "0 etymology
texts rewritten" and its tail-anchoring simply never fired. That was caught only by checking for the
old string directly afterward rather than trusting the summary line. Exact string replacement fixed
all three. Anyone relying on that script should verify its output, not its report.

**A defect scan that was mostly wrong.** Shard 023 flagged malformed sense strings, and a
corpus-wide scan turned up 60 senses naming a target verb built on their own morpheme. Most are not
defects: *abhanden*, *vonstatten*, *überhand*, *vorlieb*, *zugute*, and *brach* are cranberry
morphemes, surviving in German only inside one or two fixed verbs. *abhanden* exists nowhere except
*abhandenkommen*, so a sense reading "the fixed expression *abhandenkommen*" is not circular —
naming the verb *is* the definition, because the particle has no independent life to describe. Two
were genuine: `separ:beiseite` sense 2 stranded a bare modal after its colon, and `separ:bekannt`
sense 1 was ungrammatical (`ist hier in die Öffentlichkeit: bekanntgeben, bekanntmachen`) *and*
spliced into exactly the two verbs it named, so both etymologies cited themselves. Fixed and
re-anchored.

### Also landed

Four more brief changes, all cheap, all from reports. A **rule-precedence block** (reject > sense >
length), which existed because the sense-matching tiebreak added earlier in the window promptly
collided with the 8–30 word band — two shards hit it within one wave and resolved it differently.
The **predicative-participle boundary**: the brief covered only attributive *die abgearbeitete
Liste*, so *ist stark ausgeprägt* was unaddressed; the test is gradability, since only adjectives
compare. A **fixed lead-sentence form**, after a shard opened a neighbouring `.out.json` purely to
copy the house voice — the German drops the article and the English keeps it, which was settled by
counting 525 mined entries rather than by taste. And a tightened **exemplar-leak rule**, now scoped
to `notes` as well as prose, after two shards caught themselves citing an exemplar as evidence for
the sense they had picked.

`corpus/working/PHASE5_FINDINGS.md` is new and tracked, force-added like `MINING_SPEC.md`. It exists
because a question — "is stuff being recorded for the sweep?" — exposed that the cross-cutting
findings lived only in the conversation. The per-verb hedges were always durable in each shard's
`notes` (264 of them at the time), but the gloss defects, the declined fixes, and the starvation
lists were one session boundary from vanishing. **The declined fixes were the most important thing
to write down**: a future session reading only "these are real defects" would fix them, re-rank the
pools, and orphan mined work.

Three `Verbs.xml` glosses look like extraction damage rather than mistranslation, and they are in
that file rather than fixed here, since `Verbs.xml` feeds the at-odds oracle: `ansinnen` glossed
"designate" (it is "demand or expect of someone", the sense the noun *Ansinnen* keeps), `aufstören`
glossed "pattern up" (it is "rouse"), and `ausfolgen` glossed "follow, accompany" (it is Austrian
officialese for "hand over"). "Pattern up" is the tell — not a wrong translation so much as not a
phrase.

### The economics, again

Sixteen shards at roughly two points each is about 32; the window ran to roughly 35 including the
audits, the six brief fixes, three sense-inventory changes, two indexer fixes, and a validator pass
after every one of them. Yield rose from the 53% baseline to 55% overall, with individual shards
reaching 72%. Concurrency stayed at 2, and there is still no case for raising it: not one of this
window's fixes came from inspecting code, and none was visible to the validator. They came from
subagents mentioning that something was awkward.

## The normalizer was the arsonist (2026-07-21)

Five shards mined this morning — 027 through 030 landed, 031 and 032 were still running when the
window closed — taking the corpus from 27 to 31 of 104. But the shards were not the point. Three
subagents independently reported the same defect within one hour, and chasing it turned up a script
whose docstring told future sessions to run it and whose effect was to break the file.

**Three agents, three different answers, one unusable rule.** The brief said to write a morpheme's
trailing hyphen "when the first element's `kind` is `prefix`." Shard 028 pointed out that `prefix`
is not one of the seven kinds its own table lists. Shard 030 said the same and proposed listing the
free-word kinds instead. Shard 029 hit it too and resolved it the *opposite* way, writing deictics
bare — which produced a bullet reading `- ~dazu~:` directly above a spliced sense reading `~dazu-~
ist hier: …`, contradicting itself one clause later.

The diagnosis neither agent reached is in `build_mining_shards.py`: `kind` defaults to `"prefix"`
for the 13 inseparables, which have no `kind` field. So the rule was *literally correct for 13
morphemes and silent about the other 233*. The mined corpus settled it — particle 537 hyphens to 0
bare, adjective 0 to 18, deictic split 36/11 — and the deictic split resolves against evidence the
agents had but did not use: every deictic's own sense text writes itself hyphenated. `adverb` looked
like it should go bare, since the kind is defined as a free modern adverb, and it does not: 8 of 9
adverb morphemes write `~beiseite-~`, `~quer-~`, `~weiter-~` in their own prose. An agent guessed
bare from the definition and would have been the fourth different answer.

The fix was not to reword the rule. It was to **precompute a `display` field** per morpheme and have
the brief say: write the morpheme exactly as `display` gives it. Same move as the connective fix on
2026-07-20 — delete the judgment rather than document it. A rule three agents each read differently
is not a rule.

**Then the normalizer.** Chasing a malformed sense string reported by 028 turned up 14 broken of
1,418, all English: 12 with a doubled terminal `.".`, 6 with an uppercase word stranded after a
spliced `~raus-~ Marks…`. Repaired by hand. Then 029 reported a *different* malformation and 030's
`drauf` senses turned out to be verb-initial fragments — the exact class that
`normalize_prefix_senses.py` was written on 2026-07-20 to eliminate, and whose entry in
`uses_etymologies.md` says "Idempotent; re-run it after editing any sense."

It is not idempotent, and it is not safe to re-run. Running it re-added every doubled `.".` and
double-prepended its own template, producing *"The sense of ~her-~ here is The sense of ~her-~ here
is: …"*. It fixed none of the 28 surviving fragments. **The script is the source of the defects it
claims to repair**, and the documentation invites a future session to corrupt the file by following
it. Reverted from a backup; the 28 fragments and 3 subjectless predicates were then repaired by
hand, giving every sense the morpheme as its subject.

That claim of idempotence had been sitting in the docs for a day, unexercised. It was only tested
because a subagent complained about a sentence that would not parse.

**Sense-inventory changes**, all from shard reports: `daran` gained a spatial-contact sense (028,
via `daranhalten` — every sibling deictic had one and `daran` did not); `drauf` gained a
non-compositional idiom sense (029, via `draufgehen`/`draufhaben`); `breit` sense 2 was split, because
it read "flattened by pressure, and figuratively talked round (~breitschlagen~)" and was being
offered for *breittreten* — a different verb. Exemplars never ship, but a verb named inside a sense
does, so that bullet would have asserted something false. 30 stale splices across six already-mined
shards were retrofitted to the repaired text.

Also added to the brief, from 030: **separability doublets are a rejection class of their own.**
`durchbrechen` is two verbs spelled alike, and 3 of its 5 candidates were the inseparable twin.
"A different verb that happens to share the form" does not obviously cover the *same* lemma's other
reading, so the tells are now written down — `zu durchbrechen` against `durchzubrechen`,
`durchbrochen` against `durchgebrochen`.

**Still open:** `sense_exemplars` covers 13 of 246 morphemes, half of all occurrences. Three reports
landed in the uncovered half. An authoring pass over the top 15 by occurrence was in flight when the
window closed. Auto-deriving exemplars from the example verbs already inside sense strings was
tested and does not work — it nets 172 noisy occurrences, mostly the morpheme naming itself.
`normalize_prefix_senses.py` needs either a fix or the retraction of its idempotence claim; until
then it should not be run.

### Addendum: the script had four bugs, not two (2026-07-21)

Josh asked whether to fix or delete `normalize_prefix_senses.py`. Fixed, because the knowledge in
it — the curated finite-verb whitelists, the subject-first frames, the reasoning about German
verb-second order — is real and would have to be rebuilt. All four bugs were in one three-line
function:

```python
return bool(sense[:1].isupper() and sense.rstrip().endswith("."))
```

Each half fails in a different direction. A sense opening with its own morpheme (`~dahin-~ marks
…`) is not "uppercase", so an already-framed sense was misread as a fragment, routed to the
`self` branch, and had a period appended to a string already ending `."` — the doubled terminal.
A sense closing on a quoted gloss does not end with `.`, so it failed the terminal test and was
re-framed — the double-prepend. And a capitalized verb-initial fragment (`Bezeichnet die Bewegung
…`) passes *both* halves while being exactly the thing the script exists to repair, which is how
28 of them survived. The whitelists were missing `bedeutet` and `means`, the opening words of the
most common survivors.

The fourth bug only appeared once the first three were fixed: reframing `Trägt oft einen
abschätzigen Beiklang …` produced `~rum-~ Trägt oft …`, leaving the verb capitalized
mid-sentence. That is the `~raus-~ Marks …` defect — so the script generated that class too, and
would have regenerated it on the next run.

Two guards now: `terminate()` appends a period only when terminal punctuation is absent, and
`main()` **asserts** that reframing its own output is a no-op. Idempotence was a docstring claim
for a day and was false; it is now checked on every sense of every run. Three consecutive runs
rewrite 1, then 0, then 0 — and that single rewrite was a real fragment the hand-repair pass had
missed, which is the argument for having fixed the script rather than deleting it.

**`.gitignore` had no rule for mined shard output.** All 27 previously-mined `.out.json` were
tracked; the six from this session were not, because each past session had `git add -f`'d its own
by hand and this one had not yet. Mined output is authored scholarship and not regenerable, and
the resume protocol derives remaining work from which `.out.json` exist — so a forgotten add does
not merely lose the etymologies, it silently reports the shard as unmined and invites a re-mine.
Now an explicit rule tracks `*.out.json` and keeps `*.in.json` ignored, since inputs are a pure
build product.

**Exemplar coverage went 13 → 28 morphemes**, 254 insertions and no deletions, index parity
verified across the whole file. The authoring pass returned a structural finding worth more than
the entries: three senses it could not exemplify (`hin` 2, `nieder` 2, `hoch` 2) are *register*
observations sitting in lists whose other members are *semantic*. No verb can discriminate them,
because they restate a neighbouring sense from a different stylistic angle — so a miner told to
pick an index will sometimes land there, which is probably a source of the drift the shard reports
keep describing. Such observations likely belong in `chain` prose, where `durch` already puts its
separability-doublet note.

**Still open, all from shard reports:** `durch-` lacks a temporal-extension sense (`durchmachen`,
`durchfüttern`, `durchschlafen` — 031); `be-` lacks a lexicalized-opacity sense, reported
independently by 027 (`bezeigen`) and 032 (`behalten`, `bekennen`, `bestellen`); `durchschauen`
may be mismarked separable in `Verbs.xml` when its gloss is the inseparable meaning (031); and
`durchspielen`'s `tn` carries a stray unbalanced paren (032). 032 also observes that the indexer
could mechanically drop most inseparable-twin candidates — an accusative object with the prefix
attached in V2, or `zu durchX` against `durchzuXen` — which cost that shard a third of its
candidate reading. That one is an indexer change, so per the standing rule it should land before
more shards, not after.

### The doublet filter that was measured and rejected (2026-07-21)

Shard 032 proposed that the indexer drop inseparable-twin candidates mechanically, since the
class had cost it a third of its candidate reading. It is a good idea and it does not work, which
took two implementations to establish.

A separable verb is *legitimately* contiguous in four places: infinitive, zu-infinitive,
participle, and any verb-final subordinate clause. The first three are mechanical; the fourth is
not. Testing "attached, finite, and not clause-final" dropped 78 candidates and emptied 16 verbs'
pools, and sampling showed about half were real — `daß es aufklappte und …` and `Schläge
abzählte—ach!` are verb-final clauses that simply do not end in punctuation, and `die das
miterlebt haben` is a participle with no `ge-` infix at all, because *erleben* has none.

Narrowing to the V2 slot — the one position where a separable reading is ungrammatical rather
than merely unattested — cut it to 18 drops, of which **5 were true twins**. The residue was six
`-nd` participles and, worse, seven genuine attestations: `das zulief`, `der teilhat`, `die
hervorbricht` are a relative pronoun plus a contiguous verb, which is indistinguishable from `Da
durchstach ihn sein Diener` without knowing that the first word is a relative pronoun. One more
was Kafka's `K.`, whose abbreviation period reads as a clause break and shifted the whole count.

Both residual classes are patchable and it still isn't worth it: roughly 60% precision for a net
gain of about three correct drops across the entire corpus, against silently deleting real
attestations. That is the trade the indexer already refuses for extraction furniture, in a
comment two functions up. Reverted; the tells went into MINING_SPEC's rejection list instead, so
subagents reject the class visibly. The measurement is recorded in the phase spec so the next
session does not re-derive it — the proposal is attractive enough that it will be made again.

The general shape, which is the reusable part: the indexer's job is to be cheap and
deterministic, and a distinction that needs syntax belongs to the reader rather than the filter.

## Two shards, and a measurement that shrank a finding (2026-07-21)

A short window by design — one wave of two shards, 033 and 034, taking Phase 4 from 33 mined
shards to 35 of 104. Both passed the validator, as did all 35 together, and `Verbs.xml` came out
byte-identical to the hash taken at the start.

The build products from the morning's session were still on disk, so the `xcodebuild` forms dump
was skipped rather than re-run. Worth writing down because the resume block opens by telling you
to regenerate: the instruction is right for a fresh clone and wasteful inside a day. Checking the
two files' timestamps first costs one `ls` and settles it.

Both subagents independently reported that `ein-`'s six senses have a hole, and they reported
different holes. Shard 033 wanted a **concessive** sense for *eingestehen* — letting something
stand against oneself, which is not inward motion, insertion, enclosure, onset, familiarity, or
collapse. Shard 034 wanted a **reductive** one for *einkochen*, where the volume shrinks; sense 5
is explicitly about caving in, not reducing. Two agents, two shards, no contact between them,
same morpheme. That is normally the strongest possible signal to stop and fix the inventory
before spending another window.

Measuring it is what changed the recommendation. `ein-` has 110 occurrences, of which 51 are
still unmined, so the morpheme is very much ahead of us — but the two proposed senses reach only
**three** unmined verbs (*einstehen*, *einwenden*, *einsparen*) and five already-mined ones. The
110 was doing the persuading, and the 110 is not the relevant number. Both agents had already
done the right thing: spliced the nearest sense and hedged in `notes`, which is what the brief
asks for. So this is a quality improvement to make at leisure, not a stop-the-line fault. If it
is made, it must be **append-only** — `sense-exemplars.json` is index-parallel, so inserting a
sense mid-list would silently repoint every sense already chosen in 35 shards.

The other report was PDF line-break hyphens stripped without rejoining: *fach licher*,
*nachvollzieh barer*, both from the Bundesverkehrswegeplan. A scan for standalone German suffix
fragments across all 9,939 candidates found **four**, in three verbs, and none at rank 0, so none
cost a sentence. Not worth an indexer change — and the reason is sharper now than it was
yesterday. `merge_balanced` pops from sorted queues, so any change to the candidate pool can
orphan a quote already mined, and there are now 35 shards to orphan. The asymmetry that matters
is the other direction, though: an agent rejecting a corrupt candidate is a visible loss, but an
agent *not noticing* one ships `fach licher` into the app. So the fix went into MINING_SPEC's
rejection list, which cannot orphan anything, rather than into the indexer — with the tell (a
standalone *licher*, *barer*, *keit* after a token ending mid-morpheme) and an explicit ban on
rejoining the halves, since a repaired quote is no longer verbatim and fails the validator.

033's smaller request landed in the same edit. It had noticed that `einher-`'s chain already
narrates both the loss of *einher* as a free word and the gait→accompaniment shift, so its first
closers for *einhergehen* and *einherfahren* restated the bullet three lines above them; it
rewrote both by hand and asked for a warning rather than re-deriving it per shard. Checking the
chains showed this is a class, not a case: most are pure descent and leave the compound's
semantics to the closer, but a dozen — `kaputt-`, `teil-`, `durch-`, `dar-` — run to four
sentences and spend the extra ones on exactly that ground. The brief now says to read the chain
first, and that a short accurate closer beats a long one paraphrasing a bullet.

Same shape as the separability doublets the day before, and now twice in two days: a real defect,
correctly reported, whose fix costs more than the defect once you count what a pool change does
to work already done. The pipeline is cheap to change before mining and expensive after, and 35
shards in, "after" has started.

## The gap that wasn't a bug, the tail we authored anyway, and two clarifications the agents earned (2026-07-21)

A long window. Phase 4 went from 35 mined shards to 51 of 104 — sixteen shards (035–050), all
passing the validator, all still verbatim after a mid-session rebuild. But the shards were the
smaller half of the work. The larger half was a sense-exemplar gap that a shard reported, that I
twice misdiagnosed as a bug, and that ended in authoring the entire long tail of prefix exemplars.

**The outage, and why it cost one shard.** Partway through, an Anthropic outage killed the 039 and
040 subagents mid-response — one was about to write, one still reading. Neither had written its
`.out.json`, so the resume protocol did the whole job: `build_mining_shards.py` still reported them
unmined, and re-launching was the entire recovery. This is exactly the case the write-your-own-file
design exists for. A dead shard cost one shard; nothing merged, nothing to unwind. The failed
attempts did burn subagent tokens, so the window's arithmetic took a real hit even though the work
was intact — worth remembering that a flaky API costs budget without costing correctness.

**The gap, and the two false alarms.** Shard 044 reported that `fest`, `fern`, `fertig`, and `flach`
carry multiple senses but no `sense_exemplars`, and framed it as the same `abmelken`/`abladen` drift
the exemplar field was introduced to prevent. I went to measure how far it reached and twice
reported a systemic gap — once even "possible pipeline bug" — because I read the exemplars at
`morpheme.en.sense_exemplars`, where they are not. They are joined at the morpheme top level,
`morpheme.sense_exemplars`, index-parallel to `en.senses`. `insep:ver`'s eight lists were present
and correct the whole time; my scan reported every prefix as a gap. The only reason it did not turn
into a wasted fix is the habit of confirming a surprising result against a known case — checking the
one prefix a report had named as covered, before trusting a scan that said nothing was. The lesson
is narrow and cheap: confirm the schema before scanning it, not after two contradictions.

Corrected, the real picture was calm. Every high-traffic prefix — `ver-` (8 senses, 186 upcoming
refs), `zu`, `nach`, `um`, `über`, `be`, `vor` — was already covered. The true gaps were the
directional particles (`her-`, `herum-`, `heraus-`) and the adjective-resultatives (`fest`, `tot`,
`frei`, `klein`), 155 prefixes but the largest only 19 refs, and semantically the transparent ones:
`her-` is toward the speaker, `tot-` is "make dead," and an agent picks those from the translation
without help. The prefix `fest` that started it was already fully mined, so fixing it would have
helped only a re-mine of 044, which its defensible-and-noted picks did not warrant.

**Authoring the tail anyway.** Josh chose the most thorough option: author the full tail. Four
subagents took ~39 prefixes each, given the sense glosses in both languages and the corpus verbs
that actually take each prefix, and returned index-parallel exemplar lists — 743 verbs across 155
prefixes, parity checked independently against the live sense counts (a self-reported "parity OK" is
not evidence, same as a shard's self-report). One semantic fix: `insep:emp`'s only corpus verb was
`nachempfinden`, which is a `nach-` verb, so the batch parked it in the "receiving" sense; swapped
for the real `emp-` verbs (`empfangen`/`empfehlen`/`empfinden`/`empören`). Integrated append-only
into `sense-exemplars.json` — 28 keys to 183, existing entries byte-identical, per the prior entry's
warning that this file is index-parallel and a mid-list insertion silently repoints every sense
already chosen. Rebuilt, re-scanned: zero gaps. Re-validated all 45-then mined shards: no orphaned
quotes, because exemplars are a morpheme hint and never touch candidate selection.

The honest value is uneven, and the file's `_comment` now says so. The ~20 mid-frequency
directional prefixes genuinely sharpen selection for the ~570 upcoming verb-slots that touch them;
shard 045 immediately used the new `fort-` list to override a mismatched reading gloss, and 046
called them "excellent." But a good number of the 155 are single-verb fossils — `standhalten`,
`preisgeben`, `mobilmachen`, `heiligsprechen` — where the one real verb repeats across its senses
and disambiguates nothing, because there is nothing to disambiguate. Harmless filler, documented so
a future reader is not puzzled by the repeats.

**Two clarifications the agents earned, both cheap, both append-only to the brief.** First: bullet
order. The `vermeiden` template shows root-bullet first, prefix second — the reverse of the lead
sentence, which names the prefix first — but that inversion lived only in the example, and an agent
flagged it as driftable. Stated it outright, with the three-morpheme `einvernehmen` case. Second: an
intransitive change-of-state verb's `ist`+participle (`die Erde ist gefroren`) is its *sein*-perfect
and a genuine verbal use, not the Zustandspassiv the gradability rule tells you to reject. The rule
already admitted it via its "that grades" qualifier, but agents hesitated because `ist gefroren`
looks like the thing to reject; naming the case removed the hesitation, and shard 050 applied it
cleanly the same wave.

**Deferred, deliberately.** Shard 049 surfaced a real wrinkle in the exemplars I had just authored:
`herabblicken` is listed under the figurative "look down on" sense, but its corpus reading is glossed
literal, so exemplar and reading disagree. The agent chose coherence with the reading and hedged,
which is right, but the brief says exemplars outrank the reading, and here that would have made the
etymology contradict the shipped sentence. A precedence rule — "when the reading's translation names
a different sense than the exemplar slot, prefer the reading and hedge" — would settle it, but it
needs care, because the exemplars exist precisely because the terse translation often does *not*
settle sense, so a blanket "reading wins" would undo their value. That is a next-session decision at
a fresh budget, not a 91%-of-window edit. Left it for the resume note rather than half-solving it.

Standing tally: 51 of 104 shards, 53 remaining, all contiguous from 051. The exemplar tail is a
one-time asset that now sharpens every future window, which is the trade that justified spending
this one on it rather than on the four extra shards the same budget would have bought.

## Mine shards 051–052, and find a 12-way de/en frame mismatch in the separable senses (2026-07-21)

A short window — 89% of the session already spent when it opened, so the budget bought one wave
of two shards and a defect investigation, not a run. Regenerated the build products (`forms.json`
at 50,011 forms, the index at 0 unresolved morphemes, 61% of targets with candidates), mined
`mine_051` and `mine_052` at concurrency 2, and ran the Phase 4 validator over all 53 out-files:
all pass. Both shards were `her-`/`heraus-`/`herbei-`/`herein-`/`herum-` deictic compounds; yield
was 19+14 sentences against 6+11 nulls, most nulls being empty candidate pools rather than
refusals, which is the expected shape for a band this heavy in colloquial motion verbs the legal
and literary corpus barely uses.

**The window's real find came from reading a report as evidence about the pipeline, not status.**
Shard 051 flagged that `en.her.senses[1]` carried a leaked frame — *"The sense of ~her-~ here is:
It can also point backward in time…"* — while its German twin was clean. That is the exact
double-prepend signature the Phase 4 note attributes to `normalize_prefix_senses.py`, so I scanned
the whole `prefixes-separable.json` for it. The first cut was misleading: **419 EN and 411 DE
senses carry that frame**, and at a glance it looked like a corpus-wide contamination. It is not.
The frame is the *designed* form for the short-gloss prefixes — it is the connective the normalizer
adds so "splice verbatim" is executable — and it is present uniformly in both languages there. The
actual defect is narrower and sharper: a **de/en parity mismatch**, a sense framed in one language
and frame-free in its twin. There are **12** of them (10 EN-only, 2 DE-only), across `beieinander`,
`erstauf`, `gern`, `her`, `hier`, `los`, `schön`, `tot`, `voraus`, `wohl`. The subagent had found
one of the twelve.

**Why I did not fix it in-window, and why it is not a mechanical strip.** The 12 straddle two
authoring styles. The short-gloss entries (`gern`, `hier`, `beieinander`) use the frame as their
norm and one DE twin simply lost it. The full-entry prose entries (`her`, `los`, `tot`, `voraus`,
`wohl`, `erstauf`, `schön`) are flowing multi-sentence exposition — "It also…", "More often it is
temporal…" — authored to stand alone starting with the prefix name, and the frame is contamination
that landed on a sense or two in one language. Repairing either direction is real bilingual
authoring, not deletion: the frame-free senses are full clauses beginning with the prefix
(`~gern-~ drückt Zuneigung oder Mögen aus`), while the framed ones are fragments built to follow a
colon (`…ist hier: expressing fondness`), so stripping a frame leaves a fragment
(`bei Reflexiva: ein Zustand des Behagens…`) and adding one double-states the prefix. Which style
each entry should take is a presentation call that is Josh's, it does not block the 53 mined shards
(both new shards used `her` sense 0, which is clean in both languages), and the window was at its
5-point-headroom stop line — so the responsible move was to record the finding with a per-entry
recommendation and leave the authoring for a fresh budget, exactly as shard 049's exemplar/reading
precedence question was left at the end of the prior window.

Standing tally: 53 of 104 shards, 51 remaining, all contiguous from 053. Two data decisions now
wait at a fresh budget — this frame-parity repair, and the shard-049 exemplar-precedence rule from
the previous note — and both are the kind of cheap-before-mining, expensive-after change the brief
says to make between windows rather than inside one.

**Decision captured, execution deferred (Josh, 2026-07-21):** repair the 12 mismatches by
*per-entry dominant style*, not by a blanket strip. The 7 full-entry prose prefixes — `her`, `los`,
`tot`, `voraus`, `wohl`, `erstauf`, `schön` — go fully frame-free, re-authoring each contaminated
sense into a standalone clause beginning with the prefix name (in both languages, matching the
clean twin's register). The 3 short-gloss prefixes — `gern`, `hier`, `beieinander` — keep the frame
as their norm and get it *added* to the one DE twin that lost it (rephrasing the finite clause into
the colon-fragment shape the sibling senses use). `schön` is the mixed case to watch: sense 0 is
framed in both languages, so it stays framed and only senses 1–2 are brought into line frame-free —
resolve it by reading all three senses together, not sense-by-sense. Validate with
`merge_reuse_files.py --validate-only` after, which catches tilde/quote/parity regressions. This is
next-session work at a fresh budget, before mining resumes from shard 053.

## Repair the 12-way de/en frame-parity mismatch by per-entry dominant style (2026-07-21)

Executed the frame-parity repair that the prior window scoped and Josh decided but deferred (see
the shards 051–052 entry above). Re-derived the mismatch list from `prefixes-separable.json` rather
than trusting the count: the XOR check — a sense is a defect only when exactly one language carries
the normalizer frame (`The sense of ~X~ here is:` / `Die Bedeutung von ~X~ ist hier:`) and its twin
does not — reproduced the same 12 (10 EN-only, 2 DE-only) across `beieinander`, `erstauf`, `gern`,
`her`, `hier`, `los`, `schön`, `tot`, `voraus`, `wohl`.

**Reading all of an entry's senses together, not sense-by-sense, was the load-bearing step.** The
naive read of Josh's "7 prose prefixes go fully frame-free" is "strip every frame in those entries,"
but `schön` is the counterexample that disproves it: sense 0 is framed in *both* languages, so it is
parity-consistent, not a defect, and stays framed — only senses 1–2 change. The same logic spares
`wohl[2]` and `erstauf[2]` (both framed in both languages) and every framed short-gloss sibling. The
repair set is therefore exactly the 12 XOR-flagged senses; "fully frame-free" means "for the senses
that were contaminated," not "for the whole entry." The final entries mix registers deliberately —
`schön` ships framed-both / frame-free / frame-free down its three senses.

**The repair is bilingual authoring in two directions, split by the entry's dominant style.** For
the 7 prose prefixes I stripped the frame from whichever language carried it and re-authored that
sense into a standalone clause beginning with the prefix name, in the clean twin's register —
`wohl[1]` DE went from the colon-fragment `…ist hier bei Reflexiva: ein Zustand des Behagens` to the
finite clause `~wohl-~ kennzeichnet bei Reflexiva einen Zustand des Behagens`, mirroring its clean EN
twin `~wohl-~, with reflexives, marks a state of comfort`. For the 3 short-gloss prefixes (`gern`,
`hier`, `beieinander`) I went the other way: kept the frame as the entry norm and *added* it to the
one DE twin that had lost it, rephrasing the finite clause into the sibling colon-fragment shape —
`~hier-~ bindet die Handlung an den Ort des Sprechers` became `Die Bedeutung von ~hier-~ ist hier:
die Handlung an den Ort des Sprechers bindend` (finite `bindet` → participial `bindend`, because a
colon-fragment cannot host a finite verb without re-stating the subject the frame already names).

**Mechanics that kept the diff honest.** Every replacement anchored on the frame text or the
curly-quoted (`„ "`) DE string, so none touched an ASCII `"` (U+0022) — the five EN values with
`\"…\"` quotes in their kept tails were never in an anchor, sidestepping the JSON-escaping trap. Did
not round-trip through `json.dump`; used targeted `str.replace` with a uniqueness assertion per
anchor. Post-repair: the XOR check reports 0 remaining mismatches, `merge_reuse_files.py
--validate-only` passes (233 separable entries, tilde/quote/parity all clean), and `git diff --stat`
shows the single file at 12 insertions / 12 deletions — one line per repaired sense, zero
reformatting churn.

The shard-049 exemplar-vs-reading precedence question, deferred alongside this one, was settled the
same window. Josh chose the **narrow** rule: the exemplar slot still outranks the reading in the
ordinary underdetermined case (a terse `translation` that cannot settle sense — the `abmelken` /
`abladen` reason the exemplars exist), and the reading wins *only* on an unambiguous conflict, where
the `translation` clearly names a sense that is not the slot's. `herabblicken` is that case: figurative
"look down on" exemplars against a literally glossed reading, where following the slot would ship an
etymology contradicting the displayed sentence. A blanket "reading wins" was rejected precisely
because it would undo the exemplars wherever a vague translation merely looks like disagreement. The
rule is now written into `corpus/working/MINING_SPEC.md` right below the tiebreak it qualifies — not
into `uses_etymologies.md` or any launch prompt, per the resume note's standing rule that
candidate/sense-selection rules have exactly one home in the authoritative brief and a second copy
only drifts.

Both deferred data decisions are now closed. Phase 4 stands at 53 of 104 shards; next is shard 053
via the standard resume prompt in `prompts/uses_etymologies.md` § "Resuming Phase 4 in a fresh
session."

## Resume Phase 4: mine shards 053–056, and clarify the brief twice (2026-07-21)

Opened with the session at 0% used, so the budget was there for a real wave, not just the two data
repairs above. Regenerated the build products faithfully rather than trusting the on-disk copies —
the forms dump came back at 50,011 forms (4,338 split readings), the index at 0 unresolved
morphemes and 61% of targets with candidates, and `build_mining_shards.py` reported 53/104 mined,
next `mine_053`. Reproducing the prior window's numbers byte-for-byte was itself the check that
nothing had drifted since the frame-parity edit (which touched only `prefixes-separable.json`, not
`Verbs.xml`).

Mined 053–056 at concurrency 2, one subagent per shard, using the recorded per-shard launch prompt
verbatim. All four were `her-`/`hin-`-family deictic compounds — the heaviest colloquial-motion
band in the corpus — so yield ran below half on the `hinunter-`/`hineinB` sets (many verbs with
empty candidate pools) and the real work was closers and salvage-vs-null calls. The Phase 4
validator passed over all 57 out-files after each wave; two shards' worth of self-reports were not
taken as evidence.

**The 049 precedence rule earned its place on its first live outing.** It fired three times —
`herunterfahren` (053), `hineinziehen` (055), `hinweggehen` (056) — each the exact narrow case it
was written for: an exemplar slot pointing at one sense while the reading's gloss unambiguously
named another, resolved toward the reading with a hedge in `notes`. That the rule triggered on the
very first wave after being written, and only on genuine unambiguous conflicts rather than on every
terse translation, is the evidence that the narrow wording (not the blanket "reading wins" Josh
rejected) was the right cut.

**Two brief clarifications, both from friction three agents hit independently, both rule-neutral so
they cannot invalidate a mined shard.** First: the markup section stated the German-prose
quote convention (`„…"`, never ASCII `"`) but never its English mirror, and three shard-runs each
hand-cleaned a straight-quote English gloss carrying German marks or the reverse — so the symmetric
rule (English prose and translations use ASCII `"…"`, never `„…"`) is now stated where the German
one is. Second: the "do not present an exemplar as evidence" rule has a sharp variant an agent
surfaced — the sibling a closer naturally contrasts against (`hinstellen` vs `hinlegen`) is
sometimes the picked sense's own exemplar, so a contrast wanted for its own sake reads as the aid
dressed up as an argument; the fix is to reach for a different sibling or drop the contrast. Both
landed in `MINING_SPEC.md`, the one authoritative home, per the resume note's standing rule against
second copies.

Standing tally: 57 of 104 shards, 47 remaining, all contiguous from 057. Session stopped here at
Josh's call after the two clarifications, with headroom to spare rather than caught mid-wave. No
data decisions are open. Next is shard 057 via the standard resume prompt.

## Mining shards 057–070, and two indexer defects that were silently discarding the corpus's best sentences (2026-07-22)

Resumed at 57/104 and mined through 070 — fourteen shards, seven waves at concurrency 2 — landing
at **71/104, 33 remaining**. Two of those waves were spent instead on indexer fixes, and that was
the right trade: both fixes were found the way the resume prompt predicts, from a subagent's
friction note rather than from anyone reading the code, and each was silently degrading every shard
until it landed.

**Fix 1 — a defect-precedence bug that let two-column PDF garbage survive.** Shards 057 and 058
both flagged the same recurring cost: Bundestag `pdftotext -layout` gutter-merges (`Das
González zu Recht … Motiv ist glasklar` — two columns spliced word-by-word) that they had to reject
by hand each time. `is_defective` *already* had `gutter-splice` and `column-marker` drop-rules, so
this shouldn't have happened. The cause: the function returns the *first* matching defect, and the
two benign DEMOTE-only defects (`unbalanced`, `leading-dash`) were tested *above* the hard-drop
ones. A gutter splice injects `(Beifall …)` applause markers and `(C)` column tags, which read as
unbalanced parens — so every splice got the benign `unbalanced` label, was demoted-but-kept, and
never reached the `gutter-splice` test. The fix moves the two demote-checks *below* the
garbage-drops but keeps them *above* `no-terminal-punct`, so the deliberate masking that keeps a
dash-ending Nietzsche period (`… davonstürmte?—`, which is complete but fails the terminal-punct
test) as a demoted last resort is unchanged. Measured against a scratch rebuild before touching the
live index: 20 candidates dropped (all genuine gutter/column/editorial garbage), 4 verbs moved from
"rejected garbage" to honest "no candidate" nulls, and **0 of 826 already-shipped quotes orphaned**.

**Fix 2 — a rule running at 0% precision, found by pulling one thread.** One of Fix 1's drops
(`trügen`, a Grimm candidate) looked wrong — `Wand- oder Handstein` is a legitimate suspended
compound, not damage. Chasing that revealed the `gutter-hyphen` rule (`[a-zäöüß]-\s+[a-zäöüß]`) was
matching **189 candidates, every single one a suspended compound** (`Bildungs- und Berufsberatung`,
`Vater- und Mutterländern`, `Personen- und Güterverkehr`) and **zero real damage**. The reason it
had gone unnoticed for so long: it is case-sensitive, and a genuine broken word at a column edge
(`Schleswig- Holstein`, `Black- Rock`) *capitalizes* the continuation, so the rule never matched
the damage it was named for — only the lowercase `compound- und/oder/bzw` construction, which is
never damage. It was silently deleting the clean administrative German that is the pipeline's best
material. The fix guards the rule to fire only when a *non-connector* lowercase word follows
(excluding `und|oder|bzw|noch|bis|sowie|als|vnd|vnnd`, all attested; the `\b` keeps a real break
like `beding- ungslos` catchable). That rescued 189 sentences and brought 7 verbs back from
zero-candidate.

Both fixes went in mid-pass, at 69/104, with **zero re-mining** — the line-561 orphan hazard did
not fire, because every candidate removed or reshuffled was garbage no subagent had ever quoted. I
measured that (0 orphans) on a scratch rebuild before editing the live files, then again on the
real regenerate. The lesson the brief already states held exactly: the pipeline is cheap to change
when the change only removes what no one quoted.

**A capability discovery, and a corrected assumption.** The resume prompt asserted "you cannot
introspect usage — ask Josh to paste `usage.png`." That is false: `claude -p "/usage"` runs the
slash command in a headless child and prints its panel to stdout, so a session can read its own
five-hour-window figure (the `Current session` line; the weekly lines are a separate pool). I'd
confidently predicted it *wouldn't* work — the panel looked like UI-only state — and was wrong.
It's documented now in Phase 4's "As built" section (read approximate/local, poll every few waves
not in a loop, it gauges consumed-not-fits), and the resume block was changed from asserting the
false claim to pointing at that note. Josh scoped it to the pipeline doc rather than global
CLAUDE.md — the *command* is general but the *pacing discipline* it serves is orchestration-only —
and later retired the `usage.png` fallback line entirely, since self-serve always works. This
session used it to gate every wave; the 80% hard stop it enforced is what ended the run cleanly at
88% rather than mid-wave.

**Two brief additions (`MINING_SPEC.md`), both from subagents, both agreed by Josh.** A narrow
exception to "no exemplars in output, including notes": when diagnosing a *false split*, naming the
verb that owns a mis-stranded particle (`niederknien` for a bad `niedermachen` candidate) is
evidence about the indexer's mis-parse, not sense-selection leakage, so it is allowed even when
that verb is an exemplar. And a rejection-list bullet for orphaned parliamentary-heckle furniture
(`Unglaublich!) AfD:`, `Zuruf von der SPD:`), which I *measured* at 5–6 candidates corpus-wide
before deciding **not** to build an indexer filter for it — the sole-candidate cases are honest
nulls either way and the rest have clean alternatives, so it stays a subagent rejection like the
furniture and doublet residues.

**What I deliberately did *not* fix, and why.** A sense-layer problem recurred across roughly eight
shards and I let it accumulate rather than patch piecemeal: `sense-exemplars.json` has coverage gaps
(`hoch-` evaluative, `recht-` directional, `nieder-` "reduce to the ground / destroy", `nachbleiben`
stative) and, worse, *degenerate self-reference* — single-compound prefixes (`madig`, `maus`,
`platt`, `publik`, `preis`, `sonder`, `sicher`) whose only exemplar *is* the verb being resolved, so
the tiebreak points at itself. Separately, `raus-`'s sense text restates facets its own chain
already states, where `rein-`'s does not — a sense-text rewrite target. None degrades output (the
subagents fall back to a defensible sense and flag it), and all of it is *linguistic authoring*, not
a mechanical filter — exactly the work that should be done deliberately in one pass with the parity
check, never reflexively mid-wave under budget pressure. That distinction is why the gutter fixes
were worth stopping for and these are not: mechanical-and-corrupting versus linguistic-and-defensible.

**Two morpheme mis-assignments for Phase 5.** `mausrutschen` is fed `separ:maus` (the *mausetot*
fossil intensifier) but means the computer *Maus*; `reinwaschen` is fed `separ:rein` (the directional
*herein/hinein* contraction, whose chain literally says "not the adjective *rein* 'clean'") but *is*
that adjective, used resultatively. Both subagents caught the contradiction, declined to splice the
absurd chain, authored a corrected bullet inline, and flagged it — so the shipped output is right,
but `Verbs.xml` wants the fix. Homograph-starvation nulls (`krauchen`, drained by strong `kriechen`
forms) also continue as the brief's anticipated Phase-5 tail-rescue territory.

Standing tally: **71 of 104 shards, 33 remaining, all contiguous from 071.** Stopped at the 80%
gate (session read 88% after wave 7's two heavy shards coincided with Fable writing the blog post on
the same window). No data decisions are open; the two Phase-5 morpheme fixes and the sense-layer pass
are recorded above, not urgent. Next is shard 071 via the standard resume prompt.


## Mining shards 071–084, and catching a self-contradictory sense before it shipped (2026-07-22)

Fourteen shards this window (071–084), bringing the corpus to **85 of 104 mined, 19 remaining
(085–103)**, all contiguous. Concurrency held at 2 per Josh's standing call. Yield where a candidate
exists is steady at **90.6%**; the "yield runs near half" framing remains a denominator artifact —
832 of the no-sentence verbs simply have no corpus candidate at all and wait for Phase-5 corpus
expansion, against only 122 honest reader refusals.

Three pipeline changes landed, and the discriminator between "stop and fix now" and "collect for
later" was the same each time: **fix it mid-run only if the defect ships silently *and* the fix is
cheap and data-checkable; otherwise write it up and keep mining.**

- **Two MINING_SPEC clarifications, both silent-degradation holes.** The exemplar-leak scan is now
  specified **case-insensitive** — shard 076 shipped a capitalised `Umrühren` past a case-sensitive
  pass and caught it only on a rescan, and a subagent that scans once would not. And the `contiguous`
  candidate field, which appeared in the schema but was documented nowhere while its sibling
  `truncated` got three paragraphs, is now explained: `contiguous: false` is the *ordinary*
  stranded-particle word order for a separable verb, not a rejection signal. Shard 075's best
  `umdeuten` candidate was `contiguous: false`; a subagent misreading the flag would have shipped a
  worse quote. Both fixes were prompted by subagent friction reports, not code inspection — the same
  pattern every prior improvement followed.

- **`insep:um` had two senses that called the inseparable prefix "separable."** Senses 2–3 in
  `prefixes-inseparable.json` read "als trennbares Präfix / as a separable prefix" — spliced
  *verbatim* into any inseparable-um etymology that picked them, a contradiction no reader could
  catch because subagents splice senses, they don't write them. This was the window's one genuine
  stop-and-fix. It was decided **from data, not German**: the mislabeled slots were exemplified by
  *umdrehen, umstellen, umwandeln, umformen* — all separable verbs that already appear under
  `separ:um`, so they were misfiled duplicates. Deleted both senses and their exemplar slots,
  leaving `insep:um` with its two true inseparable meanings at 2↔2 parity. No already-mined output
  used them, no remaining shard needs `insep:um`, and a full shard-rebuild confirmed the corrected
  data joins cleanly with zero orphaned quotes. Josh, who noted his German is limited, could trust
  this precisely because the correction rests on a checkable duplication rather than an ear.

Left for Josh, because they need an authoring voice rather than a data edit (all cause *flagged*
hedges, never silent breakage, so nothing is at risk deferring them):

- **A `unter-`/`über-` "degree" sense pair.** Three shards flagged a missing `insep:unter`
  "below-a-norm / shortfall" sense (*unterschätzen, unterbezahlen, untersteuern* …), the exact mirror
  of a missing `insep:über` "surpass / prevail over" sense (*überbieten, überstimmen, überwiegen*) —
  German's degree pair. Draft de+en sense text and exemplars are in the session report, ready to
  approve; appending them preserves existing indices, and applying well wants a targeted re-mine of
  the ~10 hedged verbs.
- **`ver-` polysemy.** All three all-`ver-` shards (081–083) plus 084 independently hit the same
  wall: ~7 of 25 verbs per shard collapse onto sense 0 ("intensify"). Three recurring clusters have
  no home — pejorative transitivizer (*verlachen, verklagen*), announce-forth (*verkünden,
  vermelden*), and combinatorial "together" (*vermischen, verschmelzen, verschwören*, corroborated
  by 083 *and* 084). Not pre-drafted: how to carve `ver-`'s polysemy is a taxonomy judgment, not a
  dedup.
- **A Verbs.xml separability/decomposition audit.** Four verbs surfaced whose separability marker
  contradicts attestation (`überkochen`, `umlagern`, `umsorgen`, `unterwinden`) and one false root
  split (`versiegen` = *ver-* + "win", handled inline via the *begleiten* rule). These drive
  *conjugation*, so they matter more than the etymology; a scoped homograph-marker audit is the
  proposed follow-up.

Cost accounting, since the brief keeps insisting pipeline work is worth it: this window spent real
points on the `um` investigation-and-fix, two analysis questions from Josh (government-doc yield;
exemplar coverage), and a living session report — and it was the right trade, because the `um` fix
alone would have silently degraded every future inseparable-um etymology that reached those senses.

**Standing tally: 85 of 104 shards, 19 remaining (085–103), all contiguous.** Stopped at the ~82%
session mark, one wave short of the budget, to keep headroom for this wrap-up rather than get caught
mid-wave. No data decisions are open; the deferred items above are recorded in the session report and
are not urgent. Next is shard 085 via the standard resume prompt.

## Mining shards 085–102: the prefix tail, and a reciprocal-sense gap that recurs across prefixes (2026-07-22)

Eighteen shards mined this window (085–102), concurrency held at 2, one subagent per shard, every
one validated by the Phase 4 verbatim-quote checker before it counted as done. Yield was **274
sentences over 450 verbs, 60%** — well above the ~half the brief predicted from shards 000–001,
because this is the alphabetical prefix tail (`ver-`, `vor-`, `weg-`, `wieder-`, `zer-`, `zu-`,
`zurück-`, `zusammen-`) and those compounds are comparatively well-attested in the literary corpus.
Most of the 176 nulls are genuinely empty candidate pools; the honest-refusal nulls are a minority.
Only shard **103 remains**, left deliberately (see the headroom note at the end).

**Unlike the 071–084 window, this one made no data edits.** That window found the `insep:um`
separable-label defect and stopped to fix it. This window found no silent breakage: every friction
item below arrived as a *flagged hedge* in a subagent's notes, never as a contaminated etymology, so
nothing was at risk in deferring it. The one check that would have justified a stop — is any mined
output wrong? — kept coming back clean across all 103 shards. So the discipline was to mine, record,
and hand Josh a consolidated list, rather than spend the window on sense edits that only benefit a
future re-mine and carry index-parity risk.

**The headline finding: "reciprocal / in-return" is a cross-prefix sense gap, not per-prefix noise.**
Two independent subagents (shards 098 and 099) each concluded, without seeing the other, that
`zurück-`'s three senses (return-to-former-state / backward-retreat / withdrawal) have no slot for
the very productive "do X in return" reading — *zurückschreiben* "reply," *zurückzahlen* "repay,"
*zurückschlagen* "retaliate," *zurücklächeln* "smile back." Then shard 101 hit the *same shape* on a
different prefix: `zusammen-` has no reciprocal mutual-contact sense for *zusammenstoßen* "collide,"
*zusammentreffen* "coincide/meet." A reproduced finding on one prefix plus an independent echo on
another is the strongest sense-inventory signal the pipeline has produced. Proposed: a reciprocal
sense for `zurück-` ("in return, reciprocating an action") and for `zusammen-` ("reciprocal meeting
of two sides"); `zurück-` also wants a retentive sense for *zurückhalten* "withhold."

**Other sense-inventory gaps, all flagged-and-hedged, all author-voice work for Josh (extends the
"Left for Josh" list from the 071–084 entry, does not duplicate it):**

- **`zer-` distributive/intensive.** The three `zer-` senses are all physical fragmentation; there is
  no slot for "all over, thoroughly" or figurative dissolution of a bond/order (*zersetzen* "subvert,"
  *zerstreiten* "fall out"). Shard 095 proposed a fourth sense exemplified by *zerrütten*/*zermürben*.
- **`be-` inside double-prefix and already-transitive bases.** Shards 087, 090, 093 each hit `be-`
  compounds that match none of the six `be-` senses: the `vor-`+`be-`+root lexicalizations
  (*vorbehalten, vorbestellen, vorbestimmen*) and `be-` on an already-transitive goal-directed base
  (*befördern* "convey/transport" — neither transitivizer nor covering nor denominal). A "conveys/
  directs toward a goal" sense, or a picking aid for opaque double-prefix stacks, would remove the
  guesswork.
- **`zu-` durative/attentive.** *zuwarten* "bide time" and *zusehen* "look on" (shard 102) fit none of
  `zu-`'s four senses; a durative/attentive sense would cover both. Shard 097 separately noted that
  the exemplar tiebreak resolves *zuleiten*/*zuliefern* to the allocation sense on *syntactic*
  resemblance (transitive + dative) when their semantics are directional — a syntax-vs-semantics split
  worth a line in the spec so future shards resolve it identically.
- **`ver-` polysemy — corroborates the existing deferred item.** *verwenden* "employ/use" (093) and
  *verwirken* "forfeit" / *verzeigen* "denounce" (085, 086) collapse onto ill-fitting `ver-` senses,
  the same "~7 of 25 verbs land on sense 0" wall the 081–084 shards reported. This is more evidence
  for the already-deferred `ver-` taxonomy carve, not a new finding.
- **`wider-` one genuinely mis-pointed exemplar.** For *widerrufen* "revoke" (093), the `insep:wider`
  exemplar slot points at a sense that is really a *wider-/wieder-* spelling-disambiguation note
  carrying no semantics. This is the one slot a subagent called mis-pointed rather than merely terse,
  so it is a targeted fix rather than an authoring judgment.

**The one concrete indexer finding — and why it was NOT fixed this window.** Three shards (085, 094,
097) reported Luther verse-number / corrupt-token mis-splits reaching the reader flagged
`truncated: false`: `"E ist"` for `"Es ist"` (085, Goethe line 1722), a Rev 16:10–11 two-verse merge
carrying an embedded "11" (094 *zerbeißen*), and `des HERRN 14 und sah` mid-sentence (097 *zulaufen*).
The subagents rejected all three correctly, so no output is contaminated — they cost nulls, not bad
sentences. The indexer *has* a verse-number filter; it is under-catching. This was deliberately left
alone mid-run: per the brief's own `abgehen` precedent, any change to what survives `MAX_OCCURRENCES`
can silently orphan a legitimately-quoted candidate elsewhere, and with 103 shards already mined and
validated the blast radius is the whole corpus. Indexer changes are cheap before mining and expensive
after; the cheap moment is the corpus expansion + re-mine the roadmap already plans for the zero-hit
verbs. Recommendation: tighten the verse-number/corrupt-token filter *then*, with those three cases as
regression fixtures, not now.

**A documentation note for whoever writes an automated exemplar-leak validator.** Four shards (088,
094, 096, 102) observed that a naive case-insensitive scan of the *whole* etymology false-positives,
because spliced chain/sense text legitimately names a prefix's own exemplar: the `vorher-` chain names
*vorhersagen*; the `zer-` chain glosses OE *tōbrecan* as *zerbrechen* (a sense-0 exemplar); the
`separ:zu` sense-1 string literally contains *zumachen*; a compound's own base verb (*zugehören* →
*gehören*) is sometimes the picked sense's exemplar. The real check must scope to the authored
lead+closer, which is exactly what every subagent's own scan did. Worth a line in the brief before
someone writes the whole-etymology version and chases phantom leaks.

**Headroom, not completion, set the stopping point.** Per-shard main-loop cost climbed through the
window as the running report history accumulated in context — an *estimated* ~3.75%/shard early,
~7%/shard by the end (read from `/usage`'s Current-session line, polled every few waves). At the 85%
mark after shard 102, mining 103 too would have pushed the mandatory wrap-up (this note + commit) past
the 5-point-headroom line, so 103 was left for a resume. It is one relaunch: `build_mining_shards.py`
will report it, and the standard resume prompt finishes it. Stopping a wave short to protect the
wrap-up is the same call the 071–084 window made, and the same one the brief keeps arguing for.

**Standing tally: 103 of 104 shards, 1 remaining (103).** No data decisions are open; the sense-work
and indexer items above are recorded here and in the session, and none is urgent because none is
silently breaking output. Next is shard 103 via the standard resume prompt.

## Mining shard 103: the alphabetical tail, and Phase 4 closes at 104/104 (2026-07-23)

The 085–102 window stopped one shard short of the end — not because 103 was hard but because
per-shard main-loop cost had climbed to ~7%/shard as the running report history accumulated in
context, and mining 103 would have pushed the mandatory wrap-up past the 5-point-headroom line.
That was the right call, and it made this session trivial: a fresh five-hour window (0% used at
start), one relaunch, one wave.

Shard 103 is the very end of the corpus alphabetically — seven separable compounds, `zuwerfen`
through `zwischenspeichern`. Three yielded sentences, four were etymology-only nulls (all four had
no candidate at all, the honest ~36%-of-targets floor, not a refusal). `zuwerfen` is a small
illustration of why the length tiebreak earns its keep: its rank-0 and rank-1 candidates both
attest the *wrong* sense (`die Tür zugeworfen`, "slam shut"), rank 2 attests the glossed throw-to
sense but runs 37 words, and the in-band rank-3 Nietzsche quote — "euch werfe ich den goldenen Ball
zu", 23 words — is the one that shipped. `zuziehen` was the one hedge: the reading's etymology
tracks the "move here" relocation sense, but no candidate attests it (the verb is badly polysemous
— bring-in, consult, incur), so the subagent fell back to the earliest genuine use and noted the
mismatch, exactly as the fallback rule prescribes. It also correctly caught a false split where a
stranded `zu` came from `zuvor`, not the particle.

**One friction note, recorded not acted on.** On this tail shard, three of six sense-exemplar slots
(`zuwiderhandeln`, `zwischenlagern`, `zwischenspeichern`) had the *target verb itself* as their only
exemplar — the picking-aid degenerates for rare verbs with no cohort in `sense-exemplars.json`. It
cost nothing here because the sense was confirmable from the `translation` alone, so it is a note
for whoever tunes exemplar coverage, not a pipeline change. Consistent with the whole 085–102
window's finding that the remaining friction is all in sense-selection aids, none of it silently
breaking output.

**The at-odds check was satisfied by construction, not by a classification pass.** The pipeline note
says the count "should not move; if it does, something unintended happened," and the reason it should
not move is that neither half touches `Verbs.xml`. Mining shard 103 writes only
`corpus/working/shards/mine_103.out.json` (gitignored). Rather than pay a multi-minute
classify-and-verify run to confirm a file I could see was byte-identical in git, I checked
`git status Konjugieren/Models/Verbs.xml` directly — clean, before and after. The full oracle is for
steps that edit `Verbs.xml`; a git-integrity check is the same invariant for a step that provably
cannot.

**Phase 4 is complete: 104/104 shards, all passing the validator** including the verbatim quote
check. `build_mining_shards.py` now prints "Phase 4 is complete; proceed to Phase 5." Phase 5 —
aggregating `mined_*.json` into `Etymologies.json` and `ExampleSentences.json` by *widening*
`.claude/skills/integrate` rather than writing a parallel merge — is deliberately left untouched
here, per the resume brief. Next session starts there.

## Phase 5: the mined shards become shipping content, and the docs finally catch up (2026-07-24)

Two windows are folded into one entry here, because the journal skipped a beat: Phase 5 (commit
`34e57ab`) and the formatting sweep (`3e37016`) both landed on 2026-07-23 without a blog note, and
this session found the gap while answering a simpler question — "what's the next step, and is there
cleanup?" The answer turned out to be that Phase 5 was already done and the *docs* were the cleanup.

**Phase 5 — aggregation, done the way the brief demanded and not the tempting way.** The 104
validated `mine_<NNN>.out.json` shards had been sitting inert since Phase 4 closed. The obvious move
was a one-off merge script; the brief was emphatic that this is exactly how a bundle drifts, because
then there are two write paths into the same file. So the work went into a new **Mode B** of
`.claude/skills/integrate` instead, widening the one skill that already knew the rules — diff
working against bundled, add only missing verbs, never overwrite, keep keys sorted per language,
assert `de`/`en` agree in count. Result: `Etymologies.json` 990 → **3,572** per language (every verb
in the corpus now ships an etymology; the imported tranche no longer ships bare), and
`ExampleSentences.json` 990 → **2,438** (1,448 corpus-mined sentences added).

Mode B had to close three gaps the sentence-only skill did not cover, and the third was the
dangerous one. It merges an etymology as well as a sentence; it aggregates 104 shard files rather
than one working file (tolerating missing shards, since a resumed run leaves gaps); and it treats
`"sentence": null` as a **successful etymology-only result**, not a skip. That last distinction is
load-bearing: Phase 4 emits a null sentence for any verb whose candidates were all non-verbal, but
the etymology is still good. Had Mode B reused the old skip-if-incomplete rule, it would have
silently dropped roughly a third of the etymologies — the exact failure the brief warned about.

Two findings surfaced mid-merge, both worth recording because they contradict advice written
elsewhere in this repo. First, **the "confirm `git diff --stat` shows no deletions" rule is wrong
for `ExampleSentences.json`.** That file is object-valued and keys interleave, so inserting new
verbs makes git's *line* diff report ~4,000 phantom deletions with zero semantic change. The rule
holds only for files whose new keys append at the end. Mode B replaced it with a byte-for-byte
preservation check: strip the merged verbs and assert the remainder reproduces `HEAD` exactly. Every
original entry is provably intact — a stronger guarantee than the diff ever gave. Second, **the
brief's "candidates were all nominal" bucket was coarser than the truth.** 34 of the 141
`candidates-none-usable` verbs are genuine verbal uses rejected only for the 55-word sentence
ceiling — recoverable by revisiting the ceiling, no corpus growth required. So
`verbdata/no-corpus-example.txt` now carries a per-verb reason (`no-candidates` 995,
`candidates-none-usable` 141) rather than one flat label, and the re-mine can act on the split.

**The formatting sweep (`3e37016`) came from Josh eyeballing ten random mined verbs in the app.** Two
systemic defects, both cosmetic, both across the whole of `Etymologies.json`: the hyphen that
introduced each morpheme bullet was ugly, and some cited sentence-initial forms rendered lowercase.
So 12,388 bullets became `•` (plain literal text — `RichTextView` does not special-case the marker,
so this is pure legibility) and 1,375 sentence-initial forms were capitalized *inside* the tildes.
The sweep is abbreviation-guarded so a descent chain (*Aus mhd. ~x~, aus ahd. ~y~*) is never wrongly
capitalized, and reconstructed `*~` forms stay lowercase by PIE convention; a char-level audit
asserted every single change was one of those two and nothing else moved. `MINING_SPEC.md` gained
both rules so a future re-mine does not reintroduce them.

An unplanned bonus fell out of that whole-file rewrite: it **cleared the two Phase-3 shipping-data
defects** the pipeline doc had been flagging as outstanding — the literal `\n` in 49 German entries
and the Latvian `ķ` standing in for the PIE palatal `ḱ` in 36 places. Both are now 0 occurrences. A
formatting pass fixed a data bug for free because it was the first thing to rewrite those entries
since they were imported.

**The cleanup this session actually did was the docs sweep — roadmap step 11.** The caches were
already honest (`check_docs.py` came back clean throughout), but three *planning* docs described a
pre-Phase-5 world, and the checker can't police planning prose. `docs/roadmap.md` still showed steps
10–11 as not-started and quoted "28% coverage / 2,582 verbs missing"; `docs/etymology-pipeline.md`
still led with **"INCOMPLETE… 2,582 verbs have no etymology at all"**; `prompts/uses_etymologies.md`
still said "phase 5 is not [done]." The etymology-pipeline header was the sly one: `check_docs.py`
reported `[ok] etymology completeness claim`, but that check only fires when the headline *claims*
COMPLETE — a stale "INCOMPLETE" passes it trivially while being flat wrong. Flipping the header to
`**COMPLETE` did not defeat the guard; it armed it. The check was written as a self-clearing
conditional ("when step 10 fills the gap, the claim becomes true and the check goes quiet"), so it
now runs the missing-verb diff against `Verbs.xml` on every invocation and will fail loudly if any
future verb ever ships without an etymology. All three docs are corrected, this entry fills the
journal gap, and `check_docs.py` is still clean.

**What's next is a feature, not cleanup: corpus expansion, then a re-mine.** 1,134 verbs ship an
etymology but no example sentence, and the shape of the miss is the instruction. The large majority
(995) have *zero* corpus candidates — the corpus never attests them — and they are overwhelmingly
administrative, commercial, and technical vocabulary (*abbuchen* "debit an account",
*zwischenspeichern* "cache") that Kafka, Luther, and Nietzsche never wrote. So this is a **register
gap, not a thin corpus**: adding more literary German will not touch it; adding contemporary news,
non-fiction, administrative, and technical prose should resolve a large fraction on the next pass.
That re-mine reuses the Phase 4 machinery verbatim, which is why `prompts/uses_etymologies.md` stays
live rather than being retired.

**Two "cheap follow-ons" were proposed here, investigated the same session, and both dissolved — so
this paragraph corrects itself rather than leaving the bad framing for a future session to chase.**

- **The ceiling recovery is not cheap and not mechanical.** The ceiling is *tiered*, not a single
  55-word rule — 45 words for a last-resort candidate, 55 normally, 65 for a sole candidate — so
  "raise the 55-word limit" is not even well-defined. The 22 genuinely-verbal-but-too-long rejects
  run 41–86 words, many of them single Nietzsche/Mann periods. Recovering them needs a UX policy
  call on the longest sentence that belongs on a phone screen (Josh's, not automatable) *and*
  per-verb translation, since a rejected candidate was never translated (`sentence` is `null`). It
  is a small authored project, not an edit.
- **The `Verbs.xml` separability flags are false alarms — checked against the oracle, the app is
  already right.** All seven miner-flagged verbs (*überkochen, umsorgen, unterwinden, umlagern,
  versiegen, mausrutschen, reinwaschen*) come back `status: verified` in `classification.json`, and
  six carry `shippedEncodingFailed: False` — the app conjugates them correctly and matches
  Wiktionary. The mining flags were reasoning from *one corpus sentence*, usually the other half of
  a separability doublet: a subagent seeing "die Milch kocht über" concluded `über*kochen`
  (inseparable) was wrong, but kaikki's paradigm attests `überkocht`, the inseparable homograph
  (overcook), which is what ships — *überkochen* is two identically-spelled verbs. *umsorgen* and
  *unterwinden* are genuine doublets: kaikki lists **both** `sorgt um`/`umsorgt` and `windet
  unter`/`unterwindet`, and the app ships the separable reading defensibly. Flipping any of the six
  would break a currently-correct verb. Where both readings are attested, the honest enhancement is
  *adding a second reading* via the existing dual-separability machinery (the *übersetzen*/*umgehen*
  pattern), not a flip — real, oracle-verified work, not a quick edit. This is "verified means agrees
  with Wiktionary, not correct" cutting the other way: a confident linguistic read (*überkochen* =
  boil over = separable) is *true* and still wrong, because it picks the wrong homograph, and the
  paradigm oracle is what disambiguates.

  The one genuine defect the check surfaced is *reinwaschen* (`shippedEncodingFailed: True`), but it
  is an *ablaut-encoding* problem on strong `waschen` (wäscht/wusch/gewaschen), not a separability
  flip, and it already sits inside the known 7-verbs-at-odds audit the roadmap tracks — not a
  standalone win.

So the honest residue is: no cheap wins here. The real next work is corpus expansion + re-mine (the
feature above), the ceiling policy call, and — if wanted — dual-reading enrichment for the true
doublets, each of which is deliberate work verified through the classify-and-verify oracle.

## The ceiling policy call, made: recover 12 real attestations at 80 words (2026-07-24)

The entry above listed "the ceiling policy call" as deliberate work needing Josh's judgment, not a
cheap win. Josh made the call the same day, and it is worth recording *why* rather than just *what*,
because it inverts the reasoning the ceiling was built on.

The sentence-length ceiling had moved twice already (45 → 65) and each move was a *reaction* — a
shard-run reported nulling a verb's sole genuine attestation to a few words of margin, and the
ceiling rose just far enough to catch it. This move was different: a *policy* decision, made after
looking at three of the actual rejected sentences (the Kafka *auflachen* period, the Mann
*aufklingen* and *entsteigen* periods). Josh's reasoning: **a real corpus attestation has value that
a phone-screen-friendly length does not, and these verbs are unlikely to be attested more briefly
anywhere else, so re-finding them by expanding the corpus would burn compute to reproduce sentences
we already hold.** "People can scroll." So the ceiling went to **80 words**, and the recovery ran
against the shards already on disk — no re-mine, because the ceiling is a *subagent judgment rule*,
not an indexer filter, so every rejected candidate was still sitting in its `mine_<NNN>.in.json`
waiting to be reconsidered.

The recovery was a filtering problem more than a translation one, and the filtering is where the
care went. A naive "word count ≤ 80" pass admits garbage: the same pool holds candidates that are
the wrong verb (*zeihen*'s hits are all *ziehen*), adjectival participles masquerading as verbal
uses (*bewehren*, *umkämpfen*, *vorherbestimmen* — all stative *'-ed'* forms), mis-splits with
dialogue debris (*zurechtlegen*), and verse-number-corrupted Luther runs (*abbinden*, *ausbeten*).
The miner's own per-verb note already classified each, so the filter was: a length signal in the
note, **minus** every disqualifier, then read each surviving candidate by eye to confirm the target
verb genuinely appears as a verb. That took the field from ~140 verbs-with-candidates down to **12**
clean recoveries. Two were excluded on grounds length alone would have passed: *umdenken* (a
two-sentence quote whose second sentence carries no verb, and the verbatim rule forbids trimming to
the first), and *abwechseln* (its only genuine candidate is 83 words, past even the new ceiling; the
under-80 ones are the adverb *abwechselnd*).

One case needed the conjugation oracle, not just a reading: ***durchziehen* is a separability
doublet**, and the app ships `durch+z^ieh^en` — the *separable* reading (pull/draw through). Its
Luther candidates ("*durchzogen das Land*") are the *inseparable* traverse sense the app does not
ship, so they were correctly avoided; the recovered sentence is the Mann one where a sheet "*unter
der rechten Schulter durchgezogen war*" — separable, literal, and the right reading. Picking by word
count alone would have had a one-in-three chance of shipping the wrong verb under a Mann citation.

Merged via `integrate` **Mode A** (single working file, sentences only) rather than touching the
frozen shards — `ExampleSentences.json` went **2,438 → 2,450** per language, the 12 dropped from
`no-corpus-example.txt` (now 1,122 rows: 994 no-candidates, 128 candidates-none-usable), and the
byte-for-byte preservation check confirmed all 2,438 prior entries intact. The German side is every
candidate's stored text *verbatim* (the quote invariant that proves a real attestation, not a
paraphrase); only the English translation was authored, one careful pass over twelve literary
periods. `MINING_SPEC.md`'s ceiling section is updated to 80 with this reasoning, so a future
re-mine inherits the policy rather than re-litigating it. The etymologies were already shipping for
all twelve; this only adds the sentence. Neither `Verbs.xml` nor the at-odds count is touched —
`durchziehen`'s reading was *read*, not changed.

## Corpus expansion scoped, rejected, and replaced with Claude-authored examples (2026-07-24)

The "corpus expansion" next step got scoped with real measurement, and the measurement killed it —
which is exactly what scoping is for. Then Josh chose a different path, and a 25-verb pilot proved it
out. Three findings and a pivot.

**Scoping finding 1: the pipeline could not be re-mined at all.** `build_corpus_index.py`'s
`target_verbs()` defined the work-list as *verbs with no etymology*, and Phase 5 drove that set to 0.
The indexer literally printed `TARGET verbs (no etymology): 0`; a re-mine would have targeted
nothing. Fixed to key on *missing example sentences* (`ExampleSentences.json`), which returns the real
1,122-verb gap. This was a silent trap — a re-mine would have "succeeded" doing nothing, the same
green-but-empty failure mode the repo keeps tripping over.

**Scoping finding 2: the right-register sources were already on disk and moved the gap by ~0.**
`government2/`, expanded `government/`, and `technology/` (data-protection, circular-economy, three
more Bundestag protocols, BSI security, German Wikipedia tech articles, ~6.9 MB) were already staged
and wired into the indexer's `TIERS`. Measured against the 994 no-candidate verbs: `government2`
attests 569 distinct verbs, **0 of them in the gap**. Every verb it covers was already covered by the
literary corpus. On-register text does not help when the gap verbs are too rare to appear in it — a
Zipfian wall: corpus coverage of a fixed vocabulary grows with the *log* of size, so a few curated MB
re-attest common verbs and surface almost no rare ones. Of the 994, ~190 are deictic/multi-particle
coinages (*heraufgeben*, *drauflosreden*) rare in any corpus; ~804 are plausibly attestable.

**The pivot: Josh rejected a large Wikipedia ingest and chose high-quality Claude-authored
examples.** This is not a new practice — the app already ships 11 authored sentences marked
`source: "Opus 4.6"`, disclosed in `creditsText`. The Phase 5 note anticipated exactly this ("authored
sentences… must be flagged in Credits as the existing eleven are"). So the work is to continue the
established, honestly-marked practice at scale, with this session's batch marked `source: "Opus 4.8"`
(and future models get their own tag — the `source` field is a per-sentence provenance record, so
"multiple Opuses" is a feature).

**The pilot: 25 representative verbs, a two-stage validation stack, and it earned its keep.** Stage
one is a mechanical gate — every authored sentence must contain a real conjugated form of its verb,
checked against `forms.json` (25/25 passed). Stage two is an independent adversarial review by a
second Opus playing native linguist. That second pass caught what neither the gate nor a non-native
could: a **logic** contradiction in *abbehalten* ("trotz der Kälte … die Mütze nicht abbehalten" —
keeping a cap on in the cold is sensible, not stubborn; fixed with a warm setting), a post-2020
political connotation on *querdenken* (which **Josh chose to keep** — his call, and it is a lovely
word), and two verbs whose **glosses were wrong**.

**The unplanned bonus: authoring is also a gloss audit.** To write a correct sentence you must commit
to what a verb *means*, which forces a confrontation with the stored `tn` gloss that mining never
does — a miner just quotes a corpus sentence. Two of 25 flagged gloss problems, and resolving them
re-taught the *überkochen* lesson in both directions. *anräumen*'s gloss ("fill or clutter with
objects") the reviewer confidently called wrong ("it means clear the table") — but kaikki tags it
`[Austria] "fill or clutter"`, vindicating the shipped gloss and the sentence; the confident native
read lost to the source, again. *aufsprechen*'s gloss ("chat, talk") was the genuine error: the
standard modern sense is *record a message* (*eine Nachricht aufsprechen*), so `Verbs.xml`'s `tn` was
corrected to "record (a message)" and the sentence rewritten to the record sense. Projected over
1,122 verbs, an ~8% flag rate could surface ~90 gloss errors as a side effect — a second deliverable
improving the app's *translations*, riding along on the first.

**Shipped tonight:** 25 authored sentences merged via `integrate` Mode A (`ExampleSentences.json`
2,450 → 2,475), the `aufsprechen` gloss fix, the `target_verbs()` fix, and a `creditsText` rewrite
that **drops the verb enumeration** (Josh's call — it does not scale past a handful) and generalizes
the credit to "Opus 4.6 and 4.8" so it survives future batches. `no-corpus-example.txt` fell 1,122 →
1,097. Verified: `forms.json` gate, adversarial review, byte-for-byte preservation of the 2,450 prior
sentences, `Verbs.xml` DTD-valid, `.xcstrings` a clean 2-line diff, `check_docs` clean. The remaining
~1,097 gap verbs are Josh's next session — the sharded author → gate → adversarial-review → merge
loop the pilot validated.

## Authoring 1,097 example sentences, and an Opus 4.8 vs 5.0 A/B (2026-07-25)

The pilot in the previous entry validated the loop on 25 verbs. This session ran it over the
remaining **1,097** — every verb shipping an etymology but no example sentence — and, because Opus 5.0
shipped the same day, ran half the work on each model to compare them. Plan:
`prompts/example_generation.md`; the subagent brief `prompts/example_prompt.md` was passed verbatim to
every child and is deliberately **measurement-blind** — it never mentions models, tokens, or timing —
so the two models would behave as they naturally would.

**Why headless `claude -p` children rather than the Task tool.** The in-session Agent tool cannot pin
a *specific* Opus version (its selector is the alias `opus`) and hands back no per-run token or
duration figures. `claude -p --model <exact-id> --output-format json` does both. One wrinkle worth
recording: the JSON is an **array of events**, and the metrics live in the element with
`type == "result"`. A second wrinkle became the run's integrity check — that element also carries
`modelUsage`, keyed by the models that actually served, so a silent fallback to the wrong model would
otherwise have been invisible. It was recorded per shard; all 44 matched.

**The result.** All 44 shards finished in one five-hour window, 23% → 75%, ~15 minutes of wall clock,
1,097/1,097 verbs with both `de` and `en`, 22 shards per model.

```
model            shards sent  en/sent  tok/sent  med_api_ms  $/sent
claude-opus-4-8     22   550     76.6     239.9     85,454    0.02028
claude-opus-5       22   547     80.5     313.1     95,718    0.02285
```

**The interesting finding started as a mismatch between two measures of verbosity.** Opus 5.0's
English is only **+5%** longer per sentence, but it spends **+30%** more output tokens producing it.
Completion was identical — 25/25 on every shard — so the extra tokens were not landing in the
deliverable. The natural reading was "deliberation, not output," and two other signals agreed: 5.0
filed uncertainty `note`s on **12.1%** of verbs against 4.8's **7.6%**, saying "I am not sure about
this obscure verb" 60% more often.

**Then the inference turned into a measurement.** The per-child `meta/*.meta.json` files carry
`thinking_tokens` events that nothing in the pipeline had looked at. Extracting them:

```
model            think_tok/sent  % of out_tokens  turns(med)
claude-opus-4-8            93.7            39.0%         3.0
claude-opus-5             151.6            48.4%         3.0
```

Of the +73.2 tok/sentence gap, **+57.9 is thinking** (a +62% increase) and only +15.3 is prose (+10%,
matching the +5% longer English). **79% of the excess is deliberation** — no longer inferred from a
mismatch but read off directly. And median `num_turns` is **3.0 for both models**, so this is not
extra tool-use rounds or retries; it is deeper thinking inside the identical read-then-write
structure. The thinking *text* is redacted (empty `thinking` field, signature only), so the counts
survive and the content does not. `thinking_tokens` and `num_turns` were folded back into
`metrics.jsonl` afterward, which also makes that file self-sufficient for analysis. 5.0 was also
noticeably less consistent shard-to-shard (output tokens 6.1k–13.6k vs 3.4k–7.9k). None of this is a
*quality* claim — `verbdata/authored/provenance.json` tags each verb with its author model precisely
so a later adversarial review can split accept/reject by model and settle that.

**Measurement is not free, and that was the run's biggest practical surprise.** The plan shipped with
its window cost deliberately UNRESOLVED, to be filled in by the first run. Running waves of *differing*
width (4, 6, 8, 9, 9, 9) let the cost be decomposed algebraically instead of guessed — every wave cost
exactly `shards + 1` points, giving **≈1.0 window point per 25-verb shard and ≈1.0 point per `/usage`
read**. A usage probe costs as much window as an entire authoring shard, because every headless child
pays the same ~23k cache-creation input regardless of how little it does. At the plan's suggested
4-shard waves, **20% of the window goes to measuring**; widening to 8–9 after the first clean wave is
most of why all 44 shards fit. Same-width waves could not have separated the two terms at all.

**Two shards failed, one per model, in the same way.** Shard 023 (Opus 5.0) and shard 038 (Opus 4.8)
each wrote invalid JSON by opening a German quotation with `„` (U+201E) and closing it with an
unescaped **ASCII** `"`. Notably, 038's *English* curly quotes in the same entry were correct — it is
specifically the German closer that slips. This is the identical failure class `CLAUDE.md` documents
for `Localizable.xcstrings`: ASCII `"` needs JSON escaping, curly quotes do not. Both retried clean.
The fix was to delete and re-run, not to repair the escape by hand — a repair is a *correction*, and
corrections are a later pass whose whole point is to be independent. The episode also exposed a resume
hazard now documented in the plan: `run_wave.sh` skips on **file existence**, not validity, so a
corrupt `.out.json` would silently count as done forever.

**The gloss audit came in above projection.** The pilot flagged 2 of 25 glosses (~8%) and projected
~90 over the corpus. The real rate was **125 of 1,097 (11.4%)** — `verbdata/authored/gloss-
disagreements.txt`. Better still, the check is cheap: `verbdata/candidates.json` holds the full
multi-gloss kaikki list per verb, and **83 of the 125** already have a competing gloss sitting on disk,
meaning the import simply picked the wrong sense. Those are mechanically confirmable; the other 42 need
judgment.

**Deliberately not done:** no adversarial review, no `forms.json` gate, no corrections, no `integrate`
merge. Running them would have muddied the performance data, which was the point of the exercise. A
successor plan, `prompts/example_analysis.md`, hands the analysis session the file inventory, the
already-computed baseline, and — more usefully — what is *not* on disk. Three things: `metrics.jsonl`
records only successes, so it shows 44 clean shards and hides the true 42/44 first-try rate; there is
no window or wave data in it; and no quality verdict exists anywhere. It also documents a trap found
while writing it. The obvious way to test "does 5.0's deliberation help on obscure verbs?" is to join
corpus frequency from `verbdata/dwds-frequencies.json` — but its 990 lemmas overlap these 1,097 verbs
by **exactly zero**, because all 990 are verbs that were already shipping an example. The gap set is by
construction what that pass did not reach. Coverage was measured rather than assumed for every
auxiliary file, which is the only reason that was caught before a session wasted a window on it.

**Handoff:** 1,097 authored sentences under `verbdata/authored/shards/`, `metrics.jsonl`,
`provenance.json`, `gloss-disagreements.txt`. Review, gate, and merge are a fresh window — a review
split across two windows would reintroduce exactly the throughput bias the interleaved-wave design was
built to cancel.

## The forms.json gate on 1,097 authored sentences (2026-07-25)

Ran the mechanical conjugation gate over the authored batch — the "gate" half of the pilot's
author → gate → review → merge loop. It costs no five-hour window at all (an `xcodebuild` harness plus
local Python), which is why it went first while the window sat at 77%.

`corpus/working/forms.json` was already on disk from Jul 23, and `Verbs.xml` had changed since — but
the only change was one `tn` gloss attribute (*aufsprechen*), which cannot affect conjugation.
Regenerated anyway and the new file was **byte-identical**, which is a better position to argue from
than an inference. Worth recording that the harness's own header comment gives the run command as
`KonjugierenTests/CorpusFormsDump/dumpForms()` — the `@Suite` **display name**, not the struct name.
That filter matches nothing, runs zero tests, and still prints `Test Succeeded`. The working address is
`KonjugierenTests/CorpusFormsDumpTests/dumpForms()`.

**1,076 / 1,097 (98.1%).** Split by author: 4.8 at 98.5%, 5.0 at 97.6% — a 0.9-point gap against a
±1.6-point confidence interval, so **not significant**. On mechanical conjugation correctness the two
models are indistinguishable, and 5.0's +62% thinking bought nothing measurable here. This is exactly
the regime the review-design section warns about, and it was pleasant to have written the power
analysis down *before* seeing the number rather than after.

**The calibration test came back positive, and it is the better result.** Each model had flagged verbs
it felt unsure about. Do those verbs actually fail more? Flagged: 4.6% miss. Unflagged: 1.6%. A
**2.86x relative risk, Fisher one-sided p = 0.048.** Both models' hedging is aimed at real difficulty
rather than sprayed as generic anxiety — and because it is a *within*-model comparison, no judge bias
can touch it. That is a claim about self-knowledge, and it survives without an adversarial review
existing at all.

**The headline 98.1% is a floor, not an estimate**, which only became clear by reading all 21 misses
rather than trusting the ratio. Just **four** are real authoring errors (*wegschmeißen* used *warf* —
that is *wegwerfen*; *hochstellen* used *höher*; *heranhalten* used *an* not *heran*; *rechtdrehen* used
*rechts*). Nine are dual-form verbs where the model chose the other attested German form: the app
conjugates *saugen* strong (*absog*) against the models' *saugte*, *hauen* and *senden* weak against
their *hieb* and *sandte*. *verglimmen* is the sweetest of these — the model wrote *verglomm*, and
`wiktionary-defects.json` already lists the verb as **deferred** for precisely that weak-Präteritum /
strong-participle wrinkle. The cross-check written into the analysis plan a few hours earlier fired on
its first real use. Four more misses are clipped colloquial imperatives („Halt bitte das Essen warm")
that the app does not generate, and two are matcher limits.

**Two misses are corpus defects the gate surfaced.** `zusammen+spinnen` ships `fa="w"`, so the app
generates *zusammengespinnt* — not a German word — while its own siblings `sp^i^nnen` and
`herum+sp^i^nnen` are `fa="s" ag="beginnen"`. The model's *zusammengesponnen* was right and the corpus
was wrong. And `über*kochen` reprised the pilot's lesson from a third direction: the app ships the
inseparable homograph (*overcook*) **correctly**, as the pilot established against a confident native
read — but the entry carries `tn="boil over"`, which is the *separable* homograph's meaning. So the
model was handed a gloss describing one verb and an entry encoding the other, and wrote a perfectly
good separable sentence for the gloss it got. The defect is upstream of the sentence, and the fix is
the one the pilot already prescribed: add a second separable reading via the *übersetzen*/*umgehen*
dual machinery, not a flip. Neither is fixed; both are Josh's call.

The lesson that generalises: a mechanical gate's aggregate number is nearly useless on its own. 98.1%
sounds like "21 bad sentences" and actually means "4 bad sentences, 2 bad corpus entries, and 15 places
where German is wider than the app's paradigm." The categorisation, not the ratio, is the deliverable —
`verbdata/authored/forms-gate-misses.md`.

## Fixing the two corpus defects the gate found — and losing a p-value doing it (2026-07-25)

The `forms.json` gate surfaced two defects in `Verbs.xml`. Both are now fixed, both verified by
regenerating `forms.json` and re-running the gate, with the full 211-test suite green and the file
still DTD-valid.

**zusammenspinnen** shipped as `zusammen+spinnen fa="w"`, so the app generated *zusammengespinnt* — not
a German word. Its own siblings `sp^i^nnen` and `herum+sp^i^nnen` are `fa="s" ag="beginnen"`, so the
import had simply dropped the strong classification on one member of a family. Now
`zusammen+sp^i^nnen fa="s" ag="beginnen"`, which yields *spann* and *zusammengesponnen*. The authoring
model's *zusammengesponnen* had been right the whole time; the corpus was wrong.

**überkochen** is the more interesting one, and it closes a loop the pilot opened. The app ships
`über*kochen` — the inseparable homograph, *overcook* — and the pilot established that this is
**correct**, against a confident native read that "überkochen means boil over, so it must be
separable." Kaikki's paradigm attests *überkocht*. But the shipped entry carried `tn="boil over"`,
which is the *separable* homograph's meaning. So the authoring model was handed a gloss describing one
verb and an entry encoding another, and wrote a perfectly good separable sentence for the gloss it got.
The fix is the one the pilot itself prescribed — *add a second reading, do not flip* — using the
`über*setzen` dual-separability pattern, where a `<reading>` carries its own `in=` overriding the
verb-level marked infinitive:

```xml
<verb in="über*kochen" hi="71407" hp="y" ic="cooldown">
  <reading tn="overcook" fa="w" />
  <reading in="über+kochen" tn="boil over" fa="w" ay="s" />
</verb>
```

`ay="s"` because *die Milch **ist** übergekocht*. The corpus stays 3,572 verbs; readings went 3,615 →
3,616. Both authored sentences now pass, and the gate rose 98.1% → **98.3%** (1,076 → 1,078).

**And then the calibration result stopped being significant.** Before the fixes: flagged verbs missed
at 4.6% against 1.6% unflagged, a 2.86x relative risk at Fisher one-sided p = 0.048. After: 3.7% vs
1.5%, 2.44x, **p = 0.108**. The cause is exactly one observation. *überkochen* had been **flagged** by
its author, so fixing the corpus converted a flagged miss into a flagged hit — and with only 108
flagged verbs in the whole batch, that single reclassification walked p from just under the threshold
to just over it.

The honest lesson is about the earlier number, not the later one. **A p-value that one observation can
flip was never worth the weight "significant" implies**, and it was sitting at 0.048 when I first
reported it. The direction still looks real (2.4x is not nothing) and deserves retesting on a larger
flagged set; the threshold claim does not survive.

There is a subtler reading too, and it may be the more useful one. *überkochen* was flagged because the
model sensed something was wrong — and something **was** wrong, in the corpus rather than in its
sentence. So these flags may be tracking *"this verb is ambiguous or its gloss looks off"* rather than
*"my sentence is probably incorrect."* Those are different competencies, and only the second predicts
gate failure. The first is arguably more valuable — it found a real corpus defect that had been sitting
in `Verbs.xml` unnoticed. Worth separating the two if the adversarial review ever supplies an
independent defect signal to correlate against.

Which is the second time in one day that this pipeline audited the corpus rather than the sentences. It
was built to check the authors and keeps catching the app instead.
