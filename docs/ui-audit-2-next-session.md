# Next session: UI audit Round Two — VerbView polish (#12 + #14)

## TL;DR

Implement two items from `docs/ui-audit-2.md`, both in `Konjugieren/Views/VerbView.swift`:

- **#12** — Differentiate the metadata pills by tint, extending the existing German-flag color system (yellow = descriptive, red = structural) into VerbView's pill row. Mechanical change once tints are decided.
- **#14** — Drop `.lineLimit(1)` (and likely `.minimumScaleFactor(0.5)`) on the verb-infinitive title so long verbs like `auseinandersetzen` wrap into the available canvas instead of shrinking to half-size.

Self-contained, single-file scope. The Settings polish batch (#7 / #8a, plus a bratwurst-thumbnail bug fix) shipped 2026-05-06 — this batch starts from a clean main.

After completion, update `docs/ui-audit-2.md` per the conventions of earlier resolved sections (Status line, Resolution block, strikethrough in implementation-order list).

## Read first

- `docs/ui-audit-2.md` — sections #12 and #14. Resolution blocks of recently shipped sections (especially #4, #7, #8) describe the conventions to match. The Settings-polish #7 Resolution has a "Bug-and-fix during shipping" paragraph that's a useful template for any post-implementation discoveries.
- `CLAUDE.md` (root) and `Konjugieren/CLAUDE.md` — build/test commands, the `IBV_SCRIPTS` resolution pattern, Swift coding rules (alphabetize enum cases, no force-unwraps in production), the `.xcstrings` Edit-tool hazard around ASCII double quotes.
- `Konjugieren/Views/VerbView.swift` — entire file. Both batch items live in the top region (lines ~33-98) plus the helper at lines 204-210.

## Pre-flight findings (verified 2026-05-06)

- **`metadataPill` helper lives at `VerbView.swift:204-210`** (the audit doc says 200-206; minor line drift, no semantic change).
- **Five pill call sites** total, across two HStacks:
  - Lines 53-72 (always-rendered HStack): Family, Auxiliary, Frequency.
  - Lines 75-97 (conditional HStack, only renders if `verb.prefix != .none || verb.ablautGroup != nil`): Separable / Inseparable (mutually exclusive), Ablaut.
- **Each pill already uses `Label(text, systemImage:)`** form. The audit's pill-content snippet pattern is already in place for the labels themselves; #12 only mutates the *background tint* + adds an optional border, not the label structure.
- **All pill backgrounds today use `Color.customYellow.opacity(0.08)`** (line 208) — the uniform tint that #12 is breaking up.
- **Long-infinitive typography at `VerbView.swift:37-45`**, with `.minimumScaleFactor(0.5)` at line 41 and `.lineLimit(1)` at line 42 (audit's references are accurate).
- **No existing tests** cover the pill-tint or title-typography behavior. View-layer changes don't typically warrant new tests; expect `122/122 in 17 suites` to hold post-batch.
- **Color tokens available**: `.customYellow`, `.customRed`, `.customForeground`, `.customCardBackground`, `.customCardBorder`. The German-flag system uses yellow + red as the two semantic tints; black is the canvas. No `customGold`, `customAmber`, etc. — don't invent new tones.

## Recommended sequence

1. **Surface decisions D1–D3 to Josh before coding.** All three are design-judgment calls that can't be settled by reading code. Once ratified, both items are mechanical.
2. **#12 first** — the substantive item. Generalize the helper, update five call sites.
3. **#14 second** — 1-2 line cleanup. Worth pairing because the long-infinitive wrap visually depends on the title space the user sees alongside the pills; visual sanity-check works better post-#12.
4. **Build clean → tests green → screenshots → audit-doc updates → surface for commit approval.**

## Decisions to ratify with Josh before coding

### D1. Per-pill tint assignments (#12)

Audit recommendation:

| Pill | Tint | Rationale |
|---|---|---|
| Family | `customYellow` | Descriptive metadata |
| Auxiliary | `customRed` | Structural — controls Perfekt construction with `sein`/`haben` |
| Frequency | `customYellow` | Descriptive metadata |
| Separable / Inseparable | `customRed` | Structural — affects word order, especially in subordinate clauses |
| Ablaut | `customYellow` with optional thin yellow border overlay | Visual exception worth marking |

The logic: **red tint = "this affects sentence structure beyond the verb itself"; yellow tint = "descriptive metadata about the verb."** The German-flag colors map naturally — red is the high-attention ribbon, suited to the structural-impact tag.

**Lean: ratify the audit's mapping.** Alternative: invert (red = irregular/exception, yellow = regular/expected) — would put Ablaut and Auxiliary-sein on red, but breaks the structural/descriptive grammar. The audit's split feels more linguistically coherent.

### D2. Ablaut pill: border overlay or no border?

Audit suggests adding a thin yellow border to the ablaut pill specifically (`Capsule().strokeBorder(.customYellow.opacity(0.3))`), so it's distinguishable from Family and Frequency despite the same tint. Decision: add the border (more differentiation), or skip it (cleaner)?

**Lean: add.** The ablaut pill carries higher information density than family or frequency (it's a learning hook — points at the ablaut pattern the verb belongs to, which the user can study), and the audit's "ablaut group is a visual exception worth marking" reasoning is sound.

### D3. For #14: drop only `.lineLimit(1)`, or also `.minimumScaleFactor(0.5)`?

Once `.lineLimit(1)` is removed, `.minimumScaleFactor(0.5)` becomes effectively dead code: SwiftUI will wrap rather than scale. The remaining edge case is a single word longer than the line — `.minimumScaleFactor` would still scale that. For German verb infinitives, the longest realistic case (`auseinandersetzen` at 17 characters, `unterscheiden` at 13) fits at `.largeTitle` on iPhone width.

**Lean: drop both.** Cleaner, avoids dead code, and removes the subtle visual scale-down that triggers for borderline-long verbs.

## Per-item handoff notes

### #12 — VerbView metadata pill differentiation

**1. Generalize the helper at `VerbView.swift:204-210`:**

```swift
private func metadataPill<Content: View>(
  tint: Color = .customYellow,
  bordered: Bool = false,
  @ViewBuilder content: () -> Content
) -> some View {
  content()
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(tint.opacity(0.08))
    .overlay {
      if bordered {
        Capsule().strokeBorder(tint.opacity(0.3))
      }
    }
    .clipShape(Capsule())
}
```

The default-parameter pattern preserves call-site backward compatibility — any future call site that omits `tint:` just gets yellow, any that omits `bordered:` just gets no border. The conditional in `.overlay {}` uses the `@ViewBuilder` form so the empty-branch case compiles cleanly (vs the audit's snippet which used a non-builder `.overlay(...)`).

**2. Update the five call sites per D1+D2** (assuming the audit's defaults are ratified):

```swift
// Line 54: Family — descriptive
metadataPill(tint: .customYellow) {
  Label(verb.family.displayName, systemImage: "tag")...
}

// Line 59: Auxiliary — structural
metadataPill(tint: .customRed) {
  Label { Text(verbatim: verb.auxiliary.verb) } icon: { Image(systemName: "arrow.triangle.branch") }...
}

// Line 68: Frequency — descriptive
metadataPill(tint: .customYellow) {
  Label("#\(verb.frequency)", systemImage: verb.frequencyIcon)...
}

// Lines 78, 82: Separable / Inseparable — structural
metadataPill(tint: .customRed) {
  Label(L.BrowseableFamily.separable, systemImage: "arrow.left.arrow.right")
}
metadataPill(tint: .customRed) {
  Label(L.BrowseableFamily.inseparable, systemImage: "link")
}

// Line 88: Ablaut — exceptional, with border
metadataPill(tint: .customYellow, bordered: true) {
  Label(ablautGroup, systemImage: "figure.and.child.holdinghands")...
}
```

**3. Accessibility:** no changes needed. The Label provides the standard text label; tint and border are purely presentational and don't affect VoiceOver. The existing `.accessibilityLabel(...)` calls on the Auxiliary, Frequency, and Ablaut pills (used to override the SF-Symbol-default reading) stay as-is.

### #14 — Long infinitive wrap

At `VerbView.swift:37-45`, remove lines 41 and 42:

```swift
Text(verb.infinitiv)
  .font(.largeTitle)
  .fontWeight(.bold)
  .fontDesign(.serif)
  // .minimumScaleFactor(0.5)  ← remove (per D3 lean: drop both)
  // .lineLimit(1)              ← remove
  .accessibilityAddTraits(UserLocale.isGerman ? .isHeader : [])
  .germanPronunciation()
  .speakOnTap(verb.infinitiv)
```

Visual verification with long verbs: `auseinandersetzen`, `zusammenarbeiten`, `unterscheiden`. Confirm the title wraps cleanly at iPhone width without overflowing the card-internal padding.

## Verification

Per the audit's "Verification" section and matching post-#7/#8(a) conventions:

1. **Build clean**: `"$IBV_SCRIPTS/build_app.sh"`. (Resolve `IBV_SCRIPTS` once per session per CLAUDE.md.)
2. **Tests stay green**: `"$IBV_SCRIPTS/run_tests.sh"`. Last known good: 122/122 in 17 suites. This batch is unlikely to add tests (view-layer changes, no new model API), so 122/122 should hold.
3. **Visual screenshots** under `docs/screenshots/` — pre/post pairs:
   - **Pre-batch baseline #1** (pill exemplar): pick a verb that exercises *all five* pill types in one view — for example `aufstehen` (auxiliary `sein`, separable prefix, ablaut group). Tap into VerbView from VerbBrowse → screenshot the top region showing the pill row.
   - **Pre-batch baseline #2** (long-infinitive exemplar): navigate to `auseinandersetzen` (or similar long verb) → screenshot.
   - **Post-batch versions of both**: same two views post-#12+#14.
4. **Manual simulator checks**:
   - For #12: verify all 5 pill types render in their assigned tints. Test verb combinations: a `sein`-auxiliary verb, a `haben`-auxiliary verb, a separable-prefix verb, an inseparable-prefix verb, a verb with an ablaut group, and a verb with none of the optional pills (the conditional second HStack should not render at all).
   - For #14: confirm long-infinitive wrap (no scale-down). Test on iPhone 17 (the IBV-configured simulator).

The Apple-Intelligence host-eligibility caveat (per CLAUDE.md) **does not apply** to this batch — VerbView has no Tutor-gated surfaces. Visual verification on the Intel-Mac dev host is fully meaningful here.

## Updates to `docs/ui-audit-2.md` after completion

For each shipped item, match the convention used by earlier resolved sections (#1, #2, #3, #4, #5, #6, #7, #8, #9, #10, #11, #13, #15, #19, #20, #22, #A):

1. **Add `**Status:** Resolved YYYY-MM-DD. See "Resolution" block at the end of this section.`** immediately after the section's `### N.` heading.
2. **Add `**Resolution (YYYY-MM-DD):**`** block at the end of the section, including: file/line diff summary, the D1/D2/D3 decisions made, side-effects worth recording, visual-confirmation screenshot paths, and any audit-snippet deviations (likely candidates: the `@ViewBuilder` overlay form vs the audit's non-builder snippet; any tint-mapping deviations from the audit's defaults).
3. **Strikethrough** the implementation-order line(s). #14 lives on line ~1007: `9. **~~#9~~ / #14 / #16 / #17 / #21** — small independent items. *#9 done 2026-05-06.*`. After #14 ships:

   `9. **~~#9~~ / ~~#14~~ / #16 / #17 / #21** — small independent items. *#9 done 2026-05-06. #14 done YYYY-MM-DD.*`

   #12 isn't in the line-9 list — it's a Medium Priority item without its own implementation-order entry. Find its mention via `grep -n '#12' docs/ui-audit-2.md` if you want to add a "done" marker; otherwise the Status line on the section itself is sufficient signal.

The audit doc is load-bearing for future sessions. After the edits, a future Claude session reading it cold should immediately see which VerbView items are done and where to find the resolution context.

## What's next after this batch

The remaining audit items, all independent of each other:

- **#16 (OnboardingView)**: reclaim empty space on page 1. Two sub-options — Spacer cap vs decorative gradient. Design-judgment-heavy single-screen item.
- **#17 (ResultsView)**: insert the gradient-divider pattern between score card and per-question list. Includes a small refactor — lift `gradientDivider` from `SettingsView`'s private property into a shared `GradientDivider` View in `Modifiers.swift`. Touches 3 files.
- **#21 (InfoBrowseView)**: pulse the Tutor-row brain icon. 2-line change, but **can't be visually verified on Intel-Mac hosts** (Apple Intelligence host-eligibility gate fails silently). Best paired with another item that *can* be verified, OR shipped with the verification caveat in the Resolution block.

A reasonable next batch after VerbView polish: **#17 + #21** as a "small cross-cutting cleanup" pair (the ResultsView change is verifiable; #21 ships with the host-eligibility caveat). Or **#16 alone** as a focused Onboarding session.

After this batch surfaces the choice to Josh, overwrite this `docs/ui-audit-2-next-session.md` with the next handoff or delete it if no batch is queued.

## Don't

- **Don't touch the Game or Dedication screens** (off-limits per Round One; see Constraints in the audit).
- **Don't ship D1/D2/D3 decisions without ratification.** Surface them first. The lean recommendations are well-reasoned but not prescriptive.
- **Don't expand the per-pill tint vocabulary beyond `customYellow` and `customRed`.** The German-flag color system in this app uses these two tints exclusively for semantic differentiation. Adding `customGold` or other variants for "yet another semantic distinction" is out of scope and would need its own audit cycle.
- **Don't change the pill icons.** #12 is about background tint; the SF Symbol assignments stay as-is.
- **Don't drop accessibility labels or hints when restructuring pill labels.** Each pill that has `.accessibilityLabel(Text(verbatim: ...))` today (Auxiliary, Frequency, Ablaut) keeps it.
- **Don't expand scope.** While editing `VerbView.swift`, the file has many other polishable surfaces (the etymology card, the example sentence card, the divider styling, the conjugation-section typography). Resist. This batch is scoped to two items.
- **Don't commit without asking Josh.** Standard project rule (CLAUDE.md).
- **Delete this file** (`docs/ui-audit-2-next-session.md`) once the batch lands, OR overwrite it with a fresh handoff for the next batch (#17+#21 or #16). The file is ephemeral working memory between sessions.
