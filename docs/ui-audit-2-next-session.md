# Next session: UI audit Round Two — OnboardingView page-1 layout (#16, options a + b)

## TL;DR

Implement #16 from `docs/ui-audit-2.md`, shipping both fix candidates the audit listed:

- **(a) Spacer cap.** Cap the leading `Spacer()` in `OnboardingPageView.body` at `maxHeight: 100` so content anchors ~1/3 down the page rather than vertically centered. Side effect: applies to every onboarding page (not just page 1), since `OnboardingPageView` is the shared per-page subview.
- **(b) Decorative gradient.** Add a subtle `customYellow.opacity(0.08) → .clear` linear gradient in the upper canvas region. Static, decorative, accessibility-hidden.

Single-screen item. Single file touched (`Konjugieren/Views/OnboardingView.swift`) plus the audit doc and possibly `docs/screenshots/`. Fully verifiable on Intel-Mac dev hosts.

The prior audit batch (#17 / #21) shipped 2026-05-06 — this batch starts from a clean main. After this batch lands, Round Two's actionable surface is **complete**; remaining items (#18, #23, #24) are deferred or not-recommended.

## Read first

- `docs/ui-audit-2.md` — section #16 (line ~858). Resolution blocks of recently shipped sections (#17 and #21, both 2026-05-06) describe the conventions to match.
- `CLAUDE.md` (root) and `Konjugieren/CLAUDE.md` — build/test commands, the `IBV_SCRIPTS` resolution pattern, Swift coding rules, comment policy ("Hacks or workarounds" comments allowed; no MARK or explanatory comments).
- `Konjugieren/Views/OnboardingView.swift` — entire file (~291 lines). Key regions:
  - `OnboardingView.body` ZStack at lines 22-129 — where (b) lands.
  - `OnboardingPageView.body` at lines 187-248 — where (a) lands.

## Pre-flight findings (verified 2026-05-06)

- **`OnboardingPageView.body` is at lines 187-248**, not 188-231 as the audit references. ~+17 line drift since the audit was written; structure unchanged.
- **The leading `Spacer()` is at line 189**, exactly as the audit says. Trailing `Spacer()` at line 230 — leave as unbounded; it's the bottom counterweight.
- **`OnboardingPageView` is the shared per-page subview**, used for all pages. The page count is conditional: 6 pages on Apple-Intelligence-eligible hosts (welcome / browse / families / quiz / **Tutor** / learn-articles), 5 pages on others (Tutor page tag 4 is gated on `Current.languageModelService.isAvailable`). On this Intel-Mac dev host, 5 pages render.
- **The (a) layout change applies to every page** — uniform behavior is the intent, not a bug. Worth recording as a side effect in the Resolution block.
- **`OnboardingView`'s parent ZStack at line 23** already paints `Color.customBackground.ignoresSafeArea()`. The (b) gradient can sit as a sibling in this ZStack (parent-level, applies once for the whole flow) **or** as a `.background(...)` modifier on `OnboardingPageView`'s VStack (per-page). See D2 below.
- **Gotcha for parent-level placement**: `ZStack`'s default child alignment is `.center`. A 300pt gradient inside the ZStack without explicit top-anchoring would render mid-screen, not in the upper canvas. Either apply `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)` on the gradient, or use `ZStack(alignment: .top)`. Per-page placement (via `.background(alignment: .top)`) doesn't have this concern — the modifier API anchors automatically.
- **No tests cover OnboardingView's layout.** View-layer changes; expect 122/122 in 17 suites to hold post-batch.
- **#21's pending real-iPhone visual verification** (Tutor brain pulse from prior batch) — confirm with Josh whether that has been done, since Round Two's "complete" framing presumes it's verified. Not a blocker for this batch but worth flagging.

## Recommended sequence

1. **Surface decisions D1–D4 to Josh before coding.** Three are short design ratifications (D1, D2, D3); D4 is a process call about screenshot scope.
2. **(b) first** — the gradient is purely additive (background layer), zero risk of layout regression. Land it, screenshot, confirm visually before introducing the layout change.
3. **(a) second** — the Spacer cap reshapes layout. Land after (b) so the visual change is on top of the gradient backdrop and the post-batch screenshots reflect both at once.
4. **Build clean → tests green → screenshots (page 0 + one spot-check page, plus AX3 on page 0) → audit-doc updates → surface for commit approval.**

## Decisions to ratify with Josh before coding

### D1. Spacer cap value: 100 vs alternative?

Audit snippet: `.frame(maxHeight: 100)`.

On a tall iPhone (~852pt content height for iPhone 17), a 100pt cap leaves content sitting roughly ~12% from the top of the safe area — the upper third when the trailing Spacer takes the rest. On a smaller iPhone (SE, ~568pt content height), 100pt is closer to ~18% from top — content crowds the upper region but doesn't overflow.

**Lean: ratify 100.** Audit's recommendation. The cap interacts well with both extremes — on tall phones, content sits in the upper third (the audit's stated intent); on small phones, content sits closer to the top, which is acceptable given the screen has less room to spare. No reason to override.

### D2. Gradient placement: per-page (`OnboardingPageView`) vs parent-level (`OnboardingView`'s ZStack)?

- **Per-page**: `.background(alignment: .top) { gradient }` applied to `OnboardingPageView`'s VStack at line 187. Gradient is rendered once per page; SwiftUI optimizes via View-tree caching but conceptually each page has its own gradient instance. Side effect: gradient swipes horizontally with the page as the user transitions between TabView pages.
- **Parent-level**: gradient as a sibling of `Color.customBackground` in `OnboardingView`'s ZStack at line 23. Renders once for the whole onboarding flow. Side effect: gradient stays put as pages swipe — content moves over a fixed canvas tint.

**Lean: parent-level.** Cleaner code (one gradient instance, not per-page). Decorative scenery should sit below content as ambient tint rather than per-page styling. The "static scenery, swiping content" feel is what one expects from system-style onboarding flows. Plus: per-page placement means each page's `OnboardingPageView` re-renders the gradient on appearance, which (while cheap) is conceptually wasteful.

Counter-argument worth surfacing: per-page placement keeps the gradient API local to the page subview, which makes it easier to vary per-page (e.g., page 0 yellow tint, page-with-Tutor a different tint). If Josh wants per-page tint variation later, parent-level is a refactor; per-page is the natural surface. But — no current call for per-page variation. YAGNI.

### D3. Gradient height: 300 vs alternative?

Audit snippet: `.frame(height: 300)`.

A 300pt-tall gradient on iPhone 17 (~852pt content height) covers roughly the upper third. The gradient fades from `customYellow` at 8% opacity at the very top to clear at the gradient's center (so 50% down the gradient, which is 150pt from top). After 300pt, no gradient at all.

**Lean: ratify 300.** Audit's recommendation; visual scope matches "upper canvas" intent. On smaller iPhones, 300pt is more than half the screen, but the fade-to-clear at midpoint means the gradient stays in the upper region. Layout adapts.

### D4. Verification screenshots: which pages?

Page 0 (welcome — mug icon) is the audit's reference page. Other pages share the same `OnboardingPageView` layout but their content varies (different icons, different bodies, info-button vs nav-button).

- **D4a — Page 0 only.** Minimal effort; the audit cited page 0; the layout is shared so the rest follow.
- **D4b — Page 0 + one spot-check page.** Take pre/post on page 0, plus a spot-check screenshot on a page with a navigation button (e.g., page 1 — Browse Verbs). Verifies the layout adapts to button-content variance and that no page renders worse than page 0.
- **D4c — All pages.** Most thorough; 5-6 pre/post pairs. Total screenshots ~10-12. Likely overkill for a layout change that's known to be uniform.

**Lean: D4b.** Spot-check a second page to catch any case where button height or body-text length interacts badly with the new Spacer cap. Low cost (one extra page navigation + screenshot pair), high confidence boost.

## Per-item handoff notes

### #16 — OnboardingView page-1 layout (options a + b)

**1. Add the gradient (b) to `OnboardingView`'s ZStack** (per D2 — parent-level lean):

In `OnboardingView.body` at the ZStack starting line 23, between the existing `Color.customBackground` and the existing `VStack`:

```swift
ZStack(alignment: .top) {                                  // ← changed: explicit alignment
  Color.customBackground
    .ignoresSafeArea()

  LinearGradient(                                          // ← new
    colors: [.customYellow.opacity(0.08), .clear],
    startPoint: .top,
    endPoint: .center
  )
  .frame(height: 300)
  .frame(maxWidth: .infinity)
  .allowsHitTesting(false)
  .accessibilityHidden(true)

  VStack {
    // ... existing content unchanged
  }
}
```

Two adjustments worth flagging vs the audit's snippet:

- The audit's snippet uses `.background(alignment: .top) { ... }` as a modifier — that wraps a parent View's background. Used as a sibling inside a ZStack, the same gradient needs explicit top-anchoring (here via `ZStack(alignment: .top)`). Same visual result, slightly different SwiftUI plumbing.
- `.frame(maxWidth: .infinity)` on the gradient ensures it spans the full screen width regardless of content layout.

**2. Cap the leading Spacer (a)** at `OnboardingPageView.body` line 189:

```swift
var body: some View {
  VStack(spacing: Layout.doubleDefaultSpacing) {
    Spacer()
      .frame(maxHeight: 100)                              // ← new: was unbounded

    Image(systemName: symbolName)
      // ... rest unchanged through line 230
  }
}
```

The trailing `Spacer()` at line 230 stays unbounded — it's the bottom counterweight that fills the remainder of the page.

**3. Accessibility**: the gradient is `.accessibilityHidden(true)` (audit-spec'd). The Spacer cap doesn't change accessibility — Spacer carries no accessibility content.

**4. AccessibilityReduceMotion**: the gradient is static. The existing `.symbolEffect(.bounce, value: bounceValue)` on the icon already respects reduce-motion via SwiftUI's symbol-effect handling. No new motion considerations introduced by this batch.

## Verification

1. **Build clean**: `"$IBV_SCRIPTS/build_app.sh"`. Resolve `IBV_SCRIPTS` once per session per `CLAUDE.md`.
2. **Tests stay green**: `"$IBV_SCRIPTS/run_tests.sh"`. Last known good: 122/122 in 17 suites. View-layer changes only — count holds.
3. **Visual screenshots** under `docs/screenshots/`:
   - **Pre-batch page 0**: existing `docs/screenshots/20260505-104459-onboarding-1.png` is the page-0 baseline (predates today's audit batches; OnboardingView hasn't been touched since). Reuse as the baseline.
   - **Pre-batch spot-check page (D4b)**: take a fresh pre-batch screenshot of one downstream page (e.g., page 1 — Browse Verbs) before code changes.
   - **Post-batch page 0** (after both (a) and (b) shipped): screenshot for direct comparison to `20260505-104459-onboarding-1.png`.
   - **Post-batch spot-check page**: screenshot for direct comparison to its pre-batch counterpart.
4. **AX3 spot-check** on page 0: set `xcrun simctl ui "$UDID" content_size accessibility-extra-large` and confirm the Spacer cap doesn't break content overflow. The icon/title/body region grows at AX sizes; verify the cap (100pt) plus content plus trailing Spacer still produces a sensible layout. The gradient is independent of content size.
5. **Reset content size** to `large` after AX3 work.

### Triggering onboarding on the simulator

Onboarding shows automatically on first launch (when `hasSeenOnboarding` is false). For repeated screenshots:

- **Easiest**: tap **Settings → Show Onboarding** in the simulator. Re-shows onboarding modally with `isReshow: true` (the only visible difference vs first-launch is the top-right button reads "Dismiss" instead of "Skip" per `OnboardingView.swift:31`). Visual layout is identical, so re-show is fine for verification screenshots.
- **For the cleanest first-launch state**: `xcrun simctl uninstall <UDID> biz.joshadams.Konjugieren`, then `launch_app.sh`. Note: `launch_app.sh` interleaves a Skip-tap during wait-for-render (per `CLAUDE.md`), so onboarding auto-dismisses by default. To take onboarding screenshots, either (a) edit the launch script's Skip-tap interleave out for this run, or (b) just use the Settings → Show Onboarding path. **(b) is recommended** — less friction, same visual.

## Updates to `docs/ui-audit-2.md` after completion

Match the convention used by earlier resolved sections (#1, #2, #3, #4, #5, #6, #7, #8, #9, #10, #11, #12, #13, #14, #15, #17, #19, #20, #21, #22, #A):

1. **Add `**Status:** Resolved YYYY-MM-DD. See "Resolution" block at the end of this section.`** immediately after `### 16. OnboardingView: Reclaim empty space on page 1`.
2. **Add `**Resolution (YYYY-MM-DD):**`** block at the end of section #16 (before the trailing `---` separator), including:
   - File/line diff summary.
   - D1 / D2 / D3 / D4 decisions made.
   - **Side effect to record**: layout change applies to all `OnboardingPageView` pages, not just page 1 (the audit's page-1 framing was a representative reference, not a scope restriction).
   - Visual-confirmation screenshot paths (page 0 pre/post + spot-check page pre/post + AX3).
3. **Strikethrough** the implementation-order list entry. Currently:

   `9. **~~#9~~ / ~~#14~~ / #16 / ~~#17~~ / ~~#21~~** — small independent items. *#9 done 2026-05-06. #14 done 2026-05-06. #17 done 2026-05-06. #21 done 2026-05-06.*`

   After this batch:

   `9. **~~#9~~ / ~~#14~~ / ~~#16~~ / ~~#17~~ / ~~#21~~** — small independent items. *#9 done 2026-05-06. #14 done 2026-05-06. #16 done YYYY-MM-DD. #17 done 2026-05-06. #21 done 2026-05-06.*`

   All items in line 9 struck through after this batch — Round Two's small-independent-items group is complete.

The audit doc is load-bearing for future sessions. After the edits, a future Claude session reading it cold should immediately see all of Round Two's actionable items are resolved.

## What's next after this batch

After #16 lands, **Round Two's actionable surface is complete.** The remaining numbered items are:

- **#18 VerbBrowseView sort scroll-to-top** — author marked "tradeoff, not a bug. No fix recommended without user feedback." Effectively deferred indefinitely. Don't ship without Josh having user data justifying a change.
- **#23 floating tab pill material** — author marked "Lowest priority — likely leave alone." Could be moved to "won't fix" status in a future doc-tidying pass.
- **#24 SettingsView section-header divider variety** — author marked "bordering on over-design. Listed for completeness; not recommended."

A possible **Round Three** would target the currently-off-limits screens or screens not covered in Round One/Two:

- **Game screen** (off-limits per Round One; see Constraints in the audit).
- **Dedication screen** (off-limits per Round One).
- **TutorView** (the AI chat interface) and its `ErrorExplainerView` card surface inside `QuizView` — both Apple-Intelligence-gated, so verification requires real-iPhone or Apple-Silicon-Mac access.
- **ChatHistoryView** (if it exists; check `Konjugieren/Views/`).

Whether to greenlight Round Three is a future-cycle decision after #16 ships and we see how the round-two surface holds up in App Store user feedback.

After this batch surfaces the choice to Josh, **delete `docs/ui-audit-2-next-session.md`** (no successor batch is queued unless Round Three is greenlit). Same for any `*-questions.md` and `*-followup.md` files this batch produces — they're ephemeral working memory between sessions.

## Don't

- **Don't touch the Game or Dedication screens** (off-limits per Round One; see Constraints in the audit).
- **Don't ship D1–D4 decisions without ratification.** Surface them first. The leans are well-reasoned but not prescriptive.
- **Don't apply the (a) Spacer cap selectively per page** (e.g., only page 0). The whole point of `OnboardingPageView` being shared is uniform visual treatment across pages. Per-page selective layout would require a parameter and adds friction for marginal benefit.
- **Don't add motion to the gradient** (e.g., shifting hue, animating opacity, breathing effect). The audit's snippet is a static gradient; keep it static. Animated decorative elements need to gate on `accessibilityReduceMotion` and add scope.
- **Don't expand scope into other OnboardingView polish** (e.g., button styling, tab indicator styling, icon size, page-transition animation). The leading-Spacer cap and the upper-canvas gradient are the items. Other polish out of scope.
- **Don't try to combine the gradient with the existing `.symbolEffect(.bounce)` on the icon** in any way. They're orthogonal concerns (per-icon symbol motion vs canvas-wide static decoration). Don't entangle.
- **Don't re-run the launch_app.sh Skip-tap interleave for onboarding screenshots.** It dismisses onboarding before you can screenshot it. Use the Settings → Show Onboarding path instead — same visual, no friction.
- **Don't commit without asking Josh.** Standard project rule (`CLAUDE.md`).
- **Delete this file** (`docs/ui-audit-2-next-session.md`) once the batch lands. No successor handoff is queued absent a Round Three decision. Same for any `*-questions.md` and `*-followup.md` files this batch produces.
