# Next session: UI audit Round Two — item #13

## TL;DR

Implement **#13** from `docs/ui-audit-2.md`: change `RichTextView`'s subheading rendering from `.headline` yellow-centered to a serif `.title3.bold()` heading with a small red-dot leading ornament, yellow fill, and `.frame(maxWidth: .infinity, alignment: .leading)`. The change is one `switch` case (`case .subheading`) in `RichTextView.swift`. The audit's recommended snippet at #13 ships verbatim.

After completion, update `docs/ui-audit-2.md` per the conventions of earlier resolved sections (Status line, Resolution block, strikethrough in implementation-order list).

## Read first

- **`docs/ui-audit-2.md`** — the full audit. Status lines mark what's done. Section #13 is your specification. The Resolution blocks of #1, #2, #3, #6, #9, #11, #A describe how prior work shipped and the conventions to match.
- **`CLAUDE.md`** — build/test commands (note the `IBV_SCRIPTS` resolution pattern), Swift coding rules, the Apple-Intelligence host-eligibility caveat.

The audit's #13 caveat (around line ~590) names every place `RichTextView` is rendered: InfoView article body, FamilyDetailView long descriptions (now carded post-#11), OnboardingInfoSheet ("What is a conjugationgroup?" body), and VerbView etymology (now carded post-#6 — but only if etymology content contains backtick subheadings; see note below). All currently render `case .subheading` the same way; the visual unification is desirable.

## Per-item handoff notes

These are things the previous session (which just shipped #6/#9/#11) noticed and that aren't in the audit but would catch a fresh session out.

### Visual verification multiplies across framing contexts

`RichTextView`'s subheading now lives inside three different framing contexts. The new dot-and-serif heading needs to read well in all three:

1. **Carded with accent bar** — VerbView etymology + example sentences post-#6 use `.konjCardWithAccentBar()`. Three yellow elements (accent bar, heading text, body emphasis) plus a red dot can feel busy. Particularly worth eyeballing here.
2. **Carded without accent bar** — FamilyDetailView description post-#11 uses `.konjCard()`. No competing yellow accent; cleaner case.
3. **Full-bleed (no card)** — InfoView article body, OnboardingInfoSheet body. No surrounding card; the dot ornament must read as a section marker rather than a UI control.

If the carded-with-accent-bar case feels overcrowded, options to discuss with Josh: (a) make the dot color responsive to context, (b) drop the dot inside cards and keep it for full-bleed, or (c) accept the density and ship as-is. The audit's snippet doesn't anticipate this; the previous session flagged it as a thing to look at.

### Check `Etymology.text` for backtick subheadings before assuming VerbView etymology is affected

The audit lists VerbView etymology as a post-#13 surface, but only because etymology *might* contain backtick subheadings. Verify before claiming it. Quick check:

```bash
# Find the source of Etymology.text(for:) and grep its body for backticks.
grep -rn 'Etymology' Konjugieren/Models/ Konjugieren/Assets/
```

If no etymology contains `` ` `` subheadings, VerbView etymology won't visually change despite the rendering change — that narrows the post-#13 verification scope to InfoView, FamilyDetailView, and OnboardingInfoSheet.

### Don't drop `.accessibilityAddTraits(.isHeader)`

The audit's recommended snippet at #13 keeps `.accessibilityAddTraits(.isHeader)` on the heading `Text`. Easy to miss when restructuring the `case .subheading` body into the `HStack { Circle(); Text(...) }` layout — preserve the trait, or screen readers lose the section-marker semantics. The previous session specifically flagged this.

### Tests likely unaffected

`StringExtensions` parsing tests cover subheading *detection* in markup (the `` ` `` delimiter); the #13 change is in `RichTextView`'s *rendering*, not in parsing. The 118/118 in 17 suites count should hold post-change. Confirm with `"$IBV_SCRIPTS/run_tests.sh"`.

## Verification

Per the audit's "Verification" section:

1. **Build clean**: `"$IBV_SCRIPTS/build_app.sh"`.
2. **Tests stay green**: `"$IBV_SCRIPTS/run_tests.sh"`. Last known good: 118/118 in 17 suites.
3. **Visual screenshots** (capture under `docs/screenshots/` with a fresh timestamp), one per relevant framing context:
   - **InfoView article body** with at least one subheading visible (e.g., navigate to "A History of the German Verb System"; the article has multiple backtick headings). Pre-#13 baseline: `docs/screenshots/20260505-104299-info-history-detail.png`.
   - **OnboardingInfoSheet** "What is a conjugationgroup?" body scrolled to a subheading.
   - **FamilyDetailView/separable** if its description contains a subheading inside the carded prose. Pre-#13 baseline: `docs/screenshots/20260506-101406-separable-detail-post11.png`.
   - **VerbView/sein etymology** only if `Etymology.text("sein")` contains backticks (verify per the note above). Pre-#13 baselines: `docs/screenshots/20260506-101245-sein-etymology-post6.png`, `docs/screenshots/20260506-101339-sein-example-sentences-post6.png`.

## Updates to `docs/ui-audit-2.md` after completion

Match the convention used by earlier resolved sections (#1, #2, #3, #6, #9, #11, #15, #19, #20, #A):

1. **Add `**Status:** Resolved YYYY-MM-DD. See "Resolution" block at the end of this section.`** immediately after the `### 13. InfoView: Subheading visual treatment` section heading.
2. **Add `**Resolution (YYYY-MM-DD):**`** block at the end of the section. Include: the file/line diff in `RichTextView.swift`, how the dot reads in the carded-with-accent-bar context (the side effect to call out), and visual-confirmation screenshot paths per framing context.
3. **Strikethrough** "Implementation order recommendation" line 6 (`**#13** (subheading treatment)...`, around line ~895) wrapped in `~~...~~` with a `*Done YYYY-MM-DD.*` tail. After this batch, items 1–6 should all be struck.

The audit's stated intent is **self-containedness for future sessions**. After your edits, a future Claude session reading the audit cold should immediately see that #13 is done and where to find the resolution context.

## What's next after this batch

The card system + rich-text rendering refactor is fully landed once #13 ships. The remaining audit items are independent of each other, and the choice between them is a question of focus rather than dependency:

- **Quiz polish**: #4 (reclaim empty bottom 60%), #5 (progress bar visibility), #10 (Conjgroup label), #22 (speak-on-tap for infinitive).
- **Settings polish**: #7 (App Icon picker thumbnails), #8 (action-button differentiation).
- **VerbView polish**: #12 (metadata pill differentiation), #14 (long-infinitive wrap).
- **Small independents**: #16 (onboarding page-1 layout), #17 (Results score-card divider), #21 (Tutor icon emphasis).

**Do not implement any of these in the same session as #13.** Surface the choice to Josh once #13 lands.

## Don't

- **Don't touch the Game or Dedication screens** (off-limits per Round One; see Constraints in the audit).
- **Don't expand scope.** While editing `RichTextView.swift` for #13, the body builder has other cases (links, conjugations, plain-text, bold) that could be polished. Resist. This batch is just `case .subheading`.
- **Don't refactor the `RichTextView` rendering pipeline** beyond the one switch case. It's settled. If you have improvement ideas (e.g., parameterizing the dot color, lifting heading style into a shared modifier), surface them to Josh as a separate conversation rather than acting on them.
- **Don't drop `.accessibilityAddTraits(.isHeader)`** on the heading `Text` (called out separately above; repeating because it's easy to miss).
- **Don't skip the audit-doc updates** at the end. The doc is load-bearing for future sessions; leaving it stale defeats its purpose.
- **Don't commit without asking Josh.** Standard project rule (see CLAUDE.md).
- **Delete this file** (`docs/ui-audit-2-next-session.md`) once the work lands, OR overwrite it with a fresh handoff for the next batch (Quiz polish / Settings polish / VerbView polish — Josh's choice). The file is meant to be ephemeral.
