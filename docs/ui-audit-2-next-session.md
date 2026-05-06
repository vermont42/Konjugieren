# Next session: UI audit Round Two — Settings polish (#7 + #8)

## TL;DR

Implement two items from `docs/ui-audit-2.md`, both in `Konjugieren/Views/SettingsView.swift` (plus `AppIcon.swift`, `Localizable.xcstrings`, possibly `L.swift`):

- **#7** — replace the App Icon segmented Picker (`SettingsView.swift:102-114`) with a `LazyVGrid` of selectable thumbnails.
- **#8** — differentiate the action buttons (`SettingsView.swift:116-189`): add SF Symbol labels, optionally split the single actions card into two thematic cards.

Self-contained, single-screen scope. The Quiz-polish batch (#4 / #5 / #10 / #22) shipped 2026-05-06 — this batch starts from a clean main.

After completion, update `docs/ui-audit-2.md` per the conventions of earlier resolved sections (Status line, Resolution block, strikethrough in implementation-order list).

## Read first

- **`docs/ui-audit-2.md`** — sections #7 (lines ~407-447) and #8 (lines ~451-486). Resolution blocks of recently shipped sections (especially #4 with the bug-and-fix paragraph) describe the conventions to match.
- **`CLAUDE.md`** — build/test commands, the `IBV_SCRIPTS` resolution pattern, Swift coding rules (alphabetize enum cases, no force-unwraps in production), the `.xcstrings` Edit-tool hazard around ASCII double quotes.
- **`Konjugieren/Views/SettingsView.swift`** — entire file. The two batch items live in adjacent cards and one helper (`settingsCard`).
- **`Konjugieren/Models/AppIcon.swift`** — current AppIcon enum + `alternateIconName` mapping. New `previewAssetName` property gets added here for #7.
- **`Konjugieren/Utils/Settings.swift:118-125`** — `setAppIcon(_:)` and the `didSet` wiring; confirms the new thumbnail Buttons need no extra side-effect plumbing.

## Pre-flight findings (already verified)

- **Preview imagesets all exist** in `Konjugieren/Assets/Assets.xcassets`: `Hat.imageset`, `Bundestag.imageset`, `Pretzel.imageset`, `BratwurstBroetchen.imageset`. **Note the asymmetry:** `bratwurst` maps to `BratwurstBroetchen`, not `Bratwurst`. The new `AppIcon.previewAssetName` property must reflect that.
- **Icon-swap side effect already wired**: `Settings.appIcon.didSet` calls `setAppIcon(_:)` which calls `UIApplication.setAlternateIconName(icon.alternateIconName)`. Replacing the Picker with Buttons that mutate `settings.appIcon` is transparent — no additional `.onChange` modifier needed.
- **funButton() pattern**: `Modifiers.swift:23` defines `func funButton() -> some View { modifier(FunButton()) }`. The modifier is applied to a `Button`'s body. SwiftUI's `Button` accepts any View as label, so `Button { ... } label: { Label(text, systemImage: "trophy.fill") }.funButton()` will work — visual confirmation needed for icon tint and sizing.
- **Action card has UP TO 5 buttons**, two conditional:
  - View Leaderboard — conditional on `Current.gameCenter.isAuthenticated`.
  - Show Onboarding — always.
  - Play Game — always.
  - Delete Chat History — conditional on `Current.languageModelService.isAvailable && hasChatHistory`.
  - Rate or Review — always.

  The audit says "four"; in practice there can be 3, 4, or 5. The split-into-two-cards plan needs to handle the empty-card edge case (e.g., if Game Center isn't authenticated, the "Game Center" card becomes Play Game alone).

## Recommended sequence

1. **#7 first** — the higher-payoff visual change. Self-contained; replaces one card's contents. Independent of #8.
2. **#8 next** — touches the adjacent card. Two sub-options (a) Label icons and (b) split into two cards. Decide both with Josh before starting; (a) is verbatim-shippable, (b) requires layout judgment around empty-card states.
3. **Build, test, screenshot, audit-doc updates, surface for commit approval.**

If Josh wants to defer #8(b), ship #7 + #8(a) and note (b) as a follow-up. (a) and (b) are independent within #8 — (a) is a per-button modifier change, (b) is a structural card split.

## Per-item handoff notes

### #7 — App Icon thumbnail picker

The audit's snippet at `docs/ui-audit-2.md:417-438` gestures at the right shape but glosses over a few details. Concrete implementation plan:

**1. Add `previewAssetName` to `AppIcon`** (`AppIcon.swift`):

```swift
var previewAssetName: String {
  switch self {
  case .bratwurst:
    return "BratwurstBroetchen"
  case .bundestag:
    return "Bundestag"
  case .hat:
    return "Hat"
  case .pretzel:
    return "Pretzel"
  }
}
```

Per CLAUDE.md, alphabetize enum cases in switch (cases are already alphabetized in the enum declaration; mirror that order). Note: existing `localizedAppIcon` switch at `AppIcon.swift:9-20` is *not* in alphabetical order (bratwurst, hat, pretzel, bundestag) — that's a pre-existing inconsistency. Fix it in the same PR for free, or leave it (low-stakes; flag in the Resolution block either way).

**2. Replace the App Icon Picker** at `SettingsView.swift:102-114`. The audit's snippet's `LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 12)` works, but verify:

- **Selection ring color**: `Color.customYellow` (matches the German-flag system).
- **Thumbnail clipping**: `.clipShape(RoundedRectangle(cornerRadius: 14))` — match iOS's app-icon corner curve as closely as possible. iOS 26 actual rounded-rect-superellipse "squircle" has more curvature than `RoundedRectangle`; if the visual reads off, use `.continuousCornerRadius` or check `RoundedRectangle(cornerRadius: 14, style: .continuous)`.
- **Caption typography**: `.font(.caption2)` is fine; matches existing button-description text.
- **Tap target**: the whole VStack (image + caption) is the Button's label, so the entire pill is tappable.
- **Sensory feedback**: `.sensoryFeedback(.selection, trigger: settings.appIcon)` is net-new — no precedent for app-icon-switching haptic in the project. Reasonable.

**3. Accessibility:**

- The Image inside the Button's label should be `.accessibilityHidden(true)` (or use `Label(...)` which handles this) so VoiceOver doesn't double-announce. The Text caption already provides the spoken label.
- Each Button needs the selected state communicated. Add `.accessibilityValue(settings.appIcon == icon ? L.Accessibility.selected : "")` or use `.accessibilityAddTraits(.isSelected)` on the selected Button. **New localizable string** `Accessibility.selected` may be needed (`"Selected"` / `"Ausgewählt"`).

**4. Visual considerations:**

- iPhone 14 (smallest device, 390pt logical width) at `Layout.doubleDefaultSpacing × 2 = ~32pt` outer padding + card internal padding gives ~330pt for the LazyVGrid. With `GridItem(.adaptive(minimum: 72))`, that fits 4 across (72 × 4 = 288pt + 3 × ~12pt spacing = 324pt). Should look balanced as a 1×4 row at iPhone 14, possibly 2×2 if the grid wraps. Verify visually.
- iPad: the `.adaptive(minimum: 72)` will pack 8+ columns at iPad widths. Acceptable, but if the row stretches absurdly wide it's worth capping at 4 columns: `[GridItem(.adaptive(minimum: 72, maximum: 100))]` or a fixed `[GridItem(.flexible(), count: 4)]`.

### #8 — Action button differentiation

Two sub-options that compose:

**(a) Add SF Symbols via `Label`.** Verbatim per the audit's snippet at `docs/ui-audit-2.md:461-470`. Symbol mapping the audit recommends:

| Button | SF Symbol |
|---|---|
| View Leaderboard | `trophy.fill` |
| Show Onboarding | `questionmark.circle.fill` |
| Play Game | `gamecontroller.fill` |
| Rate or Review | `star.fill` |
| Delete Chat History | `trash` |

Apply per-button:

```swift
Button {
  Current.gameCenter.showLeaderboard()
  Current.analytics.signal(name: .tapViewLeaderboard)
} label: {
  Label(L.GameCenter.viewLeaderboard, systemImage: "trophy.fill")
}
.funButton()
.frame(maxWidth: .infinity)
.accessibilityHint(L.Accessibility.leaderboardHint)
```

`funButton()` already styles the Button's label container; Label inside should pick up the existing yellow-foreground tint. Visual check: SF Symbol color matches the Text label's color (both yellow). If the symbol reads too prominent, scale it down via `.imageScale(.small)` on the Label.

**Delete Chat History** is the destructive action. The audit suggests `.tint(.customRed)` and a confirmation dialog. Currently at `SettingsView.swift:160-173` it deletes immediately. Adding `.confirmationDialog` is additive:

```swift
@State private var showingDeleteChatHistoryConfirmation = false

Button {
  showingDeleteChatHistoryConfirmation = true
} label: {
  Label(L.Tutor.deleteChatHistory, systemImage: "trash")
}
.funButton()
.frame(maxWidth: .infinity)
.confirmationDialog(
  L.Tutor.deleteChatHistoryConfirmTitle,
  isPresented: $showingDeleteChatHistoryConfirmation,
  titleVisibility: .visible
) {
  Button(L.Tutor.deleteChatHistoryConfirmButton, role: .destructive) {
    TutorChatHistory.clear(getterSetter: Current.getterSetter)
    hasChatHistory = false
    Current.analytics.signal(name: .tapDeleteChatHistory)
  }
  Button(L.Common.cancel, role: .cancel) { }
}
```

Three new localized strings: `Tutor.deleteChatHistoryConfirmTitle`, `Tutor.deleteChatHistoryConfirmButton`, possibly `Common.cancel` (check if it already exists — iOS auto-localizes "Cancel" via `Button(role: .cancel)` if you pass `Text("Cancel")`, but explicit localization is safer).

**(b) Group thematically into two cards.** Two cards with explicit conditional handling:

```swift
// Game Center card — only renders if there's at least one button to show.
if Current.gameCenter.isAuthenticated || true {  // Play Game is always present
  settingsCard {
    if Current.gameCenter.isAuthenticated {
      // View Leaderboard button + description
    }
    // Play Game button + description
  }
}

// Help & feedback card — also always has at least one button (Show Onboarding, Rate or Review).
settingsCard {
  // Show Onboarding button + description
  if Current.languageModelService.isAvailable && hasChatHistory {
    // Delete Chat History button + description
  }
  // Rate or Review button + description
}
```

Edge cases:

- Game Center NOT authenticated → "Game Center" card has only Play Game. Visually OK; Play Game IS Game Center adjacent (a personal-best gameplay loop).
- Apple Intelligence unavailable / no chat history → "Help & feedback" card omits Delete Chat History. The card still has Show Onboarding + Rate or Review. Fine.

**Card labels**: do the new cards get explicit headings ("Game Center", "Help & feedback") or stay unlabeled like the other settingsCards in the file? **Decision needed.** Current settingsCards have section headings INSIDE (`settingSection(heading:...)`) but no card-level title. Adding card-level titles for these two would be a small new convention — visual choice, not a correctness issue. If yes, two new localized strings: `Settings.gameCenterCardHeading`, `Settings.helpAndFeedbackCardHeading`.

## Verification

Per the audit's "Verification" section and matching post-#13/#11 conventions:

1. **Build clean**: `"$IBV_SCRIPTS/build_app.sh"`. (Resolve `IBV_SCRIPTS` once per session per CLAUDE.md.)
2. **Tests stay green**: `"$IBV_SCRIPTS/run_tests.sh"`. Last known good: 122/122 in 17 suites. This batch is unlikely to add tests (view-layer changes, no new model API), so 122/122 holds.
3. **Visual screenshots** under `docs/screenshots/` (gitignored) — pre/post pairs:
   - **Pre-batch baseline**: refresh on current main before any code changes. Tap Settings → scroll to App Icon picker → screenshot.
   - **Post-#7**: same screen, showing the LazyVGrid of thumbnails with one selected (yellow ring).
   - **Post-#8**: scroll to actions; if (a) only, screenshot the action buttons with SF Symbols; if (a) + (b), screenshot both new cards in sequence.
4. **JSON integrity** if `Localizable.xcstrings` was edited:
   ```bash
   python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"
   ```
5. **Manual verification on simulator**:
   - Tap each thumbnail; confirm the app icon switches (visible after backgrounding the app and viewing the home screen, since `setAlternateIconName` updates the launcher icon — the in-app picker doesn't show the change directly).
   - Tap each action button; confirm each fires its action correctly (leaderboard sheet opens, onboarding shows, game launches, rate URL opens, chat history confirmation dialog appears).
   - VoiceOver pass: navigate the thumbnail grid and confirm each Button announces its localized name and selected state cleanly.

Apple-Intelligence caveat: the Delete Chat History button is gated on `Current.languageModelService.isAvailable`. On Intel-Mac hosts running iOS 26.3.1+, this gate fails silently (per CLAUDE.md). The button won't render. State this in the Resolution block so future-Josh doesn't wonder why the screenshot is missing the row.

## Updates to `docs/ui-audit-2.md` after completion

For each item that ships, match the convention used by earlier resolved sections (#1, #2, #3, #4, #5, #6, #9, #10, #11, #13, #15, #19, #20, #22, #A):

1. **Add `**Status:** Resolved YYYY-MM-DD. See "Resolution" block at the end of this section.`** immediately after the section's `### N.` heading.
2. **Add `**Resolution (YYYY-MM-DD):**`** block at the end of the section, including: file/line diff summary, side-effects worth recording, visual-confirmation screenshot paths, and any audit-snippet deviations (likely: the `BratwurstBroetchen` asset-name asymmetry, the empty-card edge cases, any decisions on card labels and sub-option (b)).
3. **Strikethrough** the implementation-order line. Find the Settings-polish line via:
   ```bash
   grep -n "Settings polish" docs/ui-audit-2.md
   ```
   It's currently `8. **#7 / #8** (Settings polish) — independent.` (around line 952 — line numbers drift as Resolution blocks are added; grep is the source of truth).

   If both items ship: `8. ~~**#7 / #8** (Settings polish) — independent.~~ *Done YYYY-MM-DD.*`

   If only #7 ships: leave the line, add a per-item tail.

The audit doc is load-bearing for future sessions. After the edits, a future Claude session reading it cold should immediately see which Settings items are done and where to find the resolution context.

## What's next after this batch

The remaining audit items are independent — choice-of-focus, not dependency:

- **VerbView polish**: #12 (metadata pill differentiation — leverages the German-flag color system semantically), #14 (long-infinitive wrap — small).
- **Small independents**: #16 (onboarding page-1 layout), #17 (Results score-card divider), #21 (Tutor icon emphasis).

The implementation-order list at `docs/ui-audit-2.md` (Implementation order section) names #14, #16, #17, #21 as small independents — any of them is a reasonable next batch or palate cleanser. #12 is design-judgment work and a good standalone session.

After this batch surfaces the choice to Josh, overwrite this `docs/ui-audit-2-next-session.md` with the next handoff or delete it if no batch is queued.

## Don't

- **Don't touch the Game or Dedication screens** (off-limits per Round One; see Constraints in the audit).
- **Don't ship #8(b) without surfacing card-label decisions to Josh.** The audit's "Card 1: Game Center / Card 2: Help & feedback" framing implies titled cards, but existing `settingsCard` instances have no card-level headings. Two new localized strings would be needed, plus a convention shift. Decide explicitly before implementing.
- **Don't replace `funButton()` for individual buttons.** The styling consistency across all action buttons matters; (a) adds Labels INSIDE existing `funButton()`-styled Buttons. Don't accidentally drop the modifier.
- **Don't expand scope.** While editing `SettingsView.swift`, the file has many other polishable surfaces (the gradientDivider, the section heading typography, the description Text styling). Resist. This batch is scoped to two items.
- **Don't drop accessibility traits or hints when restructuring.** Each existing button has `.accessibilityHint(...)` — preserve them when wrapping in Label or moving cards.
- **Don't commit without asking Josh.** Standard project rule (CLAUDE.md).
- **Delete this file** (`docs/ui-audit-2-next-session.md`) once the batch lands, OR overwrite it with a fresh handoff. The file is ephemeral.
