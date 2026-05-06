# Next session: UI audit Round Two — Quiz polish (items #4, #5, #10, #22)

## TL;DR

Implement four items from `docs/ui-audit-2.md`, all in `Konjugieren/Views/QuizView.swift` (plus one `Localizable.xcstrings` edit):

- **#22** — `.speakOnTap()` on the verb infinitive (`QuizView.swift:94-97`).
- **#10** — replace the awkward "Conjgroup:" label, two flavors (a: rename string, b: drop label for SF Symbol).
- **#5** — improve `ProgressView` visibility (`QuizView.swift:91-92`).
- **#4** — reclaim the empty bottom 60% of the canvas. Three sub-options (a/b/c), the recommended (a) requires new Quiz API surface and is **not** a "ship the audit snippet" item.

After completion, update `docs/ui-audit-2.md` per the conventions of earlier resolved sections (Status line, Resolution block, strikethrough in implementation-order list).

## Read first

- **`docs/ui-audit-2.md`** — the audit. Section #4 (lines 299-335), #5 (336-361), #10 (515-542), #22 (811-826). The Resolution blocks of recently shipped items (#13 at 596-, #11 at 555-) describe the conventions to match.
- **`CLAUDE.md`** — build/test commands (note the `IBV_SCRIPTS` resolution pattern), Swift coding rules, the Apple-Intelligence host-eligibility caveat, the `.xcstrings` Edit-tool hazard around ASCII double quotes.
- **`Konjugieren/Views/QuizView.swift:88-228`** — the entire `quizContent` `@ViewBuilder`. All four items live in this view; reading the whole builder once will save time.

## Recommended sequence

The interactions matter:

1. **#22 first** — one modifier addition, independent of everything else. Cleanest warm-up.
2. **#10(a)** — one xcstrings value edit. Verify the longer string wraps cleanly on iPhone 17. Falls back to #10(b) if it doesn't.
3. **Decide #4 with Josh before doing #4 or #5**, because:
   - #4(a) replaces the progress bar (the audit explicitly says "drop the progress bar entirely — the dot row replaces it with richer information"). If (a) ships, **#5 is moot** and should not be implemented.
   - #4(a) requires designing new Quiz API surface (see per-item notes). It is **not** a verbatim-snippet item.
   - #4(b) and #4(c) leave the progress bar in place, in which case #5 is in scope.
4. **#5 if and only if** #4(a) is not chosen.
5. **#4** last (largest item).

If Josh wants to defer the #4 conversation, ship #22 + #10 + #5 first, stop, surface #4 design questions separately. That's a reasonable cut-point.

## Per-item handoff notes

### #22 (smallest, independent)

The audit's snippet adds `.speakOnTap(question.verb.infinitiv)` after `.germanPronunciation()` at `QuizView.swift:94-97`. Verbatim-shippable.

`Modifiers.swift:47` shows `.speakOnTap()` defaults to `UttererLocale.german`, so omitting the second arg is correct here — the verb infinitive is German.

Accessibility: tapping a `Text` to speak adds a tap target where one didn't exist. Verify VoiceOver still announces the infinitive cleanly (the existing `.germanPronunciation()` modifier shapes the VoiceOver pronunciation; adding `.speakOnTap` may layer a tap-action announcement). Smoke-test with VoiceOver if Josh wants the polish belt-and-suspenders.

### #10 ("Conjgroup:" label)

The string lives at `Quiz.conjugationgroup` in `Localizable.xcstrings`. Per CLAUDE.md, do not Grep on xcstrings — use Read with offset, or Python via Bash for find/replace. The German value also needs review (the current `Conjgroup` may have a corresponding German abbreviation worth expanding).

**Option (a)** — the recommended path — is a value edit: `"Conjgroup:"` → `"Conjugationgroup:"`. Verify the longer string wraps cleanly on iPhone 17 width inside the active-quiz card. The current layout at `QuizView.swift:115-123` is an `HStack(alignment: .top)` with `.fixedSize(horizontal: true, vertical: false)` on the label `Text` — meaning the label won't wrap, so the full word will push the right-hand `Text(verbatim:)` further right or wrap *it* across lines. That's a visual question worth screenshotting before committing.

**Option (b)** — replace the `Conjgroup:` label entirely with an SF Symbol — is bigger. It's a real UX/UI shift (drops the printed word in favor of an icon), affects accessibility (the SF Symbol needs an accessibility label), and the audit recommends doing the same to the `Pronoun:` label at `QuizView.swift:104-113` for consistency. If (a) wraps badly, (b) is the natural fall-back, but recommend asking Josh before committing to (b) — it's a design choice, not a fix.

### #5 (progress-bar visibility) — only if #4(a) is not shipping

The audit's snippet at `docs/ui-audit-2.md:349-356` adds:

```swift
.background(Color.customYellow.opacity(0.15))
.frame(height: 6)
.clipShape(Capsule())
```

A caveat: `ProgressView`'s linear style on iOS doesn't expose a track via `.background`. The snippet's `.background(...)` will paint behind the *entire* ProgressView frame (including the filled portion), which gives a different visual than a "dim track + bright fill" pattern. Eyeball the result; if the layered backgrounds don't read as a track-and-fill, fall back to a custom `ProgressViewStyle` (a `Capsule` track + a leading-aligned `Capsule` fill scaled by progress). That's more code but produces the visual the audit gestures at.

The audit's `.frame(height: 6)` + `.clipShape(Capsule())` are uncontroversial.

### #4 (reclaim empty bottom 60%) — discuss before implementing

The audit offers three options (a/b/c). Each has different scope:

- **(a) Question-queue dot row.** The audit's snippet calls `quiz.stateForQuestion(at: i)` — **this Quiz API does not exist.** The Quiz model (see `Konjugieren/Models/Quiz.swift`) currently tracks `currentIndex`, `correctCount`, `lastIncorrectAnswer`, `lastCorrectAnswer`, and `lastErrorContext`, but not a per-question state array across the entire run. Implementing (a) requires:
  - A new `enum QuestionState { case correct, incorrect, unanswered }` (or similar).
  - A new `[QuestionState]` (or similar) on Quiz, mutated as each answer is submitted.
  - A public `func stateForQuestion(at index: Int) -> QuestionState` on Quiz.
  - Tests in `QuizTests` covering the new API across correct/incorrect/quit/restart paths.

  This is the highest-payoff visual change in the batch, but it is not a "ship the snippet" item — it is a small Quiz refactor with new public API surface. Cost: maybe an hour of careful work + tests. Surface this to Josh before starting.

  Layout sanity-check: 30 dots × 8pt + 29 spacings × 4pt = 356pt. iPhone 17 native width is ~402pt. Fits with the standard horizontal padding (`Layout.doubleDefaultSpacing` × 2 = ~32pt total). Tight on smaller devices (iPhone SE 3 = 375pt) — verify, possibly reduce dot size or spacing.

  iOS-version note: `.symbolEffect(.pulse, options:, isActive:)` with the `isActive:` parameter is iOS 18+. Project min target is current; verify before assuming.

- **(b) Move the "last answer" card out of the active card.** Splits `QuizView.swift:147-170` (the lastAnswer review block) into a separate `.konjCard()` below the active card. Reduces active-card density. Lower implementation cost than (a), no new Quiz API. The visual question: where to put the new card relative to the input field — above, below, or floating off to one side. Likely below, matching the existing top-down reading order.

- **(c) Glanceable conjugation reference card.** A third card showing related conjugations of the current verb (e.g., `Perfektpartizip` and `Präteritum 3sg`). Higher pedagogical value, higher design cost — needs deciding which conjugations to surface, and whether the user can tap a related conjugation to hear it. Probably out of scope for the polish batch; flag as a Round Three item.

The audit recommends (a). If Josh wants the highest visual payoff, accept the API-design cost. If he wants a pure-polish batch with no new API surface, (b) is the right call. (c) is best deferred.

## Verification

Per the audit's "Verification" section and matching the post-#13 conventions:

1. **Build clean**: `"$IBV_SCRIPTS/build_app.sh"`.
2. **Tests stay green**: `"$IBV_SCRIPTS/run_tests.sh"`. Last known good: 118/118 in 17 suites. If #4(a) ships with new Quiz API, expect that count to grow (add tests in `QuizTests`).
3. **Visual screenshots** (capture under `docs/screenshots/` with a fresh timestamp, slug suffix `-postQuizPolish` or per-item):
   - **Pre-batch baseline** already exists: `docs/screenshots/20260505-105500-quiz-active.png` (the audit cites this as #4/#5/#10's visual proof).
   - **Post-#22**: tap the infinitive to confirm `.speakOnTap` fires (audible, no visual change); a screenshot is optional but a brief description of the test is worth recording in the Resolution block.
   - **Post-#10**: screenshot showing the new label.
   - **Post-#4**: a screenshot showing the new dot row (or the split cards, depending on which sub-option ships).
   - **Post-#5** (if shipped): screenshot showing the upgraded progress bar with track.

The `docs/screenshots/` directory is gitignored (per `.gitignore:10`) — captures live on disk and serve as documentation pointers in the Resolution block, but are not committed.

Apple-Intelligence caveat: the `ErrorExplainerView` at `QuizView.swift:166-169` is gated on `Current.languageModelService.isAvailable`. On Intel-Mac hosts running iOS 26.3.1+, this surface does not render. None of #4/#5/#10/#22 modify ErrorExplainerView, so the gate doesn't matter for *implementation*; but if the screenshots are taken on the Intel-Mac host, they will not show ErrorExplainerView. State that explicitly in the Resolution block to avoid future-Josh wondering whether ErrorExplainerView regressed.

## Updates to `docs/ui-audit-2.md` after completion

For each item that ships, match the convention used by earlier resolved sections (#1, #2, #3, #6, #9, #11, #13, #15, #19, #20, #A):

1. **Add `**Status:** Resolved YYYY-MM-DD. See "Resolution" block at the end of this section.`** immediately after the section's `### N.` heading.
2. **Add `**Resolution (YYYY-MM-DD):**`** block at the end of the section, including: the file/line diff, side-effects worth recording, and visual-confirmation screenshot paths.
3. **Strikethrough** the implementation-order line. The Quiz-polish items live at `docs/ui-audit-2.md:928`:
   - `7. **#4 / #5 / #22 / #10** (Quiz polish) — independent of card system.`

   If all four ship in this batch, strike the entire line. If only some ship, leave the line and add a per-item "Done YYYY-MM-DD" tail noting which.

The audit doc is load-bearing for future sessions. After the edits, a future Claude session reading the audit cold should immediately see which Quiz-polish items are done and where to find the resolution context.

## What's next after this batch

The remaining audit items are independent of each other and the Quiz-polish work. Choice-of-focus, not dependency:

- **Settings polish**: #7 (App Icon picker thumbnails), #8 (action-button differentiation).
- **VerbView polish**: #12 (metadata pill differentiation), #14 (long-infinitive wrap).
- **Small independents**: #16 (onboarding page-1 layout), #17 (Results score-card divider), #21 (Tutor icon emphasis).

Surface the choice to Josh once the Quiz-polish batch lands.

## Don't

- **Don't touch the Game or Dedication screens** (off-limits per Round One; see Constraints in the audit).
- **Don't ship #4(a) without surfacing the Quiz API design to Josh.** The audit's snippet implies a public method that does not exist; designing that API is part of the work, not a snippet to copy.
- **Don't implement #5 if #4(a) is shipping.** The dot row replaces the progress bar by design; keeping both is visual redundancy.
- **Don't expand scope.** While editing `QuizView.swift`, the `quizContent` builder has many other polishable surfaces (the score row, the check overlay, the shake animation parameters, the text-field appearance). Resist. This batch is scoped to four items.
- **Don't drop accessibility traits or hints when restructuring.** `QuizView.swift:178` sets `.accessibilityHint(L.Accessibility.quizTextFieldHint)`; if the input field moves under #4(b), the hint must move with it. The Pronoun label uses `.fixedSize(horizontal: true, vertical: false)` — a layout hint that VoiceOver doesn't see, but the text-pair semantics rely on it for visual layout.
- **Don't commit without asking Josh.** Standard project rule (see CLAUDE.md).
- **Delete this file** (`docs/ui-audit-2-next-session.md`) once the batch lands, OR overwrite it with a fresh handoff for the next batch (Settings / VerbView / Small independents — Josh's choice). The file is ephemeral.
