# Konjugieren UI Audit — Round Two

## Context for future sessions

This document is intended to be **self-contained**. A future Claude Code session — or a human — should be able to pick up any single suggestion and implement it without reading prior conversations or other audit files. Each suggestion includes its target file, problem statement, exact recommended SwiftUI code (where applicable), and dependencies on other items.

### How this audit was produced

A prior audit, `docs/ui-audit.md` (referred to below as "Round One"), was produced by applying the `ios-design-agent-skill` (an Anthropic-authored Frontend Design Skill ported to SwiftUI). Round One enumerated 24 suggestions across six screens. Commit `657bb4f` ("apply ios-design-agent-skill UI audit suggestions") implemented essentially every High and Medium suggestion from Round One.

This document, Round Two, was produced afterward by combining `ios-design-agent-skill` and `ios-build-verify`. The latter drove the running app on an iPhone 17 simulator (iOS 26.3), captured 13+ screenshots into `docs/screenshots/`, and let the audit reference real visual evidence rather than only source code. The post-657bb4f source for `QuizView`, `ResultsView`, `VerbView`, `SettingsView`, `OnboardingView`, `VerbBrowseView`, `FamilyDetailView`, `InfoView`, `InfoBrowseView`, `MainTabView`, `RichTextView`, `Modifiers`, and `Layout` was read in full as part of synthesis.

### What Round One delivered (preserve when implementing)

Future sessions should not re-suggest these — they are already in place:

- **Cards**: `Color(.secondarySystemBackground)` rounded-rectangle backgrounds wrap `ConjugationSectionView` (in `VerbView.swift`), Settings groups (in `SettingsView.swift`'s `settingsCard` helper), the Quiz active card (in `QuizView.swift`'s `quizContent`), the Results stats card (in `ResultsView.swift`), and the Tutor row (in `InfoBrowseView.swift`'s `TutorRowView`).
- **Typographic differentiation via SF Pro design axes**: VerbView title at `.fontDesign(.serif)`; conjugation section headings at `.subheadline.smallCaps().weight(.semibold).fontDesign(.serif)`; ResultsView score at `design: .rounded`; stats counters at `.monospacedDigit()`; verb-count banner in VerbBrowseView at `.font(.caption.smallCaps())`.
- **Motion / sensory feedback**: `.sensoryFeedback(.success/.error/.selection/.impact)` in QuizView, VerbBrowseView, OnboardingView. `.symbolEffect(.pulse.byLayer)` on the Quiz Start button. `.symbolEffect(.bounce, value:)` on each onboarding page's SF Symbol. `.contentTransition(.numericText())` animating the Results score from 0. `.scrollTransition` fading verb rows and parallax-scaling Info photos. Four-keyframe shake animation on incorrect quiz answer; scale + opacity check on correct.
- **Empty states / counts**: `ContentUnavailableView` in `VerbBrowseView.swift` for empty search; alternating row tints (3% yellow); `#N` frequency rank.
- **InfoView literary treatment**: serif `.largeTitle.bold()` title; `.lineSpacing(4)` in `BodyTextView`; reading-width constraint of 680pt via `.frame(maxWidth: 680)`; the German-flag tricolor decorative ornament (three small black/red/yellow circles) between title/photo and body.
- **Score color-coding**: green for >80%, yellow for 50–80%, red for <50% in `ResultsView.swift`.
- **Quit-to-toolbar**: Quiz's Quit button moved out of inline content into `.toolbar { ToolbarItem(placement: .cancellationAction) }`.
- **Accent bars**: 2pt yellow leading-edge accent on each `ConjugationSectionView` card.
- **Gradient dividers**: `LinearGradient(colors: [.clear, .customYellow.opacity(0.3), .clear])` 1pt rectangles between settings sections, replacing dot patterns.
- **Pill-shaped metadata**: family / auxiliary / frequency / prefix / ablaut metadata in VerbView wrapped in `Capsule` shapes with `Color.customYellow.opacity(0.08)` background.

### Constraints (do not violate)

- **System fonts only**. SF Pro and its design axes (`.serif`, `.rounded`, `.monospaced`). No custom font files.
- **iOS 17+ APIs**. Project targets iOS 26 (per `MainTabView`'s use of the modern `Tab(...)` DSL with the floating tab pill). All recommendations below use APIs available since iOS 17.
- **Swift 6 with default `@MainActor` isolation**. Pure-computation helpers must be marked `nonisolated` (see CLAUDE.md). Test code: `@MainActor` does not propagate to nested suites.
- **Game and Dedication screens are off-limits** to design changes (per Round One; preserved here).
- **No emojis in code unless preserving an existing emoji** that is part of the localized markup. Localizable rich-text markup uses specific emoji as bullet markers (see CLAUDE.md "Rich Text Markup in Localizable.xcstrings") — these are intentional and protected.
- **Accessibility**: every motion suggestion should respect `@Environment(\.accessibilityReduceMotion)`. The codebase has many `reduceMotion ? nil : someAnimation` examples to follow.
- **Dynamic Type**: prefer semantic font sizes (`.title3`, `.body`, `.caption`) with weight modifiers; the only fixed size in the post-657bb4f code is `48` for the Results score, which is justified as a focal-point exception.

### Color and design system in place

Defined in `Assets.xcassets`:

- `customYellow` — German-flag yellow. Semantic: regular conjugations, structural labels, accents, callouts.
- `customRed` — German-flag red. Semantic: ablaut (irregular vowel changes), error states, destructive actions.
- `customBackground` — pure black in dark mode, pure white in light. The flat canvas the entire app sits on.
- `customForeground` — readable text on `customBackground`.
- (System-derived) `Color(.secondarySystemBackground)` is the established card surface.

Spacing constants in `Utils/Layout.swift`:

```swift
static let defaultSpacing: CGFloat = 8.0
static let doubleDefaultSpacing: CGFloat = 16.0
static let tripleDefaultSpacing: CGFloat = 24.0
static let pronounColumnWidth: CGFloat = 30.0
static let verbGridMinimum: CGFloat = 220.0
static let showcaseCardGridMinimum: CGFloat = 340.0
```

Custom modifiers in `Utils/Modifiers.swift`:

- `subheadingLabel()` — `.title3.bold()` yellow + horizontal padding + isHeader trait.
- `headingLabel()` — `.title2.bold()` + isHeader trait.
- `funButton()` — `.foregroundStyle(.customYellow).buttonStyle(.bordered).tint(.customRed)`. The dominant button style throughout the app.
- `tableText()` — `.headline` yellow.
- `tableSubtext()` — `.subheadline` foreground.
- `germanPronunciation(forReal:)` — sets `\.locale` to the German `UttererLocale` so VoiceOver pronounces text in German.
- `englishPronunciation()` — same for English.
- `speakOnTap(_:)` — adds tap-to-speak with a 300ms 15%-opacity yellow flash (see `SpeakOnTap` private struct).

### Screenshots referenced

All under `docs/screenshots/`, captured 2026-05-05:

- `20260505-103643-tab1-verbs.png` — Verbs tab top.
- `20260505-103718-verb-detail-sein.png` — VerbView for `sein` (post-657bb4f, with serif title, pills, conjugation cards).
- `20260505-103736-verb-detail-sein-scrolled1.png` — `sein` scrolled into etymology.
- `20260505-103810-tab2-families.png` — Families tab list.
- `20260505-103934-family-detail-strong-real.png` — Strong family detail with ablaut groups.
- `20260505-105800-separable-detail.png` — Separable family detail. **Critical**: shows the `[?]` glyph rendering bug.
- `20260505-104019-tab3-quiz-start.png` and `20260505-105400-quiz-start.png` — Quiz idle state with vast empty space.
- `20260505-104035-tab3-quiz-active.png` and `20260505-105500-quiz-active.png` — Quiz active state with card.
- `20260505-104140-tab4-info.png` — Info tab list.
- `20260505-104299-info-history-detail.png` — InfoView for "A History of the German Verb System."
- `20260505-104412-tab5-settings.png` and `20260505-105300-after-dismiss.png` — Settings tab top.
- `20260505-104427-settings-scrolled1.png` — Settings middle (App Icon picker, action buttons).
- `20260505-104441-settings-scrolled2.png` — Settings bottom.
- `20260505-104459-onboarding-1.png` — Onboarding page 1.
- `20260505-105900-verbs-tab.png` — VerbView for `sein` showing bare etymology section (no card frame).

### Driving the simulator (for verification)

`ios-build-verify` is configured in `.claude/ios-build-verify.config.sh` (gitignored). Operations used in this audit:

```bash
# Build (pipes xcodebuild through xcbeautify; tees raw to build.log).
bash ~/.claude/plugins/cache/ios-build-verify/.../scripts/build_app.sh

# Launch — polls FIRST_SCREEN_ID=verb_browse_anchor and auto-taps Skip on onboarding.
bash ~/.claude/plugins/cache/ios-build-verify/.../scripts/launch_app.sh

# Verify operations: tap_id / tap_label / tap_xy / tap_tab / screenshot / describe-ui.
# axe is the underlying tool; run `axe describe-ui --udid <UDID>` to see the AXTree.
```

Tab pill coords (calibrated 5-tab; raw points): `verbs=63,818  families=132,818  quiz=201,818  info=269,818  settings=339,818`. iOS 26 SwiftUI `TabView(.page)` is hostile to programmatic swipe — use direct coordinate taps for tab switching, and accept that paging through `OnboardingView` programmatically is unreliable.

App-specific: a custom "Enjoying Konjugieren?" review prompt can fire on launch and gate the AXTree if `promptActionCount` has accumulated. Recovery: tap "Not Now" once, or `xcrun simctl uninstall <UDID> biz.joshadams.Konjugieren`.

---

## Overall Assessment

### Strengths to preserve

- The card pattern is consistent across the app's most-used screens.
- The German-flag color system has earned its semantic place: yellow = regular/structural; red = ablaut/error; black/white = canvas/text.
- Typography uses SF Pro design axes (`.serif`, `.rounded`, `.monospaced`) appropriately, giving content types visible distinction without custom fonts.
- Motion is layered: haptics + symbol effects + transitions + scroll-transitions, all gated on `accessibilityReduceMotion`.
- VoiceOver / accessibility traits are thorough — `.isHeader`, `.isButton`, `accessibilityLabel`, `germanPronunciation` / `englishPronunciation` modifiers throughout.

### Areas for growth (this audit's focus)

1. **Card-treatment inconsistency**: `Color(.secondarySystemBackground)` appears at full opacity in `QuizView` but `.opacity(0.5)` in `VerbView` / `SettingsView` / `ResultsView`. Two visual languages for "card" within one app.
2. **Cards without elevation**: no shadows, no borders. On a pure-black background, fill-only cards have no depth dimension.
3. **One real rendering bug**: `[?]` glyph fallback on inline emoji in long-form `BrowseableFamily` descriptions.
4. **Quiz screen still leaves ~60% of vertical space empty** below the question card.
5. **VerbView's etymology and example-sentence sections are bare** while the conjugation sections above them are carded — visual rhythm breaks halfway down.
6. **SettingsView action-button card is undifferentiated** — four identical `funButton` calls stacked together.

---

## Critical (visible bug)

### 1. FamilyDetailView: Missing emoji glyphs in long descriptions

**Status:** Resolved 2026-05-05. See "Resolution" block at the end of this section.

**Screen:** `Konjugieren/Views/FamilyDetailView.swift` rendered via `RichTextView` from a localized string in `Konjugieren/Assets/Localizable.xcstrings`.
**Visual proof:** `docs/screenshots/20260505-105800-separable-detail.png`. Two `[?]` boxes appear in the prose:

> "...In the table that follows, **[?]** precedes the English meaning of a German prefix; **[?]** precedes the Proto-Indo-European root of that prefix and the root's meaning..."

These should be `[England flag emoji]` and `[horse emoji]`. They render correctly *as bullets* in `PrefixHeaderView` (`FamilyDetailView.swift:93,100`) but fail inline within the long description. The rendering divergence between the two locations within a single screen is the diagnostic clue.

**Likely cause:** the England regional flag is a tag sequence (`U+1F3F4 U+E0067 U+E0062 U+E0065 U+E006E U+E0067 U+E007F`). Even when the codepoint sequence is identical in both locations, font-fallback can resolve differently inline vs. as a standalone glyph at a larger size. The horse emoji `U+1F40E` is widely supported but co-occurs in the same prose; if the issue is font-substitution scoped to an `AttributedString` segment built by `BodyTextView.buildAttributedString()` (in `Konjugieren/Views/RichTextView.swift:36-80`), both could be affected.

**Diagnosis (run before fixing):**

```bash
python3 -c "
import json
data = json.load(open('Konjugieren/Assets/Localizable.xcstrings'))
for key, entry in data.get('strings', {}).items():
    en = entry.get('localizations', {}).get('en', {}).get('stringUnit', {}).get('value', '')
    if '\U0001F3F4' in en or '\U0001F40E' in en:
        print(key)
        print('  ASCII codepoints:', [hex(ord(c)) for c in en if ord(c) > 0x7F][:30])
"
```

This identifies which keys carry the affected emoji and exposes the actual codepoint sequence saved.

**Fix candidates (pick one):**

a. **Replace the tag sequence with a regional-indicator pair.** `🇬🇧` (`U+1F1EC U+1F1E7` — UK regional indicators) is universally supported and reads as "British/English":

```bash
python3 -c "
import json, pathlib
p = pathlib.Path('Konjugieren/Assets/Localizable.xcstrings')
t = p.read_text()
t = t.replace('\U0001F3F4\U000E0067\U000E0062\U000E0065\U000E006E\U000E0067\U000E007F', '\U0001F1EC\U0001F1E7')
p.write_text(t)
"
```

Note: this also changes the `PrefixHeaderView` bullet rendering. Decide whether bullet + inline references should match.

b. **Render the inline emoji via `Image(systemName:)` instead.** Replace the inline emoji bullets in the prose with SF Symbols (`globe.europe.africa.fill` for English-meaning, `figure.equestrian.sports` or a custom horse if available). Requires editing `Localizable.xcstrings` to inject markdown image references and updating `RichTextView` parsing in `Utils/StringExtensions.swift` to handle them. Higher implementation cost; cleanest result.

c. **Localize the inline references away.** Restructure the prose so it does not reference the bullet emoji inline at all — describe the table format declaratively ("English meanings appear with their Proto-Indo-European roots below"). Lowest implementation cost; loses the visual self-reference.

**Recommended:** option (a). One-line replacement, universal support, minimal disruption.

**Validation:**

```bash
python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"
bash ~/.claude/plugins/cache/ios-build-verify/.../scripts/build_app.sh
bash ~/.claude/plugins/cache/ios-build-verify/.../scripts/launch_app.sh
# Tap Families tab, tap Separable, scroll to the prose paragraph, screenshot.
```

**Resolution (2026-05-05):**

The structural shape of approach (b) shipped — render the inline emoji as `Image` views via SwiftUI Text-Image interpolation rather than as text characters subject to font fallback — but with the actual emoji glyphs preserved as static PNG assets, not substituted with SF Symbols. Josh's intent was to keep the visual identity of the original emoji, and the SF Symbol substitution that approach (b) literally proposed would have lost that.

The investigation surfaced a deeper bug than the audit's "AttributedString font-substitution" hypothesis. On iOS 26.3, no SwiftUI or UIKit text-rendering path produces the correct emoji glyphs for the affected codepoints. `Text(AttributedString)`, `Text + Text` composition, `NSAttributedString.draw(at:)` into a `UIGraphicsImageRenderer` context, `UILabel.layer.render(in:)` offscreen, SwiftUI's `ImageRenderer`, and `UITextView` via `UIViewRepresentable` were all tested. Each one produces `[?]` tofu glyphs.

Critically, the audit's premise that `PrefixHeaderView`'s standalone `Text("🐎")` was the working pattern was wrong on this iOS version. Those bullets are also broken; the audit's screenshot captured only the prose and missed the bullets below the fold. `PrefixHeaderView` was updated to use the same image assets for visual consistency.

The shipped fix renders the affected emoji on macOS (where `NSAttributedString` → `NSImage` does resolve them correctly), crops each PNG to its alpha bounding box so SwiftUI's baseline alignment puts the glyph at the text baseline, and ships them in `Assets.xcassets`. A new `^...^` markup separator in `StringExtensions.swift` joins the existing `~bold~`, `%link%`, `$conjugation$`, and `` `subheading` `` markers; affected occurrences in `Localizable.xcstrings` are wrapped (95 England-flag, 17 horse, across `FamilyDetail.{separable,inseparable}Long` and all `Info.*Text` keys). `EmojiAsset` in `RichTextView.swift` maps wrapped content to asset names. `BodyTextView` and `InfoBrowseView`'s preview path render the lookup as `Text("\(Image(name).renderingMode(.original))")`.

Affected emoji and asset names:

| Codepoints | Glyph | Asset name |
|---|---|---|
| `U+1F3F4 U+E0067 U+E0062 U+E0065 U+E006E U+E0067 U+E007F` | 🏴󠁧󠁢󠁥󠁮󠁧󠁿 (England flag tag sequence) | `EmojiEnglandFlag` |
| `U+1F40E` | 🐎 (horse) | `EmojiHorse` |

Visual confirmation: `docs/screenshots/20260505-181006-separable-cropped-baseline.png` shows the prose rendering with the actual emoji glyphs inline at baseline alignment.

Full architecture and instructions for adding new affected emoji: `docs/emoji-assets.md`. Render script: `scripts/render_emoji.swift`.

---

## High Priority (consistency + completeness)

### 2. Cross-cutting: Unify card opacity

**Files:**
- `Konjugieren/Views/QuizView.swift:223` — full opacity: `Color(.secondarySystemBackground)`.
- `Konjugieren/Views/VerbView.swift:311` — half opacity: `Color(.secondarySystemBackground).opacity(0.5)`.
- `Konjugieren/Views/SettingsView.swift:222` — half opacity.
- `Konjugieren/Views/ResultsView.swift:50` — half opacity.

**Problem:** Two card languages co-exist within the same app. Quiz cards look heavier than Verb / Settings / Results cards.

**Recommended fix:** standardize on full opacity. Half-opacity cards on Konjugieren's pure-black background barely register visually. Update VerbView, SettingsView, ResultsView to drop `.opacity(0.5)`.

**Foundation for #19** below — if pursuing the named-asset cleanup, do that first and adopt the asset everywhere in one pass.

**Independent of:** all other suggestions.

### 3. Cross-cutting: Add subtle elevation to cards

**Files:** every site listed in #2, plus `InfoBrowseView.swift:174` (TutorRowView background) and `FamilyDetailView.swift` (after #11 below).

**Problem:** Cards exist as fill-only rectangles with no shadow, no border, no depth. The fifth design pillar (atmospheric depth) is the least developed in the app.

**Recommended fix:** the standard `.shadow(color: .black.opacity(0.25), radius: 8, y: 2)` is invisible against a pure-black background (already-black has nowhere darker to go). Use a thin warm rim instead:

```swift
.overlay(
  RoundedRectangle(cornerRadius: 12)
    .strokeBorder(Color.customYellow.opacity(0.08), lineWidth: 1)
)
```

This gives cards a subtle warm edge that aligns with the German-flag color system. Apply at every card site after #2 lands.

**Light-mode consideration:** `customBackground` is white in light mode. A 0.08-opacity yellow stroke on white is faint but visible. If light-mode contrast becomes a concern, switch to `Color(.separator)` for the stroke color, which adapts to appearance.

**Depends on:** #2 (so the visual is consistent).

### 4. Quiz: Reclaim the empty bottom 60%

**Screen:** `Konjugieren/Views/QuizView.swift:88-232` (the `quizContent` `@ViewBuilder`).

**Visual proof:** `docs/screenshots/20260505-105500-quiz-active.png`. The card occupies the top quarter; the rest is black up to the tab pill.

**Problem:** During the most-active screen in the app, ~60% of the canvas is unused. The user's eyes have nowhere to settle while typing. The Round One audit added the card framing; this is the natural next step.

**Recommended fix (any one of these is independently valuable; layered would be even better):**

a. **Visualize the question queue.** Below the input card, render 30 small dot markers — one per quiz question — colored by state (filled `customYellow` for correct, filled `customRed` for incorrect, dim gray for upcoming). The current question's dot pulses. Roughly:

```swift
HStack(spacing: 4) {
  ForEach(0..<Quiz.questionCount, id: \.self) { i in
    let state = quiz.stateForQuestion(at: i)  // requires new Quiz API
    Circle()
      .fill(state.dotColor)
      .frame(width: 8, height: 8)
      .scaleEffect(i == quiz.currentIndex ? 1.4 : 1.0)
      .symbolEffect(.pulse, options: i == quiz.currentIndex ? .repeating : .nonRepeating, isActive: i == quiz.currentIndex)
  }
}
.padding(.horizontal, Layout.doubleDefaultSpacing)
.padding(.top, Layout.defaultSpacing)
```

This converts dead space into glanceable progress and per-question feedback.

b. **Move the "last answer" card out of the active card.** Currently `QuizView.swift:147-170` renders the previous question's review (last-incorrect, correct-answer, ErrorExplainerView) inside the same card alongside the input field. Splitting them into two stacked cards reduces the active card's density and gives the empty space below something to hold.

c. **Show a glanceable conjugation reference card.** Once the user submits any answer to any question, show a third card below with a couple of related conjugations of the current verb (e.g., `Perfektpartizip` and `Präteritum 3sg`) — reinforces learning.

**Recommended:** start with (a) since it has the highest ratio of visual payoff to implementation cost. The dot row also doubles as a Round One progress-bar replacement (see #5).

**Independent of:** all other suggestions.

### 5. Quiz: Progress bar visibility

**Screen:** `Konjugieren/Views/QuizView.swift:91-92`.

```swift
ProgressView(value: Double(quiz.currentIndex), total: Double(Quiz.questionCount))
  .tint(.customYellow)
```

**Problem:** A thin yellow line on a black background is barely visible (see `20260505-105500-quiz-active.png` — the bar is a single-pixel-feeling line at the very top of the card).

**Recommended fix:** add a dim track and increase weight:

```swift
ProgressView(value: Double(quiz.currentIndex), total: Double(Quiz.questionCount))
  .progressViewStyle(.linear)
  .tint(.customYellow)
  .background(Color.customYellow.opacity(0.15))
  .frame(height: 6)
  .clipShape(Capsule())
```

**Alternative:** if implementing #4(a) above, drop the progress bar entirely — the dot row replaces it with richer information.

**Depends on:** none. Independent of #4 unless the dot-row replacement is chosen, in which case skip this.

### 6. VerbView: Wrap etymology and example-sentence sections in cards

**Screen:** `Konjugieren/Views/VerbView.swift:115-152`.

**Visual proof:** `docs/screenshots/20260505-105900-verbs-tab.png` shows etymology body text on the flat canvas with no card frame, immediately below carded conjugation sections.

**Problem:** Within a single screen, conjugation sections get the full `ConjugationSectionView` treatment (card + accent bar + small-caps serif heading at `VerbView.swift:281-319`), but etymology and example sentences below them are visually unframed. The screen's rhythm breaks halfway down.

**Recommended fix:** apply the same wrapper to both sections. Concretely, in `VerbView.swift:115-126` and `:128-152`:

```swift
if let etymologyText = Etymology.text(for: verb.infinitiv) {
  Divider()
  VStack(alignment: .leading, spacing: 8) {
    Text(L.VerbView.etymologyHeading)
      .font(.subheadline.smallCaps().weight(.semibold))
      .fontDesign(.serif)
      .foregroundStyle(.primary)
      .accessibilityAddTraits(.isHeader)
      .foregroundStyle(.customYellow)
    RichTextView(blocks: etymologyText.richTextBlocks)
  }
  .padding()
  .background(Color(.secondarySystemBackground))   // or via #2's named asset
  .clipShape(RoundedRectangle(cornerRadius: 12))
  .overlay(alignment: .leading) {
    Rectangle()
      .fill(.customYellow.opacity(0.3))
      .frame(width: 2)
      .clipShape(RoundedRectangle(cornerRadius: 1))
  }
  .padding(.horizontal)
}
```

Same wrapper for the example-sentences section. Note the heading style change to match conjugation section headings (`.subheadline.smallCaps().weight(.semibold).fontDesign(.serif)`) — this also unifies typography across sections within a single VerbView.

**Depends on:** #2 cleanup is recommended first so the same asset name is used everywhere. Independent if shipping immediately at full opacity.

### 7. Settings: App Icon picker — replace text segments with previews

**Screen:** `Konjugieren/Views/SettingsView.swift:103-114`.

**Visual proof:** `docs/screenshots/20260505-104427-settings-scrolled1.png`. Four-segment `.segmented` `Picker` with text labels Bratwurst / Bundestag / Hat / Pretzel — labels are very tight at iPhone width.

**Problem:** This is the only setting where the visual *is* the choice. Showing text labels for icon variants forces the user to imagine the result. The cramped layout also makes the picker harder to scan than the surrounding 2-3-segment pickers.

**Recommended fix:** replace the segmented `Picker` with a `LazyVGrid` of selectable thumbnails. Requires preview assets for each AppIcon variant — which the project already has (`AppIcon.swift` lists `bratwurst`, `bundestag`, `hat`, `pretzel`; their primary icons are in `Assets.xcassets`).

```swift
LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 12) {
  ForEach(AppIcon.allCases, id: \.self) { icon in
    Button {
      settings.appIcon = icon
    } label: {
      VStack(spacing: 4) {
        Image(icon.previewAssetName)   // requires adding `previewAssetName` to AppIcon
          .resizable()
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: 14))
          .overlay(
            RoundedRectangle(cornerRadius: 14)
              .strokeBorder(settings.appIcon == icon ? Color.customYellow : Color.clear, lineWidth: 3)
          )
        Text(icon.localizedAppIcon).font(.caption2)
      }
    }
    .buttonStyle(.plain)
  }
}
.sensoryFeedback(.selection, trigger: settings.appIcon)
```

**`AppIcon.previewAssetName`** would be a new computed property mapping each enum case to its preview asset name. Verify the assets exist before implementing; if not, this becomes higher-cost.

**Depends on:** existence of preview asset images. Verify with:

```bash
ls Konjugieren/Assets/Assets.xcassets/AppIcon.appiconset
ls Konjugieren/Assets/Assets.xcassets | grep -i icon
```

### 8. Settings: Differentiate the four action buttons

**Screen:** `Konjugieren/Views/SettingsView.swift:116-189`.

**Visual proof:** `docs/screenshots/20260505-104427-settings-scrolled1.png`. Four buttons in one card: View Leaderboard (when GameCenter authenticated), Show Onboarding, Play Game, Rate or Review. All use `funButton()` (yellow text + customRed bordered tint). All look identical.

**Problem:** Four "primary" actions stacked together with no visual differentiation. Users have to read every label every time.

**Recommended fix (combined approach):**

a. **Add a leading SF Symbol to each button via `Label`:**

```swift
Button {
  Current.gameCenter.showLeaderboard()
  Current.analytics.signal(name: .tapViewLeaderboard)
} label: {
  Label(L.GameCenter.viewLeaderboard, systemImage: "trophy.fill")
}
.funButton()
.frame(maxWidth: .infinity)
```

Suggested symbol mapping:
- View Leaderboard → `trophy.fill`
- Show Onboarding → `questionmark.circle.fill`
- Play Game → `gamecontroller.fill`
- Rate or Review → `star.fill`
- Delete Chat History → `trash` (this one already implies destructive; consider `.tint(.customRed)` and confirmation dialog if not present)

b. **Group thematically into two cards** — split the single action card at `SettingsView.swift:116-189` into:
- Card 1: "Game Center" — View Leaderboard (when authenticated), Play Game.
- Card 2: "Help & feedback" — Show Onboarding, Delete Chat History (when applicable), Rate or Review.

Two cards aligns the action group with the structural card pattern of the rest of `SettingsView`.

**Independent of:** all other suggestions, though combines well with #7's iconography pattern.

---

## Medium Priority (polish)

### 9. Cross-cutting: Sensory feedback on tab change

**Screen:** `Konjugieren/Views/MainTabView.swift:9-31`.

**Problem:** No haptic when switching tabs. The rest of the app generously uses `.sensoryFeedback`; the root navigation surface should too.

**Fix:**

```swift
TabView(selection: $world.selectedTab) {
  // existing Tab(...) declarations
}
.tint(.customRed)
.sensoryFeedback(.selection, trigger: world.selectedTab)
```

One line. Independent of all other suggestions.

### 10. Quiz: Reconsider "Conjgroup:" label

**Screen:** `Konjugieren/Views/QuizView.swift:116`. Renders `L.Quiz.conjugationgroup` from `Localizable.xcstrings`.

**Visual proof:** `docs/screenshots/20260505-105500-quiz-active.png` shows "Conjgroup: Imperativ".

**Problem:** "Conjgroup" reads awkwardly — half-abbreviated word coined just for this UI. The app otherwise uses "conjugationgroup" as the canonical English term (per CLAUDE.md "Terminology" section).

**Fix candidates:**

a. **Expand to the full word.** "Conjugationgroup: Imperativ" wraps cleanly on iPhone width. Edit the `Quiz.conjugationgroup` value in `Localizable.xcstrings`.

b. **Replace label with an icon.** Drop the prefix label entirely and lead with an SF Symbol:

```swift
HStack(alignment: .top, spacing: 4) {
  Image(systemName: "textformat.abc")
    .foregroundStyle(.customYellow)
  Text(verbatim: question.displayName(lang: settings.conjugationgroupLang))
    .foregroundStyle(.customForeground)
    .germanPronunciation(forReal: settings.conjugationgroupLang == .german)
}
```

Ditto for the `Pronoun:` line at `QuizView.swift:104-113` — both could use SF Symbols (`person` for pronoun, `textformat.abc` for conjugation group).

**Recommended:** (a) is the lowest-cost fix; (b) is the higher-design-payoff fix.

### 11. FamilyDetailView: Wrap long description in a card

**Screen:** `Konjugieren/Views/FamilyDetailView.swift:31-32`.

**Problem:** The long-form `RichTextView` description at the top of every family detail sits naked on the black background between the centered title and the verb list. Cards everywhere else in the app; not here.

**Fix:** apply the same wrapper as #6. Requires deciding whether the `RichTextView` should also have a 2pt accent bar (consistency argues yes; restraint argues no since family-detail prose is already framed as the page's focal content).

Recommended: card without accent bar (the `BrowseableFamily.systemImageName` icon at the top is the focal element).

### 12. VerbView: Differentiate metadata pills

**Screen:** `Konjugieren/Views/VerbView.swift:53-97`, `VerbView.swift:200-206` (`metadataPill` helper).

**Problem:** Family pill, Auxiliary pill, Frequency pill, Separable / Inseparable pill, Ablaut pill — all use identical `Color.customYellow.opacity(0.08)` background. Same color = same meaning, but these mean different things. The German-flag color system already encodes meaning elsewhere (yellow = regular, red = ablaut); the metadata pills are not exploiting it.

**Fix:**

```swift
// Generalize metadataPill to accept a tint
private func metadataPill<Content: View>(tint: Color = .customYellow, @ViewBuilder content: () -> Content) -> some View {
  content()
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(tint.opacity(0.08))
    .clipShape(Capsule())
}

// Apply per-pill semantics:
metadataPill(tint: .customYellow) { /* family */ }
metadataPill(tint: .customRed) { /* auxiliary — controls Perfekt construction */ }
metadataPill(tint: .customYellow) { /* frequency rank */ }
metadataPill(tint: .customRed) { /* separable / inseparable — affects sentence-level structure */ }
metadataPill(tint: .customYellow) { /* ablaut group — keep yellow but add a thin yellow border via .overlay(Capsule().strokeBorder(.customYellow.opacity(0.3))) */ }
```

The choice is which pills get red. Auxiliary and prefix-affixation are the most "structural" — both affect sentence-level construction beyond the verb form itself. Frequency and family are descriptive metadata. Ablaut group is a visual exception worth marking.

**Independent of:** all other suggestions.

### 13. InfoView: Subheading visual treatment

**Screen:** `Konjugieren/Views/RichTextView.swift:13-18` (the `.subheading` case in the body builder).

**Problem:** Subheadings (backtick-delimited in the `Localizable.xcstrings` markup, parsed by `Utils/StringExtensions.swift`) render as `.headline` yellow centered. They blend with body text size-wise and look generic.

**Fix:**

```swift
case .subheading(let text):
  HStack(alignment: .firstTextBaseline, spacing: 8) {
    Circle()
      .fill(.customRed)
      .frame(width: 4, height: 4)
    Text(text)
      .font(.title3.bold())
      .fontDesign(.serif)
      .foregroundStyle(.customYellow)
      .accessibilityAddTraits(.isHeader)
  }
  .padding(.top, 8)
  .frame(maxWidth: .infinity, alignment: .leading)
```

Three changes: serif design (matches article title), leading alignment (replaces center), small red dot (echoes the German-flag tricolor ornament between title and body).

**Caveat:** changing `RichTextView`'s subheading rendering affects every place rich-text is rendered — InfoView (article body), FamilyDetailView (long descriptions), OnboardingInfoSheet (the "What is a conjugationgroup?" sheet body), VerbView (etymology if #6 lands and uses RichTextView). All currently render subheadings the same way; the visual unification is desirable.

### 14. VerbView: Long infinitives wrap rather than scale-down

**Screen:** `Konjugieren/Views/VerbView.swift:41-42`.

```swift
.minimumScaleFactor(0.5)
.lineLimit(1)
```

**Problem:** Long verbs like `auseinandersetzen` shrink to fit one line at half-size, looking visually weak compared to short verbs like `sein` rendered at full `.largeTitle`.

**Fix:** drop `.lineLimit(1)`. Optionally drop `.minimumScaleFactor(0.5)` too. The serif design absorbs multi-line titles gracefully (article-style); a long verb on two lines reads better than a tiny verb on one.

```swift
Text(verb.infinitiv)
  .font(.largeTitle)
  .fontWeight(.bold)
  .fontDesign(.serif)
  .accessibilityAddTraits(UserLocale.isGerman ? .isHeader : [])
  .germanPronunciation()
  .speakOnTap(verb.infinitiv)
```

**Verify:** test with `auseinandersetzen`, `zusammenarbeiten`, and other long verbs that the title still looks reasonable on the smallest supported device width (iPhone SE if still supported, otherwise iPhone 15 base).

### 15. SettingsView: Audio Feedback inactive segment contrast

**Screen:** `Konjugieren/Views/SettingsView.swift:93-99`.

**Visual proof:** `docs/screenshots/20260505-105300-after-dismiss.png`. The "Disable" segment text (when "Enable" is active) is barely readable against the segmented picker's dark inactive background.

**Problem:** The host card currently uses `Color(.secondarySystemBackground).opacity(0.5)`. On a black canvas with a half-strength card, the segmented picker's inactive background blends with the card and the inactive segment text loses contrast.

**Fix:** the cleanest path is to address #2 first (drop the `.opacity(0.5)` everywhere). Card-at-full-opacity gives the segmented picker enough background contrast to make inactive segments legible. If #2 is not adopted, raise this card's specific opacity to 0.7 or 0.8 as a localized fix.

**Depends on:** #2 (resolves automatically) or independent localized fix.

### 16. OnboardingView: Reclaim empty space on page 1

**Screen:** `Konjugieren/Views/OnboardingView.swift:188-231` (`OnboardingPageView.body`).

**Visual proof:** `docs/screenshots/20260505-104459-onboarding-1.png`. The mug icon + title + body + button content occupies the bottom half. Top ~1100pt is pure black on a tall iPhone.

**Problem:** The page reads bottom-heavy because the `Spacer()` at line 189 vertically centers content, and content total height is small relative to a tall iPhone screen.

**Fix candidates:**

a. **Reduce the leading `Spacer()` to a fixed top padding:**

```swift
var body: some View {
  VStack(spacing: Layout.doubleDefaultSpacing) {
    Spacer()
      .frame(maxHeight: 100)   // was: unbounded Spacer()
    Image(systemName: symbolName)
      // ... rest unchanged
  }
}
```

This anchors content roughly 1/3 down the page rather than centered.

b. **Add a decorative gradient in the upper canvas:**

```swift
.background(alignment: .top) {
  LinearGradient(
    colors: [.customYellow.opacity(0.08), .clear],
    startPoint: .top,
    endPoint: .center
  )
  .frame(height: 300)
  .allowsHitTesting(false)
  .accessibilityHidden(true)
}
```

Adds a subtle warm glow to the upper region without disturbing layout.

**Recommended:** (a) for layout improvement; (b) optionally on top.

### 17. ResultsView: Score-card / list divider

**Screen:** `Konjugieren/Views/ResultsView.swift:65-72`.

**Problem:** The score card and the list of per-question results sit directly adjacent with no visual transition. The eye has nothing to mark "summary above; per-item below."

**Fix:** insert the gradient divider used in `SettingsView`. Lift it into a shared modifier first:

```swift
// In Utils/Modifiers.swift, add:
struct GradientDivider: View {
  var color: Color = .customYellow

  var body: some View {
    Rectangle()
      .fill(
        LinearGradient(
          colors: [.clear, color.opacity(0.3), .clear],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .frame(height: 1)
  }
}

// In ResultsView.swift between the score card and the List:
GradientDivider()
  .padding(.horizontal, Layout.doubleDefaultSpacing)
  .padding(.top, Layout.defaultSpacing)
```

Dedupe with `SettingsView`'s `gradientDivider` private computed property.

---

## Low Priority (polish pass)

### 18. VerbBrowseView: Sort animation preserves position vs. scroll-to-top

**Screen:** `Konjugieren/Views/VerbBrowseView.swift:73-80`.

The current behavior animates the list and scrolls to the first verb on sort change. If a user has scrolled deep, they lose position.

**This is a tradeoff, not a bug.** Frequency and alphabetical sort have different semantic meaning, so a top-scroll on order change is defensible. Worth a usability note but no fix recommended without user feedback.

### 19. Cross-cutting: Define `customCardBackground` named asset

Many surfaces use `Color(.secondarySystemBackground).opacity(0.5)` (or full). Defining a named color asset (`customCardBackground` and optionally `customCardBackgroundSubtle`) gives a single source of truth and lets you tune card opacity in one place. Foundation for #2.

Implementation:

1. Add color asset in `Assets.xcassets` named `customCardBackground`. Set base color to `Color(.secondarySystemBackground)` equivalent (e.g., `#1C1C1E` dark / `#F2F2F7` light) or directly to that semantic color.
2. Replace every site listed in #2 with `Color.customCardBackground`.

### 20. Cross-cutting: Define `customCardBorder`

Same pattern: a single named color for the subtle yellow-tinted card rim if #3's stroke approach is adopted. Color value: `customYellow` at 0.08 opacity baked in.

### 21. InfoBrowseView: Distinct iconography for Tutor row

**Screen:** `Konjugieren/Views/InfoBrowseView.swift:167`.

The Tutor row uses `brain.head.profile.fill` at `.title` size with yellow tint. The yellow card-tint background helps differentiate, but the icon weight could too — Tutor is the most novel feature in the app and can afford a moment of life.

**Fix:**

```swift
Image(systemName: "brain.head.profile.fill")
  .font(.largeTitle)                                    // bumped from .title
  .foregroundStyle(.customYellow)
  .symbolEffect(.pulse, options: .repeating)
  .accessibilityHidden(true)
```

Respects `accessibilityReduceMotion` automatically (symbol effects honor this preference).

### 22. QuizView: Speak-on-tap for the verb infinitive

**Screen:** `Konjugieren/Views/QuizView.swift:94-97`.

The verb infinitive `mitteilen` is shown but not tappable for pronunciation. Elsewhere in the app (`VerbView.swift:46`), every verb gets `.speakOnTap()`. Reinforces phonetic learning during quiz; consistent.

**Fix:**

```swift
Text(verbatim: question.verb.infinitiv)
  .font(.title.bold())
  .foregroundStyle(.customForeground)
  .germanPronunciation()
  .speakOnTap(question.verb.infinitiv)
```

### 23. Cross-cutting: Material backgrounds for the floating tab pill

iOS 26's floating tab pill uses a system material. Konjugieren's `customRed` `.tint` works but the pill against the all-black canvas looks slightly clinical. A custom `UITabBarAppearance` with a tinted `backgroundEffect` could knit the pill into the German-flag system more tightly. **Lowest priority** — likely leave alone.

### 24. SettingsView: Section-header divider variety

`gradientDivider` is used identically throughout `SettingsView`. Varying divider color subtly per card (yellow in Display, red in Quiz, neutral gray in Actions) is bordering on over-design. Listed for completeness; not recommended.

---

## Cross-Cutting Design System Additions

### A. Card-elevation modifier suite

Instead of every site re-deciding card opacity, shadow, and border, ship one set of view modifiers in `Utils/Modifiers.swift`:

```swift
extension View {
  func konjCard() -> some View {
    self
      .padding()
      .background(Color.customCardBackground)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .strokeBorder(Color.customCardBorder, lineWidth: 1)
      )
  }

  func konjCardWithAccentBar(_ color: Color = .customYellow) -> some View {
    self
      .konjCard()
      .overlay(alignment: .leading) {
        Rectangle()
          .fill(color.opacity(0.3))
          .frame(width: 2)
          .clipShape(RoundedRectangle(cornerRadius: 1))
      }
  }
}
```

Collapses the inconsistencies (#2, #3) and makes shadow / border decisions globally tunable.

**When this lands:** implement #2 and #3 by adopting `konjCard()` everywhere. Convert `ConjugationSectionView`'s ad-hoc card setup to `konjCardWithAccentBar()`.

### B. Color semantics documentation

Capture in `CLAUDE.md` (under a new "Design system" section) or `docs/colors.md`:

- `customYellow` = regular conjugations, structural labels, accents, callouts.
- `customRed` = ablaut (irregular vowel changes), error states, destructive actions.
- `customBackground` = canvas (black dark / white light).
- `customForeground` = readable text on canvas.
- `customCardBackground` (proposed, #19) = surface for grouped content.
- `customCardBorder` (proposed, #20) = subtle warm rim for cards.

### C. Treat emoji in Localizable.xcstrings as a fragility

Specifically regional flag tag sequences. Pin them to safer alternatives (Unicode regional-indicator pairs like `\U0001F1EC\U0001F1E7` for UK) or render via `Image(systemName:)` baseline-aligned in `Text` to avoid font-fallback risk. Not just simulator hygiene — App Store users on older devices encounter the same fallback.

If this audit's #1 fix lands by replacing inline tag sequences with regional-indicator pairs, document the convention in CLAUDE.md alongside the existing "Rich Text Markup" section so future content edits don't reintroduce tag sequences.

---

## Critical Files (quick reference)

| File | Relevance |
|------|-----------|
| `Konjugieren/Assets/Localizable.xcstrings` | Source of the `[?]` glyph bug — find and replace inline emoji (#1) |
| `Konjugieren/Views/QuizView.swift` | Empty space below card (#4); progress bar weight (#5); speak-on-tap (#22); Conjgroup label (#10) |
| `Konjugieren/Views/VerbView.swift` | Card etymology / example sections (#6); pill differentiation (#12); long-infinitive wrap (#14) |
| `Konjugieren/Views/SettingsView.swift` | App-icon picker (#7); action-button differentiation (#8); audio-feedback contrast (#15) |
| `Konjugieren/Views/FamilyDetailView.swift` | Long-description card (#11) |
| `Konjugieren/Views/InfoView.swift` + `Konjugieren/Views/RichTextView.swift` | Subheading treatment (#13) |
| `Konjugieren/Views/OnboardingView.swift` | Page-1 layout (#16) |
| `Konjugieren/Views/ResultsView.swift` | Score-card / list divider (#17) |
| `Konjugieren/Views/MainTabView.swift` | Tab haptic (#9) |
| `Konjugieren/Views/InfoBrowseView.swift` | Tutor icon emphasis (#21) |
| `Konjugieren/Utils/Modifiers.swift` | Card-elevation modifiers (cross-cutting #A); GradientDivider lift (#17) |
| `Konjugieren/Utils/Layout.swift` | Possibly card-corner-radius constant if standardizing |
| `Konjugieren/Assets/Assets.xcassets` | New color assets `customCardBackground`, `customCardBorder` (#19, #20) |

---

## Verification

Since this is an audit (no code changes were made by this document itself), each implemented suggestion should be verified by:

1. **Visual regression**: re-run the simulator with `ios-build-verify` (`build_app.sh` then `launch_app.sh`), navigate to the affected screen, screenshot under `docs/screenshots/` with a fresh timestamp, and compare to the pre-change screenshot listed in the suggestion's "Visual proof" line.
2. **Source verification**: confirm the change matches the recommended snippet exactly, with appropriate `accessibilityReduceMotion` gating where motion was added.
3. **iOS / Swift compatibility**: every suggested API works on iOS 17+; the project targets iOS 26 with `SWIFT_VERSION = 6.0` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. No `nonisolated` annotations are required for any of the additions above.
4. **JSON integrity** after editing `Localizable.xcstrings` (#1):
   ```bash
   python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"
   ```
5. **Test suite**: `bash ~/.claude/plugins/cache/ios-build-verify/.../scripts/run_tests.sh`. None of the suggestions touch test-coverable logic, but the test suite should pass cleanly post-change.

---

## Implementation order recommendation

If implementing more than one suggestion, this order minimizes rework:

1. **#19 + #20** (color assets) — establishes naming.
2. **#A** (card modifiers in `Modifiers.swift`) — establishes API.
3. **#2 + #3** (apply unified card treatment everywhere) — uses #A.
4. **#1** (fix `[?]` glyph bug) — independent, can ship anytime.
5. **#6 + #11** (card-wrap remaining sections) — uses #A.
6. **#13** (subheading treatment) — affects all rich-text screens; do once #6/#11 land so the visual context is consistent.
7. **#4 / #5 / #22 / #10** (Quiz polish) — independent of card system.
8. **#7 / #8** (Settings polish) — independent.
9. **#9 / #14 / #16 / #17 / #21** — small independent items.
10. Skip / defer **#23 / #24** unless explicit user feedback motivates them.
