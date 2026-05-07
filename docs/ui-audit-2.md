# Konjugieren UI Audit — Round Two

## Context for future sessions

This document is intended to be **self-contained**. A future Claude Code session — or a human — should be able to pick up any single suggestion and implement it without reading prior conversations or other audit files. Each suggestion includes its target file, problem statement, exact recommended SwiftUI code (where applicable), and dependencies on other items.

### How this audit was produced

A prior audit, `docs/ui-audit.md` (referred to below as "Round One"), was produced by applying the `ios-design-agent-skill` (an Anthropic-authored Frontend Design Skill ported to SwiftUI). Round One enumerated 24 suggestions across six screens. Commit `657bb4f` ("apply ios-design-agent-skill UI audit suggestions") implemented essentially every High and Medium suggestion from Round One.

This document, Round Two, was produced afterward by combining `ios-design-agent-skill` and `ios-build-verify`. The latter drove the running app on an iPhone 17 simulator (iOS 26.3), captured 13+ screenshots into `docs/screenshots/`, and let the audit reference real visual evidence rather than only source code. The post-657bb4f source for `QuizView`, `ResultsView`, `VerbView`, `SettingsView`, `OnboardingView`, `VerbBrowseView`, `FamilyDetailView`, `InfoView`, `InfoBrowseView`, `MainTabView`, `RichTextView`, `Modifiers`, and `Layout` was read in full as part of synthesis.

### What Round One delivered (preserve when implementing)

Future sessions should not re-suggest these — they are already in place:

- **Cards**: rounded-rectangle backgrounds wrap `ConjugationSectionView` (in `VerbView.swift`), Settings groups (in `SettingsView.swift`'s `settingsCard` helper), the Quiz active card (in `QuizView.swift`'s `quizContent`), the Results stats card (in `ResultsView.swift`), and the Tutor row (in `InfoBrowseView.swift`'s `TutorRowView`). Round Two added the `konjCard()` / `konjCardWithAccentBar()` / `konjCardRim()` modifier suite (#A) backed by the `customCardBackground` and `customCardBorder` named assets (#19, #20); all five sites use them.
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
- `customCardBackground` — surface for grouped content (Round Two #19). Matches `Color(.secondarySystemBackground)` semantic values: `#1C1C1E` dark / `#F2F2F7` light.
- `customCardBorder` — `customYellow` at 0.08 opacity baked in (Round Two #20). Used by `konjCard()` and `konjCardRim()` for the warm rim overlay.

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
- `konjCard()` — full card surface (Round Two #A): `.padding()` + `customCardBackground` + clip to 12pt rounded rectangle + `customCardBorder` rim overlay.
- `konjCardWithAccentBar(_:)` — `konjCard()` plus a 2pt yellow leading-edge accent bar. Used by `ConjugationSectionView`.
- `konjCardRim()` — just the `customCardBorder` overlay (no padding, background, or clip). For sites that need the rim while keeping their own background or padding.

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
# Resolve the skill's scripts/ directory once per session. Plugin-marketplace
# install location includes a version segment that rotates on release bumps;
# see SKILL.md "Resolving the script path" for the full convention.
export IBV_SCRIPTS=$(dirname "$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")

# Build (pipes xcodebuild through xcbeautify; tees raw to build.log).
"$IBV_SCRIPTS/build_app.sh"

# Launch — polls FIRST_SCREEN_ID=verb_browse_anchor and auto-taps Skip on onboarding.
"$IBV_SCRIPTS/launch_app.sh"

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

1. ~~**Card-treatment inconsistency**: `Color(.secondarySystemBackground)` appears at full opacity in `QuizView` but `.opacity(0.5)` in `VerbView` / `SettingsView` / `ResultsView`. Two visual languages for "card" within one app.~~ *Done — see #2.*
2. ~~**Cards without elevation**: no shadows, no borders. On a pure-black background, fill-only cards have no depth dimension.~~ *Done — see #3.*
3. ~~**One real rendering bug**: `[?]` glyph fallback on inline emoji in long-form `BrowseableFamily` descriptions.~~ *Done — see #1.*
4. **Quiz screen still leaves ~60% of vertical space empty** below the question card.
5. ~~**VerbView's etymology and example-sentence sections are bare** while the conjugation sections above them are carded — visual rhythm breaks halfway down.~~ *Done — see #6.*
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
"$IBV_SCRIPTS/build_app.sh"   # IBV_SCRIPTS set per "Driving the simulator" section above
"$IBV_SCRIPTS/launch_app.sh"
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

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

**Files:**
- `Konjugieren/Views/QuizView.swift:223` — full opacity: `Color(.secondarySystemBackground)`.
- `Konjugieren/Views/VerbView.swift:311` — half opacity: `Color(.secondarySystemBackground).opacity(0.5)`.
- `Konjugieren/Views/SettingsView.swift:222` — half opacity.
- `Konjugieren/Views/ResultsView.swift:50` — half opacity.

**Problem:** Two card languages co-exist within the same app. Quiz cards look heavier than Verb / Settings / Results cards.

**Recommended fix:** standardize on full opacity. Half-opacity cards on Konjugieren's pure-black background barely register visually. Update VerbView, SettingsView, ResultsView to drop `.opacity(0.5)`.

**Foundation for #19** below — if pursuing the named-asset cleanup, do that first and adopt the asset everywhere in one pass.

**Independent of:** all other suggestions.

**Resolution (2026-05-06):**

All four card sites adopted the `konjCard()` / `konjCardWithAccentBar()` modifiers from #A, dropping `.opacity(0.5)` in the process. Site-by-site:

- `VerbView.swift` `ConjugationSectionView` — replaced ad-hoc `.padding+.background+.clipShape+.overlay(accent bar)` with `.konjCardWithAccentBar()`.
- `SettingsView.swift` `settingsCard` helper — replaced `.padding+.background+.clipShape` with `.konjCard()`.
- `ResultsView.swift` score card — same as above; `.frame(maxWidth: .infinity)` preserved before `.konjCard()`.
- `QuizView.swift` quiz active card — adopted `.konjCard()`; conditional incorrect-flash `strokeBorder` overlay layered on top so it co-exists with the warm rim.

Two side effects worth noting:

1. Quiz card corner radius normalized from 16 to 12, joining the rest of the app's consensus (the modifier hardcodes 12).
2. #15 (Audio Feedback inactive segment contrast) resolves as a side effect — the audit predicted the contrast issue would clear once `.opacity(0.5)` was dropped everywhere.

Visual confirmation: `docs/screenshots/20260506-090229-verb-detail-sein-rim.png`, `docs/screenshots/20260506-090310-settings-top-rim.png`, `docs/screenshots/20260506-090350-quiz-active-rim.png`.

### 3. Cross-cutting: Add subtle elevation to cards

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

Achieved as a side effect of #2 — `konjCard()` already wraps the `customCardBorder` overlay per #A, so adopting `konjCard()` for opacity unification gave each site the rim in the same move. Five sites now carry the rim:

- `VerbView.swift` `ConjugationSectionView` (via `konjCardWithAccentBar()`)
- `SettingsView.swift` `settingsCard` helper (via `konjCard()`)
- `ResultsView.swift` score card (via `konjCard()`)
- `QuizView.swift` quiz active card (via `konjCard()`)
- `InfoBrowseView.swift` `TutorRowView` — keeps its intentional `Color.customYellow.opacity(0.05)` tint background (the row's identity, not a default card surface) and gains the rim via `.konjCardRim()`, the third modifier in #A's suite. The result: same background-tint identity as before, plus the warm rim.

`FamilyDetailView.swift` is not yet a card site (depends on #11). When #11 lands, its wrapper should adopt `konjCard()` and gain the rim for free.

Visual confirmation: same screenshots as #2. The rim is most visible on the larger Settings cards and least visible on the small per-conjugation cards in VerbView — same `customCardBorder` color, same 1pt width, but visual weight scales with the card's perimeter.

### 4. Quiz: Reclaim the empty bottom 60%

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

Shipped (a) — the question-queue dot row. (b) and (c) deferred to Round Three.

`Quiz.swift:358-374` — added `QuizItem.State` enum (`.correct` / `.incorrect` / `.unanswered`) with a computed `state` property derived from the existing `isCorrect: Bool?`. The audit's `quiz.stateForQuestion(at:)` call simplified to `quiz.questions[i].state` since `Quiz.questions` is already `private(set)` and readable from the view — no new method on `Quiz` needed.

`QuizView.swift:223-246` — dot row as the second child of the outer VStack in `quizContent`, with `Layout.doubleDefaultSpacing` separating it from the card. Each dot is `Image(systemName: "circle.fill")` (not `Circle()`, since `.symbolEffect(.pulse)` only animates SF Symbols — the audit's snippet would have been a no-op as written). The current dot scales to 1.4× and pulses via `.symbolEffect(.pulse.byLayer, options: reduceMotion ? .nonRepeating : .repeating, isActive: i == quiz.currentIndex)`, matching the start-button pulse pattern at `QuizView.swift:40`. State transitions get `.animation(.spring(duration: 0.3), value: quiz.questions[i].isCorrect)`. Color mapping lives in a private `extension QuizItem.State` at `QuizView.swift:252-263`: correct → `.customYellow`, incorrect → `.customRed`, unanswered → `.gray.opacity(0.4)`. The current dot intentionally stays dim gray — its identity comes from scale + pulse, not a fourth color.

Combined VoiceOver label via `.accessibilityElement(children: .ignore)` + new `L.Accessibility.quizDotRow(current:total:correct:incorrect:remaining:)` (added to `L.swift:35-37` and `Localizable.xcstrings`, both `de` and `en`, with positional `%n$lld` substitutions). One glanceable announcement instead of 30 per-dot rotor stops.

Tests added at `QuizTests.swift:395-440`: `quizItemStateIsUnansweredBeforeSubmit`, `quizItemStateIsCorrectAfterCorrectAnswer`, `quizItemStateIsIncorrectAfterIncorrectAnswer`, `quitClearsAllQuestionsAndStates`. Suite count 122/122 in 17 suites (118 baseline + 4).

Layout sanity: `30 × 8pt + 29 × 4pt = 356pt`; iPhone 14 (smallest device given the iOS 26.0 deployment floor) has ~358pt usable width inside `Layout.doubleDefaultSpacing × 2` horizontal padding. Tight by 2pt but no overflow. If a future device surfaces claustrophobia, swap the dot row body to `ViewThatFits` with primary `(8pt, 4pt)` and fallback `(6pt, 3pt)` — three lines of code.

**Bug-and-fix during shipping:** the initial implementation followed the audit's snippet form, `ForEach(0..<Quiz.questionCount, id: \.self) { i in ... quiz.questions[i] ... }`. This crashed with `Fatal error: Index out of range` on the first tap of the Quit toolbar button (or sometimes the second tap, on real iPhone hardware where keyboard-dismiss steals the first tap): `Quiz.quit()` sets `questions = []` (`Quiz.swift:176`), but the constant-range `ForEach` still tried to iterate 30 times and access `quiz.questions[i]`. Although the parent `if quiz.isInProgress, let question = quiz.currentQuestion` should fail and prevent `quizContent` from being called once `isInProgress == false`, SwiftUI's `@Observable` invalidation can re-evaluate child closures one more time during transition unmount or between sibling property mutations within `quit()`. The fix switched the dot row to `ForEach(Array(quiz.questions.enumerated()), id: \.element.id) { index, item in ... }` — iteration count is now coupled to the actual collection, so an empty `questions` array produces zero dot renders instead of 30 out-of-bounds accesses. **Generalizable lesson:** when iterating with `ForEach` over a mutable `@Observable` collection, bind iteration to the collection itself (or its `.indices`), never to a presumed-stable constant range. The audit's recommended snippet had this fragility built in; future audits should flag it. Live repro of the crash captured at `docs/screenshots/20260506-122952-repro-after-first-quit.png` (app crashed to home screen with the Live Activity pill still visible because `quit()` aborted mid-mutation); post-fix verification at `docs/screenshots/20260506-123247-repro-fix-after-quit.png` (clean transition back to the Start screen with no Live Activity pill, indicating `quit()` completed cleanly).

Visual confirmation:

- Pre-batch baseline (post-#13, pre-Quiz-polish): `docs/screenshots/20260506-120810-quiz-active-pre-batch.png` — empty bottom 60%, "Conjgroup:" label, thin yellow ProgressView line.
- Post-batch fresh quiz state: `docs/screenshots/20260506-121611-quiz-active-post-batch-fresh.png` — dot row visible below the card with all-gray dots, current dot subtly larger from the 1.4× scale.
- Post-batch mid-quiz mixed states: `docs/screenshots/20260506-121728-quiz-after-q1.png` — yellow correct dot at position 1, red incorrect dot at position 2, pulsing larger gray current dot at position 3, 27 dim-gray upcoming dots. Also confirms #5's absorption (no ProgressView at top of card) and #10's full-word "Conjugationgroup:" label.

### 5. Quiz: Progress bar visibility

**Status:** Resolved 2026-05-06 (absorbed into #4(a)). See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

Absorbed into #4(a)'s dot row, per the audit's own alternative recommendation. The audit's standalone snippet (track-and-fill `ProgressView` styling) was not implemented because the dot row encodes the same progress with richer per-question feedback, and shipping both would have been visual redundancy.

`QuizView.swift:91-92` (the original `ProgressView`) and the `progressText` cell at the former `QuizView.swift:126` were both deleted. The stats row inside the card is now just `Score` and `Elapsed` — the dot row provides the progress dimension visually. See #4's Resolution block for the dot-row implementation, the screenshots, and the test additions.

### 6. VerbView: Wrap etymology and example-sentence sections in cards

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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
  .konjCardWithAccentBar()
  .padding(.horizontal)
}
```

Same wrapper for the example-sentences section. Note the heading style change to match conjugation section headings (`.subheadline.smallCaps().weight(.semibold).fontDesign(.serif)`) — this also unifies typography across sections within a single VerbView. The `.konjCardWithAccentBar()` modifier is from #A's suite (shipped) and replaces what was, in the original audit, an explicit `.padding+.background+.clipShape+.overlay(accent bar)` chain.

**Depends on:** #2 cleanup is recommended first so the same asset name is used everywhere. Independent if shipping immediately at full opacity.

**Resolution (2026-05-06):**

Both etymology (`VerbView.swift:115-127`) and example-sentences (`VerbView.swift:129-154`) sections wrapped with `.konjCardWithAccentBar()` from #A's modifier suite, replacing the prior bare `.padding(.horizontal)` framing. The `.padding(.horizontal)` is preserved as the outer modifier so each card sits within the screen-edge gutters.

Heading typography updated in both sections from `.font(.headline)` to `.font(.subheadline.smallCaps().weight(.semibold)).fontDesign(.serif)`, matching the heading style of `ConjugationSectionView` (line 284-285). This unifies typography across every section heading within `VerbView` — etymology, example sentences, and per-conjugation cards now all share the same small-caps serif treatment. The double `.foregroundStyle(.primary)` → `.foregroundStyle(.customYellow)` chain at the etymology and example-sentence call sites is preserved verbatim per the audit's recommended snippet (the second wins; keeping both minimizes the diff at the existing site).

Visual confirmation:

- `docs/screenshots/20260506-101245-sein-etymology-post6.png` — Futur Konjunktiv II conjugation card above; the new Etymology card below with matching accent bar and small-caps serif heading.
- `docs/screenshots/20260506-101339-sein-example-sentences-post6.png` — etymology body trailing into the new Example Sentence card.

### 7. Settings: App Icon picker — replace text segments with previews

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

`AppIcon.swift` — added `previewAssetName: String` mapping each enum case to its preview imageset: `.bratwurst → "BratwurstIconPreview"`, `.bundestag → "Bundestag"`, `.hat → "Hat"`, `.pretzel → "Pretzel"`. Drive-by per CLAUDE.md's "Alphabetize Enum Cases" rule: the existing `localizedAppIcon` and `alternateIconName` switches were also alphabetized in the same edit. Both had been declared in non-alphabetical order (`bratwurst → hat → pretzel → bundestag`) since the file's inception, even though the enum cases at lines 3-7 were already alphabetical. Three switches in one file now share consistent ordering.

`SettingsView.swift:102-141` — replaced the App Icon segmented `Picker` with a `LazyVGrid` of four selectable `Button`s. Layout uses `Array(repeating: GridItem(.flexible(), spacing: Layout.defaultSpacing), count: 4)` for a fixed 4-column row — predictable across iPhone and iPad and matches the icon count exactly — instead of the audit's `[GridItem(.adaptive(minimum: 72))]`, which would have packed 8+ columns at iPad widths. Each cell is a `VStack` containing `Image(appIcon.previewAssetName).resizable().aspectRatio(1, contentMode: .fit).frame(width: 60, height: 60)` clipped via `RoundedRectangle(cornerRadius: 14, style: .continuous)` — the `.continuous` style matches iOS's actual app-icon squircle curvature better than the default rounded rect — with a 3pt `customYellow` stroke overlay when selected (`Color.clear` when not, so layout doesn't shift on selection change), and a `.font(.caption2)` Text caption beneath. The Button uses `.buttonStyle(.plain)` to suppress the system's default tinted-pill chrome — visual identity comes from the thumbnail itself.

Accessibility: `.accessibilityHidden(true)` on the `Image` (the Text caption is the spoken label, avoiding double-announcement) and `.accessibilityAddTraits(settings.appIcon == appIcon ? .isSelected : [])` on the Button. The standard iOS-localized "selected" announcement is used, which avoided introducing any new localized strings to the catalog.

`.sensoryFeedback(.selection, trigger: settings.appIcon)` is applied to the LazyVGrid, mirroring the precedent set by #9's tab-change haptic on `MainTabView`.

The audit's snippet at lines 449-470 was directionally correct but had two implementation gaps that surfaced during shipping: (1) it omitted `.buttonStyle(.plain)`, which would have allowed the system's default Button tint to fight with the thumbnail visual; (2) it didn't specify a corner-radius style, leaving the default non-`.continuous` rounded rect that reads less iOS-native than `.continuous` does. Future audits in this file should default to `.continuous` for any rounded shape meant to evoke a real iOS surface.

The icon-swap side effect remains transparent: `Settings.appIcon.didSet` in `Settings.swift:118-125` already calls `setAppIcon(_:)` which invokes `UIApplication.setAlternateIconName(_:)`. The new Buttons mutate `settings.appIcon` exactly as the old Picker did, so no extra `.onChange` plumbing was needed. Note that the icon swap is only visible after backgrounding the app — the in-app picker doesn't show the home-screen icon change, so verification of the swap itself requires a manual home-screen check.

**Bug-and-fix during shipping:** the initial implementation pointed `previewAssetName` for `.bratwurst` at the existing `BratwurstBroetchen.imageset` (the only bratwurst-themed imageset in `Assets.xcassets` at the time). Post-implementation visual verification revealed the bratwurst thumbnail rendered as a bright white squircle with the bratwurst illustration in the middle — visually broken against the dark Settings card. Pixel sampling on `BratwurstBroetchen.png` (512×512 RGBA) confirmed the root cause: corner pixels at `(248, 254, 251)` with alpha=255 throughout — a fully opaque cream/white background baked into the source image, with no `-light` luminosity variant. The other three preview imagesets (`Hat`, `Bundestag`, `Pretzel`) all ship paired light/dark variants with corner pixels at `(0,0,0)` for dark and `~(240,240,225)` for light, so they integrate properly with the surrounding card in either appearance mode. `BratwurstBroetchen` was a single-asset orphan with no other consumers in the codebase (verified by grep). The fix: a new `BratwurstIconPreview.imageset` was created by copying the actual `BratwurstIcon.appiconset` artwork (`BratwurstIcon.png` + `BratwurstIcon-light.png`, both 1024×1024 with corner pixels matching the established `(0,0,0)` / `(237,233,224)` pattern) into the new imageset with a `Contents.json` declaring the `appearance: luminosity, value: light` variant per the `Hat.imageset` template. The orphaned `BratwurstBroetchen.imageset` was deleted, and `previewAssetName` for `.bratwurst` was updated to return `"BratwurstIconPreview"`. **Generalizable lesson:** when adopting an existing asset for a new role (especially as a thumbnail with adjacency to a designed surface), verify pixel-level properties first — opacity, corner color, presence of luminosity variants — rather than trusting that an imageset with a thematically-matching name will visually integrate. The fix path also tightened the design contract: the bratwurst preview now uses the actual app-icon artwork, so the picker thumbnail and the resulting home-screen icon are visually identical (a stronger truth-telling than the original decorative-asset approach).

Visual confirmation:

- Pre-batch baseline: `docs/screenshots/20260506-130327-appicon-picker-baseline.png` — text-segmented Picker with cramped Bratwurst / Bundestag / Hat / Pretzel labels.
- Post-batch (initial, before bratwurst-fix): `docs/screenshots/20260506-130719-appicon-picker-post.png` — 4-thumbnail LazyVGrid with the Hat icon selected; bratwurst thumbnail visibly broken with white background.
- Post-bratwurst-fix: `docs/screenshots/20260506-132841-appicon-picker-bratwurst-fix.png` — same 4-thumbnail LazyVGrid, bratwurst thumbnail now integrating cleanly with the dark card via the proper appiconset-derived imagery.

### 8. Settings: Differentiate the four action buttons

**Status:** Resolved 2026-05-06 (item (a) only; (b) deferred). See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

Shipped (a) only — the per-button SF Symbol `Label` swap. (b), the thematic card split, was deferred to a future batch on the rationale that with the chassis already unified by `funButton()`, (b) becomes a thematic-grouping question rather than a visual-rhythm one. The post-(a) screenshot is therefore the right evidence base for any future card-split decision; reasoning about empty-card edge cases (Game Center unauthenticated; Apple Intelligence host-eligibility on Intel-Mac hosts) without concrete visual input wastes design budget. The audit's confirmation-dialog and `.tint(.customRed)` notes for Delete Chat History were also deferred — they're destructive-action UX, not differentiation, and the audit's #8 strict scope is differentiation. Mixing them in would have required three new localized strings and a `Common.cancel` entry (no `enum Common` exists in `L.swift` today, so a whole new enum bucket).

**Code-level finding worth recording for future audits:** `funButton()` at `Modifiers.swift:100-107` already applies `.tint(.customRed)` (full styling: `.foregroundStyle(.customYellow) + .buttonStyle(.bordered) + .tint(.customRed)`). Every action button in Settings is therefore already red-tinted with yellow text. The audit's "tint Delete Chat History red" note can't differentiate via tint — they're all red. SF Symbols inside `Label`s inherit the foreground style and render yellow on the red bordered chassis. Differentiation in this batch comes from the symbol choice alone (e.g., `trash` is iconographically destructive); chassis-level differentiation would require a more invasive change (per-button tint override, or a destructive-role variant of `funButton()`) and is the natural follow-up if Delete Chat History needs more visual prominence.

`SettingsView.swift` — five buttons converted from `Button(text) { action }` to `Button { action } label: { Label(text, systemImage: ...) }`:

- View Leaderboard → `trophy.fill` (line 152)
- Show Onboarding → `questionmark.circle.fill` (line 168)
- Play Game → `gamecontroller.fill` (line 184)
- Delete Chat History → `trash` (line 201)
- Rate or Review → `star.fill` (line 216)

All existing per-button modifiers preserved exactly: `.funButton()`, `.frame(maxWidth: .infinity)`, `.accessibilityHint(...)` on View Leaderboard and Show Onboarding (the only two with hints today; the other three are unhinted and remain so to keep this batch tight to the icon-swap scope), `.popoverTip(playGameTip)` on Play Game. `funButton()` itself was not modified; the chassis stays unified across all five buttons.

No new localized strings were introduced. SF Symbol names are pure-ASCII identifiers and don't go through `Localizable.xcstrings` — so the JSON-edit hazard from CLAUDE.md doesn't apply to this batch.

Visual confirmation:

- Pre-batch baseline: `docs/screenshots/20260506-130327-appicon-picker-baseline.png` (the same frame captures both #7 and #8 baselines: cards 3 + 4 visible together) — three text-only Buttons (Show Onboarding, Play Game, Rate or Review), no leading symbols.
- Post-batch: `docs/screenshots/20260506-130719-appicon-picker-post.png` — same three buttons now with leading SF Symbols (questionmark.circle.fill, gamecontroller.fill, star.fill), funButton chassis untouched, yellow-symbol-on-red-pill aesthetic preserved.

**Apple-Intelligence host-eligibility caveat** (per CLAUDE.md): the Delete Chat History button is gated on `Current.languageModelService.isAvailable`. On the Intel-Mac development host running iOS 26.3.1+ the gate fails silently and the button doesn't render; the `trash` symbol assignment can only be visually verified on Apple-Silicon Mac hosts or a real Apple-Intelligence-capable iPhone. Game Center authentication was likewise off in the verification simulator — View Leaderboard's `trophy.fill` is also unverified visually. Both buttons compile cleanly per `build_app.sh`; verification of their iconography is reduced to "code matches the spec, build clean."

---

## Medium Priority (polish)

### 9. Cross-cutting: Sensory feedback on tab change

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

`MainTabView.swift:33` — added `.sensoryFeedback(.selection, trigger: world.selectedTab)` directly after `.tint(.customRed)`. Verified by build; haptics aren't visually testable on the simulator, so the verification reduces to "code matches the recommendation, build clean."

### 10. Quiz: Reconsider "Conjgroup:" label

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

Shipped (a) — the value edit. Both locales updated in `Localizable.xcstrings`'s `Quiz.conjugationgroup` entry: `en` from `"Conjgroup:"` to `"Conjugationgroup:"`; `de` from `"Conjgroup:"` to `"Konjugationsgruppe:"`. Both locales were stuck on the awkward English coinage — German had never been properly localized — so this batch fixed both rather than just the English half.

Wrap-check on iPhone 17 (the simulator) at `"Conjugationgroup: Imperativ"` width: clean single line inside the card. The longest German conjugationgroup name is `Plusquamperfekt Konjunktiv II` (only emitted at `.ridiculous` difficulty), giving a worst-case label of `"Konjugationsgruppe: Plusquamperfekt Konjunktiv II"` — ~50 characters at body font. Length math fits ~370pt of card-internal width on iPhone 14 / 17, but a visual check on a Plusquamperfekt-class question is worth doing in normal usage (not blocked on it; the underlying `.fixedSize(horizontal: true, vertical: false)` on the label `Text` plus `.fixedSize(horizontal: false, vertical: true)` on the value `Text` already wraps the value cleanly across lines if needed).

JSON integrity validated post-edit (`python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"` returned cleanly). The replacement was performed via Python per CLAUDE.md's xcstrings-editing rule, even though no ASCII double quotes were affected — the surrounding JSON syntax made it the safer tool.

Visual confirmation: the post-batch screenshots cited in #4's Resolution block both render the new full-word label clearly. Pre-batch baseline at `docs/screenshots/20260506-120810-quiz-active-pre-batch.png` shows the old "Conjgroup:" for direct comparison.

### 11. FamilyDetailView: Wrap long description in a card

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

**Screen:** `Konjugieren/Views/FamilyDetailView.swift:31-32`.

**Problem:** The long-form `RichTextView` description at the top of every family detail sits naked on the black background between the centered title and the verb list. Cards everywhere else in the app; not here.

**Fix:** apply `.konjCard()` (or `.konjCardWithAccentBar()` if matching `ConjugationSectionView`'s accent treatment is desired). The choice is the 2pt yellow leading-edge accent bar — consistency with VerbView's per-section cards argues yes; restraint argues no, since family-detail prose is already framed as the page's focal content.

Recommended: `.konjCard()` (no accent bar — the `BrowseableFamily.systemImageName` icon at the top is the focal element).

**Resolution (2026-05-06):**

`FamilyDetailView.swift:31-34` — long-description `RichTextView` wrapped with `.konjCard()` per the audit's recommendation (no accent bar). Confirmed visually: with the centered "Separable" title + `arrow.left.arrow.right` icon as the page's focal element, the bare `konjCard()` rim provides separation from the verb list below without competing with the icon-title pair above. The `customCardBackground` and `customCardBorder` (the rim) come along automatically via the modifier suite from #A.

Visual confirmation:

- Pre-#11 baseline: `docs/screenshots/20260506-100741-separable-detail-pre11.png` — description sits flat on the canvas, running directly into the "ab-" prefix header.
- Post-#11: `docs/screenshots/20260506-101406-separable-detail-post11.png` — description framed in a card with internal padding; the verb list is pushed below the fold.

The post-#1 inline emoji fix (England flag + horse glyphs) renders correctly inside the carded prose, confirming the wrapping doesn't disturb the `^...^` markup pipeline.

### 12. VerbView: Differentiate metadata pills

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

`VerbView.swift:204-218` — `metadataPill` helper generalized to accept `tint: Color = .customYellow` and `bordered: Bool = false`, with the bordered branch emitting `Capsule().strokeBorder(tint.opacity(0.4), lineWidth: 1.5)`. Two deviations from the audit's snippet:

1. **Border specification: 1.5pt at 40% opacity instead of 1pt at 30%.** The audit's `.strokeBorder(.customYellow.opacity(0.3))` (1pt default) reads too faintly against the 0.08-fill backdrop in light-or-dark mode. Per Q2 in the followup, started at 1.5pt/40% — landed visibly distinct from un-bordered yellow without competing with red pills. No iteration needed.
2. **`@ViewBuilder` overlay form.** The audit's snippet was `.overlay(Capsule().strokeBorder(...))` (non-builder), which would always evaluate the Capsule even when `bordered: false`. Switched to `.overlay { if bordered { ... } }` so the empty branch produces an `EmptyView` and is free at the un-bordered call sites. Functionally equivalent at the call sites that need a border; idiomatic SwiftUI elsewhere.

`VerbView.swift:53-97` — six pill call sites updated per the D1 mapping (yellow = descriptive, red = structural):

- Line 54 (Family): `tint: .customYellow` — descriptive.
- Line 59 (Auxiliary): `tint: .customRed` — structural; controls Perfekt construction with `sein`/`haben`.
- Line 68 (Frequency): `tint: .customYellow` — descriptive.
- Line 78 (Separable): `tint: .customRed` — structural; affects word order.
- Line 82 (Inseparable): `tint: .customRed` — structural; affects word order.
- Line 88 (Ablaut): `tint: .customYellow, bordered: true` — descriptive but visually exceptional; the border distinguishes it from family/frequency.

Audit said "five pill call sites" — in the source there are six, because Separable and Inseparable are mutually exclusive at runtime but live as two separate `if` branches. Both go red.

D1/D2/D3 ratification (per Q1–Q5 in `docs/ui-audit-2-next-session-followup.md`, an ephemeral working-memory file the cleanup convention says to delete after the batch lands): D1 audit mapping ratified. D2 border started at 1.5pt/40% (no iteration). D3 amended for #14 (see below).

**Q5 customRed-coexistence assessment (post-implementation):** the new structural-pill red and the existing mixed-case-letters red (rendered via `Text(mixedCaseString:)` at `VerbView.swift:303` → `TextExtension.swift:75/91`) are spatially separated by the `Divider` between the metadata block (lines 53-97) and the conjugation grid (lines 109-113 / 172-202). At the all-5-pill exemplar `ankommen`, the post-batch screenshot (`docs/screenshots/20260506-141709-post12-ankommen-default.png`) shows red `sein` and red `Separable` above the divider; the conjugation rows below show no red because the present-tense forms don't trigger ablaut. At `werden` (`docs/screenshots/20260506-141502-post12-werden-default.png`), red `sein` is above the divider and red ablaut letters in `geworden` and `wirst` are below — visually coherent rather than competing, since both reds carry the same semantic weight ("structural impact" / "irregular structural mutation").

Visual confirmation:

- **Pre-batch baselines** (uniform yellow pills): `docs/screenshots/20260506-140402-pre12-werden-default.png` (4 pills), `docs/screenshots/20260506-140518-pre12-machen-default.png` (3 pills, no second HStack), `docs/screenshots/20260506-140721-pre12-befinden-default.png` (5 pills, inseparable+ablaut), `docs/screenshots/20260506-140839-pre12-ankommen-default.png` (5 pills, separable+ablaut).
- **Post-batch** (differentiated): `docs/screenshots/20260506-141502-post12-werden-default.png`, `docs/screenshots/20260506-141553-post12-machen-default.png`, `docs/screenshots/20260506-141631-post12-befinden-default.png`, `docs/screenshots/20260506-141709-post12-ankommen-default.png`.
- **AX3 differentiation check**: `docs/screenshots/20260506-141021-pre14-werden-AX3.png` (pre — uniform yellow), `docs/screenshots/20260506-142020-post14-werden-AX3.png` (post — red sein, bordered ablaut). Confirms the differentiation reads at accessibility size too, despite the existing per-pill word-wrap that already crowds the row.

**Smoke checks:**

- `machen` (no prefix, no ablaut): the conditional second HStack at lines 75-97 does not render — only Family / Auxiliary / Frequency pills shown. Pre and post screenshots both confirm.
- Audit-doc claim that `aufstehen` was the all-5-pill exemplar — `aufstehen` is **not in the corpus**. The followup corrected to `ankommen` (`an+k^om^men`, fr=253), which is in the corpus and was used here.

Build and tests: `Build Succeeded`; `Test run with 122 tests in 17 suites passed after 26.400 seconds`. No regressions.

**No accessibility regressions:** existing `.accessibilityLabel(Text(verbatim: ...))` calls on the Auxiliary, Frequency, and Ablaut pills (which override the SF-Symbol-default reading) are preserved unchanged. Tint and border are purely presentational and don't affect VoiceOver.

### 13. InfoView: Subheading visual treatment

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

`RichTextView.swift:12-24` — `case .subheading` rewritten per the audit's snippet, with one deviation: `HStack(alignment: .center)` instead of `.firstTextBaseline`. `.firstTextBaseline` puts a 4-pt circle's bottom on the text's baseline, placing the dot in the descender region (where commas and periods sit) rather than alongside the heading text. `.center` puts the dot at the line-box midline, which for `.title3.bold()` lands near the heading's optical center — the section-marker bullet the audit gestures at.

The serif `.title3.bold()` heading text matches `InfoView.swift:17`'s article-title typography, giving long-form prose a coherent typographic register (serif title → serif subheadings → sans-serif body for readability).

Visual confirmation:

- Pre-#13 baselines: `docs/screenshots/20260505-104259-info-history-detail.png` (top of "A History of the German Verb System") and `docs/screenshots/20260505-104313-info-history-scrolled.png` (article-body scroll).
- Post-#13: `docs/screenshots/20260506-104716-info-history-detail-post13.png` shows "From Stardust to Speech" leading-aligned with the red-dot ornament; `docs/screenshots/20260506-104845-info-history-scrolled-post13.png` shows "The Yamnaya and Proto-Indo-European" the same way.

Side-effect verification across non-InfoView surfaces — all unaffected because no current data triggers `case .subheading` outside InfoView:

- `FamilyDetailView` long descriptions (`.konjCard()`-wrapped post-#11): no visual change. All seven `FamilyDetail.*Long` keys contain zero backtick subheadings.
- `OnboardingInfoSheet` body: no visual change. `Onboarding.conjugationgroupBody` contains zero backtick subheadings.
- `VerbView` etymology cards (`.konjCardWithAccentBar()` post-#6): no visual change. `Etymologies.json` contains zero backtick subheadings across all 990 entries.

If a future etymology adds backtick subheadings inside `VerbView`'s carded etymology section, eyeball the result for visual crowding (yellow accent bar + yellow heading + red dot all competing) and adjust if needed — e.g., parameterize the dot color on a `subheadingStyle` enum, or omit the dot inside cards.

The existing `SubheadingLabel` ViewModifier in `Modifiers.swift:64-72` (used by `SettingsView` and elsewhere for non-RichTextView labels) keeps its sans-serif design intentionally — long-form prose subheadings (serif + dot, post-#13) and UI-label subheadings (sans-serif + no dot) serve different visual jobs.

### 14. VerbView: Long infinitives wrap rather than scale-down

**Status:** Resolved 2026-05-06 with caveats. See "Resolution" block at the end of this section — the audit's stated default-size visible-wrap goal was **not achieved** for the current corpus, but the change is shipped as-is on the strength of an AX-size win and zero default-size regression.

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

**Resolution (2026-05-06):**

`VerbView.swift:42` — `.lineLimit(1)` removed. `.minimumScaleFactor(0.5)` at line 41 **retained** as an accessibility-size safety net, per Q1's amended D3 in the followup. The audit's "drop both" lean was superseded after surfacing dynamic-type behavior: at AX1–AX5, `.largeTitle` scales up dramatically and even short verbs can overflow iPhone width; SwiftUI doesn't break a single token across lines via word-wrapping alone, so without `.minimumScaleFactor` the AX-size result would be horizontal overflow / clipping rather than wrap.

**Empirical finding from post-batch screenshots — the audit's default-size assumption was incorrect:**

SwiftUI's text-fitting algorithm appears to prefer scale-down (within `.minimumScaleFactor` bounds) over wrap. Wrap with locale-aware German hyphenation only triggers when even max scale-down can't fit one line. Concrete observations using `auseinandersetzen` (the corpus's longest infinitive at 19 stored chars / 17 displayed chars):

| Size | Behavior | Screenshot |
|---|---|---|
| Default (large) pre-batch | Single line, scaled to ~0.85x via `.minimumScaleFactor(0.5)` | `20260506-140917-pre14-auseinandersetzen-default.png` |
| Default (large) post-batch | Single line, scaled to ~0.85x — **identical to pre-batch** | `20260506-141823-post14-auseinandersetzen-default.png` |
| AX3 pre-batch | Single line, scaled to ~0.5x (max scale-down) | `20260506-141103-pre14-auseinandersetzen-AX3.png` |
| AX3 post-batch | **Two lines, full `.largeTitle`, hyphenated as `auseinander-/setzen`** | `20260506-142059-post14-auseinandersetzen-AX3.png` |

At default size, removing `.lineLimit(1)` had **zero visible effect** on the canonical long verb. SwiftUI absorbs the slight overflow via `.minimumScaleFactor` before falling back to wrap. At AX3, the natural width vastly exceeds the available width and even max scale-down can't fit, so SwiftUI cleanly wraps with German hyphenation at the compound boundary `auseinander-setzen` — which is exactly the audit's stated intent, just not at the size the audit was looking at.

**Why this is shipped as-is rather than iterated:**

The change is well-scoped: it removes a redundant constraint when `.minimumScaleFactor` is the actual fitting mechanism. There is no regression at any size. The AX-size hyphenation win is real and was previously suppressed by `.lineLimit(1)`. No other corpus verb is longer than `auseinandersetzen`, so the default-size scale-down behavior is the same for every realistic case in the app.

**Options for future iteration if Josh wants visible default-size wrap:**

1. **Tighten `.minimumScaleFactor`** (e.g., `0.85`) to force wrap at default size for verbs that currently scale below 85%. Side effect: borderline verbs that previously got minor scale-down now wrap; need to verify the visual at 12-15 character verbs.
2. **Remove `.minimumScaleFactor` entirely.** Default and AX both rely on wrap; single-token unbreakable cases would overflow / truncate, which doesn't apply to German verbs (all wrap-eligible at compound boundaries) but loses the safety net for any future text that isn't a German infinitive.
3. **Apply a manual line-break at compound boundaries.** Verbs.xml already encodes prefix boundaries via `+` and `*`. A `displayInfinitive(withSoftBreak:)` accessor could insert `\u{200B}` (zero-width space) at the prefix boundary to give SwiftUI a break opportunity at default size. Touches Verb-rendering surfaces beyond VerbView.

This batch ships option (0) — the change-as-spec'd. The above options are documented for a future audit cycle if visible default-size wrap becomes a stated goal again.

**Smoke checks:**

- Short verb at AX3 (`werden`, 6 chars): full `.largeTitle`, no scale or wrap. Pre and post screenshots match (`20260506-141021-pre14-werden-AX3.png`, `20260506-142020-post14-werden-AX3.png`). Confirms `.minimumScaleFactor` is dormant when not needed and the wrap behavior is reserved for the genuine overflow case.
- Default-size short verbs (`werden`, `machen`, `befinden`, `ankommen`): unchanged. Visual confirmation in #12's screenshot inventory.

Build and tests: `Build Succeeded`; `Test run with 122 tests in 17 suites passed after 26.400 seconds`. No regressions.

### 15. SettingsView: Audio Feedback inactive segment contrast

**Status:** Resolved 2026-05-06 as a side effect of #2 (dropping `.opacity(0.5)` everywhere gave the segmented picker enough background contrast to make inactive segments legible).

**Screen:** `Konjugieren/Views/SettingsView.swift:93-99`.

**Visual proof:** `docs/screenshots/20260505-105300-after-dismiss.png`. The "Disable" segment text (when "Enable" is active) is barely readable against the segmented picker's dark inactive background.

**Problem:** The host card currently uses `Color(.secondarySystemBackground).opacity(0.5)`. On a black canvas with a half-strength card, the segmented picker's inactive background blends with the card and the inactive segment text loses contrast.

**Fix:** the cleanest path is to address #2 first (drop the `.opacity(0.5)` everywhere). Card-at-full-opacity gives the segmented picker enough background contrast to make inactive segments legible. If #2 is not adopted, raise this card's specific opacity to 0.7 or 0.8 as a localized fix.

**Depends on:** #2 (resolves automatically) or independent localized fix.

### 16. OnboardingView: Reclaim empty space on page 1

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

Shipped both fix candidates with two snippet-level overrides on (b) and one consistency fix beyond the audit's scope. Q2 in the questions doc surfaced that the audit's literal pairing of `endPoint: .center` with `.frame(height: 300)` would have produced a visible fade only over the upper 150pt of canvas — past `.center`, LinearGradient holds the endpoint color, leaving the lower 150pt of the frame fully clear. Q2 ratified `endPoint: .bottom` instead, spreading the fade across the full 300pt and matching the audit's narrative description ("upper third"). The audit's `.background(...)` modifier was also adapted to a sibling-in-ZStack pattern (parent-level placement per D2) with `ZStack(alignment: .top)` to top-anchor the gradient.

After the initial post-batch screenshot, real-iPhone visual feedback from Josh revealed that the audit's `customYellow.opacity(0.08)` was too subtle to register as decoration on OLED — present in the pixel buffer (top-row pixel ≈ (20, 16, 0)) but below most viewers' casual perception threshold. **Opacity bumped to `0.20`** (top-row pixel now ≈ (50, 40, 0) — clearly perceptible warm cast); see "Visual confirmation" below for the full pixel sample. The audit's recommendation appears to have been calibrated by visual judgement rather than empirical pixel measurement on the target hardware.

Beyond the audit's two items, **the title `Text` at `OnboardingPageView` was given `.multilineTextAlignment(.center)`** to match the body text's alignment. The original code only set this modifier on the body; on phones or accessibility sizes where the title wraps to multiple lines, lines were left-aligned within the title's bounding box, producing a visible inconsistency against the centered body text. Single-line rendering at default size on tall iPhones masked this latent bug; Josh's iPhone surfaced it, and AX3 verification reproduces it. The fix is local to OnboardingPageView (one line added) rather than a change to the shared `headingLabel()` modifier — broadening that modifier's behavior would re-align headings throughout the app, which may not be desired in all contexts.

Decisions ratified before coding (D1–D4, Q1–Q2) and post-batch feedback:

- **D1.** Cap leading `Spacer()` at `.frame(maxHeight: 100)` (audit literal).
- **D2.** Parent-level gradient placement in `OnboardingView`'s ZStack — cleaner than per-page; ambient-tint feel matches system onboarding flows.
- **D3.** Gradient `.frame(height: 300)` (audit literal) — combined with Q2 override below.
- **D4.** Page 0 + spot-check page (D4b ratified). Spot-check page screenshot **blocked by iOS 26 SwiftUI `TabView(.page)` gesture-injection wall** (`ios-build-verify` SKILL.md "Common first-real-app friction" item 7) — the same wall the May 5 OnboardingView batch hit. Falling back to D4a (page 0 + AX3). `OnboardingPageView` is the shared per-page subview, so layout uniformity follows from the structure — a visual spot-check on a second page would have duplicated page 0's appearance.
- **Q1.** Top-anchoring via `ZStack(alignment: .top)` (Option A). Verified the inner VStack already fills its container via `TabView.tabViewStyle(.page)`, so re-aligning ZStack children to top does not shift the VStack.
- **Q2.** Gradient `endPoint: .bottom` (Option C) — **overrides** the audit's `.center`. Visible fade now spans the full 300pt of upper canvas, matching the audit's "upper third" narrative.
- **Post-batch (opacity).** Opacity bumped from audit's `0.08` to `0.20` after real-iPhone feedback showed the audit value was below perception threshold on OLED. Empirical: top-row pixel went from (20, 16, 0) to (50, 40, 0).
- **Post-batch (title alignment).** `.multilineTextAlignment(.center)` added to the title `Text` to match the body text's alignment when the title wraps. Local to `OnboardingPageView`; not propagated to the shared `headingLabel()` modifier.

**Side effects to record**: the (a) Spacer cap and the post-batch title-alignment fix both apply to all `OnboardingPageView` pages (5 on this Intel-Mac dev host, 6 on Apple-Intelligence-eligible hosts), not just page 1. This is the intended uniform treatment — `OnboardingPageView` is the shared per-page subview, and the audit's "page 1" framing was a representative reference, not a scope restriction.

File diff:

- `Konjugieren/Views/OnboardingView.swift`: at `OnboardingView.body` — gradient block + `alignment: .top` parameter (~12 net lines added); at `OnboardingPageView.body` — `.frame(maxHeight: 100)` added to the leading `Spacer()` (1 line) and `.multilineTextAlignment(.center)` added to the title `Text` (1 line).

Build clean (`build_app.sh`). Tests green: 122/122 in 17 suites — view-layer changes had zero test impact, as expected.

Visual confirmation:

- Page 0 pre-batch baseline: existing `docs/screenshots/20260505-104459-onboarding-1.png` (predates #16; OnboardingView untouched since).
- Page 0 post-batch (default size): `docs/screenshots/20260506-222224-onboarding-page0-post-batch-v4.png` — gradient clearly present as a warm yellow wash in the upper third of the canvas; mug icon now anchored at ~30% from top instead of ~50% (Spacer cap working as intended). Pixel sampling at the post-bump 0.20 opacity: top-row (50, 40, 0), fading to (32, 26, 0) at 20%, (17, 14, 0) at 30%, (0, 0, 0) by 50% — confirms expected fade profile.
- Page 0 post-batch (AX3): `docs/screenshots/20260506-222249-onboarding-page0-post-batch-ax3-v4.png` — content size `accessibility-extra-large`. Title wraps to two lines, both centered (post-batch alignment fix verified). Layout otherwise sensible: body fills available space with a slight last-line truncation ("across…" instead of "…across every conjugationgroup.") — whether this is pre-existing AX3 behavior or a regression introduced by the cap was not isolatable on this verification path. Worth a follow-up real-iPhone spot-check; flagging for completeness, not as a blocker. Content size reset to `large` after the spot-check.
- D4b spot-check page screenshot blocked by the gesture wall noted in D4 above.

### 17. ResultsView: Score-card / list divider

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

Shipped per the audit's snippet, with one architectural override surfaced via the next-session handoff cycle: `GradientDivider` lives in its own file at `Konjugieren/Utils/GradientDivider.swift`, not in `Konjugieren/Utils/Modifiers.swift` as this section originally prescribed. Rationale: `Modifiers.swift` is dedicated to view-extension methods plus private `ViewModifier` structs; a non-private file-scope `struct GradientDivider: View` is neither, and lumping it in would muddy the file's filename-intent. The override was surfaced via `docs/ui-audit-2-followup.md` (since deleted per the cleanup convention).

Decisions ratified before coding (D1–D3):

- **D1.** Default `color: Color = .customYellow`. All four call sites (3 in `SettingsView`, 1 in `ResultsView`) omit the parameter and rely on the default.
- **D2.** Divider sits *below* the optional GameCenter button and *above* the per-question `List` in `ResultsView` (option B). When the GC button is absent — e.g., in a non-GC-authenticated test run — the divider sits directly under the score card. Either way, the divider's job (separating summary above from per-item below) is coherent.
- **D3.** Full dedupe (D3a). `SettingsView`'s private `gradientDivider` computed property was removed; the three call sites at the original lines 44, 58, 87 were migrated to `GradientDivider()`.

File diff:

- New file: `Konjugieren/Utils/GradientDivider.swift` (17 lines).
- `Konjugieren/Views/SettingsView.swift`: removed private property (12 lines deleted); 3 call-site renames `gradientDivider` → `GradientDivider()`.
- `Konjugieren/Views/ResultsView.swift`: 4 lines added between the GC button block and the `List`.

Build clean (`build_app.sh`). Tests green: 122/122 in 17 suites — view-layer changes had zero test impact, as expected.

Visual confirmation:

- SettingsView regression check (D3a): `docs/screenshots/20260506-184004-settings-pre-batch-top.png` ↔ `docs/screenshots/20260506-184814-settings-post-batch-top.png` (card 1, two dividers); `docs/screenshots/20260506-184104-settings-pre-batch-scrolled.png` ↔ `docs/screenshots/20260506-184831-settings-post-batch-scrolled.png` (card 2, one divider). All three dividers pixel-identical pre/post — the migration to the shared component is visually transparent.
- ResultsView post-batch: `docs/screenshots/20260506-185228-results-post-batch-divider.png` — the new gradient divider is visible between the score card and the per-question list.
- ResultsView pre-batch baseline: existing `docs/screenshots/20260505-104123-quiz-results.png` (ResultsView's last commit was `117bce5`, predating that screenshot — the existing image is a valid pre-#17 reference).
- AX3 spot-check: `docs/screenshots/20260506-185312-results-post-batch-ax3.png` — divider scales sensibly at `accessibility-extra-large` content size; no layout regression in the parent VStack. Content size reset to `large` after the spot-check.

---

## Low Priority (polish pass)

### 18. VerbBrowseView: Sort animation preserves position vs. scroll-to-top

**Screen:** `Konjugieren/Views/VerbBrowseView.swift:73-80`.

The current behavior animates the list and scrolls to the first verb on sort change. If a user has scrolled deep, they lose position.

**This is a tradeoff, not a bug.** Frequency and alphabetical sort have different semantic meaning, so a top-scroll on order change is defensible. Worth a usability note but no fix recommended without user feedback.

### 19. Cross-cutting: Define `customCardBackground` named asset

**Status:** Resolved in commit `92d5043`. Color values shipped: `#F2F2F7` light / `#1C1C1E` dark — matches `Color(.secondarySystemBackground)` semantic values. Adopted by `konjCard()`'s background; per-site `Color(.secondarySystemBackground).opacity(0.5)` references replaced via the #2 migration (2026-05-06).

Many surfaces use `Color(.secondarySystemBackground).opacity(0.5)` (or full). Defining a named color asset (`customCardBackground` and optionally `customCardBackgroundSubtle`) gives a single source of truth and lets you tune card opacity in one place. Foundation for #2.

Implementation:

1. Add color asset in `Assets.xcassets` named `customCardBackground`. Set base color to `Color(.secondarySystemBackground)` equivalent (e.g., `#1C1C1E` dark / `#F2F2F7` light) or directly to that semantic color.
2. Replace every site listed in #2 with `Color.customCardBackground`.

### 20. Cross-cutting: Define `customCardBorder`

**Status:** Resolved in commit `92d5043`. Color value baked into the asset: `customYellow` RGB at alpha 0.080 (`#665300` light / `#FFCE00` dark, both at 8% opacity). Used by `konjCard()` and `konjCardRim()` for the warm-rim overlay.

Same pattern: a single named color for the subtle yellow-tinted card rim if #3's stroke approach is adopted. Color value: `customYellow` at 0.08 opacity baked in.

### 21. InfoBrowseView: Distinct iconography for Tutor row

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

Shipped per the audit's snippet at `Konjugieren/Views/InfoBrowseView.swift:170-172`: `.font(.title)` → `.font(.largeTitle)`; `.symbolEffect(.pulse, options: .repeating)` inserted between `.foregroundStyle(.customYellow)` and `.accessibilityHidden(true)`.

D4: shipped with code-inspection caveat (D4a) on the Intel-Mac dev host; real-iPhone visual verification subsequently confirmed by Josh — the brain icon's `.largeTitle` size and continuous `.pulse` animation render as intended on Apple-Intelligence-eligible hardware.

Verification context: Apple Intelligence host-eligibility silently suppresses the InfoBrowseView Tutor row on Intel-Mac dev hosts (per `CLAUDE.md`'s host-eligibility caveat) — the row simply does not render, with no console error or fallback UI. Pre/post visual screenshots on this hardware were not meaningful, which is why the change was paired with #17 (fully verifiable on the dev host) and the visual confirmation was deferred to Josh's real-iPhone check. That post-merge verification has now closed the loop; "shipped with caveat" is retired.

Build clean. Tests green: 122/122 in 17 suites.

`.symbolEffect(.pulse, options: .repeating)` automatically respects `accessibilityReduceMotion` per SwiftUI's documented behavior — no manual gating needed.

### 22. QuizView: Speak-on-tap for the verb infinitive

**Status:** Resolved 2026-05-06. See "Resolution" block at the end of this section.

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

**Resolution (2026-05-06):**

Shipped verbatim per the audit's snippet. `QuizView.swift:95` — `.speakOnTap(question.verb.infinitiv)` added after `.germanPronunciation()` on the infinitive `Text`. The default locale (`UttererLocale.german` per `Modifiers.swift:47`) is correct here — verb infinitives are German.

Pattern matches existing `.speakOnTap` call sites elsewhere in the app: `VerbView.swift:45` (verb infinitive), `VerbView.swift:51` (translation, English locale), `VerbView.swift:92` (ablaut group), `VerbView.swift:308` (conjugation row). The Quiz now joins the consistent surface where every printed verb is tappable to hear it.

VoiceOver behavior: the existing `.germanPronunciation()` modifier shapes the VoiceOver pronunciation hint. Adding `.speakOnTap` layers a tap action on top; the modifier doesn't override the accessibility label or trait. A manual VoiceOver pass on this surface is recommended at the next polish-batch boundary, but build clean + manual tap-fires-audio check is the verification scope per Round Two's followup.

### 23. Cross-cutting: Material backgrounds for the floating tab pill

iOS 26's floating tab pill uses a system material. Konjugieren's `customRed` `.tint` works but the pill against the all-black canvas looks slightly clinical. A custom `UITabBarAppearance` with a tinted `backgroundEffect` could knit the pill into the German-flag system more tightly. **Lowest priority** — likely leave alone.

### 24. SettingsView: Section-header divider variety

`gradientDivider` is used identically throughout `SettingsView`. Varying divider color subtly per card (yellow in Display, red in Quiz, neutral gray in Actions) is bordering on over-design. Listed for completeness; not recommended.

### 25. Highlight the AI Tutor as a banner feature

**Screen:** Cross-cutting — `Konjugieren/Views/OnboardingView.swift` (the page-4 brain icon, gated on `Current.languageModelService.isAvailable`), `Konjugieren/Views/InfoBrowseView.swift` (the Tutor row at lines 169-173 post-#21), and a possible new `MeetTutorTip` in `Konjugieren/Models/KonjugierenTips.swift`.

**Problem:** The AI Tutor is the most novel feature in the app, but it's discoverable only via two surfaces:

- The Tutor row in `InfoBrowseView` (now pulsating per #21), which sits as one row among the Info articles.
- The dedicated Tutor page in `OnboardingView` (page 4, gated on AI availability), seen once per user — and not at all by users who skipped onboarding or pre-dated the feature.

A returning user on an Apple-Intelligence-eligible device can easily miss the feature. Returning users on ineligible devices won't see it regardless, which is correct — but the absence of visible promotion to eligible users is a discoverability gap worth addressing.

**Fix candidates** (cumulative — they compose):

a. **Extend the pulse to the `OnboardingView` Tutor page icon.** Currently the shared `OnboardingPageView` renders all icons with a one-shot `.symbolEffect(.bounce, value: bounceValue)` on appear (per `OnboardingView.swift:191-194`). Add a `pulsing: Bool = false` parameter so only the Tutor page (already gated on AI availability) gets `.symbolEffect(.pulse, options: .repeating)` layered alongside the bounce. Two Tutor entry points, one consistent visual signature — continuity between the AI tutor's onboarding introduction and its post-onboarding home in `InfoBrowseView`.

b. **`MeetTutorTip` via TipKit.** The project already ships TipKit (`ChangeDifficultyTip`, `PlayGameTip` in `Konjugieren/Models/KonjugierenTips.swift`). Add a `MeetTutorTip` that fires on the Tutor row in `InfoBrowseView` once per user, gated on AI availability. Self-dismissing pop-tart with a tagline like "Try the AI Tutor — ask questions in plain language." First-time discoverability for returning users; auto-cleans up after first interaction. Naming and copy land in `Localizable.xcstrings` under `Tips.meetTutor*` keys.

c. **Hero banner card at the top of `InfoBrowseView`.** Promote the Tutor row from "just another row" to a full-width hero card with a larger icon, dedicated tagline, and a "Try it" affordance. Reshapes `InfoBrowseView`'s information architecture so the Tutor visually dominates the screen for AI-eligible users; falls back to the current row layout for ineligible users. Most invasive option; biggest discoverability gain. Warrants design exploration before implementation.

**Verification gap (Apple Intelligence host-eligibility):** same caveat as #21. The Tutor surface silently does not render on Intel-Mac dev hosts (per `CLAUDE.md`'s host-eligibility note). Real-iPhone or Apple-Silicon-Mac access required for visual confirmation. Code inspection alone is insufficient for any banner / hero-card layout work.

**Recommended:** ship (a) and (b) together as a paired batch — both are low-cost, compose cleanly, and reinforce each other's signal. Defer (c) to its own design cycle. Sub-option (a) is a natural ride-along with #16's `OnboardingView` work since it touches the same file.

**Origin:** suggested 2026-05-06 after #21 shipped, in conversation following Josh's "banner feature like this deserves highlighting" reaction to the brain-pulse animation.

---

## Cross-Cutting Design System Additions

### A. Card-elevation modifier suite

**Status:** Resolved 2026-05-06 (commit `92d5043` for the API; #2/#3 resolutions on the same day for the migration). See "Resolution" block at the end of this section.

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

**Resolution (commit `92d5043` + 2026-05-06):**

Shipped in `Konjugieren/Utils/Modifiers.swift`: `KonjCard` (lines 169-180) and `KonjCardWithAccentBar` (lines 182-195) with the public `View` extensions at lines 51-57. Both use the `customCardBackground` (#19) and `customCardBorder` (#20) named color assets, also added in commit `92d5043`.

The recommended snippet shipped verbatim, plus a third modifier `konjCardRim()` for sites that want the rim without surrendering their background or padding. The suite is **opt-in, not enforced** — callers pick from three modifiers based on which parts they want to delegate:

- `konjCard()` — full padding + `customCardBackground` + clip + rim. The default.
- `konjCardWithAccentBar(_:)` — same as `konjCard()` plus the 2pt yellow leading-edge accent. Used by `ConjugationSectionView`.
- `konjCardRim()` — just the rim overlay. The caller keeps its own padding, background, and clip. Used by `InfoBrowseView`'s `TutorRowView` to preserve its `Color.customYellow.opacity(0.05)` tint background (the row's identity).

Migration of all five card call sites to use these modifiers landed 2026-05-06; see the #2 and #3 Resolution blocks for the per-site diff and visual confirmation.

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
| `Konjugieren/Utils/Modifiers.swift` | Card-elevation modifiers (#A — done); GradientDivider lift (#17) |
| `Konjugieren/Utils/Layout.swift` | Possibly card-corner-radius constant if standardizing |
| `Konjugieren/Assets/Assets.xcassets` | Color assets `customCardBackground`, `customCardBorder` (#19, #20 — done) |

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
5. **Test suite**: `"$IBV_SCRIPTS/run_tests.sh"` (set `IBV_SCRIPTS` per the "Driving the simulator" section above). None of the suggestions touch test-coverable logic, but the test suite should pass cleanly post-change.

---

## Implementation order recommendation

If implementing more than one suggestion, this order minimizes rework:

1. ~~**#19 + #20** (color assets) — establishes naming.~~ *Done in commit `92d5043`.*
2. ~~**#A** (card modifiers in `Modifiers.swift`) — establishes API.~~ *Done in commit `92d5043`.*
3. ~~**#2 + #3** (apply unified card treatment everywhere) — uses #A.~~ *Done 2026-05-06.*
4. ~~**#1** (fix `[?]` glyph bug) — independent, can ship anytime.~~ *Done 2026-05-05.*
5. ~~**#6 + #11** (card-wrap remaining sections) — uses #A.~~ *Done 2026-05-06.*
6. ~~**#13** (subheading treatment) — affects all rich-text screens; do once #6/#11 land so the visual context is consistent.~~ *Done 2026-05-06.*
7. ~~**#4 / #5 / #22 / #10** (Quiz polish) — independent of card system.~~ *Done 2026-05-06.*
8. ~~**#7 / #8(a)** (Settings polish) — independent.~~ *Done 2026-05-06. #8(b) deferred.*
9. **~~#9~~ / ~~#14~~ / ~~#16~~ / ~~#17~~ / ~~#21~~** — small independent items. *#9 done 2026-05-06. #14 done 2026-05-06. #16 done 2026-05-06. #17 done 2026-05-06. #21 done 2026-05-06.*
10. Skip / defer **#23 / #24** unless explicit user feedback motivates them.
11. **#25** — Tutor feature highlighting (extends #21). Sub-option (a) is a natural ride-along with #16's `OnboardingView` work; (b) is a small standalone TipKit addition; (c) is a bigger `InfoBrowseView` redesign for a future cycle.
