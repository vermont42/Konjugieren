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
