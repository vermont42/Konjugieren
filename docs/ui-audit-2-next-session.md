# Next session: UI audit Round Two — items #9, #6, #11

## TL;DR

Implement three items from `docs/ui-audit-2.md`, in this order:

1. **#9** — Tab haptic on `MainTabView`. One line. (Warm-up — confirms the build pipeline is healthy.)
2. **#6** — Wrap VerbView's etymology and example-sentence sections with `.konjCardWithAccentBar()`.
3. **#11** — Wrap FamilyDetailView's long description with `.konjCard()`.

After completion, update `docs/ui-audit-2.md` per the conventions of earlier resolved sections (Status line, Resolution block, strikethrough in implementation-order list).

## Read first

- **`docs/ui-audit-2.md`** — the full audit. Status lines mark what's done. Sections #9, #6, and #11 are your specifications. The Resolution blocks of #2, #3, and #A describe how the modifier suite shipped and the conventions to match.
- **`CLAUDE.md`** — build/test commands (note the `IBV_SCRIPTS` resolution pattern), Swift coding rules, the Apple-Intelligence host-eligibility caveat.

The audit's "Custom modifiers in `Utils/Modifiers.swift`" list (line ~60) describes the three-modifier card suite (`konjCard()`, `konjCardWithAccentBar()`, `konjCardRim()`) that #6 and #11 build on. The "Color and design system in place" list (line ~38) names `customCardBackground` and `customCardBorder`, the assets the modifiers use.

## Per-item handoff notes

These are things I noticed during the session that just shipped #2/#3/#A and that aren't in the audit but would catch a fresh session out.

### #9 — Tab haptic (warm-up)

One line in `Konjugieren/Views/MainTabView.swift`. The audit gives the exact snippet. The simulator can't test haptics directly; verification is "code matches the recommendation, build clean."

### #6 — VerbView etymology + example sentences

- **Two sub-sections to wrap, not one.** The audit's recommended snippet shows etymology; the same wrapper applies to example sentences immediately below. Both need to land in the same change.
- **Typography change is layered onto the card-wrapping.** Etymology and example-sentence headings change from `.font(.headline)` to `.font(.subheadline.smallCaps().weight(.semibold)).fontDesign(.serif)` to match `ConjugationSectionView`'s heading style. Easy to skip if you focus only on "wrap in card." The audit's recommended snippet at #6 shows this — re-read it carefully.

### #11 — FamilyDetailView long description

- **Recommended modifier is `.konjCard()`, NOT `.konjCardWithAccentBar()`.** The audit is explicit: no accent bar, because the `BrowseableFamily.systemImageName` icon at the top is the focal element. Resist the consistency pull toward `.konjCardWithAccentBar()` — the recommendation is intentional.

## Verification

Per the audit's "Verification" section:

1. **Build clean**: `"$IBV_SCRIPTS/build_app.sh"`.
2. **Tests stay green**: `"$IBV_SCRIPTS/run_tests.sh"`. Last known good count: 118/118 in 17 suites.
3. **Visual screenshots** (capture under `docs/screenshots/` with a fresh timestamp):
   - **VerbView/sein** scrolled to etymology + example sentences. Pre-change baseline: `docs/screenshots/20260505-105900-verbs-tab.png` (shows bare etymology section pre-#6).
   - **FamilyDetailView/separable** (or any family with a long description). **No clean post-#A pre-#11 baseline exists.** Capture the current state *first* as a fresh baseline before implementing #11, then capture again after. (`docs/screenshots/20260505-105800-separable-detail.png` is pre-emoji-fix from before #1's resolution and is not a clean A/B comparison.)

## Updates to `docs/ui-audit-2.md` after completion

For each of the three implemented items, match the convention used by earlier resolved sections (#1, #2, #3, #15, #19, #20, #A):

1. **Add `**Status:** Resolved YYYY-MM-DD. See "Resolution" block at the end of this section.`** immediately after the `### N. Title` section heading.
2. **Add `**Resolution (YYYY-MM-DD):**`** block at the end of the section. Include: file/line site-by-site diff, any side effects (e.g., #6's typography change), and visual-confirmation screenshot paths.
3. **Strikethrough** the corresponding "Implementation order recommendation" line (around line ~890) wrapped in `~~...~~` with a `*Done YYYY-MM-DD.*` tail. After this batch, items 1–5 should all be struck.
4. **For #6 only**: strikethrough item 5 of "Areas for growth" (around line ~136) with `*Done — see #6.*` tail. #9 and #11 don't have areas-for-growth correlates; skip that step for them.

The audit's stated intent is **self-containedness for future sessions**. After your edits, a future Claude session reading the audit cold should immediately see that #9, #6, #11 are done and where to find the resolution context.

## What's next after this batch

Per the audit's implementation order, **#13** (subheading treatment in `RichTextView`) is the natural next step — it depends on #6/#11 having landed so the visual context is consistent across rich-text-rendering sites. **Do not implement #13 in this session**; leave the audit ready for the session after this one.

## Don't

- **Don't touch the Game or Dedication screens** (off-limits per Round One; see Constraints in the audit).
- **Don't expand scope.** While editing `VerbView.swift` for #6, you'll see #12 (metadata pill differentiation) and #14 (long-infinitive wrap) sitting right there. Resist. Those are for later batches.
- **Don't refactor the modifier suite.** It's settled. If you have improvement ideas (e.g., parameterizing corner radius), surface them to Josh as a separate conversation rather than acting on them.
- **Don't skip the audit-doc updates** at the end. The doc is load-bearing for future sessions; leaving it stale defeats its purpose.
- **Don't commit without asking Josh.** Standard project rule (see CLAUDE.md).
- **Delete this file** (`docs/ui-audit-2-next-session.md`) once the work lands, OR overwrite it with a fresh handoff for the session that will implement #13. The file is meant to be ephemeral.
