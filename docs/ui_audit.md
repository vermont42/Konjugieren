# Konjugieren UI Audit — Frontend Design Skill Applied to iOS

## Context

This audit translates Anthropic's Frontend Design Skill — a web-design critique methodology emphasizing bold aesthetic direction, typography, color cohesion, spatial composition, motion, and atmospheric depth — into actionable SwiftUI suggestions for Konjugieren. Every recommendation is grounded in the app's actual code and screenshots.

**Constraints:** System fonts only (SF Pro). Game and Dedication screens are off-limits. Audit only — no code changes.

---

## Overall Assessment

### Strengths
- **German-flag color system (yellow/red/black)** serves a precise educational function: yellow = regular, red = ablaut. Distinctive and memorable.
- **Consistent modifier system** (`Modifiers.swift`) enforces styling discipline across 16 views.
- **FamilyBrowseView showcase cards** are the strongest design element — conjugation previews, capsule verb chips, decoration images. The rest of the app should aspire to this level.
- **Accessibility is thorough** — pronunciation modifiers, speakOnTap, reduceMotion checks.
- **Adaptive layouts** via `horizontalSizeClass` throughout.

### Areas for Growth
- **Flat uniformity** — most screens are unstyled lists on a flat background with no depth cues, cards, or surface variation.
- **Color underutilization** — only 4 colors. No tertiary color, no surface tints, no subtle variations.
- **The Quiz screen** is the weakest — a sparse form with vast empty space on the screen where users spend the most active time.
- **Typography is functional but undifferentiated** — no use of SF Pro's design axes (`.serif`, `.rounded`, `.monospaced`) to create contrast between content types.

---

## High-Priority Suggestions (implement first)

### 1. Quiz: Card Framing + Progress Bar
**Screen:** `QuizView.swift`
**Problem:** Content pins to top with empty black below. No structural framing. The Quit button floats at the bottom.
**Suggestions:**
- Wrap quiz content in a card: `RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground))` with padding
- Add a `ProgressView(value:total:).tint(.customYellow)` progress bar at the top of the card
- Display the verb infinitive at `.font(.title.bold())` as a focal point instead of a small labeled field
- Move Quit into `.toolbar { ToolbarItem(placement: .cancellationAction) }`
- Compact the progress/score/elapsed into a horizontal stats bar with `.font(.caption.monospaced())`

### 2. Quiz: Correct/Incorrect Micro-interactions
**Screen:** `QuizView.swift`
**Problem:** No visual or haptic feedback on answer submission.
**Suggestions:**
- On correct: brief checkmark animation via `.transition(.scale.combined(with: .opacity))` + `.sensoryFeedback(.success, trigger: correctCount)`
- On incorrect: shake the text field with `PhaseAnimator` or keyframe offset + `.sensoryFeedback(.error, trigger: incorrectCount)` + briefly stroke the card border in `.customRed`
- Replace the pulsing scale animation (currently scales to 2.5x which is jarring) with `.symbolEffect(.pulse.byLayer)` on an SF Symbol inside the Start button

### 3. Verb Detail: Conjugation Section Cards + Accent Bars
**Screen:** `VerbView.swift`
**Problem:** Conjugation sections blend together on a flat background. No visual separation between Präsens Indikativ, Präteritum, etc.
**Suggestions:**
- Wrap each `ConjugationSectionView` in a card: `.padding().background(Color(.secondarySystemBackground).opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 12))`
- Add a 2pt vertical accent bar on the left of each section: `.overlay(alignment: .leading) { Rectangle().fill(.customYellow.opacity(0.3)).frame(width: 2) }`
- Use `.font(.subheadline.smallCaps().weight(.semibold))` for conjugationgroup headings to visually separate structural labels from content

### 4. Info Detail: Serif Title + Reading Width
**Screen:** `InfoView.swift`
**Problem:** Long essays stretch full-width on iPad. Titles use the same font as navigation chrome.
**Suggestions:**
- Add `.fontDesign(.serif)` to `Text(info.heading).font(.largeTitle.bold())` — gives articles a literary/journal feel
- Constrain reading width on iPad: `.frame(maxWidth: 680)` centered
- Add `.lineSpacing(4)` to `BodyTextView` for improved long-form readability
- Add a decorative ornament (three small circles in black-red-gold) between title/photo and body text

### 5. Settings: Visual Section Grouping
**Screen:** `SettingsView.swift`
**Problem:** All settings run together in one undifferentiated scroll. Hard to parse.
**Suggestions:**
- Group into cards: "Display" (conjugationgroup lang, pronoun, search scope), "Quiz" (difficulty, audio), "Actions" (leaderboard, onboarding, game, rate)
- Each card: `.padding().background(Color(.secondarySystemBackground).opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 12))`
- Replace the dot-pattern separator with a thin horizontal gradient line: `LinearGradient(colors: [.clear, .customYellow.opacity(0.3), .clear], ...)` in a 1pt `Rectangle`

### 6. Results: Large Score Display
**Screen:** `ResultsView.swift`
**Problem:** The score is just another labeled text line. No emotional payoff.
**Suggestions:**
- Display score at `.font(.system(size: 48, weight: .bold, design: .rounded))` as the focal point
- Color-code by performance: green >80%, yellow 50–80%, red <50%
- Frame summary stats in a card, visually separated from the scrollable results list
- Animate score counting up from 0 using `.contentTransition(.numericText())`

### 7. Tutor: Fix Invisible Assistant Bubbles
**Screen:** `TutorView.swift:260`
**Problem:** Assistant bubbles use `Color.customBackground` which is identical to the screen background — they visually disappear.
**Fix:** Change `Color.customBackground` to `Color(.secondarySystemBackground)` in the assistant bubble `.fill()`.

### 8. Verb List: Empty-State View
**Screen:** `VerbBrowseView.swift`
**Problem:** Searching with no results shows a blank screen.
**Fix:** Add `ContentUnavailableView` (iOS 17+) with a `magnifyingglass` symbol and a brief message when `filteredVerbs.isEmpty`.

---

## Medium-Priority Suggestions (second pass)

### 9. Cross-Cutting: Adopt `.fontDesign(.serif)` for Linguistic Content
Use SF Serif (available since iOS 17) for verb infinitives in `VerbView`, conjugationgroup names, and article titles. Creates immediate visual distinction between "linguistic content" and "UI chrome" without custom fonts.

### 10. Cross-Cutting: Add `.sensoryFeedback()` Modifiers
- `.sensoryFeedback(.success, trigger:)` / `.sensoryFeedback(.error, trigger:)` in QuizView
- `.sensoryFeedback(.selection, trigger: sortOrder)` in VerbBrowseView
- `.sensoryFeedback(.impact(weight: .light), trigger: currentPage)` in OnboardingView

### 11. Verb Detail: Speak-on-Tap Flash
When a conjugation is tapped to hear pronunciation, briefly flash the row background (0.15s yellow pulse) as visual confirmation. Use a `@State var isSpeaking` bool with `.background(Color.customYellow.opacity(isSpeaking ? 0.15 : 0)).animation(.easeOut(duration: 0.15))`.

### 12. Verb Detail: Metadata Pills
Give the metadata tags (family, auxiliary, frequency) pill-shaped backgrounds: `.padding(.horizontal, 8).padding(.vertical, 4).background(Color.customYellow.opacity(0.08)).clipShape(Capsule())`.

### 13. Verb List: Sort Animation
Add `.contentTransition(.numericText())` or wrap sort-order changes in `withAnimation(.easeInOut(duration: 0.3))` so the list visibly reorders rather than snapping.

### 14. Verb List: Verb Count Banner
Add a compact header above the list: "247 Verben" in `.font(.caption.smallCaps())` to convey scale.

### 15. Family Detail: Sticky Headers + Chevron Animation
- Use `.pinnedViews([.sectionHeaders])` with `LazyVStack` for ablaut group headers
- Animate chevron rotation: single `Image(systemName: "chevron.right").rotationEffect(.degrees(isExpanded ? 90 : 0))` instead of swapping images

### 16. Info List: Distinct Tutor Row
The Tutor row is interactive (chat), not a static article. Give it a card background: `.background(Color.customYellow.opacity(0.05)).clipShape(RoundedRectangle(cornerRadius: 12))` to signal its different nature.

### 17. Tutor: Message Animations + Typing Indicator
- Animate new bubbles in with `.transition(.move(edge: .bottom).combined(with: .opacity))`
- Show a typing indicator (three animated dots via `PhaseAnimator`) while `isGenerating`

### 18. Onboarding: Symbol Bounce
Apply `.symbolEffect(.bounce, value: currentPage)` to each page's SF Symbol for a moment of life on page change.

---

## Low-Priority Suggestions (polish pass)

### 19. Cross-Cutting: Scroll Transitions
`.scrollTransition(.animated) { content, phase in content.opacity(1 - abs(phase.value) * 0.15) }` on list rows for subtle fade-at-edges effect.

### 20. Cross-Cutting: Define `customYellowSubtle` Color Asset
Many suggestions use `Color.customYellow.opacity(0.05)`. Define this as a named asset for consistency.

### 21. Verb List: Alternating Row Tint
Every other row gets `.background(Color.customYellow.opacity(0.03))` in light / `0.05` in dark.

### 22. Verb List: Frequency Rank Numbers
Display `#N` in `.font(.caption.monospaced())` to the left of each row as a visual anchor.

### 23. Family List: Gradient Card Backgrounds
Replace flat `Color.white.opacity(0.05)` in showcase cards with `LinearGradient(colors: [.customYellow.opacity(0.05), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)`.

### 24. Info Detail: Photo Parallax
Apply `.scrollTransition { content, phase in content.scaleEffect(1 + phase.value * 0.05) }` to article photos.

---

## Cross-Cutting Design System Addition

**Introduce a surface color.** The app currently uses only pure black and pure white backgrounds. Adding `Color(.secondarySystemBackground)` (or a custom `customSurface` asset at ~`#1C1C1E` dark / `#F2F2F7` light) unlocks every card-treatment suggestion above. This single addition is the foundation for suggestions 1, 3, 5, 6, and 7.

---

## Critical Files

| File | Relevance |
|------|-----------|
| `Views/QuizView.swift` | Highest-impact redesign target |
| `Views/VerbView.swift` | Core educational screen — cards + serif |
| `Views/InfoView.swift` | Serif title + reading width |
| `Views/SettingsView.swift` | Section grouping |
| `Views/ResultsView.swift` | Score display |
| `Views/TutorView.swift:260` | Invisible bubble fix |
| `Views/VerbBrowseView.swift` | Empty state + sort animation |
| `Utils/Modifiers.swift` | Central style definitions |
| `Utils/Layout.swift` | May need new card-padding constants |
| `Views/RichTextView.swift` | Line spacing for body text |

---

## Verification

Since this is an audit (no code changes), verification means reviewing each suggestion against:
1. The relevant screenshot to confirm the problem exists
2. The actual SwiftUI code to confirm the suggested API/modifier is applicable
3. iOS version compatibility (all suggestions use iOS 17+ APIs, which the app already targets)
